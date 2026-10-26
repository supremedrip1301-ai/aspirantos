<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.*, com.aspirantos.model.InfoReport, com.aspirantos.dao.InfoReportDAO, com.aspirantos.util.HtmlUtil, com.aspirantos.util.DateUtil, com.aspirantos.util.ValidationUtil" %>
<%--
    "Outdated info" reports from students (admin inbox). Each report can be marked resolved or
    rejected with a reply; the student gets the reply as a notification.
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%
    String status = ValidationUtil.clean(request.getParameter("status"));
    if (status == null) {
        status = "OPEN";
    }
    List<InfoReport> reports = new InfoReportDAO().getAllReports("ALL".equals(status) ? null : status);
    String pageTitle = "Reports";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<h1>Reports from students</h1>
<%@ include file="/WEB-INF/jspf/flash.jspf" %>
<nav class="pill-nav" aria-label="Report status">
    <% String[][] tabs = {{"OPEN", "Open"}, {"RESOLVED", "Resolved"}, {"REJECTED", "Rejected"}, {"ALL", "All"}};
       for (String[] t : tabs) { %>
    <a href="reports.jsp?status=<%= t[0] %>" class="<%= t[0].equals(status) ? "active" : "" %>"><%= t[1] %></a>
    <% } %>
</nav>
<% if (reports.isEmpty()) { %>
<div class="card empty-state"><p>No reports here.</p></div>
<% } %>
<% for (InfoReport r : reports) { %>
<article class="card report-card">
    <header class="dash-head">
        <h2><a href="rules.jsp?exam=<%= r.getExamId() %>"><%= HtmlUtil.escape(r.getExamShortName()) %></a>
            <span class="muted small">from <%= HtmlUtil.escape(r.getUserName()) %>, <%= DateUtil.format(r.getCreatedAt()) %></span></h2>
        <span class="status-chip <%= "OPEN".equals(r.getStatus()) ? "status-provisional" : ("RESOLVED".equals(r.getStatus()) ? "status-eligible" : "status-unknown") %>"><%= r.getStatus() %></span>
    </header>
    <p><%= HtmlUtil.escape(r.getMessage()) %></p>
    <% if (r.getAdminReply() != null) { %><p class="small"><strong>Reply:</strong> <%= HtmlUtil.escape(r.getAdminReply()) %></p><% } %>
    <form action="report-action.jsp" method="post" class="reply-form" novalidate>
        <input type="hidden" name="id" value="<%= r.getId() %>">
        <input type="hidden" name="back" value="<%= HtmlUtil.escape(status) %>">
        <label for="reply-<%= r.getId() %>">Reply to the student</label>
        <textarea id="reply-<%= r.getId() %>" name="reply" rows="2" maxlength="1000"><%= HtmlUtil.escape(r.getAdminReply()) %></textarea>
        <div class="form-actions">
            <button type="submit" name="status" value="REJECTED" class="btn">Reject</button>
            <button type="submit" name="status" value="RESOLVED" class="btn btn-primary">Mark resolved</button>
        </div>
    </form>
</article>
<% } %>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
