package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import com.mycompany.hotelmanagement.config.DBContext;
import org.mindrot.jbcrypt.BCrypt;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ResetPasswordController", urlPatterns = {"/home/reset-password"})
public class ResetPasswordController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward to the reset password page
        request.getRequestDispatcher("/WEB-INF/views/home/reset-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String otp = request.getParameter("otp");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (email != null) email = email.trim();
        if (otp != null) otp = otp.trim();

        if (email == null || email.isEmpty() ||
            otp == null || otp.isEmpty() ||
            newPassword == null || newPassword.isEmpty() ||
            confirmPassword == null || confirmPassword.isEmpty()) {
            
            response.sendRedirect(request.getContextPath() + "/home/reset-password?error=invalid_input&email=" + email);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            response.sendRedirect(request.getContextPath() + "/home/reset-password?error=passwords_dont_match&email=" + email);
            return;
        }

        Connection conn = null;
        PreparedStatement checkOtpPs = null;
        PreparedStatement updatePassPs = null;
        PreparedStatement updateOtpPs = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false); // Begin Transaction

            // 1. Verify OTP token in database
            // Top 1 ordered by created_at desc to get the latest otp
            String checkOtpSql = "SELECT TOP 1 id FROM PasswordReset " +
                                 "WHERE email = ? AND token = ? AND is_used = 0 AND expiry_time > GETDATE() " +
                                 "ORDER BY created_at DESC";
            
            checkOtpPs = conn.prepareStatement(checkOtpSql);
            checkOtpPs.setString(1, email);
            checkOtpPs.setString(2, otp);
            rs = checkOtpPs.executeQuery();

            if (!rs.next()) {
                // Invalid or expired OTP code
                conn.rollback();
                response.sendRedirect(request.getContextPath() + "/home/reset-password?error=invalid_otp&email=" + email);
                return;
            }

            int resetId = rs.getInt("id");
            rs.close();
            checkOtpPs.close();

            // 2. Hash the new password with BCrypt
            String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt(12));

            // 3. Update the password in Account table (if exists)
            String updatePassSql = "UPDATE Account SET password = ? WHERE email = ? AND is_active = 1";
            updatePassPs = conn.prepareStatement(updatePassSql);
            updatePassPs.setString(1, hashedPassword);
            updatePassPs.setString(2, email);
            updatePassPs.executeUpdate(); // Proceed even if account doesn't exist

            // 4. Mark OTP as used
            String updateOtpSql = "UPDATE PasswordReset SET is_used = 1 WHERE id = ?";
            updateOtpPs = conn.prepareStatement(updateOtpSql);
            updateOtpPs.setInt(1, resetId);
            updateOtpPs.executeUpdate();

            conn.commit(); // Commit Transaction

            // Success, redirect to login page
            response.sendRedirect(request.getContextPath() + "/home/login?success=password_reset");

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home/reset-password?error=server_error&email=" + email);
        } finally {
            try {
                if (rs != null) rs.close();
                if (checkOtpPs != null) checkOtpPs.close();
                if (updatePassPs != null) updatePassPs.close();
                if (updateOtpPs != null) updateOtpPs.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
