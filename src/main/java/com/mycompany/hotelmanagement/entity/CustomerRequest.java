package com.mycompany.hotelmanagement.entity;

import java.sql.Timestamp;

/**
 * CustomerRequest
 * Yêu cầu của khách hàng phát sinh tại một phòng, được Manager phân công cho
 * nhân viên Housekeeping xử lý.
 *
 * Date: 02/6/2026
 * ver 1.0
 * @author Phạm Quốc Quý
 */
public class CustomerRequest {

    private int requestId;
    private Integer roomId;          // có thể null
    private String roomNumber;       // lấy kèm từ JOIN Room để hiển thị
    private String title;            // nội dung yêu cầu
    private String description;
    private String priority;         // Low / Medium / High / Urgent
    private String status;           // Pending / InProgress / Completed / Cancelled
    private Integer assignedStaffId; // null = chưa gán
    private String assignedStaffName;// lấy kèm từ JOIN Account
    private Timestamp createdAt;     // thời gian yêu cầu
    private Timestamp completedAt;

    public CustomerRequest() {}

    /* ---------- Getters & Setters ---------- */
    public int getRequestId()                 { return requestId; }
    public void setRequestId(int v)           { this.requestId = v; }

    public Integer getRoomId()                { return roomId; }
    public void setRoomId(Integer v)          { this.roomId = v; }

    public String getRoomNumber()             { return roomNumber; }
    public void setRoomNumber(String v)       { this.roomNumber = v; }

    public String getTitle()                  { return title; }
    public void setTitle(String v)            { this.title = v; }

    public String getDescription()            { return description; }
    public void setDescription(String v)      { this.description = v; }

    public String getPriority()               { return priority; }
    public void setPriority(String v)         { this.priority = v; }

    public String getStatus()                 { return status; }
    public void setStatus(String v)           { this.status = v; }

    public Integer getAssignedStaffId()       { return assignedStaffId; }
    public void setAssignedStaffId(Integer v) { this.assignedStaffId = v; }

    public String getAssignedStaffName()      { return assignedStaffName; }
    public void setAssignedStaffName(String v){ this.assignedStaffName = v; }

    public Timestamp getCreatedAt()           { return createdAt; }
    public void setCreatedAt(Timestamp v)     { this.createdAt = v; }

    public Timestamp getCompletedAt()         { return completedAt; }
    public void setCompletedAt(Timestamp v)   { this.completedAt = v; }
}
