<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.*, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.engine.RelaxationResolver, com.aspirantos.util.HtmlUtil, com.aspirantos.util.DateUtil, com.aspirantos.util.ValidationUtil" %>
<%--
    Users (admin view page): every account with a GET search, block / unblock buttons and a
    read-only view of one student's profile (?view=<id>). The admin cannot edit student data.
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%
    String q = ValidationUtil.clean(request.getParameter("q"));
    List<User> users = new ArrayList<>();
    for (User u : new UserDAO().getAllUsers()) {
        if (q == null || u.getFullName().toLowerCase().contains(q.toLowerCase())
                || u.getEmail().toLowerCase().contains(q.toLowerCase())) {
            users.add(u);
        }
    }
    // read-only profile of one student
    Integer viewId = ValidationUtil.parseIntOrNull(request.getParameter("view"));
    User viewed = viewId == null ? null : new UserDAO().getUser(viewId);
    Profile viewedProfile = viewed == null ? null : new ProfileDAO().getProfile(viewed.getId());
    List<Education> viewedEducation = viewed == null ? new ArrayList<Education>() : new EducationDAO().getEducationByUser(viewed.getId());
    int viewedTracked = viewed == null ? 0 : new TrackingDAO().getTrackingByUser(viewed.getId()).size();
    int viewedAttempts = viewed == null ? 0 : new AttemptDAO().getAttemptsByUser(viewed.getId()).size();
    String pageTitle = "Users";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<h1>Users</h1>
<%@ include file="/WEB-INF/jspf/flash.jspf" %>

<% if (viewed != null) { %>
<section class="card">
    <h2><%= HtmlUtil.escape(viewed.getFullName()) %> <span class="muted small"><%= HtmlUtil.escape(viewed.getEmail()) %></span></h2>
    <% if (viewedProfile == null) { %>
    <p class="empty">This user has not filled a profile yet.</p>
    <% } else { %>
    <dl class="facts">
        <dt>Date of birth</dt><dd><%= DateUtil.format(viewedProfile.getDob()) %></dd>
        <dt>Category</dt><dd><%= RelaxationResolver.categoryLabel(viewedProfile.getCategory()) %><%= viewedProfile.isPwbd() ? ", PwBD " + HtmlUtil.orDash(viewedProfile.getPwbdPercent()) + "%" : "" %><%= viewedProfile.isExServiceman() ? ", ex-serviceman" : "" %></dd>
        <dt>Domicile</dt><dd><%= HtmlUtil.orDash(viewedProfile.getDomicileStateCode()) %></dd>
        <dt>Education rows</dt><dd><%= viewedEducation.size() %></dd>
        <dt>Tracked exams</dt><dd><%= viewedTracked %></dd>
        <dt>Logged attempts</dt><dd><%= viewedAttempts %></dd>
        <dt>Profile complete</dt><dd><%= viewedProfile.getProfileCompletionPct() %>%</dd>
    </dl>
    <% } %>
    <a class="btn btn-small" href="users.jsp">Close</a>
</section>
<% } %>

<form class="card filters inline-filter" action="users.jsp" method="get" role="search">
    <label for="q">Search by name or e-mail</label>
    <div class="inline-row">
        <input type="search" id="q" name="q" value="<%= HtmlUtil.escape(q) %>" maxlength="100">
        <button type="submit" class="btn">Search</button>
    </div>
</form>

<div class="table-wrap card">
<table>
    <thead><tr><th>Name</th><th>E-mail</th><th>Role</th><th>Status</th><th>Joined</th><th>Last login</th><th><span class="sr-only">Actions</span></th></tr></thead>
    <tbody>
    <% if (users.isEmpty()) { %><tr><td colspan="7" class="empty">No users found.</td></tr><% } %>
    <% for (User u : users) { %>
    <tr>
        <td><%= HtmlUtil.escape(u.getFullName()) %></td>
        <td><%= HtmlUtil.escape(u.getEmail()) %></td>
        <td><%= "ADMIN".equals(u.getRole()) ? "Admin" : "Student" %></td>
        <td><span class="status-chip <%= "ACTIVE".equals(u.getStatus()) ? "status-eligible" : "status-not_eligible" %>"><%= "ACTIVE".equals(u.getStatus()) ? "Active" : "Blocked" %></span></td>
        <td class="small"><%= u.getCreatedAt() == null ? "-" : DateUtil.format(u.getCreatedAt().toLocalDate()) %></td>
        <td class="small"><%= u.getLastLoginAt() == null ? "never" : DateUtil.format(u.getLastLoginAt()) %></td>
        <td class="actions">
            <% if (!"ADMIN".equals(u.getRole())) { %>
            <a href="users.jsp?view=<%= u.getId() %>">View</a>
            <form action="user-action.jsp" method="post" class="inline">
                <input type="hidden" name="id" value="<%= u.getId() %>">
                <input type="hidden" name="action" value="<%= "ACTIVE".equals(u.getStatus()) ? "block" : "unblock" %>">
                <button type="submit" class="link-button"<%= "ACTIVE".equals(u.getStatus()) ? " data-confirm=\"Block this account? The student cannot log in until you unblock it.\"" : "" %>><%= "ACTIVE".equals(u.getStatus()) ? "Block" : "Unblock" %></button>
            </form>
            <% } %>
        </td>
    </tr>
    <% } %>
    </tbody>
</table>
</div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
