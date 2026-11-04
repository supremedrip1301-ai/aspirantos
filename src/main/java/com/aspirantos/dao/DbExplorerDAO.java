package com.aspirantos.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import com.aspirantos.util.DBConnection;

/**
 * Read-only DB Explorer of the admin area.
 *
 * - The table name cannot be a "?" placeholder, so it must be one of the fixed names below
 *   (a whitelist) - user text never reaches the SQL.
 * - Statement.execute() returns true when the statement produced a ResultSet.
 * - A SCROLLABLE ResultSet (TYPE_SCROLL_INSENSITIVE) moves freely: first(), last(),
 *   previous(), next(), absolute(n) and getRow() give the page navigation and the row count.
 * - ResultSetMetaData gives the column count, names, SQL type names and the table name.
 * - updateSetting() edits app_setting through an UPDATABLE ResultSet (CONCUR_UPDATABLE,
 *   updateString + updateRow) instead of an UPDATE statement.
 */
public class DbExplorerDAO {

    public static final String[] TABLES = {
        "app_setting", "app_user", "aspirant_profile", "education", "work_experience", "remember_token",
        "state_master", "exam_category", "conducting_body", "exam", "exam_rule_version",
        "age_rule", "relaxation_rule", "attempt_rule", "qualification_rule", "other_rule",
        "doc_spec", "exam_event", "user_exam_tracking", "attempt_log", "eligibility_snapshot",
        "notification", "info_report", "exam_update_check", "rule_change_log", "audit_log",
        "v_exam_catalog", "v_rule_history", "v_upcoming_events", "v_user_attempt_summary", "v_user_dashboard", "v_admin_category_stats"
    };

    /** Columns that are never shown, even to the admin. */
    private static final List<String> HIDDEN = Arrays.asList("password_hash", "password_salt", "token_hash", "aadhaar_last4");

    /** One page of a table. */
    public static class Page {
        public String table;
        public boolean executeGaveResultSet;
        public int columnCount;
        public String metaTableName;
        public List<String> columns = new ArrayList<>();
        public List<String> types = new ArrayList<>();
        public List<String[]> rows = new ArrayList<>();
        public int totalRows;
        public int firstRow;      // 1-based number of the first row shown (0 = empty table)
    }

    public static boolean isAllowed(String table) {
        return table != null && Arrays.asList(TABLES).contains(table);
    }

    /**
     * Reads one page. move = first / previous / next / last / goto; current = first row shown now.
     */
    public Page browse(String table, String move, int current, int pageSize) {
        Page page = new Page();
        page.table = table;
        if (!isAllowed(table)) {
            return page;
        }
        try (
            Connection con = DBConnection.getConnection();
            Statement st = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY)
        ) {
            page.executeGaveResultSet = st.execute("SELECT * FROM " + table);   // table name from the whitelist only
            try (ResultSet rs = st.getResultSet()) {
                ResultSetMetaData md = rs.getMetaData();
                page.columnCount = md.getColumnCount();
                page.metaTableName = md.getTableName(1);
                for (int c = 1; c <= page.columnCount; c++) {
                    page.columns.add(md.getColumnLabel(c));
                    page.types.add(md.getColumnTypeName(c) + (md.getPrecision(c) > 0 && md.getPrecision(c) < 70000 ? "(" + md.getPrecision(c) + ")" : ""));
                }
                if (rs.last()) {                      // jump to the last row: its number is the row count
                    page.totalRows = rs.getRow();
                }
                if (page.totalRows == 0) {
                    return page;
                }
                // place the cursor on the first row of the wanted page
                boolean onRow;
                if ("last".equals(move)) {
                    int start = Math.max(1, page.totalRows - pageSize + 1);
                    onRow = rs.absolute(start);
                } else if ("next".equals(move)) {
                    int target = current + pageSize <= page.totalRows ? current + pageSize : Math.max(1, Math.min(current, page.totalRows));
                    onRow = rs.absolute(Math.max(1, Math.min(current, page.totalRows)));
                    while (onRow && rs.getRow() < target) {
                        onRow = rs.next();
                    }
                } else if ("previous".equals(move)) {
                    onRow = rs.absolute(Math.max(1, Math.min(current, page.totalRows)));
                    for (int i = 0; i < pageSize && rs.getRow() > 1; i++) {
                        onRow = rs.previous();
                    }
                } else if ("goto".equals(move)) {
                    onRow = rs.absolute(Math.max(1, Math.min(current, page.totalRows)));
                } else {
                    onRow = rs.first();
                }
                page.firstRow = rs.getRow();
                int read = 0;
                while (onRow && read < pageSize) {
                    String[] row = new String[page.columnCount];
                    for (int c = 1; c <= page.columnCount; c++) {
                        String name = page.columns.get(c - 1);
                        String v = rs.getString(c);
                        if (v != null && HIDDEN.contains(name)) {
                            v = "(hidden)";
                        } else if (v != null && v.length() > 80) {
                            v = v.substring(0, 80) + "...";
                        }
                        row[c - 1] = v;
                    }
                    page.rows.add(row);
                    read++;
                    onRow = rs.next();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return page;
    }

    /** Quick edit of one app_setting value through an updatable ResultSet. Returns 1 when saved. */
    public int updateSetting(String key, String value) {
        String sql = "SELECT setting_key, setting_value FROM app_setting WHERE setting_key=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql, ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE)
        ) {
            ps.setString(1, key);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    rs.updateString("setting_value", value);
                    rs.updateRow();                  // writes the changed row back to the table
                    return 1;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}
