#!/usr/bin/env bash
set -Eeuo pipefail

: "${STATE_DATABASE_URL:?Set STATE_DATABASE_URL to the dedicated state database}"
OUTPUT_FILE="${1:-backups/media-state-$(date -u +%Y%m%dT%H%M%SZ).dump}"
mkdir -p "$(dirname "$OUTPUT_FILE")"
umask 077
pg_dump --format=custom --no-owner --no-acl "$STATE_DATABASE_URL" > "$OUTPUT_FILE"
printf 'State backup written to %s\n' "$OUTPUT_FILE"
