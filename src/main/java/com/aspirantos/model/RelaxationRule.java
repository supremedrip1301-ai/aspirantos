package com.aspirantos.model;

/**
 * An upper-age relaxation of a rule version (table relaxation_rule).
 * Plain JavaBean like Student in lab Experiment 4: private fields, constructors,
 * getters and setters, no annotations.
 */
public class RelaxationRule {

    private int id;
    private int ruleVersionId;
    private String relaxationType;
    private String category;
    private int years;
    private String stacking;   // ADD / ADD_AFTER_SERVICE_DEDUCTION / REPLACE_WITH_MAX
    private Integer overallMaxAgeCap;
    private boolean requiresStateDomicile;
    private String notes;

    public RelaxationRule() {
    }

    public RelaxationRule(int id,
            int ruleVersionId,
            String relaxationType,
            String category,
            int years,
            String stacking,
            Integer overallMaxAgeCap,
            boolean requiresStateDomicile,
            String notes) {
        this.id = id;
        this.ruleVersionId = ruleVersionId;
        this.relaxationType = relaxationType;
        this.category = category;
        this.years = years;
        this.stacking = stacking;
        this.overallMaxAgeCap = overallMaxAgeCap;
        this.requiresStateDomicile = requiresStateDomicile;
        this.notes = notes;
    }

    public RelaxationRule(int ruleVersionId,
            String relaxationType,
            String category,
            int years,
            String stacking,
            Integer overallMaxAgeCap,
            boolean requiresStateDomicile,
            String notes) {
        this.ruleVersionId = ruleVersionId;
        this.relaxationType = relaxationType;
        this.category = category;
        this.years = years;
        this.stacking = stacking;
        this.overallMaxAgeCap = overallMaxAgeCap;
        this.requiresStateDomicile = requiresStateDomicile;
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

    public String getRelaxationType() {
        return relaxationType;
    }

    public void setRelaxationType(String relaxationType) {
        this.relaxationType = relaxationType;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public int getYears() {
        return years;
    }

    public void setYears(int years) {
        this.years = years;
    }

    public String getStacking() {
        return stacking;
    }

    public void setStacking(String stacking) {
        this.stacking = stacking;
    }

    public Integer getOverallMaxAgeCap() {
        return overallMaxAgeCap;
    }

    public void setOverallMaxAgeCap(Integer overallMaxAgeCap) {
        this.overallMaxAgeCap = overallMaxAgeCap;
    }

    public boolean isRequiresStateDomicile() {
        return requiresStateDomicile;
    }

    public void setRequiresStateDomicile(boolean requiresStateDomicile) {
        this.requiresStateDomicile = requiresStateDomicile;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}
