-- ============================================================
-- AspirantOS - 99_reset_all.sql
-- DANGER: deletes ALL AspirantOS tables, views, routines, triggers and data.
-- Use only for a completely fresh start, then run RUN_ALL.sql again.
-- The database itself and the user aspirant_app are kept.
-- ============================================================

USE aspirantos;

SET FOREIGN_KEY_CHECKS = 0;

-- triggers go away with their tables; routines and views are dropped explicitly
DROP PROCEDURE IF EXISTS sp_log_rule_change;
DROP PROCEDURE IF EXISTS sp_user_dashboard_summary;
DROP PROCEDURE IF EXISTS sp_activate_rule_version;
DROP PROCEDURE IF EXISTS sp_clone_rule_version;
DROP PROCEDURE IF EXISTS sp_category_report;
DROP FUNCTION IF EXISTS fn_app_today;
DROP FUNCTION IF EXISTS fn_age_on;
DROP FUNCTION IF EXISTS fn_attempts_used;

DROP VIEW IF EXISTS v_exam_catalog;
DROP VIEW IF EXISTS v_user_attempt_summary;
DROP VIEW IF EXISTS v_user_dashboard;
DROP VIEW IF EXISTS v_admin_category_stats;
DROP VIEW IF EXISTS v_rule_history;
DROP VIEW IF EXISTS v_upcoming_events;

DROP TABLE IF EXISTS audit_log;
DROP TABLE IF EXISTS notification;
DROP TABLE IF EXISTS info_report;
DROP TABLE IF EXISTS rule_change_log;
DROP TABLE IF EXISTS exam_update_check;
DROP TABLE IF EXISTS eligibility_snapshot;
DROP TABLE IF EXISTS attempt_log;
DROP TABLE IF EXISTS user_exam_tracking;
DROP TABLE IF EXISTS exam_event;
DROP TABLE IF EXISTS doc_spec;
DROP TABLE IF EXISTS other_rule;
DROP TABLE IF EXISTS qualification_rule;
DROP TABLE IF EXISTS attempt_rule;
DROP TABLE IF EXISTS relaxation_rule;
DROP TABLE IF EXISTS age_rule;
DROP TABLE IF EXISTS exam_rule_version;
DROP TABLE IF EXISTS exam;
DROP TABLE IF EXISTS work_experience;
DROP TABLE IF EXISTS education;
DROP TABLE IF EXISTS aspirant_profile;
DROP TABLE IF EXISTS app_setting;
DROP TABLE IF EXISTS conducting_body;
DROP TABLE IF EXISTS exam_category;
DROP TABLE IF EXISTS state_master;
DROP TABLE IF EXISTS remember_token;
DROP TABLE IF EXISTS app_user;

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'All AspirantOS objects dropped - now run RUN_ALL.sql' AS status;
