<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.*, com.aspirantos.dao.DbExplorerDAO, com.aspirantos.util.HtmlUtil, com.aspirantos.util.ValidationUtil" %>
<%--
    DB Explorer (admin, read only): pick a table or view, see its columns and 25 rows at a time
    with First / Previous / Next / Last and "go to row". app_setting values can be edited in place.
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%
    String table = request.getParameter("table");
    if (!DbExplorerDAO.isAllowed(table)) {
        table = "app_setting";
    }
    String move = request.getParameter("move");
    Integer at = ValidationUtil.parseIntOrNull(request.getParameter("at"));
    int pageSize = 25;
    DbExplorerDAO.Page p = new DbExplorerDAO().browse(table, move, at == null ? 1 : at, pageSize);
    int lastRow = p.firstRow == 0 ? 0 : p.firstRow + p.rows.size() - 1;
    boolean settings = "app_setting".equals(table);
    String link = "db-explorer.jsp?table=" + table + "&amp;at=" + p.firstRow + "&amp;move=";
    String pageTitle = "DB Explorer";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<h1>DB Explorer</h1>
<p class="muted">A read-only look into the database tables and views.</p>
<%@ include file="/WEB-INF/jspf/flash.jspf" %>

<form class="card filters inline-filter" action="db-explorer.jsp" method="get">
    <label for="table">Table or view</label>
    <div class="inline-row">
        <select id="table" name="table">
            <% for (String t : DbExplorerDAO.TABLES) { %><option value="<%= t %>" <%= HtmlUtil.selected(table, t) %>><%= t %><%= t.startsWith("v_") ? " (view)" : "" %></option><% } %>
        </select>
        <button type="submit" class="btn btn-primary">Show</button>
    </div>
</form>

<section class="card">
    <h2 class="mono"><%= HtmlUtil.escape(p.table) %></h2>
    <p class="small muted"><%= p.columnCount %> columns &middot; <%= p.totalRows %> rows<%= p.totalRows > 0 ? " &middot; showing rows " + p.firstRow + " to " + lastRow : "" %>
        <%= p.metaTableName != null && !p.metaTableName.isEmpty() && !p.metaTableName.equals(p.table) ? " &middot; based on table " + HtmlUtil.escape(p.metaTableName) : "" %></p>
    <details>
        <summary>Columns and types</summary>
        <ul class="column-list">
            <% for (int c = 0; c < p.columns.size(); c++) { %><li><span class="mono"><%= HtmlUtil.escape(p.columns.get(c)) %></span> <span class="muted small"><%= HtmlUtil.escape(p.types.get(c)) %></span></li><% } %>
        </ul>
    </details>

    <nav class="pager db-pager" aria-label="Rows">
        <a class="btn btn-small" href="<%= link %>first">First</a>
        <a class="btn btn-small" href="<%= link %>previous">Previous</a>
        <form action="db-explorer.jsp" method="get" class="inline">
            <input type="hidden" name="table" value="<%= table %>"><input type="hidden" name="move" value="goto">
            <label for="at" class="sr-only">Go to row</label>
            <input type="number" id="at" name="at" min="1" max="<%= Math.max(1, p.totalRows) %>" value="<%= Math.max(1, p.firstRow) %>" class="num">
            <button type="submit" class="btn btn-small">Go to row</button>
        </form>
        <a class="btn btn-small" href="<%= link %>next">Next</a>
        <a class="btn btn-small" href="<%= link %>last">Last</a>
    </nav>

    <div class="table-wrap db-table">
    <table>
        <thead><tr><th>#</th><% for (String c : p.columns) { %><th class="mono small"><%= HtmlUtil.escape(c) %></th><% } %><% if (settings) { %><th>Edit</th><% } %></tr></thead>
        <tbody>
        <% if (p.rows.isEmpty()) { %><tr><td colspan="<%= p.columnCount + 1 %>" class="empty">No rows.</td></tr><% } %>
        <% for (int r = 0; r < p.rows.size(); r++) {
               String[] row = p.rows.get(r); %>
        <tr>
            <td class="mono small muted"><%= p.firstRow + r %></td>
            <% for (String v : row) { %><td class="small"><%= v == null ? "<span class=\"muted\">NULL</span>" : HtmlUtil.escape(v) %></td><% } %>
            <% if (settings) { %>
            <td>
                <form action="db-explorer-action.jsp" method="post" class="inline-row">
                    <input type="hidden" name="key" value="<%= HtmlUtil.escape(row[0]) %>">
                    <label for="v-<%= r %>" class="sr-only">New value</label>
                    <input type="text" id="v-<%= r %>" name="value" value="<%= HtmlUtil.escape(row[1]) %>" maxlength="200" class="small-input">
                    <button type="submit" class="btn btn-small">Save</button>
                </form>
            </td>
            <% } %>
        </tr>
        <% } %>
        </tbody>
    </table>
    </div>
</section>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
