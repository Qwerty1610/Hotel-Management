package com.mycompany.hotelmanagement.controller.admin;

import java.io.Serializable;

/**
 * Đối tượng DTO để map dữ liệu JSON nhận từ client khi đổi mật khẩu Admin.
 * 
 * @author TùngNQ
 */
public class AdminChangePasswordRequest implements Serializable {
    private static final long serialVersionUID = 1L;

    private String oldPassword;
    private String newPassword;
    private String confirmPassword;

    public AdminChangePasswordRequest() {
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
