-- ============================================================
-- AspirantOS - 98_integrity_checks.sql
-- Read-only health check of the seeded data. Run any time (as aspirant_app or root).
-- Every "PROBLEM" row must show 0. The summary shows the size of the catalogue.
-- ============================================================

USE aspirantos;

SELECT 'exams' AS item, COUNT(*) AS value FROM exam
UNION ALL SELECT 'categories with exams', COUNT(DISTINCT category_id) FROM exam
UNION ALL SELECT 'VERIFIED exams', COUNT(*) FROM exam WHERE data_confidence = 'VERIFIED'
UNION ALL SELECT 'document specs', COUNT(*) FROM doc_spec
UNION ALL SELECT 'exam events (official)', COUNT(*) FROM exam_event WHERE is_tentative = FALSE
UNION ALL SELECT 'exam events (tentative)', COUNT(*) FROM exam_event WHERE is_tentative = TRUE
UNION ALL SELECT 'accounts', COUNT(*) FROM app_user
UNION ALL SELECT 'admin accounts', COUNT(*) FROM app_user WHERE role = 'ADMIN';

SELECT 'PROBLEM: exam without active version' AS problem, COUNT(*) AS rows_found FROM exam WHERE active_rule_version_id IS NULL
UNION ALL SELECT 'PROBLEM: active version belongs to another exam or is not ACTIVE', COUNT(*)
    FROM exam e JOIN exam_rule_version v ON v.id = e.active_rule_version_id WHERE v.exam_id <> e.id OR v.status <> 'ACTIVE'
UNION ALL SELECT 'PROBLEM: no age rule', COUNT(*) FROM exam e
    WHERE NOT EXISTS (SELECT 1 FROM age_rule a WHERE a.rule_version_id = e.active_rule_version_id)
UNION ALL SELECT 'PROBLEM: no qualification rule', COUNT(*) FROM exam e
    WHERE NOT EXISTS (SELECT 1 FROM qualification_rule q WHERE q.rule_version_id = e.active_rule_version_id)
UNION ALL SELECT 'PROBLEM: no attempt rule', COUNT(*) FROM exam e
    WHERE NOT EXISTS (SELECT 1 FROM attempt_rule t WHERE t.rule_version_id = e.active_rule_version_id)
UNION ALL SELECT 'PROBLEM: no photo spec', COUNT(*) FROM exam e
    WHERE NOT EXISTS (SELECT 1 FROM doc_spec s WHERE s.exam_id = e.id AND s.doc_type = 'PHOTO')
UNION ALL SELECT 'PROBLEM: more than one ACTIVE version', COUNT(*)
    FROM (SELECT exam_id FROM exam_rule_version WHERE status = 'ACTIVE' GROUP BY exam_id HAVING COUNT(*) > 1) t
UNION ALL SELECT 'PROBLEM: STATE exam without a state', COUNT(*) FROM exam WHERE scope = 'STATE' AND state_code IS NULL
UNION ALL SELECT 'PROBLEM: fixed-date age rule without month/day', COUNT(*) FROM age_rule
    WHERE cutoff_type LIKE 'FIXED%' AND (cutoff_month IS NULL OR cutoff_day IS NULL)
UNION ALL SELECT 'PROBLEM: max age below min age', COUNT(*) FROM age_rule WHERE max_age < min_age
UNION ALL SELECT 'PROBLEM: demo student accounts', COUNT(*) FROM app_user WHERE email LIKE '%.demo@%'
UNION ALL SELECT 'PROBLEM: admin account missing', 1 - COUNT(*) FROM app_user WHERE email = 'admin@aspirantos.in' AND role = 'ADMIN';
