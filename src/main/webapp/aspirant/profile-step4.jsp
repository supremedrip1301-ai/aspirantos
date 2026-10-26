<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.List, java.util.Map, java.util.HashMap, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.util.HtmlUtil, com.aspirantos.util.DateUtil" %>
<%--
    Profile wizard - step 4 of 4: attempts already used + review of everything.
    The review shows the session bean with <jsp:getProperty>; the form posts to
    profile-save.jsp, which saves the profile with JDBC and redirects to the dashboard.
--%>
<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>
<%@ include file="/WEB-INF/jspf/aspirant-only.jspf" %>
<jsp:useBean id="profile" class="com.aspirantos.model.ProfileBean" scope="session"/>
<%!
    // declaration: readable words for the stored codes
    private String label(String code) {
        if (code == null || code.isEmpty()) {
            return "-";
        }
        switch (code) {
            case "GEN": return "General";
            case "OBC_NCL": return "OBC (non-creamy layer)";
            case "TIBETAN_REFUGEE": return "Tibetan refugee";
            case "PIO": return "Person of Indian origin";
            case "SPEECH_LANGUAGE": return "Speech and language";
            case "MENTAL_ILLNESS": return "Mental illness";
            default:
                String s = code.replace('_', ' ').toLowerCase();
                return code.length() <= 3 ? code : Character.toUpperCase(s.charAt(0)) + s.substring(1);
        }
    }
%>
<%
    if (!profile.isLoaded()) {
        profile.loadFrom(new UserDAO().getUser(currentUser.getId()), new ProfileDAO().getProfile(currentUser.getId()));
    }
    if (!profile.isStep2Done()) {
        session.setAttribute("error", "Please complete the earlier steps first.");
        response.sendRedirect(profile.isStep1Done() ? "profile-step2.jsp" : "profile-step1.jsp");
        return;
    }
    List<Exam> limitedExams = new ExamDAO().getExamsWithAttemptLimit();
    Map<Integer, Integer> usedBefore = new HashMap<>();
    for (Tracking t : new TrackingDAO().getTrackingByUser(currentUser.getId())) {
        usedBefore.put(t.getExamId(), t.getAttemptsUsedBeforeApp());
    }
    List<Education> educations = new EducationDAO().getEducationByUser(currentUser.getId());
    List<State> states = new StateDAO().getAllStates();
    String stateName = new StateDAO().getStateName(profile.getDomicileStateCode(), states);

    String pageTitle = "Profile - attempts and review";
    int wizardStep = 4;
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<section class="wizard card">
    <%@ include file="/WEB-INF/jspf/wizard-steps.jspf" %>
    <h1>Attempts already used</h1>
    <p class="muted">Only these exams limit the number of attempts. Enter the attempts you used <strong>before</strong> joining - later attempts go in your attempt journal.
       Count them the way the exam does (for UPSC, appearing in at least one Prelims paper is an attempt; only applying is not).</p>
    <%@ include file="/WEB-INF/jspf/flash.jspf" %>

    <form action="profile-save.jsp" method="post" data-validate="step4" novalidate>
        <div class="table-wrap">
        <table class="attempts-table">
            <thead><tr><th>Exam</th><th>Category</th><th>Attempts used</th></tr></thead>
            <tbody>
            <% for (Exam x : limitedExams) {
                   Integer used = usedBefore.get(x.getId()); %>
            <tr>
                <td><label for="attempts_<%= x.getId() %>"><strong><%= HtmlUtil.escape(x.getShortName()) %></strong></label><br><span class="muted small"><%= HtmlUtil.escape(x.getName()) %></span></td>
                <td class="small"><%= HtmlUtil.escape(x.getCategoryName()) %></td>
                <td><input type="number" class="num" id="attempts_<%= x.getId() %>" name="attempts_<%= x.getId() %>"
                           value="<%= used == null ? 0 : used %>" min="0" max="20" step="1"></td>
            </tr>
            <% } %>
            </tbody>
        </table>
        </div>

        <h2 class="section-title">Review</h2>
        <div class="review-grid">
            <div class="review-block">
                <h3>Personal <a class="small" href="profile-step1.jsp">Edit</a></h3>
                <dl>
                    <dt>Name</dt><dd><jsp:getProperty name="profile" property="fullName"/></dd>
                    <dt>Date of birth</dt><dd><%= DateUtil.format(DateUtil.parse(profile.getDob())) %> (<jsp:getProperty name="profile" property="ageText"/> today)</dd>
                    <dt>Gender</dt><dd><%= label(profile.getGender()) %></dd>
                    <dt>Marital status</dt><dd><%= label(profile.getMaritalStatus()) %></dd>
                    <dt>Nationality</dt><dd><%= label(profile.getNationality()) %></dd>
                    <dt>Domicile</dt><dd><%= HtmlUtil.escape(stateName) %></dd>
                    <dt>City / PIN</dt><dd><%= HtmlUtil.orDash(profile.getCity()) %> <%= HtmlUtil.escape(profile.getPincode()) %></dd>
                </dl>
            </div>
            <div class="review-block">
                <h3>Category and status <a class="small" href="profile-step2.jsp">Edit</a></h3>
                <dl>
                    <dt>Category</dt><dd><%= label(profile.getCategory()) %></dd>
                    <dt>PwBD</dt><dd><%= profile.isPwbd() ? label(profile.getPwbdType()) + ", " + HtmlUtil.escape(profile.getPwbdPercent()) + "%" : "No" %></dd>
                    <dt>Ex-serviceman</dt><dd><%= profile.isExServiceman() ? HtmlUtil.escape(profile.getEsmServiceYears()) + " years of service" : "No" %></dd>
                    <dt>Government employee</dt><dd><%= profile.isGovtEmployee() ? "Yes" : "No" %></dd>
                    <dt>J&amp;K 1980-89</dt><dd><%= profile.isJkDomicile198089() ? "Yes" : "No" %></dd>
                </dl>
            </div>
            <div class="review-block">
                <h3>Education <a class="small" href="profile-step3.jsp">Edit</a></h3>
                <% if (educations.isEmpty()) { %>
                <p class="warn-text">No education added - many exams cannot be checked without it.</p>
                <% } else { %>
                <ul class="plain">
                    <% for (Education e : educations) { %>
                    <li><%= HtmlUtil.escape(e.getDegreeName() != null ? e.getDegreeName() : label(e.getLevel())) %>
                        <span class="muted">- <%= "APPEARING".equals(e.getStatus()) ? "appearing" : HtmlUtil.orDash(e.getPassingYear()) %></span></li>
                    <% } %>
                </ul>
                <% } %>
            </div>
        </div>

        <div class="wizard-nav">
            <a class="btn" href="profile-step3.jsp">Back</a>
            <button type="submit" class="btn btn-primary">Save my profile</button>
        </div>
    </form>
</section>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
