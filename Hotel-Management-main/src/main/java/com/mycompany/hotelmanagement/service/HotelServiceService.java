package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.HotelServiceRepository;
import com.mycompany.hotelmanagement.entity.HotelService;
import java.util.List;

public class HotelServiceService {
    private final HotelServiceRepository hotelServiceRepository = new HotelServiceRepository();

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
