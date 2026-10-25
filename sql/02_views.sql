-- ============================================================
-- AspirantOS - 02_views.sql
-- Run THIRD (after 01_schema.sql).
-- Views = saved SELECT queries that pages and reports read like tables.
-- Re-runnable: CREATE OR REPLACE VIEW.
-- "Today" in these views is app_setting.simulation_date when the admin
-- has set it (demo day), otherwise the real CURDATE().
-- Next file: 03_functions_procedures.sql
-- ============================================================

USE aspirantos;

-- Exam list with its category, conducting body and active rule version.
CREATE OR REPLACE VIEW v_exam_catalog AS
SELECT  e.id                    AS exam_id,
        e.code                  AS exam_code,
        e.name                  AS exam_name,
        e.short_name,
        c.code                  AS category_code,
        c.name                  AS category_name,
        b.short_name            AS body_short_name,
        b.full_name             AS body_full_name,
        e.scope,
        e.state_code,
        e.sector,
        e.purpose,
        e.cycles_per_year,
        e.typical_exam_month,
        e.data_confidence,
        e.last_verified_on,
        e.official_url,
        e.is_active,
        v.id                    AS active_version_id,
        v.version_no            AS active_version_no,
        v.activated_at
FROM exam e
JOIN exam_category c       ON c.id = e.category_id
JOIN conducting_body b     ON b.id = e.body_id
LEFT JOIN exam_rule_version v ON v.id = e.active_rule_version_id;

-- Attempts used per student per exam = attempts before joining + logged attempts that count.
CREATE OR REPLACE VIEW v_user_attempt_summary AS
SELECT  p.user_id,
        p.exam_id,
        COALESCE(t.attempts_used_before_app, 0)                         AS attempts_before_app,
        COALESCE(l.logged_attempts, 0)                                  AS logged_attempts,
        COALESCE(t.attempts_used_before_app, 0) + COALESCE(l.logged_attempts, 0) AS attempts_used,
        l.last_attempt_year
FROM (
        SELECT user_id, exam_id FROM user_exam_tracking
        UNION
        SELECT user_id, exam_id FROM attempt_log
     ) p
LEFT JOIN user_exam_tracking t ON t.user_id = p.user_id AND t.exam_id = p.exam_id
LEFT JOIN (
        SELECT user_id, exam_id,
               SUM(CASE WHEN counts_as_attempt THEN 1 ELSE 0 END) AS logged_attempts,
               MAX(cycle_year) AS last_attempt_year
        FROM attempt_log
        GROUP BY user_id, exam_id
     ) l ON l.user_id = p.user_id AND l.exam_id = p.exam_id;

-- Dashboard counters per student, read from the eligibility cache.
CREATE OR REPLACE VIEW v_user_dashboard AS
SELECT  u.id AS user_id,
        u.full_name,
        SUM(CASE WHEN s.status = 'ELIGIBLE'     THEN 1 ELSE 0 END) AS eligible_now,
        SUM(CASE WHEN s.status = 'PROVISIONAL'  THEN 1 ELSE 0 END) AS provisional,
        SUM(CASE WHEN s.status IN ('ELIGIBLE','PROVISIONAL')
                  AND s.last_eligible_year IS NOT NULL
                  AND s.last_eligible_year <= YEAR(s.computed_for_date) + 1 THEN 1 ELSE 0 END) AS closing_soon,
        SUM(CASE WHEN s.status = 'NOT_YET'      THEN 1 ELSE 0 END) AS not_yet,
        SUM(CASE WHEN s.status = 'NOT_ELIGIBLE' THEN 1 ELSE 0 END) AS not_eligible,
        SUM(CASE WHEN s.status = 'EXHAUSTED'    THEN 1 ELSE 0 END) AS exhausted,
        COUNT(s.id)                                                AS exams_checked
FROM app_user u
LEFT JOIN eligibility_snapshot s ON s.user_id = u.id
WHERE u.role = 'ASPIRANT'
GROUP BY u.id, u.full_name;

-- Admin analytics: how many registered students per category / state / PwBD.
CREATE OR REPLACE VIEW v_admin_category_stats AS
SELECT  'CATEGORY' AS dimension, p.category AS dimension_value, COUNT(*) AS students
FROM aspirant_profile p JOIN app_user u ON u.id = p.user_id AND u.role = 'ASPIRANT'
GROUP BY p.category
UNION ALL
SELECT  'STATE', COALESCE(s.name, 'Not given'), COUNT(*)
FROM aspirant_profile p JOIN app_user u ON u.id = p.user_id AND u.role = 'ASPIRANT'
LEFT JOIN state_master s ON s.code = p.domicile_state_code
GROUP BY COALESCE(s.name, 'Not given')
UNION ALL
SELECT  'PWBD', CASE WHEN p.is_pwbd THEN 'PwBD' ELSE 'Not PwBD' END, COUNT(*)
FROM aspirant_profile p JOIN app_user u ON u.id = p.user_id AND u.role = 'ASPIRANT'
GROUP BY CASE WHEN p.is_pwbd THEN 'PwBD' ELSE 'Not PwBD' END;

-- Every rule version with the number of logged changes.
CREATE OR REPLACE VIEW v_rule_history AS
SELECT  v.id            AS rule_version_id,
        v.exam_id,
        e.code          AS exam_code,
        e.short_name,
        v.version_no,
        v.status,
        v.applies_from_cycle_year,
        v.change_summary,
        v.source_url,
        v.created_at,
        v.activated_at,
        u.full_name     AS created_by_name,
        (SELECT COUNT(*) FROM rule_change_log l WHERE l.rule_version_id = v.id) AS change_count
FROM exam_rule_version v
JOIN exam e          ON e.id = v.exam_id
LEFT JOIN app_user u ON u.id = v.created_by;

-- Exam events in the next 90 days (from "today" = simulation date or real date).
CREATE OR REPLACE VIEW v_upcoming_events AS
SELECT  ev.id AS event_id,
        ev.exam_id,
        e.code       AS exam_code,
        e.short_name,
        ev.cycle_year,
        ev.event_type,
        ev.event_date,
        ev.is_tentative,
        DATEDIFF(ev.event_date, t.today) AS days_left
FROM exam_event ev
JOIN exam e ON e.id = ev.exam_id AND e.is_active
CROSS JOIN (
        SELECT COALESCE(STR_TO_DATE(NULLIF((SELECT setting_value FROM app_setting
                                            WHERE setting_key = 'simulation_date'), ''), '%Y-%m-%d'),
                        CURDATE()) AS today
     ) t
WHERE ev.event_date BETWEEN t.today AND DATE_ADD(t.today, INTERVAL 90 DAY);

SELECT 'Views ready' AS status, COUNT(*) AS views_in_aspirantos
FROM information_schema.VIEWS WHERE TABLE_SCHEMA = 'aspirantos';
