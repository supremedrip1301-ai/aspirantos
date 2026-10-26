<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.List, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.util.ValidationUtil" %>
<%--
    Profile save action (no HTML): last step of the wizard.
    1. checks the session bean once more (steps 1 and 2 are validated again on the server),
    2. saves the profile row (INSERT ... ON DUPLICATE KEY UPDATE) and the name / phone,
    3. saves "attempts used before the app" for the exams with an attempt limit,
    4. removes the wizard bean from the session and redirects to the dashboard (PRG).
    The database triggers delete old eligibility snapshots, so the results are recomputed.
--%>
<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>
<%@ include file="/WEB-INF/jspf/aspirant-only.jspf" %>
<jsp:useBean id="profile" class="com.aspirantos.model.ProfileBean" scope="session"/>
<%
    if (!"POST".equals(request.getMethod())) {
        response.sendRedirect("profile-step4.jsp");
        return;
    }
    request.setCharacterEncoding("UTF-8");
    if (!profile.isLoaded() || profile.validateStep1() != null) {
        session.setAttribute("error", profile.isLoaded() ? profile.validateStep1() : "Please start the profile from step 1.");
        response.sendRedirect("profile-step1.jsp");
        return;
    }
    if (profile.validateStep2() != null) {
        session.setAttribute("error", profile.validateStep2());
        response.sendRedirect("profile-step2.jsp");
        return;
    }

    // attempts typed in step 4 - every value is checked before anything is saved
    List<Exam> limitedExams = new ExamDAO().getExamsWithAttemptLimit();
    int[] attempts = new int[limitedExams.size()];
    for (int i = 0; i < limitedExams.size(); i++) {
        String raw = request.getParameter("attempts_" + limitedExams.get(i).getId());
        Integer value = ValidationUtil.isBlank(raw) ? Integer.valueOf(0) : ValidationUtil.parseIntOrNull(raw);
        if (!ValidationUtil.inRange(value, 0, 20)) {
            session.setAttribute("error", "Attempts for " + limitedExams.get(i).getShortName() + " must be a whole number from 0 to 20.");
            response.sendRedirect("profile-step4.jsp");
            return;
        }
        attempts[i] = value;
    }

    int userId = currentUser.getId();
    int educationRows = new EducationDAO().getEducationByUser(userId).size();
    Profile p = profile.toProfile(userId);
    p.setProfileCompletionPct(profile.completionPercent(educationRows));
    int rows = new ProfileDAO().saveProfile(p);

    // name and mobile number live in app_user
    User account = new User();
    account.setId(userId);
    account.setFullName(profile.getFullName().trim().replaceAll("\\s+", " "));
    account.setPhone(ValidationUtil.clean(profile.getPhone()));
    new UserDAO().updateUser(account);
    currentUser.setFullName(account.getFullName());   // the header shows the new name at once
    currentUser.setPhone(account.getPhone());

    // attempts before the app: kept in user_exam_tracking (the exam is tracked when attempts > 0)
    TrackingDAO trackingDAO = new TrackingDAO();
    int trackedNow = 0;
    for (int i = 0; i < limitedExams.size(); i++) {
        Exam x = limitedExams.get(i);
        Tracking existing = trackingDAO.getTracking(userId, x.getId());
        if (existing == null && attempts[i] == 0) {
            continue;
        }
        Tracking t = existing != null ? existing : new Tracking();
        t.setUserId(userId);
        t.setExamId(x.getId());
        t.setAttemptsUsedBeforeApp(attempts[i]);
        trackingDAO.trackExam(t);
        if (existing == null) {
            trackedNow++;
        }
    }

    new AuditDAO().insertAudit(userId, "PROFILE_SAVE", "aspirant_profile", String.valueOf(userId),
                               request.getRemoteAddr(), request.getHeader("User-Agent"));
    session.removeAttribute("profile");   // the wizard bean is no longer needed

    // INSERT ... ON DUPLICATE KEY UPDATE returns 1 for a new row, 2 for a changed row, 0 when nothing changed
    String message = rows == 1 ? "Profile created (1 row affected)." : "Profile saved.";
    if (trackedNow > 0) {
        message += " " + trackedNow + " exam" + (trackedNow == 1 ? " is" : "s are") + " now on your tracked list.";
    }
    session.setAttribute("success", message);
    response.sendRedirect("dashboard.jsp");
%>
