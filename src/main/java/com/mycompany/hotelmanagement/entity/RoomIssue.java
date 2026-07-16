/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.hotelmanagement.entity;

/**
 *
 * @author MinhTDP
 * Created: 10/07/2026
 */
public class RoomIssue {
    private int issueId;
    private int roomId;
    private String issueType;
    private String severity;
    private String description;
    private String note;
    private String status;
    private Integer reportedBy;

    public RoomIssue(int issueId, int roomId, String issueType, String severity, String description, String note, String status, Integer reportedBy) {
        this.issueId = issueId;
        this.roomId = roomId;
        this.issueType = issueType;
        this.severity = severity;
        this.description = description;
        this.note = note;
        this.status = status;
        this.reportedBy = reportedBy;
    }

    public RoomIssue() {
    }

    public int getIssueId() {
        return issueId;
    }

    public void setIssueId(int issueId) {
        this.issueId = issueId;
    }

    public int getRoomId() {
        return roomId;
    }

    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }

    public String getIssueType() {
        return issueType;
    }

    public void setIssueType(String issueType) {
        this.issueType = issueType;
    }

    public String getSeverity() {
        return severity;
    }

    public void setSeverity(String severity) {
        this.severity = severity;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getReportedBy() {
        return reportedBy;
    }

    public void setReportedBy(Integer reportedBy) {
        this.reportedBy = reportedBy;
    }
    
}
