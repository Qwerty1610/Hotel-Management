package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;

import org.mindrot.jbcrypt.BCrypt;

import com.mycompany.hotelmanagement.config.DBContext;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "RegisterController", urlPatterns = {"/home/register"})
public class RegisterController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward to the registration page
        request.getRequestDispatcher("/WEB-INF/views/home/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (fullName != null) fullName = fullName.trim();
        if (email != null) email = email.trim();
        if (phone != null) phone = phone.trim();

        // Basic validations
        if (fullName == null || fullName.isEmpty() ||
            email == null || email.isEmpty() ||
            phone == null || phone.isEmpty() ||
            password == null || password.isEmpty() ||
            confirmPassword == null || confirmPassword.isEmpty()) {
            
            response.sendRedirect(request.getContextPath() + "/home/register?error=invalid_input");
            return;
        }

        // Email validation: regex check
        String emailRegex = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
        if (!email.matches(emailRegex)) {
            response.sendRedirect(request.getContextPath() + "/home/register?error=invalid_email"
                + "&fullName=" + java.net.URLEncoder.encode(fullName, java.nio.charset.StandardCharsets.UTF_8)
                + "&phone=" + java.net.URLEncoder.encode(phone, java.nio.charset.StandardCharsets.UTF_8));
            return;
        }

        // Phone validation: starts with 0 and contains only digits
        if (!phone.matches("^0[0-9]+$")) {
            response.sendRedirect(request.getContextPath() + "/home/register?error=invalid_phone"
                + "&fullName=" + java.net.URLEncoder.encode(fullName, java.nio.charset.StandardCharsets.UTF_8)
                + "&email=" + java.net.URLEncoder.encode(email, java.nio.charset.StandardCharsets.UTF_8));
            return;
        }

        // Password complexity validation: min length 8, contains letters, digits, and special characters
        boolean hasLetter = password.matches(".*[a-zA-Z].*");
        boolean hasDigit = password.matches(".*[0-9].*");
        boolean hasSpecial = password.matches(".*[^a-zA-Z0-9].*");
        if (password.length() < 8 || !hasLetter || !hasDigit || !hasSpecial) {
            response.sendRedirect(request.getContextPath() + "/home/register?error=invalid_password"
                + "&fullName=" + java.net.URLEncoder.encode(fullName, java.nio.charset.StandardCharsets.UTF_8)
                + "&email=" + java.net.URLEncoder.encode(email, java.nio.charset.StandardCharsets.UTF_8)
                + "&phone=" + java.net.URLEncoder.encode(phone, java.nio.charset.StandardCharsets.UTF_8));
            return;
        }

        if (!password.equals(confirmPassword)) {
            response.sendRedirect(request.getContextPath() + "/home/register?error=passwords_dont_match"
                + "&fullName=" + java.net.URLEncoder.encode(fullName, java.nio.charset.StandardCharsets.UTF_8)
                + "&email=" + java.net.URLEncoder.encode(email, java.nio.charset.StandardCharsets.UTF_8)
                + "&phone=" + java.net.URLEncoder.encode(phone, java.nio.charset.StandardCharsets.UTF_8));
            return;
        }

        Connection conn = null;
        PreparedStatement checkPs = null;
        PreparedStatement insertAccountPs = null;
        PreparedStatement insertCustomerPs = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false); // Begin Transaction

            // 1. Check if email already exists
            checkPs = conn.prepareStatement("SELECT account_id FROM Account WHERE email = ?");
            checkPs.setString(1, email);
            rs = checkPs.executeQuery();
            if (rs.next()) {
                // Email already exists
                conn.rollback();
                response.sendRedirect(request.getContextPath() + "/home/register?error=email_exists"
                    + "&fullName=" + java.net.URLEncoder.encode(fullName, java.nio.charset.StandardCharsets.UTF_8)
                    + "&email=" + java.net.URLEncoder.encode(email, java.nio.charset.StandardCharsets.UTF_8)
                    + "&phone=" + java.net.URLEncoder.encode(phone, java.nio.charset.StandardCharsets.UTF_8));
                return;
            }
            rs.close();
            checkPs.close();

            // 2. Hash the password with BCrypt
            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(12));
            // 3. Determine role_id for Customer (do not hardcode)
            int customerRoleId = 2;
            try (PreparedStatement rolePs = conn.prepareStatement("SELECT role_id FROM Role WHERE role_name = ?")) {
                rolePs.setString(1, "Customer");
                try (ResultSet roleRs = rolePs.executeQuery()) {
                    if (roleRs.next()) {
                        customerRoleId = roleRs.getInt(1);
                    }
                }
            }

            // 4. Insert into Account
            String insertAccountSql = "INSERT INTO Account (email, password, full_name, phone, role_id, is_active, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)";
            insertAccountPs = conn.prepareStatement(insertAccountSql, Statement.RETURN_GENERATED_KEYS);
            insertAccountPs.setString(1, email);
            insertAccountPs.setString(2, hashedPassword);
            insertAccountPs.setString(3, fullName);
            insertAccountPs.setString(4, phone);
            insertAccountPs.setInt(5, customerRoleId);
            insertAccountPs.setInt(6, 1); // is_active = 1
            insertAccountPs.setTimestamp(7, new Timestamp(System.currentTimeMillis()));

            int affectedRows = insertAccountPs.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating account failed, no rows affected.");
            }

            // Get generated account_id
            int accountId = -1;
            try (ResultSet generatedKeys = insertAccountPs.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    accountId = generatedKeys.getInt(1);
                } else {
                    throw new SQLException("Creating account failed, no ID obtained.");
                }
            }

            // 4. Insert into Customer
            String insertCustomerSql = "INSERT INTO Customer (account_id, loyalty_points, membership_level) VALUES (?, ?, ?)";
            insertCustomerPs = conn.prepareStatement(insertCustomerSql);
            insertCustomerPs.setInt(1, accountId);
            insertCustomerPs.setInt(2, 0); // 0 loyalty points initially
            insertCustomerPs.setString(3, "Standard"); // Standard membership initially
            insertCustomerPs.executeUpdate();

            conn.commit(); // Commit Transaction
            
            // Redirect to login page with success status
            response.sendRedirect(request.getContextPath() + "/home/login?success=registered");

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home/register?error=server_error");
        } finally {
            // Close resources
            try {
                if (rs != null) rs.close();
                if (checkPs != null) checkPs.close();
                if (insertAccountPs != null) insertAccountPs.close();
                if (insertCustomerPs != null) insertCustomerPs.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
