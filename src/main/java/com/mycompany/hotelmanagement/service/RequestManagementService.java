package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.CustomerRequestDAO;
import com.mycompany.hotelmanagement.dal.StaffDAO;
import com.mycompany.hotelmanagement.entity.CustomerRequest;
import com.mycompany.hotelmanagement.entity.StaffInfo;

import java.util.List;

/**
 * RequestManagementService
 * Tầng nghiệp vụ cho trang "Quản lý yêu cầu khách hàng & theo dõi công việc nhân viên".
 *
 * Date: 02/6/2026
 * version 1.0
 * @author Pham Quoc Quy
 */
public class RequestManagementService {

    private final CustomerRequestDAO requestDAO = new CustomerRequestDAO();
    private final StaffDAO staffDAO = new StaffDAO();

    public List<CustomerRequest> getAllRequests() {
        return requestDAO.getAllRequests();
    }

    /* ---------- Danh sách yêu cầu Maintenance (booking_id IS NULL): lọc + phân trang ----------
     * Manager chỉ quản lý Maintenance requests (bảo trì phòng, giao Housekeeping).
     * Service requests (booking_id IS NOT NULL) do Receptionist xử lý riêng.
     */
    public List<CustomerRequest> getRequests(String roomKw, String priority, String staffFilter,
                                             String status, int offset, int pageSize) {
        return requestDAO.getMaintenanceRequests(roomKw, priority, staffFilter, status, offset, pageSize);
    }

    public int countRequests(String roomKw, String priority, String staffFilter, String status) {
        return requestDAO.countMaintenanceRequests(roomKw, priority, staffFilter, status);
    }

    /* ---------- Trang chi tiết nhân viên ---------- */
    public com.mycompany.hotelmanagement.entity.StaffInfo getStaffById(int accountId) {
        return staffDAO.getStaffById(accountId);
    }

    public List<CustomerRequest> getRequestsByStaff(int staffId, int offset, int pageSize) {
        return requestDAO.getRequestsByStaff(staffId, offset, pageSize);
    }

    public int countRequestsByStaff(int staffId) {
        return requestDAO.countRequestsByStaff(staffId);
    }

    public List<CustomerRequest> getInProgressByStaff(int staffId) {
        return requestDAO.getInProgressByStaff(staffId);
    }

    public List<StaffInfo> getHousekeepingStaff() {
        return staffDAO.getHousekeepingStaff();
    }

    /** Số Maintenance requests đang chờ (Pending + InProgress) — KPI cho Manager. */
    public int countPending() {
        return requestDAO.countMaintenanceByStatus("Pending");
    }

    /** Số Maintenance requests đang thực hiện — KPI cho Manager. */
    public int countInProgress() {
        return requestDAO.countMaintenanceByStatus("InProgress");
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
}
