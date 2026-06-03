package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.config.EmailUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ForgotPasswordController", urlPatterns = {"/home/forgot-password"})
public class ForgotPasswordController extends HttpServlet {

    private static final SecureRandom random = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward to forgot password page
        request.getRequestDispatcher("/WEB-INF/views/home/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        if (email != null) {
            email = email.trim();
        }

        if (email == null || email.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home/forgot-password?error=invalid_input");
            return;
        }

        Connection conn = null;
        PreparedStatement checkPs = null;
        PreparedStatement insertPs = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();

            // 1. Check if email exists in Account database
            checkPs = conn.prepareStatement("SELECT account_id FROM Account WHERE email = ? AND is_active = 1");
            checkPs.setString(1, email);
            rs = checkPs.executeQuery();

            if (!rs.next()) {
                // Email not found in active accounts
                response.sendRedirect(request.getContextPath() + "/home/forgot-password?error=email_not_found&email=" + email);
                return;
            }
            rs.close();
            checkPs.close();

            // 2. Generate 6-digit OTP token
            int otpNum = random.nextInt(900000) + 100000; // range 100000 to 999999
            String otpCode = String.valueOf(otpNum);

            // 3. Expiration time is 10 minutes from now
            long expiryMillis = System.currentTimeMillis() + (10 * 60 * 1000); // 10 mins
            Timestamp expiryTime = new Timestamp(expiryMillis);

            // 4. Save to PasswordReset table
            String insertSql = "INSERT INTO PasswordReset (email, token, expiry_time, is_used, created_at) VALUES (?, ?, ?, 0, ?)";
            insertPs = conn.prepareStatement(insertSql);
            insertPs.setString(1, email);
            insertPs.setString(2, otpCode);
            insertPs.setTimestamp(3, expiryTime);
            insertPs.setTimestamp(4, new Timestamp(System.currentTimeMillis()));
            insertPs.executeUpdate();

            // 5. Send OTP via Email
            String subject = "Mã xác minh khôi phục mật khẩu - HotelOps Pro";
            String emailBody = "<div style=\"font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 10px; background-color: #fcfcfc;\">" +
                    "    <div style=\"text-align: center; border-bottom: 2px solid #c29a30; padding-bottom: 15px; margin-bottom: 20px;\">" +
                    "        <h2 style=\"color: #0b132b; margin: 0;\">Hotel<span style=\"color: #c29a30;\">Ops</span> Pro</h2>" +
                    "    </div>" +
                    "    <p style=\"font-size: 16px; color: #1c2541;\">Xin chào,</p>" +
                    "    <p style=\"font-size: 15px; color: #1c2541; line-height: 1.6;\">Bạn vừa yêu cầu cấp lại mật khẩu cho tài khoản trên hệ thống HotelOps Pro. Vui lòng sử dụng mã xác thực (OTP) dưới đây để tiến hành đặt lại mật khẩu của mình:</p>" +
                    "    <div style=\"text-align: center; margin: 30px 0;\">" +
                    "        <span style=\"font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #c29a30; background: #0b132b; padding: 12px 30px; border-radius: 8px; display: inline-block;\">" + otpCode + "</span>" +
                    "    </div>" +
                    "    <p style=\"font-size: 13px; color: #6c757d; line-height: 1.5;\">Lưu ý: Mã OTP này có hiệu lực trong vòng <b>10 phút</b> kể từ lúc yêu cầu và chỉ sử dụng được 1 lần duy nhất. Nếu bạn không yêu cầu hành động này, vui lòng bỏ qua email này.</p>" +
                    "    <div style=\"margin-top: 30px; border-top: 1px solid #e0e0e0; padding-top: 15px; text-align: center; font-size: 12px; color: #999;\">" +
                    "        © 2026 HotelOps Pro. Mọi quyền được bảo lưu." +
                    "    </div>" +
                    "</div>";

            EmailUtil.sendEmail(email, subject, emailBody);

            // Redirect to Reset Password input form
            response.sendRedirect(request.getContextPath() + "/home/reset-password?email=" + email + "&success=otp_sent");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home/forgot-password?error=server_error&email=" + email);
        } finally {
            try {
                if (rs != null) rs.close();
                if (checkPs != null) checkPs.close();
                if (insertPs != null) insertPs.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
