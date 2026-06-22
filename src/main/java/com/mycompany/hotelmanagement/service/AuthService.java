package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.AccountRepository;
import com.mycompany.hotelmanagement.dal.PasswordResetRepository;
import com.mycompany.hotelmanagement.entity.Account;
import com.mycompany.hotelmanagement.config.EmailUtil;
import org.mindrot.jbcrypt.BCrypt;
import java.sql.Timestamp;
import java.security.SecureRandom;

public class AuthService {
    private final AccountRepository accountRepository = new AccountRepository();
    private final PasswordResetRepository passwordResetRepository = new PasswordResetRepository();
    private static final SecureRandom random = new SecureRandom();

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

        // 1. Authenticate using database via AccountRepository
        Account account = authenticate(username, password);
        if (account != null) {
            String dbRoleName = account.getRoleName();
            String fullName = account.getFullName();

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
                displayName = "Admin User";
            } else if ("customer".equalsIgnoreCase(username) && "customer123".equals(password)) {
                role = "CUSTOMER";
                redirectUrl = "/home";
                displayName = "Customer User";
            }
        }

        if (role != null) {
            return new LoginResult(true, role, displayName, redirectUrl);
        } else {
            return new LoginResult(false, null, null, null);
        }
    }

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

        if (account != null) {
            String dbFullName = account.getFullName();
            String dbRoleName = account.getRoleName();
            userDisplayName = (dbFullName != null && !dbFullName.trim().isEmpty()) ? dbFullName : name;

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
            }
        }

        if (role != null) {
            return new LoginResult(true, role, userDisplayName, redirectUrl);
        } else {
            return new LoginResult(false, null, null, null);
        }
    }

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

        // 3. Phone validation: starts with 0 and contains only digits
        if (!phone.matches("^0[0-9]+$")) {
            return "invalid_phone";
        }

        // 4. Password complexity validation: min length 8, contains letters, digits, and special characters
        boolean hasLetter = password.matches(".*[a-zA-Z].*");
        boolean hasDigit = password.matches(".*[0-9].*");
        boolean hasSpecial = password.matches(".*[^a-zA-Z0-9].*");
        if (password.length() < 8 || !hasLetter || !hasDigit || !hasSpecial) {
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
        return success ? "success" : "server_error";
    }

    public String requestPasswordReset(String email) {
        if (email != null) {
            email = email.trim();
        }

        if (email == null || email.isEmpty()) {
            return "invalid_input";
        }

        // 1. Check if email exists in active accounts via AccountRepository
        Account account = accountRepository.getAccountByEmail(email);
        if (account == null) {
            return "email_not_found";
        }

        // 2. Generate 6-digit OTP token
        int otpNum = random.nextInt(900000) + 100000; // range 100000 to 999999
        String otpCode = String.valueOf(otpNum);

        // 3. Expiration time is 10 minutes from now
        long expiryMillis = System.currentTimeMillis() + (10 * 60 * 1000); // 10 mins
        Timestamp expiryTime = new Timestamp(expiryMillis);

        // 4. Save to PasswordReset table using PasswordResetRepository
        boolean saved = passwordResetRepository.insertResetToken(email, otpCode, expiryTime);
        if (!saved) {
            return "server_error";
        }

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
        return "success";
    }

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
}
