# AspirantOS — VIVA GUIDE

> Started in Phase 3. The full guide (architecture walk-through, likely viva questions and answers, demo flow) is written in Phase 11. Until then this file keeps the register of everything marked `[EXTRA]` in the code.

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
