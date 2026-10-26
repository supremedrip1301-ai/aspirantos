# AspirantOS — TEST REPORT

## 1. Engine self-test (P4.3)

- **Class:** `com.aspirantos.engine.EngineSelfTest` (plain `main` method, no JUnit)
- **How to run in Eclipse:** right-click `EngineSelfTest.java` → Run As → Java Application.
- **How to run from the command line:** `tools\build.cmd`, then `java -cp build\cli\classes com.aspirantos.engine.EngineSelfTest`
- **Data:** in-memory sample profiles and rule sets copied from the seed files. These are test data inside Java only, not database accounts (CHANGE 001).
- **"Today":** fixed to 15-Jan-2027, the presentation simulation date.
- **Run on:** 26-Oct-2026, OpenJDK 21.0.12 (Temurin), Windows 11.
- **Result:** **61 passed, 0 failed.** The exact demo headline "You have 2 UPSC attempts left, valid until 2028." is test 01.

The list below is the exact console output. Headlines in the engine use a long dash (U+2014); the test names use only plain ASCII.

```
AspirantOS EngineSelfTest - today = 2027-01-15
------------------------------------------------------------
PASS  01  Sample profile (GEN, born 15-Sep-1996, B.A. 2018, 4 attempts): exact UPSC headline
PASS  02  Sample profile: status ELIGIBLE, used 4, remaining 2, cycle 2027
PASS  03  Sample profile: date-of-birth window for 2027
PASS  04  Sample profile: relaxation breakdown (General)
PASS  05  Sample profile: 609 days until the age limit (turns 32 on 15-Sep-2028)
PASS  06  NOT_ATTAINED 32: born 02-Aug-1995 (day after) is 31 on the cut-off -> eligible for 2027 only
PASS  07  NOT_ATTAINED 32: born 01-Aug-1995 (birthday = cut-off) attains 32 -> NOT_ELIGIBLE
PASS  08  NOT_ATTAINED 32: born 31-Jul-1995 (day before) -> NOT_ELIGIBLE
PASS  09  NOT_MORE_THAN 32: born 01-Aug-1995 is exactly 32 on the cut-off -> ELIGIBLE
PASS  10  NOT_MORE_THAN 32: born 02-Aug-1994 (day after) is still 32 -> ELIGIBLE
PASS  11  NOT_MORE_THAN 32: born 01-Aug-1994 turns 33 on the cut-off -> NOT_ELIGIBLE
PASS  12  Minimum age 21: born 01-Aug-2006 completes 21 on the cut-off -> ELIGIBLE
PASS  13  Minimum age 21: born 02-Aug-2006 is 20 -> NOT_YET from 2028
PASS  14  OBC + PwBD stacking: 32 + 3 + 10 = 45
PASS  15  OBC + PwBD aged 44 on the cut-off is eligible with 9 attempts
PASS  16  General PwBD (40%) gets 9 attempts and +10 years
PASS  17  PwBD below 40% is not a benchmark disability: no relaxation, 6 attempts, NOT_ELIGIBLE at 37
PASS  18  SC: unlimited attempts, ending by age (37) after 2028
PASS  19  SC: attemptsRemaining is null (shown as Unlimited)
PASS  20  EWS gets no age relaxation: 32 on the cut-off -> NOT_ELIGIBLE, reason shown
PASS  21  Attempts exhausted: General with 6 of 6 used
PASS  22  Attempt journal: 3 before the app + 1 counted log (applied-only not counted) = 4 used, 2 left
PASS  23  Ex-serviceman: age 37 minus 8 years of service = 29, below 30 + 3 -> ELIGIBLE
PASS  24  Ex-serviceman: only 2 years of service -> age counts as 35 -> NOT_ELIGIBLE
PASS  25  Government employee: upper age raised to 40 (REPLACE_WITH_MAX with cap) -> ELIGIBLE at 38
PASS  26  SSC CGL post groups: age 28 -> best group is 18-30, a Post group line explains it
PASS  27  State exam: OBC from Bihar in UPPSC is treated as General (40) -> NOT_ELIGIBLE at 42
PASS  28  State exam: the same OBC candidate with UP domicile gets +5 (45) -> ELIGIBLE
PASS  29  Final-year B.Sc student: PROVISIONAL, must pass by 30-Jun-2027
PASS  30  Class 12 student and UPSC: NOT_YET, eligible after graduation
PASS  31  IBPS Clerk: final year not allowed, but the result (31-May-2027) comes before the October exam -> PROVISIONAL
PASS  32  Nationality not in the list -> NOT_ELIGIBLE
PASS  33  JEE Main: Class 12 in 2025 -> 3-year window 2025-2027
PASS  34  JEE Main: Class 12 in 2023 -> window 2023-2025 is over -> NOT_ELIGIBLE
PASS  35  JEE Advanced: 2 attempts in 2 consecutive years, 1 used
PASS  36  JEE Advanced DOB window: born 30-Sep-2002 (before 01-Oct-2002) -> NOT_ELIGIBLE
PASS  37  JEE Advanced DOB window: born 01-Oct-2002 -> ELIGIBLE with 2 attempts
PASS  38  JEE Advanced: SC window moves 5 years earlier (01-Oct-1997) -> ELIGIBLE
PASS  39  NEET: born 31-Dec-2010 is 17 on 31-Dec-2027 -> PROVISIONAL (Class 12 appearing)
PASS  40  NEET: born 01-Jan-2011 is 16 on 31-Dec-2027 -> NOT_YET from 2028
PASS  41  NEET subjects: PCM without Biology/Biotechnology -> NOT_ELIGIBLE
PASS  42  NEET subjects: Biotechnology instead of Biology is accepted -> ELIGIBLE
PASS  43  CAT: no age limit, 55% graduate born 1970
PASS  44  CAT: General with 48% (needs 50%) -> NOT_ELIGIBLE
PASS  45  CAT: SC with 46% passes the relaxed 45% -> ELIGIBLE
PASS  46  CGPA 5.5/10 = 52.25% (x 9.5) -> CAT ELIGIBLE
PASS  47  CGPA 5.2/10 = 49.4% -> CAT NOT_ELIGIBLE
PASS  48  GRE: last test on 30-Dec-2026 + 21-day gap -> next test from 20-Jan-2027
PASS  49  GRE: 5 tests in the last 12 months -> next test from 01-Feb-2027 (rolling 12 months)
PASS  50  GRE: no tests yet -> can test now
PASS  51  GMAT: 8 lifetime attempts used -> EXHAUSTED (lifetime and rolling rules together)
PASS  52  NDA: born 15-Mar-2009 is inside the 2027 window, Class 12 appearing -> PROVISIONAL
PASS  53  NDA: the age is reported first for a 26-year-old graduate (no Class 12 row needed to see that)
PASS  54  NDA: a married candidate is blocked
PASS  55  UGC NET: age 37 -> JRF closed, Assistant Professor group (no age limit) -> ELIGIBLE
PASS  56  UGC NET JRF: SC + PwBD + woman get only the largest 'up to 5 years' (30 -> 35, not 45)
PASS  57  Leap day: born 29-Feb-2004 is 20 on 28-Feb-2025 and 21 on 01-Mar-2025
PASS  58  Leap day: born 29-Feb-1996 is 31 on 01-Aug-2027 and 32 on 01-Aug-2028
PASS  59  Planner: UPSC prelims (May) already over on 01-Jun-2027 -> next cycle 2028; JEE Main July sitting still open on 01-Mar-2027
PASS  60  Snapshot text: a check line survives toStorageText / fromStorageText
PASS  61  Profile without date of birth -> profileIncomplete, asks to complete the profile
------------------------------------------------------------
RESULT: 61 passed, 0 failed, 61 total
```

### What the tests cover (PART 6 checklist)

| Required case | Tests |
|---|---|
| Sample profile (GEN, born 15-Sep-1996, B.A. 2018, 4 attempts) → exact headline | 01–05 |
| NOT_ATTAINED vs NOT_MORE_THAN on the day before, the day of and the day after the cut-off birthday | 06–11 |
| Minimum-age boundary | 12–13 |
| OBC + PwBD stacking | 14–15 |
| PwBD attempts; disability below 40 % gets no benefit | 16–17 |
| SC: unlimited attempts that end because of age | 18–19 |
| EWS gets no age relaxation | 20 |
| Attempts exhausted; attempt journal counting | 21–22 |
| Ex-serviceman: military service deducted from age | 23–24 |
| Government employee: age raised to a cap (REPLACE_WITH_MAX) | 25 |
| Post groups (SSC CGL) | 26 |
| State exam: reserved candidate from another state treated as GEN | 27–28 |
| Final-year students: PROVISIONAL (with and without final-year entry) | 29, 31 |
| Class 12 student and UPSC → NOT_YET | 30 |
| Nationality block | 32 |
| JEE Main 3-year window | 33–34 |
| JEE Advanced: 2 attempts and DOB window (with SC relaxation) | 35–38 |
| NEET: minimum age 17 by 31 December; subject check | 39–42 |
| CAT: no age limit; percentage relaxation for SC; CGPA conversion | 43–47 |
| GRE rolling 12-month and gap rule; GMAT lifetime limit | 48–51 |
| NDA birth-date window; age reported first; marital-status block | 52–54 |
| UGC NET post groups; only the largest "up to 5 years" relaxation counts | 55–56 |
| Leap-day birthday (29 February) | 57–58 |
| Cycle planner, snapshot text format, incomplete profile | 59–61 |

## 2. Engine sweep over the real catalogue

A scratch program loaded every exam's active rule version from MySQL through `EligibilityService.loadRuleSet()`. It then ran the engine for 7 in-memory profiles: B.Tech GEN 26; OBC PwBD 35 from UP; SC widow 30 with M.Sc; Class 12 student; ex-serviceman 42; final-year B.Com EWS; no education.

That is 267 exams × 7 profiles = 1869 evaluations.

- **Exceptions:** 0.
- **Empty headlines:** 0.
- **Headlines longer than 160 characters:** 0 (the snapshot column limit is 255).

## 3. EligibilityService end-to-end (P4.2)

A temporary aspirant account was created through the DAOs and deleted at the end; the database is back to 1 admin and 0 snapshots. "Today" was the real date, 26-Oct-2026, so the next UPSC cycle is 2027.

| Check | Result |
|---|---|
| No profile yet → no snapshots | PASS |
| `checkExam()` for UPSC CSE → "You have 2 UPSC attempts left, valid until 2028." | PASS |
| Snapshot stored with the active rule version, the check lines and attempts_remaining = 2 | PASS |
| `getSnapshots()` for all 267 exams | PASS (first pass about 5.4 s) |
| Second call is served from the snapshot cache | PASS (15 ms) |
| New attempt logged → trigger deletes the stale snapshot | PASS |
| Recomputed snapshot → "You have 1 UPSC attempt left, valid until 2028." | PASS |

## 4. Auth, profile wizard and settings (Phase 5)

- **Script:** `tools/smoke-auth.sh` (bash + curl), run against the WAR deployed on Tomcat 11.0.27.
- **Account:** a temporary student `smoke.<time>@test.local` is registered by the script and deleted by the script at the end. No student account remains in the database (CHANGE 001).
- **Result (26-Oct-2026): 35 passed, 0 failed.**

| Area | Checks |
|---|---|
| Register | validation errors keep the typed values; account created; logged in and sent to the wizard |
| Wizard step 1 | unknown state refused; saved into the session bean; a posted `step2Done` cannot skip step 2 |
| Wizard step 2 | PwBD without type / percentage refused; saved |
| Step 3 (education / experience) | UG without degree refused; row added with ticked + typed subjects; second Class 12 refused; end-before-start refused; experience added and deleted |
| Step 4 + save | 20 exams with attempt limits listed with the review; 99 attempts refused; profile saved; dashboard shows "You have 2 UPSC attempts left, valid until 2028." |
| Login / logout | logout ends the session; protected page redirects to login; wrong password refused (e-mail kept); login goes to the dashboard |
| Remember me | cookie set; a new browser session is logged in by the cookie; password change logs that device out |
| Settings | theme cookie switches the page to dark; password change; delete needs the confirm box; account deleted and cannot log in again |
| Admin | admin login goes to the admin dashboard (267 exams); admin is kept out of the student wizard |

The same flow was also clicked through in the browser (light and dark theme) with one more temporary account, which was deleted afterwards. EngineSelfTest still passes 61/61.

## 5. Exams, eligibility UI, journal and dashboard (Phase 6)

- **Script:** `tools/smoke-exams.sh`. A temporary student is registered with the sample profile (General, 15-Sep-1996, B.A. 2018, 4 UPSC attempts) and deleted at the end.
- **Result (26-Oct-2026): 30 passed, 0 failed.** `tools/smoke-auth.sh` was run again afterwards: 35/35.

| Area | Checks |
|---|---|
| Explorer | 267 exams with pages; search "UPSC" with a status chip; category filter + sort; page 2; SQL text in the search box finds 0 exams; "only eligible" filter (114 exams) |
| Exam detail | headline "You have 2 UPSC attempts left, valid until 2028." with tabs; rules in plain words ("21 to below 32 years on 1 August of the exam year", "OBC-NCL: +3 years"); rule history v1; verification line; an unknown id goes back to the explorer |
| Tracking | track SSC CGL, pin it on the dashboard, untrack it |
| Dashboard | counters from `sp_user_dashboard_summary`; UPSC ticket "2 attempts left / valid until 2028"; SSC CGL ticket |
| Journal | a logged UPSC 2026 attempt counts (set by the trigger) and the ticket changes to "1 attempt left"; duplicate year + sitting refused; "applied only" does not count; future date refused; delete |
| Reports, notifications | a too short report is refused, a report is saved; notifications page |
| Admin | sees the explorer without status chips and the exam page without the eligibility part |

Other checks:

- **Bulk loading:** for all 267 exams, loading the rules in bulk and one exam at a time gave identical headlines and check lines (0 differences). The first full computation now takes 1.3 s instead of 5.4 s.
- **Mobile layout:** at 375 px width, every student page has no horizontal scroll. A table that is wider than the screen scrolls inside its own box.
- **Browser check:** dashboard tickets, stamps and counters; tab switching.

## 6. Admin area: dashboard, users, settings, exam CRUD, rule versions (Phase 8.1-8.3)

- **Script:** `tools/smoke-admin.sh`, run with the root password in `MYSQL_PWD` so that it can remove its own test exam at the end.
- **Test data:** the script never touches the seeded exams. It creates its own exam `SMOKE_<time>` and a temporary student, and removes both at the end.
- **Result (26-Oct-2026): 35 passed, 0 failed.** The other two smoke tests were run again afterwards: smoke-exams 30/30 and smoke-auth 35/35. EngineSelfTest: 61/61.

| Area | Checks |
|---|---|
| Dashboard | System information card (DatabaseMetaData, Connector/J); counters |
| Users | search; read-only profile; block ends the student's open session at once; blocked student cannot log in; unblock |
| Settings | presentation date set; banner shown and the student dashboard uses 15-Jan-2027; out-of-range date refused; cleared again; audit log entry |
| Exam CRUD | invalid code refused (values kept); exam created; "Verified" without date and source refused; edit keeps the code |
| Rule versions | empty v1 draft; age rule with max < min refused; 3 rules added; publish without a summary refused; v1 published; student sees "You have 3 ... attempts left, valid until 2026." |
| Update flow | clone to draft v2; age limit 30 -> 35; diff shows the old row struck through and the new row highlighted; edit logged; publish notifies the 1 tracking student; the student's result is recalculated (valid until 2031); v1 archived |
| Safety | unchanged draft cannot be published; draft discarded; ACTIVE version cannot be edited; deactivated exam hidden from students |

Other checks:

- **Layout:** every admin page (including the draft editor with all forms open) fits at 375 px and 1280 px.
- **Database after the tests:** 1 admin, 267 exams, 267 rule versions, no draft, empty simulation date. All `98_integrity_checks.sql` problem counts are 0.

## 7. Update checker, rule pack, editors, reports, DB Explorer (Phase 8.4-8.7)

- **Script:** `tools/smoke-admin2.sh` (needs `MYSQL_PWD`). It creates its own exam `SMOKE2_<time>` and a temporary student, and removes both at the end, together with the update checks made during the run. The test exam's "official page" is a page of the app itself, so the update checker can be tested without the internet.
- **Result (26-Oct-2026): 35 passed, 0 failed.** Afterwards the other smoke tests were run again: smoke-admin 35/35, smoke-exams 30/30, smoke-auth 35/35. EngineSelfTest: 61/61.

| Area | Checks |
|---|---|
| Update checker | first check saves the page fingerprint; second check reports "no change"; a different page is reported as changed, with snippets; an unreachable site gives a message and no crash; update checks list |
| Check all | progress JSON (403 without an admin login); job starts in the background and stops on request |
| Rule pack | preview without problems; apply creates v1; export of one exam and of all exams (1994 lines); bad lines listed with line numbers and Apply disabled; an invalid pack cannot be applied; an edited export shows the diff and creates v2 (v1 archived); an exam with an open draft is blocked |
| Editors | photo spec with max < min refused; spec saved; exam date saved and deleted |
| Reports | a student's report reaches the inbox; it is resolved with a reply and the student gets a notification |
| DB Explorer | secret columns hidden; Next / go to row 100 / Previous / Last pages of exam_event (1478 rows); an unknown table name falls back to app_setting; a view can be browsed; quick edit with a bad value refused; quick edit saved through an updatable ResultSet (and restored) |

Other checks:

- **Round trip:** exporting all 267 exams and parsing the file again gave 1990 rows, 0 problems and 0 differences from the active rules.
- **Layout:** every new admin page fits at 375 px and 1280 px.
- **Database after the tests:** 1 admin, 267 exams and versions, no draft, no update check, no report, empty simulation date, cycles = 15. All integrity checks are 0.

## 8. Landing page, About, error page, horizon, calendar (Phase 9)

- **Script:** `tools/smoke-features.sh`. A temporary student with the sample profile is registered and deleted at the end.
- **Result (26-Oct-2026): 21 passed, 0 failed.** The other smoke tests were run again afterwards: smoke-auth 35/35, smoke-exams 30/30, smoke-admin 35/35, smoke-admin2 35/35. EngineSelfTest: 61/61.

| Area | Checks |
|---|---|
| Landing page | `/` forwards (no redirect) to the landing page; instant check form; category tiles with icons |
| Instant check (JSON) | sample profile gives "You have 2 UPSC attempts left, valid until 2028."; OBC + PwBD breakdown 32 + 3 + 10 = 45; a bad date gives a JSON error with status 400 |
| About | opened through the web.xml mapping with its init params; the application-wide visit counter goes up; the JSP inside WEB-INF cannot be opened directly; ER diagram served |
| Error page | friendly 404 without technical details |
| Horizon | asks for a profile first; SVG with the tracked UPSC bar, 2 attempt dots and the today line; age clock shows the age on 01-Aug-2027 |
| Calendar | May 2027 shows the UPSC prelims (23-May-2027); a bad month falls back to the current month; a single date downloads as text/calendar with CRLF lines; all tracked dates of the next 12 months; download links on the exam page; .ics needs a login |

Other checks:

- **Layout:** landing, About, horizon, calendar, dashboard and the error page all fit at 375 px and 1280 px.
- **Database after the tests:** 1 admin, 267 exams, no draft, empty simulation date.

## 9. Design polish (Phase 10)

- **Script:** `tools/smoke-design.sh`. A temporary student is registered and deleted at the end.
- **Result (26-Oct-2026): 18 passed, 0 failed.** The other smoke tests were run again afterwards: smoke-auth 35/35, smoke-exams 30/30, smoke-features 21/21, smoke-admin 35/35, smoke-admin2 35/35. EngineSelfTest: 61/61.

| Area | Checks |
|---|---|
| Fonts | the three woff2 files are served (woff2 signature), the three OFL licence files are there, tokens.css has the local @font-face rules |
| No internet | no stylesheet contains an http(s) address or @import |
| Layout | logged-in pages have the sidebar layout; exactly one link is marked as the current page (Dashboard, Explore on the exam page, Profile on the wizard); public pages have no sidebar |
| Header | exam search form, bell with a screen-reader label, account menu with the initials |
| Toasts | the message after saving the profile is a toast with a close button |
| Print | print.css linked on every page; print buttons and print-only headings on the exam page and on profile step 4 |
| Theme | the dark theme cookie switches every page, including the error page |

Checks made in the browser with a script (every student page, every admin page, the public pages):

- **Responsive:** no horizontal scrolling and no element wider than the screen at 360, 768 and 1280 px, in the light and the dark theme. One problem found and fixed: the check table of the exam page was too wide on phones (now shown as a list).
- **Contrast:** every text checked against its real background - nothing below WCAG AA (4.5 : 1, or 3 : 1 for large text) in either theme. Fixed on the way: white text on saffron buttons, amber text, white text on the light chips of the dark theme, the year chips of the exam page, the 404 number.
- **Forms:** every input, select and text area has a label; one h1 per page; no button without a name.
- **Print preview:** the exam page printed with all tabs (except History) under a heading with the student name and the date; the stamp keeps its colour.
