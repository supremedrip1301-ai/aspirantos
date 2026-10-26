<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.*, java.time.LocalDate, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.util.HtmlUtil, com.aspirantos.util.DateUtil, com.aspirantos.util.ValidationUtil" %>
<%--
    Attempt journal (view page): every attempt the student logged, grouped by exam as a timeline,
    plus the form to log or edit one. Whether an attempt COUNTS is decided by the database trigger
    trg_attempt_log_bi from the exam's counting rule (e.g. "applied only" does not count for UPSC).
--%>
<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>
<%@ include file="/WEB-INF/jspf/aspirant-only.jspf" %>
<%!
    // declaration: words for the stage_reached values
    private static final String[][] STAGES = {
        {"APPLIED_ONLY", "Applied only (did not appear)"},
        {"ABSENT", "Absent on the exam day"},
        {"APPEARED_STAGE_1", "Appeared in the first stage"},
        {"CLEARED_STAGE_1", "Cleared the first stage"},
        {"APPEARED_STAGE_2", "Appeared in the second stage"},
        {"CLEARED_STAGE_2", "Cleared the second stage"},
        {"INTERVIEW", "Reached the interview"},
        {"FINAL_SELECTED", "Finally selected"}
    };

    private String stageLabel(String code) {
        for (String[] s : STAGES) {
            if (s[0].equals(code)) {
                return s[1];
            }
        }
        return code;
    }
%>
<%
    ExamDAO examDAO = new ExamDAO();
    AttemptDAO attemptDAO = new AttemptDAO();
    List<AttemptLog> attempts = attemptDAO.getAttemptsByUser(currentUser.getId());
    List<Exam> allExams = examDAO.getAllExams();
    Map<Integer, Exam> examById = new HashMap<>();
    for (Exam x : allExams) {
        examById.put(x.getId(), x);
    }
    // group the attempts by exam, keeping the newest-first order of the DAO
    Map<Integer, List<AttemptLog>> byExam = new LinkedHashMap<>();
    for (AttemptLog a : attempts) {
        List<AttemptLog> list = byExam.get(a.getExamId());
        if (list == null) {
            list = new ArrayList<>();
            byExam.put(a.getExamId(), list);
        }
        list.add(a);
    }
    Set<Integer> trackedIds = new HashSet<>();
    for (Tracking t : new TrackingDAO().getTrackingByUser(currentUser.getId())) {
        trackedIds.add(t.getExamId());
    }

    // form: values after an error, or the attempt being edited, or a new one (?exam=<id> preselects)
    AttemptLog form = (AttemptLog) session.getAttribute("formAttempt");
    if (form != null) {
        session.removeAttribute("formAttempt");
    } else if (request.getParameter("edit") != null) {
        Integer editId = ValidationUtil.parseIntOrNull(request.getParameter("edit"));
        form = editId == null ? null : attemptDAO.getAttempt(editId);
        if (form != null && form.getUserId() != currentUser.getId()) {
            form = null;
        }
    }
    if (form == null) {
        form = new AttemptLog();
        form.setCycleYear(new com.aspirantos.dao.SettingDAO().getToday().getYear());
        form.setSittingNo(1);
        form.setStageReached("APPEARED_STAGE_1");
        Integer pre = ValidationUtil.parseIntOrNull(request.getParameter("exam"));
        if (pre != null && examById.containsKey(pre)) {
            form.setExamId(pre);
        }
    }
    boolean editing = form.getId() > 0;

    String pageTitle = "Attempt journal";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<h1>Attempt journal</h1>
<p class="muted">Log every exam you sit. Attempts you used before joining are in <a href="profile-step4.jsp">your profile</a>.</p>
<%@ include file="/WEB-INF/jspf/flash.jspf" %>

<div class="journal-layout">
    <section>
        <% if (byExam.isEmpty()) { %>
        <div class="card empty-state">
            <h2>No attempts logged yet</h2>
            <p>After each exam, add it here - the app then counts your attempts left automatically.</p>
        </div>
        <% } %>
        <% for (Map.Entry<Integer, List<AttemptLog>> entry : byExam.entrySet()) {
               Exam x = examById.get(entry.getKey());
               int counted = 0;
               for (AttemptLog a : entry.getValue()) {
                   if (a.isCountsAsAttempt()) {
                       counted++;
                   }
               } %>
        <article class="card timeline-card">
            <h2><a href="exam-detail.jsp?id=<%= entry.getKey() %>"><%= x == null ? "Exam" : HtmlUtil.escape(x.getShortName()) %></a>
                <span class="muted small"><%= counted %> counted attempt<%= counted == 1 ? "" : "s" %> logged</span></h2>
            <ol class="timeline">
                <% for (AttemptLog a : entry.getValue()) { %>
                <li class="<%= a.isCountsAsAttempt() ? "counts" : "not-counted" %>">
                    <div class="when mono"><%= a.getCycleYear() %><%= a.getSittingNo() > 1 ? " (" + a.getSittingNo() + ")" : "" %></div>
                    <div class="what">
                        <strong><%= stageLabel(a.getStageReached()) %></strong>
                        <span class="tag <%= a.isCountsAsAttempt() ? "tag-counts" : "" %>"><%= a.isCountsAsAttempt() ? "counts as an attempt" : "does not count" %></span>
                        <div class="small muted">
                            <%= a.getAttemptDate() != null ? DateUtil.format(a.getAttemptDate()) : "" %>
                            <%= a.getScore() != null ? " &middot; score " + a.getScore() : "" %>
                            <%= a.getRankObtained() != null ? " &middot; rank " + a.getRankObtained() : "" %>
                        </div>
                        <% if (a.getRemarks() != null) { %><p class="small"><%= HtmlUtil.escape(a.getRemarks()) %></p><% } %>
                        <div class="row-actions">
                            <a href="journal.jsp?edit=<%= a.getId() %>#log">Edit</a>
                            <a href="attempt-action.jsp?action=delete&amp;id=<%= a.getId() %>" data-confirm="Delete this attempt from your journal?">Delete</a>
                        </div>
                    </div>
                </li>
                <% } %>
            </ol>
        </article>
        <% } %>
    </section>

    <form id="log" class="card" action="attempt-action.jsp" method="post" data-validate="attempt" novalidate>
        <h2><%= editing ? "Edit attempt" : "Log an attempt" %></h2>
        <input type="hidden" name="action" value="save">
        <input type="hidden" name="id" value="<%= form.getId() %>">
        <label for="examId">Exam</label>
        <% if (editing) { %>
        <input type="hidden" name="examId" value="<%= form.getExamId() %>">
        <p><strong><%= HtmlUtil.escape(examById.containsKey(form.getExamId()) ? examById.get(form.getExamId()).getShortName() : "") %></strong></p>
        <% } else { %>
        <select id="examId" name="examId" required>
            <option value="">Choose the exam...</option>
            <% if (!trackedIds.isEmpty()) { %>
            <optgroup label="Tracked exams">
                <% for (Exam x : allExams) { if (trackedIds.contains(x.getId())) { %>
                <option value="<%= x.getId() %>" <%= HtmlUtil.selected(form.getExamId(), String.valueOf(x.getId())) %>><%= HtmlUtil.escape(x.getShortName()) %></option>
                <% } } %>
            </optgroup>
            <% } %>
            <%  String group = null;
                for (Exam x : allExams) {
                    if (trackedIds.contains(x.getId())) {
                        continue;
                    }
                    if (!x.getCategoryName().equals(group)) {
                        if (group != null) { %></optgroup><% }
                        group = x.getCategoryName(); %>
            <optgroup label="<%= HtmlUtil.escape(group) %>">
            <%      } %>
                <option value="<%= x.getId() %>" <%= HtmlUtil.selected(form.getExamId(), String.valueOf(x.getId())) %>><%= HtmlUtil.escape(x.getShortName()) %></option>
            <%  }
                if (group != null) { %></optgroup><% } %>
        </select>
        <% } %>

        <div class="form-grid">
            <div>
                <label for="cycleYear">Exam year</label>
                <input type="number" id="cycleYear" name="cycleYear" value="<%= form.getCycleYear() %>" min="1990" max="2100" required>
            </div>
            <div>
                <label for="sittingNo">Sitting <span class="muted">(1 or 2 ...)</span></label>
                <input type="number" id="sittingNo" name="sittingNo" value="<%= form.getSittingNo() <= 0 ? 1 : form.getSittingNo() %>" min="1" max="12">
            </div>
        </div>
        <label for="attemptDate">Exam date <span class="muted">(needed for GRE / GMAT retake rules)</span></label>
        <input type="date" id="attemptDate" name="attemptDate" value="<%= DateUtil.toInput(form.getAttemptDate()) %>">

        <label for="stageReached">How far did you get?</label>
        <select id="stageReached" name="stageReached" required>
            <% for (String[] s : STAGES) { %>
            <option value="<%= s[0] %>" <%= HtmlUtil.selected(form.getStageReached(), s[0]) %>><%= s[1] %></option>
            <% } %>
        </select>
        <div class="form-grid">
            <div>
                <label for="score">Score <span class="muted">(optional)</span></label>
                <input type="number" id="score" name="score" value="<%= form.getScore() == null ? "" : form.getScore() %>" step="0.01" min="-9999" max="99999">
            </div>
            <div>
                <label for="rankObtained">Rank <span class="muted">(optional)</span></label>
                <input type="number" id="rankObtained" name="rankObtained" value="<%= form.getRankObtained() == null ? "" : form.getRankObtained() %>" min="1">
            </div>
        </div>
        <label for="remarks">Notes <span class="muted">(optional)</span></label>
        <textarea id="remarks" name="remarks" rows="2" maxlength="500"><%= HtmlUtil.escape(form.getRemarks()) %></textarea>
        <div class="form-actions">
            <% if (editing) { %><a class="btn" href="journal.jsp">Cancel</a><% } %>
            <button type="submit" class="btn btn-primary"><%= editing ? "Save changes" : "Add to journal" %></button>
        </div>
    </form>
</div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
