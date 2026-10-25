package com.aspirantos.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.Education;
import com.aspirantos.util.DBConnection;

/**
 * JDBC access to the education table (StudentDAO shape). Update and delete also check the
 * owner (user_id) so one student can never change another student's rows.
 */
public class EducationDAO {

    // CREATE - returns the new row id
    public int insertEducation(Education ed) {
        String sql = "INSERT INTO education "
                + "(user_id, level, degree_name, stream_or_specialisation, subjects, board_or_university, "
                + "percentage, cgpa, cgpa_scale, passing_year, status, expected_completion_date) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
        ) {
            ps.setInt(1, ed.getUserId());
            fillFields(ps, ed, 2);
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

    // READ ALL rows of one student, lowest level first
    public List<Education> getEducationByUser(int userId) {
        List<Education> list = new ArrayList<>();
        String sql = "SELECT * FROM education WHERE user_id=? ORDER BY "
                + "FIELD(level,'CLASS_10','CLASS_12','DIPLOMA','UG','PG','PHD','PROFESSIONAL'), passing_year";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapEducation(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // READ ONE ROW
    public Education getEducation(int id) {
        String sql = "SELECT * FROM education WHERE id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapEducation(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // UPDATE (only the owner's row)
    public int updateEducation(Education ed) {
        String sql = "UPDATE education SET level=?, degree_name=?, stream_or_specialisation=?, subjects=?, "
                + "board_or_university=?, percentage=?, cgpa=?, cgpa_scale=?, passing_year=?, status=?, "
                + "expected_completion_date=? WHERE id=? AND user_id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            int next = fillFields(ps, ed, 1);
            ps.setInt(next, ed.getId());
            ps.setInt(next + 1, ed.getUserId());
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // DELETE (only the owner's row)
    public int deleteEducation(int id, int userId) {
        String sql = "DELETE FROM education WHERE id=? AND user_id=?";
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

    /** Sets the 11 data columns starting at the given parameter index; returns the next index. */
    private int fillFields(PreparedStatement ps, Education ed, int i) throws SQLException {
        ps.setString(i++, ed.getLevel());
        DaoUtil.setString(ps, i++, ed.getDegreeName());
        DaoUtil.setString(ps, i++, ed.getStreamOrSpecialisation());
        DaoUtil.setString(ps, i++, ed.getSubjects() == null ? null : ed.getSubjects().toUpperCase());
        DaoUtil.setString(ps, i++, ed.getBoardOrUniversity());
        DaoUtil.setDouble(ps, i++, ed.getPercentage());
        DaoUtil.setDouble(ps, i++, ed.getCgpa());
        DaoUtil.setDouble(ps, i++, ed.getCgpa() == null ? null : ed.getCgpaScale());
        DaoUtil.setInt(ps, i++, ed.getPassingYear());
        ps.setString(i++, ed.getStatus() == null ? "COMPLETED" : ed.getStatus());
        DaoUtil.setDate(ps, i++, ed.getExpectedCompletionDate());
        return i;
    }

    private Education mapEducation(ResultSet rs) throws SQLException {
        return new Education(
                rs.getInt("id"),
                rs.getInt("user_id"),
                rs.getString("level"),
                rs.getString("degree_name"),
                rs.getString("stream_or_specialisation"),
                rs.getString("subjects"),
                rs.getString("board_or_university"),
                DaoUtil.getDouble(rs, "percentage"),
                DaoUtil.getDouble(rs, "cgpa"),
                DaoUtil.getDouble(rs, "cgpa_scale"),
                DaoUtil.getInteger(rs, "passing_year"),
                rs.getString("status"),
                DaoUtil.getLocalDate(rs, "expected_completion_date")
        );
    }
}
