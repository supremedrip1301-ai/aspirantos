<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="error.jsp"%>
<%@ page import="com.aspirantos.dao.ExamDAO, com.aspirantos.dao.CategoryDAO, com.aspirantos.util.HtmlUtil" %>
<%--
    Landing page (reached from index.jsp through <jsp:forward>): the promise of the app, an
    instant UPSC check that works without an account (assets/js/instant-check.js asks
    instant-check.jsp for a JSON answer), the main features and the category tiles
    (a separate JSP inserted with <jsp:include> and a <jsp:param>).
--%>
<%@ include file="/WEB-INF/jspf/remember-me.jspf" %>
<%
    int[] counts = new ExamDAO().getConfidenceCounts();     // total, verified, likely, needs verification
    int categoryCount = new CategoryDAO().getAllCategories().size();
    String tagline = application.getInitParameter("appTagline");   // context-param from web.xml
    pageContext.setAttribute("examTotal", counts[0]);              // page scope: lives only while this page runs
    String pageTitle = "Home";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<section class="hero">
    <div class="hero-text">
        <p class="eyebrow">Exam eligibility &amp; attempt tracker</p>
        <h1><%= HtmlUtil.escape(tagline) %></h1>
        <p class="lead">Fill in your profile once - date of birth, category, education and the attempts you have used.
            AspirantOS checks <strong><%= pageContext.getAttribute("examTotal") %> exams</strong> in <%= categoryCount %> categories
            and tells you how many chances you have left and until which year, with every age relaxation applied.</p>
        <div class="hero-actions">
            <% if (headerUser == null) { %>
            <a class="btn btn-primary" href="register.jsp">Create your free account</a>
            <a class="btn" href="login.jsp">Log in</a>
            <% } else { %>
            <a class="btn btn-primary" href="<%= "ADMIN".equals(headerUser.getRole()) ? "admin/dashboard.jsp" : "aspirant/dashboard.jsp" %>">Open my dashboard</a>
            <% } %>
        </div>
        <p class="small muted"><%= counts[1] %> exams are checked against their latest official notice; the others are marked as not yet verified.</p>
    </div>

    <form class="card instant-check" id="instant-check" action="instant-check.jsp" method="get" data-instant-check novalidate>
        <h2>Try it now: UPSC Civil Services</h2>
        <div class="form-grid">
            <div>
                <label for="ic-dob">Date of birth</label>
                <input type="date" id="ic-dob" name="dob" required>
            </div>
            <div>
                <label for="ic-category">Category</label>
                <select id="ic-category" name="category">
                    <option value="GEN">General</option>
                    <option value="EWS">EWS</option>
                    <option value="OBC_NCL">OBC (non-creamy layer)</option>
                    <option value="SC">SC</option>
                    <option value="ST">ST</option>
                </select>
            </div>
            <div>
                <label for="ic-attempts">Attempts already used</label>
                <input type="number" id="ic-attempts" name="attempts" value="0" min="0" max="20">
            </div>
            <div class="check-cell">
                <label class="check"><input type="checkbox" name="pwbd" value="true"> Person with benchmark disability</label>
            </div>
        </div>
        <button type="submit" class="btn btn-primary btn-block">Check my UPSC chances</button>
        <div class="instant-result" id="ic-result" aria-live="polite"></div>
        <p class="hint">Assumes you are a graduate. Nothing is saved.</p>
    </form>
</section>

<section class="features" aria-label="What AspirantOS does">
    <article class="feature"><h3>Every relaxation applied</h3><p>OBC, SC/ST, PwBD, ex-servicemen, state domicile - the upper age is worked out for you, with the full breakdown.</p></article>
    <article class="feature"><h3>Attempts left, not guessed</h3><p>Each exam counts attempts its own way. Log your attempts and the count stays right.</p></article>
    <article class="feature"><h3>Your eligibility horizon</h3><p>See on one chart which exams you can sit in which year, and which ones close first.</p></article>
    <article class="feature"><h3>Rules that stay current</h3><p>When an exam changes its rules, a new version is published and your result is recalculated - you get a notification.</p></article>
    <article class="feature"><h3>Dates in your calendar</h3><p>Notification, last date and exam days of your exams - download them into Google Calendar or Outlook.</p></article>
    <article class="feature"><h3>Honest about the data</h3><p>Every exam shows whether its rules were verified from the official notice, and when.</p></article>
</section>

<jsp:include page="/WEB-INF/includes/category-grid.jsp">
    <jsp:param name="heading" value="Exams in every category"/>
</jsp:include>
<script src="<%= ctx %>/assets/js/instant-check.js"></script>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
