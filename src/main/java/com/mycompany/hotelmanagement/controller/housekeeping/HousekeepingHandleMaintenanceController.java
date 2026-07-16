/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.hotelmanagement.controller.housekeeping;

import com.mycompany.hotelmanagement.dal.MaintenanceRequestDAO;
import com.mycompany.hotelmanagement.entity.MaintenanceRequest;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;

/**
 *
 * @author MinhTDP Created: 11/07/2026
 */
@WebServlet(name = "HousekeepingHandleMaintenanceController", urlPatterns = {"/housekeeping/handlemaintenance"})
public class HousekeepingHandleMaintenanceController extends HttpServlet {

    private final MaintenanceRequestDAO maintenanceDAO
            = new MaintenanceRequestDAO();

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet HousekeepingHandleMaintenanceController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet HousekeepingHandleMaintenanceController at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }

        switch (action) {

            case "detail":
                showDetail(request, response);
                break;

            default:
                showList(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/housekeeping/handlemaintenance");
            return;
        }

        switch (action) {

            case "start":
                startProcessing(request, response);
                break;

            case "resolve":
                resolveRequest(request, response);
                break;

            case "unresolvable":
                markUnresolvable(request, response);
                break;

            default:
                response.sendRedirect(
                        request.getContextPath()
                        + "/housekeeping/handlemaintenance");
                break;
        }
    }

    private void showList(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String status = request.getParameter("status");

        if (status == null || status.isBlank()) {
            status = "all";
        }

        List<MaintenanceRequest> list
                = maintenanceDAO.getMaintenanceRequests(status);

        request.setAttribute("maintenanceRequests", list);
        request.setAttribute("currentStatus", status);

        // Bộ đếm
        request.setAttribute("countAll",
                maintenanceDAO.countAll());

        request.setAttribute("countPending",
                maintenanceDAO.countByStatus("Pending"));

        request.setAttribute("countInProgress",
                maintenanceDAO.countByStatus("InProgress"));

        request.setAttribute("countResolved",
                maintenanceDAO.countByStatus("Resolved"));

        request.setAttribute("countUnresolvable",
                maintenanceDAO.countByStatus("Unresolvable"));
        
        request.setAttribute(
                "countCancelled",
                maintenanceDAO.countByStatus("Cancelled"));
        
        Integer accountId
                = (Integer) request.getSession().getAttribute("accountId");

        request.setAttribute("currentAccountId", accountId);

        request.getRequestDispatcher(
                "/WEB-INF/views/housekeeping/maintenance-request-list.jsp")
                .forward(request, response);
    }

    private void showDetail(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        int requestId = Integer.parseInt(request.getParameter("id"));

        MaintenanceRequestDAO dao = new MaintenanceRequestDAO();

        MaintenanceRequest maintenance
                = dao.getMaintenanceRequestById(requestId);

        if (maintenance == null) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/housekeeping/handlemaintenance?action=list");
            return;
        }

        request.setAttribute("maintenance", maintenance);

        request.getRequestDispatcher(
                "/WEB-INF/views/housekeeping/maintenance-request-handle.jsp")
                .forward(request, response);
    }

    private void startProcessing(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Integer staffId = (Integer) request.getSession().getAttribute("accountId");

        if (staffId == null) {
            response.sendRedirect(request.getContextPath() + "/home/login");
            return;
        }

        int requestId = Integer.parseInt(request.getParameter("requestId"));

        boolean success = maintenanceDAO.startProcessing(requestId, staffId);

        if (success) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/housekeeping/handlemaintenance?action=detail&id="
                    + requestId);

        } else {

            request.getSession().setAttribute(
                    "error",
                    "This request has already been processed.");

            response.sendRedirect(
                    request.getContextPath()
                    + "/housekeeping/handlemaintenance?action=detail&id="
                    + requestId);
        }
    }

    private void resolveRequest(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        int requestId = Integer.parseInt(
                request.getParameter("requestId"));

        String resolutionNote = request.getParameter("resolutionNote");

        boolean success = maintenanceDAO.resolveRequest(
                requestId,
                resolutionNote);

        if (success) {

            request.getSession().setAttribute(
                    "success",
                    "Maintenance request resolved successfully.");

        } else {

            request.getSession().setAttribute(
                    "error",
                    "Unable to resolve this maintenance request.");
        }

        response.sendRedirect(
                request.getContextPath()
                + "/housekeeping/handlemaintenance?action=detail&id="
                + requestId);
    }

    private void markUnresolvable(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        int requestId = Integer.parseInt(
                request.getParameter("requestId"));

        String resolutionNote = request.getParameter("resolutionNote");

        boolean success = maintenanceDAO.markUnresolvable(
                requestId,
                resolutionNote);

        if (success) {

            request.getSession().setAttribute(
                    "success",
                    "Maintenance request marked as unresolvable.");

        } else {

            request.getSession().setAttribute(
                    "error",
                    "Unable to update this maintenance request.");
        }

        response.sendRedirect(
                request.getContextPath()
                + "/housekeeping/handlemaintenance?action=detail&id="
                + requestId);
    }
}
