<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true"%>
<%-- Placeholder error page (Phase 0). Uses the exception implicit object; styled in P10. --%>
<%
    Integer statusCode = (Integer) request.getAttribute("jakarta.servlet.error.status_code");
    if (statusCode == null) {
        statusCode = 500;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Error <%= statusCode %></title>
</head>
<body>
<h1><%= statusCode == 404 ? "Page not found" : "Something went wrong" %></h1>
<%
    if (exception != null) {
        // full details only in the server console, never on the page
        System.out.println("AspirantOS error: " + exception);
    }
%>
<p><a href="<%= request.getContextPath() %>/index.jsp">Go to home page</a></p>
</body>
</html>
