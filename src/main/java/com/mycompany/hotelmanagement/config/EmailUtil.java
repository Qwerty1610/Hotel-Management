package com.mycompany.hotelmanagement.config;

import java.util.Properties;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Lớp tiện ích gửi email bằng giao thức SMTP.
 * Hỗ trợ gửi mã OTP khôi phục mật khẩu. Tự động ghi log ra console nếu chưa cấu hình SMTP (cho local development).
 * 
 * @author TùngNQ
 * @version 1.0.1
 * Created: 24/06/2026
 * Modified: 16/07/2026
 */
public class EmailUtil {
    private static final Logger logger = LoggerFactory.getLogger(EmailUtil.class);

    // Helper methods to retrieve configurations dynamically on each request
    private static String getSmtpHost() {
        return ConfigUtil.get("smtp.host", System.getProperty("smtp.host", "smtp.gmail.com"));
    }

    private static String getSmtpPort() {
        return ConfigUtil.get("smtp.port", System.getProperty("smtp.port", "587"));
    }

    private static String getSmtpUser() {
        return ConfigUtil.get("smtp.user", System.getProperty("smtp.user", "your-email@gmail.com"));
    }

    private static String getSmtpPassword() {
        return ConfigUtil.get("smtp.password", System.getProperty("smtp.password", "your-app-password"));
    }

    /**
     * Thực hiện gửi thư điện tử.
     * Nếu thông tin tài khoản SMTP chưa được thiết lập, nội dung email sẽ được ghi lại trong Console để hỗ trợ phát triển cục bộ.
     * 
     * @param toEmail Địa chỉ email người nhận
     * @param subject Tiêu đề thư
     * @param body    Nội dung thư (hỗ trợ định dạng HTML)
     * @return true nếu gửi hoặc ghi nhận thành công, false nếu phát sinh lỗi
     */
    public static boolean sendEmail(String toEmail, String subject, String body) {
        String host = getSmtpHost();
        String port = getSmtpPort();
        String user = getSmtpUser();
        String password = getSmtpPassword();

        // Log the email action and content first for debugging purposes
        logger.info("Attempting to send email to: {}", toEmail);
        logger.info("Subject: {}", subject);
        logger.info("Body (OTP): \n====================\n{}\n====================", body);

        System.out.println("==================================================");
        System.out.println("[EMAIL LOG] Gửi tới: " + toEmail);
        System.out.println("[EMAIL LOG] Tiêu đề: " + subject);
        System.out.println("[EMAIL LOG] Nội dung:\n" + body);
        System.out.println("==================================================");

        // Check if configuration is default/mock
        if (ConfigUtil.isPlaceholder(user) || ConfigUtil.isPlaceholder(password)) {
            logger.warn(
                    "SMTP credentials are not configured. The email was logged to the console but not sent via SMTP.");
            return true; // Return true because it was successfully logged and handled for local dev
        }

        Properties properties = new Properties();
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.starttls.required", "true");
        properties.put("mail.smtp.host", host);
        properties.put("mail.smtp.port", port);
        properties.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
        properties.put("mail.smtp.ssl.trust", host);
        properties.put("mail.smtp.connectiontimeout", "10000");
        properties.put("mail.smtp.timeout", "10000");
        properties.put("mail.smtp.writetimeout", "10000");

        Session session = Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(user, password);
            }
        });

        try {
            MimeMessage message = new MimeMessage(session);
            String hotelName = ConfigUtil.get("hotel.name", "HotelOps Pro");
            try {
                message.setFrom(new InternetAddress(user, hotelName, "UTF-8"));
            } catch (Exception e) {
                message.setFrom(new InternetAddress(user));
            }
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject, "UTF-8");
            message.setContent(body, "text/html; charset=UTF-8");
            message.setSentDate(new java.util.Date());

            Transport.send(message);
            logger.info("Email sent successfully to {}", toEmail);
            System.out.println("[EMAIL SUCCESS] Đã gửi email thành công tới: " + toEmail);
            return true;
        } catch (Exception e) {
            logger.error("Failed to send email to {}", toEmail, e);
            System.err.println("[EMAIL ERROR] Lỗi gửi email tới " + toEmail + ": " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Khung giao diện HTML chuẩn đồng bộ cho tất cả các email của hệ thống.
     */
    public static String buildEmailWrapper(String titleHtml, String bodyContent) {
        String hotelName = ConfigUtil.get("hotel.name", "HotelOps Pro");
        return "<div style=\"background-color: #f4f6f9; padding: 30px 10px; font-family: 'Segoe UI', Arial, sans-serif;\">"
             + "  <div style=\"max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; overflow: hidden; border: 1px solid #e2e8f0; box-shadow: 0 4px 12px rgba(0,0,0,0.05);\">"
             + "    <div style=\"background-color: #0b132b; padding: 24px 30px; text-align: center; border-bottom: 3px solid #c29a30;\">"
             + "      <h2 style=\"margin: 0; color: #ffffff; font-size: 24px; font-weight: 700; letter-spacing: 0.5px;\">"
             + "        Hotel<span style=\"color: #c29a30;\">Ops</span> Pro"
             + "      </h2>"
             + "      <p style=\"margin: 4px 0 0 0; color: #94a3b8; font-size: 13px;\">Hệ thống Quản lý Khách sạn Cao cấp</p>"
             + "    </div>"
             + "    <div style=\"padding: 30px; color: #334155; line-height: 1.6;\">"
             +        bodyContent
             + "    </div>"
             + "    <div style=\"background-color: #f8fafc; padding: 18px 30px; text-align: center; border-top: 1px solid #e2e8f0; font-size: 12px; color: #94a3b8;\">"
             + "      <p style=\"margin: 0;\">&copy; 2026 " + hotelName + ". Tất cả các quyền được bảo lưu.</p>"
             + "      <p style=\"margin: 4px 0 0 0;\">Thư này được gửi tự động từ hệ thống, vui lòng không phản hồi trực tiếp email này.</p>"
             + "    </div>"
             + "  </div>"
             + "</div>";
    }

    /**
     * Mẫu Email gửi mã OTP xác nhận khôi phục mật khẩu.
     */
    public static String buildOtpEmail(String otpCode) {
        String body = "<h3 style=\"margin-top: 0; color: #0b132b; font-size: 18px;\">Xác thực khôi phục mật khẩu</h3>"
             + "<p style=\"font-size: 15px; color: #334155;\">Xin chào,</p>"
             + "<p style=\"font-size: 15px; color: #334155;\">Bạn vừa yêu cầu cấp lại mật khẩu cho tài khoản trên hệ thống. Vui lòng sử dụng mã xác thực (OTP) dưới đây để hoàn tất quá trình đặt lại mật khẩu:</p>"
             + "<div style=\"text-align: center; margin: 30px 0;\">"
             + "  <span style=\"font-size: 32px; font-weight: 700; letter-spacing: 6px; color: #ffffff; background-color: #0b132b; padding: 12px 30px; border-radius: 8px; display: inline-block; border: 2px solid #c29a30;\">" + otpCode + "</span>"
             + "</div>"
             + "<p style=\"font-size: 13px; color: #64748b; background-color: #f8fafc; padding: 12px 16px; border-left: 4px solid #c29a30; border-radius: 4px; margin-bottom: 0;\">"
             + "  <strong>Lưu ý:</strong> Mã OTP có hiệu lực trong <strong>10 phút</strong>. Nếu bạn không yêu cầu hành động này, vui lòng bỏ qua email để bảo mật tài khoản."
             + "</p>";
        return buildEmailWrapper("Xác thực khôi phục mật khẩu", body);
    }

    /**
     * Mẫu Email chào mừng khách hàng đăng ký tài khoản mới thành công.
     */
    public static String buildCustomerWelcomeEmail(String fullName, String email) {
        String nameStr = (fullName != null && !fullName.trim().isEmpty()) ? fullName.trim() : "Khách hàng";
        String body = "<h3 style=\"margin-top: 0; color: #0b132b; font-size: 18px;\">Chào mừng bạn đến với HotelOps Pro!</h3>"
             + "<p style=\"font-size: 15px; color: #334155;\">Xin chào <strong>" + nameStr + "</strong>,</p>"
             + "<p style=\"font-size: 15px; color: #334155;\">Chúc mừng bạn đã đăng ký thành công tài khoản khách hàng tại <strong>HotelOps Pro</strong>. Giờ đây bạn có thể dễ dàng tìm kiếm phòng, đặt dịch vụ và trải nghiệm dịch vụ nghỉ dưỡng cao cấp của chúng tôi.</p>"
             + "<div style=\"background-color: #f8fafc; border: 1px solid #cbd5e1; border-left: 4px solid #c29a30; border-radius: 6px; padding: 18px; margin: 24px 0;\">"
             + "  <p style=\"margin: 4px 0; font-size: 14px;\"><strong>Họ và tên:</strong> " + nameStr + "</p>"
             + "  <p style=\"margin: 4px 0; font-size: 14px;\"><strong>Email đăng ký:</strong> " + email + "</p>"
             + "</div>"
             + "<p style=\"font-size: 14px; color: #64748b; margin-bottom: 0;\">Cảm ơn bạn đã tin tưởng và lựa chọn dịch vụ của chúng tôi!</p>";
        return buildEmailWrapper("Chào mừng đăng ký tài khoản thành công", body);
    }

    /**
     * Mẫu Email cung cấp thông tin tài khoản và mật khẩu cho Nhân viên mới.
     */
    public static String buildStaffAccountEmail(String fullName, String email, String rawPassword, String roleName) {
        String nameStr = (fullName != null && !fullName.trim().isEmpty()) ? fullName.trim() : "Nhân viên";
        String roleStr = (roleName != null && !roleName.trim().isEmpty()) ? roleName.trim() : "Nhân viên";
        String body = "<h3 style=\"margin-top: 0; color: #0b132b; font-size: 18px;\">Thông tin tài khoản nhân viên mới</h3>"
             + "<p style=\"font-size: 15px; color: #334155;\">Xin chào <strong>" + nameStr + "</strong>,</p>"
             + "<p style=\"font-size: 15px; color: #334155;\">Tài khoản nhân viên của bạn đã được quản trị viên khởi tạo thành công với vai trò <strong>" + roleStr + "</strong>.</p>"
             + "<p style=\"font-size: 15px; color: #334155;\">Dưới đây là thông tin đăng nhập cá nhân của bạn:</p>"
             + "<div style=\"background-color: #f8fafc; border: 1px solid #cbd5e1; border-left: 4px solid #c29a30; border-radius: 6px; padding: 18px; margin: 24px 0;\">"
             + "  <p style=\"margin: 4px 0; font-size: 14px;\"><strong>Email đăng nhập:</strong> " + email + "</p>"
             + "  <p style=\"margin: 4px 0; font-size: 14px;\"><strong>Mật khẩu ban đầu:</strong> <span style=\"font-family: monospace; font-size: 16px; font-weight: 700; color: #0f172a; background: #e2e8f0; padding: 3px 8px; border-radius: 4px;\">" + rawPassword + "</span></p>"
             + "</div>"
             + "<p style=\"font-size: 13px; color: #64748b; background-color: #f8fafc; padding: 12px 16px; border-left: 4px solid #0b132b; border-radius: 4px; margin-bottom: 0;\">"
             + "  <strong>Lưu ý bảo mật:</strong> Vui lòng đăng nhập và tiến hành đổi mật khẩu ngay trong lần sử dụng đầu tiên để bảo vệ tài khoản cá nhân."
             + "</p>";
        return buildEmailWrapper("Thông tin tài khoản nhân viên mới", body);
    }

    /**
     * Mẫu Email thông báo cập nhật thông tin/mật khẩu tài khoản nhân viên do Admin thực hiện.
     */
    public static String buildStaffUpdateEmail(String fullName, String email, String newRawPassword, String roleName) {
        String nameStr = (fullName != null && !fullName.trim().isEmpty()) ? fullName.trim() : "Nhân viên";
        String roleStr = (roleName != null && !roleName.trim().isEmpty()) ? roleName.trim() : "Nhân viên";

        StringBuilder content = new StringBuilder();
        content.append("<h3 style=\"margin-top: 0; color: #0b132b; font-size: 18px;\">Cập nhật thông tin tài khoản nhân viên</h3>");
        content.append("<p style=\"font-size: 15px; color: #334155;\">Xin chào <strong>").append(nameStr).append("</strong>,</p>");
        content.append("<p style=\"font-size: 15px; color: #334155;\">Thông tin tài khoản của bạn trên hệ thống vừa được Quản trị viên cập nhật thành công.</p>");
        content.append("<div style=\"background-color: #f8fafc; border: 1px solid #cbd5e1; border-left: 4px solid #c29a30; border-radius: 6px; padding: 18px; margin: 24px 0;\">");
        content.append("  <p style=\"margin: 4px 0; font-size: 14px;\"><strong>Họ và tên:</strong> ").append(nameStr).append("</p>");
        content.append("  <p style=\"margin: 4px 0; font-size: 14px;\"><strong>Email đăng nhập:</strong> ").append(email).append("</p>");
        content.append("  <p style=\"margin: 4px 0; font-size: 14px;\"><strong>Vai trò công việc:</strong> ").append(roleStr).append("</p>");

        if (newRawPassword != null && !newRawPassword.trim().isEmpty()) {
            content.append("  <p style=\"margin: 8px 0 4px 0; font-size: 14px;\"><strong>Mật khẩu mới:</strong> <span style=\"font-family: monospace; font-size: 16px; font-weight: 700; color: #0f172a; background: #e2e8f0; padding: 3px 8px; border-radius: 4px;\">").append(newRawPassword.trim()).append("</span></p>");
        }
        content.append("</div>");

        if (newRawPassword != null && !newRawPassword.trim().isEmpty()) {
            content.append("<p style=\"font-size: 13px; color: #64748b; background-color: #f8fafc; padding: 12px 16px; border-left: 4px solid #0b132b; border-radius: 4px; margin-bottom: 0;\">");
            content.append("  <strong>Lưu ý bảo mật:</strong> Vui lòng sử dụng mật khẩu mới này để đăng nhập vào hệ thống.");
            content.append("</p>");
        } else {
            content.append("<p style=\"font-size: 13px; color: #64748b; background-color: #f8fafc; padding: 12px 16px; border-left: 4px solid #0b132b; border-radius: 4px; margin-bottom: 0;\">");
            content.append("  Mật khẩu đăng nhập của bạn giữ nguyên không thay đổi.");
            content.append("</p>");
        }

        return buildEmailWrapper("Cập nhật thông tin tài khoản nhân viên", content.toString());
    }

    /**
     * Tương thích với lời gọi cũ.
     */
    public static String buildStaffPasswordUpdateEmail(String fullName, String email, String newRawPassword, String roleName) {
        return buildStaffUpdateEmail(fullName, email, newRawPassword, roleName);
    }

    /**
     * Mẫu Email thông báo thông tin tài khoản khách hàng được cập nhật.
     */
    public static String buildCustomerUpdateEmail(String fullName, String email, String phone) {
        String nameStr = (fullName != null && !fullName.trim().isEmpty()) ? fullName.trim() : "Khách hàng";

        StringBuilder content = new StringBuilder();
        content.append("<h3 style=\"margin-top: 0; color: #0b132b; font-size: 18px;\">Cập nhật thông tin tài khoản khách hàng</h3>");
        content.append("<p style=\"font-size: 15px; color: #334155;\">Xin chào <strong>").append(nameStr).append("</strong>,</p>");
        content.append("<p style=\"font-size: 15px; color: #334155;\">Thông tin tài khoản khách hàng của bạn trên hệ thống <strong>HotelOps Pro</strong> vừa được cập nhật thành công với các thông số sau:</p>");

        content.append("<div style=\"background-color: #f8fafc; border: 1px solid #cbd5e1; border-left: 4px solid #c29a30; border-radius: 6px; padding: 18px; margin: 24px 0;\">");
        content.append("  <p style=\"margin: 4px 0; font-size: 14px;\"><strong>Họ và tên:</strong> ").append(nameStr).append("</p>");
        content.append("  <p style=\"margin: 4px 0; font-size: 14px;\"><strong>Email tài khoản:</strong> ").append(email).append("</p>");

        if (phone != null && !phone.trim().isEmpty()) {
            content.append("  <p style=\"margin: 4px 0; font-size: 14px;\"><strong>Số điện thoại:</strong> ").append(phone.trim()).append("</p>");
        }

        content.append("</div>");
        content.append("<p style=\"font-size: 14px; color: #64748b; margin-bottom: 0;\">Cảm ơn bạn đã luôn sử dụng dịch vụ của <strong>HotelOps Pro</strong>. Nếu bạn có bất kỳ thắc mắc nào, vui lòng liên hệ bộ phận Chăm sóc khách hàng.</p>");

        return buildEmailWrapper("Cập nhật thông tin tài khoản khách hàng", content.toString());
    }
}
