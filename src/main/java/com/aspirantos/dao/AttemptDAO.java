package com.aspirantos.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.AttemptLog;
import com.aspirantos.util.DBConnection;

/**
 * JDBC access to attempt_log (the attempt journal). The column counts_as_attempt is NOT
 * sent by the application - the BEFORE INSERT/UPDATE triggers decide it from the exam's
 * counting rule (for UPSC, "applied only" or "absent" does not use up an attempt).
 */
public class AttemptDAO {

    // CREATE - returns the new row id (0 if the same exam/year/sitting was already logged)
    public int insertAttempt(AttemptLog a) {
        String sql = "INSERT INTO attempt_log "
                + "(user_id, exam_id, cycle_year, sitting_no, attempt_date, stage_reached, score, rank_obtained, remarks) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
        ) {
            ps.setInt(1, a.getUserId());
            ps.setInt(2, a.getExamId());
            ps.setInt(3, a.getCycleYear());
            ps.setInt(4, a.getSittingNo() <= 0 ? 1 : a.getSittingNo());
            DaoUtil.setDate(ps, 5, a.getAttemptDate());
            ps.setString(6, a.getStageReached());
            DaoUtil.setDouble(ps, 7, a.getScore());
            DaoUtil.setInt(ps, 8, a.getRankObtained());
            DaoUtil.setString(ps, 9, a.getRemarks());
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

    public List<AttemptLog> getAttemptsByUser(int userId) {
        return query("SELECT * FROM attempt_log WHERE user_id=? ORDER BY cycle_year DESC, sitting_no DESC", userId, 0);
    }

    public List<AttemptLog> getAttemptsByUserAndExam(int userId, int examId) {
        return query("SELECT * FROM attempt_log WHERE user_id=? AND exam_id=? ORDER BY cycle_year, sitting_no", userId, examId);
    }

    public AttemptLog getAttempt(int id) {
        String sql = "SELECT * FROM attempt_log WHERE id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapAttempt(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // UPDATE (only the owner's row)
    public int updateAttempt(AttemptLog a) {
        String sql = "UPDATE attempt_log SET cycle_year=?, sitting_no=?, attempt_date=?, stage_reached=?, "
                + "score=?, rank_obtained=?, remarks=? WHERE id=? AND user_id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, a.getCycleYear());
            ps.setInt(2, a.getSittingNo() <= 0 ? 1 : a.getSittingNo());
            DaoUtil.setDate(ps, 3, a.getAttemptDate());
            ps.setString(4, a.getStageReached());
            DaoUtil.setDouble(ps, 5, a.getScore());
            DaoUtil.setInt(ps, 6, a.getRankObtained());
            DaoUtil.setString(ps, 7, a.getRemarks());
            ps.setInt(8, a.getId());
            ps.setInt(9, a.getUserId());
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // DELETE (only the owner's row)
    public int deleteAttempt(int id, int userId) {
        String sql = "DELETE FROM attempt_log WHERE id=? AND user_id=?";
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

    /** Attempts used = before-app attempts + counted log rows, from the stored function fn_attempts_used. */
    public int getAttemptsUsed(int userId, int examId) {
        String sql = "SELECT fn_attempts_used(?, ?) AS used";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ps.setInt(2, examId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("used");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private List<AttemptLog> query(String sql, int userId, int examId) {
        List<AttemptLog> list = new ArrayList<>();
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            if (examId > 0) {
                ps.setInt(2, examId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapAttempt(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private AttemptLog mapAttempt(ResultSet rs) throws SQLException {
        return new AttemptLog(
                rs.getInt("id"),
                rs.getInt("user_id"),
                rs.getInt("exam_id"),
                rs.getInt("cycle_year"),
                rs.getInt("sitting_no"),
                DaoUtil.getLocalDate(rs, "attempt_date"),
                rs.getString("stage_reached"),
                rs.getBoolean("counts_as_attempt"),
                DaoUtil.getDouble(rs, "score"),
                DaoUtil.getInteger(rs, "rank_obtained"),
                rs.getString("remarks")
        );
    }
}
