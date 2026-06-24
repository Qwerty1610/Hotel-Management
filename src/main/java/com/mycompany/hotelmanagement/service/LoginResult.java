package com.mycompany.hotelmanagement.service;

public class LoginResult {
    private final boolean success;
    private final String role;
    private final String displayName;
    private final String redirectUrl;

    public LoginResult(boolean success, String role, String displayName, String redirectUrl) {
        this.success = success;
        this.role = role;
        this.displayName = displayName;
        this.redirectUrl = redirectUrl;
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
}
