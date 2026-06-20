package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.Account;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class AccountRepository {

    public Account getAccountByEmail(String email) {
        String sql = "SELECT a.account_id, a.email, a.password, a.full_name, r.role_name " +
                     "FROM Account a JOIN Role r ON a.role_id = r.role_id " +
                     "WHERE a.email = ? AND a.is_active = 1";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
             
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Account account = new Account();
                    account.setAccountId(rs.getInt("account_id"));
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

    public int insertAccount(String email, String passwordHash, String fullName, int roleId) {
        String sql = "INSERT INTO Account (email, password, full_name, role_id, is_active) VALUES (?, ?, ?, ?, 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, email);
            ps.setString(2, passwordHash);
            ps.setString(3, fullName);
            ps.setInt(4, roleId);
            
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public int getRoleIdByName(String roleName) {
        String sql = "SELECT role_id FROM Role WHERE role_name = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, roleName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("role_id");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public java.util.List<String> getAllCustomerNames() {
        java.util.List<String> names = new java.util.ArrayList<>();
        String sql = "SELECT a.full_name " +
                     "FROM Account a JOIN Role r ON a.role_id = r.role_id " +
                     "WHERE r.role_name = 'Customer' AND a.is_active = 1 " +
                     "ORDER BY a.full_name";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                names.add(rs.getString("full_name"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return names;
    }
}

