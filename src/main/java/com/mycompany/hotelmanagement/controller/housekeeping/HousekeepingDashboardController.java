package com.mycompany.hotelmanagement.controller.housekeeping;

import com.mycompany.hotelmanagement.dal.HousekeepingDAO;
import com.mycompany.hotelmanagement.dal.CustomerRequestDAO;
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
        CustomerRequestDAO requestDAO = new CustomerRequestDAO();

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
                    "customerRequests",
                    requestDAO.getRequestsByStaff(
                            staffId,
                            0,
                            100
                    )
            );
        } else {
            request.setAttribute(
                    "customerRequests",
                    new ArrayList<>()
            );
        }
        // Authorized, forward to Housekeeping Dashboard view
        request.getRequestDispatcher("/WEB-INF/views/dashboard/housekeeping.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if ("completeRequest".equals(action)) {
            HttpSession session = request.getSession(false);
            Integer staffId
                    = (Integer) session.getAttribute("accountId");
            String requestIdRaw
                    = request.getParameter("requestId");
            if (staffId != null && requestIdRaw != null) {
                int requestId
                        = Integer.parseInt(requestIdRaw);
                HousekeepingDAO dao
                        = new HousekeepingDAO();
                dao.requestCompleteCustomerRequest(
                        requestId,
                        staffId
                );
            }
            response.sendRedirect(
                    request.getContextPath()
                    + "/housekeeping/dashboard?tab=overview"
            );
            return;
        }
        doGet(request, response);
    }
}
