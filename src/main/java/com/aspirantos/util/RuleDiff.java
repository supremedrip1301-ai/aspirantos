package com.aspirantos.util;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.aspirantos.engine.ExamRuleSet;
import com.aspirantos.model.AgeRule;
import com.aspirantos.model.AttemptRule;
import com.aspirantos.model.OtherRule;
import com.aspirantos.model.QualificationRule;
import com.aspirantos.model.RelaxationRule;

/**
 * Diff preview of a DRAFT rule version against the ACTIVE one (admin rule editor).
 * Cloned rows get new ids, so rows are compared by a readable "signature" (all the values
 * of the row in words). A row whose signature is only in the active version was removed or
 * changed (shown struck through); a row only in the draft was added or changed (highlighted).
 */
public class RuleDiff {

    public static final String[] SECTIONS = {"Age", "Relaxation", "Attempts", "Qualification", "Other conditions"};

    /** Section name -> one signature per rule row. */
    public static Map<String, List<String>> signatures(ExamRuleSet rules) {
        Map<String, List<String>> map = new LinkedHashMap<>();
        for (String s : SECTIONS) {
            map.put(s, new ArrayList<String>());
        }
        if (rules == null) {
            return map;
        }
        for (AgeRule a : rules.getAgeRules()) {
            map.get("Age").add(post(a.getPostOrCourse()) + RuleText.age(a) + note(a.getNotes()));
        }
        for (RelaxationRule r : rules.getRelaxationRules()) {
            map.get("Relaxation").add(RuleText.relaxation(r) + note(r.getNotes()));
        }
        for (AttemptRule r : rules.getAttemptRules()) {
            map.get("Attempts").add(RuleText.attemptWho(r) + ": " + RuleText.attemptLimit(r) + " - "
                    + RuleText.countingRule(r.getCountingRule()) + note(r.getNotes()));
        }
        for (QualificationRule q : rules.getQualificationRules()) {
            StringBuilder sb = new StringBuilder(post(q.getPostOrCourse()));
            sb.append(qualificationText(q)).append("; marks ").append(RuleText.marks(q))
              .append(q.isFinalYearAllowed() ? "; final year may apply" : "; must have passed");
            if (q.getMaxYearsSincePassing() != null) {
                sb.append("; within ").append(q.getMaxYearsSincePassing()).append(" year(s) of passing");
            }
            if (q.getMinExperienceYears() != null) {
                sb.append("; experience ").append(q.getMinExperienceYears()).append(" years");
            }
            map.get("Qualification").add(sb.toString() + note(q.getTextSummary()));
        }
        for (OtherRule o : rules.getOtherRules()) {
            map.get("Other conditions").add(post(o.getPostOrCourse()) + RuleText.otherType(o.getRuleType()) + ": "
                    + (o.getRuleValue() == null ? "-" : o.getRuleValue()) + (o.isBlocking() ? "" : " (information)")
                    + note(o.getTextSummary()));
        }
        return map;
    }

    /** Section -> {removed rows, added rows}; sections without changes are left out. */
    public static Map<String, List<List<String>>> diff(ExamRuleSet active, ExamRuleSet draft) {
        Map<String, List<String>> before = signatures(active);
        Map<String, List<String>> after = signatures(draft);
        Map<String, List<List<String>>> result = new LinkedHashMap<>();
        for (String section : SECTIONS) {
            List<String> removed = new ArrayList<>(before.get(section));
            List<String> added = new ArrayList<>();
            for (String s : after.get(section)) {
                if (!removed.remove(s)) {     // removes one matching row, so duplicates are counted correctly
                    added.add(s);
                }
            }
            if (!removed.isEmpty() || !added.isEmpty()) {
                List<List<String>> pair = new ArrayList<>();
                pair.add(removed);
                pair.add(added);
                result.put(section, pair);
            }
        }
        return result;
    }

    /** Total number of rule rows of a version. */
    public static int rowCount(ExamRuleSet rules) {
        if (rules == null) {
            return 0;
        }
        return rules.getAgeRules().size() + rules.getRelaxationRules().size() + rules.getAttemptRules().size()
                + rules.getQualificationRules().size() + rules.getOtherRules().size();
    }

    private static String qualificationText(QualificationRule q) {
        StringBuilder sb = new StringBuilder(q.getRequiredLevel());
        if (q.getAcceptedDegrees() != null && !"ANY".equalsIgnoreCase(q.getAcceptedDegrees())) {
            sb.append(" (").append(q.getAcceptedDegrees()).append(")");
        }
        if (q.getRequiredSubjects() != null) {
            sb.append(", subjects ").append(q.getRequiredSubjects());
        }
        return sb.toString();
    }

    private static String post(String post) {
        return post == null ? "" : "[" + post + "] ";
    }

    private static String note(String note) {
        return note == null ? "" : " (" + note + ")";
    }
}
