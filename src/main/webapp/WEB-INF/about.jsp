<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%-- Placeholder About page (Phase 0). Mapped in web.xml with <jsp-file>; full page in P9.8. --%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>About - <%= application.getInitParameter("appName") %></title>
</head>
<body>
<h1>About <%= application.getInitParameter("appName") %></h1>
<p>Version <%= config.getInitParameter("appVersion") %></p>
<p>Contact: <%= config.getInitParameter("supportEmail") %></p>
<p><a href="<%= request.getContextPath() %>/index.jsp">Home</a></p>
</body>
</html>
