package com.aspirantos.model;

import java.time.LocalDate;

/**
 * An exam of the catalogue (table exam) with its category and body names.
 * Plain JavaBean like Student in lab Experiment 4: private fields, constructors,
 * getters and setters, no annotations.
 */
public class Exam {

    private int id;
    private String code;
    private String name;
    private String shortName;
    private int categoryId;
    private String categoryCode;   // from exam_category
    private String categoryName;   // from exam_category
    private int bodyId;
    private String bodyShortName;   // from conducting_body
    private String scope;
    private String stateCode;
    private String sector;
    private String purpose;
    private double cyclesPerYear;
    private Integer typicalNotificationMonth;
    private Integer typicalExamMonth;
    private String stagesSummary;
    private String postsOrCourses;
    private String officialUrl;
    private String watchUrl;
    private String description;
    private String feeSummary;
    private String attemptCountingNote;
    private String dataConfidence;
    private LocalDate lastVerifiedOn;
    private String sourceNote;
    private boolean active;
    private Integer activeRuleVersionId;

    public Exam() {
    }

    public Exam(int id,
            String code,
            String name,
            String shortName,
            int categoryId,
            String categoryCode,
            String categoryName,
            int bodyId,
            String bodyShortName,
            String scope,
            String stateCode,
            String sector,
            String purpose,
            double cyclesPerYear,
            Integer typicalNotificationMonth,
            Integer typicalExamMonth,
            String stagesSummary,
            String postsOrCourses,
            String officialUrl,
            String watchUrl,
            String description,
            String feeSummary,
            String attemptCountingNote,
            String dataConfidence,
            LocalDate lastVerifiedOn,
            String sourceNote,
            boolean active,
            Integer activeRuleVersionId) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.shortName = shortName;
        this.categoryId = categoryId;
        this.categoryCode = categoryCode;
        this.categoryName = categoryName;
        this.bodyId = bodyId;
        this.bodyShortName = bodyShortName;
        this.scope = scope;
        this.stateCode = stateCode;
        this.sector = sector;
        this.purpose = purpose;
        this.cyclesPerYear = cyclesPerYear;
        this.typicalNotificationMonth = typicalNotificationMonth;
        this.typicalExamMonth = typicalExamMonth;
        this.stagesSummary = stagesSummary;
        this.postsOrCourses = postsOrCourses;
        this.officialUrl = officialUrl;
        this.watchUrl = watchUrl;
        this.description = description;
        this.feeSummary = feeSummary;
        this.attemptCountingNote = attemptCountingNote;
        this.dataConfidence = dataConfidence;
        this.lastVerifiedOn = lastVerifiedOn;
        this.sourceNote = sourceNote;
        this.active = active;
        this.activeRuleVersionId = activeRuleVersionId;
    }

    public Exam(String code,
            String name,
            String shortName,
            int categoryId,
            String categoryCode,
            String categoryName,
            int bodyId,
            String bodyShortName,
            String scope,
            String stateCode,
            String sector,
            String purpose,
            double cyclesPerYear,
            Integer typicalNotificationMonth,
            Integer typicalExamMonth,
            String stagesSummary,
            String postsOrCourses,
            String officialUrl,
            String watchUrl,
            String description,
            String feeSummary,
            String attemptCountingNote,
            String dataConfidence,
            LocalDate lastVerifiedOn,
            String sourceNote,
            boolean active,
            Integer activeRuleVersionId) {
        this.code = code;
        this.name = name;
        this.shortName = shortName;
        this.categoryId = categoryId;
        this.categoryCode = categoryCode;
        this.categoryName = categoryName;
        this.bodyId = bodyId;
        this.bodyShortName = bodyShortName;
        this.scope = scope;
        this.stateCode = stateCode;
        this.sector = sector;
        this.purpose = purpose;
        this.cyclesPerYear = cyclesPerYear;
        this.typicalNotificationMonth = typicalNotificationMonth;
        this.typicalExamMonth = typicalExamMonth;
        this.stagesSummary = stagesSummary;
        this.postsOrCourses = postsOrCourses;
        this.officialUrl = officialUrl;
        this.watchUrl = watchUrl;
        this.description = description;
        this.feeSummary = feeSummary;
        this.attemptCountingNote = attemptCountingNote;
        this.dataConfidence = dataConfidence;
        this.lastVerifiedOn = lastVerifiedOn;
        this.sourceNote = sourceNote;
        this.active = active;
        this.activeRuleVersionId = activeRuleVersionId;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getShortName() {
        return shortName;
    }

    public void setShortName(String shortName) {
        this.shortName = shortName;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryCode() {
        return categoryCode;
    }

    public void setCategoryCode(String categoryCode) {
        this.categoryCode = categoryCode;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public int getBodyId() {
        return bodyId;
    }

    public void setBodyId(int bodyId) {
        this.bodyId = bodyId;
    }

    public String getBodyShortName() {
        return bodyShortName;
    }

    public void setBodyShortName(String bodyShortName) {
        this.bodyShortName = bodyShortName;
    }

    public String getScope() {
        return scope;
    }

    public void setScope(String scope) {
        this.scope = scope;
    }

    public String getStateCode() {
        return stateCode;
    }

    public void setStateCode(String stateCode) {
        this.stateCode = stateCode;
    }

    public String getSector() {
        return sector;
    }

    public void setSector(String sector) {
        this.sector = sector;
    }

    public String getPurpose() {
        return purpose;
    }

    public void setPurpose(String purpose) {
        this.purpose = purpose;
    }

    public double getCyclesPerYear() {
        return cyclesPerYear;
    }

    public void setCyclesPerYear(double cyclesPerYear) {
        this.cyclesPerYear = cyclesPerYear;
    }

    public Integer getTypicalNotificationMonth() {
        return typicalNotificationMonth;
    }

    public void setTypicalNotificationMonth(Integer typicalNotificationMonth) {
        this.typicalNotificationMonth = typicalNotificationMonth;
    }

    public Integer getTypicalExamMonth() {
        return typicalExamMonth;
    }

    public void setTypicalExamMonth(Integer typicalExamMonth) {
        this.typicalExamMonth = typicalExamMonth;
    }

    public String getStagesSummary() {
        return stagesSummary;
    }

    public void setStagesSummary(String stagesSummary) {
        this.stagesSummary = stagesSummary;
    }

    public String getPostsOrCourses() {
        return postsOrCourses;
    }

    public void setPostsOrCourses(String postsOrCourses) {
        this.postsOrCourses = postsOrCourses;
    }

    public String getOfficialUrl() {
        return officialUrl;
    }

    public void setOfficialUrl(String officialUrl) {
        this.officialUrl = officialUrl;
    }

    public String getWatchUrl() {
        return watchUrl;
    }

    public void setWatchUrl(String watchUrl) {
        this.watchUrl = watchUrl;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getFeeSummary() {
        return feeSummary;
    }

    public void setFeeSummary(String feeSummary) {
        this.feeSummary = feeSummary;
    }

    public String getAttemptCountingNote() {
        return attemptCountingNote;
    }

    public void setAttemptCountingNote(String attemptCountingNote) {
        this.attemptCountingNote = attemptCountingNote;
    }

    public String getDataConfidence() {
        return dataConfidence;
    }

    public void setDataConfidence(String dataConfidence) {
        this.dataConfidence = dataConfidence;
    }

    public LocalDate getLastVerifiedOn() {
        return lastVerifiedOn;
    }

    public void setLastVerifiedOn(LocalDate lastVerifiedOn) {
        this.lastVerifiedOn = lastVerifiedOn;
    }

    public String getSourceNote() {
        return sourceNote;
    }

    public void setSourceNote(String sourceNote) {
        this.sourceNote = sourceNote;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public Integer getActiveRuleVersionId() {
        return activeRuleVersionId;
    }

    public void setActiveRuleVersionId(Integer activeRuleVersionId) {
        this.activeRuleVersionId = activeRuleVersionId;
    }
}
