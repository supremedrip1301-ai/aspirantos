# AspirantOS — VIVA GUIDE

> Started in Phase 3. The full guide (architecture walk-through, likely viva questions and answers, demo flow) is written in Phase 11. Until then this file keeps the register of everything marked `[EXTRA]` in the code and the syllabus map (where each syllabus topic is used).

## [EXTRA] register — code that goes beyond what was taught in the lab

Every item below is marked `[EXTRA] <reason>` in a comment where it is used.

| # | Where | What it is | Why it is needed | One-line viva answer |
|---|-------|-----------|------------------|----------------------|
| 1 | `sql/01_schema.sql` (`rule_version.active_exam_id`) | VIRTUAL generated column + UNIQUE key | Guarantees at most one ACTIVE rule version per exam inside the database itself | "The column holds the exam id only while the version is ACTIVE, otherwise NULL; UNIQUE ignores NULLs, so two ACTIVE versions of one exam are impossible." |
| 2 | `util/PasswordUtil.java` | PBKDF2WithHmacSHA256 hashing with a random salt (D39) | No plain-text password is ever stored | "Same password + same salt gives the same hash, so login compares hashes; the salt makes equal passwords look different." |
| 3 | `dao/RememberTokenDAO.java` | "Remember me" tokens (table `remember_token`) | The cookie holds a random token, the database stores only its SHA-256, so a stolen database cannot log anyone in | "The cookie is a random key; we keep only its hash, like a password." |
| 4 | `webapp/assets/css/tokens.css` | CSS custom properties (variables) | One place for colours, fonts and spacing; the dark theme only swaps values | "`var(--saffron)` is a variable; `[data-theme=dark]` redefines it." |
| 5 | `service/EligibilityService.java` | Service layer between JSPs and DAOs + snapshot cache in `eligibility_snapshot` | Keeps the engine free of JDBC (testable from a main method) and avoids recomputing 267 exams on every page | "The JSP asks the service; the service reads the DAOs, runs the engine and stores the answer; next time it reads the stored answer unless the date or the rule version changed." |
| 6 | `WEB-INF/jspf/remember-me.jspf`, `login-action.jsp` | "Remember me" cookie restored on the next visit (with RememberTokenDAO) | Students stay logged in on their own computer for 14 days | "The cookie has a random token; the database only has its hash; logout and password change delete it." |
| 7 | `login-action.jsp`, `register-action.jsp` (`request.changeSessionId()`) | New session id after login | Stops a session id that was planted before login from being used afterwards (session fixation) | "After login the server gives the browser a new session id, the old one becomes useless." |
| 8 | `dao/SnapshotDAO.saveSnapshots()` | JDBC batch: `addBatch()` + `executeBatch()` on one PreparedStatement | Saves up to 267 results in one go instead of 267 separate connections | "The same INSERT is prepared once, every row is added to a batch, and the batch is sent together." |
| 9 | `assets/css/app.css` (`.ticket`, `.stamp`) | CSS `mask` with radial gradients for the perforated ticket edge, CSS animation for the stamp | The signature "attempt ticket" look of the dashboard | "Two radial gradients cut half circles out of both sides; the stamp is a rotated bordered label with a short scale animation." |
| 10 | `service/UpdateChecker.java` | `java.net.http.HttpClient` (timeouts, redirects), HTML to text, SHA-256 fingerprint | Detects that an official exam page has changed | "We download the official page, keep only its text and compare its fingerprint with the last check; the admin reads the highlighted lines and updates the rules." |
| 11 | `service/UpdateCheckJob.java` | A background `Thread` started from a JSP, progress read as JSON every 2 s | "Check all exams" takes minutes, the page must not wait | "The job runs in its own thread; the page asks a small JSP for the progress numbers every two seconds." |
| 12 | `assets/css/tokens.css`, `assets/fonts/` | `@font-face` with bundled variable woff2 fonts (SIL Open Font License) | The design fonts must work without internet in the lab | "The fonts are files inside the project; @font-face tells the browser where they are, so nothing is downloaded from Google." |
| 13 | `assets/css/print.css` | A print stylesheet (`media="print"`, `@page`, `print-color-adjust`) | Print the eligibility report and the profile sheet | "When the user prints, the browser uses this extra stylesheet: menus and buttons disappear and every tab is printed." |
| 14 | `assets/js/app.js` (toasts, account menu, print) | Small DOM scripts: timers to hide a toast, closing a `<details>` menu on outside click / Escape, `window.print()` | Messages after an action and the account menu | "Without JavaScript the page still works - the toast just stays and the menu closes on a second click." |

## Syllabus map — where each topic is used

Line numbers were generated from the source on 26-Oct-2026 (P9.8, refreshed after P10); they move a little when the files change.

| Topic | Where | What to say in the viva |
|---|---|---|
| Model 1 / MVC idea (view JSP + action JSP + DAO + model) | `login.jsp:3`, `login-action.jsp:29` | The view JSP shows the form, the action JSP reads the POST, calls the DAO and redirects; Java beans carry the data. |
| GET form (search / filters, bookmarkable) | `aspirant/exams.jsp:82` | Filters go in the URL, so the result page can be bookmarked; nothing is changed on the server. |
| POST form (every change) | `register.jsp:23`, `register-action.jsp:10` | Data that changes the database goes in the request body; action pages refuse other methods. |
| response.sendRedirect (Post/Redirect/Get) | `login-action.jsp:79`, `logout.jsp:30` | After a POST the browser is sent to a new GET page, so refresh never repeats the save. |
| Server-side forward | `index.jsp:7` | The server hands the request to home.jsp; the address bar does not change (unlike sendRedirect). |
| Static include directive | `aspirant/dashboard.jsp:86` | The fragment's text is copied into the page before translation (same servlet, shared variables). |
| Dynamic include + parameter | `home.jsp:76`, `WEB-INF/includes/category-grid.jsp:11` | The other JSP runs at request time and its output is inserted; jsp:param passes a value. |
| jsp:useBean / setProperty / getProperty | `aspirant/profile-step1.jsp:11`, `aspirant/profile-step1.jsp:23`, `aspirant/profile-step4.jsp:5` | A session-scoped bean keeps the wizard values; property="*" copies every matching request parameter. |
| Declaration <%! %> | `aspirant/horizon.jsp:11`, `aspirant/journal.jsp:10` | Declares methods / constants of the generated servlet class (not inside _jspService). |
| Scriptlet and expression | `aspirant/exams.jsp:175`, `aspirant/exams.jsp:182` | Scriptlet = Java statements (a loop like student-list.jsp); expression = a value printed into the page. |
| JSP life cycle (jspInit) | `WEB-INF/about.jsp:12` | A JSP becomes a servlet: jspInit once, _jspService per request, jspDestroy at shutdown. |
| Implicit object: out | `aspirant/calendar-ics.jsp:44` | The page's writer; here it writes iCalendar text instead of HTML. |
| Implicit object: request | `register-action.jsp:15` | Form parameters, headers (User-Agent), method and context path. |
| Implicit object: response | `aspirant/calendar-ics.jsp:43` | Headers, status codes, redirects and cookies. |
| Implicit object: session (HttpSession) | `aspirant/settings.jsp:62`, `logout.jsp:5` | Holds the logged-in user and flash messages; id, creation and last access time like Worksheet 2; invalidate on logout. |
| Implicit object: application (ServletContext) | `WEB-INF/jspf/header.jspf:8`, `WEB-INF/about.jsp:22` | One object for the whole web app: context-params from web.xml and an app-wide visit counter. |
| Implicit object: config (ServletConfig) | `WEB-INF/about.jsp:25` | Init-params of this JSP's own <servlet> entry in web.xml (<jsp-file> mapping). |
| Implicit object: pageContext | `home.jsp:14` | Page scope: an attribute that lives only while this page runs. |
| Implicit object: page | `WEB-INF/about.jsp:24` | 'this' of the generated servlet - its class name shows the JSP was translated into a servlet. |
| Implicit object: exception | `error.jsp:1`, `error.jsp:23` | Only in an error page; the admin sees the stack trace, students a friendly message. |
| Cookies | `aspirant/settings-action.jsp:54`, `WEB-INF/jspf/header.jspf:37` | The theme is stored in the browser for one year (setMaxAge) and read on every page. |
| web.xml | `WEB-INF/web.xml` | context-param, <servlet> with <jsp-file> + <init-param>, servlet-mapping /about, welcome-file, error-page (404, 500, Throwable), session-timeout, request encoding. |
| JDBC connection (Type 4 driver) | `util/DBConnection.java:9`, `util/DBConnection.java:10` | Load Connector/J, open a connection with URL, user and password - exactly as in Experiment 4. |
| Statement | `dao/StateDAO.java:25` | Only for fixed SQL without user input (master lists). |
| PreparedStatement (all user input) | `dao/UserDAO.java:33` | Values go through ? placeholders, so SQL injection is impossible. |
| executeUpdate() rows affected | `aspirant/education-action.jsp:27` | The returned count is shown in the flash message, like the notes print "Rows affected". |
| getGeneratedKeys() | `dao/UserDAO.java:40` | The new AUTO_INCREMENT id is read back after an INSERT. |
| CallableStatement (IN parameter, result set) | `dao/DashboardDAO.java:25` | Calls a stored procedure; the dashboard counters come from its result set. |
| CallableStatement with an OUT parameter | `dao/RuleVersionDAO.java:100` | sp_clone_rule_version returns the new draft id through an OUT parameter. |
| Statement.execute() | `dao/DbExplorerDAO.java:70` | Returns true when the statement produced a ResultSet (read with getResultSet()). |
| Scrollable ResultSet | `dao/DbExplorerDAO.java:68`, `dao/DbExplorerDAO.java:89` | first(), last(), previous(), next(), absolute(n), getRow() move freely for paging. |
| Updatable ResultSet | `dao/DbExplorerDAO.java:136`, `dao/DbExplorerDAO.java:142` | updateString + updateRow write a changed row back without an UPDATE statement. |
| ResultSetMetaData | `dao/DbExplorerDAO.java:72` | Column count, names, type names and table name of any result. |
| DatabaseMetaData | `dao/DashboardDAO.java:81` | Driver name / version and database version on the admin dashboard. |
| Transactions (commit / rollback) | `dao/RulePackDAO.java:39`, `dao/RulePackDAO.java:52` | A rule pack is written completely or not at all. |
| Batch updates | `dao/SnapshotDAO.java:127` | Many INSERTs sent together with executeBatch(). |
| Error pages | `error.jsp:10` | web.xml maps 404 / 500 / Throwable here; every page also names it with errorPage="...". |

Not used, by decision: Servlet classes, filters and listeners (CHANGE 005 - every request is a JSP, which Tomcat turns into a servlet); Hibernate (CHANGE 003); JSTL (D21 - scriptlet loops as in Experiment 4; the taglib directive is explained in theory only). ODBC is covered in theory (`docs/ODBC_DEMO.md`, Phase 11).
