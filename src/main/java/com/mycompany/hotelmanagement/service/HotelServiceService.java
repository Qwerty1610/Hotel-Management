package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.HotelServiceDAO;
import com.mycompany.hotelmanagement.entity.HotelService;
import java.util.List;

/**
 * Project: Hotel Management System
 * Class: HotelServiceService
 *
 * Description:
 * Tầng nghiệp vụ quản lý dịch vụ khách sạn. Cung cấp các phương thức lấy
 * toàn bộ danh sách dịch vụ, xóa dịch vụ, bật/tắt trạng thái hoạt động và
 * lưu dịch vụ (thêm mới nếu serviceId <= 0, cập nhật nếu > 0). Ủy quyền
 * thao tác dữ liệu cho HotelServiceDAO.
 *
 * Related Use Cases:
 * - UC-08 View Available Services
 * - UC-09 Submit Service Request
 * - UC-59 View Service Records
 * - UC-60 Add Service
 * - UC-61 Edit Service
 * - UC-62 View Service Request History
 *
 * Date: 01-06-2026
 *
 * @author KhanhTD
 * @version 1.0
 */
public class HotelServiceService {
    private final HotelServiceDAO hotelServiceRepository = new HotelServiceDAO();

    /**
     * UC-09: View Available Service
     * Lấy toàn bộ danh sách dịch vụ của khách sạn từ cơ sở dữ liệu.
     *
     * @return danh sách đối tượng HotelService
     */
    public List<HotelService> getAllServices() {
        return hotelServiceRepository.getAllServices();
    }

    public void deleteService(int serviceId) {
        hotelServiceRepository.deleteService(serviceId);
    }

    public void toggleServiceStatus(int serviceId, boolean isActive) {
        hotelServiceRepository.toggleServiceStatus(serviceId, isActive);
    }

    public void saveService(HotelService service) {
        if (service.getServiceId() <= 0) {
            hotelServiceRepository.insertService(service);
        } else {
            hotelServiceRepository.updateService(service);
        }
    }
}
