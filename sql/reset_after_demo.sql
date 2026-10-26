-- ============================================================
-- AspirantOS - reset after a demo rehearsal (NOT part of RUN_ALL.sql)
-- The demo (docs/DEMO_SCRIPT.md) publishes a new UPSC CSE rule version and sets the
-- simulation date. Run this file as root in Workbench (or: mysql -uroot -p aspirantos <
-- sql/reset_after_demo.sql) after a rehearsal, so the real presentation starts from the
-- seeded state again. It:
--   1. makes the seeded version 1 of UPSC CSE active again and deletes later versions
--      (their rule rows and cached results go with them - ON DELETE CASCADE),
--   2. removes the rule-change log, update checks and audit entries of those versions,
--   3. switches the simulation date off.
-- Student accounts are not touched: delete the rehearsal student from its own Settings page
-- ("Delete my account").
-- ============================================================
USE aspirantos;

SET @exam = (SELECT id FROM exam WHERE code = 'UPSC_CSE');
SET @v1   = (SELECT id FROM exam_rule_version WHERE exam_id = @exam AND version_no = 1);

START TRANSACTION;

-- 1. archive whatever is active now, then activate version 1
--    (the UNIQUE key on active_exam_id allows only one ACTIVE version at a time)
UPDATE exam_rule_version SET status = 'ARCHIVED' WHERE exam_id = @exam AND status = 'ACTIVE' AND id <> @v1;
UPDATE exam_rule_version SET status = 'ACTIVE' WHERE id = @v1;
UPDATE exam SET active_rule_version_id = @v1 WHERE id = @exam;

-- 2. later versions and their traces
DELETE FROM rule_change_log WHERE exam_id = @exam AND change_source IN ('ADMIN_EDIT', 'VERSION_ACTIVATED');
DELETE FROM audit_log WHERE entity = 'exam_rule_version'
   AND entity_id IN (SELECT CAST(id AS CHAR) FROM exam_rule_version WHERE exam_id = @exam AND version_no > 1);
DELETE FROM exam_rule_version WHERE exam_id = @exam AND version_no > 1;
DELETE FROM exam_update_check WHERE exam_id = @exam;

-- 3. real date again
UPDATE app_setting SET setting_value = '' WHERE setting_key = 'simulation_date';

COMMIT;

SELECT e.short_name, v.version_no, v.status
FROM exam e JOIN exam_rule_version v ON v.exam_id = e.id
WHERE e.id = @exam;
