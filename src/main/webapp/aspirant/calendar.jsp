<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.*, java.time.LocalDate, java.time.YearMonth, java.time.format.DateTimeFormatter, java.util.Locale, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.util.HtmlUtil, com.aspirantos.util.DateUtil, com.aspirantos.util.IcsUtil" %>
<%--
    Exam calendar (view page): a month grid with the dates of the tracked exams
    (?month=2027-05, GET so the month can be bookmarked), the list of the month's dates and
    downloads for Google Calendar / Outlook (.ics from calendar-ics.jsp).
--%>
<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>
<%@ include file="/WEB-INF/jspf/aspirant-only.jspf" %>
<%
    LocalDate today = new SettingDAO().getToday();
    YearMonth month;
    try {
        month = request.getParameter("month") == null ? YearMonth.from(today) : YearMonth.parse(request.getParameter("month"));
    } catch (Exception e) {
        month = YearMonth.from(today);
    }
    if (month.getYear() < 2000 || month.getYear() > 2100) {
        month = YearMonth.from(today);
    }
    LocalDate first = month.atDay(1);
    LocalDate last = month.atEndOfMonth();
    List<ExamEvent> events = new ExamEventDAO().getEventsForUser(currentUser.getId(), first, last);
    Map<Integer, List<ExamEvent>> byDay = new HashMap<>();
    for (ExamEvent ev : events) {
        List<ExamEvent> list = byDay.get(ev.getEventDate().getDayOfMonth());
        if (list == null) {
            list = new ArrayList<>();
            byDay.put(ev.getEventDate().getDayOfMonth(), list);
        }
        list.add(ev);
    }
    int tracked = new TrackingDAO().getTrackingByUser(currentUser.getId()).size();
    int blanks = first.getDayOfWeek().getValue() - 1;   // Monday = 1, so blanks before the 1st
    String title = month.format(DateTimeFormatter.ofPattern("MMMM yyyy", Locale.ENGLISH));
    String pageTitle = "Calendar";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<div class="dash-head">
    <h1>Exam calendar</h1>
    <a class="btn btn-small" href="calendar-ics.jsp?all=1">Download all my dates (next 12 months, .ics)</a>
</div>
<%@ include file="/WEB-INF/jspf/flash.jspf" %>
<% if (tracked == 0) { %>
<p class="flash flash-info">The calendar shows the dates of the exams you track - track exams in <a href="exams.jsp">Explore exams</a>.</p>
<% } %>

<section class="card">
    <nav class="month-nav" aria-label="Month">
        <a class="btn btn-small" href="calendar.jsp?month=<%= month.minusMonths(1) %>" rel="prev">&larr; <%= month.minusMonths(1).format(DateTimeFormatter.ofPattern("MMM", Locale.ENGLISH)) %></a>
        <h2><%= title %></h2>
        <a class="btn btn-small" href="calendar.jsp?month=<%= month.plusMonths(1) %>" rel="next"><%= month.plusMonths(1).format(DateTimeFormatter.ofPattern("MMM", Locale.ENGLISH)) %> &rarr;</a>
    </nav>
    <div class="month-grid" role="grid" aria-label="<%= title %>">
        <% String[] days = {"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"};
           for (String d : days) { %><div class="dow" role="columnheader"><%= d %></div><% } %>
        <% for (int b = 0; b < blanks; b++) { %><div class="day empty-day"></div><% } %>
        <% for (int d = 1; d <= month.lengthOfMonth(); d++) {
               LocalDate date = month.atDay(d);
               List<ExamEvent> list = byDay.get(d); %>
        <div class="day<%= date.equals(today) ? " today" : "" %><%= list != null ? " has-events" : "" %>" role="gridcell">
            <span class="day-no"><%= d %></span>
            <% if (list != null) { for (ExamEvent ev : list) { %>
            <a class="day-event<%= ev.isTentative() ? " tentative" : "" %>" href="exam-detail.jsp?id=<%= ev.getExamId() %>#calendar" title="<%= HtmlUtil.escape(ev.getExamShortName() + ": " + IcsUtil.eventLabel(ev.getEventType())) %>"><%= HtmlUtil.escape(ev.getExamShortName()) %></a>
            <% } } %>
        </div>
        <% } %>
    </div>
</section>

<section class="card">
    <h2>Dates in <%= title %></h2>
    <% if (events.isEmpty()) { %>
    <p class="empty">No dates of your tracked exams in this month.</p>
    <% } else { %>
    <ul class="event-list">
        <% for (ExamEvent ev : events) { %>
        <li class="<%= ev.getEventDate().isBefore(today) ? "past" : "" %>">
            <span class="mono"><%= DateUtil.format(ev.getEventDate()) %></span>
            <a href="exam-detail.jsp?id=<%= ev.getExamId() %>#calendar"><%= HtmlUtil.escape(ev.getExamShortName()) %></a>
            <span><%= IcsUtil.eventLabel(ev.getEventType()) %></span>
            <span class="tag <%= ev.isTentative() ? "" : "tag-official" %>"><%= ev.isTentative() ? "tentative" : "official" %></span>
            <a class="small" href="calendar-ics.jsp?id=<%= ev.getId() %>">Add to my calendar</a>
        </li>
        <% } %>
    </ul>
    <% } %>
    <p class="hint">Tentative dates are estimated from the usual month of the exam. A downloaded .ics file can be imported into Google Calendar, Outlook or a phone calendar.</p>
</section>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
