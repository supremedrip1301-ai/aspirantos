<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.time.LocalDate, com.aspirantos.model.*, com.aspirantos.dao.RuleDAO, com.aspirantos.dao.RuleVersionDAO, com.aspirantos.util.ValidationUtil" %>
<%--
    Rule row action page (admin, no HTML): save (insert / update) or delete one row of the
    DRAFT version. type = age / relax / attempt / qual / other. RuleDAO refuses every change
    to a version that is not a DRAFT and records who changed what in rule_change_log.
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%!
    // declaration: small helpers for the many optional fields
    private Integer num(HttpServletRequest r, String name) {
        return ValidationUtil.parseIntOrNull(r.getParameter(name));
    }

    private Double dec(HttpServletRequest r, String name) {
        return ValidationUtil.parseDoubleOrNull(r.getParameter(name));
    }

    private String str(HttpServletRequest r, String name) {
        return ValidationUtil.clean(r.getParameter(name));
    }

    private boolean okRange(Number v, double min, double max) {
        return v == null || ValidationUtil.inRange(v, min, max);
    }

    private boolean okLength(String s, int max) {
        return s == null || s.length() <= max;
    }

    private boolean okDay(Integer month, Integer day) {
        if (month == null || day == null) {
            return false;
        }
        try {
            LocalDate.of(2024, month, day);   // 2024 is a leap year, so 29 February is allowed
            return true;
        } catch (Exception e) {
            return false;
        }
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    Integer examId = num(request, "exam");
    Integer versionId = num(request, "version");
    String type = request.getParameter("type");
    String action = request.getParameter("action");
    RuleVersion version = versionId == null ? null : new RuleVersionDAO().getVersion(versionId);
    if (examId == null || version == null || version.getExamId() != examId || !"DRAFT".equals(version.getStatus())) {
        session.setAttribute("error", "Rules can only be changed in a draft version.");
        response.sendRedirect(examId == null ? "exams.jsp" : "rules.jsp?exam=" + examId);
        return;
    }
    String back = "rules.jsp?exam=" + examId;
    RuleDAO ruleDAO = new RuleDAO();
    int adminId = currentUser.getId();
    Integer id = num(request, "id");
    int rowId = id == null ? 0 : id;

    // ------------------------------------------------------------ delete (GET link with confirm)
    if ("delete".equals(action)) {
        int rows = 0;
        switch (type == null ? "" : type) {
            case "age": rows = ruleDAO.deleteAgeRule(rowId, versionId, adminId); break;
            case "relax": rows = ruleDAO.deleteRelaxationRule(rowId, versionId, adminId); break;
            case "attempt": rows = ruleDAO.deleteAttemptRule(rowId, versionId, adminId); break;
            case "qual": rows = ruleDAO.deleteQualificationRule(rowId, versionId, adminId); break;
            case "other": rows = ruleDAO.deleteOtherRule(rowId, versionId, adminId); break;
            default: break;
        }
        session.setAttribute(rows > 0 ? "success" : "error", rows > 0 ? "Rule deleted from the draft (" + rows + " row affected)." : "That rule was not found in the draft.");
        response.sendRedirect(back + "#" + type);
        return;
    }
    if (!"POST".equals(request.getMethod()) || !"save".equals(action)) {
        response.sendRedirect(back);
        return;
    }

    // ------------------------------------------------------------ save
    String error = null;
    Object row = null;
    int rows = 0;
    switch (type == null ? "" : type) {
        case "age": {
            AgeRule r = new AgeRule();
            r.setId(rowId);
            r.setRuleVersionId(versionId);
            r.setPostOrCourse(str(request, "postOrCourse"));
            r.setMinAge(num(request, "minAge"));
            r.setMaxAge(num(request, "maxAge"));
            r.setMaxAgeSemantics(request.getParameter("maxAgeSemantics"));
            r.setCutoffType(request.getParameter("cutoffType"));
            r.setCutoffMonth(num(request, "cutoffMonth"));
            r.setCutoffDay(num(request, "cutoffDay"));
            r.setDobFromOffsetYears(num(request, "dobFromOffsetYears"));
            r.setDobFromMonth(num(request, "dobFromMonth"));
            r.setDobFromDay(num(request, "dobFromDay"));
            r.setDobToOffsetYears(num(request, "dobToOffsetYears"));
            r.setDobToMonth(num(request, "dobToMonth"));
            r.setDobToDay(num(request, "dobToDay"));
            r.setNotes(str(request, "notes"));
            row = r;
            boolean fixed = r.getCutoffType() != null && r.getCutoffType().startsWith("FIXED_DATE");
            if (!ValidationUtil.isOneOf(r.getCutoffType(), "FIXED_DATE_IN_CYCLE_YEAR", "FIXED_DATE_IN_PREVIOUS_YEAR", "FIXED_DATE_IN_NEXT_YEAR", "DOB_WINDOW", "NONE")
                    || !ValidationUtil.isOneOf(r.getMaxAgeSemantics(), "NOT_ATTAINED", "NOT_MORE_THAN")) {
                error = "Please choose how the age is counted.";
            } else if (!okRange(r.getMinAge(), 0, 80) || !okRange(r.getMaxAge(), 0, 80)) {
                error = "Ages must be between 0 and 80.";
            } else if (r.getMinAge() != null && r.getMaxAge() != null && r.getMaxAge() < r.getMinAge()) {
                error = "The upper age cannot be below the minimum age.";
            } else if (fixed && !okDay(r.getCutoffMonth(), r.getCutoffDay())) {
                error = "A cut-off date rule needs a valid month and day.";
            } else if ("DOB_WINDOW".equals(r.getCutoffType())
                       && (r.getDobFromOffsetYears() == null || !okRange(r.getDobFromOffsetYears(), -100, 0) || !okDay(r.getDobFromMonth(), r.getDobFromDay()))) {
                error = "A birth-date window needs the 'born on or after' year offset (for example -25), month and day.";
            } else if ("DOB_WINDOW".equals(r.getCutoffType()) && r.getDobToOffsetYears() != null
                       && (!okRange(r.getDobToOffsetYears(), -100, 0) || !okDay(r.getDobToMonth(), r.getDobToDay()))) {
                error = "The 'born on or before' part needs a year offset, month and day (or leave all three empty).";
            } else if (!okLength(r.getPostOrCourse(), 120) || !okLength(r.getNotes(), 500)) {
                error = "Post: at most 120 characters, notes: at most 500.";
            }
            if (error == null) {
                if (!fixed) {
                    r.setCutoffMonth(null);
                    r.setCutoffDay(null);
                }
                if (!"DOB_WINDOW".equals(r.getCutoffType())) {
                    r.setDobFromOffsetYears(null); r.setDobFromMonth(null); r.setDobFromDay(null);
                    r.setDobToOffsetYears(null); r.setDobToMonth(null); r.setDobToDay(null);
                } else if (r.getDobToOffsetYears() == null) {
                    r.setDobToMonth(null);
                    r.setDobToDay(null);
                }
                rows = rowId > 0 ? ruleDAO.updateAgeRule(r, adminId) : ruleDAO.insertAgeRule(r, adminId);
            }
            break;
        }
        case "relax": {
            RelaxationRule r = new RelaxationRule();
            r.setId(rowId);
            r.setRuleVersionId(versionId);
            r.setRelaxationType(request.getParameter("relaxationType"));
            r.setCategory(str(request, "category"));
            Integer years = num(request, "years");
            r.setYears(years == null ? 0 : years);
            r.setStacking(request.getParameter("stacking"));
            r.setOverallMaxAgeCap(num(request, "overallMaxAgeCap"));
            r.setRequiresStateDomicile(request.getParameter("requiresStateDomicile") != null);
            r.setNotes(str(request, "notes"));
            row = r;
            if (!ValidationUtil.isOneOf(r.getRelaxationType(), "CATEGORY", "PWBD", "EX_SERVICEMAN", "JK_DOMICILE_1980_89", "GOVT_EMPLOYEE",
                                        "WOMEN", "WIDOW_DIVORCED_WOMEN", "TRANSGENDER", "STATE_DOMICILE")
                    || !ValidationUtil.isOneOf(r.getStacking(), "ADD", "ADD_AFTER_SERVICE_DEDUCTION", "REPLACE_WITH_MAX")) {
                error = "Please choose who gets the relaxation and how it works.";
            } else if (r.getCategory() != null && !ValidationUtil.isOneOf(r.getCategory(), "GEN", "EWS", "OBC_NCL", "SC", "ST")) {
                error = "Please choose a category from the list.";
            } else if ("CATEGORY".equals(r.getRelaxationType()) && r.getCategory() == null) {
                error = "A category relaxation needs the category.";
            } else if (years == null || !ValidationUtil.inRange(years, 0, 40)) {
                error = "Years must be between 0 and 40.";
            } else if (!okRange(r.getOverallMaxAgeCap(), 18, 70)) {
                error = "The age cap must be between 18 and 70.";
            } else if ("REPLACE_WITH_MAX".equals(r.getStacking()) && r.getOverallMaxAgeCap() == null && years == 0) {
                error = "An 'up to' relaxation needs years, or an age cap that raises the limit.";
            } else if (!okLength(r.getNotes(), 500)) {
                error = "Notes can be at most 500 characters.";
            }
            if (error == null) {
                rows = rowId > 0 ? ruleDAO.updateRelaxationRule(r, adminId) : ruleDAO.insertRelaxationRule(r, adminId);
            }
            break;
        }
        case "attempt": {
            AttemptRule r = new AttemptRule();
            r.setId(rowId);
            r.setRuleVersionId(versionId);
            r.setCategory(str(request, "category"));
            String pwbd = request.getParameter("pwbd");
            r.setPwbd("true".equals(pwbd) ? Boolean.TRUE : ("false".equals(pwbd) ? Boolean.FALSE : null));
            r.setMaxAttempts(num(request, "maxAttempts"));
            r.setCountingRule(request.getParameter("countingRule"));
            r.setWindowYears(num(request, "windowYears"));
            r.setMinGapDays(num(request, "minGapDays"));
            r.setNotes(str(request, "notes"));
            row = r;
            if (!ValidationUtil.isOneOf(r.getCountingRule(), "APPEARED_IN_FIRST_STAGE", "APPLIED", "PER_SITTING",
                                        "CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM", "PER_ROLLING_12_MONTHS", "LIFETIME_TOTAL")) {
                error = "Please choose what counts as an attempt.";
            } else if (r.getCategory() != null && !ValidationUtil.isOneOf(r.getCategory(), "GEN", "EWS", "OBC_NCL", "SC", "ST")) {
                error = "Please choose a category from the list.";
            } else if (!okRange(r.getMaxAttempts(), 1, 50) || !okRange(r.getWindowYears(), 1, 10) || !okRange(r.getMinGapDays(), 1, 365)) {
                error = "Attempts 1 to 50, window 1 to 10 years, gap 1 to 365 days.";
            } else if ("CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM".equals(r.getCountingRule()) && r.getWindowYears() == null) {
                error = "The Class 12 window rule needs the number of window years.";
            } else if (("PER_ROLLING_12_MONTHS".equals(r.getCountingRule()) || "LIFETIME_TOTAL".equals(r.getCountingRule())) && r.getMaxAttempts() == null) {
                error = "A 12-month or lifetime rule needs the maximum number of attempts.";
            } else if (!okLength(r.getNotes(), 500)) {
                error = "Notes can be at most 500 characters.";
            }
            if (error == null) {
                rows = rowId > 0 ? ruleDAO.updateAttemptRule(r, adminId) : ruleDAO.insertAttemptRule(r, adminId);
            }
            break;
        }
        case "qual": {
            QualificationRule r = new QualificationRule();
            r.setId(rowId);
            r.setRuleVersionId(versionId);
            r.setPostOrCourse(str(request, "postOrCourse"));
            r.setRequiredLevel(request.getParameter("requiredLevel"));
            String accepted = str(request, "acceptedDegrees");
            r.setAcceptedDegrees(accepted == null ? "ANY" : accepted);
            String subjects = str(request, "requiredSubjects");
            r.setRequiredSubjects(subjects == null ? null : subjects.toUpperCase().replaceAll("\\s*([,|:])\\s*", "$1"));
            r.setMinPercentGeneral(dec(request, "minPercentGeneral"));
            r.setMinPercentRelaxed(dec(request, "minPercentRelaxed"));
            String relaxedFor = str(request, "relaxedFor");
            r.setRelaxedFor(relaxedFor == null ? null : relaxedFor.toUpperCase().replace(" ", ""));
            r.setFinalYearAllowed(request.getParameter("finalYearAllowed") != null);
            r.setMaxYearsSincePassing(num(request, "maxYearsSincePassing"));
            r.setMinExperienceYears(dec(request, "minExperienceYears"));
            r.setTextSummary(str(request, "textSummary"));
            row = r;
            if (!ValidationUtil.isOneOf(r.getRequiredLevel(), "NONE", "CLASS_10", "CLASS_12", "DIPLOMA", "UG", "PG", "PHD", "PROFESSIONAL")) {
                error = "Please choose the required level.";
            } else if (!okLength(r.getAcceptedDegrees(), 500) || !okLength(r.getPostOrCourse(), 120) || !okLength(r.getTextSummary(), 500)) {
                error = "Degrees and summary: at most 500 characters, post: at most 120.";
            } else if (r.getRequiredSubjects() != null && !r.getRequiredSubjects().matches("([A-Z_0-9]+:)?[A-Z0-9 &().|,-]{1,300}")) {
                error = "Subjects: words separated by , (all needed) or | (any one), optionally starting with CLASS_12: or CLASS_10:.";
            } else if (!okRange(r.getMinPercentGeneral(), 0, 100) || !okRange(r.getMinPercentRelaxed(), 0, 100)) {
                error = "Percentages must be between 0 and 100.";
            } else if (r.getMinPercentRelaxed() != null && (r.getMinPercentGeneral() == null || r.getMinPercentRelaxed() > r.getMinPercentGeneral())) {
                error = "The relaxed percentage needs a general percentage and cannot be higher than it.";
            } else if (r.getMinPercentRelaxed() != null && r.getRelaxedFor() == null) {
                error = "Say who gets the relaxed percentage (for example SC,ST,PWBD).";
            } else if (r.getRelaxedFor() != null && !r.getRelaxedFor().matches("[A-Z_]+(,[A-Z_]+)*")) {
                error = "Relaxed for: codes separated by commas, for example SC,ST,OBC_NCL,PWBD.";
            } else if (!okRange(r.getMaxYearsSincePassing(), 0, 20) || !okRange(r.getMinExperienceYears(), 0, 40)) {
                error = "Years since passing 0 to 20, experience 0 to 40.";
            }
            if (error == null) {
                rows = rowId > 0 ? ruleDAO.updateQualificationRule(r, adminId) : ruleDAO.insertQualificationRule(r, adminId);
            }
            break;
        }
        case "other": {
            OtherRule r = new OtherRule();
            r.setId(rowId);
            r.setRuleVersionId(versionId);
            r.setPostOrCourse(str(request, "postOrCourse"));
            r.setRuleType(request.getParameter("ruleType"));
            String value = str(request, "ruleValue");
            r.setRuleValue(value == null ? null : value.toUpperCase().replace(" ", ""));
            r.setBlocking(request.getParameter("blocking") != null);
            r.setTextSummary(str(request, "textSummary"));
            row = r;
            if (!ValidationUtil.isOneOf(r.getRuleType(), "NATIONALITY", "GENDER", "MARITAL_STATUS", "DOMICILE", "PHYSICAL_STANDARD", "REGISTRATION", "OTHER")) {
                error = "Please choose the type of condition.";
            } else if (r.getRuleValue() != null && !r.getRuleValue().matches("[A-Z0-9_]+(,[A-Z0-9_]+)*")) {
                error = "Value: codes separated by commas, for example UNMARRIED or MALE,FEMALE.";
            } else if (r.getRuleValue() == null && ValidationUtil.isOneOf(r.getRuleType(), "NATIONALITY", "GENDER", "MARITAL_STATUS", "DOMICILE")) {
                error = "This type of condition needs a value.";
            } else if (!okLength(r.getRuleValue(), 200) || !okLength(r.getTextSummary(), 500) || !okLength(r.getPostOrCourse(), 120)) {
                error = "Value: at most 200 characters, text: at most 500.";
            }
            if (error == null) {
                rows = rowId > 0 ? ruleDAO.updateOtherRule(r, adminId) : ruleDAO.insertOtherRule(r, adminId);
            }
            break;
        }
        default:
            error = "Unknown rule type.";
    }

    if (error == null && rows == 0) {
        error = "The rule could not be saved - please check the values.";
    }
    if (error != null) {
        session.setAttribute("error", error);
        if (row != null) {
            session.setAttribute("formRule", row);       // keep the typed values (Experiment 5 pattern)
            session.setAttribute("formRuleType", type);
        }
        response.sendRedirect(back + "#" + type + "-form");
        return;
    }
    session.setAttribute("success", (rowId > 0 ? "Rule updated" : "Rule added") + " in the draft (" + rows + " row affected).");
    response.sendRedirect(back + "#" + type);
%>
