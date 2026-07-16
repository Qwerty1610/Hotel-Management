package com.mycompany.hotelmanagement.controller.receptionist;

import com.mycompany.hotelmanagement.dal.WalkInBookingDAO;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Date;
import java.util.List;

@WebServlet("/receptionist/available-room-types")
public class AvailableRoomTypeController extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        response.setContentType(
                "application/json;charset=UTF-8");

        try {

            Date checkIn =
                    Date.valueOf(
                            request.getParameter("checkInDate"));

            Date checkOut =
                    Date.valueOf(
                            request.getParameter("checkOutDate"));

            WalkInBookingDAO dao =
                    new WalkInBookingDAO();

            List<RoomTypeInfo> roomTypes =
                    dao.getAvailableRoomTypes(
                            checkIn,
                            checkOut);

            StringBuilder json =
                    new StringBuilder("[");

            for (int i = 0; i < roomTypes.size(); i++) {

                RoomTypeInfo rt =
                        roomTypes.get(i);

                if (i > 0) {
                    json.append(",");
                }

                json.append("{")
                        .append("\"typeId\":")
                        .append(rt.getTypeId())
                        .append(",")

                        .append("\"typeName\":\"")
                        .append(rt.getTypeName())
                        .append("\",")

                        .append("\"capacity\":")
                        .append(rt.getCapacity())
                        .append(",")

                        .append("\"basePrice\":")
                        .append(rt.getBasePrice())

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