<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="error.jsp"%>
<%@ page import="com.aspirantos.model.User, com.aspirantos.util.HtmlUtil" %>
<%-- Registration form (view page). The form is posted to register-action.jsp. --%>
<%
    if (session.getAttribute("user") != null) {
        response.sendRedirect(request.getContextPath() + "/aspirant/dashboard.jsp");
        return;
    }
    // values typed before a validation error (formUser, like formEmployee in Experiment 5)
    User formUser = (User) session.getAttribute("formUser");
    if (formUser != null) {
        session.removeAttribute("formUser");
    } else {
        formUser = new User();
    }
    String pageTitle = "Create your account";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<section class="auth-card card">
    <h1>Create your free account</h1>
    <p class="muted">One profile for every exam. Your details stay on this computer.</p>
    <%@ include file="/WEB-INF/jspf/flash.jspf" %>
    <form action="register-action.jsp" method="post" data-validate="register" novalidate>
        <label for="fullName">Full name (as in your Class 10 certificate)</label>
        <input type="text" id="fullName" name="fullName" value="<%= HtmlUtil.escape(formUser.getFullName()) %>"
               maxlength="100" pattern="[A-Za-z .']{3,100}" title="Letters, spaces, dots and apostrophes, at least 3 characters"
               autocomplete="name" required autofocus>

        <label for="email">E-mail</label>
        <input type="email" id="email" name="email" value="<%= HtmlUtil.escape(formUser.getEmail()) %>"
               maxlength="150" autocomplete="email" required>

        <label for="phone">Mobile number <span class="muted">(optional)</span></label>
        <input type="tel" id="phone" name="phone" value="<%= HtmlUtil.escape(formUser.getPhone()) %>"
               maxlength="10" pattern="\d{10}" title="Exactly 10 digits" inputmode="numeric" autocomplete="tel">

        <label for="password">Password</label>
        <input type="password" id="password" name="password" maxlength="64" autocomplete="new-password"
               data-strength-meter="strength" required>
        <div class="strength" id="strength" aria-live="polite"><span class="strength-bar"></span><span class="strength-text">At least 8 characters with a letter and a number</span></div>

        <label for="confirmPassword">Confirm password</label>
        <input type="password" id="confirmPassword" name="confirmPassword" maxlength="64" autocomplete="new-password" required>

        <button type="submit" class="btn btn-primary btn-block">Create account</button>
    </form>
    <p class="auth-switch">Already registered? <a href="login.jsp">Log in</a></p>
</section>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
