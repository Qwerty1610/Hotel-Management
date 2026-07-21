package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.RoomDAO;
import com.mycompany.hotelmanagement.entity.Room;
import com.mycompany.hotelmanagement.entity.RoomInfo;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

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

    public List<RoomInfo> getAllRooms() {
        return roomRepository.getAllRooms();
    }

    public boolean deleteRoom(int roomId) {
        return roomRepository.deleteRoom(roomId);
    }

    public void updateRoomStatus(int roomId, String status) {
        roomRepository.updateRoomStatus(roomId, status);
    }

    public String saveRoom(RoomInfo room) {
        String num = room.getRoomNumber();
        int id = room.getRoomId();

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

    public Map<String, List<Room>> groupByFloor(List<Room> rooms) {

        Map<String, List<Room>> map = new LinkedHashMap<>();

        for (Room r : rooms) {

            map.computeIfAbsent(r.getFloor(), k -> new ArrayList<>())
                    .add(r);
        }

        return map;
    }
}
