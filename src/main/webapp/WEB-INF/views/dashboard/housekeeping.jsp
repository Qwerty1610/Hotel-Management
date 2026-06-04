<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/header.jsp" %>
<%@ include file="../../includes/taglibs.jsp" %>

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
                        <i class="fa-solid fa-list-check"></i>
                        <span>Công việc</span>
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
                <div class="user-profile-card">
                    <div class="profile-avatar">HK</div>
                    <div class="profile-info">
                        <span class="profile-name">
                            ${not empty sessionScope.user ? sessionScope.user : 'Housekeeping'}
                        </span>
                        <span class="profile-role">Housekeeping</span>
                    </div>
                </div>
            </div>
        </aside>

        <div class="dashboard-main">
            <header class="main-topbar">
                <div class="breadcrumb">
                    <span>Quản trị</span>
                    <span class="separator">&gt;</span>
                    <span class="current">
                        <c:choose>
                            <c:when test="${param.tab == 'task'}">Công việc</c:when>
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
                            <h1>Housekeeping Overview</h1>
                            <p>Quản lý tình trạng phòng và công việc dọn dẹp hiện tại.</p>
                        </div>
                    </div>
                    <div class="hk-stat-grid">
                        <div class="hk-card"><h3>Dirty (Cleaning)</h3><span>${cleaningCount}</span></div>
                        <div class="hk-card"><h3>Maintenance</h3><span>${maintenanceCount}</span></div>
                        <div class="hk-card"><h3>Available</h3><span>${availableCount}</span></div>
                        <div class="hk-card"><h3>Occupied</h3><span>${occupiedCount}</span></div>
                    </div>
                </c:if>

                <c:if test="${param.tab == 'task'}">
                    <div class="content-header-row">
                        <div>
                            <h1>Sơ đồ trạng thái phòng</h1>
                            <p>Danh sách sơ đồ hiển thị trực quan theo thời gian thực.</p>
                        </div>
                    </div>

                    <div class="quick-filter-wrapper">
                        <span class="filter-title">BỘ LỌC NHANH:</span>
                        <button type="button" class="btn-filter active"
                                onclick="applyStatusFilter('ALL', event)">
                            Tất cả
                        </button>

                        <button type="button" class="btn-filter"
                                onclick="applyStatusFilter('Occupied', event)">
                            OCCUPIED
                        </button>

                        <button type="button" class="btn-filter"
                                onclick="applyStatusFilter('Available', event)">
                            AVAILABLE
                        </button>

                        <button type="button" class="btn-filter"
                                onclick="applyStatusFilter('Cleaning', event)">
                            CLEANING
                        </button>

                        <button type="button" class="btn-filter"
                                onclick="applyStatusFilter('Maintenance', event)">
                            MAINTENANCE
                        </button>

                        <button type="button" class="btn-filter"
                                onclick="applyStatusFilter('Completed', event)">
                            COMPLETED
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
                                                <c:when test="${room.status == 'Occupied'}"><c:set var="colorClass" value="status-occupied" /></c:when>
                                                <c:when test="${room.status == 'Available'}"><c:set var="colorClass" value="status-available" /></c:when>
                                                <c:when test="${room.status == 'Cleaning'}"><c:set var="colorClass" value="status-cleaning" /></c:when>
                                                <c:when test="${room.status == 'Maintenance'}"><c:set var="colorClass" value="status-maintenance" /></c:when>
                                                <c:when test="${room.status == 'Completed'}"><c:set var="colorClass" value="status-completed" /></c:when>
                                                <c:otherwise><c:set var="colorClass" value="status-available" /></c:otherwise>
                                            </c:choose>

                                            <div class="room-item ${colorClass}"
                                                 data-room-status="${room.status}"
                                                 data-room-id="${room.roomId}"
                                                 onclick="goTaskDetail('${room.roomId}')">

                                                <div class="dirty-dot"></div>
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
    <script src="${pageContext.request.contextPath}/assets/js/housekeeping.js"></script>
</body>
</html>