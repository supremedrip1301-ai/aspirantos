<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="com.aspirantos.model.InfoReport, com.aspirantos.model.Notification, com.aspirantos.dao.InfoReportDAO, com.aspirantos.dao.NotificationDAO, com.aspirantos.util.ValidationUtil" %>
<%--
    Answer a student's report (admin action page, no HTML): set RESOLVED / REJECTED with a
    reply and send the reply to the student as a notification.
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%
    String back = ValidationUtil.isOneOf(request.getParameter("back"), "OPEN", "RESOLVED", "REJECTED", "ALL") ? request.getParameter("back") : "OPEN";
    if ("POST".equals(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        Integer id = ValidationUtil.parseIntOrNull(request.getParameter("id"));
        String status = request.getParameter("status");
        String reply = ValidationUtil.clean(request.getParameter("reply"));
        InfoReportDAO reportDAO = new InfoReportDAO();
        InfoReport report = id == null ? null : reportDAO.getReport(id);
        if (report == null || !ValidationUtil.isOneOf(status, "RESOLVED", "REJECTED")) {
            session.setAttribute("error", "That report was not found.");
        } else if (reply != null && reply.length() > 1000) {
            session.setAttribute("error", "The reply can be at most 1000 characters.");
        } else {
            int rows = reportDAO.updateReport(report.getId(), status, reply);
            Notification n = new Notification();
            n.setUserId(report.getUserId());
            n.setTitle("Your report about " + report.getExamShortName() + " was " + ("RESOLVED".equals(status) ? "resolved" : "closed"));
            n.setMessage(reply != null ? reply : ("RESOLVED".equals(status) ? "Thank you - the information has been checked." : "The information was checked and no change was needed."));
            n.setLinkUrl("aspirant/exam-detail.jsp?id=" + report.getExamId());
            new NotificationDAO().insertNotification(n);
            session.setAttribute("success", "Report " + status.toLowerCase() + " and the student was notified (" + rows + " row affected).");
        }
    }
    response.sendRedirect("reports.jsp?status=" + back);
%>
