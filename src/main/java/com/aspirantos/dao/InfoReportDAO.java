package com.aspirantos.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.InfoReport;
import com.aspirantos.util.DBConnection;

/**
 * JDBC access to info_report - "Report outdated info" messages sent by students and
 * answered by the admin.
 */
public class InfoReportDAO {

    private static final String SELECT =
            "SELECT r.*, u.full_name AS user_name, e.short_name AS exam_short_name "
            + "FROM info_report r JOIN app_user u ON u.id = r.user_id JOIN exam e ON e.id = r.exam_id ";

    public int insertReport(InfoReport r) {
        String sql = "INSERT INTO info_report (user_id, exam_id, message) VALUES (?, ?, ?)";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, r.getUserId());
            ps.setInt(2, r.getExamId());
            ps.setString(3, r.getMessage());
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** status = OPEN / RESOLVED / REJECTED, or null for all reports. */
    public List<InfoReport> getAllReports(String status) {
        String sql = SELECT + (status == null ? "" : "WHERE r.status=? ") + "ORDER BY r.created_at DESC";
        return query(sql, status, 0);
    }

    public List<InfoReport> getReportsByUser(int userId) {
        return query(SELECT + "WHERE r.user_id=? ORDER BY r.created_at DESC", null, userId);
    }

    public InfoReport getReport(int id) {
        List<InfoReport> list = new ArrayList<>();
        String sql = SELECT + "WHERE r.id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapReport(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list.isEmpty() ? null : list.get(0);
    }

    /** Admin answer: new status and a reply text. */
    public int updateReport(int id, String status, String adminReply) {
        String sql = "UPDATE info_report SET status=?, admin_reply=? WHERE id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, status);
            DaoUtil.setString(ps, 2, adminReply);
            ps.setInt(3, id);
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countOpen() {
        String sql = "SELECT COUNT(*) FROM info_report WHERE status='OPEN'";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private List<InfoReport> query(String sql, String status, int userId) {
        List<InfoReport> list = new ArrayList<>();
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            if (status != null) {
                ps.setString(1, status);
            } else if (userId > 0) {
                ps.setInt(1, userId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapReport(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private InfoReport mapReport(ResultSet rs) throws SQLException {
        return new InfoReport(
                rs.getInt("id"),
                rs.getInt("user_id"),
                rs.getInt("exam_id"),
                rs.getString("message"),
                rs.getString("status"),
                rs.getString("admin_reply"),
                DaoUtil.getLocalDateTime(rs, "created_at"),
                rs.getString("user_name"),
                rs.getString("exam_short_name")
        );
    }
}
