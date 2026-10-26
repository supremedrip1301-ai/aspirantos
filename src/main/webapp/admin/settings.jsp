<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.List, com.aspirantos.model.AppSetting, com.aspirantos.dao.SettingDAO, com.aspirantos.util.HtmlUtil, com.aspirantos.util.DateUtil" %>
<%--
    App settings (admin view page): the simulation date used as "today" by the whole engine
    (empty = real date), the number of cycles the horizon looks at and the update-check timeout.
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%
    SettingDAO settingDAO = new SettingDAO();
    List<AppSetting> settings = settingDAO.getAllSettings();
    String simValue = settingDAO.getSetting("simulation_date");
    String cyclesValue = settingDAO.getSetting("upcoming_cycles_to_plan");
    String timeoutValue = settingDAO.getSetting("update_check_timeout_seconds");
    String pageTitle = "App settings";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<h1>App settings</h1>
<%@ include file="/WEB-INF/jspf/flash.jspf" %>

<div class="grid settings-grid">
    <section class="card">
        <h2>Simulation date</h2>
        <p>When a date is set, every result in the app is worked out as if today were that date, and a banner shows it on every page. Leave it empty to use the real date.</p>
        <form action="settings-action.jsp" method="post">
            <input type="hidden" name="action" value="simulation">
            <label for="simulation_date">Use this date as today</label>
            <input type="date" id="simulation_date" name="value" value="<%= HtmlUtil.escape(simValue) %>" min="2020-01-01" max="2040-12-31">
            <div class="form-actions">
                <button type="submit" name="preset" value="demo" class="btn">Presentation date (15-Jan-2027)</button>
                <button type="submit" name="preset" value="clear" class="btn">Use the real date</button>
                <button type="submit" class="btn btn-primary">Save date</button>
            </div>
        </form>
    </section>

    <section class="card">
        <h2>Eligibility and updates</h2>
        <form action="settings-action.jsp" method="post" novalidate>
            <input type="hidden" name="action" value="numbers">
            <label for="cycles">Future exam cycles to check (5 to 30)</label>
            <input type="number" id="cycles" name="upcoming_cycles_to_plan" value="<%= HtmlUtil.escape(cyclesValue) %>" min="5" max="30" required>
            <label for="timeout">Timeout when checking an official website, seconds (5 to 60)</label>
            <input type="number" id="timeout" name="update_check_timeout_seconds" value="<%= HtmlUtil.escape(timeoutValue) %>" min="5" max="60" required>
            <div class="form-actions"><button type="submit" class="btn btn-primary">Save</button></div>
        </form>
    </section>

    <section class="card span-2">
        <h2>All settings</h2>
        <div class="table-wrap"><table>
            <thead><tr><th>Key</th><th>Value</th><th>Meaning</th></tr></thead>
            <tbody>
            <% for (AppSetting s : settings) { %>
            <tr><td class="mono small"><%= HtmlUtil.escape(s.getSettingKey()) %></td><td class="mono"><%= HtmlUtil.orDash(s.getSettingValue() == null || s.getSettingValue().isEmpty() ? null : s.getSettingValue()) %></td><td class="small"><%= HtmlUtil.escape(s.getDescription()) %></td></tr>
            <% } %>
            </tbody>
        </table></div>
    </section>
</div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
