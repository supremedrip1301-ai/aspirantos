#!/bin/bash
# Smoke test of Phase 6: Exam Explorer, exam detail, tracking, attempt journal, dashboard,
# notifications and "report outdated info". Needs the WAR deployed on
# http://localhost:8080/AspirantOS. A temporary student (smoke.<time>@test.local) is
# registered, fills the sample profile (General, 15-Sep-1996, B.A. 2018, 4 UPSC attempts)
# and deletes itself at the end (CHANGE 001).
B=http://localhost:8080/AspirantOS
D=$(mktemp -d); J=$D/jar.txt
EMAIL="smoke.$(date +%s)@test.local"
pass=0; fail=0
ok() { if [ "$1" = "1" ]; then pass=$((pass+1)); echo "PASS  $2"; else fail=$((fail+1)); echo "FAIL  $2  -> $3"; fi; }
code() { curl -s -o /dev/null -w "%{http_code} %{redirect_url}" -b $J -c $J "$@"; }
page() { curl -s -b $J -c $J "$@"; }
has() { [[ "$1" == *"$2"* ]] && echo 1; }
both() { [[ "$1" == *"$2"* && "$1" == *"$3"* ]] && echo 1; }

# ---- set up the sample student
code -d "fullName=Smoke Explorer&email=$EMAIL&password=abcd1234&confirmPassword=abcd1234" $B/register-action.jsp >/dev/null
code -d "fullName=Smoke Explorer&dob=1996-09-15&gender=MALE&maritalStatus=UNMARRIED&nationality=INDIAN&domicileStateCode=UP" $B/aspirant/profile-step1.jsp >/dev/null
code -d "category=GEN" $B/aspirant/profile-step2.jsp >/dev/null
code -d "action=save&id=0&level=UG&degreeName=B.A.&subject=HISTORY&percentage=62&status=COMPLETED&passingYear=2018" $B/aspirant/education-action.jsp >/dev/null
h=$(page $B/aspirant/profile-step4.jsp); upsc=$(echo "$h" | grep -o 'name="attempts_[0-9]*"' | head -1 | grep -o '[0-9]*')
r=$(code -d "attempts_$upsc=4" $B/aspirant/profile-save.jsp); ok "$(has "$r" dashboard.jsp)" "sample profile saved" "$r"

# ---- explorer
h=$(page $B/aspirant/exams.jsp); ok "$(both "$h" "267 exams found" "Page 1 of")" "explorer lists 267 exams with pages" ""
h=$(page "$B/aspirant/exams.jsp?q=UPSC"); ok "$(both "$h" "UPSC CSE" "status-chip")" "search UPSC shows UPSC CSE with a status chip" ""
h=$(page "$B/aspirant/exams.jsp?category=BANKING&sort=month"); ok "$(has "$h" "SBI PO")" "category filter (banking)" ""
h=$(page "$B/aspirant/exams.jsp?page=2"); ok "$(has "$h" "Page 2 of")" "second page" ""
h=$(page "$B/aspirant/exams.jsp?q=%27%20OR%201%3D1%20--"); ok "$(has "$h" "0 exams found")" "SQL text in the search box finds nothing (PreparedStatement)" ""
h=$(page "$B/aspirant/exams.jsp?eligible=1"); n=$(echo "$h" | grep -o '[0-9]* exams found' | grep -o '^[0-9]*')
ok "$([[ -n "$n" && $n -gt 50 && $n -lt 267 ]] && echo 1)" "only-eligible filter ($n exams)" ""

# ---- exam detail
h=$(page "$B/aspirant/exam-detail.jsp?id=$upsc")
ok "$(both "$h" "You have 2 UPSC attempts left, valid until 2028." "role=\"tablist\"")" "exam detail shows the headline and tabs" ""
ok "$(both "$h" "21 to below 32 years on 1 August of the exam year" "OBC-NCL: +3 years")" "rules tab in plain words" ""
ok "$(both "$h" "Rule history" "v1")" "history tab lists version 1" ""
ok "$(has "$h" "Rules last verified on")" "verification line shown" ""
r=$(code "$B/aspirant/exam-detail.jsp?id=999999"); ok "$(has "$r" exams.jsp)" "unknown exam goes back to the explorer" "$r"
cgl=$(page "$B/aspirant/exams.jsp?q=SSC+CGL" | grep -o 'exam-detail.jsp?id=[0-9]*' | head -1 | grep -o '[0-9]*$')
r=$(code -d "examId=$cgl&action=track" $B/aspirant/track-action.jsp); h=$(page "$B/aspirant/exam-detail.jsp?id=$cgl")
ok "$(both "$h" "now on your tracked list" "Tracking - untrack")" "track SSC CGL" ""

# ---- dashboard
h=$(page $B/aspirant/dashboard.jsp)
ok "$(both "$h" "Eligible now" "data-count=")" "dashboard counters from the stored procedure" ""
ok "$(both "$h" "2 attempts left" "valid until <b class=\"mono\">2028</b>")" "UPSC attempt ticket" ""
ok "$(has "$h" "SSC CGL")" "SSC CGL ticket" ""
r=$(code -d "examId=$cgl&action=favourite&back=dashboard" $B/aspirant/track-action.jsp); ok "$(has "$r" dashboard.jsp)" "pin a ticket" "$r"

# ---- journal
r=$(code -d "action=save&id=0&examId=$upsc&cycleYear=2026&sittingNo=1&stageReached=APPEARED_STAGE_1" $B/aspirant/attempt-action.jsp)
h=$(page $B/aspirant/journal.jsp); ok "$(both "$h" "added to your journal" "counts as an attempt")" "logged attempt counts (trigger)" ""
h=$(page $B/aspirant/dashboard.jsp); ok "$(has "$h" "1 attempt left")" "dashboard now shows 1 attempt left" ""
r=$(code -d "action=save&id=0&examId=$upsc&cycleYear=2026&sittingNo=1&stageReached=APPLIED_ONLY" $B/aspirant/attempt-action.jsp)
h=$(page $B/aspirant/journal.jsp); ok "$(has "$h" "already logged")" "duplicate year and sitting refused" ""
r=$(code -d "action=save&id=0&examId=$cgl&cycleYear=2025&sittingNo=1&stageReached=APPLIED_ONLY" $B/aspirant/attempt-action.jsp)
h=$(page $B/aspirant/journal.jsp); ok "$(has "$h" "does not count")" "applied-only attempt does not count" ""
r=$(code -d "action=save&id=0&examId=$upsc&cycleYear=2026&sittingNo=2&attemptDate=2099-01-01&stageReached=APPEARED_STAGE_1" $B/aspirant/attempt-action.jsp)
h=$(page $B/aspirant/journal.jsp); ok "$(has "$h" "cannot be in the future")" "future exam date refused" ""
aid=$(echo "$h" | grep -o 'attempt-action.jsp?action=delete&amp;id=[0-9]*' | head -1 | grep -o '[0-9]*$')
r=$(code "$B/aspirant/attempt-action.jsp?action=delete&id=$aid"); h=$(page $B/aspirant/journal.jsp)
ok "$(has "$h" "Attempt deleted")" "attempt deleted" ""

# ---- report, notifications, untrack
r=$(code -d "examId=$upsc&message=short" $B/aspirant/report-action.jsp); h=$(page "$B/aspirant/exam-detail.jsp?id=$upsc")
ok "$(has "$h" "10 to 1000 characters")" "too short report refused" ""
r=$(code -d "examId=$upsc&message=The 2027 notification changed the age limit (smoke test)." $B/aspirant/report-action.jsp); h=$(page "$B/aspirant/exam-detail.jsp?id=$upsc")
ok "$(has "$h" "the administrator will check")" "report saved for the admin" ""
h=$(page $B/aspirant/notifications.jsp); ok "$(has "$h" "No notifications yet")" "notifications page" ""
r=$(code -d "examId=$cgl&action=untrack" $B/aspirant/track-action.jsp); h=$(page "$B/aspirant/exam-detail.jsp?id=$cgl")
ok "$(has "$h" "removed from your tracked list")" "untrack SSC CGL" ""

# ---- admin view
J_SAVE=$J; J=$D/admin.txt
code -d "email=admin@aspirantos.in&password=Admin@123" $B/login-action.jsp >/dev/null
h=$(page "$B/aspirant/exams.jsp?q=UPSC"); ok "$([[ "$h" == *"UPSC CSE"* && "$h" != *"status-chip"* ]] && echo 1)" "admin sees the explorer without status chips" ""
h=$(page "$B/aspirant/exam-detail.jsp?id=$upsc"); ok "$(has "$h" "Eligibility is shown to students")" "admin sees the exam page" ""
code $B/logout.jsp >/dev/null
J=$J_SAVE

# ---- clean up: delete the temporary account (all child rows go with ON DELETE CASCADE)
r=$(code -d "action=deleteAccount&password=abcd1234&confirm=yes" $B/aspirant/settings-action.jsp)
ok "$(has "$r" login.jsp)" "temporary account deleted" "$r"
rm -rf "$D"
echo "RESULT: $pass passed, $fail failed"
