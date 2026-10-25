package com.aspirantos.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.ConductingBody;
import com.aspirantos.model.ExamCategory;
import com.aspirantos.util.DBConnection;

/**
 * Exam categories (tiles on the landing page / explorer) and conducting bodies
 * (drop-down in the admin exam form). Fixed queries use a plain Statement.
 */
public class CategoryDAO {

    /** All categories with the number of active exams in each (LEFT JOIN + GROUP BY). */
    public List<ExamCategory> getAllCategories() {
        List<ExamCategory> list = new ArrayList<>();
        String sql = "SELECT c.*, COUNT(e.id) AS exam_count "
                + "FROM exam_category c LEFT JOIN exam e ON e.category_id = c.id AND e.is_active "
                + "GROUP BY c.id ORDER BY c.sort_order";
        try (
            Connection con = DBConnection.getConnection();
            Statement statement = con.createStatement();
            ResultSet rs = statement.executeQuery(sql)
        ) {
            while (rs.next()) {
                list.add(mapCategory(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public ExamCategory getCategoryByCode(String code) {
        String sql = "SELECT c.*, (SELECT COUNT(*) FROM exam e WHERE e.category_id = c.id AND e.is_active) AS exam_count "
                + "FROM exam_category c WHERE c.code=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCategory(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<ConductingBody> getAllBodies() {
        List<ConductingBody> list = new ArrayList<>();
        String sql = "SELECT id, short_name, full_name, website, body_type FROM conducting_body ORDER BY short_name";
        try (
            Connection con = DBConnection.getConnection();
            Statement statement = con.createStatement();
            ResultSet rs = statement.executeQuery(sql)
        ) {
            while (rs.next()) {
                list.add(new ConductingBody(
                        rs.getInt("id"),
                        rs.getString("short_name"),
                        rs.getString("full_name"),
                        rs.getString("website"),
                        rs.getString("body_type")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private ExamCategory mapCategory(ResultSet rs) throws SQLException {
        return new ExamCategory(
                rs.getInt("id"),
                rs.getString("code"),
                rs.getString("name"),
                rs.getString("short_description"),
                rs.getString("icon_svg_name"),
                rs.getString("accent_color"),
                rs.getInt("sort_order"),
                rs.getInt("exam_count")
        );
    }
}
