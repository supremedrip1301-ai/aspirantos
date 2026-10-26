<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="com.aspirantos.dao.UserDAO, com.aspirantos.dao.AuditDAO, com.aspirantos.dao.RememberTokenDAO, com.aspirantos.util.ValidationUtil" %>
<%--
    Block / unblock a student account (admin action page, no HTML). UserDAO.updateStatus only
    changes ASPIRANT rows, so the admin account can never be blocked. Blocking also removes
    the student's "remember me" logins and puts the id into the application-wide set
    "blockedUserIds" (ServletContext attribute); auth-check.jspf ends such a session at once.
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%
    if ("POST".equals(request.getMethod())) {
        Integer id = ValidationUtil.parseIntOrNull(request.getParameter("id"));
        String action = request.getParameter("action");
        String status = "block".equals(action) ? "BLOCKED" : ("unblock".equals(action) ? "ACTIVE" : null);
        if (id != null && status != null) {
            int rows = new UserDAO().updateStatus(id, status);
            java.util.Set<Integer> blocked = (java.util.Set<Integer>) application.getAttribute("blockedUserIds");
            if (blocked == null) {
                blocked = java.util.Collections.synchronizedSet(new java.util.HashSet<Integer>());
                application.setAttribute("blockedUserIds", blocked);
            }
            if (rows > 0 && "BLOCKED".equals(status)) {
                new RememberTokenDAO().deleteTokensOfUser(id);
                blocked.add(id);
            } else if (rows > 0) {
                blocked.remove(id);
            }
            new AuditDAO().insertAudit(currentUser.getId(), "BLOCKED".equals(status) ? "USER_BLOCK" : "USER_UNBLOCK",
                                       "app_user", String.valueOf(id), request.getRemoteAddr(), request.getHeader("User-Agent"));
            session.setAttribute(rows > 0 ? "success" : "error", rows > 0
                    ? ("BLOCKED".equals(status) ? "Account blocked" : "Account unblocked") + " (" + rows + " row affected)."
                    : "That account cannot be changed.");
        }
    }
    response.sendRedirect("users.jsp");
%>
