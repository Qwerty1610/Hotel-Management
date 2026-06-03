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


}
