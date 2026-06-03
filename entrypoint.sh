#!/bin/sh
set -eu

# ---------------------------------------------------------------------------
# Validate HOST_NAME
# ---------------------------------------------------------------------------

if [ -z "${HOST_NAME:-}" ]; then
  echo "Error: HOST_NAME environment variable is not set." >&2
  exit 1
fi

# Guard against path traversal (e.g. HOST_NAME="../../etc").
# Only alphanumeric characters, hyphens, underscores, and dots are allowed.
case "$HOST_NAME" in
  *[!a-zA-Z0-9._-]*)
    echo "Error: HOST_NAME contains invalid characters. Only alphanumeric, hyphens, underscores, and dots are permitted." >&2
    exit 1
    ;;
esac

# ---------------------------------------------------------------------------
# Validate log directory
# ---------------------------------------------------------------------------

LOG_DIR="/host_syslog/$HOST_NAME"

if [ ! -d "$LOG_DIR" ]; then
  echo "Error: Log directory $LOG_DIR does not exist." >&2
  exit 1
fi

# Verify at least one .log file is present before proceeding.
# Using set -- to expand the glob; if nothing matches, $1 will be the literal
# pattern string which is not a regular file.
set -- "$LOG_DIR"/*.log
if [ ! -f "$1" ]; then
  echo "Error: No .log files found in $LOG_DIR." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Build 3-day log snapshot
# ---------------------------------------------------------------------------

# Calculate the date three days ago (requires GNU date from coreutils)
start_date=$(date -d "@$(($(date +%s) - 3 * 86400))" '+%Y-%m-%d')

# Filter lines from the past three days into a snapshot file.
# $@ is now the expanded list of .log files (safe, no literal glob string).
awk -v start_date="$start_date" '
  {
    log_date = $1 " " $2
    if (log_date >= start_date) print
  }
' "$@" > /logs/three_days_logs.log

# ---------------------------------------------------------------------------
# Stream live logs
# ---------------------------------------------------------------------------

# Tail all .log files and merge their output into a single stdout stream.
exec tail -f -n +1 "$@"
