package com.aspirantos.util;

/**
 * Safe output in JSP pages. Every value typed by a user is printed through escape()
 * (e.g. <%= HtmlUtil.escape(user.getFullName()) %>) so that text like "<script>" is shown
 * as text and never runs in the browser (protection against XSS).
 */
public class HtmlUtil {

    /** Replaces the five HTML special characters; null becomes an empty string. */
    public static String escape(String text) {
        if (text == null) {
            return "";
        }
        StringBuilder sb = new StringBuilder(text.length() + 16);
        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            switch (c) {
                case '<':
                    sb.append("&lt;");
                    break;
                case '>':
                    sb.append("&gt;");
                    break;
                case '&':
                    sb.append("&amp;");
                    break;
                case '"':
                    sb.append("&quot;");
                    break;
                case '\'':
                    sb.append("&#39;");
                    break;
                default:
                    sb.append(c);
            }
        }
        return sb.toString();
    }

    /** escape() of any object (numbers, dates); null becomes an empty string. */
    public static String escape(Object value) {
        return value == null ? "" : escape(String.valueOf(value));
    }

    /** The value, or the fallback when the value is null or blank (already escaped). */
    public static String orDash(Object value) {
        if (value == null || String.valueOf(value).trim().isEmpty()) {
            return "&ndash;";
        }
        return escape(value);
    }

    /** "selected" when both values are equal - for <option> tags in edit forms. */
    public static String selected(Object current, String option) {
        return option != null && current != null && option.equals(String.valueOf(current)) ? "selected" : "";
    }

    /** "checked" when the condition is true - for radio buttons and check boxes. */
    public static String checked(boolean condition) {
        return condition ? "checked" : "";
    }
}
