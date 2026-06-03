package com.mycompany.hotelmanagement.util;

import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeTokenRequest;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.googleapis.auth.oauth2.GoogleTokenResponse;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.Properties;

public final class GoogleOAuthHelper {

    private static final Logger logger = LoggerFactory.getLogger(GoogleOAuthHelper.class);

    private static String clientId;
    private static String clientSecret;
    private static String redirectUri;
    private static boolean configured = false;

    private static final String AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth";
    private static final String SCOPE = "openid email profile";

    static {
        loadConfig();
    }

    private GoogleOAuthHelper() {}

    private static void loadConfig() {
        try (InputStream input = GoogleOAuthHelper.class.getClassLoader()
                .getResourceAsStream("oauth.properties")) {
            if (input != null) {
                Properties props = new Properties();
                props.load(input);
                clientId = props.getProperty("google.client.id");
                clientSecret = props.getProperty("google.client.secret");
                redirectUri = props.getProperty("google.redirect.uri");
                configured = clientId != null && clientSecret != null && redirectUri != null
                        && !clientId.contains("YOUR_CLIENT_ID");
                if (configured) {
                    logger.info("Google OAuth config loaded successfully");
                } else {
                    logger.warn("Google OAuth not configured - update oauth.properties");
                }
            } else {
                logger.warn("oauth.properties not found in classpath");
            }
        } catch (Exception e) {
            logger.error("Failed to load oauth.properties", e);
        }
    }

    public static boolean isConfigured() {
        return configured;
    }

    public static String getAuthorizationUrl(String state) {
        if (!configured) {
            throw new IllegalStateException("Google OAuth not configured");
        }
        return AUTH_URL + "?"
                + "client_id=" + URLEncoder.encode(clientId, StandardCharsets.UTF_8)
                + "&redirect_uri=" + URLEncoder.encode(redirectUri, StandardCharsets.UTF_8)
                + "&response_type=code"
                + "&scope=" + URLEncoder.encode(SCOPE, StandardCharsets.UTF_8)
                + "&state=" + URLEncoder.encode(state, StandardCharsets.UTF_8)
                + "&access_type=offline"
                + "&prompt=consent";
    }

    public static GoogleUserInfo exchangeCodeAndGetUserInfo(String code) throws Exception {
        if (!configured) {
            throw new IllegalStateException("Google OAuth not configured");
        }

        NetHttpTransport transport = new NetHttpTransport();
        GsonFactory jsonFactory = GsonFactory.getDefaultInstance();

        // Exchange authorization code for tokens
        GoogleTokenResponse tokenResponse = new GoogleAuthorizationCodeTokenRequest(
                transport, jsonFactory, clientId, clientSecret, code, redirectUri)
                .execute();

        String idTokenString = tokenResponse.getIdToken();

        // Verify and decode ID token
        GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(transport, jsonFactory)
                .setAudience(Collections.singletonList(clientId))
                .build();

        GoogleIdToken idToken = verifier.verify(idTokenString);
        if (idToken == null) {
            throw new SecurityException("Invalid ID token");
        }

        GoogleIdToken.Payload payload = idToken.getPayload();
        return new GoogleUserInfo(
                payload.getSubject(),
                payload.getEmail(),
                (String) payload.get("name"),
                (String) payload.get("picture")
        );
    }

    public static class GoogleUserInfo {
        private final String id;
        private final String email;
        private final String name;
        private final String picture;

        public GoogleUserInfo(String id, String email, String name, String picture) {
            this.id = id;
            this.email = email;
            this.name = name;
            this.picture = picture;
        }

        public String getId() { return id; }
        public String getEmail() { return email; }
        public String getName() { return name; }
        public String getPicture() { return picture; }
    }
}
