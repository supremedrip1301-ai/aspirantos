<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="com.aspirantos.model.Exam, com.aspirantos.model.UpdateCheck, com.aspirantos.dao.ExamDAO, com.aspirantos.dao.AuditDAO, com.aspirantos.service.UpdateChecker, com.aspirantos.service.UpdateCheckJob, com.aspirantos.util.DateUtil, com.aspirantos.util.ValidationUtil" %>
<%--
    Update check action page (admin, no HTML):
      check    - checks one exam's official page now and goes back to its rules page
      checkAll - starts the background job for every active exam (UpdateCheckJob)
      stop     - asks the background job to stop after the current exam
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%
    if (!"POST".equals(request.getMethod())) {
        response.sendRedirect("update-check.jsp");
        return;
    }
    String action = request.getParameter("action");
    if ("check".equals(action)) {
        Integer examId = ValidationUtil.parseIntOrNull(request.getParameter("exam"));
        Exam exam = examId == null ? null : new ExamDAO().getExam(examId);
        if (exam == null) {
            session.setAttribute("error", "That exam was not found.");
            response.sendRedirect("exams.jsp");
            return;
        }
        UpdateCheck c = new UpdateChecker().check(exam, currentUser.getId());
        new AuditDAO().insertAudit(currentUser.getId(), "UPDATE_CHECK", "exam", String.valueOf(exam.getId()),
                                   request.getRemoteAddr(), request.getHeader("User-Agent"));
        if (c.getErrorMessage() != null) {
            session.setAttribute("error", "Could not reach the official site (" + c.getErrorMessage() + ") You can still update the rules by hand.");
        } else if (c.getChangedSinceLast() == null) {
            session.setAttribute("success", "First check saved - later checks are compared with this one.");
        } else if (c.getChangedSinceLast()) {
            session.setAttribute("error", "The official page has changed since the last check - read the snippets below and update the rules if needed.");
        } else {
            session.setAttribute("success", "No change detected on the official page.");
        }
        response.sendRedirect("rules.jsp?exam=" + exam.getId() + "#updates");
        return;
    }
    if ("checkAll".equals(action)) {
        boolean started = UpdateCheckJob.start(currentUser.getId());
        new AuditDAO().insertAudit(currentUser.getId(), "UPDATE_CHECK_ALL", "exam", "all", request.getRemoteAddr(), request.getHeader("User-Agent"));
        session.setAttribute(started ? "success" : "error", started ? "Checking all exams in the background - you can leave this page." : "A check is already running.");
    } else if ("stop".equals(action)) {
        UpdateCheckJob.stop();
        session.setAttribute("success", "The check will stop after the current exam.");
    }
    response.sendRedirect("update-check.jsp");
%>
