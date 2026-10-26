package com.aspirantos.util;

import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

import com.aspirantos.model.ExamEvent;

/**
 * Hand-written iCalendar (.ics, RFC 5545) text for exam dates, so they can be imported into
 * Google Calendar or Outlook - no library. Every exam date is an all-day event
 * (DTSTART;VALUE=DATE, DTEND = next day). Lines end with CRLF and long lines are folded.
 */
public class IcsUtil {

    private static final DateTimeFormatter DAY = DateTimeFormatter.ofPattern("yyyyMMdd");
    private static final DateTimeFormatter STAMP = DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmmss'Z'");

    public static String calendar(List<ExamEvent> events) {
        String stamp = ZonedDateTime.now(ZoneOffset.UTC).format(STAMP);
        StringBuilder sb = new StringBuilder();
        line(sb, "BEGIN:VCALENDAR");
        line(sb, "VERSION:2.0");
        line(sb, "PRODID:-//AspirantOS//Exam calendar//EN");
        line(sb, "CALSCALE:GREGORIAN");
        line(sb, "METHOD:PUBLISH");
        line(sb, "X-WR-CALNAME:AspirantOS exam dates");
        for (ExamEvent ev : events) {
            LocalDate d = ev.getEventDate();
            line(sb, "BEGIN:VEVENT");
            line(sb, "UID:aspirantos-event-" + ev.getId() + "@aspirantos.in");
            line(sb, "DTSTAMP:" + stamp);
            line(sb, "DTSTART;VALUE=DATE:" + d.format(DAY));
            line(sb, "DTEND;VALUE=DATE:" + d.plusDays(1).format(DAY));
            line(sb, "SUMMARY:" + escape(ev.getExamShortName() + " - " + eventLabel(ev.getEventType())));
            line(sb, "DESCRIPTION:" + escape(ev.getExamShortName() + " " + ev.getCycleYear() + ": " + eventLabel(ev.getEventType())
                    + (ev.isTentative() ? ". Tentative date - confirm with the official notification." : ". Date from the official calendar.")
                    + (ev.getNotes() != null ? " " + ev.getNotes() : "")));
            line(sb, "TRANSP:TRANSPARENT");
            line(sb, "END:VEVENT");
        }
        line(sb, "END:VCALENDAR");
        return sb.toString();
    }

    public static String eventLabel(String type) {
        switch (type) {
            case "NOTIFICATION": return "Notification";
            case "APPLY_START": return "Applications open";
            case "APPLY_END": return "Last date to apply";
            case "ADMIT_CARD": return "Admit card";
            case "STAGE_1": return "First stage / prelims";
            case "STAGE_2": return "Second stage / mains";
            case "STAGE_3": return "Third stage / interview";
            default: return "Result";
        }
    }

    /** Text values: backslash, semicolon, comma and line breaks must be escaped. */
    static String escape(String s) {
        return s.replace("\\", "\\\\").replace(";", "\\;").replace(",", "\\,").replace("\r", "").replace("\n", "\\n");
    }

    /** Adds one content line, folded after 75 octets (continuation lines start with a space). */
    private static void line(StringBuilder sb, String text) {
        byte[] bytes = text.getBytes(StandardCharsets.UTF_8);
        if (bytes.length <= 75) {
            sb.append(text).append("\r\n");
            return;
        }
        StringBuilder part = new StringBuilder();
        int octets = 0;
        int limit = 75;
        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            int size = String.valueOf(c).getBytes(StandardCharsets.UTF_8).length;
            if (octets + size > limit) {
                sb.append(part).append("\r\n ");
                part.setLength(0);
                octets = 0;
                limit = 74;   // the leading space counts
            }
            part.append(c);
            octets += size;
        }
        sb.append(part).append("\r\n");
    }
}
