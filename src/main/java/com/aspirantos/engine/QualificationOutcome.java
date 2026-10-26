package com.aspirantos.engine;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.QualificationRule;

/**
 * Result of QualificationChecker for one post group.
 *
 * status:
 *   PASS        qualification already completed
 *   PROVISIONAL final-year student and the exam allows final-year candidates
 *   NOT_YET     qualification not finished yet - met from metFromYear (null = unknown)
 *   FAIL        the student has the level but not the required degree / subjects / marks
 */
public class QualificationOutcome {

    public static final String PASS = "PASS";
    public static final String PROVISIONAL = "PROVISIONAL";
    public static final String NOT_YET = "NOT_YET";
    public static final String FAIL = "FAIL";

    private String status;
    private QualificationRule rule;       // the rule that matched best
    private Integer metFromYear;          // first cycle year in which the qualification counts (null = already)
    private Integer completionYear;       // PROVISIONAL: year in which the student finishes
    private LocalDate passBy;             // PROVISIONAL: expected completion date from the profile
    private Integer lastYearAllowed;      // max_years_since_passing: last cycle year allowed
    private String levelWords;            // "graduation", "Class 12", ...
    private String failReason;            // short reason for the headline, e.g. "the required subjects are missing in your Class 12"
    private List<CheckLine> lines = new ArrayList<>();   // Qualification, Subjects, Percentage, Experience

    /**
     * Rank used to choose between alternative rules: a rule for a level the student has
     * no row for at all (and no expected year) ranks below a failed rule, so a B.Com with
     * low marks is told about the marks, not about a missing CA qualification.
     */
    public static int rank(QualificationOutcome o) {
        if (NOT_YET.equals(o.getStatus()) && o.getMetFromYear() == null) {
            return 0;
        }
        return rank(o.getStatus());
    }

    public static int rank(String status) {
        if (PASS.equals(status)) {
            return 4;
        }
        if (PROVISIONAL.equals(status)) {
            return 3;
        }
        if (NOT_YET.equals(status)) {
            return 2;
        }
        return 1;
    }

    /** Is the qualification (or final-year status) good enough for this cycle year? */
    public boolean metFor(int cycleYear) {
        if (FAIL.equals(status)) {
            return false;
        }
        if (NOT_YET.equals(status) && metFromYear == null) {
            return false;   // not finished and no expected year known
        }
        if (metFromYear != null && cycleYear < metFromYear) {
            return false;
        }
        return lastYearAllowed == null || cycleYear <= lastYearAllowed;
    }

    /** PROVISIONAL only in the year the student is still in the final year. */
    public boolean provisionalFor(int cycleYear) {
        return PROVISIONAL.equals(status) && completionYear != null && cycleYear <= completionYear;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public QualificationRule getRule() {
        return rule;
    }

    public void setRule(QualificationRule rule) {
        this.rule = rule;
    }

    public Integer getMetFromYear() {
        return metFromYear;
    }

    public void setMetFromYear(Integer metFromYear) {
        this.metFromYear = metFromYear;
    }

    public Integer getCompletionYear() {
        return completionYear;
    }

    public void setCompletionYear(Integer completionYear) {
        this.completionYear = completionYear;
    }

    public LocalDate getPassBy() {
        return passBy;
    }

    public void setPassBy(LocalDate passBy) {
        this.passBy = passBy;
    }

    public Integer getLastYearAllowed() {
        return lastYearAllowed;
    }

    public void setLastYearAllowed(Integer lastYearAllowed) {
        this.lastYearAllowed = lastYearAllowed;
    }

    public String getLevelWords() {
        return levelWords;
    }

    public void setLevelWords(String levelWords) {
        this.levelWords = levelWords;
    }

    public String getFailReason() {
        return failReason;
    }

    /** Keeps the first reason only. */
    public void setFailReason(String failReason) {
        if (this.failReason == null) {
            this.failReason = failReason;
        }
    }

    public List<CheckLine> getLines() {
        return lines;
    }

    public void setLines(List<CheckLine> lines) {
        this.lines = lines;
    }
}
