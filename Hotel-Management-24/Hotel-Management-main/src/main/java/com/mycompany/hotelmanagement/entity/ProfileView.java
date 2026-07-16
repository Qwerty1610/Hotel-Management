package com.mycompany.hotelmanagement.entity;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Read-only view model representing the personal profile of the currently
 * logged-in user (any role). For Customer accounts it also carries the
 * loyalty information; for other roles those fields stay null/zero.
 */
public class ProfileView implements Serializable {
    private int accountId;
    private String email;
    private String fullName;
    private String phone;
    private String roleName;
    private boolean active;
    private Timestamp createdAt;

    // Customer-only fields (null/0 for staff & admin accounts)
    private boolean customer;
    private int loyaltyPoints;
    private String membershipLevel;

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isCustomer() {
        return customer;
    }

    public void setCustomer(boolean customer) {
        this.customer = customer;
    }

    public int getLoyaltyPoints() {
        return loyaltyPoints;
    }

    public void setLoyaltyPoints(int loyaltyPoints) {
        this.loyaltyPoints = loyaltyPoints;
    }

    public String getMembershipLevel() {
        return membershipLevel;
    }

    public void setMembershipLevel(String membershipLevel) {
        this.membershipLevel = membershipLevel;
    }
}
