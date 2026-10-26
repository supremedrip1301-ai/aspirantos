#!/bin/bash
# Smoke test of Phase 10 (design polish): bundled fonts + licences, print stylesheet, sidebar
# navigation with aria-current, account menu, toasts, print buttons, theme cookie on the error
# page, and no files loaded from the internet. Needs the WAR deployed on
# http://localhost:8080/AspirantOS. A temporary student is registered and deleted at the end.
B=http://localhost:8080/AspirantOS
D=$(mktemp -d); S=$D/student.txt
TS=$(date +%s); EMAIL="smoke.$TS@test.local"
pass=0; fail=0
ok() { if [ "$1" = "1" ]; then pass=$((pass+1)); echo "PASS  $2"; else fail=$((fail+1)); echo "FAIL  $2  -> $3"; fi; }
has() { [[ "$1" == *"$2"* ]] && echo 1; }
scode() { curl -s -o /dev/null -w "%{http_code} %{redirect_url}" -b $S -c $S "$@"; }
spage() { curl -s -b $S -c $S "$@"; }

# ---- static files
for f in fraunces-latin-wght-normal manrope-latin-wght-normal jetbrains-mono-latin-wght-normal; do
    r=$(curl -s -o $D/font.bin -w "%{http_code}" $B/assets/fonts/$f.woff2); magic=$(head -c 4 $D/font.bin)
    ok "$([[ $r == 200 && $magic == wOF2 ]] && echo 1)" "font $f.woff2 served" "$r $magic"
done
lic=0; for f in OFL-Fraunces OFL-Manrope OFL-JetBrainsMono; do curl -s $B/assets/fonts/$f.txt | grep -q "SIL Open Font License" && lic=$((lic+1)); done
ok "$([[ $lic == 3 ]] && echo 1)" "three OFL licence files next to the fonts" "$lic"
css=$(curl -s $B/assets/css/tokens.css)
ok "$([[ "$css" == *"@font-face"* && "$css" == *"../fonts/fraunces-latin-wght-normal.woff2"* && "$css" == *'[data-theme="dark"]'* ]] && echo 1)" "tokens.css: local @font-face rules and the dark theme" ""
all=$(curl -s $B/assets/css/tokens.css $B/assets/css/app.css $B/assets/css/print.css)
ok "$([[ "$all" != *"http://"* && "$all" != *"https://"* && "$all" != *"@import"* ]] && echo 1)" "no stylesheet loads anything from the internet" ""
p=$(curl -s $B/assets/css/print.css); ok "$([[ "$p" == *".sidebar"* && "$p" == *"#panel-history"* && "$p" == *"print-color-adjust"* ]] && echo 1)" "print stylesheet hides navigation and keeps the stamp colours" ""
h=$(curl -s $B/home.jsp)
ok "$([[ "$h" == *'href="/AspirantOS/assets/css/print.css" media="print"'* && "$h" == *'class="signed-out"'* && "$h" != *'class="sidebar"'* ]] && echo 1)" "public page: print.css linked, no sidebar" ""

# ---- student pages
scode -d "fullName=Smoke Design&email=$EMAIL&password=abcd1234&confirmPassword=abcd1234" $B/register-action.jsp >/dev/null
scode -d "fullName=Smoke Design&dob=1996-09-15&gender=MALE&maritalStatus=UNMARRIED&nationality=INDIAN&domicileStateCode=UP" $B/aspirant/profile-step1.jsp >/dev/null
scode -d "category=GEN" $B/aspirant/profile-step2.jsp >/dev/null
h=$(spage $B/aspirant/profile-step4.jsp); upsc=$(echo "$h" | grep -o 'name="attempts_[0-9]*"' | head -1 | grep -o '[0-9]*')
ok "$([[ "$h" == *"data-print>Print profile sheet</button>"* && "$h" == *'class="print-only print-head"'* && "$h" == *"Profile sheet of Smoke Design"* ]] && echo 1)" "profile step 4: print button and print-only heading" ""
ok "$(echo "$h" | grep -c 'aria-current="page"><svg[^>]*><path[^>]*/></svg><span>Profile</span>' | grep -q 1 && echo 1)" "sidebar marks Profile as the current page on step 4" ""
scode -d "attempts_$upsc=2" $B/aspirant/profile-save.jsp >/dev/null
h=$(spage $B/aspirant/dashboard.jsp)
ok "$([[ "$h" == *'class="sidebar" aria-label="Main"'* && "$h" == *'class="layout has-sidebar"'* ]] && echo 1)" "logged-in page has the sidebar layout" ""
n=$(echo "$h" | grep -o 'aria-current="page"' | wc -l); ok "$([[ $n == 1 && "$h" == *'aria-current="page"><svg class="nav-icon"'*'<span>Dashboard</span>'* ]] && echo 1)" "exactly one sidebar link is current (Dashboard)" "$n"
ok "$([[ "$h" == *'class="flash flash-success toast" role="status"'* && "$h" == *'class="toast-close" aria-label="Close message"'* ]] && echo 1)" "the success message after saving is a toast with a close button" ""
ok "$([[ "$h" == *'role="search"'* && "$h" == *'action="/AspirantOS/aspirant/exams.jsp"'* && "$h" == *'<span class="avatar" aria-hidden="true">SD</span>'* ]] && echo 1)" "header: exam search and account menu with initials" ""
ok "$([[ "$h" == *'aria-label="Notifications, '*' unread"'* ]] && echo 1)" "bell has a label for screen readers" ""
h=$(spage "$B/aspirant/exam-detail.jsp?id=$upsc")
ok "$([[ "$h" == *"data-print>Print report</button>"* && "$h" == *"Eligibility report for Smoke Design"* && "$h" == *'aria-current="page"><svg class="nav-icon"'*'<span>Explore</span>'* ]] && echo 1)" "exam page: print report button, report heading, Explore stays current" ""
h=$(spage -b "theme=dark" $B/aspirant/journal.jsp)
ok "$(has "$h" 'data-theme="dark"')" "dark theme cookie switches the theme" ""
r=$(curl -s -b "theme=dark" -o $D/err.html -w "%{http_code}" $B/no-such-page.jsp); h=$(cat $D/err.html)
ok "$([[ $r == 404 && "$h" == *'data-theme="dark"'* ]] && echo 1)" "error page follows the theme cookie" "$r"

# ---- clean up
scode -d "action=deleteAccount&password=abcd1234&confirm=yes" $B/aspirant/settings-action.jsp >/dev/null
rm -rf "$D"
echo "RESULT: $pass passed, $fail failed"
