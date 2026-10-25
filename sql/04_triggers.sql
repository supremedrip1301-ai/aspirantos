-- ============================================================
-- AspirantOS - 04_triggers.sql
-- Run FIFTH (after 03_functions_procedures.sql), in Workbench or the mysql CLI.
-- Triggers keep the database consistent on their own:
--   * attempt_log   : decide counts_as_attempt from the exam's counting rule,
--                     and clear the cached eligibility result
--   * profile / education / work experience / tracking : clear cached results
--   * rule tables   : write every changed value (old -> new) into rule_change_log
-- The application can say WHO made a rule change by running
--   SET @app_user_id = <admin id>, @rule_change_source = 'ADMIN_EDIT';
-- on the same connection before the UPDATE (RuleDAO does this).
-- Re-runnable: DROP ... IF EXISTS before every CREATE.
-- Next files: 10_seed_master.sql and the other seed files (see RUN_ALL.sql)
-- ============================================================

USE aspirantos;

DROP PROCEDURE IF EXISTS sp_log_rule_change;
DROP TRIGGER IF EXISTS trg_attempt_log_bi;
DROP TRIGGER IF EXISTS trg_attempt_log_bu;
DROP TRIGGER IF EXISTS trg_attempt_log_ai;
DROP TRIGGER IF EXISTS trg_attempt_log_au;
DROP TRIGGER IF EXISTS trg_attempt_log_ad;
DROP TRIGGER IF EXISTS trg_profile_au;
DROP TRIGGER IF EXISTS trg_education_ai;
DROP TRIGGER IF EXISTS trg_education_au;
DROP TRIGGER IF EXISTS trg_education_ad;
DROP TRIGGER IF EXISTS trg_work_experience_ai;
DROP TRIGGER IF EXISTS trg_work_experience_au;
DROP TRIGGER IF EXISTS trg_work_experience_ad;
DROP TRIGGER IF EXISTS trg_tracking_ai;
DROP TRIGGER IF EXISTS trg_tracking_au;
DROP TRIGGER IF EXISTS trg_tracking_ad;
DROP TRIGGER IF EXISTS trg_age_rule_au;
DROP TRIGGER IF EXISTS trg_relaxation_rule_au;
DROP TRIGGER IF EXISTS trg_attempt_rule_au;
DROP TRIGGER IF EXISTS trg_qualification_rule_au;

DELIMITER $$

-- Helper used by the rule-table triggers: logs one column if its value really changed.
CREATE PROCEDURE sp_log_rule_change(IN p_version INT, IN p_table VARCHAR(60), IN p_column VARCHAR(60),
                                    IN p_old VARCHAR(500), IN p_new VARCHAR(500))
MODIFIES SQL DATA
BEGIN
    IF NOT (p_old <=> p_new) THEN
        INSERT INTO rule_change_log (exam_id, rule_version_id, table_name, column_name,
                                     old_value, new_value, change_source, changed_by)
        SELECT v.exam_id, p_version, p_table, p_column, p_old, p_new,
               COALESCE(@rule_change_source, 'ADMIN_EDIT'), @app_user_id
        FROM exam_rule_version v
        WHERE v.id = p_version;
    END IF;
END$$

-- ---------- attempt_log ----------

-- An attempt counts unless the student only applied or was absent,
-- except for exams whose rule says that applying itself counts (counting_rule = APPLIED).
CREATE TRIGGER trg_attempt_log_bi
BEFORE INSERT ON attempt_log
FOR EACH ROW
BEGIN
    DECLARE v_rule VARCHAR(50);
    SET v_rule = (SELECT ar.counting_rule
                  FROM attempt_rule ar
                  JOIN exam e ON e.active_rule_version_id = ar.rule_version_id
                  WHERE e.id = NEW.exam_id
                  ORDER BY (ar.category IS NULL) DESC, (ar.is_pwbd IS NULL) DESC
                  LIMIT 1);
    IF v_rule = 'APPLIED' THEN
        SET NEW.counts_as_attempt = TRUE;
    ELSE
        SET NEW.counts_as_attempt = NEW.stage_reached NOT IN ('APPLIED_ONLY', 'ABSENT');
    END IF;
END$$

CREATE TRIGGER trg_attempt_log_bu
BEFORE UPDATE ON attempt_log
FOR EACH ROW
BEGIN
    DECLARE v_rule VARCHAR(50);
    SET v_rule = (SELECT ar.counting_rule
                  FROM attempt_rule ar
                  JOIN exam e ON e.active_rule_version_id = ar.rule_version_id
                  WHERE e.id = NEW.exam_id
                  ORDER BY (ar.category IS NULL) DESC, (ar.is_pwbd IS NULL) DESC
                  LIMIT 1);
    IF v_rule = 'APPLIED' THEN
        SET NEW.counts_as_attempt = TRUE;
    ELSE
        SET NEW.counts_as_attempt = NEW.stage_reached NOT IN ('APPLIED_ONLY', 'ABSENT');
    END IF;
END$$

CREATE TRIGGER trg_attempt_log_ai
AFTER INSERT ON attempt_log
FOR EACH ROW
BEGIN
    DELETE FROM eligibility_snapshot WHERE user_id = NEW.user_id AND exam_id = NEW.exam_id;
END$$

CREATE TRIGGER trg_attempt_log_au
AFTER UPDATE ON attempt_log
FOR EACH ROW
BEGIN
    DELETE FROM eligibility_snapshot WHERE user_id = NEW.user_id AND exam_id IN (OLD.exam_id, NEW.exam_id);
END$$

CREATE TRIGGER trg_attempt_log_ad
AFTER DELETE ON attempt_log
FOR EACH ROW
BEGIN
    DELETE FROM eligibility_snapshot WHERE user_id = OLD.user_id AND exam_id = OLD.exam_id;
END$$

-- ---------- profile, education, work experience: any change -> recompute all results ----------

CREATE TRIGGER trg_profile_au
AFTER UPDATE ON aspirant_profile
FOR EACH ROW
BEGIN
    DELETE FROM eligibility_snapshot WHERE user_id = NEW.user_id;
END$$

CREATE TRIGGER trg_education_ai
AFTER INSERT ON education
FOR EACH ROW
BEGIN
    DELETE FROM eligibility_snapshot WHERE user_id = NEW.user_id;
END$$

CREATE TRIGGER trg_education_au
AFTER UPDATE ON education
FOR EACH ROW
BEGIN
    DELETE FROM eligibility_snapshot WHERE user_id = NEW.user_id;
END$$

CREATE TRIGGER trg_education_ad
AFTER DELETE ON education
FOR EACH ROW
BEGIN
    DELETE FROM eligibility_snapshot WHERE user_id = OLD.user_id;
END$$

CREATE TRIGGER trg_work_experience_ai
AFTER INSERT ON work_experience
FOR EACH ROW
BEGIN
    DELETE FROM eligibility_snapshot WHERE user_id = NEW.user_id;
END$$

CREATE TRIGGER trg_work_experience_au
AFTER UPDATE ON work_experience
FOR EACH ROW
BEGIN
    DELETE FROM eligibility_snapshot WHERE user_id = NEW.user_id;
END$$

CREATE TRIGGER trg_work_experience_ad
AFTER DELETE ON work_experience
FOR EACH ROW
BEGIN
    DELETE FROM eligibility_snapshot WHERE user_id = OLD.user_id;
END$$

-- ---------- tracking: attempts used before joining changed -> recompute that exam ----------

CREATE TRIGGER trg_tracking_ai
AFTER INSERT ON user_exam_tracking
FOR EACH ROW
BEGIN
    DELETE FROM eligibility_snapshot WHERE user_id = NEW.user_id AND exam_id = NEW.exam_id;
END$$

CREATE TRIGGER trg_tracking_au
AFTER UPDATE ON user_exam_tracking
FOR EACH ROW
BEGIN
    IF NOT (OLD.attempts_used_before_app <=> NEW.attempts_used_before_app) THEN
        DELETE FROM eligibility_snapshot WHERE user_id = NEW.user_id AND exam_id = NEW.exam_id;
    END IF;
END$$

CREATE TRIGGER trg_tracking_ad
AFTER DELETE ON user_exam_tracking
FOR EACH ROW
BEGIN
    DELETE FROM eligibility_snapshot WHERE user_id = OLD.user_id AND exam_id = OLD.exam_id;
END$$

-- ---------- rule tables: audit trail of every changed value ----------
-- If the edited row belongs to the ACTIVE version, cached results of that exam are cleared too.

CREATE TRIGGER trg_age_rule_au
AFTER UPDATE ON age_rule
FOR EACH ROW
BEGIN
    CALL sp_log_rule_change(NEW.rule_version_id, 'age_rule', 'post_or_course', OLD.post_or_course, NEW.post_or_course);
    CALL sp_log_rule_change(NEW.rule_version_id, 'age_rule', 'min_age', OLD.min_age, NEW.min_age);
    CALL sp_log_rule_change(NEW.rule_version_id, 'age_rule', 'max_age', OLD.max_age, NEW.max_age);
    CALL sp_log_rule_change(NEW.rule_version_id, 'age_rule', 'max_age_semantics', OLD.max_age_semantics, NEW.max_age_semantics);
    CALL sp_log_rule_change(NEW.rule_version_id, 'age_rule', 'cutoff_type', OLD.cutoff_type, NEW.cutoff_type);
    CALL sp_log_rule_change(NEW.rule_version_id, 'age_rule', 'cutoff_month', OLD.cutoff_month, NEW.cutoff_month);
    CALL sp_log_rule_change(NEW.rule_version_id, 'age_rule', 'cutoff_day', OLD.cutoff_day, NEW.cutoff_day);
    CALL sp_log_rule_change(NEW.rule_version_id, 'age_rule', 'dob_from_offset_years', OLD.dob_from_offset_years, NEW.dob_from_offset_years);
    CALL sp_log_rule_change(NEW.rule_version_id, 'age_rule', 'dob_from_month', OLD.dob_from_month, NEW.dob_from_month);
    CALL sp_log_rule_change(NEW.rule_version_id, 'age_rule', 'dob_from_day', OLD.dob_from_day, NEW.dob_from_day);
    CALL sp_log_rule_change(NEW.rule_version_id, 'age_rule', 'dob_to_offset_years', OLD.dob_to_offset_years, NEW.dob_to_offset_years);
    CALL sp_log_rule_change(NEW.rule_version_id, 'age_rule', 'dob_to_month', OLD.dob_to_month, NEW.dob_to_month);
    CALL sp_log_rule_change(NEW.rule_version_id, 'age_rule', 'dob_to_day', OLD.dob_to_day, NEW.dob_to_day);
    CALL sp_log_rule_change(NEW.rule_version_id, 'age_rule', 'notes', OLD.notes, NEW.notes);
    DELETE s FROM eligibility_snapshot s
    JOIN exam_rule_version v ON v.exam_id = s.exam_id
    WHERE v.id = NEW.rule_version_id AND v.status = 'ACTIVE';
END$$

CREATE TRIGGER trg_relaxation_rule_au
AFTER UPDATE ON relaxation_rule
FOR EACH ROW
BEGIN
    CALL sp_log_rule_change(NEW.rule_version_id, 'relaxation_rule', 'relaxation_type', OLD.relaxation_type, NEW.relaxation_type);
    CALL sp_log_rule_change(NEW.rule_version_id, 'relaxation_rule', 'category', OLD.category, NEW.category);
    CALL sp_log_rule_change(NEW.rule_version_id, 'relaxation_rule', 'years', OLD.years, NEW.years);
    CALL sp_log_rule_change(NEW.rule_version_id, 'relaxation_rule', 'stacking', OLD.stacking, NEW.stacking);
    CALL sp_log_rule_change(NEW.rule_version_id, 'relaxation_rule', 'overall_max_age_cap', OLD.overall_max_age_cap, NEW.overall_max_age_cap);
    CALL sp_log_rule_change(NEW.rule_version_id, 'relaxation_rule', 'requires_state_domicile', OLD.requires_state_domicile, NEW.requires_state_domicile);
    CALL sp_log_rule_change(NEW.rule_version_id, 'relaxation_rule', 'notes', OLD.notes, NEW.notes);
    DELETE s FROM eligibility_snapshot s
    JOIN exam_rule_version v ON v.exam_id = s.exam_id
    WHERE v.id = NEW.rule_version_id AND v.status = 'ACTIVE';
END$$

CREATE TRIGGER trg_attempt_rule_au
AFTER UPDATE ON attempt_rule
FOR EACH ROW
BEGIN
    CALL sp_log_rule_change(NEW.rule_version_id, 'attempt_rule', 'category', OLD.category, NEW.category);
    CALL sp_log_rule_change(NEW.rule_version_id, 'attempt_rule', 'is_pwbd', OLD.is_pwbd, NEW.is_pwbd);
    CALL sp_log_rule_change(NEW.rule_version_id, 'attempt_rule', 'max_attempts', OLD.max_attempts, NEW.max_attempts);
    CALL sp_log_rule_change(NEW.rule_version_id, 'attempt_rule', 'counting_rule', OLD.counting_rule, NEW.counting_rule);
    CALL sp_log_rule_change(NEW.rule_version_id, 'attempt_rule', 'window_years', OLD.window_years, NEW.window_years);
    CALL sp_log_rule_change(NEW.rule_version_id, 'attempt_rule', 'min_gap_days', OLD.min_gap_days, NEW.min_gap_days);
    CALL sp_log_rule_change(NEW.rule_version_id, 'attempt_rule', 'notes', OLD.notes, NEW.notes);
    DELETE s FROM eligibility_snapshot s
    JOIN exam_rule_version v ON v.exam_id = s.exam_id
    WHERE v.id = NEW.rule_version_id AND v.status = 'ACTIVE';
END$$

CREATE TRIGGER trg_qualification_rule_au
AFTER UPDATE ON qualification_rule
FOR EACH ROW
BEGIN
    CALL sp_log_rule_change(NEW.rule_version_id, 'qualification_rule', 'post_or_course', OLD.post_or_course, NEW.post_or_course);
    CALL sp_log_rule_change(NEW.rule_version_id, 'qualification_rule', 'required_level', OLD.required_level, NEW.required_level);
    CALL sp_log_rule_change(NEW.rule_version_id, 'qualification_rule', 'accepted_degrees', OLD.accepted_degrees, NEW.accepted_degrees);
    CALL sp_log_rule_change(NEW.rule_version_id, 'qualification_rule', 'required_subjects', OLD.required_subjects, NEW.required_subjects);
    CALL sp_log_rule_change(NEW.rule_version_id, 'qualification_rule', 'min_percent_general', OLD.min_percent_general, NEW.min_percent_general);
    CALL sp_log_rule_change(NEW.rule_version_id, 'qualification_rule', 'min_percent_relaxed', OLD.min_percent_relaxed, NEW.min_percent_relaxed);
    CALL sp_log_rule_change(NEW.rule_version_id, 'qualification_rule', 'relaxed_for', OLD.relaxed_for, NEW.relaxed_for);
    CALL sp_log_rule_change(NEW.rule_version_id, 'qualification_rule', 'final_year_allowed', OLD.final_year_allowed, NEW.final_year_allowed);
    CALL sp_log_rule_change(NEW.rule_version_id, 'qualification_rule', 'max_years_since_passing', OLD.max_years_since_passing, NEW.max_years_since_passing);
    CALL sp_log_rule_change(NEW.rule_version_id, 'qualification_rule', 'min_experience_years', OLD.min_experience_years, NEW.min_experience_years);
    CALL sp_log_rule_change(NEW.rule_version_id, 'qualification_rule', 'text_summary', OLD.text_summary, NEW.text_summary);
    DELETE s FROM eligibility_snapshot s
    JOIN exam_rule_version v ON v.exam_id = s.exam_id
    WHERE v.id = NEW.rule_version_id AND v.status = 'ACTIVE';
END$$

DELIMITER ;

SELECT 'Triggers ready' AS status,
       (SELECT COUNT(*) FROM information_schema.TRIGGERS
         WHERE TRIGGER_SCHEMA = 'aspirantos') AS triggers_in_aspirantos;
