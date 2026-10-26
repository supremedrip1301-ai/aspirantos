<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.List, com.aspirantos.model.Notification, com.aspirantos.dao.NotificationDAO, com.aspirantos.util.HtmlUtil, com.aspirantos.util.DateUtil" %>
<%--
    Notifications (view page): messages written by the database when the rules of a tracked
    exam are published again (sp_activate_rule_version). Mark one / all as read via
    notification-action.jsp.
--%>
<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>
<%
    List<Notification> notes = new NotificationDAO().getNotificationsByUser(currentUser.getId(), 100);
    String pageTitle = "Notifications";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<div class="dash-head">
    <h1>Notifications</h1>
    <% if (unreadCount > 0) { %>
    <form action="notification-action.jsp" method="post">
        <input type="hidden" name="action" value="readAll">
        <button type="submit" class="btn btn-small">Mark all as read</button>
    </form>
    <% } %>
</div>
<%@ include file="/WEB-INF/jspf/flash.jspf" %>
<% if (notes.isEmpty()) { %>
<div class="card empty-state">
    <h2>No notifications yet</h2>
    <p>When the eligibility rules of an exam you track are updated, you will see it here and your results are recalculated.</p>
</div>
<% } else { %>
<ul class="card note-list full">
    <% for (Notification n : notes) { %>
    <li class="<%= n.isRead() ? "" : "unread" %>">
        <div>
            <strong><%= HtmlUtil.escape(n.getTitle()) %></strong>
            <span class="small muted"><%= DateUtil.format(n.getCreatedAt()) %></span>
            <p><%= HtmlUtil.escape(n.getMessage()) %></p>
            <%-- links written by the database are paths inside the app, e.g. aspirant/exam-detail.jsp?id=1 --%>
            <% if (n.getLinkUrl() != null && !n.getLinkUrl().contains(":") && !n.getLinkUrl().startsWith("//")) { %>
            <a class="small" href="<%= ctx %>/<%= HtmlUtil.escape(n.getLinkUrl().startsWith("/") ? n.getLinkUrl().substring(1) : n.getLinkUrl()) %>">Open</a><% } %>
        </div>
        <% if (!n.isRead()) { %>
        <form action="notification-action.jsp" method="post">
            <input type="hidden" name="action" value="read">
            <input type="hidden" name="id" value="<%= n.getId() %>">
            <button type="submit" class="link-button">Mark as read</button>
        </form>
        <% } %>
    </li>
    <% } %>
</ul>
<% } %>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
