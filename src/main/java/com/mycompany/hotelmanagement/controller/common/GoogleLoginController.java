package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import com.mycompany.hotelmanagement.config.ConfigUtil;
import com.mycompany.hotelmanagement.config.DBContext;
import org.mindrot.jbcrypt.BCrypt;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "GoogleLoginController", urlPatterns = {"/login-google"})
public class GoogleLoginController extends HttpServlet {

    private static final String CLIENT_ID = ConfigUtil.get("google.client.id",
            System.getProperty("google.client.id", "your-google-client-id"));
    private static final String CLIENT_SECRET = ConfigUtil.get("google.client.secret",
            System.getProperty("google.client.secret", "your-google-client-secret"));
    private static final String REDIRECT_URI = "http://localhost:8080/HotelManagement/login-google";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String code = request.getParameter("code");
        if (code == null || code.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home/login?error=invalid_credentials");
            return;
        }

        try {
            // 1. Exchange authorization code for tokens
            String tokenResponse = exchangeCodeForToken(code);
            String accessToken = extractJsonField(tokenResponse, "access_token");
            
            if (accessToken == null || accessToken.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/home/login?error=invalid_credentials");
                return;
            }

            // 2. Fetch user details using access token
            String userInfoResponse = fetchUserInfo(accessToken);
            String email = extractJsonField(userInfoResponse, "email");
            String name = extractJsonField(userInfoResponse, "name");

            if (email == null || email.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/home/login?error=invalid_credentials");
                return;
            }

            // 3. Check and authenticate or register in DB
            authenticateOrRegisterUser(email, name, request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home/login?error=server_error");
        }
    }

    private String exchangeCodeForToken(String code) throws Exception {
        HttpClient client = HttpClient.newHttpClient();
        String requestBody = "code=" + java.net.URLEncoder.encode(code, java.nio.charset.StandardCharsets.UTF_8) +
                             "&client_id=" + java.net.URLEncoder.encode(CLIENT_ID, java.nio.charset.StandardCharsets.UTF_8) +
                             "&client_secret=" + java.net.URLEncoder.encode(CLIENT_SECRET, java.nio.charset.StandardCharsets.UTF_8) +
                             "&redirect_uri=" + java.net.URLEncoder.encode(REDIRECT_URI, java.nio.charset.StandardCharsets.UTF_8) +
                             "&grant_type=authorization_code";

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://oauth2.googleapis.com/token"))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                .build();

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        return response.body();
    }

    private String fetchUserInfo(String accessToken) throws Exception {
        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://www.googleapis.com/oauth2/v3/userinfo"))
                .header("Authorization", "Bearer " + accessToken)
                .GET()
                .build();

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        return response.body();
    }

    private void authenticateOrRegisterUser(String email, String name, HttpServletRequest request, HttpServletResponse response) throws Exception {
        Connection conn = null;
        PreparedStatement checkPs = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            
            // Query to find user and role
            checkPs = conn.prepareStatement(
                "SELECT a.email, a.full_name, r.role_name " +
                "FROM Account a JOIN Role r ON a.role_id = r.role_id " +
                "WHERE a.email = ? AND a.is_active = 1");
            checkPs.setString(1, email);
            rs = checkPs.executeQuery();

            String role = null;
            String redirectUrl = null;
            String userDisplayName = name;

            if (rs.next()) {
                // User already exists, retrieve details
                String dbFullName = rs.getString("full_name");
                String dbRoleName = rs.getString("role_name");
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
                // User doesn't exist, create new Customer account
                rs.close();
                checkPs.close();

                conn.setAutoCommit(false); // Begin Transaction

                PreparedStatement insertAccountPs = null;
                PreparedStatement insertCustomerPs = null;

                try {
                    String randomPassword = java.util.UUID.randomUUID().toString();
                    String hashedPassword = BCrypt.hashpw(randomPassword, BCrypt.gensalt(12));

                    String insertAccountSql = "INSERT INTO Account (email, password, full_name, role_id, is_active, created_at) VALUES (?, ?, ?, ?, ?, ?)";
                    insertAccountPs = conn.prepareStatement(insertAccountSql, Statement.RETURN_GENERATED_KEYS);
                    insertAccountPs.setString(1, email);
                    insertAccountPs.setString(2, hashedPassword);
                    insertAccountPs.setString(3, name);
                    insertAccountPs.setInt(4, 2); // Role ID 2 is Customer
                    insertAccountPs.setInt(5, 1); // is_active = 1
                    insertAccountPs.setTimestamp(6, new Timestamp(System.currentTimeMillis()));

                    insertAccountPs.executeUpdate();

                    int accountId = -1;
                    try (ResultSet generatedKeys = insertAccountPs.getGeneratedKeys()) {
                        if (generatedKeys.next()) {
                            accountId = generatedKeys.getInt(1);
                        } else {
                            throw new SQLException("Creating account failed, no ID obtained.");
                        }
                    }

                    String insertCustomerSql = "INSERT INTO Customer (account_id, loyalty_points, membership_level) VALUES (?, ?, ?)";
                    insertCustomerPs = conn.prepareStatement(insertCustomerSql);
                    insertCustomerPs.setInt(1, accountId);
                    insertCustomerPs.setInt(2, 0);
                    insertCustomerPs.setString(3, "Standard");
                    insertCustomerPs.executeUpdate();

                    conn.commit(); // Commit Transaction
                    
                    role = "CUSTOMER";
                    redirectUrl = "/home";

                } catch (Exception e) {
                    if (conn != null) conn.rollback();
                    throw e;
                } finally {
                    if (insertAccountPs != null) insertAccountPs.close();
                    if (insertCustomerPs != null) insertCustomerPs.close();
                }
            }

            if (role != null) {
                HttpSession session = request.getSession();
                session.setAttribute("user", userDisplayName);
                session.setAttribute("role", role);
                response.sendRedirect(request.getContextPath() + redirectUrl);
            } else {
                response.sendRedirect(request.getContextPath() + "/home/login?error=invalid_credentials");
            }

        } finally {
            if (rs != null) rs.close();
            if (checkPs != null) checkPs.close();
            if (conn != null) conn.close();
        }
    }

    private String extractJsonField(String json, String field) {
        java.util.regex.Pattern pattern = java.util.regex.Pattern.compile("\"" + field + "\":\\s*\"([^\"]+)\"");
        java.util.regex.Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }
}
