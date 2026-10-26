<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.time.LocalDate, com.aspirantos.model.WorkExperience, com.aspirantos.dao.WorkExperienceDAO, com.aspirantos.util.ValidationUtil, com.aspirantos.util.DateUtil" %>
<%--
    Work experience action page (no HTML): insert, update, delete - same switch pattern as
    education-action.jsp. Goes back to step 3 of the wizard.
--%>
<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>
<%@ include file="/WEB-INF/jspf/aspirant-only.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    WorkExperienceDAO workDAO = new WorkExperienceDAO();
    String action = request.getParameter("action");
    if (action == null) {
        action = "";
    }

    switch (action) {
        case "delete": {
            int rows = 0;
            try {
                rows = workDAO.deleteWork(Integer.parseInt(request.getParameter("id")), currentUser.getId());
            } catch (NumberFormatException e) {
                rows = 0;
            }
            session.setAttribute(rows > 0 ? "success" : "error",
                    rows > 0 ? "Work experience deleted (" + rows + " row affected)." : "That work experience was not found.");
            break;
        }
        case "save": {
            if (!"POST".equals(request.getMethod())) {
                break;
            }
            WorkExperience w = new WorkExperience();
            w.setUserId(currentUser.getId());
            Integer id = ValidationUtil.parseIntOrNull(request.getParameter("id"));
            w.setId(id == null ? 0 : id);
            w.setOrganisation(ValidationUtil.clean(request.getParameter("organisation")));
            w.setDesignation(ValidationUtil.clean(request.getParameter("designation")));
            w.setStartDate(DateUtil.parse(request.getParameter("startDate")));
            w.setEndDate(DateUtil.parse(request.getParameter("endDate")));
            w.setGovt(request.getParameter("govt") != null);
            w.setRelevantProfessional(request.getParameter("relevantProfessional") != null);

            String error = null;
            LocalDate today = LocalDate.now();
            if (w.getOrganisation() == null || w.getOrganisation().length() < 2 || w.getOrganisation().length() > 150) {
                error = "Please enter the organisation name (2 to 150 characters).";
            } else if (w.getDesignation() != null && w.getDesignation().length() > 100) {
                error = "Designation can be at most 100 characters.";
            } else if (w.getStartDate() == null || w.getStartDate().isAfter(today)) {
                error = "Please enter the start date (not in the future).";
            } else if (w.getEndDate() != null && (w.getEndDate().isBefore(w.getStartDate()) || w.getEndDate().isAfter(today))) {
                error = "The end date must be after the start date and not in the future.";
            }
            if (error != null) {
                session.setAttribute("error", error);
                session.setAttribute("formWork", w);
                response.sendRedirect("profile-step3.jsp" + (w.getId() > 0 ? "?editWork=" + w.getId() : "") + "#work-form");
                return;
            }
            int rows = w.getId() > 0 ? workDAO.updateWork(w) : (workDAO.insertWork(w) > 0 ? 1 : 0);
            session.setAttribute(rows > 0 ? "success" : "error", rows > 0
                    ? (w.getId() > 0 ? "Work experience updated" : "Work experience added") + " (" + rows + " row affected)."
                    : "Nothing was saved - please try again.");
            break;
        }
        default:
            break;
    }
    response.sendRedirect("profile-step3.jsp#work-form");
%>
