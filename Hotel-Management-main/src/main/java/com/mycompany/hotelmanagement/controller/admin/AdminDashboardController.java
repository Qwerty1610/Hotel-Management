package com.mycompany.hotelmanagement.controller.admin;

import com.mycompany.hotelmanagement.entity.Account;
import com.mycompany.hotelmanagement.entity.CustomerInfo;
import com.mycompany.hotelmanagement.entity.Role;
import com.mycompany.hotelmanagement.service.AdminService;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Controller xử lý Dashboard quản trị của Admin.
 * Quản lý tài khoản nhân viên và khách hàng.
 * 
 * @author TungNQ
 */
@WebServlet(name = "AdminDashboardController", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardController extends HttpServlet {

    private final AdminService adminService = new AdminService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String tab = request.getParameter("tab");
        if (tab == null || tab.isEmpty()) {
            tab = "staff";
        }
        
        if ("staff".equals(tab)) {
            List<Account> staffList = adminService.getStaffAccounts();
            List<Role> roles = adminService.getStaffRoles();
            request.setAttribute("staffList", staffList);
            request.setAttribute("roles", roles);
        } else if ("customers".equals(tab)) {
            List<CustomerInfo> customerList = adminService.getCustomerAccounts();
            request.setAttribute("customerList", customerList);
        }
        
        request.setAttribute("currentTab", tab);
        request.getRequestDispatcher("/WEB-INF/views/dashboard/admin.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null || action.isEmpty()) {
            doGet(request, response);
            return;
        }
        
        try {
            if ("create-staff".equals(action)) {
                String email = request.getParameter("email");
                String fullName = request.getParameter("fullName");
                String phone = request.getParameter("phone");
                String password = request.getParameter("password");
                int roleId = Integer.parseInt(request.getParameter("roleId"));
                
                String result = adminService.createStaffAccount(email, fullName, phone, password, roleId);
                
                if ("success".equals(result)) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard?tab=staff&success=created");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard?tab=staff&error=" + result);
                }
                
            } else if ("update-staff".equals(action)) {
                int accountId = Integer.parseInt(request.getParameter("accountId"));
                String email = request.getParameter("email");
                String fullName = request.getParameter("fullName");
                String phone = request.getParameter("phone");
                String password = request.getParameter("password");
                int roleId = Integer.parseInt(request.getParameter("roleId"));
                
                String result = adminService.updateStaffAccount(accountId, email, fullName, phone, password, roleId);
                
                if ("success".equals(result)) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard?tab=staff&success=updated");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard?tab=staff&error=" + result);
                }
                
            } else if ("update-customer".equals(action)) {
                int accountId = Integer.parseInt(request.getParameter("accountId"));
                String email = request.getParameter("email");
                String fullName = request.getParameter("fullName");
                String phone = request.getParameter("phone");
                String password = request.getParameter("password");
                int loyaltyPoints = Integer.parseInt(request.getParameter("loyaltyPoints"));
                String membershipLevel = request.getParameter("membershipLevel");
                
                String result = adminService.updateCustomerAccount(accountId, email, fullName, phone, password, loyaltyPoints, membershipLevel);
                
                if ("success".equals(result)) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard?tab=customers&success=updated");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard?tab=customers&error=" + result);
                }
                
            } else if ("toggle-staff".equals(action) || "toggle-customer".equals(action)) {
                int accountId = Integer.parseInt(request.getParameter("accountId"));
                boolean active = Boolean.parseBoolean(request.getParameter("active"));
                
                boolean success = adminService.toggleAccountStatus(accountId, active);
                String returnTab = "toggle-staff".equals(action) ? "staff" : "customers";
                
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard?tab=" + returnTab + "&success=status_changed");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard?tab=" + returnTab + "&error=status_change_failed");
                }
            } else {
                doGet(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            String returnTab = action.contains("customer") ? "customers" : "staff";
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?tab=" + returnTab + "&error=system_error");
        }
    }
}
