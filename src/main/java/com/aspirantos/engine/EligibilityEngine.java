package com.aspirantos.engine;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.AgeRule;
import com.aspirantos.model.Education;
import com.aspirantos.model.Exam;
import com.aspirantos.model.OtherRule;
import com.aspirantos.model.Profile;
import com.aspirantos.util.DateUtil;

/**
 * The eligibility engine. Plain Java: no servlet, JSP or JDBC
 * code, so EngineSelfTest can run it from a main method.
 *
 * Input : CandidateData (profile, education, work, attempts), ExamRuleSet, today, cycles to plan.
 * Output: EligibilityResult with status, headline, attempts, horizon years and CheckLines.
 *
 * Exams with post groups (SSC CGL, CDS, UGC NET ...) are checked once per group and
 * the best group is reported.
 */
public class EligibilityEngine {

    private static final String DASH = "\u2014";   // the long dash used in the headlines

    private static final String AGE_OK = "OK";
    private static final String AGE_YOUNG = "YOUNG";
    private static final String AGE_OLD = "OLD";

    private RelaxationResolver relaxationResolver = new RelaxationResolver();
    private AttemptCounter attemptCounter = new AttemptCounter();
    private QualificationChecker qualificationChecker = new QualificationChecker();

    public EligibilityResult evaluate(CandidateData candidate, ExamRuleSet rules, LocalDate today, int cyclesToPlan) {
        Exam exam = rules.getExam();
        Profile p = candidate.getProfile();

        if (p == null || p.getDob() == null) {
            EligibilityResult r = newResult(rules, today);
            r.setProfileIncomplete(true);
            r.setStatus(EligibilityResult.NOT_ELIGIBLE);
            r.setHeadline("Complete your profile (date of birth, category and education) to check your eligibility.");
            r.addLine("Profile", CheckLine.WARN, "Your date of birth is missing, so the age rules cannot be checked.");
            return r;
        }

        List<Integer> years = HorizonPlanner.planYears(exam, rules.getEvents(), today, cyclesToPlan);
        boolean domicileOk = RelaxationResolver.isDomicileOk(p, exam);
        // reserved-category benefits of a state exam only for that state's domicile
        String benefitCategory = domicileOk ? candidate.getCategory() : "GEN";

        Education class12 = QualificationChecker.findRow(candidate, "CLASS_12");
        Integer qualifyingYear = class12 == null ? null : QualificationChecker.completionYearOf(class12);
        AttemptStatus attempts = attemptCounter.count(candidate, rules.getAttemptRules(), benefitCategory, today, qualifyingYear);
        RelaxationOutcome relax = relaxationResolver.resolve(candidate, exam, rules.getRelaxationRules());

        List<String> groups = rules.getPostGroups();
        if (groups.isEmpty()) {
            groups.add(null);
        }
        EligibilityResult best = null;
        List<EligibilityResult> all = new ArrayList<>();
        for (String group : groups) {
            EligibilityResult r = evaluateGroup(candidate, rules, group, years, today, attempts, relax,
                                                benefitCategory, domicileOk);
            all.add(r);
            if (best == null || better(r, best)) {
                best = r;
            }
        }

        if (groups.size() > 1) {
            StringBuilder sb = new StringBuilder("This exam has " + groups.size() + " post groups; the best one for you is \""
                    + best.getPostGroup() + "\".");
            List<String> alsoOpen = new ArrayList<>();
            for (EligibilityResult r : all) {
                if (r != best && r.isEligibleNow()) {
                    alsoOpen.add(r.getPostGroup());
                }
            }
            if (!alsoOpen.isEmpty()) {
                sb.append(" Also open to you: ").append(String.join("; ", alsoOpen)).append(".");
            }
            best.getCheckLines().add(0, new CheckLine("Post group", CheckLine.INFO, sb.toString()));
        }
        return best;
    }

    // ------------------------------------------------------------------ one post group

    private EligibilityResult evaluateGroup(CandidateData c, ExamRuleSet rules, String group, List<Integer> years,
                                            LocalDate today, AttemptStatus attempts, RelaxationOutcome relax,
                                            String benefitCategory, boolean domicileOk) {
        Exam exam = rules.getExam();
        Profile p = c.getProfile();
        EligibilityResult r = newResult(rules, today);
        r.setPostGroup(group);
        r.setNextCycleYear(years.get(0));
        r.setAttemptsUsed(attempts.getUsed());
        r.setAttemptsRemaining(attempts.getRemaining());
        r.setNextRetestDate(attempts.getNextRetestDate());

        AgeRule age = rules.getAgeRuleFor(group);
        QualificationOutcome qual = qualificationChecker.check(c, rules.getQualificationRulesFor(group), benefitCategory,
                                                               exam.getTypicalExamMonth(), today);
        List<CheckLine> otherLines = checkOtherRules(c, rules.getOtherRulesFor(group), exam, domicileOk);

        // walk through the planned cycles
        String[] ageState = new String[years.size()];
        boolean[] usable = new boolean[years.size()];
        for (int i = 0; i < years.size(); i++) {
            int y = years.get(i);
            ageState[i] = ageState(age, relax, p.getDob(), y, exam, rules, today);
            boolean windowOk = attempts.getWindowFrom() == null
                    || (y >= attempts.getWindowFrom() && y <= attempts.getWindowTo());
            usable[i] = AGE_OK.equals(ageState[i]) && qual.metFor(y) && windowOk;
            if (usable[i]) {
                r.getUsableYears().add(y);
            }
        }

        // explanation lines in the order of PART 6
        r.getCheckLines().add(ageLine(age, relax, p.getDob(), years.get(0), ageState[0], exam, rules, today));
        r.getCheckLines().add(relaxationLine(age, relax));
        r.getCheckLines().add(attemptLine(attempts, exam));
        List<CheckLine> experienceLines = new ArrayList<>();
        for (CheckLine line : qual.getLines()) {
            if ("Experience".equals(line.getName())) {
                experienceLines.add(line);
            } else {
                r.getCheckLines().add(line);
            }
        }
        List<CheckLine> infoLines = new ArrayList<>();
        for (CheckLine line : otherLines) {
            if (isPersonalCheck(line.getName())) {
                r.getCheckLines().add(line);
            } else {
                infoLines.add(line);
            }
        }
        r.getCheckLines().addAll(experienceLines);
        r.getCheckLines().addAll(infoLines);

        r.setRelaxationBreakdown(relaxationText(age, relax));
        r.setDobWindow(dobWindowText(age, relax, years.get(0)));
        r.setDaysUntilAgeLimitCrossed(daysUntilCrossed(age, relax, p.getDob(), today));
        r.setNextCutoffDate(AgeCalculator.cutoffDate(age, years.get(0)));   // null for birth-date windows / no age rule

        String name = headlineName(exam);

        int firstIdx = -1;
        for (int i = 0; i < years.size(); i++) {
            if (usable[i]) {
                firstIdx = i;
                break;
            }
        }

        // 0. too old already for the next cycle: the age is the clearest reason
        if (firstIdx == -1 && AGE_OLD.equals(ageState[0])) {
            r.setStatus(EligibilityResult.NOT_ELIGIBLE);
            r.setHeadline(ageCrossedHeadline(age, relax, p.getDob(), years.get(0), today));
            return r;
        }
        // 1. blocking personal rules (nationality, gender, marital status, ...)
        CheckLine otherFail = firstFail(otherLines);
        if (otherFail != null) {
            r.setStatus(EligibilityResult.NOT_ELIGIBLE);
            r.setHeadline("Not eligible " + DASH + " " + lowerFirst(otherFail.getExplanation()));
            return r;
        }
        // 2. wrong degree / subjects / marks
        if (QualificationOutcome.FAIL.equals(qual.getStatus())) {
            r.setStatus(EligibilityResult.NOT_ELIGIBLE);
            String reason = qual.getFailReason() != null ? qual.getFailReason() : "your qualification does not match the rule";
            r.setHeadline("Not eligible " + DASH + " " + reason + ".");
            return r;
        }
        // 3. attempts used up
        if (attempts.isExhausted()) {
            r.setStatus(EligibilityResult.EXHAUSTED);
            boolean lifetime = attempts.getLifetimeRemaining() != null && attempts.getLifetimeRemaining() == 0
                    && (attempts.getRemaining() == null || attempts.getRemaining() > 0 || attempts.getMainRule() == null);
            int max = lifetime ? attempts.getLifetimeRule().getMaxAttempts() : attempts.getMaxAttempts();
            r.setHeadline("Attempts exhausted " + DASH + " you used " + attempts.getUsed() + " of " + max
                    + (lifetime ? " lifetime attempts." : "."));
            return r;
        }

        // 4. no usable cycle at all
        if (firstIdx == -1) {
            int y0 = years.get(0);
            if (attempts.getWindowTo() != null && y0 > attempts.getWindowTo()) {
                r.setStatus(EligibilityResult.NOT_ELIGIBLE);
                r.setHeadline("Not eligible " + DASH + " your " + attempts.getMainRule().getWindowYears()
                        + "-year window after Class 12 (" + attempts.getWindowFrom() + "-" + attempts.getWindowTo() + ") is over.");
            } else if (qual.getLastYearAllowed() != null && y0 > qual.getLastYearAllowed()) {
                r.setStatus(EligibilityResult.NOT_ELIGIBLE);
                r.setHeadline("Not eligible " + DASH + " this exam must be taken by " + qual.getLastYearAllowed()
                        + " (within " + qual.getRule().getMaxYearsSincePassing() + " year(s) of passing).");
            } else if (QualificationOutcome.NOT_YET.equals(qual.getStatus()) && qual.getMetFromYear() == null) {
                r.setStatus(EligibilityResult.NOT_YET);
                r.setHeadline("Not eligible yet " + DASH + " you need " + qual.getLevelWords()
                        + " first; add it to your profile when you start it.");
            } else if (containsOld(ageState)) {
                r.setStatus(EligibilityResult.NOT_ELIGIBLE);
                r.setHeadline("Not eligible " + DASH + " by the time you complete " + qual.getLevelWords()
                        + " you will be above the age limit.");
            } else {
                r.setStatus(EligibilityResult.NOT_YET);
                r.setHeadline("Not eligible yet " + DASH + " not within the next " + years.size() + " cycles.");
            }
            return r;
        }

        int lastIdx = firstIdx;
        while (lastIdx + 1 < years.size() && usable[lastIdx + 1]) {
            lastIdx++;
        }
        boolean limited = hasUpperAgeLimit(age, relax) || attempts.getWindowTo() != null || qual.getLastYearAllowed() != null;
        int first = years.get(firstIdx);
        Integer last = limited ? years.get(lastIdx) : null;
        r.setFirstEligibleYear(first);
        r.setLastEligibleYear(last);

        // which limit ends the run: the window, the years-since-passing rule or the age
        String limitReason = "AGE";
        if (limited && lastIdx + 1 < years.size()) {
            int after = years.get(lastIdx + 1);
            if (!AGE_OLD.equals(ageState[lastIdx + 1])) {
                if (attempts.getWindowTo() != null && after > attempts.getWindowTo()) {
                    limitReason = "WINDOW";
                } else if (qual.getLastYearAllowed() != null && after > qual.getLastYearAllowed()) {
                    limitReason = "QUALIFICATION";
                }
            }
        } else if (attempts.getWindowTo() != null && last != null && last.equals(attempts.getWindowTo())) {
            limitReason = "WINDOW";
        }

        // 5. eligible only from a later cycle
        if (firstIdx > 0) {
            int y0 = years.get(0);
            String reason;
            if (!qual.metFor(y0)) {
                reason = " after " + qual.getLevelWords() + ".";
            } else if (attempts.getWindowFrom() != null && y0 < attempts.getWindowFrom()) {
                reason = " after Class 12.";
            } else if (AGE_YOUNG.equals(ageState[0]) && age != null && age.getMinAge() != null) {
                reason = " (minimum age " + age.getMinAge() + ").";
            } else {
                reason = ".";
            }
            r.setStatus(EligibilityResult.NOT_YET);
            r.setHeadline("Not eligible yet " + DASH + " eligible from " + first + reason);
            return r;
        }

        // 6. eligible in the next cycle
        String headline = eligibleHeadline(name, attempts, last, limitReason, qual, exam);
        if (qual.provisionalFor(first)) {
            r.setStatus(EligibilityResult.PROVISIONAL);
            String by = qual.getPassBy() != null ? DateUtil.format(qual.getPassBy()) : "the date in the notification";
            r.setHeadline("Provisional: you must pass by " + by + ". " + headline);
        } else {
            r.setStatus(EligibilityResult.ELIGIBLE);
            r.setHeadline(headline);
        }
        return r;
    }

    // ------------------------------------------------------------------ age

    private String ageState(AgeRule age, RelaxationOutcome relax, LocalDate dob, int year, Exam exam,
                            ExamRuleSet rules, LocalDate today) {
        if (age == null) {
            return AGE_OK;
        }
        String type = age.getCutoffType();
        if ("NONE".equals(type)) {
            if (age.getMinAge() != null && AgeCalculator.ageOn(dob, referenceDate(exam, rules, year, today)) < age.getMinAge()) {
                return AGE_YOUNG;
            }
            return AGE_OK;
        }
        if ("DOB_WINDOW".equals(type)) {
            LocalDate from = AgeCalculator.windowFrom(age, year);
            if (from != null && dob.isBefore(from.minusYears(relax.totalYears()))) {
                return AGE_OLD;
            }
            LocalDate to = AgeCalculator.windowTo(age, year);
            if (to != null && dob.isAfter(to)) {
                return AGE_YOUNG;
            }
            return AGE_OK;
        }
        LocalDate cutoff = AgeCalculator.cutoffDate(age, year);
        if (cutoff == null) {
            return AGE_OK;
        }
        if (age.getMinAge() != null && AgeCalculator.ageOn(dob, cutoff) < age.getMinAge()) {
            return AGE_YOUNG;
        }
        if (age.getMaxAge() != null) {
            int effMax = relax.effectiveMax(age.getMaxAge());
            if (!AgeCalculator.withinUpperLimit(AgeCalculator.ageOn(countedDob(dob, relax), cutoff), effMax,
                                                age.getMaxAgeSemantics())) {
                return AGE_OLD;
            }
            if (relax.getHardCap() != null
                    && !AgeCalculator.withinUpperLimit(AgeCalculator.ageOn(dob, cutoff), relax.getHardCap(), age.getMaxAgeSemantics())) {
                return AGE_OLD;
            }
        }
        return AGE_OK;
    }

    /** Ex-servicemen: military service is deducted from the age, i.e. the birth date moves later. */
    private LocalDate countedDob(LocalDate dob, RelaxationOutcome relax) {
        if (relax.getServiceDeductionYears() <= 0) {
            return dob;
        }
        return dob.plusMonths(Math.round(relax.getServiceDeductionYears() * 12));
    }

    /** Age date for rules without a cut-off date (e.g. GMAT minimum age 13): the exam date or today. */
    private LocalDate referenceDate(Exam exam, ExamRuleSet rules, int year, LocalDate today) {
        LocalDate d = HorizonPlanner.firstStageDate(exam, rules.getEvents(), year);
        if (d == null) {
            d = year == today.getYear() ? today : LocalDate.of(year, 1, 1);
        }
        return d;
    }

    private boolean hasUpperAgeLimit(AgeRule age, RelaxationOutcome relax) {
        if (age == null) {
            return false;
        }
        if ("DOB_WINDOW".equals(age.getCutoffType())) {
            return age.getDobFromOffsetYears() != null;
        }
        return !"NONE".equals(age.getCutoffType()) && age.getMaxAge() != null;
    }

    private CheckLine ageLine(AgeRule age, RelaxationOutcome relax, LocalDate dob, int year, String state,
                              Exam exam, ExamRuleSet rules, LocalDate today) {
        String result = AGE_OK.equals(state) ? CheckLine.PASS : (AGE_YOUNG.equals(state) ? CheckLine.WARN : CheckLine.FAIL);
        if (age == null || "NONE".equals(age.getCutoffType())) {
            if (age != null && age.getMinAge() != null) {
                LocalDate ref = referenceDate(exam, rules, year, today);
                return new CheckLine("Age", result, "Minimum age " + age.getMinAge() + "; you will be "
                        + AgeCalculator.describeAge(dob, ref) + " on " + DateUtil.format(ref) + ". No upper age limit.");
            }
            return new CheckLine("Age", CheckLine.PASS, "No age limit for this exam.");
        }
        if ("DOB_WINDOW".equals(age.getCutoffType())) {
            String window = dobWindowText(age, relax, year);
            return new CheckLine("Age", result, "For " + year + " " + lowerFirst(window == null ? "There is no birth-date limit" : window)
                    + " (birth-date window). Your date of birth " + DateUtil.format(dob)
                    + (AGE_OK.equals(state) ? " is inside the window." : " is outside the window.")
                    + (age.getNotes() != null ? " " + age.getNotes() : ""));
        }
        LocalDate cutoff = AgeCalculator.cutoffDate(age, year);
        StringBuilder sb = new StringBuilder();
        sb.append(cutoff.isBefore(today) ? "You were " : "You will be ")
          .append(AgeCalculator.describeAge(dob, cutoff)).append(" on ").append(DateUtil.format(cutoff))
          .append(" (age is counted on this date for ").append(year).append("). Allowed: ");
        if (age.getMinAge() != null) {
            sb.append("at least ").append(age.getMinAge());
            if (age.getMaxAge() != null) {
                sb.append(" and ");
            }
        }
        if (age.getMaxAge() != null) {
            int effMax = relax.effectiveMax(age.getMaxAge());
            sb.append(AgeCalculator.describeUpperLimit(effMax, age.getMaxAgeSemantics()));
            if (effMax != age.getMaxAge()) {
                sb.append(", after relaxation");
            }
        } else {
            sb.append(", no upper age limit");
        }
        sb.append(".");
        if (relax.getServiceDeductionYears() > 0 && age.getMaxAge() != null) {
            sb.append(" After deducting ").append(RelaxationOutcome.formatYears(relax.getServiceDeductionYears()))
              .append(" of military service your age counts as ")
              .append(AgeCalculator.ageOn(countedDob(dob, relax), cutoff)).append(".");
        }
        if (AGE_YOUNG.equals(state)) {
            sb.append(" You are below the minimum age for ").append(year).append(".");
        } else if (AGE_OLD.equals(state)) {
            sb.append(" You are above the upper age limit for ").append(year).append(".");
        }
        return new CheckLine("Age", result, sb.toString());
    }

    private CheckLine relaxationLine(AgeRule age, RelaxationOutcome relax) {
        String result = relax.isDomicileSkipped() ? CheckLine.WARN : CheckLine.INFO;
        return new CheckLine("Relaxation", result, relaxationText(age, relax)
                + (relax.getNotes().isEmpty() ? "" : " " + String.join(" ", relax.getNotes())));
    }

    private String relaxationText(AgeRule age, RelaxationOutcome relax) {
        if (age == null || !hasUpperAgeLimit(age, relax)) {
            return "No upper age limit, so no relaxation is needed.";
        }
        if ("DOB_WINDOW".equals(age.getCutoffType())) {
            if (relax.totalYears() == 0) {
                return "No relaxation applies to you.";
            }
            List<String> labels = new ArrayList<>(relax.getApplied());
            if (relax.getReplaceLabel() != null) {
                labels.add(relax.getReplaceLabel());
            }
            return "The \"born on or after\" date moves " + relax.totalYears() + " years earlier for you ("
                    + String.join(" + ", labels) + ").";
        }
        return relax.breakdown(age.getMaxAge());
    }

    /** "You must be born between 02-Aug-1995 and 01-Aug-2006" for the given cycle; null without age limits. */
    private String dobWindowText(AgeRule age, RelaxationOutcome relax, int year) {
        if (age == null) {
            return null;
        }
        LocalDate earliest = null;
        LocalDate latest = null;
        if ("DOB_WINDOW".equals(age.getCutoffType())) {
            LocalDate from = AgeCalculator.windowFrom(age, year);
            earliest = from == null ? null : from.minusYears(relax.totalYears());
            latest = AgeCalculator.windowTo(age, year);
        } else {
            LocalDate cutoff = AgeCalculator.cutoffDate(age, year);
            if (cutoff == null) {
                return null;
            }
            if (age.getMaxAge() != null) {
                earliest = AgeCalculator.earliestDob(cutoff, relax.effectiveMax(age.getMaxAge()), age.getMaxAgeSemantics());
                if (relax.getServiceDeductionYears() > 0) {
                    earliest = earliest.minusMonths(Math.round(relax.getServiceDeductionYears() * 12));
                }
                if (relax.getHardCap() != null) {
                    LocalDate capDob = AgeCalculator.earliestDob(cutoff, relax.getHardCap(), age.getMaxAgeSemantics());
                    if (capDob.isAfter(earliest)) {
                        earliest = capDob;
                    }
                }
            }
            if (age.getMinAge() != null) {
                latest = AgeCalculator.latestDob(cutoff, age.getMinAge());
            }
        }
        if (earliest != null && latest != null) {
            return "You must be born between " + DateUtil.format(earliest) + " and " + DateUtil.format(latest);
        }
        if (earliest != null) {
            return "You must be born on or after " + DateUtil.format(earliest);
        }
        if (latest != null) {
            return "You must be born on or before " + DateUtil.format(latest);
        }
        return null;
    }

    private Long daysUntilCrossed(AgeRule age, RelaxationOutcome relax, LocalDate dob, LocalDate today) {
        if (age == null || age.getMaxAge() == null || "NONE".equals(age.getCutoffType())
                || "DOB_WINDOW".equals(age.getCutoffType())) {
            return null;
        }
        LocalDate crossed = AgeCalculator.dateLimitCrossed(countedDob(dob, relax), relax.effectiveMax(age.getMaxAge()),
                                                           age.getMaxAgeSemantics());
        long days = ChronoUnit.DAYS.between(today, crossed);
        return Math.max(0, days);
    }

    private String ageCrossedHeadline(AgeRule age, RelaxationOutcome relax, LocalDate dob, int year, LocalDate today) {
        if ("DOB_WINDOW".equals(age.getCutoffType())) {
            return "Not eligible " + DASH + " for " + year + " " + lowerFirst(dobWindowText(age, relax, year)) + ".";
        }
        int effMax = relax.effectiveMax(age.getMaxAge());
        LocalDate crossed = AgeCalculator.dateLimitCrossed(countedDob(dob, relax), effMax, age.getMaxAgeSemantics());
        if (relax.getHardCap() != null) {
            LocalDate capCrossed = AgeCalculator.dateLimitCrossed(dob, relax.getHardCap(), age.getMaxAgeSemantics());
            if (capCrossed.isBefore(crossed)) {
                crossed = capCrossed;
            }
        }
        if (!crossed.isAfter(today)) {
            return "Age limit crossed on " + DateUtil.format(crossed) + ".";
        }
        return "Not eligible " + DASH + " you reach the upper age limit on " + DateUtil.format(crossed)
                + ", on or before the " + year + " cut-off date.";
    }

    private boolean containsOld(String[] states) {
        for (String s : states) {
            if (AGE_OLD.equals(s)) {
                return true;
            }
        }
        return false;
    }

    // ------------------------------------------------------------------ attempts

    private CheckLine attemptLine(AttemptStatus a, Exam exam) {
        String rawNote = a.getMainRule() != null && a.getMainRule().getNotes() != null ? a.getMainRule().getNotes()
                : exam.getAttemptCountingNote();
        String note = rawNote == null ? "" : " Rule: " + rawNote + (rawNote.endsWith(".") ? "" : ".");
        String usedText = a.getUsedBeforeApp() + " entered before joining + " + a.getUsedInJournal() + " from your attempt journal";

        if (a.getRollingRule() != null) {
            StringBuilder sb = new StringBuilder();
            if (a.getRollingRule().getMaxAttempts() != null) {
                sb.append("At most ").append(a.getRollingRule().getMaxAttempts()).append(" tests in any 12 months");
            } else {
                sb.append("No yearly limit");
            }
            if (a.getRollingRule().getMinGapDays() != null) {
                sb.append(", at least ").append(a.getRollingRule().getMinGapDays()).append(" days between two tests");
            }
            sb.append(". Tests in the last 12 months: ").append(a.getUsedLast12Months()).append(".");
            if (a.getLifetimeRule() != null && a.getLifetimeRule().getMaxAttempts() != null) {
                sb.append(" Lifetime: used ").append(a.getUsed()).append(" of ").append(a.getLifetimeRule().getMaxAttempts()).append(".");
            }
            if (a.isExhausted()) {
                return new CheckLine("Attempts", CheckLine.FAIL, sb.toString() + " No attempts left.");
            }
            if (a.getNextRetestDate() != null) {
                sb.append(" Next test allowed from ").append(DateUtil.format(a.getNextRetestDate())).append(".");
                return new CheckLine("Attempts", CheckLine.WARN, sb.toString());
            }
            sb.append(" You can take the test now.");
            return new CheckLine("Attempts", CheckLine.PASS, sb.toString());
        }

        String window = "";
        if (a.getMainRule() != null && AttemptCounter.CONSECUTIVE.equals(a.getMainRule().getCountingRule())) {
            window = a.getWindowFrom() != null
                    ? " Allowed in " + a.getMainRule().getWindowYears() + " consecutive years from your Class 12 year: "
                      + a.getWindowFrom() + "-" + a.getWindowTo() + "."
                    : " Allowed in " + a.getMainRule().getWindowYears()
                      + " consecutive years from the year you pass Class 12 - add your Class 12 details.";
        }
        if (a.getMaxAttempts() != null) {
            String text = (a.getUsed() == 0 ? "None of the " + a.getMaxAttempts() + " attempts used yet. "
                                            : "Used " + a.getUsed() + " of " + a.getMaxAttempts() + " (" + usedText + "). ")
                    + a.getRemaining() + " left." + window + note;
            return new CheckLine("Attempts", a.isExhausted() ? CheckLine.FAIL : CheckLine.PASS, text);
        }
        if (a.getMainRule() == null) {
            return new CheckLine("Attempts", CheckLine.INFO, "No attempt rule is recorded, so attempts are treated as unlimited.");
        }
        String used = a.getUsed() > 0 ? " You have used " + a.getUsed() + " so far (" + usedText + ")." : "";
        if (rawNote != null && rawNote.startsWith("No attempt limit")) {
            note = rawNote.equals("No attempt limit") || rawNote.startsWith("No attempt limit within") ? ""
                    : " Rule: " + rawNote + (rawNote.endsWith(".") ? "" : ".");
        }
        return new CheckLine("Attempts", a.getWindowFrom() == null && !window.isEmpty() ? CheckLine.WARN : CheckLine.INFO,
                "No attempt limit - unlimited within the age limit." + used + window + note);
    }

    private String eligibleHeadline(String name, AttemptStatus a, Integer last, String limitReason,
                                    QualificationOutcome qual, Exam exam) {
        if (a.getRollingRule() != null) {
            if (a.getNextRetestDate() != null) {
                return "You can take " + name + " again from " + DateUtil.format(a.getNextRetestDate())
                        + " (retake rules: " + rollingRuleText(a) + ").";
            }
            if (a.getLifetimeRemaining() != null) {
                return "You can take " + name + " now " + DASH + " " + a.getLifetimeRemaining() + " of "
                        + a.getLifetimeRule().getMaxAttempts() + " lifetime attempts left.";
            }
            if (a.getRollingRule().getMaxAttempts() != null) {
                return "You can take " + name + " now " + DASH + " "
                        + (a.getRollingRule().getMaxAttempts() - a.getUsedLast12Months()) + " of "
                        + a.getRollingRule().getMaxAttempts() + " tests left in the current 12 months.";
            }
            return "You can take " + name + " now.";
        }
        if (a.getRemaining() != null) {
            int left = a.getRemaining();
            String s = "You have " + left + " " + name + " attempt" + (left == 1 ? "" : "s") + " left";
            return last != null ? s + ", valid until " + last + "." : s + " (no age limit).";
        }
        if (last != null) {
            if ("WINDOW".equals(limitReason)) {
                return "Eligible for " + name + " until " + last + " " + DASH + " " + a.getMainRule().getWindowYears()
                        + " consecutive years from your Class 12 year (" + a.getWindowFrom() + ").";
            }
            if ("QUALIFICATION".equals(limitReason)) {
                return "Eligible for " + name + " until " + last + " " + DASH + " within "
                        + qual.getRule().getMaxYearsSincePassing() + " year(s) of passing.";
            }
            return "Unlimited attempts within age " + DASH + " eligible until " + last + " (age limit).";
        }
        return "No age or attempt limit " + DASH + " you can take " + name
                + (HorizonPlanner.sittingsPerYear(exam) > 1 ? " in every session." : " every year.");
    }

    private String rollingRuleText(AttemptStatus a) {
        List<String> parts = new ArrayList<>();
        if (a.getRollingRule().getMaxAttempts() != null) {
            parts.add(a.getRollingRule().getMaxAttempts() + " tests in 12 months");
        }
        if (a.getRollingRule().getMinGapDays() != null) {
            parts.add(a.getRollingRule().getMinGapDays() + "-day gap");
        }
        return String.join(", ", parts);
    }

    // ------------------------------------------------------------------ other rules (step 7)

    private List<CheckLine> checkOtherRules(CandidateData c, List<OtherRule> rules, Exam exam, boolean domicileOk) {
        Profile p = c.getProfile();
        List<CheckLine> lines = new ArrayList<>();
        String[] order = {"NATIONALITY", "GENDER", "MARITAL_STATUS", "DOMICILE", "PHYSICAL_STANDARD", "REGISTRATION", "OTHER"};
        boolean stateLineDone = false;

        for (String type : order) {
            if ("DOMICILE".equals(type) && "STATE".equals(exam.getScope()) && exam.getStateCode() != null) {
                lines.add(stateDomicileLine(c, exam, domicileOk));
                stateLineDone = true;
            }
            for (OtherRule r : rules) {
                if (!type.equals(r.getRuleType())) {
                    continue;
                }
                String summary = r.getTextSummary();
                String failResult = r.isBlocking() ? CheckLine.FAIL : CheckLine.WARN;
                switch (type) {
                    case "NATIONALITY": {
                        String v = p.getNationality() == null ? "INDIAN" : p.getNationality();
                        if (inList(v, r.getRuleValue())) {
                            lines.add(new CheckLine("Nationality", CheckLine.PASS, "Your nationality (" + pretty(v) + ") is accepted."));
                        } else {
                            lines.add(new CheckLine("Nationality", failResult, "This exam is open only to "
                                    + prettyList(r.getRuleValue()) + " candidates; your profile says " + pretty(v) + "."));
                        }
                        break;
                    }
                    case "GENDER": {
                        String v = p.getGender();
                        if (v == null) {
                            lines.add(new CheckLine("Gender", CheckLine.WARN, "This entry is only for "
                                    + prettyList(r.getRuleValue()).toLowerCase() + " candidates - add your gender to the profile."));
                        } else if (inList(v, r.getRuleValue())) {
                            lines.add(new CheckLine("Gender", CheckLine.PASS, "Open to " + prettyList(r.getRuleValue()).toLowerCase() + " candidates."));
                        } else {
                            lines.add(new CheckLine("Gender", failResult, "This entry is only for "
                                    + prettyList(r.getRuleValue()).toLowerCase() + " candidates."));
                        }
                        break;
                    }
                    case "MARITAL_STATUS": {
                        String v = p.getMaritalStatus();
                        if (v == null) {
                            lines.add(new CheckLine("Marital status", CheckLine.WARN, "This entry is only for "
                                    + prettyList(r.getRuleValue()).toLowerCase() + " candidates - add your marital status to the profile."));
                        } else if (inList(v, r.getRuleValue())) {
                            lines.add(new CheckLine("Marital status", CheckLine.PASS, "Marital status \"" + pretty(v).toLowerCase() + "\" is accepted."));
                        } else {
                            lines.add(new CheckLine("Marital status", failResult, "This entry is only for "
                                    + prettyList(r.getRuleValue()).toLowerCase() + " candidates."));
                        }
                        break;
                    }
                    case "DOMICILE": {
                        if (stateLineDone && r.getRuleValue() != null && r.getRuleValue().equals(exam.getStateCode()) && !r.isBlocking()) {
                            break;   // already explained by the state domicile line
                        }
                        boolean ok = r.getRuleValue() != null && r.getRuleValue().equals(p.getDomicileStateCode());
                        if (ok) {
                            lines.add(new CheckLine("Domicile", CheckLine.PASS, "Your domicile (" + p.getDomicileStateCode() + ") matches."));
                        } else {
                            lines.add(new CheckLine("Domicile", r.isBlocking() ? CheckLine.FAIL : CheckLine.INFO,
                                    summary != null ? summary : "Domicile of " + r.getRuleValue() + " is needed for some posts or benefits."));
                        }
                        break;
                    }
                    case "PHYSICAL_STANDARD":
                        lines.add(new CheckLine("Physical standards", CheckLine.INFO,
                                summary != null ? summary : "Physical / medical standards apply - check the official notification."));
                        break;
                    case "REGISTRATION":
                        lines.add(new CheckLine("Requirement", CheckLine.WARN, "You also need: "
                                + (summary != null ? summary : pretty(r.getRuleValue())) + " (the app cannot check this)."));
                        break;
                    default: // OTHER
                        if ("NO_PWBD".equals(r.getRuleValue())) {
                            if (c.isBenchmarkPwbd()) {
                                lines.add(new CheckLine("PwBD", failResult, "This entry is not open to PwBD candidates."));
                            }
                        } else if ("NOT_GRADUATE".equals(r.getRuleValue())) {
                            if (isGraduate(c)) {
                                lines.add(new CheckLine("Qualification limit", failResult, "This exam is only for candidates who are not yet graduates."));
                            }
                        } else {
                            lines.add(new CheckLine("Note", CheckLine.INFO, summary != null ? summary : pretty(r.getRuleValue())));
                        }
                        break;
                }
            }
        }
        return lines;
    }

    private CheckLine stateDomicileLine(CandidateData c, Exam exam, boolean domicileOk) {
        if (domicileOk) {
            return new CheckLine("Domicile", CheckLine.PASS, "You are a domicile of " + exam.getStateCode()
                    + ", so the state's relaxations and reservation apply to you.");
        }
        if (!"GEN".equals(c.getCategory())) {
            return new CheckLine("Domicile", CheckLine.WARN, "You are not a domicile of " + exam.getStateCode()
                    + ", so reserved-category benefits do not apply; you are treated as General for this exam.");
        }
        return new CheckLine("Domicile", CheckLine.INFO, "Candidates from other states may apply as General candidates.");
    }

    private boolean isGraduate(CandidateData c) {
        for (Education e : c.getEducations()) {
            if (!"APPEARING".equals(e.getStatus())
                    && ("UG".equals(e.getLevel()) || "PG".equals(e.getLevel()) || "PHD".equals(e.getLevel()))) {
                return true;
            }
        }
        return false;
    }

    private boolean isPersonalCheck(String name) {
        return "Nationality".equals(name) || "Gender".equals(name) || "Marital status".equals(name)
                || "Domicile".equals(name) || "PwBD".equals(name) || "Qualification limit".equals(name);
    }

    // ------------------------------------------------------------------ small helpers

    private EligibilityResult newResult(ExamRuleSet rules, LocalDate today) {
        EligibilityResult r = new EligibilityResult();
        r.setExamId(rules.getExam().getId());
        r.setRuleVersionId(rules.getRuleVersionId());
        r.setComputedFor(today);
        return r;
    }

    /** ELIGIBLE > PROVISIONAL > NOT_YET > EXHAUSTED > NOT_ELIGIBLE, then the later last year (null = no end). */
    private boolean better(EligibilityResult a, EligibilityResult b) {
        int ra = statusRank(a.getStatus());
        int rb = statusRank(b.getStatus());
        if (ra != rb) {
            return ra > rb;
        }
        if (a.getLastEligibleYear() == null || b.getLastEligibleYear() == null) {
            return a.getLastEligibleYear() == null && b.getLastEligibleYear() != null;
        }
        if (!a.getLastEligibleYear().equals(b.getLastEligibleYear())) {
            return a.getLastEligibleYear() > b.getLastEligibleYear();
        }
        return a.getFirstEligibleYear() != null && b.getFirstEligibleYear() != null
                && a.getFirstEligibleYear() < b.getFirstEligibleYear();
    }

    public static int statusRank(String status) {
        switch (status) {
            case EligibilityResult.ELIGIBLE:
                return 5;
            case EligibilityResult.PROVISIONAL:
                return 4;
            case EligibilityResult.NOT_YET:
                return 3;
            case EligibilityResult.EXHAUSTED:
                return 2;
            default:
                return 1;
        }
    }

    /** Civil services exams are spoken of by the body name: "UPSC CSE" -> "UPSC". */
    public static String headlineName(Exam exam) {
        String n = exam.getShortName() == null ? exam.getName() : exam.getShortName();
        if (n.endsWith(" CSE")) {
            n = n.substring(0, n.length() - 4);
        }
        return n;
    }

    private CheckLine firstFail(List<CheckLine> lines) {
        for (CheckLine l : lines) {
            if (l.isFail()) {
                return l;
            }
        }
        return null;
    }

    private boolean inList(String value, String list) {
        if (list == null) {
            return true;
        }
        for (String s : list.split(",")) {
            if (s.trim().equalsIgnoreCase(value)) {
                return true;
            }
        }
        return false;
    }

    private String pretty(String code) {
        if (code == null) {
            return "";
        }
        String s = code.replace('_', ' ').toLowerCase();
        return Character.toUpperCase(s.charAt(0)) + s.substring(1);
    }

    /** "INDIAN,NEPAL,BHUTAN" -> "Indian, Nepal or Bhutan" */
    private String prettyList(String list) {
        String[] parts = list.split(",");
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < parts.length; i++) {
            if (i > 0) {
                sb.append(i == parts.length - 1 ? " or " : ", ");
            }
            sb.append(pretty(parts[i].trim()));
        }
        return sb.toString();
    }

    private String lowerFirst(String s) {
        if (s == null || s.isEmpty()) {
            return "";
        }
        if (s.length() > 1 && Character.isUpperCase(s.charAt(1))) {
            return s;   // keeps abbreviations such as "PwBD" or "SC"
        }
        return Character.toLowerCase(s.charAt(0)) + s.substring(1);
    }
}
