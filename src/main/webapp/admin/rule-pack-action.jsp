<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.*, com.aspirantos.dao.RulePackDAO, com.aspirantos.dao.AuditDAO, com.aspirantos.service.RulePackParser, com.aspirantos.util.ValidationUtil" %>
<%--
    Rule pack action page (admin, no HTML):
      preview - parses and validates the CSV text, keeps the result in the session
      apply   - writes all exams of the checked pack in one transaction (RulePackDAO)
      clear   - forgets the pack
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%
    if (!"POST".equals(request.getMethod())) {
        response.sendRedirect("rule-pack.jsp");
        return;
    }
    request.setCharacterEncoding("UTF-8");
    String action = request.getParameter("action");

    if ("preview".equals(action)) {
        String csv = request.getParameter("csv");
        String summary = ValidationUtil.clean(request.getParameter("summary"));
        String source = ValidationUtil.clean(request.getParameter("sourceUrl"));
        String from = ValidationUtil.clean(request.getParameter("appliesFrom"));
        String[] meta = {summary == null ? "" : summary, source == null ? "" : source, from == null ? "" : from, csv == null ? "" : csv};
        session.setAttribute("rulePackMeta", meta);
        if (csv == null || csv.length() > 1024 * 1024) {
            session.setAttribute("error", "Please paste a rule pack (at most 1 MB).");
            session.removeAttribute("rulePack");
        } else {
            RulePackParser.RulePack pack = new RulePackParser().parse(csv);
            session.setAttribute("rulePack", pack);
            session.setAttribute(pack.errorCount() == 0 ? "success" : "error", pack.errorCount() == 0
                    ? "The pack looks fine - check the differences below, then apply it."
                    : "The pack has " + pack.errorCount() + " problem(s) - nothing was saved.");
        }
        response.sendRedirect("rule-pack.jsp#preview");
        return;
    }

    if ("apply".equals(action)) {
        RulePackParser.RulePack pack = (RulePackParser.RulePack) session.getAttribute("rulePack");
        String[] meta = (String[]) session.getAttribute("rulePackMeta");
        if (pack == null || meta == null || pack.errorCount() > 0 || pack.byExam.isEmpty()) {
            session.setAttribute("error", "Please check a valid pack first.");
            response.sendRedirect("rule-pack.jsp");
            return;
        }
        String summary = meta[0].isEmpty() ? null : meta[0];
        String source = meta[1].isEmpty() ? null : meta[1];
        Integer from = ValidationUtil.parseIntOrNull(meta[2]);
        if (summary == null || summary.length() > 500) {
            session.setAttribute("error", "Please write what changed (at most 500 characters) and check the pack again.");
        } else if (source != null && (source.length() > 500 || !source.matches("https?://[^\\s\"'<>]+"))) {
            session.setAttribute("error", "The source must be an http(s) link.");
        } else if (from != null && !ValidationUtil.inRange(from, 2000, 2100)) {
            session.setAttribute("error", "Applies-from cycle must be between 2000 and 2100.");
        } else {
            try {
                Map<String, Integer> notified = new RulePackDAO().applyPack(pack.byExam, summary, source, from, currentUser.getId());
                int students = 0;
                for (int n : notified.values()) {
                    students += n;
                }
                new AuditDAO().insertAudit(currentUser.getId(), "RULE_PACK_IMPORT", "exam_rule_version",
                                           notified.size() + " exams", request.getRemoteAddr(), request.getHeader("User-Agent"));
                session.removeAttribute("rulePack");
                session.removeAttribute("rulePackMeta");
                session.setAttribute("success", "Rule pack applied: new active versions for " + notified.size() + " exam(s) "
                        + notified.keySet() + ", " + students + " student notification(s).");
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("error", "The pack was NOT applied (everything was rolled back): " + e.getMessage());
            }
        }
        response.sendRedirect("rule-pack.jsp");
        return;
    }

    session.removeAttribute("rulePack");
    session.removeAttribute("rulePackMeta");
    response.sendRedirect("rule-pack.jsp");
%>
