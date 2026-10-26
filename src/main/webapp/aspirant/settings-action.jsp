<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="com.aspirantos.model.User, com.aspirantos.dao.UserDAO, com.aspirantos.dao.AuditDAO, com.aspirantos.dao.RememberTokenDAO, com.aspirantos.util.PasswordUtil, com.aspirantos.util.ValidationUtil" %>
<%--
    Settings action page (no HTML). One page, several actions (switch like StudentServlet):
      password      - checks the current password, saves a new hash, logs out other devices
      theme         - stores the theme in a cookie for one year
      forget        - deletes every "remember me" token of the user
      deleteAccount - deletes the student account (ON DELETE CASCADE removes the child rows)
--%>
<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>
<%
    if (!"POST".equals(request.getMethod())) {
        response.sendRedirect("settings.jsp");
        return;
    }
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();
    String cookiePath = ctx.isEmpty() ? "/" : ctx;
    String action = request.getParameter("action");
    if (action == null) {
        action = "";
    }
    UserDAO userDAO = new UserDAO();
    AuditDAO auditDAO = new AuditDAO();
    String ip = request.getRemoteAddr();
    String agent = request.getHeader("User-Agent");

    switch (action) {
        case "password": {
            String current = request.getParameter("currentPassword");
            String fresh = request.getParameter("newPassword");
            String confirm = request.getParameter("confirmPassword");
            User stored = userDAO.getUserByEmail(currentUser.getEmail());   // the session copy has no hash
            if (stored == null || ValidationUtil.isBlank(current)
                    || !PasswordUtil.verify(current, stored.getPasswordSalt(), stored.getPasswordHash())) {
                session.setAttribute("error", "Your current password is not correct.");
            } else if (!ValidationUtil.isValidPassword(fresh)) {
                session.setAttribute("error", "The new password must have at least 8 characters, with a letter and a number.");
            } else if (!fresh.equals(confirm)) {
                session.setAttribute("error", "The two new passwords do not match.");
            } else if (fresh.equals(current)) {
                session.setAttribute("error", "The new password must be different from the current one.");
            } else {
                String salt = PasswordUtil.newSalt();
                int rows = userDAO.updatePassword(currentUser.getId(), PasswordUtil.hash(fresh, salt), salt);
                new RememberTokenDAO().deleteTokensOfUser(currentUser.getId());   // other devices must log in again
                auditDAO.insertAudit(currentUser.getId(), "PASSWORD_CHANGE", "app_user", String.valueOf(currentUser.getId()), ip, agent);
                session.setAttribute("success", "Password changed (" + rows + " row affected). Other devices have been logged out.");
            }
            break;
        }
        case "theme": {
            String theme = "dark".equals(request.getParameter("theme")) ? "dark" : "light";
            Cookie themeCookie = new Cookie("theme", theme);   // cookies: a small value kept by the browser
            themeCookie.setMaxAge(365 * 24 * 60 * 60);         // one year, in seconds
            themeCookie.setPath(cookiePath);
            response.addCookie(themeCookie);
            session.setAttribute("success", "Theme set to " + theme + ".");
            break;
        }
        case "forget": {
            int rows = new RememberTokenDAO().deleteTokensOfUser(currentUser.getId());
            Cookie gone = new Cookie("remember", "");
            gone.setMaxAge(0);
            gone.setPath(cookiePath);
            response.addCookie(gone);
            session.setAttribute("success", "Logged out on all devices (" + rows + " saved login" + (rows == 1 ? "" : "s") + " removed).");
            break;
        }
        case "deleteAccount": {
            if ("ADMIN".equals(currentUser.getRole())) {
                session.setAttribute("error", "The administrator account cannot be deleted.");
                break;
            }
            User stored = userDAO.getUserByEmail(currentUser.getEmail());
            String password = request.getParameter("password");
            if (!"yes".equals(request.getParameter("confirm"))) {
                session.setAttribute("error", "Please tick the box to confirm that you want to delete your account.");
                break;
            }
            if (stored == null || ValidationUtil.isBlank(password)
                    || !PasswordUtil.verify(password, stored.getPasswordSalt(), stored.getPasswordHash())) {
                session.setAttribute("error", "Your password is not correct - the account was not deleted.");
                break;
            }
            int userId = currentUser.getId();
            auditDAO.insertAudit(userId, "ACCOUNT_DELETE", "app_user", String.valueOf(userId), ip, agent);
            int rows = userDAO.deleteUser(userId);
            Cookie gone = new Cookie("remember", "");
            gone.setMaxAge(0);
            gone.setPath(cookiePath);
            response.addCookie(gone);
            session.invalidate();
            HttpSession freshSession = request.getSession(true);
            freshSession.setAttribute(rows > 0 ? "success" : "error",
                    rows > 0 ? "Your account and all your data have been deleted." : "The account could not be deleted.");
            response.sendRedirect(ctx + "/login.jsp");
            return;
        }
        default:
            break;
    }
    response.sendRedirect("settings.jsp");
%>
