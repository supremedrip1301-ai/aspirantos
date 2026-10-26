package com.aspirantos.engine;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.aspirantos.model.Education;
import com.aspirantos.model.QualificationRule;
import com.aspirantos.model.WorkExperience;
import com.aspirantos.util.DateUtil;

/**
 * Checks the education rows of the student against the qualification rules of one
 * post group (MASTER_PROMPT PART 6, step 6). Several rules for the same group are
 * alternatives - the best one is used (D26).
 *
 * Levels: CLASS_10 < CLASS_12 < UG < PG < PHD. A higher level satisfies a lower
 * requirement; a DIPLOMA satisfies CLASS_10 and DIPLOMA requirements (and a degree
 * satisfies a DIPLOMA requirement); PROFESSIONAL (CA, CS, ...) satisfies only
 * PROFESSIONAL, CLASS_10 and CLASS_12 requirements.
 *
 * Subjects (D27): comma = all required, "|" = any one, "CLASS_12:" prefix = check the
 * Class 12 row. CGPA -> percentage: CGPA / scale x 95 (the CBSE formula CGPA x 9.5 on a
 * 10-point scale); the official conversion of a university may differ.
 */
public class QualificationChecker {

    public QualificationOutcome check(CandidateData candidate, List<QualificationRule> rules, String category,
                                      Integer examMonth, LocalDate today) {
        if (rules == null || rules.isEmpty()) {
            QualificationOutcome o = new QualificationOutcome();
            o.setStatus(QualificationOutcome.PASS);
            o.setLevelWords("no minimum qualification");
            o.getLines().add(new CheckLine("Qualification", CheckLine.INFO, "No qualification rule is recorded for this exam."));
            return o;
        }
        QualificationOutcome best = null;
        for (QualificationRule rule : rules) {
            QualificationOutcome o = checkRule(candidate, rule, category, examMonth, today);
            if (best == null || QualificationOutcome.rank(o) > QualificationOutcome.rank(best)
                    || (QualificationOutcome.rank(o) == QualificationOutcome.rank(best)
                        && earlier(o.getMetFromYear(), best.getMetFromYear()))) {
                best = o;
            }
        }
        return best;
    }

    private boolean earlier(Integer a, Integer b) {
        if (a == null) {
            return b != null;
        }
        return b != null && a < b;
    }

    private QualificationOutcome checkRule(CandidateData c, QualificationRule rule, String category,
                                           Integer examMonth, LocalDate today) {
        String level = rule.getRequiredLevel();
        QualificationOutcome out = new QualificationOutcome();
        out.setRule(rule);
        out.setLevelWords(levelWords(level));
        String summary = rule.getTextSummary() == null ? "" : " (" + rule.getTextSummary() + ")";

        if ("NONE".equals(level)) {
            out.setStatus(QualificationOutcome.PASS);
            out.getLines().add(new CheckLine("Qualification", CheckLine.PASS, "No minimum qualification is needed" + summary + "."));
            return out;
        }

        // rows that reach the level: exact level first, completed rows first
        List<Education> candidates = new ArrayList<>();
        for (int pass = 0; pass < 4; pass++) {
            for (Education e : c.getEducations()) {
                boolean exact = level.equals(e.getLevel());
                boolean completed = !"APPEARING".equals(e.getStatus());
                boolean wanted = (pass == 0 && exact && completed) || (pass == 1 && exact && !completed)
                        || (pass == 2 && !exact && completed) || (pass == 3 && !exact && !completed);
                if (wanted && satisfiesLevel(e.getLevel(), level)) {
                    candidates.add(e);
                }
            }
        }

        if (candidates.isEmpty()) {
            Integer estimate = estimateYear(level, c);
            if (estimate != null && estimate < today.getYear()) {
                estimate = null;   // e.g. Class 12 in 2015 but no degree row: the student is not on that track
            }
            out.setStatus(QualificationOutcome.NOT_YET);
            if (estimate != null) {
                // a degree is assumed to finish in June; without final-year entry the exam must come after that
                boolean sameYear = rule.isFinalYearAllowed() || (examMonth != null && examMonth > 6);
                out.setMetFromYear(sameYear ? estimate : estimate + 1);
                out.setCompletionYear(estimate);
            }
            out.getLines().add(new CheckLine("Qualification", CheckLine.WARN, "You need " + levelWords(level) + summary + ". "
                    + (estimate != null
                        ? "Expected around " + estimate + " (estimated from your education: " + estimateBasis(level) + ")."
                        : "Add your education details to the profile.")));
            return out;
        }

        QualificationOutcome best = null;
        for (Education row : candidates) {
            QualificationOutcome o = checkRow(c, rule, row, category, examMonth, today);
            if (best == null || QualificationOutcome.rank(o.getStatus()) > QualificationOutcome.rank(best.getStatus())) {
                best = o;
            }
        }
        return best;
    }

    private QualificationOutcome checkRow(CandidateData c, QualificationRule rule, Education row, String category,
                                          Integer examMonth, LocalDate today) {
        QualificationOutcome out = new QualificationOutcome();
        out.setRule(rule);
        out.setLevelWords(levelWords(rule.getRequiredLevel()));
        boolean ok = true;
        String summary = rule.getTextSummary() == null ? "" : " (" + rule.getTextSummary() + ")";

        // 1. degree
        String accepted = rule.getAcceptedDegrees();
        if (accepted != null && !accepted.trim().isEmpty() && !"ANY".equalsIgnoreCase(accepted.trim())) {
            if (matchesDegree(row.getDegreeName(), accepted)) {
                out.getLines().add(new CheckLine("Qualification", CheckLine.PASS,
                        "Your " + describeRow(row) + " is an accepted degree" + summary + "."));
            } else {
                ok = false;
                out.setFailReason("this exam accepts only " + accepted);
                out.getLines().add(new CheckLine("Qualification", CheckLine.FAIL,
                        "This exam accepts only " + accepted + "; your " + describeRow(row) + " is not in the list."));
            }
        } else {
            out.getLines().add(new CheckLine("Qualification", CheckLine.PASS,
                    "Your " + describeRow(row) + " meets the requirement of " + levelWords(rule.getRequiredLevel()) + summary + "."));
        }

        // 2. subjects
        Education prefixRow = null;
        String subjects = rule.getRequiredSubjects();
        if (subjects != null && !subjects.trim().isEmpty()) {
            Education subjectRow = row;
            String where = "your " + levelWords(row.getLevel());
            int colon = subjects.indexOf(':');
            if (colon > 0) {
                String prefixLevel = subjects.substring(0, colon).trim();
                subjects = subjects.substring(colon + 1);
                prefixRow = findRow(c, prefixLevel);
                subjectRow = prefixRow;
                where = "your " + levelWords(prefixLevel);
            } else if (isSchoolLevel(rule.getRequiredLevel()) && !rule.getRequiredLevel().equals(row.getLevel())) {
                // Class 10 / Class 12 subjects are checked on that row, not on a degree row
                subjectRow = findRow(c, rule.getRequiredLevel());
                where = "your " + levelWords(rule.getRequiredLevel());
            }
            if (subjectRow == null) {
                ok = false;
                out.setFailReason("the required subjects of " + where.substring(5) + " cannot be checked - add your "
                        + where.substring(5) + " details");
                out.getLines().add(new CheckLine("Subjects", CheckLine.FAIL,
                        "Needs " + prettySubjects(subjects) + " in " + where.substring(5) + " - add your "
                        + where.substring(5) + " details to the profile."));
            } else {
                List<String> missing = missingSubjects(subjectRow, subjects);
                if (missing.isEmpty()) {
                    out.getLines().add(new CheckLine("Subjects", CheckLine.PASS,
                            "Required subjects " + prettySubjects(subjects) + " found in " + where + "."));
                } else {
                    ok = false;
                    out.setFailReason(missing.size() == 1 && missing.get(0).length() <= 40
                            ? missing.get(0) + " is required in " + where
                            : "the required subjects are missing in " + where);
                    out.getLines().add(new CheckLine("Subjects", CheckLine.FAIL,
                            "Required subjects: " + prettySubjects(subjects) + ". Missing in " + where + ": "
                            + String.join(", ", missing) + "."));
                }
            }
        }

        // 3. minimum percentage
        if (rule.getMinPercentGeneral() != null) {
            boolean relaxed = rule.getMinPercentRelaxed() != null && isRelaxed(rule.getRelaxedFor(), category, c);
            double need = relaxed ? rule.getMinPercentRelaxed() : rule.getMinPercentGeneral();
            Education markRow = prefixRow != null ? prefixRow : row;
            String needText = "Needs at least " + trim(need) + "%"
                    + (relaxed ? " (relaxed for you from " + trim(rule.getMinPercentGeneral()) + "%)" : "");
            Double pct = percentOf(markRow);
            if (pct == null) {
                if ("APPEARING".equals(markRow.getStatus())) {
                    out.getLines().add(new CheckLine("Percentage", CheckLine.WARN,
                            needText + "; your result is not out yet, so you must reach it in the final result."));
                } else {
                    out.getLines().add(new CheckLine("Percentage", CheckLine.WARN,
                            needText + " - enter your marks in the profile so it can be checked."));
                }
            } else {
                String have = markRow.getPercentage() != null
                        ? trim(pct) + "%"
                        : "CGPA " + trim(markRow.getCgpa()) + "/" + trim(scaleOf(markRow)) + " = about " + trim(pct)
                          + "% (CGPA / scale x 95; the official conversion may differ)";
                if (pct >= need) {
                    out.getLines().add(new CheckLine("Percentage", CheckLine.PASS, needText + "; you have " + have + "."));
                } else {
                    ok = false;
                    out.setFailReason("you need at least " + trim(need) + "% marks, you have " + trim(pct) + "%");
                    out.getLines().add(new CheckLine("Percentage", CheckLine.FAIL, needText + "; you have " + have + "."));
                }
            }
        }

        // 4. experience
        if (rule.getMinExperienceYears() != null && rule.getMinExperienceYears() > 0) {
            double years = experienceYears(c.getWorkExperiences(), today);
            String text = "Needs " + trim(rule.getMinExperienceYears()) + " years of experience; your profile shows "
                    + trim(Math.floor(years * 10) / 10) + " years.";
            if (years >= rule.getMinExperienceYears()) {
                out.getLines().add(new CheckLine("Experience", CheckLine.PASS, text));
            } else {
                ok = false;
                out.setFailReason("you need " + trim(rule.getMinExperienceYears()) + " years of experience");
                out.getLines().add(new CheckLine("Experience", CheckLine.FAIL, text));
            }
        }

        // 5. years since passing (e.g. JEE: passed Class 12 this year or in the last N years)
        Integer completion = completionYearOf(row);
        if (rule.getMaxYearsSincePassing() != null && completion != null) {
            out.setLastYearAllowed(completion + rule.getMaxYearsSincePassing());
            out.getLines().add(new CheckLine("Qualification", CheckLine.INFO,
                    "Candidates must apply within " + rule.getMaxYearsSincePassing() + " year(s) of passing "
                    + levelWords(row.getLevel()) + "; you passed / will pass in " + completion
                    + ", so the last year for you is " + out.getLastYearAllowed() + "."));
        }

        if (!ok) {
            out.setStatus(QualificationOutcome.FAIL);
        } else if (!"APPEARING".equals(row.getStatus())) {
            out.setStatus(QualificationOutcome.PASS);
        } else if (rule.isFinalYearAllowed()) {
            out.setStatus(QualificationOutcome.PROVISIONAL);
            out.setCompletionYear(completion);
            out.setMetFromYear(completion);
            out.setPassBy(row.getExpectedCompletionDate());
            out.getLines().add(new CheckLine("Qualification", CheckLine.WARN,
                    "Provisional: final-year candidates may apply, but you must pass by "
                    + (row.getExpectedCompletionDate() != null
                        ? DateUtil.format(row.getExpectedCompletionDate())
                        : "the date given in the notification") + "."));
        } else {
            int month = row.getExpectedCompletionDate() != null ? row.getExpectedCompletionDate().getMonthValue() : 6;
            boolean sameYear = completion != null && examMonth != null && month < examMonth;
            out.setCompletionYear(completion);
            if (sameYear) {
                // the result comes before this year's exam: usable in the same year once passed
                out.setStatus(QualificationOutcome.PROVISIONAL);
                out.setMetFromYear(completion);
                out.setPassBy(row.getExpectedCompletionDate());
                out.getLines().add(new CheckLine("Qualification", CheckLine.WARN,
                        "Final-year candidates cannot apply, but your result (expected "
                        + (row.getExpectedCompletionDate() != null ? DateUtil.format(row.getExpectedCompletionDate()) : String.valueOf(completion))
                        + ") comes before this exam, so you can apply for " + completion + " once you have passed."));
            } else {
                out.setStatus(QualificationOutcome.NOT_YET);
                if (completion != null) {
                    out.setMetFromYear(completion + 1);
                }
                out.getLines().add(new CheckLine("Qualification", CheckLine.WARN,
                        "Final-year candidates cannot apply for this exam; you can apply after you pass"
                        + (completion != null ? " (expected " + completion + ")" : "") + "."));
            }
        }
        return out;
    }

    // ---------------------------------------------------------------- helpers

    /** Does an education row of rowLevel satisfy a requirement of requiredLevel? */
    public static boolean satisfiesLevel(String rowLevel, String requiredLevel) {
        if (rowLevel == null) {
            return false;
        }
        if (rowLevel.equals(requiredLevel) || "NONE".equals(requiredLevel)) {
            return true;
        }
        if ("PROFESSIONAL".equals(requiredLevel)) {
            return false;
        }
        if ("PROFESSIONAL".equals(rowLevel)) {
            return "CLASS_10".equals(requiredLevel) || "CLASS_12".equals(requiredLevel);
        }
        if ("DIPLOMA".equals(rowLevel)) {
            return "CLASS_10".equals(requiredLevel);
        }
        if ("DIPLOMA".equals(requiredLevel)) {
            return levelRank(rowLevel) >= levelRank("UG");
        }
        return levelRank(rowLevel) >= levelRank(requiredLevel);
    }

    private static boolean isSchoolLevel(String level) {
        return "CLASS_10".equals(level) || "CLASS_12".equals(level);
    }

    private static int levelRank(String level) {
        switch (level) {
            case "CLASS_10":
                return 1;
            case "CLASS_12":
                return 2;
            case "UG":
                return 3;
            case "PG":
                return 4;
            case "PHD":
                return 5;
            default:
                return 0;
        }
    }

    public static String levelWords(String level) {
        if (level == null) {
            return "the qualification";
        }
        switch (level) {
            case "CLASS_10":
                return "Class 10";
            case "CLASS_12":
                return "Class 12";
            case "DIPLOMA":
                return "a diploma";
            case "UG":
                return "graduation";
            case "PG":
                return "post-graduation";
            case "PHD":
                return "a PhD";
            case "PROFESSIONAL":
                return "a professional qualification";
            default:
                return "no minimum qualification";
        }
    }

    /** "B.E." matches "B.E.", "BE" and "B.E. (Civil)"; comparison ignores dots, spaces and case. */
    public static boolean matchesDegree(String degree, String acceptedList) {
        if (degree == null || degree.trim().isEmpty()) {
            return false;
        }
        String d = normDegree(degree);
        for (String a : acceptedList.split(",")) {
            String acc = normDegree(a);
            if (acc.isEmpty()) {
                continue;
            }
            if (d.equals(acc) || d.startsWith(acc + " ") || d.startsWith(acc + "(")) {
                return true;
            }
        }
        return false;
    }

    private static String normDegree(String s) {
        return s.toUpperCase().replace(".", "").replaceAll("\\s+", " ").trim();
    }

    /** Required subject groups that are missing in the row ("BIOLOGY or BIOTECHNOLOGY"). */
    public static List<String> missingSubjects(Education row, String spec) {
        Set<String> have = new HashSet<>();
        if (row.getSubjects() != null) {
            for (String s : row.getSubjects().split(",")) {
                if (!s.trim().isEmpty()) {
                    have.add(normSubject(s));
                }
            }
        }
        String text = " " + normSubject((row.getStreamOrSpecialisation() == null ? "" : row.getStreamOrSpecialisation())
                + " " + (row.getDegreeName() == null ? "" : row.getDegreeName())).replaceAll("[^A-Z0-9]+", " ") + " ";

        List<String> missing = new ArrayList<>();
        for (String group : spec.split(",")) {
            if (group.trim().isEmpty()) {
                continue;
            }
            boolean found = false;
            for (String alt : group.split("\\|")) {
                String s = normSubject(alt);
                if (have.contains(s) || text.contains(" " + s + " ")) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                missing.add(group.trim().replace("|", " or "));
            }
        }
        return missing;
    }

    private static String normSubject(String s) {
        String t = " " + s.toUpperCase().trim().replaceAll("\\s+", " ") + " ";
        t = t.replace(" MATHEMATICS ", " MATHS ").replace(" MATH ", " MATHS ");
        return t.trim();
    }

    private static String prettySubjects(String spec) {
        return spec.trim().replace(",", ", ").replace("|", " or ");
    }

    /** Percentage of a row, or CGPA converted (CGPA / scale x 95); null when no marks are entered. */
    public static Double percentOf(Education row) {
        if (row.getPercentage() != null) {
            return row.getPercentage();
        }
        if (row.getCgpa() != null) {
            return cgpaToPercent(row.getCgpa(), scaleOf(row));
        }
        return null;
    }

    public static double cgpaToPercent(double cgpa, double scale) {
        return Math.round(cgpa / scale * 95 * 100) / 100.0;
    }

    private static double scaleOf(Education row) {
        return row.getCgpaScale() == null || row.getCgpaScale() <= 0 ? 10 : row.getCgpaScale();
    }

    private boolean isRelaxed(String relaxedFor, String category, CandidateData c) {
        if (relaxedFor == null) {
            return false;
        }
        for (String g : relaxedFor.toUpperCase().split(",")) {
            g = g.trim();
            if (g.equals(category) || ("OBC".equals(g) && "OBC_NCL".equals(category))
                    || ("PWBD".equals(g) && c.isBenchmarkPwbd())
                    || ("TRANSGENDER".equals(g) && "TRANSGENDER".equals(c.getProfile().getGender()))
                    || (("WOMEN".equals(g) || "FEMALE".equals(g)) && c.isFemale())) {
                return true;
            }
        }
        return false;
    }

    private static double experienceYears(List<WorkExperience> work, LocalDate today) {
        long days = 0;
        for (WorkExperience w : work) {
            if (w.getStartDate() == null) {
                continue;
            }
            LocalDate end = w.getEndDate() == null || w.getEndDate().isAfter(today) ? today : w.getEndDate();
            if (end.isAfter(w.getStartDate())) {
                days += ChronoUnit.DAYS.between(w.getStartDate(), end);
            }
        }
        return days / 365.25;
    }

    /** Passing year of a completed row, expected year of an appearing row. */
    public static Integer completionYearOf(Education row) {
        if ("APPEARING".equals(row.getStatus()) && row.getExpectedCompletionDate() != null) {
            return row.getExpectedCompletionDate().getYear();
        }
        return row.getPassingYear();
    }

    /** The student's row of exactly this level (completed preferred). */
    public static Education findRow(CandidateData c, String level) {
        Education appearing = null;
        for (Education e : c.getEducations()) {
            if (level.equals(e.getLevel())) {
                if (!"APPEARING".equals(e.getStatus())) {
                    return e;
                }
                appearing = e;
            }
        }
        return appearing;
    }

    private Integer yearOf(CandidateData c, String level) {
        Education e = findRow(c, level);
        return e == null ? null : completionYearOf(e);
    }

    /** Rough year in which a missing level will be reached (3-year degree, 2-year PG). */
    private Integer estimateYear(String level, CandidateData c) {
        Integer y10 = yearOf(c, "CLASS_10");
        Integer y12 = yearOf(c, "CLASS_12");
        Integer yDiploma = yearOf(c, "DIPLOMA");
        Integer yUg = yearOf(c, "UG");
        switch (level) {
            case "CLASS_12":
                return y10 == null ? null : y10 + 2;
            case "UG":
                if (y12 != null) {
                    return y12 + 3;
                }
                if (yDiploma != null) {
                    return yDiploma + 3;
                }
                return y10 == null ? null : y10 + 5;
            case "PG":
                if (yUg != null) {
                    return yUg + 2;
                }
                return y12 == null ? null : y12 + 5;
            default:
                return null;
        }
    }

    private String estimateBasis(String level) {
        switch (level) {
            case "CLASS_12":
                return "Class 12 two years after Class 10";
            case "UG":
                return "a 3-year degree after Class 12";
            case "PG":
                return "a 2-year PG after graduation";
            default:
                return "your education rows";
        }
    }

    /** "B.A. (History), passed 2018" / "B.Sc, final year" */
    public static String describeRow(Education row) {
        StringBuilder sb = new StringBuilder();
        sb.append(row.getDegreeName() != null && !row.getDegreeName().trim().isEmpty()
                ? row.getDegreeName() : levelWords(row.getLevel()));
        if (row.getStreamOrSpecialisation() != null && !row.getStreamOrSpecialisation().trim().isEmpty()) {
            sb.append(" (").append(row.getStreamOrSpecialisation()).append(")");
        }
        if ("APPEARING".equals(row.getStatus())) {
            sb.append(", final year");
        } else if (row.getPassingYear() != null) {
            sb.append(", passed ").append(row.getPassingYear());
        }
        return sb.toString();
    }

    private static String trim(double value) {
        if (value == Math.floor(value)) {
            return String.valueOf((int) value);
        }
        return String.valueOf(Math.round(value * 100) / 100.0);
    }
}
