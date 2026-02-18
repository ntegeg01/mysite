#!/bin/zsh
set -euo pipefail

ROOT="/Users/nebiyutegegne/Documents/New project"
SCRIPT_PATH="${ROOT}/scripts/test-booking.sh"
LOG_PATH="${ROOT}/test-booking.log"

if [[ ! -x "$SCRIPT_PATH" ]]; then
  echo "Script not executable: $SCRIPT_PATH"
  echo "Run: chmod +x \"$SCRIPT_PATH\""
  exit 1
fi

CRON_LINE="0 9 */3 * * TEST_BOOKING_ENDPOINT=https://formspree.io/f/mkgqbnlv \"$SCRIPT_PATH\" >> \"$LOG_PATH\" 2>&1"

TMP_FILE="$(mktemp)"
crontab -l 2>/dev/null | rg -v "test-booking.sh" > "$TMP_FILE" || true
echo "$CRON_LINE" >> "$TMP_FILE"
crontab "$TMP_FILE"
rm -f "$TMP_FILE"

echo "Installed cron job:"
echo "$CRON_LINE"
