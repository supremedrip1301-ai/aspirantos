package com.aspirantos.model;

import java.time.LocalDateTime;

/**
 * One logged rule change (table rule_change_log).
 * Plain JavaBean like Student in lab Experiment 4: private fields, constructors,
 * getters and setters, no annotations.
 */
public class RuleChange {

    private int id;
    private int examId;
    private Integer ruleVersionId;
    private String tableName;
    private String columnName;
    private String oldValue;
    private String newValue;
    private String changeSource;
    private Integer changedBy;
    private String changedByName;   // from app_user
    private LocalDateTime changedAt;

    public RuleChange() {
    }

    public RuleChange(int id,
            int examId,
            Integer ruleVersionId,
            String tableName,
            String columnName,
            String oldValue,
            String newValue,
            String changeSource,
            Integer changedBy,
            String changedByName,
            LocalDateTime changedAt) {
        this.id = id;
        this.examId = examId;
        this.ruleVersionId = ruleVersionId;
        this.tableName = tableName;
        this.columnName = columnName;
        this.oldValue = oldValue;
        this.newValue = newValue;
        this.changeSource = changeSource;
        this.changedBy = changedBy;
        this.changedByName = changedByName;
        this.changedAt = changedAt;
    }

    public RuleChange(int examId,
            Integer ruleVersionId,
            String tableName,
            String columnName,
            String oldValue,
            String newValue,
            String changeSource,
            Integer changedBy,
            String changedByName,
            LocalDateTime changedAt) {
        this.examId = examId;
        this.ruleVersionId = ruleVersionId;
        this.tableName = tableName;
        this.columnName = columnName;
        this.oldValue = oldValue;
        this.newValue = newValue;
        this.changeSource = changeSource;
        this.changedBy = changedBy;
        this.changedByName = changedByName;
        this.changedAt = changedAt;
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

    public Integer getRuleVersionId() {
        return ruleVersionId;
    }

    public void setRuleVersionId(Integer ruleVersionId) {
        this.ruleVersionId = ruleVersionId;
    }

    public String getTableName() {
        return tableName;
    }

    public void setTableName(String tableName) {
        this.tableName = tableName;
    }

    public String getColumnName() {
        return columnName;
    }

    public void setColumnName(String columnName) {
        this.columnName = columnName;
    }

    public String getOldValue() {
        return oldValue;
    }

    public void setOldValue(String oldValue) {
        this.oldValue = oldValue;
    }

    public String getNewValue() {
        return newValue;
    }

    public void setNewValue(String newValue) {
        this.newValue = newValue;
    }

    public String getChangeSource() {
        return changeSource;
    }

    public void setChangeSource(String changeSource) {
        this.changeSource = changeSource;
    }

    public Integer getChangedBy() {
        return changedBy;
    }

    public void setChangedBy(Integer changedBy) {
        this.changedBy = changedBy;
    }

    public String getChangedByName() {
        return changedByName;
    }

    public void setChangedByName(String changedByName) {
        this.changedByName = changedByName;
    }

    public LocalDateTime getChangedAt() {
        return changedAt;
    }

    public void setChangedAt(LocalDateTime changedAt) {
        this.changedAt = changedAt;
    }
}
