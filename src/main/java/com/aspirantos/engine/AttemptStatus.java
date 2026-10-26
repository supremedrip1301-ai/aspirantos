package com.aspirantos.engine;

import java.time.LocalDate;

import com.aspirantos.model.AttemptRule;

/**
 * Result of AttemptCounter for one student and one exam.
 */
public class AttemptStatus {

    private AttemptRule mainRule;          // most specific normal row (null when only lifetime/rolling rows exist)
    private int used;                      // attempts_used_before_app + counted journal rows
    private int usedBeforeApp;
    private int usedInJournal;
    private Integer maxAttempts;           // null = unlimited
    private Integer remaining;             // null = unlimited
    private Integer windowFrom;            // CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM (JEE): first allowed year
    private Integer windowTo;              // last allowed year
    private AttemptRule lifetimeRule;
    private Integer lifetimeRemaining;
    private AttemptRule rollingRule;
    private int usedLast12Months;
    private LocalDate nextRetestDate;      // null = may test now
    private boolean exhausted;

    public AttemptRule getMainRule() {
        return mainRule;
    }

    public void setMainRule(AttemptRule mainRule) {
        this.mainRule = mainRule;
    }

    public int getUsed() {
        return used;
    }

    public void setUsed(int used) {
        this.used = used;
    }

    public int getUsedBeforeApp() {
        return usedBeforeApp;
    }

    public void setUsedBeforeApp(int usedBeforeApp) {
        this.usedBeforeApp = usedBeforeApp;
    }

    public int getUsedInJournal() {
        return usedInJournal;
    }

    public void setUsedInJournal(int usedInJournal) {
        this.usedInJournal = usedInJournal;
    }

    public Integer getMaxAttempts() {
        return maxAttempts;
    }

    public void setMaxAttempts(Integer maxAttempts) {
        this.maxAttempts = maxAttempts;
    }

    public Integer getRemaining() {
        return remaining;
    }

    public void setRemaining(Integer remaining) {
        this.remaining = remaining;
    }

    public Integer getWindowFrom() {
        return windowFrom;
    }

    public void setWindowFrom(Integer windowFrom) {
        this.windowFrom = windowFrom;
    }

    public Integer getWindowTo() {
        return windowTo;
    }

    public void setWindowTo(Integer windowTo) {
        this.windowTo = windowTo;
    }

    public AttemptRule getLifetimeRule() {
        return lifetimeRule;
    }

    public void setLifetimeRule(AttemptRule lifetimeRule) {
        this.lifetimeRule = lifetimeRule;
    }

    public Integer getLifetimeRemaining() {
        return lifetimeRemaining;
    }

    public void setLifetimeRemaining(Integer lifetimeRemaining) {
        this.lifetimeRemaining = lifetimeRemaining;
    }

    public AttemptRule getRollingRule() {
        return rollingRule;
    }

    public void setRollingRule(AttemptRule rollingRule) {
        this.rollingRule = rollingRule;
    }

    public int getUsedLast12Months() {
        return usedLast12Months;
    }

    public void setUsedLast12Months(int usedLast12Months) {
        this.usedLast12Months = usedLast12Months;
    }

    public LocalDate getNextRetestDate() {
        return nextRetestDate;
    }

    public void setNextRetestDate(LocalDate nextRetestDate) {
        this.nextRetestDate = nextRetestDate;
    }

    public boolean isExhausted() {
        return exhausted;
    }

    public void setExhausted(boolean exhausted) {
        this.exhausted = exhausted;
    }
}
