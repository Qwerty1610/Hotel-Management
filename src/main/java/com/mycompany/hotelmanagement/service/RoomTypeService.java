package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.dal.RoomTypeRepository;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import com.mycompany.hotelmanagement.entity.AmenityInfo;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class RoomTypeService {
    private final RoomTypeRepository roomTypeRepository = new RoomTypeRepository();

    public List<RoomTypeInfo> getAllRoomTypes() {
        List<RoomTypeInfo> allRoomTypes = roomTypeRepository.getAllRoomTypes();
        Map<Integer, List<String>> typeImages = roomTypeRepository.getAllRoomImages();
        Map<Integer, List<String>> typeAmenities = roomTypeRepository.getAllRoomAmenities();

        for (RoomTypeInfo info : allRoomTypes) {
            int tId = info.getTypeId();

            List<String> images = typeImages.get(tId);
            if (images != null && !images.isEmpty()) {
                info.setImageUrl(images.get(0));
                info.setImageUrls(images);
            } else {
                info.setImageUrl("https://images.unsplash.com/photo-1618773928121-c32242e63f39?q=80&w=600");
                info.setImageUrls(new ArrayList<>());
            }

            // Attach amenities
            List<String> amenities = typeAmenities.get(tId);
            if (amenities != null) {
                info.setAmenities(amenities);
            } else {
                info.setAmenities(new ArrayList<>());
            }
        }
        return allRoomTypes;
    }

    public List<RoomTypeInfo> getFilteredRoomTypes(String typeFilter, int guestsFilter, double minPriceFilter,
            double maxPriceFilter) {
        List<RoomTypeInfo> allRoomTypes = getAllRoomTypes();
        List<RoomTypeInfo> filteredRoomTypes = new ArrayList<>();

        for (RoomTypeInfo room : allRoomTypes) {
            // Filter by Room Type Name (contains)
            if (typeFilter != null && !typeFilter.trim().isEmpty() && !"all".equalsIgnoreCase(typeFilter)) {
                String roomName = room.getTypeName().toLowerCase();
                String filterVal = typeFilter.toLowerCase().trim();
                if (!roomName.contains(filterVal)) {
                    continue;
                }
            }

            // Filter by Capacity (Guests)
            if (guestsFilter != -1 && room.getCapacity() < guestsFilter) {
                continue;
            }

            // Filter by Price range
            double finalPrice = room.getBasePrice();
            if (finalPrice < minPriceFilter || finalPrice > maxPriceFilter) {
                continue;
            }

            filteredRoomTypes.add(room);
        }
        return filteredRoomTypes;
    }

    public RoomTypeInfo getRoomTypeDetail(int typeId) {
        RoomTypeInfo roomDetail = roomTypeRepository.getRoomTypeById(typeId);
        if (roomDetail != null) {
            // Fetch images
            List<String> imageUrls = roomTypeRepository.getRoomImagesByTypeId(typeId);
            if (imageUrls.isEmpty()) {
                if (typeId == 1) {
                    imageUrls.add("https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80");
                } else if (typeId == 2 || typeId == 6) {
                    imageUrls.add("https://images.unsplash.com/photo-1618773928121-c32242e63f39?q=80&w=600");
                } else if (typeId == 3) {
                    imageUrls.add("https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80");
                } else {
                    imageUrls.add("https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80");
                }
            }
            roomDetail.setImageUrls(imageUrls);
            roomDetail.setImageUrl(imageUrls.get(0));

            // Fetch amenities
            List<AmenityInfo> amenityDetails = roomTypeRepository.getAmenityDetailsByTypeId(typeId);
            List<String> amenityNames = new ArrayList<>();
            for (AmenityInfo am : amenityDetails) {
                amenityNames.add(am.getName());
            }
            roomDetail.setAmenities(amenityNames);
            roomDetail.setAmenityDetails(amenityDetails);

            // Fetch available count
            int availableCount = roomTypeRepository.getAvailableRoomCount(typeId);
            roomDetail.setAvailableCount(availableCount);
        }
        return roomDetail;
    }

    public void saveRoomType(RoomTypeInfo rt, String imageUrl, String[] amenities) {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int typeId = rt.getTypeId();
                if (typeId <= 0) {
                    typeId = roomTypeRepository.insertRoomType(rt, conn);
                } else {
                    roomTypeRepository.updateRoomType(rt, conn);
                }

                if (typeId != -1) {
                    // Save images
                    roomTypeRepository.deleteRoomImages(typeId, conn);
                    if (imageUrl != null && !imageUrl.isEmpty()) {
                        roomTypeRepository.insertRoomImage(typeId, imageUrl, conn);
                    }

                    // Save amenities
                    roomTypeRepository.deleteRoomAmenities(typeId, conn);
                    if (amenities != null && amenities.length > 0) {
                        for (String amName : amenities) {
                            int amenityId = roomTypeRepository.getAmenityIdByName(amName, conn);

                            // If amenity doesn't exist, insert it
                            if (amenityId == -1) {
                                String iconUrl = "fa-wifi"; // Default icon mapping
                                if (amName.contains("Điều hòa"))
                                    iconUrl = "fa-snowflake";
                                else if (amName.contains("Tivi"))
                                    iconUrl = "fa-tv";
                                else if (amName.contains("View"))
                                    iconUrl = "fa-city";
                                else if (amName.contains("bar"))
                                    iconUrl = "fa-glass";
                                else if (amName.contains("tắm"))
                                    iconUrl = "fa-bath";
                                else if (amName.contains("công"))
                                    iconUrl = "fa-door-open";
                                else if (amName.contains("cà phê"))
                                    iconUrl = "fa-mug-hot";

                                amenityId = roomTypeRepository.insertAmenity(amName, iconUrl, conn);
                            }

                            if (amenityId != -1) {
                                roomTypeRepository.insertRoomTypeAmenityMapping(typeId, amenityId, conn);
                            }
                        }
                    }
                }
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void deleteRoomType(int typeId) {
        roomTypeRepository.deleteRoomType(typeId);
    }
}
