<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="com.aspirantos.dao.*, com.aspirantos.util.HtmlUtil, com.aspirantos.util.DateUtil" %>
<%--
    Admin dashboard (first version, Phase 5): a few counts. The full admin area
    (exams, rule versions, update checks, reports, users, settings) comes in Phase 8.
--%>
<%@ include file="/WEB-INF/jspf/admin-check.jspf" %>
<%
    int aspirants = new UserDAO().countUsersByRole("ASPIRANT");
    int[] confidence = new ExamDAO().getConfidenceCounts();   // total, verified, likely, needs verification
    java.time.LocalDate simDate = new SettingDAO().getSimulationDate();
    String pageTitle = "Admin dashboard";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<h1>Admin dashboard</h1>
<%@ include file="/WEB-INF/jspf/flash.jspf" %>
<div class="grid">
    <section class="card stat"><span class="stat-value"><%= aspirants %></span><span class="stat-label">Registered students</span></section>
    <section class="card stat"><span class="stat-value"><%= confidence[0] %></span><span class="stat-label">Exams in the catalogue</span></section>
    <section class="card stat"><span class="stat-value"><%= confidence[1] %></span><span class="stat-label">Exams verified from official notices</span></section>
    <section class="card stat"><span class="stat-value"><%= simDate == null ? "Off" : DateUtil.format(simDate) %></span><span class="stat-label">Simulation date</span></section>
</div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
