#!/usr/bin/env bash
set -Eeuo pipefail

: "${STATE_DATABASE_URL:?Set STATE_DATABASE_URL to the target state database}"
: "${BACKUP_FILE:?Set BACKUP_FILE to a custom-format pg_dump file}"
: "${CONFIRM_STATE_RESTORE:?Set CONFIRM_STATE_RESTORE=I_UNDERSTAND_STATE_RESTORE to continue}"
[[ "$CONFIRM_STATE_RESTORE" == "I_UNDERSTAND_STATE_RESTORE" ]] || {
  echo 'Refusing restore: explicit confirmation is required.' >&2
  exit 3
}
[[ -s "$BACKUP_FILE" ]] || { echo "Backup file missing or empty: $BACKUP_FILE" >&2; exit 4; }
pg_restore --clean --if-exists --no-owner --no-acl --dbname "$STATE_DATABASE_URL" "$BACKUP_FILE"
printf 'State restore completed from %s\n' "$BACKUP_FILE"
