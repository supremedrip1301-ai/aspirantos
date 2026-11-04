package com.aspirantos.engine;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import com.aspirantos.model.AttemptLog;
import com.aspirantos.model.AttemptRule;

/**
 * Counts attempts and picks the attempt limit.
 *
 * Row choice: category + PwBD row, then category row, then PwBD row, then the general row.
 * LIFETIME_TOTAL and PER_ROLLING_12_MONTHS rows apply together with the normal row.
 * Attempts used = attempts_used_before_app + journal rows with counts_as_attempt = TRUE
 * (the trigger trg_attempt_log_bi decides counts_as_attempt from the counting rule).
 */
public class AttemptCounter {

    public static final String CONSECUTIVE = "CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM";
    public static final String LIFETIME = "LIFETIME_TOTAL";
    public static final String ROLLING = "PER_ROLLING_12_MONTHS";

    /**
     * @param category        category used for attempt rows (GEN for a non-domicile in a state exam)
     * @param qualifyingYear  year of the qualifying exam (Class 12) for JEE-style windows; may be null
     */
    public AttemptStatus count(CandidateData candidate, List<AttemptRule> rules, String category,
                               LocalDate today, Integer qualifyingYear) {
        AttemptStatus st = new AttemptStatus();
        boolean pwbd = candidate.isBenchmarkPwbd();

        List<AttemptRule> normal = new ArrayList<>();
        List<AttemptRule> lifetime = new ArrayList<>();
        List<AttemptRule> rolling = new ArrayList<>();
        for (AttemptRule r : rules) {
            if (LIFETIME.equals(r.getCountingRule())) {
                lifetime.add(r);
            } else if (ROLLING.equals(r.getCountingRule())) {
                rolling.add(r);
            } else {
                normal.add(r);
            }
        }
        st.setMainRule(mostSpecific(normal, category, pwbd));
        st.setLifetimeRule(mostSpecific(lifetime, category, pwbd));
        st.setRollingRule(mostSpecific(rolling, category, pwbd));

        // attempts used
        int journal = 0;
        List<LocalDate> datedAttempts = new ArrayList<>();
        for (AttemptLog log : candidate.getAttemptLogs()) {
            if (log.isCountsAsAttempt()) {
                journal++;
                if (log.getAttemptDate() != null) {
                    datedAttempts.add(log.getAttemptDate());
                }
            }
        }
        st.setUsedBeforeApp(candidate.getAttemptsBeforeApp());
        st.setUsedInJournal(journal);
        st.setUsed(candidate.getAttemptsBeforeApp() + journal);

        AttemptRule main = st.getMainRule();
        if (main != null && main.getMaxAttempts() != null) {
            st.setMaxAttempts(main.getMaxAttempts());
            st.setRemaining(Math.max(0, main.getMaxAttempts() - st.getUsed()));
            if (st.getRemaining() == 0) {
                st.setExhausted(true);
            }
        }
        if (main != null && CONSECUTIVE.equals(main.getCountingRule()) && qualifyingYear != null
                && main.getWindowYears() != null) {
            st.setWindowFrom(qualifyingYear);
            st.setWindowTo(qualifyingYear + main.getWindowYears() - 1);
        }

        AttemptRule life = st.getLifetimeRule();
        if (life != null && life.getMaxAttempts() != null) {
            st.setLifetimeRemaining(Math.max(0, life.getMaxAttempts() - st.getUsed()));
            if (st.getLifetimeRemaining() == 0) {
                st.setExhausted(true);
            }
            if (st.getMaxAttempts() == null) {
                st.setMaxAttempts(life.getMaxAttempts());
                st.setRemaining(st.getLifetimeRemaining());
            }
        }

        AttemptRule roll = st.getRollingRule();
        if (roll != null) {
            st.setNextRetestDate(nextRetestDate(roll, datedAttempts, today, st));
        }
        return st;
    }

    /**
     * Rolling rule: at most max_attempts in any 12 months and min_gap_days between two tests.
     * Returns null when the student may test today.
     */
    private LocalDate nextRetestDate(AttemptRule roll, List<LocalDate> dates, LocalDate today, AttemptStatus st) {
        List<LocalDate> inWindow = new ArrayList<>();
        LocalDate windowStart = today.minusYears(1);
        LocalDate last = null;
        for (LocalDate d : dates) {
            if (d.isAfter(windowStart) && !d.isAfter(today)) {
                inWindow.add(d);
            }
            if (!d.isAfter(today) && (last == null || d.isAfter(last))) {
                last = d;
            }
        }
        Collections.sort(inWindow);
        st.setUsedLast12Months(inWindow.size());

        LocalDate next = null;
        if (roll.getMaxAttempts() != null && inWindow.size() >= roll.getMaxAttempts()) {
            // the oldest test that has to leave the 12-month window
            LocalDate oldest = inWindow.get(inWindow.size() - roll.getMaxAttempts());
            next = oldest.plusYears(1);
        }
        if (roll.getMinGapDays() != null && last != null) {
            LocalDate gapEnd = last.plusDays(roll.getMinGapDays());
            if (next == null || gapEnd.isAfter(next)) {
                next = gapEnd;
            }
        }
        if (next != null && !next.isAfter(today)) {
            return null;
        }
        return next;
    }

    /** Category + PwBD (3), category (2), PwBD (1), general (0); rows that do not match are ignored. */
    private AttemptRule mostSpecific(List<AttemptRule> rows, String category, boolean pwbd) {
        AttemptRule best = null;
        int bestScore = -1;
        for (AttemptRule r : rows) {
            if (r.getCategory() != null && !r.getCategory().equals(category)) {
                continue;
            }
            if (r.getPwbd() != null && r.getPwbd() != pwbd) {
                continue;
            }
            int score = (r.getCategory() != null ? 2 : 0) + (r.getPwbd() != null ? 1 : 0);
            if (score > bestScore) {
                best = r;
                bestScore = score;
            }
        }
        return best;
    }
}
