<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.List, java.util.ArrayList, java.time.LocalDate, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.engine.AgeCalculator, com.aspirantos.engine.RelaxationResolver, com.aspirantos.service.EligibilityService, com.aspirantos.util.HtmlUtil" %>
<%--
    Student dashboard (first version, Phase 5): profile summary and the eligibility of the
    tracked exams (read from the snapshot cache through EligibilityService).
    Phase 6 turns this page into the full "Eligibility Radar".
--%>
<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>
<%@ include file="/WEB-INF/jspf/aspirant-only.jspf" %>
<%
    Profile myProfile = new ProfileDAO().getProfile(currentUser.getId());
    EligibilityService eligibility = new EligibilityService();
    LocalDate today = eligibility.getToday();

    List<Exam> trackedExams = new ArrayList<>();
    List<EligibilitySnapshot> results = new ArrayList<>();
    if (myProfile != null) {
        ExamDAO examDAO = new ExamDAO();
        for (Tracking t : new TrackingDAO().getTrackingByUser(currentUser.getId())) {
            Exam x = examDAO.getExam(t.getExamId());
            if (x != null) {
                trackedExams.add(x);
            }
        }
        results = eligibility.getSnapshots(currentUser.getId(), trackedExams);
    }
    String pageTitle = "Dashboard";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<h1>Hello, <%= HtmlUtil.escape(currentUser.getFullName()) %></h1>
<%@ include file="/WEB-INF/jspf/flash.jspf" %>

<% if (myProfile == null) { %>
<section class="card cta">
    <h2>Fill in your profile once</h2>
    <p>Date of birth, category, education and the attempts you have used - then every exam shows exactly how many chances you have left.</p>
    <a class="btn btn-primary" href="profile-step1.jsp">Start my profile</a>
</section>
<% } else { %>
<div class="grid">
    <section class="card">
        <h2>Your profile</h2>
        <dl class="facts">
            <dt>Age today</dt><dd><%= AgeCalculator.describeAge(myProfile.getDob(), today) %></dd>
            <dt>Category</dt><dd><%= RelaxationResolver.categoryLabel(myProfile.getCategory()) %><%= myProfile.isPwbd() ? ", PwBD" : "" %><%= myProfile.isExServiceman() ? ", ex-serviceman" : "" %></dd>
            <dt>Profile complete</dt><dd><%= myProfile.getProfileCompletionPct() %>%</dd>
        </dl>
        <a class="btn btn-small" href="profile-step1.jsp">Edit profile</a>
    </section>

    <section class="card span-2">
        <h2>Tracked exams</h2>
        <% if (results.isEmpty()) { %>
        <p class="empty">You are not tracking any exam yet. Exams where you entered attempts in your profile appear here.</p>
        <% } else { %>
        <ul class="result-list">
        <% for (EligibilitySnapshot s : results) {
               String examName = "";
               for (Exam x : trackedExams) {
                   if (x.getId() == s.getExamId()) {
                       examName = x.getShortName();
                   }
               } %>
            <li>
                <span class="status-chip status-<%= s.getStatus().toLowerCase() %>"><%= s.getStatus().replace('_', ' ') %></span>
                <strong><%= HtmlUtil.escape(examName) %></strong>
                <span class="headline"><%= HtmlUtil.escape(s.getHeadline()) %></span>
            </li>
        <% } %>
        </ul>
        <% } %>
    </section>
</div>
<% } %>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
