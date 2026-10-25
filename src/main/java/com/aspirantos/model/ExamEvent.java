package com.aspirantos.model;

import java.time.LocalDate;

/**
 * A calendar date of an exam cycle (table exam_event).
 * Plain JavaBean like Student in lab Experiment 4: private fields, constructors,
 * getters and setters, no annotations.
 */
public class ExamEvent {

    private int id;
    private int examId;
    private String examCode;   // from exam
    private String examShortName;   // from exam
    private int cycleYear;
    private String eventType;
    private LocalDate eventDate;
    private boolean tentative;
    private String notes;

    public ExamEvent() {
    }

    public ExamEvent(int id,
            int examId,
            String examCode,
            String examShortName,
            int cycleYear,
            String eventType,
            LocalDate eventDate,
            boolean tentative,
            String notes) {
        this.id = id;
        this.examId = examId;
        this.examCode = examCode;
        this.examShortName = examShortName;
        this.cycleYear = cycleYear;
        this.eventType = eventType;
        this.eventDate = eventDate;
        this.tentative = tentative;
        this.notes = notes;
    }

    public ExamEvent(int examId,
            String examCode,
            String examShortName,
            int cycleYear,
            String eventType,
            LocalDate eventDate,
            boolean tentative,
            String notes) {
        this.examId = examId;
        this.examCode = examCode;
        this.examShortName = examShortName;
        this.cycleYear = cycleYear;
        this.eventType = eventType;
        this.eventDate = eventDate;
        this.tentative = tentative;
        this.notes = notes;
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

    public String getExamCode() {
        return examCode;
    }

    public void setExamCode(String examCode) {
        this.examCode = examCode;
    }

    public String getExamShortName() {
        return examShortName;
    }

    public void setExamShortName(String examShortName) {
        this.examShortName = examShortName;
    }

    public int getCycleYear() {
        return cycleYear;
    }

    public void setCycleYear(int cycleYear) {
        this.cycleYear = cycleYear;
    }

    public String getEventType() {
        return eventType;
    }

    public void setEventType(String eventType) {
        this.eventType = eventType;
    }

    public LocalDate getEventDate() {
        return eventDate;
    }

    public void setEventDate(LocalDate eventDate) {
        this.eventDate = eventDate;
    }

    public boolean isTentative() {
        return tentative;
    }

    public void setTentative(boolean tentative) {
        this.tentative = tentative;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}
