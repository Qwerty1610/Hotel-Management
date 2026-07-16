package com.mycompany.hotelmanagement.scratch;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class CheckColumns {
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://localhost:1433;databaseName=HotelManagementDB;encrypt=true;trustServerCertificate=true;";
        String user = "sa";
        String password = "123";
        try (Connection conn = DriverManager.getConnection(url, user, password)) {
            System.out.println("Accounts in database:");
            try (PreparedStatement ps = conn.prepareStatement("SELECT account_id, email, full_name, phone, role_id FROM Account")) {
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        System.out.println("- ID: " + rs.getInt("account_id") + 
                                           ", Email: " + rs.getString("email") + 
                                           ", Name: " + rs.getString("full_name") + 
                                           ", Phone: '" + rs.getString("phone") + "'" +
                                           ", RoleID: " + rs.getInt("role_id"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
