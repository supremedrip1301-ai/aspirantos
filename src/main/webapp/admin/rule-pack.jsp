<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.*, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.engine.ExamRuleSet, com.aspirantos.service.EligibilityService, com.aspirantos.service.RulePackParser, com.aspirantos.util.HtmlUtil, com.aspirantos.util.RuleDiff" %>
<%--
    Rule pack (admin view page): export the active rules as CSV (Excel), and import a CSV pack:
    paste it (or pick a .csv file - the browser reads it into the box), preview every row with
    its problems and the differences, then apply all exams in one transaction as new versions.
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%
    RulePackParser.RulePack pack = (RulePackParser.RulePack) session.getAttribute("rulePack");
    String[] meta = (String[]) session.getAttribute("rulePackMeta");   // summary, source, applies-from, csv text
    List<ExamCategory> categories = new CategoryDAO().getAllCategories();
    EligibilityService eligibility = new EligibilityService();
    RuleVersionDAO versionDAO = new RuleVersionDAO();
    String pageTitle = "Rule pack";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<h1>Rule pack</h1>
<p class="muted">A rule pack is a CSV file with the rules of one or many exams. Export the current rules, change them in Excel, and import them back: for every exam in the file its rows become the complete new rule version.</p>
<details class="card format-box">
    <summary>Columns of a rule pack</summary>
    <p class="small">One line per rule row. <strong>rule_table</strong> is AGE, RELAXATION, ATTEMPT, QUALIFICATION or OTHER; leave the columns of other tables empty. Yes/no columns take 1 or 0. Lines starting with # are ignored.</p>
    <p class="mono small"><%= String.join(", ", RulePackParser.COLUMNS) %></p>
</details>
<%@ include file="/WEB-INF/jspf/flash.jspf" %>

<div class="grid settings-grid">
    <section class="card">
        <h2>Export</h2>
        <form action="rule-pack-export.jsp" method="get">
            <label for="category">Category</label>
            <select id="category" name="category">
                <option value="">All exams</option>
                <% for (ExamCategory c : categories) { %><option value="<%= c.getCode() %>"><%= HtmlUtil.escape(c.getName()) %> (<%= c.getExamCount() %>)</option><% } %>
            </select>
            <label for="code">or one exam code <span class="muted">(optional)</span></label>
            <input type="text" id="code" name="code" maxlength="40" placeholder="UPSC_CSE">
            <div class="form-actions"><button type="submit" class="btn btn-primary">Download CSV</button></div>
        </form>
    </section>

    <section class="card">
        <h2>Import</h2>
        <form action="rule-pack-action.jsp" method="post" novalidate>
            <input type="hidden" name="action" value="preview">
            <label for="csvFile">Pick a .csv file <span class="muted">(or paste below)</span></label>
            <input type="file" id="csvFile" accept=".csv,text/csv" data-fill-textarea="csv">
            <label for="csv">CSV text</label>
            <textarea id="csv" name="csv" rows="7" class="mono small" spellcheck="false"><%= meta == null ? "" : HtmlUtil.escape(meta[3]) %></textarea>
            <label for="summary">What changed? (saved with every new version)</label>
            <input type="text" id="summary" name="summary" maxlength="500" value="<%= meta == null ? "" : HtmlUtil.escape(meta[0]) %>">
            <div class="form-grid">
                <div><label for="sourceUrl">Official source <span class="muted">(optional)</span></label>
                    <input type="url" id="sourceUrl" name="sourceUrl" maxlength="500" value="<%= meta == null ? "" : HtmlUtil.escape(meta[1]) %>" placeholder="https://"></div>
                <div><label for="appliesFrom">Applies from cycle <span class="muted">(optional)</span></label>
                    <input type="number" id="appliesFrom" name="appliesFrom" min="2000" max="2100" value="<%= meta == null ? "" : HtmlUtil.escape(meta[2]) %>"></div>
            </div>
            <div class="form-actions"><button type="submit" class="btn btn-primary">Check the pack</button></div>
        </form>
    </section>
</div>

<% if (pack != null) { %>
<section class="card" id="preview">
    <h2>Preview</h2>
    <p><strong><%= pack.rows.size() %></strong> rows for <strong><%= pack.byExam.size() %></strong> exam<%= pack.byExam.size() == 1 ? "" : "s" %>,
       <strong class="<%= pack.errorCount() > 0 ? "warn-text" : "" %>"><%= pack.errorCount() %></strong> problem<%= pack.errorCount() == 1 ? "" : "s" %>.</p>

    <% if (pack.errorCount() > 0) { %>
    <h3>Problems - fix them in the CSV and check again</h3>
    <ul class="rule-list">
        <% for (String p : pack.problems) { %><li class="warn-text"><%= HtmlUtil.escape(p) %></li><% } %>
        <% for (RulePackParser.PackRow r : pack.rows) { if (r.error != null) { %>
        <li>Line <span class="mono"><%= r.lineNo %></span> (<%= HtmlUtil.escape(r.examCode) %>, <%= HtmlUtil.escape(r.table) %>): <%= HtmlUtil.escape(r.error) %></li>
        <% } } %>
    </ul>
    <% } %>

    <% boolean anyDraft = false;
       for (Map.Entry<String, ExamRuleSet> e : pack.byExam.entrySet()) {
           Exam x = e.getValue().getExam();
           boolean draft = versionDAO.getDraft(x.getId()) != null;
           anyDraft = anyDraft || draft;
           Map<String, List<List<String>>> diff = RuleDiff.diff(eligibility.loadRuleSet(x), e.getValue()); %>
    <details class="pack-exam" <%= pack.byExam.size() <= 3 ? "open" : "" %>>
        <summary><strong><%= HtmlUtil.escape(x.getShortName()) %></strong> <span class="mono small"><%= HtmlUtil.escape(x.getCode()) %></span>
            - <%= RuleDiff.rowCount(e.getValue()) %> rows, <%= diff.isEmpty() ? "no change" : diff.size() + " part(s) changed" %><%= draft ? " - has an open draft!" : "" %></summary>
        <% if (draft) { %><p class="warn-text">This exam has an open draft. Publish or discard it before applying the pack.</p><% } %>
        <% for (Map.Entry<String, List<List<String>>> d : diff.entrySet()) { %>
        <h4><%= d.getKey() %></h4>
        <ul class="diff-list">
            <% for (String s : d.getValue().get(0)) { %><li class="removed"><del><%= HtmlUtil.escape(s) %></del></li><% } %>
            <% for (String s : d.getValue().get(1)) { %><li class="added"><ins><%= HtmlUtil.escape(s) %></ins></li><% } %>
        </ul>
        <% } %>
    </details>
    <% } %>

    <div class="form-actions">
        <form action="rule-pack-action.jsp" method="post"><input type="hidden" name="action" value="clear"><button type="submit" class="btn">Cancel</button></form>
        <form action="rule-pack-action.jsp" method="post">
            <input type="hidden" name="action" value="apply">
            <button type="submit" class="btn btn-primary" <%= pack.errorCount() > 0 || pack.byExam.isEmpty() || anyDraft ? "disabled" : "" %>
                    data-confirm="Publish new rule versions for <%= pack.byExam.size() %> exam(s)? Students who track them are notified.">Apply the pack</button>
        </form>
    </div>
</section>
<% } %>
<script src="<%= ctx %>/assets/js/rule-pack.js"></script>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
