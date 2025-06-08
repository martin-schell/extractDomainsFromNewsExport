#!/usr/bin/env bash

# Script for creating a list of domains from the OPML export of Nextcloud News.
# Steps:
# - Extract domains from OPML file
# - Write extracted domains in a file, separated by newline
#
# Log resolving into a log file

SCRIPTNAME=$(basename "$0" | cut -d'.' -f1)
LOG_FILE="$SCRIPTNAME".log

usage() {
  echo "Usage: $0"
  echo "-i, --input <file>  Read OPML export from Nextcloud News"
  echo "-o, --output <file> Output file"
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

# Check if no parameters were passed
if [ $# -eq 0 ]; then
    echo "Error: No arguments provided."
    usage
    exit 1
fi

# Defaults
out_file="$SCRIPTNAME".out

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -i | --input)
      if [[ -z "$2" || "$2" == --* ]]; then
        echo "Error: -i, --input requires a value."
        exit 1
		  elif [[ ! -f "$2" ]]; then
			  echo "ERROR" "$2 does not exist"
			  exit 1
      elif [[ -z "$(ls -A "$2")" ]]; then
        echo "ERROR" "$2 is emtpy"
        exit 1
      fi
      in_file="$2"
      shift 2
      ;;
    -o | --output)
      if [[ -z "$2" || "$2" == --* ]]; then
        echo "Error: -i, --input requires a value."
        exit 1
      fi
      out_file="$2"
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
echo "" > "$out_file"
# Clear the log file
echo "" > "$LOG_FILE"

# Extract domains into an array
domains=$(grep -o 'xmlUrl="https\{0,1\}://[^/"]*' "$in_file" | sed 's/xmlUrl="//' | sed 's|https\{0,1\}://||')

# Collect annotated results into a temp file
for domain in $domains; do
  log "DEBUG" "Add $domain"
  echo "$domain" >> "$out_file"
done

# Remove empty line
sed -i '/^$/d' "$out_file"
# Remove duplicates
sort -u -o "$out_file" "$out_file"