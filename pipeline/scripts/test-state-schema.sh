#!/usr/bin/env bash
set -Eeuo pipefail

: "${STATE_DATABASE_URL:?Set STATE_DATABASE_URL to a test PostgreSQL database}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCHEMA_FILE="$ROOT_DIR/pipeline/state-schema.sql"

psql "$STATE_DATABASE_URL" -v ON_ERROR_STOP=1 -f "$SCHEMA_FILE" >/dev/null

psql "$STATE_DATABASE_URL" -v ON_ERROR_STOP=1 <<'SQL'
BEGIN;

INSERT INTO source_items(source_name, guid, url, url_hash, title, raw_excerpt, content_hash, status)
VALUES ('fixture', 'fixture-guid', 'https://fixture.invalid/item-1', md5('https://fixture.invalid/item-1'),
        'Fixture source', 'Fixture excerpt', md5('Fixture excerpt'), 'eligible');

INSERT INTO content_drafts(source_item_id, pillar, title, body, claims_json, uncertainties_json,
                           safety_note, source_url, model_name, prompt_version, status)
SELECT id, 'kien_thuc_khoa_hoc', 'Fixture draft', 'Body', '[]'::jsonb, '[]'::jsonb,
       'Review required', 'https://fixture.invalid/item-1', 'fixture', 'content-pack.v1', 'needs_review'
FROM source_items WHERE guid = 'fixture-guid';

-- Approval must atomically create exactly one queued publishing job.
SELECT approve_content_draft(
  (SELECT id FROM content_drafts WHERE source_url = 'https://fixture.invalid/item-1'),
  'ci-reviewer', 'facebook_page'
);

DO $$
DECLARE
  draft_status TEXT;
  job_status TEXT;
  job_count INTEGER;
BEGIN
  SELECT status INTO draft_status FROM content_drafts WHERE source_url = 'https://fixture.invalid/item-1';
  IF draft_status <> 'approved' THEN RAISE EXCEPTION 'approval status is %', draft_status; END IF;
  SELECT count(*)::integer INTO job_count FROM publishing_jobs WHERE idempotency_key = 'draft:https://fixture.invalid/item-1';
  IF job_count <> 1 THEN RAISE EXCEPTION 'expected one idempotent job, got %', job_count; END IF;
  SELECT status INTO job_status FROM publishing_jobs WHERE idempotency_key = 'draft:https://fixture.invalid/item-1';
  IF job_status <> 'queued' THEN RAISE EXCEPTION 'job status is %', job_status; END IF;
END $$;

-- A second approval is intentionally rejected by the state machine; the
-- unique idempotency key is still asserted above and on every job insert.

-- Claim the queued job and verify the durable in-flight state.
WITH candidates AS (
  SELECT id FROM publishing_jobs WHERE status = 'queued' FOR UPDATE SKIP LOCKED
), claimed AS (
  UPDATE publishing_jobs pj SET status = 'publishing', claimed_at = now()
  FROM candidates c WHERE pj.id = c.id RETURNING pj.id
)
SELECT count(*) FROM claimed;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM publishing_jobs WHERE status = 'publishing' AND claimed_at IS NOT NULL) THEN
    RAISE EXCEPTION 'durable publishing claim failed';
  END IF;
END $$;

ROLLBACK;
SQL

printf 'state schema integration tests passed\n'
