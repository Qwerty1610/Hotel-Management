package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.AccountDAO;
import com.mycompany.hotelmanagement.entity.Account;
import com.mycompany.hotelmanagement.entity.CustomerInfo;
import com.mycompany.hotelmanagement.entity.Role;
import org.mindrot.jbcrypt.BCrypt;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

/**
 * Service xử lý các nghiệp vụ quản trị hệ thống của Admin.
 * 
 * @author TungNQ
 * @version 1.0.5
 * Created: 24/06/2026
 * Modified: 16/07/2026
 */
public class AdminService {
    private static final Logger logger = LoggerFactory.getLogger(AdminService.class);
    private final AccountDAO accountRepository = new AccountDAO();

    public List<Account> getStaffAccounts() {
        return accountRepository.getAllStaffAccounts();
    }

    public List<CustomerInfo> getCustomerAccounts() {
        return accountRepository.getAllCustomerAccounts();
    }

    public List<Role> getStaffRoles() {
        return accountRepository.getStaffRoles();
    }

    private boolean isInvalidEmail(String email) {
        String emailRegex = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
        return email == null || !email.trim().matches(emailRegex);
    }

    public String sanitizePhone(String phone) {
        if (phone == null) {
            return null;
        }
        String trimmed = phone.trim();
        if (trimmed.isEmpty() || trimmed.equalsIgnoreCase("null") || trimmed.equalsIgnoreCase("undefined") || trimmed.equals("-") || trimmed.equals("—")) {
            return null;
        }
        String cleaned = trimmed.replaceAll("[\\s\\-\\.\\(\\)]", "");
        if (cleaned.startsWith("+84")) {
            cleaned = "0" + cleaned.substring(3);
        }
        return cleaned.isEmpty() ? null : cleaned;
    }

    private boolean isInvalidPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return false; // phone is optional
        }
        return !phone.trim().matches("^0[35789]\\d{8}$");
    }

    private boolean isWeakPassword(String password) {
        if (password == null || password.isEmpty()) {
            return true;
        }
        boolean hasLetter = password.matches(".*[a-zA-Z].*");
        boolean hasDigit = password.matches(".*[0-9].*");
        boolean hasSpecial = password.matches(".*[^a-zA-Z0-9].*");
        return password.length() < 8 || !hasLetter || !hasDigit || !hasSpecial;
    }

    public String createStaffAccount(String email, String fullName, String phone, String password, int roleId) {
        if (email == null || email.trim().isEmpty() || fullName == null || fullName.trim().isEmpty() || password == null || password.isEmpty()) {
            return "invalid_input";
        }
        phone = sanitizePhone(phone);
        if (isInvalidEmail(email)) {
            return "invalid_email";
        }
        if (isInvalidPhone(phone)) {
            return "invalid_phone";
        }
        if (isWeakPassword(password)) {
            return "weak_password";
        }
        if (accountRepository.existsByEmail(email.trim())) {
            return "email_exists";
        }
        if (phone != null && accountRepository.existsByPhone(phone)) {
            return "phone_exists";
        }
        String passwordHash = BCrypt.hashpw(password.trim(), BCrypt.gensalt(12));
        boolean success = accountRepository.insertStaffAccount(email.trim(), passwordHash, fullName.trim(), phone, roleId);
        if (success) {
            logger.info("Admin created new staff account: {} with role ID: {}", email, roleId);
            return "success";
        }
        return "create_failed";
    }

    public String updateStaffAccount(int accountId, String email, String fullName, String phone, String password, int roleId) {
        if (email == null || email.trim().isEmpty() || fullName == null || fullName.trim().isEmpty()) {
            return "invalid_input";
        }
        
        // BR-65 validation: Cannot change role of the Admin account to non-Admin
        Account existingAccount = accountRepository.getAccountById(accountId);
        if (existingAccount != null && "Admin".equals(existingAccount.getRoleName())) {
            String targetRoleName = accountRepository.getRoleNameById(roleId);
            if (!"Admin".equals(targetRoleName)) {
                return "cannot_demote_admin";
            }
        }

        phone = sanitizePhone(phone);
        if (isInvalidEmail(email)) {
            return "invalid_email";
        }
        if (isInvalidPhone(phone)) {
            return "invalid_phone";
        }
        if (accountRepository.existsByEmailExcept(email.trim(), accountId)) {
            return "email_exists";
        }
        if (phone != null && accountRepository.existsByPhoneExcept(phone, accountId)) {
            return "phone_exists";
        }
        
        String passwordHash = null;
        if (password != null && !password.trim().isEmpty()) {
            if (isWeakPassword(password)) {
                return "weak_password";
            }
            passwordHash = BCrypt.hashpw(password.trim(), BCrypt.gensalt(12));
        }
        
        boolean success = accountRepository.updateStaffAccount(accountId, email.trim(), fullName.trim(), phone, roleId, passwordHash);
        if (success) {
            logger.info("Admin updated staff account: {}, Name: {}, Phone: {}, Role: {}", email, fullName, phone, roleId);
            return "success";
        }
        return "update_failed";
    }

    public String toggleAccountStatus(int accountId, boolean active) {
        // BR-65 validation: Cannot lock/deactivate the Admin account
        if (!active) {
            Account account = accountRepository.getAccountById(accountId);
            if (account != null && "Admin".equals(account.getRoleName())) {
                return "cannot_lock_admin";
            }
        }
        boolean success = accountRepository.toggleAccountStatus(accountId, active);
        if (success) {
            logger.info("Admin toggled account status: ID {}, Active: {}", accountId, active);
            return "success";
        }
        return "failed";
    }

    public boolean existsByEmail(String email) {
        return accountRepository.existsByEmail(email);
    }

    public boolean existsByPhone(String phone) {
        return accountRepository.existsByPhone(phone);
    }

    public boolean existsByEmailExcept(String email, int excludeId) {
        return accountRepository.existsByEmailExcept(email, excludeId);
    }

    public boolean existsByPhoneExcept(String phone, int excludeId) {
        return accountRepository.existsByPhoneExcept(phone, excludeId);
    }

    public String updateCustomerAccount(int accountId, String email, String fullName, String phone, String password, int loyaltyPoints, String membershipLevel) {
        if (email == null || email.trim().isEmpty() || fullName == null || fullName.trim().isEmpty()) {
            return "invalid_input";
        }
        phone = sanitizePhone(phone);
        if (isInvalidEmail(email)) {
            return "invalid_email";
        }
        if (isInvalidPhone(phone)) {
            return "invalid_phone";
        }
        if (accountRepository.existsByEmailExcept(email.trim(), accountId)) {
            return "email_exists";
        }
        if (phone != null && accountRepository.existsByPhoneExcept(phone, accountId)) {
            return "phone_exists";
        }
        
        String passwordHash = null;
        if (password != null && !password.trim().isEmpty()) {
            if (isWeakPassword(password)) {
                return "weak_password";
            }
            passwordHash = BCrypt.hashpw(password.trim(), BCrypt.gensalt(12));
        }
        
        boolean success = accountRepository.updateCustomerAccount(accountId, email.trim(), fullName.trim(), phone, loyaltyPoints, membershipLevel, passwordHash);
        return success ? "success" : "update_failed";
    }

    /**
     * Đổi mật khẩu tài khoản Admin.
     * Validate thông tin nhập vào, kiểm tra mật khẩu cũ trùng khớp,
     * xác thực độ phức tạp của mật khẩu mới theo chuẩn đăng ký tài khoản,
     * mã hóa mật khẩu mới và cập nhật vào cơ sở dữ liệu.
     */
    public String changePassword(String email, String oldPassword, String newPassword, String confirmPassword) {
        if (email == null || email.trim().isEmpty() || oldPassword == null || oldPassword.isEmpty() ||
            newPassword == null || newPassword.isEmpty() || confirmPassword == null || confirmPassword.isEmpty()) {
            return "invalid_input";
        }

        // 1. Kiểm tra tài khoản tồn tại trong hệ thống
        Account account = accountRepository.getAccountByEmail(email.trim());
        if (account == null) {
            return "account_not_found";
        }

        // 2. Xác thực mật khẩu cũ bằng BCrypt
        if (!BCrypt.checkpw(oldPassword.trim(), account.getPassword())) {
            return "incorrect_old_password";
        }

        // 3. Xác thực độ phức tạp của mật khẩu mới (trùng khớp quy tắc đăng ký)
        boolean hasLetter = newPassword.matches(".*[a-zA-Z].*");
        boolean hasDigit = newPassword.matches(".*[0-9].*");
        boolean hasSpecial = newPassword.matches(".*[^a-zA-Z0-9].*");
        
        if (newPassword.length() < 8) {
            return "password_too_short";
        }
        if (!hasLetter || !hasDigit || !hasSpecial) {
            return "password_too_weak";
        }

        // 4. Kiểm tra trùng khớp mật khẩu nhập lại
        if (!newPassword.equals(confirmPassword)) {
            return "passwords_dont_match";
        }

        // 5. Kiểm tra mật khẩu mới không được trùng với mật khẩu hiện tại
        if (oldPassword.trim().equals(newPassword.trim())) {
            return "password_same_as_current";
        }

        // 6. Tiến hành mã hóa mật khẩu mới và lưu vào database
        String hashedPassword = BCrypt.hashpw(newPassword.trim(), BCrypt.gensalt(12));
        boolean success = accountRepository.updatePassword(email.trim(), hashedPassword);
        return success ? "success" : "update_failed";
    }
}
