<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.time.LocalDate, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.util.ValidationUtil, com.aspirantos.util.DateUtil" %>
<%--
    Document spec / exam date action page (admin, no HTML). kind = doc or event,
    action = save (INSERT ... ON DUPLICATE KEY UPDATE, one row per exam + document type or
    exam + cycle + event) or delete. A changed exam date also changes the students' next cycle,
    so their cached results for that exam are deleted.
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%!
    private Integer num(HttpServletRequest r, String name) {
        return ValidationUtil.parseIntOrNull(r.getParameter(name));
    }

    private boolean range(Integer v, int min, int max) {
        return v == null || (v >= min && v <= max);
    }

    private boolean order(Integer from, Integer to) {
        return from == null || to == null || to >= from;
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    Integer examId = num(request, "exam");
    Exam exam = examId == null ? null : new ExamDAO().getExam(examId);
    if (exam == null) {
        session.setAttribute("error", "That exam was not found.");
        response.sendRedirect("exams.jsp");
        return;
    }
    String back = "docs-events.jsp?exam=" + exam.getId();
    String kind = request.getParameter("kind");
    String action = request.getParameter("action");
    Integer id = num(request, "id");

    if ("delete".equals(action) && id != null) {
        int rows = 0;
        if ("doc".equals(kind)) {
            DocSpec d = new DocSpecDAO().getDocSpec(id);
            rows = d != null && d.getExamId() == exam.getId() ? new DocSpecDAO().deleteDocSpec(id) : 0;
        } else if ("event".equals(kind)) {
            ExamEvent e = new ExamEventDAO().getEvent(id);
            rows = e != null && e.getExamId() == exam.getId() ? new ExamEventDAO().deleteEvent(id) : 0;
            if (rows > 0) {
                new SnapshotDAO().deleteSnapshotsOfExam(exam.getId());
            }
        }
        session.setAttribute(rows > 0 ? "success" : "error", rows > 0 ? "Deleted (" + rows + " row affected)." : "Nothing was deleted.");
        response.sendRedirect(back + ("doc".equals(kind) ? "#docs" : "#events"));
        return;
    }
    if (!"POST".equals(request.getMethod()) || !"save".equals(action)) {
        response.sendRedirect(back);
        return;
    }

    if ("doc".equals(kind)) {
        DocSpec d = new DocSpec();
        d.setExamId(exam.getId());
        d.setDocType(request.getParameter("docType"));
        d.setMinWidthPx(num(request, "minWidthPx"));
        d.setMaxWidthPx(num(request, "maxWidthPx"));
        d.setMinHeightPx(num(request, "minHeightPx"));
        d.setMaxHeightPx(num(request, "maxHeightPx"));
        d.setMinKb(num(request, "minKb"));
        d.setMaxKb(num(request, "maxKb"));
        String formats = ValidationUtil.clean(request.getParameter("allowedFormats"));
        d.setAllowedFormats(formats == null ? null : formats.toUpperCase().replace(" ", ""));
        String background = ValidationUtil.clean(request.getParameter("backgroundRule"));
        d.setBackgroundRule(background == null ? null : background.toUpperCase().replace(" ", "_"));
        d.setRequiresNameAndDate(request.getParameter("requiresNameAndDate") != null);
        d.setMaxPhotoAgeMonths(num(request, "maxPhotoAgeMonths"));
        d.setNotes(ValidationUtil.clean(request.getParameter("notes")));
        String error = null;
        if (!ValidationUtil.isOneOf(d.getDocType(), "PHOTO", "SIGNATURE", "LEFT_THUMB", "HANDWRITTEN_DECLARATION", "CATEGORY_CERT", "PWBD_CERT", "OTHER")) {
            error = "Please choose the document.";
        } else if (!range(d.getMinWidthPx(), 1, 10000) || !range(d.getMaxWidthPx(), 1, 10000) || !range(d.getMinHeightPx(), 1, 10000)
                || !range(d.getMaxHeightPx(), 1, 10000) || !range(d.getMinKb(), 1, 10000) || !range(d.getMaxKb(), 1, 10000)) {
            error = "Sizes must be between 1 and 10000.";
        } else if (!order(d.getMinWidthPx(), d.getMaxWidthPx()) || !order(d.getMinHeightPx(), d.getMaxHeightPx()) || !order(d.getMinKb(), d.getMaxKb())) {
            error = "Each 'to' value must be at least the 'from' value.";
        } else if (!range(d.getMaxPhotoAgeMonths(), 1, 60)) {
            error = "Photo age must be 1 to 60 months.";
        } else if (d.getAllowedFormats() != null && !d.getAllowedFormats().matches("[A-Z0-9]{2,5}(,[A-Z0-9]{2,5})*")) {
            error = "Formats: short file types separated by commas, for example JPG,JPEG,PDF.";
        } else if ((d.getBackgroundRule() != null && d.getBackgroundRule().length() > 60) || (d.getNotes() != null && d.getNotes().length() > 500)) {
            error = "Background: at most 60 characters, notes: at most 500.";
        }
        if (error != null) {
            session.setAttribute("error", error);
            session.setAttribute("formDoc", d);
            response.sendRedirect(back + "#doc-form");
            return;
        }
        int rows = new DocSpecDAO().saveDocSpec(d);
        session.setAttribute(rows > 0 ? "success" : "error", rows > 0 ? "Document rule saved." : "Nothing was saved - please check the values.");
        response.sendRedirect(back + "#docs");
        return;
    }

    if ("event".equals(kind)) {
        ExamEvent e = new ExamEvent();
        e.setExamId(exam.getId());
        Integer year = num(request, "cycleYear");
        e.setCycleYear(year == null ? 0 : year);
        e.setEventType(request.getParameter("eventType"));
        e.setEventDate(DateUtil.parse(request.getParameter("eventDate")));
        e.setTentative(request.getParameter("tentative") != null);
        e.setNotes(ValidationUtil.clean(request.getParameter("notes")));
        String error = null;
        if (!ValidationUtil.inRange(e.getCycleYear(), 2000, 2100)) {
            error = "The cycle year must be between 2000 and 2100.";
        } else if (!ValidationUtil.isOneOf(e.getEventType(), "NOTIFICATION", "APPLY_START", "APPLY_END", "ADMIT_CARD", "STAGE_1", "STAGE_2", "STAGE_3", "RESULT")) {
            error = "Please choose the event.";
        } else if (e.getEventDate() == null || Math.abs(e.getEventDate().getYear() - e.getCycleYear()) > 1) {
            error = "Please give a date in (or next to) the cycle year.";
        } else if (e.getNotes() != null && e.getNotes().length() > 255) {
            error = "Notes can be at most 255 characters.";
        }
        if (error != null) {
            session.setAttribute("error", error);
            session.setAttribute("formEvent", e);
            response.sendRedirect(back + "#event-form");
            return;
        }
        int rows = new ExamEventDAO().saveEvent(e);
        new SnapshotDAO().deleteSnapshotsOfExam(exam.getId());   // the next cycle may have moved
        session.setAttribute(rows > 0 ? "success" : "error", rows > 0 ? "Date saved." : "Nothing was saved - please check the values.");
        response.sendRedirect(back + "#events");
        return;
    }
    response.sendRedirect(back);
%>
