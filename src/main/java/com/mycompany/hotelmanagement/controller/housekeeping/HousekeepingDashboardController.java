package com.mycompany.hotelmanagement.controller.housekeeping;

import com.mycompany.hotelmanagement.dal.HousekeepingDAO;
import com.mycompany.hotelmanagement.dal.MaintenanceRequestDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.ArrayList;

@WebServlet(name = "HousekeepingDashboardController", urlPatterns = {"/housekeeping/dashboard"})
public class HousekeepingDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null || !"HOUSEKEEPING".equals(session.getAttribute("role"))) {
            // Unauthorized or wrong role, redirect back to login page with unauthorized error
            response.sendRedirect(request.getContextPath() + "/staff/login?error=unauthorized");
            return;
        }
        HousekeepingDAO dao = new HousekeepingDAO();
        MaintenanceRequestDAO requestDAO = new MaintenanceRequestDAO();

        request.setAttribute("cleaningRooms",
                dao.getCleaningRooms());

        request.setAttribute("maintenanceRooms",
                dao.getMaintenanceRooms());

        request.setAttribute("cleaningCount",
                dao.countCleaningRooms());

        request.setAttribute("maintenanceCount",
                dao.countMaintenanceRooms());

        request.setAttribute("availableCount",
                dao.countAvailableRooms());

        request.setAttribute("outOfServiceCount",
                dao.countOutOfServiceRooms());

        request.setAttribute("roomList",
                dao.getAllRooms());

        Integer staffId = (Integer) session.getAttribute("accountId");
        if (staffId != null) {
            request.setAttribute(
                    "assignedRequests",
                    requestDAO.getRequestsByStaff(
                            staffId,
                            0,
                            5
                    )
            );
        } else {
            request.setAttribute(
                    "assignedRequests",
                    new ArrayList<>()
            );
        }
        // Authorized, forward to Housekeeping Dashboard view
        request.getRequestDispatcher("/WEB-INF/views/dashboard/housekeeping.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        doGet(request, response);
    }
}
