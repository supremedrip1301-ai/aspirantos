package com.aspirantos.model;

import java.time.LocalDateTime;

/**
 * Result of one "Check for updates" run of an exam (table exam_update_check).
 * Plain JavaBean like Student in lab Experiment 4: private fields, constructors,
 * getters and setters, no annotations.
 */
public class UpdateCheck {

    private int id;
    private int examId;
    private Integer checkedBy;
    private LocalDateTime checkedAt;
    private String urlChecked;
    private Integer httpStatus;
    private String contentSha256;
    private Boolean changedSinceLast;   // null = first check
    private String keywordHits;
    private String errorMessage;

    public UpdateCheck() {
    }

    public UpdateCheck(int id,
            int examId,
            Integer checkedBy,
            LocalDateTime checkedAt,
            String urlChecked,
            Integer httpStatus,
            String contentSha256,
            Boolean changedSinceLast,
            String keywordHits,
            String errorMessage) {
        this.id = id;
        this.examId = examId;
        this.checkedBy = checkedBy;
        this.checkedAt = checkedAt;
        this.urlChecked = urlChecked;
        this.httpStatus = httpStatus;
        this.contentSha256 = contentSha256;
        this.changedSinceLast = changedSinceLast;
        this.keywordHits = keywordHits;
        this.errorMessage = errorMessage;
    }

    public UpdateCheck(int examId,
            Integer checkedBy,
            LocalDateTime checkedAt,
            String urlChecked,
            Integer httpStatus,
            String contentSha256,
            Boolean changedSinceLast,
            String keywordHits,
            String errorMessage) {
        this.examId = examId;
        this.checkedBy = checkedBy;
        this.checkedAt = checkedAt;
        this.urlChecked = urlChecked;
        this.httpStatus = httpStatus;
        this.contentSha256 = contentSha256;
        this.changedSinceLast = changedSinceLast;
        this.keywordHits = keywordHits;
        this.errorMessage = errorMessage;
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

    public Integer getCheckedBy() {
        return checkedBy;
    }

    public void setCheckedBy(Integer checkedBy) {
        this.checkedBy = checkedBy;
    }

    public LocalDateTime getCheckedAt() {
        return checkedAt;
    }

    public void setCheckedAt(LocalDateTime checkedAt) {
        this.checkedAt = checkedAt;
    }

    public String getUrlChecked() {
        return urlChecked;
    }

    public void setUrlChecked(String urlChecked) {
        this.urlChecked = urlChecked;
    }

    public Integer getHttpStatus() {
        return httpStatus;
    }

    public void setHttpStatus(Integer httpStatus) {
        this.httpStatus = httpStatus;
    }

    public String getContentSha256() {
        return contentSha256;
    }

    public void setContentSha256(String contentSha256) {
        this.contentSha256 = contentSha256;
    }

    public Boolean getChangedSinceLast() {
        return changedSinceLast;
    }

    public void setChangedSinceLast(Boolean changedSinceLast) {
        this.changedSinceLast = changedSinceLast;
    }

    public String getKeywordHits() {
        return keywordHits;
    }

    public void setKeywordHits(String keywordHits) {
        this.keywordHits = keywordHits;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }
}
