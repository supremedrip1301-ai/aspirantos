<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.*, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.engine.ExamRuleSet, com.aspirantos.util.HtmlUtil, com.aspirantos.util.DateUtil, com.aspirantos.util.RuleText, com.aspirantos.util.RuleDiff, com.aspirantos.util.ValidationUtil" %>
<%--
    Rule versions of one exam (admin page, MASTER_PROMPT PART 8):
      - every version (DRAFT / ACTIVE / ARCHIVED) with who changed what,
      - "Update rules" copies the ACTIVE version into a DRAFT (sp_clone_rule_version, CallableStatement),
      - the DRAFT is edited row by row (rule-action.jsp; ACTIVE / ARCHIVED rows can never change),
      - a diff preview shows the DRAFT against the ACTIVE version,
      - "Publish" calls sp_activate_rule_version: the old version is archived, every student who
        tracks the exam is notified and their cached results are recalculated.
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%!
    // ---------- declarations: load a version and print small form fields ----------
    private ExamRuleSet loadVersion(Exam exam, Integer versionId) {
        if (versionId == null) {
            return null;
        }
        RuleDAO dao = new RuleDAO();
        ExamRuleSet rs = new ExamRuleSet(exam, versionId);
        rs.setAgeRules(dao.getAgeRules(versionId));
        rs.setRelaxationRules(dao.getRelaxationRules(versionId));
        rs.setAttemptRules(dao.getAttemptRules(versionId));
        rs.setQualificationRules(dao.getQualificationRules(versionId));
        rs.setOtherRules(dao.getOtherRules(versionId));
        return rs;
    }

    private String text(String name, String label, Object value, int max) {
        return "<div><label for=\"" + name + "\">" + label + "</label><input type=\"text\" id=\"" + name + "\" name=\"" + name
                + "\" value=\"" + HtmlUtil.escape(value) + "\" maxlength=\"" + max + "\"></div>";
    }

    private String number(String name, String label, Object value, String min, String max, String step) {
        return "<div><label for=\"" + name + "\">" + label + "</label><input type=\"number\" id=\"" + name + "\" name=\"" + name
                + "\" value=\"" + HtmlUtil.escape(value) + "\" min=\"" + min + "\" max=\"" + max + "\" step=\"" + step + "\"></div>";
    }

    private String select(String name, String label, String[][] options, Object current) {
        StringBuilder sb = new StringBuilder("<div><label for=\"" + name + "\">" + label + "</label><select id=\"" + name
                + "\" name=\"" + name + "\">");
        for (String[] o : options) {
            sb.append("<option value=\"").append(o[0]).append("\" ").append(HtmlUtil.selected(current == null ? "" : current, o[0]))
              .append(">").append(o[1]).append("</option>");
        }
        return sb.append("</select></div>").toString();
    }

    private String check(String name, String label, boolean on) {
        return "<label class=\"check\"><input type=\"checkbox\" name=\"" + name + "\" value=\"true\" " + HtmlUtil.checked(on) + "> " + label + "</label>";
    }

    private static final String[][] CATEGORIES = {{"", "All categories"}, {"GEN", "General"}, {"EWS", "EWS"}, {"OBC_NCL", "OBC-NCL"}, {"SC", "SC"}, {"ST", "ST"}};
    private static final String[][] MONTHS = {{"", "-"}, {"1", "January"}, {"2", "February"}, {"3", "March"}, {"4", "April"}, {"5", "May"}, {"6", "June"},
            {"7", "July"}, {"8", "August"}, {"9", "September"}, {"10", "October"}, {"11", "November"}, {"12", "December"}};
%>
<%
    Integer examId = ValidationUtil.parseIntOrNull(request.getParameter("exam"));
    Exam exam = examId == null ? null : new ExamDAO().getExam(examId);
    if (exam == null) {
        session.setAttribute("error", "That exam was not found.");
        response.sendRedirect("exams.jsp");
        return;
    }
    RuleVersionDAO versionDAO = new RuleVersionDAO();
    List<RuleVersion> versions = versionDAO.getVersionsByExam(exam.getId());
    RuleVersion draft = versionDAO.getDraft(exam.getId());
    ExamRuleSet active = loadVersion(exam, exam.getActiveRuleVersionId());
    ExamRuleSet editing = draft == null ? null : loadVersion(exam, draft.getId());

    // read-only view of another version (?version=<id>), default the active one
    Integer viewId = ValidationUtil.parseIntOrNull(request.getParameter("version"));
    RuleVersion viewed = null;
    for (RuleVersion v : versions) {
        if (viewId != null && v.getId() == viewId && v.getExamId() == exam.getId()) {
            viewed = v;
        }
    }
    ExamRuleSet viewedRules = viewed == null ? active : loadVersion(exam, viewed.getId());

    Map<String, List<List<String>>> diff = editing == null ? null : RuleDiff.diff(active, editing);
    List<UpdateCheck> lastChecks = new UpdateCheckDAO().getChecksByExam(exam.getId(), 1);
    UpdateCheck lastCheck = lastChecks.isEmpty() ? null : lastChecks.get(0);
    List<RuleChange> draftChanges = new ArrayList<>();
    if (draft != null) {
        for (RuleChange c : new UpdateCheckDAO().getChangesByExam(exam.getId(), 100)) {
            if (c.getRuleVersionId() != null && c.getRuleVersionId() == draft.getId()) {
                draftChanges.add(c);
            }
        }
    }

    // the row being edited (?edit=age-12) or typed values kept after an error
    Object formRule = session.getAttribute("formRule");
    String formType = (String) session.getAttribute("formRuleType");
    if (formRule != null) {
        session.removeAttribute("formRule");
        session.removeAttribute("formRuleType");
    } else if (editing != null && request.getParameter("edit") != null) {
        String[] parts = request.getParameter("edit").split("-");
        Integer rowId = parts.length == 2 ? ValidationUtil.parseIntOrNull(parts[1]) : null;
        if (rowId != null) {
            formType = parts[0];
            if ("age".equals(formType)) { for (AgeRule r : editing.getAgeRules()) { if (r.getId() == rowId) { formRule = r; } } }
            if ("relax".equals(formType)) { for (RelaxationRule r : editing.getRelaxationRules()) { if (r.getId() == rowId) { formRule = r; } } }
            if ("attempt".equals(formType)) { for (AttemptRule r : editing.getAttemptRules()) { if (r.getId() == rowId) { formRule = r; } } }
            if ("qual".equals(formType)) { for (QualificationRule r : editing.getQualificationRules()) { if (r.getId() == rowId) { formRule = r; } } }
            if ("other".equals(formType)) { for (OtherRule r : editing.getOtherRules()) { if (r.getId() == rowId) { formRule = r; } } }
        }
    }
    AgeRule fAge = "age".equals(formType) && formRule instanceof AgeRule ? (AgeRule) formRule : new AgeRule();
    RelaxationRule fRelax = "relax".equals(formType) && formRule instanceof RelaxationRule ? (RelaxationRule) formRule : new RelaxationRule();
    AttemptRule fAttempt = "attempt".equals(formType) && formRule instanceof AttemptRule ? (AttemptRule) formRule : new AttemptRule();
    QualificationRule fQual = "qual".equals(formType) && formRule instanceof QualificationRule ? (QualificationRule) formRule : new QualificationRule();
    OtherRule fOther = "other".equals(formType) && formRule instanceof OtherRule ? (OtherRule) formRule : new OtherRule();
    if (fAge.getId() == 0 && fAge.getCutoffType() == null) { fAge.setCutoffType("FIXED_DATE_IN_CYCLE_YEAR"); fAge.setMaxAgeSemantics("NOT_ATTAINED"); }
    if (fQual.getAcceptedDegrees() == null) { fQual.setAcceptedDegrees("ANY"); }
    if (fOther.getId() == 0 && fOther.getRuleType() == null) { fOther.setBlocking(true); }

    String base = "rule-action.jsp?exam=" + exam.getId() + "&amp;version=" + (draft == null ? 0 : draft.getId());
    String pageTitle = "Rules - " + exam.getShortName();
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<p class="crumbs"><a href="exams.jsp">Exams</a> / <a href="exam-form.jsp?id=<%= exam.getId() %>"><%= HtmlUtil.escape(exam.getShortName()) %></a> / Rules</p>
<div class="dash-head">
    <h1>Rules of <%= HtmlUtil.escape(exam.getShortName()) %></h1>
    <span class="head-links">
        <a class="btn btn-small" href="docs-events.jsp?exam=<%= exam.getId() %>">Documents and dates</a>
        <a class="btn btn-small" href="../aspirant/exam-detail.jsp?id=<%= exam.getId() %>#rules">See the student page</a>
    </span>
</div>
<%@ include file="/WEB-INF/jspf/flash.jspf" %>

<section class="card">
    <h2>Versions</h2>
    <% if (versions.isEmpty()) { %>
    <p class="empty">This exam has no rules yet.</p>
    <% } else { %>
    <div class="table-wrap"><table>
        <thead><tr><th>Version</th><th>Status</th><th>From cycle</th><th>Summary</th><th>By</th><th>Created</th><th>Published</th><th></th></tr></thead>
        <tbody>
        <% for (RuleVersion v : versions) { %>
        <tr class="<%= "ACTIVE".equals(v.getStatus()) ? "row-active" : "" %>">
            <td class="mono">v<%= v.getVersionNo() %></td>
            <td><span class="status-chip <%= "ACTIVE".equals(v.getStatus()) ? "status-eligible" : ("DRAFT".equals(v.getStatus()) ? "status-provisional" : "status-unknown") %>"><%= v.getStatus() %></span></td>
            <td><%= HtmlUtil.orDash(v.getAppliesFromCycleYear()) %></td>
            <td class="small"><%= HtmlUtil.orDash(v.getChangeSummary()) %></td>
            <td class="small"><%= HtmlUtil.orDash(v.getCreatedByName()) %></td>
            <td class="small"><%= v.getCreatedAt() == null ? "-" : DateUtil.format(v.getCreatedAt().toLocalDate()) %></td>
            <td class="small"><%= v.getActivatedAt() == null ? "-" : DateUtil.format(v.getActivatedAt().toLocalDate()) %></td>
            <td><% if (!"DRAFT".equals(v.getStatus())) { %><a class="small" href="rules.jsp?exam=<%= exam.getId() %>&amp;version=<%= v.getId() %>#viewed">View</a><% } %></td>
        </tr>
        <% } %>
        </tbody>
    </table></div>
    <% } %>
    <% if (draft == null) { %>
    <form action="rule-version-action.jsp" method="post" class="form-actions">
        <input type="hidden" name="action" value="clone">
        <input type="hidden" name="exam" value="<%= exam.getId() %>">
        <button type="submit" class="btn btn-primary"><%= versions.isEmpty() ? "Create version 1" : "Update rules (copy the active version into a draft)" %></button>
    </form>
    <% } %>
</section>

<section class="card" id="updates">
    <h2>Official page</h2>
    <form action="update-check-action.jsp" method="post" class="check-row">
        <input type="hidden" name="action" value="check">
        <input type="hidden" name="exam" value="<%= exam.getId() %>">
        <button type="submit" class="btn btn-primary">Check for updates</button>
        <span class="small muted">
            <% if (lastCheck == null) { %>Never checked.<% } else { %>Last checked <%= DateUtil.format(lastCheck.getCheckedAt()) %>
            - <%= lastCheck.getErrorMessage() != null ? "could not reach the site" : (lastCheck.getChangedSinceLast() == null ? "first check" : (lastCheck.getChangedSinceLast() ? "the page had changed" : "no change")) %><% } %>
            &middot; page: <%= HtmlUtil.escape(exam.getWatchUrl() != null ? exam.getWatchUrl() : HtmlUtil.orDash(exam.getOfficialUrl())) %>
        </span>
    </form>
    <% if (lastCheck != null && lastCheck.getErrorMessage() != null) { %>
    <p class="warn-text">Could not reach the official site: <%= HtmlUtil.escape(lastCheck.getErrorMessage()) %> You can still update the rules by hand.</p>
    <% } else if (lastCheck != null && lastCheck.getKeywordHits() != null) { %>
    <details <%= Boolean.TRUE.equals(lastCheck.getChangedSinceLast()) ? "open" : "" %>>
        <summary>Lines around eligibility words on the page</summary>
        <% for (String snip : lastCheck.getKeywordHits().split("\n\n")) { %><p class="snippet small"><%= HtmlUtil.escape(snip) %></p><% } %>
        <% if (exam.getOfficialUrl() != null) { %><a class="small" href="<%= HtmlUtil.escape(exam.getWatchUrl() != null ? exam.getWatchUrl() : exam.getOfficialUrl()) %>" target="_blank" rel="noopener noreferrer">Open the official page</a><% } %>
    </details>
    <% } %>
</section>

<% if (editing != null) { %>
<!-- =================================== DRAFT EDITOR =================================== -->
<section class="card draft-card" id="draft">
    <h2>Draft v<%= draft.getVersionNo() %> <span class="muted small">- only this version can be changed</span></h2>
    <form action="rule-version-action.jsp" method="post" novalidate>
        <input type="hidden" name="action" value="saveInfo">
        <input type="hidden" name="exam" value="<%= exam.getId() %>">
        <input type="hidden" name="version" value="<%= draft.getId() %>">
        <div class="form-grid">
            <div class="span-2"><label for="changeSummary">What changed? (students see this in the history)</label>
                <input type="text" id="changeSummary" name="changeSummary" value="<%= HtmlUtil.escape(draft.getChangeSummary()) %>" maxlength="500"></div>
            <div><label for="sourceUrl">Official source of the change</label>
                <input type="url" id="sourceUrl" name="sourceUrl" value="<%= HtmlUtil.escape(draft.getSourceUrl()) %>" maxlength="500" placeholder="https://"></div>
            <div><label for="appliesFrom">Applies from exam cycle</label>
                <input type="number" id="appliesFrom" name="appliesFromCycleYear" value="<%= HtmlUtil.escape(draft.getAppliesFromCycleYear()) %>" min="2000" max="2100"></div>
        </div>
        <div class="form-actions"><button type="submit" class="btn">Save draft details</button></div>
    </form>
</section>

<%-- ---------- age ---------- --%>
<section class="card" id="age">
    <h2>Age rules</h2>
    <div class="table-wrap"><table>
        <thead><tr><th>Post / course</th><th>Rule</th><th>Notes</th><th></th></tr></thead>
        <tbody>
        <% if (editing.getAgeRules().isEmpty()) { %><tr><td colspan="4" class="empty">No age rule - no age limit.</td></tr><% } %>
        <% for (AgeRule a : editing.getAgeRules()) { %>
        <tr><td><%= a.getPostOrCourse() == null ? "All" : HtmlUtil.escape(a.getPostOrCourse()) %></td><td><%= HtmlUtil.escape(RuleText.age(a)) %></td><td class="small"><%= HtmlUtil.orDash(a.getNotes()) %></td>
            <td class="actions"><a href="rules.jsp?exam=<%= exam.getId() %>&amp;edit=age-<%= a.getId() %>#age-form">Edit</a>
                <a href="<%= base %>&amp;type=age&amp;action=delete&amp;id=<%= a.getId() %>" data-confirm="Delete this age rule from the draft?">Delete</a></td></tr>
        <% } %>
        </tbody>
    </table></div>
    <details id="age-form" <%= "age".equals(formType) ? "open" : "" %>>
        <summary><%= fAge.getId() > 0 ? "Edit age rule" : "Add an age rule" %></summary>
        <form action="rule-action.jsp" method="post" novalidate>
            <input type="hidden" name="type" value="age"><input type="hidden" name="action" value="save">
            <input type="hidden" name="exam" value="<%= exam.getId() %>"><input type="hidden" name="version" value="<%= draft.getId() %>">
            <input type="hidden" name="id" value="<%= fAge.getId() %>">
            <div class="form-grid">
                <%= text("postOrCourse", "Post / course (empty = all)", fAge.getPostOrCourse(), 120) %>
                <%= select("cutoffType", "Age is counted", new String[][] {{"FIXED_DATE_IN_CYCLE_YEAR", "On a date in the exam year"}, {"FIXED_DATE_IN_PREVIOUS_YEAR", "On a date in the year before"},
                        {"FIXED_DATE_IN_NEXT_YEAR", "On a date in the year after"}, {"DOB_WINDOW", "Birth-date window"}, {"NONE", "No cut-off date"}}, fAge.getCutoffType()) %>
                <%= number("minAge", "Minimum age", fAge.getMinAge(), "0", "80", "1") %>
                <%= number("maxAge", "Upper age", fAge.getMaxAge(), "0", "80", "1") %>
                <%= select("maxAgeSemantics", "Upper age means", new String[][] {{"NOT_ATTAINED", "must not have attained it (below)"}, {"NOT_MORE_THAN", "not more than (inclusive)"}}, fAge.getMaxAgeSemantics()) %>
                <div class="pair"><%= select("cutoffMonth", "Cut-off month", MONTHS, fAge.getCutoffMonth()) %><%= number("cutoffDay", "Day", fAge.getCutoffDay(), "1", "31", "1") %></div>
                <%= number("dobFromOffsetYears", "Window: born on/after - years from exam year (e.g. -25)", fAge.getDobFromOffsetYears(), "-100", "0", "1") %>
                <div class="pair"><%= select("dobFromMonth", "month", MONTHS, fAge.getDobFromMonth()) %><%= number("dobFromDay", "day", fAge.getDobFromDay(), "1", "31", "1") %></div>
                <%= number("dobToOffsetYears", "Window: born on/before - years from exam year (optional)", fAge.getDobToOffsetYears(), "-100", "0", "1") %>
                <div class="pair"><%= select("dobToMonth", "month", MONTHS, fAge.getDobToMonth()) %><%= number("dobToDay", "day", fAge.getDobToDay(), "1", "31", "1") %></div>
                <div class="span-2"><%= text("notes", "Notes", fAge.getNotes(), 500) %></div>
            </div>
            <div class="form-actions"><a class="btn" href="rules.jsp?exam=<%= exam.getId() %>#age">Cancel</a><button type="submit" class="btn btn-primary">Save age rule</button></div>
        </form>
    </details>
</section>

<%-- ---------- relaxation ---------- --%>
<section class="card" id="relax">
    <h2>Age relaxations</h2>
    <ul class="rule-list">
        <% if (editing.getRelaxationRules().isEmpty()) { %><li class="empty">No relaxation.</li><% } %>
        <% for (RelaxationRule r : editing.getRelaxationRules()) { %>
        <li><%= HtmlUtil.escape(RuleText.relaxation(r)) %><% if (r.getNotes() != null) { %> <span class="muted small">- <%= HtmlUtil.escape(r.getNotes()) %></span><% } %>
            <span class="actions"><a href="rules.jsp?exam=<%= exam.getId() %>&amp;edit=relax-<%= r.getId() %>#relax-form">Edit</a>
            <a href="<%= base %>&amp;type=relax&amp;action=delete&amp;id=<%= r.getId() %>" data-confirm="Delete this relaxation from the draft?">Delete</a></span></li>
        <% } %>
    </ul>
    <details id="relax-form" <%= "relax".equals(formType) ? "open" : "" %>>
        <summary><%= fRelax.getId() > 0 ? "Edit relaxation" : "Add a relaxation" %></summary>
        <form action="rule-action.jsp" method="post" novalidate>
            <input type="hidden" name="type" value="relax"><input type="hidden" name="action" value="save">
            <input type="hidden" name="exam" value="<%= exam.getId() %>"><input type="hidden" name="version" value="<%= draft.getId() %>">
            <input type="hidden" name="id" value="<%= fRelax.getId() %>">
            <div class="form-grid">
                <%= select("relaxationType", "Who", new String[][] {{"CATEGORY", "Category"}, {"PWBD", "PwBD"}, {"EX_SERVICEMAN", "Ex-serviceman"}, {"JK_DOMICILE_1980_89", "J&amp;K domicile 1980-89"},
                        {"GOVT_EMPLOYEE", "Government employee"}, {"WOMEN", "Women"}, {"WIDOW_DIVORCED_WOMEN", "Widow / divorced women"}, {"TRANSGENDER", "Transgender"}, {"STATE_DOMICILE", "State domicile"}}, fRelax.getRelaxationType()) %>
                <%= select("category", "Category (needed for Category)", CATEGORIES, fRelax.getCategory()) %>
                <%= number("years", "Years", fRelax.getId() == 0 && fRelax.getRelaxationType() == null ? null : fRelax.getYears(), "0", "40", "1") %>
                <%= select("stacking", "How it works", new String[][] {{"ADD", "Adds years"}, {"ADD_AFTER_SERVICE_DEDUCTION", "Adds years after deducting military service"},
                        {"REPLACE_WITH_MAX", "Up to N years / raises the limit to the cap"}}, fRelax.getStacking()) %>
                <%= number("overallMaxAgeCap", "Upper age cap (optional)", fRelax.getOverallMaxAgeCap(), "18", "70", "1") %>
                <%= text("notes", "Notes", fRelax.getNotes(), 500) %>
            </div>
            <%= check("requiresStateDomicile", "Only for the state's own domicile candidates", fRelax.isRequiresStateDomicile()) %>
            <div class="form-actions"><a class="btn" href="rules.jsp?exam=<%= exam.getId() %>#relax">Cancel</a><button type="submit" class="btn btn-primary">Save relaxation</button></div>
        </form>
    </details>
</section>

<%-- ---------- attempts ---------- --%>
<section class="card" id="attempt">
    <h2>Attempt limits</h2>
    <div class="table-wrap"><table>
        <thead><tr><th>Who</th><th>Limit</th><th>Counting</th><th></th></tr></thead>
        <tbody>
        <% if (editing.getAttemptRules().isEmpty()) { %><tr><td colspan="4" class="empty">No attempt rule - unlimited.</td></tr><% } %>
        <% for (AttemptRule r : editing.getAttemptRules()) { %>
        <tr><td><%= HtmlUtil.escape(RuleText.attemptWho(r)) %></td><td><%= HtmlUtil.escape(RuleText.attemptLimit(r)) %></td><td class="small"><%= HtmlUtil.escape(r.getNotes() != null ? r.getNotes() : RuleText.countingRule(r.getCountingRule())) %></td>
            <td class="actions"><a href="rules.jsp?exam=<%= exam.getId() %>&amp;edit=attempt-<%= r.getId() %>#attempt-form">Edit</a>
                <a href="<%= base %>&amp;type=attempt&amp;action=delete&amp;id=<%= r.getId() %>" data-confirm="Delete this attempt rule from the draft?">Delete</a></td></tr>
        <% } %>
        </tbody>
    </table></div>
    <details id="attempt-form" <%= "attempt".equals(formType) ? "open" : "" %>>
        <summary><%= fAttempt.getId() > 0 ? "Edit attempt rule" : "Add an attempt rule" %></summary>
        <form action="rule-action.jsp" method="post" novalidate>
            <input type="hidden" name="type" value="attempt"><input type="hidden" name="action" value="save">
            <input type="hidden" name="exam" value="<%= exam.getId() %>"><input type="hidden" name="version" value="<%= draft.getId() %>">
            <input type="hidden" name="id" value="<%= fAttempt.getId() %>">
            <div class="form-grid">
                <%= select("category", "Category", CATEGORIES, fAttempt.getCategory()) %>
                <%= select("pwbd", "PwBD", new String[][] {{"", "PwBD and others"}, {"true", "PwBD only"}, {"false", "Not PwBD"}}, fAttempt.getPwbd()) %>
                <%= number("maxAttempts", "Maximum attempts (empty = unlimited)", fAttempt.getMaxAttempts(), "1", "50", "1") %>
                <%= select("countingRule", "What counts", new String[][] {{"APPEARED_IN_FIRST_STAGE", "Appearing in the first stage"}, {"APPLIED", "Every application"}, {"PER_SITTING", "Every sitting"},
                        {"CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM", "Years after Class 12 (window)"}, {"PER_ROLLING_12_MONTHS", "Tests in any 12 months"}, {"LIFETIME_TOTAL", "Lifetime total"}}, fAttempt.getCountingRule()) %>
                <%= number("windowYears", "Window years (for the Class 12 window)", fAttempt.getWindowYears(), "1", "10", "1") %>
                <%= number("minGapDays", "Days between two tests (optional)", fAttempt.getMinGapDays(), "1", "365", "1") %>
                <div class="span-2"><%= text("notes", "Notes shown to students", fAttempt.getNotes(), 500) %></div>
            </div>
            <div class="form-actions"><a class="btn" href="rules.jsp?exam=<%= exam.getId() %>#attempt">Cancel</a><button type="submit" class="btn btn-primary">Save attempt rule</button></div>
        </form>
    </details>
</section>

<%-- ---------- qualification ---------- --%>
<section class="card" id="qual">
    <h2>Qualification</h2>
    <div class="table-wrap"><table>
        <thead><tr><th>Post / course</th><th>Required</th><th>Marks</th><th>Final year</th><th></th></tr></thead>
        <tbody>
        <% if (editing.getQualificationRules().isEmpty()) { %><tr><td colspan="5" class="empty">No qualification rule.</td></tr><% } %>
        <% for (QualificationRule q : editing.getQualificationRules()) { %>
        <tr><td><%= q.getPostOrCourse() == null ? "All" : HtmlUtil.escape(q.getPostOrCourse()) %></td><td><%= HtmlUtil.escape(RuleText.qualification(q)) %></td><td><%= HtmlUtil.escape(RuleText.marks(q)) %></td><td><%= q.isFinalYearAllowed() ? "May apply" : "Must have passed" %></td>
            <td class="actions"><a href="rules.jsp?exam=<%= exam.getId() %>&amp;edit=qual-<%= q.getId() %>#qual-form">Edit</a>
                <a href="<%= base %>&amp;type=qual&amp;action=delete&amp;id=<%= q.getId() %>" data-confirm="Delete this qualification rule from the draft?">Delete</a></td></tr>
        <% } %>
        </tbody>
    </table></div>
    <details id="qual-form" <%= "qual".equals(formType) ? "open" : "" %>>
        <summary><%= fQual.getId() > 0 ? "Edit qualification rule" : "Add a qualification rule" %></summary>
        <form action="rule-action.jsp" method="post" novalidate>
            <input type="hidden" name="type" value="qual"><input type="hidden" name="action" value="save">
            <input type="hidden" name="exam" value="<%= exam.getId() %>"><input type="hidden" name="version" value="<%= draft.getId() %>">
            <input type="hidden" name="id" value="<%= fQual.getId() %>">
            <div class="form-grid">
                <%= text("postOrCourse", "Post / course (empty = all)", fQual.getPostOrCourse(), 120) %>
                <%= select("requiredLevel", "Required level", new String[][] {{"NONE", "None"}, {"CLASS_10", "Class 10"}, {"CLASS_12", "Class 12"}, {"DIPLOMA", "Diploma"}, {"UG", "Graduation"},
                        {"PG", "Post-graduation"}, {"PHD", "PhD"}, {"PROFESSIONAL", "Professional (CA, CS ...)"}}, fQual.getRequiredLevel()) %>
                <%= text("acceptedDegrees", "Accepted degrees (comma list or ANY)", fQual.getAcceptedDegrees(), 500) %>
                <%= text("requiredSubjects", "Subjects (comma = all, | = any one, CLASS_12: prefix)", fQual.getRequiredSubjects(), 300) %>
                <%= number("minPercentGeneral", "Minimum % (general)", fQual.getMinPercentGeneral(), "0", "100", "0.01") %>
                <%= number("minPercentRelaxed", "Minimum % (relaxed)", fQual.getMinPercentRelaxed(), "0", "100", "0.01") %>
                <%= text("relaxedFor", "Relaxed % for (e.g. SC,ST,OBC_NCL,PWBD)", fQual.getRelaxedFor(), 100) %>
                <%= number("maxYearsSincePassing", "Must apply within N years of passing (optional)", fQual.getMaxYearsSincePassing(), "0", "20", "1") %>
                <%= number("minExperienceYears", "Experience in years (optional)", fQual.getMinExperienceYears(), "0", "40", "0.5") %>
                <%= text("textSummary", "Summary shown to students", fQual.getTextSummary(), 500) %>
            </div>
            <%= check("finalYearAllowed", "Final-year students may apply", fQual.isFinalYearAllowed()) %>
            <div class="form-actions"><a class="btn" href="rules.jsp?exam=<%= exam.getId() %>#qual">Cancel</a><button type="submit" class="btn btn-primary">Save qualification rule</button></div>
        </form>
    </details>
</section>

<%-- ---------- other ---------- --%>
<section class="card" id="other">
    <h2>Other conditions</h2>
    <ul class="rule-list">
        <% if (editing.getOtherRules().isEmpty()) { %><li class="empty">No other condition.</li><% } %>
        <% for (OtherRule o : editing.getOtherRules()) { %>
        <li><strong><%= RuleText.otherType(o.getRuleType()) %>:</strong> <%= HtmlUtil.escape(RuleText.other(o)) %><%= o.getPostOrCourse() != null ? " (" + HtmlUtil.escape(o.getPostOrCourse()) + ")" : "" %><%= o.isBlocking() ? "" : " <span class=\"muted small\">- information</span>" %>
            <span class="actions"><a href="rules.jsp?exam=<%= exam.getId() %>&amp;edit=other-<%= o.getId() %>#other-form">Edit</a>
            <a href="<%= base %>&amp;type=other&amp;action=delete&amp;id=<%= o.getId() %>" data-confirm="Delete this condition from the draft?">Delete</a></span></li>
        <% } %>
    </ul>
    <details id="other-form" <%= "other".equals(formType) ? "open" : "" %>>
        <summary><%= fOther.getId() > 0 ? "Edit condition" : "Add a condition" %></summary>
        <form action="rule-action.jsp" method="post" novalidate>
            <input type="hidden" name="type" value="other"><input type="hidden" name="action" value="save">
            <input type="hidden" name="exam" value="<%= exam.getId() %>"><input type="hidden" name="version" value="<%= draft.getId() %>">
            <input type="hidden" name="id" value="<%= fOther.getId() %>">
            <div class="form-grid">
                <%= text("postOrCourse", "Post / course (empty = all)", fOther.getPostOrCourse(), 120) %>
                <%= select("ruleType", "Type", new String[][] {{"NATIONALITY", "Nationality"}, {"GENDER", "Gender"}, {"MARITAL_STATUS", "Marital status"}, {"DOMICILE", "Domicile"},
                        {"PHYSICAL_STANDARD", "Physical standard"}, {"REGISTRATION", "Other exam / registration"}, {"OTHER", "Other"}}, fOther.getRuleType()) %>
                <%= text("ruleValue", "Value (e.g. UNMARRIED, MALE,FEMALE, UP, NO_PWBD)", fOther.getRuleValue(), 200) %>
                <%= text("textSummary", "Text shown to students", fOther.getTextSummary(), 500) %>
            </div>
            <%= check("blocking", "Blocking (not meeting it makes the student not eligible)", fOther.isBlocking()) %>
            <div class="form-actions"><a class="btn" href="rules.jsp?exam=<%= exam.getId() %>#other">Cancel</a><button type="submit" class="btn btn-primary">Save condition</button></div>
        </form>
    </details>
</section>

<%-- ---------- diff + publish ---------- --%>
<section class="card" id="diff">
    <h2>Changes compared with <%= active == null ? "nothing (first version)" : "the active version" %></h2>
    <% if (diff.isEmpty()) { %>
    <p class="empty">No differences yet - edit the rules above.</p>
    <% } else { %>
    <% for (Map.Entry<String, List<List<String>>> e : diff.entrySet()) { %>
    <h3><%= e.getKey() %></h3>
    <ul class="diff-list">
        <% for (String s : e.getValue().get(0)) { %><li class="removed"><del><%= HtmlUtil.escape(s) %></del></li><% } %>
        <% for (String s : e.getValue().get(1)) { %><li class="added"><ins><%= HtmlUtil.escape(s) %></ins></li><% } %>
    </ul>
    <% } %>
    <% } %>
    <% if (!draftChanges.isEmpty()) { %>
    <details><summary><%= draftChanges.size() %> edits logged in this draft</summary>
        <ul class="rule-list small">
            <% for (RuleChange c : draftChanges) { %><li><%= DateUtil.format(c.getChangedAt()) %> - <%= HtmlUtil.escape(c.getTableName()) %>.<%= HtmlUtil.escape(c.getColumnName()) %>: <%= HtmlUtil.orDash(c.getOldValue()) %> &rarr; <%= HtmlUtil.orDash(c.getNewValue()) %> (<%= HtmlUtil.orDash(c.getChangedByName()) %>)</li><% } %>
        </ul>
    </details>
    <% } %>
    <div class="form-actions">
        <form action="rule-version-action.jsp" method="post">
            <input type="hidden" name="action" value="discard"><input type="hidden" name="exam" value="<%= exam.getId() %>"><input type="hidden" name="version" value="<%= draft.getId() %>">
            <button type="submit" class="btn" data-confirm="Throw away this draft and all its edits?">Discard draft</button>
        </form>
        <form action="rule-version-action.jsp" method="post">
            <input type="hidden" name="action" value="publish"><input type="hidden" name="exam" value="<%= exam.getId() %>"><input type="hidden" name="version" value="<%= draft.getId() %>">
            <button type="submit" class="btn btn-primary" data-confirm="Publish draft v<%= draft.getVersionNo() %>? Students who track <%= HtmlUtil.escape(exam.getShortName()) %> are notified and their results are recalculated.">Publish v<%= draft.getVersionNo() %></button>
        </form>
    </div>
</section>
<% } %>

<% if (viewedRules != null) { %>
<!-- =================================== READ-ONLY VIEW =================================== -->
<section class="card" id="viewed">
    <h2><%= viewed == null ? "Active rules" : "Version v" + viewed.getVersionNo() + " (" + viewed.getStatus().toLowerCase() + ", read only)" %></h2>
    <% Map<String, List<String>> sigs = RuleDiff.signatures(viewedRules);
       for (Map.Entry<String, List<String>> e : sigs.entrySet()) { %>
    <h3><%= e.getKey() %></h3>
    <ul class="rule-list">
        <% if (e.getValue().isEmpty()) { %><li class="empty">none</li><% } %>
        <% for (String s : e.getValue()) { %><li><%= HtmlUtil.escape(s) %></li><% } %>
    </ul>
    <% } %>
</section>
<% } %>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
