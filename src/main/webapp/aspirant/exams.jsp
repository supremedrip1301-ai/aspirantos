<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.*, java.net.URLEncoder, java.nio.charset.StandardCharsets, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.service.EligibilityService, com.aspirantos.util.HtmlUtil, com.aspirantos.util.DateUtil, com.aspirantos.util.ValidationUtil" %>
<%--
    Exam Explorer (view page). The filter form uses GET (Worksheet 1): every filter is visible in
    the URL, so a result page can be bookmarked or shared. ExamDAO builds the WHERE clause with
    "?" placeholders only. Each card shows the student's own status from the snapshot cache.
--%>
<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>
<%!
    // declaration: query string of the current filters, used by the pagination links
    private String filterQuery(HttpServletRequest req, String... names) {
        StringBuilder sb = new StringBuilder();
        for (String n : names) {
            String v = req.getParameter(n);
            if (v != null && !v.trim().isEmpty()) {
                sb.append(sb.length() == 0 ? "" : "&").append(n).append("=")
                  .append(URLEncoder.encode(v.trim(), StandardCharsets.UTF_8));
            }
        }
        return sb.toString();
    }
%>
<%
    int pageSize = 12;
    try {
        pageSize = Integer.parseInt(application.getInitParameter("examsPageSize"));   // context-param in web.xml
    } catch (NumberFormatException e) {
        pageSize = 12;
    }
    Integer pageNo = ValidationUtil.parseIntOrNull(request.getParameter("page"));

    ExamFilter filter = new ExamFilter();
    filter.setQuery(ValidationUtil.clean(request.getParameter("q")));
    filter.setCategoryCode(ValidationUtil.clean(request.getParameter("category")));
    filter.setSector(ValidationUtil.clean(request.getParameter("sector")));
    filter.setPurpose(ValidationUtil.clean(request.getParameter("purpose")));
    filter.setScope(ValidationUtil.clean(request.getParameter("scope")));
    filter.setStateCode(ValidationUtil.clean(request.getParameter("state")));
    filter.setConfidence(ValidationUtil.clean(request.getParameter("confidence")));
    filter.setSort(ValidationUtil.clean(request.getParameter("sort")));
    filter.setPageSize(pageSize);
    filter.setPage(pageNo == null || pageNo < 1 ? 1 : pageNo);
    if (filter.getQuery() != null && filter.getQuery().length() > 60) {
        filter.setQuery(filter.getQuery().substring(0, 60));
    }

    boolean isStudent = !"ADMIN".equals(currentUser.getRole());
    boolean hasProfile = isStudent && new ProfileDAO().getProfile(currentUser.getId()) != null;
    boolean eligibleOnly = hasProfile && "1".equals(request.getParameter("eligible"));
    ExamDAO examDAO = new ExamDAO();
    EligibilityService eligibility = new EligibilityService();
    if (eligibleOnly) {
        eligibility.getSnapshots(currentUser.getId(), examDAO.getAllExams());   // make sure every exam has a result
        filter.setEligibleForUserId(currentUser.getId());
    }

    int total = examDAO.countExams(filter);
    int pages = Math.max(1, (total + pageSize - 1) / pageSize);
    if (filter.getPage() > pages) {
        filter.setPage(pages);
    }
    List<Exam> exams = examDAO.searchExams(filter);

    Map<Integer, EligibilitySnapshot> mine = new HashMap<>();
    if (hasProfile) {
        for (EligibilitySnapshot s : eligibility.getSnapshots(currentUser.getId(), exams)) {
            mine.put(s.getExamId(), s);
        }
    }
    List<ExamCategory> categories = new CategoryDAO().getAllCategories();
    List<State> states = new StateDAO().getAllStates();
    String base = filterQuery(request, "q", "category", "sector", "purpose", "scope", "state", "confidence", "sort", "eligible")
            .replace("&", "&amp;");   // & must be written as &amp; inside an HTML attribute

    String pageTitle = "Explore exams";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<h1>Explore exams</h1>
<p class="muted"><%= total %> exam<%= total == 1 ? "" : "s" %> found. Rules are checked against your profile.</p>
<%@ include file="/WEB-INF/jspf/flash.jspf" %>

<form class="card filters" action="exams.jsp" method="get" role="search">
    <div class="filter-grid">
        <div class="span-2">
            <label for="q">Search</label>
            <input type="search" id="q" name="q" value="<%= HtmlUtil.escape(filter.getQuery()) %>" maxlength="60" placeholder="Exam name, short name or body - e.g. UPSC, CGL, NEET">
        </div>
        <div>
            <label for="category">Category</label>
            <select id="category" name="category">
                <option value="">All categories</option>
                <% for (ExamCategory c : categories) { %>
                <option value="<%= c.getCode() %>" <%= HtmlUtil.selected(filter.getCategoryCode(), c.getCode()) %>><%= HtmlUtil.escape(c.getName()) %> (<%= c.getExamCount() %>)</option>
                <% } %>
            </select>
        </div>
        <div>
            <label for="purpose">Purpose</label>
            <select id="purpose" name="purpose">
                <option value="">Any</option>
                <option value="RECRUITMENT" <%= HtmlUtil.selected(filter.getPurpose(), "RECRUITMENT") %>>Job / recruitment</option>
                <option value="ADMISSION" <%= HtmlUtil.selected(filter.getPurpose(), "ADMISSION") %>>Admission</option>
                <option value="CERTIFICATION" <%= HtmlUtil.selected(filter.getPurpose(), "CERTIFICATION") %>>Certification</option>
                <option value="LICENSING" <%= HtmlUtil.selected(filter.getPurpose(), "LICENSING") %>>Licensing</option>
                <option value="FELLOWSHIP" <%= HtmlUtil.selected(filter.getPurpose(), "FELLOWSHIP") %>>Fellowship</option>
                <option value="SCHOLARSHIP" <%= HtmlUtil.selected(filter.getPurpose(), "SCHOLARSHIP") %>>Scholarship</option>
            </select>
        </div>
        <div>
            <label for="sector">Sector</label>
            <select id="sector" name="sector">
                <option value="">Any</option>
                <option value="GOVERNMENT" <%= HtmlUtil.selected(filter.getSector(), "GOVERNMENT") %>>Government</option>
                <option value="AUTONOMOUS" <%= HtmlUtil.selected(filter.getSector(), "AUTONOMOUS") %>>Autonomous</option>
                <option value="PRIVATE" <%= HtmlUtil.selected(filter.getSector(), "PRIVATE") %>>Private</option>
            </select>
        </div>
        <div>
            <label for="scope">Level</label>
            <select id="scope" name="scope">
                <option value="">Any</option>
                <option value="NATIONAL" <%= HtmlUtil.selected(filter.getScope(), "NATIONAL") %>>National</option>
                <option value="STATE" <%= HtmlUtil.selected(filter.getScope(), "STATE") %>>State</option>
                <option value="INTERNATIONAL" <%= HtmlUtil.selected(filter.getScope(), "INTERNATIONAL") %>>International</option>
            </select>
        </div>
        <div>
            <label for="state">State</label>
            <select id="state" name="state">
                <option value="">Any state</option>
                <% for (State s : states) { %>
                <option value="<%= s.getCode() %>" <%= HtmlUtil.selected(filter.getStateCode(), s.getCode()) %>><%= HtmlUtil.escape(s.getName()) %></option>
                <% } %>
            </select>
        </div>
        <div>
            <label for="confidence">Data</label>
            <select id="confidence" name="confidence">
                <option value="">All</option>
                <option value="VERIFIED" <%= HtmlUtil.selected(filter.getConfidence(), "VERIFIED") %>>Verified from official notice</option>
                <option value="LIKELY" <%= HtmlUtil.selected(filter.getConfidence(), "LIKELY") %>>Likely</option>
                <option value="NEEDS_VERIFICATION" <%= HtmlUtil.selected(filter.getConfidence(), "NEEDS_VERIFICATION") %>>Needs verification</option>
            </select>
        </div>
        <div>
            <label for="sort">Sort by</label>
            <select id="sort" name="sort">
                <option value="name" <%= HtmlUtil.selected(filter.getSort(), "name") %>>Name</option>
                <option value="category" <%= HtmlUtil.selected(filter.getSort(), "category") %>>Category</option>
                <option value="month" <%= HtmlUtil.selected(filter.getSort(), "month") %>>Exam month</option>
                <option value="confidence" <%= HtmlUtil.selected(filter.getSort(), "confidence") %>>Verified first</option>
            </select>
        </div>
    </div>
    <div class="filter-actions">
        <% if (hasProfile) { %>
        <label class="check"><input type="checkbox" name="eligible" value="1" <%= HtmlUtil.checked(eligibleOnly) %>> Only exams I am eligible for</label>
        <% } %>
        <a class="btn" href="exams.jsp">Clear</a>
        <button type="submit" class="btn btn-primary">Search</button>
    </div>
</form>

<% if (isStudent && !hasProfile) { %>
<p class="flash flash-info">Fill in <a href="profile-step1.jsp">your profile</a> to see your status on every exam.</p>
<% } %>

<% if (exams.isEmpty()) { %>
<div class="card empty-state">
    <h2>No exams match these filters</h2>
    <p>Try a shorter search word or <a href="exams.jsp">clear the filters</a>.</p>
</div>
<% } else { %>
<div class="exam-grid">
    <% for (Exam x : exams) {
           EligibilitySnapshot s = mine.get(x.getId()); %>
    <article class="card exam-card">
        <header>
            <span class="body-tag"><%= HtmlUtil.escape(x.getBodyShortName()) %></span>
            <span class="badge-confidence conf-<%= x.getDataConfidence().toLowerCase() %>"><%= HtmlUtil.confidenceLabel(x.getDataConfidence()) %></span>
        </header>
        <h2><a href="exam-detail.jsp?id=<%= x.getId() %>"><%= HtmlUtil.escape(x.getShortName()) %></a></h2>
        <p class="exam-name"><%= HtmlUtil.escape(x.getName()) %></p>
        <p class="meta"><%= HtmlUtil.escape(x.getCategoryName()) %>
            <% if (x.getStateCode() != null) { %> &middot; <%= x.getStateCode() %><% } %>
            <% if (x.getTypicalExamMonth() != null) { %> &middot; usually in <%= DateUtil.monthName(x.getTypicalExamMonth()) %><% } %></p>
        <% if (s != null) { %>
        <p class="my-status"><span class="status-chip <%= HtmlUtil.statusClass(s.getStatus()) %>"><%= HtmlUtil.statusLabel(s.getStatus()) %></span>
            <span><%= HtmlUtil.escape(s.getHeadline()) %></span></p>
        <% } %>
    </article>
    <% } %>
</div>

<% if (pages > 1) { %>
<nav class="pager" aria-label="Pages">
    <% if (filter.getPage() > 1) { %><a class="btn btn-small" href="exams.jsp?<%= base %><%= base.isEmpty() ? "" : "&amp;" %>page=<%= filter.getPage() - 1 %>" rel="prev">Previous</a><% } %>
    <span>Page <%= filter.getPage() %> of <%= pages %></span>
    <% if (filter.getPage() < pages) { %><a class="btn btn-small" href="exams.jsp?<%= base %><%= base.isEmpty() ? "" : "&amp;" %>page=<%= filter.getPage() + 1 %>" rel="next">Next</a><% } %>
</nav>
<% } %>
<% } %>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
