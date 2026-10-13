#!/bin/bash
set -euo pipefail


if [ -e "${1:-}" ]; then
    echo "Invalid parameter value" >&2
    echo "Usage: log-archive <log-directory>" >&2
    exit 1
fi

LOG_DIR=$1

if [ ! -d "$LOG_DIR"]; then
    echo "Directory doesn't exist" >&2
    exit 1
fi

ARCHIVE_DIR="/var/log-archive"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
ARCHIVE_NAME="logs_archive_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${ARCHIVE_DIR}/${ARCHIVE_NAME}"
LOG_FILE="${ARCHIVE_DIR}/archive-history.log"

# Creating the Archive Directory if it doesn't exist
mkdir -p $ARCHIVE_DIR

# Creating Archive File with tar
tar -czf "$ARCHIVE_PATH" -C "$LOG_DIR" .

## Here what we are doing is: with -czf Creating Archive with File Path described with ARCHIVE_PATH and then -C to change the directory to $LOG_DIR and then we are using . as if saying tar to compress everything from the current directory which in our case is LOG_DIR. 

# Logging Archival

ARCHIVE_SIZE=$(du -h "$ARCHIVE_PATH" | awk '{print $1}')
RECORD="$(date +"%Y-%m-%d %H:%M:%S") - Archived: ${ARCHIVE_NAME} | Size: ${ARCHIVE_SIZE} | Source: ${LOG_DIR}"

# Append to file and display to console
echo "$RECORD" >> "$LOG_FILE"
echo "Success: $RECORD"

