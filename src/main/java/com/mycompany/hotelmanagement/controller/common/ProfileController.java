package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;

import com.mycompany.hotelmanagement.entity.ProfileView;
import com.mycompany.hotelmanagement.service.ProfileService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Controller for viewing and editing the personal profile of the currently
 * logged-in user. Shared by every role: Customers reach it through the
 * "Hồ sơ" dropdown item ({@code /customer/profile}); staff, manager and admin
 * reach it by clicking their avatar/name ({@code /profile}).
 *
 * The page is not behind {@code AuthFilter} (which only guards role-specific
 * areas), so the controller performs its own session check (use case E1).
 *
 * @author QuyPQ
 */
@WebServlet(name = "ProfileController", urlPatterns = {"/profile", "/customer/profile"})
public class ProfileController extends HttpServlet {

    private final ProfileService profileService = new ProfileService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer accountId = resolveAccountId(session);
        if (accountId == null) {
            // E1 - Session expired / not logged in
            response.sendRedirect(request.getContextPath() + "/home/login?error=session_timeout");
            return;
        }

        ProfileView profile = profileService.getProfile(accountId);
        if (profile == null) {
            response.sendRedirect(request.getContextPath() + "/home/login?error=session_timeout");
            return;
        }

        request.setAttribute("profile", profile);
        request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer accountId = resolveAccountId(session);
        // The path this servlet was reached through (/profile or /customer/profile),
        // so the post-redirect-get stays on the same URL for every role.
        String selfPath = request.getContextPath() + request.getServletPath();
        if (accountId == null) {
            response.sendRedirect(request.getContextPath() + "/home/login?error=session_timeout");
            return;
        }

        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");

        String result = profileService.updateProfile(accountId, fullName, phone);

        if ("success".equals(result)) {
            // Keep the navbar/sidebar display name in sync with the saved name.
            if (fullName != null && !fullName.trim().isEmpty()) {
                session.setAttribute("user", fullName.trim());
            }
            response.sendRedirect(selfPath + "?result=" + result);
        } else {
            response.sendRedirect(selfPath + "?error=" + result);
        }
    }

    /** Extract the logged-in account id from the session, or null if absent. */
    private Integer resolveAccountId(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object user = session.getAttribute("user");
        Object accountIdAttr = session.getAttribute("accountId");
        if (user == null || accountIdAttr == null) {
            return null;
        }
        try {
            int id = Integer.parseInt(accountIdAttr.toString());
            return id > 0 ? id : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
