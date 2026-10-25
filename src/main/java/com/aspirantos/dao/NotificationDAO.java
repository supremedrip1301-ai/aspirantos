package com.aspirantos.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.Notification;
import com.aspirantos.util.DBConnection;

/**
 * JDBC access to notification (the bell in the header). Rule-update notifications are
 * created by the stored procedure sp_activate_rule_version; this DAO reads them and creates
 * the other ones (welcome message, report answered ...).
 */
public class NotificationDAO {

    public int insertNotification(Notification n) {
        String sql = "INSERT INTO notification (user_id, title, message, link_url) VALUES (?, ?, ?, ?)";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, n.getUserId());
            ps.setString(2, n.getTitle());
            ps.setString(3, n.getMessage());
            DaoUtil.setString(ps, 4, n.getLinkUrl());
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Newest first; limit = how many rows (e.g. 5 for the bell drop-down). */
    public List<Notification> getNotificationsByUser(int userId, int limit) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT * FROM notification WHERE user_id=? ORDER BY created_at DESC, id DESC LIMIT ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapNotification(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countUnread(int userId) {
        String sql = "SELECT COUNT(*) FROM notification WHERE user_id=? AND is_read=FALSE";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
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

    public int markRead(int id, int userId) {
        String sql = "UPDATE notification SET is_read=TRUE WHERE id=? AND user_id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int markAllRead(int userId) {
        String sql = "UPDATE notification SET is_read=TRUE WHERE user_id=? AND is_read=FALSE";
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

    private Notification mapNotification(ResultSet rs) throws SQLException {
        return new Notification(
                rs.getInt("id"),
                rs.getInt("user_id"),
                rs.getString("title"),
                rs.getString("message"),
                rs.getString("link_url"),
                rs.getBoolean("is_read"),
                DaoUtil.getLocalDateTime(rs, "created_at")
        );
    }
}
