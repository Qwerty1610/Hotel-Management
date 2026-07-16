package com.mycompany.hotelmanagement.controller.receptionist;

import com.mycompany.hotelmanagement.dal.CustomerRequestDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * ReceptionistRequestController
 * URL: /receptionist/servicerequest
 *
 * Xử lý duyệt hoặc hủy yêu cầu dịch vụ của khách hàng từ phía lễ tân.
 * Hành động (action param):
 * - approve : Duyệt hoàn thành yêu cầu (status -> Completed, gán Lễ tân duyệt làm staff)
 * - cancel  : Hủy yêu cầu (status -> Cancelled)
 *
 * Date: 21/6/2026
 * @author DINH KHANH
 */
@WebServlet(name = "ReceptionistRequestController", urlPatterns = { "/receptionist/servicerequest" })
public class ReceptionistRequestController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ReceptionistRequestController.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra xác thực & quyền hạn
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"RECEPTIONIST".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login?error=unauthorized");
            return;
        }

        String action = request.getParameter("action");
        String requestIdStr = request.getParameter("requestId");

        try {
            if (action == null || requestIdStr == null || requestIdStr.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=servicerequests&error=invalid");
                return;
            }

            int requestId;
            try {
                requestId = Integer.parseInt(requestIdStr.trim());
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=servicerequests&error=invalid");
                return;
            }

            CustomerRequestDAO dao = new CustomerRequestDAO();
            boolean success = false;
            Integer receptionistId = (Integer) session.getAttribute("accountId");
            if (receptionistId == null) {
                response.sendRedirect(request.getContextPath() + "/home/login?error=unauthorized");
                return;
            }

            switch (action.toLowerCase()) {
                case "approve":
                    // Duyệt yêu cầu dịch vụ, cập nhật trạng thái Completed, tự động gán nhân viên duyệt
                    success = dao.updateStatusByReceptionist(requestId, "Completed", receptionistId);
                    break;

                case "cancel":
                    // Hủy yêu cầu dịch vụ
                    success = dao.updateStatus(requestId, "Cancelled");
                    break;

                default:
                    LOGGER.log(Level.WARNING, "Unknown action received: " + action);
                    response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=servicerequests&error=invalid");
                    return;
            }

            String result = success ? "success" : "fail";
            response.sendRedirect(request.getContextPath() 
                    + "/receptionist/dashboard?tab=servicerequests&result=" + result 
                    + "&action=" + action);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in ReceptionistRequestController doPost", e);
            response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=servicerequests&error=unknown");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=servicerequests");
    }
}
