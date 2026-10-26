<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.time.LocalDate, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.util.ValidationUtil, com.aspirantos.util.DateUtil" %>
<%--
    Attempt journal action page (no HTML): save (insert / update) and delete, switch like
    StudentServlet. A new attempt also puts the exam on the tracked list. The trigger
    trg_attempt_log_bi sets counts_as_attempt and the AFTER triggers delete the old snapshot.
--%>
<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>
<%@ include file="/WEB-INF/jspf/aspirant-only.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    AttemptDAO attemptDAO = new AttemptDAO();
    String action = request.getParameter("action");
    if (action == null) {
        action = "";
    }

    switch (action) {
        case "delete": {
            Integer id = ValidationUtil.parseIntOrNull(request.getParameter("id"));
            int rows = id == null ? 0 : attemptDAO.deleteAttempt(id, currentUser.getId());
            session.setAttribute(rows > 0 ? "success" : "error",
                    rows > 0 ? "Attempt deleted (" + rows + " row affected)." : "That attempt was not found.");
            break;
        }
        case "save": {
            if (!"POST".equals(request.getMethod())) {
                break;
            }
            AttemptLog a = new AttemptLog();
            Integer id = ValidationUtil.parseIntOrNull(request.getParameter("id"));
            a.setId(id == null ? 0 : id);
            a.setUserId(currentUser.getId());
            Integer examId = ValidationUtil.parseIntOrNull(request.getParameter("examId"));
            a.setExamId(examId == null ? 0 : examId);
            Integer year = ValidationUtil.parseIntOrNull(request.getParameter("cycleYear"));
            a.setCycleYear(year == null ? 0 : year);
            Integer sitting = ValidationUtil.parseIntOrNull(request.getParameter("sittingNo"));
            a.setSittingNo(sitting == null ? 1 : sitting);
            a.setAttemptDate(DateUtil.parse(request.getParameter("attemptDate")));
            a.setStageReached(request.getParameter("stageReached"));
            a.setScore(ValidationUtil.parseDoubleOrNull(request.getParameter("score")));
            a.setRankObtained(ValidationUtil.parseIntOrNull(request.getParameter("rankObtained")));
            a.setRemarks(ValidationUtil.clean(request.getParameter("remarks")));

            LocalDate today = LocalDate.now();
            Exam exam = new ExamDAO().getExam(a.getExamId());
            String error = null;
            if (exam == null) {
                error = "Please choose the exam.";
            } else if (!ValidationUtil.inRange(a.getCycleYear(), 1990, today.getYear() + 1)) {
                error = "Exam year must be between 1990 and " + (today.getYear() + 1) + ".";
            } else if (!ValidationUtil.inRange(a.getSittingNo(), 1, 12)) {
                error = "Sitting must be a number from 1 to 12.";
            } else if (a.getAttemptDate() != null && a.getAttemptDate().isAfter(today)) {
                error = "The exam date cannot be in the future - log an attempt after you sit the exam.";
            } else if (!ValidationUtil.isOneOf(a.getStageReached(), "APPLIED_ONLY", "ABSENT", "APPEARED_STAGE_1", "CLEARED_STAGE_1",
                                               "APPEARED_STAGE_2", "CLEARED_STAGE_2", "INTERVIEW", "FINAL_SELECTED")) {
                error = "Please choose how far you got.";
            } else if (a.getScore() != null && !ValidationUtil.inRange(a.getScore(), -9999, 99999)) {
                error = "Score must be between -9999 and 99999.";
            } else if (a.getRankObtained() != null && a.getRankObtained() < 1) {
                error = "Rank must be 1 or more.";
            } else if (a.getRemarks() != null && a.getRemarks().length() > 500) {
                error = "Notes can be at most 500 characters.";
            }
            if (error == null) {
                // one row per exam, year and sitting (UNIQUE key uq_attempt_log)
                for (AttemptLog other : attemptDAO.getAttemptsByUserAndExam(currentUser.getId(), a.getExamId())) {
                    if (other.getId() != a.getId() && other.getCycleYear() == a.getCycleYear() && other.getSittingNo() == a.getSittingNo()) {
                        error = "You already logged " + exam.getShortName() + " " + a.getCycleYear() + " sitting " + a.getSittingNo() + " - edit that entry instead.";
                    }
                }
            }
            if (error != null) {
                session.setAttribute("error", error);
                session.setAttribute("formAttempt", a);
                response.sendRedirect("journal.jsp#log");
                return;
            }

            int rows;
            if (a.getId() > 0) {
                rows = attemptDAO.updateAttempt(a);
            } else {
                rows = attemptDAO.insertAttempt(a) > 0 ? 1 : 0;
                TrackingDAO trackingDAO = new TrackingDAO();
                if (rows > 0 && trackingDAO.getTracking(currentUser.getId(), a.getExamId()) == null) {
                    Tracking t = new Tracking();
                    t.setUserId(currentUser.getId());
                    t.setExamId(a.getExamId());
                    trackingDAO.trackExam(t);
                }
            }
            session.setAttribute(rows > 0 ? "success" : "error", rows > 0
                    ? (a.getId() > 0 ? "Attempt updated" : exam.getShortName() + " " + a.getCycleYear() + " added to your journal") + " (" + rows + " row affected)."
                    : "Nothing was saved - please try again.");
            break;
        }
        default:
            break;
    }
    response.sendRedirect("journal.jsp");
%>
