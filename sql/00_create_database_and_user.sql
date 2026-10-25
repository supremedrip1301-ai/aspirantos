-- ============================================================
-- AspirantOS - 00_create_database_and_user.sql
-- Run FIRST, as the MySQL root user (MySQL Workbench or mysql CLI).
-- Creates the database `aspirantos` and the application user
-- `aspirant_app` / `Aspirant@123`, so the root password never
-- appears in the project code (DBConnection uses aspirant_app).
-- Re-runnable: IF NOT EXISTS everywhere, password is re-applied.
-- Next file: 01_schema.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS aspirantos
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

CREATE USER IF NOT EXISTS 'aspirant_app'@'localhost' IDENTIFIED BY 'Aspirant@123';
ALTER USER 'aspirant_app'@'localhost' IDENTIFIED BY 'Aspirant@123';

-- The app user may do everything inside aspirantos only (tables, views,
-- procedures, triggers), and nothing in any other database.
GRANT ALL PRIVILEGES ON aspirantos.* TO 'aspirant_app'@'localhost';
FLUSH PRIVILEGES;

USE aspirantos;
SELECT 'Database aspirantos and user aspirant_app are ready' AS status;
