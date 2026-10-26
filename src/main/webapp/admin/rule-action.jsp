<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="com.aspirantos.model.*, com.aspirantos.dao.RuleDAO, com.aspirantos.dao.RuleVersionDAO, com.aspirantos.service.RuleValidator, com.aspirantos.util.ValidationUtil" %>
<%--
    Rule row action page (admin, no HTML): save (insert / update) or delete one row of the
    DRAFT version. type = age / relax / attempt / qual / other. The checks are in
    RuleValidator (shared with the rule pack import); RuleDAO refuses every change to a
    version that is not a DRAFT and records who changed what in rule_change_log.
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%!
    // declaration: short helpers for the many optional fields
    private Integer num(HttpServletRequest r, String name) {
        return ValidationUtil.parseIntOrNull(r.getParameter(name));
    }

    private Double dec(HttpServletRequest r, String name) {
        return ValidationUtil.parseDoubleOrNull(r.getParameter(name));
    }

    private String str(HttpServletRequest r, String name) {
        return ValidationUtil.clean(r.getParameter(name));
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
    if (type == null) {
        type = "";
    }

    // ------------------------------------------------------------ delete (GET link with confirm)
    if ("delete".equals(action)) {
        int rows = 0;
        switch (type) {
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
    String error;
    Object row;
    int rows = 0;
    switch (type) {
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
            error = RuleValidator.age(r);
            if (error == null) {
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
            r.setYears(years == null ? -1 : years);   // -1 = missing, refused by the validator
            r.setStacking(request.getParameter("stacking"));
            r.setOverallMaxAgeCap(num(request, "overallMaxAgeCap"));
            r.setRequiresStateDomicile(request.getParameter("requiresStateDomicile") != null);
            r.setNotes(str(request, "notes"));
            row = r;
            error = RuleValidator.relaxation(r);
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
            error = RuleValidator.attempt(r);
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
            r.setAcceptedDegrees(str(request, "acceptedDegrees"));
            r.setRequiredSubjects(str(request, "requiredSubjects"));
            r.setMinPercentGeneral(dec(request, "minPercentGeneral"));
            r.setMinPercentRelaxed(dec(request, "minPercentRelaxed"));
            r.setRelaxedFor(str(request, "relaxedFor"));
            r.setFinalYearAllowed(request.getParameter("finalYearAllowed") != null);
            r.setMaxYearsSincePassing(num(request, "maxYearsSincePassing"));
            r.setMinExperienceYears(dec(request, "minExperienceYears"));
            r.setTextSummary(str(request, "textSummary"));
            row = r;
            error = RuleValidator.qualification(r);
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
            r.setRuleValue(str(request, "ruleValue"));
            r.setBlocking(request.getParameter("blocking") != null);
            r.setTextSummary(str(request, "textSummary"));
            row = r;
            error = RuleValidator.other(r);
            if (error == null) {
                rows = rowId > 0 ? ruleDAO.updateOtherRule(r, adminId) : ruleDAO.insertOtherRule(r, adminId);
            }
            break;
        }
        default:
            row = null;
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
