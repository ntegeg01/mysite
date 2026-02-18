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

# Cron needs an explicit PATH since it runs with a bare environment
CRON_LINE="0 9 */3 * * PATH=/usr/local/bin:/usr/bin:/bin TEST_BOOKING_ENDPOINT=https://formspree.io/f/mkgqbnlv $SCRIPT_PATH >> $LOG_PATH 2>&1"

TMP_FILE="$(mktemp)"

# Use grep instead of rg (ripgrep not guaranteed to be installed)
crontab -l 2>/dev/null | grep -v "test-booking.sh" > "$TMP_FILE" || true

echo "$CRON_LINE" >> "$TMP_FILE"
crontab "$TMP_FILE"
rm -f "$TMP_FILE"

# Verify it actually got installed
if crontab -l 2>/dev/null | grep -q "test-booking.sh"; then
  echo "✅ Cron job installed successfully:"
  echo "   $CRON_LINE"
else
  echo "❌ Cron job installation failed"
  exit 1
fi