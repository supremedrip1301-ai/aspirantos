package com.aspirantos.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.DocSpec;
import com.aspirantos.util.DBConnection;

/**
 * Photo / signature / thumb / declaration rules of an exam (table doc_spec), shown
 * read-only on the exam page and edited by the admin.
 */
public class DocSpecDAO {

    public List<DocSpec> getDocSpecsByExam(int examId) {
        List<DocSpec> list = new ArrayList<>();
        String sql = "SELECT * FROM doc_spec WHERE exam_id=? "
                + "ORDER BY FIELD(doc_type,'PHOTO','SIGNATURE','LEFT_THUMB','HANDWRITTEN_DECLARATION','CATEGORY_CERT','PWBD_CERT','OTHER')";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, examId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapSpec(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public DocSpec getDocSpec(int id) {
        String sql = "SELECT * FROM doc_spec WHERE id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapSpec(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Inserts, or replaces the spec of the same document type (UNIQUE exam_id + doc_type). */
    public int saveDocSpec(DocSpec d) {
        String sql = "INSERT INTO doc_spec (exam_id, doc_type, min_width_px, max_width_px, min_height_px, max_height_px, "
                + "min_kb, max_kb, allowed_formats, background_rule, requires_name_and_date, max_photo_age_months, notes) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) "
                + "AS new ON DUPLICATE KEY UPDATE min_width_px=new.min_width_px, max_width_px=new.max_width_px, "
                + "min_height_px=new.min_height_px, max_height_px=new.max_height_px, min_kb=new.min_kb, max_kb=new.max_kb, "
                + "allowed_formats=new.allowed_formats, background_rule=new.background_rule, "
                + "requires_name_and_date=new.requires_name_and_date, max_photo_age_months=new.max_photo_age_months, "
                + "notes=new.notes";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, d.getExamId());
            ps.setString(2, d.getDocType());
            DaoUtil.setInt(ps, 3, d.getMinWidthPx());
            DaoUtil.setInt(ps, 4, d.getMaxWidthPx());
            DaoUtil.setInt(ps, 5, d.getMinHeightPx());
            DaoUtil.setInt(ps, 6, d.getMaxHeightPx());
            DaoUtil.setInt(ps, 7, d.getMinKb());
            DaoUtil.setInt(ps, 8, d.getMaxKb());
            DaoUtil.setString(ps, 9, d.getAllowedFormats());
            DaoUtil.setString(ps, 10, d.getBackgroundRule());
            ps.setBoolean(11, d.isRequiresNameAndDate());
            DaoUtil.setInt(ps, 12, d.getMaxPhotoAgeMonths());
            DaoUtil.setString(ps, 13, d.getNotes());
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int deleteDocSpec(int id) {
        String sql = "DELETE FROM doc_spec WHERE id=?";
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

    private DocSpec mapSpec(ResultSet rs) throws SQLException {
        return new DocSpec(
                rs.getInt("id"),
                rs.getInt("exam_id"),
                rs.getString("doc_type"),
                DaoUtil.getInteger(rs, "min_width_px"),
                DaoUtil.getInteger(rs, "max_width_px"),
                DaoUtil.getInteger(rs, "min_height_px"),
                DaoUtil.getInteger(rs, "max_height_px"),
                DaoUtil.getInteger(rs, "min_kb"),
                DaoUtil.getInteger(rs, "max_kb"),
                rs.getString("allowed_formats"),
                rs.getString("background_rule"),
                rs.getBoolean("requires_name_and_date"),
                DaoUtil.getInteger(rs, "max_photo_age_months"),
                rs.getString("notes")
        );
    }
}
