package com.aspirantos.model;

/**
 * An educational qualification of a rule version (table qualification_rule).
 * Plain JavaBean like Student in lab Experiment 4: private fields, constructors,
 * getters and setters, no annotations.
 */
public class QualificationRule {

    private int id;
    private int ruleVersionId;
    private String postOrCourse;
    private String requiredLevel;
    private String acceptedDegrees;   // comma list or ANY
    private String requiredSubjects;   // comma = all, | = any one
    private Double minPercentGeneral;
    private Double minPercentRelaxed;
    private String relaxedFor;
    private boolean finalYearAllowed;
    private Integer maxYearsSincePassing;
    private Double minExperienceYears;
    private String textSummary;

    public QualificationRule() {
    }

    public QualificationRule(int id,
            int ruleVersionId,
            String postOrCourse,
            String requiredLevel,
            String acceptedDegrees,
            String requiredSubjects,
            Double minPercentGeneral,
            Double minPercentRelaxed,
            String relaxedFor,
            boolean finalYearAllowed,
            Integer maxYearsSincePassing,
            Double minExperienceYears,
            String textSummary) {
        this.id = id;
        this.ruleVersionId = ruleVersionId;
        this.postOrCourse = postOrCourse;
        this.requiredLevel = requiredLevel;
        this.acceptedDegrees = acceptedDegrees;
        this.requiredSubjects = requiredSubjects;
        this.minPercentGeneral = minPercentGeneral;
        this.minPercentRelaxed = minPercentRelaxed;
        this.relaxedFor = relaxedFor;
        this.finalYearAllowed = finalYearAllowed;
        this.maxYearsSincePassing = maxYearsSincePassing;
        this.minExperienceYears = minExperienceYears;
        this.textSummary = textSummary;
    }

    public QualificationRule(int ruleVersionId,
            String postOrCourse,
            String requiredLevel,
            String acceptedDegrees,
            String requiredSubjects,
            Double minPercentGeneral,
            Double minPercentRelaxed,
            String relaxedFor,
            boolean finalYearAllowed,
            Integer maxYearsSincePassing,
            Double minExperienceYears,
            String textSummary) {
        this.ruleVersionId = ruleVersionId;
        this.postOrCourse = postOrCourse;
        this.requiredLevel = requiredLevel;
        this.acceptedDegrees = acceptedDegrees;
        this.requiredSubjects = requiredSubjects;
        this.minPercentGeneral = minPercentGeneral;
        this.minPercentRelaxed = minPercentRelaxed;
        this.relaxedFor = relaxedFor;
        this.finalYearAllowed = finalYearAllowed;
        this.maxYearsSincePassing = maxYearsSincePassing;
        this.minExperienceYears = minExperienceYears;
        this.textSummary = textSummary;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getRuleVersionId() {
        return ruleVersionId;
    }

    public void setRuleVersionId(int ruleVersionId) {
        this.ruleVersionId = ruleVersionId;
    }

    public String getPostOrCourse() {
        return postOrCourse;
    }

    public void setPostOrCourse(String postOrCourse) {
        this.postOrCourse = postOrCourse;
    }

    public String getRequiredLevel() {
        return requiredLevel;
    }

    public void setRequiredLevel(String requiredLevel) {
        this.requiredLevel = requiredLevel;
    }

    public String getAcceptedDegrees() {
        return acceptedDegrees;
    }

    public void setAcceptedDegrees(String acceptedDegrees) {
        this.acceptedDegrees = acceptedDegrees;
    }

    public String getRequiredSubjects() {
        return requiredSubjects;
    }

    public void setRequiredSubjects(String requiredSubjects) {
        this.requiredSubjects = requiredSubjects;
    }

    public Double getMinPercentGeneral() {
        return minPercentGeneral;
    }

    public void setMinPercentGeneral(Double minPercentGeneral) {
        this.minPercentGeneral = minPercentGeneral;
    }

    public Double getMinPercentRelaxed() {
        return minPercentRelaxed;
    }

    public void setMinPercentRelaxed(Double minPercentRelaxed) {
        this.minPercentRelaxed = minPercentRelaxed;
    }

    public String getRelaxedFor() {
        return relaxedFor;
    }

    public void setRelaxedFor(String relaxedFor) {
        this.relaxedFor = relaxedFor;
    }

    public boolean isFinalYearAllowed() {
        return finalYearAllowed;
    }

    public void setFinalYearAllowed(boolean finalYearAllowed) {
        this.finalYearAllowed = finalYearAllowed;
    }

    public Integer getMaxYearsSincePassing() {
        return maxYearsSincePassing;
    }

    public void setMaxYearsSincePassing(Integer maxYearsSincePassing) {
        this.maxYearsSincePassing = maxYearsSincePassing;
    }

    public Double getMinExperienceYears() {
        return minExperienceYears;
    }

    public void setMinExperienceYears(Double minExperienceYears) {
        this.minExperienceYears = minExperienceYears;
    }

    public String getTextSummary() {
        return textSummary;
    }

    public void setTextSummary(String textSummary) {
        this.textSummary = textSummary;
    }
}
