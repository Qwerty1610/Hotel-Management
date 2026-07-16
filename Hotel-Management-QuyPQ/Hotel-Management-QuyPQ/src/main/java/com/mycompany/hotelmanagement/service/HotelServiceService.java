package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.HotelServiceRepository;
import com.mycompany.hotelmanagement.entity.HotelService;
import java.util.List;

/**
 * HotelServiceService
 * Tầng nghiệp vụ (Service) quản lý thông tin các dịch vụ khách sạn.
 *
 * Date: 01/6/2026
 * @author DINH KHANH
 */
public class HotelServiceService {
    private final HotelServiceRepository hotelServiceRepository = new HotelServiceRepository();

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
