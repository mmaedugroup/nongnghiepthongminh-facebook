#!/usr/bin/env bash
set -Eeuo pipefail

BASE_URL="${POSTIZ_BASE_URL:-http://localhost:5000}"
API_KEY="${POSTIZ_API_KEY:-}"
INTEGRATION_ID="${POSTIZ_FACEBOOK_INTEGRATION_ID:-}"
MODE="${1:---dry-run}"

if [[ "$MODE" == "--dry-run" ]]; then
  cat <<EOF
Dry-run only. No network request and no post will be created.
Base URL: $BASE_URL
Read-only check: GET $BASE_URL/public/v1/integrations
Create endpoint: POST $BASE_URL/public/v1/posts
EOF
  exit 0
fi

[[ "$MODE" == "--check" || "$MODE" == "--create" ]] || {
  echo "Usage: $0 [--dry-run|--check|--create]" >&2
  exit 2
}
: "${API_KEY:?Set POSTIZ_API_KEY only on the staging host}"

if [[ "$MODE" == "--check" ]]; then
  curl --fail-with-body --silent --show-error \
    -H "Authorization: $API_KEY" \
    -H 'Accept: application/json' \
    "$BASE_URL/public/v1/integrations"
  printf '\nPostiz integrations read-only check passed.\n'
  exit 0
fi

[[ "${POSTIZ_CONFIRM_CREATE:-}" == "I_UNDERSTAND_STAGING_POST" ]] || {
  echo "Refusing to create a post. Set POSTIZ_CONFIRM_CREATE=I_UNDERSTAND_STAGING_POST explicitly." >&2
  exit 3
}
: "${INTEGRATION_ID:?Set POSTIZ_FACEBOOK_INTEGRATION_ID for staging}"

payload=$(cat <<JSON
{
  "type": "schedule",
  "date": "$(date -u -d '+15 minutes' '+%Y-%m-%dT%H:%M:%S.000Z')",
  "shortLink": false,
  "tags": [],
  "posts": [{
    "integration": {"id": "$INTEGRATION_ID"},
    "value": [{"content": "NNTT staging contract test — không đăng production.", "image": []}],
    "settings": {"__type": "facebook"}
  }]
}
JSON
)

curl --fail-with-body --silent --show-error \
  -X POST "$BASE_URL/public/v1/posts" \
  -H "Authorization: $API_KEY" \
  -H 'Content-Type: application/json' \
  --data "$payload"
printf '\nPostiz staging create request passed. Save the response with secrets redacted.\n'
