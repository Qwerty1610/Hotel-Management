package com.mycompany.hotelmanagement.entity;

import java.io.Serializable;

public class Account implements Serializable {
    private int accountId;
    private String email;
    private String password;
    private String fullName;
    private String roleName;

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public Account() {
    }

    public Account(String email, String password, String fullName, String roleName) {
        this.email = email;
        this.password = password;
        this.fullName = fullName;
        this.roleName = roleName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }
}
