<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true"%>
<%@ page import="java.io.StringWriter, java.io.PrintWriter, com.aspirantos.model.User, com.aspirantos.util.HtmlUtil" %>
<%--
    One error page for 404, 500 and every exception (web.xml <error-page> and errorPage="..." in
    the page directives). isErrorPage="true" gives this JSP the "exception" implicit object.
    Students see a friendly message; only the administrator sees the technical details.
    It does not use the database, so it still works when MySQL is down.
--%>
<%
    Integer statusCode = (Integer) request.getAttribute("jakarta.servlet.error.status_code");
    if (statusCode == null) {
        statusCode = exception != null ? 500 : 404;
    }
    response.setStatus(statusCode);
    boolean notFound = statusCode == 404;
    User viewer = (User) session.getAttribute("user");
    boolean admin = viewer != null && "ADMIN".equals(viewer.getRole());
    String details = null;
    if (exception != null) {
        application.log("AspirantOS error on " + request.getAttribute("jakarta.servlet.error.request_uri"), exception);
        if (admin) {
            StringWriter sw = new StringWriter();
            exception.printStackTrace(new PrintWriter(sw));
            details = sw.toString();
        }
    }
    String ctx = request.getContextPath();
    String themeValue = "light";
    if (request.getCookies() != null) {
        for (jakarta.servlet.http.Cookie c : request.getCookies()) {
            if ("theme".equals(c.getName()) && "dark".equals(c.getValue())) {
                themeValue = "dark";
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en" data-theme="<%= themeValue %>">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= notFound ? "Page not found" : "Something went wrong" %> - AspirantOS</title>
<link rel="stylesheet" href="<%= ctx %>/assets/css/tokens.css">
<link rel="stylesheet" href="<%= ctx %>/assets/css/app.css">
</head>
<body class="signed-out">
<header class="topbar"><a class="brand" href="<%= ctx %>/"><span class="brand-mark" aria-hidden="true">A</span>AspirantOS</a></header>
<main id="main" class="page">
    <section class="card error-card">
        <p class="error-code mono"><%= statusCode %></p>
        <h1><%= notFound ? "This page does not exist" : "Something went wrong" %></h1>
        <p><%= notFound ? "The link may be old or mistyped." : "Your data is safe. Please go back and try again in a moment." %></p>
        <div class="form-actions">
            <a class="btn btn-primary" href="<%= ctx %>/">Home</a>
        </div>
        <% if (details != null) { %>
        <details class="error-details"><summary>Technical details (administrator only)</summary><pre><%= HtmlUtil.escape(details) %></pre></details>
        <% } %>
    </section>
</main>
</body>
</html>
