-- ============================================================
-- AspirantOS - 03_functions_procedures.sql
-- Run FOURTH (after 02_views.sql). Run it in MySQL Workbench or the
-- mysql CLI (DELIMITER is a client command, it is not sent to the server).
-- Stored functions : fn_app_today, fn_age_on, fn_attempts_used
-- Stored procedures: sp_user_dashboard_summary  (CallableStatement, result set)
--                    sp_activate_rule_version   (CallableStatement, transaction)
--                    sp_clone_rule_version      (CallableStatement with an OUT parameter)
--                    sp_category_report         (admin analytics)
-- Re-runnable: DROP ... IF EXISTS before every CREATE.
-- Next file: 04_triggers.sql
-- ============================================================

USE aspirantos;

DROP FUNCTION IF EXISTS fn_app_today;
DROP FUNCTION IF EXISTS fn_age_on;
DROP FUNCTION IF EXISTS fn_attempts_used;
DROP PROCEDURE IF EXISTS sp_user_dashboard_summary;
DROP PROCEDURE IF EXISTS sp_activate_rule_version;
DROP PROCEDURE IF EXISTS sp_clone_rule_version;
DROP PROCEDURE IF EXISTS sp_category_report;

DELIMITER $$

-- "Today" for the whole app: the admin's simulation date if set, else the real date.
CREATE FUNCTION fn_app_today()
RETURNS DATE
READS SQL DATA
BEGIN
    DECLARE v_value VARCHAR(255);
    SET v_value = (SELECT setting_value FROM app_setting WHERE setting_key = 'simulation_date');
    IF v_value IS NULL OR v_value = '' THEN
        RETURN CURDATE();
    END IF;
    RETURN STR_TO_DATE(v_value, '%Y-%m-%d');
END$$

-- Completed years of age on a date (same as Period.between(dob, onDate).getYears() in Java).
CREATE FUNCTION fn_age_on(p_dob DATE, p_on_date DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    IF p_dob IS NULL OR p_on_date IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN TIMESTAMPDIFF(YEAR, p_dob, p_on_date);
END$$

-- Attempts used = attempts before joining the app + logged attempts that count.
CREATE FUNCTION fn_attempts_used(p_user INT, p_exam INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_before INT DEFAULT 0;
    DECLARE v_logged INT DEFAULT 0;
    SET v_before = COALESCE((SELECT attempts_used_before_app FROM user_exam_tracking
                             WHERE user_id = p_user AND exam_id = p_exam), 0);
    SET v_logged = (SELECT COUNT(*) FROM attempt_log
                    WHERE user_id = p_user AND exam_id = p_exam AND counts_as_attempt = TRUE);
    RETURN v_before + v_logged;
END$$

-- Dashboard counters for one student (called from DashboardDAO with CallableStatement).
CREATE PROCEDURE sp_user_dashboard_summary(IN p_user INT)
READS SQL DATA
BEGIN
    SELECT  COALESCE(SUM(s.status = 'ELIGIBLE'), 0)                         AS eligible_now,
            COALESCE(SUM(s.status = 'PROVISIONAL'), 0)                      AS provisional,
            COALESCE(SUM(s.status IN ('ELIGIBLE','PROVISIONAL')
                         AND s.last_eligible_year IS NOT NULL
                         AND s.last_eligible_year <= YEAR(fn_app_today()) + 1), 0) AS closing_soon,
            COALESCE(SUM(s.status = 'NOT_YET'), 0)                          AS not_yet,
            COALESCE(SUM(s.status IN ('NOT_ELIGIBLE','EXHAUSTED')), 0)      AS not_eligible,
            (SELECT COUNT(*) FROM user_exam_tracking t WHERE t.user_id = p_user) AS tracked_exams,
            (SELECT COUNT(*) FROM notification n
              WHERE n.user_id = p_user AND n.is_read = FALSE)               AS unread_notifications,
            COUNT(s.id)                                                     AS exams_checked
    FROM eligibility_snapshot s
    WHERE s.user_id = p_user;
END$$

-- Publish a rule version: archive the old ACTIVE one, activate this one, log it,
-- notify every student who tracks the exam and delete their cached results
-- so everybody's eligibility is recalculated. All inside ONE transaction.
CREATE PROCEDURE sp_activate_rule_version(IN p_version INT, IN p_admin INT)
MODIFIES SQL DATA
BEGIN
    DECLARE v_exam      INT;
    DECLARE v_status    VARCHAR(10);
    DECLARE v_no        INT;
    DECLARE v_old       INT;
    DECLARE v_old_no    INT;
    DECLARE v_short     VARCHAR(60);
    DECLARE v_notified  INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT exam_id, status, version_no INTO v_exam, v_status, v_no
    FROM exam_rule_version WHERE id = p_version FOR UPDATE;

    IF v_exam IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rule version not found';
    END IF;
    IF v_status = 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This rule version is already active';
    END IF;

    SET v_old    = (SELECT id FROM exam_rule_version WHERE exam_id = v_exam AND status = 'ACTIVE');
    SET v_old_no = (SELECT version_no FROM exam_rule_version WHERE id = v_old);
    SET v_short  = (SELECT short_name FROM exam WHERE id = v_exam);

    -- archive first: the UNIQUE key on active_exam_id allows only one ACTIVE version
    UPDATE exam_rule_version SET status = 'ARCHIVED' WHERE id = v_old;
    UPDATE exam_rule_version SET status = 'ACTIVE', activated_at = NOW() WHERE id = p_version;
    UPDATE exam SET active_rule_version_id = p_version WHERE id = v_exam;

    INSERT INTO rule_change_log (exam_id, rule_version_id, table_name, column_name,
                                 old_value, new_value, change_source, changed_by)
    VALUES (v_exam, p_version, 'exam_rule_version', 'status',
            IF(v_old_no IS NULL, NULL, CONCAT('v', v_old_no, ' ACTIVE')),
            CONCAT('v', v_no, ' ACTIVE'), 'VERSION_ACTIVATED', p_admin);

    INSERT INTO notification (user_id, title, message, link_url)
    SELECT t.user_id,
           CONCAT(v_short, ' rules updated'),
           CONCAT(v_short, ' eligibility rules were updated on ', DATE_FORMAT(NOW(), '%d-%b-%Y'),
                  ' - your result has been recalculated.'),
           CONCAT('aspirant/exam-detail.jsp?id=', v_exam)
    FROM user_exam_tracking t
    WHERE t.exam_id = v_exam;
    SET v_notified = ROW_COUNT();

    DELETE FROM eligibility_snapshot WHERE exam_id = v_exam;

    COMMIT;

    SELECT v_exam AS exam_id, v_no AS version_no, v_notified AS users_notified;
END$$

-- Copy the ACTIVE version of an exam (with all its rule rows) into a new DRAFT.
-- If a DRAFT already exists it is returned instead, so there is only one draft at a time.
-- OUT parameter p_new_version = id of the draft (read with CallableStatement.getInt(3)).
CREATE PROCEDURE sp_clone_rule_version(IN p_exam INT, IN p_admin INT, OUT p_new_version INT)
MODIFIES SQL DATA
clone_block: BEGIN
    DECLARE v_src    INT;
    DECLARE v_src_no INT;
    DECLARE v_next   INT;
    DECLARE v_draft  INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SET v_draft = (SELECT id FROM exam_rule_version
                   WHERE exam_id = p_exam AND status = 'DRAFT'
                   ORDER BY version_no DESC LIMIT 1);
    IF v_draft IS NOT NULL THEN
        SET p_new_version = v_draft;
        LEAVE clone_block;
    END IF;

    START TRANSACTION;

    SET v_src = (SELECT active_rule_version_id FROM exam WHERE id = p_exam);
    IF v_src IS NULL THEN
        SET v_src = (SELECT id FROM exam_rule_version WHERE exam_id = p_exam
                     ORDER BY version_no DESC LIMIT 1);
    END IF;
    IF v_src IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This exam has no rule version to copy';
    END IF;

    SET v_src_no = (SELECT version_no FROM exam_rule_version WHERE id = v_src);
    SET v_next   = (SELECT MAX(version_no) + 1 FROM exam_rule_version WHERE exam_id = p_exam);

    INSERT INTO exam_rule_version (exam_id, version_no, applies_from_cycle_year, status,
                                   change_summary, source_url, created_by)
    SELECT exam_id, v_next, applies_from_cycle_year, 'DRAFT',
           CONCAT('Draft copied from version ', v_src_no), source_url, p_admin
    FROM exam_rule_version WHERE id = v_src;
    SET p_new_version = LAST_INSERT_ID();

    INSERT INTO age_rule (rule_version_id, post_or_course, min_age, max_age, max_age_semantics,
                          cutoff_type, cutoff_month, cutoff_day,
                          dob_from_offset_years, dob_from_month, dob_from_day,
                          dob_to_offset_years, dob_to_month, dob_to_day, notes)
    SELECT p_new_version, post_or_course, min_age, max_age, max_age_semantics,
           cutoff_type, cutoff_month, cutoff_day,
           dob_from_offset_years, dob_from_month, dob_from_day,
           dob_to_offset_years, dob_to_month, dob_to_day, notes
    FROM age_rule WHERE rule_version_id = v_src;

    INSERT INTO relaxation_rule (rule_version_id, relaxation_type, category, years, stacking,
                                 overall_max_age_cap, requires_state_domicile, notes)
    SELECT p_new_version, relaxation_type, category, years, stacking,
           overall_max_age_cap, requires_state_domicile, notes
    FROM relaxation_rule WHERE rule_version_id = v_src;

    INSERT INTO attempt_rule (rule_version_id, category, is_pwbd, max_attempts, counting_rule,
                              window_years, min_gap_days, notes)
    SELECT p_new_version, category, is_pwbd, max_attempts, counting_rule,
           window_years, min_gap_days, notes
    FROM attempt_rule WHERE rule_version_id = v_src;

    INSERT INTO qualification_rule (rule_version_id, post_or_course, required_level, accepted_degrees,
                                    required_subjects, min_percent_general, min_percent_relaxed,
                                    relaxed_for, final_year_allowed, max_years_since_passing,
                                    min_experience_years, text_summary)
    SELECT p_new_version, post_or_course, required_level, accepted_degrees,
           required_subjects, min_percent_general, min_percent_relaxed,
           relaxed_for, final_year_allowed, max_years_since_passing,
           min_experience_years, text_summary
    FROM qualification_rule WHERE rule_version_id = v_src;

    INSERT INTO other_rule (rule_version_id, post_or_course, rule_type, rule_value, is_blocking, text_summary)
    SELECT p_new_version, post_or_course, rule_type, rule_value, is_blocking, text_summary
    FROM other_rule WHERE rule_version_id = v_src;

    COMMIT;
END$$

-- Admin analytics page: students per category, per state and PwBD / not PwBD.
CREATE PROCEDURE sp_category_report()
READS SQL DATA
BEGIN
    SELECT dimension, dimension_value, students
    FROM v_admin_category_stats
    ORDER BY dimension, students DESC, dimension_value;
END$$

DELIMITER ;

SELECT 'Functions and procedures ready' AS status,
       (SELECT COUNT(*) FROM information_schema.ROUTINES
         WHERE ROUTINE_SCHEMA = 'aspirantos') AS routines_in_aspirantos;
