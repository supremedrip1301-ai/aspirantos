<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="error.jsp"%>
<%@ page import="com.aspirantos.model.User, com.aspirantos.util.HtmlUtil" %>
<%-- Login form (view page). The form is posted to login-action.jsp. --%>
<%@ include file="/WEB-INF/jspf/remember-me.jspf" %>
<%
    // already logged in (or remembered by the cookie): go straight to the right home page
    User loggedIn = (User) session.getAttribute("user");
    if (loggedIn != null) {
        response.sendRedirect(request.getContextPath()
                + ("ADMIN".equals(loggedIn.getRole()) ? "/admin/dashboard.jsp" : "/aspirant/dashboard.jsp"));
        return;
    }
    // e-mail typed before a failed attempt (flash pattern of Experiment 5)
    String formEmail = (String) session.getAttribute("formEmail");
    if (formEmail != null) {
        session.removeAttribute("formEmail");
    } else {
        formEmail = "";
    }
    String pageTitle = "Log in";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<section class="auth-card card">
    <h1>Welcome back</h1>
    <p class="muted">Log in to see your eligibility, attempts left and upcoming exams.</p>
    <%@ include file="/WEB-INF/jspf/flash.jspf" %>
    <form action="login-action.jsp" method="post" data-validate="login" novalidate>
        <label for="email">E-mail</label>
        <input type="email" id="email" name="email" value="<%= HtmlUtil.escape(formEmail) %>"
               maxlength="150" autocomplete="username" required autofocus>

        <label for="password">Password</label>
        <input type="password" id="password" name="password" maxlength="64" autocomplete="current-password" required>

        <label class="check"><input type="checkbox" name="remember"> Keep me logged in on this computer for 14 days</label>

        <button type="submit" class="btn btn-primary btn-block">Log in</button>
    </form>
    <p class="auth-switch">New here? <a href="register.jsp">Create your free account</a></p>
    <p class="hint">Forgot your password? This app runs offline and cannot send e-mails - please ask the administrator.</p>
</section>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
