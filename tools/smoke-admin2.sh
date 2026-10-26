#!/bin/bash
# Smoke test of P8.4-P8.7: update checker (single exam + check-all progress), rule pack
# import / export, document spec + exam date editors, reports inbox, DB Explorer.
# Needs the WAR deployed on http://localhost:8080/AspirantOS and MYSQL_PWD = MySQL root
# password (only to remove the test data at the end). The seeded exams are not changed:
# the script creates its own exam SMOKE2_<time>, whose "official page" is a page of this app
# (so the update checker can be tested without the internet), and a temporary student.
B=http://localhost:8080/AspirantOS
D=$(mktemp -d); S=$D/student.txt; A=$D/admin.txt
TS=$(date +%s); EMAIL="smoke.$TS@test.local"; CODE="SMOKE2_$TS"
START=$(mysql -uroot -N aspirantos -e "SELECT NOW()" 2>/dev/null)
pass=0; fail=0
ok() { if [ "$1" = "1" ]; then pass=$((pass+1)); echo "PASS  $2"; else fail=$((fail+1)); echo "FAIL  $2  -> $3"; fi; }
has() { [[ "$1" == *"$2"* ]] && echo 1; }
scode() { curl -s -o /dev/null -w "%{http_code} %{redirect_url}" -b $S -c $S "$@"; }
spage() { curl -s -b $S -c $S "$@"; }
acode() { curl -s -o /dev/null -w "%{http_code} %{redirect_url}" -b $A -c $A "$@"; }
apage() { curl -s -b $A -c $A "$@"; }
post() { curl -s -o /dev/null -w "%{http_code} %{redirect_url}" -b $A -c $A --data-urlencode "$@"; }

acode -d "email=admin@aspirantos.in&password=Admin@123" $B/login-action.jsp >/dev/null
h=$(apage $B/admin/exam-form.jsp)
cat=$(echo "$h" | sed -n '/name="categoryId"/,/<\/select>/p' | grep -o 'value="[0-9][0-9]*"' | head -1 | grep -o '[0-9][0-9]*')
body=$(echo "$h" | sed -n '/name="bodyId"/,/<\/select>/p' | grep -o 'value="[0-9][0-9]*"' | head -1 | grep -o '[0-9][0-9]*')
EXAM="action=save&id=0&code=$CODE&name=Smoke Two Exam&shortName=SMOKE2&categoryId=$cat&bodyId=$body&scope=NATIONAL&sector=GOVERNMENT&purpose=RECRUITMENT&cyclesPerYear=1&typicalExamMonth=11&dataConfidence=NEEDS_VERIFICATION&active=true"
r=$(acode -d "$EXAM&officialUrl=$B/index.jsp" $B/admin/exam-action.jsp); eid=$(echo "$r" | grep -o 'exam=[0-9]*' | grep -o '[0-9]*')
ok "$([[ -n "$eid" ]] && echo 1)" "test exam created" "$r"

# ---- P8.4 update checker
acode -d "action=check&exam=$eid" $B/admin/update-check-action.jsp >/dev/null; h=$(apage "$B/admin/rules.jsp?exam=$eid")
ok "$(has "$h" "First check saved")" "first check stores the page fingerprint" ""
acode -d "action=check&exam=$eid" $B/admin/update-check-action.jsp >/dev/null; h=$(apage "$B/admin/rules.jsp?exam=$eid")
ok "$(has "$h" "No change detected")" "second check: no change" ""
acode -d "action=save&id=$eid&code=$CODE&name=Smoke Two Exam&shortName=SMOKE2&categoryId=$cat&bodyId=$body&scope=NATIONAL&sector=GOVERNMENT&purpose=RECRUITMENT&cyclesPerYear=1&typicalExamMonth=11&dataConfidence=NEEDS_VERIFICATION&active=true&officialUrl=$B/index.jsp&watchUrl=$B/about" $B/admin/exam-action.jsp >/dev/null
acode -d "action=check&exam=$eid" $B/admin/update-check-action.jsp >/dev/null; h=$(apage "$B/admin/rules.jsp?exam=$eid")
ok "$([[ "$h" == *"has changed since the last check"* && "$h" == *"snippet"* ]] && echo 1)" "different page: change detected with snippets" ""
acode -d "action=save&id=$eid&code=$CODE&name=Smoke Two Exam&shortName=SMOKE2&categoryId=$cat&bodyId=$body&scope=NATIONAL&sector=GOVERNMENT&purpose=RECRUITMENT&cyclesPerYear=1&typicalExamMonth=11&dataConfidence=NEEDS_VERIFICATION&active=true&officialUrl=http://127.0.0.1:9/nothing" $B/admin/exam-action.jsp >/dev/null
acode -d "action=check&exam=$eid" $B/admin/update-check-action.jsp >/dev/null; h=$(apage "$B/admin/rules.jsp?exam=$eid")
ok "$(has "$h" "Could not reach the official site")" "unreachable site handled without a crash" ""
h=$(apage $B/admin/update-check.jsp); ok "$(both=1; [[ "$h" == *"Check all exams"* && "$h" == *"SMOKE2"* ]] && echo 1)" "update checks page lists the results" ""
j=$(apage $B/admin/update-check-progress.jsp); ok "$(has "$j" '"running":false')" "progress JSON (idle)" "$j"
code=$(curl -s -o /dev/null -w "%{http_code}" $B/admin/update-check-progress.jsp); ok "$([[ $code == 403 ]] && echo 1)" "progress JSON refused without admin login" "$code"
acode -d "action=checkAll" $B/admin/update-check-action.jsp >/dev/null; j=$(apage $B/admin/update-check-progress.jsp)
acode -d "action=stop" $B/admin/update-check-action.jsp >/dev/null
ok "$([[ "$j" == *'"total":'* && "$j" != *'"total":0,"done":0,"changed":0,"failed":0,"stopped":false,"current":"","startedAt":""'* ]] && echo 1)" "check-all started in the background" "$j"
for i in $(seq 1 40); do j=$(apage $B/admin/update-check-progress.jsp); [[ "$j" == *'"running":false'* ]] && break; sleep 1; done
ok "$(has "$j" '"stopped":true')" "check-all stopped on request" "$j"

# ---- P8.5 rule pack
PACK="exam_code,rule_table,min_age,max_age,max_age_semantics,cutoff_type,cutoff_month,cutoff_day,max_attempts,counting_rule,required_level,final_year_allowed,notes
$CODE,AGE,21,30,NOT_ATTAINED,FIXED_DATE_IN_CYCLE_YEAR,8,1,,,,,
$CODE,ATTEMPT,,,,,,,3,APPEARED_IN_FIRST_STAGE,,,
$CODE,QUALIFICATION,,,,,,,,,UG,1,Graduation in any discipline"
post "csv=$PACK" -d "action=preview" --data-urlencode "summary=First rules from a pack (smoke test)" $B/admin/rule-pack-action.jsp >/dev/null
h=$(apage $B/admin/rule-pack.jsp); ok "$([[ "$h" == *"looks fine"* && "$h" == *"<ins>[] "* || "$h" == *"looks fine"* && "$h" == *"<ins>"* ]] && echo 1)" "pack preview: no problems, new rows highlighted" ""
acode -d "action=apply" $B/admin/rule-pack-action.jsp >/dev/null; h=$(apage $B/admin/rule-pack.jsp)
ok "$(has "$h" "Rule pack applied")" "pack applied (version 1 active)" ""
csv=$(apage "$B/admin/rule-pack-export.jsp?code=$CODE"); ok "$([[ "$csv" == *"exam_code,rule_table"* && "$csv" == *"$CODE,AGE,,21,30,NOT_ATTAINED"* ]] && echo 1)" "export of one exam" "$(echo "$csv" | head -2)"
all=$(apage "$B/admin/rule-pack-export.jsp" | wc -l); ok "$([[ $all -gt 1900 ]] && echo 1)" "export of all exams ($all lines)" ""
BAD="exam_code,rule_table,min_age,max_age,max_age_semantics,cutoff_type,cutoff_month,cutoff_day
$CODE,AGE,21,abc,NOT_ATTAINED,FIXED_DATE_IN_CYCLE_YEAR,8,1
NO_SUCH_EXAM,AGE,21,30,NOT_ATTAINED,FIXED_DATE_IN_CYCLE_YEAR,8,1"
post "csv=$BAD" -d "action=preview" --data-urlencode "summary=bad" $B/admin/rule-pack-action.jsp >/dev/null
h=$(apage $B/admin/rule-pack.jsp); ok "$([[ "$h" == *"Line <span class=\"mono\">2"* && "$h" == *"Unknown exam code NO_SUCH_EXAM"* && "$h" == *"disabled"* ]] && echo 1)" "bad lines listed, apply disabled" ""
acode -d "action=apply" $B/admin/rule-pack-action.jsp >/dev/null; h=$(apage $B/admin/rule-pack.jsp); ok "$(has "$h" "check a valid pack first")" "invalid pack cannot be applied" ""
PACK2=$(echo "$csv" | sed "s/,21,30,NOT_ATTAINED/,21,35,NOT_ATTAINED/")
post "csv=$PACK2" -d "action=preview" --data-urlencode "summary=Upper age 35 from a pack (smoke test)" $B/admin/rule-pack-action.jsp >/dev/null
h=$(apage $B/admin/rule-pack.jsp); ok "$([[ "$h" == *"<del>21 to below 30 years"* && "$h" == *"<ins>21 to below 35 years"* ]] && echo 1)" "edited export: preview shows the change" ""
acode -d "action=apply" $B/admin/rule-pack-action.jsp >/dev/null; h=$(apage "$B/admin/rules.jsp?exam=$eid")
ok "$([[ "$h" == *"Upper age 35 from a pack"* && "$h" == *"ARCHIVED"* ]] && echo 1)" "version 2 from the pack active, version 1 archived" ""
acode -d "action=clone&exam=$eid" $B/admin/rule-version-action.jsp >/dev/null
post "csv=$PACK2" -d "action=preview" --data-urlencode "summary=while a draft is open" $B/admin/rule-pack-action.jsp >/dev/null
h=$(apage $B/admin/rule-pack.jsp); ok "$(has "$h" "has an open draft")" "exam with an open draft is blocked" ""
v=$(apage "$B/admin/rules.jsp?exam=$eid" | sed -n '/id="draft"/,$p' | grep -o 'name="version" value="[0-9]*"' | head -1 | grep -o '[0-9]*"$' | tr -d '"')
acode -d "action=discard&exam=$eid&version=$v" $B/admin/rule-version-action.jsp >/dev/null; acode -d "action=clear" $B/admin/rule-pack-action.jsp >/dev/null

# ---- P8.6 document specs, dates, reports
acode -d "kind=doc&action=save&exam=$eid&docType=PHOTO&minWidthPx=300&maxWidthPx=200&allowedFormats=JPG" $B/admin/doc-event-action.jsp >/dev/null
h=$(apage "$B/admin/docs-events.jsp?exam=$eid"); ok "$(has "$h" "must be at least the")" "photo spec with max < min refused" ""
acode -d "kind=doc&action=save&exam=$eid&docType=PHOTO&minWidthPx=200&maxWidthPx=300&minHeightPx=230&maxHeightPx=350&minKb=20&maxKb=50&allowedFormats=jpg, jpeg&notes=Smoke" $B/admin/doc-event-action.jsp >/dev/null
h=$(apage "$B/admin/docs-events.jsp?exam=$eid"); ok "$([[ "$h" == *"200-300 x 230-350 px"* && "$h" == *"JPG,JPEG"* ]] && echo 1)" "photo spec saved" ""
acode -d "kind=event&action=save&exam=$eid&cycleYear=2027&eventType=STAGE_1&eventDate=2027-11-20&notes=Smoke date" $B/admin/doc-event-action.jsp >/dev/null
h=$(apage "$B/admin/docs-events.jsp?exam=$eid"); ok "$([[ "$h" == *"20-Nov-2027"* && "$h" == *"Tentative"* ]] && echo 1)" "exam date saved" ""
evid=$(echo "$h" | grep -o 'kind=event&amp;action=delete&amp;exam=[0-9]*&amp;id=[0-9]*' | head -1 | grep -o '[0-9]*$')
acode "$B/admin/doc-event-action.jsp?kind=event&action=delete&exam=$eid&id=$evid" >/dev/null; h=$(apage "$B/admin/docs-events.jsp?exam=$eid")
ok "$([[ "$h" == *"Deleted"* && "$h" != *"20-Nov-2027"* ]] && echo 1)" "exam date deleted" ""
scode -d "fullName=Smoke Reporter&email=$EMAIL&password=abcd1234&confirmPassword=abcd1234" $B/register-action.jsp >/dev/null
scode -d "examId=$eid&message=The age limit of this smoke exam looks outdated." $B/aspirant/report-action.jsp >/dev/null
h=$(apage $B/admin/reports.jsp); rid=$(echo "$h" | grep -o 'name="id" value="[0-9]*"' | head -1 | grep -o '[0-9]*"' | tr -d '"')
ok "$([[ "$h" == *"looks outdated"* && -n "$rid" ]] && echo 1)" "report appears in the admin inbox" ""
acode -d "id=$rid&status=RESOLVED&back=OPEN&reply=Checked - the age limit is now 35." $B/admin/report-action.jsp >/dev/null
h=$(apage "$B/admin/reports.jsp?status=RESOLVED"); ok "$(has "$h" "the age limit is now 35")" "report resolved with a reply" ""
h=$(spage $B/aspirant/notifications.jsp); ok "$(has "$h" "the age limit is now 35")" "student got the reply as a notification" ""

# ---- P8.7 DB Explorer
h=$(apage "$B/admin/db-explorer.jsp?table=app_user"); ok "$([[ "$h" == *"(hidden)"* && "$h" != *"lvXFJjyQ"* ]] && echo 1)" "password hashes are hidden" ""
h=$(apage "$B/admin/db-explorer.jsp?table=exam_event&move=next&at=1"); ok "$(has "$h" "showing rows 26 to 50")" "Next page (scrollable ResultSet)" ""
h=$(apage "$B/admin/db-explorer.jsp?table=exam_event&move=goto&at=100"); ok "$(has "$h" "showing rows 100 to 124")" "go to row 100 (absolute)" ""
h=$(apage "$B/admin/db-explorer.jsp?table=exam_event&move=previous&at=100"); ok "$(has "$h" "showing rows 75 to 99")" "Previous page" ""
h=$(apage "$B/admin/db-explorer.jsp?table=exam_event&move=last"); n=$(echo "$h" | grep -o '[0-9]* rows' | head -1 | grep -o '[0-9]*'); ok "$(has "$h" "to $n")" "Last page ends at row $n" ""
h=$(apage "$B/admin/db-explorer.jsp?table=app_user;DROP%20TABLE%20exam"); ok "$(has "$h" "<h2 class=\"mono\">app_setting</h2>")" "unknown table name falls back to app_setting" ""
h=$(apage "$B/admin/db-explorer.jsp?table=v_exam_catalog"); ok "$(has "$h" "Columns and types")" "a view can be browsed" ""
post "value=abc" -d "key=upcoming_cycles_to_plan" $B/admin/db-explorer-action.jsp >/dev/null; h=$(apage "$B/admin/db-explorer.jsp?table=app_setting")
ok "$(has "$h" "from 5 to 30")" "quick edit with a bad value refused" ""
post "value=16" -d "key=upcoming_cycles_to_plan" $B/admin/db-explorer-action.jsp >/dev/null; h=$(apage "$B/admin/db-explorer.jsp?table=app_setting")
ok "$(has "$h" "1 row updated")" "quick edit through an updatable ResultSet" ""
post "value=15" -d "key=upcoming_cycles_to_plan" $B/admin/db-explorer-action.jsp >/dev/null

# ---- clean up
scode -d "action=deleteAccount&password=abcd1234&confirm=yes" $B/aspirant/settings-action.jsp >/dev/null
acode $B/logout.jsp >/dev/null
if [ -n "$MYSQL_PWD" ] && command -v mysql >/dev/null 2>&1; then
    mysql -uroot aspirantos -e "DELETE FROM exam WHERE code='$CODE'; DELETE FROM exam_update_check WHERE checked_at >= '$START'; DELETE FROM audit_log WHERE entity='exam' AND entity_id='$eid';" \
        && echo "      test exam $CODE and the update checks of this run removed"
fi
rm -rf "$D"
echo "RESULT: $pass passed, $fail failed"
