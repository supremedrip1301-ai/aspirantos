package com.aspirantos.model;

/**
 * An exam followed by a student (table user_exam_tracking).
 * Plain JavaBean like Student in lab Experiment 4: private fields, constructors,
 * getters and setters, no annotations.
 */
public class Tracking {

    private int id;
    private int userId;
    private int examId;
    private boolean favourite;
    private int attemptsUsedBeforeApp;
    private Integer targetCycleYear;
    private String personalNote;

    public Tracking() {
    }

    public Tracking(int id,
            int userId,
            int examId,
            boolean favourite,
            int attemptsUsedBeforeApp,
            Integer targetCycleYear,
            String personalNote) {
        this.id = id;
        this.userId = userId;
        this.examId = examId;
        this.favourite = favourite;
        this.attemptsUsedBeforeApp = attemptsUsedBeforeApp;
        this.targetCycleYear = targetCycleYear;
        this.personalNote = personalNote;
    }

    public Tracking(int userId,
            int examId,
            boolean favourite,
            int attemptsUsedBeforeApp,
            Integer targetCycleYear,
            String personalNote) {
        this.userId = userId;
        this.examId = examId;
        this.favourite = favourite;
        this.attemptsUsedBeforeApp = attemptsUsedBeforeApp;
        this.targetCycleYear = targetCycleYear;
        this.personalNote = personalNote;
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

    public boolean isFavourite() {
        return favourite;
    }

    public void setFavourite(boolean favourite) {
        this.favourite = favourite;
    }

    public int getAttemptsUsedBeforeApp() {
        return attemptsUsedBeforeApp;
    }

    public void setAttemptsUsedBeforeApp(int attemptsUsedBeforeApp) {
        this.attemptsUsedBeforeApp = attemptsUsedBeforeApp;
    }

    public Integer getTargetCycleYear() {
        return targetCycleYear;
    }

    public void setTargetCycleYear(Integer targetCycleYear) {
        this.targetCycleYear = targetCycleYear;
    }

    public String getPersonalNote() {
        return personalNote;
    }

    public void setPersonalNote(String personalNote) {
        this.personalNote = personalNote;
    }
}
