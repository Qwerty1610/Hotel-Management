<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../../includes/taglibs.jsp" %>
<%--
    Sidebar chung cho Admin Dashboard.
    Sử dụng biến 'activePage' (request scope) để highlight menu item hiện tại.
    Các giá trị hợp lệ: 'staff', 'customers'
--%>
<aside class="dashboard-sidebar">
    <div class="sidebar-brand" style="color: #3a86ff !important;">
        <i class="fa-solid fa-hotel" style="color: #3a86ff !important;"></i> <span>HotelOps</span>
    </div>

    <ul class="sidebar-menu">
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

    <div class="sidebar-footer">
        <div class="user-profile-card">
            <div class="profile-avatar" style="background: linear-gradient(135deg, #3a86ff, #0056b3) !important;">
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
        </div>
    </div>
</aside>
