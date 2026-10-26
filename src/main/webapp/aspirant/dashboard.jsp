<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.*, java.time.LocalDate, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.engine.*, com.aspirantos.service.EligibilityService, com.aspirantos.util.HtmlUtil, com.aspirantos.util.DateUtil" %>
<%--
    Student dashboard - "Eligibility Radar".
      1. EligibilityService makes sure every exam has a fresh snapshot (cached per day),
      2. the four counters come from the stored procedure sp_user_dashboard_summary
         (CallableStatement in DashboardDAO),
      3. every tracked exam is shown as an "attempt ticket" with the engine's headline,
      4. alerts, upcoming dates of tracked exams and the latest notifications.
--%>
<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>
<%@ include file="/WEB-INF/jspf/aspirant-only.jspf" %>
<%!
    // declaration: the big line of an attempt ticket ("2 attempts left", "From 2030" ...)
    private String ticketBig(EligibilityResult r) {
        switch (r.getStatus()) {
            case "EXHAUSTED":
                return "Attempts used up";
            case "NOT_ELIGIBLE":
                return "Not eligible";
            case "NOT_YET":
                return r.getFirstEligibleYear() != null ? "From " + r.getFirstEligibleYear() : "Not yet";
            default:
                if (r.getNextRetestDate() != null) {
                    return "Retest " + DateUtil.format(r.getNextRetestDate());
                }
                if (r.getAttemptsRemaining() != null) {
                    return r.getAttemptsRemaining() + (r.getAttemptsRemaining() == 1 ? " attempt left" : " attempts left");
                }
                return "Unlimited attempts";
        }
    }
%>
<%
    int userId = currentUser.getId();
    Profile myProfile = new ProfileDAO().getProfile(userId);
    EligibilityService eligibility = new EligibilityService();
    LocalDate today = eligibility.getToday();
    ExamDAO examDAO = new ExamDAO();

    DashboardSummary summary = null;
    List<Exam> trackedExams = new ArrayList<>();
    Map<Integer, Tracking> trackingByExam = new HashMap<>();
    List<EligibilityResult> tracked = new ArrayList<>();
    List<String[]> alerts = new ArrayList<>();      // {css class, text}
    List<ExamEvent> upcoming = new ArrayList<>();
    if (myProfile != null) {
        eligibility.getSnapshots(userId, examDAO.getAllExams());     // 1. every exam has a result for today
        summary = new DashboardDAO().getSummary(userId);              // 2. counters (CallableStatement)

        for (Tracking t : new TrackingDAO().getTrackingByUser(userId)) {   // favourites first
            Exam x = examDAO.getExam(t.getExamId());
            if (x != null) {
                trackedExams.add(x);
                trackingByExam.put(x.getId(), t);
            }
        }
        tracked = eligibility.getResults(userId, trackedExams);      // 3. full results of the tracked exams

        Map<Integer, Exam> byId = new HashMap<>();
        for (Exam x : trackedExams) {
            byId.put(x.getId(), x);
        }
        for (EligibilityResult r : tracked) {                        // 4. alerts
            String name = byId.get(r.getExamId()).getShortName();
            if (r.isEligibleNow() && r.getDaysUntilAgeLimitCrossed() != null
                    && r.getDaysUntilAgeLimitCrossed() > 0 && r.getDaysUntilAgeLimitCrossed() <= 400) {
                alerts.add(new String[] {"alert-warn", name + ": you reach the upper age limit in " + r.getDaysUntilAgeLimitCrossed() + " days."});
            }
            if (r.isEligibleNow() && r.getLastEligibleYear() != null && r.getLastEligibleYear().equals(r.getNextCycleYear())) {
                alerts.add(new String[] {"alert-warn", name + ": the " + r.getNextCycleYear() + " cycle is your last chance."});
            }
            if (EligibilityResult.PROVISIONAL.equals(r.getStatus())) {
                alerts.add(new String[] {"alert-info", name + ": " + r.getHeadline()});
            }
        }
        if (myProfile.getProfileCompletionPct() < 60) {
            alerts.add(new String[] {"alert-info", "Your profile is " + myProfile.getProfileCompletionPct() + "% complete - add your education for more exact results."});
        }
        upcoming = new ExamEventDAO().getEventsForUser(userId, today, today.plusDays(120));
    }
    List<Notification> notes = new NotificationDAO().getNotificationsByUser(userId, 5);

    String pageTitle = "Dashboard";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<div class="dash-head">
    <h1>Hello, <%= HtmlUtil.escape(currentUser.getFullName()) %></h1>
    <p class="muted">Results for <span class="mono"><%= DateUtil.format(today) %></span></p>
</div>
<%@ include file="/WEB-INF/jspf/flash.jspf" %>

<% if (myProfile == null) { %>
<section class="card cta">
    <h2>Fill in your profile once</h2>
    <p>Date of birth, category, education and the attempts you have used - then every exam shows exactly how many chances you have left.</p>
    <a class="btn btn-primary" href="profile-step1.jsp">Start my profile</a>
</section>
<% } else { %>

<section class="counters" aria-label="Summary">
    <a class="counter c-eligible" href="exams.jsp?eligible=1"><span class="count" data-count="<%= summary.getEligibleNow() %>"><%= summary.getEligibleNow() %></span><span>Eligible now</span></a>
    <a class="counter c-provisional" href="exams.jsp?eligible=1"><span class="count" data-count="<%= summary.getProvisional() %>"><%= summary.getProvisional() %></span><span>Provisional</span></a>
    <div class="counter c-closing"><span class="count" data-count="<%= summary.getClosingSoon() %>"><%= summary.getClosingSoon() %></span><span>Closing within a year</span></div>
    <div class="counter c-not"><span class="count" data-count="<%= summary.getNotEligible() %>"><%= summary.getNotEligible() %></span><span>Not eligible</span></div>
</section>
<p class="muted small">Checked <%= summary.getExamsChecked() %> exams &middot; <%= summary.getNotYet() %> open to you later.</p>

<% if (!alerts.isEmpty()) { %>
<ul class="alert-strip" aria-label="Alerts">
    <% for (String[] a : alerts) { %><li class="<%= a[0] %>"><%= HtmlUtil.escape(a[1]) %></li><% } %>
</ul>
<% } %>

<h2 class="section-title">Your attempt tickets</h2>
<% if (tracked.isEmpty()) { %>
<div class="card empty-state">
    <p>You are not tracking any exam yet. Open an exam in <a href="exams.jsp">Explore exams</a> and press "Track this exam".</p>
</div>
<% } else { %>
<div class="ticket-grid">
<% for (EligibilityResult r : tracked) {
       Exam x = null;
       for (Exam e : trackedExams) {
           if (e.getId() == r.getExamId()) {
               x = e;
           }
       }
       Tracking t = trackingByExam.get(r.getExamId());
       Integer left = r.getAttemptsRemaining();
       int used = r.getAttemptsUsed() == null ? 0 : r.getAttemptsUsed();
       boolean showDots = left != null && used + left <= 12 && r.getNextRetestDate() == null; %>
    <article class="ticket <%= HtmlUtil.statusClass(r.getStatus()) %>">
        <header class="ticket-head">
            <a class="ticket-exam" href="exam-detail.jsp?id=<%= x.getId() %>"><%= HtmlUtil.escape(x.getShortName()) %></a>
            <span class="ticket-body"><%= HtmlUtil.escape(x.getBodyShortName()) %><%= t != null && t.isFavourite() ? " &#9733;" : "" %></span>
        </header>
        <div class="ticket-main">
            <span class="stamp <%= HtmlUtil.statusClass(r.getStatus()) %>"><%= HtmlUtil.statusLabel(r.getStatus()) %></span>
            <p class="ticket-big"><%= HtmlUtil.escape(ticketBig(r)) %></p>
            <% if (r.isEligibleNow()) { %>
            <p class="ticket-valid"><%= r.getLastEligibleYear() != null ? "valid until <b class=\"mono\">" + r.getLastEligibleYear() + "</b>" : "no end year" %></p>
            <% } %>
            <% if (showDots) { %>
            <p class="dots" aria-label="<%= used %> used, <%= left %> left">
                <% for (int i = 0; i < used + left; i++) { %><span class="<%= i < used ? "dot used" : "dot" %>"></span><% } %>
            </p>
            <% } %>
            <p class="ticket-headline"><%= HtmlUtil.escape(r.getHeadline()) %></p>
        </div>
        <footer class="ticket-foot">
            <a href="exam-detail.jsp?id=<%= x.getId() %>#mine">Why?</a>
            <a href="journal.jsp?exam=<%= x.getId() %>#log">Log attempt</a>
            <form action="track-action.jsp" method="post">
                <input type="hidden" name="examId" value="<%= x.getId() %>">
                <input type="hidden" name="action" value="favourite">
                <input type="hidden" name="back" value="dashboard">
                <button type="submit" class="link-button"><%= t != null && t.isFavourite() ? "Unpin" : "Pin" %></button>
            </form>
        </footer>
    </article>
<% } %>
</div>
<% } %>

<div class="grid dash-lower">
    <section class="card">
        <h2>Coming up</h2>
        <% if (upcoming.isEmpty()) { %>
        <p class="empty">No dates in the next four months for your tracked exams.</p>
        <% } else { %>
        <ul class="event-list">
            <% for (ExamEvent ev : upcoming) { %>
            <li><span class="mono"><%= DateUtil.format(ev.getEventDate()) %></span>
                <a href="exam-detail.jsp?id=<%= ev.getExamId() %>#calendar"><%= HtmlUtil.escape(ev.getExamShortName()) %></a>
                <span class="small"><%= ev.getEventType().replace('_', ' ').toLowerCase() %></span>
                <% if (ev.isTentative()) { %><span class="tag">tentative</span><% } %></li>
            <% } %>
        </ul>
        <% } %>
    </section>
    <section class="card">
        <h2>Notifications</h2>
        <% if (notes.isEmpty()) { %>
        <p class="empty">Nothing new. You will be told here when the rules of a tracked exam change.</p>
        <% } else { %>
        <ul class="note-list">
            <% for (Notification n : notes) { %>
            <li class="<%= n.isRead() ? "" : "unread" %>"><strong><%= HtmlUtil.escape(n.getTitle()) %></strong>
                <span class="small muted"><%= DateUtil.format(n.getCreatedAt()) %></span></li>
            <% } %>
        </ul>
        <a class="small" href="notifications.jsp">All notifications</a>
        <% } %>
    </section>
    <section class="card">
        <h2>Your profile</h2>
        <dl class="facts">
            <dt>Age today</dt><dd class="mono"><%= AgeCalculator.describeAge(myProfile.getDob(), today) %></dd>
            <dt>Category</dt><dd><%= RelaxationResolver.categoryLabel(myProfile.getCategory()) %><%= myProfile.isPwbd() ? ", PwBD" : "" %><%= myProfile.isExServiceman() ? ", ex-serviceman" : "" %></dd>
            <dt>Complete</dt><dd><%= myProfile.getProfileCompletionPct() %>%</dd>
        </dl>
        <a class="btn btn-small" href="profile-step1.jsp">Edit profile</a>
        <a class="btn btn-small" href="journal.jsp">Attempt journal</a>
    </section>
</div>
<% } %>
<script src="<%= ctx %>/assets/js/dashboard.js"></script>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
