package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.AccountRepository;
import com.mycompany.hotelmanagement.entity.Account;
import org.mindrot.jbcrypt.BCrypt;

public class AuthService {
    private final AccountRepository accountRepository = new AccountRepository();

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

    public Account loginWithGoogle(String code) {
        try {
            com.mycompany.hotelmanagement.util.GoogleOAuthHelper.GoogleUserInfo userInfo = 
                com.mycompany.hotelmanagement.util.GoogleOAuthHelper.exchangeCodeAndGetUserInfo(code);
            
            Account account = accountRepository.getAccountByEmail(userInfo.getEmail().toLowerCase());
            if (account != null) {
                return account;
            }
            
            int customerRoleId = accountRepository.getRoleIdByName("Customer");
            if (customerRoleId <= 0) {
                customerRoleId = 5; // fallback
            }
            
            // Sinh một mật khẩu ngẫu nhiên để thỏa mãn ràng buộc NOT NULL của DB
            String randomPassword = java.util.UUID.randomUUID().toString();
            String passwordHash = BCrypt.hashpw(randomPassword, BCrypt.gensalt(12));
            
            int accountId = accountRepository.insertAccount(
                userInfo.getEmail().toLowerCase(),
                passwordHash,
                userInfo.getName(),
                customerRoleId
            );
            
            if (accountId > 0) {
                Account newAccount = new Account();
                newAccount.setEmail(userInfo.getEmail().toLowerCase());
                newAccount.setFullName(userInfo.getName());
                newAccount.setRoleName("Customer");
                return newAccount;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
