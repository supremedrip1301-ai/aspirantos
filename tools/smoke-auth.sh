#!/bin/bash
# Smoke test of register / login / logout / profile wizard / settings (Phase 5).
# Needs the WAR deployed on http://localhost:8080/AspirantOS. A temporary student
# (smoke.<time>@test.local) is registered and deletes itself at the end (CHANGE 001).
B=http://localhost:8080/AspirantOS
D=$(mktemp -d); J=$D/jar.txt; J2=$D/jar2.txt
EMAIL="smoke.$(date +%s)@test.local"
pass=0; fail=0
ok() { if [ "$1" = "1" ]; then pass=$((pass+1)); echo "PASS  $2"; else fail=$((fail+1)); echo "FAIL  $2  -> $3"; fi; }
code() { curl -s -o /dev/null -w "%{http_code} %{redirect_url}" -b $J -c $J "$@"; }
page() { curl -s -b $J -c $J "$@"; }
has() { [[ "$1" == *"$2"* ]] && echo 1; }

r=$(code $B/register.jsp); ok "$([[ $r == 200* ]] && echo 1)" "register page loads" "$r"
r=$(code -d "fullName=Smoke Tester&email=$EMAIL&password=abcd1234&confirmPassword=abcd9999" $B/register-action.jsp)
ok "$(has "$r" register.jsp)" "password mismatch goes back to register" "$r"
h=$(page $B/register.jsp)
ok "$([[ "$h" == *"do not match"* && "$h" == *"Smoke Tester"* ]] && echo 1)" "error shown and typed name kept" ""
r=$(code -d "fullName=Smoke Tester&email=$EMAIL&phone=9876543210&password=abcd1234&confirmPassword=abcd1234" $B/register-action.jsp)
ok "$(has "$r" aspirant/profile-step1.jsp)" "register creates account and opens wizard" "$r"
h=$(page $B/aspirant/profile-step1.jsp)
ok "$([[ "$h" == *"Personal details"* && "$h" == *"Account created"* ]] && echo 1)" "step 1 shows with success message" ""
r=$(code -d "fullName=Smoke Tester&dob=1996-09-15&gender=MALE&maritalStatus=UNMARRIED&nationality=INDIAN&domicileStateCode=XX" $B/aspirant/profile-step1.jsp)
h=$(page $B/aspirant/profile-step1.jsp); ok "$(has "$h" "domicile state")" "unknown state rejected" ""
r=$(code -d "fullName=Smoke Tester&phone=9876543210&dob=1996-09-15&gender=MALE&maritalStatus=UNMARRIED&nationality=INDIAN&domicileStateCode=UP&city=Lucknow&pincode=226001&step2Done=true" $B/aspirant/profile-step1.jsp)
ok "$(has "$r" profile-step2.jsp)" "step 1 saved" "$r"
r=$(code $B/aspirant/profile-step3.jsp); ok "$(has "$r" profile-step2.jsp)" "cannot skip step 2 (posted step2Done ignored)" "$r"
r=$(code -d "category=GEN&pwbd=true" $B/aspirant/profile-step2.jsp); h=$(page $B/aspirant/profile-step2.jsp)
ok "$(has "$h" "type of disability")" "PwBD without details rejected" ""
r=$(code -d "category=GEN" $B/aspirant/profile-step2.jsp); ok "$(has "$r" profile-step3.jsp)" "step 2 saved" "$r"
r=$(code -d "action=save&id=0&level=UG&status=COMPLETED&passingYear=2018" $B/aspirant/education-action.jsp)
h=$(page $B/aspirant/profile-step3.jsp); ok "$(has "$h" "degree or course name")" "UG without degree name rejected" ""
r=$(code -d "action=save&id=0&level=UG&degreeName=B.A.&subject=HISTORY&subject=POLITICAL SCIENCE&otherSubjects=Sociology&percentage=62&status=COMPLETED&passingYear=2018" $B/aspirant/education-action.jsp)
h=$(page $B/aspirant/profile-step3.jsp)
ok "$([[ "$h" == *"Education added"* && "$h" == *"HISTORY, POLITICAL SCIENCE, SOCIOLOGY"* ]] && echo 1)" "education row added with subjects" ""
r=$(code -d "action=save&id=0&level=CLASS_12&subject=HISTORY&percentage=70&status=COMPLETED&passingYear=2015" $B/aspirant/education-action.jsp)
r=$(code -d "action=save&id=0&level=CLASS_12&percentage=71&status=COMPLETED&passingYear=2015" $B/aspirant/education-action.jsp)
h=$(page $B/aspirant/profile-step3.jsp); ok "$(has "$h" "already added Class 12")" "second Class 12 row refused" ""
r=$(code -d "action=save&id=0&organisation=Acme Ltd&startDate=2019-01-01&endDate=2018-01-01" $B/aspirant/experience-action.jsp)
h=$(page $B/aspirant/profile-step3.jsp); ok "$(has "$h" "after the start date")" "work end before start refused" ""
r=$(code -d "action=save&id=0&organisation=Acme Ltd&designation=Clerk&startDate=2019-01-01&endDate=2020-06-30" $B/aspirant/experience-action.jsp)
h=$(page $B/aspirant/profile-step3.jsp); ok "$(has "$h" "Acme Ltd")" "work experience added" ""
wid=$(echo "$h" | grep -o 'experience-action.jsp?action=delete&amp;id=[0-9]*' | head -1 | grep -o '[0-9]*$')
r=$(code "$B/aspirant/experience-action.jsp?action=delete&id=$wid"); h=$(page $B/aspirant/profile-step3.jsp)
ok "$([[ "$h" == *"Work experience deleted"* && "$h" != *"Acme Ltd"* ]] && echo 1)" "work experience deleted" ""
h=$(page $B/aspirant/profile-step4.jsp); upsc=$(echo "$h" | grep -o 'name="attempts_[0-9]*"' | head -1 | grep -o '[0-9]*')
ok "$([[ "$h" == *"UPSC CSE"* && "$h" == *"Smoke Tester"* && -n "$upsc" ]] && echo 1)" "step 4 lists limited-attempt exams and the review" ""
r=$(code -d "attempts_$upsc=99" $B/aspirant/profile-save.jsp); h=$(page $B/aspirant/profile-step4.jsp)
ok "$(has "$h" "from 0 to 20")" "99 attempts refused" ""
r=$(code -d "attempts_$upsc=4" $B/aspirant/profile-save.jsp); ok "$(has "$r" aspirant/dashboard.jsp)" "profile saved" "$r"
h=$(page $B/aspirant/dashboard.jsp)
ok "$([[ "$h" == *"Profile created"* && "$h" == *"You have 2 UPSC attempts left, valid until 2028."* ]] && echo 1)" "dashboard shows the UPSC headline" "$(echo "$h" | grep -o 'headline">[^<]*')"
r=$(code $B/logout.jsp); ok "$(has "$r" login.jsp)" "logout redirects to login" "$r"
r=$(code $B/aspirant/dashboard.jsp); ok "$(has "$r" login.jsp)" "dashboard needs login after logout" "$r"
r=$(code -d "email=$EMAIL&password=wrong123" $B/login-action.jsp); h=$(page $B/login.jsp)
ok "$([[ "$h" == *"not correct"* && "$h" == *"$EMAIL"* ]] && echo 1)" "wrong password refused, e-mail kept" ""
r=$(code -d "email=$EMAIL&password=abcd1234&remember=on" $B/login-action.jsp); ok "$(has "$r" aspirant/dashboard.jsp)" "login with profile goes to dashboard" "$r"
tok=$(awk '$6=="remember" {print $7}' $J); ok "$([[ ${#tok} -ge 20 ]] && echo 1)" "remember-me cookie set" ""
printf "# Netscape HTTP Cookie File\nlocalhost\tFALSE\t/AspirantOS\tFALSE\t0\tremember\t%s\n" "$tok" > $J2
r=$(curl -s -o /dev/null -w "%{http_code}" -b $J2 -c $J2 $B/aspirant/dashboard.jsp); ok "$([[ $r == 200 ]] && echo 1)" "new browser session logged in by remember-me cookie" "$r"
r=$(code -d "action=theme&theme=dark" $B/aspirant/settings-action.jsp); h=$(page $B/aspirant/settings.jsp)
ok "$([[ "$h" == *'data-theme="dark"'* && "$h" == *"Theme set to dark"* ]] && echo 1)" "theme cookie switches to dark" ""
r=$(code -d "action=password&currentPassword=abcd1234&newPassword=newpass99&confirmPassword=newpass99" $B/aspirant/settings-action.jsp); h=$(page $B/aspirant/settings.jsp)
ok "$(has "$h" "Password changed")" "password changed" ""
rm -f $J2.new; printf "# Netscape HTTP Cookie File\nlocalhost\tFALSE\t/AspirantOS\tFALSE\t0\tremember\t%s\n" "$tok" > $J2
r=$(curl -s -o /dev/null -w "%{http_code} %{redirect_url}" -b $J2 $B/aspirant/dashboard.jsp); ok "$(has "$r" login.jsp)" "other device logged out after password change" "$r"
r=$(code -d "action=deleteAccount&password=newpass99" $B/aspirant/settings-action.jsp); h=$(page $B/aspirant/settings.jsp)
ok "$(has "$h" "tick the box")" "delete needs the confirm box" ""
r=$(code -d "action=deleteAccount&password=newpass99&confirm=yes" $B/aspirant/settings-action.jsp)
h=$(page $B/login.jsp); ok "$(has "$h" "have been deleted")" "account deleted" ""
rm -f $J
r=$(code -d "email=admin@aspirantos.in&password=Admin@123" $B/login-action.jsp); ok "$(has "$r" admin/dashboard.jsp)" "admin login goes to admin dashboard" "$r"
h=$(page $B/admin/dashboard.jsp); ok "$([[ "$h" == *"Active exams"* && "$h" == *">267<"* ]] && echo 1)" "admin dashboard shows counts" ""
r=$(code $B/aspirant/profile-step1.jsp); ok "$(has "$r" admin/dashboard.jsp)" "admin is kept out of the student wizard" "$r"
r=$(code $B/logout.jsp)
rm -f $J
r=$(code -d "email=$EMAIL&password=newpass99" $B/login-action.jsp); h=$(page $B/login.jsp)
ok "$(has "$h" "not correct")" "deleted account cannot log in" ""
echo "RESULT: $pass passed, $fail failed"
