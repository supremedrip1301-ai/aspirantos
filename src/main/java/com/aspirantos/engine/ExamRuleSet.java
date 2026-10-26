package com.aspirantos.engine;

import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.AgeRule;
import com.aspirantos.model.AttemptRule;
import com.aspirantos.model.Exam;
import com.aspirantos.model.ExamEvent;
import com.aspirantos.model.OtherRule;
import com.aspirantos.model.QualificationRule;
import com.aspirantos.model.RelaxationRule;

/**
 * Everything the engine needs to know about one exam: the exam row, the rule version
 * that is used, all rule rows of that version and the calendar events.
 * EligibilityService fills it from the DAOs; EngineSelfTest fills it by hand.
 *
 * Post groups (D26, D29): rows with a post_or_course apply to that post group only,
 * rows with post_or_course = NULL apply to every group.
 */
public class ExamRuleSet {

    private Exam exam;
    private int ruleVersionId;
    private List<AgeRule> ageRules = new ArrayList<>();
    private List<RelaxationRule> relaxationRules = new ArrayList<>();
    private List<AttemptRule> attemptRules = new ArrayList<>();
    private List<QualificationRule> qualificationRules = new ArrayList<>();
    private List<OtherRule> otherRules = new ArrayList<>();
    private List<ExamEvent> events = new ArrayList<>();

    public ExamRuleSet() {
    }

    public ExamRuleSet(Exam exam, int ruleVersionId) {
        this.exam = exam;
        this.ruleVersionId = ruleVersionId;
    }

    /** Distinct post groups named in the age and qualification rows, in table order. Empty = one group for the whole exam. */
    public List<String> getPostGroups() {
        List<String> groups = new ArrayList<>();
        for (AgeRule r : ageRules) {
            if (r.getPostOrCourse() != null && !groups.contains(r.getPostOrCourse())) {
                groups.add(r.getPostOrCourse());
            }
        }
        for (QualificationRule r : qualificationRules) {
            if (r.getPostOrCourse() != null && !groups.contains(r.getPostOrCourse())) {
                groups.add(r.getPostOrCourse());
            }
        }
        return groups;
    }

    /** The group's own age row, else the general (NULL) row, else null = no age rule. */
    public AgeRule getAgeRuleFor(String group) {
        AgeRule general = null;
        for (AgeRule r : ageRules) {
            if (r.getPostOrCourse() == null) {
                general = r;
            } else if (r.getPostOrCourse().equals(group)) {
                return r;
            }
        }
        return general;
    }

    /** The group's own qualification rows replace the general rows; several rows = alternatives. */
    public List<QualificationRule> getQualificationRulesFor(String group) {
        List<QualificationRule> own = new ArrayList<>();
        List<QualificationRule> general = new ArrayList<>();
        for (QualificationRule r : qualificationRules) {
            if (r.getPostOrCourse() == null) {
                general.add(r);
            } else if (r.getPostOrCourse().equals(group)) {
                own.add(r);
            }
        }
        return own.isEmpty() ? general : own;
    }

    /** Other rules add up: the general rows always apply, plus the group's own rows. */
    public List<OtherRule> getOtherRulesFor(String group) {
        List<OtherRule> list = new ArrayList<>();
        for (OtherRule r : otherRules) {
            if (r.getPostOrCourse() == null || r.getPostOrCourse().equals(group)) {
                list.add(r);
            }
        }
        return list;
    }

    public Exam getExam() {
        return exam;
    }

    public void setExam(Exam exam) {
        this.exam = exam;
    }

    public int getRuleVersionId() {
        return ruleVersionId;
    }

    public void setRuleVersionId(int ruleVersionId) {
        this.ruleVersionId = ruleVersionId;
    }

    public List<AgeRule> getAgeRules() {
        return ageRules;
    }

    public void setAgeRules(List<AgeRule> ageRules) {
        this.ageRules = ageRules;
    }

    public List<RelaxationRule> getRelaxationRules() {
        return relaxationRules;
    }

    public void setRelaxationRules(List<RelaxationRule> relaxationRules) {
        this.relaxationRules = relaxationRules;
    }

    public List<AttemptRule> getAttemptRules() {
        return attemptRules;
    }

    public void setAttemptRules(List<AttemptRule> attemptRules) {
        this.attemptRules = attemptRules;
    }

    public List<QualificationRule> getQualificationRules() {
        return qualificationRules;
    }

    public void setQualificationRules(List<QualificationRule> qualificationRules) {
        this.qualificationRules = qualificationRules;
    }

    public List<OtherRule> getOtherRules() {
        return otherRules;
    }

    public void setOtherRules(List<OtherRule> otherRules) {
        this.otherRules = otherRules;
    }

    public List<ExamEvent> getEvents() {
        return events;
    }

    public void setEvents(List<ExamEvent> events) {
        this.events = events;
    }
}
