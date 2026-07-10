package com.mycompany.hotelmanagement.controller.housekeeping;

import com.mycompany.hotelmanagement.dal.HousekeepingDAO;
import com.mycompany.hotelmanagement.dal.RoomIssueDAO;
import com.mycompany.hotelmanagement.entity.Room;
import com.mycompany.hotelmanagement.entity.RoomIssue;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 *
 * @author MinhTDP
 */
@WebServlet("/housekeeping/taskDetail")
public class HouseKeepingTaskDetailController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        int roomId = Integer.parseInt(
                request.getParameter("roomId")
        );

        HousekeepingDAO roomDAO
                = new HousekeepingDAO();

        RoomIssueDAO issueDAO
                = new RoomIssueDAO();

        // lấy thông tin phòng
        Room room
                = roomDAO.getRoomById(roomId);

        // lấy danh sách issue
        List<RoomIssue> issues
                = issueDAO.getIssuesByRoomId(roomId);
        request.setAttribute(
                "room",
                room
        );
        request.setAttribute(
                "issues",
                issues
        );

        request.getRequestDispatcher(
                "/WEB-INF/views/housekeeping/taskDetail.jsp"
        ).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        int issueId
                = Integer.parseInt(
                        request.getParameter("issueId")
                );

        int roomId
                = Integer.parseInt(
                        request.getParameter("roomId")
                );

        RoomIssueDAO issueDAO
                = new RoomIssueDAO();

        HousekeepingDAO roomDAO
                = new HousekeepingDAO();

        // 1. Pending -> Success
        boolean completed
                = issueDAO.completeIssue(issueId);

        if (completed) {
            roomDAO.refreshRoomStatusByPendingIssues(roomId);
        }

        response.sendRedirect(
                request.getContextPath()
                + "/housekeeping/taskDetail?roomId="
                + roomId
        );
    }
}
