package com.aspirantos.util;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Locale;

/**
 * Date helpers used by pages and the eligibility engine.
 * Display format in the UI: 15-Jan-2027. Form inputs (type="date") send yyyy-MM-dd.
 */
public class DateUtil {

    private static final DateTimeFormatter DISPLAY = DateTimeFormatter.ofPattern("dd-MMM-yyyy", Locale.ENGLISH);
    private static final DateTimeFormatter DISPLAY_TIME = DateTimeFormatter.ofPattern("dd-MMM-yyyy hh:mm a", Locale.ENGLISH);
    private static final DateTimeFormatter FORM_STYLE = DateTimeFormatter.ofPattern("dd/MM/yyyy", Locale.ENGLISH);

    /** 2027-01-15 -> "15-Jan-2027"; null -> "". */
    public static String format(LocalDate date) {
        return date == null ? "" : date.format(DISPLAY);
    }

    /** Date and time for logs and notifications. */
    public static String format(LocalDateTime dateTime) {
        return dateTime == null ? "" : dateTime.format(DISPLAY_TIME);
    }

    /** 2027-01-15 -> "15/01/2027" (the way application forms ask for it). */
    public static String formatDmy(LocalDate date) {
        return date == null ? "" : date.format(FORM_STYLE);
    }

    /** Value for <input type="date">: yyyy-MM-dd; null -> "". */
    public static String toInput(LocalDate date) {
        return date == null ? "" : date.toString();
    }

    /** Parses yyyy-MM-dd from a form; blank or invalid text -> null. */
    public static LocalDate parse(String text) {
        if (text == null || text.trim().isEmpty()) {
            return null;
        }
        try {
            return LocalDate.parse(text.trim());
        } catch (DateTimeParseException e) {
            return null;
        }
    }

    /** java.sql.Date from JDBC -> LocalDate (null stays null). */
    public static LocalDate toLocalDate(java.sql.Date date) {
        return date == null ? null : date.toLocalDate();
    }

    /** java.sql.Timestamp from JDBC -> LocalDateTime (null stays null). */
    public static LocalDateTime toLocalDateTime(java.sql.Timestamp ts) {
        return ts == null ? null : ts.toLocalDateTime();
    }

    /** Completed years between two dates (age on a cut-off date). */
    public static int completedYears(LocalDate from, LocalDate to) {
        return Period.between(from, to).getYears();
    }

    /** "29 years 4 months 12 days" - the exact age shown on the eligibility page. */
    public static String describeAge(LocalDate dob, LocalDate on) {
        Period p = Period.between(dob, on);
        return p.getYears() + " years " + p.getMonths() + " months " + p.getDays() + " days";
    }
}
