package com.aspirantos.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.aspirantos.dao.ExamDAO;
import com.aspirantos.engine.ExamRuleSet;
import com.aspirantos.model.AgeRule;
import com.aspirantos.model.AttemptRule;
import com.aspirantos.model.Exam;
import com.aspirantos.model.OtherRule;
import com.aspirantos.model.QualificationRule;
import com.aspirantos.model.RelaxationRule;
import com.aspirantos.util.ValidationUtil;

/**
 * Rule pack CSV (MASTER_PROMPT PART 8, part 3; format in docs/RULE_PACK_FORMAT.md).
 * One line = one rule row of one exam; the columns that do not belong to the row's
 * rule_table stay empty. The rows of an exam together form its complete new rule version.
 * Plain Java, no CSV library: fields may be quoted with " and a "" inside quotes is one ".
 */
public class RulePackParser {

    public static final String[] COLUMNS = {
        "exam_code", "rule_table", "post_or_course",
        "min_age", "max_age", "max_age_semantics", "cutoff_type", "cutoff_month", "cutoff_day",
        "dob_from_offset_years", "dob_from_month", "dob_from_day", "dob_to_offset_years", "dob_to_month", "dob_to_day",
        "relaxation_type", "category", "years", "stacking", "overall_max_age_cap", "requires_state_domicile",
        "is_pwbd", "max_attempts", "counting_rule", "window_years", "min_gap_days",
        "required_level", "accepted_degrees", "required_subjects", "min_percent_general", "min_percent_relaxed",
        "relaxed_for", "final_year_allowed", "max_years_since_passing", "min_experience_years",
        "rule_type", "rule_value", "is_blocking", "notes"
    };

    /** One CSV line after parsing. */
    public static class PackRow {
        public int lineNo;
        public String examCode;
        public String table;
        public Object rule;      // AgeRule, RelaxationRule, AttemptRule, QualificationRule or OtherRule
        public String error;     // null = valid
    }

    /** The whole pack: every row, plus the valid rows grouped into one rule set per exam. */
    public static class RulePack {
        public List<PackRow> rows = new ArrayList<>();
        public Map<String, ExamRuleSet> byExam = new LinkedHashMap<>();
        public List<String> problems = new ArrayList<>();   // file-level problems (header ...)

        public int errorCount() {
            int n = problems.size();
            for (PackRow r : rows) {
                if (r.error != null) {
                    n++;
                }
            }
            return n;
        }
    }

    public RulePack parse(String text) {
        RulePack pack = new RulePack();
        if (text == null || text.trim().isEmpty()) {
            pack.problems.add("The rule pack is empty.");
            return pack;
        }
        // skip a byte order mark (Excel writes one) or any other invisible character before the header
        int first = 0;
        while (first < text.length() && !Character.isLetterOrDigit(text.charAt(first)) && text.charAt(first) != '#') {
            first++;
        }
        text = text.substring(first);
        String[] lines = text.split("\r\n|\n|\r");
        Map<String, Integer> col = null;
        Map<String, Exam> exams = new HashMap<>();
        ExamDAO examDAO = new ExamDAO();

        for (int i = 0; i < lines.length; i++) {
            String line = lines[i];
            if (line.trim().isEmpty() || line.trim().startsWith("#")) {
                continue;
            }
            List<String> cells = splitCsvLine(line);
            if (col == null) {                       // first real line = header
                col = new HashMap<>();
                for (int c = 0; c < cells.size(); c++) {
                    col.put(cells.get(c).trim().toLowerCase().replaceAll("[^a-z0-9_]", ""), c);
                }
                if (!col.containsKey("exam_code") || !col.containsKey("rule_table")) {
                    pack.problems.add("Line " + (i + 1) + ": the header must contain at least exam_code and rule_table.");
                    return pack;
                }
                continue;
            }
            if (pack.rows.size() >= 5000) {
                pack.problems.add("A rule pack can have at most 5000 rows.");
                break;
            }
            PackRow row = new PackRow();
            row.lineNo = i + 1;
            row.examCode = upper(cell(cells, col, "exam_code"));
            row.table = upper(cell(cells, col, "rule_table"));
            pack.rows.add(row);

            Exam exam = row.examCode == null ? null : exams.get(row.examCode);
            if (exam == null && row.examCode != null) {
                exam = examDAO.getExamByCode(row.examCode);
                if (exam != null) {
                    exams.put(row.examCode, exam);
                }
            }
            if (exam == null) {
                row.error = "Unknown exam code " + (row.examCode == null ? "(empty)" : row.examCode) + ".";
                continue;
            }
            try {
                row.error = build(row, cells, col);
            } catch (NumberFormatException e) {
                row.error = "A number column contains text: " + e.getMessage();
            }
            if (row.error == null) {
                ExamRuleSet rs = pack.byExam.get(row.examCode);
                if (rs == null) {
                    rs = new ExamRuleSet(exam, 0);
                    pack.byExam.put(row.examCode, rs);
                }
                add(rs, row.rule);
            }
        }
        if (col == null) {
            pack.problems.add("No header line found.");
        } else if (pack.rows.isEmpty()) {
            pack.problems.add("The pack has a header but no rule rows.");
        }
        return pack;
    }

    /** Creates the rule object of one line and validates it; returns the problem or null. */
    private String build(PackRow row, List<String> c, Map<String, Integer> col) {
        String post = cell(c, col, "post_or_course");
        String notes = cell(c, col, "notes");
        if (row.table == null) {
            return "rule_table is empty.";
        }
        switch (row.table) {
            case "AGE": {
                AgeRule r = new AgeRule();
                r.setPostOrCourse(post);
                r.setMinAge(integer(c, col, "min_age"));
                r.setMaxAge(integer(c, col, "max_age"));
                r.setMaxAgeSemantics(upper(cell(c, col, "max_age_semantics")));
                r.setCutoffType(upper(cell(c, col, "cutoff_type")));
                r.setCutoffMonth(integer(c, col, "cutoff_month"));
                r.setCutoffDay(integer(c, col, "cutoff_day"));
                r.setDobFromOffsetYears(integer(c, col, "dob_from_offset_years"));
                r.setDobFromMonth(integer(c, col, "dob_from_month"));
                r.setDobFromDay(integer(c, col, "dob_from_day"));
                r.setDobToOffsetYears(integer(c, col, "dob_to_offset_years"));
                r.setDobToMonth(integer(c, col, "dob_to_month"));
                r.setDobToDay(integer(c, col, "dob_to_day"));
                r.setNotes(notes);
                row.rule = r;
                return RuleValidator.age(r);
            }
            case "RELAXATION": {
                RelaxationRule r = new RelaxationRule();
                r.setRelaxationType(upper(cell(c, col, "relaxation_type")));
                r.setCategory(upper(cell(c, col, "category")));
                Integer years = integer(c, col, "years");
                r.setYears(years == null ? -1 : years);
                r.setStacking(upper(cell(c, col, "stacking")));
                r.setOverallMaxAgeCap(integer(c, col, "overall_max_age_cap"));
                r.setRequiresStateDomicile(bool(c, col, "requires_state_domicile", false));
                r.setNotes(notes);
                row.rule = r;
                return RuleValidator.relaxation(r);
            }
            case "ATTEMPT": {
                AttemptRule r = new AttemptRule();
                r.setCategory(upper(cell(c, col, "category")));
                String pwbd = cell(c, col, "is_pwbd");
                r.setPwbd(pwbd == null ? null : Boolean.valueOf(isTrue(pwbd)));
                r.setMaxAttempts(integer(c, col, "max_attempts"));
                r.setCountingRule(upper(cell(c, col, "counting_rule")));
                r.setWindowYears(integer(c, col, "window_years"));
                r.setMinGapDays(integer(c, col, "min_gap_days"));
                r.setNotes(notes);
                row.rule = r;
                return RuleValidator.attempt(r);
            }
            case "QUALIFICATION": {
                QualificationRule r = new QualificationRule();
                r.setPostOrCourse(post);
                r.setRequiredLevel(upper(cell(c, col, "required_level")));
                r.setAcceptedDegrees(cell(c, col, "accepted_degrees"));
                r.setRequiredSubjects(cell(c, col, "required_subjects"));
                r.setMinPercentGeneral(decimal(c, col, "min_percent_general"));
                r.setMinPercentRelaxed(decimal(c, col, "min_percent_relaxed"));
                r.setRelaxedFor(cell(c, col, "relaxed_for"));
                r.setFinalYearAllowed(bool(c, col, "final_year_allowed", false));
                r.setMaxYearsSincePassing(integer(c, col, "max_years_since_passing"));
                r.setMinExperienceYears(decimal(c, col, "min_experience_years"));
                r.setTextSummary(notes);
                row.rule = r;
                return RuleValidator.qualification(r);
            }
            case "OTHER": {
                OtherRule r = new OtherRule();
                r.setPostOrCourse(post);
                r.setRuleType(upper(cell(c, col, "rule_type")));
                r.setRuleValue(cell(c, col, "rule_value"));
                r.setBlocking(bool(c, col, "is_blocking", true));
                r.setTextSummary(notes);
                row.rule = r;
                return RuleValidator.other(r);
            }
            default:
                return "rule_table must be AGE, RELAXATION, ATTEMPT, QUALIFICATION or OTHER.";
        }
    }

    private void add(ExamRuleSet rs, Object rule) {
        if (rule instanceof AgeRule) {
            rs.getAgeRules().add((AgeRule) rule);
        } else if (rule instanceof RelaxationRule) {
            rs.getRelaxationRules().add((RelaxationRule) rule);
        } else if (rule instanceof AttemptRule) {
            rs.getAttemptRules().add((AttemptRule) rule);
        } else if (rule instanceof QualificationRule) {
            rs.getQualificationRules().add((QualificationRule) rule);
        } else if (rule instanceof OtherRule) {
            rs.getOtherRules().add((OtherRule) rule);
        }
    }

    // ---------------------------------------------------------------- CSV reading helpers

    /** Splits one CSV line; quoted fields may contain commas, "" inside quotes is one quote. */
    public static List<String> splitCsvLine(String line) {
        List<String> cells = new ArrayList<>();
        StringBuilder cur = new StringBuilder();
        boolean quoted = false;
        for (int i = 0; i < line.length(); i++) {
            char ch = line.charAt(i);
            if (quoted) {
                if (ch == '"' && i + 1 < line.length() && line.charAt(i + 1) == '"') {
                    cur.append('"');
                    i++;
                } else if (ch == '"') {
                    quoted = false;
                } else {
                    cur.append(ch);
                }
            } else if (ch == '"') {
                quoted = true;
            } else if (ch == ',') {
                cells.add(cur.toString());
                cur.setLength(0);
            } else {
                cur.append(ch);
            }
        }
        cells.add(cur.toString());
        return cells;
    }

    private static String cell(List<String> cells, Map<String, Integer> col, String name) {
        Integer i = col.get(name);
        if (i == null || i >= cells.size()) {
            return null;
        }
        return ValidationUtil.clean(cells.get(i));
    }

    private static Integer integer(List<String> cells, Map<String, Integer> col, String name) {
        String v = cell(cells, col, name);
        if (v == null) {
            return null;
        }
        try {
            return Integer.valueOf(v.endsWith(".0") ? v.substring(0, v.length() - 2) : v);   // Excel may write 21.0
        } catch (NumberFormatException e) {
            throw new NumberFormatException(name + " = " + v);
        }
    }

    private static Double decimal(List<String> cells, Map<String, Integer> col, String name) {
        String v = cell(cells, col, name);
        if (v == null) {
            return null;
        }
        try {
            return Double.valueOf(v);
        } catch (NumberFormatException e) {
            throw new NumberFormatException(name + " = " + v);
        }
    }

    private static boolean bool(List<String> cells, Map<String, Integer> col, String name, boolean empty) {
        String v = cell(cells, col, name);
        return v == null ? empty : isTrue(v);
    }

    private static boolean isTrue(String v) {
        return "1".equals(v) || "TRUE".equalsIgnoreCase(v) || "YES".equalsIgnoreCase(v) || "Y".equalsIgnoreCase(v);
    }

    private static String upper(String v) {
        return v == null ? null : v.toUpperCase();
    }

    // ---------------------------------------------------------------- CSV writing (export)

    /** The active rules of the given rule sets as a rule pack CSV (header + one line per rule row). */
    public static String toCsv(List<ExamRuleSet> sets) {
        StringBuilder sb = new StringBuilder();
        sb.append(String.join(",", COLUMNS)).append("\r\n");
        for (ExamRuleSet rs : sets) {
            String code = rs.getExam().getCode();
            for (AgeRule r : rs.getAgeRules()) {
                Map<String, Object> m = new HashMap<>();
                m.put("post_or_course", r.getPostOrCourse());
                m.put("min_age", r.getMinAge());
                m.put("max_age", r.getMaxAge());
                m.put("max_age_semantics", r.getMaxAgeSemantics());
                m.put("cutoff_type", r.getCutoffType());
                m.put("cutoff_month", r.getCutoffMonth());
                m.put("cutoff_day", r.getCutoffDay());
                m.put("dob_from_offset_years", r.getDobFromOffsetYears());
                m.put("dob_from_month", r.getDobFromMonth());
                m.put("dob_from_day", r.getDobFromDay());
                m.put("dob_to_offset_years", r.getDobToOffsetYears());
                m.put("dob_to_month", r.getDobToMonth());
                m.put("dob_to_day", r.getDobToDay());
                m.put("notes", r.getNotes());
                line(sb, code, "AGE", m);
            }
            for (RelaxationRule r : rs.getRelaxationRules()) {
                Map<String, Object> m = new HashMap<>();
                m.put("relaxation_type", r.getRelaxationType());
                m.put("category", r.getCategory());
                m.put("years", r.getYears());
                m.put("stacking", r.getStacking());
                m.put("overall_max_age_cap", r.getOverallMaxAgeCap());
                m.put("requires_state_domicile", r.isRequiresStateDomicile() ? "1" : "0");
                m.put("notes", r.getNotes());
                line(sb, code, "RELAXATION", m);
            }
            for (AttemptRule r : rs.getAttemptRules()) {
                Map<String, Object> m = new HashMap<>();
                m.put("category", r.getCategory());
                m.put("is_pwbd", r.getPwbd() == null ? null : (r.getPwbd() ? "1" : "0"));
                m.put("max_attempts", r.getMaxAttempts());
                m.put("counting_rule", r.getCountingRule());
                m.put("window_years", r.getWindowYears());
                m.put("min_gap_days", r.getMinGapDays());
                m.put("notes", r.getNotes());
                line(sb, code, "ATTEMPT", m);
            }
            for (QualificationRule r : rs.getQualificationRules()) {
                Map<String, Object> m = new HashMap<>();
                m.put("post_or_course", r.getPostOrCourse());
                m.put("required_level", r.getRequiredLevel());
                m.put("accepted_degrees", r.getAcceptedDegrees());
                m.put("required_subjects", r.getRequiredSubjects());
                m.put("min_percent_general", trim(r.getMinPercentGeneral()));
                m.put("min_percent_relaxed", trim(r.getMinPercentRelaxed()));
                m.put("relaxed_for", r.getRelaxedFor());
                m.put("final_year_allowed", r.isFinalYearAllowed() ? "1" : "0");
                m.put("max_years_since_passing", r.getMaxYearsSincePassing());
                m.put("min_experience_years", trim(r.getMinExperienceYears()));
                m.put("notes", r.getTextSummary());
                line(sb, code, "QUALIFICATION", m);
            }
            for (OtherRule r : rs.getOtherRules()) {
                Map<String, Object> m = new HashMap<>();
                m.put("post_or_course", r.getPostOrCourse());
                m.put("rule_type", r.getRuleType());
                m.put("rule_value", r.getRuleValue());
                m.put("is_blocking", r.isBlocking() ? "1" : "0");
                m.put("notes", r.getTextSummary());
                line(sb, code, "OTHER", m);
            }
        }
        return sb.toString();
    }

    private static void line(StringBuilder sb, String code, String table, Map<String, Object> values) {
        values.put("exam_code", code);
        values.put("rule_table", table);
        for (int i = 0; i < COLUMNS.length; i++) {
            if (i > 0) {
                sb.append(',');
            }
            Object v = values.get(COLUMNS[i]);
            sb.append(quote(v == null ? "" : String.valueOf(v)));
        }
        sb.append("\r\n");
    }

    /** CSV quoting: wrap in quotes when the value has a comma, quote or line break. */
    public static String quote(String v) {
        v = v.replace("\r", " ").replace("\n", " ");   // one CSV line per rule row
        if (v.contains(",") || v.contains("\"")) {
            return "\"" + v.replace("\"", "\"\"") + "\"";
        }
        return v;
    }

    private static String trim(Double d) {
        if (d == null) {
            return null;
        }
        return d == Math.floor(d) ? String.valueOf(d.intValue()) : String.valueOf(d);
    }
}
