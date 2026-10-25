package com.aspirantos.model;

/**
 * Age limits of a rule version (table age_rule).
 * Plain JavaBean like Student in lab Experiment 4: private fields, constructors,
 * getters and setters, no annotations.
 */
public class AgeRule {

    private int id;
    private int ruleVersionId;
    private String postOrCourse;   // null = whole exam
    private Integer minAge;
    private Integer maxAge;   // null = no upper limit
    private String maxAgeSemantics;   // NOT_ATTAINED or NOT_MORE_THAN
    private String cutoffType;
    private Integer cutoffMonth;
    private Integer cutoffDay;
    private Integer dobFromOffsetYears;
    private Integer dobFromMonth;
    private Integer dobFromDay;
    private Integer dobToOffsetYears;
    private Integer dobToMonth;
    private Integer dobToDay;
    private String notes;

    public AgeRule() {
    }

    public AgeRule(int id,
            int ruleVersionId,
            String postOrCourse,
            Integer minAge,
            Integer maxAge,
            String maxAgeSemantics,
            String cutoffType,
            Integer cutoffMonth,
            Integer cutoffDay,
            Integer dobFromOffsetYears,
            Integer dobFromMonth,
            Integer dobFromDay,
            Integer dobToOffsetYears,
            Integer dobToMonth,
            Integer dobToDay,
            String notes) {
        this.id = id;
        this.ruleVersionId = ruleVersionId;
        this.postOrCourse = postOrCourse;
        this.minAge = minAge;
        this.maxAge = maxAge;
        this.maxAgeSemantics = maxAgeSemantics;
        this.cutoffType = cutoffType;
        this.cutoffMonth = cutoffMonth;
        this.cutoffDay = cutoffDay;
        this.dobFromOffsetYears = dobFromOffsetYears;
        this.dobFromMonth = dobFromMonth;
        this.dobFromDay = dobFromDay;
        this.dobToOffsetYears = dobToOffsetYears;
        this.dobToMonth = dobToMonth;
        this.dobToDay = dobToDay;
        this.notes = notes;
    }

    public AgeRule(int ruleVersionId,
            String postOrCourse,
            Integer minAge,
            Integer maxAge,
            String maxAgeSemantics,
            String cutoffType,
            Integer cutoffMonth,
            Integer cutoffDay,
            Integer dobFromOffsetYears,
            Integer dobFromMonth,
            Integer dobFromDay,
            Integer dobToOffsetYears,
            Integer dobToMonth,
            Integer dobToDay,
            String notes) {
        this.ruleVersionId = ruleVersionId;
        this.postOrCourse = postOrCourse;
        this.minAge = minAge;
        this.maxAge = maxAge;
        this.maxAgeSemantics = maxAgeSemantics;
        this.cutoffType = cutoffType;
        this.cutoffMonth = cutoffMonth;
        this.cutoffDay = cutoffDay;
        this.dobFromOffsetYears = dobFromOffsetYears;
        this.dobFromMonth = dobFromMonth;
        this.dobFromDay = dobFromDay;
        this.dobToOffsetYears = dobToOffsetYears;
        this.dobToMonth = dobToMonth;
        this.dobToDay = dobToDay;
        this.notes = notes;
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

    public Integer getMinAge() {
        return minAge;
    }

    public void setMinAge(Integer minAge) {
        this.minAge = minAge;
    }

    public Integer getMaxAge() {
        return maxAge;
    }

    public void setMaxAge(Integer maxAge) {
        this.maxAge = maxAge;
    }

    public String getMaxAgeSemantics() {
        return maxAgeSemantics;
    }

    public void setMaxAgeSemantics(String maxAgeSemantics) {
        this.maxAgeSemantics = maxAgeSemantics;
    }

    public String getCutoffType() {
        return cutoffType;
    }

    public void setCutoffType(String cutoffType) {
        this.cutoffType = cutoffType;
    }

    public Integer getCutoffMonth() {
        return cutoffMonth;
    }

    public void setCutoffMonth(Integer cutoffMonth) {
        this.cutoffMonth = cutoffMonth;
    }

    public Integer getCutoffDay() {
        return cutoffDay;
    }

    public void setCutoffDay(Integer cutoffDay) {
        this.cutoffDay = cutoffDay;
    }

    public Integer getDobFromOffsetYears() {
        return dobFromOffsetYears;
    }

    public void setDobFromOffsetYears(Integer dobFromOffsetYears) {
        this.dobFromOffsetYears = dobFromOffsetYears;
    }

    public Integer getDobFromMonth() {
        return dobFromMonth;
    }

    public void setDobFromMonth(Integer dobFromMonth) {
        this.dobFromMonth = dobFromMonth;
    }

    public Integer getDobFromDay() {
        return dobFromDay;
    }

    public void setDobFromDay(Integer dobFromDay) {
        this.dobFromDay = dobFromDay;
    }

    public Integer getDobToOffsetYears() {
        return dobToOffsetYears;
    }

    public void setDobToOffsetYears(Integer dobToOffsetYears) {
        this.dobToOffsetYears = dobToOffsetYears;
    }

    public Integer getDobToMonth() {
        return dobToMonth;
    }

    public void setDobToMonth(Integer dobToMonth) {
        this.dobToMonth = dobToMonth;
    }

    public Integer getDobToDay() {
        return dobToDay;
    }

    public void setDobToDay(Integer dobToDay) {
        this.dobToDay = dobToDay;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}
