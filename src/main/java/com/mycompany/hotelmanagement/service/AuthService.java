package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.AccountRepository;
import com.mycompany.hotelmanagement.dal.PasswordResetRepository;
import com.mycompany.hotelmanagement.entity.Account;
import com.mycompany.hotelmanagement.config.EmailUtil;
import org.mindrot.jbcrypt.BCrypt;
import java.sql.Timestamp;
import java.security.SecureRandom;

/**
 *
 * @author TungNQ
 * @version 1.0.7
 * Created: 01/06/2026
 * Modified: 07/07/2026
 */
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
        String emailVal = null;
        int accountIdVal = -1;

        // 1. Authenticate using database via AccountRepository
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
                displayName = "Admin User";
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
                displayName = "Customer User";
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
        String emailBody = "<div style=\"font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, 'Roboto', 'Helvetica Neue', Arial, sans-serif; max-width: 560px; margin: 0 auto; padding: 30px; border: 1px solid #e2e8f0; border-radius: 12px; background-color: #ffffff; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);\">" +
                "    <div style=\"text-align: center; border-bottom: 2px solid #c29a30; padding-bottom: 20px; margin-bottom: 25px;\">" +
                "        <h2 style=\"color: #0b132b; margin: 0; font-size: 24px; font-weight: 700; letter-spacing: -0.5px;\">Hotel<span style=\"color: #c29a30;\">Ops</span> Pro</h2>" +
                "    </div>" +
                "    <p style=\"font-size: 16px; color: #1e293b; font-weight: 600; margin-top: 0; margin-bottom: 12px;\">Xin chào,</p>" +
                "    <p style=\"font-size: 15px; color: #334155; line-height: 1.6; margin-bottom: 24px;\">Bạn vừa yêu cầu cấp lại mật khẩu cho tài khoản trên hệ thống <strong>HotelOps Pro</strong>. Vui lòng sử dụng mã xác thực (OTP) dưới đây để tiến hành đặt lại mật khẩu của mình:</p>" +
                "    <div style=\"text-align: center; margin: 35px 0;\">" +
                "        <span style=\"font-size: 36px; font-weight: 700; letter-spacing: 6px; color: #ffffff; background-color: #0b132b; padding: 14px 35px; border-radius: 10px; display: inline-block; border: 1px solid #c29a30;\">" + otpCode + "</span>" +
                "    </div>" +
                "    <p style=\"font-size: 13px; color: #64748b; line-height: 1.6; margin-top: 25px; margin-bottom: 0; padding: 12px; background-color: #f8fafc; border-left: 3px solid #c29a30; border-radius: 4px;\">" +
                "        <strong>Lưu ý:</strong> Mã OTP này có hiệu lực trong vòng <strong>10 phút</strong> kể từ lúc yêu cầu và chỉ sử dụng được 1 lần duy nhất. Nếu bạn không yêu cầu hành động này, vui lòng bỏ qua email này." +
                "    </p>" +
                "    <div style=\"margin-top: 35px; border-top: 1px solid #e2e8f0; padding-top: 20px; text-align: center; font-size: 12px; color: #94a3b8;\">" +
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
