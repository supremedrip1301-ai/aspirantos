package com.aspirantos.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;

import com.aspirantos.util.DBConnection;

/**
 * [EXTRA] "Remember me" tokens (table remember_token). The browser cookie keeps a random
 * token; only its SHA-256 hash is stored here, with a 14-day expiry.
 */
public class RememberTokenDAO {

    public int insertToken(int userId, String tokenHash, LocalDateTime expiresAt) {
        String sql = "INSERT INTO remember_token (user_id, token_hash, expires_at) VALUES (?, ?, ?)";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ps.setString(2, tokenHash);
            ps.setTimestamp(3, Timestamp.valueOf(expiresAt));
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** The user id of a valid (not expired) token, or 0. */
    public int getUserIdByToken(String tokenHash) {
        String sql = "SELECT user_id FROM remember_token WHERE token_hash=? AND expires_at > NOW()";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, tokenHash);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("user_id");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int deleteToken(String tokenHash) {
        String sql = "DELETE FROM remember_token WHERE token_hash=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, tokenHash);
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Logs the user out on every device (used after a password change). */
    public int deleteTokensOfUser(int userId) {
        String sql = "DELETE FROM remember_token WHERE user_id=? OR expires_at <= NOW()";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}
