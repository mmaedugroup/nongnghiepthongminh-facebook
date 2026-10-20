#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCHEMA_FILE="$ROOT_DIR/pipeline/state-schema.sql"

if [[ "${1:-}" == "--dry-run" ]]; then
  echo "Dry-run: would apply $SCHEMA_FILE"
  grep -E '^CREATE TABLE|UNIQUE|CHECK \(status' "$SCHEMA_FILE"
  exit 0
fi

: "${STATE_DATABASE_URL:?Set STATE_DATABASE_URL to the dedicated Media MVP PostgreSQL URL}"
command -v psql >/dev/null 2>&1 || {
  echo "psql is required. Run this script on the staging host or install the PostgreSQL client." >&2
  exit 127
}

psql "$STATE_DATABASE_URL" -v ON_ERROR_STOP=1 -f "$SCHEMA_FILE"
echo "State schema applied successfully."
