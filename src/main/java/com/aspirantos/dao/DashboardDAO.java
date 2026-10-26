package com.aspirantos.dao;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.aspirantos.model.DashboardSummary;
import com.aspirantos.util.DBConnection;

/**
 * Dashboard and analytics numbers read from stored procedures through CallableStatement
 * (con.prepareCall("{call ...}") - the third statement type of the JDBC notes, after
 * Statement and PreparedStatement).
 */
public class DashboardDAO {

    /** Counters of one student from sp_user_dashboard_summary(IN p_user). */
    public DashboardSummary getSummary(int userId) {
        DashboardSummary summary = new DashboardSummary();
        String sql = "{call sp_user_dashboard_summary(?)}";
        try (
            Connection con = DBConnection.getConnection();
            CallableStatement cs = con.prepareCall(sql)
        ) {
            cs.setInt(1, userId);
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    summary.setEligibleNow(rs.getInt("eligible_now"));
                    summary.setProvisional(rs.getInt("provisional"));
                    summary.setClosingSoon(rs.getInt("closing_soon"));
                    summary.setNotYet(rs.getInt("not_yet"));
                    summary.setNotEligible(rs.getInt("not_eligible"));
                    summary.setTrackedExams(rs.getInt("tracked_exams"));
                    summary.setUnreadNotifications(rs.getInt("unread_notifications"));
                    summary.setExamsChecked(rs.getInt("exams_checked"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return summary;
    }

    /**
     * Admin analytics from sp_category_report(): each row is {dimension, value, students},
     * e.g. {"CATEGORY", "OBC_NCL", "12"}.
     */
    public List<String[]> getCategoryReport() {
        List<String[]> rows = new ArrayList<>();
        String sql = "{call sp_category_report()}";
        try (
            Connection con = DBConnection.getConnection();
            CallableStatement cs = con.prepareCall(sql);
            ResultSet rs = cs.executeQuery()
        ) {
            while (rs.next()) {
                rows.add(new String[] {
                        rs.getString("dimension"),
                        rs.getString("dimension_value"),
                        String.valueOf(rs.getInt("students"))
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return rows;
    }

    /**
     * "System information" card of the admin dashboard, read from DatabaseMetaData:
     * which JDBC driver (Type 4, MySQL Connector/J) and which database the app uses.
     */
    public Map<String, String> getSystemInfo() {
        Map<String, String> info = new LinkedHashMap<>();
        try (Connection con = DBConnection.getConnection()) {
            DatabaseMetaData md = con.getMetaData();
            info.put("Database", md.getDatabaseProductName() + " " + md.getDatabaseProductVersion());
            info.put("JDBC driver", md.getDriverName() + " " + md.getDriverVersion());
            info.put("JDBC version", md.getJDBCMajorVersion() + "." + md.getJDBCMinorVersion());
            info.put("Connection URL", md.getURL());
            info.put("Database user", md.getUserName());
            info.put("Stored procedures supported", md.supportsStoredProcedures() ? "Yes" : "No");
            info.put("Batch updates supported", md.supportsBatchUpdates() ? "Yes" : "No");
        } catch (Exception e) {
            e.printStackTrace();
            info.put("Database", "not reachable: " + e.getMessage());
        }
        return info;
    }
}
