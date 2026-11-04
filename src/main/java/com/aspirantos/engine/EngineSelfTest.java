package com.aspirantos.engine;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.AgeRule;
import com.aspirantos.model.AttemptLog;
import com.aspirantos.model.AttemptRule;
import com.aspirantos.model.Education;
import com.aspirantos.model.Exam;
import com.aspirantos.model.OtherRule;
import com.aspirantos.model.Profile;
import com.aspirantos.model.QualificationRule;
import com.aspirantos.model.RelaxationRule;

/**
 * Self-test of the eligibility engine. A plain main method - no JUnit -
 * so it runs like any lab program: in Eclipse right-click -> Run As -> Java Application.
 *
 * Everything is in memory: the rule sets copy the seeded rules of the real exams and the
 * candidates are SAMPLE PROFILES (test data inside Java only, never database accounts).
 * "Today" is fixed to 15-Jan-2027, the presentation simulation date.
 */
public class EngineSelfTest {

    private static final LocalDate TODAY = LocalDate.of(2027, 1, 15);
    private static final int CYCLES = 15;
    private static final String DASH = "\u2014";

    private static EligibilityEngine engine = new EligibilityEngine();
    private static int passed = 0;
    private static int failed = 0;
    private static int number = 0;

    public static void main(String[] args) {
        System.out.println("AspirantOS EngineSelfTest - today = " + TODAY);
        System.out.println("------------------------------------------------------------");

        // ---------- the PART 11 sample profile ----------
        EligibilityResult sample = run(sampleProfile(), upscCse());
        checkEquals("Sample profile (GEN, born 15-Sep-1996, B.A. 2018, 4 attempts): exact UPSC headline",
                "You have 2 UPSC attempts left, valid until 2028.", sample.getHeadline());
        check("Sample profile: status ELIGIBLE, used 4, remaining 2, cycle 2027",
                "ELIGIBLE".equals(sample.getStatus()) && sample.getAttemptsUsed() == 4
                && sample.getAttemptsRemaining() == 2 && sample.getNextCycleYear() == 2027, describe(sample));
        checkEquals("Sample profile: date-of-birth window for 2027",
                "You must be born between 02-Aug-1995 and 01-Aug-2006", sample.getDobWindow());
        checkEquals("Sample profile: relaxation breakdown (General)",
                "Base upper age 32, no relaxation applies to you.", sample.getRelaxationBreakdown());
        checkEquals("Sample profile: 609 days until the age limit (turns 32 on 15-Sep-2028)",
                Long.valueOf(609), sample.getDaysUntilAgeLimitCrossed());

        // ---------- NOT_ATTAINED vs NOT_MORE_THAN on boundary birthdays (cut-off 01-Aug-2027) ----------
        EligibilityResult r = run(graduate("1995-08-02", "GEN", 0), upscCse());
        checkEquals("NOT_ATTAINED 32: born 02-Aug-1995 (day after) is 31 on the cut-off -> eligible for 2027 only",
                "You have 6 UPSC attempts left, valid until 2027.", r.getHeadline());
        r = run(graduate("1995-08-01", "GEN", 0), upscCse());
        check("NOT_ATTAINED 32: born 01-Aug-1995 (birthday = cut-off) attains 32 -> NOT_ELIGIBLE",
                "NOT_ELIGIBLE".equals(r.getStatus()) && r.getHeadline().contains("01-Aug-2027"), describe(r));
        r = run(graduate("1995-07-31", "GEN", 0), upscCse());
        check("NOT_ATTAINED 32: born 31-Jul-1995 (day before) -> NOT_ELIGIBLE", "NOT_ELIGIBLE".equals(r.getStatus()), describe(r));
        r = run(graduate("1995-08-01", "GEN", 0), notMoreThan32());
        check("NOT_MORE_THAN 32: born 01-Aug-1995 is exactly 32 on the cut-off -> ELIGIBLE",
                "ELIGIBLE".equals(r.getStatus()), describe(r));
        r = run(graduate("1994-08-02", "GEN", 0), notMoreThan32());
        check("NOT_MORE_THAN 32: born 02-Aug-1994 (day after) is still 32 -> ELIGIBLE",
                "ELIGIBLE".equals(r.getStatus()) && r.getLastEligibleYear() == 2027, describe(r));
        r = run(graduate("1994-08-01", "GEN", 0), notMoreThan32());
        check("NOT_MORE_THAN 32: born 01-Aug-1994 turns 33 on the cut-off -> NOT_ELIGIBLE",
                "NOT_ELIGIBLE".equals(r.getStatus()), describe(r));
        r = run(graduate("2006-08-01", "GEN", 0), upscCse());
        check("Minimum age 21: born 01-Aug-2006 completes 21 on the cut-off -> ELIGIBLE",
                "ELIGIBLE".equals(r.getStatus()), describe(r));
        r = run(graduate("2006-08-02", "GEN", 0), upscCse());
        checkEquals("Minimum age 21: born 02-Aug-2006 is 20 -> NOT_YET from 2028",
                "Not eligible yet " + DASH + " eligible from 2028 (minimum age 21).", r.getHeadline());

        // ---------- relaxations and attempt limits ----------
        CandidateData obcPwbd = graduate("1983-03-01", "OBC_NCL", 0);
        obcPwbd.getProfile().setPwbd(true);
        obcPwbd.getProfile().setPwbdPercent(50);
        r = run(obcPwbd, upscCse());
        checkEquals("OBC + PwBD stacking: 32 + 3 + 10 = 45",
                "Base upper age 32 + OBC-NCL 3 + PwBD 10 = 45.", r.getRelaxationBreakdown());
        check("OBC + PwBD aged 44 on the cut-off is eligible with 9 attempts",
                "ELIGIBLE".equals(r.getStatus()) && r.getAttemptsRemaining() == 9 && r.getLastEligibleYear() == 2027, describe(r));
        CandidateData genPwbd = graduate("1990-01-01", "GEN", 0);
        genPwbd.getProfile().setPwbd(true);
        genPwbd.getProfile().setPwbdPercent(40);
        r = run(genPwbd, upscCse());
        check("General PwBD (40%) gets 9 attempts and +10 years",
                r.getAttemptsRemaining() == 9 && r.getRelaxationBreakdown().contains("PwBD 10 = 42"), describe(r));
        CandidateData lowPwbd = graduate("1990-01-01", "GEN", 0);
        lowPwbd.getProfile().setPwbd(true);
        lowPwbd.getProfile().setPwbdPercent(30);
        r = run(lowPwbd, upscCse());
        check("PwBD below 40% is not a benchmark disability: no relaxation, 6 attempts, NOT_ELIGIBLE at 37",
                "NOT_ELIGIBLE".equals(r.getStatus()) && r.getAttemptsRemaining() == 6, describe(r));
        r = run(graduate("1992-03-10", "SC", 0), upscCse());
        checkEquals("SC: unlimited attempts, ending by age (37) after 2028",
                "Unlimited attempts within age " + DASH + " eligible until 2028 (age limit).", r.getHeadline());
        check("SC: attemptsRemaining is null (shown as Unlimited)",
                r.getAttemptsRemaining() == null && "Unlimited (within age)".equals(r.getAttemptsRemainingText()), describe(r));
        r = run(graduate("1995-01-01", "EWS", 0), upscCse());
        check("EWS gets no age relaxation: 32 on the cut-off -> NOT_ELIGIBLE, reason shown",
                "NOT_ELIGIBLE".equals(r.getStatus()) && lineText(r, "Relaxation").contains("No age relaxation for EWS"), describe(r));
        r = run(graduate("1998-01-01", "GEN", 6), upscCse());
        checkEquals("Attempts exhausted: General with 6 of 6 used",
                "Attempts exhausted " + DASH + " you used 6 of 6.", r.getHeadline());
        CandidateData journal = graduate("1996-09-15", "GEN", 3);
        journal.getAttemptLogs().add(log(2025, null, true));     // appeared in prelims -> counts
        journal.getAttemptLogs().add(log(2026, null, false));    // applied only -> the trigger set FALSE
        r = run(journal, upscCse());
        check("Attempt journal: 3 before the app + 1 counted log (applied-only not counted) = 4 used, 2 left",
                r.getAttemptsUsed() == 4 && r.getAttemptsRemaining() == 2, describe(r));

        CandidateData esm = graduate("1990-01-10", "GEN", 0);
        esm.getProfile().setExServiceman(true);
        esm.getProfile().setEsmServiceYears(8.0);
        r = run(esm, sscCgl());
        check("Ex-serviceman: age 37 minus 8 years of service = 29, below 30 + 3 -> ELIGIBLE",
                "ELIGIBLE".equals(r.getStatus()) && lineText(r, "Age").contains("your age counts as 29"), describe(r));
        esm.getProfile().setEsmServiceYears(2.0);
        r = run(esm, sscCgl());
        check("Ex-serviceman: only 2 years of service -> age counts as 35 -> NOT_ELIGIBLE",
                "NOT_ELIGIBLE".equals(r.getStatus()), describe(r));
        CandidateData govt = graduate("1989-05-01", "GEN", 0);
        govt.getProfile().setGovtEmployee(true);
        r = run(govt, sscCgl());
        check("Government employee: upper age raised to 40 (REPLACE_WITH_MAX with cap) -> ELIGIBLE at 38",
                "ELIGIBLE".equals(r.getStatus()) && r.getRelaxationBreakdown().contains("raises it to 40"), describe(r));
        r = run(graduate("1999-03-01", "GEN", 0), sscCgl());
        check("SSC CGL post groups: age 28 -> best group is 18-30, a Post group line explains it",
                "ELIGIBLE".equals(r.getStatus()) && r.getPostGroup() != null && r.getPostGroup().startsWith("Posts with limit 18-30")
                && "Post group".equals(r.getCheckLines().get(0).getName()), describe(r));

        // ---------- state exam ----------
        CandidateData obcBihar = graduate("1985-03-01", "OBC_NCL", 0);
        obcBihar.getProfile().setDomicileStateCode("BR");
        r = run(obcBihar, uppscPcs());
        check("State exam: OBC from Bihar in UPPSC is treated as General (40) -> NOT_ELIGIBLE at 42",
                "NOT_ELIGIBLE".equals(r.getStatus()) && "WARN".equals(lineResult(r, "Domicile")), describe(r));
        obcBihar.getProfile().setDomicileStateCode("UP");
        r = run(obcBihar, uppscPcs());
        check("State exam: the same OBC candidate with UP domicile gets +5 (45) -> ELIGIBLE",
                "ELIGIBLE".equals(r.getStatus()), describe(r));

        // ---------- qualification ----------
        CandidateData finalYear = candidate(profile("2004-05-01", "GEN"), 0,
                appearing("UG", "B.Sc", "PHYSICS,CHEMISTRY,MATHS", "2027-06-30"));
        r = run(finalYear, upscCse());
        check("Final-year B.Sc student: PROVISIONAL, must pass by 30-Jun-2027",
                "PROVISIONAL".equals(r.getStatus()) && r.getHeadline().startsWith("Provisional: you must pass by 30-Jun-2027."), describe(r));
        CandidateData class12 = candidate(profile("2009-02-10", "GEN"), 0,
                edu("CLASS_10", null, null, 88.0, 2025),
                appearing("CLASS_12", null, "PHYSICS,CHEMISTRY,MATHS,ENGLISH", "2027-03-31"));
        r = run(class12, upscCse());
        checkEquals("Class 12 student and UPSC: NOT_YET, eligible after graduation",
                "Not eligible yet " + DASH + " eligible from 2030 after graduation.", r.getHeadline());
        CandidateData bcomFinal = candidate(profile("2005-09-09", "GEN"), 0,
                appearing("UG", "B.Com", "ACCOUNTANCY", "2027-05-31"));
        r = run(bcomFinal, ibpsClerk());
        check("IBPS Clerk: final year not allowed, but the result (31-May-2027) comes before the October exam -> PROVISIONAL",
                "PROVISIONAL".equals(r.getStatus()) && r.getHeadline().startsWith("Provisional: you must pass by 31-May-2027."), describe(r));
        CandidateData foreign = graduate("1998-01-01", "GEN", 0);
        foreign.getProfile().setNationality("OTHER");
        r = run(foreign, upscCse());
        check("Nationality not in the list -> NOT_ELIGIBLE", "NOT_ELIGIBLE".equals(r.getStatus())
                && "FAIL".equals(lineResult(r, "Nationality")), describe(r));

        // ---------- engineering / medical entrance ----------
        CandidateData jee = candidate(profile("2007-06-01", "GEN"), 0,
                edu("CLASS_12", null, "PHYSICS,CHEMISTRY,MATHS,ENGLISH", 85.0, 2025));
        r = run(jee, jeeMain());
        checkEquals("JEE Main: Class 12 in 2025 -> 3-year window 2025-2027",
                "Eligible for JEE Main until 2027 " + DASH + " 3 consecutive years from your Class 12 year (2025).", r.getHeadline());
        CandidateData jeeOld = candidate(profile("2005-06-01", "GEN"), 0,
                edu("CLASS_12", null, "PHYSICS,CHEMISTRY,MATHS,ENGLISH", 85.0, 2023));
        r = run(jeeOld, jeeMain());
        check("JEE Main: Class 12 in 2023 -> window 2023-2025 is over -> NOT_ELIGIBLE",
                "NOT_ELIGIBLE".equals(r.getStatus()) && r.getHeadline().contains("2023-2025"), describe(r));
        CandidateData adv = candidate(profile("2008-05-01", "GEN"), 1,
                edu("CLASS_12", null, "PHYSICS,CHEMISTRY,MATHS", 90.0, 2026));
        r = run(adv, jeeAdvanced());
        checkEquals("JEE Advanced: 2 attempts in 2 consecutive years, 1 used",
                "You have 1 JEE Advanced attempt left, valid until 2027.", r.getHeadline());
        r = run(candidate(profile("2002-09-30", "GEN"), 0, edu("CLASS_12", null, "PHYSICS,CHEMISTRY,MATHS", 90.0, 2026)), jeeAdvanced());
        check("JEE Advanced DOB window: born 30-Sep-2002 (before 01-Oct-2002) -> NOT_ELIGIBLE",
                "NOT_ELIGIBLE".equals(r.getStatus()) && r.getHeadline().contains("01-Oct-2002"), describe(r));
        r = run(candidate(profile("2002-10-01", "GEN"), 0, edu("CLASS_12", null, "PHYSICS,CHEMISTRY,MATHS", 90.0, 2026)), jeeAdvanced());
        check("JEE Advanced DOB window: born 01-Oct-2002 -> ELIGIBLE with 2 attempts",
                "ELIGIBLE".equals(r.getStatus()) && r.getAttemptsRemaining() == 2, describe(r));
        r = run(candidate(profile("1997-10-01", "SC"), 0, edu("CLASS_12", null, "PHYSICS,CHEMISTRY,MATHS", 90.0, 2026)), jeeAdvanced());
        check("JEE Advanced: SC window moves 5 years earlier (01-Oct-1997) -> ELIGIBLE",
                "ELIGIBLE".equals(r.getStatus()) && r.getDobWindow().contains("01-Oct-1997"), describe(r));
        CandidateData neet17 = candidate(profile("2010-12-31", "GEN"), 0,
                appearing("CLASS_12", null, "PHYSICS,CHEMISTRY,BIOLOGY,ENGLISH", "2027-03-31"));
        r = run(neet17, neetUg());
        check("NEET: born 31-Dec-2010 is 17 on 31-Dec-2027 -> PROVISIONAL (Class 12 appearing)",
                "PROVISIONAL".equals(r.getStatus()), describe(r));
        CandidateData neet16 = candidate(profile("2011-01-01", "GEN"), 0,
                appearing("CLASS_12", null, "PHYSICS,CHEMISTRY,BIOLOGY,ENGLISH", "2027-03-31"));
        r = run(neet16, neetUg());
        checkEquals("NEET: born 01-Jan-2011 is 16 on 31-Dec-2027 -> NOT_YET from 2028",
                "Not eligible yet " + DASH + " eligible from 2028 (minimum age 17).", r.getHeadline());
        r = run(candidate(profile("2008-01-01", "GEN"), 0, edu("CLASS_12", null, "PHYSICS,CHEMISTRY,MATHS,ENGLISH", 80.0, 2026)), neetUg());
        check("NEET subjects: PCM without Biology/Biotechnology -> NOT_ELIGIBLE",
                "NOT_ELIGIBLE".equals(r.getStatus()) && r.getHeadline().contains("BIOLOGY or BIOTECHNOLOGY"), describe(r));
        r = run(candidate(profile("2008-01-01", "GEN"), 0, edu("CLASS_12", null, "PHYSICS,CHEMISTRY,BIOTECHNOLOGY,ENGLISH", 80.0, 2026)), neetUg());
        check("NEET subjects: Biotechnology instead of Biology is accepted -> ELIGIBLE", "ELIGIBLE".equals(r.getStatus()), describe(r));

        // ---------- management / percentage / CGPA ----------
        r = run(candidate(profile("1970-05-05", "GEN"), 0, edu("UG", "B.Com", "ACCOUNTANCY", 55.0, 1991)), cat());
        checkEquals("CAT: no age limit, 55% graduate born 1970",
                "No age or attempt limit " + DASH + " you can take CAT every year.", r.getHeadline());
        r = run(candidate(profile("2000-05-05", "GEN"), 0, edu("UG", "B.Com", "ACCOUNTANCY", 48.0, 2021)), cat());
        check("CAT: General with 48% (needs 50%) -> NOT_ELIGIBLE", "NOT_ELIGIBLE".equals(r.getStatus())
                && "FAIL".equals(lineResult(r, "Percentage")), describe(r));
        r = run(candidate(profile("2000-05-05", "SC"), 0, edu("UG", "B.Com", "ACCOUNTANCY", 46.0, 2021)), cat());
        check("CAT: SC with 46% passes the relaxed 45% -> ELIGIBLE", "ELIGIBLE".equals(r.getStatus())
                && lineText(r, "Percentage").contains("relaxed for you from 50%"), describe(r));
        r = run(candidate(profile("2000-05-05", "GEN"), 0, cgpaEdu("B.Tech", 5.5, 10.0, 2022)), cat());
        check("CGPA 5.5/10 = 52.25% (x 9.5) -> CAT ELIGIBLE", "ELIGIBLE".equals(r.getStatus())
                && lineText(r, "Percentage").contains("52.25"), describe(r));
        r = run(candidate(profile("2000-05-05", "GEN"), 0, cgpaEdu("B.Tech", 5.2, 10.0, 2022)), cat());
        check("CGPA 5.2/10 = 49.4% -> CAT NOT_ELIGIBLE", "NOT_ELIGIBLE".equals(r.getStatus()), describe(r));

        // ---------- international retake rules ----------
        CandidateData gre = candidate(profile("2001-01-01", "GEN"), 0);
        gre.getAttemptLogs().add(log(2026, "2026-12-30", true));
        r = run(gre, gre());
        check("GRE: last test on 30-Dec-2026 + 21-day gap -> next test from 20-Jan-2027",
                r.getHeadline().contains("20-Jan-2027") && LocalDate.of(2027, 1, 20).equals(r.getNextRetestDate()), describe(r));
        CandidateData gre5 = candidate(profile("2001-01-01", "GEN"), 0);
        String[] dates = {"2026-02-01", "2026-04-01", "2026-06-01", "2026-08-01", "2026-10-01"};
        for (String d : dates) {
            gre5.getAttemptLogs().add(log(2026, d, true));
        }
        r = run(gre5, gre());
        check("GRE: 5 tests in the last 12 months -> next test from 01-Feb-2027 (rolling 12 months)",
                LocalDate.of(2027, 2, 1).equals(r.getNextRetestDate()), describe(r));
        r = run(candidate(profile("2001-01-01", "GEN"), 0), gre());
        checkEquals("GRE: no tests yet -> can test now",
                "You can take GRE now " + DASH + " 5 of 5 tests left in the current 12 months.", r.getHeadline());
        CandidateData gmat = candidate(profile("1995-01-01", "GEN"), 0);
        for (int y = 2019; y <= 2026; y++) {
            gmat.getAttemptLogs().add(log(y, y + "-03-01", true));
        }
        r = run(gmat, gmat());
        checkEquals("GMAT: 8 lifetime attempts used -> EXHAUSTED (lifetime and rolling rules together)",
                "Attempts exhausted " + DASH + " you used 8 of 8 lifetime attempts.", r.getHeadline());

        // ---------- defence ----------
        CandidateData ndaOk = candidate(profile("2009-03-15", "GEN"), 0,
                appearing("CLASS_12", null, "PHYSICS,CHEMISTRY,MATHS,ENGLISH", "2027-03-31"));
        r = run(ndaOk, nda());
        check("NDA: born 15-Mar-2009 is inside the 2027 window, Class 12 appearing -> PROVISIONAL",
                "PROVISIONAL".equals(r.getStatus()) && r.getDobWindow().equals("You must be born between 01-Jul-2008 and 01-Jan-2012"), describe(r));
        r = run(graduate("2000-06-10", "GEN", 0), nda());
        checkEquals("NDA: the age is reported first for a 26-year-old graduate (no Class 12 row needed to see that)",
                "Not eligible " + DASH + " for 2027 you must be born between 01-Jul-2008 and 01-Jan-2012.", r.getHeadline());
        ndaOk.getProfile().setMaritalStatus("MARRIED");
        r = run(ndaOk, nda());
        checkEquals("NDA: a married candidate is blocked",
                "Not eligible " + DASH + " this entry is only for unmarried candidates.", r.getHeadline());

        // ---------- teaching: post groups with REPLACE_WITH_MAX ----------
        CandidateData net = candidate(profile("1990-01-01", "GEN"), 0, edu("PG", "M.A.", "ENGLISH", 60.0, 2014));
        r = run(net, ugcNet());
        check("UGC NET: age 37 -> JRF closed, Assistant Professor group (no age limit) -> ELIGIBLE",
                "ELIGIBLE".equals(r.getStatus()) && "Assistant Professor / PhD admission".equals(r.getPostGroup()), describe(r));
        CandidateData scWoman = candidate(profile("1995-01-01", "SC"), 0, edu("PG", "M.Sc", "PHYSICS", 52.0, 2018));
        scWoman.getProfile().setGender("FEMALE");
        scWoman.getProfile().setPwbd(true);
        scWoman.getProfile().setPwbdPercent(60);
        RelaxationOutcome ro = new RelaxationResolver().resolve(scWoman, ugcNet().getExam(), ugcNet().getRelaxationRules());
        check("UGC NET JRF: SC + PwBD + woman get only the largest 'up to 5 years' (30 -> 35, not 45)",
                ro.effectiveMax(30) == 35, "effectiveMax = " + ro.effectiveMax(30));

        // ---------- leap-day birthday ----------
        LocalDate leap = LocalDate.of(2004, 2, 29);
        check("Leap day: born 29-Feb-2004 is 20 on 28-Feb-2025 and 21 on 01-Mar-2025",
                AgeCalculator.ageOn(leap, LocalDate.of(2025, 2, 28)) == 20 && AgeCalculator.ageOn(leap, LocalDate.of(2025, 3, 1)) == 21,
                AgeCalculator.describeAge(leap, LocalDate.of(2025, 2, 28)));
        r = run(graduate("1996-02-29", "GEN", 0), upscCse());
        checkEquals("Leap day: born 29-Feb-1996 is 31 on 01-Aug-2027 and 32 on 01-Aug-2028",
                "You have 6 UPSC attempts left, valid until 2027.", r.getHeadline());

        // ---------- planner, storage, incomplete profile ----------
        check("Planner: UPSC prelims (May) already over on 01-Jun-2027 -> next cycle 2028; JEE Main July sitting still open on 01-Mar-2027",
                HorizonPlanner.nextCycleYear(upscCse().getExam(), null, LocalDate.of(2027, 6, 1)) == 2028
                && HorizonPlanner.nextCycleYear(jeeMain().getExam(), null, LocalDate.of(2027, 3, 1)) == 2027, "");
        CheckLine back = CheckLine.fromStorageText(sample.getCheckLines().get(0).toStorageText());
        check("Snapshot text: a check line survives toStorageText / fromStorageText",
                back != null && back.getName().equals(sample.getCheckLines().get(0).getName())
                && back.getExplanation().equals(sample.getCheckLines().get(0).getExplanation()), "");
        Profile noDob = profile("2000-01-01", "GEN");
        noDob.setDob(null);
        r = run(candidate(noDob, 0), upscCse());
        check("Profile without date of birth -> profileIncomplete, asks to complete the profile",
                r.isProfileIncomplete() && r.getHeadline().startsWith("Complete your profile"), describe(r));

        System.out.println("------------------------------------------------------------");
        System.out.println("RESULT: " + passed + " passed, " + failed + " failed, " + (passed + failed) + " total");
        if (failed > 0) {
            System.exit(1);
        }
    }

    // ================================================================ test helpers

    private static EligibilityResult run(CandidateData c, ExamRuleSet rules) {
        return engine.evaluate(c, rules, TODAY, CYCLES);
    }

    private static void check(String name, boolean ok, String detail) {
        number++;
        String id = (number < 10 ? "0" : "") + number;
        if (ok) {
            passed++;
            System.out.println("PASS  " + id + "  " + name);
        } else {
            failed++;
            System.out.println("FAIL  " + id + "  " + name);
            System.out.println("          got: " + detail);
        }
    }

    private static void checkEquals(String name, Object expected, Object actual) {
        boolean ok = expected == null ? actual == null : expected.equals(actual);
        check(name, ok, "expected [" + expected + "] but was [" + actual + "]");
    }

    private static String describe(EligibilityResult r) {
        StringBuilder sb = new StringBuilder(r.getStatus() + " | " + r.getHeadline() + " | used=" + r.getAttemptsUsed()
                + " left=" + r.getAttemptsRemaining() + " first=" + r.getFirstEligibleYear() + " last=" + r.getLastEligibleYear());
        for (CheckLine l : r.getCheckLines()) {
            sb.append("\n            ").append(l);
        }
        return sb.toString();
    }

    private static String lineText(EligibilityResult r, String name) {
        for (CheckLine l : r.getCheckLines()) {
            if (name.equals(l.getName())) {
                return l.getExplanation();
            }
        }
        return "";
    }

    private static String lineResult(EligibilityResult r, String name) {
        for (CheckLine l : r.getCheckLines()) {
            if (name.equals(l.getName())) {
                return l.getResult();
            }
        }
        return "";
    }

    // ---------------------------------------------------------------- sample profiles

    /** PART 11 sample profile: General, born 15-Sep-1996, B.A. 2018, 4 UPSC attempts used. */
    private static CandidateData sampleProfile() {
        return candidate(profile("1996-09-15", "GEN"), 4, edu("UG", "B.A.", "HISTORY,POLITICAL SCIENCE", 62.0, 2018));
    }

    private static CandidateData graduate(String dob, String category, int attemptsBefore) {
        return candidate(profile(dob, category), attemptsBefore, edu("UG", "B.Com", "ACCOUNTANCY,BUSINESS STUDIES", 60.0, 2018));
    }

    private static Profile profile(String dob, String category) {
        Profile p = new Profile();
        p.setUserId(1);
        p.setDob(LocalDate.parse(dob));
        p.setCategory(category);
        p.setGender("MALE");
        p.setNationality("INDIAN");
        p.setMaritalStatus("UNMARRIED");
        p.setDomicileStateCode("DL");
        return p;
    }

    private static CandidateData candidate(Profile p, int attemptsBefore, Education... rows) {
        List<Education> list = new ArrayList<>();
        for (Education e : rows) {
            list.add(e);
        }
        return new CandidateData(p, list, new ArrayList<>(), attemptsBefore, new ArrayList<>());
    }

    private static Education edu(String level, String degree, String subjects, Double percent, Integer year) {
        Education e = new Education();
        e.setLevel(level);
        e.setDegreeName(degree);
        e.setSubjects(subjects);
        e.setPercentage(percent);
        e.setPassingYear(year);
        e.setStatus("COMPLETED");
        return e;
    }

    private static Education cgpaEdu(String degree, double cgpa, double scale, int year) {
        Education e = edu("UG", degree, "ENGINEERING", null, year);
        e.setCgpa(cgpa);
        e.setCgpaScale(scale);
        return e;
    }

    private static Education appearing(String level, String degree, String subjects, String expected) {
        Education e = edu(level, degree, subjects, null, LocalDate.parse(expected).getYear());
        e.setStatus("APPEARING");
        e.setExpectedCompletionDate(LocalDate.parse(expected));
        return e;
    }

    private static AttemptLog log(int year, String date, boolean counts) {
        AttemptLog a = new AttemptLog();
        a.setCycleYear(year);
        a.setAttemptDate(date == null ? null : LocalDate.parse(date));
        a.setStageReached(counts ? "APPEARED_STAGE_1" : "APPLIED_ONLY");
        a.setCountsAsAttempt(counts);
        return a;
    }

    // ---------------------------------------------------------------- rule sets (copied from the seed files)

    private static Exam exam(String code, String shortName, double cyclesPerYear, Integer month, String scope, String state) {
        Exam x = new Exam();
        x.setId(code.hashCode());
        x.setCode(code);
        x.setName(shortName);
        x.setShortName(shortName);
        x.setCyclesPerYear(cyclesPerYear);
        x.setTypicalExamMonth(month);
        x.setScope(scope);
        x.setStateCode(state);
        return x;
    }

    private static AgeRule fixedAge(String post, Integer min, Integer max, String semantics, int month, int day) {
        AgeRule a = new AgeRule();
        a.setPostOrCourse(post);
        a.setMinAge(min);
        a.setMaxAge(max);
        a.setMaxAgeSemantics(semantics);
        a.setCutoffType("FIXED_DATE_IN_CYCLE_YEAR");
        a.setCutoffMonth(month);
        a.setCutoffDay(day);
        return a;
    }

    private static AgeRule windowAge(int fromOffset, int fromMonth, int fromDay, Integer toOffset, Integer toMonth, Integer toDay) {
        AgeRule a = new AgeRule();
        a.setMaxAgeSemantics("NOT_MORE_THAN");
        a.setCutoffType("DOB_WINDOW");
        a.setDobFromOffsetYears(fromOffset);
        a.setDobFromMonth(fromMonth);
        a.setDobFromDay(fromDay);
        a.setDobToOffsetYears(toOffset);
        a.setDobToMonth(toMonth);
        a.setDobToDay(toDay);
        return a;
    }

    private static AgeRule noAge(String post, Integer min) {
        AgeRule a = new AgeRule();
        a.setPostOrCourse(post);
        a.setMinAge(min);
        a.setMaxAgeSemantics("NOT_MORE_THAN");
        a.setCutoffType("NONE");
        return a;
    }

    private static RelaxationRule relax(String type, String category, int years, String stacking, Integer cap, boolean domicile) {
        RelaxationRule r = new RelaxationRule();
        r.setRelaxationType(type);
        r.setCategory(category);
        r.setYears(years);
        r.setStacking(stacking);
        r.setOverallMaxAgeCap(cap);
        r.setRequiresStateDomicile(domicile);
        return r;
    }

    private static AttemptRule attempt(String category, Boolean pwbd, Integer max, String counting, Integer window, Integer gap) {
        AttemptRule a = new AttemptRule();
        a.setCategory(category);
        a.setPwbd(pwbd);
        a.setMaxAttempts(max);
        a.setCountingRule(counting);
        a.setWindowYears(window);
        a.setMinGapDays(gap);
        return a;
    }

    private static QualificationRule qual(String post, String level, String accepted, String subjects,
                                          Double general, Double relaxed, String relaxedFor, boolean finalYear, Integer maxYears) {
        QualificationRule q = new QualificationRule();
        q.setPostOrCourse(post);
        q.setRequiredLevel(level);
        q.setAcceptedDegrees(accepted);
        q.setRequiredSubjects(subjects);
        q.setMinPercentGeneral(general);
        q.setMinPercentRelaxed(relaxed);
        q.setRelaxedFor(relaxedFor);
        q.setFinalYearAllowed(finalYear);
        q.setMaxYearsSincePassing(maxYears);
        return q;
    }

    private static OtherRule other(String post, String type, String value, boolean blocking) {
        OtherRule o = new OtherRule();
        o.setPostOrCourse(post);
        o.setRuleType(type);
        o.setRuleValue(value);
        o.setBlocking(blocking);
        return o;
    }

    private static final String NATIONS = "INDIAN,NEPAL,BHUTAN,TIBETAN_REFUGEE,PIO";
    private static final String FIRST_STAGE = "APPEARED_IN_FIRST_STAGE";

    private static ExamRuleSet upscCse() {
        ExamRuleSet s = new ExamRuleSet(exam("UPSC_CSE", "UPSC CSE", 1.0, 5, "NATIONAL", null), 1);
        s.getAgeRules().add(fixedAge(null, 21, 32, "NOT_ATTAINED", 8, 1));
        s.getRelaxationRules().add(relax("CATEGORY", "OBC_NCL", 3, "ADD", null, false));
        s.getRelaxationRules().add(relax("CATEGORY", "SC", 5, "ADD", null, false));
        s.getRelaxationRules().add(relax("CATEGORY", "ST", 5, "ADD", null, false));
        s.getRelaxationRules().add(relax("PWBD", null, 10, "ADD", null, false));
        s.getRelaxationRules().add(relax("EX_SERVICEMAN", null, 5, "ADD", null, false));
        s.getAttemptRules().add(attempt("GEN", false, 6, FIRST_STAGE, null, null));
        s.getAttemptRules().add(attempt("EWS", false, 6, FIRST_STAGE, null, null));
        s.getAttemptRules().add(attempt("GEN", true, 9, FIRST_STAGE, null, null));
        s.getAttemptRules().add(attempt("EWS", true, 9, FIRST_STAGE, null, null));
        s.getAttemptRules().add(attempt("OBC_NCL", null, 9, FIRST_STAGE, null, null));
        s.getAttemptRules().add(attempt("SC", null, null, FIRST_STAGE, null, null));
        s.getAttemptRules().add(attempt("ST", null, null, FIRST_STAGE, null, null));
        s.getQualificationRules().add(qual(null, "UG", "ANY", null, null, null, null, true, null));
        s.getOtherRules().add(other(null, "NATIONALITY", NATIONS, true));
        return s;
    }

    /** Same as UPSC CSE but worded "not more than 32" - only for the semantics tests. */
    private static ExamRuleSet notMoreThan32() {
        ExamRuleSet s = upscCse();
        s.getAgeRules().clear();
        s.getAgeRules().add(fixedAge(null, 21, 32, "NOT_MORE_THAN", 8, 1));
        return s;
    }

    private static ExamRuleSet sscCgl() {
        ExamRuleSet s = new ExamRuleSet(exam("SSC_CGL", "SSC CGL", 1.0, 9, "NATIONAL", null), 2);
        String g27 = "Posts with limit 18-27 (Auditor, Accountant, UDC, Tax Assistant, Inspector NCB)";
        String g30 = "Posts with limit 18-30 (Inspector Income Tax/CGST/Posts, Assistant Audit Officer)";
        String g2030 = "Posts with limit 20-30 (ASO CSS/MEA, Sub-Inspector CBI/NIA)";
        String g32 = "Posts with limit 18-32 (JSO, Statistical Investigator Gr II)";
        s.getAgeRules().add(fixedAge(g27, 18, 27, "NOT_ATTAINED", 8, 1));
        s.getAgeRules().add(fixedAge(g30, 18, 30, "NOT_ATTAINED", 8, 1));
        s.getAgeRules().add(fixedAge(g2030, 20, 30, "NOT_ATTAINED", 8, 1));
        s.getAgeRules().add(fixedAge(g32, 18, 32, "NOT_ATTAINED", 8, 1));
        s.getRelaxationRules().add(relax("CATEGORY", "OBC_NCL", 3, "ADD", null, false));
        s.getRelaxationRules().add(relax("CATEGORY", "SC", 5, "ADD", null, false));
        s.getRelaxationRules().add(relax("CATEGORY", "ST", 5, "ADD", null, false));
        s.getRelaxationRules().add(relax("PWBD", null, 10, "ADD", null, false));
        s.getRelaxationRules().add(relax("EX_SERVICEMAN", null, 3, "ADD_AFTER_SERVICE_DEDUCTION", null, false));
        s.getRelaxationRules().add(relax("GOVT_EMPLOYEE", "GEN", 0, "REPLACE_WITH_MAX", 40, false));
        s.getRelaxationRules().add(relax("GOVT_EMPLOYEE", "EWS", 0, "REPLACE_WITH_MAX", 40, false));
        s.getRelaxationRules().add(relax("GOVT_EMPLOYEE", "OBC_NCL", 0, "REPLACE_WITH_MAX", 40, false));
        s.getRelaxationRules().add(relax("GOVT_EMPLOYEE", "SC", 0, "REPLACE_WITH_MAX", 45, false));
        s.getRelaxationRules().add(relax("GOVT_EMPLOYEE", "ST", 0, "REPLACE_WITH_MAX", 45, false));
        s.getAttemptRules().add(attempt(null, null, null, FIRST_STAGE, null, null));
        s.getQualificationRules().add(qual(null, "UG", "ANY", null, null, null, null, true, null));
        s.getQualificationRules().add(qual(g32, "UG", "ANY", "CLASS_12:MATHS", 60.0, null, null, true, null));
        s.getQualificationRules().add(qual(g32, "UG", "ANY", "STATISTICS", null, null, null, true, null));
        s.getQualificationRules().add(qual(g32, "UG", "ANY", "STATISTICS|MATHS|ECONOMICS", null, null, null, true, null));
        s.getOtherRules().add(other(null, "NATIONALITY", NATIONS, true));
        return s;
    }

    private static ExamRuleSet ibpsClerk() {
        ExamRuleSet s = new ExamRuleSet(exam("IBPS_CLERK", "IBPS Clerk", 1.0, 10, "NATIONAL", null), 12);
        s.getAgeRules().add(fixedAge(null, 20, 28, "NOT_ATTAINED", 8, 1));
        s.getRelaxationRules().add(relax("CATEGORY", "OBC_NCL", 3, "ADD", null, false));
        s.getRelaxationRules().add(relax("CATEGORY", "SC", 5, "ADD", null, false));
        s.getRelaxationRules().add(relax("EX_SERVICEMAN", null, 3, "ADD_AFTER_SERVICE_DEDUCTION", 50, false));
        s.getAttemptRules().add(attempt(null, null, null, FIRST_STAGE, null, null));
        s.getQualificationRules().add(qual(null, "UG", "ANY", null, null, null, null, false, null));
        s.getOtherRules().add(other(null, "NATIONALITY", NATIONS, true));
        return s;
    }

    private static ExamRuleSet uppscPcs() {
        ExamRuleSet s = new ExamRuleSet(exam("UPPSC_PCS", "UPPSC PCS", 1.0, 10, "STATE", "UP"), 3);
        s.getAgeRules().add(fixedAge(null, 21, 40, "NOT_ATTAINED", 7, 1));
        s.getRelaxationRules().add(relax("CATEGORY", "OBC_NCL", 5, "ADD", null, true));
        s.getRelaxationRules().add(relax("CATEGORY", "SC", 5, "ADD", null, true));
        s.getRelaxationRules().add(relax("CATEGORY", "ST", 5, "ADD", null, true));
        s.getRelaxationRules().add(relax("PWBD", null, 15, "ADD", null, true));
        s.getAttemptRules().add(attempt(null, null, null, FIRST_STAGE, null, null));
        s.getQualificationRules().add(qual(null, "UG", "ANY", null, null, null, null, true, null));
        s.getOtherRules().add(other(null, "DOMICILE", "UP", false));
        return s;
    }

    private static ExamRuleSet jeeMain() {
        ExamRuleSet s = new ExamRuleSet(exam("JEE_MAIN", "JEE Main", 2.0, 1, "NATIONAL", null), 4);
        s.getAgeRules().add(noAge(null, null));
        s.getAttemptRules().add(attempt(null, null, null, AttemptCounter.CONSECUTIVE, 3, null));
        s.getQualificationRules().add(qual("Paper 1 (B.E. / B.Tech)", "CLASS_12", "ANY", "PHYSICS,MATHS", null, null, null, true, 2));
        s.getQualificationRules().add(qual("Paper 2 (B.Arch / B.Planning)", "CLASS_12", "ANY", "MATHS", null, null, null, true, 2));
        return s;
    }

    private static ExamRuleSet jeeAdvanced() {
        ExamRuleSet s = new ExamRuleSet(exam("JEE_ADVANCED", "JEE Advanced", 1.0, 5, "NATIONAL", null), 5);
        s.getAgeRules().add(windowAge(-25, 10, 1, null, null, null));
        s.getRelaxationRules().add(relax("CATEGORY", "SC", 5, "REPLACE_WITH_MAX", null, false));
        s.getRelaxationRules().add(relax("CATEGORY", "ST", 5, "REPLACE_WITH_MAX", null, false));
        s.getRelaxationRules().add(relax("PWBD", null, 5, "REPLACE_WITH_MAX", null, false));
        s.getAttemptRules().add(attempt(null, null, 2, AttemptCounter.CONSECUTIVE, 2, null));
        s.getQualificationRules().add(qual(null, "CLASS_12", "ANY", "PHYSICS,CHEMISTRY,MATHS", null, null, null, true, 1));
        s.getOtherRules().add(other(null, "REGISTRATION", "JEE_MAIN_TOP_250000", false));
        return s;
    }

    private static ExamRuleSet neetUg() {
        ExamRuleSet s = new ExamRuleSet(exam("NEET_UG", "NEET UG", 1.0, 5, "NATIONAL", null), 6);
        s.getAgeRules().add(fixedAge(null, 17, null, "NOT_ATTAINED", 12, 31));
        s.getAttemptRules().add(attempt(null, null, null, "PER_SITTING", null, null));
        s.getQualificationRules().add(qual(null, "CLASS_12", "ANY", "PHYSICS,CHEMISTRY,BIOLOGY|BIOTECHNOLOGY,ENGLISH",
                null, null, null, true, null));
        return s;
    }

    private static ExamRuleSet cat() {
        ExamRuleSet s = new ExamRuleSet(exam("CAT", "CAT", 1.0, 11, "NATIONAL", null), 7);
        s.getAgeRules().add(noAge(null, null));
        s.getAttemptRules().add(attempt(null, null, null, "PER_SITTING", null, null));
        s.getQualificationRules().add(qual(null, "UG", "ANY", null, 50.0, 45.0, "SC,ST,PWBD", true, null));
        s.getQualificationRules().add(qual(null, "PROFESSIONAL", "CA,CS,CMA,FIAI", null, 50.0, 45.0, "SC,ST,PWBD", false, null));
        return s;
    }

    private static ExamRuleSet gre() {
        ExamRuleSet s = new ExamRuleSet(exam("GRE", "GRE", 12.0, null, "INTERNATIONAL", null), 8);
        s.getAgeRules().add(noAge(null, null));
        s.getAttemptRules().add(attempt(null, null, 5, AttemptCounter.ROLLING, null, 21));
        s.getQualificationRules().add(qual(null, "NONE", "ANY", null, null, null, null, true, null));
        s.getOtherRules().add(other(null, "OTHER", "PASSPORT", false));
        return s;
    }

    private static ExamRuleSet gmat() {
        ExamRuleSet s = new ExamRuleSet(exam("GMAT_FOCUS", "GMAT", 12.0, null, "INTERNATIONAL", null), 9);
        s.getAgeRules().add(noAge(null, 13));
        s.getAttemptRules().add(attempt(null, null, 5, AttemptCounter.ROLLING, null, 16));
        s.getAttemptRules().add(attempt(null, null, 8, AttemptCounter.LIFETIME, null, null));
        s.getQualificationRules().add(qual(null, "NONE", "ANY", null, null, null, null, true, null));
        return s;
    }

    private static ExamRuleSet nda() {
        ExamRuleSet s = new ExamRuleSet(exam("UPSC_NDA", "UPSC NDA", 2.0, 4, "NATIONAL", null), 10);
        s.getAgeRules().add(windowAge(-19, 7, 1, -15, 1, 1));
        s.getAttemptRules().add(attempt(null, null, null, "PER_SITTING", null, null));
        s.getQualificationRules().add(qual("Army Wing", "CLASS_12", "ANY", null, null, null, null, true, null));
        s.getQualificationRules().add(qual("Air Force / Naval Wing", "CLASS_12", "ANY", "PHYSICS,CHEMISTRY,MATHS",
                null, null, null, true, null));
        s.getOtherRules().add(other(null, "MARITAL_STATUS", "UNMARRIED", true));
        s.getOtherRules().add(other(null, "NATIONALITY", NATIONS, true));
        s.getOtherRules().add(other(null, "PHYSICAL_STANDARD", null, false));
        return s;
    }

    private static ExamRuleSet ugcNet() {
        ExamRuleSet s = new ExamRuleSet(exam("UGC_NET", "UGC NET", 2.0, 6, "NATIONAL", null), 11);
        s.getAgeRules().add(fixedAge("JRF", null, 30, "NOT_ATTAINED", 12, 1));
        s.getAgeRules().add(noAge("Assistant Professor / PhD admission", null));
        s.getRelaxationRules().add(relax("CATEGORY", "OBC_NCL", 5, "REPLACE_WITH_MAX", null, false));
        s.getRelaxationRules().add(relax("CATEGORY", "SC", 5, "REPLACE_WITH_MAX", null, false));
        s.getRelaxationRules().add(relax("CATEGORY", "ST", 5, "REPLACE_WITH_MAX", null, false));
        s.getRelaxationRules().add(relax("PWBD", null, 5, "REPLACE_WITH_MAX", null, false));
        s.getRelaxationRules().add(relax("WOMEN", null, 5, "REPLACE_WITH_MAX", null, false));
        s.getRelaxationRules().add(relax("TRANSGENDER", null, 5, "REPLACE_WITH_MAX", null, false));
        s.getAttemptRules().add(attempt(null, null, null, "PER_SITTING", null, null));
        s.getQualificationRules().add(qual(null, "PG", "ANY", null, 55.0, 50.0, "OBC_NCL,SC,ST,PWBD,TRANSGENDER", true, null));
        s.getOtherRules().add(other(null, "NATIONALITY", "INDIAN", false));
        return s;
    }
}
