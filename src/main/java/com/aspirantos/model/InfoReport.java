package com.aspirantos.model;

import java.time.LocalDateTime;

/**
 * A "Report outdated info" message (table info_report).
 * Plain JavaBean like Student in lab Experiment 4: private fields, constructors,
 * getters and setters, no annotations.
 */
public class InfoReport {

    private int id;
    private int userId;
    private int examId;
    private String message;
    private String status;
    private String adminReply;
    private LocalDateTime createdAt;
    private String userName;   // from app_user
    private String examShortName;   // from exam

    public InfoReport() {
    }

    public InfoReport(int id,
            int userId,
            int examId,
            String message,
            String status,
            String adminReply,
            LocalDateTime createdAt,
            String userName,
            String examShortName) {
        this.id = id;
        this.userId = userId;
        this.examId = examId;
        this.message = message;
        this.status = status;
        this.adminReply = adminReply;
        this.createdAt = createdAt;
        this.userName = userName;
        this.examShortName = examShortName;
    }

    public InfoReport(int userId,
            int examId,
            String message,
            String status,
            String adminReply,
            LocalDateTime createdAt,
            String userName,
            String examShortName) {
        this.userId = userId;
        this.examId = examId;
        this.message = message;
        this.status = status;
        this.adminReply = adminReply;
        this.createdAt = createdAt;
        this.userName = userName;
        this.examShortName = examShortName;
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

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getAdminReply() {
        return adminReply;
    }

    public void setAdminReply(String adminReply) {
        this.adminReply = adminReply;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getExamShortName() {
        return examShortName;
    }

    public void setExamShortName(String examShortName) {
        this.examShortName = examShortName;
    }
}
