package com.aspirantos.model;

import java.time.LocalDateTime;

/**
 * One complete, versioned rule set of an exam (table exam_rule_version).
 * Plain JavaBean like Student in lab Experiment 4: private fields, constructors,
 * getters and setters, no annotations.
 */
public class RuleVersion {

    private int id;
    private int examId;
    private int versionNo;
    private Integer appliesFromCycleYear;
    private String status;   // DRAFT / ACTIVE / ARCHIVED
    private String changeSummary;
    private String sourceUrl;
    private Integer createdBy;
    private String createdByName;   // from app_user
    private LocalDateTime createdAt;
    private LocalDateTime activatedAt;
    private int changeCount;   // from rule_change_log

    public RuleVersion() {
    }

    public RuleVersion(int id,
            int examId,
            int versionNo,
            Integer appliesFromCycleYear,
            String status,
            String changeSummary,
            String sourceUrl,
            Integer createdBy,
            String createdByName,
            LocalDateTime createdAt,
            LocalDateTime activatedAt,
            int changeCount) {
        this.id = id;
        this.examId = examId;
        this.versionNo = versionNo;
        this.appliesFromCycleYear = appliesFromCycleYear;
        this.status = status;
        this.changeSummary = changeSummary;
        this.sourceUrl = sourceUrl;
        this.createdBy = createdBy;
        this.createdByName = createdByName;
        this.createdAt = createdAt;
        this.activatedAt = activatedAt;
        this.changeCount = changeCount;
    }

    public RuleVersion(int examId,
            int versionNo,
            Integer appliesFromCycleYear,
            String status,
            String changeSummary,
            String sourceUrl,
            Integer createdBy,
            String createdByName,
            LocalDateTime createdAt,
            LocalDateTime activatedAt,
            int changeCount) {
        this.examId = examId;
        this.versionNo = versionNo;
        this.appliesFromCycleYear = appliesFromCycleYear;
        this.status = status;
        this.changeSummary = changeSummary;
        this.sourceUrl = sourceUrl;
        this.createdBy = createdBy;
        this.createdByName = createdByName;
        this.createdAt = createdAt;
        this.activatedAt = activatedAt;
        this.changeCount = changeCount;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getExamId() {
        return examId;
    }

    public void setExamId(int examId) {
        this.examId = examId;
    }

    public int getVersionNo() {
        return versionNo;
    }

    public void setVersionNo(int versionNo) {
        this.versionNo = versionNo;
    }

    public Integer getAppliesFromCycleYear() {
        return appliesFromCycleYear;
    }

    public void setAppliesFromCycleYear(Integer appliesFromCycleYear) {
        this.appliesFromCycleYear = appliesFromCycleYear;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getChangeSummary() {
        return changeSummary;
    }

    public void setChangeSummary(String changeSummary) {
        this.changeSummary = changeSummary;
    }

    public String getSourceUrl() {
        return sourceUrl;
    }

    public void setSourceUrl(String sourceUrl) {
        this.sourceUrl = sourceUrl;
    }

    public Integer getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
    }

    public String getCreatedByName() {
        return createdByName;
    }

    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getActivatedAt() {
        return activatedAt;
    }

    public void setActivatedAt(LocalDateTime activatedAt) {
        this.activatedAt = activatedAt;
    }

    public int getChangeCount() {
        return changeCount;
    }

    public void setChangeCount(int changeCount) {
        this.changeCount = changeCount;
    }
}
