#!/bin/sh
set -eu

LOG_PATH="${LETSWATCH_STREAM_LOG:-/var/log/nginx/letswatch-stream-access.log}"
ARCHIVE_DIR="${LETSWATCH_STREAM_LOG_ARCHIVE_DIR:-/var/log/nginx/letswatch-stream-archive}"
MAX_BYTES="${LETSWATCH_STREAM_LOG_MAX_BYTES:-1073741824}"
ROTATE_BYTES="${LETSWATCH_STREAM_LOG_ROTATE_BYTES:-134217728}"
RETENTION_DAYS="${LETSWATCH_STREAM_LOG_RETENTION_DAYS:-7}"

mkdir -p "$ARCHIVE_DIR"

if [ -f "$LOG_PATH" ]; then
  size="$(wc -c < "$LOG_PATH" | tr -d ' ')"
  if [ "${size:-0}" -ge "$ROTATE_BYTES" ]; then
    ts="$(date -u +%Y%m%dT%H%M%SZ)"
    rotated="$ARCHIVE_DIR/letswatch-stream-access.$ts.log"
    mv "$LOG_PATH" "$rotated"
    nginx -s reopen >/dev/null 2>&1 || true
  fi
fi

find "$ARCHIVE_DIR" -type f -name 'letswatch-stream-access.*.log' -mtime +"$RETENTION_DAYS" -delete

total="$(find "$ARCHIVE_DIR" -type f -name 'letswatch-stream-access.*.log' -exec sh -c 'total=0; for file do size="$(wc -c < "$file" | tr -d " ")"; total=$((total + size)); done; echo "$total"' sh {} +)"
while [ "${total:-0}" -gt "$MAX_BYTES" ]; do
  oldest="$(find "$ARCHIVE_DIR" -type f -name 'letswatch-stream-access.*.log' -print | sort | head -n 1)"
  if [ -z "$oldest" ]; then
    break
  fi
  rm -f "$oldest"
  total="$(find "$ARCHIVE_DIR" -type f -name 'letswatch-stream-access.*.log' -exec sh -c 'total=0; for file do size="$(wc -c < "$file" | tr -d " ")"; total=$((total + size)); done; echo "$total"' sh {} +)"
done
