<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="com.aspirantos.model.Exam, com.aspirantos.model.InfoReport, com.aspirantos.dao.ExamDAO, com.aspirantos.dao.InfoReportDAO, com.aspirantos.util.ValidationUtil" %>
<%--
    "Report outdated info" (action page, no HTML): stores an info_report row for the admin.
--%>
<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>
<%@ include file="/WEB-INF/jspf/aspirant-only.jspf" %>
<%
    if (!"POST".equals(request.getMethod())) {
        response.sendRedirect("exams.jsp");
        return;
    }
    request.setCharacterEncoding("UTF-8");
    Integer examId = ValidationUtil.parseIntOrNull(request.getParameter("examId"));
    Exam exam = examId == null ? null : new ExamDAO().getExam(examId);
    if (exam == null) {
        session.setAttribute("error", "That exam was not found.");
        response.sendRedirect("exams.jsp");
        return;
    }
    String message = ValidationUtil.clean(request.getParameter("message"));
    if (message == null || message.length() < 10 || message.length() > 1000) {
        session.setAttribute("error", "Please describe the problem in 10 to 1000 characters.");
        response.sendRedirect("exam-detail.jsp?id=" + exam.getId() + "#overview");
        return;
    }
    InfoReport r = new InfoReport();
    r.setUserId(currentUser.getId());
    r.setExamId(exam.getId());
    r.setMessage(message);
    int rows = new InfoReportDAO().insertReport(r);
    session.setAttribute(rows > 0 ? "success" : "error", rows > 0
            ? "Thank you - the administrator will check the " + exam.getShortName() + " rules (" + rows + " row affected)."
            : "The report could not be saved. Please try again.");
    response.sendRedirect("exam-detail.jsp?id=" + exam.getId());
%>
