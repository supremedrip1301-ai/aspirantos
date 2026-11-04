package com.aspirantos.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

/**
 * [EXTRA] Password hashing - not taught in the lab, needed so that no plain password is ever
 * stored. Uses PBKDF2WithHmacSHA256 with 120 000 iterations, a 256-bit key and a 16-byte
 * random salt (both stored as Base64 in app_user). The seeded admin hash in
 * sql/40_seed_admin.sql was made with exactly these settings.
 * Also creates random tokens and SHA-256 hashes for the "Remember me" cookie.
 */
public class PasswordUtil {

    private static final int ITERATIONS = 120000;
    private static final int KEY_BITS = 256;
    private static final int SALT_BYTES = 16;
    private static final SecureRandom RANDOM = new SecureRandom();

    /** A new random salt, Base64 encoded (24 characters). */
    public static String newSalt() {
        byte[] salt = new byte[SALT_BYTES];
        RANDOM.nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }

    /** PBKDF2 hash of the password with the given Base64 salt, Base64 encoded (44 characters). */
    public static String hash(String password, String saltBase64) {
        try {
            byte[] salt = Base64.getDecoder().decode(saltBase64);
            PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, ITERATIONS, KEY_BITS);
            byte[] hash = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
            spec.clearPassword();
            return Base64.getEncoder().encodeToString(hash);
        } catch (Exception e) {
            throw new IllegalStateException("Password hashing failed", e);
        }
    }

    /** True when the password produces the stored hash. Compared in constant time. */
    public static boolean verify(String password, String saltBase64, String expectedHash) {
        if (password == null || saltBase64 == null || expectedHash == null) {
            return false;
        }
        byte[] actual = hash(password, saltBase64).getBytes(StandardCharsets.UTF_8);
        byte[] expected = expectedHash.getBytes(StandardCharsets.UTF_8);
        return MessageDigest.isEqual(actual, expected);
    }

    /** A random URL-safe token (for the remember-me cookie). */
    public static String randomToken() {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    /** SHA-256 of a text as 64 hex characters (only this is stored for remember-me tokens and page hashes). */
    public static String sha256Hex(String text) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(text.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : digest) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new IllegalStateException("SHA-256 failed", e);
        }
    }
}
