-- ============================================================
-- AspirantOS - 40_seed_admin.sql
-- The ONE pre-created account (CHANGE 001): the administrator.
--     email    : admin@aspirantos.in
--     password : Admin@123   (change it from Settings after the first login)
-- There are NO demo student accounts - students register themselves.
--
-- The password is stored only as a PBKDF2 hash (PBKDF2WithHmacSHA256, 120000 iterations,
-- 256-bit key, 16-byte random salt, both Base64) - the same algorithm as
-- com.aspirantos.util.PasswordUtil. The hash was generated once and cross-checked with
-- javax.crypto.SecretKeyFactory (identical result).
--
-- Re-runnable: if the admin already exists, only the role and status are restored; the
-- password is NOT reset, so a password changed by the admin survives a re-run.
-- ============================================================

USE aspirantos;

INSERT INTO app_user (full_name, email, phone, password_hash, password_salt, role, status)
VALUES ('AspirantOS Administrator', 'admin@aspirantos.in', NULL,
        'lvXFJjyQlfMt7s8YZQLpDeYeUK/WlOuf8ddwpufRF1c=', '+kZr4KmhPMHBjF6oTQOdfA==',
        'ADMIN', 'ACTIVE')
AS new ON DUPLICATE KEY UPDATE role = 'ADMIN', status = 'ACTIVE';

SELECT 'Admin account ready' AS status, id, email, role, status AS account_status
FROM app_user WHERE email = 'admin@aspirantos.in';
