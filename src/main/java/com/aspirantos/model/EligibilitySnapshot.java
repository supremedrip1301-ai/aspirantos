package com.aspirantos.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Cached eligibility result of one student for one exam (table eligibility_snapshot).
 * Plain JavaBean like Student in lab Experiment 4: private fields, constructors,
 * getters and setters, no annotations.
 */
public class EligibilitySnapshot {

    private int id;
    private int userId;
    private int examId;
    private int ruleVersionId;
    private LocalDate computedForDate;
    private String status;
    private Integer attemptsUsed;
    private Integer attemptsRemaining;   // null = unlimited
    private Integer nextCycleYear;
    private Integer firstEligibleYear;
    private Integer lastEligibleYear;
    private String headline;
    private String detailsText;
    private LocalDateTime computedAt;

    public EligibilitySnapshot() {
    }

    public EligibilitySnapshot(int id,
            int userId,
            int examId,
            int ruleVersionId,
            LocalDate computedForDate,
            String status,
            Integer attemptsUsed,
            Integer attemptsRemaining,
            Integer nextCycleYear,
            Integer firstEligibleYear,
            Integer lastEligibleYear,
            String headline,
            String detailsText,
            LocalDateTime computedAt) {
        this.id = id;
        this.userId = userId;
        this.examId = examId;
        this.ruleVersionId = ruleVersionId;
        this.computedForDate = computedForDate;
        this.status = status;
        this.attemptsUsed = attemptsUsed;
        this.attemptsRemaining = attemptsRemaining;
        this.nextCycleYear = nextCycleYear;
        this.firstEligibleYear = firstEligibleYear;
        this.lastEligibleYear = lastEligibleYear;
        this.headline = headline;
        this.detailsText = detailsText;
        this.computedAt = computedAt;
    }

    public EligibilitySnapshot(int userId,
            int examId,
            int ruleVersionId,
            LocalDate computedForDate,
            String status,
            Integer attemptsUsed,
            Integer attemptsRemaining,
            Integer nextCycleYear,
            Integer firstEligibleYear,
            Integer lastEligibleYear,
            String headline,
            String detailsText,
            LocalDateTime computedAt) {
        this.userId = userId;
        this.examId = examId;
        this.ruleVersionId = ruleVersionId;
        this.computedForDate = computedForDate;
        this.status = status;
        this.attemptsUsed = attemptsUsed;
        this.attemptsRemaining = attemptsRemaining;
        this.nextCycleYear = nextCycleYear;
        this.firstEligibleYear = firstEligibleYear;
        this.lastEligibleYear = lastEligibleYear;
        this.headline = headline;
        this.detailsText = detailsText;
        this.computedAt = computedAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getExamId() {
        return examId;
    }

    public void setExamId(int examId) {
        this.examId = examId;
    }

    public int getRuleVersionId() {
        return ruleVersionId;
    }

    public void setRuleVersionId(int ruleVersionId) {
        this.ruleVersionId = ruleVersionId;
    }

    public LocalDate getComputedForDate() {
        return computedForDate;
    }

    public void setComputedForDate(LocalDate computedForDate) {
        this.computedForDate = computedForDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getAttemptsUsed() {
        return attemptsUsed;
    }

    public void setAttemptsUsed(Integer attemptsUsed) {
        this.attemptsUsed = attemptsUsed;
    }

    public Integer getAttemptsRemaining() {
        return attemptsRemaining;
    }

    public void setAttemptsRemaining(Integer attemptsRemaining) {
        this.attemptsRemaining = attemptsRemaining;
    }

    public Integer getNextCycleYear() {
        return nextCycleYear;
    }

    public void setNextCycleYear(Integer nextCycleYear) {
        this.nextCycleYear = nextCycleYear;
    }

    public Integer getFirstEligibleYear() {
        return firstEligibleYear;
    }

    public void setFirstEligibleYear(Integer firstEligibleYear) {
        this.firstEligibleYear = firstEligibleYear;
    }

    public Integer getLastEligibleYear() {
        return lastEligibleYear;
    }

    public void setLastEligibleYear(Integer lastEligibleYear) {
        this.lastEligibleYear = lastEligibleYear;
    }

    public String getHeadline() {
        return headline;
    }

    public void setHeadline(String headline) {
        this.headline = headline;
    }

    public String getDetailsText() {
        return detailsText;
    }

    public void setDetailsText(String detailsText) {
        this.detailsText = detailsText;
    }

    public LocalDateTime getComputedAt() {
        return computedAt;
    }

    public void setComputedAt(LocalDateTime computedAt) {
        this.computedAt = computedAt;
    }
}
