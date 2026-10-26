<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="com.aspirantos.dao.NotificationDAO, com.aspirantos.util.ValidationUtil" %>
<%-- Mark one or all notifications as read (action page, no HTML). --%>
<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>
<%
    if ("POST".equals(request.getMethod())) {
        NotificationDAO notificationDAO = new NotificationDAO();
        String action = request.getParameter("action");
        if ("readAll".equals(action)) {
            int rows = notificationDAO.markAllRead(currentUser.getId());
            session.setAttribute("success", rows + " notification" + (rows == 1 ? "" : "s") + " marked as read.");
        } else if ("read".equals(action)) {
            Integer id = ValidationUtil.parseIntOrNull(request.getParameter("id"));
            if (id != null) {
                notificationDAO.markRead(id, currentUser.getId());   // the DAO checks the owner
            }
        }
    }
    response.sendRedirect("notifications.jsp");
%>
