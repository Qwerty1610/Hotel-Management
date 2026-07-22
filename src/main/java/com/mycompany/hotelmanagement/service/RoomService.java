package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.RoomDAO;
import com.mycompany.hotelmanagement.entity.Room;
import com.mycompany.hotelmanagement.entity.RoomInfo;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Project: Hotel Management System
 * Class: RoomService
 *
 * Description:
 * Tầng nghiệp vụ quản lý phòng khách sạn. Cung cấp các phương thức lấy
 * danh sách phòng, xóa phòng, cập nhật trạng thái phòng và lưu phòng (thêm
 * mới hoặc cập nhật). Khi thêm mới, kiểm tra trùng số phòng và tự động khôi
 * phục phòng bị xóa mềm nếu trùng số. Ủy quyền thao tác dữ liệu cho
 * RoomDAO.
 *
 * Related Use Cases:
 * - UC-56 View Room List
 * - UC-57 Add Room
 * - UC-58 Edit Room
 *
 * Date: 01-06-2026
 *
 * @author KhanhTD
 * @version 1.0
 */
public class RoomService {

    private final RoomDAO roomRepository = new RoomDAO();

    private static final Set<String> ALLOWED_OPERATIONAL_STATUSES = Set.of(
            "Available", "Cleaning", "Maintenance", "OutOfService"
    );

    public List<RoomInfo> getAllRooms() {
        return getRoomsByDate(LocalDate.now());
    }

    public List<RoomInfo> getRoomsByDateRange(LocalDate fromDate, LocalDate toDate) {
        if (fromDate == null) {
            fromDate = LocalDate.now();
        }
        if (toDate == null || !toDate.isAfter(fromDate)) {
            toDate = fromDate.plusDays(1);
        }
        return roomRepository.getRoomsByDateRange(java.sql.Date.valueOf(fromDate), java.sql.Date.valueOf(toDate));
    }

    public List<RoomInfo> getRoomsByDate(LocalDate date) {
        if (date == null) {
            date = LocalDate.now();
        }
        return getRoomsByDateRange(date, date.plusDays(1));
    }

    public List<RoomInfo> getRoomsByDate(String dateStr) {
        LocalDate date;
        try {
            if (dateStr != null && !dateStr.trim().isEmpty()) {
                date = LocalDate.parse(dateStr.trim());
            } else {
                date = LocalDate.now();
            }
        } catch (DateTimeParseException e) {
            date = LocalDate.now();
        }
        return getRoomsByDate(date);
    }

    public boolean deleteRoom(int roomId) {
        return roomRepository.deleteRoom(roomId);
    }

    public String updateRoomStatus(int roomId, String status) {
        if (status == null || !ALLOWED_OPERATIONAL_STATUSES.contains(status.trim())) {
            return "invalidStatus";
        }
        status = status.trim();

        if (roomRepository.isRoomCurrentlyOccupied(roomId)) {
            String currentStatus = roomRepository.getRoomOperationalStatus(roomId);
            if (currentStatus == null || !status.equalsIgnoreCase(currentStatus)) {
                return "roomCurrentlyOccupied";
            }
        }

        roomRepository.updateRoomStatus(roomId, status);
        return "success";
    }

    public String saveRoom(RoomInfo room) {
        String num = room.getRoomNumber();
        int id = room.getRoomId();
        String requestedStatus = room.getOperationalStatus() != null ? room.getOperationalStatus().trim() : (room.getStatus() != null ? room.getStatus().trim() : "");

        if (!ALLOWED_OPERATIONAL_STATUSES.contains(requestedStatus)) {
            return "invalidStatus";
        }

        if (id <= 0) {
            // Check active duplicates
            if (roomRepository.isRoomNumberDuplicate(num, 0)) {
                return "duplicateNumber";
            }
            // Check soft-deleted duplicates
            RoomInfo softDeleted = roomRepository.getSoftDeletedRoomByNumber(num);
            if (softDeleted != null) {
                // Restore and update attributes
                boolean ok = roomRepository.restoreRoom(softDeleted.getRoomId(), room);
                return ok ? "success" : "error";
            }
            // Normal insert
            boolean ok = roomRepository.insertRoom(room);
            return ok ? "success" : "error";
        } else {
            // Check if currently occupied
            if (roomRepository.isRoomCurrentlyOccupied(id)) {
                String currentDbStatus = roomRepository.getRoomOperationalStatus(id);
                if (currentDbStatus != null && !currentDbStatus.equalsIgnoreCase(requestedStatus)) {
                    return "roomCurrentlyOccupied";
                }
                if (currentDbStatus != null) {
                    room.setStatus(currentDbStatus);
                    room.setOperationalStatus(currentDbStatus);
                }
            }

            // Check active duplicates excluding self
            if (roomRepository.isRoomNumberDuplicate(num, id)) {
                return "duplicateNumber";
            }
            // Check if there is another room with this number that is soft-deleted
            RoomInfo softDeleted = roomRepository.getSoftDeletedRoomByNumber(num);
            if (softDeleted != null && softDeleted.getRoomId() != id) {
                return "duplicateNumber";
            }
            // Normal update
            boolean ok = roomRepository.updateRoom(room);
            return ok ? "success" : "error";
        }
    }
}
