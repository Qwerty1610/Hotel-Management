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
        
        if (path.startsWith("/admin")) {
            if ("ADMIN".equals(role)) {
                authorized = true;
            }
        } else if (path.startsWith("/manager")) {
            if ("HOTEL_MANAGER".equals(role)) {
                authorized = true;
            }
        } else if (path.startsWith("/receptionist")) {
            if ("RECEPTIONIST".equals(role)) {
                authorized = true;
            }
        } else if (path.startsWith("/housekeeping")) {
            if ("HOUSEKEEPING".equals(role)) {
                authorized = true;
            }
        } else {
            // General pages
            authorized = true;
        }
        
        if (authorized) {
            chain.doFilter(request, response);
        } else {
            // Unauthorized, redirect back to staff login page
            res.sendRedirect(contextPath + "/staff/login?error=unauthorized");
        }
    }

    @Override
    public void destroy() {
    }
}
