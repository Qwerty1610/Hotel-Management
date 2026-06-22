package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.Account;
import com.mycompany.hotelmanagement.entity.CustomerInfo;
import com.mycompany.hotelmanagement.entity.Role;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

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

    public boolean existsByEmail(String email) {
        String sql = "SELECT 1 FROM Account WHERE email = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean existsByPhone(String phone) {
        String sql = "SELECT 1 FROM Account WHERE phone = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updatePassword(String email, String hashedPassword) {
        String sql = "UPDATE Account SET password = ? WHERE email = ? AND is_active = 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, hashedPassword);
            ps.setString(2, email);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean registerCustomer(String email, String passwordHash, String fullName, String phone, int roleId) {
        String insertAccountSql = "INSERT INTO Account (email, password, full_name, phone, role_id, is_active, created_at) VALUES (?, ?, ?, ?, ?, 1, ?)";
        String insertCustomerSql = "INSERT INTO Customer (account_id, loyalty_points, membership_level) VALUES (?, 0, 'Standard')";
        
        Connection conn = null;
        PreparedStatement insertAccountPs = null;
        PreparedStatement insertCustomerPs = null;
        ResultSet rs = null;
        
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);
            
            insertAccountPs = conn.prepareStatement(insertAccountSql, java.sql.Statement.RETURN_GENERATED_KEYS);
            insertAccountPs.setString(1, email);
            insertAccountPs.setString(2, passwordHash);
            insertAccountPs.setString(3, fullName);
            insertAccountPs.setString(4, phone);
            insertAccountPs.setInt(5, roleId);
            insertAccountPs.setTimestamp(6, new java.sql.Timestamp(System.currentTimeMillis()));
            
            int affectedRows = insertAccountPs.executeUpdate();
            if (affectedRows == 0) {
                conn.rollback();
                return false;
            }
            
            int accountId = -1;
            rs = insertAccountPs.getGeneratedKeys();
            if (rs.next()) {
                accountId = rs.getInt(1);
            } else {
                conn.rollback();
                return false;
            }
            
            insertCustomerPs = conn.prepareStatement(insertCustomerSql);
            insertCustomerPs.setInt(1, accountId);
            insertCustomerPs.executeUpdate();
            
            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (rs != null) rs.close();
                if (insertAccountPs != null) insertAccountPs.close();
                if (insertCustomerPs != null) insertCustomerPs.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public List<Account> getAllStaffAccounts() {
        List<Account> list = new ArrayList<>();
        String sql = "SELECT a.account_id, a.email, a.full_name, a.phone, a.role_id, r.role_name, a.is_active, a.created_at " +
                     "FROM Account a JOIN Role r ON a.role_id = r.role_id " +
                     "WHERE r.role_name != 'Customer' AND r.role_name != 'Admin' " +
                     "ORDER BY a.account_id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Account account = new Account();
                account.setAccountId(rs.getInt("account_id"));
                account.setEmail(rs.getString("email"));
                account.setFullName(rs.getString("full_name"));
                account.setPhone(rs.getString("phone"));
                account.setRoleId(rs.getInt("role_id"));
                account.setRoleName(rs.getString("role_name"));
                account.setActive(rs.getBoolean("is_active"));
                account.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(account);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<CustomerInfo> getAllCustomerAccounts() {
        List<CustomerInfo> list = new ArrayList<>();
        String sql = "SELECT a.account_id, a.email, a.full_name, a.phone, a.is_active, a.created_at, " +
                     "       c.loyalty_points, c.membership_level " +
                     "FROM Account a " +
                     "JOIN Role r ON a.role_id = r.role_id " +
                     "LEFT JOIN Customer c ON a.account_id = c.account_id " +
                     "WHERE r.role_name = 'Customer' " +
                     "ORDER BY a.account_id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                CustomerInfo customer = new CustomerInfo();
                customer.setAccountId(rs.getInt("account_id"));
                customer.setEmail(rs.getString("email"));
                customer.setFullName(rs.getString("full_name"));
                customer.setPhone(rs.getString("phone"));
                customer.setActive(rs.getBoolean("is_active"));
                customer.setCreatedAt(rs.getTimestamp("created_at"));
                customer.setLoyaltyPoints(rs.getInt("loyalty_points"));
                customer.setMembershipLevel(rs.getString("membership_level"));
                list.add(customer);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Role> getStaffRoles() {
        List<Role> list = new ArrayList<>();
        String sql = "SELECT role_id, role_name, description FROM Role WHERE role_name != 'Customer' AND role_name != 'Admin'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Role role = new Role();
                role.setRoleId(rs.getInt("role_id"));
                role.setRoleName(rs.getString("role_name"));
                role.setDescription(rs.getString("description"));
                list.add(role);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean insertStaffAccount(String email, String passwordHash, String fullName, String phone, int roleId) {
        String sql = "INSERT INTO Account (email, password, full_name, phone, role_id, is_active, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, 1, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, passwordHash);
            ps.setString(3, fullName);
            ps.setString(4, phone);
            ps.setInt(5, roleId);
            ps.setTimestamp(6, new java.sql.Timestamp(System.currentTimeMillis()));
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateStaffAccount(int accountId, String email, String fullName, String phone, int roleId, String passwordHash) {
        String sql;
        boolean hasPassword = passwordHash != null && !passwordHash.isEmpty();
        if (hasPassword) {
            sql = "UPDATE Account SET email = ?, full_name = ?, phone = ?, role_id = ?, password = ? WHERE account_id = ?";
        } else {
            sql = "UPDATE Account SET email = ?, full_name = ?, phone = ?, role_id = ? WHERE account_id = ?";
        }
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, fullName);
            ps.setString(3, phone);
            ps.setInt(4, roleId);
            if (hasPassword) {
                ps.setString(5, passwordHash);
                ps.setInt(6, accountId);
            } else {
                ps.setInt(5, accountId);
            }
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean toggleAccountStatus(int accountId, boolean isActive) {
        String sql = "UPDATE Account SET is_active = ? WHERE account_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, isActive ? 1 : 0);
            ps.setInt(2, accountId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateCustomerAccount(int accountId, String email, String fullName, String phone, int loyaltyPoints, String membershipLevel, String passwordHash) {
        String updateAccountSql;
        boolean hasPassword = passwordHash != null && !passwordHash.isEmpty();
        if (hasPassword) {
            updateAccountSql = "UPDATE Account SET email = ?, full_name = ?, phone = ?, password = ? WHERE account_id = ?";
        } else {
            updateAccountSql = "UPDATE Account SET email = ?, full_name = ?, phone = ? WHERE account_id = ?";
        }
        
        String updateCustomerSql = "UPDATE Customer SET loyalty_points = ?, membership_level = ? WHERE account_id = ?";
        
        Connection conn = null;
        PreparedStatement accountPs = null;
        PreparedStatement customerPs = null;
        
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);
            
            accountPs = conn.prepareStatement(updateAccountSql);
            accountPs.setString(1, email);
            accountPs.setString(2, fullName);
            accountPs.setString(3, phone);
            if (hasPassword) {
                accountPs.setString(4, passwordHash);
                accountPs.setInt(5, accountId);
            } else {
                accountPs.setInt(4, accountId);
            }
            accountPs.executeUpdate();
            
            customerPs = conn.prepareStatement(updateCustomerSql);
            customerPs.setInt(1, loyaltyPoints);
            customerPs.setString(2, membershipLevel);
            customerPs.setInt(3, accountId);
            int affected = customerPs.executeUpdate();
            if (affected == 0) {
                try (PreparedStatement insertPs = conn.prepareStatement(
                        "INSERT INTO Customer (account_id, loyalty_points, membership_level) VALUES (?, ?, ?)")) {
                    insertPs.setInt(1, accountId);
                    insertPs.setInt(2, loyaltyPoints);
                    insertPs.setString(3, membershipLevel);
                    insertPs.executeUpdate();
                }
            }
            
            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (accountPs != null) accountPs.close();
                if (customerPs != null) customerPs.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
