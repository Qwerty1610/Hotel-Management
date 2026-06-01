package com.mycompany.hotelmanagement.controller.housekeeping;

import com.mycompany.hotelmanagement.dal.HousekeepingDAO;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/housekeeping/task")
public class HouseKeepingTaskController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        int roomId = Integer.parseInt(request.getParameter("roomId"));

        HousekeepingDAO dao = new HousekeepingDAO();

        dao.completeCleaning(roomId);

        response.sendRedirect(
            request.getContextPath()
            + "/housekeeping/taskDetail?roomId=" + roomId
        );
    }
}