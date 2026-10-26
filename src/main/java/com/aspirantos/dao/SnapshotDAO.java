package com.aspirantos.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.EligibilitySnapshot;
import com.aspirantos.util.DBConnection;

/**
 * JDBC access to eligibility_snapshot - the cache of engine results. Rows are deleted by
 * triggers whenever the profile, education, attempts or rules change; the eligibility
 * service recomputes only the missing rows.
 */
public class SnapshotDAO {

    public EligibilitySnapshot getSnapshot(int userId, int examId) {
        String sql = "SELECT * FROM eligibility_snapshot WHERE user_id=? AND exam_id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ps.setInt(2, examId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapSnapshot(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<EligibilitySnapshot> getSnapshotsByUser(int userId) {
        List<EligibilitySnapshot> list = new ArrayList<>();
        String sql = "SELECT * FROM eligibility_snapshot WHERE user_id=?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapSnapshot(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Stores (or replaces) the result for one student and exam. */
    public int saveSnapshot(EligibilitySnapshot s) {
        String sql = "INSERT INTO eligibility_snapshot "
                + "(user_id, exam_id, rule_version_id, computed_for_date, status, attempts_used, attempts_remaining, "
                + "next_cycle_year, first_eligible_year, last_eligible_year, headline, details_text) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) "
                + "AS new ON DUPLICATE KEY UPDATE rule_version_id=new.rule_version_id, "
                + "computed_for_date=new.computed_for_date, status=new.status, attempts_used=new.attempts_used, "
                + "attempts_remaining=new.attempts_remaining, next_cycle_year=new.next_cycle_year, "
                + "first_eligible_year=new.first_eligible_year, last_eligible_year=new.last_eligible_year, "
                + "headline=new.headline, details_text=new.details_text, computed_at=CURRENT_TIMESTAMP";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, s.getUserId());
            ps.setInt(2, s.getExamId());
            ps.setInt(3, s.getRuleVersionId());
            DaoUtil.setDate(ps, 4, s.getComputedForDate());
            ps.setString(5, s.getStatus());
            DaoUtil.setInt(ps, 6, s.getAttemptsUsed());
            DaoUtil.setInt(ps, 7, s.getAttemptsRemaining());
            DaoUtil.setInt(ps, 8, s.getNextCycleYear());
            DaoUtil.setInt(ps, 9, s.getFirstEligibleYear());
            DaoUtil.setInt(ps, 10, s.getLastEligibleYear());
            ps.setString(11, s.getHeadline());
            DaoUtil.setString(ps, 12, s.getDetailsText());
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Clears every cached result of a student (e.g. when the simulation date changes). */
    /**
     * [EXTRA] JDBC batch (addBatch / executeBatch): saves many snapshots with ONE connection;
     * the dashboard stores up to 267 results at once. Returns the number of snapshots sent.
     */
    public int saveSnapshots(List<EligibilitySnapshot> list) {
        if (list.isEmpty()) {
            return 0;
        }
        String sql = "INSERT INTO eligibility_snapshot "
                + "(user_id, exam_id, rule_version_id, computed_for_date, status, attempts_used, attempts_remaining, "
                + "next_cycle_year, first_eligible_year, last_eligible_year, headline, details_text) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) "
                + "AS new ON DUPLICATE KEY UPDATE rule_version_id=new.rule_version_id, "
                + "computed_for_date=new.computed_for_date, status=new.status, attempts_used=new.attempts_used, "
                + "attempts_remaining=new.attempts_remaining, next_cycle_year=new.next_cycle_year, "
                + "first_eligible_year=new.first_eligible_year, last_eligible_year=new.last_eligible_year, "
                + "headline=new.headline, details_text=new.details_text, computed_at=CURRENT_TIMESTAMP";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            for (EligibilitySnapshot s : list) {
                ps.setInt(1, s.getUserId());
                ps.setInt(2, s.getExamId());
                ps.setInt(3, s.getRuleVersionId());
                DaoUtil.setDate(ps, 4, s.getComputedForDate());
                ps.setString(5, s.getStatus());
                DaoUtil.setInt(ps, 6, s.getAttemptsUsed());
                DaoUtil.setInt(ps, 7, s.getAttemptsRemaining());
                DaoUtil.setInt(ps, 8, s.getNextCycleYear());
                DaoUtil.setInt(ps, 9, s.getFirstEligibleYear());
                DaoUtil.setInt(ps, 10, s.getLastEligibleYear());
                ps.setString(11, s.getHeadline());
                DaoUtil.setString(ps, 12, s.getDetailsText());
                ps.addBatch();
            }
            ps.executeBatch();
            return list.size();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int deleteSnapshotsOfUser(int userId) {
        String sql = "DELETE FROM eligibility_snapshot WHERE user_id=?";
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

    /** Clears every cached result (admin changed the simulation date). */
    public int deleteAllSnapshots() {
        String sql = "DELETE FROM eligibility_snapshot";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private EligibilitySnapshot mapSnapshot(ResultSet rs) throws SQLException {
        return new EligibilitySnapshot(
                rs.getInt("id"),
                rs.getInt("user_id"),
                rs.getInt("exam_id"),
                rs.getInt("rule_version_id"),
                DaoUtil.getLocalDate(rs, "computed_for_date"),
                rs.getString("status"),
                DaoUtil.getInteger(rs, "attempts_used"),
                DaoUtil.getInteger(rs, "attempts_remaining"),
                DaoUtil.getInteger(rs, "next_cycle_year"),
                DaoUtil.getInteger(rs, "first_eligible_year"),
                DaoUtil.getInteger(rs, "last_eligible_year"),
                rs.getString("headline"),
                rs.getString("details_text"),
                DaoUtil.getLocalDateTime(rs, "computed_at")
        );
    }
}
