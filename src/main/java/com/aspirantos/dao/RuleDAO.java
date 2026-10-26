package com.aspirantos.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.AgeRule;
import com.aspirantos.model.AttemptRule;
import com.aspirantos.model.OtherRule;
import com.aspirantos.model.QualificationRule;
import com.aspirantos.model.RelaxationRule;
import com.aspirantos.util.DBConnection;

/**
 * Reads and edits the five rule tables of a rule version: age_rule, relaxation_rule,
 * attempt_rule, qualification_rule and other_rule.
 *
 * Rules of an ACTIVE or ARCHIVED version are never changed - every write checks that the
 * version is a DRAFT. Before an UPDATE, the DAO runs "SET @app_user_id = ?" on the same
 * connection, so the AFTER UPDATE triggers can write WHO changed WHAT into rule_change_log.
 * Inserts and deletes are logged by the DAO itself (triggers exist only for updates).
 */
public class RuleDAO {

    // ======================= READ =======================

    public List<AgeRule> getAgeRules(int versionId) {
        List<AgeRule> list = new ArrayList<>();
        String sql = "SELECT * FROM age_rule WHERE rule_version_id=? ORDER BY post_or_course IS NOT NULL, post_or_course, id";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, versionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapAgeRule(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<RelaxationRule> getRelaxationRules(int versionId) {
        List<RelaxationRule> list = new ArrayList<>();
        String sql = "SELECT * FROM relaxation_rule WHERE rule_version_id=? ORDER BY relaxation_type, category, id";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, versionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRelaxationRule(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<AttemptRule> getAttemptRules(int versionId) {
        List<AttemptRule> list = new ArrayList<>();
        String sql = "SELECT * FROM attempt_rule WHERE rule_version_id=? ORDER BY category IS NULL, category, id";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, versionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapAttemptRule(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<QualificationRule> getQualificationRules(int versionId) {
        List<QualificationRule> list = new ArrayList<>();
        String sql = "SELECT * FROM qualification_rule WHERE rule_version_id=? ORDER BY post_or_course IS NOT NULL, post_or_course, id";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, versionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapQualificationRule(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<OtherRule> getOtherRules(int versionId) {
        List<OtherRule> list = new ArrayList<>();
        String sql = "SELECT * FROM other_rule WHERE rule_version_id=? ORDER BY rule_type, id";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, versionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapOtherRule(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ======================= READ ALL ACTIVE (bulk) =======================
    // The dashboard checks every exam at once: one query per rule table for all ACTIVE
    // versions instead of five queries per exam. EligibilityService groups the rows by version.

    public List<AgeRule> getActiveAgeRules() {
        List<AgeRule> list = new ArrayList<>();
        String sql = "SELECT r.* FROM age_rule r JOIN exam e ON e.active_rule_version_id = r.rule_version_id "
                + "WHERE e.is_active ORDER BY r.rule_version_id, r.post_or_course IS NOT NULL, r.post_or_course, r.id";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                list.add(mapAgeRule(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<RelaxationRule> getActiveRelaxationRules() {
        List<RelaxationRule> list = new ArrayList<>();
        String sql = "SELECT r.* FROM relaxation_rule r JOIN exam e ON e.active_rule_version_id = r.rule_version_id "
                + "WHERE e.is_active ORDER BY r.rule_version_id, r.relaxation_type, r.category, r.id";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                list.add(mapRelaxationRule(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<AttemptRule> getActiveAttemptRules() {
        List<AttemptRule> list = new ArrayList<>();
        String sql = "SELECT r.* FROM attempt_rule r JOIN exam e ON e.active_rule_version_id = r.rule_version_id "
                + "WHERE e.is_active ORDER BY r.rule_version_id, r.category IS NULL, r.category, r.id";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                list.add(mapAttemptRule(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<QualificationRule> getActiveQualificationRules() {
        List<QualificationRule> list = new ArrayList<>();
        String sql = "SELECT r.* FROM qualification_rule r JOIN exam e ON e.active_rule_version_id = r.rule_version_id "
                + "WHERE e.is_active ORDER BY r.rule_version_id, r.post_or_course IS NOT NULL, r.post_or_course, r.id";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                list.add(mapQualificationRule(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<OtherRule> getActiveOtherRules() {
        List<OtherRule> list = new ArrayList<>();
        String sql = "SELECT r.* FROM other_rule r JOIN exam e ON e.active_rule_version_id = r.rule_version_id "
                + "WHERE e.is_active ORDER BY r.rule_version_id, r.rule_type, r.id";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                list.add(mapOtherRule(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ======================= AGE RULES (write) =======================

    public int insertAgeRule(AgeRule r, int adminId) {
        String sql = "INSERT INTO age_rule (rule_version_id, post_or_course, min_age, max_age, max_age_semantics, "
                + "cutoff_type, cutoff_month, cutoff_day, dob_from_offset_years, dob_from_month, dob_from_day, "
                + "dob_to_offset_years, dob_to_month, dob_to_day, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection()) {
            if (!isDraft(con, r.getRuleVersionId())) {
                return 0;
            }
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, r.getRuleVersionId());
                fillAge(ps, r, 2);
                int rows = ps.executeUpdate();
                logChange(con, r.getRuleVersionId(), "age_rule", "(new row)", null, describeAge(r), adminId);
                return rows;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int updateAgeRule(AgeRule r, int adminId) {
        String sql = "UPDATE age_rule SET post_or_course=?, min_age=?, max_age=?, max_age_semantics=?, cutoff_type=?, "
                + "cutoff_month=?, cutoff_day=?, dob_from_offset_years=?, dob_from_month=?, dob_from_day=?, "
                + "dob_to_offset_years=?, dob_to_month=?, dob_to_day=?, notes=? WHERE id=? AND rule_version_id=?";
        try (Connection con = DBConnection.getConnection()) {
            if (!isDraft(con, r.getRuleVersionId())) {
                return 0;
            }
            setActor(con, adminId);
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                int next = fillAge(ps, r, 1);
                ps.setInt(next, r.getId());
                ps.setInt(next + 1, r.getRuleVersionId());
                return ps.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int deleteAgeRule(int id, int versionId, int adminId) {
        return deleteRow("age_rule", id, versionId, adminId);
    }

    // ======================= RELAXATION RULES (write) =======================

    public int insertRelaxationRule(RelaxationRule r, int adminId) {
        String sql = "INSERT INTO relaxation_rule (rule_version_id, relaxation_type, category, years, stacking, "
                + "overall_max_age_cap, requires_state_domicile, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection()) {
            if (!isDraft(con, r.getRuleVersionId())) {
                return 0;
            }
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, r.getRuleVersionId());
                fillRelaxation(ps, r, 2);
                int rows = ps.executeUpdate();
                logChange(con, r.getRuleVersionId(), "relaxation_rule", "(new row)", null,
                        r.getRelaxationType() + " " + nz(r.getCategory()) + " +" + r.getYears(), adminId);
                return rows;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int updateRelaxationRule(RelaxationRule r, int adminId) {
        String sql = "UPDATE relaxation_rule SET relaxation_type=?, category=?, years=?, stacking=?, "
                + "overall_max_age_cap=?, requires_state_domicile=?, notes=? WHERE id=? AND rule_version_id=?";
        try (Connection con = DBConnection.getConnection()) {
            if (!isDraft(con, r.getRuleVersionId())) {
                return 0;
            }
            setActor(con, adminId);
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                int next = fillRelaxation(ps, r, 1);
                ps.setInt(next, r.getId());
                ps.setInt(next + 1, r.getRuleVersionId());
                return ps.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int deleteRelaxationRule(int id, int versionId, int adminId) {
        return deleteRow("relaxation_rule", id, versionId, adminId);
    }

    // ======================= ATTEMPT RULES (write) =======================

    public int insertAttemptRule(AttemptRule r, int adminId) {
        String sql = "INSERT INTO attempt_rule (rule_version_id, category, is_pwbd, max_attempts, counting_rule, "
                + "window_years, min_gap_days, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection()) {
            if (!isDraft(con, r.getRuleVersionId())) {
                return 0;
            }
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, r.getRuleVersionId());
                fillAttempt(ps, r, 2);
                int rows = ps.executeUpdate();
                logChange(con, r.getRuleVersionId(), "attempt_rule", "(new row)", null,
                        nz(r.getCategory()) + " max " + (r.getMaxAttempts() == null ? "unlimited" : r.getMaxAttempts()), adminId);
                return rows;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int updateAttemptRule(AttemptRule r, int adminId) {
        String sql = "UPDATE attempt_rule SET category=?, is_pwbd=?, max_attempts=?, counting_rule=?, "
                + "window_years=?, min_gap_days=?, notes=? WHERE id=? AND rule_version_id=?";
        try (Connection con = DBConnection.getConnection()) {
            if (!isDraft(con, r.getRuleVersionId())) {
                return 0;
            }
            setActor(con, adminId);
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                int next = fillAttempt(ps, r, 1);
                ps.setInt(next, r.getId());
                ps.setInt(next + 1, r.getRuleVersionId());
                return ps.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int deleteAttemptRule(int id, int versionId, int adminId) {
        return deleteRow("attempt_rule", id, versionId, adminId);
    }

    // ======================= QUALIFICATION RULES (write) =======================

    public int insertQualificationRule(QualificationRule r, int adminId) {
        String sql = "INSERT INTO qualification_rule (rule_version_id, post_or_course, required_level, accepted_degrees, "
                + "required_subjects, min_percent_general, min_percent_relaxed, relaxed_for, final_year_allowed, "
                + "max_years_since_passing, min_experience_years, text_summary) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection()) {
            if (!isDraft(con, r.getRuleVersionId())) {
                return 0;
            }
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, r.getRuleVersionId());
                fillQualification(ps, r, 2);
                int rows = ps.executeUpdate();
                logChange(con, r.getRuleVersionId(), "qualification_rule", "(new row)", null,
                        r.getRequiredLevel() + " " + nz(r.getAcceptedDegrees()), adminId);
                return rows;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int updateQualificationRule(QualificationRule r, int adminId) {
        String sql = "UPDATE qualification_rule SET post_or_course=?, required_level=?, accepted_degrees=?, "
                + "required_subjects=?, min_percent_general=?, min_percent_relaxed=?, relaxed_for=?, final_year_allowed=?, "
                + "max_years_since_passing=?, min_experience_years=?, text_summary=? WHERE id=? AND rule_version_id=?";
        try (Connection con = DBConnection.getConnection()) {
            if (!isDraft(con, r.getRuleVersionId())) {
                return 0;
            }
            setActor(con, adminId);
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                int next = fillQualification(ps, r, 1);
                ps.setInt(next, r.getId());
                ps.setInt(next + 1, r.getRuleVersionId());
                return ps.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int deleteQualificationRule(int id, int versionId, int adminId) {
        return deleteRow("qualification_rule", id, versionId, adminId);
    }

    // ======================= OTHER RULES (write) =======================

    public int insertOtherRule(OtherRule r, int adminId) {
        String sql = "INSERT INTO other_rule (rule_version_id, post_or_course, rule_type, rule_value, is_blocking, text_summary) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection()) {
            if (!isDraft(con, r.getRuleVersionId())) {
                return 0;
            }
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, r.getRuleVersionId());
                DaoUtil.setString(ps, 2, r.getPostOrCourse());
                ps.setString(3, r.getRuleType());
                DaoUtil.setString(ps, 4, r.getRuleValue());
                ps.setBoolean(5, r.isBlocking());
                DaoUtil.setString(ps, 6, r.getTextSummary());
                int rows = ps.executeUpdate();
                logChange(con, r.getRuleVersionId(), "other_rule", "(new row)", null,
                        r.getRuleType() + " " + nz(r.getRuleValue()), adminId);
                return rows;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** other_rule has no UPDATE trigger, so the old and new values are logged here. */
    public int updateOtherRule(OtherRule r, int adminId) {
        String sql = "UPDATE other_rule SET post_or_course=?, rule_type=?, rule_value=?, is_blocking=?, text_summary=? "
                + "WHERE id=? AND rule_version_id=?";
        try (Connection con = DBConnection.getConnection()) {
            if (!isDraft(con, r.getRuleVersionId())) {
                return 0;
            }
            String old = null;
            try (PreparedStatement ps = con.prepareStatement("SELECT rule_type, rule_value, is_blocking FROM other_rule WHERE id=?")) {
                ps.setInt(1, r.getId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        old = rs.getString(1) + " " + nz(rs.getString(2)) + (rs.getBoolean(3) ? " (blocking)" : "");
                    }
                }
            }
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                DaoUtil.setString(ps, 1, r.getPostOrCourse());
                ps.setString(2, r.getRuleType());
                DaoUtil.setString(ps, 3, r.getRuleValue());
                ps.setBoolean(4, r.isBlocking());
                DaoUtil.setString(ps, 5, r.getTextSummary());
                ps.setInt(6, r.getId());
                ps.setInt(7, r.getRuleVersionId());
                int rows = ps.executeUpdate();
                String now = r.getRuleType() + " " + nz(r.getRuleValue()) + (r.isBlocking() ? " (blocking)" : "");
                if (rows > 0 && !now.equals(old)) {
                    logChange(con, r.getRuleVersionId(), "other_rule", "rule", old, now, adminId);
                }
                return rows;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int deleteOtherRule(int id, int versionId, int adminId) {
        return deleteRow("other_rule", id, versionId, adminId);
    }

    // ======================= helpers =======================

    /** True when the version exists and is a DRAFT (only drafts may be edited). */
    private AgeRule mapAgeRule(ResultSet rs) throws SQLException {
        return new AgeRule(
                rs.getInt("id"),
                rs.getInt("rule_version_id"),
                rs.getString("post_or_course"),
                DaoUtil.getInteger(rs, "min_age"),
                DaoUtil.getInteger(rs, "max_age"),
                rs.getString("max_age_semantics"),
                rs.getString("cutoff_type"),
                DaoUtil.getInteger(rs, "cutoff_month"),
                DaoUtil.getInteger(rs, "cutoff_day"),
                DaoUtil.getInteger(rs, "dob_from_offset_years"),
                DaoUtil.getInteger(rs, "dob_from_month"),
                DaoUtil.getInteger(rs, "dob_from_day"),
                DaoUtil.getInteger(rs, "dob_to_offset_years"),
                DaoUtil.getInteger(rs, "dob_to_month"),
                DaoUtil.getInteger(rs, "dob_to_day"),
                rs.getString("notes"));
    }

    private RelaxationRule mapRelaxationRule(ResultSet rs) throws SQLException {
        return new RelaxationRule(
                rs.getInt("id"),
                rs.getInt("rule_version_id"),
                rs.getString("relaxation_type"),
                rs.getString("category"),
                rs.getInt("years"),
                rs.getString("stacking"),
                DaoUtil.getInteger(rs, "overall_max_age_cap"),
                rs.getBoolean("requires_state_domicile"),
                rs.getString("notes"));
    }

    private AttemptRule mapAttemptRule(ResultSet rs) throws SQLException {
        return new AttemptRule(
                rs.getInt("id"),
                rs.getInt("rule_version_id"),
                rs.getString("category"),
                DaoUtil.getBooleanOrNull(rs, "is_pwbd"),
                DaoUtil.getInteger(rs, "max_attempts"),
                rs.getString("counting_rule"),
                DaoUtil.getInteger(rs, "window_years"),
                DaoUtil.getInteger(rs, "min_gap_days"),
                rs.getString("notes"));
    }

    private QualificationRule mapQualificationRule(ResultSet rs) throws SQLException {
        return new QualificationRule(
                rs.getInt("id"),
                rs.getInt("rule_version_id"),
                rs.getString("post_or_course"),
                rs.getString("required_level"),
                rs.getString("accepted_degrees"),
                rs.getString("required_subjects"),
                DaoUtil.getDouble(rs, "min_percent_general"),
                DaoUtil.getDouble(rs, "min_percent_relaxed"),
                rs.getString("relaxed_for"),
                rs.getBoolean("final_year_allowed"),
                DaoUtil.getInteger(rs, "max_years_since_passing"),
                DaoUtil.getDouble(rs, "min_experience_years"),
                rs.getString("text_summary"));
    }

    private OtherRule mapOtherRule(ResultSet rs) throws SQLException {
        return new OtherRule(
                rs.getInt("id"),
                rs.getInt("rule_version_id"),
                rs.getString("post_or_course"),
                rs.getString("rule_type"),
                rs.getString("rule_value"),
                rs.getBoolean("is_blocking"),
                rs.getString("text_summary"));
    }

    private boolean isDraft(Connection con, int versionId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("SELECT status FROM exam_rule_version WHERE id=?")) {
            ps.setInt(1, versionId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && "DRAFT".equals(rs.getString(1));
            }
        }
    }

    /** Tells the AFTER UPDATE triggers who is editing (session variables of this connection). */
    private void setActor(Connection con, int adminId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("SET @app_user_id = ?, @rule_change_source = 'ADMIN_EDIT'")) {
            ps.setInt(1, adminId);
            ps.executeUpdate();
        }
    }

    private void logChange(Connection con, int versionId, String table, String column,
                           String oldValue, String newValue, int adminId) throws SQLException {
        String sql = "INSERT INTO rule_change_log (exam_id, rule_version_id, table_name, column_name, old_value, "
                + "new_value, change_source, changed_by) "
                + "SELECT exam_id, id, ?, ?, ?, ?, 'ADMIN_EDIT', ? FROM exam_rule_version WHERE id=?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, table);
            ps.setString(2, column);
            DaoUtil.setString(ps, 3, oldValue);
            DaoUtil.setString(ps, 4, newValue);
            ps.setInt(5, adminId);
            ps.setInt(6, versionId);
            ps.executeUpdate();
        }
    }

    /** Deletes one rule row of a DRAFT. The table name comes from the methods above, never from the user. */
    private int deleteRow(String table, int id, int versionId, int adminId) {
        String sql = "DELETE FROM " + table + " WHERE id=? AND rule_version_id=?";
        try (Connection con = DBConnection.getConnection()) {
            if (!isDraft(con, versionId)) {
                return 0;
            }
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, id);
                ps.setInt(2, versionId);
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    logChange(con, versionId, table, "(row deleted)", "row " + id, null, adminId);
                }
                return rows;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private int fillAge(PreparedStatement ps, AgeRule r, int i) throws SQLException {
        DaoUtil.setString(ps, i++, r.getPostOrCourse());
        DaoUtil.setInt(ps, i++, r.getMinAge());
        DaoUtil.setInt(ps, i++, r.getMaxAge());
        ps.setString(i++, r.getMaxAgeSemantics() == null ? "NOT_ATTAINED" : r.getMaxAgeSemantics());
        ps.setString(i++, r.getCutoffType());
        DaoUtil.setInt(ps, i++, r.getCutoffMonth());
        DaoUtil.setInt(ps, i++, r.getCutoffDay());
        DaoUtil.setInt(ps, i++, r.getDobFromOffsetYears());
        DaoUtil.setInt(ps, i++, r.getDobFromMonth());
        DaoUtil.setInt(ps, i++, r.getDobFromDay());
        DaoUtil.setInt(ps, i++, r.getDobToOffsetYears());
        DaoUtil.setInt(ps, i++, r.getDobToMonth());
        DaoUtil.setInt(ps, i++, r.getDobToDay());
        DaoUtil.setString(ps, i++, r.getNotes());
        return i;
    }

    private int fillRelaxation(PreparedStatement ps, RelaxationRule r, int i) throws SQLException {
        ps.setString(i++, r.getRelaxationType());
        DaoUtil.setString(ps, i++, r.getCategory());
        ps.setInt(i++, r.getYears());
        ps.setString(i++, r.getStacking() == null ? "ADD" : r.getStacking());
        DaoUtil.setInt(ps, i++, r.getOverallMaxAgeCap());
        ps.setBoolean(i++, r.isRequiresStateDomicile());
        DaoUtil.setString(ps, i++, r.getNotes());
        return i;
    }

    private int fillAttempt(PreparedStatement ps, AttemptRule r, int i) throws SQLException {
        DaoUtil.setString(ps, i++, r.getCategory());
        DaoUtil.setBoolean(ps, i++, r.getPwbd());
        DaoUtil.setInt(ps, i++, r.getMaxAttempts());
        ps.setString(i++, r.getCountingRule());
        DaoUtil.setInt(ps, i++, r.getWindowYears());
        DaoUtil.setInt(ps, i++, r.getMinGapDays());
        DaoUtil.setString(ps, i++, r.getNotes());
        return i;
    }

    private int fillQualification(PreparedStatement ps, QualificationRule r, int i) throws SQLException {
        DaoUtil.setString(ps, i++, r.getPostOrCourse());
        ps.setString(i++, r.getRequiredLevel());
        ps.setString(i++, r.getAcceptedDegrees() == null || r.getAcceptedDegrees().trim().isEmpty() ? "ANY" : r.getAcceptedDegrees().trim());
        DaoUtil.setString(ps, i++, r.getRequiredSubjects());
        DaoUtil.setDouble(ps, i++, r.getMinPercentGeneral());
        DaoUtil.setDouble(ps, i++, r.getMinPercentRelaxed());
        DaoUtil.setString(ps, i++, r.getRelaxedFor());
        ps.setBoolean(i++, r.isFinalYearAllowed());
        DaoUtil.setInt(ps, i++, r.getMaxYearsSincePassing());
        DaoUtil.setDouble(ps, i++, r.getMinExperienceYears());
        DaoUtil.setString(ps, i++, r.getTextSummary());
        return i;
    }

    private String describeAge(AgeRule r) {
        return nz(r.getPostOrCourse()) + " " + (r.getMinAge() == null ? "" : r.getMinAge()) + "-"
                + (r.getMaxAge() == null ? "no limit" : r.getMaxAge()) + " " + r.getCutoffType();
    }

    private String nz(String s) {
        return s == null ? "" : s;
    }
}
