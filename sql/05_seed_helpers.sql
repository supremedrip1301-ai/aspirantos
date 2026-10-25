-- ============================================================
-- AspirantOS - 05_seed_helpers.sql
-- Run after 04_triggers.sql (as root, like 03/04). Small stored procedures
-- that make the exam seed files (11-24) short and readable:
--
--   CALL sp_seed_body('UPSC', 'Union Public Service Commission', 'https://upsc.gov.in', 'CENTRAL_GOVT');
--   CALL sp_seed_exam('UPSC_CSE', 'Civil Services Examination', 'UPSC CSE', 'CIVIL_SERVICES', 'UPSC',
--                     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 1, 5, ...);
--   CALL sp_seed_age(NULL, 21, 32, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, '...');
--   CALL sp_seed_relax_central(5, 'ADD', TRUE);
--   CALL sp_seed_attempt('GEN', FALSE, 6, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, '...');
--   CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, '...');
--
-- sp_seed_exam remembers the exam and its version 1 in the session variables
-- @seed_exam and @seed_version; the other helpers add rule rows to @seed_version.
--
-- Re-run behaviour (keeps the seeds re-runnable without duplicates):
--   * the exam row is upserted by its code;
--   * the seed always (re)writes VERSION 1 only: its old rule rows are deleted and
--     inserted again, so editing a seed file and running it again just works;
--   * version 1 is made ACTIVE only when the exam has no active version yet, so a
--     newer version published by the admin is never replaced by a re-run.
-- ============================================================

USE aspirantos;

DROP PROCEDURE IF EXISTS sp_seed_body;
DROP PROCEDURE IF EXISTS sp_seed_exam;
DROP PROCEDURE IF EXISTS sp_seed_exam_info;
DROP PROCEDURE IF EXISTS sp_seed_age;
DROP PROCEDURE IF EXISTS sp_seed_age_window;
DROP PROCEDURE IF EXISTS sp_seed_relax;
DROP PROCEDURE IF EXISTS sp_seed_relax_central;
DROP PROCEDURE IF EXISTS sp_seed_relax_ssc;
DROP PROCEDURE IF EXISTS sp_seed_attempt;
DROP PROCEDURE IF EXISTS sp_seed_qual;
DROP PROCEDURE IF EXISTS sp_seed_other;

DELIMITER $$

-- Insert or update a conducting body (natural key: short_name).
CREATE PROCEDURE sp_seed_body(IN p_short VARCHAR(40), IN p_full VARCHAR(200),
                              IN p_website VARCHAR(300), IN p_type VARCHAR(20))
MODIFIES SQL DATA
BEGIN
    INSERT INTO conducting_body (short_name, full_name, website, body_type)
    VALUES (p_short, p_full, p_website, p_type)
    AS new ON DUPLICATE KEY UPDATE full_name = new.full_name, website = new.website, body_type = new.body_type;
END$$

-- Insert or update an exam and prepare its rule version 1 (see the header).
CREATE PROCEDURE sp_seed_exam(
    IN p_code VARCHAR(40), IN p_name VARCHAR(200), IN p_short VARCHAR(60),
    IN p_category VARCHAR(40), IN p_body VARCHAR(40),
    IN p_scope VARCHAR(15), IN p_state VARCHAR(3), IN p_sector VARCHAR(15), IN p_purpose VARCHAR(15),
    IN p_cycles DECIMAL(3,1), IN p_notif_month TINYINT, IN p_exam_month TINYINT,
    IN p_stages VARCHAR(255), IN p_posts VARCHAR(500), IN p_url VARCHAR(500),
    IN p_description TEXT, IN p_confidence VARCHAR(20), IN p_source_note VARCHAR(500))
MODIFIES SQL DATA
BEGIN
    DECLARE v_cat INT;
    DECLARE v_body INT;
    DECLARE v_ver INT;
    DECLARE v_msg VARCHAR(200);

    SET v_cat  = (SELECT id FROM exam_category WHERE code = p_category);
    SET v_body = (SELECT id FROM conducting_body WHERE short_name = p_body);
    IF v_cat IS NULL THEN
        SET v_msg = CONCAT('Unknown exam category: ', p_category);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;
    IF v_body IS NULL THEN
        SET v_msg = CONCAT('Unknown conducting body: ', p_body);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;

    INSERT INTO exam (code, name, short_name, category_id, body_id, scope, state_code, sector, purpose,
                      cycles_per_year, typical_notification_month, typical_exam_month, stages_summary,
                      posts_or_courses, official_url, watch_url, description, data_confidence, source_note)
    VALUES (p_code, p_name, p_short, v_cat, v_body, p_scope, p_state, p_sector, p_purpose,
            p_cycles, p_notif_month, p_exam_month, p_stages,
            p_posts, p_url, p_url, p_description, p_confidence, p_source_note)
    AS new ON DUPLICATE KEY UPDATE
        name = new.name, short_name = new.short_name, category_id = new.category_id, body_id = new.body_id,
        scope = new.scope, state_code = new.state_code, sector = new.sector, purpose = new.purpose,
        cycles_per_year = new.cycles_per_year, typical_notification_month = new.typical_notification_month,
        typical_exam_month = new.typical_exam_month, stages_summary = new.stages_summary,
        posts_or_courses = new.posts_or_courses, official_url = new.official_url,
        description = new.description, data_confidence = new.data_confidence, source_note = new.source_note;
    -- watch_url and last_verified_on are not overwritten on re-run (the admin may have changed them)

    SET @seed_exam = (SELECT id FROM exam WHERE code = p_code);
    SET v_ver = (SELECT id FROM exam_rule_version WHERE exam_id = @seed_exam AND version_no = 1);

    IF v_ver IS NULL THEN
        INSERT INTO exam_rule_version (exam_id, version_no, status, change_summary, source_url)
        VALUES (@seed_exam, 1, 'DRAFT', 'Initial rules loaded from the seed file', p_url);
        SET v_ver = LAST_INSERT_ID();
        INSERT INTO rule_change_log (exam_id, rule_version_id, table_name, column_name, old_value, new_value, change_source)
        VALUES (@seed_exam, v_ver, 'exam_rule_version', 'version_no', NULL, 'v1 seeded', 'SEED');
    END IF;

    DELETE FROM age_rule           WHERE rule_version_id = v_ver;
    DELETE FROM relaxation_rule    WHERE rule_version_id = v_ver;
    DELETE FROM attempt_rule       WHERE rule_version_id = v_ver;
    DELETE FROM qualification_rule WHERE rule_version_id = v_ver;
    DELETE FROM other_rule         WHERE rule_version_id = v_ver;

    IF (SELECT active_rule_version_id FROM exam WHERE id = @seed_exam) IS NULL THEN
        UPDATE exam_rule_version SET status = 'ACTIVE', activated_at = NOW() WHERE id = v_ver;
        UPDATE exam SET active_rule_version_id = v_ver WHERE id = @seed_exam;
    END IF;

    -- cached results computed with version 1 are out of date now
    DELETE FROM eligibility_snapshot WHERE exam_id = @seed_exam AND rule_version_id = v_ver;

    SET @seed_version = v_ver;
END$$

-- Optional extra information for the exam just seeded.
CREATE PROCEDURE sp_seed_exam_info(IN p_fee VARCHAR(500), IN p_attempt_note VARCHAR(500))
MODIFIES SQL DATA
BEGIN
    UPDATE exam SET fee_summary = p_fee, attempt_counting_note = p_attempt_note WHERE id = @seed_exam;
END$$

-- Age rule on a fixed cut-off date, or cutoff 'NONE' for "no age limit".
CREATE PROCEDURE sp_seed_age(IN p_post VARCHAR(120), IN p_min TINYINT, IN p_max TINYINT,
                             IN p_semantics VARCHAR(15), IN p_cutoff VARCHAR(30),
                             IN p_month TINYINT, IN p_day TINYINT, IN p_notes VARCHAR(500))
MODIFIES SQL DATA
BEGIN
    INSERT INTO age_rule (rule_version_id, post_or_course, min_age, max_age, max_age_semantics,
                          cutoff_type, cutoff_month, cutoff_day, notes)
    VALUES (@seed_version, p_post, p_min, p_max, p_semantics, p_cutoff, p_month, p_day, p_notes);
END$$

-- Age rule as a date-of-birth window relative to the cycle year:
-- born on/after (Y + from_offset)-from_month-from_day and on/before (Y + to_offset)-to_month-to_day.
-- p_min / p_max are only the nominal ages shown to the student (e.g. 16 and 19 for NDA).
CREATE PROCEDURE sp_seed_age_window(IN p_post VARCHAR(120), IN p_min TINYINT, IN p_max TINYINT,
                                    IN p_from_off SMALLINT, IN p_from_m TINYINT, IN p_from_d TINYINT,
                                    IN p_to_off SMALLINT, IN p_to_m TINYINT, IN p_to_d TINYINT,
                                    IN p_notes VARCHAR(500))
MODIFIES SQL DATA
BEGIN
    INSERT INTO age_rule (rule_version_id, post_or_course, min_age, max_age, max_age_semantics, cutoff_type,
                          dob_from_offset_years, dob_from_month, dob_from_day,
                          dob_to_offset_years, dob_to_month, dob_to_day, notes)
    VALUES (@seed_version, p_post, p_min, p_max, 'NOT_MORE_THAN', 'DOB_WINDOW',
            p_from_off, p_from_m, p_from_d, p_to_off, p_to_m, p_to_d, p_notes);
END$$

CREATE PROCEDURE sp_seed_relax(IN p_type VARCHAR(30), IN p_category VARCHAR(10), IN p_years TINYINT,
                               IN p_stacking VARCHAR(30), IN p_cap TINYINT, IN p_domicile BOOLEAN,
                               IN p_notes VARCHAR(500))
MODIFIES SQL DATA
BEGIN
    INSERT INTO relaxation_rule (rule_version_id, relaxation_type, category, years, stacking,
                                 overall_max_age_cap, requires_state_domicile, notes)
    VALUES (@seed_version, p_type, p_category, p_years, p_stacking, p_cap, p_domicile, p_notes);
END$$

-- The usual Government of India relaxations: OBC-NCL +3, SC/ST +5, PwBD +10 (on top of the
-- category relaxation, so OBC PwBD +13 and SC/ST PwBD +15); EWS gets none.
-- p_esm_years > 0 adds an ex-serviceman row with the given stacking; p_with_jk adds J&K 1980-89 +5.
CREATE PROCEDURE sp_seed_relax_central(IN p_esm_years TINYINT, IN p_esm_stacking VARCHAR(30), IN p_with_jk BOOLEAN)
MODIFIES SQL DATA
BEGIN
    CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 3, 'ADD', NULL, FALSE, 'OBC non-creamy layer');
    CALL sp_seed_relax('CATEGORY', 'SC', 5, 'ADD', NULL, FALSE, NULL);
    CALL sp_seed_relax('CATEGORY', 'ST', 5, 'ADD', NULL, FALSE, NULL);
    CALL sp_seed_relax('PWBD', NULL, 10, 'ADD', NULL, FALSE, 'Benchmark disability (40% or more); added to the category relaxation');
    IF p_esm_years > 0 THEN
        CALL sp_seed_relax('EX_SERVICEMAN', NULL, p_esm_years, p_esm_stacking, NULL, FALSE,
             IF(p_esm_stacking = 'ADD_AFTER_SERVICE_DEDUCTION',
                'Age minus military service must not exceed the limit by more than these years',
                'Subject to the service conditions in the notification'));
    END IF;
    IF p_with_jk THEN
        CALL sp_seed_relax('JK_DOMICILE_1980_89', NULL, 5, 'ADD', NULL, FALSE,
             'Domiciled in Jammu & Kashmir between 1 Jan 1980 and 31 Dec 1989');
    END IF;
END$$

-- SSC-style relaxations: OBC-NCL +3, SC/ST +5, PwBD +10 (stacked), ex-servicemen +3 after
-- deducting military service. Optional raised limits (REPLACE_WITH_MAX = the limit becomes the cap):
--   p_govt  : central government civilian employees (3 years service) up to 40 / 43 / 45
--   p_widow : widows / divorced women (not remarried) up to 35 / 38 / 40
CREATE PROCEDURE sp_seed_relax_ssc(IN p_govt BOOLEAN, IN p_widow BOOLEAN)
MODIFIES SQL DATA
BEGIN
    CALL sp_seed_relax_central(3, 'ADD_AFTER_SERVICE_DEDUCTION', FALSE);
    IF p_govt THEN
        CALL sp_seed_relax('GOVT_EMPLOYEE', 'GEN',     0, 'REPLACE_WITH_MAX', 40, FALSE, 'Central govt civilian employees with 3 years continuous service: up to 40');
        CALL sp_seed_relax('GOVT_EMPLOYEE', 'EWS',     0, 'REPLACE_WITH_MAX', 40, FALSE, 'Central govt civilian employees with 3 years continuous service: up to 40');
        CALL sp_seed_relax('GOVT_EMPLOYEE', 'OBC_NCL', 0, 'REPLACE_WITH_MAX', 43, FALSE, 'Central govt civilian employees (OBC): up to 43');
        CALL sp_seed_relax('GOVT_EMPLOYEE', 'SC',      0, 'REPLACE_WITH_MAX', 45, FALSE, 'Central govt civilian employees (SC): up to 45');
        CALL sp_seed_relax('GOVT_EMPLOYEE', 'ST',      0, 'REPLACE_WITH_MAX', 45, FALSE, 'Central govt civilian employees (ST): up to 45');
    END IF;
    IF p_widow THEN
        CALL sp_seed_relax('WIDOW_DIVORCED_WOMEN', 'GEN',     0, 'REPLACE_WITH_MAX', 35, FALSE, 'Widows / divorced women not remarried: up to 35');
        CALL sp_seed_relax('WIDOW_DIVORCED_WOMEN', 'EWS',     0, 'REPLACE_WITH_MAX', 35, FALSE, 'Widows / divorced women not remarried: up to 35');
        CALL sp_seed_relax('WIDOW_DIVORCED_WOMEN', 'OBC_NCL', 0, 'REPLACE_WITH_MAX', 38, FALSE, 'Widows / divorced women not remarried (OBC): up to 38');
        CALL sp_seed_relax('WIDOW_DIVORCED_WOMEN', 'SC',      0, 'REPLACE_WITH_MAX', 40, FALSE, 'Widows / divorced women not remarried (SC): up to 40');
        CALL sp_seed_relax('WIDOW_DIVORCED_WOMEN', 'ST',      0, 'REPLACE_WITH_MAX', 40, FALSE, 'Widows / divorced women not remarried (ST): up to 40');
    END IF;
END$$

CREATE PROCEDURE sp_seed_attempt(IN p_category VARCHAR(10), IN p_is_pwbd BOOLEAN, IN p_max TINYINT,
                                 IN p_counting VARCHAR(45), IN p_window TINYINT, IN p_gap SMALLINT,
                                 IN p_notes VARCHAR(500))
MODIFIES SQL DATA
BEGIN
    INSERT INTO attempt_rule (rule_version_id, category, is_pwbd, max_attempts, counting_rule,
                              window_years, min_gap_days, notes)
    VALUES (@seed_version, p_category, p_is_pwbd, p_max, p_counting, p_window, p_gap, p_notes);
END$$

-- required_subjects: comma = all needed, '|' = any one of them (e.g. 'PHYSICS,CHEMISTRY,BIOLOGY|BIOTECHNOLOGY')
CREATE PROCEDURE sp_seed_qual(IN p_post VARCHAR(120), IN p_level VARCHAR(15), IN p_degrees VARCHAR(500),
                              IN p_subjects VARCHAR(300), IN p_pct_general DECIMAL(5,2),
                              IN p_pct_relaxed DECIMAL(5,2), IN p_relaxed_for VARCHAR(100),
                              IN p_final_year BOOLEAN, IN p_max_years TINYINT, IN p_experience DECIMAL(3,1),
                              IN p_summary VARCHAR(500))
MODIFIES SQL DATA
BEGIN
    INSERT INTO qualification_rule (rule_version_id, post_or_course, required_level, accepted_degrees,
                                    required_subjects, min_percent_general, min_percent_relaxed, relaxed_for,
                                    final_year_allowed, max_years_since_passing, min_experience_years, text_summary)
    VALUES (@seed_version, p_post, p_level, COALESCE(p_degrees, 'ANY'), p_subjects, p_pct_general,
            p_pct_relaxed, p_relaxed_for, p_final_year, p_max_years, p_experience, p_summary);
END$$

CREATE PROCEDURE sp_seed_other(IN p_post VARCHAR(120), IN p_type VARCHAR(20), IN p_value VARCHAR(200),
                               IN p_blocking BOOLEAN, IN p_summary VARCHAR(500))
MODIFIES SQL DATA
BEGIN
    INSERT INTO other_rule (rule_version_id, post_or_course, rule_type, rule_value, is_blocking, text_summary)
    VALUES (@seed_version, p_post, p_type, p_value, p_blocking, p_summary);
END$$

DELIMITER ;

SELECT 'Seed helpers ready' AS status;
