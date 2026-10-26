<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.time.LocalDate, java.util.List, java.util.Arrays, com.aspirantos.model.Education, com.aspirantos.dao.EducationDAO, com.aspirantos.util.ValidationUtil, com.aspirantos.util.DateUtil" %>
<%--
    Education action page (no HTML): insert, update and delete of education rows.
    One page, several actions - the same "switch (action)" as StudentServlet (Experiment 4).
    Every change goes back to step 3 with a flash message (Post/Redirect/Get).
--%>
<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>
<%@ include file="/WEB-INF/jspf/aspirant-only.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    EducationDAO educationDAO = new EducationDAO();
    String action = request.getParameter("action");
    if (action == null) {
        action = "";
    }

    switch (action) {
        case "delete": {
            int rows = 0;
            try {
                rows = educationDAO.deleteEducation(Integer.parseInt(request.getParameter("id")), currentUser.getId());
            } catch (NumberFormatException e) {
                rows = 0;
            }
            session.setAttribute(rows > 0 ? "success" : "error",
                    rows > 0 ? "Education row deleted (" + rows + " row affected)." : "That education row was not found.");
            break;
        }
        case "save": {
            if (!"POST".equals(request.getMethod())) {
                break;
            }
            Education ed = new Education();
            ed.setUserId(currentUser.getId());
            ed.setId(ValidationUtil.parseIntOrNull(request.getParameter("id")) == null ? 0
                     : ValidationUtil.parseIntOrNull(request.getParameter("id")));
            ed.setLevel(request.getParameter("level"));
            ed.setDegreeName(ValidationUtil.clean(request.getParameter("degreeName")));
            ed.setStreamOrSpecialisation(ValidationUtil.clean(request.getParameter("streamOrSpecialisation")));
            ed.setBoardOrUniversity(ValidationUtil.clean(request.getParameter("boardOrUniversity")));
            ed.setStatus("APPEARING".equals(request.getParameter("status")) ? "APPEARING" : "COMPLETED");
            ed.setPercentage(ValidationUtil.parseDoubleOrNull(request.getParameter("percentage")));
            ed.setCgpa(ValidationUtil.parseDoubleOrNull(request.getParameter("cgpa")));
            ed.setCgpaScale(ed.getCgpa() == null ? null : ValidationUtil.parseDoubleOrNull(request.getParameter("cgpaScale")));
            ed.setPassingYear(ValidationUtil.parseIntOrNull(request.getParameter("passingYear")));
            ed.setExpectedCompletionDate(DateUtil.parse(request.getParameter("expectedCompletionDate")));

            // subjects: ticked boxes (only known words) + "other subjects" typed by the student
            StringBuilder subjects = new StringBuilder();
            List<String> known = Arrays.asList(Education.COMMON_SUBJECTS);
            String[] ticked = request.getParameterValues("subject");
            if (ticked != null) {
                for (String s : ticked) {
                    if (known.contains(s) && subjects.indexOf(s) < 0) {
                        subjects.append(subjects.length() > 0 ? "," : "").append(s);
                    }
                }
            }
            String error = null;
            String other = request.getParameter("otherSubjects");
            if (!ValidationUtil.isBlank(other)) {
                for (String s : other.split(",")) {
                    String word = s.trim().toUpperCase().replaceAll("\\s+", " ");
                    if (word.isEmpty()) {
                        continue;
                    }
                    if (!word.matches("[A-Z][A-Z &.()-]{1,39}")) {
                        error = "Other subjects: use letters only and separate subjects with commas.";
                    } else if (subjects.indexOf(word) < 0) {
                        subjects.append(subjects.length() > 0 ? "," : "").append(word);
                    }
                }
            }
            ed.setSubjects(subjects.length() == 0 ? null : subjects.toString());

            int thisYear = LocalDate.now().getYear();
            boolean needsDegree = ValidationUtil.isOneOf(ed.getLevel(), "DIPLOMA", "UG", "PG", "PHD", "PROFESSIONAL");
            if (error != null) {
                // keep the first message
            } else if (!ValidationUtil.isOneOf(ed.getLevel(), "CLASS_10", "CLASS_12", "DIPLOMA", "UG", "PG", "PHD", "PROFESSIONAL")) {
                error = "Please choose the level of education.";
            } else if (needsDegree && ed.getDegreeName() == null) {
                error = "Please enter the degree or course name (for example B.A. or B.Tech).";
            } else if (ed.getDegreeName() != null && !ed.getDegreeName().matches("[A-Za-z0-9 .,()&/'-]{1,60}")) {
                error = "Degree name can contain letters, numbers, spaces and . , ( ) & / - only.";
            } else if (subjects.length() > 300) {
                error = "Too many subjects - please keep the list shorter.";
            } else if (ed.getPercentage() != null && !ValidationUtil.inRange(ed.getPercentage(), 0, 100)) {
                error = "Percentage must be between 0 and 100.";
            } else if (ed.getCgpa() != null && !ValidationUtil.inRange(ed.getCgpaScale(), 4, 10)) {
                error = "CGPA scale must be between 4 and 10 (usually 10).";
            } else if (ed.getCgpa() != null && !ValidationUtil.inRange(ed.getCgpa(), 0, ed.getCgpaScale())) {
                error = "CGPA cannot be more than the scale.";
            } else if ("COMPLETED".equals(ed.getStatus())
                       && !ValidationUtil.inRange(ed.getPassingYear(), 1960, thisYear)) {
                error = "Please enter the passing year (1960 to " + thisYear + ").";
            } else if ("APPEARING".equals(ed.getStatus())
                       && (ed.getExpectedCompletionDate() == null
                           || ed.getExpectedCompletionDate().isBefore(LocalDate.now().minusMonths(6))
                           || ed.getExpectedCompletionDate().isAfter(LocalDate.now().plusYears(8)))) {
                error = "For a course you are still studying, enter the expected result date (within the next 8 years).";
            }
            if (error == null && ValidationUtil.isOneOf(ed.getLevel(), "CLASS_10", "CLASS_12")) {
                // only one Class 10 and one Class 12 row
                for (Education existing : educationDAO.getEducationByUser(currentUser.getId())) {
                    if (existing.getLevel().equals(ed.getLevel()) && existing.getId() != ed.getId()) {
                        error = "You already added " + ("CLASS_10".equals(ed.getLevel()) ? "Class 10" : "Class 12")
                                + " - please edit that row instead.";
                    }
                }
            }
            if (error != null) {
                session.setAttribute("error", error);
                session.setAttribute("formEducation", ed);    // keep the typed values
                response.sendRedirect("profile-step3.jsp" + (ed.getId() > 0 ? "?editEdu=" + ed.getId() : "") + "#education-form");
                return;
            }
            if ("APPEARING".equals(ed.getStatus())) {
                ed.setPassingYear(ed.getExpectedCompletionDate().getYear());
            } else {
                ed.setExpectedCompletionDate(null);
            }
            // updateEducation returns the row count, insertEducation the new id
            int rows = ed.getId() > 0 ? educationDAO.updateEducation(ed) : (educationDAO.insertEducation(ed) > 0 ? 1 : 0);
            session.setAttribute(rows > 0 ? "success" : "error", rows > 0
                    ? (ed.getId() > 0 ? "Education updated" : "Education added") + " (" + rows + " row affected)."
                    : "Nothing was saved - please try again.");
            break;
        }
        default:
            break;
    }
    response.sendRedirect("profile-step3.jsp");
%>
