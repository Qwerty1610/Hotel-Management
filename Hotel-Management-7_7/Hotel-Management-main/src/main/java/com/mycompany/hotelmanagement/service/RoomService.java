package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.RoomRepository;
import com.mycompany.hotelmanagement.entity.Room;
import com.mycompany.hotelmanagement.entity.RoomInfo;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class RoomService {

    private final RoomRepository roomRepository = new RoomRepository();

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
