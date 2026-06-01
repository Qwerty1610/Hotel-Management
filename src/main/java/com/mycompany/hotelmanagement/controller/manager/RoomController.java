package com.mycompany.hotelmanagement.controller.manager;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.mycompany.hotelmanagement.config.DBContext;

@WebServlet(name = "RoomController", urlPatterns = {"/manager/rooms"})
public class RoomController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Authorization check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null || !"HOTEL_MANAGER".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login?error=unauthorized");
            return;
        }

        String action = request.getParameter("action");
        String idParam = request.getParameter("id");
        int roomId = -1;
        try {
            if (idParam != null) {
                roomId = Integer.parseInt(idParam.trim());
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/manager/dashboard?tab=rooms");
            return;
        }

        // 2. Perform DB operations based on GET action
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try {
                    conn.createStatement().execute("USE HotelManagementDB");
                } catch (SQLException e) {
                    // Ignore
                }

                if ("delete".equalsIgnoreCase(action) && roomId != -1) {
                    String deleteSql = "DELETE FROM Room WHERE room_id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                        ps.setInt(1, roomId);
                        ps.executeUpdate();
                    }
                } else if ("updateStatus".equalsIgnoreCase(action) && roomId != -1) {
                    String status = request.getParameter("status");
                    if (status != null && !status.trim().isEmpty()) {
                        String updateSql = "UPDATE Room SET status = ? WHERE room_id = ?";
                        try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                            ps.setString(1, status.trim());
                            ps.setInt(2, roomId);
                            ps.executeUpdate();
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/manager/dashboard?tab=rooms");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Authorization check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null || !"HOTEL_MANAGER".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login?error=unauthorized");
            return;
        }

        String action = request.getParameter("action");
        if ("save".equalsIgnoreCase(action)) {
            String roomIdParam = request.getParameter("roomId");
            String roomNumber = request.getParameter("roomNumber");
            String floor = request.getParameter("floor");
            String typeIdParam = request.getParameter("typeId");
            String status = request.getParameter("status");

            if (roomNumber != null) roomNumber = roomNumber.trim();
            if (floor != null) floor = floor.trim();
            if (status != null) status = status.trim();

            int typeId = -1;
            try {
                if (typeIdParam != null) {
                    typeId = Integer.parseInt(typeIdParam.trim());
                }
            } catch (NumberFormatException e) {
                // keep -1
            }

            try (Connection conn = DBContext.getConnection()) {
                if (conn != null) {
                    try {
                        conn.createStatement().execute("USE HotelManagementDB");
                    } catch (SQLException e) {
                        // Ignore
                    }

                    if (roomIdParam == null || roomIdParam.trim().isEmpty()) {
                        // Insert new room
                        String insertSql = "INSERT INTO Room (room_number, floor, type_id, status) VALUES (?, ?, ?, ?)";
                        try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                            ps.setString(1, roomNumber);
                            ps.setString(2, floor);
                            ps.setInt(3, typeId);
                            ps.setString(4, status);
                            ps.executeUpdate();
                        }
                    } else {
                        // Update existing room
                        int roomId = Integer.parseInt(roomIdParam.trim());
                        String updateSql = "UPDATE Room SET room_number = ?, floor = ?, type_id = ?, status = ? WHERE room_id = ?";
                        try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                            ps.setString(1, roomNumber);
                            ps.setString(2, floor);
                            ps.setInt(3, typeId);
                            ps.setString(4, status);
                            ps.setInt(5, roomId);
                            ps.executeUpdate();
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect(request.getContextPath() + "/manager/dashboard?tab=rooms");
    }
}
