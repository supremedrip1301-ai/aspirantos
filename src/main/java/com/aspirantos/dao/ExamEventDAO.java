package com.aspirantos.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.ExamEvent;
import com.aspirantos.util.DBConnection;

/**
 * Exam calendar dates (table exam_event). Used by the exam page (Calendar tab), the
 * dashboard ("upcoming events"), the month calendar and the .ics export.
 */
public class ExamEventDAO {

    private static final String SELECT =
            "SELECT ev.*, e.code AS exam_code, e.short_name AS exam_short_name "
            + "FROM exam_event ev JOIN exam e ON e.id = ev.exam_id ";

    public List<ExamEvent> getEventsByExam(int examId) {
        List<ExamEvent> list = new ArrayList<>();
        String sql = SELECT + "WHERE ev.exam_id=? ORDER BY ev.event_date";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, examId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapEvent(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** All events of one type for every exam (the eligibility service reads all STAGE_1 dates at once). */
    public List<ExamEvent> getEventsByType(String eventType) {
        List<ExamEvent> list = new ArrayList<>();
        String sql = SELECT + "WHERE ev.event_type=? ORDER BY ev.exam_id, ev.event_date";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, eventType);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapEvent(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Events of the exams a student tracks between two dates (month calendar, dashboard). */
    public List<ExamEvent> getEventsForUser(int userId, LocalDate from, LocalDate to) {
        List<ExamEvent> list = new ArrayList<>();
        String sql = SELECT + "JOIN user_exam_tracking t ON t.exam_id = ev.exam_id AND t.user_id=? "
                + "WHERE ev.event_date BETWEEN ? AND ? ORDER BY ev.event_date, e.short_name";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            DaoUtil.setDate(ps, 2, from);
            DaoUtil.setDate(ps, 3, to);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapEvent(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** All events in the next 90 days from the view v_upcoming_events (simulation-date aware). */
    public List<ExamEvent> getUpcomingEvents(int limit) {
        List<ExamEvent> list = new ArrayList<>();
        String sql = "SELECT u.event_id AS id, u.exam_id, u.exam_code, u.short_name AS exam_short_name, u.cycle_year, "
                + "u.event_type, u.event_date, u.is_tentative, ev.notes "
                + "FROM v_upcoming_events u JOIN exam_event ev ON ev.id = u.event_id "
                + "ORDER BY u.event_date, u.short_name LIMIT ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapEvent(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public ExamEvent getEvent(int id) {
        String sql = SELECT + "WHERE ev.id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapEvent(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Inserts, or updates the date of the same event type in the same cycle. */
    public int saveEvent(ExamEvent ev) {
        String sql = "INSERT INTO exam_event (exam_id, cycle_year, event_type, event_date, is_tentative, notes) "
                + "VALUES (?, ?, ?, ?, ?, ?) AS new ON DUPLICATE KEY UPDATE event_date=new.event_date, "
                + "is_tentative=new.is_tentative, notes=new.notes";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, ev.getExamId());
            ps.setInt(2, ev.getCycleYear());
            ps.setString(3, ev.getEventType());
            DaoUtil.setDate(ps, 4, ev.getEventDate());
            ps.setBoolean(5, ev.isTentative());
            DaoUtil.setString(ps, 6, ev.getNotes());
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int deleteEvent(int id) {
        String sql = "DELETE FROM exam_event WHERE id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, id);
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private ExamEvent mapEvent(ResultSet rs) throws SQLException {
        return new ExamEvent(
                rs.getInt("id"),
                rs.getInt("exam_id"),
                rs.getString("exam_code"),
                rs.getString("exam_short_name"),
                rs.getInt("cycle_year"),
                rs.getString("event_type"),
                DaoUtil.getLocalDate(rs, "event_date"),
                rs.getBoolean("is_tentative"),
                rs.getString("notes")
        );
    }
}
