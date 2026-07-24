package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.MaintenanceRequestDAO;
import com.mycompany.hotelmanagement.dal.RoomIssueDAO;
import com.mycompany.hotelmanagement.dal.StaffDAO;
import com.mycompany.hotelmanagement.entity.MaintenanceRequest;
import com.mycompany.hotelmanagement.entity.RoomIssue;
import com.mycompany.hotelmanagement.entity.StaffInfo;

import java.util.List;

/**
 * Project: Hotel Management System
 * Class: RequestManagementService
 *
 * Description:
 * Tầng nghiệp vụ quản lý yêu cầu bảo trì (Maintenance) của khách hàng và
 * theo dõi công việc nhân viên Housekeeping. Cung cấp các phương thức lấy
 * danh sách Maintenance requests có lọc/phân trang, đếm tổng, tra cứu thông
 * tin nhân viên, lấy công việc theo nhân viên, gán nhân viên xử lý và cập
 * nhật trạng thái yêu cầu. Ủy quyền thao tác dữ liệu cho MaintenanceRequestDAO
 * và StaffDAO.
 *
 * Related Use Cases:
 * - UC-34 View Service Requests
 *
 * Date: 02-06-2026
 *
 * @author Pham Quoc Quy, KhanhTD
 * @version 1.1
 */
public class RequestManagementService {

    private final MaintenanceRequestDAO requestDAO = new MaintenanceRequestDAO();
    private final StaffDAO staffDAO = new StaffDAO();
    private final RoomIssueDAO roomIssueDAO = new RoomIssueDAO();

    /* ---------- Danh sách yêu cầu bảo trì: lọc + phân trang ---------- */
    public List<MaintenanceRequest> getRequests(String roomKw, String priority, String staffFilter,
                                             String status, int offset, int pageSize) {
        return requestDAO.getMaintenanceRequests(roomKw, priority, staffFilter, status, offset, pageSize);
    }

    public int countRequests(String roomKw, String priority, String staffFilter, String status) {
        return requestDAO.countMaintenanceRequests(roomKw, priority, staffFilter, status);
    }

    /* ---------- Trang chi tiết nhân viên ---------- */
    public StaffInfo getStaffById(int accountId) {
        return staffDAO.getStaffById(accountId);
    }

    public List<MaintenanceRequest> getRequestsByStaff(int staffId, int offset, int pageSize) {
        return requestDAO.getRequestsByStaff(staffId, offset, pageSize);
    }

    public int countRequestsByStaff(int staffId) {
        return requestDAO.countRequestsByStaff(staffId);
    }

    public List<MaintenanceRequest> getInProgressByStaff(int staffId) {
        return requestDAO.getInProgressByStaff(staffId);
    }

    public List<StaffInfo> getHousekeepingStaff() {
        return staffDAO.getHousekeepingStaff();
    }

    /** Số yêu cầu đang chờ (Pending + InProgress) — KPI cho Manager. */
    public int countPending() {
        return requestDAO.countPendingIncludingInProgress();
    }

    /** Số yêu cầu đang thực hiện — KPI cho Manager. */
    public int countInProgress() {
        return requestDAO.countByStatus("InProgress");
    }

    public int countActiveStaff() {
        return staffDAO.countActiveStaff();
    }

    public boolean assignRequest(int requestId, int staffId) {
        return requestDAO.assignRequest(requestId, staffId);
    }

    public boolean updateStatus(int requestId, String newStatus) {
        return requestDAO.updateStatus(requestId, newStatus);
    }

    public boolean updatePriority(int requestId, String priority) {
        return requestDAO.updatePriority(requestId, priority);
    }

    /** Báo cáo sự cố phòng do nhân viên gửi (bảng RoomIssue) — cho Manager xem. */
    public List<RoomIssue> getAllRoomIssues() {
        return roomIssueDAO.getAllForManager();
    }
}
