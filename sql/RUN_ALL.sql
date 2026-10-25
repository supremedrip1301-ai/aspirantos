-- ============================================================
-- AspirantOS - RUN_ALL.sql
-- Runs every script in the correct order (mysql command-line client only,
-- because SOURCE is a client command).
--
-- Run it as root from INSIDE the sql folder:
--     cd D:\AIP\AspirantOS\sql
--     mysql -u root -p --default-character-set=utf8mb4 < RUN_ALL.sql
-- Root is needed because MySQL (binary logging is on by default) only lets
-- a SUPER user create stored functions and triggers. The web application
-- itself always connects as aspirant_app.
--
-- In MySQL Workbench: open and execute the files one by one in this order.
-- Every file is re-runnable.
-- ============================================================

SOURCE 00_create_database_and_user.sql;
SOURCE 01_schema.sql;
SOURCE 02_views.sql;
SOURCE 03_functions_procedures.sql;
SOURCE 04_triggers.sql;
SOURCE 05_seed_helpers.sql;

SOURCE 10_seed_master.sql;
SOURCE 11_seed_exams_upsc.sql;
SOURCE 12_seed_exams_ssc.sql;
SOURCE 13_seed_exams_banking_insurance.sql;
SOURCE 14_seed_exams_railways_defence_police.sql;
SOURCE 15_seed_exams_state_psc.sql;
SOURCE 16_seed_exams_teaching.sql;
SOURCE 17_seed_exams_engineering.sql;
SOURCE 18_seed_exams_medical.sql;
SOURCE 19_seed_exams_management.sql;
SOURCE 20_seed_exams_law_judiciary.sql;
SOURCE 21_seed_exams_design_science_research_agri.sql;
SOURCE 22_seed_exams_professional_finance.sql;
SOURCE 23_seed_exams_school_level.sql;
SOURCE 24_seed_exams_international.sql;
SOURCE 29_verified_sources.sql;
SOURCE 30_seed_doc_specs.sql;
SOURCE 31_seed_exam_events.sql;
SOURCE 40_seed_admin.sql;

SELECT 'RUN_ALL finished' AS status;
