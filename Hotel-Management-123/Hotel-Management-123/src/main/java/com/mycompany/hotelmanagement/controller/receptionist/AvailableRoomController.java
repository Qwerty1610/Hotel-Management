package com.mycompany.hotelmanagement.controller.receptionist;

import com.mycompany.hotelmanagement.dal.WalkInBookingDAO;
import com.mycompany.hotelmanagement.entity.Room;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Date;
import java.util.List;

@WebServlet("/receptionist/available-rooms")
public class AvailableRoomController extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        response.setContentType(
                "application/json;charset=UTF-8");

        try {

            int typeId =
                    Integer.parseInt(
                            request.getParameter("typeId"));

            Date checkIn =
                    Date.valueOf(
                            request.getParameter("checkInDate"));

            Date checkOut =
                    Date.valueOf(
                            request.getParameter("checkOutDate"));

            WalkInBookingDAO dao =
                    new WalkInBookingDAO();

            List<Room> rooms =
                    dao.getAvailableRoomsByType(
                            typeId,
                            checkIn,
                            checkOut);

            StringBuilder json =
                    new StringBuilder("[");

            for (int i = 0; i < rooms.size(); i++) {

                Room room = rooms.get(i);

                if (i > 0) {
                    json.append(",");
                }

                json.append("{")
                        .append("\"roomId\":")
                        .append(room.getRoomId())
                        .append(",")

                        .append("\"roomNumber\":\"")
                        .append(room.getRoomNumber())
                        .append("\",")

                        .append("\"typeName\":\"")
                        .append(room.getTypeName())
                        .append("\"")

                        .append("}");
            }

            json.append("]");

            response.getWriter()
                    .write(json.toString());

        } catch (Exception ex) {

            ex.printStackTrace();

            response.getWriter()
                    .write("[]");
        }
    }
}