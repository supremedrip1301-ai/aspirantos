package com.aspirantos.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * The aspirant's eligibility profile (table aspirant_profile, one row per student).
 * Plain JavaBean like Student in lab Experiment 4: private fields, constructors,
 * getters and setters, no annotations.
 */
public class Profile {

    private int userId;
    private LocalDate dob;
    private String gender;   // MALE / FEMALE / TRANSGENDER
    private String category;   // GEN / EWS / OBC_NCL / SC / ST
    private boolean pwbd;
    private String pwbdType;
    private Integer pwbdPercent;
    private boolean exServiceman;
    private Double esmServiceYears;
    private LocalDate esmReleaseDate;
    private String domicileStateCode;
    private boolean jkDomicile198089;
    private boolean govtEmployee;
    private Double govtServiceYears;
    private String maritalStatus;
    private String nationality;
    private String fatherName;
    private String motherName;
    private String addressLine;
    private String city;
    private String pincode;
    private String aadhaarLast4;   // only the last 4 digits
    private int profileCompletionPct;
    private LocalDateTime updatedAt;

    public Profile() {
    }

    public Profile(int userId,
            LocalDate dob,
            String gender,
            String category,
            boolean pwbd,
            String pwbdType,
            Integer pwbdPercent,
            boolean exServiceman,
            Double esmServiceYears,
            LocalDate esmReleaseDate,
            String domicileStateCode,
            boolean jkDomicile198089,
            boolean govtEmployee,
            Double govtServiceYears,
            String maritalStatus,
            String nationality,
            String fatherName,
            String motherName,
            String addressLine,
            String city,
            String pincode,
            String aadhaarLast4,
            int profileCompletionPct,
            LocalDateTime updatedAt) {
        this.userId = userId;
        this.dob = dob;
        this.gender = gender;
        this.category = category;
        this.pwbd = pwbd;
        this.pwbdType = pwbdType;
        this.pwbdPercent = pwbdPercent;
        this.exServiceman = exServiceman;
        this.esmServiceYears = esmServiceYears;
        this.esmReleaseDate = esmReleaseDate;
        this.domicileStateCode = domicileStateCode;
        this.jkDomicile198089 = jkDomicile198089;
        this.govtEmployee = govtEmployee;
        this.govtServiceYears = govtServiceYears;
        this.maritalStatus = maritalStatus;
        this.nationality = nationality;
        this.fatherName = fatherName;
        this.motherName = motherName;
        this.addressLine = addressLine;
        this.city = city;
        this.pincode = pincode;
        this.aadhaarLast4 = aadhaarLast4;
        this.profileCompletionPct = profileCompletionPct;
        this.updatedAt = updatedAt;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public LocalDate getDob() {
        return dob;
    }

    public void setDob(LocalDate dob) {
        this.dob = dob;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public boolean isPwbd() {
        return pwbd;
    }

    public void setPwbd(boolean pwbd) {
        this.pwbd = pwbd;
    }

    public String getPwbdType() {
        return pwbdType;
    }

    public void setPwbdType(String pwbdType) {
        this.pwbdType = pwbdType;
    }

    public Integer getPwbdPercent() {
        return pwbdPercent;
    }

    public void setPwbdPercent(Integer pwbdPercent) {
        this.pwbdPercent = pwbdPercent;
    }

    public boolean isExServiceman() {
        return exServiceman;
    }

    public void setExServiceman(boolean exServiceman) {
        this.exServiceman = exServiceman;
    }

    public Double getEsmServiceYears() {
        return esmServiceYears;
    }

    public void setEsmServiceYears(Double esmServiceYears) {
        this.esmServiceYears = esmServiceYears;
    }

    public LocalDate getEsmReleaseDate() {
        return esmReleaseDate;
    }

    public void setEsmReleaseDate(LocalDate esmReleaseDate) {
        this.esmReleaseDate = esmReleaseDate;
    }

    public String getDomicileStateCode() {
        return domicileStateCode;
    }

    public void setDomicileStateCode(String domicileStateCode) {
        this.domicileStateCode = domicileStateCode;
    }

    public boolean isJkDomicile198089() {
        return jkDomicile198089;
    }

    public void setJkDomicile198089(boolean jkDomicile198089) {
        this.jkDomicile198089 = jkDomicile198089;
    }

    public boolean isGovtEmployee() {
        return govtEmployee;
    }

    public void setGovtEmployee(boolean govtEmployee) {
        this.govtEmployee = govtEmployee;
    }

    public Double getGovtServiceYears() {
        return govtServiceYears;
    }

    public void setGovtServiceYears(Double govtServiceYears) {
        this.govtServiceYears = govtServiceYears;
    }

    public String getMaritalStatus() {
        return maritalStatus;
    }

    public void setMaritalStatus(String maritalStatus) {
        this.maritalStatus = maritalStatus;
    }

    public String getNationality() {
        return nationality;
    }

    public void setNationality(String nationality) {
        this.nationality = nationality;
    }

    public String getFatherName() {
        return fatherName;
    }

    public void setFatherName(String fatherName) {
        this.fatherName = fatherName;
    }

    public String getMotherName() {
        return motherName;
    }

    public void setMotherName(String motherName) {
        this.motherName = motherName;
    }

    public String getAddressLine() {
        return addressLine;
    }

    public void setAddressLine(String addressLine) {
        this.addressLine = addressLine;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getPincode() {
        return pincode;
    }

    public void setPincode(String pincode) {
        this.pincode = pincode;
    }

    public String getAadhaarLast4() {
        return aadhaarLast4;
    }

    public void setAadhaarLast4(String aadhaarLast4) {
        this.aadhaarLast4 = aadhaarLast4;
    }

    public int getProfileCompletionPct() {
        return profileCompletionPct;
    }

    public void setProfileCompletionPct(int profileCompletionPct) {
        this.profileCompletionPct = profileCompletionPct;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
