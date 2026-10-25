package com.aspirantos.model;

/**
 * The organisation that conducts an exam (table conducting_body).
 * Plain JavaBean like Student in lab Experiment 4: private fields, constructors,
 * getters and setters, no annotations.
 */
public class ConductingBody {

    private int id;
    private String shortName;
    private String fullName;
    private String website;
    private String bodyType;

    public ConductingBody() {
    }

    public ConductingBody(int id,
            String shortName,
            String fullName,
            String website,
            String bodyType) {
        this.id = id;
        this.shortName = shortName;
        this.fullName = fullName;
        this.website = website;
        this.bodyType = bodyType;
    }

    public ConductingBody(String shortName,
            String fullName,
            String website,
            String bodyType) {
        this.shortName = shortName;
        this.fullName = fullName;
        this.website = website;
        this.bodyType = bodyType;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getShortName() {
        return shortName;
    }

    public void setShortName(String shortName) {
        this.shortName = shortName;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getWebsite() {
        return website;
    }

    public void setWebsite(String website) {
        this.website = website;
    }

    public String getBodyType() {
        return bodyType;
    }

    public void setBodyType(String bodyType) {
        this.bodyType = bodyType;
    }
}
