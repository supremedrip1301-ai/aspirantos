<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.Date, com.aspirantos.util.HtmlUtil" %>
<%--
    Settings (view page): change password, theme (stored in a cookie), "remember me" devices,
    the current HttpSession (id, creation time, last accessed time - as in Worksheet 2) and
    deleting the account. Every form posts to settings-action.jsp.
--%>
<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>
<%
    String pageTitle = "Settings";
    String sessionId = session.getId();
    String shortId = sessionId.length() > 6 ? "..." + sessionId.substring(sessionId.length() - 6) : sessionId;
    boolean isAdmin = "ADMIN".equals(currentUser.getRole());
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<h1>Settings</h1>
<%@ include file="/WEB-INF/jspf/flash.jspf" %>

<div class="grid settings-grid">
    <section class="card">
        <h2>Change password</h2>
        <form action="settings-action.jsp" method="post" data-validate="password" novalidate>
            <input type="hidden" name="action" value="password">
            <label for="currentPassword">Current password</label>
            <input type="password" id="currentPassword" name="currentPassword" maxlength="64" autocomplete="current-password" required>
            <label for="newPassword">New password</label>
            <input type="password" id="newPassword" name="newPassword" maxlength="64" autocomplete="new-password" data-strength-meter="new-strength" required>
            <div class="strength" id="new-strength" aria-live="polite"><span class="strength-bar"></span><span class="strength-text">At least 8 characters with a letter and a number</span></div>
            <label for="confirmPassword">Confirm new password</label>
            <input type="password" id="confirmPassword" name="confirmPassword" maxlength="64" autocomplete="new-password" required>
            <button type="submit" class="btn btn-primary">Change password</button>
        </form>
    </section>

    <section class="card">
        <h2>Appearance</h2>
        <form action="settings-action.jsp" method="post">
            <input type="hidden" name="action" value="theme">
            <fieldset class="choice-group">
                <legend>Theme</legend>
                <label class="check"><input type="radio" name="theme" value="light" <%= HtmlUtil.checked(!"dark".equals(themeValue)) %>> Light</label>
                <label class="check"><input type="radio" name="theme" value="dark" <%= HtmlUtil.checked("dark".equals(themeValue)) %>> Dark</label>
            </fieldset>
            <p class="hint">Saved in this browser for one year.</p>
            <button type="submit" class="btn">Save theme</button>
        </form>
    </section>

    <section class="card">
        <h2>Logged-in devices</h2>
        <p>If you ticked "Keep me logged in" on a computer you no longer use, log out everywhere.</p>
        <form action="settings-action.jsp" method="post">
            <input type="hidden" name="action" value="forget">
            <button type="submit" class="btn">Log out on all devices</button>
        </form>
    </section>

    <section class="card">
        <h2>This visit</h2>
        <dl class="facts">
            <dt>Session</dt><dd class="mono"><%= HtmlUtil.escape(shortId) %></dd>
            <dt>Started</dt><dd><%= new Date(session.getCreationTime()) %></dd>
            <dt>Last activity</dt><dd><%= new Date(session.getLastAccessedTime()) %></dd>
            <dt>Ends after</dt><dd><%= session.getMaxInactiveInterval() / 60 %> minutes without activity</dd>
        </dl>
    </section>

    <% if (!isAdmin) { %>
    <section class="card danger-zone">
        <h2>Delete my account</h2>
        <p>This deletes your profile, education, attempts and tracked exams permanently.</p>
        <form action="settings-action.jsp" method="post" data-validate="delete-account" novalidate>
            <input type="hidden" name="action" value="deleteAccount">
            <label for="deletePassword">Your password</label>
            <input type="password" id="deletePassword" name="password" maxlength="64" autocomplete="current-password" required>
            <label class="check"><input type="checkbox" name="confirm" value="yes" required> I understand that this cannot be undone</label>
            <button type="submit" class="btn btn-danger" data-confirm="Delete your account and all your data?">Delete my account</button>
        </form>
    </section>
    <% } %>
</div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
