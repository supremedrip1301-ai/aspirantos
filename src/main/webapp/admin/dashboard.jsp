<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.*, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.util.HtmlUtil, com.aspirantos.util.DateUtil" %>
<%--
    Admin dashboard (view page): counts, verification coverage, open reports, students by
    category / state / PwBD (stored procedure sp_category_report through CallableStatement),
    the latest audit entries and the "System information" card (DatabaseMetaData).
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%
    UserDAO userDAO = new UserDAO();
    int aspirants = userDAO.countUsersByRole("ASPIRANT");
    int[] confidence = new ExamDAO().getConfidenceCounts();   // total, verified, likely, needs verification
    int verifiedPct = confidence[0] == 0 ? 0 : Math.round(confidence[1] * 100f / confidence[0]);
    int openReports = new InfoReportDAO().countOpen();
    DashboardDAO dashboardDAO = new DashboardDAO();
    List<String[]> report = dashboardDAO.getCategoryReport();
    Map<String, String> system = dashboardDAO.getSystemInfo();
    List<AuditLog> recent = new AuditDAO().getRecent(8);
    java.time.LocalDate simDate = new SettingDAO().getSimulationDate();

    // group the report rows by dimension (CATEGORY, STATE, PWBD)
    Map<String, List<String[]>> byDimension = new LinkedHashMap<>();
    for (String[] row : report) {
        List<String[]> list = byDimension.get(row[0]);
        if (list == null) {
            list = new ArrayList<>();
            byDimension.put(row[0], list);
        }
        list.add(row);
    }
    String pageTitle = "Admin dashboard";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<h1>Admin dashboard</h1>
<%@ include file="/WEB-INF/jspf/flash.jspf" %>

<section class="counters" aria-label="Summary">
    <a class="counter c-eligible" href="users.jsp"><span class="count"><%= aspirants %></span><span>Registered students</span></a>
    <a class="counter c-closing" href="exams.jsp"><span class="count"><%= confidence[0] %></span><span>Active exams</span></a>
    <a class="counter c-provisional" href="exams.jsp?confidence=VERIFIED"><span class="count"><%= verifiedPct %>%</span><span><%= confidence[1] %> verified from official notices</span></a>
    <a class="counter c-not" href="reports.jsp"><span class="count"><%= openReports %></span><span>Open "outdated info" reports</span></a>
</section>
<nav class="card tool-links" aria-label="Admin tools">
    <a href="update-check.jsp">Update checks</a>
    <a href="rule-pack.jsp">Rule pack (CSV)</a>
    <a href="reports.jsp">Reports from students</a>
    <a href="db-explorer.jsp">DB Explorer</a>
    <a href="audit.jsp">Audit log</a>
</nav>
<p class="muted small">Likely: <%= confidence[2] %> &middot; Needs verification: <%= confidence[3] %> &middot;
    Simulation date: <%= simDate == null ? "off (real date)" : DateUtil.format(simDate) %> - <a href="settings.jsp">change</a></p>

<div class="grid dash-lower">
    <section class="card">
        <h2>Students</h2>
        <% if (byDimension.isEmpty()) { %>
        <p class="empty">No student has filled a profile yet.</p>
        <% } %>
        <% for (Map.Entry<String, List<String[]>> e : byDimension.entrySet()) { %>
        <h3 class="small-heading"><%= "PWBD".equals(e.getKey()) ? "PwBD" : e.getKey().charAt(0) + e.getKey().substring(1).toLowerCase() %></h3>
        <ul class="bar-list">
            <% for (String[] row : e.getValue()) {
                   int n = Integer.parseInt(row[2]);
                   int width = aspirants == 0 ? 0 : Math.max(4, n * 100 / Math.max(1, aspirants)); %>
            <li><span class="bar-label"><%= HtmlUtil.escape("OBC_NCL".equals(row[1]) ? "OBC-NCL" : row[1]) %></span>
                <span class="bar"><span style="width: <%= width %>%"></span></span><span class="mono"><%= n %></span></li>
            <% } %>
        </ul>
        <% } %>
    </section>

    <section class="card">
        <h2>Recent activity</h2>
        <% if (recent.isEmpty()) { %><p class="empty">Nothing logged yet.</p><% } else { %>
        <ul class="note-list">
            <% for (AuditLog a : recent) { %>
            <li><span><strong><%= HtmlUtil.escape(a.getAction()) %></strong> <span class="muted small"><%= HtmlUtil.escape(a.getEntity()) %> <%= HtmlUtil.escape(a.getEntityId()) %></span></span>
                <span class="small muted"><%= DateUtil.format(a.getCreatedAt()) %></span></li>
            <% } %>
        </ul>
        <a class="small" href="audit.jsp">Full audit log</a>
        <% } %>
    </section>

    <section class="card">
        <h2>System information</h2>
        <dl class="facts">
            <% for (Map.Entry<String, String> e : system.entrySet()) { %>
            <dt><%= HtmlUtil.escape(e.getKey()) %></dt><dd class="small"><%= HtmlUtil.escape(e.getValue()) %></dd>
            <% } %>
            <dt>Server</dt><dd class="small"><%= HtmlUtil.escape(application.getServerInfo()) %></dd>
            <dt>Java</dt><dd class="small"><%= HtmlUtil.escape(System.getProperty("java.version")) %></dd>
        </dl>
    </section>
</div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
