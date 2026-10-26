<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.*, com.aspirantos.model.AuditLog, com.aspirantos.dao.AuditDAO, com.aspirantos.util.HtmlUtil, com.aspirantos.util.DateUtil, com.aspirantos.util.ValidationUtil" %>
<%--
    Audit log (admin view page): the latest 500 entries (logins, profile saves, settings,
    rule publishing ...), with a GET filter by action.
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%
    String filterAction = ValidationUtil.clean(request.getParameter("action"));
    List<AuditLog> all = new AuditDAO().getRecent(500);
    Set<String> actions = new TreeSet<>();
    List<AuditLog> shown = new ArrayList<>();
    for (AuditLog a : all) {
        actions.add(a.getAction());
        if (filterAction == null || filterAction.equals(a.getAction())) {
            shown.add(a);
        }
    }
    String pageTitle = "Audit log";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<h1>Audit log</h1>
<form class="card filters inline-filter" action="audit.jsp" method="get">
    <label for="action">Show</label>
    <div class="inline-row">
        <select id="action" name="action">
            <option value="">All actions</option>
            <% for (String a : actions) { %><option value="<%= HtmlUtil.escape(a) %>" <%= HtmlUtil.selected(filterAction, a) %>><%= HtmlUtil.escape(a) %></option><% } %>
        </select>
        <button type="submit" class="btn">Filter</button>
    </div>
</form>
<div class="table-wrap card">
<table>
    <thead><tr><th>When</th><th>Action</th><th>User id</th><th>What</th><th>IP address</th></tr></thead>
    <tbody>
    <% if (shown.isEmpty()) { %><tr><td colspan="5" class="empty">No entries.</td></tr><% } %>
    <% for (AuditLog a : shown) { %>
    <tr>
        <td class="small mono"><%= DateUtil.format(a.getCreatedAt()) %></td>
        <td><%= HtmlUtil.escape(a.getAction()) %></td>
        <td><%= HtmlUtil.orDash(a.getUserId()) %></td>
        <td class="small"><%= HtmlUtil.escape(a.getEntity()) %> <%= HtmlUtil.escape(a.getEntityId()) %></td>
        <td class="small mono"><%= HtmlUtil.escape(a.getIpAddress()) %></td>
    </tr>
    <% } %>
    </tbody>
</table>
</div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
