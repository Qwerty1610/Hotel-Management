package com.mycompany.hotelmanagement.controller.common;

import java.io.Serializable;

/**
 * Request payload class for changing password.
 * Used by all roles.
 * 
 * @author TungNQ
 * @version 1.0.0
 * Created: 24/06/2026
 * Modified: 24/06/2026
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
