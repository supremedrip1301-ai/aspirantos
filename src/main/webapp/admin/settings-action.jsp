<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.time.LocalDate, com.aspirantos.dao.SettingDAO, com.aspirantos.dao.AuditDAO, com.aspirantos.util.DateUtil, com.aspirantos.util.ValidationUtil" %>
<%--
    App settings action page (admin, no HTML). Only the known keys can be changed.
    The cached eligibility snapshots are stored per date, so a new simulation date simply
    makes every page compute fresh results for that date.
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%
    if (!"POST".equals(request.getMethod())) {
        response.sendRedirect("settings.jsp");
        return;
    }
    SettingDAO settingDAO = new SettingDAO();
    AuditDAO auditDAO = new AuditDAO();
    String action = request.getParameter("action");
    String ip = request.getRemoteAddr();
    String agent = request.getHeader("User-Agent");

    if ("simulation".equals(action)) {
        String preset = request.getParameter("preset");
        String value;
        if ("demo".equals(preset)) {
            value = "2027-01-15";
        } else if ("clear".equals(preset)) {
            value = "";
        } else {
            String typed = request.getParameter("value");
            LocalDate d = DateUtil.parse(typed);
            if (!ValidationUtil.isBlank(typed) && (d == null || d.getYear() < 2020 || d.getYear() > 2040)) {
                session.setAttribute("error", "Please give a date between 2020 and 2040, or leave it empty.");
                response.sendRedirect("settings.jsp");
                return;
            }
            value = d == null ? "" : d.toString();
        }
        int rows = settingDAO.updateSetting("simulation_date", value);
        auditDAO.insertAudit(currentUser.getId(), "SETTING_CHANGE", "app_setting", "simulation_date=" + value, ip, agent);
        session.setAttribute("success", (value.isEmpty() ? "Simulation date switched off - the real date is used" : "Simulation date set to "
                + DateUtil.format(LocalDate.parse(value))) + " (" + rows + " row affected).");
    } else if ("numbers".equals(action)) {
        Integer cycles = ValidationUtil.parseIntOrNull(request.getParameter("upcoming_cycles_to_plan"));
        Integer timeout = ValidationUtil.parseIntOrNull(request.getParameter("update_check_timeout_seconds"));
        if (!ValidationUtil.inRange(cycles, 5, 30) || !ValidationUtil.inRange(timeout, 5, 60)) {
            session.setAttribute("error", "Cycles must be 5 to 30 and the timeout 5 to 60 seconds.");
        } else {
            int rows = settingDAO.updateSetting("upcoming_cycles_to_plan", String.valueOf(cycles))
                     + settingDAO.updateSetting("update_check_timeout_seconds", String.valueOf(timeout));
            auditDAO.insertAudit(currentUser.getId(), "SETTING_CHANGE", "app_setting",
                                 "cycles=" + cycles + ",timeout=" + timeout, ip, agent);
            session.setAttribute("success", "Settings saved (" + rows + " rows affected).");
        }
    }
    response.sendRedirect("settings.jsp");
%>
