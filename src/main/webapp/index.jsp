<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- Placeholder landing page (Phase 0). The real landing page is built in P9.7. --%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title><%= application.getInitParameter("appName") %></title>
</head>
<body>
<h1><%= application.getInitParameter("appName") %></h1>
<p><%= application.getInitParameter("appTagline") %></p>
<p><a href="about">About</a></p>
</body>
</html>
