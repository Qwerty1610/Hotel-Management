package com.mycompany.hotelmanagement.filter;

import java.io.IOException;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.mycompany.hotelmanagement.dal.PermissionDAO;
import java.util.List;

/**
 *
 * @author TungNQ
 * @version 1.0.5
 * Created: 01/06/2026
 * Modified: 16/07/2026
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = {
    "/admin/*", 
    "/manager/*", 
    "/receptionist/*", 
    "/housekeeping/*"
})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);
        
        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();
        String path = uri.substring(contextPath.length());
        
        boolean loggedIn = false;
        String role = null;
        if (session != null) {
            Object userAttr = session.getAttribute("user");
            if (userAttr != null) {
                loggedIn = true;
                Object roleAttr = session.getAttribute("role");
                if (roleAttr != null) {
                    role = roleAttr.toString();
                }
            }
        }
        
        boolean authorized = false;
        
        PermissionDAO permissionRepository = new PermissionDAO();
        List<String> allowedRoles = permissionRepository.getAllowedRolesForPath(path);
        
        if (allowedRoles.isEmpty()) {
            // General pages (no restriction in database RolePath)
            authorized = true;
        } else {
            for (String allowedRole : allowedRoles) {
                if (matchesRole(role, allowedRole)) {
                    authorized = true;
                    break;
                }
            }
        }
        
        if (authorized) {
            chain.doFilter(request, response);
        } else {
            if (role != null) {
                // Logged in but not authorized for this specific path -> Send HTTP 403 Forbidden
                res.sendError(HttpServletResponse.SC_FORBIDDEN);
            } else {
                // Not logged in -> Redirect to login page
                res.sendRedirect(contextPath + "/staff/login?error=unauthorized");
            }
        }
    }

    @Override
    public void destroy() {
    }

    private boolean matchesRole(String sessionRole, String dbRoleName) {
        if (sessionRole == null || dbRoleName == null) {
            return false;
        }
        switch (sessionRole.toUpperCase()) {
            case "ADMIN":
                return "Admin".equalsIgnoreCase(dbRoleName);
            case "HOTEL_MANAGER":
                return "Manager".equalsIgnoreCase(dbRoleName);
            case "RECEPTIONIST":
                return "Receptionist".equalsIgnoreCase(dbRoleName);
            case "HOUSEKEEPING":
                return "Housekeeping".equalsIgnoreCase(dbRoleName) || "Housekeeper".equalsIgnoreCase(dbRoleName);
            case "CUSTOMER":
                return "Customer".equalsIgnoreCase(dbRoleName);
            default:
                return sessionRole.equalsIgnoreCase(dbRoleName);
        }
    }
}
