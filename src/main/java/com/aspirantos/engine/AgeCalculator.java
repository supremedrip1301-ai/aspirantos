package com.aspirantos.engine;

import java.time.LocalDate;
import java.time.Period;

import com.aspirantos.model.AgeRule;

/**
 * Age arithmetic of the engine.
 *
 * Completed age uses java.time.Period, so a person born on 29-Feb completes a year
 * on 1-Mar in a non-leap year (Period.between(2004-02-29, 2025-02-28) = 20 years).
 *
 * Upper-age semantics:
 *   NOT_ATTAINED  "must not have attained 32" -> completed age must be below 32 (at most 31)
 *   NOT_MORE_THAN "not more than 32"          -> completed age may be 32
 */
public class AgeCalculator {

    public static final String NOT_ATTAINED = "NOT_ATTAINED";

    /** Completed years on a date. */
    public static int ageOn(LocalDate dob, LocalDate on) {
        return Period.between(dob, on).getYears();
    }

    /** "29 years 4 months 12 days" */
    public static String describeAge(LocalDate dob, LocalDate on) {
        Period p = Period.between(dob, on);
        return p.getYears() + (p.getYears() == 1 ? " year " : " years ")
                + p.getMonths() + (p.getMonths() == 1 ? " month " : " months ")
                + p.getDays() + (p.getDays() == 1 ? " day" : " days");
    }

    /** Cut-off date of a cycle for fixed-date rules; null for DOB_WINDOW / NONE. */
    public static LocalDate cutoffDate(AgeRule rule, int cycleYear) {
        if (rule == null || rule.getCutoffMonth() == null || rule.getCutoffDay() == null) {
            return null;
        }
        int year;
        if ("FIXED_DATE_IN_CYCLE_YEAR".equals(rule.getCutoffType())) {
            year = cycleYear;
        } else if ("FIXED_DATE_IN_PREVIOUS_YEAR".equals(rule.getCutoffType())) {
            year = cycleYear - 1;
        } else if ("FIXED_DATE_IN_NEXT_YEAR".equals(rule.getCutoffType())) {
            year = cycleYear + 1;
        } else {
            return null;
        }
        return safeDate(year, rule.getCutoffMonth(), rule.getCutoffDay());
    }

    /** DOB_WINDOW: "born on or after" date of a cycle (before relaxation). */
    public static LocalDate windowFrom(AgeRule rule, int cycleYear) {
        if (rule.getDobFromOffsetYears() == null) {
            return null;
        }
        return safeDate(cycleYear + rule.getDobFromOffsetYears(), rule.getDobFromMonth(), rule.getDobFromDay());
    }

    /** DOB_WINDOW: "born on or before" date of a cycle; null = no such limit. */
    public static LocalDate windowTo(AgeRule rule, int cycleYear) {
        if (rule.getDobToOffsetYears() == null) {
            return null;
        }
        return safeDate(cycleYear + rule.getDobToOffsetYears(), rule.getDobToMonth(), rule.getDobToDay());
    }

    /** Upper-limit comparison with the right semantics. */
    public static boolean withinUpperLimit(int completedAge, int maxAge, String semantics) {
        if (NOT_ATTAINED.equals(semantics)) {
            return completedAge < maxAge;
        }
        return completedAge <= maxAge;
    }

    /** First date on which the candidate is too old: the birthday of maxAge (NOT_ATTAINED) or maxAge + 1. */
    public static LocalDate dateLimitCrossed(LocalDate dob, int maxAge, String semantics) {
        return NOT_ATTAINED.equals(semantics) ? dob.plusYears(maxAge) : dob.plusYears(maxAge + 1);
    }

    /** Earliest allowed date of birth for a cut-off date and upper limit. */
    public static LocalDate earliestDob(LocalDate cutoff, int maxAge, String semantics) {
        int years = NOT_ATTAINED.equals(semantics) ? maxAge : maxAge + 1;
        return cutoff.minusYears(years).plusDays(1);
    }

    /** Latest allowed date of birth for a minimum age (the candidate must have completed minAge). */
    public static LocalDate latestDob(LocalDate cutoff, int minAge) {
        return cutoff.minusYears(minAge);
    }

    /** "must not have attained 32" / "must not be more than 32" */
    public static String describeUpperLimit(int maxAge, String semantics) {
        if (NOT_ATTAINED.equals(semantics)) {
            return "below " + maxAge + " (must not have attained " + maxAge + ")";
        }
        return "at most " + maxAge;
    }

    /** 29 February in a non-leap year becomes 28 February. */
    private static LocalDate safeDate(int year, int month, int day) {
        LocalDate first = LocalDate.of(year, month, 1);
        return first.withDayOfMonth(Math.min(day, first.lengthOfMonth()));
    }
}
