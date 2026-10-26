package com.aspirantos.model;

import java.time.LocalDate;

/**
 * One education level of a student (table education).
 * Plain JavaBean like Student in lab Experiment 4: private fields, constructors,
 * getters and setters, no annotations.
 */
public class Education {

    /** Subjects offered as tick boxes on the education form; the eligibility rules use the same words. */
    public static final String[] COMMON_SUBJECTS = {
        "PHYSICS", "CHEMISTRY", "MATHS", "BIOLOGY", "BIOTECHNOLOGY", "ENGLISH", "HINDI",
        "COMPUTER SCIENCE", "INFORMATION TECHNOLOGY", "ELECTRONICS", "STATISTICS", "ECONOMICS",
        "ACCOUNTANCY", "BUSINESS STUDIES", "HISTORY", "GEOGRAPHY", "POLITICAL SCIENCE",
        "BOTANY", "ZOOLOGY", "GEOLOGY", "AGRICULTURE"
    };

    private int id;
    private int userId;
    private String level;   // CLASS_10 ... PROFESSIONAL
    private String degreeName;
    private String streamOrSpecialisation;
    private String subjects;   // comma list
    private String boardOrUniversity;
    private Double percentage;
    private Double cgpa;
    private Double cgpaScale;
    private Integer passingYear;
    private String status;   // COMPLETED or APPEARING
    private LocalDate expectedCompletionDate;

    public Education() {
    }

    public Education(int id,
            int userId,
            String level,
            String degreeName,
            String streamOrSpecialisation,
            String subjects,
            String boardOrUniversity,
            Double percentage,
            Double cgpa,
            Double cgpaScale,
            Integer passingYear,
            String status,
            LocalDate expectedCompletionDate) {
        this.id = id;
        this.userId = userId;
        this.level = level;
        this.degreeName = degreeName;
        this.streamOrSpecialisation = streamOrSpecialisation;
        this.subjects = subjects;
        this.boardOrUniversity = boardOrUniversity;
        this.percentage = percentage;
        this.cgpa = cgpa;
        this.cgpaScale = cgpaScale;
        this.passingYear = passingYear;
        this.status = status;
        this.expectedCompletionDate = expectedCompletionDate;
    }

    public Education(int userId,
            String level,
            String degreeName,
            String streamOrSpecialisation,
            String subjects,
            String boardOrUniversity,
            Double percentage,
            Double cgpa,
            Double cgpaScale,
            Integer passingYear,
            String status,
            LocalDate expectedCompletionDate) {
        this.userId = userId;
        this.level = level;
        this.degreeName = degreeName;
        this.streamOrSpecialisation = streamOrSpecialisation;
        this.subjects = subjects;
        this.boardOrUniversity = boardOrUniversity;
        this.percentage = percentage;
        this.cgpa = cgpa;
        this.cgpaScale = cgpaScale;
        this.passingYear = passingYear;
        this.status = status;
        this.expectedCompletionDate = expectedCompletionDate;
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

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public String getDegreeName() {
        return degreeName;
    }

    public void setDegreeName(String degreeName) {
        this.degreeName = degreeName;
    }

    public String getStreamOrSpecialisation() {
        return streamOrSpecialisation;
    }

    public void setStreamOrSpecialisation(String streamOrSpecialisation) {
        this.streamOrSpecialisation = streamOrSpecialisation;
    }

    public String getSubjects() {
        return subjects;
    }

    public void setSubjects(String subjects) {
        this.subjects = subjects;
    }

    public String getBoardOrUniversity() {
        return boardOrUniversity;
    }

    public void setBoardOrUniversity(String boardOrUniversity) {
        this.boardOrUniversity = boardOrUniversity;
    }

    public Double getPercentage() {
        return percentage;
    }

    public void setPercentage(Double percentage) {
        this.percentage = percentage;
    }

    public Double getCgpa() {
        return cgpa;
    }

    public void setCgpa(Double cgpa) {
        this.cgpa = cgpa;
    }

    public Double getCgpaScale() {
        return cgpaScale;
    }

    public void setCgpaScale(Double cgpaScale) {
        this.cgpaScale = cgpaScale;
    }

    public Integer getPassingYear() {
        return passingYear;
    }

    public void setPassingYear(Integer passingYear) {
        this.passingYear = passingYear;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDate getExpectedCompletionDate() {
        return expectedCompletionDate;
    }

    public void setExpectedCompletionDate(LocalDate expectedCompletionDate) {
        this.expectedCompletionDate = expectedCompletionDate;
    }
}
