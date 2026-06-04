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

    public List<StaffInfo> getHousekeepingStaff() {
        return staffDAO.getHousekeepingStaff();
    }

    public int countPending() {
        return requestDAO.countByStatus("Pending");
    }

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
}
