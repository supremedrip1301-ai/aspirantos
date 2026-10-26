<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="com.aspirantos.model.User, com.aspirantos.service.UpdateCheckJob" %>
<%--
    JSON progress of "Check all exams" (a JSP can answer with JSON as well - CHANGE 005).
    Polled every 2 seconds by assets/js/update-progress.js. Admins only.
--%>
<%
    User who = (User) session.getAttribute("user");
    if (who == null || !"ADMIN".equals(who.getRole())) {
        response.setStatus(403);
        out.print("{\"error\":\"admin only\"}");
        return;
    }
    response.setHeader("Cache-Control", "no-store");
    out.print(UpdateCheckJob.progressJson());
%>
