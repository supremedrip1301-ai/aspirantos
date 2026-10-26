#!/bin/bash
# Rehearsal of docs/DEMO_SCRIPT.md, step by step, with curl (P11.1):
#   register the sample student -> profile wizard -> admin sets the simulation date
#   15-Jan-2027 -> dashboard ticket "2 attempts left, valid until 2028" -> UPSC page with
#   the explanation lines -> admin publishes UPSC rules v2 (General: 7 attempts) -> student
#   gets the notification and now sees "3 attempts left".
# Needs the WAR deployed on http://localhost:8080/AspirantOS and MYSQL_PWD = MySQL root
# password: at the end the student deletes itself and sql/reset_after_demo.sql puts UPSC
# back to its seeded version 1 (and switches the simulation date off).
B=http://localhost:8080/AspirantOS
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
D=$(mktemp -d); S=$D/student.txt; A=$D/admin.txt
TS=$(date +%s); EMAIL="demo.$TS@test.local"
pass=0; fail=0
ok() { if [ "$1" = "1" ]; then pass=$((pass+1)); echo "PASS  $2"; else fail=$((fail+1)); echo "FAIL  $2  -> $3"; fi; }
has() { [[ "$1" == *"$2"* ]] && echo 1; }
scode() { curl -s -o /dev/null -w "%{http_code} %{redirect_url}" -b $S -c $S "$@"; }
spage() { curl -s -b $S -c $S "$@"; }
acode() { curl -s -o /dev/null -w "%{http_code} %{redirect_url}" -b $A -c $A "$@"; }
apage() { curl -s -b $A -c $A "$@"; }
if [ -z "$MYSQL_PWD" ]; then echo "Set MYSQL_PWD to the MySQL root password first."; exit 1; fi

# ---- 1. register live + onboarding wizard (sample details of the demo script)
r=$(scode -d "fullName=Aarav Mishra&email=$EMAIL&password=Demo2027ok&confirmPassword=Demo2027ok" $B/register-action.jsp)
ok "$(has "$r" profile-step1.jsp)" "register a new student" "$r"
r=$(scode -d "fullName=Aarav Mishra&dob=1996-09-15&gender=MALE&maritalStatus=UNMARRIED&nationality=INDIAN&domicileStateCode=UP&city=Prayagraj&pincode=211001" $B/aspirant/profile-step1.jsp)
ok "$(has "$r" profile-step2.jsp)" "wizard step 1 (DOB 15-09-1996, Uttar Pradesh)" "$r"
r=$(scode -d "category=GEN" $B/aspirant/profile-step2.jsp); ok "$(has "$r" profile-step3.jsp)" "wizard step 2 (General)" "$r"
r=$(scode -d "action=save&id=0&level=UG&degreeName=B.A.&percentage=62&status=COMPLETED&passingYear=2018" $B/aspirant/education-action.jsp)
ok "$(has "$r" profile-step3.jsp)" "wizard step 3 (B.A. 2018, 62 %)" "$r"
h=$(spage $B/aspirant/profile-step4.jsp); upsc=$(echo "$h" | grep -o 'name="attempts_[0-9]*"' | head -1 | grep -o '[0-9]*')
r=$(scode -d "attempts_$upsc=4" $B/aspirant/profile-save.jsp); ok "$(has "$r" dashboard.jsp)" "wizard step 4 (UPSC CSE: 4 attempts used) saved" "$r"

# ---- 2. admin sets the simulation date
r=$(acode -d "email=admin@aspirantos.in&password=Admin@123" $B/login-action.jsp); ok "$(has "$r" admin/dashboard.jsp)" "admin login" "$r"
acode -d "action=simulation&preset=demo" $B/admin/settings-action.jsp >/dev/null
h=$(spage $B/aspirant/dashboard.jsp)
ok "$(has "$h" "Simulation date: 15-Jan-2027")" "simulation date 15-Jan-2027 shown to the student" ""
ok "$([[ "$h" == *">2 attempts left<"* && "$h" == *'valid until <b class="mono">2028</b>'* && "$h" == *"You have 2 UPSC attempts left, valid until 2028."* ]] && echo 1)" "dashboard ticket: 2 attempts left, valid until 2028 (the demo sentence)" ""
ok "$(has "$h" 'class="stamp status-eligible">Eligible<')" "the ticket stamp says ELIGIBLE" ""

# ---- 3. UPSC page: the explanation lines
h=$(spage "$B/aspirant/exam-detail.jsp?id=$upsc")
ok "$([[ "$h" == *"used 4 &middot; left 2"* && "$h" == *'class="check-pass"'* && "$h" == *"01-Aug-2027"* ]] && echo 1)" "UPSC page: attempts used / left and the passed checks with the cut-off date" ""
ok "$([[ "$h" == *"Base upper age 32"* ]] && echo 1)" "UPSC page: age limit explained (General 32)" ""

# ---- 4. admin: new rule version (General attempts 6 -> 7), publish
r=$(acode -d "action=clone&exam=$upsc" $B/admin/rule-version-action.jsp); h=$(apage "$B/admin/rules.jsp?exam=$upsc")
v2=$(echo "$h" | sed -n '/id="draft"/,$p' | grep -o 'name="version" value="[0-9]*"' | head -1 | grep -o '[0-9]*"$' | tr -d '"')
ok "$([[ "$h" == *"Draft v2"* && -n "$v2" ]] && echo 1)" "update rules: draft v2 copied from the active version" "$r"
aid=$(mysql -uroot -N aspirantos -e "SELECT id FROM attempt_rule WHERE rule_version_id=$v2 AND category='GEN' AND is_pwbd=0")
acode -d "type=attempt&action=save&exam=$upsc&version=$v2&id=$aid&category=GEN&pwbd=false&maxAttempts=7&countingRule=APPEARED_IN_FIRST_STAGE&notes=General: 7 attempts" $B/admin/rule-action.jsp >/dev/null
h=$(apage "$B/admin/rules.jsp?exam=$upsc"); ok "$([[ "$h" == *"<del>"*"6 attempts"* && "$h" == *"<ins>"*"7 attempts"* ]] && echo 1)" "the diff shows 6 -> 7 attempts" ""
acode -d "action=saveInfo&exam=$upsc&version=$v2&changeSummary=General candidates now get 7 attempts&appliesFromCycleYear=2027" $B/admin/rule-version-action.jsp >/dev/null
acode -d "action=publish&exam=$upsc&version=$v2" $B/admin/rule-version-action.jsp >/dev/null
h=$(apage "$B/admin/rules.jsp?exam=$upsc"); ok "$([[ "$h" == *"Version 2 of UPSC CSE is now active"* && "$h" == *"1 student was notified"* ]] && echo 1)" "version 2 published, the student is notified" ""

# ---- 5. back to the student
h=$(spage $B/aspirant/dashboard.jsp)
ok "$([[ "$h" == *">3 attempts left<"* && "$h" == *"You have 3 UPSC attempts left, valid until 2028."* ]] && echo 1)" "dashboard recalculated: 3 attempts left" ""
h=$(spage $B/aspirant/notifications.jsp); ok "$([[ "$h" == *"UPSC CSE rules updated"* ]] && echo 1)" "notification about the new UPSC rules" ""
h=$(apage $B/admin/db-explorer.jsp?table=exam_rule_version); ok "$(has "$h" "exam_rule_version")" "DB Explorer opens the rule version table" ""
r=$(curl -s -o /dev/null -w "%{http_code}" $B/assets/img/er-diagram.svg); ok "$([[ $r == 200 ]] && echo 1)" "ER diagram for the closing" "$r"

# ---- clean up: student deletes itself, UPSC back to version 1, simulation date off
r=$(scode -d "action=deleteAccount&password=Demo2027ok&confirm=yes" $B/aspirant/settings-action.jsp); ok "$(has "$r" login.jsp)" "demo student deleted" "$r"
mysql -uroot aspirantos < "$ROOT/sql/reset_after_demo.sql" | tail -n +2 | tr '\t' ' '
n=$(mysql -uroot -N aspirantos -e "SELECT COUNT(*) FROM exam_rule_version v JOIN exam e ON e.id=v.exam_id WHERE e.code='UPSC_CSE'")
s=$(mysql -uroot -N aspirantos -e "SELECT setting_value FROM app_setting WHERE setting_key='simulation_date'")
ok "$([[ $n == 1 && -z "$s" ]] && echo 1)" "reset_after_demo.sql: UPSC has only version 1 again, simulation date off" "$n '$s'"
rm -rf "$D"
echo "RESULT: $pass passed, $fail failed"
