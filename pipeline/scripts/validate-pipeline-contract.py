#!/usr/bin/env python3
"""Static contract checks for the n8n staging workflows.

These checks do not contact Postiz or PostgreSQL; staging runbook remains the
place for live smoke tests with secrets.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
intake = json.loads((ROOT / 'pipeline/n8n-workflow-content-pipeline.json').read_text())
publish = json.loads((ROOT / 'pipeline/n8n-workflow-publish-approved.json').read_text())
error_workflow = json.loads((ROOT / 'pipeline/n8n-error-handler-workflow.json').read_text())
schema = (ROOT / 'pipeline/state-schema.sql').read_text()
content_schema = json.loads((ROOT / 'pipeline/content-pack.v1.schema.json').read_text())

intake_text = json.dumps(intake, ensure_ascii=False)
publish_text = json.dumps(publish, ensure_ascii=False)
error_text = json.dumps(error_workflow, ensure_ascii=False)
errors = []

def check(condition, message):
    if not condition:
        errors.append(message)

check('/api/posts' not in intake_text, 'Intake must not call legacy /api/posts.')
check('Day ban nhap vao Postiz' not in [n['name'] for n in intake['nodes']], 'Legacy Postiz intake node remains.')
check(intake.get('settings', {}).get('errorWorkflow') == 'NNTT - Error Handler', 'Intake errorWorkflow is not assigned.')
check('provider_publish_blocked' in intake_text and 'approval_required' in intake_text, 'Intake approval boundary is missing.')
check('n8n-nodes-base.postgres' in intake_text and 'state_sql' in intake_text, 'Intake is not connected to the state PostgreSQL node.')
check('content-pack.v1' in intake_text and 'hashtags_json' in intake_text, 'Intake does not persist the content-pack v1 metadata.')
check('/public/v1/posts' in publish_text, 'Publish workflow must use /public/v1/posts.')
check('approved_at' in publish_text and 'reviewer' in publish_text, 'Publish workflow has no approval gate.')
check('n8n-nodes-base.postgres' in publish_text and 'FOR UPDATE OF pj SKIP LOCKED' in publish_text, 'Publish workflow is missing a locked state-store candidate query.')
check('claimed_at' in publish_text and 'Thu hoi job publish bi ket' in publish_text, 'Publish workflow is missing durable claim recovery.')
check('Idempotency-Key' in publish_text, 'Publish workflow has no idempotency header.')
check('hashtags_json' in publish_text, 'Publish workflow does not use persisted hashtags.')
check('continueOnFail' in publish_text and 'Chi bao loi dead-letter' in publish_text, 'Provider failure is not routed through the state updater/dead-letter gate.')
check('retry_policy' in publish_text and ('[30, 120, 600]' in publish_text or '[30,120,600]' in publish_text), 'Retry/dead-letter policy is missing.')
check(publish.get('settings', {}).get('errorWorkflow') == 'NNTT - Error Handler', 'Publish errorWorkflow is not assigned.')
check('UNIQUE (url_hash)' in schema and 'idempotency_key TEXT NOT NULL UNIQUE' in schema, 'State uniqueness constraints are missing.')
check('approved_at IS NOT NULL' in schema and 'reviewer IS NOT NULL' in schema, 'Approval invariant is missing from schema.')
check("'publishing'" in schema and 'claimed_at TIMESTAMPTZ' in schema, 'In-flight publishing state is missing.')
check('ux_content_drafts_source_prompt_active' in schema, 'Active draft dedup index is missing.')
check('approve_content_draft' in schema and "'draft:' || v_source_url" in schema, 'Atomic approval-to-publish function is missing.')
check('audit_sql' in error_text and 'n8n-nodes-base.postgres' in error_text, 'Error Workflow does not persist a state audit event.')
check(content_schema.get('$id', '').endswith('content-pack.v1.schema.json'), 'Content-pack v1 schema is missing or has an invalid id.')

if errors:
    print('\n'.join(f'ERROR: {e}' for e in errors))
    raise SystemExit(1)
print('pipeline contract checks passed')
