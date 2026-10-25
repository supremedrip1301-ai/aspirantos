package com.aspirantos.dao;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.RuleVersion;
import com.aspirantos.util.DBConnection;

/**
 * Rule versions of an exam (table exam_rule_version, read through the view v_rule_history).
 * Cloning and publishing call stored procedures with CallableStatement:
 *   {call sp_clone_rule_version(?, ?, ?)}   - IN exam, IN admin, OUT new version id
 *   {call sp_activate_rule_version(?, ?)}   - one transaction inside MySQL
 */
public class RuleVersionDAO {

    private static final String SELECT =
            "SELECT rule_version_id AS id, exam_id, version_no, applies_from_cycle_year, status, change_summary, "
            + "source_url, created_by_name, created_at, activated_at, change_count, "
            + "(SELECT created_by FROM exam_rule_version v WHERE v.id = h.rule_version_id) AS created_by "
            + "FROM v_rule_history h ";

    /** All versions of an exam, newest first (Rule History tab). */
    public List<RuleVersion> getVersionsByExam(int examId) {
        List<RuleVersion> list = new ArrayList<>();
        String sql = SELECT + "WHERE exam_id=? ORDER BY version_no DESC";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, examId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapVersion(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public RuleVersion getVersion(int versionId) {
        String sql = SELECT + "WHERE rule_version_id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, versionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapVersion(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** The DRAFT of an exam, or null when there is none. */
    public RuleVersion getDraft(int examId) {
        String sql = SELECT + "WHERE exam_id=? AND status='DRAFT' ORDER BY version_no DESC LIMIT 1";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, examId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapVersion(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * "Update rules": copies the ACTIVE version with all its rule rows into a DRAFT (or returns
     * the existing draft). Uses CallableStatement with an OUT parameter.
     * Returns the draft's id, or 0 on error.
     */
    public int cloneActiveVersion(int examId, int adminId) {
        String sql = "{call sp_clone_rule_version(?, ?, ?)}";
        try (
            Connection con = DBConnection.getConnection();
            CallableStatement cs = con.prepareCall(sql)
        ) {
            cs.setInt(1, examId);
            cs.setInt(2, adminId);
            cs.registerOutParameter(3, Types.INTEGER);
            cs.execute();
            return cs.getInt(3);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * "Publish": activates the version, archives the old one, logs the change, notifies every
     * student who tracks the exam and clears their cached results (one MySQL transaction).
     * Returns the number of students notified, or -1 on error.
     */
    public int activateVersion(int versionId, int adminId) {
        String sql = "{call sp_activate_rule_version(?, ?)}";
        try (
            Connection con = DBConnection.getConnection();
            CallableStatement cs = con.prepareCall(sql)
        ) {
            cs.setInt(1, versionId);
            cs.setInt(2, adminId);
            boolean hasResult = cs.execute();
            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    if (rs.next()) {
                        return rs.getInt("users_notified");
                    }
                }
            }
            return 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /** Edits the summary / source / first cycle year of a DRAFT. */
    public int updateDraftInfo(int versionId, String changeSummary, String sourceUrl, Integer appliesFromCycleYear) {
        String sql = "UPDATE exam_rule_version SET change_summary=?, source_url=?, applies_from_cycle_year=? "
                + "WHERE id=? AND status='DRAFT'";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            DaoUtil.setString(ps, 1, changeSummary);
            DaoUtil.setString(ps, 2, sourceUrl);
            DaoUtil.setInt(ps, 3, appliesFromCycleYear);
            ps.setInt(4, versionId);
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Throws a DRAFT away (its rule rows go with ON DELETE CASCADE). Active / archived versions stay. */
    public int deleteDraft(int versionId) {
        String sql = "DELETE FROM exam_rule_version WHERE id=? AND status='DRAFT'";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, versionId);
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private RuleVersion mapVersion(ResultSet rs) throws SQLException {
        return new RuleVersion(
                rs.getInt("id"),
                rs.getInt("exam_id"),
                rs.getInt("version_no"),
                DaoUtil.getInteger(rs, "applies_from_cycle_year"),
                rs.getString("status"),
                rs.getString("change_summary"),
                rs.getString("source_url"),
                DaoUtil.getInteger(rs, "created_by"),
                rs.getString("created_by_name"),
                DaoUtil.getLocalDateTime(rs, "created_at"),
                DaoUtil.getLocalDateTime(rs, "activated_at"),
                rs.getInt("change_count")
        );
    }
}
