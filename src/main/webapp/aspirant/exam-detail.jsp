<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.*, java.time.LocalDate, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.engine.*, com.aspirantos.service.EligibilityService, com.aspirantos.util.HtmlUtil, com.aspirantos.util.DateUtil, com.aspirantos.util.RuleText, com.aspirantos.util.ValidationUtil" %>
<%--
    Exam detail (view page): Overview, My eligibility, Rules, Documents, Calendar and History tabs.
    "My eligibility" runs the engine for this exam (EligibilityService.checkExam), which also
    refreshes the cached snapshot. Track / untrack, report and attempt forms post to action pages.
--%>
<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>
<%!
    // declaration: readable names of the calendar event types
    private String eventLabel(String type) {
        switch (type) {
            case "NOTIFICATION": return "Notification";
            case "APPLY_START": return "Applications open";
            case "APPLY_END": return "Last date to apply";
            case "ADMIT_CARD": return "Admit card";
            case "STAGE_1": return "First stage / prelims";
            case "STAGE_2": return "Second stage / mains";
            case "STAGE_3": return "Third stage / interview";
            default: return "Result";
        }
    }
%>
<%
    Integer examId = ValidationUtil.parseIntOrNull(request.getParameter("id"));
    Exam exam = examId == null ? null : new ExamDAO().getExam(examId);
    if (exam == null) {
        session.setAttribute("error", "That exam was not found.");
        response.sendRedirect("exams.jsp");
        return;
    }
    boolean isStudent = !"ADMIN".equals(currentUser.getRole());
    EligibilityService eligibility = new EligibilityService();
    ExamRuleSet rules = eligibility.loadRuleSet(exam);
    boolean hasProfile = isStudent && new ProfileDAO().getProfile(currentUser.getId()) != null;
    EligibilityResult result = hasProfile && rules != null ? eligibility.checkExam(currentUser.getId(), exam.getId()) : null;
    Tracking tracking = isStudent ? new TrackingDAO().getTracking(currentUser.getId(), exam.getId()) : null;
    List<DocSpec> docSpecs = new DocSpecDAO().getDocSpecsByExam(exam.getId());
    List<ExamEvent> events = new ExamEventDAO().getEventsByExam(exam.getId());
    List<RuleVersion> versions = new RuleVersionDAO().getVersionsByExam(exam.getId());
    List<RuleChange> changes = new UpdateCheckDAO().getChangesByExam(exam.getId(), 20);
    LocalDate today = eligibility.getToday();

    String pageTitle = exam.getShortName();
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<p class="crumbs"><a href="exams.jsp">Explore exams</a> / <%= HtmlUtil.escape(exam.getCategoryName()) %></p>
<div class="exam-head">
    <div>
        <h1><%= HtmlUtil.escape(exam.getShortName()) %></h1>
        <p class="exam-name"><%= HtmlUtil.escape(exam.getName()) %> &middot; <%= HtmlUtil.escape(exam.getBodyShortName()) %></p>
    </div>
    <% if (isStudent) { %>
    <div class="exam-actions">
        <form action="track-action.jsp" method="post">
            <input type="hidden" name="examId" value="<%= exam.getId() %>">
            <input type="hidden" name="action" value="<%= tracking == null ? "track" : "untrack" %>">
            <button type="submit" class="btn <%= tracking == null ? "btn-primary" : "" %>"<%= tracking != null && tracking.getAttemptsUsedBeforeApp() > 0 ? " data-confirm=\"Untrack this exam? The attempts you entered before joining will be removed.\"" : "" %>><%= tracking == null ? "Track this exam" : "Tracking - untrack" %></button>
        </form>
        <a class="btn" href="journal.jsp?exam=<%= exam.getId() %>#log">Log an attempt</a>
    </div>
    <% } %>
</div>
<%@ include file="/WEB-INF/jspf/flash.jspf" %>

<p class="verify-line">
    <span class="badge-confidence conf-<%= exam.getDataConfidence().toLowerCase() %>"><%= HtmlUtil.confidenceLabel(exam.getDataConfidence()) %></span>
    <% if (exam.getLastVerifiedOn() != null) { %>
    Rules last verified on <%= DateUtil.format(exam.getLastVerifiedOn()) %> from
    <% if (exam.getOfficialUrl() != null) { %><a href="<%= HtmlUtil.escape(exam.getOfficialUrl()) %>" target="_blank" rel="noopener noreferrer">the official source</a><% } else { %>the official source<% } %>
    &mdash; always confirm with the latest official notification before applying.
    <% } else { %>
    These rules have not been checked against an official notice yet &mdash; always confirm with the latest official notification before applying.
    <% } %>
</p>

<div class="tabs" data-tabs>
    <div class="tab-list" role="tablist" aria-label="Exam information">
        <button type="button" role="tab" id="tab-overview" aria-controls="panel-overview">Overview</button>
        <button type="button" role="tab" id="tab-mine" aria-controls="panel-mine">My eligibility</button>
        <button type="button" role="tab" id="tab-rules" aria-controls="panel-rules">Rules</button>
        <button type="button" role="tab" id="tab-docs" aria-controls="panel-docs">Documents</button>
        <button type="button" role="tab" id="tab-calendar" aria-controls="panel-calendar">Calendar</button>
        <button type="button" role="tab" id="tab-history" aria-controls="panel-history">History</button>
    </div>

    <!-- ===================== Overview ===================== -->
    <section class="tab-panel card" role="tabpanel" id="panel-overview" aria-labelledby="tab-overview">
        <h2 class="panel-title">Overview</h2>
        <% if (exam.getDescription() != null) { %><p><%= HtmlUtil.escape(exam.getDescription()) %></p><% } %>
        <dl class="facts">
            <dt>Conducted by</dt><dd><%= HtmlUtil.escape(exam.getBodyShortName()) %></dd>
            <dt>Category</dt><dd><%= HtmlUtil.escape(exam.getCategoryName()) %></dd>
            <dt>Level</dt><dd><%= exam.getScope().charAt(0) + exam.getScope().substring(1).toLowerCase() %><%= exam.getStateCode() != null ? " (" + exam.getStateCode() + ")" : "" %></dd>
            <dt>How often</dt><dd><%= exam.getCyclesPerYear() >= 12 ? "Test dates all year round" : exam.getCyclesPerYear() >= 2 ? (int) exam.getCyclesPerYear() + " times a year" : exam.getCyclesPerYear() < 1 ? "Once in two years" : "Once a year" %></dd>
            <% if (exam.getTypicalNotificationMonth() != null) { %><dt>Notification usually</dt><dd><%= DateUtil.monthName(exam.getTypicalNotificationMonth()) %></dd><% } %>
            <% if (exam.getTypicalExamMonth() != null) { %><dt>Exam usually</dt><dd><%= DateUtil.monthName(exam.getTypicalExamMonth()) %></dd><% } %>
            <% if (exam.getStagesSummary() != null) { %><dt>Stages</dt><dd><%= HtmlUtil.escape(exam.getStagesSummary()) %></dd><% } %>
            <% if (exam.getPostsOrCourses() != null) { %><dt>Posts / courses</dt><dd><%= HtmlUtil.escape(exam.getPostsOrCourses()) %></dd><% } %>
            <% if (exam.getFeeSummary() != null) { %><dt>Fee</dt><dd><%= HtmlUtil.escape(exam.getFeeSummary()) %></dd><% } %>
            <% if (exam.getOfficialUrl() != null) { %><dt>Official website</dt><dd><a href="<%= HtmlUtil.escape(exam.getOfficialUrl()) %>" target="_blank" rel="noopener noreferrer"><%= HtmlUtil.escape(exam.getOfficialUrl()) %></a></dd><% } %>
            <% if (exam.getSourceNote() != null) { %><dt>Source</dt><dd class="small"><%= HtmlUtil.escape(exam.getSourceNote()) %></dd><% } %>
        </dl>
    </section>

    <!-- ===================== My eligibility ===================== -->
    <section class="tab-panel card" role="tabpanel" id="panel-mine" aria-labelledby="tab-mine">
        <h2 class="panel-title">My eligibility</h2>
        <% if (!isStudent) { %>
        <p class="empty">Eligibility is shown to students, based on their own profile.</p>
        <% } else if (!hasProfile) { %>
        <p class="empty">Fill in <a href="profile-step1.jsp">your profile</a> to see whether you are eligible.</p>
        <% } else if (result == null) { %>
        <p class="empty">No rules are recorded for this exam yet.</p>
        <% } else { %>
        <div class="result-head">
            <span class="stamp <%= HtmlUtil.statusClass(result.getStatus()) %>"><%= HtmlUtil.statusLabel(result.getStatus()) %></span>
            <p class="result-headline"><%= HtmlUtil.escape(result.getHeadline()) %></p>
        </div>
        <dl class="facts">
            <dt>Attempts</dt><dd class="mono">used <%= result.getAttemptsUsed() %> &middot; left <%= result.getAttemptsRemainingText() %></dd>
            <dt>Next exam cycle</dt><dd class="mono"><%= HtmlUtil.orDash(result.getNextCycleYear()) %></dd>
            <% if (result.getFirstEligibleYear() != null) { %><dt>Eligible years</dt><dd class="mono"><%= result.getFirstEligibleYear() %> - <%= result.getLastEligibleYear() == null ? "no end" : String.valueOf(result.getLastEligibleYear()) %></dd><% } %>
            <% if (result.getDaysUntilAgeLimitCrossed() != null && result.getDaysUntilAgeLimitCrossed() > 0) { %><dt>Age limit reached in</dt><dd class="mono"><%= result.getDaysUntilAgeLimitCrossed() %> days</dd><% } %>
            <% if (result.getDobWindow() != null) { %><dt>Birth-date rule</dt><dd><%= HtmlUtil.escape(result.getDobWindow()) %> (for <%= result.getNextCycleYear() %>)</dd><% } %>
            <dt>Age limit for you</dt><dd><%= HtmlUtil.escape(result.getRelaxationBreakdown()) %></dd>
            <% if (result.getPostGroup() != null) { %><dt>Best post group</dt><dd><%= HtmlUtil.escape(result.getPostGroup()) %></dd><% } %>
        </dl>

        <%-- horizon strip: the next 15 cycles, green where the student can sit the exam --%>
        <div class="horizon" aria-label="Exam cycles you can use">
            <% int startYear = result.getNextCycleYear() == null ? today.getYear() : result.getNextCycleYear();
               for (int y = startYear; y < startYear + 15; y++) {
                   boolean usable = result.getUsableYears().contains(y); %>
            <span class="year <%= usable ? "usable" : "" %>" title="<%= y %>: <%= usable ? "you can sit" : "not open to you" %>"><%= y %></span>
            <% } %>
        </div>

        <table class="checks">
            <thead><tr><th>Check</th><th>Result</th><th>Explanation</th></tr></thead>
            <tbody>
            <% for (CheckLine line : result.getCheckLines()) { %>
            <tr class="check-<%= line.getResult().toLowerCase() %>">
                <td><%= HtmlUtil.escape(line.getName()) %></td>
                <td><span class="check-result"><%= line.getResult() %></span></td>
                <td><%= HtmlUtil.escape(line.getExplanation()) %></td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <% } %>
    </section>

    <!-- ===================== Rules ===================== -->
    <section class="tab-panel card" role="tabpanel" id="panel-rules" aria-labelledby="tab-rules">
        <h2 class="panel-title">Rules</h2>
        <% if (rules == null) { %>
        <p class="empty">No active rule version yet.</p>
        <% } else { %>
        <h3>Age</h3>
        <div class="table-wrap"><table>
            <thead><tr><th>Post / course</th><th>Age rule</th><th>Notes</th></tr></thead>
            <tbody>
            <% if (rules.getAgeRules().isEmpty()) { %><tr><td colspan="3">No age limit</td></tr><% } %>
            <% for (AgeRule a : rules.getAgeRules()) { %>
            <tr><td><%= a.getPostOrCourse() == null ? "All" : HtmlUtil.escape(a.getPostOrCourse()) %></td><td><%= HtmlUtil.escape(RuleText.age(a)) %></td><td class="small"><%= HtmlUtil.orDash(a.getNotes()) %></td></tr>
            <% } %>
            </tbody>
        </table></div>

        <h3>Age relaxation</h3>
        <% if (rules.getRelaxationRules().isEmpty()) { %><p class="empty">No age relaxation is recorded.</p><% } else { %>
        <ul class="rule-list">
            <% for (RelaxationRule rr : rules.getRelaxationRules()) { %>
            <li><%= HtmlUtil.escape(RuleText.relaxation(rr)) %><% if (rr.getNotes() != null) { %> <span class="muted small">- <%= HtmlUtil.escape(rr.getNotes()) %></span><% } %></li>
            <% } %>
        </ul>
        <% } %>

        <h3>Attempts</h3>
        <div class="table-wrap"><table>
            <thead><tr><th>Who</th><th>Limit</th><th>How attempts are counted</th></tr></thead>
            <tbody>
            <% for (AttemptRule ar : rules.getAttemptRules()) { %>
            <tr><td><%= HtmlUtil.escape(RuleText.attemptWho(ar)) %></td><td><%= HtmlUtil.escape(RuleText.attemptLimit(ar)) %></td><td class="small"><%= HtmlUtil.escape(ar.getNotes() != null ? ar.getNotes() : RuleText.countingRule(ar.getCountingRule())) %></td></tr>
            <% } %>
            </tbody>
        </table></div>

        <h3>Qualification</h3>
        <div class="table-wrap"><table>
            <thead><tr><th>Post / course</th><th>Required</th><th>Minimum marks</th><th>Final year</th></tr></thead>
            <tbody>
            <% for (QualificationRule q : rules.getQualificationRules()) { %>
            <tr><td><%= q.getPostOrCourse() == null ? "All" : HtmlUtil.escape(q.getPostOrCourse()) %></td><td><%= HtmlUtil.escape(RuleText.qualification(q)) %></td><td><%= HtmlUtil.escape(RuleText.marks(q)) %></td><td><%= q.isFinalYearAllowed() ? "May apply" : "Must have passed" %></td></tr>
            <% } %>
            </tbody>
        </table></div>

        <% if (!rules.getOtherRules().isEmpty()) { %>
        <h3>Other conditions</h3>
        <ul class="rule-list">
            <% for (OtherRule o : rules.getOtherRules()) { %>
            <li><strong><%= RuleText.otherType(o.getRuleType()) %>:</strong> <%= HtmlUtil.escape(RuleText.other(o)) %><%= o.getPostOrCourse() != null ? " (" + HtmlUtil.escape(o.getPostOrCourse()) + ")" : "" %><%= o.isBlocking() ? "" : " <span class=\"muted small\">- information</span>" %></li>
            <% } %>
        </ul>
        <% } %>
        <% if (exam.getAttemptCountingNote() != null) { %><p class="hint"><%= HtmlUtil.escape(exam.getAttemptCountingNote()) %></p><% } %>
        <% } %>
    </section>

    <!-- ===================== Documents ===================== -->
    <section class="tab-panel card" role="tabpanel" id="panel-docs" aria-labelledby="tab-docs">
        <h2 class="panel-title">Photo, signature and documents</h2>
        <% if (docSpecs.isEmpty()) { %>
        <p class="empty">No document rules are recorded for this exam.</p>
        <% } else { %>
        <div class="table-wrap"><table>
            <thead><tr><th>Document</th><th>Size</th><th>File size</th><th>Format</th><th>Background / notes</th></tr></thead>
            <tbody>
            <% for (DocSpec d : docSpecs) { %>
            <tr>
                <td><%= RuleText.docType(d.getDocType()) %></td>
                <td class="mono"><%= RuleText.docSize(d) %></td>
                <td class="mono"><%= RuleText.docKb(d) %></td>
                <td><%= HtmlUtil.orDash(d.getAllowedFormats()) %></td>
                <td class="small"><%= HtmlUtil.escape(d.getBackgroundRule()) %><%= d.isRequiresNameAndDate() ? " Name and date on the photo." : "" %><%= d.getNotes() != null ? " " + HtmlUtil.escape(d.getNotes()) : "" %></td>
            </tr>
            <% } %>
            </tbody>
        </table></div>
        <% } %>
    </section>

    <!-- ===================== Calendar ===================== -->
    <section class="tab-panel card" role="tabpanel" id="panel-calendar" aria-labelledby="tab-calendar">
        <h2 class="panel-title">Calendar</h2>
        <% if (events.isEmpty()) { %>
        <p class="empty">No dates are recorded. <%= exam.getTypicalExamMonth() != null ? "The exam is usually held in " + DateUtil.monthName(exam.getTypicalExamMonth()) + "." : "" %></p>
        <% } else { %>
        <ul class="event-list">
            <% for (ExamEvent ev : events) {
                   boolean past = ev.getEventDate().isBefore(today); %>
            <li class="<%= past ? "past" : "" %>">
                <span class="mono"><%= DateUtil.format(ev.getEventDate()) %></span>
                <span><%= eventLabel(ev.getEventType()) %> (<%= ev.getCycleYear() %>)</span>
                <% if (ev.isTentative()) { %><span class="tag">tentative</span><% } else { %><span class="tag tag-official">official</span><% } %>
            </li>
            <% } %>
        </ul>
        <p class="hint">Tentative dates are estimated from the usual month and change every year.</p>
        <% } %>
    </section>

    <!-- ===================== History ===================== -->
    <section class="tab-panel card" role="tabpanel" id="panel-history" aria-labelledby="tab-history">
        <h2 class="panel-title">Rule history</h2>
        <div class="table-wrap"><table>
            <thead><tr><th>Version</th><th>Status</th><th>From cycle</th><th>Summary</th><th>By</th><th>Published</th></tr></thead>
            <tbody>
            <% for (RuleVersion v : versions) { %>
            <tr>
                <td class="mono">v<%= v.getVersionNo() %></td>
                <td><%= v.getStatus().charAt(0) + v.getStatus().substring(1).toLowerCase() %></td>
                <td><%= HtmlUtil.orDash(v.getAppliesFromCycleYear()) %></td>
                <td><%= HtmlUtil.orDash(v.getChangeSummary()) %><% if (v.getChangeCount() > 0) { %> <span class="muted small">(<%= v.getChangeCount() %> changes)</span><% } %></td>
                <td><%= HtmlUtil.orDash(v.getCreatedByName()) %></td>
                <td><%= v.getActivatedAt() == null ? "-" : DateUtil.format(v.getActivatedAt().toLocalDate()) %></td>
            </tr>
            <% } %>
            </tbody>
        </table></div>
        <% if (!changes.isEmpty()) { %>
        <h3>Recent changes</h3>
        <ul class="rule-list">
            <% for (RuleChange c : changes) { %>
            <li><span class="mono small"><%= DateUtil.format(c.getChangedAt()) %></span> <%= HtmlUtil.escape(c.getTableName()) %>.<%= HtmlUtil.escape(c.getColumnName()) %>:
                <del><%= HtmlUtil.orDash(c.getOldValue()) %></del> &rarr; <ins><%= HtmlUtil.orDash(c.getNewValue()) %></ins></li>
            <% } %>
        </ul>
        <% } %>
    </section>
</div>

<% if (isStudent) { %>
<details class="card report-box">
    <summary>Is something here out of date? Tell the administrator</summary>
    <form action="report-action.jsp" method="post" data-validate="report" novalidate>
        <input type="hidden" name="examId" value="<%= exam.getId() %>">
        <label for="message">What is wrong? (for example a new age limit in the latest notification)</label>
        <textarea id="message" name="message" rows="3" maxlength="1000" required></textarea>
        <button type="submit" class="btn">Send report</button>
    </form>
</details>
<% } %>
<script src="<%= ctx %>/assets/js/tabs.js"></script>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
