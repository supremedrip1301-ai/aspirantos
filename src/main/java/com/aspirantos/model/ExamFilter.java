package com.aspirantos.model;

/**
 * The search and filter values of the Exam Explorer (a GET form, so every value is visible
 * in the URL and the result page can be bookmarked). Null / empty = no filter.
 */
public class ExamFilter {

    private String query;           // part of the exam name, short name or code
    private String categoryCode;
    private String sector;          // GOVERNMENT / PRIVATE / AUTONOMOUS
    private String purpose;         // RECRUITMENT / ADMISSION / ...
    private String scope;           // NATIONAL / STATE / INTERNATIONAL
    private String stateCode;
    private String confidence;      // VERIFIED / LIKELY / NEEDS_VERIFICATION
    private String sort;            // name / category / confidence / month
    private int page = 1;
    private int pageSize = 12;

    public ExamFilter() {
    }

    public ExamFilter(String query, String categoryCode, String sector, String purpose, String scope,
                      String stateCode, String confidence, String sort, int page, int pageSize) {
        this.query = query;
        this.categoryCode = categoryCode;
        this.sector = sector;
        this.purpose = purpose;
        this.scope = scope;
        this.stateCode = stateCode;
        this.confidence = confidence;
        this.sort = sort;
        this.page = page;
        this.pageSize = pageSize;
    }

    public String getQuery() {
        return query;
    }

    public void setQuery(String query) {
        this.query = query;
    }

    public String getCategoryCode() {
        return categoryCode;
    }

    public void setCategoryCode(String categoryCode) {
        this.categoryCode = categoryCode;
    }

    public String getSector() {
        return sector;
    }

    public void setSector(String sector) {
        this.sector = sector;
    }

    public String getPurpose() {
        return purpose;
    }

    public void setPurpose(String purpose) {
        this.purpose = purpose;
    }

    public String getScope() {
        return scope;
    }

    public void setScope(String scope) {
        this.scope = scope;
    }

    public String getStateCode() {
        return stateCode;
    }

    public void setStateCode(String stateCode) {
        this.stateCode = stateCode;
    }

    public String getConfidence() {
        return confidence;
    }

    public void setConfidence(String confidence) {
        this.confidence = confidence;
    }

    public String getSort() {
        return sort;
    }

    public void setSort(String sort) {
        this.sort = sort;
    }

    public int getPage() {
        return page;
    }

    public void setPage(int page) {
        this.page = page;
    }

    public int getPageSize() {
        return pageSize;
    }

    public void setPageSize(int pageSize) {
        this.pageSize = pageSize;
    }
}
