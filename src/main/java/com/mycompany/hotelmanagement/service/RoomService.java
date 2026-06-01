package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.RoomRepository;
import com.mycompany.hotelmanagement.entity.RoomInfo;
import java.util.List;

public class RoomService {
    private final RoomRepository roomRepository = new RoomRepository();

    public List<RoomInfo> getAllRooms() {
        return roomRepository.getAllRooms();
    }

    public void deleteRoom(int roomId) {
        roomRepository.deleteRoom(roomId);
    }

    public void updateRoomStatus(int roomId, String status) {
        roomRepository.updateRoomStatus(roomId, status);
    }

    public void saveRoom(RoomInfo room) {
        if (room.getRoomId() <= 0) {
            roomRepository.insertRoom(room);
        } else {
            roomRepository.updateRoom(room);
        }
    }
}
