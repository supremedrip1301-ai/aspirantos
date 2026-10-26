#!/bin/bash
# Smoke test of Phase 8 (admin): dashboard, users (block / unblock), app settings (simulation
# date), audit log, exam CRUD and rule versions (create v1, publish, clone, edit, diff, publish
# again with a notification, discard). Needs the WAR deployed on http://localhost:8080/AspirantOS.
#
# It never touches the seeded exams: it creates its own exam SMOKE_<time> and a temporary
# student, and removes both at the end. The exam can only be deleted with SQL (the app only
# deactivates exams), so set MYSQL_PWD to the MySQL root password before running it if the
# test exam should be removed too; otherwise it stays deactivated and the script says so.
B=http://localhost:8080/AspirantOS
D=$(mktemp -d); S=$D/student.txt; A=$D/admin.txt
TS=$(date +%s); EMAIL="smoke.$TS@test.local"; CODE="SMOKE_$TS"
pass=0; fail=0
ok() { if [ "$1" = "1" ]; then pass=$((pass+1)); echo "PASS  $2"; else fail=$((fail+1)); echo "FAIL  $2  -> $3"; fi; }
has() { [[ "$1" == *"$2"* ]] && echo 1; }
scode() { curl -s -o /dev/null -w "%{http_code} %{redirect_url}" -b $S -c $S "$@"; }
spage() { curl -s -b $S -c $S "$@"; }
acode() { curl -s -o /dev/null -w "%{http_code} %{redirect_url}" -b $A -c $A "$@"; }
apage() { curl -s -b $A -c $A "$@"; }

# ---- a temporary student with the sample profile
scode -d "fullName=Smoke Student&email=$EMAIL&password=abcd1234&confirmPassword=abcd1234" $B/register-action.jsp >/dev/null
scode -d "fullName=Smoke Student&dob=1996-09-15&gender=MALE&maritalStatus=UNMARRIED&nationality=INDIAN&domicileStateCode=UP" $B/aspirant/profile-step1.jsp >/dev/null
scode -d "category=GEN" $B/aspirant/profile-step2.jsp >/dev/null
scode -d "action=save&id=0&level=UG&degreeName=B.A.&percentage=62&status=COMPLETED&passingYear=2018" $B/aspirant/education-action.jsp >/dev/null
r=$(scode -d "x=1" $B/aspirant/profile-save.jsp); ok "$(has "$r" dashboard.jsp)" "temporary student ready" "$r"
sid=$(spage $B/aspirant/settings.jsp >/dev/null; echo)

# ---- admin pages
r=$(acode -d "email=admin@aspirantos.in&password=Admin@123" $B/login-action.jsp); ok "$(has "$r" admin/dashboard.jsp)" "admin login" "$r"
h=$(apage $B/admin/dashboard.jsp); ok "$([[ "$h" == *"System information"* && "$h" == *"MySQL Connector/J"* && "$h" == *"Registered students"* ]] && echo 1)" "admin dashboard with system information" ""
h=$(apage "$B/admin/users.jsp?q=smoke.$TS"); uid=$(echo "$h" | grep -o 'users.jsp?view=[0-9]*' | head -1 | grep -o '[0-9]*$')
ok "$([[ -n "$uid" && "$h" == *"$EMAIL"* ]] && echo 1)" "users page finds the student" ""
h=$(apage "$B/admin/users.jsp?view=$uid"); ok "$(has "$h" "Profile complete")" "read-only student profile" ""
r=$(acode -d "id=$uid&action=block" $B/admin/user-action.jsp); r=$(scode $B/aspirant/dashboard.jsp)
h=$(spage $B/login.jsp); ok "$([[ "$r" == *login.jsp* && "$h" == *"blocked"* ]] && echo 1)" "blocking ends the student's open session" "$r"
r=$(scode -d "email=$EMAIL&password=abcd1234" $B/login-action.jsp); h=$(spage $B/login.jsp); ok "$(has "$h" "blocked")" "blocked student cannot log in" ""
r=$(acode -d "id=$uid&action=unblock" $B/admin/user-action.jsp)
r=$(scode -d "email=$EMAIL&password=abcd1234" $B/login-action.jsp); ok "$(has "$r" dashboard.jsp)" "unblocked student logs in again" "$r"
r=$(acode -d "action=simulation&preset=demo" $B/admin/settings-action.jsp); h=$(apage $B/admin/settings.jsp)
ok "$([[ "$h" == *"Simulation date: 15-Jan-2027"* ]] && echo 1)" "simulation date set (banner shown)" ""
h=$(spage $B/aspirant/dashboard.jsp); ok "$(has "$h" "Results for <span class=\"mono\">15-Jan-2027")" "student results use the simulation date" ""
r=$(acode -d "action=simulation&value=1999-01-01" $B/admin/settings-action.jsp); h=$(apage $B/admin/settings.jsp); ok "$(has "$h" "between 2020 and 2040")" "out-of-range date refused" ""
r=$(acode -d "action=simulation&preset=clear" $B/admin/settings-action.jsp); h=$(apage $B/admin/settings.jsp)
ok "$([[ "$h" != *"sim-banner"* && "$h" == *"switched off"* ]] && echo 1)" "simulation date cleared" ""
h=$(apage "$B/admin/audit.jsp?action=SETTING_CHANGE"); ok "$(has "$h" "simulation_date=2027-01-15")" "audit log shows the setting change" ""

# ---- exam CRUD
h=$(apage $B/admin/exam-form.jsp)
cat=$(echo "$h" | sed -n '/name="categoryId"/,/<\/select>/p' | grep -o 'value="[0-9][0-9]*"' | head -1 | grep -o '[0-9][0-9]*')
body=$(echo "$h" | sed -n '/name="bodyId"/,/<\/select>/p' | grep -o 'value="[0-9][0-9]*"' | head -1 | grep -o '[0-9][0-9]*')
r=$(acode -d "action=save&id=0&code=bad code&name=Smoke Exam&shortName=SMOKE&categoryId=$cat&bodyId=$body&scope=NATIONAL&sector=GOVERNMENT&purpose=RECRUITMENT&cyclesPerYear=1&dataConfidence=NEEDS_VERIFICATION&active=true" $B/admin/exam-action.jsp)
h=$(apage $B/admin/exam-form.jsp); ok "$([[ "$h" == *"capital letters"* && "$h" == *"Smoke Exam"* ]] && echo 1)" "invalid code refused, values kept" ""
r=$(acode -d "action=save&id=0&code=$CODE&name=Smoke Test Exam&shortName=SMOKE $TS&categoryId=$cat&bodyId=$body&scope=NATIONAL&sector=GOVERNMENT&purpose=RECRUITMENT&cyclesPerYear=1&typicalExamMonth=11&dataConfidence=NEEDS_VERIFICATION&active=true" $B/admin/exam-action.jsp)
eid=$(echo "$r" | grep -o 'exam=[0-9]*' | grep -o '[0-9]*'); ok "$([[ -n "$eid" ]] && echo 1)" "exam created, rules page opens" "$r"
r=$(acode -d "action=save&id=$eid&code=IGNORED&name=Smoke Test Exam (edited)&shortName=SMOKE $TS&categoryId=$cat&bodyId=$body&scope=NATIONAL&sector=GOVERNMENT&purpose=RECRUITMENT&cyclesPerYear=1&typicalExamMonth=11&dataConfidence=VERIFIED&active=true" $B/admin/exam-action.jsp)
h=$(apage "$B/admin/exam-form.jsp?id=$eid"); ok "$(has "$h" "needs the date you checked")" "VERIFIED without date and source refused" ""
r=$(acode -d "action=save&id=$eid&code=IGNORED&name=Smoke Test Exam (edited)&shortName=SMOKE $TS&categoryId=$cat&bodyId=$body&scope=NATIONAL&sector=GOVERNMENT&purpose=RECRUITMENT&cyclesPerYear=1&typicalExamMonth=11&dataConfidence=NEEDS_VERIFICATION&active=true" $B/admin/exam-action.jsp)
h=$(apage "$B/admin/exams.jsp?q=$CODE"); ok "$([[ "$h" == *"$CODE"* && "$h" == *"Create rules"* ]] && echo 1)" "exam edited, code unchanged, no rules yet" ""

# ---- rule versions
r=$(acode -d "action=clone&exam=$eid" $B/admin/rule-version-action.jsp); h=$(apage "$B/admin/rules.jsp?exam=$eid")
v1=$(echo "$h" | grep -o 'name="version" value="[0-9]*"' | head -1 | grep -o '[0-9]*"$' | tr -d '"')
ok "$([[ "$h" == *"Draft v1"* && -n "$v1" ]] && echo 1)" "empty version 1 created as a draft" ""
r=$(acode -d "type=age&action=save&exam=$eid&version=$v1&id=0&cutoffType=FIXED_DATE_IN_CYCLE_YEAR&maxAgeSemantics=NOT_ATTAINED&minAge=30&maxAge=21&cutoffMonth=8&cutoffDay=1" $B/admin/rule-action.jsp)
h=$(apage "$B/admin/rules.jsp?exam=$eid"); ok "$(has "$h" "cannot be below the minimum")" "age rule with max < min refused" ""
r=$(acode -d "type=age&action=save&exam=$eid&version=$v1&id=0&cutoffType=FIXED_DATE_IN_CYCLE_YEAR&maxAgeSemantics=NOT_ATTAINED&minAge=21&maxAge=30&cutoffMonth=8&cutoffDay=1" $B/admin/rule-action.jsp)
r=$(acode -d "type=attempt&action=save&exam=$eid&version=$v1&id=0&countingRule=APPEARED_IN_FIRST_STAGE&maxAttempts=3" $B/admin/rule-action.jsp)
r=$(acode -d "type=qual&action=save&exam=$eid&version=$v1&id=0&requiredLevel=UG&acceptedDegrees=ANY&finalYearAllowed=true" $B/admin/rule-action.jsp)
h=$(apage "$B/admin/rules.jsp?exam=$eid"); ok "$([[ "$h" == *"21 to below 30 years on 1 August"* && "$h" == *"3 attempts"* ]] && echo 1)" "three rules added to the draft" ""
r=$(acode -d "action=publish&exam=$eid&version=$v1" $B/admin/rule-version-action.jsp); h=$(apage "$B/admin/rules.jsp?exam=$eid")
ok "$(has "$h" "write what changed")" "publish without a summary refused" ""
r=$(acode -d "action=saveInfo&exam=$eid&version=$v1&changeSummary=First rules (smoke test)" $B/admin/rule-version-action.jsp)
r=$(acode -d "action=publish&exam=$eid&version=$v1" $B/admin/rule-version-action.jsp); h=$(apage "$B/admin/rules.jsp?exam=$eid")
ok "$(has "$h" "Version 1 of SMOKE $TS is now active")" "version 1 published" ""
r=$(scode -d "examId=$eid&action=track" $B/aspirant/track-action.jsp); h=$(spage "$B/aspirant/exam-detail.jsp?id=$eid")
ok "$(has "$h" "You have 3 SMOKE $TS attempts left, valid until 2026.")" "student sees the new exam (30 limit: last cycle 2026)" "$(echo "$h" | grep -o 'result-headline">[^<]*')"
r=$(acode -d "action=clone&exam=$eid" $B/admin/rule-version-action.jsp); h=$(apage "$B/admin/rules.jsp?exam=$eid")
v2=$(echo "$h" | sed -n '/id="draft"/,$p' | grep -o 'name="version" value="[0-9]*"' | head -1 | grep -o '[0-9]*"$' | tr -d '"')
aid=$(echo "$h" | grep -o 'edit=age-[0-9]*' | head -1 | grep -o '[0-9]*$')
ok "$([[ "$h" == *"Draft v2"* && -n "$aid" ]] && echo 1)" "update rules: active version copied into draft v2" ""
r=$(acode -d "type=age&action=save&exam=$eid&version=$v2&id=$aid&cutoffType=FIXED_DATE_IN_CYCLE_YEAR&maxAgeSemantics=NOT_ATTAINED&minAge=21&maxAge=35&cutoffMonth=8&cutoffDay=1" $B/admin/rule-action.jsp)
h=$(apage "$B/admin/rules.jsp?exam=$eid")
ok "$([[ "$h" == *"<del>21 to below 30 years"* && "$h" == *"<ins>21 to below 35 years"* ]] && echo 1)" "diff shows the old and the new age rule" ""
ok "$(has "$h" "edits logged in this draft")" "the edit is logged (rule_change_log trigger)" ""
r=$(acode -d "action=saveInfo&exam=$eid&version=$v2&changeSummary=Upper age raised to 35 (smoke test)&appliesFromCycleYear=2027" $B/admin/rule-version-action.jsp)
r=$(acode -d "action=publish&exam=$eid&version=$v2" $B/admin/rule-version-action.jsp); h=$(apage "$B/admin/rules.jsp?exam=$eid")
ok "$(has "$h" "1 student was notified")" "version 2 published, tracking student notified" ""
h=$(spage $B/aspirant/notifications.jsp); ok "$(has "$h" "SMOKE $TS rules updated")" "student got the notification" ""
h=$(spage "$B/aspirant/exam-detail.jsp?id=$eid"); ok "$(has "$h" "valid until 2031.")" "student result recalculated with the new limit" "$(echo "$h" | grep -o 'result-headline">[^<]*')"
h=$(apage "$B/admin/rules.jsp?exam=$eid"); ok "$([[ "$h" == *"ARCHIVED"* && "$h" == *"ACTIVE"* ]] && echo 1)" "version 1 archived, version 2 active" ""
r=$(acode -d "action=clone&exam=$eid" $B/admin/rule-version-action.jsp); h=$(apage "$B/admin/rules.jsp?exam=$eid")
v3=$(echo "$h" | sed -n '/id="draft"/,$p' | grep -o 'name="version" value="[0-9]*"' | head -1 | grep -o '[0-9]*"$' | tr -d '"')
r=$(acode -d "action=publish&exam=$eid&version=$v3" $B/admin/rule-version-action.jsp); h=$(apage "$B/admin/rules.jsp?exam=$eid")
ok "$(has "$h" "same as the active version")" "unchanged draft cannot be published" ""
r=$(acode -d "action=discard&exam=$eid&version=$v3" $B/admin/rule-version-action.jsp); h=$(apage "$B/admin/rules.jsp?exam=$eid")
ok "$([[ "$h" == *"Draft discarded"* && "$h" != *"Draft v3"* ]] && echo 1)" "draft v3 discarded" ""
r=$(acode -d "type=age&action=save&exam=$eid&version=$v2&id=$aid&cutoffType=NONE&maxAgeSemantics=NOT_MORE_THAN" $B/admin/rule-action.jsp)
h=$(apage "$B/admin/rules.jsp?exam=$eid"); ok "$(has "$h" "only be changed in a draft")" "the ACTIVE version cannot be edited" ""
r=$(acode -d "action=deactivate&id=$eid" $B/admin/exam-action.jsp)
h=$(spage "$B/aspirant/exams.jsp?q=$CODE"); ok "$(has "$h" "0 exams found")" "deactivated exam hidden from students" ""

# ---- clean up
r=$(scode -d "action=deleteAccount&password=abcd1234&confirm=yes" $B/aspirant/settings-action.jsp); ok "$(has "$r" login.jsp)" "temporary student deleted" "$r"
acode $B/logout.jsp >/dev/null
if [ -n "$MYSQL_PWD" ] && command -v mysql >/dev/null 2>&1; then
    mysql -uroot aspirantos -e "DELETE FROM exam WHERE code='$CODE'; DELETE FROM audit_log WHERE entity='exam' AND entity_id='$eid';" && echo "      test exam $CODE removed"
else
    echo "      note: test exam $CODE stays deactivated (set MYSQL_PWD to remove it)"
fi
rm -rf "$D"
echo "RESULT: $pass passed, $fail failed"
