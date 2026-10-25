package com.aspirantos.model;

import java.time.LocalDate;

/**
 * One entry of the attempt journal (table attempt_log).
 * Plain JavaBean like Student in lab Experiment 4: private fields, constructors,
 * getters and setters, no annotations.
 */
public class AttemptLog {

    private int id;
    private int userId;
    private int examId;
    private int cycleYear;
    private int sittingNo;
    private LocalDate attemptDate;
    private String stageReached;
    private boolean countsAsAttempt;   // set by a trigger
    private Double score;
    private Integer rankObtained;
    private String remarks;

    public AttemptLog() {
    }

    public AttemptLog(int id,
            int userId,
            int examId,
            int cycleYear,
            int sittingNo,
            LocalDate attemptDate,
            String stageReached,
            boolean countsAsAttempt,
            Double score,
            Integer rankObtained,
            String remarks) {
        this.id = id;
        this.userId = userId;
        this.examId = examId;
        this.cycleYear = cycleYear;
        this.sittingNo = sittingNo;
        this.attemptDate = attemptDate;
        this.stageReached = stageReached;
        this.countsAsAttempt = countsAsAttempt;
        this.score = score;
        this.rankObtained = rankObtained;
        this.remarks = remarks;
    }

    public AttemptLog(int userId,
            int examId,
            int cycleYear,
            int sittingNo,
            LocalDate attemptDate,
            String stageReached,
            boolean countsAsAttempt,
            Double score,
            Integer rankObtained,
            String remarks) {
        this.userId = userId;
        this.examId = examId;
        this.cycleYear = cycleYear;
        this.sittingNo = sittingNo;
        this.attemptDate = attemptDate;
        this.stageReached = stageReached;
        this.countsAsAttempt = countsAsAttempt;
        this.score = score;
        this.rankObtained = rankObtained;
        this.remarks = remarks;
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

    public int getCycleYear() {
        return cycleYear;
    }

    public void setCycleYear(int cycleYear) {
        this.cycleYear = cycleYear;
    }

    public int getSittingNo() {
        return sittingNo;
    }

    public void setSittingNo(int sittingNo) {
        this.sittingNo = sittingNo;
    }

    public LocalDate getAttemptDate() {
        return attemptDate;
    }

    public void setAttemptDate(LocalDate attemptDate) {
        this.attemptDate = attemptDate;
    }

    public String getStageReached() {
        return stageReached;
    }

    public void setStageReached(String stageReached) {
        this.stageReached = stageReached;
    }

    public boolean isCountsAsAttempt() {
        return countsAsAttempt;
    }

    public void setCountsAsAttempt(boolean countsAsAttempt) {
        this.countsAsAttempt = countsAsAttempt;
    }

    public Double getScore() {
        return score;
    }

    public void setScore(Double score) {
        this.score = score;
    }

    public Integer getRankObtained() {
        return rankObtained;
    }

    public void setRankObtained(Integer rankObtained) {
        this.rankObtained = rankObtained;
    }

    public String getRemarks() {
        return remarks;
    }

    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }
}
