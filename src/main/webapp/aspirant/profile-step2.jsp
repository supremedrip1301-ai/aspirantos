<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="com.aspirantos.dao.UserDAO, com.aspirantos.dao.ProfileDAO, com.aspirantos.util.HtmlUtil" %>
<%--
    Profile wizard - step 2 of 4: category and special status (PwBD, ex-serviceman,
    government employee, J&K 1980-89). Same pattern as step 1: post back to this page,
    jsp:setProperty fills the session bean, the bean validates, then on to step 3.
--%>
<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>
<%@ include file="/WEB-INF/jspf/aspirant-only.jspf" %>
<jsp:useBean id="profile" class="com.aspirantos.model.ProfileBean" scope="session"/>
<%
    if (!profile.isLoaded()) {
        profile.loadFrom(new UserDAO().getUser(currentUser.getId()), new ProfileDAO().getProfile(currentUser.getId()));
    }
    if (!profile.isStep1Done()) {
        session.setAttribute("error", "Please complete step 1 first.");
        response.sendRedirect("profile-step1.jsp");
        return;
    }
    if ("POST".equals(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        profile.clearStep2();     // unticked check boxes send nothing, so start from "false"
%>
<jsp:setProperty name="profile" property="*"/>
<%
        String problem = profile.validateStep2();
        if (problem != null) {
            session.setAttribute("error", problem);
            response.sendRedirect("profile-step2.jsp");
            return;
        }
        profile.markStep2Done();
        response.sendRedirect("profile-step3.jsp");
        return;
    }

    String pageTitle = "Profile - category and status";
    int wizardStep = 2;
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<section class="wizard card">
    <%@ include file="/WEB-INF/jspf/wizard-steps.jspf" %>
    <h1>Category and special status</h1>
    <p class="muted">These decide your age relaxation and how many attempts you get.</p>
    <%@ include file="/WEB-INF/jspf/flash.jspf" %>

    <form action="profile-step2.jsp" method="post" data-validate="step2" novalidate>
        <fieldset class="choice-group">
            <legend>Category</legend>
            <label class="check"><input type="radio" name="category" value="GEN" <%= HtmlUtil.checked("GEN".equals(profile.getCategory())) %> required> General (also OBC creamy layer)</label>
            <label class="check"><input type="radio" name="category" value="EWS" <%= HtmlUtil.checked("EWS".equals(profile.getCategory())) %>> EWS (Economically Weaker Section)</label>
            <label class="check"><input type="radio" name="category" value="OBC_NCL" <%= HtmlUtil.checked("OBC_NCL".equals(profile.getCategory())) %>> OBC - non-creamy layer</label>
            <label class="check"><input type="radio" name="category" value="SC" <%= HtmlUtil.checked("SC".equals(profile.getCategory())) %>> SC</label>
            <label class="check"><input type="radio" name="category" value="ST" <%= HtmlUtil.checked("ST".equals(profile.getCategory())) %>> ST</label>
        </fieldset>

        <fieldset class="choice-group">
            <legend>Special status <span class="muted">(tick all that apply)</span></legend>

            <label class="check"><input type="checkbox" name="pwbd" value="true" data-reveal="pwbd-details" <%= HtmlUtil.checked(profile.isPwbd()) %>> Person with benchmark disability (PwBD)</label>
            <div class="reveal form-grid" id="pwbd-details">
                <div>
                    <label for="pwbdType">Type of disability</label>
                    <select id="pwbdType" name="pwbdType">
                        <option value="">Choose...</option>
                        <option value="LOCOMOTOR" <%= HtmlUtil.selected(profile.getPwbdType(), "LOCOMOTOR") %>>Locomotor</option>
                        <option value="VISUAL" <%= HtmlUtil.selected(profile.getPwbdType(), "VISUAL") %>>Visual</option>
                        <option value="HEARING" <%= HtmlUtil.selected(profile.getPwbdType(), "HEARING") %>>Hearing</option>
                        <option value="SPEECH_LANGUAGE" <%= HtmlUtil.selected(profile.getPwbdType(), "SPEECH_LANGUAGE") %>>Speech and language</option>
                        <option value="INTELLECTUAL" <%= HtmlUtil.selected(profile.getPwbdType(), "INTELLECTUAL") %>>Intellectual</option>
                        <option value="MENTAL_ILLNESS" <%= HtmlUtil.selected(profile.getPwbdType(), "MENTAL_ILLNESS") %>>Mental illness</option>
                        <option value="MULTIPLE" <%= HtmlUtil.selected(profile.getPwbdType(), "MULTIPLE") %>>Multiple disabilities</option>
                        <option value="OTHER" <%= HtmlUtil.selected(profile.getPwbdType(), "OTHER") %>>Other</option>
                    </select>
                </div>
                <div>
                    <label for="pwbdPercent">Disability percentage (as on the certificate)</label>
                    <input type="number" id="pwbdPercent" name="pwbdPercent" value="<%= HtmlUtil.escape(profile.getPwbdPercent()) %>" min="1" max="100" step="1">
                    <p class="hint">Relaxations need a benchmark disability of 40% or more.</p>
                </div>
            </div>

            <label class="check"><input type="checkbox" name="exServiceman" value="true" data-reveal="esm-details" <%= HtmlUtil.checked(profile.isExServiceman()) %>> Ex-serviceman</label>
            <div class="reveal form-grid" id="esm-details">
                <div>
                    <label for="esmServiceYears">Years of military service</label>
                    <input type="number" id="esmServiceYears" name="esmServiceYears" value="<%= HtmlUtil.escape(profile.getEsmServiceYears()) %>" min="0.5" max="40" step="0.5">
                    <p class="hint">Some exams deduct this from your age.</p>
                </div>
                <div>
                    <label for="esmReleaseDate">Release date <span class="muted">(optional)</span></label>
                    <input type="date" id="esmReleaseDate" name="esmReleaseDate" value="<%= HtmlUtil.escape(profile.getEsmReleaseDate()) %>">
                </div>
            </div>

            <label class="check"><input type="checkbox" name="govtEmployee" value="true" data-reveal="govt-details" <%= HtmlUtil.checked(profile.isGovtEmployee()) %>> Central / state government employee</label>
            <div class="reveal form-grid" id="govt-details">
                <div>
                    <label for="govtServiceYears">Years of continuous service <span class="muted">(optional)</span></label>
                    <input type="number" id="govtServiceYears" name="govtServiceYears" value="<%= HtmlUtil.escape(profile.getGovtServiceYears()) %>" min="0" max="45" step="0.5">
                </div>
            </div>

            <label class="check"><input type="checkbox" name="jkDomicile198089" value="true" <%= HtmlUtil.checked(profile.isJkDomicile198089()) %>> Domiciled in Jammu &amp; Kashmir between 1 Jan 1980 and 31 Dec 1989</label>
        </fieldset>

        <div class="wizard-nav">
            <a class="btn" href="profile-step1.jsp">Back</a>
            <button type="submit" class="btn btn-primary">Save and continue</button>
        </div>
    </form>
</section>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
