package com.aspirantos.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.Tracking;
import com.aspirantos.util.DBConnection;

/**
 * JDBC access to user_exam_tracking - the exams a student follows and the attempts used
 * before joining AspirantOS.
 */
public class TrackingDAO {

    /** Tracks an exam, or updates the before-app attempts if it is already tracked. */
    public int trackExam(Tracking t) {
        String sql = "INSERT INTO user_exam_tracking "
                + "(user_id, exam_id, is_favourite, attempts_used_before_app, target_cycle_year, personal_note) "
                + "VALUES (?, ?, ?, ?, ?, ?) "
                + "AS new ON DUPLICATE KEY UPDATE is_favourite=new.is_favourite, "
                + "attempts_used_before_app=new.attempts_used_before_app, "
                + "target_cycle_year=new.target_cycle_year, personal_note=new.personal_note";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, t.getUserId());
            ps.setInt(2, t.getExamId());
            ps.setBoolean(3, t.isFavourite());
            ps.setInt(4, t.getAttemptsUsedBeforeApp());
            DaoUtil.setInt(ps, 5, t.getTargetCycleYear());
            DaoUtil.setString(ps, 6, t.getPersonalNote());
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Tracking> getTrackingByUser(int userId) {
        List<Tracking> list = new ArrayList<>();
        String sql = "SELECT * FROM user_exam_tracking WHERE user_id=? ORDER BY is_favourite DESC, created_at";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapTracking(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** null when the student does not track this exam. */
    public Tracking getTracking(int userId, int examId) {
        String sql = "SELECT * FROM user_exam_tracking WHERE user_id=? AND exam_id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ps.setInt(2, examId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapTracking(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public int untrackExam(int userId, int examId) {
        String sql = "DELETE FROM user_exam_tracking WHERE user_id=? AND exam_id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ps.setInt(2, examId);
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private Tracking mapTracking(ResultSet rs) throws SQLException {
        return new Tracking(
                rs.getInt("id"),
                rs.getInt("user_id"),
                rs.getInt("exam_id"),
                rs.getBoolean("is_favourite"),
                rs.getInt("attempts_used_before_app"),
                DaoUtil.getInteger(rs, "target_cycle_year"),
                rs.getString("personal_note")
        );
    }
}
