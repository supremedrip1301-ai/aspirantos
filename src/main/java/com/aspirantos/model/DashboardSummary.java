package com.aspirantos.model;

/**
 * Dashboard counters returned by the stored procedure sp_user_dashboard_summary.
 * Plain JavaBean like Student in lab Experiment 4: private fields, constructors,
 * getters and setters, no annotations.
 */
public class DashboardSummary {

    private int eligibleNow;
    private int provisional;
    private int closingSoon;
    private int notYet;
    private int notEligible;
    private int trackedExams;
    private int unreadNotifications;
    private int examsChecked;

    public DashboardSummary() {
    }

    public DashboardSummary(int eligibleNow,
            int provisional,
            int closingSoon,
            int notYet,
            int notEligible,
            int trackedExams,
            int unreadNotifications,
            int examsChecked) {
        this.eligibleNow = eligibleNow;
        this.provisional = provisional;
        this.closingSoon = closingSoon;
        this.notYet = notYet;
        this.notEligible = notEligible;
        this.trackedExams = trackedExams;
        this.unreadNotifications = unreadNotifications;
        this.examsChecked = examsChecked;
    }

    public int getEligibleNow() {
        return eligibleNow;
    }

    public void setEligibleNow(int eligibleNow) {
        this.eligibleNow = eligibleNow;
    }

    public int getProvisional() {
        return provisional;
    }

    public void setProvisional(int provisional) {
        this.provisional = provisional;
    }

    public int getClosingSoon() {
        return closingSoon;
    }

    public void setClosingSoon(int closingSoon) {
        this.closingSoon = closingSoon;
    }

    public int getNotYet() {
        return notYet;
    }

    public void setNotYet(int notYet) {
        this.notYet = notYet;
    }

    public int getNotEligible() {
        return notEligible;
    }

    public void setNotEligible(int notEligible) {
        this.notEligible = notEligible;
    }

    public int getTrackedExams() {
        return trackedExams;
    }

    public void setTrackedExams(int trackedExams) {
        this.trackedExams = trackedExams;
    }

    public int getUnreadNotifications() {
        return unreadNotifications;
    }

    public void setUnreadNotifications(int unreadNotifications) {
        this.unreadNotifications = unreadNotifications;
    }

    public int getExamsChecked() {
        return examsChecked;
    }

    public void setExamsChecked(int examsChecked) {
        this.examsChecked = examsChecked;
    }
}
