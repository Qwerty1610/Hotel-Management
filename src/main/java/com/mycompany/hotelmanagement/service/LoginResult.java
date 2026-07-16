package com.mycompany.hotelmanagement.service;

/**
 *
 * @author TungNQ
 * @version 1.0.2
 * Created: 24/06/2026
 * Modified: 25/06/2026
 */
public class LoginResult {
    private final boolean success;
    private final String role;
    private final String displayName;
    private final String redirectUrl;
    private final String email;
    private final int accountId;

    public LoginResult(boolean success, String role, String displayName, String redirectUrl) {
        this(success, role, displayName, redirectUrl, null, -1);
    }

    public LoginResult(boolean success, String role, String displayName, String redirectUrl, String email, int accountId) {
        this.success = success;
        this.role = role;
        this.displayName = displayName;
        this.redirectUrl = redirectUrl;
        this.email = email;
        this.accountId = accountId;
    }

    public boolean isSuccess() {
        return success;
    }

    public String getRole() {
        return role;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getRedirectUrl() {
        return redirectUrl;
    }

    public String getEmail() {
        return email;
    }

    public int getAccountId() {
        return accountId;
    }
}
