package com.aspirantos.service;

import java.time.LocalDate;

import com.aspirantos.model.AgeRule;
import com.aspirantos.model.AttemptRule;
import com.aspirantos.model.OtherRule;
import com.aspirantos.model.QualificationRule;
import com.aspirantos.model.RelaxationRule;
import com.aspirantos.util.ValidationUtil;

/**
 * Server-side checks of one rule row, shared by the rule editor (admin/rule-action.jsp) and the
 * rule pack import (RulePackParser). Each method returns the first problem in plain words, or
 * null when the row is valid; it also clears fields that do not belong to the chosen type
 * (for example the cut-off date of a birth-date window rule).
 */
public class RuleValidator {

    private static final String[] CATEGORIES = {"GEN", "EWS", "OBC_NCL", "SC", "ST"};

    public static String age(AgeRule r) {
        boolean fixed = r.getCutoffType() != null && r.getCutoffType().startsWith("FIXED_DATE");
        if (!ValidationUtil.isOneOf(r.getCutoffType(), "FIXED_DATE_IN_CYCLE_YEAR", "FIXED_DATE_IN_PREVIOUS_YEAR", "FIXED_DATE_IN_NEXT_YEAR", "DOB_WINDOW", "NONE")
                || !ValidationUtil.isOneOf(r.getMaxAgeSemantics(), "NOT_ATTAINED", "NOT_MORE_THAN")) {
            return "Please choose how the age is counted (cutoff_type, max_age_semantics).";
        }
        if (!okRange(r.getMinAge(), 0, 80) || !okRange(r.getMaxAge(), 0, 80)) {
            return "Ages must be between 0 and 80.";
        }
        if (r.getMinAge() != null && r.getMaxAge() != null && r.getMaxAge() < r.getMinAge()) {
            return "The upper age cannot be below the minimum age.";
        }
        if (fixed && !okDay(r.getCutoffMonth(), r.getCutoffDay())) {
            return "A cut-off date rule needs a valid month and day.";
        }
        if ("DOB_WINDOW".equals(r.getCutoffType())
                && (r.getDobFromOffsetYears() == null || !okRange(r.getDobFromOffsetYears(), -100, 0) || !okDay(r.getDobFromMonth(), r.getDobFromDay()))) {
            return "A birth-date window needs the 'born on or after' year offset (for example -25), month and day.";
        }
        if ("DOB_WINDOW".equals(r.getCutoffType()) && r.getDobToOffsetYears() != null
                && (!okRange(r.getDobToOffsetYears(), -100, 0) || !okDay(r.getDobToMonth(), r.getDobToDay()))) {
            return "The 'born on or before' part needs a year offset, month and day (or leave all three empty).";
        }
        if (!okLength(r.getPostOrCourse(), 120) || !okLength(r.getNotes(), 500)) {
            return "Post: at most 120 characters, notes: at most 500.";
        }
        if (!fixed) {
            r.setCutoffMonth(null);
            r.setCutoffDay(null);
        }
        if (!"DOB_WINDOW".equals(r.getCutoffType())) {
            r.setDobFromOffsetYears(null);
            r.setDobFromMonth(null);
            r.setDobFromDay(null);
            r.setDobToOffsetYears(null);
            r.setDobToMonth(null);
            r.setDobToDay(null);
        } else if (r.getDobToOffsetYears() == null) {
            r.setDobToMonth(null);
            r.setDobToDay(null);
        }
        return null;
    }

    public static String relaxation(RelaxationRule r) {
        if (!ValidationUtil.isOneOf(r.getRelaxationType(), "CATEGORY", "PWBD", "EX_SERVICEMAN", "JK_DOMICILE_1980_89", "GOVT_EMPLOYEE",
                                    "WOMEN", "WIDOW_DIVORCED_WOMEN", "TRANSGENDER", "STATE_DOMICILE")
                || !ValidationUtil.isOneOf(r.getStacking(), "ADD", "ADD_AFTER_SERVICE_DEDUCTION", "REPLACE_WITH_MAX")) {
            return "Please choose who gets the relaxation and how it works (relaxation_type, stacking).";
        }
        if (r.getCategory() != null && !ValidationUtil.isOneOf(r.getCategory(), CATEGORIES)) {
            return "Category must be GEN, EWS, OBC_NCL, SC or ST.";
        }
        if ("CATEGORY".equals(r.getRelaxationType()) && r.getCategory() == null) {
            return "A category relaxation needs the category.";
        }
        if (!ValidationUtil.inRange(r.getYears(), 0, 40)) {
            return "Years must be between 0 and 40.";
        }
        if (!okRange(r.getOverallMaxAgeCap(), 18, 70)) {
            return "The age cap must be between 18 and 70.";
        }
        if ("REPLACE_WITH_MAX".equals(r.getStacking()) && r.getOverallMaxAgeCap() == null && r.getYears() == 0) {
            return "An 'up to' relaxation needs years, or an age cap that raises the limit.";
        }
        if (!okLength(r.getNotes(), 500)) {
            return "Notes can be at most 500 characters.";
        }
        return null;
    }

    public static String attempt(AttemptRule r) {
        if (!ValidationUtil.isOneOf(r.getCountingRule(), "APPEARED_IN_FIRST_STAGE", "APPLIED", "PER_SITTING",
                                    "CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM", "PER_ROLLING_12_MONTHS", "LIFETIME_TOTAL")) {
            return "Please choose what counts as an attempt (counting_rule).";
        }
        if (r.getCategory() != null && !ValidationUtil.isOneOf(r.getCategory(), CATEGORIES)) {
            return "Category must be GEN, EWS, OBC_NCL, SC or ST.";
        }
        if (!okRange(r.getMaxAttempts(), 1, 50) || !okRange(r.getWindowYears(), 1, 10) || !okRange(r.getMinGapDays(), 1, 365)) {
            return "Attempts 1 to 50, window 1 to 10 years, gap 1 to 365 days.";
        }
        if ("CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM".equals(r.getCountingRule()) && r.getWindowYears() == null) {
            return "The Class 12 window rule needs the number of window years.";
        }
        if ("LIFETIME_TOTAL".equals(r.getCountingRule()) && r.getMaxAttempts() == null) {
            return "A lifetime rule needs the maximum number of attempts.";
        }
        if ("PER_ROLLING_12_MONTHS".equals(r.getCountingRule()) && r.getMaxAttempts() == null && r.getMinGapDays() == null) {
            return "A 12-month retake rule needs the maximum number of tests or the days between two tests.";
        }
        if (!okLength(r.getNotes(), 500)) {
            return "Notes can be at most 500 characters.";
        }
        return null;
    }

    public static String qualification(QualificationRule r) {
        if (r.getAcceptedDegrees() == null) {
            r.setAcceptedDegrees("ANY");
        }
        if (r.getRequiredSubjects() != null) {
            r.setRequiredSubjects(r.getRequiredSubjects().toUpperCase().replaceAll("\\s*([,|:])\\s*", "$1"));
        }
        if (r.getRelaxedFor() != null) {
            r.setRelaxedFor(r.getRelaxedFor().toUpperCase().replace(" ", ""));
        }
        if (!ValidationUtil.isOneOf(r.getRequiredLevel(), "NONE", "CLASS_10", "CLASS_12", "DIPLOMA", "UG", "PG", "PHD", "PROFESSIONAL")) {
            return "Please choose the required level (NONE, CLASS_10, CLASS_12, DIPLOMA, UG, PG, PHD or PROFESSIONAL).";
        }
        if (!okLength(r.getAcceptedDegrees(), 500) || !okLength(r.getPostOrCourse(), 120) || !okLength(r.getTextSummary(), 500)) {
            return "Degrees and summary: at most 500 characters, post: at most 120.";
        }
        if (r.getRequiredSubjects() != null && !r.getRequiredSubjects().matches("([A-Z_0-9]+:)?[A-Z0-9 &().|,-]{1,300}")) {
            return "Subjects: words separated by , (all needed) or | (any one), optionally starting with CLASS_12: or CLASS_10:.";
        }
        if (!okRange(r.getMinPercentGeneral(), 0, 100) || !okRange(r.getMinPercentRelaxed(), 0, 100)) {
            return "Percentages must be between 0 and 100.";
        }
        if (r.getMinPercentRelaxed() != null && (r.getMinPercentGeneral() == null || r.getMinPercentRelaxed() > r.getMinPercentGeneral())) {
            return "The relaxed percentage needs a general percentage and cannot be higher than it.";
        }
        if (r.getMinPercentRelaxed() != null && r.getRelaxedFor() == null) {
            return "Say who gets the relaxed percentage (for example SC,ST,PWBD).";
        }
        if (r.getRelaxedFor() != null && !r.getRelaxedFor().matches("[A-Z_]+(,[A-Z_]+)*")) {
            return "Relaxed for: codes separated by commas, for example SC,ST,OBC_NCL,PWBD.";
        }
        if (!okRange(r.getMaxYearsSincePassing(), 0, 20) || !okRange(r.getMinExperienceYears(), 0, 40)) {
            return "Years since passing 0 to 20, experience 0 to 40.";
        }
        return null;
    }

    public static String other(OtherRule r) {
        if (r.getRuleValue() != null) {
            r.setRuleValue(r.getRuleValue().toUpperCase().replace(" ", ""));
        }
        if (!ValidationUtil.isOneOf(r.getRuleType(), "NATIONALITY", "GENDER", "MARITAL_STATUS", "DOMICILE", "PHYSICAL_STANDARD", "REGISTRATION", "OTHER")) {
            return "Please choose the type of condition (rule_type).";
        }
        if (r.getRuleValue() != null && !r.getRuleValue().matches("[A-Z0-9_]+(,[A-Z0-9_]+)*")) {
            return "Value: codes separated by commas, for example UNMARRIED or MALE,FEMALE.";
        }
        if (r.getRuleValue() == null && ValidationUtil.isOneOf(r.getRuleType(), "NATIONALITY", "GENDER", "MARITAL_STATUS", "DOMICILE")) {
            return "This type of condition needs a value.";
        }
        if (!okLength(r.getRuleValue(), 200) || !okLength(r.getTextSummary(), 500) || !okLength(r.getPostOrCourse(), 120)) {
            return "Value: at most 200 characters, text: at most 500.";
        }
        return null;
    }

    private static boolean okRange(Number v, double min, double max) {
        return v == null || ValidationUtil.inRange(v, min, max);
    }

    private static boolean okLength(String s, int max) {
        return s == null || s.length() <= max;
    }

    private static boolean okDay(Integer month, Integer day) {
        if (month == null || day == null) {
            return false;
        }
        try {
            LocalDate.of(2024, month, day);   // 2024 is a leap year, so 29 February is allowed
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
