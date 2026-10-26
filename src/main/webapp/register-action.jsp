<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="error.jsp"%>
<%@ page import="com.aspirantos.model.User, com.aspirantos.dao.UserDAO, com.aspirantos.dao.AuditDAO, com.aspirantos.util.PasswordUtil, com.aspirantos.util.ValidationUtil" %>
<%--
    Register action page (no HTML). Server-side validation like EmployeeServlet (Experiment 5):
    on an error the message and the typed values go into the session and the browser is sent
    back to register.jsp; on success the account is created, the student is logged in and
    sent to the profile wizard.
--%>
<%
    if (!"POST".equals(request.getMethod())) {
        response.sendRedirect("register.jsp");
        return;
    }
    request.setCharacterEncoding("UTF-8");
    String fullName = request.getParameter("fullName");
    String email = request.getParameter("email");
    String phone = request.getParameter("phone");
    String password = request.getParameter("password");
    String confirmPassword = request.getParameter("confirmPassword");

    // typed values (never the password) so the form stays filled after an error
    User formUser = new User();
    formUser.setFullName(fullName == null ? "" : fullName.trim());
    formUser.setEmail(email == null ? "" : email.trim());
    formUser.setPhone(phone == null ? "" : phone.trim());

    String error = null;
    UserDAO userDAO = new UserDAO();
    if (!ValidationUtil.isValidName(fullName)) {
        error = "Please enter your full name (letters only, at least 3 characters).";
    } else if (!ValidationUtil.isValidEmail(email)) {
        error = "Please enter a valid e-mail address.";
    } else if (!ValidationUtil.isBlank(phone) && !ValidationUtil.isValidPhone(phone)) {
        error = "Mobile number must have exactly 10 digits.";
    } else if (!ValidationUtil.isValidPassword(password)) {
        error = "Password must have at least 8 characters, with at least one letter and one number.";
    } else if (!password.equals(confirmPassword)) {
        error = "The two passwords do not match.";
    } else if (userDAO.emailExists(email)) {
        error = "An account with this e-mail already exists. Please log in.";
    }
    if (error != null) {
        session.setAttribute("error", error);
        session.setAttribute("formUser", formUser);
        response.sendRedirect("register.jsp");
        return;
    }

    String salt = PasswordUtil.newSalt();
    User user = new User();
    user.setFullName(fullName.trim().replaceAll("\\s+", " "));
    user.setEmail(email.trim().toLowerCase());
    user.setPhone(ValidationUtil.clean(phone));
    user.setPasswordSalt(salt);
    user.setPasswordHash(PasswordUtil.hash(password, salt));
    user.setRole("ASPIRANT");
    user.setStatus("ACTIVE");
    int newId = userDAO.insertUser(user);
    if (newId == 0) {
        session.setAttribute("error", "The account could not be created. Please try again.");
        session.setAttribute("formUser", formUser);
        response.sendRedirect("register.jsp");
        return;
    }

    // log the new student in straight away
    User saved = userDAO.getUser(newId);
    saved.setPasswordHash(null);
    saved.setPasswordSalt(null);
    request.changeSessionId();   // [EXTRA] new session id after login (session fixation)
    session.setAttribute("user", saved);
    userDAO.updateLastLogin(newId);
    new AuditDAO().insertAudit(newId, "REGISTER", "app_user", String.valueOf(newId),
                               request.getRemoteAddr(), request.getHeader("User-Agent"));

    session.setAttribute("success", "Account created. Now fill in your profile - it takes about three minutes.");
    response.sendRedirect(request.getContextPath() + "/aspirant/profile-step1.jsp");
%>
