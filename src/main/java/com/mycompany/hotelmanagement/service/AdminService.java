package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.AccountRepository;
import com.mycompany.hotelmanagement.entity.Account;
import com.mycompany.hotelmanagement.entity.CustomerInfo;
import com.mycompany.hotelmanagement.entity.Role;
import org.mindrot.jbcrypt.BCrypt;

import java.util.List;

public class AdminService {
    private final AccountRepository accountRepository = new AccountRepository();

    public List<Account> getStaffAccounts() {
        return accountRepository.getAllStaffAccounts();
    }

    public List<CustomerInfo> getCustomerAccounts() {
        return accountRepository.getAllCustomerAccounts();
    }

    public List<Role> getStaffRoles() {
        return accountRepository.getStaffRoles();
    }

    public String createStaffAccount(String email, String fullName, String phone, String password, int roleId) {
        if (email == null || email.trim().isEmpty() || fullName == null || fullName.trim().isEmpty() || password == null || password.isEmpty()) {
            return "invalid_input";
        }
        if (accountRepository.existsByEmail(email.trim())) {
            return "email_exists";
        }
        String passwordHash = BCrypt.hashpw(password.trim(), BCrypt.gensalt(12));
        boolean success = accountRepository.insertStaffAccount(email.trim(), passwordHash, fullName.trim(), phone != null ? phone.trim() : null, roleId);
        return success ? "success" : "create_failed";
    }

    public String updateStaffAccount(int accountId, String email, String fullName, String phone, String password, int roleId) {
        if (email == null || email.trim().isEmpty() || fullName == null || fullName.trim().isEmpty()) {
            return "invalid_input";
        }
        
        String passwordHash = null;
        if (password != null && !password.trim().isEmpty()) {
            passwordHash = BCrypt.hashpw(password.trim(), BCrypt.gensalt(12));
        }
        
        boolean success = accountRepository.updateStaffAccount(accountId, email.trim(), fullName.trim(), phone != null ? phone.trim() : null, roleId, passwordHash);
        return success ? "success" : "update_failed";
    }

    public boolean toggleAccountStatus(int accountId, boolean active) {
        return accountRepository.toggleAccountStatus(accountId, active);
    }

    public String updateCustomerAccount(int accountId, String email, String fullName, String phone, String password, int loyaltyPoints, String membershipLevel) {
        if (email == null || email.trim().isEmpty() || fullName == null || fullName.trim().isEmpty()) {
            return "invalid_input";
        }
        
        String passwordHash = null;
        if (password != null && !password.trim().isEmpty()) {
            passwordHash = BCrypt.hashpw(password.trim(), BCrypt.gensalt(12));
        }
        
        boolean success = accountRepository.updateCustomerAccount(accountId, email.trim(), fullName.trim(), phone != null ? phone.trim() : null, loyaltyPoints, membershipLevel, passwordHash);
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

        // 5. Tiến hành mã hóa mật khẩu mới và lưu vào database
        String hashedPassword = BCrypt.hashpw(newPassword.trim(), BCrypt.gensalt(12));
        boolean success = accountRepository.updatePassword(email.trim(), hashedPassword);
        return success ? "success" : "update_failed";
    }
}
