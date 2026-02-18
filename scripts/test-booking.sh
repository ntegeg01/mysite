#!/bin/zsh
set -euo pipefail

ENDPOINT="${TEST_BOOKING_ENDPOINT:-https://formspree.io/f/mkgqbnlv}"
TOTAL="${1:-20}"
PARALLEL=2  # lowered to reduce spam detection

FIRST_NAMES=("Liam" "Noah" "Mason" "Ethan" "Lucas" "Elijah" "James" "Benjamin" "Henry" "Jack" "Oliver" "William")
LAST_NAMES=("Johnson" "Williams" "Brown" "Jones" "Garcia" "Miller" "Wilson" "Moore" "Taylor" "Anderson" "Thomas" "Jackson")
PICKUPS=("CLT Airport" "Uptown Charlotte" "SouthPark Mall" "Concord Mills")
DROPOFFS=("Ballantyne Resort" "Whitewater Center" "Mooresville" "Rock Hill")
SPECIAL_REQUESTS=("Need child seat" "Extra luggage (4 bags)" "Flight arriving early" "Wheelchair assistance" "Late-night pickup" "VIP service requested" "No special requests")
AIRLINES=("AA" "DL" "UA" "SW" "B6")

RESULTS_FILE=$(mktemp)

submit_booking() {
  local first="${FIRST_NAMES[$((RANDOM % ${#FIRST_NAMES[@]} + 1))]}"
  local last="${LAST_NAMES[$((RANDOM % ${#LAST_NAMES[@]} + 1))]}"
  local name="${first} ${last}"
  local pickup="${PICKUPS[$((RANDOM % ${#PICKUPS[@]} + 1))]}"
  local dropoff="${DROPOFFS[$((RANDOM % ${#DROPOFFS[@]} + 1))]}"
  local special="${SPECIAL_REQUESTS[$((RANDOM % ${#SPECIAL_REQUESTS[@]} + 1))]}"
  local days_ahead=$((RANDOM % 14 + 1))
  local pickup_date="$(date -v+${days_ahead}d '+%Y-%m-%d')"
  local hour=$((RANDOM % 12 + 1))
  local minute=$(printf "%02d" $((RANDOM % 60)))
  local ampm=$([ $((RANDOM % 2)) -eq 0 ] && echo "AM" || echo "PM")
  local pickup_time="${hour}:${minute} ${ampm}"
  local passengers=$((RANDOM % 4 + 1))
  local airline="${AIRLINES[$((RANDOM % ${#AIRLINES[@]} + 1))]}"
  local flight_number="${airline}$((RANDOM % 9000 + 1000))"
  local email="${first:l}.${last:l}$((RANDOM % 9000 + 1000))@gmail.com"
  local phone="$((RANDOM % 900 + 100))-$((RANDOM % 900 + 100))-$((RANDOM % 9000 + 1000))"

  # Random delay between 1-4 seconds to avoid rate limiting
  sleep $((RANDOM % 4 + 1))

  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$ENDPOINT" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "name=${name}" \
    --data-urlencode "_replyto=${email}" \
    --data-urlencode "_subject=New Booking Request: ${name}" \
    --data-urlencode "phone=${phone}" \
    --data-urlencode "pickup=${pickup}" \
    --data-urlencode "dropoff=${dropoff}" \
    --data-urlencode "pickup_date=${pickup_date}" \
    --data-urlencode "pickup_time=${pickup_time}" \
    --data-urlencode "passengers=${passengers}" \
    --data-urlencode "flight_number=${flight_number}" \
    --data-urlencode "special_requests=${special}")

  if [[ "$status" == "200" || "$status" == "302" ]]; then
    echo "✅ [$status] ${name} | ${pickup} → ${dropoff} | ${pickup_date} ${pickup_time}"
    echo "ok" >> "$RESULTS_FILE"
  else
    echo "❌ [$status] ${name} | ${pickup} → ${dropoff}"
    echo "fail" >> "$RESULTS_FILE"
  fi
}

echo "🚀 Starting load test..."
echo "   Endpoint : $ENDPOINT"
echo "   Bookings : $TOTAL"
echo "   Workers  : $PARALLEL"
echo ""

for ((i=1; i<=TOTAL; i++)); do
  submit_booking &
  if (( i % PARALLEL == 0 )); then
    wait
  fi
done
wait

success=$(grep -c "^ok$" "$RESULTS_FILE" 2>/dev/null || echo 0)
fail=$(grep -c "^fail$" "$RESULTS_FILE" 2>/dev/null || echo 0)
rm -f "$RESULTS_FILE"

echo ""
echo "─────────────────────────────"
echo "✅ Success : $success"
echo "❌ Failed  : $fail"
echo "📦 Total   : $TOTAL"
echo "─────────────────────────────"



