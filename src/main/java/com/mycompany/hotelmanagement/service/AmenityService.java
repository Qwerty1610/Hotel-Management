package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.AmenityDAO;
import com.mycompany.hotelmanagement.entity.AmenityInfo;
import java.util.List;

public class AmenityService {

    private final AmenityDAO amenityDAO;

    public AmenityService() {
        this.amenityDAO = new AmenityDAO();
    }

    public List<AmenityInfo> getAllAmenities() {
        return amenityDAO.getAllAmenities(false);
    }

    public List<AmenityInfo> getActiveAmenities() {
        return amenityDAO.getAllAmenities(true);
    }

    public void addAmenity(AmenityInfo amenity) {
        amenityDAO.insertAmenity(amenity);
    }

    public void updateAmenity(AmenityInfo amenity) {
        amenityDAO.updateAmenity(amenity);
    }

    public void toggleAmenityStatus(int amenityId, boolean isActive) {
        amenityDAO.toggleAmenityStatus(amenityId, isActive);
    }

    public List<Integer> getAssignedRoomTypeIds(int amenityId) {
        return amenityDAO.getAssignedRoomTypeIds(amenityId);
    }

    public void assignToRoomTypes(int amenityId, List<Integer> roomTypeIds) {
        amenityDAO.assignToRoomTypes(amenityId, roomTypeIds);
    }

    public void deleteAmenity(int amenityId) {
        amenityDAO.deleteAmenity(amenityId);
    }
}
