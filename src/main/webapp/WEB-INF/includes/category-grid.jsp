<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.aspirantos.model.ExamCategory, com.aspirantos.dao.CategoryDAO, com.aspirantos.util.HtmlUtil, com.aspirantos.util.CategoryIcons" %>
<%--
    Category tiles with the number of exams in each category. Included at RUN time by home.jsp with
        <jsp:include page="/WEB-INF/includes/category-grid.jsp"><jsp:param name="heading" value="..."/></jsp:include>
    (unlike the include directive, this page is compiled on its own and its output is inserted).
    The tile colour comes from exam_category.accent_color.
--%>
<%
    List<ExamCategory> categories = new CategoryDAO().getAllCategories();
    String heading = request.getParameter("heading");    // set with <jsp:param>
%>
<section class="category-section" aria-labelledby="cat-heading">
    <h2 id="cat-heading"><%= HtmlUtil.escape(heading == null ? "Exam categories" : heading) %></h2>
    <div class="category-grid">
        <% for (ExamCategory c : categories) {
               String accent = c.getAccentColor() != null && c.getAccentColor().matches("#[0-9A-Fa-f]{6}") ? c.getAccentColor() : "#5B6478"; %>
        <a class="category-tile" href="<%= request.getContextPath() %>/aspirant/exams.jsp?category=<%= c.getCode() %>" style="--accent: <%= accent %>">
            <%= CategoryIcons.svg(c.getIconSvgName()) %>
            <span class="cat-name"><%= HtmlUtil.escape(c.getName()) %></span>
            <span class="cat-count"><%= c.getExamCount() %> exams</span>
        </a>
        <% } %>
    </div>
</section>
