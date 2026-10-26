<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.*, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.util.HtmlUtil, com.aspirantos.util.DateUtil, com.aspirantos.util.ValidationUtil" %>
<%--
    Add / edit an exam (admin form page, like edit-student.jsp of Experiment 4): the form is
    filled from the exam row (?id=) or from the values kept after a validation error.
    It posts to exam-action.jsp. The rules of the exam are edited on rules.jsp.
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%
    Exam x = (Exam) session.getAttribute("formExam");
    if (x != null) {
        session.removeAttribute("formExam");
    } else {
        Integer id = ValidationUtil.parseIntOrNull(request.getParameter("id"));
        x = id == null ? null : new ExamDAO().getExam(id);
    }
    if (x == null) {
        x = new Exam();
        x.setScope("NATIONAL");
        x.setSector("GOVERNMENT");
        x.setPurpose("RECRUITMENT");
        x.setCyclesPerYear(1.0);
        x.setDataConfidence("NEEDS_VERIFICATION");
        x.setActive(true);
    }
    boolean editing = x.getId() > 0;
    List<ExamCategory> categories = new CategoryDAO().getAllCategories();
    List<ConductingBody> bodies = new CategoryDAO().getAllBodies();
    List<State> states = new StateDAO().getAllStates();
    String[] months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
    String pageTitle = editing ? "Edit " + x.getShortName() : "Add an exam";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<p class="crumbs"><a href="exams.jsp">Exams</a> / <%= editing ? HtmlUtil.escape(x.getShortName()) : "New" %></p>
<h1><%= editing ? "Edit " + HtmlUtil.escape(x.getShortName()) : "Add an exam" %></h1>
<%@ include file="/WEB-INF/jspf/flash.jspf" %>

<form class="card wide-form" action="exam-action.jsp" method="post" data-validate="exam" novalidate>
    <input type="hidden" name="action" value="save">
    <input type="hidden" name="id" value="<%= x.getId() %>">
    <div class="form-grid">
        <div>
            <label for="code">Code <span class="muted">(capital letters, digits, _ ; cannot be changed later)</span></label>
            <input type="text" id="code" name="code" value="<%= HtmlUtil.escape(x.getCode()) %>" maxlength="40" pattern="[A-Z0-9_]{2,40}" <%= editing ? "readonly" : "required" %>>
        </div>
        <div>
            <label for="shortName">Short name</label>
            <input type="text" id="shortName" name="shortName" value="<%= HtmlUtil.escape(x.getShortName()) %>" maxlength="60" required>
        </div>
        <div class="span-2">
            <label for="name">Full name</label>
            <input type="text" id="name" name="name" value="<%= HtmlUtil.escape(x.getName()) %>" maxlength="200" required>
        </div>
        <div>
            <label for="categoryId">Category</label>
            <select id="categoryId" name="categoryId" required>
                <option value="">Choose...</option>
                <% for (ExamCategory c : categories) { %><option value="<%= c.getId() %>" <%= HtmlUtil.selected(x.getCategoryId(), String.valueOf(c.getId())) %>><%= HtmlUtil.escape(c.getName()) %></option><% } %>
            </select>
        </div>
        <div>
            <label for="bodyId">Conducting body</label>
            <select id="bodyId" name="bodyId" required>
                <option value="">Choose...</option>
                <% for (ConductingBody b : bodies) { %><option value="<%= b.getId() %>" <%= HtmlUtil.selected(x.getBodyId(), String.valueOf(b.getId())) %>><%= HtmlUtil.escape(b.getShortName()) %> - <%= HtmlUtil.escape(b.getFullName()) %></option><% } %>
            </select>
        </div>
        <div>
            <label for="scope">Level</label>
            <select id="scope" name="scope">
                <option value="NATIONAL" <%= HtmlUtil.selected(x.getScope(), "NATIONAL") %>>National</option>
                <option value="STATE" <%= HtmlUtil.selected(x.getScope(), "STATE") %>>State</option>
                <option value="INTERNATIONAL" <%= HtmlUtil.selected(x.getScope(), "INTERNATIONAL") %>>International</option>
            </select>
        </div>
        <div>
            <label for="stateCode">State <span class="muted">(only for state exams)</span></label>
            <select id="stateCode" name="stateCode">
                <option value="">-</option>
                <% for (State s : states) { %><option value="<%= s.getCode() %>" <%= HtmlUtil.selected(x.getStateCode(), s.getCode()) %>><%= HtmlUtil.escape(s.getName()) %></option><% } %>
            </select>
        </div>
        <div>
            <label for="sector">Sector</label>
            <select id="sector" name="sector">
                <option value="GOVERNMENT" <%= HtmlUtil.selected(x.getSector(), "GOVERNMENT") %>>Government</option>
                <option value="AUTONOMOUS" <%= HtmlUtil.selected(x.getSector(), "AUTONOMOUS") %>>Autonomous</option>
                <option value="PRIVATE" <%= HtmlUtil.selected(x.getSector(), "PRIVATE") %>>Private</option>
            </select>
        </div>
        <div>
            <label for="purpose">Purpose</label>
            <select id="purpose" name="purpose">
                <% String[] purposes = {"RECRUITMENT", "ADMISSION", "CERTIFICATION", "LICENSING", "FELLOWSHIP", "SCHOLARSHIP"};
                   for (String pu : purposes) { %><option value="<%= pu %>" <%= HtmlUtil.selected(x.getPurpose(), pu) %>><%= pu.charAt(0) + pu.substring(1).toLowerCase() %></option><% } %>
            </select>
        </div>
        <div>
            <label for="cyclesPerYear">Sittings per year <span class="muted">(0.5 = once in two years)</span></label>
            <input type="number" id="cyclesPerYear" name="cyclesPerYear" value="<%= x.getCyclesPerYear() %>" min="0.5" max="12" step="0.5" required>
        </div>
        <div class="pair">
            <div>
                <label for="typicalNotificationMonth">Notification month</label>
                <select id="typicalNotificationMonth" name="typicalNotificationMonth">
                    <option value="">-</option>
                    <% for (int m = 1; m <= 12; m++) { %><option value="<%= m %>" <%= HtmlUtil.selected(x.getTypicalNotificationMonth(), String.valueOf(m)) %>><%= months[m - 1] %></option><% } %>
                </select>
            </div>
            <div>
                <label for="typicalExamMonth">Exam month</label>
                <select id="typicalExamMonth" name="typicalExamMonth">
                    <option value="">-</option>
                    <% for (int m = 1; m <= 12; m++) { %><option value="<%= m %>" <%= HtmlUtil.selected(x.getTypicalExamMonth(), String.valueOf(m)) %>><%= months[m - 1] %></option><% } %>
                </select>
            </div>
        </div>
        <div class="span-2">
            <label for="stagesSummary">Stages</label>
            <input type="text" id="stagesSummary" name="stagesSummary" value="<%= HtmlUtil.escape(x.getStagesSummary()) %>" maxlength="255" placeholder="Prelims, Mains, Interview">
        </div>
        <div class="span-2">
            <label for="postsOrCourses">Posts / courses</label>
            <input type="text" id="postsOrCourses" name="postsOrCourses" value="<%= HtmlUtil.escape(x.getPostsOrCourses()) %>" maxlength="500">
        </div>
        <div>
            <label for="officialUrl">Official website</label>
            <input type="url" id="officialUrl" name="officialUrl" value="<%= HtmlUtil.escape(x.getOfficialUrl()) %>" maxlength="500" placeholder="https://">
        </div>
        <div>
            <label for="watchUrl">Page to watch for updates <span class="muted">(optional)</span></label>
            <input type="url" id="watchUrl" name="watchUrl" value="<%= HtmlUtil.escape(x.getWatchUrl()) %>" maxlength="500" placeholder="https://">
        </div>
        <div class="span-2">
            <label for="description">Description</label>
            <textarea id="description" name="description" rows="3" maxlength="4000"><%= HtmlUtil.escape(x.getDescription()) %></textarea>
        </div>
        <div class="span-2">
            <label for="feeSummary">Fee</label>
            <input type="text" id="feeSummary" name="feeSummary" value="<%= HtmlUtil.escape(x.getFeeSummary()) %>" maxlength="500">
        </div>
        <div class="span-2">
            <label for="attemptCountingNote">How attempts are counted</label>
            <input type="text" id="attemptCountingNote" name="attemptCountingNote" value="<%= HtmlUtil.escape(x.getAttemptCountingNote()) %>" maxlength="500">
        </div>
        <div>
            <label for="dataConfidence">Data confidence</label>
            <select id="dataConfidence" name="dataConfidence">
                <option value="VERIFIED" <%= HtmlUtil.selected(x.getDataConfidence(), "VERIFIED") %>>Verified from the official notice</option>
                <option value="LIKELY" <%= HtmlUtil.selected(x.getDataConfidence(), "LIKELY") %>>Likely</option>
                <option value="NEEDS_VERIFICATION" <%= HtmlUtil.selected(x.getDataConfidence(), "NEEDS_VERIFICATION") %>>Needs verification</option>
            </select>
        </div>
        <div>
            <label for="lastVerifiedOn">Last verified on <span class="muted">(needed for "Verified")</span></label>
            <input type="date" id="lastVerifiedOn" name="lastVerifiedOn" value="<%= DateUtil.toInput(x.getLastVerifiedOn()) %>">
        </div>
        <div class="span-2">
            <label for="sourceNote">Source</label>
            <input type="text" id="sourceNote" name="sourceNote" value="<%= HtmlUtil.escape(x.getSourceNote()) %>" maxlength="500" placeholder="e.g. UPSC CSE 2026 notice, para 3">
        </div>
    </div>
    <label class="check"><input type="checkbox" name="active" value="true" <%= HtmlUtil.checked(x.isActive()) %>> Visible to students</label>
    <div class="form-actions">
        <a class="btn" href="exams.jsp">Cancel</a>
        <button type="submit" class="btn btn-primary"><%= editing ? "Save changes" : "Add exam" %></button>
    </div>
</form>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
