<%@ page language="java" contentType="text/csv; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.*, java.time.LocalDate, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.engine.ExamRuleSet, com.aspirantos.service.EligibilityService, com.aspirantos.service.RulePackParser, com.aspirantos.util.ValidationUtil" %>
<%--
    Rule pack export: the ACTIVE rules as a CSV download (a JSP can send any content type -
    here text/csv with a Content-Disposition header so the browser saves the file).
    ?category=<code> or ?code=<exam code> limit the export; nothing = all active exams.
--%>
<%
    User who = (User) session.getAttribute("user");
    if (who == null || !"ADMIN".equals(who.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String code = ValidationUtil.clean(request.getParameter("code"));
    String category = ValidationUtil.clean(request.getParameter("category"));
    List<Exam> exams = new ArrayList<>();
    for (Exam x : new ExamDAO().getAllExams()) {
        if ((code == null || x.getCode().equalsIgnoreCase(code)) && (category == null || category.equals(x.getCategoryCode()))) {
            exams.add(x);
        }
    }
    Map<Integer, ExamRuleSet> sets = new EligibilityService().loadAllRuleSets(exams);
    List<ExamRuleSet> ordered = new ArrayList<>();
    for (Exam x : exams) {
        if (sets.get(x.getId()) != null) {
            ordered.add(sets.get(x.getId()));
        }
    }
    String name = "aspirantos_rule_pack_" + (code != null ? code.toUpperCase().replaceAll("[^A-Z0-9_]", "")
            : (category != null ? category.replaceAll("[^A-Z0-9_]", "") : "all")) + "_" + LocalDate.now() + ".csv";
    response.setHeader("Content-Disposition", "attachment; filename=\"" + name + "\"");
    out.print('\ufeff');   // byte order mark: Excel then opens the file as UTF-8
    out.print(RulePackParser.toCsv(ordered));
%>
