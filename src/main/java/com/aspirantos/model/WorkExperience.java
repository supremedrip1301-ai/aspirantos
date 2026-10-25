package com.aspirantos.model;

import java.time.LocalDate;

/**
 * A job or legal practice period of a student (table work_experience).
 * Plain JavaBean like Student in lab Experiment 4: private fields, constructors,
 * getters and setters, no annotations.
 */
public class WorkExperience {

    private int id;
    private int userId;
    private String organisation;
    private String designation;
    private LocalDate startDate;
    private LocalDate endDate;   // null = still working
    private boolean govt;
    private boolean relevantProfessional;   // counts as practice / relevant experience

    public WorkExperience() {
    }

    public WorkExperience(int id,
            int userId,
            String organisation,
            String designation,
            LocalDate startDate,
            LocalDate endDate,
            boolean govt,
            boolean relevantProfessional) {
        this.id = id;
        this.userId = userId;
        this.organisation = organisation;
        this.designation = designation;
        this.startDate = startDate;
        this.endDate = endDate;
        this.govt = govt;
        this.relevantProfessional = relevantProfessional;
    }

    public WorkExperience(int userId,
            String organisation,
            String designation,
            LocalDate startDate,
            LocalDate endDate,
            boolean govt,
            boolean relevantProfessional) {
        this.userId = userId;
        this.organisation = organisation;
        this.designation = designation;
        this.startDate = startDate;
        this.endDate = endDate;
        this.govt = govt;
        this.relevantProfessional = relevantProfessional;
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

    public String getOrganisation() {
        return organisation;
    }

    public void setOrganisation(String organisation) {
        this.organisation = organisation;
    }

    public String getDesignation() {
        return designation;
    }

    public void setDesignation(String designation) {
        this.designation = designation;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public boolean isGovt() {
        return govt;
    }

    public void setGovt(boolean govt) {
        this.govt = govt;
    }

    public boolean isRelevantProfessional() {
        return relevantProfessional;
    }

    public void setRelevantProfessional(boolean relevantProfessional) {
        this.relevantProfessional = relevantProfessional;
    }
}
