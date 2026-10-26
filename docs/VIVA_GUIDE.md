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
