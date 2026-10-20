-- Media MVP state store
-- Apply to a dedicated PostgreSQL database before enabling scheduled runs.
-- The schema is intentionally independent from n8n/Postiz internal tables.

CREATE TABLE IF NOT EXISTS source_items (
  id BIGSERIAL PRIMARY KEY,
  source_name TEXT NOT NULL,
  guid TEXT NOT NULL,
  url TEXT NOT NULL,
  url_hash TEXT NOT NULL,
  title TEXT NOT NULL,
  published_at TIMESTAMPTZ,
  raw_excerpt TEXT,
  content_hash TEXT NOT NULL,
  first_seen_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_seen_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  status TEXT NOT NULL DEFAULT 'discovered'
    CHECK (status IN ('discovered', 'eligible', 'rejected', 'failed')),
  UNIQUE (source_name, guid),
  UNIQUE (url_hash)
);

CREATE TABLE IF NOT EXISTS content_drafts (
  id BIGSERIAL PRIMARY KEY,
  source_item_id BIGINT REFERENCES source_items(id),
  pillar TEXT CHECK (pillar IN ('mo_hinh_thuc_te', 'kien_thuc_khoa_hoc', 'meo_ap_dung_ngay')),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  claims_json JSONB NOT NULL DEFAULT '[]'::jsonb,
  uncertainties_json JSONB NOT NULL DEFAULT '[]'::jsonb,
  safety_note TEXT NOT NULL,
  source_url TEXT NOT NULL,
  model_name TEXT,
  prompt_version TEXT,
  status TEXT NOT NULL DEFAULT 'drafted'
    CHECK (status IN ('drafted', 'needs_review', 'approved', 'rejected', 'scheduled', 'published', 'failed')),
  reviewer TEXT,
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (status NOT IN ('approved', 'scheduled', 'published') OR (reviewer IS NOT NULL AND approved_at IS NOT NULL))
);

CREATE TABLE IF NOT EXISTS publishing_jobs (
  id BIGSERIAL PRIMARY KEY,
  draft_id BIGINT NOT NULL REFERENCES content_drafts(id),
  destination TEXT NOT NULL,
  provider_post_id TEXT,
  idempotency_key TEXT NOT NULL UNIQUE,
  scheduled_at TIMESTAMPTZ,
  published_at TIMESTAMPTZ,
  attempts INTEGER NOT NULL DEFAULT 0,
  claimed_at TIMESTAMPTZ,
  last_error_code TEXT,
  last_error_message TEXT,
  status TEXT NOT NULL DEFAULT 'queued'
    CHECK (status IN ('queued', 'publishing', 'scheduled', 'published', 'failed'))
);

CREATE TABLE IF NOT EXISTS audit_events (
  id BIGSERIAL PRIMARY KEY,
  entity_type TEXT NOT NULL,
  entity_id BIGINT NOT NULL,
  event_type TEXT NOT NULL,
  actor_type TEXT NOT NULL CHECK (actor_type IN ('rss', 'ai', 'human', 'system')),
  actor_id TEXT,
  payload_json JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_source_items_published_at ON source_items (published_at);
CREATE INDEX IF NOT EXISTS idx_source_items_status ON source_items (status);
CREATE INDEX IF NOT EXISTS idx_content_drafts_status ON content_drafts (status);
CREATE INDEX IF NOT EXISTS idx_audit_events_entity ON audit_events (entity_type, entity_id, created_at);

-- Prevent repeated RSS runs from creating duplicate active drafts for the same
-- source/prompt. Rejected or failed drafts may be regenerated deliberately.
CREATE UNIQUE INDEX IF NOT EXISTS ux_content_drafts_source_prompt_active
  ON content_drafts (source_item_id, prompt_version)
  WHERE status NOT IN ('rejected', 'failed');

-- The reviewer calls this function after inspecting the draft. It makes the
-- approval invariant and publishing queue insertion one atomic operation.
CREATE OR REPLACE FUNCTION approve_content_draft(
  p_draft_id BIGINT,
  p_reviewer TEXT,
  p_destination TEXT DEFAULT 'facebook_page'
) RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
  v_source_url TEXT;
  v_job_id BIGINT;
BEGIN
  IF NULLIF(trim(p_reviewer), '') IS NULL THEN
    RAISE EXCEPTION 'reviewer is required';
  END IF;

  UPDATE content_drafts
  SET status = 'approved', reviewer = p_reviewer, approved_at = now(), updated_at = now()
  WHERE id = p_draft_id AND status = 'needs_review'
  RETURNING source_url INTO v_source_url;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'draft % is missing or is not in needs_review state', p_draft_id;
  END IF;

  INSERT INTO publishing_jobs(draft_id, destination, idempotency_key, status)
  VALUES (p_draft_id, p_destination, 'draft:' || v_source_url, 'queued')
  ON CONFLICT (idempotency_key) DO UPDATE
    SET draft_id = EXCLUDED.draft_id, destination = EXCLUDED.destination,
        status = 'queued', attempts = 0, claimed_at = NULL,
        last_error_code = NULL, last_error_message = NULL
  RETURNING id INTO v_job_id;

  INSERT INTO audit_events(entity_type, entity_id, event_type, actor_type, actor_id, payload_json)
  VALUES ('content_draft', p_draft_id, 'approved', 'human', p_reviewer,
          jsonb_build_object('destination', p_destination, 'publishing_job_id', v_job_id));
  RETURN v_job_id;
END;
$$;
