-- ============================================================
-- AspirantOS - 01_schema.sql
-- Run SECOND (after 00_create_database_and_user.sql).
-- Creates every table with primary keys, foreign keys, UNIQUE and
-- CHECK constraints and indexes. Engine InnoDB, charset utf8mb4.
-- Re-runnable: CREATE TABLE IF NOT EXISTS (existing data is kept).
-- For a completely fresh start run 99_reset_all.sql first.
-- Next file: 02_views.sql
--
-- Table groups
--   1. Users        : app_user, remember_token
--   2. Master data  : state_master, exam_category, conducting_body, app_setting
--   3. Aspirant     : aspirant_profile, education, work_experience
--   4. Exams/rules  : exam, exam_rule_version, age_rule, relaxation_rule,
--                     attempt_rule, qualification_rule, other_rule,
--                     doc_spec, exam_event
--   5. Tracking     : user_exam_tracking, attempt_log, eligibility_snapshot
--   6. Admin/audit  : exam_update_check, rule_change_log, info_report,
--                     notification, audit_log
-- ============================================================

USE aspirantos;

-- ------------------------------------------------------------
-- 1. USERS
-- ------------------------------------------------------------

-- Every login account. Only ONE account is seeded (the admin, 40_seed_admin.sql);
-- students create their own account on the Register page.
CREATE TABLE IF NOT EXISTS app_user (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(100) NOT NULL,
    email           VARCHAR(150) NOT NULL,
    phone           VARCHAR(10)  NULL,
    password_hash   VARCHAR(100) NOT NULL,          -- PBKDF2 hash (Base64), never the plain password
    password_salt   VARCHAR(50)  NOT NULL,          -- random salt (Base64)
    role            ENUM('ASPIRANT','ADMIN') NOT NULL DEFAULT 'ASPIRANT',
    status          ENUM('ACTIVE','BLOCKED') NOT NULL DEFAULT 'ACTIVE',
    last_login_at   DATETIME NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_app_user_email UNIQUE (email),
    CONSTRAINT chk_app_user_phone CHECK (phone IS NULL OR phone REGEXP '^[0-9]{10}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- "Remember me" cookie: the cookie holds a random token, only its SHA-256 is stored here.
CREATE TABLE IF NOT EXISTS remember_token (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    token_hash      CHAR(64) NOT NULL,
    expires_at      DATETIME NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_remember_token_hash UNIQUE (token_hash),
    CONSTRAINT fk_remember_token_user FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE CASCADE,
    INDEX idx_remember_token_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 2. MASTER DATA
-- ------------------------------------------------------------

-- 28 states + 8 union territories (seeded in 10_seed_master.sql).
CREATE TABLE IF NOT EXISTS state_master (
    code            VARCHAR(3)  NOT NULL PRIMARY KEY,   -- e.g. UP, MH, DL
    name            VARCHAR(60) NOT NULL,
    type            ENUM('STATE','UT') NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_state_master_name UNIQUE (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Exam groups shown as tiles (Civil Services, SSC, Banking, ...).
CREATE TABLE IF NOT EXISTS exam_category (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    code                VARCHAR(40)  NOT NULL,
    name                VARCHAR(80)  NOT NULL,
    short_description   VARCHAR(255) NULL,
    icon_svg_name       VARCHAR(40)  NULL,
    accent_color        CHAR(7)      NULL,              -- e.g. #1F7A4F
    sort_order          INT NOT NULL DEFAULT 100,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_exam_category_code UNIQUE (code),
    CONSTRAINT chk_exam_category_color CHECK (accent_color IS NULL OR accent_color REGEXP '^#[0-9A-Fa-f]{6}$'),
    INDEX idx_exam_category_sort (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Organisation that conducts an exam (UPSC, SSC, IBPS, NTA, ...).
CREATE TABLE IF NOT EXISTS conducting_body (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    short_name      VARCHAR(40)  NOT NULL,
    full_name       VARCHAR(200) NOT NULL,
    website         VARCHAR(300) NULL,
    body_type       ENUM('CENTRAL_GOVT','STATE_GOVT','PSU','AUTONOMOUS','UNIVERSITY','PRIVATE','INTERNATIONAL') NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_conducting_body_short UNIQUE (short_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Key/value settings the admin can change (simulation_date, timeouts, ...).
CREATE TABLE IF NOT EXISTS app_setting (
    setting_key     VARCHAR(60)  NOT NULL PRIMARY KEY,
    setting_value   VARCHAR(255) NOT NULL DEFAULT '',
    description     VARCHAR(255) NULL,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 3. ASPIRANT PROFILE
-- ------------------------------------------------------------

-- One row per student (1:1 with app_user). Filled by the onboarding wizard.
CREATE TABLE IF NOT EXISTS aspirant_profile (
    user_id                 INT NOT NULL PRIMARY KEY,
    dob                     DATE NULL,
    gender                  ENUM('MALE','FEMALE','TRANSGENDER') NULL,
    category                ENUM('GEN','EWS','OBC_NCL','SC','ST') NOT NULL DEFAULT 'GEN',  -- OBC creamy layer = GEN
    is_pwbd                 BOOLEAN NOT NULL DEFAULT FALSE,
    pwbd_type               ENUM('LOCOMOTOR','VISUAL','HEARING','SPEECH_LANGUAGE','INTELLECTUAL','MENTAL_ILLNESS','MULTIPLE','OTHER') NULL,
    pwbd_percent            TINYINT UNSIGNED NULL,
    is_ex_serviceman        BOOLEAN NOT NULL DEFAULT FALSE,
    esm_service_years       DECIMAL(4,1) NULL,
    esm_release_date        DATE NULL,
    domicile_state_code     VARCHAR(3) NULL,
    is_jk_domicile_1980_89  BOOLEAN NOT NULL DEFAULT FALSE,
    is_govt_employee        BOOLEAN NOT NULL DEFAULT FALSE,
    govt_service_years      DECIMAL(4,1) NULL,
    marital_status          ENUM('UNMARRIED','MARRIED','WIDOWED','DIVORCED') NULL,
    nationality             ENUM('INDIAN','NEPAL','BHUTAN','TIBETAN_REFUGEE','PIO','OTHER') NOT NULL DEFAULT 'INDIAN',
    father_name             VARCHAR(100) NULL,
    mother_name             VARCHAR(100) NULL,
    address_line            VARCHAR(255) NULL,
    city                    VARCHAR(60)  NULL,
    pincode                 CHAR(6)      NULL,
    aadhaar_last4           CHAR(4)      NULL,          -- privacy: only the last 4 digits are stored
    profile_completion_pct  TINYINT UNSIGNED NOT NULL DEFAULT 0,
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_profile_user  FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE CASCADE,
    CONSTRAINT fk_profile_state FOREIGN KEY (domicile_state_code) REFERENCES state_master(code) ON DELETE SET NULL,
    CONSTRAINT chk_profile_pwbd_pct  CHECK (pwbd_percent IS NULL OR pwbd_percent BETWEEN 0 AND 100),
    CONSTRAINT chk_profile_esm_years CHECK (esm_service_years IS NULL OR esm_service_years BETWEEN 0 AND 40),
    CONSTRAINT chk_profile_govt_years CHECK (govt_service_years IS NULL OR govt_service_years BETWEEN 0 AND 45),
    CONSTRAINT chk_profile_pincode   CHECK (pincode IS NULL OR pincode REGEXP '^[1-9][0-9]{5}$'),
    CONSTRAINT chk_profile_aadhaar4  CHECK (aadhaar_last4 IS NULL OR aadhaar_last4 REGEXP '^[0-9]{4}$'),
    CONSTRAINT chk_profile_pct       CHECK (profile_completion_pct BETWEEN 0 AND 100),
    INDEX idx_profile_category (category),
    INDEX idx_profile_state (domicile_state_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Education history: one row per level (Class 10, Class 12, UG, PG, ...).
CREATE TABLE IF NOT EXISTS education (
    id                          INT AUTO_INCREMENT PRIMARY KEY,
    user_id                     INT NOT NULL,
    level                       ENUM('CLASS_10','CLASS_12','DIPLOMA','UG','PG','PHD','PROFESSIONAL') NOT NULL,
    degree_name                 VARCHAR(60)  NULL,      -- B.Tech, B.Sc, BA, MBBS, LLB, CA, ...
    stream_or_specialisation    VARCHAR(100) NULL,
    subjects                    VARCHAR(300) NULL,      -- comma list, e.g. PHYSICS,CHEMISTRY,MATHS,ENGLISH
    board_or_university         VARCHAR(150) NULL,
    percentage                  DECIMAL(5,2) NULL,
    cgpa                        DECIMAL(4,2) NULL,
    cgpa_scale                  DECIMAL(4,2) NULL,
    passing_year                SMALLINT NULL,
    status                      ENUM('COMPLETED','APPEARING') NOT NULL DEFAULT 'COMPLETED',
    expected_completion_date    DATE NULL,
    created_at                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_education_user FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE CASCADE,
    CONSTRAINT chk_education_pct   CHECK (percentage IS NULL OR percentage BETWEEN 0 AND 100),
    CONSTRAINT chk_education_cgpa  CHECK (cgpa IS NULL OR (cgpa >= 0 AND cgpa_scale IS NOT NULL AND cgpa <= cgpa_scale)),
    CONSTRAINT chk_education_scale CHECK (cgpa_scale IS NULL OR cgpa_scale IN (4, 5, 10)),
    CONSTRAINT chk_education_year  CHECK (passing_year IS NULL OR passing_year BETWEEN 1960 AND 2100),
    INDEX idx_education_user_level (user_id, level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Jobs / practice (needed for judiciary, some teaching and law exams).
CREATE TABLE IF NOT EXISTS work_experience (
    id                          INT AUTO_INCREMENT PRIMARY KEY,
    user_id                     INT NOT NULL,
    organisation                VARCHAR(150) NOT NULL,
    designation                 VARCHAR(100) NULL,
    start_date                  DATE NOT NULL,
    end_date                    DATE NULL,              -- NULL = still working here
    is_govt                     BOOLEAN NOT NULL DEFAULT FALSE,
    is_relevant_professional    BOOLEAN NOT NULL DEFAULT FALSE,
    created_at                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_work_user FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE CASCADE,
    CONSTRAINT chk_work_dates CHECK (end_date IS NULL OR end_date >= start_date),
    INDEX idx_work_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 4. EXAMS AND VERSIONED RULES
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS exam (
    id                          INT AUTO_INCREMENT PRIMARY KEY,
    code                        VARCHAR(40)  NOT NULL,      -- natural key, e.g. UPSC_CSE
    name                        VARCHAR(200) NOT NULL,
    short_name                  VARCHAR(60)  NOT NULL,
    category_id                 INT NOT NULL,
    body_id                     INT NOT NULL,
    scope                       ENUM('NATIONAL','STATE','INTERNATIONAL') NOT NULL DEFAULT 'NATIONAL',
    state_code                  VARCHAR(3) NULL,            -- only for STATE exams
    sector                      ENUM('GOVERNMENT','PRIVATE','AUTONOMOUS') NOT NULL DEFAULT 'GOVERNMENT',
    purpose                     ENUM('RECRUITMENT','ADMISSION','CERTIFICATION','LICENSING','FELLOWSHIP','SCHOLARSHIP') NOT NULL,
    cycles_per_year             DECIMAL(3,1) NOT NULL DEFAULT 1.0,   -- 0.5 = once in two years
    typical_notification_month  TINYINT NULL,
    typical_exam_month          TINYINT NULL,
    stages_summary              VARCHAR(255) NULL,
    posts_or_courses            VARCHAR(500) NULL,
    official_url                VARCHAR(500) NULL,
    watch_url                   VARCHAR(500) NULL,          -- page watched by the update checker
    description                 TEXT NULL,
    fee_summary                 VARCHAR(500) NULL,
    attempt_counting_note       VARCHAR(500) NULL,
    data_confidence             ENUM('VERIFIED','LIKELY','NEEDS_VERIFICATION') NOT NULL DEFAULT 'NEEDS_VERIFICATION',
    last_verified_on            DATE NULL,
    source_note                 VARCHAR(500) NULL,
    is_active                   BOOLEAN NOT NULL DEFAULT TRUE,
    active_rule_version_id      INT NULL,                   -- FK added below (circular reference)
    created_at                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_exam_code UNIQUE (code),
    CONSTRAINT fk_exam_category FOREIGN KEY (category_id) REFERENCES exam_category(id),
    CONSTRAINT fk_exam_body     FOREIGN KEY (body_id) REFERENCES conducting_body(id),
    CONSTRAINT fk_exam_state    FOREIGN KEY (state_code) REFERENCES state_master(code),
    CONSTRAINT chk_exam_cycles  CHECK (cycles_per_year > 0 AND cycles_per_year <= 12),
    CONSTRAINT chk_exam_notif_month CHECK (typical_notification_month IS NULL OR typical_notification_month BETWEEN 1 AND 12),
    CONSTRAINT chk_exam_exam_month  CHECK (typical_exam_month IS NULL OR typical_exam_month BETWEEN 1 AND 12),
    CONSTRAINT chk_exam_state_scope CHECK (scope <> 'STATE' OR state_code IS NOT NULL),
    INDEX idx_exam_category (category_id),
    INDEX idx_exam_body (body_id),
    INDEX idx_exam_state (state_code),
    INDEX idx_exam_active (is_active),
    INDEX idx_exam_confidence (data_confidence),
    INDEX idx_exam_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- One version = one complete set of rules for an exam. Edits happen on a DRAFT copy;
-- publishing archives the old ACTIVE version (sp_activate_rule_version).
CREATE TABLE IF NOT EXISTS exam_rule_version (
    id                      INT AUTO_INCREMENT PRIMARY KEY,
    exam_id                 INT NOT NULL,
    version_no              INT NOT NULL,
    applies_from_cycle_year SMALLINT NULL,
    status                  ENUM('DRAFT','ACTIVE','ARCHIVED') NOT NULL DEFAULT 'DRAFT',
    change_summary          VARCHAR(500) NULL,
    source_url              VARCHAR(500) NULL,
    created_by              INT NULL,
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activated_at            DATETIME NULL,
    -- [EXTRA] generated column: holds exam_id only while ACTIVE, so the UNIQUE key below
    -- lets the database itself refuse a second ACTIVE version of the same exam.
    -- VIRTUAL (not STORED): MySQL forbids ON DELETE CASCADE on base columns of STORED generated columns.
    active_exam_id          INT GENERATED ALWAYS AS (CASE WHEN status = 'ACTIVE' THEN exam_id END) VIRTUAL,
    CONSTRAINT uq_rule_version_no UNIQUE (exam_id, version_no),
    CONSTRAINT uq_rule_version_one_active UNIQUE (active_exam_id),
    CONSTRAINT fk_rule_version_exam FOREIGN KEY (exam_id) REFERENCES exam(id) ON DELETE CASCADE,
    CONSTRAINT fk_rule_version_user FOREIGN KEY (created_by) REFERENCES app_user(id) ON DELETE SET NULL,
    CONSTRAINT chk_rule_version_no CHECK (version_no >= 1),
    INDEX idx_rule_version_status (exam_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- exam.active_rule_version_id -> exam_rule_version.id (added only if missing, so the file stays re-runnable)
SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
                  WHERE CONSTRAINT_SCHEMA = 'aspirantos' AND TABLE_NAME = 'exam'
                    AND CONSTRAINT_NAME = 'fk_exam_active_version');
SET @sql_fk = IF(@fk_exists = 0,
    'ALTER TABLE exam ADD CONSTRAINT fk_exam_active_version FOREIGN KEY (active_rule_version_id) REFERENCES exam_rule_version(id) ON DELETE SET NULL',
    'SELECT ''fk_exam_active_version already exists'' AS info');
PREPARE stmt_fk FROM @sql_fk;
EXECUTE stmt_fk;
DEALLOCATE PREPARE stmt_fk;

-- Age limits. One row per post group when an exam has post-wise limits (SSC CGL, CDS).
--   max_age_semantics NOT_ATTAINED  : "must not have attained 32" -> completed age <= 31
--   max_age_semantics NOT_MORE_THAN : "18-32 years"               -> completed age <= 32
--   cutoff_type DOB_WINDOW          : born between (cycle_year + from_offset)-from_month-from_day
--                                     and (cycle_year + to_offset)-to_month-to_day (NDA, JEE Advanced)
CREATE TABLE IF NOT EXISTS age_rule (
    id                      INT AUTO_INCREMENT PRIMARY KEY,
    rule_version_id         INT NOT NULL,
    post_or_course          VARCHAR(120) NULL,          -- NULL = applies to the whole exam
    min_age                 TINYINT UNSIGNED NULL,
    max_age                 TINYINT UNSIGNED NULL,      -- NULL = no upper age limit
    max_age_semantics       ENUM('NOT_ATTAINED','NOT_MORE_THAN') NOT NULL DEFAULT 'NOT_MORE_THAN',
    cutoff_type             ENUM('FIXED_DATE_IN_CYCLE_YEAR','FIXED_DATE_IN_PREVIOUS_YEAR','DOB_WINDOW','NONE') NOT NULL,
    cutoff_month            TINYINT NULL,
    cutoff_day              TINYINT NULL,
    dob_from_offset_years   SMALLINT NULL,              -- e.g. -25 for "born on or after 1 Oct (year-25)"
    dob_from_month          TINYINT NULL,
    dob_from_day            TINYINT NULL,
    dob_to_offset_years     SMALLINT NULL,              -- NULL = no "born on or before" limit
    dob_to_month            TINYINT NULL,
    dob_to_day              TINYINT NULL,
    notes                   VARCHAR(500) NULL,
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_age_rule_version FOREIGN KEY (rule_version_id) REFERENCES exam_rule_version(id) ON DELETE CASCADE,
    CONSTRAINT chk_age_rule_range  CHECK (max_age IS NULL OR min_age IS NULL OR max_age >= min_age),
    CONSTRAINT chk_age_rule_month  CHECK (cutoff_month IS NULL OR cutoff_month BETWEEN 1 AND 12),
    CONSTRAINT chk_age_rule_day    CHECK (cutoff_day IS NULL OR cutoff_day BETWEEN 1 AND 31),
    CONSTRAINT chk_age_rule_fixed  CHECK (cutoff_type NOT IN ('FIXED_DATE_IN_CYCLE_YEAR','FIXED_DATE_IN_PREVIOUS_YEAR')
                                          OR (cutoff_month IS NOT NULL AND cutoff_day IS NOT NULL)),
    CONSTRAINT chk_age_rule_window CHECK (cutoff_type <> 'DOB_WINDOW'
                                          OR (dob_from_offset_years IS NOT NULL AND dob_from_month IS NOT NULL AND dob_from_day IS NOT NULL)),
    INDEX idx_age_rule_version (rule_version_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Upper-age relaxations. CATEGORY rows name the category; PWBD rows may name one too
-- when the PwBD relaxation differs by category.
--   stacking ADD                         : added on top of the category relaxation
--   stacking ADD_AFTER_SERVICE_DEDUCTION : ex-servicemen - subtract military service from actual age first
--   stacking REPLACE_WITH_MAX            : use the bigger of this and the other relaxations, not the sum
CREATE TABLE IF NOT EXISTS relaxation_rule (
    id                      INT AUTO_INCREMENT PRIMARY KEY,
    rule_version_id         INT NOT NULL,
    relaxation_type         ENUM('CATEGORY','PWBD','EX_SERVICEMAN','JK_DOMICILE_1980_89','GOVT_EMPLOYEE',
                                 'WOMEN','WIDOW_DIVORCED_WOMEN','TRANSGENDER','STATE_DOMICILE') NOT NULL,
    category                ENUM('GEN','EWS','OBC_NCL','SC','ST') NULL,
    years                   TINYINT UNSIGNED NOT NULL,
    stacking                ENUM('ADD','ADD_AFTER_SERVICE_DEDUCTION','REPLACE_WITH_MAX') NOT NULL DEFAULT 'ADD',
    overall_max_age_cap     TINYINT UNSIGNED NULL,
    requires_state_domicile BOOLEAN NOT NULL DEFAULT FALSE,     -- state exams: only that state's domicile gets it
    notes                   VARCHAR(500) NULL,
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_relax_rule_version FOREIGN KEY (rule_version_id) REFERENCES exam_rule_version(id) ON DELETE CASCADE,
    CONSTRAINT chk_relax_category CHECK (relaxation_type <> 'CATEGORY' OR category IS NOT NULL),
    CONSTRAINT chk_relax_years    CHECK (years BETWEEN 0 AND 40),
    INDEX idx_relax_rule_version (rule_version_id, relaxation_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Attempt limits. The most specific row wins (category + PwBD, then category, then PwBD, then general).
CREATE TABLE IF NOT EXISTS attempt_rule (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    rule_version_id     INT NOT NULL,
    category            ENUM('GEN','EWS','OBC_NCL','SC','ST') NULL,     -- NULL = all categories
    is_pwbd             BOOLEAN NULL,                                    -- NULL = PwBD and non-PwBD
    max_attempts        TINYINT UNSIGNED NULL,                           -- NULL = unlimited (within age)
    counting_rule       ENUM('APPEARED_IN_FIRST_STAGE','APPLIED','PER_SITTING',
                             'CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM','LIFETIME_TOTAL','PER_ROLLING_12_MONTHS') NOT NULL,
    window_years        TINYINT UNSIGNED NULL,      -- JEE: 12th year + window_years - 1
    min_gap_days        SMALLINT UNSIGNED NULL,     -- GRE: 21 days between two attempts
    notes               VARCHAR(500) NULL,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_attempt_rule_version FOREIGN KEY (rule_version_id) REFERENCES exam_rule_version(id) ON DELETE CASCADE,
    CONSTRAINT chk_attempt_rule_max CHECK (max_attempts IS NULL OR max_attempts >= 1),
    INDEX idx_attempt_rule_version (rule_version_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Educational qualification. Several rows for the same post group are ALTERNATIVES
-- (meeting any one of them is enough).
CREATE TABLE IF NOT EXISTS qualification_rule (
    id                          INT AUTO_INCREMENT PRIMARY KEY,
    rule_version_id             INT NOT NULL,
    post_or_course              VARCHAR(120) NULL,
    required_level              ENUM('NONE','CLASS_10','CLASS_12','DIPLOMA','UG','PG','PHD','PROFESSIONAL') NOT NULL,
    accepted_degrees            VARCHAR(500) NOT NULL DEFAULT 'ANY',    -- comma list or ANY
    required_subjects           VARCHAR(300) NULL,                      -- comma list, case-insensitive
    min_percent_general         DECIMAL(5,2) NULL,
    min_percent_relaxed         DECIMAL(5,2) NULL,
    relaxed_for                 VARCHAR(100) NULL,                      -- e.g. SC,ST,OBC_NCL,PWBD
    final_year_allowed          BOOLEAN NOT NULL DEFAULT FALSE,
    max_years_since_passing     TINYINT UNSIGNED NULL,
    min_experience_years        DECIMAL(3,1) NULL,
    text_summary                VARCHAR(500) NULL,
    created_at                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_qual_rule_version FOREIGN KEY (rule_version_id) REFERENCES exam_rule_version(id) ON DELETE CASCADE,
    CONSTRAINT chk_qual_pct_general CHECK (min_percent_general IS NULL OR min_percent_general BETWEEN 0 AND 100),
    CONSTRAINT chk_qual_pct_relaxed CHECK (min_percent_relaxed IS NULL OR min_percent_relaxed BETWEEN 0 AND 100),
    INDEX idx_qual_rule_version (rule_version_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Gender / marital status / nationality / domicile / physical standards / other conditions.
CREATE TABLE IF NOT EXISTS other_rule (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    rule_version_id     INT NOT NULL,
    post_or_course      VARCHAR(120) NULL,
    rule_type           ENUM('GENDER','MARITAL_STATUS','NATIONALITY','DOMICILE','PHYSICAL_STANDARD','REGISTRATION','OTHER') NOT NULL,
    rule_value          VARCHAR(200) NULL,          -- e.g. UNMARRIED, MALE,FEMALE, INDIAN,NEPAL,BHUTAN
    is_blocking         BOOLEAN NOT NULL DEFAULT TRUE,  -- FALSE = information only (e.g. height)
    text_summary        VARCHAR(500) NULL,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_other_rule_version FOREIGN KEY (rule_version_id) REFERENCES exam_rule_version(id) ON DELETE CASCADE,
    INDEX idx_other_rule_version (rule_version_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Photo / signature / thumb size rules per exam (shown read-only on the exam page).
CREATE TABLE IF NOT EXISTS doc_spec (
    id                      INT AUTO_INCREMENT PRIMARY KEY,
    exam_id                 INT NOT NULL,
    doc_type                ENUM('PHOTO','SIGNATURE','LEFT_THUMB','HANDWRITTEN_DECLARATION','CATEGORY_CERT','PWBD_CERT','OTHER') NOT NULL,
    min_width_px            SMALLINT UNSIGNED NULL,
    max_width_px            SMALLINT UNSIGNED NULL,
    min_height_px           SMALLINT UNSIGNED NULL,
    max_height_px           SMALLINT UNSIGNED NULL,
    min_kb                  SMALLINT UNSIGNED NULL,
    max_kb                  SMALLINT UNSIGNED NULL,
    allowed_formats         VARCHAR(60) NULL,       -- e.g. JPG,JPEG
    background_rule         VARCHAR(60) NULL,       -- e.g. WHITE_OR_LIGHT
    requires_name_and_date  BOOLEAN NOT NULL DEFAULT FALSE,
    max_photo_age_months    TINYINT UNSIGNED NULL,
    notes                   VARCHAR(500) NULL,
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_doc_spec UNIQUE (exam_id, doc_type),
    CONSTRAINT fk_doc_spec_exam FOREIGN KEY (exam_id) REFERENCES exam(id) ON DELETE CASCADE,
    CONSTRAINT chk_doc_spec_kb    CHECK (max_kb IS NULL OR min_kb IS NULL OR max_kb >= min_kb),
    CONSTRAINT chk_doc_spec_width CHECK (max_width_px IS NULL OR min_width_px IS NULL OR max_width_px >= min_width_px),
    CONSTRAINT chk_doc_spec_height CHECK (max_height_px IS NULL OR min_height_px IS NULL OR max_height_px >= min_height_px)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Calendar of an exam cycle (notification, application window, exam stages, result).
CREATE TABLE IF NOT EXISTS exam_event (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    exam_id         INT NOT NULL,
    cycle_year      SMALLINT NOT NULL,
    event_type      ENUM('NOTIFICATION','APPLY_START','APPLY_END','ADMIT_CARD','STAGE_1','STAGE_2','STAGE_3','RESULT') NOT NULL,
    event_date      DATE NOT NULL,
    is_tentative    BOOLEAN NOT NULL DEFAULT TRUE,
    notes           VARCHAR(255) NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_exam_event UNIQUE (exam_id, cycle_year, event_type),
    CONSTRAINT fk_exam_event_exam FOREIGN KEY (exam_id) REFERENCES exam(id) ON DELETE CASCADE,
    INDEX idx_exam_event_date (event_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 5. TRACKING, ATTEMPTS AND THE ELIGIBILITY CACHE
-- ------------------------------------------------------------

-- Exams a student follows, plus attempts used before joining AspirantOS.
CREATE TABLE IF NOT EXISTS user_exam_tracking (
    id                          INT AUTO_INCREMENT PRIMARY KEY,
    user_id                     INT NOT NULL,
    exam_id                     INT NOT NULL,
    is_favourite                BOOLEAN NOT NULL DEFAULT FALSE,
    attempts_used_before_app    TINYINT UNSIGNED NOT NULL DEFAULT 0,
    target_cycle_year           SMALLINT NULL,
    personal_note               VARCHAR(500) NULL,
    created_at                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_tracking UNIQUE (user_id, exam_id),
    CONSTRAINT fk_tracking_user FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE CASCADE,
    CONSTRAINT fk_tracking_exam FOREIGN KEY (exam_id) REFERENCES exam(id) ON DELETE CASCADE,
    CONSTRAINT chk_tracking_attempts CHECK (attempts_used_before_app <= 50),
    INDEX idx_tracking_exam (exam_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Attempt journal. counts_as_attempt is decided by trigger trg_attempt_log_bi
-- from the exam's counting rule (e.g. "applied only" does not count for UPSC).
CREATE TABLE IF NOT EXISTS attempt_log (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    user_id             INT NOT NULL,
    exam_id             INT NOT NULL,
    cycle_year          SMALLINT NOT NULL,
    sitting_no          TINYINT UNSIGNED NOT NULL DEFAULT 1,
    attempt_date        DATE NULL,                  -- needed for rolling 12-month rules (GRE, GMAT)
    stage_reached       ENUM('APPLIED_ONLY','APPEARED_STAGE_1','CLEARED_STAGE_1','APPEARED_STAGE_2',
                             'CLEARED_STAGE_2','INTERVIEW','FINAL_SELECTED','ABSENT') NOT NULL,
    counts_as_attempt   BOOLEAN NOT NULL DEFAULT TRUE,
    score               DECIMAL(7,2) NULL,
    rank_obtained       INT NULL,
    remarks             VARCHAR(500) NULL,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_attempt_log UNIQUE (user_id, exam_id, cycle_year, sitting_no),
    CONSTRAINT fk_attempt_log_user FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE CASCADE,
    CONSTRAINT fk_attempt_log_exam FOREIGN KEY (exam_id) REFERENCES exam(id) ON DELETE CASCADE,
    CONSTRAINT chk_attempt_log_year CHECK (cycle_year BETWEEN 1990 AND 2100),
    CONSTRAINT chk_attempt_log_rank CHECK (rank_obtained IS NULL OR rank_obtained >= 1),
    INDEX idx_attempt_log_exam (exam_id),
    INDEX idx_attempt_log_user_exam (user_id, exam_id, counts_as_attempt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Cache of the eligibility engine's answer per (user, exam). Triggers delete stale rows
-- when the profile, education, attempts or the exam's active rules change.
CREATE TABLE IF NOT EXISTS eligibility_snapshot (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    user_id             INT NOT NULL,
    exam_id             INT NOT NULL,
    rule_version_id     INT NOT NULL,
    computed_for_date   DATE NOT NULL,
    status              ENUM('ELIGIBLE','PROVISIONAL','NOT_YET','NOT_ELIGIBLE','EXHAUSTED') NOT NULL,
    attempts_used       TINYINT UNSIGNED NULL,
    attempts_remaining  TINYINT UNSIGNED NULL,      -- NULL = unlimited
    next_cycle_year     SMALLINT NULL,
    first_eligible_year SMALLINT NULL,
    last_eligible_year  SMALLINT NULL,
    headline            VARCHAR(255) NOT NULL,
    details_text        TEXT NULL,
    computed_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_snapshot UNIQUE (user_id, exam_id),
    CONSTRAINT fk_snapshot_user    FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE CASCADE,
    CONSTRAINT fk_snapshot_exam    FOREIGN KEY (exam_id) REFERENCES exam(id) ON DELETE CASCADE,
    CONSTRAINT fk_snapshot_version FOREIGN KEY (rule_version_id) REFERENCES exam_rule_version(id) ON DELETE CASCADE,
    INDEX idx_snapshot_exam (exam_id),
    INDEX idx_snapshot_status (user_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 6. ADMIN, NOTIFICATIONS AND AUDIT
-- ------------------------------------------------------------

-- Result of every "Check for updates" click (hash of the official page + keyword snippets).
CREATE TABLE IF NOT EXISTS exam_update_check (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    exam_id             INT NOT NULL,
    checked_by          INT NULL,
    checked_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    url_checked         VARCHAR(500) NOT NULL,
    http_status         SMALLINT NULL,
    content_sha256      CHAR(64) NULL,
    changed_since_last  BOOLEAN NULL,               -- NULL = first check / could not compare
    keyword_hits        TEXT NULL,
    error_message       VARCHAR(500) NULL,
    CONSTRAINT fk_update_check_exam FOREIGN KEY (exam_id) REFERENCES exam(id) ON DELETE CASCADE,
    CONSTRAINT fk_update_check_user FOREIGN KEY (checked_by) REFERENCES app_user(id) ON DELETE SET NULL,
    INDEX idx_update_check_exam (exam_id, checked_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Who changed which rule value, when (filled by triggers and by the application).
CREATE TABLE IF NOT EXISTS rule_change_log (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    exam_id             INT NOT NULL,
    rule_version_id     INT NULL,
    table_name          VARCHAR(60) NOT NULL,
    column_name         VARCHAR(60) NULL,
    old_value           VARCHAR(500) NULL,
    new_value           VARCHAR(500) NULL,
    change_source       ENUM('ADMIN_EDIT','CSV_IMPORT','VERSION_ACTIVATED','SEED') NOT NULL,
    changed_by          INT NULL,
    changed_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_change_log_exam    FOREIGN KEY (exam_id) REFERENCES exam(id) ON DELETE CASCADE,
    CONSTRAINT fk_change_log_version FOREIGN KEY (rule_version_id) REFERENCES exam_rule_version(id) ON DELETE SET NULL,
    CONSTRAINT fk_change_log_user    FOREIGN KEY (changed_by) REFERENCES app_user(id) ON DELETE SET NULL,
    INDEX idx_change_log_exam (exam_id, changed_at),
    INDEX idx_change_log_version (rule_version_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- "Report outdated info" sent by students to the admin.
CREATE TABLE IF NOT EXISTS info_report (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    exam_id         INT NOT NULL,
    message         VARCHAR(1000) NOT NULL,
    status          ENUM('OPEN','RESOLVED','REJECTED') NOT NULL DEFAULT 'OPEN',
    admin_reply     VARCHAR(1000) NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_info_report_user FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE CASCADE,
    CONSTRAINT fk_info_report_exam FOREIGN KEY (exam_id) REFERENCES exam(id) ON DELETE CASCADE,
    INDEX idx_info_report_status (status, created_at),
    INDEX idx_info_report_exam (exam_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Bell notifications (e.g. "UPSC CSE rules were updated - your result was recalculated").
CREATE TABLE IF NOT EXISTS notification (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    title           VARCHAR(150) NOT NULL,
    message         VARCHAR(1000) NOT NULL,
    link_url        VARCHAR(300) NULL,
    is_read         BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notification_user FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE CASCADE,
    INDEX idx_notification_user (user_id, is_read, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Security / activity log (login, logout, profile saved, rules published, ...).
CREATE TABLE IF NOT EXISTS audit_log (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NULL,
    action          VARCHAR(60) NOT NULL,
    entity          VARCHAR(60) NULL,
    entity_id       VARCHAR(60) NULL,
    ip_address      VARCHAR(45) NULL,
    user_agent      VARCHAR(300) NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE SET NULL,
    INDEX idx_audit_created (created_at),
    INDEX idx_audit_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT 'Schema ready' AS status, COUNT(*) AS tables_in_aspirantos
FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'aspirantos' AND TABLE_TYPE = 'BASE TABLE';
