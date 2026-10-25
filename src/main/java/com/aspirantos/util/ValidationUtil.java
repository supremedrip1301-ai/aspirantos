package com.aspirantos.util;

/**
 * Server-side form validation used by the action JSPs - the same checks as in
 * StudentServlet / EmployeeServlet of the lab (trim(), isEmpty(), matches(regex),
 * Integer.parseInt in try/catch). The browser checks the same rules with HTML5 attributes
 * and JavaScript, but the server is the authority.
 */
public class ValidationUtil {

    /** null or only spaces. */
    public static boolean isBlank(String text) {
        return text == null || text.trim().isEmpty();
    }

    /** Trimmed text, or null when blank (so empty form fields become NULL in the database). */
    public static String clean(String text) {
        return isBlank(text) ? null : text.trim();
    }

    /** Letters, spaces, dot and apostrophe, 3 to 100 characters (names). */
    public static boolean isValidName(String name) {
        return name != null && name.trim().matches("[A-Za-z .']{3,100}");
    }

    /** Same e-mail pattern as StudentServlet in Experiment 4, plus a dot in the domain. */
    public static boolean isValidEmail(String email) {
        return email != null && email.trim().length() <= 150
                && email.trim().matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    }

    /** Exactly 10 digits (Indian mobile number). */
    public static boolean isValidPhone(String phone) {
        return phone != null && phone.trim().matches("\\d{10}");
    }

    /** 6-digit PIN code not starting with 0. */
    public static boolean isValidPincode(String pincode) {
        return pincode != null && pincode.trim().matches("[1-9]\\d{5}");
    }

    /** At least 8 characters with at least one letter and one digit. */
    public static boolean isValidPassword(String password) {
        return password != null && password.length() >= 8 && password.length() <= 64
                && password.matches(".*[A-Za-z].*") && password.matches(".*\\d.*");
    }

    /** Integer from a form field, or null when blank / not a number. */
    public static Integer parseIntOrNull(String text) {
        if (isBlank(text)) {
            return null;
        }
        try {
            return Integer.parseInt(text.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /** Decimal number from a form field, or null when blank / not a number. */
    public static Double parseDoubleOrNull(String text) {
        if (isBlank(text)) {
            return null;
        }
        try {
            return Double.parseDouble(text.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /** True when the value is one of the allowed values (for ENUM columns such as category). */
    public static boolean isOneOf(String value, String... allowed) {
        if (value == null) {
            return false;
        }
        for (String a : allowed) {
            if (a.equals(value)) {
                return true;
            }
        }
        return false;
    }

    /** Value between min and max (inclusive); null is not valid. */
    public static boolean inRange(Number value, double min, double max) {
        return value != null && value.doubleValue() >= min && value.doubleValue() <= max;
    }
}
