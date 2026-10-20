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
schema = (ROOT / 'pipeline/state-schema.sql').read_text()

intake_text = json.dumps(intake, ensure_ascii=False)
publish_text = json.dumps(publish, ensure_ascii=False)
errors = []

def check(condition, message):
    if not condition:
        errors.append(message)

check('/api/posts' not in intake_text, 'Intake must not call legacy /api/posts.')
check('Day ban nhap vao Postiz' not in [n['name'] for n in intake['nodes']], 'Legacy Postiz intake node remains.')
check(intake.get('settings', {}).get('errorWorkflow') == 'NNTT - Error Handler', 'Intake errorWorkflow is not assigned.')
check('provider_publish_blocked' in intake_text and 'approval_required' in intake_text, 'Intake approval boundary is missing.')
check('/public/v1/posts' in publish_text, 'Publish workflow must use /public/v1/posts.')
check('approved_at' in publish_text and 'reviewer' in publish_text, 'Publish workflow has no approval gate.')
check('Idempotency-Key' in publish_text, 'Publish workflow has no idempotency header.')
check('retry_policy' in publish_text and '[30, 120, 600]' in publish_text, 'Retry/dead-letter policy is missing.')
check(publish.get('settings', {}).get('errorWorkflow') == 'NNTT - Error Handler', 'Publish errorWorkflow is not assigned.')
check('UNIQUE (url_hash)' in schema and 'idempotency_key TEXT NOT NULL UNIQUE' in schema, 'State uniqueness constraints are missing.')
check('approved_at IS NOT NULL' in schema and 'reviewer IS NOT NULL' in schema, 'Approval invariant is missing from schema.')

if errors:
    print('\n'.join(f'ERROR: {e}' for e in errors))
    raise SystemExit(1)
print('pipeline contract checks passed')
