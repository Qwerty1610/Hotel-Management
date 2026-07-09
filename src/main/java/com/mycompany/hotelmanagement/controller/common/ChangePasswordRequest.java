package com.mycompany.hotelmanagement.controller.common;

import java.io.Serializable;

/**
 * Request payload class for changing password.
 * Used by all roles.
 * 
 * @author TungNQ
 */
public class ChangePasswordRequest implements Serializable {
    private static final long serialVersionUID = 1L;

    private String oldPassword;
    private String newPassword;
    private String confirmPassword;

    public ChangePasswordRequest() {
    }

    public String getOldPassword() {
        return oldPassword;
    }

    public void setOldPassword(String oldPassword) {
        this.oldPassword = oldPassword;
    }

    public String getNewPassword() {
        return newPassword;
    }

    public void setNewPassword(String newPassword) {
        this.newPassword = newPassword;
    }

    public String getConfirmPassword() {
        return confirmPassword;
    }

    public void setConfirmPassword(String confirmPassword) {
        this.confirmPassword = confirmPassword;
    }
}
