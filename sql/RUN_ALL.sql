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
-- (more seed files are added here as Phase 2 continues: 13-24, 30, 31, 40)
