package com.aspirantos.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.User;
import com.aspirantos.util.DBConnection;

/**
 * JDBC access to the table app_user - same shape as StudentDAO in lab Experiment 4
 * (try-with-resources, PreparedStatement, setXxx, executeUpdate / executeQuery).
 */
public class UserDAO {

    private static final String COLUMNS =
            "id, full_name, email, phone, password_hash, password_salt, role, status, last_login_at, created_at";

    // CREATE - returns the new user id (0 if the insert failed)
    public int insertUser(User user) {
        String sql = "INSERT INTO app_user "
                + "(full_name, email, phone, password_hash, password_salt, role, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
        ) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail().trim().toLowerCase());
            DaoUtil.setString(ps, 3, user.getPhone());
            ps.setString(4, user.getPasswordHash());
            ps.setString(5, user.getPasswordSalt());
            ps.setString(6, user.getRole() == null ? "ASPIRANT" : user.getRole());
            ps.setString(7, user.getStatus() == null ? "ACTIVE" : user.getStatus());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // READ ALL (newest first)
    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT " + COLUMNS + " FROM app_user ORDER BY created_at DESC";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                users.add(mapUser(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return users;
    }

    // READ ONE USER
    public User getUser(int id) {
        String sql = "SELECT " + COLUMNS + " FROM app_user WHERE id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // READ BY E-MAIL (login)
    public User getUserByEmail(String email) {
        String sql = "SELECT " + COLUMNS + " FROM app_user WHERE email=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, email.trim().toLowerCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean emailExists(String email) {
        return getUserByEmail(email) != null;
    }

    // UPDATE name and phone
    public int updateUser(User user) {
        String sql = "UPDATE app_user SET full_name=?, phone=? WHERE id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, user.getFullName());
            DaoUtil.setString(ps, 2, user.getPhone());
            ps.setInt(3, user.getId());
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int updatePassword(int userId, String passwordHash, String passwordSalt) {
        String sql = "UPDATE app_user SET password_hash=?, password_salt=? WHERE id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, passwordHash);
            ps.setString(2, passwordSalt);
            ps.setInt(3, userId);
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** ACTIVE or BLOCKED (admin "Users" page). The admin account itself is never blocked. */
    public int updateStatus(int userId, String status) {
        String sql = "UPDATE app_user SET status=? WHERE id=? AND role='ASPIRANT'";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, status);
            ps.setInt(2, userId);
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int updateLastLogin(int userId) {
        String sql = "UPDATE app_user SET last_login_at=NOW() WHERE id=?";
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

    // DELETE - child rows (profile, education, attempts ...) go with ON DELETE CASCADE
    public int deleteUser(int id) {
        String sql = "DELETE FROM app_user WHERE id=? AND role='ASPIRANT'";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, id);
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countUsersByRole(String role) {
        String sql = "SELECT COUNT(*) FROM app_user WHERE role=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, role);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        return new User(
                rs.getInt("id"),
                rs.getString("full_name"),
                rs.getString("email"),
                rs.getString("phone"),
                rs.getString("password_hash"),
                rs.getString("password_salt"),
                rs.getString("role"),
                rs.getString("status"),
                DaoUtil.getLocalDateTime(rs, "last_login_at"),
                DaoUtil.getLocalDateTime(rs, "created_at")
        );
    }
}
