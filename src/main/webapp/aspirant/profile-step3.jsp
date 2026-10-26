<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.List, java.util.ArrayList, java.util.Arrays, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.util.HtmlUtil, com.aspirantos.util.DateUtil" %>
<%--
    Profile wizard - step 3 of 4: education and work experience.
    Rows are saved straight away by education-action.jsp / experience-action.jsp (insert,
    update, delete with JDBC) and listed here with a for-loop like student-list.jsp.
    ?editEdu=<id> / ?editWork=<id> fill the form with an existing row (like edit-student.jsp).
--%>
<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>
<%@ include file="/WEB-INF/jspf/aspirant-only.jspf" %>
<jsp:useBean id="profile" class="com.aspirantos.model.ProfileBean" scope="session"/>
<%!
    // declaration: a small helper used by the table below
    private String levelLabel(String level) {
        switch (level) {
            case "CLASS_10": return "Class 10";
            case "CLASS_12": return "Class 12";
            case "DIPLOMA": return "Diploma";
            case "UG": return "Graduation";
            case "PG": return "Post-graduation";
            case "PHD": return "PhD";
            default: return "Professional";
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
    EducationDAO educationDAO = new EducationDAO();
    WorkExperienceDAO workDAO = new WorkExperienceDAO();
    List<Education> educations = educationDAO.getEducationByUser(currentUser.getId());
    List<WorkExperience> works = workDAO.getWorkByUser(currentUser.getId());

    // education form: values after a validation error, or the row being edited, or empty
    Education edu = (Education) session.getAttribute("formEducation");
    if (edu != null) {
        session.removeAttribute("formEducation");
    } else if (request.getParameter("editEdu") != null) {
        try {
            edu = educationDAO.getEducation(Integer.parseInt(request.getParameter("editEdu")));
        } catch (NumberFormatException e) {
            edu = null;
        }
        if (edu != null && edu.getUserId() != currentUser.getId()) {
            edu = null;   // never show another student's row
        }
    }
    if (edu == null) {
        edu = new Education();
        edu.setStatus("COMPLETED");
    }
    List<String> eduSubjects = new ArrayList<>();
    if (edu.getSubjects() != null) {
        for (String s : edu.getSubjects().split(",")) {
            if (!s.trim().isEmpty()) {
                eduSubjects.add(s.trim());
            }
        }
    }
    List<String> commonSubjects = Arrays.asList(Education.COMMON_SUBJECTS);
    StringBuilder otherSubjects = new StringBuilder();
    for (String s : eduSubjects) {
        if (!commonSubjects.contains(s)) {
            otherSubjects.append(otherSubjects.length() > 0 ? ", " : "").append(s);
        }
    }

    // work form
    WorkExperience work = (WorkExperience) session.getAttribute("formWork");
    if (work != null) {
        session.removeAttribute("formWork");
    } else if (request.getParameter("editWork") != null) {
        try {
            work = workDAO.getWork(Integer.parseInt(request.getParameter("editWork")));
        } catch (NumberFormatException e) {
            work = null;
        }
        if (work != null && work.getUserId() != currentUser.getId()) {
            work = null;
        }
    }
    if (work == null) {
        work = new WorkExperience();
    }

    String pageTitle = "Profile - education";
    int wizardStep = 3;
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<section class="wizard card">
    <%@ include file="/WEB-INF/jspf/wizard-steps.jspf" %>
    <h1>Education</h1>
    <p class="muted">Add Class 10, Class 12 and every degree. Final-year students: choose "Appearing" and give the expected result date.</p>
    <%@ include file="/WEB-INF/jspf/flash.jspf" %>

    <% if (educations.isEmpty()) { %>
    <p class="empty">No education added yet. Most exams need at least your highest qualification.</p>
    <% } else { %>
    <div class="table-wrap">
    <table>
        <thead><tr><th>Level</th><th>Degree / stream</th><th>Subjects</th><th>Marks</th><th>Year</th><th><span class="sr-only">Actions</span></th></tr></thead>
        <tbody>
        <% for (Education e : educations) { %>
        <tr>
            <td><%= levelLabel(e.getLevel()) %></td>
            <td><%= HtmlUtil.orDash(e.getDegreeName()) %><% if (e.getStreamOrSpecialisation() != null) { %><br><span class="muted"><%= HtmlUtil.escape(e.getStreamOrSpecialisation()) %></span><% } %></td>
            <td class="small"><%= HtmlUtil.orDash(e.getSubjects() == null ? null : e.getSubjects().replace(",", ", ")) %></td>
            <td><%= e.getPercentage() != null ? e.getPercentage() + "%" : (e.getCgpa() != null ? e.getCgpa() + " / " + (e.getCgpaScale() == null ? 10 : e.getCgpaScale()) : "-") %></td>
            <td><%= "APPEARING".equals(e.getStatus()) ? "Appearing (result " + DateUtil.format(e.getExpectedCompletionDate()) + ")" : HtmlUtil.orDash(e.getPassingYear()) %></td>
            <td class="actions">
                <a href="profile-step3.jsp?editEdu=<%= e.getId() %>#education-form">Edit</a>
                <a href="education-action.jsp?action=delete&amp;id=<%= e.getId() %>" data-confirm="Delete this education row?">Delete</a>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
    </div>
    <% } %>

    <form id="education-form" class="sub-form" action="education-action.jsp" method="post" data-validate="education" novalidate>
        <h2><%= edu.getId() > 0 ? "Edit education" : "Add education" %></h2>
        <input type="hidden" name="action" value="save">
        <input type="hidden" name="id" value="<%= edu.getId() %>">
        <div class="form-grid">
            <div>
                <label for="level">Level</label>
                <select id="level" name="level" required>
                    <option value="">Choose...</option>
                    <option value="CLASS_10" <%= HtmlUtil.selected(edu.getLevel(), "CLASS_10") %>>Class 10</option>
                    <option value="CLASS_12" <%= HtmlUtil.selected(edu.getLevel(), "CLASS_12") %>>Class 12</option>
                    <option value="DIPLOMA" <%= HtmlUtil.selected(edu.getLevel(), "DIPLOMA") %>>Diploma (after Class 10)</option>
                    <option value="UG" <%= HtmlUtil.selected(edu.getLevel(), "UG") %>>Graduation (bachelor's degree)</option>
                    <option value="PG" <%= HtmlUtil.selected(edu.getLevel(), "PG") %>>Post-graduation (master's degree)</option>
                    <option value="PHD" <%= HtmlUtil.selected(edu.getLevel(), "PHD") %>>PhD</option>
                    <option value="PROFESSIONAL" <%= HtmlUtil.selected(edu.getLevel(), "PROFESSIONAL") %>>Professional (CA, CS, CMA ...)</option>
                </select>
            </div>
            <div>
                <label for="degreeName">Degree / course <span class="muted">(not needed for Class 10 / 12)</span></label>
                <input type="text" id="degreeName" name="degreeName" list="degree-list" value="<%= HtmlUtil.escape(edu.getDegreeName()) %>" maxlength="60">
                <datalist id="degree-list">
                    <option value="B.A."><option value="B.Sc"><option value="B.Com"><option value="B.Tech"><option value="B.E.">
                    <option value="BCA"><option value="BBA"><option value="MBBS"><option value="BDS"><option value="B.Pharm">
                    <option value="LLB"><option value="B.Ed"><option value="B.Sc Nursing"><option value="M.A."><option value="M.Sc">
                    <option value="M.Com"><option value="M.Tech"><option value="MCA"><option value="MBA"><option value="LLM">
                    <option value="CA"><option value="CS"><option value="CMA"><option value="Ph.D"><option value="Diploma in Engineering">
                </datalist>
            </div>
            <div>
                <label for="streamOrSpecialisation">Stream / specialisation <span class="muted">(optional)</span></label>
                <input type="text" id="streamOrSpecialisation" name="streamOrSpecialisation" value="<%= HtmlUtil.escape(edu.getStreamOrSpecialisation()) %>" maxlength="100" placeholder="e.g. Science, Computer Science, History">
            </div>
            <div>
                <label for="boardOrUniversity">Board / university <span class="muted">(optional)</span></label>
                <input type="text" id="boardOrUniversity" name="boardOrUniversity" value="<%= HtmlUtil.escape(edu.getBoardOrUniversity()) %>" maxlength="150">
            </div>
        </div>

        <fieldset class="choice-group subjects">
            <legend>Subjects studied <span class="muted">(some exams need particular subjects)</span></legend>
            <% for (String s : Education.COMMON_SUBJECTS) { %>
            <label class="check"><input type="checkbox" name="subject" value="<%= s %>" <%= HtmlUtil.checked(eduSubjects.contains(s)) %>> <%= s.charAt(0) + s.substring(1).toLowerCase() %></label>
            <% } %>
            <div class="span-all">
                <label for="otherSubjects">Other subjects <span class="muted">(comma separated)</span></label>
                <input type="text" id="otherSubjects" name="otherSubjects" value="<%= HtmlUtil.escape(otherSubjects.toString()) %>" maxlength="200" placeholder="e.g. Sociology, Psychology">
            </div>
        </fieldset>

        <div class="form-grid">
            <div>
                <label for="percentage">Percentage <span class="muted">(or CGPA)</span></label>
                <input type="number" id="percentage" name="percentage" value="<%= edu.getPercentage() == null ? "" : edu.getPercentage() %>" min="0" max="100" step="0.01">
            </div>
            <div class="pair">
                <div>
                    <label for="cgpa">CGPA</label>
                    <input type="number" id="cgpa" name="cgpa" value="<%= edu.getCgpa() == null ? "" : edu.getCgpa() %>" min="0" max="10" step="0.01">
                </div>
                <div>
                    <label for="cgpaScale">out of</label>
                    <input type="number" id="cgpaScale" name="cgpaScale" value="<%= edu.getCgpaScale() == null ? "10" : edu.getCgpaScale() %>" min="4" max="10" step="0.01">
                </div>
            </div>
        </div>

        <fieldset class="choice-group">
            <legend>Status</legend>
            <label class="check"><input type="radio" name="status" value="COMPLETED" <%= HtmlUtil.checked(!"APPEARING".equals(edu.getStatus())) %>> Completed</label>
            <label class="check"><input type="radio" name="status" value="APPEARING" data-reveal="appearing-details" <%= HtmlUtil.checked("APPEARING".equals(edu.getStatus())) %>> Appearing / final year</label>
        </fieldset>
        <div class="form-grid">
            <div class="completed-only">
                <label for="passingYear">Passing year</label>
                <input type="number" id="passingYear" name="passingYear" value="<%= edu.getPassingYear() == null ? "" : edu.getPassingYear() %>" min="1960" max="2100">
            </div>
            <div class="reveal" id="appearing-details">
                <label for="expectedCompletionDate">Expected result date</label>
                <input type="date" id="expectedCompletionDate" name="expectedCompletionDate" value="<%= DateUtil.toInput(edu.getExpectedCompletionDate()) %>">
            </div>
        </div>
        <div class="form-actions">
            <% if (edu.getId() > 0) { %><a class="btn" href="profile-step3.jsp">Cancel edit</a><% } %>
            <button type="submit" class="btn btn-primary"><%= edu.getId() > 0 ? "Update education" : "Add education" %></button>
        </div>
    </form>

    <h2 class="section-title">Work experience <span class="muted">(optional)</span></h2>
    <p class="muted">Needed only for exams that ask for experience, for example some PG and judicial exams.</p>
    <% if (!works.isEmpty()) { %>
    <div class="table-wrap">
    <table>
        <thead><tr><th>Organisation</th><th>Designation</th><th>From</th><th>To</th><th>Type</th><th><span class="sr-only">Actions</span></th></tr></thead>
        <tbody>
        <% for (WorkExperience w : works) { %>
        <tr>
            <td><%= HtmlUtil.escape(w.getOrganisation()) %></td>
            <td><%= HtmlUtil.orDash(w.getDesignation()) %></td>
            <td><%= DateUtil.format(w.getStartDate()) %></td>
            <td><%= w.getEndDate() == null ? "Present" : DateUtil.format(w.getEndDate()) %></td>
            <td><%= w.isGovt() ? "Government" : "Private" %><%= w.isRelevantProfessional() ? ", professional" : "" %></td>
            <td class="actions">
                <a href="profile-step3.jsp?editWork=<%= w.getId() %>#work-form">Edit</a>
                <a href="experience-action.jsp?action=delete&amp;id=<%= w.getId() %>" data-confirm="Delete this work experience?">Delete</a>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
    </div>
    <% } %>

    <form id="work-form" class="sub-form" action="experience-action.jsp" method="post" data-validate="work" novalidate>
        <h3><%= work.getId() > 0 ? "Edit work experience" : "Add work experience" %></h3>
        <input type="hidden" name="action" value="save">
        <input type="hidden" name="id" value="<%= work.getId() %>">
        <div class="form-grid">
            <div>
                <label for="organisation">Organisation</label>
                <input type="text" id="organisation" name="organisation" value="<%= HtmlUtil.escape(work.getOrganisation()) %>" maxlength="150">
            </div>
            <div>
                <label for="designation">Designation <span class="muted">(optional)</span></label>
                <input type="text" id="designation" name="designation" value="<%= HtmlUtil.escape(work.getDesignation()) %>" maxlength="100">
            </div>
            <div>
                <label for="startDate">From</label>
                <input type="date" id="startDate" name="startDate" value="<%= DateUtil.toInput(work.getStartDate()) %>">
            </div>
            <div>
                <label for="endDate">To <span class="muted">(leave empty if you still work there)</span></label>
                <input type="date" id="endDate" name="endDate" value="<%= DateUtil.toInput(work.getEndDate()) %>">
            </div>
        </div>
        <label class="check"><input type="checkbox" name="govt" value="true" <%= HtmlUtil.checked(work.isGovt()) %>> Government job</label>
        <label class="check"><input type="checkbox" name="relevantProfessional" value="true" <%= HtmlUtil.checked(work.isRelevantProfessional()) %>> Professional experience in my field (e.g. practice as an advocate)</label>
        <div class="form-actions">
            <% if (work.getId() > 0) { %><a class="btn" href="profile-step3.jsp">Cancel edit</a><% } %>
            <button type="submit" class="btn"><%= work.getId() > 0 ? "Update experience" : "Add experience" %></button>
        </div>
    </form>

    <div class="wizard-nav">
        <a class="btn" href="profile-step2.jsp">Back</a>
        <a class="btn btn-primary" href="profile-step4.jsp">Continue</a>
    </div>
</section>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
