package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import com.mycompany.hotelmanagement.config.ConfigUtil;
import com.mycompany.hotelmanagement.service.AuthService;
import com.mycompany.hotelmanagement.service.LoginResult;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Controller xử lý đăng nhập bằng Google OAuth2.
 * Nhận authorization code, đổi lấy access token, lấy thông tin tài khoản người dùng,
 * sau đó ủy thác việc đăng nhập/đăng ký tự động cho AuthService.
 * 
 * @author TùngNQ
 */
@WebServlet(name = "GoogleLoginController", urlPatterns = {"/login-google"})
public class GoogleLoginController extends HttpServlet {

    private final AuthService authService = new AuthService();

    private static final String CLIENT_ID = ConfigUtil.get("google.client.id",
            System.getProperty("google.client.id", "your-google-client-id"));
    private static final String CLIENT_SECRET = ConfigUtil.get("google.client.secret",
            System.getProperty("google.client.secret", "your-google-client-secret"));
    private static final String REDIRECT_URI = "http://localhost:8080/HotelManagement/login-google";

    /**
     * Xử lý callback từ Google sau khi người dùng xác thực và đồng ý cấp quyền.
     */
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

            // 3. Delegate authentication and register logic to AuthService
            LoginResult result = authService.loginOrRegisterGoogle(email, name);

            if (result.isSuccess()) {
                HttpSession session = request.getSession();
                session.setAttribute("user", result.getDisplayName());
                session.setAttribute("role", result.getRole());
                session.setAttribute("email", email != null ? email.trim() : "");
                
                String redirectUrl = null;
                if ("CUSTOMER".equals(result.getRole())) {
                    redirectUrl = (String) session.getAttribute("redirectAfterLogin");
                    session.removeAttribute("redirectAfterLogin");
                } else {
                    session.removeAttribute("redirectAfterLogin");
                }

                if (redirectUrl != null && !redirectUrl.isEmpty()) {
                    response.sendRedirect(redirectUrl);
                } else {
                    response.sendRedirect(request.getContextPath() + result.getRedirectUrl());
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/home/login?error=invalid_credentials");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home/login?error=server_error");
        }
    }

    /**
     * Gửi request POST tới Google OAuth2 server để đổi authorization code lấy access token.
     * 
     * @param code Mã authorization code nhận từ Google
     * @return Chuỗi JSON chứa access_token
     */
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

    /**
     * Gửi request GET tới Google API để lấy thông tin hồ sơ của người dùng (email, name).
     * 
     * @param accessToken Access token của Google
     * @return Chuỗi JSON chứa thông tin người dùng
     */
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

    /**
     * Hàm helper trích xuất giá trị trường JSON đơn giản bằng biểu thức chính quy (Regex).
     */
    private String extractJsonField(String json, String field) {
        java.util.regex.Pattern pattern = java.util.regex.Pattern.compile("\"" + field + "\":\\s*\"([^\"]+)\"");
        java.util.regex.Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }
}
