package com.aspirantos.model;

import java.time.LocalDate;

import com.aspirantos.util.DateUtil;
import com.aspirantos.util.ValidationUtil;

/**
 * Form bean of the 4-step profile wizard, kept in the session with
 *     <jsp:useBean id="profile" class="com.aspirantos.model.ProfileBean" scope="session"/>
 * and filled by <jsp:setProperty name="profile" property="*"/>.
 *
 * setProperty copies request parameters into setters with the same name, so every field
 * has the same name as its form input. Text fields are Strings (dates and numbers are
 * checked and converted only when the profile is saved); check boxes are booleans.
 * profile-save.jsp turns the bean into a Profile and saves it with ProfileDAO.
 */
public class ProfileBean {

    // step 1 - personal details
    private String fullName;
    private String phone;
    private String dob;                 // yyyy-MM-dd from <input type="date">
    private String gender;
    private String maritalStatus;
    private String nationality = "INDIAN";
    private String fatherName;
    private String motherName;
    private String addressLine;
    private String city;
    private String pincode;
    private String domicileStateCode;

    // step 2 - category and special status
    private String category = "GEN";
    private boolean pwbd;
    private String pwbdType;
    private String pwbdPercent;
    private boolean exServiceman;
    private String esmServiceYears;
    private String esmReleaseDate;
    private boolean jkDomicile198089;
    private boolean govtEmployee;
    private String govtServiceYears;

    // wizard state
    private boolean loaded;             // values copied from the database once
    private boolean step1Done;
    private boolean step2Done;

    public ProfileBean() {
    }

    /** Copies the saved account and profile into the bean (editing an existing profile). */
    public void loadFrom(User user, Profile p) {
        fullName = user.getFullName();
        phone = user.getPhone();
        if (p != null) {
            dob = DateUtil.toInput(p.getDob());
            gender = p.getGender();
            maritalStatus = p.getMaritalStatus();
            nationality = p.getNationality();
            fatherName = p.getFatherName();
            motherName = p.getMotherName();
            addressLine = p.getAddressLine();
            city = p.getCity();
            pincode = p.getPincode();
            domicileStateCode = p.getDomicileStateCode();
            category = p.getCategory();
            pwbd = p.isPwbd();
            pwbdType = p.getPwbdType();
            pwbdPercent = p.getPwbdPercent() == null ? null : String.valueOf(p.getPwbdPercent());
            exServiceman = p.isExServiceman();
            esmServiceYears = p.getEsmServiceYears() == null ? null : trimNumber(p.getEsmServiceYears());
            esmReleaseDate = DateUtil.toInput(p.getEsmReleaseDate());
            jkDomicile198089 = p.isJkDomicile198089();
            govtEmployee = p.isGovtEmployee();
            govtServiceYears = p.getGovtServiceYears() == null ? null : trimNumber(p.getGovtServiceYears());
            step1Done = validateStep1() == null;
            step2Done = validateStep2() == null;
        }
        loaded = true;
    }

    /**
     * jsp:setProperty does not touch a property whose parameter is empty or missing, so
     * before a step is submitted its fields are cleared; otherwise a cleared text box or an
     * unticked check box would keep its old value.
     */
    public void clearStep1() {
        fullName = null;
        phone = null;
        dob = null;
        gender = null;
        maritalStatus = null;
        nationality = null;
        fatherName = null;
        motherName = null;
        addressLine = null;
        city = null;
        pincode = null;
        domicileStateCode = null;
    }

    public void clearStep2() {
        category = null;
        pwbd = false;
        pwbdType = null;
        pwbdPercent = null;
        exServiceman = false;
        esmServiceYears = null;
        esmReleaseDate = null;
        jkDomicile198089 = false;
        govtEmployee = false;
        govtServiceYears = null;
    }

    /** The bean as a Profile row (call only after the steps were validated). */
    public Profile toProfile(int userId) {
        Profile p = new Profile();
        p.setUserId(userId);
        p.setDob(DateUtil.parse(dob));
        p.setGender(ValidationUtil.clean(gender));
        p.setCategory(category == null ? "GEN" : category);
        p.setPwbd(pwbd);
        p.setPwbdType(pwbd ? ValidationUtil.clean(pwbdType) : null);
        p.setPwbdPercent(pwbd ? ValidationUtil.parseIntOrNull(pwbdPercent) : null);
        p.setExServiceman(exServiceman);
        p.setEsmServiceYears(exServiceman ? ValidationUtil.parseDoubleOrNull(esmServiceYears) : null);
        p.setEsmReleaseDate(exServiceman ? DateUtil.parse(esmReleaseDate) : null);
        p.setDomicileStateCode(ValidationUtil.clean(domicileStateCode));
        p.setJkDomicile198089(jkDomicile198089);
        p.setGovtEmployee(govtEmployee);
        p.setGovtServiceYears(govtEmployee ? ValidationUtil.parseDoubleOrNull(govtServiceYears) : null);
        p.setMaritalStatus(ValidationUtil.clean(maritalStatus));
        p.setNationality(nationality == null ? "INDIAN" : nationality);
        p.setFatherName(ValidationUtil.clean(fatherName));
        p.setMotherName(ValidationUtil.clean(motherName));
        p.setAddressLine(ValidationUtil.clean(addressLine));
        p.setCity(ValidationUtil.clean(city));
        p.setPincode(ValidationUtil.clean(pincode));
        p.setProfileCompletionPct(completionPercent(0));
        return p;
    }

    /** Rough completeness for the dashboard: 10 profile fields + education rows. */
    public int completionPercent(int educationRows) {
        int filled = 0;
        String[] fields = {dob, gender, maritalStatus, nationality, category, domicileStateCode,
                           fatherName, motherName, city, pincode};
        for (String f : fields) {
            if (!ValidationUtil.isBlank(f)) {
                filled++;
            }
        }
        int pct = filled * 8;                       // 80 % for the profile fields
        pct += Math.min(educationRows, 2) * 10;     // 20 % for at least two education rows
        return Math.min(100, pct);
    }

    /** Age today, for the review step ("27 years"); null when the date is missing. */
    public String getAgeText() {
        LocalDate d = DateUtil.parse(dob);
        return d == null ? null : DateUtil.describeAge(d, LocalDate.now());
    }

    private static String trimNumber(double value) {
        return value == Math.floor(value) ? String.valueOf((int) value) : String.valueOf(value);
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getDob() {
        return dob;
    }

    public void setDob(String dob) {
        this.dob = dob;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
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

    public String getDomicileStateCode() {
        return domicileStateCode;
    }

    public void setDomicileStateCode(String domicileStateCode) {
        this.domicileStateCode = domicileStateCode;
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

    public String getPwbdPercent() {
        return pwbdPercent;
    }

    public void setPwbdPercent(String pwbdPercent) {
        this.pwbdPercent = pwbdPercent;
    }

    public boolean isExServiceman() {
        return exServiceman;
    }

    public void setExServiceman(boolean exServiceman) {
        this.exServiceman = exServiceman;
    }

    public String getEsmServiceYears() {
        return esmServiceYears;
    }

    public void setEsmServiceYears(String esmServiceYears) {
        this.esmServiceYears = esmServiceYears;
    }

    public String getEsmReleaseDate() {
        return esmReleaseDate;
    }

    public void setEsmReleaseDate(String esmReleaseDate) {
        this.esmReleaseDate = esmReleaseDate;
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

    public String getGovtServiceYears() {
        return govtServiceYears;
    }

    public void setGovtServiceYears(String govtServiceYears) {
        this.govtServiceYears = govtServiceYears;
    }

    // The wizard flags have no setters on purpose: jsp:setProperty property="*" can only set
    // properties that have a setter, so a posted "step2Done=true" cannot skip a step.

    public boolean isLoaded() {
        return loaded;
    }

    public boolean isStep1Done() {
        return step1Done;
    }

    public void markStep1Done() {
        step1Done = true;
    }

    public boolean isStep2Done() {
        return step2Done;
    }

    public void markStep2Done() {
        step2Done = true;
    }

    // ------------------------------------------------------------ validation (server side)

    /** First problem of step 1, or null when the step is valid. */
    public String validateStep1() {
        if (!ValidationUtil.isValidName(fullName)) {
            return "Please enter your full name (letters only, at least 3 characters).";
        }
        if (!ValidationUtil.isBlank(phone) && !ValidationUtil.isValidPhone(phone)) {
            return "Mobile number must have exactly 10 digits.";
        }
        LocalDate d = DateUtil.parse(dob);
        if (d == null) {
            return "Please enter your date of birth.";
        }
        if (d.isAfter(LocalDate.now().minusYears(10)) || d.isBefore(LocalDate.now().minusYears(80))) {
            return "Please check your date of birth - age must be between 10 and 80 years.";
        }
        if (!ValidationUtil.isOneOf(gender, "MALE", "FEMALE", "TRANSGENDER")) {
            return "Please choose your gender.";
        }
        if (!ValidationUtil.isOneOf(maritalStatus, "UNMARRIED", "MARRIED", "WIDOWED", "DIVORCED")) {
            return "Please choose your marital status.";
        }
        if (!ValidationUtil.isOneOf(nationality, "INDIAN", "NEPAL", "BHUTAN", "TIBETAN_REFUGEE", "PIO", "OTHER")) {
            return "Please choose your nationality.";
        }
        if (domicileStateCode == null || !domicileStateCode.matches("[A-Z]{2,3}")) {
            return "Please choose your domicile state.";
        }
        if (!ValidationUtil.isBlank(fatherName) && !ValidationUtil.isValidName(fatherName)) {
            return "Father's name can contain letters, spaces, dots and apostrophes only.";
        }
        if (!ValidationUtil.isBlank(motherName) && !ValidationUtil.isValidName(motherName)) {
            return "Mother's name can contain letters, spaces, dots and apostrophes only.";
        }
        if (addressLine != null && addressLine.trim().length() > 200) {
            return "Address can be at most 200 characters.";
        }
        if (!ValidationUtil.isBlank(city) && !city.trim().matches("[A-Za-z .'-]{2,80}")) {
            return "City can contain letters and spaces only.";
        }
        if (!ValidationUtil.isBlank(pincode) && !ValidationUtil.isValidPincode(pincode)) {
            return "PIN code must have 6 digits and cannot start with 0.";
        }
        return null;
    }

    /** First problem of step 2, or null when the step is valid. */
    public String validateStep2() {
        if (!ValidationUtil.isOneOf(category, "GEN", "EWS", "OBC_NCL", "SC", "ST")) {
            return "Please choose your category.";
        }
        if (pwbd) {
            if (!ValidationUtil.isOneOf(pwbdType, "LOCOMOTOR", "VISUAL", "HEARING", "SPEECH_LANGUAGE",
                                        "INTELLECTUAL", "MENTAL_ILLNESS", "MULTIPLE", "OTHER")) {
                return "Please choose the type of disability.";
            }
            if (!ValidationUtil.inRange(ValidationUtil.parseIntOrNull(pwbdPercent), 1, 100)) {
                return "Disability percentage must be a whole number from 1 to 100 (as on your certificate).";
            }
        }
        if (exServiceman) {
            if (!ValidationUtil.inRange(ValidationUtil.parseDoubleOrNull(esmServiceYears), 0.5, 40)) {
                return "Military service must be between 0.5 and 40 years (it is deducted from your age).";
            }
            LocalDate release = DateUtil.parse(esmReleaseDate);
            if (!ValidationUtil.isBlank(esmReleaseDate) && (release == null || release.isAfter(LocalDate.now().plusYears(1)))) {
                return "Please check the release date from the armed forces.";
            }
        }
        if (govtEmployee && !ValidationUtil.isBlank(govtServiceYears)
                && !ValidationUtil.inRange(ValidationUtil.parseDoubleOrNull(govtServiceYears), 0, 45)) {
            return "Government service must be between 0 and 45 years.";
        }
        return null;
    }
}
