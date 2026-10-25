package com.aspirantos.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.RuleChange;
import com.aspirantos.model.UpdateCheck;
import com.aspirantos.util.DBConnection;

/**
 * "Check for updates" results (table exam_update_check) and the rule change history
 * (table rule_change_log) shown on the admin pages and the Rule History tab.
 */
public class UpdateCheckDAO {

    public int insertCheck(UpdateCheck c) {
        String sql = "INSERT INTO exam_update_check (exam_id, checked_by, url_checked, http_status, content_sha256, "
                + "changed_since_last, keyword_hits, error_message) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, c.getExamId());
            DaoUtil.setInt(ps, 2, c.getCheckedBy());
            ps.setString(3, c.getUrlChecked());
            DaoUtil.setInt(ps, 4, c.getHttpStatus());
            DaoUtil.setString(ps, 5, c.getContentSha256());
            DaoUtil.setBoolean(ps, 6, c.getChangedSinceLast());
            DaoUtil.setString(ps, 7, c.getKeywordHits());
            DaoUtil.setString(ps, 8, c.getErrorMessage());
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** The newest check of an exam that reached the page (has a hash), or null. */
    public UpdateCheck getLastSuccessfulCheck(int examId) {
        List<UpdateCheck> list = checks("SELECT * FROM exam_update_check WHERE exam_id=? AND content_sha256 IS NOT NULL "
                + "ORDER BY checked_at DESC, id DESC LIMIT 1", examId, 1);
        return list.isEmpty() ? null : list.get(0);
    }

    public List<UpdateCheck> getChecksByExam(int examId, int limit) {
        return checks("SELECT * FROM exam_update_check WHERE exam_id=? ORDER BY checked_at DESC, id DESC LIMIT ?", examId, limit);
    }

    public List<UpdateCheck> getRecentChecks(int limit) {
        return checks("SELECT * FROM exam_update_check ORDER BY checked_at DESC, id DESC LIMIT ?", 0, limit);
    }

    /** Rule changes of an exam, newest first (with the admin's name). */
    public List<RuleChange> getChangesByExam(int examId, int limit) {
        List<RuleChange> list = new ArrayList<>();
        String sql = "SELECT l.*, u.full_name AS changed_by_name FROM rule_change_log l "
                + "LEFT JOIN app_user u ON u.id = l.changed_by WHERE l.exam_id=? "
                + "ORDER BY l.changed_at DESC, l.id DESC LIMIT ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, examId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new RuleChange(
                            rs.getInt("id"),
                            rs.getInt("exam_id"),
                            DaoUtil.getInteger(rs, "rule_version_id"),
                            rs.getString("table_name"),
                            rs.getString("column_name"),
                            rs.getString("old_value"),
                            rs.getString("new_value"),
                            rs.getString("change_source"),
                            DaoUtil.getInteger(rs, "changed_by"),
                            rs.getString("changed_by_name"),
                            DaoUtil.getLocalDateTime(rs, "changed_at")));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private List<UpdateCheck> checks(String sql, int examId, int limit) {
        List<UpdateCheck> list = new ArrayList<>();
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            int i = 1;
            if (examId > 0) {
                ps.setInt(i++, examId);
            }
            if (sql.endsWith("LIMIT ?")) {
                ps.setInt(i, limit);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapCheck(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private UpdateCheck mapCheck(ResultSet rs) throws SQLException {
        return new UpdateCheck(
                rs.getInt("id"),
                rs.getInt("exam_id"),
                DaoUtil.getInteger(rs, "checked_by"),
                DaoUtil.getLocalDateTime(rs, "checked_at"),
                rs.getString("url_checked"),
                DaoUtil.getInteger(rs, "http_status"),
                rs.getString("content_sha256"),
                DaoUtil.getBooleanOrNull(rs, "changed_since_last"),
                rs.getString("keyword_hits"),
                rs.getString("error_message")
        );
    }
}
