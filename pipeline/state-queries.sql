-- Operational queries for the independent Media MVP state store.
-- These statements are intentionally parameterized when used by an n8n
-- PostgreSQL node. Do not point them at n8n/Postiz internal databases.

-- 1) Atomically claim candidates before calling the provider. The status
-- transition makes the claim durable after the SELECT transaction ends.
WITH candidates AS (
  SELECT pj.id
  FROM publishing_jobs pj
  JOIN content_drafts cd ON cd.id = pj.draft_id
  WHERE pj.status = 'queued'
    AND cd.status = 'approved'
    AND cd.approved_at IS NOT NULL
    AND cd.reviewer IS NOT NULL
    AND (pj.scheduled_at IS NULL OR pj.scheduled_at <= now())
  ORDER BY pj.id
  FOR UPDATE OF pj SKIP LOCKED
  LIMIT 10
), claimed AS (
  UPDATE publishing_jobs pj
  SET status = 'publishing', claimed_at = now()
  FROM candidates c
  WHERE pj.id = c.id
  RETURNING pj.*
)
SELECT c.id AS publishing_job_id, c.draft_id, c.destination, c.idempotency_key,
       c.scheduled_at, c.attempts, cd.title, cd.body, cd.claims_json,
       cd.uncertainties_json, cd.safety_note, cd.source_url, cd.approved_at,
       cd.reviewer, cd.status AS draft_status
FROM claimed c JOIN content_drafts cd ON cd.id = c.draft_id;

-- 2) Mark a successful provider response. Bind :job_id and :provider_post_id.
UPDATE publishing_jobs
SET status = 'published', provider_post_id = :provider_post_id,
    published_at = now(), attempts = attempts + 1, claimed_at = NULL,
    last_error_code = NULL, last_error_message = NULL
WHERE id = :job_id AND status = 'publishing';

-- 3) Record a retryable failure. Bind :job_id, :error_code and :error_message.
UPDATE publishing_jobs
SET attempts = attempts + 1, claimed_at = NULL,
    last_error_code = :error_code,
    last_error_message = :error_message,
    status = CASE WHEN attempts + 1 >= 3 THEN 'failed' ELSE 'queued' END
WHERE id = :job_id AND status = 'publishing';

-- 4) Audit event template. Bind all :event_* values and keep secrets out of
-- payload_json. A failed job is the dead-letter record for this MVP.
INSERT INTO audit_events(entity_type, entity_id, event_type, actor_type, actor_id, payload_json)
VALUES (:event_entity_type, :event_entity_id, :event_type, 'system', 'n8n', :payload_json::jsonb);

-- 5) Recovery before the claim query: a crashed execution must not block a job forever.
UPDATE publishing_jobs
SET status = 'queued', claimed_at = NULL
WHERE status = 'publishing' AND claimed_at < now() - interval '15 minutes';
