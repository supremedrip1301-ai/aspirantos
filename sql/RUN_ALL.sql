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

-- Seed files (added in Phase 2):
-- SOURCE 10_seed_master.sql;  ... 11-24 exam seeds ... 30, 31, 40
