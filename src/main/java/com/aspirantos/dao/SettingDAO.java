package com.aspirantos.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.AppSetting;
import com.aspirantos.util.DBConnection;
import com.aspirantos.util.DateUtil;

/**
 * JDBC access to app_setting. getToday() is the single place where the whole application
 * decides what "today" is: the admin's simulation date when it is set, otherwise the real date.
 */
public class SettingDAO {

    public String getSetting(String key) {
        String sql = "SELECT setting_value FROM app_setting WHERE setting_key=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, key);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("setting_value");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<AppSetting> getAllSettings() {
        List<AppSetting> list = new ArrayList<>();
        String sql = "SELECT setting_key, setting_value, description FROM app_setting ORDER BY setting_key";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                list.add(new AppSetting(
                        rs.getString("setting_key"),
                        rs.getString("setting_value"),
                        rs.getString("description")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Returns rows affected (1 = changed, 0 = unknown key or same value). */
    public int updateSetting(String key, String value) {
        String sql = "UPDATE app_setting SET setting_value=? WHERE setting_key=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, value == null ? "" : value.trim());
            ps.setString(2, key);
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Integer setting with a fallback when it is missing or not a number. */
    public int getInt(String key, int fallback) {
        try {
            return Integer.parseInt(getSetting(key).trim());
        } catch (Exception e) {
            return fallback;
        }
    }

    /** The simulation date, or null when it is empty (= use the real date). */
    public LocalDate getSimulationDate() {
        return DateUtil.parse(getSetting("simulation_date"));
    }

    /** "Today" for the eligibility engine: simulation date if set, otherwise LocalDate.now(). */
    public LocalDate getToday() {
        LocalDate simulated = getSimulationDate();
        return simulated != null ? simulated : LocalDate.now();
    }
}
