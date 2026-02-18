#!/bin/zsh
set -euo pipefail

ENDPOINT="${TEST_BOOKING_ENDPOINT:-https://formspree.io/f/xjgeoowv}"

# How many bookings to send
TOTAL="${1:-20}"          # default 20 if not provided
PARALLEL=5                # number of parallel workers

FIRST_NAMES=("Liam" "Noah" "Mason" "Ethan" "Lucas" "Elijah" "James" "Benjamin" "Henry" "Jack" "Oliver" "William")
LAST_NAMES=("Johnson" "Williams" "Brown" "Jones" "Garcia" "Miller" "Wilson" "Moore" "Taylor" "Anderson" "Thomas" "Jackson")
PICKUPS=("CLT Airport" "Uptown Charlotte" "SouthPark Mall" "Concord Mills")
DROPOFFS=("Ballantyne Resort" "Whitewater Center" "Mooresville" "Rock Hill")
SPECIAL_REQUESTS=("Need child seat" "Extra luggage (4 bags)" "Flight arriving early" "Wheelchair assistance" "Late-night pickup" "VIP service requested" "No special requests")
AIRLINES=("AA" "DL" "UA" "SW" "B6")

submit_booking() {

  first="${FIRST_NAMES[$((RANDOM % ${#FIRST_NAMES[@]} + 1))]}"
  last="${LAST_NAMES[$((RANDOM % ${#LAST_NAMES[@]} + 1))]}"
  name="${first} ${last}"

  pickup="${PICKUPS[$((RANDOM % ${#PICKUPS[@]} + 1))]}"
  dropoff="${DROPOFFS[$((RANDOM % ${#DROPOFFS[@]} + 1))]}"
  special="${SPECIAL_REQUESTS[$((RANDOM % ${#SPECIAL_REQUESTS[@]} + 1))]}"

  days_ahead=$((RANDOM % 14 + 1))
  pickup_date="$(date -v+${days_ahead}d '+%Y-%m-%d')"

  hour=$((RANDOM % 12 + 1))
  minute=$(printf "%02d" $((RANDOM % 60)))
  ampm=$([ $((RANDOM % 2)) -eq 0 ] && echo "AM" || echo "PM")
  pickup_time="${hour}:${minute} ${ampm}"

  passengers=$((RANDOM % 4 + 1))
  airline="${AIRLINES[$((RANDOM % ${#AIRLINES[@]} + 1))]}"
  flight_number="${airline}$((RANDOM % 9000 + 1000))"

  email="${first:l}.${last:l}$((RANDOM % 9000 + 1000))@gmail.com"
  phone="$((RANDOM % 900 + 100))-$((RANDOM % 900 + 100))-$((RANDOM % 9000 + 1000))"

  status=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$ENDPOINT" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "name=${name}" \
    --data-urlencode "email=${email}" \
    --data-urlencode "phone=${phone}" \
    --data-urlencode "pickup=${pickup}" \
    --data-urlencode "dropoff=${dropoff}" \
    --data-urlencode "pickup_date=${pickup_date}" \
    --data-urlencode "pickup_time=${pickup_time}" \
    --data-urlencode "passengers=${passengers}" \
    --data-urlencode "flight_number=${flight_number}" \
    --data-urlencode "special_requests=${special}" \
    --data-urlencode "message=Booking load test")

  echo "$status"
}

echo "🚀 Starting load test..."
echo "Total bookings: $TOTAL"
echo "Parallel workers: $PARALLEL"
echo ""

success=0
fail=0

for ((i=1; i<=TOTAL; i++)); do
  submit_booking &
  
  if (( i % PARALLEL == 0 )); then
    wait
  fi
done

wait

echo ""
echo "✅ Load test complete."
