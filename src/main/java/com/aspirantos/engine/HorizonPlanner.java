package com.aspirantos.engine;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.Exam;
import com.aspirantos.model.ExamEvent;

/**
 * Plans the exam cycles the engine looks at (MASTER_PROMPT PART 6, steps 1 and 8).
 *
 * The next cycle is the first year whose last first-stage sitting has not happened yet
 * on "today". Dates come from exam_event (STAGE_1 rows); without events the 15th of
 * typical_exam_month is assumed (same convention as the tentative events, D40).
 * cycles_per_year: 2 = two sittings a year, 0.5 = once in two years.
 * Exams with no typical month (GRE, GMAT: tests all year round) are open every year.
 */
public class HorizonPlanner {

    /** Sittings in one year: 2 for twice-a-year exams, 1 for yearly and once-in-two-years exams. */
    public static int sittingsPerYear(Exam exam) {
        int s = (int) Math.round(exam.getCyclesPerYear());
        return Math.max(1, Math.min(12, s));
    }

    /** 2 for exams held once in two years, otherwise 1. */
    public static int yearStep(Exam exam) {
        return exam.getCyclesPerYear() > 0 && exam.getCyclesPerYear() < 1 ? (int) Math.round(1 / exam.getCyclesPerYear()) : 1;
    }

    /** Date of the first stage of a cycle (earliest sitting); null when the exam runs all year. */
    public static LocalDate firstStageDate(Exam exam, List<ExamEvent> events, int year) {
        LocalDate first = null;
        if (events != null) {
            for (ExamEvent ev : events) {
                if ("STAGE_1".equals(ev.getEventType()) && ev.getCycleYear() == year && ev.getEventDate() != null
                        && (first == null || ev.getEventDate().isBefore(first))) {
                    first = ev.getEventDate();
                }
            }
        }
        if (first == null && exam.getTypicalExamMonth() != null) {
            first = LocalDate.of(year, exam.getTypicalExamMonth(), 15);
        }
        return first;
    }

    /** Date of the last first-stage sitting of a year; null when the exam runs all year. */
    public static LocalDate lastSittingDate(Exam exam, List<ExamEvent> events, int year) {
        LocalDate last = null;
        if (events != null) {
            for (ExamEvent ev : events) {
                if ("STAGE_1".equals(ev.getEventType()) && ev.getCycleYear() == year && ev.getEventDate() != null
                        && (last == null || ev.getEventDate().isAfter(last))) {
                    last = ev.getEventDate();
                }
            }
        }
        if (last == null && exam.getTypicalExamMonth() != null) {
            int sittings = sittingsPerYear(exam);
            int month = exam.getTypicalExamMonth() + (sittings - 1) * (12 / sittings);
            last = LocalDate.of(year, Math.min(12, month), 15);
        }
        return last;
    }

    /** First cycle year that is still ahead on "today". */
    public static int nextCycleYear(Exam exam, List<ExamEvent> events, LocalDate today) {
        int year = today.getYear();
        LocalDate last = lastSittingDate(exam, events, year);
        if (last != null && last.isBefore(today)) {
            year++;
        }
        if (yearStep(exam) > 1 && events != null) {
            // once-in-two-years exams: trust a future event if there is one
            Integer eventYear = null;
            for (ExamEvent ev : events) {
                if ("STAGE_1".equals(ev.getEventType()) && ev.getEventDate() != null && !ev.getEventDate().isBefore(today)
                        && (eventYear == null || ev.getCycleYear() < eventYear)) {
                    eventYear = ev.getCycleYear();
                }
            }
            if (eventYear != null && eventYear >= year) {
                year = eventYear;
            }
        }
        return year;
    }

    /** The cycle years to check: the next cycle and the following ones (upcoming_cycles_to_plan). */
    public static List<Integer> planYears(Exam exam, List<ExamEvent> events, LocalDate today, int cycles) {
        List<Integer> years = new ArrayList<>();
        int year = nextCycleYear(exam, events, today);
        int step = yearStep(exam);
        for (int i = 0; i < Math.max(1, cycles); i++) {
            years.add(year + i * step);
        }
        return years;
    }
}
