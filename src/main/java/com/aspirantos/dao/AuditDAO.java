package com.aspirantos.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.AuditLog;
import com.aspirantos.util.DBConnection;

/**
 * JDBC access to audit_log - who did what and when (login, logout, profile saved,
 * rules published ...). Shown on the admin "Audit log" page.
 */
public class AuditDAO {

    /** userId may be null (e.g. a failed login for an unknown e-mail). */
    public int insertAudit(Integer userId, String action, String entity, String entityId,
                           String ipAddress, String userAgent) {
        String sql = "INSERT INTO audit_log (user_id, action, entity, entity_id, ip_address, user_agent) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            DaoUtil.setInt(ps, 1, userId);
            ps.setString(2, action);
            DaoUtil.setString(ps, 3, entity);
            DaoUtil.setString(ps, 4, entityId);
            DaoUtil.setString(ps, 5, ipAddress);
            DaoUtil.setString(ps, 6, userAgent == null || userAgent.length() <= 300 ? userAgent : userAgent.substring(0, 300));
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<AuditLog> getRecent(int limit) {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT * FROM audit_log ORDER BY created_at DESC, id DESC LIMIT ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapAudit(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private AuditLog mapAudit(ResultSet rs) throws SQLException {
        return new AuditLog(
                rs.getInt("id"),
                DaoUtil.getInteger(rs, "user_id"),
                rs.getString("action"),
                rs.getString("entity"),
                rs.getString("entity_id"),
                rs.getString("ip_address"),
                rs.getString("user_agent"),
                DaoUtil.getLocalDateTime(rs, "created_at")
        );
    }
}
