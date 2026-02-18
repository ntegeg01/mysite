#!/bin/zsh
set -euo pipefail

ENDPOINT="${TEST_BOOKING_ENDPOINT:-https://formspree.io/f/mkgqbnlv}"
TOTAL="${1:-20}"
PARALLEL=2

FIRST_NAMES=("Liam" "Noah" "Mason" "Ethan" "Lucas" "Elijah" "James" "Benjamin" "Henry" "Jack" "Oliver" "William" "Alexander" "Michael" "Daniel" "Matthew" "Joseph" "Samuel" "David" "Carter" "Owen" "Wyatt" "John" "Luke" "Dylan" "Anthony" "Isaac" "Ryan" "Nathan" "Caleb" "Adrian" "Eli" "Aaron" "Landon" "Thomas" "Charles" "Josiah" "Christopher" "Isaiah" "Andrew" "Sebastian" "Jaxon" "Julian" "Brayden" "Gavin" "Levi" "Joshua" "Ezra" "Lincoln" "Mateo" "Hunter" "Jackson" "Asher" "Aiden" "Logan" "Grayson" "Jayden" "Camden" "Dominic" "Colton" "Austin" "Robert" "Chase" "Everett" "Jordan" "Ian" "Xavier" "Cooper" "Miles" "Sawyer" "Leonardo" "Roman" "Axel" "Wesley" "Kayden" "Declan" "Emmett" "Silas" "Bennett" "Tristan" "Cole" "Carson" "Jace" "Theodore" "Nolan" "Blake" "Brody" "Max" "Ryder" "Hudson" "Bentley" "Damian" "Brady" "Zane" "Easton" "Kevin" "Jonah" "Marcus" "Vincent" "Bryson" "Griffin" "Micah" "Preston" "Kyle" "Grant" "Gage" "Zachary" "Tyler" "Milo" "Jude" "Rowan" "Finn" "Spencer" "Felix" "Connor" "Jasper" "Atticus" "Reid" "Cruz" "Harrison" "Elliot" "Arthur" "Emilio" "Andres" "Brooks" "Paxton" "Remington" "Weston" "Knox" "Lukas" "Phoenix" "Tobias" "Nico" "Maddox" "Bryce" "Tanner" "Cesar" "Warren" "Jaden" "Braxton" "Colin" "Derek" "Alejandro" "Eduardo" "Mario" "Fernando" "Rafael" "Diego" "Omar" "Malik" "Darius" "Devin" "Trey" "Jalen" "Andre" "Devon" "Cody" "Trevor" "Brock" "Peyton" "Landon" "Dawson" "Caden" "Zion" "River" "Remy" "August" "Beckett" "Rhett" "Hayden" "Maverick" "Ace" "Crew" "Soren" "Theo" "Emerson" "Sterling" "Arlo" "Colt" "Wade" "Tatum" "Zack" "Brett" "Shane" "Seth" "Garrett" "Bradley" "Lance" "Jaxson" "Kyler" "Aden" "Ryker" "Kaiden" "Corbin" "Kristopher" "Sergio" "Manuel" "Miguel" "Pablo" "Carlos" "Luis" "Juan" "Antonio" "Hector" "Ricardo" "Victor" "Roberto" "Pedro" "Raul" "Ivan" "Jorge" "Marco" "Angelo" "Dante" "Luca" "Matteo" "Gianni" "Enzo" "Rocco" "Dario" "Fabio" "Salvatore" "Bruno" "Francesco" "Kai" "Riku" "Hiroshi" "Kenji" "Takeshi" "Yuki" "Haruki" "Soren" "Lars" "Erik" "Bjorn" "Henrik" "Magnus" "Leif" "Gunnar" "Rashid" "Tariq" "Jamal" "Kareem" "Hakeem" "Idris" "Kwame" "Kofi" "Desmond" "Elijah" "Tunde" "Emeka" "Chidi" "Obinna" "Nnamdi")

LAST_NAMES=("Johnson" "Williams" "Brown" "Jones" "Garcia" "Miller" "Wilson" "Moore" "Taylor" "Anderson" "Thomas" "Jackson" "White" "Harris" "Martin" "Thompson" "Martinez" "Robinson" "Clark" "Rodriguez" "Lewis" "Lee" "Walker" "Hall" "Allen" "Young" "Hernandez" "King" "Wright" "Lopez" "Hill" "Scott" "Green" "Adams" "Baker" "Gonzalez" "Nelson" "Carter" "Mitchell" "Perez" "Roberts" "Turner" "Phillips" "Campbell" "Parker" "Evans" "Edwards" "Collins" "Stewart" "Sanchez" "Morris" "Rogers" "Reed" "Cook" "Morgan" "Bell" "Murphy" "Bailey" "Rivera" "Cooper" "Richardson" "Cox" "Howard" "Ward" "Torres" "Peterson" "Gray" "Ramirez" "James" "Watson" "Brooks" "Kelly" "Sanders" "Price" "Bennett" "Wood" "Barnes" "Ross" "Henderson" "Coleman" "Jenkins" "Perry" "Powell" "Long" "Patterson" "Hughes" "Flores" "Washington" "Butler" "Simmons" "Foster" "Gonzales" "Bryant" "Alexander" "Russell" "Griffin" "Diaz" "Hayes" "Myers" "Ford" "Hamilton" "Graham" "Sullivan" "Wallace" "Woods" "Cole" "West" "Jordan" "Owens" "Reynolds" "Fisher" "Ellis" "Harrison" "Gibson" "Mcdonald" "Cruz" "Marshall" "Ortiz" "Gomez" "Murray" "Freeman" "Wells" "Webb" "Simpson" "Stevens" "Tucker" "Porter" "Hunter" "Hicks" "Crawford" "Henry" "Boyd" "Mason" "Morales" "Kennedy" "Warren" "Dixon" "Ramos" "Reyes" "Burns" "Gordon" "Shaw" "Holmes" "Rice" "Robertson" "Hunt" "Black" "Daniels" "Palmer" "Mills" "Nichols" "Grant" "Knight" "Ferguson" "Rose" "Stone" "Hawkins" "Dunn" "Perkins" "Hudson" "Spencer" "Gardner" "Stephens" "Payne" "Pierce" "Berry" "Matthews" "Arnold" "Wagner" "Willis" "Ray" "Watkins" "Olson" "Carroll" "Duncan" "Snyder" "Hart" "Cunningham" "Bradley" "Lane" "Andrews" "Ruiz" "Harper" "Fox" "Riley" "Armstrong" "Carpenter" "Weaver" "Greene" "Lawrence" "Elliott" "Chavez" "Sims" "Austin" "Peters" "Kelley" "Franklin" "Lawson" "Fields" "Gutierrez" "Ryan" "Schmidt" "Carr" "Vasquez" "Castillo" "Wheeler" "Chapman" "Oliver" "Montgomery")

PICKUPS=("CLT Airport" "Uptown Charlotte" "SouthPark Mall" "Concord Mills")
DROPOFFS=("Ballantyne Resort" "Whitewater Center" "Mooresville" "Rock Hill")
SPECIAL_REQUESTS=("Need child seat" "Extra luggage (4 bags)" "Flight arriving early" "Wheelchair assistance" "Late-night pickup" "VIP service requested" "No special requests")
AREA_CODES=("704" "980" "803" "336" "910")

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
  local area="${AREA_CODES[$((RANDOM % ${#AREA_CODES[@]} + 1))]}"
  local phone="${area}-$((RANDOM % 900 + 100))-$((RANDOM % 9000 + 1000))"
  local email="${first:l}.${last:l}$((RANDOM % 9000 + 1000))@gmail.com"

  sleep $((RANDOM % 4 + 1))

  local status=$(curl -s -o /dev/null -w "%{http_code}" -L -X POST "$ENDPOINT" \
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
    --data-urlencode "special_requests=${special}")

  if [[ "$status" == "200" || "$status" == "302" ]]; then
    echo "✅ [$status] ${name} | ${phone} | ${pickup} → ${dropoff} | ${pickup_date} ${pickup_time}"
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



