<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="error.jsp"%>
<%@ page import="java.time.LocalDateTime, com.aspirantos.model.User, com.aspirantos.dao.UserDAO, com.aspirantos.dao.ProfileDAO, com.aspirantos.dao.AuditDAO, com.aspirantos.dao.RememberTokenDAO, com.aspirantos.util.PasswordUtil, com.aspirantos.util.ValidationUtil" %>
<%--
    Login action page (no HTML): receives the POST from login.jsp, checks the e-mail and the
    password hash, stores the user in the HttpSession and redirects (Post/Redirect/Get).
--%>
<%
    if (!"POST".equals(request.getMethod())) {
        response.sendRedirect("login.jsp");
        return;
    }
    request.setCharacterEncoding("UTF-8");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    boolean remember = request.getParameter("remember") != null;
    String ip = request.getRemoteAddr();
    String agent = request.getHeader("User-Agent");

    session.setAttribute("formEmail", email == null ? "" : email.trim());

    if (!ValidationUtil.isValidEmail(email) || ValidationUtil.isBlank(password)) {
        session.setAttribute("error", "Please enter your e-mail address and password.");
        response.sendRedirect("login.jsp");
        return;
    }

    UserDAO userDAO = new UserDAO();
    AuditDAO auditDAO = new AuditDAO();
    User user = userDAO.getUserByEmail(email);
    boolean passwordOk;
    if (user == null) {
        PasswordUtil.hash(password, PasswordUtil.newSalt());   // same work as a real check, so the answer time does not reveal unknown e-mails
        passwordOk = false;
    } else {
        passwordOk = PasswordUtil.verify(password, user.getPasswordSalt(), user.getPasswordHash());
    }
    if (!passwordOk) {
        auditDAO.insertAudit(user == null ? null : user.getId(), "LOGIN_FAILED", "app_user", email.trim().toLowerCase(), ip, agent);
        session.setAttribute("error", "The e-mail or password is not correct.");
        response.sendRedirect("login.jsp");
        return;
    }
    if (!"ACTIVE".equals(user.getStatus())) {
        auditDAO.insertAudit(user.getId(), "LOGIN_BLOCKED", "app_user", String.valueOf(user.getId()), ip, agent);
        session.setAttribute("error", "This account is blocked. Please contact the administrator.");
        response.sendRedirect("login.jsp");
        return;
    }

    // logged in
    request.changeSessionId();   // [EXTRA] new session id after login (protects against session fixation)
    session.removeAttribute("formEmail");
    user.setPasswordHash(null);  // the session never keeps password data
    user.setPasswordSalt(null);
    session.setAttribute("user", user);
    userDAO.updateLastLogin(user.getId());
    auditDAO.insertAudit(user.getId(), "LOGIN", "app_user", String.valueOf(user.getId()), ip, agent);

    if (remember) {
        // [EXTRA] remember me: random token in an HttpOnly cookie, only its hash in the database
        String token = PasswordUtil.randomToken();
        new RememberTokenDAO().insertToken(user.getId(), PasswordUtil.sha256Hex(token), LocalDateTime.now().plusDays(14));
        Cookie rememberMe = new Cookie("remember", token);
        rememberMe.setMaxAge(14 * 24 * 60 * 60);
        rememberMe.setHttpOnly(true);
        rememberMe.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
        response.addCookie(rememberMe);
    }

    String ctx = request.getContextPath();
    if ("ADMIN".equals(user.getRole())) {
        session.setAttribute("success", "Welcome back, " + user.getFullName() + ".");
        response.sendRedirect(ctx + "/admin/dashboard.jsp");
    } else if (new ProfileDAO().getProfile(user.getId()) == null) {
        session.setAttribute("success", "Welcome! Let us fill in your profile first - it takes about three minutes.");
        response.sendRedirect(ctx + "/aspirant/profile-step1.jsp");
    } else {
        session.setAttribute("success", "Welcome back, " + user.getFullName() + ".");
        response.sendRedirect(ctx + "/aspirant/dashboard.jsp");
    }
%>
