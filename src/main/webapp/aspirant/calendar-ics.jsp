<%@ page language="java" contentType="text/calendar; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.*, java.time.LocalDate, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.util.IcsUtil, com.aspirantos.util.ValidationUtil" %>
<%--
    Calendar download (.ics): a JSP whose response is not HTML but text/calendar, with a
    Content-Disposition header so the browser saves the file.
      ?id=<event id>   one date
      ?exam=<exam id>  every coming date of one exam
      ?all=1           every date of the tracked exams in the next 12 months
--%>
<%
    User who = (User) session.getAttribute("user");
    if (who == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    ExamEventDAO eventDAO = new ExamEventDAO();
    LocalDate today = new SettingDAO().getToday();
    List<ExamEvent> events = new ArrayList<>();
    String file = "aspirantos-dates";
    Integer id = ValidationUtil.parseIntOrNull(request.getParameter("id"));
    Integer examId = ValidationUtil.parseIntOrNull(request.getParameter("exam"));
    if (id != null) {
        ExamEvent ev = eventDAO.getEvent(id);
        if (ev != null) {
            for (ExamEvent e : eventDAO.getEventsByExam(ev.getExamId())) {   // read with the exam name
                if (e.getId() == ev.getId()) {
                    events.add(e);
                }
            }
            file = "aspirantos-date-" + id;
        }
    } else if (examId != null) {
        for (ExamEvent e : eventDAO.getEventsByExam(examId)) {
            if (!e.getEventDate().isBefore(today)) {
                events.add(e);
                file = "aspirantos-" + e.getExamCode().toLowerCase();
            }
        }
    } else {
        events = eventDAO.getEventsForUser(who.getId(), today, today.plusMonths(12));
        file = "aspirantos-my-exam-dates";
    }
    response.setHeader("Content-Disposition", "attachment; filename=\"" + file.replaceAll("[^a-z0-9_-]", "") + ".ics\"");
    out.print(IcsUtil.calendar(events));
%>
