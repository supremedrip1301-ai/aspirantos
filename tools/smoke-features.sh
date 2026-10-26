#!/bin/bash
# Smoke test of Phase 9: landing page (jsp:forward + jsp:include), instant check (JSON),
# About page (jsp-file mapping, init params, application counter), error page, eligibility
# horizon + age clock, calendar and .ics downloads. Needs the WAR deployed on
# http://localhost:8080/AspirantOS. A temporary student is registered and deleted at the end.
B=http://localhost:8080/AspirantOS
D=$(mktemp -d); S=$D/student.txt
TS=$(date +%s); EMAIL="smoke.$TS@test.local"
pass=0; fail=0
ok() { if [ "$1" = "1" ]; then pass=$((pass+1)); echo "PASS  $2"; else fail=$((fail+1)); echo "FAIL  $2  -> $3"; fi; }
has() { [[ "$1" == *"$2"* ]] && echo 1; }
scode() { curl -s -o /dev/null -w "%{http_code} %{redirect_url}" -b $S -c $S "$@"; }
spage() { curl -s -b $S -c $S "$@"; }

# ---- public pages
r=$(curl -s -o $D/home.html -w "%{http_code} %{redirect_url}" $B/); h=$(cat $D/home.html)
ok "$([[ "$r" == "200 " && "$h" == *"Know exactly how many chances you have left"* ]] && echo 1)" "/ forwards to the landing page (no redirect)" "$r"
ok "$([[ "$h" == *"Try it now: UPSC Civil Services"* && "$h" == *"category-tile"* && "$h" == *"Civil Services"* && "$h" == *"<svg class=\"cat-icon\""* ]] && echo 1)" "landing page: instant check form and category tiles with icons" ""
j=$(curl -s "$B/instant-check.jsp?dob=1996-09-15&category=GEN&attempts=4")
ok "$([[ "$j" == *'"ok":true'* && "$j" == *"You have 2 UPSC attempts left, valid until 2028."* ]] && echo 1)" "instant check (sample profile) answers in JSON" "$j"
j=$(curl -s "$B/instant-check.jsp?dob=1992-03-01&category=OBC_NCL&attempts=0&pwbd=true")
ok "$(has "$j" "Base upper age 32 + OBC-NCL 3 + PwBD 10 = 45.")" "instant check: OBC + PwBD relaxation" "$j"
r=$(curl -s -o $D/bad.json -w "%{http_code} %{content_type}" "$B/instant-check.jsp?dob=x&category=GEN"); j=$(cat $D/bad.json)
ok "$([[ "$r" == 400*json* && "$j" == *'"ok":false'* ]] && echo 1)" "instant check: bad date gives a JSON error (400)" "$r $j"
h1=$(curl -s $B/about); h2=$(curl -s $B/about)
v1=$(echo "$h1" | grep -o 'class="mono">[0-9]*</dd>' | tail -1 | grep -o '[0-9]*'); v2=$(echo "$h2" | grep -o 'class="mono">[0-9]*</dd>' | tail -1 | grep -o '[0-9]*')
ok "$([[ "$h1" == *"How AspirantOS works"* && "$h1" == *"admin@aspirantos.in"* && "$h1" == *"er-diagram.svg"* ]] && echo 1)" "About page through its web.xml mapping (init params shown)" ""
ok "$([[ -n "$v1" && "$v2" -eq $((v1 + 1)) ]] && echo 1)" "application-wide visit counter goes up ($v1 -> $v2)" ""
r=$(curl -s -o /dev/null -w "%{http_code}" $B/WEB-INF/about.jsp); ok "$([[ $r == 404 ]] && echo 1)" "the JSP inside WEB-INF cannot be opened directly" "$r"
r=$(curl -s -o $D/err.html -w "%{http_code}" $B/no-such-page.jsp); h=$(cat $D/err.html)
ok "$([[ $r == 404 && "$h" == *"This page does not exist"* && "$h" != *"Exception"* ]] && echo 1)" "friendly 404 page without technical details" "$r"
r=$(curl -s -o /dev/null -w "%{http_code}" $B/assets/img/er-diagram.svg); ok "$([[ $r == 200 ]] && echo 1)" "ER diagram image served" "$r"

# ---- student pages
scode -d "fullName=Smoke Horizon&email=$EMAIL&password=abcd1234&confirmPassword=abcd1234" $B/register-action.jsp >/dev/null
r=$(scode $B/aspirant/horizon.jsp); ok "$(has "$r" profile-step1.jsp)" "horizon asks for a profile first" "$r"
scode -d "fullName=Smoke Horizon&dob=1996-09-15&gender=MALE&maritalStatus=UNMARRIED&nationality=INDIAN&domicileStateCode=UP" $B/aspirant/profile-step1.jsp >/dev/null
scode -d "category=GEN" $B/aspirant/profile-step2.jsp >/dev/null
scode -d "action=save&id=0&level=UG&degreeName=B.A.&percentage=62&status=COMPLETED&passingYear=2018" $B/aspirant/education-action.jsp >/dev/null
h=$(spage $B/aspirant/profile-step4.jsp); upsc=$(echo "$h" | grep -o 'name="attempts_[0-9]*"' | head -1 | grep -o '[0-9]*')
scode -d "attempts_$upsc=4" $B/aspirant/profile-save.jsp >/dev/null
h=$(spage $B/aspirant/horizon.jsp)
ok "$([[ "$h" == *"<svg class=\"horizon-chart\""* && "$h" == *">UPSC CSE<"* && "$h" == *"today-line"* && "$h" == *"class=\"h-dot\""* ]] && echo 1)" "horizon SVG with the tracked UPSC bar and attempt dots" ""
ok "$([[ "$h" == *"Age clock"* && "$h" == *"01-Aug-2027"* && "$h" == *"30 years 10 months 17 days"* ]] && echo 1)" "age clock: age on the UPSC cut-off date" ""
dots=$(echo "$h" | sed -n '/>UPSC CSE</,/<\/g>/p' | grep -c 'class="h-dot"'); ok "$([[ $dots == 2 ]] && echo 1)" "UPSC row has 2 dots (2 attempts left)" "$dots"
h=$(spage "$B/aspirant/calendar.jsp?month=2027-05"); ok "$([[ "$h" == *"May 2027"* && "$h" == *"23-May-2027"* && "$h" == *"First stage / prelims"* ]] && echo 1)" "calendar May 2027 shows the UPSC prelims" ""
h=$(spage "$B/aspirant/calendar.jsp?month=junk"); ok "$(has "$h" "month-grid")" "bad month falls back to the current month" ""
eid=$(spage "$B/aspirant/calendar.jsp?month=2027-05" | grep -o 'calendar-ics.jsp?id=[0-9]*' | head -1 | grep -o '[0-9]*$')
r=$(curl -s -D $D/hdr.txt -o $D/one.ics -b $S "$B/aspirant/calendar-ics.jsp?id=$eid"); ics=$(cat $D/one.ics); hdr=$(cat $D/hdr.txt)
ok "$([[ "$hdr" == *"text/calendar"* && "$hdr" == *"attachment"* && "$ics" == BEGIN:VCALENDAR* && "$ics" == *"DTSTART;VALUE=DATE:20270523"* && "$ics" == *"SUMMARY:UPSC CSE - First stage / prelims"* ]] && echo 1)" "single date as .ics (text/calendar download)" "$(head -c 200 $D/one.ics)"
crlf=$(grep -c $'\r$' $D/one.ics); lines=$(wc -l < $D/one.ics); ok "$([[ $crlf -eq $lines && $lines -gt 8 ]] && echo 1)" "every .ics line ends with CRLF" "$crlf/$lines"
ics=$(spage "$B/aspirant/calendar-ics.jsp?all=1"); n=$(echo "$ics" | grep -c "BEGIN:VEVENT"); ok "$([[ $n -ge 3 ]] && echo 1)" "all tracked dates of the next 12 months ($n events)" ""
h=$(spage "$B/aspirant/exam-detail.jsp?id=$upsc"); ok "$([[ "$h" == *"Add to my calendar"* && "$h" == *"calendar-ics.jsp?exam=$upsc"* ]] && echo 1)" "exam page offers calendar downloads" ""
r=$(curl -s -o /dev/null -w "%{http_code} %{redirect_url}" "$B/aspirant/calendar-ics.jsp?all=1"); ok "$(has "$r" login.jsp)" ".ics needs a login" "$r"

# ---- clean up
scode -d "action=deleteAccount&password=abcd1234&confirm=yes" $B/aspirant/settings-action.jsp >/dev/null
rm -rf "$D"
echo "RESULT: $pass passed, $fail failed"
