package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.Account;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class AccountRepository {

    public Account getAccountByEmail(String email) {
        String sql = "SELECT a.email, a.password, a.full_name, r.role_name " +
                     "FROM Account a JOIN Role r ON a.role_id = r.role_id " +
                     "WHERE a.email = ? AND a.is_active = 1";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Account account = new Account();
                    account.setEmail(rs.getString("email"));
                    account.setPassword(rs.getString("password"));
                    account.setFullName(rs.getString("full_name"));
                    account.setRoleName(rs.getString("role_name"));
                    return account;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
