package com.aspirantos.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.WorkExperience;
import com.aspirantos.util.DBConnection;

/**
 * JDBC access to work_experience (StudentDAO shape, owner-checked update and delete).
 */
public class WorkExperienceDAO {

    // CREATE - returns the new row id
    public int insertWork(WorkExperience w) {
        String sql = "INSERT INTO work_experience "
                + "(user_id, organisation, designation, start_date, end_date, is_govt, is_relevant_professional) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
        ) {
            ps.setInt(1, w.getUserId());
            ps.setString(2, w.getOrganisation());
            DaoUtil.setString(ps, 3, w.getDesignation());
            DaoUtil.setDate(ps, 4, w.getStartDate());
            DaoUtil.setDate(ps, 5, w.getEndDate());
            ps.setBoolean(6, w.isGovt());
            ps.setBoolean(7, w.isRelevantProfessional());
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

    // READ ALL rows of one student, latest first
    public List<WorkExperience> getWorkByUser(int userId) {
        List<WorkExperience> list = new ArrayList<>();
        String sql = "SELECT * FROM work_experience WHERE user_id=? ORDER BY start_date DESC";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapWork(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // READ ONE ROW
    public WorkExperience getWork(int id) {
        String sql = "SELECT * FROM work_experience WHERE id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapWork(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // UPDATE (only the owner's row)
    public int updateWork(WorkExperience w) {
        String sql = "UPDATE work_experience SET organisation=?, designation=?, start_date=?, end_date=?, "
                + "is_govt=?, is_relevant_professional=? WHERE id=? AND user_id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, w.getOrganisation());
            DaoUtil.setString(ps, 2, w.getDesignation());
            DaoUtil.setDate(ps, 3, w.getStartDate());
            DaoUtil.setDate(ps, 4, w.getEndDate());
            ps.setBoolean(5, w.isGovt());
            ps.setBoolean(6, w.isRelevantProfessional());
            ps.setInt(7, w.getId());
            ps.setInt(8, w.getUserId());
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // DELETE (only the owner's row)
    public int deleteWork(int id, int userId) {
        String sql = "DELETE FROM work_experience WHERE id=? AND user_id=?";
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

    private WorkExperience mapWork(ResultSet rs) throws SQLException {
        return new WorkExperience(
                rs.getInt("id"),
                rs.getInt("user_id"),
                rs.getString("organisation"),
                rs.getString("designation"),
                DaoUtil.getLocalDate(rs, "start_date"),
                DaoUtil.getLocalDate(rs, "end_date"),
                rs.getBoolean("is_govt"),
                rs.getBoolean("is_relevant_professional")
        );
    }
}
