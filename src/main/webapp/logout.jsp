<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="error.jsp"%>
<%@ page import="com.aspirantos.model.User, com.aspirantos.dao.AuditDAO, com.aspirantos.dao.RememberTokenDAO, com.aspirantos.util.PasswordUtil" %>
<%--
    Logout (no HTML): forgets the "remember me" token, ends the HttpSession with
    session.invalidate() (Worksheet 2) and redirects to the login page.
--%>
<%
    String ctx = request.getContextPath();
    if (request.getCookies() != null) {
        for (Cookie c : request.getCookies()) {
            if ("remember".equals(c.getName())) {
                new RememberTokenDAO().deleteToken(PasswordUtil.sha256Hex(c.getValue()));
                Cookie gone = new Cookie("remember", "");
                gone.setMaxAge(0);              // max age 0 = the browser deletes the cookie
                gone.setPath(ctx.isEmpty() ? "/" : ctx);
                response.addCookie(gone);
            }
        }
    }
    User leaving = (User) session.getAttribute("user");
    if (leaving != null) {
        new AuditDAO().insertAudit(leaving.getId(), "LOGOUT", "app_user", String.valueOf(leaving.getId()),
                                   request.getRemoteAddr(), request.getHeader("User-Agent"));
    }
    session.invalidate();

    // a new, empty session only to carry the message to the login page
    HttpSession fresh = request.getSession(true);
    fresh.setAttribute("success", "You have been logged out.");
    response.sendRedirect(ctx + "/login.jsp");
%>
