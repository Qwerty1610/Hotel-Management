package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Controller to handle both 403 Forbidden and 404 Not Found error routing.
 * 
 * @author Antigravity
 */
@WebServlet(name = "ErrorController", urlPatterns = {"/error-404", "/error-403"})
public class ErrorController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Retrieve error status code from request attributes
        Integer statusCode = (Integer) request.getAttribute("jakarta.servlet.error.status_code");
        if (statusCode == null) {
            // Fallback checking based on request path
            String uri = request.getRequestURI();
            if (uri != null && uri.contains("error-403")) {
                statusCode = 403;
            } else {
                statusCode = 404;
            }
        }
        
        // Pass status code to JSP to render appropriate title and message
        request.setAttribute("errorCode", statusCode);
        
        // Forward request and response to custom error JSP page
        request.getRequestDispatcher("/WEB-INF/views/error/error.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
