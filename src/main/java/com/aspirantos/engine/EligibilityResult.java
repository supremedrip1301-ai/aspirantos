package com.aspirantos.engine;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * The answer of the engine for one student and one exam.
 * Status values match eligibility_snapshot.status:
 * ELIGIBLE, PROVISIONAL, NOT_YET, NOT_ELIGIBLE, EXHAUSTED.
 */
public class EligibilityResult {

    public static final String ELIGIBLE = "ELIGIBLE";
    public static final String PROVISIONAL = "PROVISIONAL";
    public static final String NOT_YET = "NOT_YET";
    public static final String NOT_ELIGIBLE = "NOT_ELIGIBLE";
    public static final String EXHAUSTED = "EXHAUSTED";

    private int examId;
    private int ruleVersionId;
    private LocalDate computedFor;          // "today" used (simulation date or real date)
    private String status;
    private String headline;                // "You have 2 UPSC attempts left, valid until 2028."
    private Integer attemptsUsed;
    private Integer attemptsRemaining;      // null = unlimited (within age)
    private Integer firstEligibleYear;
    private Integer lastEligibleYear;       // null = no end (no age or year limit)
    private Integer nextCycleYear;
    private Long daysUntilAgeLimitCrossed;  // null = no upper age limit
    private String dobWindow;               // "You must be born between 02-Aug-1995 and 01-Aug-2006"
    private String relaxationBreakdown;     // "Base upper age 32 + OBC-NCL 3 + PwBD 10 = 45"
    private String postGroup;               // best post group, null when the exam has none
    private LocalDate nextRetestDate;       // rolling 12-month rules (GRE, GMAT)
    private boolean profileIncomplete;
    private List<Integer> usableYears = new ArrayList<>();   // cycle years the student can use (horizon chart)
    private List<CheckLine> checkLines = new ArrayList<>();

    public EligibilityResult() {
    }

    public void addLine(String name, String result, String explanation) {
        checkLines.add(new CheckLine(name, result, explanation));
    }

    /** "Unlimited (within age)" or the number, for the pages. */
    public String getAttemptsRemainingText() {
        return attemptsRemaining == null ? "Unlimited (within age)" : String.valueOf(attemptsRemaining);
    }

    /** All check lines as text for eligibility_snapshot.details_text. */
    public String toDetailsText() {
        StringBuilder sb = new StringBuilder();
        for (CheckLine line : checkLines) {
            sb.append(line.toStorageText()).append('\n');
        }
        return sb.toString();
    }

    public boolean isEligibleNow() {
        return ELIGIBLE.equals(status) || PROVISIONAL.equals(status);
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

    public LocalDate getComputedFor() {
        return computedFor;
    }

    public void setComputedFor(LocalDate computedFor) {
        this.computedFor = computedFor;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getHeadline() {
        return headline;
    }

    public void setHeadline(String headline) {
        this.headline = headline;
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

    public Integer getNextCycleYear() {
        return nextCycleYear;
    }

    public void setNextCycleYear(Integer nextCycleYear) {
        this.nextCycleYear = nextCycleYear;
    }

    public Long getDaysUntilAgeLimitCrossed() {
        return daysUntilAgeLimitCrossed;
    }

    public void setDaysUntilAgeLimitCrossed(Long daysUntilAgeLimitCrossed) {
        this.daysUntilAgeLimitCrossed = daysUntilAgeLimitCrossed;
    }

    public String getDobWindow() {
        return dobWindow;
    }

    public void setDobWindow(String dobWindow) {
        this.dobWindow = dobWindow;
    }

    public String getRelaxationBreakdown() {
        return relaxationBreakdown;
    }

    public void setRelaxationBreakdown(String relaxationBreakdown) {
        this.relaxationBreakdown = relaxationBreakdown;
    }

    public String getPostGroup() {
        return postGroup;
    }

    public void setPostGroup(String postGroup) {
        this.postGroup = postGroup;
    }

    public LocalDate getNextRetestDate() {
        return nextRetestDate;
    }

    public void setNextRetestDate(LocalDate nextRetestDate) {
        this.nextRetestDate = nextRetestDate;
    }

    public boolean isProfileIncomplete() {
        return profileIncomplete;
    }

    public void setProfileIncomplete(boolean profileIncomplete) {
        this.profileIncomplete = profileIncomplete;
    }

    public List<Integer> getUsableYears() {
        return usableYears;
    }

    public void setUsableYears(List<Integer> usableYears) {
        this.usableYears = usableYears;
    }

    public List<CheckLine> getCheckLines() {
        return checkLines;
    }

    public void setCheckLines(List<CheckLine> checkLines) {
        this.checkLines = checkLines;
    }
}
