<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.time.LocalDate, com.aspirantos.dao.DbExplorerDAO, com.aspirantos.dao.AuditDAO, com.aspirantos.util.DateUtil, com.aspirantos.util.ValidationUtil" %>
<%--
    Quick edit of one app_setting value from the DB Explorer (admin action page, no HTML).
    The value is checked like on the settings page, then saved with an updatable ResultSet.
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%
    if ("POST".equals(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        String key = request.getParameter("key");
        String value = request.getParameter("value") == null ? "" : request.getParameter("value").trim();
        String error = null;
        if ("simulation_date".equals(key)) {
            LocalDate d = DateUtil.parse(value);
            if (!value.isEmpty() && (d == null || d.getYear() < 2020 || d.getYear() > 2040)) {
                error = "simulation_date must be empty or a date (yyyy-mm-dd) between 2020 and 2040.";
            }
        } else if ("upcoming_cycles_to_plan".equals(key)) {
            if (!ValidationUtil.inRange(ValidationUtil.parseIntOrNull(value), 5, 30)) {
                error = "upcoming_cycles_to_plan must be a number from 5 to 30.";
            }
        } else if ("update_check_timeout_seconds".equals(key)) {
            if (!ValidationUtil.inRange(ValidationUtil.parseIntOrNull(value), 5, 60)) {
                error = "update_check_timeout_seconds must be a number from 5 to 60.";
            }
        } else {
            error = "This setting cannot be changed here.";
        }
        if (error != null) {
            session.setAttribute("error", error);
        } else {
            int rows = new DbExplorerDAO().updateSetting(key, value);
            new AuditDAO().insertAudit(currentUser.getId(), "SETTING_CHANGE", "app_setting", key + "=" + value,
                                       request.getRemoteAddr(), request.getHeader("User-Agent"));
            session.setAttribute(rows > 0 ? "success" : "error", rows > 0 ? key + " saved (" + rows + " row updated)." : "Nothing was saved.");
        }
    }
    response.sendRedirect("db-explorer.jsp?table=app_setting");
%>
