package com.aspirantos.model;

/**
 * An exam group such as Civil Services or Banking (table exam_category).
 * Plain JavaBean like Student in lab Experiment 4: private fields, constructors,
 * getters and setters, no annotations.
 */
public class ExamCategory {

    private int id;
    private String code;
    private String name;
    private String shortDescription;
    private String iconSvgName;
    private String accentColor;
    private int sortOrder;
    private int examCount;   // computed: active exams in the category

    public ExamCategory() {
    }

    public ExamCategory(int id,
            String code,
            String name,
            String shortDescription,
            String iconSvgName,
            String accentColor,
            int sortOrder,
            int examCount) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.shortDescription = shortDescription;
        this.iconSvgName = iconSvgName;
        this.accentColor = accentColor;
        this.sortOrder = sortOrder;
        this.examCount = examCount;
    }

    public ExamCategory(String code,
            String name,
            String shortDescription,
            String iconSvgName,
            String accentColor,
            int sortOrder,
            int examCount) {
        this.code = code;
        this.name = name;
        this.shortDescription = shortDescription;
        this.iconSvgName = iconSvgName;
        this.accentColor = accentColor;
        this.sortOrder = sortOrder;
        this.examCount = examCount;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getShortDescription() {
        return shortDescription;
    }

    public void setShortDescription(String shortDescription) {
        this.shortDescription = shortDescription;
    }

    public String getIconSvgName() {
        return iconSvgName;
    }

    public void setIconSvgName(String iconSvgName) {
        this.iconSvgName = iconSvgName;
    }

    public String getAccentColor() {
        return accentColor;
    }

    public void setAccentColor(String accentColor) {
        this.accentColor = accentColor;
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }

    public int getExamCount() {
        return examCount;
    }

    public void setExamCount(int examCount) {
        this.examCount = examCount;
    }
}
