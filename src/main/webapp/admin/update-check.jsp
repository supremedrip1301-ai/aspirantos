<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.*, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.service.UpdateCheckJob, com.aspirantos.util.HtmlUtil, com.aspirantos.util.DateUtil" %>
<%--
    Update checks (admin view page): "Check all exams" with a live progress bar and the latest
    results. A single exam is checked from its rules page.
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%
    List<UpdateCheck> checks = new UpdateCheckDAO().getRecentChecks(80);
    Map<Integer, String> names = new HashMap<>();
    for (Exam x : new ExamDAO().getAllExams()) {
        names.put(x.getId(), x.getShortName());
    }
    boolean running = UpdateCheckJob.isRunning();
    String pageTitle = "Update checks";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<h1>Update checks</h1>
<p class="muted">The app downloads each exam's official page, compares it with the last check and shows the lines around words like "age limit". Rules are never changed automatically - you decide and publish a new version.</p>
<%@ include file="/WEB-INF/jspf/flash.jspf" %>

<section class="card" id="check-all" data-progress-url="update-check-progress.jsp" data-running="<%= running %>">
    <h2>Check all exams</h2>
    <div class="progress" aria-live="polite">
        <div class="progress-bar"><span id="progress-fill" style="width: 0%"></span></div>
        <p id="progress-text" class="small muted"><%= running ? "Running..." : "Not running." %></p>
    </div>
    <div class="form-actions">
        <form action="update-check-action.jsp" method="post">
            <input type="hidden" name="action" value="stop">
            <button type="submit" class="btn" id="stop-button" <%= running ? "" : "disabled" %>>Stop</button>
        </form>
        <form action="update-check-action.jsp" method="post">
            <input type="hidden" name="action" value="checkAll">
            <button type="submit" class="btn btn-primary" <%= running ? "disabled" : "" %> data-confirm="Check the official pages of all active exams? This takes several minutes and needs the internet.">Check all exams</button>
        </form>
    </div>
</section>

<div class="table-wrap card">
<table>
    <thead><tr><th>When</th><th>Exam</th><th>Result</th><th>Page</th></tr></thead>
    <tbody>
    <% if (checks.isEmpty()) { %><tr><td colspan="4" class="empty">No check has been made yet.</td></tr><% } %>
    <% for (UpdateCheck c : checks) {
           String verdict = c.getErrorMessage() != null ? "Could not check"
                   : (c.getChangedSinceLast() == null ? "First check" : (c.getChangedSinceLast() ? "Changed" : "No change"));
           String css = c.getErrorMessage() != null ? "status-not_eligible" : (Boolean.TRUE.equals(c.getChangedSinceLast()) ? "status-provisional" : "status-eligible"); %>
    <tr>
        <td class="small mono"><%= DateUtil.format(c.getCheckedAt()) %></td>
        <td><a href="rules.jsp?exam=<%= c.getExamId() %>#updates"><%= HtmlUtil.escape(names.containsKey(c.getExamId()) ? names.get(c.getExamId()) : "exam " + c.getExamId()) %></a></td>
        <td><span class="status-chip <%= css %>"><%= verdict %></span><% if (c.getErrorMessage() != null) { %> <span class="small muted"><%= HtmlUtil.escape(c.getErrorMessage()) %></span><% } %></td>
        <td class="small"><a href="<%= HtmlUtil.escape(c.getUrlChecked()) %>" target="_blank" rel="noopener noreferrer"><%= HtmlUtil.escape(c.getUrlChecked().length() > 50 ? c.getUrlChecked().substring(0, 50) + "..." : c.getUrlChecked()) %></a></td>
    </tr>
    <% } %>
    </tbody>
</table>
</div>
<script src="<%= ctx %>/assets/js/update-progress.js"></script>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
