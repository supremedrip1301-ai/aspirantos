package com.aspirantos.dao;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.State;
import com.aspirantos.util.DBConnection;

/**
 * Reads the 36 states and union territories (table state_master).
 * Uses a plain Statement on purpose: the query is fixed and has no user input, exactly like
 * the "select * from people" example of the JDBC notes. Every query with user input in this
 * project uses PreparedStatement instead (protection against SQL injection).
 */
public class StateDAO {

    public List<State> getAllStates() {
        List<State> states = new ArrayList<>();
        String sql = "SELECT code, name, type FROM state_master ORDER BY name";
        try (
            Connection con = DBConnection.getConnection();
            Statement statement = con.createStatement();
            ResultSet rs = statement.executeQuery(sql)
        ) {
            while (rs.next()) {
                states.add(new State(
                        rs.getString("code"),
                        rs.getString("name"),
                        rs.getString("type")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return states;
    }

    /** Name of a state code (e.g. "UP" -> "Uttar Pradesh"), or the code itself if unknown. */
    public String getStateName(String code, List<State> states) {
        if (code == null) {
            return "";
        }
        for (State s : states) {
            if (s.getCode().equals(code)) {
                return s.getName();
            }
        }
        return code;
    }
}
