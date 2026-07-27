package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.AccountDAO;
import com.mycompany.hotelmanagement.dal.PasswordResetDAO;
import com.mycompany.hotelmanagement.entity.Account;
import com.mycompany.hotelmanagement.config.ConfigUtil;
import com.mycompany.hotelmanagement.config.EmailUtil;
import org.mindrot.jbcrypt.BCrypt;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.sql.Timestamp;
import java.security.SecureRandom;

/**
 *
 * @author TungNQ
 * @version 1.0.8
 * Created: 01/06/2026
 * Modified: 16/07/2026
 */
public class AuthService {
    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);
    private final AccountDAO accountRepository = new AccountDAO();
    private final PasswordResetDAO passwordResetRepository = new PasswordResetDAO();
    private static final SecureRandom random = new SecureRandom();

    /**
     * Xác thực thông tin tài khoản và mật khẩu nhập vào qua mã hóa BCrypt.
     * 
     * @param username Tên đăng nhập / Email
     * @param password Mật khẩu
     * @return Đối tượng Account nếu hợp lệ, ngược lại trả về null
     */
    public Account authenticate(String username, String password) {
        if (username == null || password == null) {
            return null;
        }
        
        Account account = accountRepository.getAccountByEmail(username.trim());
        if (account != null) {
            // Verify password using BCrypt
            if (BCrypt.checkpw(password.trim(), account.getPassword())) {
                return account;
            }
        }
        return null;
    }

    /**
     * Thực hiện logic đăng nhập hệ thống cho người dùng.
     * Kiểm tra thông tin trong CSDL, kiểm tra trạng thái kích hoạt, xác định vai trò và URL điều hướng.
     * 
     * @param username Tên đăng nhập / Email
     * @param password Mật khẩu
     * @return Đối tượng LoginResult chứa kết quả đăng nhập, vai trò và đường dẫn điều hướng
     */
    public LoginResult login(String username, String password) {
        if (username != null) {
            username = username.trim();
        }
        if (password != null) {
            password = password.trim();
        }

        String role = null;
        String redirectUrl = null;
        String displayName = null;
        String emailVal = null;
        int accountIdVal = -1;

        // 1. Authenticate using database via AccountDAO
        Account account = authenticate(username, password);
        if (account != null) {
            if (!account.isActive()) {
                return new LoginResult(false, null, null, null, null, -1, "account_locked");
            }
            String dbRoleName = account.getRoleName();
            String fullName = account.getFullName();
            emailVal = account.getEmail();
            accountIdVal = account.getAccountId();

            if ("Admin".equalsIgnoreCase(dbRoleName)) {
                role = "ADMIN";
                redirectUrl = "/admin/dashboard";
            } else if ("Customer".equalsIgnoreCase(dbRoleName)) {
                role = "CUSTOMER";
                redirectUrl = "/home";
            } else if ("Manager".equalsIgnoreCase(dbRoleName)) {
                role = "HOTEL_MANAGER";
                redirectUrl = "/manager/dashboard";
            } else if ("Receptionist".equalsIgnoreCase(dbRoleName)) {
                role = "RECEPTIONIST";
                redirectUrl = "/receptionist/dashboard";
            } else if ("Housekeeping".equalsIgnoreCase(dbRoleName) || "Housekeeper".equalsIgnoreCase(dbRoleName)) {
                role = "HOUSEKEEPING";
                redirectUrl = "/housekeeping/dashboard";
            } else if ("Staff".equalsIgnoreCase(dbRoleName)) {
                if (username != null && username.toLowerCase().contains("manager")) {
                    role = "HOTEL_MANAGER";
                    redirectUrl = "/manager/dashboard";
                } else if (username != null && username.toLowerCase().contains("housekeeping")) {
                    role = "HOUSEKEEPING";
                    redirectUrl = "/housekeeping/dashboard";
                } else {
                    role = "RECEPTIONIST";
                    redirectUrl = "/receptionist/dashboard";
                }
            }
            displayName = (fullName != null && !fullName.trim().isEmpty()) ? fullName : username;
        }

        // 2. Fallback to Mock authentication credentials check
        if (role == null) {
            if ("admin".equalsIgnoreCase(username) && "admin123".equals(password)) {
                role = "ADMIN";
                redirectUrl = "/admin/dashboard";
                displayName = "Quản trị viên";
                Account mockAcc = accountRepository.getAccountByEmail("admin@hotel.com");
                if (mockAcc != null) {
                    emailVal = mockAcc.getEmail();
                    accountIdVal = mockAcc.getAccountId();
                } else {
                    emailVal = "admin@hotel.com";
                    accountIdVal = 1;
                }
            } else if ("customer".equalsIgnoreCase(username) && "customer123".equals(password)) {
                role = "CUSTOMER";
                redirectUrl = "/home";
                displayName = "Khách hàng";
                Account mockAcc = accountRepository.getAccountByEmail("customer@hotel.com");
                if (mockAcc != null) {
                    emailVal = mockAcc.getEmail();
                    accountIdVal = mockAcc.getAccountId();
                } else {
                    emailVal = "customer@hotel.com";
                    accountIdVal = 5;
                }
            }
        }

        if (role != null) {
            return new LoginResult(true, role, displayName, redirectUrl, emailVal, accountIdVal);
        } else {
            return new LoginResult(false, null, null, null);
        }
    }

    /**
     * Xử lý đăng nhập hoặc đăng ký tự động cho tài khoản xác thực qua Google OAuth2.
     * 
     * @param email Email nhận từ Google API
     * @param name Họ tên nhận từ Google API
     * @return Đối tượng LoginResult chứa thông tin phiên đăng nhập
     */
    public LoginResult loginOrRegisterGoogle(String email, String name) {
        if (email != null) email = email.trim();
        if (name != null) name = name.trim();

        if (email == null || email.isEmpty()) {
            return new LoginResult(false, null, null, null);
        }

        Account account = accountRepository.getAccountByEmail(email);
        String role = null;
        String redirectUrl = null;
        String userDisplayName = name;
        String emailVal = null;
        int accountIdVal = -1;

        if (account != null) {
            if (!account.isActive()) {
                return new LoginResult(false, null, null, null, null, -1, "account_locked");
            }
            String dbFullName = account.getFullName();
            String dbRoleName = account.getRoleName();
            userDisplayName = (dbFullName != null && !dbFullName.trim().isEmpty()) ? dbFullName : name;
            emailVal = account.getEmail();
            accountIdVal = account.getAccountId();

            if ("Admin".equalsIgnoreCase(dbRoleName)) {
                role = "ADMIN";
                redirectUrl = "/admin/dashboard";
            } else if ("Customer".equalsIgnoreCase(dbRoleName)) {
                role = "CUSTOMER";
                redirectUrl = "/home";
            } else if ("Manager".equalsIgnoreCase(dbRoleName)) {
                role = "HOTEL_MANAGER";
                redirectUrl = "/manager/dashboard";
            } else if ("Receptionist".equalsIgnoreCase(dbRoleName)) {
                role = "RECEPTIONIST";
                redirectUrl = "/receptionist/dashboard";
            } else if ("Housekeeping".equalsIgnoreCase(dbRoleName) || "Housekeeper".equalsIgnoreCase(dbRoleName)) {
                role = "HOUSEKEEPING";
                redirectUrl = "/housekeeping/dashboard";
            } else if ("Staff".equalsIgnoreCase(dbRoleName)) {
                role = "RECEPTIONIST";
                redirectUrl = "/receptionist/dashboard";
            }
        } else {
            // Register Google user
            String randomPassword = java.util.UUID.randomUUID().toString();
            String hashedPassword = BCrypt.hashpw(randomPassword, BCrypt.gensalt(12));

            int customerRoleId = accountRepository.getRoleIdByName("Customer");
            if (customerRoleId == -1) {
                customerRoleId = 2; // default fallback
            }

            boolean registered = accountRepository.registerCustomer(email, hashedPassword, name, "", customerRoleId);
            if (registered) {
                role = "CUSTOMER";
                redirectUrl = "/home";
                Account newAcc = accountRepository.getAccountByEmail(email);
                if (newAcc != null) {
                    emailVal = newAcc.getEmail();
                    accountIdVal = newAcc.getAccountId();
                } else {
                    emailVal = email;
                }
            }
        }

        if (role != null) {
            return new LoginResult(true, role, userDisplayName, redirectUrl, emailVal, accountIdVal);
        } else {
            return new LoginResult(false, null, null, null);
        }
    }

    /**
     * Xử lý đăng ký tài khoản khách hàng mới.
     * Validate định dạng email, sĐT, độ phức tạp mật khẩu, kiểm tra trùng lặp và lưu vào CSDL.
     * 
     * @param fullName Họ tên
     * @param email Email
     * @param phone Số điện thoại
     * @param password Mật khẩu
     * @param confirmPassword Mật khẩu nhập lại
     * @return Chuỗi mã kết quả ("success", "invalid_email", "invalid_phone", "password_too_short",...)
     */
    public String register(String fullName, String email, String phone, String password, String confirmPassword) {
        if (fullName != null) fullName = fullName.trim();
        if (email != null) email = email.trim();
        if (phone != null) phone = phone.trim();

        // 1. Basic validations
        if (fullName == null || fullName.isEmpty() ||
            email == null || email.isEmpty() ||
            phone == null || phone.isEmpty() ||
            password == null || password.isEmpty() ||
            confirmPassword == null || confirmPassword.isEmpty()) {
            return "invalid_input";
        }

        // 2. Email validation: regex check
        String emailRegex = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
        if (!email.matches(emailRegex)) {
            return "invalid_email";
        }

        // 3. Phone validation: starts with 0, followed by (3, 5, 7, 8, 9) and ends with exactly 8 digits
        if (!phone.matches("^0[35789]\\d{8}$")) {
            return "invalid_phone";
        }

        // 4. Password complexity validation: min length 8, contains letters, digits, and special characters
        if (password.length() < 8) {
            return "password_too_short";
        }
        boolean hasLetter = password.matches(".*[a-zA-Z].*");
        boolean hasDigit = password.matches(".*[0-9].*");
        boolean hasSpecial = password.matches(".*[^a-zA-Z0-9].*");
        if (!hasLetter || !hasDigit || !hasSpecial) {
            return "invalid_password";
        }

        if (!password.equals(confirmPassword)) {
            return "passwords_dont_match";
        }

        // 5. Check duplicate email and phone using repository
        if (accountRepository.existsByEmail(email)) {
            return "email_exists";
        }
        if (accountRepository.existsByPhone(phone)) {
            return "phone_exists";
        }

        // 6. Hash password and save via repository transaction
        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(12));
        int customerRoleId = accountRepository.getRoleIdByName("Customer");
        if (customerRoleId == -1) {
            customerRoleId = 2; // fallback defaults
        }

        boolean success = accountRepository.registerCustomer(email, hashedPassword, fullName, phone, customerRoleId);
        if (success) {
            sendCustomerWelcomeEmail(email, fullName);
            return "success";
        }
        return "server_error";
    }

    /**
     * Gửi email tự động chào mừng khách hàng mới đăng ký tài khoản.
     */
    private void sendCustomerWelcomeEmail(String email, String fullName) {
        final String emailToUse = (email != null) ? email.trim() : "";
        String hotelName = ConfigUtil.get("hotel.name", "HotelOps Pro");
        String subject = "[" + hotelName + "] Chào mừng bạn đến với " + hotelName + "!";
        String emailBody = EmailUtil.buildCustomerWelcomeEmail(fullName, emailToUse);
        new Thread(() -> {
            try {
                boolean sent = EmailUtil.sendEmail(emailToUse, subject, emailBody);
                if (sent) {
                    logger.info("Đã gửi email chào mừng đăng ký tài khoản cho khách hàng: {}", emailToUse);
                } else {
                    logger.warn("Không thể gửi email chào mừng cho khách hàng: {}", emailToUse);
                }
            } catch (Exception e) {
                logger.error("Lỗi khi gửi email chào mừng cho khách hàng: " + emailToUse, e);
            }
        }).start();
    }

    /**
     * Yêu cầu khôi phục mật khẩu qua Email.
     * Sinh mã OTP 6 chữ số ngẫu nhiên, lưu thời gian hết hạn (10 phút) vào CSDL và gửi email cho người dùng.
     * 
     * @param email Email yêu cầu khôi phục mật khẩu
     * @return Chuỗi mã kết quả ("success", "invalid_input", "email_not_found",...)
     */
    public String requestPasswordReset(String email) {
        if (email == null || email.trim().isEmpty()) {
            return "invalid_input";
        }
        final String emailToUse = email.trim();

        // 1. Check if email exists in active accounts via AccountDAO
        Account account = accountRepository.getAccountByEmail(emailToUse);
        if (account == null) {
            return "email_not_found";
        }

        // 2. Generate 6-digit OTP token
        int otpNum = random.nextInt(900000) + 100000; // range 100000 to 999999
        String otpCode = String.valueOf(otpNum);

        // 3. Expiration time is 10 minutes from now
        long expiryMillis = System.currentTimeMillis() + (10 * 60 * 1000); // 10 mins
        Timestamp expiryTime = new Timestamp(expiryMillis);

        // 4. Save to PasswordReset table using PasswordResetDAO
        boolean saved = passwordResetRepository.insertResetToken(emailToUse, otpCode, expiryTime);
        if (!saved) {
            return "server_error";
        }

        // 5. Send OTP via Email using standardized template
        String hotelName = ConfigUtil.get("hotel.name", "HotelOps Pro");
        String subject = "[" + hotelName + "] Mã xác minh khôi phục mật khẩu";
        String emailBody = EmailUtil.buildOtpEmail(otpCode);

        new Thread(() -> {
            try {
                EmailUtil.sendEmail(emailToUse, subject, emailBody);
            } catch (Exception e) {
                logger.error("Lỗi khi gửi email OTP cho: " + emailToUse, e);
            }
        }).start();

        return "success";
    }

    /**
     * Xác thực mã OTP và tiến hành đặt lại mật khẩu mới cho người dùng.
     * 
     * @param email Email tài khoản
     * @param otp Mã OTP nhập từ giao diện
     * @param newPassword Mật khẩu mới
     * @param confirmPassword Mật khẩu mới nhập lại
     * @return Chuỗi mã kết quả ("success", "invalid_otp", "invalid_password",...)
     */
    public String resetPassword(String email, String otp, String newPassword, String confirmPassword) {
        if (email != null) email = email.trim();
        if (otp != null) otp = otp.trim();

        if (email == null || email.isEmpty() ||
            otp == null || otp.isEmpty() ||
            newPassword == null || newPassword.isEmpty() ||
            confirmPassword == null || confirmPassword.isEmpty()) {
            return "invalid_input";
        }

        // Password complexity validation: min length 8, contains letters, digits, and special characters
        boolean hasLetter = newPassword.matches(".*[a-zA-Z].*");
        boolean hasDigit = newPassword.matches(".*[0-9].*");
        boolean hasSpecial = newPassword.matches(".*[^a-zA-Z0-9].*");
        if (newPassword.length() < 8 || !hasLetter || !hasDigit || !hasSpecial) {
            return "invalid_password";
        }

        if (!newPassword.equals(confirmPassword)) {
            return "passwords_dont_match";
        }

        // 1. Verify OTP token in database
        int resetId = passwordResetRepository.getValidResetId(email, otp);
        if (resetId == -1) {
            return "invalid_otp";
        }

        // 2. Hash the new password with BCrypt
        String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt(12));

        // 3. Update password and mark OTP as used atomically via repository
        boolean resetSuccess = passwordResetRepository.performPasswordReset(email, hashedPassword, resetId);
        return resetSuccess ? "success" : "server_error";
    }

    /**
     * Kiểm tra tính hợp lệ của mã OTP mà không thực hiện đổi mật khẩu.
     * 
     * @param email Email tài khoản
     * @param otp Mã OTP nhập từ giao diện
     * @return true nếu mã OTP hợp lệ và chưa hết hạn
     */
    public boolean verifyOtp(String email, String otp) {
        if (email != null) email = email.trim();
        if (otp != null) otp = otp.trim();
        if (email == null || email.isEmpty() || otp == null || otp.isEmpty()) {
            return false;
        }
        int resetId = passwordResetRepository.getValidResetId(email, otp);
        return resetId != -1;
    }
}
