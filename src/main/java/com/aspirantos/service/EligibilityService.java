package com.aspirantos.service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.aspirantos.dao.AttemptDAO;
import com.aspirantos.dao.EducationDAO;
import com.aspirantos.dao.ExamDAO;
import com.aspirantos.dao.ExamEventDAO;
import com.aspirantos.dao.ProfileDAO;
import com.aspirantos.dao.RuleDAO;
import com.aspirantos.dao.SettingDAO;
import com.aspirantos.dao.SnapshotDAO;
import com.aspirantos.dao.TrackingDAO;
import com.aspirantos.dao.WorkExperienceDAO;
import com.aspirantos.engine.CandidateData;
import com.aspirantos.engine.EligibilityEngine;
import com.aspirantos.engine.EligibilityResult;
import com.aspirantos.engine.ExamRuleSet;
import com.aspirantos.model.AttemptLog;
import com.aspirantos.model.Education;
import com.aspirantos.model.EligibilitySnapshot;
import com.aspirantos.model.Exam;
import com.aspirantos.model.Profile;
import com.aspirantos.model.Tracking;
import com.aspirantos.model.WorkExperience;

/**
 * Connects the engine to the database (MASTER_PROMPT PART 6, step 9).
 * [EXTRA] Service layer + result cache: the lab used JSP -> DAO directly; this class sits
 * between the JSPs and the DAOs so that the engine stays free of JDBC and results are cached.
 *
 * - checkExam(): full result with all check lines (exam detail page); also stores the snapshot.
 * - getSnapshots(): cached results for the dashboard and the exam list. A snapshot is reused
 *   when it was computed for the same "today" and the same active rule version; otherwise it
 *   is computed again. Triggers delete snapshots when the profile, education, attempts or
 *   rules change, so missing rows are the normal case after an edit.
 *
 * "today" = app_setting.simulation_date when the admin has set it, else the real date.
 */
public class EligibilityService {

    private ExamDAO examDAO = new ExamDAO();
    private RuleDAO ruleDAO = new RuleDAO();
    private ExamEventDAO eventDAO = new ExamEventDAO();
    private ProfileDAO profileDAO = new ProfileDAO();
    private EducationDAO educationDAO = new EducationDAO();
    private WorkExperienceDAO workDAO = new WorkExperienceDAO();
    private TrackingDAO trackingDAO = new TrackingDAO();
    private AttemptDAO attemptDAO = new AttemptDAO();
    private SnapshotDAO snapshotDAO = new SnapshotDAO();
    private SettingDAO settingDAO = new SettingDAO();
    private EligibilityEngine engine = new EligibilityEngine();

    public LocalDate getToday() {
        return settingDAO.getToday();
    }

    public int getCyclesToPlan() {
        return settingDAO.getInt("upcoming_cycles_to_plan", 15);
    }

    /** The active rule version of an exam with all rule rows and events; null when the exam has no active version. */
    public ExamRuleSet loadRuleSet(Exam exam) {
        if (exam == null || exam.getActiveRuleVersionId() == null) {
            return null;
        }
        int versionId = exam.getActiveRuleVersionId();
        ExamRuleSet rules = new ExamRuleSet(exam, versionId);
        rules.setAgeRules(ruleDAO.getAgeRules(versionId));
        rules.setRelaxationRules(ruleDAO.getRelaxationRules(versionId));
        rules.setAttemptRules(ruleDAO.getAttemptRules(versionId));
        rules.setQualificationRules(ruleDAO.getQualificationRules(versionId));
        rules.setOtherRules(ruleDAO.getOtherRules(versionId));
        rules.setEvents(eventDAO.getEventsByExam(exam.getId()));
        return rules;
    }

    /** Profile, education, work experience and the attempts of one exam. */
    public CandidateData loadCandidate(int userId, int examId) {
        Profile profile = profileDAO.getProfile(userId);
        List<Education> educations = educationDAO.getEducationByUser(userId);
        List<WorkExperience> work = workDAO.getWorkByUser(userId);
        Tracking tracking = trackingDAO.getTracking(userId, examId);
        int before = tracking == null ? 0 : tracking.getAttemptsUsedBeforeApp();
        List<AttemptLog> logs = attemptDAO.getAttemptsByUserAndExam(userId, examId);
        return new CandidateData(profile, educations, work, before, logs);
    }

    /** Fresh result with every check line, for the exam detail page. Null when the exam has no active rules. */
    public EligibilityResult checkExam(int userId, int examId) {
        Exam exam = examDAO.getExam(examId);
        ExamRuleSet rules = loadRuleSet(exam);
        if (rules == null) {
            return null;
        }
        EligibilityResult result = engine.evaluate(loadCandidate(userId, examId), rules, getToday(), getCyclesToPlan());
        if (!result.isProfileIncomplete()) {
            snapshotDAO.saveSnapshot(toSnapshot(userId, result));
        }
        return result;
    }

    /**
     * Cached results of many exams (dashboard, explorer). Profile, education and attempts are
     * read once; only missing or stale snapshots are computed. Empty list when the profile has no
     * date of birth yet.
     */
    public List<EligibilitySnapshot> getSnapshots(int userId, List<Exam> exams) {
        List<EligibilitySnapshot> list = new ArrayList<>();
        Profile profile = profileDAO.getProfile(userId);
        if (profile == null || profile.getDob() == null) {
            return list;
        }
        LocalDate today = getToday();
        int cycles = getCyclesToPlan();

        Map<Integer, EligibilitySnapshot> cached = new HashMap<>();
        for (EligibilitySnapshot s : snapshotDAO.getSnapshotsByUser(userId)) {
            cached.put(s.getExamId(), s);
        }
        List<Education> educations = null;
        List<WorkExperience> work = null;
        Map<Integer, Integer> attemptsBefore = null;
        Map<Integer, List<AttemptLog>> logsByExam = null;

        for (Exam exam : exams) {
            EligibilitySnapshot s = cached.get(exam.getId());
            if (s != null && today.equals(s.getComputedForDate()) && exam.getActiveRuleVersionId() != null
                    && exam.getActiveRuleVersionId() == s.getRuleVersionId()) {
                list.add(s);
                continue;
            }
            ExamRuleSet rules = loadRuleSet(exam);
            if (rules == null) {
                continue;
            }
            if (educations == null) {   // read the student's data only when something must be computed
                educations = educationDAO.getEducationByUser(userId);
                work = workDAO.getWorkByUser(userId);
                attemptsBefore = new HashMap<>();
                for (Tracking t : trackingDAO.getTrackingByUser(userId)) {
                    attemptsBefore.put(t.getExamId(), t.getAttemptsUsedBeforeApp());
                }
                logsByExam = new HashMap<>();
                for (AttemptLog log : attemptDAO.getAttemptsByUser(userId)) {
                    List<AttemptLog> ofExam = logsByExam.get(log.getExamId());
                    if (ofExam == null) {
                        ofExam = new ArrayList<>();
                        logsByExam.put(log.getExamId(), ofExam);
                    }
                    ofExam.add(log);
                }
            }
            int before = attemptsBefore.getOrDefault(exam.getId(), 0);
            List<AttemptLog> logs = logsByExam.getOrDefault(exam.getId(), new ArrayList<>());
            CandidateData candidate = new CandidateData(profile, educations, work, before, logs);
            EligibilityResult result = engine.evaluate(candidate, rules, today, cycles);
            EligibilitySnapshot fresh = toSnapshot(userId, result);
            snapshotDAO.saveSnapshot(fresh);
            list.add(fresh);
        }
        return list;
    }

    /** Cached result of one exam (null when it cannot be computed). */
    public EligibilitySnapshot getSnapshot(int userId, Exam exam) {
        List<Exam> one = new ArrayList<>();
        one.add(exam);
        List<EligibilitySnapshot> list = getSnapshots(userId, one);
        return list.isEmpty() ? null : list.get(0);
    }

    /** Engine result -> eligibility_snapshot row. */
    public static EligibilitySnapshot toSnapshot(int userId, EligibilityResult r) {
        EligibilitySnapshot s = new EligibilitySnapshot();
        s.setUserId(userId);
        s.setExamId(r.getExamId());
        s.setRuleVersionId(r.getRuleVersionId());
        s.setComputedForDate(r.getComputedFor());
        s.setStatus(r.getStatus());
        s.setAttemptsUsed(r.getAttemptsUsed() == null ? null : Math.min(255, r.getAttemptsUsed()));
        s.setAttemptsRemaining(r.getAttemptsRemaining() == null ? null : Math.max(0, r.getAttemptsRemaining()));
        s.setNextCycleYear(r.getNextCycleYear());
        s.setFirstEligibleYear(r.getFirstEligibleYear());
        s.setLastEligibleYear(r.getLastEligibleYear());
        String headline = r.getHeadline();
        s.setHeadline(headline.length() > 255 ? headline.substring(0, 252) + "..." : headline);
        s.setDetailsText(r.toDetailsText());
        return s;
    }
}
