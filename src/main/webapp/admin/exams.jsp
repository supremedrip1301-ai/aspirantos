<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.*, java.net.URLEncoder, java.nio.charset.StandardCharsets, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.util.HtmlUtil, com.aspirantos.util.DateUtil, com.aspirantos.util.ValidationUtil" %>
<%--
    Exams (admin list page): every exam including deactivated ones, GET filters and pages,
    links to edit the exam and its rules, activate / deactivate buttons (POST to exam-action.jsp).
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%
    ExamFilter filter = new ExamFilter();
    filter.setQuery(ValidationUtil.clean(request.getParameter("q")));
    filter.setCategoryCode(ValidationUtil.clean(request.getParameter("category")));
    filter.setConfidence(ValidationUtil.clean(request.getParameter("confidence")));
    filter.setSort("category");
    filter.setIncludeInactive(true);
    filter.setPageSize(25);
    Integer pageNo = ValidationUtil.parseIntOrNull(request.getParameter("page"));
    filter.setPage(pageNo == null || pageNo < 1 ? 1 : pageNo);

    ExamDAO examDAO = new ExamDAO();
    int total = examDAO.countExams(filter);
    int pages = Math.max(1, (total + 24) / 25);
    if (filter.getPage() > pages) {
        filter.setPage(pages);
    }
    List<Exam> exams = examDAO.searchExams(filter);
    List<ExamCategory> categories = new CategoryDAO().getAllCategories();

    StringBuilder base = new StringBuilder();
    String[] keep = {"q", "category", "confidence"};
    for (String k : keep) {
        String v = request.getParameter(k);
        if (v != null && !v.trim().isEmpty()) {
            base.append("&amp;").append(k).append("=").append(URLEncoder.encode(v.trim(), StandardCharsets.UTF_8));
        }
    }
    String pageTitle = "Exams";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<div class="dash-head">
    <h1>Exams</h1>
    <a class="btn btn-primary" href="exam-form.jsp">Add an exam</a>
</div>
<%@ include file="/WEB-INF/jspf/flash.jspf" %>

<form class="card filters" action="exams.jsp" method="get" role="search">
    <div class="filter-grid">
        <div class="span-2">
            <label for="q">Search</label>
            <input type="search" id="q" name="q" value="<%= HtmlUtil.escape(filter.getQuery()) %>" maxlength="60" placeholder="Name, short name, code or body">
        </div>
        <div>
            <label for="category">Category</label>
            <select id="category" name="category">
                <option value="">All</option>
                <% for (ExamCategory c : categories) { %><option value="<%= c.getCode() %>" <%= HtmlUtil.selected(filter.getCategoryCode(), c.getCode()) %>><%= HtmlUtil.escape(c.getName()) %></option><% } %>
            </select>
        </div>
        <div>
            <label for="confidence">Data</label>
            <select id="confidence" name="confidence">
                <option value="">All</option>
                <option value="VERIFIED" <%= HtmlUtil.selected(filter.getConfidence(), "VERIFIED") %>>Verified</option>
                <option value="LIKELY" <%= HtmlUtil.selected(filter.getConfidence(), "LIKELY") %>>Likely</option>
                <option value="NEEDS_VERIFICATION" <%= HtmlUtil.selected(filter.getConfidence(), "NEEDS_VERIFICATION") %>>Needs verification</option>
            </select>
        </div>
    </div>
    <div class="filter-actions"><span class="muted small"><%= total %> exams</span><a class="btn" href="exams.jsp">Clear</a><button type="submit" class="btn btn-primary">Search</button></div>
</form>

<div class="table-wrap card">
<table>
    <thead><tr><th>Exam</th><th>Category</th><th>Data</th><th>Verified on</th><th>Rules</th><th>Status</th><th><span class="sr-only">Actions</span></th></tr></thead>
    <tbody>
    <% if (exams.isEmpty()) { %><tr><td colspan="7" class="empty">No exams match.</td></tr><% } %>
    <% for (Exam x : exams) { %>
    <tr class="<%= x.isActive() ? "" : "inactive-row" %>">
        <td><strong><%= HtmlUtil.escape(x.getShortName()) %></strong><br><span class="mono small muted"><%= HtmlUtil.escape(x.getCode()) %></span></td>
        <td class="small"><%= HtmlUtil.escape(x.getCategoryName()) %></td>
        <td><span class="badge-confidence conf-<%= x.getDataConfidence().toLowerCase() %>"><%= HtmlUtil.confidenceLabel(x.getDataConfidence()) %></span></td>
        <td class="small"><%= x.getLastVerifiedOn() == null ? "-" : DateUtil.format(x.getLastVerifiedOn()) %></td>
        <td><a href="rules.jsp?exam=<%= x.getId() %>"><%= x.getActiveRuleVersionId() == null ? "Create rules" : "Rules" %></a></td>
        <td><%= x.isActive() ? "Active" : "Inactive" %></td>
        <td class="actions">
            <a href="exam-form.jsp?id=<%= x.getId() %>">Edit</a>
            <a href="docs-events.jsp?exam=<%= x.getId() %>">Docs &amp; dates</a>
            <a href="../aspirant/exam-detail.jsp?id=<%= x.getId() %>">View</a>
            <form action="exam-action.jsp" method="post" class="inline">
                <input type="hidden" name="action" value="<%= x.isActive() ? "deactivate" : "activate" %>">
                <input type="hidden" name="id" value="<%= x.getId() %>">
                <button type="submit" class="link-button"<%= x.isActive() ? " data-confirm=\"Hide this exam from students? Their data stays.\"" : "" %>><%= x.isActive() ? "Deactivate" : "Activate" %></button>
            </form>
        </td>
    </tr>
    <% } %>
    </tbody>
</table>
</div>
<% if (pages > 1) { %>
<nav class="pager" aria-label="Pages">
    <% if (filter.getPage() > 1) { %><a class="btn btn-small" href="exams.jsp?page=<%= filter.getPage() - 1 %><%= base %>">Previous</a><% } %>
    <span>Page <%= filter.getPage() %> of <%= pages %></span>
    <% if (filter.getPage() < pages) { %><a class="btn btn-small" href="exams.jsp?page=<%= filter.getPage() + 1 %><%= base %>">Next</a><% } %>
</nav>
<% } %>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
