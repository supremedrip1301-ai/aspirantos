<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="com.aspirantos.model.Exam, com.aspirantos.model.Tracking, com.aspirantos.dao.ExamDAO, com.aspirantos.dao.TrackingDAO, com.aspirantos.util.ValidationUtil" %>
<%--
    Track / untrack / favourite an exam (action page, no HTML). POST only.
    "back=dashboard" returns to the dashboard, otherwise to the exam page.
--%>
<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>
<%@ include file="/WEB-INF/jspf/aspirant-only.jspf" %>
<%
    if (!"POST".equals(request.getMethod())) {
        response.sendRedirect("exams.jsp");
        return;
    }
    Integer examId = ValidationUtil.parseIntOrNull(request.getParameter("examId"));
    Exam exam = examId == null ? null : new ExamDAO().getExam(examId);
    if (exam == null) {
        session.setAttribute("error", "That exam was not found.");
        response.sendRedirect("exams.jsp");
        return;
    }
    String action = request.getParameter("action");
    if (action == null) {
        action = "";
    }
    TrackingDAO trackingDAO = new TrackingDAO();
    Tracking existing = trackingDAO.getTracking(currentUser.getId(), exam.getId());

    switch (action) {
        case "track": {
            if (existing == null) {
                Tracking t = new Tracking();
                t.setUserId(currentUser.getId());
                t.setExamId(exam.getId());
                int rows = trackingDAO.trackExam(t);
                session.setAttribute("success", exam.getShortName() + " is now on your tracked list (" + rows + " row affected).");
            }
            break;
        }
        case "untrack": {
            int rows = trackingDAO.untrackExam(currentUser.getId(), exam.getId());
            session.setAttribute("success", exam.getShortName() + " removed from your tracked list (" + rows + " row affected).");
            break;
        }
        case "favourite": {
            if (existing != null) {
                existing.setFavourite(!existing.isFavourite());
                trackingDAO.trackExam(existing);
                session.setAttribute("success", existing.isFavourite() ? exam.getShortName() + " pinned to the top." : exam.getShortName() + " unpinned.");
            }
            break;
        }
        default:
            break;
    }
    response.sendRedirect("dashboard".equals(request.getParameter("back")) ? "dashboard.jsp" : "exam-detail.jsp?id=" + exam.getId());
%>
