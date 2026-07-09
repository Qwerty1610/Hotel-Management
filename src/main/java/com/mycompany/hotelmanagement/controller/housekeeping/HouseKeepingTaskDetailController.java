package com.mycompany.hotelmanagement.controller.housekeeping;

import com.mycompany.hotelmanagement.dal.HousekeepingDAO;
import com.mycompany.hotelmanagement.entity.Room;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/housekeeping/taskDetail")
public class HouseKeepingTaskDetailController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int roomId = Integer.parseInt(request.getParameter("roomId"));

        HousekeepingDAO dao = new HousekeepingDAO();
        Room room = dao.getRoomById(roomId);

        request.setAttribute("room", room);

        request.getRequestDispatcher("/WEB-INF/views/housekeeping/taskDetail.jsp")
                .forward(request, response);
    }
}
