<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.List, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.util.HtmlUtil" %>
<%--
    Profile wizard - step 1 of 4: personal details.
    The wizard keeps its values in a session-scoped JavaBean (jsp:useBean). The form posts back
    to this page; jsp:setProperty property="*" copies every parameter into the bean property
    with the same name, the bean validates itself and the browser goes on to step 2 (PRG).
--%>
<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>
<%@ include file="/WEB-INF/jspf/aspirant-only.jspf" %>
<jsp:useBean id="profile" class="com.aspirantos.model.ProfileBean" scope="session"/>
<%
    if (!profile.isLoaded()) {
        // first visit: start from the saved account and profile (if there is one)
        profile.loadFrom(new UserDAO().getUser(currentUser.getId()), new ProfileDAO().getProfile(currentUser.getId()));
    }
    List<State> states = new StateDAO().getAllStates();

    if ("POST".equals(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        profile.clearStep1();
%>
<jsp:setProperty name="profile" property="*"/>
<%
        String problem = profile.validateStep1();
        boolean stateFound = false;
        for (State s : states) {
            if (s.getCode().equals(profile.getDomicileStateCode())) {
                stateFound = true;
            }
        }
        if (problem == null && !stateFound) {
            problem = "Please choose your domicile state from the list.";
        }
        if (problem != null) {
            session.setAttribute("error", problem);     // the typed values stay in the session bean
            response.sendRedirect("profile-step1.jsp");
            return;
        }
        profile.markStep1Done();
        response.sendRedirect("profile-step2.jsp");
        return;
    }

    String pageTitle = "Profile - personal details";
    int wizardStep = 1;
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<section class="wizard card">
    <%@ include file="/WEB-INF/jspf/wizard-steps.jspf" %>
    <h1>Personal details</h1>
    <p class="muted">Fill these exactly as in your Class 10 certificate - most exams use the same details.</p>
    <%@ include file="/WEB-INF/jspf/flash.jspf" %>

    <form action="profile-step1.jsp" method="post" data-validate="step1" novalidate>
        <div class="form-grid">
            <div>
                <label for="fullName">Full name</label>
                <input type="text" id="fullName" name="fullName" value="<%= HtmlUtil.escape(profile.getFullName()) %>"
                       maxlength="100" pattern="[A-Za-z .']{3,100}" required>
            </div>
            <div>
                <label for="phone">Mobile number <span class="muted">(optional)</span></label>
                <input type="tel" id="phone" name="phone" value="<%= HtmlUtil.escape(profile.getPhone()) %>"
                       maxlength="10" pattern="\d{10}" inputmode="numeric">
            </div>
            <div>
                <label for="dob">Date of birth</label>
                <input type="date" id="dob" name="dob" value="<%= HtmlUtil.escape(profile.getDob()) %>" required>
                <p class="hint">Age limits are counted from this date.</p>
            </div>
            <div>
                <label for="gender">Gender</label>
                <select id="gender" name="gender" required>
                    <option value="">Choose...</option>
                    <option value="MALE" <%= HtmlUtil.selected(profile.getGender(), "MALE") %>>Male</option>
                    <option value="FEMALE" <%= HtmlUtil.selected(profile.getGender(), "FEMALE") %>>Female</option>
                    <option value="TRANSGENDER" <%= HtmlUtil.selected(profile.getGender(), "TRANSGENDER") %>>Transgender</option>
                </select>
            </div>
            <div>
                <label for="maritalStatus">Marital status</label>
                <select id="maritalStatus" name="maritalStatus" required>
                    <option value="">Choose...</option>
                    <option value="UNMARRIED" <%= HtmlUtil.selected(profile.getMaritalStatus(), "UNMARRIED") %>>Unmarried</option>
                    <option value="MARRIED" <%= HtmlUtil.selected(profile.getMaritalStatus(), "MARRIED") %>>Married</option>
                    <option value="WIDOWED" <%= HtmlUtil.selected(profile.getMaritalStatus(), "WIDOWED") %>>Widowed</option>
                    <option value="DIVORCED" <%= HtmlUtil.selected(profile.getMaritalStatus(), "DIVORCED") %>>Divorced</option>
                </select>
                <p class="hint">Defence entries such as NDA and CDS are for unmarried candidates.</p>
            </div>
            <div>
                <label for="nationality">Nationality</label>
                <select id="nationality" name="nationality" required>
                    <option value="INDIAN" <%= HtmlUtil.selected(profile.getNationality(), "INDIAN") %>>Indian</option>
                    <option value="NEPAL" <%= HtmlUtil.selected(profile.getNationality(), "NEPAL") %>>Subject of Nepal</option>
                    <option value="BHUTAN" <%= HtmlUtil.selected(profile.getNationality(), "BHUTAN") %>>Subject of Bhutan</option>
                    <option value="TIBETAN_REFUGEE" <%= HtmlUtil.selected(profile.getNationality(), "TIBETAN_REFUGEE") %>>Tibetan refugee (settled before 1 Jan 1962)</option>
                    <option value="PIO" <%= HtmlUtil.selected(profile.getNationality(), "PIO") %>>Person of Indian origin</option>
                    <option value="OTHER" <%= HtmlUtil.selected(profile.getNationality(), "OTHER") %>>Other</option>
                </select>
            </div>
            <div>
                <label for="domicileStateCode">Domicile state / UT</label>
                <select id="domicileStateCode" name="domicileStateCode" required>
                    <option value="">Choose...</option>
                    <% for (State s : states) { %>
                    <option value="<%= s.getCode() %>" <%= HtmlUtil.selected(profile.getDomicileStateCode(), s.getCode()) %>><%= HtmlUtil.escape(s.getName()) %></option>
                    <% } %>
                </select>
                <p class="hint">State exams give reserved-category benefits only to their own domicile.</p>
            </div>
            <div>
                <label for="fatherName">Father's name <span class="muted">(optional)</span></label>
                <input type="text" id="fatherName" name="fatherName" value="<%= HtmlUtil.escape(profile.getFatherName()) %>" maxlength="100">
            </div>
            <div>
                <label for="motherName">Mother's name <span class="muted">(optional)</span></label>
                <input type="text" id="motherName" name="motherName" value="<%= HtmlUtil.escape(profile.getMotherName()) %>" maxlength="100">
            </div>
            <div class="span-2">
                <label for="addressLine">Address <span class="muted">(optional)</span></label>
                <input type="text" id="addressLine" name="addressLine" value="<%= HtmlUtil.escape(profile.getAddressLine()) %>" maxlength="200">
            </div>
            <div>
                <label for="city">City <span class="muted">(optional)</span></label>
                <input type="text" id="city" name="city" value="<%= HtmlUtil.escape(profile.getCity()) %>" maxlength="80">
            </div>
            <div>
                <label for="pincode">PIN code <span class="muted">(optional)</span></label>
                <input type="text" id="pincode" name="pincode" value="<%= HtmlUtil.escape(profile.getPincode()) %>"
                       maxlength="6" pattern="[1-9]\d{5}" inputmode="numeric">
            </div>
        </div>
        <div class="wizard-nav">
            <a class="btn" href="dashboard.jsp">Cancel</a>
            <button type="submit" class="btn btn-primary">Save and continue</button>
        </div>
    </form>
</section>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
