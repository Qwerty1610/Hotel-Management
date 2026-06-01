package com.mycompany.hotelmanagement.entity;

/**
 * StaffInfo
 * Thông tin nhân viên (Housekeeping) phục vụ trang theo dõi công việc của Manager:
 * trạng thái làm việc và số công việc đã hoàn thành theo ngày / tháng.
 *
 * Date: 02/6/2026
 */
public class StaffInfo {

    private int accountId;
    private String fullName;
    private String email;
    private String workStatus;     // Active / OnBreak / Offline
    private int completedToday;    // số yêu cầu hoàn thành hôm nay
    private int completedMonth;    // số yêu cầu hoàn thành trong tháng
    private int activeAssignments; // số việc đang được giao (chưa hoàn thành)

    public StaffInfo() {}

    /* ---------- Getters & Setters ---------- */
    public int getAccountId()              { return accountId; }
    public void setAccountId(int v)        { this.accountId = v; }

    public String getFullName()            { return fullName; }
    public void setFullName(String v)      { this.fullName = v; }

    public String getEmail()               { return email; }
    public void setEmail(String v)         { this.email = v; }

    public String getWorkStatus()          { return workStatus; }
    public void setWorkStatus(String v)    { this.workStatus = v; }

    public int getCompletedToday()         { return completedToday; }
    public void setCompletedToday(int v)   { this.completedToday = v; }

    public int getCompletedMonth()         { return completedMonth; }
    public void setCompletedMonth(int v)   { this.completedMonth = v; }

    public int getActiveAssignments()      { return activeAssignments; }
    public void setActiveAssignments(int v){ this.activeAssignments = v; }
}
