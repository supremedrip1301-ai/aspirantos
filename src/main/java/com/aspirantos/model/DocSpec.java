package com.aspirantos.model;

/**
 * Photo / signature size rule of an exam (table doc_spec).
 * Plain JavaBean like Student in lab Experiment 4: private fields, constructors,
 * getters and setters, no annotations.
 */
public class DocSpec {

    private int id;
    private int examId;
    private String docType;
    private Integer minWidthPx;
    private Integer maxWidthPx;
    private Integer minHeightPx;
    private Integer maxHeightPx;
    private Integer minKb;
    private Integer maxKb;
    private String allowedFormats;
    private String backgroundRule;
    private boolean requiresNameAndDate;
    private Integer maxPhotoAgeMonths;
    private String notes;

    public DocSpec() {
    }

    public DocSpec(int id,
            int examId,
            String docType,
            Integer minWidthPx,
            Integer maxWidthPx,
            Integer minHeightPx,
            Integer maxHeightPx,
            Integer minKb,
            Integer maxKb,
            String allowedFormats,
            String backgroundRule,
            boolean requiresNameAndDate,
            Integer maxPhotoAgeMonths,
            String notes) {
        this.id = id;
        this.examId = examId;
        this.docType = docType;
        this.minWidthPx = minWidthPx;
        this.maxWidthPx = maxWidthPx;
        this.minHeightPx = minHeightPx;
        this.maxHeightPx = maxHeightPx;
        this.minKb = minKb;
        this.maxKb = maxKb;
        this.allowedFormats = allowedFormats;
        this.backgroundRule = backgroundRule;
        this.requiresNameAndDate = requiresNameAndDate;
        this.maxPhotoAgeMonths = maxPhotoAgeMonths;
        this.notes = notes;
    }

    public DocSpec(int examId,
            String docType,
            Integer minWidthPx,
            Integer maxWidthPx,
            Integer minHeightPx,
            Integer maxHeightPx,
            Integer minKb,
            Integer maxKb,
            String allowedFormats,
            String backgroundRule,
            boolean requiresNameAndDate,
            Integer maxPhotoAgeMonths,
            String notes) {
        this.examId = examId;
        this.docType = docType;
        this.minWidthPx = minWidthPx;
        this.maxWidthPx = maxWidthPx;
        this.minHeightPx = minHeightPx;
        this.maxHeightPx = maxHeightPx;
        this.minKb = minKb;
        this.maxKb = maxKb;
        this.allowedFormats = allowedFormats;
        this.backgroundRule = backgroundRule;
        this.requiresNameAndDate = requiresNameAndDate;
        this.maxPhotoAgeMonths = maxPhotoAgeMonths;
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

    public String getDocType() {
        return docType;
    }

    public void setDocType(String docType) {
        this.docType = docType;
    }

    public Integer getMinWidthPx() {
        return minWidthPx;
    }

    public void setMinWidthPx(Integer minWidthPx) {
        this.minWidthPx = minWidthPx;
    }

    public Integer getMaxWidthPx() {
        return maxWidthPx;
    }

    public void setMaxWidthPx(Integer maxWidthPx) {
        this.maxWidthPx = maxWidthPx;
    }

    public Integer getMinHeightPx() {
        return minHeightPx;
    }

    public void setMinHeightPx(Integer minHeightPx) {
        this.minHeightPx = minHeightPx;
    }

    public Integer getMaxHeightPx() {
        return maxHeightPx;
    }

    public void setMaxHeightPx(Integer maxHeightPx) {
        this.maxHeightPx = maxHeightPx;
    }

    public Integer getMinKb() {
        return minKb;
    }

    public void setMinKb(Integer minKb) {
        this.minKb = minKb;
    }

    public Integer getMaxKb() {
        return maxKb;
    }

    public void setMaxKb(Integer maxKb) {
        this.maxKb = maxKb;
    }

    public String getAllowedFormats() {
        return allowedFormats;
    }

    public void setAllowedFormats(String allowedFormats) {
        this.allowedFormats = allowedFormats;
    }

    public String getBackgroundRule() {
        return backgroundRule;
    }

    public void setBackgroundRule(String backgroundRule) {
        this.backgroundRule = backgroundRule;
    }

    public boolean isRequiresNameAndDate() {
        return requiresNameAndDate;
    }

    public void setRequiresNameAndDate(boolean requiresNameAndDate) {
        this.requiresNameAndDate = requiresNameAndDate;
    }

    public Integer getMaxPhotoAgeMonths() {
        return maxPhotoAgeMonths;
    }

    public void setMaxPhotoAgeMonths(Integer maxPhotoAgeMonths) {
        this.maxPhotoAgeMonths = maxPhotoAgeMonths;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}
