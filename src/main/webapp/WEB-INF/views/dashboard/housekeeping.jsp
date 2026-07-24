<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/header.jsp" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/housekeeping.css">

<body class="dashboard-body"
      data-context-path="${pageContext.request.contextPath}">
    <div class="dashboard-layout">
        <aside class="dashboard-sidebar">
            <div class="sidebar-brand">
                <i class="fa-solid fa-hotel"></i>
                <span>HotelOps</span>
            </div>
            <ul class="sidebar-menu">
                <li class="menu-item ${param.tab == null || param.tab == 'overview' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/housekeeping/dashboard?tab=overview">
                        <i class="fa-solid fa-table-cells-large"></i>
                        <span>Tổng quan</span>
                    </a>
                </li>
                <li class="menu-item ${param.tab == 'task' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/housekeeping/dashboard?tab=task">
                        <i class="fa-solid fa-bed-pulse"></i>
                        <span>Sơ đồ phòng</span>
                    </a>
                </li>
                <li class="menu-item">
                    <a href="${pageContext.request.contextPath}/housekeeping/handlemaintenance">
                        <i class="fa-solid fa-screwdriver-wrench"></i>
                        <span>Yêu cầu bảo trì</span>
                    </a>
                </li>
                <li class="menu-item">
                    <a href="${pageContext.request.contextPath}/housekeeping/reportIssue">
                        <i class="fa-solid fa-triangle-exclamation"></i>
                        <span>Báo cáo sự cố phòng</span>
                    </a>
                </li>
            </ul>
            <div class="sidebar-footer">
                <div class="menu-item">
                    <a href="#" style="display:flex;align-items:center;gap:12px;padding:12px 16px;color:#475569;text-decoration:none;font-weight:600;font-size:14px;">
                        <i class="fa-solid fa-gear"></i>
                        <span>Cài đặt</span>
                    </a>
                </div>
                <a href="${pageContext.request.contextPath}/profile" class="user-profile-card" title="Xem hồ sơ cá nhân" style="text-decoration:none;cursor:pointer;">
                    <div class="profile-avatar">HK</div>
                    <div class="profile-info">
                        <span class="profile-name">
                            ${not empty sessionScope.user ? sessionScope.user : 'Housekeeping'}
                        </span>
                        <span class="profile-role">Housekeeping</span>
                    </div>
                </a>
            </div>
        </aside>

        <div class="dashboard-main">
            <header class="main-topbar">
                <div class="breadcrumb">
                    <span>Quản trị</span>
                    <span class="separator">&gt;</span>
                    <span class="current">
                        <c:choose>
                            <c:when test="${param.tab == 'task'}">Sơ đồ trạng thái phòng</c:when>
                            <c:otherwise>Tổng quan</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </a>
            </header>

            <main class="workspace-content">
                <c:if test="${param.tab == null || param.tab == 'overview'}">
                    <div class="content-header-row">
                        <div>
                            <h1>Tổng quan công việc</h1>
                            <p>Danh sách yêu cầu khách hàng được phân công cho bạn.</p>
                        </div>
                    </div>
                    <!-- ===== ROOM STATUS SUMMARY ===== -->
                    <div class="hk-stat-grid">
                        <div class="hk-card">
                            <h3>Dọn phòng / Bổ sung vật dụng</h3>
                            <span>${cleaningCount}</span>
                        </div>
                        <div class="hk-card">
                            <h3>Bảo trì</h3>
                            <span>${maintenanceCount}</span>
                        </div>
                        <div class="hk-card">
                            <h3>Phòng trống</h3>
                            <span>${availableCount}</span>
                        </div>
                        <div class="hk-card">
                            <h3>Ngừng hoạt động</h3>
                            <span>${outOfServiceCount}</span>
                        </div>
                    </div>
                    <!-- ===== CUSTOMER REQUEST TABLE ===== -->
                    <div class="customer-request-wrapper">
                        <h2>Công việc được giao</h2>
                        <table class="customer-request-table">
                            <thead>
                                <tr>
                                    <th>Số phòng</th>
                                    <th>Yêu cầu</th>
                                    <th>Mô tả</th>
                                    <th>Ưu tiên</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty assignedRequests}">
                                        <c:forEach var="req" items="${assignedRequests}">
                                            <tr>
                                                <td>
                                                    ${req.roomNumbers}
                                                </td>
                                                <td>
                                                    ${req.issueNames}
                                                </td>
                                                <td>
                                                    ${req.description}
                                                </td>
                                                <td>
                                                    <span class="priority-badge priority-${fn:toLowerCase(req.priority)}">
                                                        <c:choose>
                                                            <c:when test="${req.priority == 'Low'}">
                                                                Thấp
                                                            </c:when>
                                                            <c:when test="${req.priority == 'Medium'}">
                                                                Trung bình
                                                            </c:when>
                                                            <c:when test="${req.priority == 'High'}">
                                                                Cao
                                                            </c:when>
                                                            <c:when test="${req.priority == 'Urgent'}">
                                                                Khẩn cấp
                                                            </c:when>
                                                        </c:choose>
                                                    </span>
                                                </td>
                                                <td>
                                                    <span class="status-badge status-${fn:toLowerCase(req.status)}">
                                                        <c:choose>
                                                            <c:when test="${req.status == 'Pending'}">
                                                                Chờ xử lý
                                                            </c:when>
                                                            <c:when test="${req.status == 'InProgress'}">
                                                                Đang thực hiện
                                                            </c:when>
                                                            <c:when test="${req.status == 'Resolved'}">
                                                                Đã xử lý
                                                            </c:when>
                                                            <c:when test="${req.status == 'Unresolvable'}">
                                                                Không thể xử lý
                                                            </c:when>
                                                            <c:when test="${req.status == 'Cancelled'}">
                                                                Đã hủy
                                                            </c:when>
                                                            <c:otherwise>
                                                                ${req.status}
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${req.status == 'InProgress'}">
                                                            <a class="btn-complete-request"
                                                               href="${pageContext.request.contextPath}/housekeeping/handlemaintenance?action=detail&id=${req.requestId}">
                                                                Bắt đầu xử lý
                                                            </a>
                                                        </c:when>
                                                        <c:when test="${req.status == 'Unresolvable'}">
                                                            <a class="btn-complete-request"
                                                               href="${pageContext.request.contextPath}/housekeeping/handlemaintenance?action=detail&id=${req.requestId}">
                                                                Xử lý tiếp
                                                            </a>
                                                        </c:when>
                                                        <c:when test="${req.status == 'Resolved'}">
                                                            <button class="btn-request-completed"
                                                                    disabled>
                                                                Đã hoàn thành
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button disabled>
                                                                ${req.status}
                                                            </button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="6"
                                                style="text-align:center;">
                                                Không có công việc được giao
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </c:if>

                <c:if test="${param.tab == 'task'}">

                    <div class="quick-filter-wrapper">
                        <span class="filter-title">BỘ LỌC NHANH:</span>
                        <button class="btn-filter active" data-status="ALL"
                                onclick="applyStatusFilter('ALL', event)">
                            TẤT CẢ
                        </button>

                        <button class="btn-filter" data-status="OutOfService"
                                onclick="applyStatusFilter('OutOfService', event)">
                            NGỪNG HOẠT ĐỘNG
                        </button>

                        <button class="btn-filter" data-status="Available"
                                onclick="applyStatusFilter('Available', event)">
                            TRỐNG
                        </button>

                        <button class="btn-filter" data-status="Cleaning"
                                onclick="applyStatusFilter('Cleaning', event)">
                            DỌN PHÒNG / BỔ SUNG
                        </button>

                        <button class="btn-filter" data-status="Maintenance"
                                onclick="applyStatusFilter('Maintenance', event)">
                            BẢO TRÌ
                        </button>

                        <button class="btn-filter" data-status="HasGuest"
                                onclick="applyStatusFilter('HasGuest', event)">
                            CÓ KHÁCH
                        </button>
                    </div>

                    <div class="floor-container">
                        <jsp:useBean id="uniqueFloors" class="java.util.LinkedHashSet" scope="page" />
                        <c:forEach var="room" items="${roomList}">
                            <c:set var="added" value="${uniqueFloors.add(room.floor)}" />
                        </c:forEach>

                        <c:forEach var="currentFloor" items="${uniqueFloors}">
                            <c:set var="roomCount" value="0" />
                            <c:forEach var="r" items="${roomList}"><c:if test="${r.floor eq currentFloor}"><c:set var="roomCount" value="${roomCount + 1}" /></c:if></c:forEach>

                                    <div class="floor-card"
                                         id="floor-area-${currentFloor}"
                                data-floor="${currentFloor}">
                                <div class="floor-header">
                                    <span>${currentFloor}</span>
                                    <span class="floor-room-count">${roomCount} phòng</span>
                                </div>
                                <div class="room-grid">
                                    <c:forEach var="room" items="${roomList}">
                                        <c:if test="${room.floor eq currentFloor}">
                                            <c:choose>
                                                <c:when test="${room.status == 'OutOfService'}"><c:set var="colorClass" value="status-outofservice" /></c:when>
                                                <c:when test="${room.status == 'Available'}"><c:set var="colorClass" value="status-available" /></c:when>
                                                <c:when test="${room.status == 'Cleaning'}"><c:set var="colorClass" value="status-cleaning" /></c:when>
                                                <c:when test="${room.status == 'Refilling'}"><c:set var="colorClass" value="status-refilling" /></c:when>
                                                <c:when test="${room.status == 'Maintenance'}"><c:set var="colorClass" value="status-maintenance" /></c:when>
                                                <c:otherwise><c:set var="colorClass" value="status-available" /></c:otherwise>
                                            </c:choose>

                                            <div class="room-item ${colorClass}"
                                                 data-room-status="${fn:toLowerCase(room.status)}"
                                                 data-has-guest="${room.hasGuest}"
                                                 data-room-id="${room.roomId}"
                                                 onclick="goTaskDetail('${room.roomId}')">

                                                <div class="maintenance-dot"></div>
                                                <c:if test="${room.hasGuest}">
                                                    <span class="guest-badge">Có khách</span>
                                                </c:if>
                                                <span class="room-num">${room.roomNumber}</span>
                                                <span class="room-type">${room.typeName}</span>
                                            </div>
                                        </c:if>
                                    </c:forEach>
                                </div>
                            </div>
                        </c:forEach>
                        <c:set var="uniqueFloors" value="${null}" scope="page" />
                    </div>
                </c:if>
            </main>

            <footer class="dashboard-footer">
                <span>© 2026 HotelOps Luxury Management.</span>
            </footer>
        </div>
    </div>
    <script src="${pageContext.request.contextPath}/assets/js/housekeeping.js" charset="UTF-8"></script>
</body>
</html>