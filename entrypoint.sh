#!/bin/sh

# Ensure the required environment variable is set
if [ -z "$HOST_NAME" ]; then
  echo "Error: HOST_NAME environment variable is not set."
  exit 1
fi

# Calculate the date three days ago
start_date=$(date -d "@$(($(date +%s) - 3 * 86400))" '+%Y-%m-%d')

LOG_DIR="/host_syslog/$HOST_NAME"

if [ ! -d "$LOG_DIR" ]; then
  echo "Error: Log directory $LOG_DIR does not exist."
  exit 1
fi

# Concatenate and filter logs from all .log files in the host's directory for the past three days
awk -v start_date="$start_date" '
  {
    log_date = $1 " " $2
    if (log_date >= start_date) print
  }
' "$LOG_DIR"/*.log > /logs/three_days_logs.log

# Tail all .log files in the host's directory and merge output into a single stream
tail -f -n +1 "$LOG_DIR"/*.log
