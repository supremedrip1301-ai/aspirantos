<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
    Welcome file (web.xml <welcome-file-list>). The request is handed to home.jsp on the server
    with the forward action: the browser still shows /AspirantOS/ in the address bar
    (a server-side forward, unlike response.sendRedirect, which makes the browser ask again).
--%>
<jsp:forward page="home.jsp"/>
