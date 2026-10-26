<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.*, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.engine.ExamRuleSet, com.aspirantos.util.RuleDiff, com.aspirantos.util.ValidationUtil" %>
<%--
    Rule version action page (admin, no HTML):
      clone    - sp_clone_rule_version (CallableStatement with an OUT parameter) copies the ACTIVE
                 version into a DRAFT; a new exam gets an empty version 1 instead
      saveInfo - change summary, official source and first cycle of the draft
      publish  - sp_activate_rule_version: archive the old version, activate the draft,
                 notify the students who track the exam, delete their cached results
      discard  - delete the draft (its rule rows go with ON DELETE CASCADE)
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%!
    private ExamRuleSet load(Exam exam, Integer versionId) {
        if (versionId == null) {
            return null;
        }
        RuleDAO dao = new RuleDAO();
        ExamRuleSet rs = new ExamRuleSet(exam, versionId);
        rs.setAgeRules(dao.getAgeRules(versionId));
        rs.setRelaxationRules(dao.getRelaxationRules(versionId));
        rs.setAttemptRules(dao.getAttemptRules(versionId));
        rs.setQualificationRules(dao.getQualificationRules(versionId));
        rs.setOtherRules(dao.getOtherRules(versionId));
        return rs;
    }
%>
<%
    if (!"POST".equals(request.getMethod())) {
        response.sendRedirect("exams.jsp");
        return;
    }
    request.setCharacterEncoding("UTF-8");
    Integer examId = ValidationUtil.parseIntOrNull(request.getParameter("exam"));
    Exam exam = examId == null ? null : new ExamDAO().getExam(examId);
    if (exam == null) {
        session.setAttribute("error", "That exam was not found.");
        response.sendRedirect("exams.jsp");
        return;
    }
    String back = "rules.jsp?exam=" + exam.getId();
    RuleVersionDAO versionDAO = new RuleVersionDAO();
    AuditDAO auditDAO = new AuditDAO();
    String action = request.getParameter("action");
    String ip = request.getRemoteAddr();
    String agent = request.getHeader("User-Agent");

    if ("clone".equals(action)) {
        int draftId;
        if (versionDAO.getVersionsByExam(exam.getId()).isEmpty()) {
            draftId = versionDAO.createFirstVersion(exam.getId(), currentUser.getId());
        } else {
            draftId = versionDAO.cloneActiveVersion(exam.getId(), currentUser.getId());   // OUT parameter = draft id
        }
        auditDAO.insertAudit(currentUser.getId(), "RULES_DRAFT", "exam_rule_version", String.valueOf(draftId), ip, agent);
        session.setAttribute(draftId > 0 ? "success" : "error", draftId > 0
                ? "Draft ready - edit the rules below, then publish." : "The draft could not be created.");
        response.sendRedirect(back + "#draft");
        return;
    }

    // the other actions work on the exam's DRAFT only
    Integer versionId = ValidationUtil.parseIntOrNull(request.getParameter("version"));
    RuleVersion draft = versionDAO.getDraft(exam.getId());
    if (draft == null || versionId == null || draft.getId() != versionId) {
        session.setAttribute("error", "This exam has no such draft.");
        response.sendRedirect(back);
        return;
    }

    if ("saveInfo".equals(action)) {
        String summary = ValidationUtil.clean(request.getParameter("changeSummary"));
        String source = ValidationUtil.clean(request.getParameter("sourceUrl"));
        Integer from = ValidationUtil.parseIntOrNull(request.getParameter("appliesFromCycleYear"));
        if ((summary != null && summary.length() > 500) || (source != null && (source.length() > 500 || !source.matches("https?://[^\\s\"'<>]+")))
                || (from != null && !ValidationUtil.inRange(from, 2000, 2100))) {
            session.setAttribute("error", "Summary at most 500 characters, source must be an http(s) link, cycle year 2000 to 2100.");
        } else {
            int rows = versionDAO.updateDraftInfo(draft.getId(), summary, source, from);
            session.setAttribute("success", "Draft details saved (" + rows + " row affected).");
        }
        response.sendRedirect(back + "#draft");
        return;
    }

    if ("publish".equals(action)) {
        ExamRuleSet draftRules = load(exam, draft.getId());
        ExamRuleSet activeRules = load(exam, exam.getActiveRuleVersionId());
        String summary = draft.getChangeSummary();
        if (RuleDiff.rowCount(draftRules) == 0) {
            session.setAttribute("error", "The draft has no rules - add at least one rule before publishing.");
        } else if (activeRules != null && RuleDiff.diff(activeRules, draftRules).isEmpty()) {
            session.setAttribute("error", "The draft is the same as the active version - nothing to publish.");
        } else if (summary == null || summary.startsWith("Draft copied from version")) {
            session.setAttribute("error", "Please write what changed (draft details) before publishing.");
        } else {
            int notified = versionDAO.activateVersion(draft.getId(), currentUser.getId());   // CallableStatement
            if (notified < 0) {
                session.setAttribute("error", "Publishing failed - nothing was changed.");
            } else {
                auditDAO.insertAudit(currentUser.getId(), "RULES_PUBLISH", "exam_rule_version",
                                     exam.getCode() + " v" + draft.getVersionNo(), ip, agent);
                session.setAttribute("success", "Version " + draft.getVersionNo() + " of " + exam.getShortName() + " is now active. "
                        + notified + " student" + (notified == 1 ? " was" : "s were") + " notified and their results are recalculated.");
            }
        }
        response.sendRedirect(back);
        return;
    }

    if ("discard".equals(action)) {
        int rows = versionDAO.deleteDraft(draft.getId());
        auditDAO.insertAudit(currentUser.getId(), "RULES_DISCARD", "exam_rule_version", String.valueOf(draft.getId()), ip, agent);
        session.setAttribute(rows > 0 ? "success" : "error", rows > 0 ? "Draft discarded (" + rows + " row affected)." : "The draft could not be deleted.");
        response.sendRedirect(back);
        return;
    }
    response.sendRedirect(back);
%>
