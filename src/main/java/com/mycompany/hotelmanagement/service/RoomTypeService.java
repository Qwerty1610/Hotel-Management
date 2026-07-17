package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.dal.RoomTypeRepository;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import com.mycompany.hotelmanagement.entity.AmenityInfo;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Project: Hotel Management System
 * Class: RoomTypeService
 *
 * Description:
 * Tầng nghiệp vụ quản lý thông tin loại phòng. Cung cấp các phương thức
 * lấy danh sách toàn bộ loại phòng kèm hình ảnh và tiện nghi, lọc loại
 * phòng theo tên/sức chứa/khoảng giá, lấy chi tiết một loại phòng kèm
 * số phòng trống, lưu (thêm hoặc cập nhật) và xóa loại phòng. Phối hợp
 * nhiều truy vấn từ RoomTypeRepository trong một transaction khi lưu.
 *
 * Related Use Cases:
 * - UC-03 Search Available Rooms
 * - UC-29 Browse Available Room Types
 * - UC-30 View Room Type Detail
 * - UC-53 View Room Type Records
 * - UC-54 Add Room Type
 * - UC-55 Edit Room Type
 *
 * Date: 01-06-2026
 *
 * @author KhanhTD
 * @version 1.0
 */
public class RoomTypeService {
    private final RoomTypeRepository roomTypeRepository = new RoomTypeRepository();

    /**
     * UC-30: View Room Types
     * Lấy toàn bộ danh sách loại phòng từ cơ sở dữ liệu kèm theo hình ảnh đầu tiên và danh sách tiện nghi.
     *
     * @return danh sách đối tượng RoomTypeInfo đầy đủ thông tin
     */
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

    /**
     * UC-03: Search Available Rooms
     * Lọc danh sách các loại phòng theo tên loại phòng, số lượng khách tối đa và khoảng giá.
     *
     * @param typeFilter tên loại phòng cần tìm kiếm (chấp nhận tìm gần đúng)
     * @param guestsFilter số lượng khách tối thiểu phòng phải đáp ứng
     * @param minPriceFilter mức giá thuê tối thiểu
     * @param maxPriceFilter mức giá thuê tối đa
     * @return danh sách loại phòng thỏa mãn các tiêu chí lọc
     */
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

    /**
     * UC-31: View Room Type Detail
     * Lấy thông tin chi tiết của một loại phòng cụ thể, bao gồm toàn bộ danh sách hình ảnh, tiện nghi chi tiết và số phòng hiện tại còn trống.
     *
     * @param typeId ID loại phòng cần lấy thông tin chi tiết
     * @return thông tin chi tiết của loại phòng hoặc null nếu không tồn tại
     */
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

    public void saveRoomType(RoomTypeInfo rt, String imageUrl) {
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
