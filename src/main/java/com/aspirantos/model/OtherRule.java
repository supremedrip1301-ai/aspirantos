package com.aspirantos.model;

/**
 * Gender, marital status, nationality, domicile or other condition (table other_rule).
 * Plain JavaBean like Student in lab Experiment 4: private fields, constructors,
 * getters and setters, no annotations.
 */
public class OtherRule {

    private int id;
    private int ruleVersionId;
    private String postOrCourse;
    private String ruleType;
    private String ruleValue;
    private boolean blocking;   // false = information only
    private String textSummary;

    public OtherRule() {
    }

    public OtherRule(int id,
            int ruleVersionId,
            String postOrCourse,
            String ruleType,
            String ruleValue,
            boolean blocking,
            String textSummary) {
        this.id = id;
        this.ruleVersionId = ruleVersionId;
        this.postOrCourse = postOrCourse;
        this.ruleType = ruleType;
        this.ruleValue = ruleValue;
        this.blocking = blocking;
        this.textSummary = textSummary;
    }

    public OtherRule(int ruleVersionId,
            String postOrCourse,
            String ruleType,
            String ruleValue,
            boolean blocking,
            String textSummary) {
        this.ruleVersionId = ruleVersionId;
        this.postOrCourse = postOrCourse;
        this.ruleType = ruleType;
        this.ruleValue = ruleValue;
        this.blocking = blocking;
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

    public String getRuleType() {
        return ruleType;
    }

    public void setRuleType(String ruleType) {
        this.ruleType = ruleType;
    }

    public String getRuleValue() {
        return ruleValue;
    }

    public void setRuleValue(String ruleValue) {
        this.ruleValue = ruleValue;
    }

    public boolean isBlocking() {
        return blocking;
    }

    public void setBlocking(boolean blocking) {
        this.blocking = blocking;
    }

    public String getTextSummary() {
        return textSummary;
    }

    public void setTextSummary(String textSummary) {
        this.textSummary = textSummary;
    }
}
