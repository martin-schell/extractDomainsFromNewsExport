#!/usr/bin/env bash

# Script for creating a list of domains from the OPML export of Nextcloud News.
# Steps:
# - Extract domains from OPML file
# - Write extracted domains in a file, separated by newline
#
# Log resolving into a log file

SCRIPTNAME=$(basename "$0" | cut -d'.' -f1)
OUT_FILE="$SCRIPTNAME".out
LOG_FILE="$SCRIPTNAME".log

usage() {
  echo "Usage: $0"
  echo "-i, --input <file>  Read OPML export from Nextcloud News"
  echo "-h, --help          Print usage"
}

log() {
    local LEVEL="$1"
    shift
    local MESSAGE="$*"
    local TIMESTAMP
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$TIMESTAMP [$LEVEL] $MESSAGE" >> "$LOG_FILE"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -i | --input)
      in_file="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use -h, --help for usage."
      exit 1
      ;;
  esac
done

# Clear the output files
echo "" > "$OUT_FILE"
# Clear the log file
echo "" > "$LOG_FILE"

# Extract domains into an array
domains=$(grep -o 'xmlUrl="https\{0,1\}://[^/"]*' "$in_file" | sed 's/xmlUrl="//' | sed 's|https\{0,1\}://||')

# Collect annotated results into a temp file
for domain in $domains; do
  log "DEBUG" "Add $domain"
  echo "$domain" >> "$OUT_FILE"
done

# Remove empty line
sed -i '/^$/d' "$OUT_FILE"