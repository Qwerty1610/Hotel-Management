<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../../includes/taglibs.jsp" %>
<%--
    Sidebar chung cho Admin Dashboard.
    Sử dụng biến 'activePage' (request scope) để highlight menu item hiện tại.
    Các giá trị hợp lệ: 'system-dashboard', 'staff', 'customers'
--%>
<aside class="dashboard-sidebar">
    <div class="sidebar-brand">
        <i class="fa-solid fa-hotel"></i> <span>HotelOps</span>
    </div>

    <ul class="sidebar-menu">
        <li class="menu-item ${activePage eq 'system-dashboard' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/system-dashboard">
                <i class="fa-solid fa-gauge-high"></i> <span>Bảng điều khiển</span>
            </a>
        </li>
        <li class="menu-item ${activePage eq 'staff' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/dashboard?tab=staff">
                <i class="fa-solid fa-user-tie"></i> <span>Quản lý nhân viên</span>
            </a>
        </li>
        <li class="menu-item ${activePage eq 'customers' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/dashboard?tab=customers">
                <i class="fa-solid fa-user-group"></i> <span>Quản lý khách hàng</span>
            </a>
        </li>
    </ul>

    <div class="sidebar-footer" style="padding-bottom: 5px;">
        <div class="menu-item ${activePage eq 'settings' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/settings" style="display: flex; align-items: center; gap: 12px; padding: 12px 16px; color: #475569; text-decoration: none; font-weight: 600; font-size: 14px;">
                <i class="fa-solid fa-gear"></i> <span>Cấu hình hệ thống</span>
            </a>
        </div>
        <div class="menu-item ${activePage eq 'hotel-settings' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/hotel-settings" style="display: flex; align-items: center; gap: 12px; padding: 12px 16px; color: #475569; text-decoration: none; font-weight: 600; font-size: 14px;">
                <i class="fa-solid fa-hotel"></i> <span>Thông tin khách sạn</span>
            </a>
        </div>

        <a href="${pageContext.request.contextPath}/profile" class="user-profile-card" title="Xem hồ sơ cá nhân" style="text-decoration:none;cursor:pointer;">
            <div class="profile-avatar">
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        ${sessionScope.user.substring(0, 1).toUpperCase()}
                    </c:when>
                    <c:otherwise>A</c:otherwise>
                </c:choose>
            </div>
            <div class="profile-info">
                <span class="profile-name">${not empty sessionScope.user ? sessionScope.user : 'Admin User'}</span>
                <span class="profile-role">Hệ Thống Admin</span>
            </div>
        </a>
    </div>
</aside>
