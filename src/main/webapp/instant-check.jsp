<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.time.LocalDate, java.util.ArrayList, com.aspirantos.model.*, com.aspirantos.dao.ExamDAO, com.aspirantos.engine.*, com.aspirantos.service.EligibilityService, com.aspirantos.util.DateUtil, com.aspirantos.util.ValidationUtil" %>
<%--
    Instant UPSC check of the landing page - a JSP that answers with JSON instead of HTML.
    GET ?dob=1996-09-15&category=GEN&attempts=4&pwbd=true. The answer comes from the real engine
    and the real UPSC CSE rules, for a sample candidate built in memory (graduate, Indian,
    unmarried). Nothing is stored.
--%>
<%!
    // declaration: a JSON string value (quotes, backslashes and control characters escaped)
    private String json(String s) {
        if (s == null) {
            return "null";
        }
        StringBuilder sb = new StringBuilder("\"");
        for (char c : s.toCharArray()) {
            if (c == '"' || c == '\\') {
                sb.append('\\').append(c);
            } else if (c < 0x20) {
                sb.append(String.format("\\u%04x", (int) c));
            } else {
                sb.append(c);
            }
        }
        return sb.append('"').toString();
    }
%>
<%
    response.setHeader("Cache-Control", "no-store");
    LocalDate dob = DateUtil.parse(request.getParameter("dob"));
    String category = request.getParameter("category");
    Integer attempts = ValidationUtil.isBlank(request.getParameter("attempts")) ? Integer.valueOf(0)
                       : ValidationUtil.parseIntOrNull(request.getParameter("attempts"));
    boolean pwbd = "true".equals(request.getParameter("pwbd"));
    EligibilityService eligibility = new EligibilityService();
    LocalDate today = eligibility.getToday();

    String error = null;
    if (dob == null) {
        error = "Please enter your date of birth.";
    } else if (dob.isAfter(today.minusYears(14)) || dob.isBefore(today.minusYears(70))) {
        error = "Please check the date of birth (age 14 to 70).";
    } else if (!ValidationUtil.isOneOf(category, "GEN", "EWS", "OBC_NCL", "SC", "ST")) {
        error = "Please choose a category.";
    } else if (!ValidationUtil.inRange(attempts, 0, 20)) {
        error = "Attempts must be a whole number from 0 to 20.";
    }
    Exam upsc = error == null ? new ExamDAO().getExamByCode("UPSC_CSE") : null;
    ExamRuleSet rules = upsc == null ? null : eligibility.loadRuleSet(upsc);
    if (error == null && rules == null) {
        error = "The UPSC rules are not available right now.";
    }
    if (error != null) {
        response.setStatus(400);
        out.print("{\"ok\":false,\"error\":" + json(error) + "}");
        return;
    }

    // sample candidate in memory - never saved
    Profile p = new Profile();
    p.setDob(dob);
    p.setCategory(category);
    p.setPwbd(pwbd);
    p.setPwbdPercent(pwbd ? 40 : null);
    p.setGender("MALE");
    p.setNationality("INDIAN");
    p.setMaritalStatus("UNMARRIED");
    Education degree = new Education();
    degree.setLevel("UG");
    degree.setDegreeName("B.A.");
    degree.setStatus("COMPLETED");
    degree.setPassingYear(Math.min(today.getYear() - 1, dob.getYear() + 21));
    java.util.List<Education> educations = new ArrayList<>();
    educations.add(degree);
    CandidateData candidate = new CandidateData(p, educations, new ArrayList<WorkExperience>(), attempts, new ArrayList<AttemptLog>());
    EligibilityResult r = new EligibilityEngine().evaluate(candidate, rules, today, eligibility.getCyclesToPlan());

    out.print("{\"ok\":true"
            + ",\"status\":" + json(r.getStatus())
            + ",\"headline\":" + json(r.getHeadline())
            + ",\"attemptsLeft\":" + json(r.getAttemptsRemainingText())
            + ",\"dobWindow\":" + json(r.getDobWindow())
            + ",\"relaxation\":" + json(r.getRelaxationBreakdown())
            + ",\"today\":" + json(DateUtil.format(today)) + "}");
%>
