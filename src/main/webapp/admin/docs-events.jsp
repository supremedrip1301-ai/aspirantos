<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.*, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.util.HtmlUtil, com.aspirantos.util.DateUtil, com.aspirantos.util.RuleText, com.aspirantos.util.ValidationUtil" %>
<%--
    Document specs and calendar of one exam (admin page): photo / signature size rules and the
    exam dates (notification, last date to apply, exam days, result). Both tables are edited
    with doc-event-action.jsp; ?editDoc=<id> / ?editEvent=<id> fill the forms.
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%!
    private static final String[][] DOC_TYPES = {{"PHOTO", "Photo"}, {"SIGNATURE", "Signature"}, {"LEFT_THUMB", "Left thumb impression"},
            {"HANDWRITTEN_DECLARATION", "Handwritten declaration"}, {"CATEGORY_CERT", "Category certificate"}, {"PWBD_CERT", "PwBD certificate"}, {"OTHER", "Other"}};
    private static final String[][] EVENT_TYPES = {{"NOTIFICATION", "Notification"}, {"APPLY_START", "Applications open"}, {"APPLY_END", "Last date to apply"},
            {"ADMIT_CARD", "Admit card"}, {"STAGE_1", "First stage / prelims"}, {"STAGE_2", "Second stage / mains"}, {"STAGE_3", "Third stage / interview"}, {"RESULT", "Result"}};

    private String label(String[][] list, String code) {
        for (String[] o : list) {
            if (o[0].equals(code)) {
                return o[1];
            }
        }
        return code;
    }

    private String value(Object o) {
        return o == null ? "" : String.valueOf(o);
    }
%>
<%
    Integer examId = ValidationUtil.parseIntOrNull(request.getParameter("exam"));
    Exam exam = examId == null ? null : new ExamDAO().getExam(examId);
    if (exam == null) {
        session.setAttribute("error", "That exam was not found.");
        response.sendRedirect("exams.jsp");
        return;
    }
    List<DocSpec> docs = new DocSpecDAO().getDocSpecsByExam(exam.getId());
    List<ExamEvent> events = new ExamEventDAO().getEventsByExam(exam.getId());
    Collections.reverse(events);   // newest first

    DocSpec doc = (DocSpec) session.getAttribute("formDoc");
    if (doc != null) {
        session.removeAttribute("formDoc");
    } else {
        Integer editDoc = ValidationUtil.parseIntOrNull(request.getParameter("editDoc"));
        for (DocSpec d : docs) {
            if (editDoc != null && d.getId() == editDoc) {
                doc = d;
            }
        }
    }
    if (doc == null) {
        doc = new DocSpec();
        doc.setDocType("PHOTO");
    }
    ExamEvent ev = (ExamEvent) session.getAttribute("formEvent");
    if (ev != null) {
        session.removeAttribute("formEvent");
    } else {
        Integer editEvent = ValidationUtil.parseIntOrNull(request.getParameter("editEvent"));
        for (ExamEvent e : events) {
            if (editEvent != null && e.getId() == editEvent) {
                ev = e;
            }
        }
    }
    if (ev == null) {
        ev = new ExamEvent();
        ev.setCycleYear(new SettingDAO().getToday().getYear() + 1);
        ev.setEventType("STAGE_1");
        ev.setTentative(true);
    }
    String pageTitle = "Documents and dates - " + exam.getShortName();
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<p class="crumbs"><a href="exams.jsp">Exams</a> / <a href="rules.jsp?exam=<%= exam.getId() %>"><%= HtmlUtil.escape(exam.getShortName()) %></a> / Documents and dates</p>
<h1>Documents and dates of <%= HtmlUtil.escape(exam.getShortName()) %></h1>
<%@ include file="/WEB-INF/jspf/flash.jspf" %>

<section class="card" id="docs">
    <h2>Photo, signature and document rules</h2>
    <div class="table-wrap"><table>
        <thead><tr><th>Document</th><th>Size</th><th>File size</th><th>Formats</th><th>Notes</th><th></th></tr></thead>
        <tbody>
        <% if (docs.isEmpty()) { %><tr><td colspan="6" class="empty">No document rules yet.</td></tr><% } %>
        <% for (DocSpec d : docs) { %>
        <tr>
            <td><%= label(DOC_TYPES, d.getDocType()) %></td>
            <td class="mono small"><%= RuleText.docSize(d) %></td>
            <td class="mono small"><%= RuleText.docKb(d) %></td>
            <td><%= HtmlUtil.orDash(d.getAllowedFormats()) %></td>
            <td class="small"><%= HtmlUtil.escape(d.getBackgroundRule()) %> <%= d.isRequiresNameAndDate() ? "name + date on photo. " : "" %><%= HtmlUtil.escape(d.getNotes()) %></td>
            <td class="actions"><a href="docs-events.jsp?exam=<%= exam.getId() %>&amp;editDoc=<%= d.getId() %>#doc-form">Edit</a>
                <a href="doc-event-action.jsp?kind=doc&amp;action=delete&amp;exam=<%= exam.getId() %>&amp;id=<%= d.getId() %>" data-confirm="Delete this document rule?">Delete</a></td>
        </tr>
        <% } %>
        </tbody>
    </table></div>
    <form id="doc-form" class="sub-form" action="doc-event-action.jsp" method="post" novalidate>
        <h3><%= doc.getId() > 0 ? "Edit " + label(DOC_TYPES, doc.getDocType()).toLowerCase() : "Add or replace a document rule" %></h3>
        <input type="hidden" name="kind" value="doc"><input type="hidden" name="action" value="save"><input type="hidden" name="exam" value="<%= exam.getId() %>">
        <div class="form-grid">
            <div><label for="docType">Document</label>
                <select id="docType" name="docType"><% for (String[] o : DOC_TYPES) { %><option value="<%= o[0] %>" <%= HtmlUtil.selected(doc.getDocType(), o[0]) %>><%= o[1] %></option><% } %></select>
                <p class="hint">Saving a document that already exists replaces its rule.</p></div>
            <div><label for="allowedFormats">Formats</label><input type="text" id="allowedFormats" name="allowedFormats" value="<%= HtmlUtil.escape(doc.getAllowedFormats()) %>" maxlength="60" placeholder="JPG,JPEG"></div>
            <div class="pair"><div><label for="minWidthPx">Width from (px)</label><input type="number" id="minWidthPx" name="minWidthPx" value="<%= value(doc.getMinWidthPx()) %>" min="1" max="10000"></div>
                <div><label for="maxWidthPx">to</label><input type="number" id="maxWidthPx" name="maxWidthPx" value="<%= value(doc.getMaxWidthPx()) %>" min="1" max="10000"></div></div>
            <div class="pair"><div><label for="minHeightPx">Height from (px)</label><input type="number" id="minHeightPx" name="minHeightPx" value="<%= value(doc.getMinHeightPx()) %>" min="1" max="10000"></div>
                <div><label for="maxHeightPx">to</label><input type="number" id="maxHeightPx" name="maxHeightPx" value="<%= value(doc.getMaxHeightPx()) %>" min="1" max="10000"></div></div>
            <div class="pair"><div><label for="minKb">File size from (KB)</label><input type="number" id="minKb" name="minKb" value="<%= value(doc.getMinKb()) %>" min="1" max="10000"></div>
                <div><label for="maxKb">to</label><input type="number" id="maxKb" name="maxKb" value="<%= value(doc.getMaxKb()) %>" min="1" max="10000"></div></div>
            <div><label for="backgroundRule">Background</label><input type="text" id="backgroundRule" name="backgroundRule" value="<%= HtmlUtil.escape(doc.getBackgroundRule()) %>" maxlength="60" placeholder="WHITE_OR_LIGHT"></div>
            <div><label for="maxPhotoAgeMonths">Photo not older than (months)</label><input type="number" id="maxPhotoAgeMonths" name="maxPhotoAgeMonths" value="<%= value(doc.getMaxPhotoAgeMonths()) %>" min="1" max="60"></div>
            <div class="span-2"><label for="docNotes">Notes (start with "Official:" when copied from the notice)</label><input type="text" id="docNotes" name="notes" value="<%= HtmlUtil.escape(doc.getNotes()) %>" maxlength="500"></div>
        </div>
        <label class="check"><input type="checkbox" name="requiresNameAndDate" value="true" <%= HtmlUtil.checked(doc.isRequiresNameAndDate()) %>> Name and date must be printed on the photo</label>
        <div class="form-actions"><% if (doc.getId() > 0) { %><a class="btn" href="docs-events.jsp?exam=<%= exam.getId() %>">Cancel</a><% } %><button type="submit" class="btn btn-primary">Save document rule</button></div>
    </form>
</section>

<section class="card" id="events">
    <h2>Calendar</h2>
    <div class="table-wrap"><table>
        <thead><tr><th>Cycle</th><th>Event</th><th>Date</th><th>Status</th><th>Notes</th><th></th></tr></thead>
        <tbody>
        <% if (events.isEmpty()) { %><tr><td colspan="6" class="empty">No dates yet.</td></tr><% } %>
        <% for (ExamEvent e : events) { %>
        <tr>
            <td class="mono"><%= e.getCycleYear() %></td>
            <td><%= label(EVENT_TYPES, e.getEventType()) %></td>
            <td class="mono"><%= DateUtil.format(e.getEventDate()) %></td>
            <td><%= e.isTentative() ? "Tentative" : "Official" %></td>
            <td class="small"><%= HtmlUtil.orDash(e.getNotes()) %></td>
            <td class="actions"><a href="docs-events.jsp?exam=<%= exam.getId() %>&amp;editEvent=<%= e.getId() %>#event-form">Edit</a>
                <a href="doc-event-action.jsp?kind=event&amp;action=delete&amp;exam=<%= exam.getId() %>&amp;id=<%= e.getId() %>" data-confirm="Delete this date?">Delete</a></td>
        </tr>
        <% } %>
        </tbody>
    </table></div>
    <form id="event-form" class="sub-form" action="doc-event-action.jsp" method="post" novalidate>
        <h3><%= ev.getId() > 0 ? "Edit date" : "Add or replace a date" %></h3>
        <input type="hidden" name="kind" value="event"><input type="hidden" name="action" value="save"><input type="hidden" name="exam" value="<%= exam.getId() %>">
        <div class="form-grid">
            <div><label for="cycleYear">Exam cycle (year)</label><input type="number" id="cycleYear" name="cycleYear" value="<%= ev.getCycleYear() %>" min="2000" max="2100" required></div>
            <div><label for="eventType">Event</label>
                <select id="eventType" name="eventType"><% for (String[] o : EVENT_TYPES) { %><option value="<%= o[0] %>" <%= HtmlUtil.selected(ev.getEventType(), o[0]) %>><%= o[1] %></option><% } %></select>
                <p class="hint">One date per cycle and event - saving again replaces it.</p></div>
            <div><label for="eventDate">Date</label><input type="date" id="eventDate" name="eventDate" value="<%= DateUtil.toInput(ev.getEventDate()) %>" required></div>
            <div><label for="eventNotes">Notes</label><input type="text" id="eventNotes" name="notes" value="<%= HtmlUtil.escape(ev.getNotes()) %>" maxlength="255"></div>
        </div>
        <label class="check"><input type="checkbox" name="tentative" value="true" <%= HtmlUtil.checked(ev.isTentative()) %>> Tentative (not yet announced officially)</label>
        <div class="form-actions"><% if (ev.getId() > 0) { %><a class="btn" href="docs-events.jsp?exam=<%= exam.getId() %>#events">Cancel</a><% } %><button type="submit" class="btn btn-primary">Save date</button></div>
    </form>
</section>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
