package com.aspirantos.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.LinkedHashMap;
import java.util.Map;

import com.aspirantos.engine.ExamRuleSet;
import com.aspirantos.model.AgeRule;
import com.aspirantos.model.AttemptRule;
import com.aspirantos.model.Exam;
import com.aspirantos.model.OtherRule;
import com.aspirantos.model.QualificationRule;
import com.aspirantos.model.RelaxationRule;
import com.aspirantos.util.DBConnection;

/**
 * Applies an imported rule pack: for every exam in the pack a new rule version is created with
 * exactly the pack's rows and made ACTIVE - all exams in ONE JDBC transaction
 * (setAutoCommit(false) ... commit(), rollback() on any error), so a pack is applied
 * completely or not at all.
 *
 * The activation steps are the same as in sp_activate_rule_version (archive the old version,
 * activate the new one, log it, notify the students who track the exam, delete their cached
 * results). They are written here in Java because a stored procedure with its own
 * START TRANSACTION would commit the surrounding transaction.
 */
public class RulePackDAO {

    /** Returns examCode -> number of students notified; throws when the pack was rolled back. */
    public Map<String, Integer> applyPack(Map<String, ExamRuleSet> pack, String summary, String sourceUrl,
                                          Integer appliesFrom, int adminId) throws SQLException {
        Map<String, Integer> notified = new LinkedHashMap<>();
        Connection con = DBConnection.getConnection();
        try {
            con.setAutoCommit(false);
            for (Map.Entry<String, ExamRuleSet> e : pack.entrySet()) {
                Exam exam = e.getValue().getExam();
                if (hasDraft(con, exam.getId())) {
                    throw new SQLException(exam.getShortName() + " has an open draft - publish or discard it first.");
                }
                int versionId = insertVersion(con, exam.getId(), summary, sourceUrl, appliesFrom, adminId);
                insertRows(con, versionId, e.getValue());
                notified.put(e.getKey(), activate(con, exam, versionId, adminId));
            }
            con.commit();
            return notified;
        } catch (SQLException ex) {
            con.rollback();
            throw ex;
        } finally {
            con.setAutoCommit(true);
            con.close();
        }
    }

    private boolean hasDraft(Connection con, int examId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM exam_rule_version WHERE exam_id=? AND status='DRAFT'")) {
            ps.setInt(1, examId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1) > 0;
            }
        }
    }

    private int insertVersion(Connection con, int examId, String summary, String sourceUrl, Integer appliesFrom, int adminId) throws SQLException {
        String sql = "INSERT INTO exam_rule_version (exam_id, version_no, applies_from_cycle_year, status, change_summary, source_url, created_by) "
                + "SELECT ?, COALESCE(MAX(version_no), 0) + 1, ?, 'DRAFT', ?, ?, ? FROM exam_rule_version WHERE exam_id=?";
        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, examId);
            DaoUtil.setInt(ps, 2, appliesFrom);
            ps.setString(3, summary);
            DaoUtil.setString(ps, 4, sourceUrl);
            ps.setInt(5, adminId);
            ps.setInt(6, examId);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                keys.next();
                return keys.getInt(1);
            }
        }
    }

    private void insertRows(Connection con, int v, ExamRuleSet rs) throws SQLException {
        String ageSql = "INSERT INTO age_rule (rule_version_id, post_or_course, min_age, max_age, max_age_semantics, cutoff_type, "
                + "cutoff_month, cutoff_day, dob_from_offset_years, dob_from_month, dob_from_day, dob_to_offset_years, "
                + "dob_to_month, dob_to_day, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(ageSql)) {
            for (AgeRule r : rs.getAgeRules()) {
                ps.setInt(1, v);
                DaoUtil.setString(ps, 2, r.getPostOrCourse());
                DaoUtil.setInt(ps, 3, r.getMinAge());
                DaoUtil.setInt(ps, 4, r.getMaxAge());
                ps.setString(5, r.getMaxAgeSemantics());
                ps.setString(6, r.getCutoffType());
                DaoUtil.setInt(ps, 7, r.getCutoffMonth());
                DaoUtil.setInt(ps, 8, r.getCutoffDay());
                DaoUtil.setInt(ps, 9, r.getDobFromOffsetYears());
                DaoUtil.setInt(ps, 10, r.getDobFromMonth());
                DaoUtil.setInt(ps, 11, r.getDobFromDay());
                DaoUtil.setInt(ps, 12, r.getDobToOffsetYears());
                DaoUtil.setInt(ps, 13, r.getDobToMonth());
                DaoUtil.setInt(ps, 14, r.getDobToDay());
                DaoUtil.setString(ps, 15, r.getNotes());
                ps.executeUpdate();
            }
        }
        String relaxSql = "INSERT INTO relaxation_rule (rule_version_id, relaxation_type, category, years, stacking, "
                + "overall_max_age_cap, requires_state_domicile, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(relaxSql)) {
            for (RelaxationRule r : rs.getRelaxationRules()) {
                ps.setInt(1, v);
                ps.setString(2, r.getRelaxationType());
                DaoUtil.setString(ps, 3, r.getCategory());
                ps.setInt(4, r.getYears());
                ps.setString(5, r.getStacking());
                DaoUtil.setInt(ps, 6, r.getOverallMaxAgeCap());
                ps.setBoolean(7, r.isRequiresStateDomicile());
                DaoUtil.setString(ps, 8, r.getNotes());
                ps.executeUpdate();
            }
        }
        String attemptSql = "INSERT INTO attempt_rule (rule_version_id, category, is_pwbd, max_attempts, counting_rule, "
                + "window_years, min_gap_days, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(attemptSql)) {
            for (AttemptRule r : rs.getAttemptRules()) {
                ps.setInt(1, v);
                DaoUtil.setString(ps, 2, r.getCategory());
                DaoUtil.setBoolean(ps, 3, r.getPwbd());
                DaoUtil.setInt(ps, 4, r.getMaxAttempts());
                ps.setString(5, r.getCountingRule());
                DaoUtil.setInt(ps, 6, r.getWindowYears());
                DaoUtil.setInt(ps, 7, r.getMinGapDays());
                DaoUtil.setString(ps, 8, r.getNotes());
                ps.executeUpdate();
            }
        }
        String qualSql = "INSERT INTO qualification_rule (rule_version_id, post_or_course, required_level, accepted_degrees, "
                + "required_subjects, min_percent_general, min_percent_relaxed, relaxed_for, final_year_allowed, "
                + "max_years_since_passing, min_experience_years, text_summary) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(qualSql)) {
            for (QualificationRule r : rs.getQualificationRules()) {
                ps.setInt(1, v);
                DaoUtil.setString(ps, 2, r.getPostOrCourse());
                ps.setString(3, r.getRequiredLevel());
                ps.setString(4, r.getAcceptedDegrees() == null ? "ANY" : r.getAcceptedDegrees());
                DaoUtil.setString(ps, 5, r.getRequiredSubjects());
                DaoUtil.setDouble(ps, 6, r.getMinPercentGeneral());
                DaoUtil.setDouble(ps, 7, r.getMinPercentRelaxed());
                DaoUtil.setString(ps, 8, r.getRelaxedFor());
                ps.setBoolean(9, r.isFinalYearAllowed());
                DaoUtil.setInt(ps, 10, r.getMaxYearsSincePassing());
                DaoUtil.setDouble(ps, 11, r.getMinExperienceYears());
                DaoUtil.setString(ps, 12, r.getTextSummary());
                ps.executeUpdate();
            }
        }
        String otherSql = "INSERT INTO other_rule (rule_version_id, post_or_course, rule_type, rule_value, is_blocking, text_summary) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(otherSql)) {
            for (OtherRule r : rs.getOtherRules()) {
                ps.setInt(1, v);
                DaoUtil.setString(ps, 2, r.getPostOrCourse());
                ps.setString(3, r.getRuleType());
                DaoUtil.setString(ps, 4, r.getRuleValue());
                ps.setBoolean(5, r.isBlocking());
                DaoUtil.setString(ps, 6, r.getTextSummary());
                ps.executeUpdate();
            }
        }
    }

    /** Same steps as sp_activate_rule_version, inside the caller's transaction. Returns students notified. */
    private int activate(Connection con, Exam exam, int versionId, int adminId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("UPDATE exam_rule_version SET status='ARCHIVED' WHERE exam_id=? AND status='ACTIVE'")) {
            ps.setInt(1, exam.getId());
            ps.executeUpdate();
        }
        try (PreparedStatement ps = con.prepareStatement("UPDATE exam_rule_version SET status='ACTIVE', activated_at=NOW() WHERE id=?")) {
            ps.setInt(1, versionId);
            ps.executeUpdate();
        }
        try (PreparedStatement ps = con.prepareStatement("UPDATE exam SET active_rule_version_id=? WHERE id=?")) {
            ps.setInt(1, versionId);
            ps.setInt(2, exam.getId());
            ps.executeUpdate();
        }
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO rule_change_log (exam_id, rule_version_id, table_name, column_name, old_value, new_value, change_source, changed_by) "
                + "SELECT exam_id, id, 'exam_rule_version', 'status', NULL, CONCAT('v', version_no, ' ACTIVE (rule pack)'), 'CSV_IMPORT', ? "
                + "FROM exam_rule_version WHERE id=?")) {
            ps.setInt(1, adminId);
            ps.setInt(2, versionId);
            ps.executeUpdate();
        }
        int notified;
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO notification (user_id, title, message, link_url) "
                + "SELECT t.user_id, CONCAT(?, ' rules updated'), "
                + "CONCAT(?, ' eligibility rules were updated on ', DATE_FORMAT(NOW(), '%d-%b-%Y'), ' - your result has been recalculated.'), "
                + "CONCAT('aspirant/exam-detail.jsp?id=', ?) FROM user_exam_tracking t WHERE t.exam_id=?")) {
            ps.setString(1, exam.getShortName());
            ps.setString(2, exam.getShortName());
            ps.setInt(3, exam.getId());
            ps.setInt(4, exam.getId());
            notified = ps.executeUpdate();
        }
        try (PreparedStatement ps = con.prepareStatement("DELETE FROM eligibility_snapshot WHERE exam_id=?")) {
            ps.setInt(1, exam.getId());
            ps.executeUpdate();
        }
        return notified;
    }
}
