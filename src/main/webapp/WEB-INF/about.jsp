<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="com.aspirantos.dao.ExamDAO, com.aspirantos.util.HtmlUtil" %>
<%--
    About / How it works. This JSP lives inside WEB-INF, so a browser can open it only through
    the URL /about, which web.xml maps to it with <servlet><jsp-file> - like a servlet.
    Its own init-params (appVersion, supportEmail) are read with config.getInitParameter(),
    the app name with application.getInitParameter() (context-param), and the number of
    visits since the server started is kept in the application scope (ServletContext).
--%>
<%!
    // declaration: runs once per JSP instance (the JSP becomes a servlet; jspInit is its init)
    public void jspInit() {
        getServletContext().log("About page loaded: " + getServletConfig().getServletName());
    }
%>
<%
    // application-wide visit counter (one value shared by every user and session)
    Integer visits;
    synchronized (application) {
        visits = (Integer) application.getAttribute("aboutVisits");
        visits = visits == null ? 1 : visits + 1;
        application.setAttribute("aboutVisits", visits);
    }
    application.log("About page served by " + page.getClass().getName() + ", visit " + visits);
    String version = config.getInitParameter("appVersion");
    String supportEmail = config.getInitParameter("supportEmail");
    int[] counts = new ExamDAO().getConfidenceCounts();
    String pageTitle = "How it works";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<h1>How <%= HtmlUtil.escape(appName) %> works</h1>
<p class="lead">One profile, checked against the rules of <%= counts[0] %> recurring exams in India: age limits with every relaxation, attempt limits, qualifications and other conditions.</p>

<section class="card">
    <h2>Three layers</h2>
    <svg class="arch-diagram" viewBox="0 0 900 230" role="img" aria-label="Browser, application server and database, connected left to right">
        <defs><marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5 0 10z" class="arch-arrowhead"/></marker></defs>
        <g class="arch-box"><rect x="10" y="30" width="240" height="170" rx="14"/>
            <text x="130" y="62" class="arch-title">Your browser</text>
            <text x="130" y="96">Pages in HTML and CSS</text><text x="130" y="122">Forms: search (GET),</text><text x="130" y="144">saving (POST)</text><text x="130" y="170">Small scripts (charts, tabs)</text></g>
        <g class="arch-box"><rect x="330" y="30" width="240" height="170" rx="14"/>
            <text x="450" y="62" class="arch-title">Apache Tomcat 11</text>
            <text x="450" y="96">Pages and form actions</text><text x="450" y="122">Eligibility engine (Java)</text><text x="450" y="144">Login session, cookies</text><text x="450" y="170">Data access classes</text></g>
        <g class="arch-box"><rect x="650" y="30" width="240" height="170" rx="14"/>
            <text x="770" y="62" class="arch-title">MySQL 8.4</text>
            <text x="770" y="96">26 tables, 6 views</text><text x="770" y="122">Stored procedures</text><text x="770" y="144">Triggers keep results fresh</text><text x="770" y="170">Rule versions + history</text></g>
        <line x1="252" y1="100" x2="326" y2="100" class="arch-line" marker-end="url(#arrow)"/>
        <line x1="328" y1="135" x2="254" y2="135" class="arch-line" marker-end="url(#arrow)"/>
        <line x1="572" y1="100" x2="646" y2="100" class="arch-line" marker-end="url(#arrow)"/>
        <line x1="648" y1="135" x2="574" y2="135" class="arch-line" marker-end="url(#arrow)"/>
        <text x="290" y="92" class="arch-small">request</text><text x="290" y="152" class="arch-small">page</text>
        <text x="610" y="92" class="arch-small">SQL</text><text x="610" y="152" class="arch-small">rows</text>
    </svg>
</section>

<section class="card">
    <h2>What happens when you save your profile</h2>
    <ol class="flow-list">
        <li>The form is sent with POST to the server, where every value is checked again (the checks in the browser only save time).</li>
        <li>The profile is saved with a prepared statement - values are never glued into SQL text.</li>
        <li>A database trigger deletes your old cached results, because they may no longer be right.</li>
        <li>The browser is redirected to the dashboard (post / redirect / get), so a refresh never saves twice.</li>
        <li>The dashboard asks the eligibility engine for every exam; the answers are cached for the day and the counters come from a stored procedure.</li>
    </ol>
</section>

<section class="card">
    <h2>When an exam changes its rules</h2>
    <p>The administrator checks the official page, copies the active rules into a draft, edits it and publishes it as a new version.
       The old version is kept in the history, every student who tracks the exam gets a notification and their results are recalculated.</p>
    <p class="small muted"><%= counts[1] %> of <%= counts[0] %> exams are currently verified from the official notice; the others say so on their page.
       Always confirm with the latest official notification before applying.</p>
</section>

<section class="card">
    <h2>The database</h2>
    <p class="small muted">Tables and their links (open the picture to zoom).</p>
    <a href="<%= ctx %>/assets/img/er-diagram.svg" target="_blank" rel="noopener"><img class="er-image" src="<%= ctx %>/assets/img/er-diagram.svg" alt="Entity relationship diagram of the AspirantOS database with its 26 tables" width="1620" height="1192" loading="lazy"></a>
</section>

<section class="card">
    <h2>About this project</h2>
    <dl class="facts">
        <dt>Version</dt><dd><%= HtmlUtil.escape(version) %></dd>
        <dt>Contact</dt><dd><a href="mailto:<%= HtmlUtil.escape(supportEmail) %>"><%= HtmlUtil.escape(supportEmail) %></a></dd>
        <dt>Built for</dt><dd>MCA, Advanced Internet Programming</dd>
        <dt>Page visits since the server started</dt><dd class="mono"><%= visits %></dd>
    </dl>
</section>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
