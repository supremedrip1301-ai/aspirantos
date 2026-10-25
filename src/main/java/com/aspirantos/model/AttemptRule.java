package com.aspirantos.model;

/**
 * An attempt limit of a rule version (table attempt_rule).
 * Plain JavaBean like Student in lab Experiment 4: private fields, constructors,
 * getters and setters, no annotations.
 */
public class AttemptRule {

    private int id;
    private int ruleVersionId;
    private String category;   // null = all categories
    private Boolean pwbd;   // null = PwBD and non-PwBD
    private Integer maxAttempts;   // null = unlimited
    private String countingRule;
    private Integer windowYears;
    private Integer minGapDays;
    private String notes;

    public AttemptRule() {
    }

    public AttemptRule(int id,
            int ruleVersionId,
            String category,
            Boolean pwbd,
            Integer maxAttempts,
            String countingRule,
            Integer windowYears,
            Integer minGapDays,
            String notes) {
        this.id = id;
        this.ruleVersionId = ruleVersionId;
        this.category = category;
        this.pwbd = pwbd;
        this.maxAttempts = maxAttempts;
        this.countingRule = countingRule;
        this.windowYears = windowYears;
        this.minGapDays = minGapDays;
        this.notes = notes;
    }

    public AttemptRule(int ruleVersionId,
            String category,
            Boolean pwbd,
            Integer maxAttempts,
            String countingRule,
            Integer windowYears,
            Integer minGapDays,
            String notes) {
        this.ruleVersionId = ruleVersionId;
        this.category = category;
        this.pwbd = pwbd;
        this.maxAttempts = maxAttempts;
        this.countingRule = countingRule;
        this.windowYears = windowYears;
        this.minGapDays = minGapDays;
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

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public Boolean getPwbd() {
        return pwbd;
    }

    public void setPwbd(Boolean pwbd) {
        this.pwbd = pwbd;
    }

    public Integer getMaxAttempts() {
        return maxAttempts;
    }

    public void setMaxAttempts(Integer maxAttempts) {
        this.maxAttempts = maxAttempts;
    }

    public String getCountingRule() {
        return countingRule;
    }

    public void setCountingRule(String countingRule) {
        this.countingRule = countingRule;
    }

    public Integer getWindowYears() {
        return windowYears;
    }

    public void setWindowYears(Integer windowYears) {
        this.windowYears = windowYears;
    }

    public Integer getMinGapDays() {
        return minGapDays;
    }

    public void setMinGapDays(Integer minGapDays) {
        this.minGapDays = minGapDays;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}
