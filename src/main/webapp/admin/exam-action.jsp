<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.time.LocalDate, com.aspirantos.model.Exam, com.aspirantos.dao.ExamDAO, com.aspirantos.dao.AuditDAO, com.aspirantos.util.ValidationUtil, com.aspirantos.util.DateUtil" %>
<%--
    Exam action page (admin, no HTML): save (insert / update) and activate / deactivate,
    with the switch of StudentServlet and the flash + redirect of Experiment 5.
    "Delete" is a deactivation, so students' tracking and attempts stay intact.
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%!
    // declaration: only http / https links are stored
    private boolean validUrl(String url) {
        return url == null || (url.length() <= 500 && url.matches("https?://[^\\s\"'<>]+"));
    }
%>
<%
    if (!"POST".equals(request.getMethod())) {
        response.sendRedirect("exams.jsp");
        return;
    }
    request.setCharacterEncoding("UTF-8");
    ExamDAO examDAO = new ExamDAO();
    String action = request.getParameter("action");
    if (action == null) {
        action = "";
    }
    String ip = request.getRemoteAddr();
    String agent = request.getHeader("User-Agent");

    switch (action) {
        case "activate":
        case "deactivate": {
            Integer id = ValidationUtil.parseIntOrNull(request.getParameter("id"));
            int rows = id == null ? 0 : examDAO.setExamActive(id, "activate".equals(action));
            new AuditDAO().insertAudit(currentUser.getId(), "activate".equals(action) ? "EXAM_ACTIVATE" : "EXAM_DEACTIVATE",
                                       "exam", String.valueOf(id), ip, agent);
            session.setAttribute(rows > 0 ? "success" : "error", rows > 0
                    ? ("activate".equals(action) ? "Exam activated" : "Exam deactivated - students no longer see it") + " (" + rows + " row affected)."
                    : "That exam was not found.");
            response.sendRedirect("exams.jsp");
            return;
        }
        case "save": {
            Exam x = new Exam();
            Integer id = ValidationUtil.parseIntOrNull(request.getParameter("id"));
            x.setId(id == null ? 0 : id);
            x.setCode(request.getParameter("code") == null ? null : request.getParameter("code").trim().toUpperCase());
            x.setName(ValidationUtil.clean(request.getParameter("name")));
            x.setShortName(ValidationUtil.clean(request.getParameter("shortName")));
            Integer categoryId = ValidationUtil.parseIntOrNull(request.getParameter("categoryId"));
            Integer bodyId = ValidationUtil.parseIntOrNull(request.getParameter("bodyId"));
            x.setCategoryId(categoryId == null ? 0 : categoryId);
            x.setBodyId(bodyId == null ? 0 : bodyId);
            x.setScope(request.getParameter("scope"));
            x.setStateCode(ValidationUtil.clean(request.getParameter("stateCode")));
            x.setSector(request.getParameter("sector"));
            x.setPurpose(request.getParameter("purpose"));
            Double cycles = ValidationUtil.parseDoubleOrNull(request.getParameter("cyclesPerYear"));
            x.setCyclesPerYear(cycles == null ? 0 : cycles);
            x.setTypicalNotificationMonth(ValidationUtil.parseIntOrNull(request.getParameter("typicalNotificationMonth")));
            x.setTypicalExamMonth(ValidationUtil.parseIntOrNull(request.getParameter("typicalExamMonth")));
            x.setStagesSummary(ValidationUtil.clean(request.getParameter("stagesSummary")));
            x.setPostsOrCourses(ValidationUtil.clean(request.getParameter("postsOrCourses")));
            x.setOfficialUrl(ValidationUtil.clean(request.getParameter("officialUrl")));
            x.setWatchUrl(ValidationUtil.clean(request.getParameter("watchUrl")));
            x.setDescription(ValidationUtil.clean(request.getParameter("description")));
            x.setFeeSummary(ValidationUtil.clean(request.getParameter("feeSummary")));
            x.setAttemptCountingNote(ValidationUtil.clean(request.getParameter("attemptCountingNote")));
            x.setDataConfidence(request.getParameter("dataConfidence"));
            x.setLastVerifiedOn(DateUtil.parse(request.getParameter("lastVerifiedOn")));
            x.setSourceNote(ValidationUtil.clean(request.getParameter("sourceNote")));
            x.setActive(request.getParameter("active") != null);

            Exam existing = x.getId() > 0 ? examDAO.getExam(x.getId()) : null;
            if (existing != null) {
                x.setCode(existing.getCode());   // the code is the natural key and never changes
            }
            String error = null;
            if (x.getId() > 0 && existing == null) {
                error = "That exam was not found.";
            } else if (x.getCode() == null || !x.getCode().matches("[A-Z0-9_]{2,40}")) {
                error = "Code: 2 to 40 capital letters, digits or underscores (for example UPSC_CSE).";
            } else if (existing == null && examDAO.getExamByCode(x.getCode()) != null) {
                error = "An exam with the code " + x.getCode() + " already exists.";
            } else if (x.getName() == null || x.getName().length() > 200) {
                error = "Please enter the full name (at most 200 characters).";
            } else if (x.getShortName() == null || x.getShortName().length() > 60) {
                error = "Please enter a short name (at most 60 characters).";
            } else if (x.getCategoryId() == 0 || x.getBodyId() == 0) {
                error = "Please choose the category and the conducting body.";
            } else if (!ValidationUtil.isOneOf(x.getScope(), "NATIONAL", "STATE", "INTERNATIONAL")
                       || !ValidationUtil.isOneOf(x.getSector(), "GOVERNMENT", "AUTONOMOUS", "PRIVATE")
                       || !ValidationUtil.isOneOf(x.getPurpose(), "RECRUITMENT", "ADMISSION", "CERTIFICATION", "LICENSING", "FELLOWSHIP", "SCHOLARSHIP")) {
                error = "Please choose the level, sector and purpose.";
            } else if ("STATE".equals(x.getScope()) && x.getStateCode() == null) {
                error = "A state exam needs its state.";
            } else if (!ValidationUtil.inRange(x.getCyclesPerYear(), 0.5, 12)) {
                error = "Sittings per year must be between 0.5 and 12.";
            } else if ((x.getTypicalNotificationMonth() != null && !ValidationUtil.inRange(x.getTypicalNotificationMonth(), 1, 12))
                       || (x.getTypicalExamMonth() != null && !ValidationUtil.inRange(x.getTypicalExamMonth(), 1, 12))) {
                error = "Months must be between 1 and 12.";
            } else if (!validUrl(x.getOfficialUrl()) || !validUrl(x.getWatchUrl())) {
                error = "Links must start with http:// or https://.";
            } else if (!ValidationUtil.isOneOf(x.getDataConfidence(), "VERIFIED", "LIKELY", "NEEDS_VERIFICATION")) {
                error = "Please choose the data confidence.";
            } else if ("VERIFIED".equals(x.getDataConfidence()) && (x.getLastVerifiedOn() == null || x.getSourceNote() == null)) {
                error = "\"Verified\" needs the date you checked the official notice and the source.";
            } else if (x.getLastVerifiedOn() != null && x.getLastVerifiedOn().isAfter(LocalDate.now())) {
                error = "The verification date cannot be in the future.";
            } else if ((x.getStagesSummary() != null && x.getStagesSummary().length() > 255)
                       || (x.getDescription() != null && x.getDescription().length() > 4000)) {
                error = "Stages: at most 255 characters, description: at most 4000.";
            }
            if (error != null) {
                session.setAttribute("error", error);
                session.setAttribute("formExam", x);
                response.sendRedirect("exam-form.jsp" + (x.getId() > 0 ? "?id=" + x.getId() : ""));
                return;
            }
            if (existing != null) {
                int rows = examDAO.updateExam(x);
                new AuditDAO().insertAudit(currentUser.getId(), "EXAM_UPDATE", "exam", String.valueOf(x.getId()), ip, agent);
                session.setAttribute(rows > 0 ? "success" : "error", rows > 0
                        ? x.getShortName() + " saved (" + rows + " row affected)." : "Nothing was saved - please check the values.");
                response.sendRedirect("exams.jsp?q=" + java.net.URLEncoder.encode(x.getCode(), "UTF-8"));
            } else {
                int newId = examDAO.insertExam(x);
                if (newId == 0) {
                    session.setAttribute("error", "The exam could not be saved - please check the values.");
                    session.setAttribute("formExam", x);
                    response.sendRedirect("exam-form.jsp");
                    return;
                }
                new AuditDAO().insertAudit(currentUser.getId(), "EXAM_CREATE", "exam", String.valueOf(newId), ip, agent);
                session.setAttribute("success", x.getShortName() + " added (1 row affected). Now add its rules and publish version 1.");
                response.sendRedirect("rules.jsp?exam=" + newId);
            }
            return;
        }
        default:
            response.sendRedirect("exams.jsp");
    }
%>
