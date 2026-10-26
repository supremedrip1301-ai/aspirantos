# AspirantOS — VIVA GUIDE

How to use this guide:

1. Learn the **two-minute walk-through** first; most viva questions start from it.
2. Then read the **40 likely questions**. Each answer is short enough to say aloud, and the file names show where to point on the screen.
3. **Beyond the syllabus** lists everything that was not taught in the lab, with a one-line explanation.
4. The **syllabus map** at the end gives the file and line of every syllabus topic, so you can open the code when the examiner asks "show me".

---

## Two-minute walk-through (say this first)

1. **The problem.** Aspirants lose track of age limits and attempt limits. These differ for every exam, category and year: UPSC General gets 6 attempts up to age 32, OBC-NCL gets 9 attempts up to 35, and so on.
2. **What the app does.** The student fills one profile. AspirantOS checks 267 exams against versioned rules and says, for example, "You have 2 UPSC attempts left, valid until 2028". It also explains every check line by line.
3. **Three tiers.**
   - The browser shows HTML made by JSPs.
   - Tomcat 11 runs the JSPs, the JavaBeans, the DAOs and the eligibility engine.
   - MySQL 8.4 holds the data, together with views, stored procedures, functions and triggers.
4. **JSP Model 1.** Every feature has a *view JSP* (shows the page) and an *action JSP* (handles the form). The action JSP reads `request.getParameter`, validates, calls a DAO, puts a flash message in the session and calls `response.sendRedirect` (Post/Redirect/Get). This is the same pattern as `employee-form.jsp` in Experiment 5. There are no Servlet classes, because Tomcat turns every JSP into a servlet anyway (CHANGE 005).
5. **JDBC only.**
   - One `DBConnection` class, written exactly like Experiment 4 (`Class.forName` + `DriverManager.getConnection`), with a Type 4 driver.
   - `PreparedStatement` for every user value, and `CallableStatement` for the stored procedures.
   - One transaction for the CSV rule-pack import, and a batch for saving results.
6. **Rule versions.**
   - The admin never edits live rules. They clone the active version into a draft, edit it and see a diff.
   - On publish, the procedure `sp_activate_rule_version` archives the old version, activates the new one and notifies every student who tracks the exam.
   - The students' results are recalculated on their next visit.

---

## 40 likely viva questions

### A. Project and architecture

**1. What is AspirantOS in one sentence?**
A JSP + JDBC + MySQL web application that tells an exam aspirant, for 267 Indian exams, whether they are eligible, how many attempts they have left and until which year. Every rule is stored in versioned database tables.

**2. Why did you choose JSP only and no Servlet classes?**
- A JSP *is* a servlet: Tomcat translates `login-action.jsp` into a Java class that extends `HttpServlet` and compiles it.
- So every servlet concept is still there: request, response, session, `RequestDispatcher` (through `jsp:forward`/`jsp:include`) and the life cycle.
- We write less code, and the HTML stays readable. This was decided in CHANGE 005.

**3. What is JSP Model 1 and how do you use it?**
- In Model 1, JSP pages handle requests themselves, with JavaBeans and DAOs behind them, and there is no separate controller servlet.
- We split each feature into a view page and an action page. For example, `register.jsp` shows the form and `register-action.jsp` saves it and redirects.

**4. What happens when a student saves the profile?**
1. Steps 1–2 of the wizard fill a session-scoped JavaBean (`ProfileBean`) with `<jsp:setProperty property="*"/>`.
2. Step 4 posts to `profile-save.jsp`, which calls `ProfileDAO` (a `PreparedStatement` `INSERT ... ON DUPLICATE KEY UPDATE`).
3. A MySQL trigger (`trg_profile_au`) deletes the student's cached results.
4. The page sends a flash message ("Profile created (1 row affected).") and redirects to the dashboard.
5. The dashboard asks `EligibilityService`, which runs the engine for all exams and saves the results with one JDBC batch.

**5. Why are rules versioned instead of updated in place?**
- Exam rules change every year, and a student must be able to see what changed.
- The admin edits a DRAFT copy, sees a diff and publishes it. The old version becomes ARCHIVED.
- Results are cached per rule version, so publishing automatically makes the old results stale.
- A UNIQUE key on a generated column allows only one ACTIVE version per exam.

**6. What is the "simulation date"?**
- It is an app setting (`app_setting.simulation_date`). When it is set, the engine uses it as "today".
- On demo day the admin sets 15-Jan-2027, so the results are always the same sentence ("2 attempts left, valid until 2028").
- A yellow banner on every page shows that it is on. The MySQL function `fn_app_today()` reads the same setting.

### B. JSP

**7. Explain the JSP life cycle.**
1. Translation: JSP to a `.java` servlet.
2. Compilation to a `.class` file.
3. Loading and instantiation.
4. `jspInit()` once.
5. `_jspService()` for every request.
6. `jspDestroy()` when the app stops.

`WEB-INF/about.jsp` overrides `jspInit()` in a declaration to read its init parameters once.

**8. Which directives do you use?**
- `page`: `import`, `contentType`, `pageEncoding`, `errorPage`, and `isErrorPage` in `error.jsp`.
- `include`: `<%@ include file="/WEB-INF/jspf/header.jspf" %>` on every page.
- `taglib`: not used, because there is no JSTL (D21). We can explain it in theory: it declares a tag library with a prefix and a URI.

**9. What is the difference between the include directive and `<jsp:include>`?**
- The directive copies the file's text into the page **before translation**, so it becomes one servlet and variables are shared (`header.jspf` defines `ctx`, which the page uses).
- `<jsp:include>` runs the other page **at request time** and inserts its output. `home.jsp` includes `WEB-INF/includes/category-grid.jsp` and passes `<jsp:param>`.

**10. What is the difference between `<jsp:forward>` and `response.sendRedirect()`?**
- **Forward** happens on the server. It is the same request, the URL does not change, and request attributes survive. `index.jsp` forwards to `home.jsp`.
- **Redirect** sends status 302 to the browser, which makes a new GET request, so the URL changes and request attributes are lost. Every action JSP redirects after a POST, so refresh never repeats the save.

**11. What are the three scripting elements?**
- **Declaration** `<%! %>`: fields and methods of the generated class. Examples: `sideLink()` in `header.jspf`, the helper methods in `horizon.jsp`.
- **Scriptlet** `<% %>`: statements inside `_jspService`, such as the `for` loop over exams in `exams.jsp`.
- **Expression** `<%= %>`: a value printed into the page.

**12. Name the nine implicit objects and where you use them.**

| Object | Where |
|---|---|
| `request` | Parameters, everywhere |
| `response` | Redirects, headers (`.ics` download) |
| `session` | The logged-in user, flash messages |
| `application` | Context params, the visit counter, blocked user ids |
| `out` | The `.ics` text |
| `config` | about.jsp init params |
| `pageContext` | Page-scope attribute on home.jsp |
| `page` | Class name shown on About |
| `exception` | error.jsp |

**13. How does `<jsp:useBean>` work in the wizard?**
`<jsp:useBean id="profile" class="com.aspirantos.model.ProfileBean" scope="session"/>` finds the bean in the session, or creates it. `<jsp:setProperty name="profile" property="*"/>` calls every setter whose name matches a request parameter. Step 4 prints values with `<jsp:getProperty>`.

**14. Why is about.jsp inside WEB-INF and mapped in web.xml?**
- Files inside WEB-INF cannot be opened directly, so the page is reachable only through `/about`.
- The `<servlet>` entry uses `<jsp-file>` and has `<init-param>`s, which the page reads with `config.getInitParameter()`.
- `config` belongs to one page, while `application.getInitParameter()` reads the `<context-param>`s shared by the whole app.

**15. How are errors handled?**
- `web.xml` maps 404, 500 and `java.lang.Throwable` to `error.jsp`, which has `isErrorPage="true"` and therefore the `exception` object.
- Students see a friendly message. The admin also sees the stack trace. The error is written to the server log with `application.log()`.

**16. Why no JSTL / EL loops?**
The lab (Experiment 4, `student-list.jsp`) used scriptlet loops, so we kept the same style (D21). JSTL would need extra jars, and the examiner can map every line of a scriptlet to Java they already know.

### C. Servlet concepts used through JSP

**17. Where do you use GET and where POST?**
- **GET** only reads: the Explorer filters are in the URL, so a search can be bookmarked or shared.
- **POST** for every change (register, login, save, delete). The data is in the body, not in the URL or the history.
- Action pages refuse other methods.

**18. What is Post/Redirect/Get and the flash message?**
1. After a POST, the action page stores a message in the session (`session.setAttribute("success", ...)`) and redirects.
2. The next page shows it through `flash.jspf` and removes it at once.
3. So it appears only once, and pressing refresh does not submit the form again.

**19. How does login work?**
1. `login-action.jsp` reads the user with `UserDAO.getUserByEmail` and checks the password hash.
2. It calls `request.changeSessionId()` (protection against session fixation) and stores the `User` bean in the session.
3. Sessions expire after 30 minutes (`session-timeout` in web.xml). `logout.jsp` calls `session.invalidate()`.

**20. How do you protect pages without a Filter?**
- Every protected page starts with `<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>`: if there is no user in the session, it redirects to the login page and stops the page with `return`.
- Admin pages include `admin-check.jspf`, which also checks the role.
- A user blocked by the admin is logged out on their next click, through a set of ids in `application` scope.

**21. Which cookies do you use?**
- `theme` (light/dark, one year, `setMaxAge`), read by `header.jspf` on every page.
- The "remember me" cookie (14 days, `HttpOnly`). It holds a random token whose SHA-256 is stored in the `remember_token` table.

The session itself uses Tomcat's `JSESSIONID` cookie.

### D. JDBC and the database

**22. Which JDBC driver do you use, and why not ODBC or Hibernate?**
- **The four driver types:**
  - Type 1: JDBC-ODBC bridge.
  - Type 2: native API.
  - Type 3: network protocol.
  - Type 4: pure Java "thin" driver.
- We use **MySQL Connector/J, a Type 4 driver.** It needs no native code and no ODBC setup.
- **Why not ODBC?** The JDBC-ODBC bridge was removed in Java 8, so it cannot run on JDK 21.
- **Why not Hibernate?** It adds many jars and hides the SQL. Our project is database-heavy (views, procedures, triggers), so direct SQL with JDBC fits better and gives full control (CHANGE 003).

**23. What are the steps of a JDBC program?**
1. Load the driver: `Class.forName("com.mysql.cj.jdbc.Driver")`.
2. Get a connection: `DriverManager.getConnection(url, user, password)`.
3. Create a statement: `PreparedStatement ps = con.prepareStatement(sql)`.
4. Set the parameters and execute.
5. Read the `ResultSet` with `while (rs.next())`.
6. Close everything.

We close with try-with-resources in every DAO, so nothing leaks even on an exception.

**24. When do you use Statement, PreparedStatement and CallableStatement?**
- `Statement`: fixed SQL with no user input, such as `StateDAO` reading the list of states.
- `PreparedStatement`: every query with user values, using `?` placeholders.
- `CallableStatement`: stored procedures, for example `{call sp_user_dashboard_summary(?)}` and `{call sp_clone_rule_version(?, ?, ?)}`.

**25. What is the difference between executeQuery, executeUpdate and execute?**
- `executeQuery`: for SELECT; returns a `ResultSet`.
- `executeUpdate`: for INSERT/UPDATE/DELETE; returns the number of rows affected, which we show in the flash message.
- `execute`: for any SQL; returns `true` if the result is a `ResultSet`, read with `getResultSet()`. DB Explorer uses it.

**26. How do you prevent SQL injection?**
- Every user value goes through `PreparedStatement` placeholders, so it is sent as data and never becomes part of the SQL text.
- DB Explorer lets the admin choose a table, but only from a fixed whitelist in `DbExplorerDAO`.

**27. Show a scrollable and an updatable ResultSet.**
In `DbExplorerDAO`:
- **Scrollable:** `createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY)` for paging with `first()`, `last()`, `previous()`, `absolute(n)` and `getRow()`.
- **Updatable:** `CONCUR_UPDATABLE` to change an app setting with `updateString()` + `updateRow()`, without writing an UPDATE statement.

**28. What is the difference between ResultSetMetaData and DatabaseMetaData?**
- `ResultSetMetaData` describes one result: column count, names and types. DB Explorer uses it to draw any table.
- `DatabaseMetaData` describes the database and the driver: product version, driver name and driver version. They are shown on the admin dashboard.

**29. Where do you use a transaction?**
- In `RulePackDAO.applyPack`: `con.setAutoCommit(false)`, then many inserts and updates, then `con.commit()`. Any exception calls `con.rollback()`.
- So a CSV rule pack is applied completely or not at all.
- The stored procedure `sp_activate_rule_version` also runs inside START TRANSACTION / COMMIT.

**30. What is a batch update and where is it used?**
`SnapshotDAO.saveSnapshots` adds one `INSERT` per exam with `ps.addBatch()` and sends them all with `executeBatch()`. That is 267 rows in one round trip instead of 267.

**31. How do you read an OUT parameter?**
`sp_clone_rule_version(IN exam, IN admin, OUT newVersionId)`:
1. Call `cs.registerOutParameter(3, Types.INTEGER)`.
2. Execute.
3. Read `cs.getInt(3)`, the id of the new draft.

**32. Which triggers do you have and why?**
There are 19 triggers:
- `attempt_log` BEFORE INSERT/UPDATE decides whether an entry *counts as an attempt* (only applying or being absent does not count, unless the exam's rule says so).
- Triggers on profile, education, work experience, tracking and attempts delete the cached results of that student.
- Triggers on the rule tables write every edit into `rule_change_log`.

**33. Which views do you use?**
- `v_exam_catalog`: exam + category + body + active version, for the Explorer.
- `v_user_attempt_summary`.
- `v_user_dashboard`.
- `v_admin_category_stats`.
- `v_rule_history`.
- `v_upcoming_events`.

A view keeps a long join in one place, so the DAO only needs a simple SELECT.

**34. How is the database normalised?**
- Exams, rule versions and each kind of rule (age, relaxation, attempt, qualification, other) are separate tables, linked by foreign keys with `ON DELETE CASCADE`.
- Master data (states, categories, bodies) has its own tables.
- The student's education and work experience are child tables of the user (one-to-many).
- Repeating groups such as a list of attempts are rows, not columns.
- The one deliberate copy is `eligibility_snapshot`, a cache that triggers keep correct.

### E. Engine and features

**35. How is age calculated? Explain "valid until 2028".**
- `AgeCalculator` uses `java.time.Period.between(dob, cutoff)`.
- UPSC counts age on 1 August of the exam year, and the rule is "must **not have attained** 32" (General).
- For DOB 15-09-1996:
  - 1-Aug-2027 gives 30 years, so eligible;
  - 1-Aug-2028 gives 31, so eligible;
  - 1-Aug-2029 gives 32, which is attained, so not eligible.
- So the last year is 2028.
- Relaxations are added to the upper limit: OBC-NCL +3, SC/ST +5, PwBD +10 and so on (`RelaxationResolver`).

**36. How are attempts counted?**
- **Attempts used** = attempts entered at sign-up for the time before the app + journal entries that count (the trigger sets `counts_as_attempt`).
- The **limit** comes from the attempt rule that matches the student's category and PwBD status (UPSC General 6, OBC-NCL 9, SC/ST unlimited).
- `AttemptCounter` returns the attempts left. The final result is the earlier of "attempts run out" and "age runs out".

**37. How does the update checker work?**
- `UpdateChecker` (`java.net.http.HttpClient`) downloads the exam's official page, keeps only the text and computes its SHA-256.
- It compares the fingerprint with the last check and lists the lines that contain keywords such as "age limit" or "attempts".
- It never changes rules by itself: the admin reads the highlights and, if needed, publishes a new rule version.
- "Check all" runs in a background thread, and the page asks a JSON JSP for the progress every 2 seconds.

### F. Security and limitations

**38. How are passwords stored?**
- They are never stored as plain text. `PasswordUtil` uses PBKDF2WithHmacSHA256 with 120 000 iterations and a random 16-byte salt per user.
- Login recomputes the hash with the stored salt and compares the two.
- Changing the password deletes the remember-me tokens.

**39. How do you stop a user from injecting HTML or JavaScript (XSS)?**
- Every value that came from a user is printed through `HtmlUtil.escape()`, which turns `<`, `>`, `&` and quotes into entities, so `<script>` is shown as text.
- The remember-me cookie is `HttpOnly`, so JavaScript cannot read it.

**40. What are the limitations, and what would you add next?**
- **Data:** 28 flagship exams are verified against official notices; the others are marked "Likely" or "Needs verification", and a rule can still be wrong.
- **Connections:** each DAO call opens its own connection through `DriverManager`, as in the lab. In production we would use a connection pool (a Tomcat JNDI `DataSource`).
- **Next features:** CSRF tokens on forms, e-mail alerts, and a weekly automatic update check (a listener would be needed, which CHANGE 005 dropped).

---

## Beyond the syllabus — what it is and why we needed it

Every item below is marked `[EXTRA] <reason>` in a comment where it is used. Things that were planned but removed (photo upload, image processing, ZIP download, Hibernate, ODBC) are not part of the project any more (CHANGE 002, CHANGE 003).

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
| 15 | `assets/js/instant-check.js`, `instant-check.jsp` | `fetch()` + a JSP that answers JSON | The landing page answers "how many UPSC attempts do I have?" without an account and without reloading the page | "The form is sent in the background; the JSP runs the real engine and prints JSON instead of HTML; JavaScript shows the answer." |


## Syllabus map — where each topic is used

Line numbers were generated from the source on 26-Oct-2026 (P11.2); they move a little when the files change.

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

Not used, by decision: Servlet classes, filters and listeners (CHANGE 005 - every request is a JSP, which Tomcat turns into a servlet); Hibernate (CHANGE 003); JSTL (D21 - scriptlet loops as in Experiment 4; the taglib directive is explained in theory only). ODBC is covered in theory only (question 22).
