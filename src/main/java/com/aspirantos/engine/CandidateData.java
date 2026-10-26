package com.aspirantos.engine;

import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.AttemptLog;
import com.aspirantos.model.Education;
import com.aspirantos.model.Profile;
import com.aspirantos.model.WorkExperience;

/**
 * Everything the engine needs to know about the student for one exam: profile,
 * education rows, work experience, attempts used before joining the app and the
 * attempt journal of that exam.
 */
public class CandidateData {

    private Profile profile;
    private List<Education> educations = new ArrayList<>();
    private List<WorkExperience> workExperiences = new ArrayList<>();
    private int attemptsBeforeApp;
    private List<AttemptLog> attemptLogs = new ArrayList<>();

    public CandidateData() {
    }

    public CandidateData(Profile profile, List<Education> educations, List<WorkExperience> workExperiences,
                         int attemptsBeforeApp, List<AttemptLog> attemptLogs) {
        this.profile = profile;
        this.educations = educations;
        this.workExperiences = workExperiences;
        this.attemptsBeforeApp = attemptsBeforeApp;
        this.attemptLogs = attemptLogs;
    }

    /** GEN when the profile has no category. OBC creamy layer is stored as GEN. */
    public String getCategory() {
        if (profile == null || profile.getCategory() == null) {
            return "GEN";
        }
        return profile.getCategory();
    }

    /** PwBD with a benchmark disability (40 % or more). A missing percentage is assumed to be benchmark. */
    public boolean isBenchmarkPwbd() {
        if (profile == null || !profile.isPwbd()) {
            return false;
        }
        return profile.getPwbdPercent() == null || profile.getPwbdPercent() >= 40;
    }

    public boolean isFemale() {
        return profile != null && "FEMALE".equals(profile.getGender());
    }

    public Profile getProfile() {
        return profile;
    }

    public void setProfile(Profile profile) {
        this.profile = profile;
    }

    public List<Education> getEducations() {
        return educations;
    }

    public void setEducations(List<Education> educations) {
        this.educations = educations;
    }

    public List<WorkExperience> getWorkExperiences() {
        return workExperiences;
    }

    public void setWorkExperiences(List<WorkExperience> workExperiences) {
        this.workExperiences = workExperiences;
    }

    public int getAttemptsBeforeApp() {
        return attemptsBeforeApp;
    }

    public void setAttemptsBeforeApp(int attemptsBeforeApp) {
        this.attemptsBeforeApp = attemptsBeforeApp;
    }

    public List<AttemptLog> getAttemptLogs() {
        return attemptLogs;
    }

    public void setAttemptLogs(List<AttemptLog> attemptLogs) {
        this.attemptLogs = attemptLogs;
    }
}
