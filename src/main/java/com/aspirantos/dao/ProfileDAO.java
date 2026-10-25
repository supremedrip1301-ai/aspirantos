package com.aspirantos.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.aspirantos.model.Profile;
import com.aspirantos.util.DBConnection;

/**
 * JDBC access to aspirant_profile (one row per student, primary key = user_id).
 * saveProfile() inserts the row the first time and updates it afterwards
 * (INSERT ... ON DUPLICATE KEY UPDATE). The trigger trg_profile_au then clears the student's
 * cached eligibility results so they are recalculated.
 */
public class ProfileDAO {

    // READ ONE PROFILE (null when the student has not filled the wizard yet)
    public Profile getProfile(int userId) {
        String sql = "SELECT * FROM aspirant_profile WHERE user_id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapProfile(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // CREATE or UPDATE - returns rows affected (1 = inserted, 2 = updated, 0 = unchanged / failed)
    public int saveProfile(Profile p) {
        String sql = "INSERT INTO aspirant_profile "
                + "(user_id, dob, gender, category, is_pwbd, pwbd_type, pwbd_percent, is_ex_serviceman, "
                + "esm_service_years, esm_release_date, domicile_state_code, is_jk_domicile_1980_89, "
                + "is_govt_employee, govt_service_years, marital_status, nationality, father_name, mother_name, "
                + "address_line, city, pincode, aadhaar_last4, profile_completion_pct) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) "
                + "AS new ON DUPLICATE KEY UPDATE "
                + "dob=new.dob, gender=new.gender, category=new.category, is_pwbd=new.is_pwbd, "
                + "pwbd_type=new.pwbd_type, pwbd_percent=new.pwbd_percent, is_ex_serviceman=new.is_ex_serviceman, "
                + "esm_service_years=new.esm_service_years, esm_release_date=new.esm_release_date, "
                + "domicile_state_code=new.domicile_state_code, is_jk_domicile_1980_89=new.is_jk_domicile_1980_89, "
                + "is_govt_employee=new.is_govt_employee, govt_service_years=new.govt_service_years, "
                + "marital_status=new.marital_status, nationality=new.nationality, father_name=new.father_name, "
                + "mother_name=new.mother_name, address_line=new.address_line, city=new.city, "
                + "pincode=new.pincode, aadhaar_last4=new.aadhaar_last4, "
                + "profile_completion_pct=new.profile_completion_pct";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, p.getUserId());
            DaoUtil.setDate(ps, 2, p.getDob());
            DaoUtil.setString(ps, 3, p.getGender());
            ps.setString(4, p.getCategory() == null ? "GEN" : p.getCategory());
            ps.setBoolean(5, p.isPwbd());
            DaoUtil.setString(ps, 6, p.isPwbd() ? p.getPwbdType() : null);
            DaoUtil.setInt(ps, 7, p.isPwbd() ? p.getPwbdPercent() : null);
            ps.setBoolean(8, p.isExServiceman());
            DaoUtil.setDouble(ps, 9, p.isExServiceman() ? p.getEsmServiceYears() : null);
            DaoUtil.setDate(ps, 10, p.isExServiceman() ? p.getEsmReleaseDate() : null);
            DaoUtil.setString(ps, 11, p.getDomicileStateCode());
            ps.setBoolean(12, p.isJkDomicile198089());
            ps.setBoolean(13, p.isGovtEmployee());
            DaoUtil.setDouble(ps, 14, p.isGovtEmployee() ? p.getGovtServiceYears() : null);
            DaoUtil.setString(ps, 15, p.getMaritalStatus());
            ps.setString(16, p.getNationality() == null ? "INDIAN" : p.getNationality());
            DaoUtil.setString(ps, 17, p.getFatherName());
            DaoUtil.setString(ps, 18, p.getMotherName());
            DaoUtil.setString(ps, 19, p.getAddressLine());
            DaoUtil.setString(ps, 20, p.getCity());
            DaoUtil.setString(ps, 21, p.getPincode());
            DaoUtil.setString(ps, 22, p.getAadhaarLast4());
            ps.setInt(23, p.getProfileCompletionPct());
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // DELETE ("delete my data" keeps the account but removes the profile)
    public int deleteProfile(int userId) {
        String sql = "DELETE FROM aspirant_profile WHERE user_id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private Profile mapProfile(ResultSet rs) throws SQLException {
        return new Profile(
                rs.getInt("user_id"),
                DaoUtil.getLocalDate(rs, "dob"),
                rs.getString("gender"),
                rs.getString("category"),
                rs.getBoolean("is_pwbd"),
                rs.getString("pwbd_type"),
                DaoUtil.getInteger(rs, "pwbd_percent"),
                rs.getBoolean("is_ex_serviceman"),
                DaoUtil.getDouble(rs, "esm_service_years"),
                DaoUtil.getLocalDate(rs, "esm_release_date"),
                rs.getString("domicile_state_code"),
                rs.getBoolean("is_jk_domicile_1980_89"),
                rs.getBoolean("is_govt_employee"),
                DaoUtil.getDouble(rs, "govt_service_years"),
                rs.getString("marital_status"),
                rs.getString("nationality"),
                rs.getString("father_name"),
                rs.getString("mother_name"),
                rs.getString("address_line"),
                rs.getString("city"),
                rs.getString("pincode"),
                rs.getString("aadhaar_last4"),
                rs.getInt("profile_completion_pct"),
                DaoUtil.getLocalDateTime(rs, "updated_at")
        );
    }
}
