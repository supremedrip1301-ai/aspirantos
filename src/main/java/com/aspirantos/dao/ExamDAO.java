package com.aspirantos.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.Exam;
import com.aspirantos.model.ExamFilter;
import com.aspirantos.util.DBConnection;

/**
 * JDBC access to the exam catalogue (table exam, joined with its category and body).
 * searchExams() builds the WHERE clause from the Explorer filters, but every value still goes
 * through a "?" placeholder of a PreparedStatement, and the ORDER BY comes from a fixed list,
 * so a user can never inject SQL.
 */
public class ExamDAO {

    private static final String SELECT =
            "SELECT e.*, c.code AS category_code, c.name AS category_name, b.short_name AS body_short_name "
            + "FROM exam e JOIN exam_category c ON c.id = e.category_id JOIN conducting_body b ON b.id = e.body_id ";

    // READ ALL active exams (by category, then name)
    public List<Exam> getAllExams() {
        return list(SELECT + "WHERE e.is_active ORDER BY c.sort_order, e.name", null);
    }

    public List<Exam> getExamsByCategory(int categoryId) {
        return list(SELECT + "WHERE e.is_active AND e.category_id=? ORDER BY e.name", categoryId);
    }

    // READ ONE EXAM
    public Exam getExam(int id) {
        List<Exam> found = list(SELECT + "WHERE e.id=?", id);
        return found.isEmpty() ? null : found.get(0);
    }

    public Exam getExamByCode(String code) {
        String sql = SELECT + "WHERE e.code=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapExam(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** One page of the Explorer result list. */
    public List<Exam> searchExams(ExamFilter f) {
        List<Object> params = new ArrayList<>();
        String sql = SELECT + buildWhere(f, params) + " ORDER BY " + orderBy(f.getSort()) + " LIMIT ? OFFSET ?";
        params.add(f.getPageSize());
        params.add((Math.max(f.getPage(), 1) - 1) * f.getPageSize());
        List<Exam> exams = new ArrayList<>();
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            bind(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    exams.add(mapExam(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return exams;
    }

    /** Total number of exams matching the filters (for "Page 2 of 9"). */
    public int countExams(ExamFilter f) {
        List<Object> params = new ArrayList<>();
        String sql = "SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id "
                + "JOIN conducting_body b ON b.id = e.body_id " + buildWhere(f, params);
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            bind(ps, params);
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

    // CREATE (admin) - the exam starts without rules; the admin then creates version 1
    public int insertExam(Exam x) {
        String sql = "INSERT INTO exam (code, name, short_name, category_id, body_id, scope, state_code, sector, purpose, "
                + "cycles_per_year, typical_notification_month, typical_exam_month, stages_summary, posts_or_courses, "
                + "official_url, watch_url, description, fee_summary, attempt_counting_note, data_confidence, "
                + "last_verified_on, source_note, is_active) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
        ) {
            ps.setString(1, x.getCode().trim().toUpperCase());
            int next = fillFields(ps, x, 2);
            ps.setBoolean(next, x.isActive());
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

    // UPDATE (admin) - the code is the natural key and is not changed
    public int updateExam(Exam x) {
        String sql = "UPDATE exam SET name=?, short_name=?, category_id=?, body_id=?, scope=?, state_code=?, sector=?, "
                + "purpose=?, cycles_per_year=?, typical_notification_month=?, typical_exam_month=?, stages_summary=?, "
                + "posts_or_courses=?, official_url=?, watch_url=?, description=?, fee_summary=?, "
                + "attempt_counting_note=?, data_confidence=?, last_verified_on=?, source_note=?, is_active=? WHERE id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            int next = fillFields(ps, x, 1);
            ps.setBoolean(next, x.isActive());
            ps.setInt(next + 1, x.getId());
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** "Delete" for the admin = deactivate; history and student data stay intact. */
    public int setExamActive(int id, boolean active) {
        String sql = "UPDATE exam SET is_active=? WHERE id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setBoolean(1, active);
            ps.setInt(2, id);
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** {total, verified, likely, needsVerification} for the admin dashboard. */
    public int[] getConfidenceCounts() {
        int[] counts = new int[4];
        String sql = "SELECT COUNT(*) AS total, SUM(data_confidence='VERIFIED') AS v, "
                + "SUM(data_confidence='LIKELY') AS l, SUM(data_confidence='NEEDS_VERIFICATION') AS n "
                + "FROM exam WHERE is_active";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            if (rs.next()) {
                counts[0] = rs.getInt("total");
                counts[1] = rs.getInt("v");
                counts[2] = rs.getInt("l");
                counts[3] = rs.getInt("n");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return counts;
    }

    // ---------- helpers ----------

    private String buildWhere(ExamFilter f, List<Object> params) {
        StringBuilder where = new StringBuilder("WHERE e.is_active");
        if (notBlank(f.getQuery())) {
            where.append(" AND (e.name LIKE ? OR e.short_name LIKE ? OR e.code LIKE ? OR b.short_name LIKE ?)");
            String like = "%" + f.getQuery().trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
        }
        addEquals(where, params, "c.code", f.getCategoryCode());
        addEquals(where, params, "e.sector", f.getSector());
        addEquals(where, params, "e.purpose", f.getPurpose());
        addEquals(where, params, "e.scope", f.getScope());
        addEquals(where, params, "e.state_code", f.getStateCode());
        addEquals(where, params, "e.data_confidence", f.getConfidence());
        return where.toString();
    }

    private void addEquals(StringBuilder where, List<Object> params, String column, String value) {
        if (notBlank(value)) {
            where.append(" AND ").append(column).append("=?");
            params.add(value.trim());
        }
    }

    /** ORDER BY from a fixed whitelist - never from user text. */
    private String orderBy(String sort) {
        if ("category".equals(sort)) {
            return "c.sort_order, e.name";
        }
        if ("confidence".equals(sort)) {
            return "FIELD(e.data_confidence,'VERIFIED','LIKELY','NEEDS_VERIFICATION'), e.name";
        }
        if ("month".equals(sort)) {
            return "e.typical_exam_month IS NULL, e.typical_exam_month, e.name";
        }
        return "e.name";
    }

    private void bind(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object p = params.get(i);
            if (p instanceof Integer) {
                ps.setInt(i + 1, (Integer) p);
            } else {
                ps.setString(i + 1, String.valueOf(p));
            }
        }
    }

    private boolean notBlank(String s) {
        return s != null && !s.trim().isEmpty();
    }

    private List<Exam> list(String sql, Integer param) {
        List<Exam> exams = new ArrayList<>();
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            if (param != null) {
                ps.setInt(1, param);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    exams.add(mapExam(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return exams;
    }

    /** Sets the 21 columns from name to source_note starting at index i; returns the next index. */
    private int fillFields(PreparedStatement ps, Exam x, int i) throws SQLException {
        ps.setString(i++, x.getName());
        ps.setString(i++, x.getShortName());
        ps.setInt(i++, x.getCategoryId());
        ps.setInt(i++, x.getBodyId());
        ps.setString(i++, x.getScope());
        DaoUtil.setString(ps, i++, "STATE".equals(x.getScope()) ? x.getStateCode() : null);
        ps.setString(i++, x.getSector());
        ps.setString(i++, x.getPurpose());
        ps.setDouble(i++, x.getCyclesPerYear());
        DaoUtil.setInt(ps, i++, x.getTypicalNotificationMonth());
        DaoUtil.setInt(ps, i++, x.getTypicalExamMonth());
        DaoUtil.setString(ps, i++, x.getStagesSummary());
        DaoUtil.setString(ps, i++, x.getPostsOrCourses());
        DaoUtil.setString(ps, i++, x.getOfficialUrl());
        DaoUtil.setString(ps, i++, x.getWatchUrl());
        DaoUtil.setString(ps, i++, x.getDescription());
        DaoUtil.setString(ps, i++, x.getFeeSummary());
        DaoUtil.setString(ps, i++, x.getAttemptCountingNote());
        ps.setString(i++, x.getDataConfidence() == null ? "NEEDS_VERIFICATION" : x.getDataConfidence());
        DaoUtil.setDate(ps, i++, x.getLastVerifiedOn());
        DaoUtil.setString(ps, i++, x.getSourceNote());
        return i;
    }

    private Exam mapExam(ResultSet rs) throws SQLException {
        return new Exam(
                rs.getInt("id"),
                rs.getString("code"),
                rs.getString("name"),
                rs.getString("short_name"),
                rs.getInt("category_id"),
                rs.getString("category_code"),
                rs.getString("category_name"),
                rs.getInt("body_id"),
                rs.getString("body_short_name"),
                rs.getString("scope"),
                rs.getString("state_code"),
                rs.getString("sector"),
                rs.getString("purpose"),
                rs.getDouble("cycles_per_year"),
                DaoUtil.getInteger(rs, "typical_notification_month"),
                DaoUtil.getInteger(rs, "typical_exam_month"),
                rs.getString("stages_summary"),
                rs.getString("posts_or_courses"),
                rs.getString("official_url"),
                rs.getString("watch_url"),
                rs.getString("description"),
                rs.getString("fee_summary"),
                rs.getString("attempt_counting_note"),
                rs.getString("data_confidence"),
                DaoUtil.getLocalDate(rs, "last_verified_on"),
                rs.getString("source_note"),
                rs.getBoolean("is_active"),
                DaoUtil.getInteger(rs, "active_rule_version_id")
        );
    }
}
