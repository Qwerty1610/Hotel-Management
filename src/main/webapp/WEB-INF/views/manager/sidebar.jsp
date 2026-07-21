<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ include file="../../includes/taglibs.jsp" %>
        <%-- Sidebar chung cho Manager Dashboard. Sử dụng biến 'activePage' (request scope) để highlight menu item hiện
            tại. Các giá trị hợp lệ: 'overview' , 'rooms' , 'room-types' , 'services' , 'requests' , 'invoices'
            , 'customers' --%>
            <aside class="dashboard-sidebar">
                <div class="sidebar-brand">
                    <i class="fa-solid fa-hotel"></i> <span>HotelOps</span>
                </div>

                <ul class="sidebar-menu">
                    <li class="menu-item ${activePage eq 'overview' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/manager/dashboard?tab=overview">
                            <i class="fa-solid fa-table-cells-large"></i> <span>Tổng quan</span>
                        </a>
                    </li>
                    <li class="menu-item ${activePage eq 'room-types' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/manager/roomtypes">
                            <i class="fa-solid fa-door-open"></i> <span>Loại phòng</span>
                        </a>
                    </li>
                    <li class="menu-item ${activePage eq 'rooms' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/manager/rooms">
                            <i class="fa-solid fa-bed"></i> <span>Phòng</span>
                        </a>
                    </li>
                    <li class="menu-item ${activePage eq 'services' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/manager/services">
                            <i class="fa-solid fa-bell-concierge"></i> <span>Dịch vụ</span>
                        </a>
                    </li>
                    <li class="menu-item ${activePage eq 'amenities' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/manager/amenities">
                            <i class="fa-solid fa-wifi"></i> <span>Tiện nghi</span>
                        </a>
                    </li>
                    <li class="menu-item ${activePage eq 'requests' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/manager/requests">
                            <i class="fa-solid fa-headset"></i> <span>Yêu cầu &amp; Nhân viên</span>
                        </a>
                    </li>
                    <li class="menu-item ${activePage eq 'invoices' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/manager/invoices">
                            <i class="fa-solid fa-file-invoice-dollar"></i> <span>Hóa đơn</span>
                        </a>
                    </li>
                    <li class="menu-item ${activePage eq 'promotions' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/manager/promotions">
                            <i class="fa-solid fa-tag"></i> <span>Khuyến mãi</span>
                        </a>
                    </li>
                    <li class="menu-item ${activePage eq 'customers' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/manager/dashboard?tab=customers">
                            <i class="fa-solid fa-user-group"></i> <span>Khách hàng</span>
                        </a>
                    </li>
                </ul>

                <div class="sidebar-footer">
                    <div class="menu-item">
                        <a href="#"
                            style="display: flex; align-items: center; gap: 12px; padding: 12px 16px; color: #475569; text-decoration: none; font-weight: 600; font-size: 14px;">
                            <i class="fa-solid fa-gear"></i> <span>Cài đặt</span>
                        </a>
                    </div>

                    <a href="${pageContext.request.contextPath}/profile" class="user-profile-card"
                        title="Xem hồ sơ cá nhân" style="text-decoration:none;cursor:pointer;">
                        <div class="profile-avatar">
                            <c:choose>
                                <c:when test="${not empty sessionScope.user}">
                                    ${sessionScope.user.substring(0, 1).toUpperCase()}
                                </c:when>
                                <c:otherwise>M</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="profile-info">
                            <span class="profile-name">${not empty sessionScope.user ? sessionScope.user : 'Hotel
                                Manager'}</span>
                            <span class="profile-role">Hotel Manager</span>
                        </div>
                    </a>
                </div>
            </aside>