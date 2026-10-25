# AspirantOS — Database Design

Database `aspirantos` on MySQL 8.4 LTS, engine InnoDB, charset `utf8mb4` / collation `utf8mb4_0900_ai_ci`.
The application connects through JDBC (MySQL Connector/J, Type 4 driver) as the user `aspirant_app`.
ER diagram: [`diagrams/er-diagram.svg`](diagrams/er-diagram.svg) — 26 tables, 34 foreign keys.

## Scripts and run order

| File | What it does |
|---|---|
| `00_create_database_and_user.sql` | Creates the database and the app user `aspirant_app` / `Aspirant@123` (root only) |
| `01_schema.sql` | All 26 tables with PK, FK, UNIQUE, CHECK and indexes |
| `02_views.sql` | 6 views |
| `03_functions_procedures.sql` | 3 stored functions, 4 stored procedures |
| `04_triggers.sql` | 19 triggers + helper procedure `sp_log_rule_change` |
| `05_seed_helpers.sql` | Helper procedures used only by the seed files (`sp_seed_exam`, `sp_seed_age`, `sp_seed_relax_*`, `sp_seed_attempt`, `sp_seed_qual`, `sp_seed_other`, `sp_seed_tet`, `sp_seed_set`, `sp_seed_body`) |
| `10_seed_master.sql` | States/UTs, exam categories, conducting bodies, app settings |
| `11_…` – `24_…` | Exam catalogue: 267 exams in 25 categories, one file per exam group, each exam with an ACTIVE rule version 1 |
| `29_verified_sources.sql` | Marks the flagship exams checked against their official notice as VERIFIED (date + URL) |
| `30_seed_doc_specs.sql`, `31_seed_exam_events.sql` | Photo/signature specs, exam calendar |
| `40_seed_admin.sql` | The ONE seeded account: `admin@aspirantos.in` (no demo students) |
| `99_reset_all.sql` | Drops every AspirantOS object (fresh start) |
| `RUN_ALL.sql` | Runs everything in order with the mysql CLI (`SOURCE …`) |

All scripts are **re-runnable**: `CREATE TABLE IF NOT EXISTS`, `CREATE OR REPLACE VIEW`, `DROP … IF EXISTS` before routines/triggers, and seeds use `INSERT … ON DUPLICATE KEY UPDATE` on natural codes (exam `code`, category `code`, state `code`).
Run them as **root**: with binary logging switched on (the MySQL 8.4 default) only a SUPER user may create stored functions and triggers (decision D23). The procedures run with `SQL SECURITY DEFINER`, so the app user can still `CALL` them.

## Design principles

- **Normalised to 3NF.** Every fact is stored once: a state name only in `state_master`, a conducting body only in `conducting_body`, an exam's rules only in the rule tables. Lists that are really separate facts (education levels, attempts, rules) are rows, not columns.
- **Fixed sets are ENUMs** (category, role, status, rule types), so wrong values are refused by MySQL itself. Ranges are protected by **CHECK** constraints (percentages 0–100, months 1–12, `max_age >= min_age`, pincode and phone patterns).
- **Foreign keys with deliberate `ON DELETE`:** child data of a user or exam is `CASCADE` (deleting a student removes their profile, attempts and cache); audit-style references (`created_by`, `changed_by`, `checked_by`, `audit_log.user_id`) are `SET NULL` so the history survives; master data (category, body) is `RESTRICT` so an exam can never point to a missing category.
- **Indexes** on every foreign key and on columns used in `WHERE` / `ORDER BY` (exam name, status, confidence, dates).
- **`created_at` / `updated_at`** on every table (`updated_at … ON UPDATE CURRENT_TIMESTAMP` where rows are edited).

### Why rules are versioned
Exam rules change every year (UPSC may change an attempt limit, SSC changes the age cut-off date). The rules of an exam are therefore never edited in place. A version (`exam_rule_version`) owns all rule rows. The admin clones the ACTIVE version into a DRAFT (`sp_clone_rule_version`), edits the draft, and publishes it (`sp_activate_rule_version`). Publishing archives the old version, so the full history stays readable and every result can say which version it was computed with. A UNIQUE key on a generated column (`active_exam_id`) makes MySQL itself refuse a second ACTIVE version of the same exam.

### Why eligibility results are cached
Computing eligibility for 180+ exams needs the profile, education, attempts and all rule rows. `eligibility_snapshot` stores the last answer per (student, exam). Triggers delete the cached row whenever something it depends on changes (profile, education, work experience, attempts, tracking, or the exam's rules). The next page view recomputes only the missing rows. So the cache is always correct without recomputing everything on every click.

## Tables

### Users
- **`app_user`** — every login account (students and the admin). Email is UNIQUE. The password is stored only as a PBKDF2 hash plus a random salt, never as plain text. `role` decides between the student area and the admin area, and `status = BLOCKED` stops a login.
- **`remember_token`** — backs the "Remember me" cookie. The cookie holds a random token; only its SHA-256 hash is stored, so a stolen database does not reveal usable cookies. Rows expire after 14 days.

### Master data
- **`state_master`** — 28 states and 8 union territories, keyed by a short code (`UP`, `MH`, `DL`). Used for the student's domicile and for state-level exams.
- **`exam_category`** — the exam groups shown as tiles (Civil Services, SSC, Banking …), with a colour and sort order for the UI.
- **`conducting_body`** — the organisation behind an exam (UPSC, SSC, IBPS, NTA, …) with its website and type (central, state, PSU, autonomous, private, international).
- **`app_setting`** — key/value settings the admin can change without code. `simulation_date` is **empty by default** (the app uses the real date). When the admin sets it, the whole engine treats it as "today" and a banner shows it, so the demo output stays stable on presentation day. Other keys: `update_check_timeout_seconds`, `upcoming_cycles_to_plan`.

### Aspirant data
- **`aspirant_profile`** — one row per student (1:1 with `app_user`, sharing the same primary key). It holds everything the eligibility rules need: date of birth, gender, category, PwBD type and percentage, ex-serviceman service, domicile state, J&K 1980–89 domicile, government service, marital status and nationality. Only the last 4 digits of Aadhaar are stored, for privacy.
- **`education`** — one row per completed or ongoing level (Class 10, Class 12, diploma, UG, PG, PhD, professional) with degree, subjects, percentage or CGPA, passing year and status (`APPEARING` gives "provisional" results for final-year students).
- **`work_experience`** — jobs and legal practice, used by exams that require experience (judiciary, some teaching and PSU posts).

### Exams and versioned rules
- **`exam`** — the catalogue (267 rows): code, names, category, body, scope (national/state/international), sector, purpose, how many cycles per year, typical months, official URL, the page watched by the update checker, and an honest `data_confidence` (`VERIFIED` / `LIKELY` / `NEEDS_VERIFICATION`) with `last_verified_on`. `active_rule_version_id` points to the rules currently in force.
- **`exam_rule_version`** — one complete rule set of an exam (`DRAFT` → `ACTIVE` → `ARCHIVED`), with a change summary and source URL.
- **`age_rule`** — minimum and maximum age and how the age is counted: on a fixed cut-off date (e.g. 1 August of the exam year), or as a date-of-birth window (NDA, JEE Advanced). `max_age_semantics` separates "must not have attained 32" (`NOT_ATTAINED`, completed age ≤ 31) from "18–32 years" (`NOT_MORE_THAN`, completed age ≤ 32). Several rows with `post_or_course` model post-wise limits (SSC CGL, CDS academies).
- **`relaxation_rule`** — upper-age relaxations by category, PwBD, ex-serviceman (with service deduction), J&K domicile, government employees, women etc. `stacking` says whether relaxations add up; `requires_state_domicile` gives reservation relaxations of state exams only to that state's domicile.
- **`attempt_rule`** — maximum attempts per category / PwBD (NULL = unlimited within age) and how an attempt is counted (appeared in prelims, applied, per sitting, consecutive years, lifetime, rolling 12 months with a minimum gap).
- **`qualification_rule`** — required education level, accepted degrees, required subjects, minimum percentage (with relaxed percentage for listed categories), whether final-year students may apply, and maximum years since passing. Several rows of the same post group are alternatives.
- **`other_rule`** — gender, marital status, nationality, domicile and informational items such as physical standards (`is_blocking = FALSE`).
- **`doc_spec`** — photo / signature / thumb size rules per exam (pixels, KB, formats, background), shown read-only on the exam page.
- **`exam_event`** — the calendar of a cycle (notification, application window, admit card, stages, result), marked tentative when not yet announced.

### Tracking and cache
- **`user_exam_tracking`** — the exams a student follows, plus the attempts used before joining AspirantOS. UNIQUE (user, exam).
- **`attempt_log`** — the attempt journal (year, sitting, stage reached, score, rank). `counts_as_attempt` is set by a trigger from the exam's counting rule, so "applied only" or "absent" does not use up a UPSC attempt.
- **`eligibility_snapshot`** — the cached engine result per (student, exam): status, headline ("You have 2 UPSC attempts left, valid until 2028."), attempts used/remaining, first/last eligible year and the explanation lines, with the rule version used.

### Admin, notifications and audit
- **`exam_update_check`** — every "Check for updates" result: URL, HTTP status, SHA-256 of the page text, whether it changed since the last check, and keyword snippets.
- **`rule_change_log`** — audit trail of rule changes (table, column, old value, new value, source, who, when). Filled by triggers and by the activate procedure.
- **`info_report`** — "Report outdated info" messages from students, with status and the admin's reply.
- **`notification`** — bell notifications, e.g. "UPSC CSE rules updated — your result has been recalculated".
- **`audit_log`** — security and activity log (login, logout, profile saved, rules published) with IP and user agent.

## Views (`02_views.sql`)

| View | Purpose |
|---|---|
| `v_exam_catalog` | Exam + category + body + active version + confidence (explorer and admin lists) |
| `v_user_attempt_summary` | Attempts used per student per exam = before-app count + counted log rows |
| `v_user_dashboard` | Eligible / provisional / closing soon / not yet / not eligible / exhausted counts per student |
| `v_admin_category_stats` | Students per category, per state, PwBD vs not (admin analytics) |
| `v_rule_history` | Every rule version with author and number of logged changes |
| `v_upcoming_events` | Exam events in the next 90 days from "today" (simulation date aware) |

## Stored functions and procedures (`03_…`, `04_…`)

| Routine | Called from | Purpose |
|---|---|---|
| `fn_app_today()` | views, procedures | Simulation date if set, else `CURDATE()` |
| `fn_age_on(dob, date)` | reports | Completed years of age on a date |
| `fn_attempts_used(user, exam)` | reports | Before-app attempts + counted logged attempts |
| `sp_user_dashboard_summary(IN user)` | Dashboard (`CallableStatement`) | One row of dashboard counters |
| `sp_activate_rule_version(IN version, IN admin)` | Admin publish (`CallableStatement`) | One transaction: archive old, activate new, log, notify trackers, clear their cache |
| `sp_clone_rule_version(IN exam, IN admin, OUT new_version)` | Admin "Update rules" (`CallableStatement` + OUT parameter) | Deep copy of the active rules into a DRAFT (returns the existing draft if there is one) |
| `sp_category_report()` | Admin analytics | Rows of `v_admin_category_stats`, sorted |
| `sp_log_rule_change(...)` | rule triggers | Writes one changed column to `rule_change_log` |

## Triggers (`04_triggers.sql`)

| Trigger | When | What it does |
|---|---|---|
| `trg_attempt_log_bi`, `trg_attempt_log_bu` | BEFORE INSERT / UPDATE on `attempt_log` | Sets `counts_as_attempt` from the exam's counting rule |
| `trg_attempt_log_ai/au/ad` | AFTER changes on `attempt_log` | Clears that student's cached result for the exam |
| `trg_profile_au` | AFTER UPDATE on `aspirant_profile` | Clears all cached results of that student |
| `trg_education_ai/au/ad`, `trg_work_experience_ai/au/ad` | AFTER changes | Clears all cached results of that student |
| `trg_tracking_ai/au/ad` | AFTER changes on `user_exam_tracking` | Clears the cached result when the before-app attempt count changes |
| `trg_age_rule_au`, `trg_relaxation_rule_au`, `trg_attempt_rule_au`, `trg_qualification_rule_au` | AFTER UPDATE on rule tables | Logs every changed value (old → new) and, if the version is ACTIVE, clears that exam's cache |

The application tells the triggers who made a change by running `SET @app_user_id = ?, @rule_change_source = 'ADMIN_EDIT'` on the same JDBC connection before the `UPDATE`.

## Accounts and demo data
Exactly **one** account is seeded: `admin@aspirantos.in` / `Admin@123` (change the password after the first login). There are no demo student accounts — students register themselves. Sample profiles used to test the eligibility engine exist only inside `EngineSelfTest.java`.
