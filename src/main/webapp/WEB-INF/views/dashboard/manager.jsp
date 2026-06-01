<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=2" />
<fmt:setLocale value="vi_VN" />

<body class="dashboard-body">

    <!-- Active Tab Resolution -->
    <c:set var="currentTab" value="${param.tab != null ? param.tab : 'overview'}" />

    <div class="dashboard-layout">
        
        <!-- SIDEBAR -->
        <aside class="dashboard-sidebar">
            <div class="sidebar-brand">
                <i class="fa-solid fa-hotel"></i> <span>HotelOps</span>
            </div>
            
            <ul class="sidebar-menu">
                <li class="menu-item ${currentTab eq 'overview' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/manager/dashboard?tab=overview">
                        <i class="fa-solid fa-table-cells-large"></i> <span>Tổng quan</span>
                    </a>
                </li>
                <li class="menu-item ${currentTab eq 'roomtypes' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/manager/dashboard?tab=roomtypes">
                        <i class="fa-solid fa-door-open"></i> <span>Loại phòng</span>
                    </a>
                </li>
                <li class="menu-item ${currentTab eq 'rooms' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/manager/dashboard?tab=rooms">
                        <i class="fa-solid fa-bed"></i> <span>Phòng</span>
                    </a>
                </li>
                <li class="menu-item ${currentTab eq 'services' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/manager/dashboard?tab=services">
                        <i class="fa-solid fa-bell-concierge"></i> <span>Dịch vụ</span>
                    </a>
                </li>
                <li class="menu-item">
                    <a href="${pageContext.request.contextPath}/manager/requests">
                        <i class="fa-solid fa-headset"></i> <span>Yêu cầu &amp; Nhân viên</span>
                    </a>
                </li>
                <li class="menu-item">
                    <a href="${pageContext.request.contextPath}/manager/invoices">
                        <i class="fa-solid fa-file-invoice-dollar"></i> <span>Hóa đơn</span>
                    </a>
                </li>
                <li class="menu-item ${currentTab eq 'customers' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/manager/dashboard?tab=customers">
                        <i class="fa-solid fa-user-group"></i> <span>Khách hàng</span>
                    </a>
                </li>
            </ul>
            
            <div class="sidebar-footer">
                <div class="menu-item">
                    <a href="#" style="display: flex; align-items: center; gap: 12px; padding: 12px 16px; color: #475569; text-decoration: none; font-weight: 600; font-size: 14px;">
                        <i class="fa-solid fa-gear"></i> <span>Cài đặt</span>
                    </a>
                </div>
                
                <div class="user-profile-card">
                    <div class="profile-avatar">AM</div>
                    <div class="profile-info">
                        <span class="profile-name">${not empty sessionScope.user ? sessionScope.user : 'Hotel Manager'}</span>
                        <span class="profile-role">Hotel Manager</span>
                    </div>
                </div>
            </div>
        </aside>
        
        <!-- MAIN DASHBOARD CONTENT -->
        <div class="dashboard-main">
            
            <!-- TOP HEADER BAR -->
            <header class="main-topbar">
                <div class="breadcrumb">
                    <span>Quản trị</span>
                    <span class="separator">&gt;</span>
                    <span class="current">
                        <c:choose>
                            <c:when test="${currentTab eq 'overview'}">Tổng quan</c:when>
                            <c:when test="${currentTab eq 'roomtypes'}">Loại phòng</c:when>
                            <c:when test="${currentTab eq 'services'}">Dịch vụ</c:when>
                            <c:when test="${currentTab eq 'customers'}">Khách hàng</c:when>
                            <c:otherwise>Tổng quan</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </a>
            </header>
            
            <!-- DYNAMIC TAB WORKSPACE -->
            <main class="workspace-content">
                <c:choose>
                    
                    <%-- 1. OVERVIEW TAB - Theo dõi doanh thu & công suất phòng --%>
                    <c:when test="${currentTab eq 'overview'}">

                        <div class="content-header-row">
                            <div>
                                <h1>Tổng quan vận hành</h1>
                                <p>Theo dõi doanh thu và công suất phòng của khách sạn theo khoảng thời gian.</p>
                            </div>
                        </div>

                        <!-- BỘ LỌC THEO NGÀY -->
                        <div class="filter-card">
                            <form method="get" action="${pageContext.request.contextPath}/manager/dashboard" class="date-filter-form">
                                <input type="hidden" name="tab" value="overview" />
                                <div class="date-field">
                                    <label for="fromDate">Từ ngày</label>
                                    <input type="date" id="fromDate" name="fromDate" value="${stats.fromDate}" />
                                </div>
                                <div class="date-field">
                                    <label for="toDate">Đến ngày</label>
                                    <input type="date" id="toDate" name="toDate" value="${stats.toDate}" />
                                </div>
                                <button type="submit" class="btn-add-service" style="height: 40px;">
                                    <i class="fa-solid fa-filter"></i> Áp dụng
                                </button>
                                <div class="quick-ranges">
                                    <button type="button" class="btn-quick" onclick="setQuickRange(7)">7 ngày</button>
                                    <button type="button" class="btn-quick" onclick="setQuickRange(30)">30 ngày</button>
                                    <button type="button" class="btn-quick" onclick="setQuickRange(90)">90 ngày</button>
                                </div>
                            </form>
                        </div>

                        <!-- THẺ KPI -->
                        <div class="stat-grid">
                            <div class="stat-card">
                                <div class="stat-icon icon-revenue"><i class="fa-solid fa-sack-dollar"></i></div>
                                <div class="stat-body">
                                    <span class="stat-label">Tổng doanh thu</span>
                                    <span class="stat-value">
                                        <fmt:formatNumber value="${stats.totalRevenue}" type="number" maxFractionDigits="0" /> đ
                                    </span>
                                </div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-icon icon-occupancy"><i class="fa-solid fa-chart-pie"></i></div>
                                <div class="stat-body">
                                    <span class="stat-label">Công suất phòng TB</span>
                                    <span class="stat-value">
                                        <fmt:formatNumber value="${stats.avgOccupancy}" maxFractionDigits="1" />%
                                    </span>
                                </div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-icon icon-bookings"><i class="fa-solid fa-calendar-check"></i></div>
                                <div class="stat-body">
                                    <span class="stat-label">Lượt đặt ghi nhận</span>
                                    <span class="stat-value">
                                        <fmt:formatNumber value="${stats.totalBookings}" type="number" />
                                    </span>
                                </div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-icon icon-nights"><i class="fa-solid fa-bed"></i></div>
                                <div class="stat-body">
                                    <span class="stat-label">Số đêm-phòng đã bán</span>
                                    <span class="stat-value">
                                        <fmt:formatNumber value="${stats.roomNightsSold}" type="number" />
                                        <span class="stat-suffix">/ ${stats.totalRooms} phòng</span>
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- BIỂU ĐỒ DOANH THU & CÔNG SUẤT THEO NGÀY -->
                        <div class="chart-card chart-full">
                            <div class="chart-card-header">
                                <h3>Doanh thu &amp; công suất phòng theo ngày</h3>
                            </div>
                            <div class="chart-canvas-wrap">
                                <canvas id="revenueOccupancyChart"></canvas>
                            </div>
                        </div>

                        <!-- BIỂU ĐỒ PHÂN TÍCH -->
                        <div class="chart-grid">
                            <div class="chart-card">
                                <div class="chart-card-header">
                                    <h3>Doanh thu theo loại phòng</h3>
                                </div>
                                <div class="chart-canvas-wrap">
                                    <canvas id="roomTypeChart"></canvas>
                                </div>
                            </div>
                            <div class="chart-card">
                                <div class="chart-card-header">
                                    <h3>Phân bổ trạng thái đặt phòng</h3>
                                </div>
                                <div class="chart-canvas-wrap">
                                    <canvas id="statusChart"></canvas>
                                </div>
                            </div>
                        </div>

                    </c:when>
                    
                    <%-- 2. ROOM TYPES TAB (FULLY CODED AND INTEGRATED WITH SQL) --%>
                    <c:when test="${currentTab eq 'roomtypes'}">
                        
                        <!-- Hidden data container for database records -->
                        <div id="roomTypeDataStorage" style="display: none;">
                            <c:forEach var="rt" items="${roomTypesList}">
                                <div class="roomtype-data-item" 
                                     data-id="${rt.typeId}" 
                                     data-name="<c:out value="${rt.typeName}" />" 
                                     data-price="${rt.basePrice}" 
                                     data-capacity="${rt.capacity}" 
                                     data-bed-type="<c:out value="${rt.bedType}" />" 
                                     data-area="<c:out value="${rt.area}" />" 
                                     data-image-url="<c:out value="${rt.imageUrl}" />" 
                                     data-description="<c:out value="${rt.description}" />" 
                                     data-amenities="<c:forEach var="am" items="${rt.amenities}" varStatus="st">${am}${!st.last ? ',' : ''}</c:forEach>">
                                </div>
                            </c:forEach>
                        </div>
                        
                        <div class="content-header-row">
                            <div>
                                <h1>Quản lý Loại Phòng</h1>
                                <p>Cập nhật và điều chỉnh thông tin các loại phòng nghỉ của khách sạn.</p>
                            </div>
                            <button class="btn-add-service" onclick="openAddRoomTypeModal()">
                                <i class="fa-solid fa-plus"></i> Thêm Loại Phòng
                            </button>
                        </div>
                        
                        <!-- Room Types Table Wrapper -->
                        <div class="table-card">
                            
                            <!-- Search Filter -->
                            <div class="table-filter-bar">
                                <div class="search-wrapper">
                                    <i class="fa-solid fa-magnifying-glass"></i>
                                    <input type="text" id="roomTypeSearch" class="input-search-service" placeholder="Tìm kiếm loại phòng..." onkeyup="filterRoomTypes()" />
                                </div>
                            </div>
                            
                            <!-- Table Content -->
                            <table class="services-table-element">
                                <thead>
                                    <tr>
                                        <th style="width: 25%">Tên Loại Phòng</th>
                                        <th style="width: 15%">Sức chứa</th>
                                        <th style="width: 15%">Loại Giường</th>
                                        <th style="width: 20%">Tiện nghi</th>
                                        <th style="width: 15%">Giá Cơ Bản</th>
                                        <th style="width: 10%">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody id="roomTypesTableBody">
                                    <!-- Dynamic rows generated by JavaScript -->
                                </tbody>
                            </table>
                            
                            <!-- Table Pagination Footer -->
                            <div class="table-pagination-bar">
                                <div class="pagination-info" id="roomTypePaginationInfo">
                                    Hiển thị 1-5 trong số 5 loại phòng
                                </div>
                                <div class="pagination-controls" id="roomTypePaginationControls">
                                </div>
                            </div>
                            
                        </div>
                        
                    </c:when>
                    
                    <%-- ROOMS TAB (FULLY CODED AND INTEGRATED WITH SQL) --%>
                    <c:when test="${currentTab eq 'rooms'}">
                        
                        <!-- Hidden data container for room database records -->
                        <div id="roomDataStorage" style="display: none;">
                            <c:forEach var="r" items="${roomsList}">
                                <div class="room-data-item" 
                                     data-id="${r.roomId}" 
                                     data-number="<c:out value="${r.roomNumber}" />" 
                                     data-type-id="${r.typeId}" 
                                     data-status="<c:out value="${r.status}" />" 
                                     data-floor="<c:out value="${r.floor}" />" 
                                     data-type-name="<c:out value="${r.typeName}" />" 
                                     data-base-price="${r.basePrice}" 
                                     data-bed-type="<c:out value="${r.bedType}" />" 
                                     data-area="<c:out value="${r.area}" />">
                                </div>
                            </c:forEach>
                        </div>
                        
                        <div class="content-header-row">
                            <div>
                                <h1>Quản lý danh sách phòng</h1>
                                <p>Hệ thống vận hành và điều phối phòng lưu trú khách sạn.</p>
                            </div>
                            <button class="btn-add-service" onclick="openAddRoomModal()">
                                <i class="fa-solid fa-plus"></i> Thêm phòng mới
                            </button>
                        </div>
                        
                        <!-- Rooms Table Wrapper -->
                        <div class="table-card">
                            
                            <!-- Search & Dropdown Filters Bar -->
                            <div class="table-filter-bar" style="display: grid; grid-template-columns: 1.5fr 1fr 1fr 1fr; gap: 16px; align-items: end;">
                                <div class="modal-form-group" style="margin-bottom: 0;">
                                    <label>Tìm kiếm phòng</label>
                                    <div class="search-wrapper" style="max-width: 100%;">
                                        <i class="fa-solid fa-magnifying-glass"></i>
                                        <input type="text" id="roomSearch" class="input-search-service" placeholder="Nhập số phòng..." onkeyup="filterRooms()" />
                                    </div>
                                </div>
                                
                                <div class="modal-form-group" style="margin-bottom: 0;">
                                    <label>Tầng</label>
                                    <select id="floorFilter" class="status-select" onchange="filterRooms()" style="width: 100%;">
                                        <option value="all">Tất cả tầng</option>
                                        <option value="Tầng 1">Tầng 1</option>
                                        <option value="Tầng 2">Tầng 2</option>
                                        <option value="Tầng 3">Tầng 3</option>
                                        <option value="Tầng VIP">Tầng VIP</option>
                                    </select>
                                </div>
                                
                                <div class="modal-form-group" style="margin-bottom: 0;">
                                    <label>Loại phòng</label>
                                    <select id="roomTypeFilter" class="status-select" onchange="filterRooms()" style="width: 100%;">
                                        <option value="all">Tất cả loại</option>
                                        <c:forEach var="rt" items="${roomTypesList}">
                                            <option value="${rt.typeId}"><c:out value="${rt.typeName}" /></option>
                                        </c:forEach>
                                    </select>
                                </div>
                                
                                <div class="modal-form-group" style="margin-bottom: 0;">
                                    <label>Trạng thái</label>
                                    <select id="statusFilter" class="status-select" onchange="filterRooms()" style="width: 100%;">
                                        <option value="all">Tất cả trạng thái</option>
                                        <option value="Available">Trống</option>
                                        <option value="Occupied">Có khách</option>
                                        <option value="Cleaning">Đang dọn</option>
                                        <option value="Maintenance">Bảo trì</option>
                                    </select>
                                </div>
                            </div>
                            
                            <!-- Table Content -->
                            <table class="services-table-element">
                                <thead>
                                    <tr>
                                        <th style="width: 15%">Phòng</th>
                                        <th style="width: 15%">Tầng</th>
                                        <th style="width: 25%">Loại phòng</th>
                                        <th style="width: 15%">Trạng thái</th>
                                        <th style="width: 15%">Giá niêm yết</th>
                                        <th style="width: 15%">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody id="roomsTableBody">
                                    <!-- Dynamic rows generated by JavaScript -->
                                </tbody>
                            </table>
                            
                            <!-- Table Pagination Footer -->
                            <div class="table-pagination-bar">
                                <div class="pagination-info" id="roomPaginationInfo">
                                    Hiển thị 1-5 trong số 5 phòng
                                </div>
                                <div class="pagination-controls" id="roomPaginationControls">
                                </div>
                            </div>
                            
                        </div>
                        
                    </c:when>
                    
                    <%-- 3. SERVICES TAB (FULLY CODED AND STYLED AS REQUESTED) --%>
                    <c:when test="${currentTab eq 'services'}">
                        
                        <!-- Hidden data container for database records -->
                        <div id="serviceDataStorage" style="display: none;">
                            <c:forEach var="service" items="${servicesList}">
                                <div class="service-data-item" 
                                     data-id="${service.serviceId}" 
                                     data-name="<c:out value="${service.serviceName}" />" 
                                     data-description="<c:out value="${service.description}" />" 
                                     data-price="${service.price}" 
                                     data-unit="<c:out value="${service.unit}" />" 
                                     data-active="${service.isActive}">
                                </div>
                            </c:forEach>
                        </div>
                        
                        <div class="content-header-row">
                            <div>
                                <h1>Quản lý Dịch vụ</h1>
                                <p>Cập nhật và điều chỉnh các dịch vụ tiện ích tại khách sạn dành cho khách hàng.</p>
                            </div>
                            <button class="btn-add-service" onclick="openAddModal()">
                                <i class="fa-solid fa-plus"></i> Thêm dịch vụ mới
                            </button>
                        </div>
                        
                        <!-- Services Main Table Wrapper -->
                        <div class="table-card">
                            
                            <!-- Search & Status Filter -->
                            <div class="table-filter-bar">
                                <div class="search-wrapper">
                                    <i class="fa-solid fa-magnifying-glass"></i>
                                    <input type="text" id="serviceSearch" class="input-search-service" placeholder="Tìm kiếm dịch vụ..." onkeyup="filterServices()" />
                                </div>
                                
                                <select id="statusFilter" class="status-select" onchange="filterServices()">
                                    <option value="all">Tất cả trạng thái</option>
                                    <option value="active">Đang kích hoạt</option>
                                    <option value="inactive">Đang tạm khóa</option>
                                </select>
                            </div>
                            
                            <!-- Table Content -->
                            <table class="services-table-element">
                                <thead>
                                    <tr>
                                        <th style="width: 25%">Dịch vụ</th>
                                        <th style="width: 35%">Mô tả</th>
                                        <th style="width: 15%">Đơn giá</th>
                                        <th style="width: 13%">Trạng thái</th>
                                        <th style="width: 12%">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody id="servicesTableBody">
                                    <!-- Dynamic rows generated by JavaScript -->
                                </tbody>
                            </table>
                            
                            <!-- Table Pagination Footer -->
                            <div class="table-pagination-bar">
                                <div class="pagination-info" id="paginationInfo">
                                    Hiển thị 1-4 trong số 4 dịch vụ
                                </div>
                                <div class="pagination-controls" id="paginationControls">
                                </div>
                            </div>
                            
                        </div>
                        
                    </c:when>
                    
                    <%-- 4. CUSTOMERS TAB (PLACEHOLDER) --%>
                    <c:when test="${currentTab eq 'customers'}">
                        <div style="padding: 40px; text-align: center; color: var(--text-muted);">
                            <i class="fa-solid fa-user-group" style="font-size: 48px; margin-bottom: 16px;"></i>
                            <h3>Tính năng Quản lý Khách hàng đang được phát triển</h3>
                        </div>
                    </c:when>
                    
                </c:choose>
            </main>
            
            <!-- DASHBOARD FOOTER -->
            <footer class="dashboard-footer">
                <span>© 2024 HotelOps Luxury Management. Hệ thống quản trị nội bộ.</span>
                <div class="footer-links-row">
                    <a href="#">Hỗ trợ</a>
                    <a href="#">Bảo mật</a>
                    <a href="#">Điều khoản</a>
                </div>
            </footer>
            
        </div>
        
    </div>

    <!-- ADD / EDIT ROOM MODAL DIALOG -->
    <div class="modal-overlay" id="roomModal">
        <div class="modal-container">
            <div class="modal-header">
                <h3 id="roomModalTitle">Thêm phòng mới</h3>
                <button class="btn-close-modal" onclick="closeRoomModal()"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="modal-body">
                <form id="roomForm" action="${pageContext.request.contextPath}/manager/rooms?action=save" method="post">
                    <input type="hidden" id="modalRoomId" name="roomId" value="" />
                    
                    <div class="modal-form-group">
                        <label for="modalRoomNumber">Số phòng</label>
                        <input type="text" id="modalRoomNumber" name="roomNumber" class="modal-input" placeholder="Ví dụ: 101" required />
                    </div>
                    
                    <div class="modal-form-group">
                        <label for="modalRoomFloor">Tầng</label>
                        <select id="modalRoomFloor" name="floor" class="modal-select" required>
                            <option value="Tầng 1">Tầng 1</option>
                            <option value="Tầng 2">Tầng 2</option>
                            <option value="Tầng 3">Tầng 3</option>
                            <option value="Tầng VIP">Tầng VIP</option>
                        </select>
                    </div>
                    
                    <div class="modal-form-group">
                        <label for="modalRoomType">Loại phòng</label>
                        <select id="modalRoomType" name="typeId" class="modal-select" required>
                            <c:forEach var="rt" items="${roomTypesList}">
                                <option value="${rt.typeId}"><c:out value="${rt.typeName}" /></option>
                            </c:forEach>
                        </select>
                    </div>
                    
                    <div class="modal-form-group">
                        <label for="modalRoomStatus">Trạng thái</label>
                        <select id="modalRoomStatus" name="status" class="modal-select" required>
                            <option value="Available">Trống (Available)</option>
                            <option value="Occupied">Có khách (Occupied)</option>
                            <option value="Cleaning">Đang dọn (Cleaning)</option>
                            <option value="Maintenance">Bảo trì (Maintenance)</option>
                        </select>
                    </div>
                    
                    <div class="modal-footer-row">
                        <button type="button" class="btn-modal-cancel" onclick="closeRoomModal()">Hủy bỏ</button>
                        <button type="submit" class="btn-modal-submit">Lưu lại</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- ADD / EDIT ROOM TYPE MODAL DIALOG -->
    <div class="modal-overlay" id="roomTypeModal">
        <div class="modal-container" style="max-width: 600px;">
            <div class="modal-header">
                <h3 id="roomTypeModalTitle">Thêm loại phòng mới</h3>
                <button class="btn-close-modal" onclick="closeRoomTypeModal()"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="modal-body">
                <form id="roomTypeForm" action="${pageContext.request.contextPath}/manager/roomtypes?action=save" method="post">
                    <input type="hidden" id="modalRtId" name="roomTypeId" value="" />
                    
                    <div class="modal-form-group">
                        <label for="modalRtName">Tên loại phòng</label>
                        <input type="text" id="modalRtName" name="name" class="modal-input" placeholder="Ví dụ: Deluxe Ocean View" required />
                    </div>
                    
                    <div class="modal-form-group" style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                        <div>
                            <label for="modalRtPrice">Giá cơ bản (VNĐ)</label>
                            <input type="number" id="modalRtPrice" name="price" class="modal-input" placeholder="Ví dụ: 2500000" required />
                        </div>
                        <div>
                            <label for="modalRtCapacity">Sức chứa (người lớn)</label>
                            <input type="number" id="modalRtCapacity" name="capacity" class="modal-input" placeholder="Ví dụ: 2" required />
                        </div>
                    </div>
                    
                    <div class="modal-form-group" style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                        <div>
                            <label for="modalRtBedType">Loại Giường</label>
                            <input type="text" id="modalRtBedType" name="bedType" class="modal-input" placeholder="Ví dụ: King Bed" required />
                        </div>
                        <div>
                            <label for="modalRtArea">Diện tích (m²)</label>
                            <input type="text" id="modalRtArea" name="area" class="modal-input" placeholder="Ví dụ: 45 m²" required />
                        </div>
                    </div>
                    
                    <div class="modal-form-group">
                        <label for="modalRtImageUrl">URL hình ảnh</label>
                        <input type="text" id="modalRtImageUrl" name="imageUrl" class="modal-input" placeholder="Ví dụ: https://..." required />
                    </div>
                    
                    <div class="modal-form-group">
                        <label for="modalRtDescription">Mô tả loại phòng</label>
                        <textarea id="modalRtDescription" name="description" class="modal-textarea" placeholder="Nhập mô tả chi tiết..." required></textarea>
                    </div>
                    
                    <div class="modal-form-group">
                        <label>Tiện nghi loại phòng</label>
                        <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 8px; margin-top: 6px;">
                            <label style="display: flex; align-items: center; gap: 8px; font-weight: 500; cursor: pointer;">
                                <input type="checkbox" name="amenity" value="Wifi miễn phí" style="width: 16px; height: 16px;" /> Wifi miễn phí
                            </label>
                            <label style="display: flex; align-items: center; gap: 8px; font-weight: 500; cursor: pointer;">
                                <input type="checkbox" name="amenity" value="Điều hòa" style="width: 16px; height: 16px;" /> Điều hòa
                            </label>
                            <label style="display: flex; align-items: center; gap: 8px; font-weight: 500; cursor: pointer;">
                                <input type="checkbox" name="amenity" value="Tivi" style="width: 16px; height: 16px;" /> Tivi
                            </label>
                            <label style="display: flex; align-items: center; gap: 8px; font-weight: 500; cursor: pointer;">
                                <input type="checkbox" name="amenity" value="View thành phố" style="width: 16px; height: 16px;" /> View thành phố
                            </label>
                            <label style="display: flex; align-items: center; gap: 8px; font-weight: 500; cursor: pointer;">
                                <input type="checkbox" name="amenity" value="Mini bar" style="width: 16px; height: 16px;" /> Mini bar
                            </label>
                            <label style="display: flex; align-items: center; gap: 8px; font-weight: 500; cursor: pointer;">
                                <input type="checkbox" name="amenity" value="Bồn tắm" style="width: 16px; height: 16px;" /> Bồn tắm
                            </label>
                            <label style="display: flex; align-items: center; gap: 8px; font-weight: 500; cursor: pointer;">
                                <input type="checkbox" name="amenity" value="Ban công" style="width: 16px; height: 16px;" /> Ban công
                            </label>
                            <label style="display: flex; align-items: center; gap: 8px; font-weight: 500; cursor: pointer;">
                                <input type="checkbox" name="amenity" value="Máy pha cà phê" style="width: 16px; height: 16px;" /> Máy pha cà phê
                            </label>
                        </div>
                    </div>
                    
                    <div class="modal-footer-row">
                        <button type="button" class="btn-modal-cancel" onclick="closeRoomTypeModal()">Hủy bỏ</button>
                        <button type="submit" class="btn-modal-submit">Lưu lại</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- ADD / EDIT SERVICE MODAL DIALOG -->
    <div class="modal-overlay" id="serviceModal">
        <div class="modal-container">
            <div class="modal-header">
                <h3 id="modalTitle">Thêm dịch vụ mới</h3>
                <button class="btn-close-modal" onclick="closeModal()"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="modal-body">
                <form id="serviceForm" action="${pageContext.request.contextPath}/manager/services?action=save" method="post">
                    <input type="hidden" id="serviceId" name="serviceId" value="" />
                    
                    <div class="modal-form-group">
                        <label for="modalName">Tên dịch vụ</label>
                        <input type="text" id="modalName" name="name" class="modal-input" placeholder="Ví dụ: Bữa sáng Buffet" required />
                    </div>
                    
                    <div class="modal-form-group">
                        <label for="modalDescription">Mô tả dịch vụ</label>
                        <textarea id="modalDescription" name="description" class="modal-textarea" placeholder="Nhập mô tả ngắn..." required></textarea>
                    </div>
                    
                    <div class="modal-form-group" style="display: grid; grid-template-columns: 2fr 1fr; gap: 16px;">
                        <div>
                            <label for="modalPrice">Đơn giá (VNĐ)</label>
                            <input type="number" id="modalPrice" name="price" class="modal-input" placeholder="Ví dụ: 350000" required />
                        </div>
                        <div>
                            <label for="modalUnit">Đơn vị tính</label>
                            <input type="text" id="modalUnit" name="unit" class="modal-input" placeholder="Ví dụ: /khách" required />
                        </div>
                    </div>

                    
                    <div class="modal-footer-row">
                        <button type="button" class="btn-modal-cancel" onclick="closeModal()">Hủy bỏ</button>
                        <button type="submit" class="btn-modal-submit">Lưu lại</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- JavaScript Data and Interactivity Logic -->
    <c:if test="${currentTab eq 'services'}">
        <script>
            
            // Helper to get service icon and background class dynamically from name
            function getServiceIconInfo(name) {
                const lowerName = name.toLowerCase();
                if (lowerName.includes("ăn") || lowerName.includes("buffet") || lowerName.includes("sáng") || lowerName.includes("nhà hàng") || lowerName.includes("uống") || lowerName.includes("food") || lowerName.includes("breakfast")) {
                    return { icon: "fa-utensils", iconClass: "icon-buffet" };
                } else if (lowerName.includes("spa") || lowerName.includes("massage") || lowerName.includes("thư giãn") || lowerName.includes("làm đẹp") || lowerName.includes("trị liệu")) {
                    return { icon: "fa-leaf", iconClass: "icon-spa" };
                } else if (lowerName.includes("giặt") || lowerName.includes("ủi") || lowerName.includes("laundry") || lowerName.includes("quần áo") || lowerName.includes("sấy")) {
                    return { icon: "fa-shirt", iconClass: "icon-laundry" };
                } else if (lowerName.includes("xe") || lowerName.includes("đưa") || lowerName.includes("đón") || lowerName.includes("sân bay") || lowerName.includes("chuyến") || lowerName.includes("shuttle") || lowerName.includes("car")) {
                    return { icon: "fa-car", iconClass: "icon-shuttle" };
                } else if (lowerName.includes("gym") || lowerName.includes("tập") || lowerName.includes("thể hình") || lowerName.includes("thể thao") || lowerName.includes("fitness")) {
                    return { icon: "fa-dumbbell", iconClass: "icon-default" };
                } else if (lowerName.includes("bơi") || lowerName.includes("pool") || lowerName.includes("hồ bơi") || lowerName.includes("nước")) {
                    return { icon: "fa-water", iconClass: "icon-default" };
                }
                return { icon: "fa-bell-concierge", iconClass: "icon-default" };
            }

            // Hydrate services array from database elements
            let services = [];
            document.querySelectorAll(".service-data-item").forEach(item => {
                const name = item.getAttribute("data-name");
                const iconInfo = getServiceIconInfo(name);
                services.push({
                    id: parseInt(item.getAttribute("data-id")),
                    name: name,
                    description: item.getAttribute("data-description"),
                    price: parseFloat(item.getAttribute("data-price")),
                    unit: item.getAttribute("data-unit"),
                    iconClass: iconInfo.iconClass,
                    icon: iconInfo.icon,
                    isActive: item.getAttribute("data-active") === "true"
                });
            });

            // Pagination state variables
            let currentPage = 1;
            const pageSize = 5;
            let filteredServicesList = [];

            // Helper to render pagination controls dynamically based on total pages
            function renderPaginationControls(totalPages) {
                const controlsContainer = document.getElementById("paginationControls");
                if (!controlsContainer) return;
                
                controlsContainer.innerHTML = "";
                
                // Left chevron button
                const prevButton = document.createElement("button");
                prevButton.type = "button";
                prevButton.className = "btn-page" + (currentPage === 1 || totalPages === 0 ? " disabled" : "");
                prevButton.innerHTML = '<i class="fa-solid fa-chevron-left"></i>';
                if (currentPage > 1 && totalPages > 0) {
                    prevButton.onclick = () => {
                        currentPage--;
                        renderTable();
                    };
                }
                controlsContainer.appendChild(prevButton);
                
                // Page numbers (1, 2, 3, etc.)
                for (let i = 1; i <= totalPages; i++) {
                    const pageButton = document.createElement("button");
                    pageButton.type = "button";
                    pageButton.className = "btn-page" + (i === currentPage ? " active" : "");
                    pageButton.innerText = i;
                    pageButton.onclick = () => {
                        currentPage = i;
                        renderTable();
                    };
                    controlsContainer.appendChild(pageButton);
                }
                
                // If totalPages is 0, still show button 1 as active but disabled
                if (totalPages === 0) {
                    const pageButton = document.createElement("button");
                    pageButton.type = "button";
                    pageButton.className = "btn-page active";
                    pageButton.innerText = 1;
                    controlsContainer.appendChild(pageButton);
                }
                
                // Right chevron button
                const nextButton = document.createElement("button");
                nextButton.type = "button";
                nextButton.className = "btn-page" + (currentPage === totalPages || totalPages === 0 ? " disabled" : "");
                nextButton.innerHTML = '<i class="fa-solid fa-chevron-right"></i>';
                if (currentPage < totalPages && totalPages > 0) {
                    nextButton.onclick = () => {
                        currentPage++;
                        renderTable();
                    };
                }
                controlsContainer.appendChild(nextButton);
            }

            // Render table records for the current page
            function renderTable() {
                const tbody = document.getElementById("servicesTableBody");
                tbody.innerHTML = "";
                
                const totalFiltered = filteredServicesList.length;
                const totalPages = Math.ceil(totalFiltered / pageSize);
                
                if (currentPage > totalPages && totalPages > 0) {
                    currentPage = totalPages;
                }
                
                if (totalFiltered === 0) {
                    tbody.innerHTML = `
                        <tr>
                            <td colspan="5" style="text-align: center; padding: 40px; color: var(--text-muted);">
                                <i class="fa-solid fa-folder-open" style="font-size: 32px; margin-bottom: 12px; display: block;"></i>
                                Không tìm thấy dịch vụ nào phù hợp
                            </td>
                        </tr>
                    `;
                    document.getElementById("paginationInfo").innerText = "Hiển thị 0 dịch vụ";
                    renderPaginationControls(0);
                    return;
                }
                
                const startIndex = (currentPage - 1) * pageSize;
                const endIndex = Math.min(startIndex + pageSize, totalFiltered);
                const pageData = filteredServicesList.slice(startIndex, endIndex);
                
                pageData.forEach(service => {
                    const priceFormatted = new Intl.NumberFormat('vi-VN').format(service.price);
                    
                    const tr = document.createElement("tr");
                    tr.innerHTML = `
                        <td>
                            <div class="service-name-cell">
                                <span class="service-title">\${service.name}</span>
                            </div>
                        </td>
                        <td>
                            <span class="service-desc-text">\${service.description}</span>
                        </td>
                        <td>
                            <span class="service-price-text">
                                \${priceFormatted} VNĐ <span class="unit">\${service.unit}</span>
                            </span>
                        </td>
                        <td>
                            <label class="switch switch-active">
                                <input type="checkbox" \${service.isActive ? 'checked' : ''} onchange="toggleStatus(\${service.id}, this.checked)" />
                                <span class="slider"></span>
                            </label>
                        </td>
                        <td>
                            <div class="table-actions">
                                <button class="btn-action edit" onclick="openEditModal(\${service.id})" title="Chỉnh sửa">
                                    <i class="fa-solid fa-pencil"></i>
                                </button>
                                <button class="btn-action delete" onclick="deleteService(\${service.id})" title="Xóa">
                                    <i class="fa-solid fa-trash-can"></i>
                                </button>
                            </div>
                        </td>
                    `;
                    tbody.appendChild(tr);
                });
                
                document.getElementById("paginationInfo").innerText = `Hiển thị \${startIndex + 1}-\${endIndex} trong số \${totalFiltered} dịch vụ`;
                renderPaginationControls(totalPages);
            }

            // Real-time Search and Filter
            function filterServices() {
                const query = document.getElementById("serviceSearch").value.toLowerCase().trim();
                const status = document.getElementById("statusFilter").value;
                
                filteredServicesList = services.filter(service => {
                    const matchQuery = service.name.toLowerCase().includes(query) || service.description.toLowerCase().includes(query);
                    const matchStatus = (status === "all") || 
                                       (status === "active" && service.isActive) || 
                                       (status === "inactive" && !service.isActive);
                    return matchQuery && matchStatus;
                });
                
                currentPage = 1;
                renderTable();
            }

            // Toggle active status in the database using background fetch()
            function toggleStatus(id, checked) {
                const url = `${pageContext.request.contextPath}/manager/services?action=toggle&id=` + id + `&status=` + checked;
                fetch(url)
                    .then(response => {
                        if (!response.ok) {
                            alert("Có lỗi xảy ra khi cập nhật trạng thái!");
                            filterServices();
                        } else {
                            const service = services.find(s => s.id === id);
                            if (service) {
                                service.isActive = checked;
                            }
                        }
                    })
                    .catch(error => {
                        console.error("Error toggling status:", error);
                        alert("Có lỗi xảy ra khi kết nối máy chủ!");
                        filterServices();
                    });
            }

            // Modal Handlers
            function openAddModal() {
                document.getElementById("modalTitle").innerText = "Thêm dịch vụ mới";
                document.getElementById("serviceId").value = "";
                document.getElementById("serviceForm").reset();
                document.getElementById("serviceModal").style.display = "flex";
            }

            function openEditModal(id) {
                const service = services.find(s => s.id === id);
                if (service) {
                    document.getElementById("modalTitle").innerText = "Chỉnh sửa dịch vụ";
                    document.getElementById("serviceId").value = service.id;
                    document.getElementById("modalName").value = service.name;
                    document.getElementById("modalDescription").value = service.description;
                    document.getElementById("modalPrice").value = service.price;
                    document.getElementById("modalUnit").value = service.unit;
                    document.getElementById("serviceModal").style.display = "flex";
                }
            }

            function closeModal() {
                document.getElementById("serviceModal").style.display = "none";
            }

            // Delete Service via redirecting to the controller delete action
            function deleteService(id) {
                if (confirm("Bạn có chắc chắn muốn xóa dịch vụ này không?")) {
                    window.location.href = `${pageContext.request.contextPath}/manager/services?action=delete&id=` + id;
                }
            }

            // Initial load of the table
            window.onload = function() {
                filterServices();
            };

        </script>
    </c:if>
    
    <c:if test="${currentTab eq 'roomtypes'}">
        <script>
            // Pagination state for room types
            let roomTypesCurrentPage = 1;
            const roomTypesPageSize = 5;
            let filteredRoomTypesList = [];

            // Helper to get service icon and background class dynamically from name
            function getServiceIconInfo(name) {
                const lowerName = name.toLowerCase();
                if (lowerName.includes("ăn") || lowerName.includes("buffet") || lowerName.includes("sáng") || lowerName.includes("nhà hàng") || lowerName.includes("uống") || lowerName.includes("food") || lowerName.includes("breakfast")) {
                    return { icon: "fa-utensils", iconClass: "icon-buffet" };
                } else if (lowerName.includes("spa") || lowerName.includes("massage") || lowerName.includes("thư giãn") || lowerName.includes("làm đẹp") || lowerName.includes("trị liệu")) {
                    return { icon: "fa-leaf", iconClass: "icon-spa" };
                } else if (lowerName.includes("giặt") || lowerName.includes("ủi") || lowerName.includes("laundry") || lowerName.includes("quần áo") || lowerName.includes("sấy")) {
                    return { icon: "fa-shirt", iconClass: "icon-laundry" };
                } else if (lowerName.includes("xe") || lowerName.includes("đưa") || lowerName.includes("đón") || lowerName.includes("sân bay") || lowerName.includes("chuyến") || lowerName.includes("shuttle") || lowerName.includes("car")) {
                    return { icon: "fa-car", iconClass: "icon-shuttle" };
                } else if (lowerName.includes("gym") || lowerName.includes("tập") || lowerName.includes("thể hình") || lowerName.includes("thể thao") || lowerName.includes("fitness")) {
                    return { icon: "fa-dumbbell", iconClass: "icon-default" };
                } else if (lowerName.includes("bơi") || lowerName.includes("pool") || lowerName.includes("hồ bơi") || lowerName.includes("nước")) {
                    return { icon: "fa-water", iconClass: "icon-default" };
                }
                return { icon: "fa-bell-concierge", iconClass: "icon-default" };
            }

            // Hydrate room types array from database elements
            let roomTypes = [];
            document.querySelectorAll(".roomtype-data-item").forEach(item => {
                const amenitiesStr = item.getAttribute("data-amenities");
                const amenitiesList = amenitiesStr ? amenitiesStr.split(",") : [];
                roomTypes.push({
                    id: parseInt(item.getAttribute("data-id")),
                    name: item.getAttribute("data-name"),
                    price: parseFloat(item.getAttribute("data-price")),
                    capacity: parseInt(item.getAttribute("data-capacity")),
                    bedType: item.getAttribute("data-bed-type"),
                    area: item.getAttribute("data-area"),
                    imageUrl: item.getAttribute("data-image-url"),
                    description: item.getAttribute("data-description"),
                    amenities: amenitiesList
                });
            });

            // Helper to render pagination controls dynamically for room types
            function renderRoomTypePaginationControls(totalPages) {
                const controlsContainer = document.getElementById("roomTypePaginationControls");
                if (!controlsContainer) return;
                
                controlsContainer.innerHTML = "";
                
                // Left chevron
                const prevButton = document.createElement("button");
                prevButton.type = "button";
                prevButton.className = "btn-page" + (roomTypesCurrentPage === 1 || totalPages === 0 ? " disabled" : "");
                prevButton.innerHTML = '<i class="fa-solid fa-chevron-left"></i>';
                if (roomTypesCurrentPage > 1 && totalPages > 0) {
                    prevButton.onclick = () => {
                        roomTypesCurrentPage--;
                        renderRoomTypesTable();
                    };
                }
                controlsContainer.appendChild(prevButton);
                
                // Pages
                for (let i = 1; i <= totalPages; i++) {
                    const pageButton = document.createElement("button");
                    pageButton.type = "button";
                    pageButton.className = "btn-page" + (i === roomTypesCurrentPage ? " active" : "");
                    pageButton.innerText = i;
                    pageButton.onclick = () => {
                        roomTypesCurrentPage = i;
                        renderRoomTypesTable();
                    };
                    controlsContainer.appendChild(pageButton);
                }
                
                if (totalPages === 0) {
                    const pageButton = document.createElement("button");
                    pageButton.type = "button";
                    pageButton.className = "btn-page active";
                    pageButton.innerText = 1;
                    controlsContainer.appendChild(pageButton);
                }
                
                // Right chevron
                const nextButton = document.createElement("button");
                nextButton.type = "button";
                nextButton.className = "btn-page" + (roomTypesCurrentPage === totalPages || totalPages === 0 ? " disabled" : "");
                nextButton.innerHTML = '<i class="fa-solid fa-chevron-right"></i>';
                if (roomTypesCurrentPage < totalPages && totalPages > 0) {
                    nextButton.onclick = () => {
                        roomTypesCurrentPage++;
                        renderRoomTypesTable();
                    };
                }
                controlsContainer.appendChild(nextButton);
            }

            // Render room types table
            function renderRoomTypesTable() {
                const tbody = document.getElementById("roomTypesTableBody");
                if (!tbody) return;
                tbody.innerHTML = "";
                
                const totalFiltered = filteredRoomTypesList.length;
                const totalPages = Math.ceil(totalFiltered / roomTypesPageSize);
                
                if (roomTypesCurrentPage > totalPages && totalPages > 0) {
                    roomTypesCurrentPage = totalPages;
                }
                
                if (totalFiltered === 0) {
                    tbody.innerHTML = `
                        <tr>
                            <td colspan="6" style="text-align: center; padding: 40px; color: var(--text-muted);">
                                <i class="fa-solid fa-folder-open" style="font-size: 32px; margin-bottom: 12px; display: block;"></i>
                                Không tìm thấy loại phòng nào phù hợp
                            </td>
                        </tr>
                    `;
                    document.getElementById("roomTypePaginationInfo").innerText = "Hiển thị 0 loại phòng";
                    renderRoomTypePaginationControls(0);
                    return;
                }
                
                const startIndex = (roomTypesCurrentPage - 1) * roomTypesPageSize;
                const endIndex = Math.min(startIndex + roomTypesPageSize, totalFiltered);
                const pageData = filteredRoomTypesList.slice(startIndex, endIndex);
                
                pageData.forEach(rt => {
                    const priceFormatted = new Intl.NumberFormat('vi-VN').format(rt.price);
                    
                    // Render amenity badges
                    let amenitiesHtml = "";
                    rt.amenities.forEach(am => {
                        if (am.trim()) {
                            let badgeText = am.toUpperCase();
                            if (badgeText.includes("WIFI")) badgeText = "WIFI";
                            else if (badgeText.includes("ĐIỀU HÒA")) badgeText = "AC";
                            else if (badgeText.includes("TIVI")) badgeText = "TV";
                            else if (badgeText.includes("VIEW THÀNH PHỐ")) badgeText = "CITY VIEW";
                            else if (badgeText.includes("BỒN TẮM")) badgeText = "BATHTUB";
                            else if (badgeText.includes("MINI BAR")) badgeText = "MINI BAR";
                            else if (badgeText.includes("BAN CÔNG")) badgeText = "BALCONY";
                            else if (badgeText.includes("MÁY PHA CÀ PHÊ")) badgeText = "COFFEE";
                            
                            amenitiesHtml += `<span class="roomtype-badge">\${badgeText}</span>`;
                        }
                    });
                    
                    const tr = document.createElement("tr");
                    tr.innerHTML = `
                        <td>
                            <div class="service-name-cell">
                                <img src="\${rt.imageUrl}" class="roomtype-img" alt="\${rt.name}" onerror="this.src='https://images.unsplash.com/photo-1618773928121-c32242e63f39?q=80&w=600'" />
                                <div>
                                    <span class="service-title">\${rt.name}</span>
                                    <span style="font-size: 11px; color: var(--text-muted); font-weight: 500;">ID: RT-00\${rt.id}</span>
                                </div>
                            </div>
                        </td>
                        <td>
                            <span class="service-desc-text" style="font-weight: 600; color: var(--text-navy); margin: 0;">\${rt.capacity} Người lớn</span>
                        </td>
                        <td>
                            <span class="service-desc-text" style="font-weight: 500; color: #475569; margin: 0;">\${rt.bedType}</span>
                        </td>
                        <td>
                            <div style="max-width: 220px;">\${amenitiesHtml || '<span style="color: var(--text-muted); font-style: italic; font-size: 12px;">Không có</span>'}</div>
                        </td>
                        <td>
                            <span class="service-price-text" style="font-size: 16px; color: var(--brand-blue); font-weight: bold;">\${priceFormatted}đ</span>
                        </td>
                        <td>
                            <div class="table-actions">
                                <button class="btn-action edit" onclick="openEditRoomTypeModal(\${rt.id})" title="Chỉnh sửa">
                                    <i class="fa-solid fa-pencil"></i>
                                </button>
                                <button class="btn-action delete" onclick="deleteRoomType(\${rt.id})" title="Xóa">
                                    <i class="fa-solid fa-trash-can"></i>
                                </button>
                            </div>
                        </td>
                    `;
                    tbody.appendChild(tr);
                });
                
                document.getElementById("roomTypePaginationInfo").innerText = `Hiển thị \${startIndex + 1}-\${endIndex} trong số \${totalFiltered} loại phòng`;
                renderRoomTypePaginationControls(totalPages);
            }

            // Filter Room Types
            function filterRoomTypes() {
                const query = document.getElementById("roomTypeSearch").value.toLowerCase().trim();
                
                filteredRoomTypesList = roomTypes.filter(rt => {
                    const matchQuery = rt.name.toLowerCase().includes(query) || 
                                       rt.bedType.toLowerCase().includes(query) || 
                                       rt.description.toLowerCase().includes(query);
                    return matchQuery;
                });
                
                roomTypesCurrentPage = 1;
                renderRoomTypesTable();
            }

            // Modal Handlers
            function openAddRoomTypeModal() {
                document.getElementById("roomTypeModalTitle").innerText = "Thêm loại phòng mới";
                document.getElementById("modalRtId").value = "";
                document.getElementById("roomTypeForm").reset();
                
                // Clear checkboxes
                document.querySelectorAll('#roomTypeForm input[name="amenity"]').forEach(cb => {
                    cb.checked = false;
                });
                
                document.getElementById("roomTypeModal").style.display = "flex";
            }

            function openEditRoomTypeModal(id) {
                const rt = roomTypes.find(item => item.id === id);
                if (rt) {
                    document.getElementById("roomTypeModalTitle").innerText = "Chỉnh sửa loại phòng";
                    document.getElementById("modalRtId").value = rt.id;
                    document.getElementById("modalRtName").value = rt.name;
                    document.getElementById("modalRtPrice").value = rt.price;
                    document.getElementById("modalRtCapacity").value = rt.capacity;
                    document.getElementById("modalRtBedType").value = rt.bedType;
                    document.getElementById("modalRtArea").value = rt.area;
                    document.getElementById("modalRtImageUrl").value = rt.imageUrl;
                    document.getElementById("modalRtDescription").value = rt.description;
                    
                    // Check appropriate checkboxes
                    document.querySelectorAll('#roomTypeForm input[name="amenity"]').forEach(cb => {
                        cb.checked = rt.amenities.some(am => am.toLowerCase().trim() === cb.value.toLowerCase().trim());
                    });
                    
                    document.getElementById("roomTypeModal").style.display = "flex";
                }
            }

            function closeRoomTypeModal() {
                document.getElementById("roomTypeModal").style.display = "none";
            }

            function deleteRoomType(id) {
                if (confirm("Bạn có chắc chắn muốn xóa loại phòng này không?\nLưu ý: Hành động này sẽ xóa tất cả phòng thuộc loại phòng này.")) {
                    window.location.href = `${pageContext.request.contextPath}/manager/roomtypes?action=delete&id=` + id;
                }
            }

            // Initial load of the table
            window.addEventListener('load', function() {
                filterRoomTypes();
            });
        </script>
    </c:if>
    
    <c:if test="${currentTab eq 'rooms'}">
        <script>
            // Hydrate rooms array from database elements
            let rooms = [];
            document.querySelectorAll(".room-data-item").forEach(item => {
                rooms.push({
                    id: parseInt(item.getAttribute("data-id")),
                    number: item.getAttribute("data-number"),
                    typeId: parseInt(item.getAttribute("data-type-id")),
                    status: item.getAttribute("data-status"),
                    floor: item.getAttribute("data-floor"),
                    typeName: item.getAttribute("data-type-name"),
                    basePrice: parseFloat(item.getAttribute("data-base-price")),
                    bedType: item.getAttribute("data-bed-type"),
                    area: item.getAttribute("data-area")
                });
            });

            // Pagination state for rooms
            let roomsCurrentPage = 1;
            const roomsPageSize = 5;
            let filteredRoomsList = [];

            // Helper to render pagination controls dynamically for rooms
            function renderRoomPaginationControls(totalPages) {
                const controlsContainer = document.getElementById("roomPaginationControls");
                if (!controlsContainer) return;
                
                controlsContainer.innerHTML = "";
                
                // Left chevron
                const prevButton = document.createElement("button");
                prevButton.type = "button";
                prevButton.className = "btn-page" + (roomsCurrentPage === 1 || totalPages === 0 ? " disabled" : "");
                prevButton.innerHTML = '<i class="fa-solid fa-chevron-left"></i>';
                if (roomsCurrentPage > 1 && totalPages > 0) {
                    prevButton.onclick = () => {
                        roomsCurrentPage--;
                        renderRoomsTable();
                    };
                }
                controlsContainer.appendChild(prevButton);
                
                // Pages
                for (let i = 1; i <= totalPages; i++) {
                    const pageButton = document.createElement("button");
                    pageButton.type = "button";
                    pageButton.className = "btn-page" + (i === roomsCurrentPage ? " active" : "");
                    pageButton.innerText = i;
                    pageButton.onclick = () => {
                        roomsCurrentPage = i;
                        renderRoomsTable();
                    };
                    controlsContainer.appendChild(pageButton);
                }
                
                if (totalPages === 0) {
                    const pageButton = document.createElement("button");
                    pageButton.type = "button";
                    pageButton.className = "btn-page active";
                    pageButton.innerText = 1;
                    controlsContainer.appendChild(pageButton);
                }
                
                // Right chevron
                const nextButton = document.createElement("button");
                nextButton.type = "button";
                nextButton.className = "btn-page" + (roomsCurrentPage === totalPages || totalPages === 0 ? " disabled" : "");
                nextButton.innerHTML = '<i class="fa-solid fa-chevron-right"></i>';
                if (roomsCurrentPage < totalPages && totalPages > 0) {
                    nextButton.onclick = () => {
                        roomsCurrentPage++;
                        renderRoomsTable();
                    };
                }
                controlsContainer.appendChild(nextButton);
            }

            // Render rooms table
            function renderRoomsTable() {
                const tbody = document.getElementById("roomsTableBody");
                if (!tbody) return;
                tbody.innerHTML = "";
                
                const totalFiltered = filteredRoomsList.length;
                const totalPages = Math.ceil(totalFiltered / roomsPageSize);
                
                if (roomsCurrentPage > totalPages && totalPages > 0) {
                    roomsCurrentPage = totalPages;
                }
                
                if (totalFiltered === 0) {
                    tbody.innerHTML = `
                        <tr>
                            <td colspan="6" style="text-align: center; padding: 40px; color: var(--text-muted);">
                                <i class="fa-solid fa-folder-open" style="font-size: 32px; margin-bottom: 12px; display: block;"></i>
                                Không tìm thấy phòng nào phù hợp
                            </td>
                        </tr>
                    `;
                    document.getElementById("roomPaginationInfo").innerText = "Hiển thị 0 phòng";
                    renderRoomPaginationControls(0);
                    return;
                }
                
                const startIndex = (roomsCurrentPage - 1) * roomsPageSize;
                const endIndex = Math.min(startIndex + roomsPageSize, totalFiltered);
                const pageData = filteredRoomsList.slice(startIndex, endIndex);
                
                pageData.forEach(room => {
                    const priceFormatted = new Intl.NumberFormat('vi-VN').format(room.basePrice);
                    
                    let statusClass = "";
                    let statusText = "";
                    if (room.status === "Available") {
                        statusClass = "status-available";
                        statusText = "TRỐNG";
                    } else if (room.status === "Occupied") {
                        statusClass = "status-occupied";
                        statusText = "CÓ KHÁCH";
                    } else if (room.status === "Cleaning") {
                        statusClass = "status-cleaning";
                        statusText = "ĐANG DỌN";
                    } else if (room.status === "Maintenance") {
                        statusClass = "status-maintenance";
                        statusText = "BẢO TRÌ";
                    }
                    
                    let actionsHtml = `
                        <button class="btn-action edit" onclick="openEditRoomModal(\${room.id})" title="Chỉnh sửa">
                            <i class="fa-solid fa-pencil"></i>
                        </button>
                        <button class="btn-action delete" onclick="deleteRoom(\${room.id})" title="Xóa">
                            <i class="fa-solid fa-trash-can"></i>
                        </button>
                    `;
                    
                    const tr = document.createElement("tr");
                    tr.innerHTML = `
                        <td>
                            <span class="room-number-cell" style="font-weight: bold; color: var(--brand-blue); font-size: 16px;">\${room.number}</span>
                        </td>
                        <td>
                            <span class="room-floor-text" style="font-weight: 500; color: #475569;">\${room.floor}</span>
                        </td>
                        <td>
                            <div class="room-type-info-cell">
                                <span class="room-type-title" style="font-weight: 600; color: var(--text-navy); display: block;">\${room.typeName}</span>
                                <span class="room-type-details" style="font-size: 11px; color: var(--text-muted); display: block;">\${room.bedType}, \${room.area}</span>
                            </div>
                        </td>
                        <td>
                            <span class="status-pill \${statusClass}"><i class="fa-solid fa-circle"></i> \${statusText}</span>
                        </td>
                        <td>
                            <span class="room-price-text" style="font-size: 15px; color: #1e293b; font-weight: bold;">\${priceFormatted}đ</span>
                        </td>
                        <td>
                            <div class="table-actions" style="display: flex; gap: 8px; align-items: center;">
                                \${actionsHtml}
                            </div>
                        </td>
                    `;
                    tbody.appendChild(tr);
                });
                
                document.getElementById("roomPaginationInfo").innerText = `Hiển thị \${startIndex + 1}-\${endIndex} trong số \${totalFiltered} phòng`;
                renderRoomPaginationControls(totalPages);
            }

            // Real-time Search and Filtering for rooms
            function filterRooms() {
                const query = document.getElementById("roomSearch").value.toLowerCase().trim();
                const floor = document.getElementById("floorFilter").value;
                const typeId = document.getElementById("roomTypeFilter").value;
                const status = document.getElementById("statusFilter").value;
                
                filteredRoomsList = rooms.filter(room => {
                    const matchQuery = room.number.toLowerCase().includes(query);
                    const matchFloor = (floor === "all") || (room.floor === floor);
                    const matchType = (typeId === "all") || (room.typeId === parseInt(typeId));
                    const matchStatus = (status === "all") || (room.status === status);
                    return matchQuery && matchFloor && matchType && matchStatus;
                });
                
                roomsCurrentPage = 1;
                renderRoomsTable();
            }

            // Update room status via background fetch
            function updateRoomStatus(id, newStatus) {
                const url = `${pageContext.request.contextPath}/manager/rooms?action=updateStatus&id=` + id + `&status=` + newStatus;
                fetch(url)
                    .then(response => {
                        if (!response.ok) {
                            alert("Có lỗi xảy ra khi cập nhật trạng thái phòng!");
                            filterRooms();
                        } else {
                            const room = rooms.find(r => r.id === id);
                            if (room) {
                                room.status = newStatus;
                            }
                            filterRooms();
                        }
                    })
                    .catch(error => {
                        console.error("Error updating status:", error);
                        alert("Có lỗi xảy ra khi kết nối máy chủ!");
                        filterRooms();
                    });
            }

            // Delete Room
            function deleteRoom(id) {
                if (confirm("Bạn có chắc chắn muốn xóa phòng này không?")) {
                    window.location.href = `${pageContext.request.contextPath}/manager/rooms?action=delete&id=` + id;
                }
            }

            // Modal Handlers
            function openAddRoomModal() {
                document.getElementById("roomModalTitle").innerText = "Thêm phòng mới";
                document.getElementById("modalRoomId").value = "";
                document.getElementById("roomForm").reset();
                document.getElementById("roomModal").style.display = "flex";
            }

            function openEditRoomModal(id) {
                const room = rooms.find(r => r.id === id);
                if (room) {
                    document.getElementById("roomModalTitle").innerText = "Chỉnh sửa thông tin phòng";
                    document.getElementById("modalRoomId").value = room.id;
                    document.getElementById("modalRoomNumber").value = room.number;
                    document.getElementById("modalRoomFloor").value = room.floor;
                    document.getElementById("modalRoomType").value = room.typeId;
                    document.getElementById("modalRoomStatus").value = room.status;
                    document.getElementById("roomModal").style.display = "flex";
                }
            }

            function closeRoomModal() {
                document.getElementById("roomModal").style.display = "none";
            }

            // Initial load of the table
            window.addEventListener('load', function() {
                filterRooms();
            });
        </script>
    </c:if>

    <%-- OVERVIEW TAB: biểu đồ doanh thu & công suất (Chart.js) --%>
    <c:if test="${currentTab eq 'overview'}">
        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
        <script>
            // ----- Dữ liệu từ server (đổ qua JSTL) -----
            const dayLabels = [<c:forEach var="l" items="${stats.dayLabels}" varStatus="st">"${l}"${!st.last ? ',' : ''}</c:forEach>];
            const dayRevenue = [<c:forEach var="v" items="${stats.dayRevenue}" varStatus="st">${v}${!st.last ? ',' : ''}</c:forEach>];
            const dayOccupancy = [<c:forEach var="v" items="${stats.dayOccupancy}" varStatus="st">${v}${!st.last ? ',' : ''}</c:forEach>];

            const roomTypeLabels = [<c:forEach var="l" items="${stats.roomTypeLabels}" varStatus="st">"${l}"${!st.last ? ',' : ''}</c:forEach>];
            const roomTypeRevenue = [<c:forEach var="v" items="${stats.roomTypeRevenue}" varStatus="st">${v}${!st.last ? ',' : ''}</c:forEach>];

            const statusLabels = [<c:forEach var="l" items="${stats.statusLabels}" varStatus="st">"${l}"${!st.last ? ',' : ''}</c:forEach>];
            const statusCounts = [<c:forEach var="v" items="${stats.statusCounts}" varStatus="st">${v}${!st.last ? ',' : ''}</c:forEach>];

            const vnCurrency = new Intl.NumberFormat('vi-VN');

            // ----- Bộ lọc nhanh theo ngày -----
            function setQuickRange(days) {
                const to = new Date();
                const from = new Date();
                from.setDate(from.getDate() - (days - 1));
                const fmt = d => d.toISOString().slice(0, 10);
                document.getElementById("fromDate").value = fmt(from);
                document.getElementById("toDate").value = fmt(to);
                document.querySelector(".date-filter-form").submit();
            }

            // ----- Biểu đồ doanh thu & công suất theo ngày -----
            new Chart(document.getElementById("revenueOccupancyChart"), {
                data: {
                    labels: dayLabels,
                    datasets: [
                        {
                            type: 'bar',
                            label: 'Doanh thu (đ)',
                            data: dayRevenue,
                            backgroundColor: 'rgba(0, 86, 179, 0.7)',
                            borderRadius: 4,
                            yAxisID: 'yRevenue',
                            order: 2
                        },
                        {
                            type: 'line',
                            label: 'Công suất (%)',
                            data: dayOccupancy,
                            borderColor: '#10b981',
                            backgroundColor: 'rgba(16, 185, 129, 0.15)',
                            borderWidth: 2,
                            tension: 0.35,
                            fill: true,
                            yAxisID: 'yOccupancy',
                            order: 1
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    interaction: { mode: 'index', intersect: false },
                    plugins: {
                        legend: { position: 'top' },
                        tooltip: {
                            callbacks: {
                                label: function(ctx) {
                                    if (ctx.dataset.yAxisID === 'yOccupancy') {
                                        return ' Công suất: ' + ctx.parsed.y + '%';
                                    }
                                    return ' Doanh thu: ' + vnCurrency.format(ctx.parsed.y) + ' đ';
                                }
                            }
                        }
                    },
                    scales: {
                        yRevenue: {
                            position: 'left',
                            beginAtZero: true,
                            title: { display: true, text: 'Doanh thu (đ)' },
                            ticks: { callback: v => vnCurrency.format(v) }
                        },
                        yOccupancy: {
                            position: 'right',
                            beginAtZero: true,
                            max: 100,
                            title: { display: true, text: 'Công suất (%)' },
                            grid: { drawOnChartArea: false },
                            ticks: { callback: v => v + '%' }
                        }
                    }
                }
            });

            // ----- Doanh thu theo loại phòng -----
            const palette = ['#0056b3', '#10b981', '#f59e0b', '#8b5cf6', '#ef4444', '#06b6d4'];
            if (roomTypeLabels.length > 0) {
                new Chart(document.getElementById("roomTypeChart"), {
                    type: 'doughnut',
                    data: {
                        labels: roomTypeLabels,
                        datasets: [{
                            data: roomTypeRevenue,
                            backgroundColor: palette,
                            borderWidth: 2,
                            borderColor: '#ffffff'
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { position: 'bottom' },
                            tooltip: {
                                callbacks: {
                                    label: ctx => ' ' + ctx.label + ': ' + vnCurrency.format(ctx.parsed) + ' đ'
                                }
                            }
                        }
                    }
                });
            }

            // ----- Phân bổ trạng thái đặt phòng -----
            if (statusLabels.length > 0) {
                new Chart(document.getElementById("statusChart"), {
                    type: 'bar',
                    data: {
                        labels: statusLabels,
                        datasets: [{
                            label: 'Số đơn',
                            data: statusCounts,
                            backgroundColor: '#0056b3',
                            borderRadius: 4
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        indexAxis: 'y',
                        plugins: { legend: { display: false } },
                        scales: { x: { beginAtZero: true, ticks: { precision: 0 } } }
                    }
                });
            }
        </script>
    </c:if>

</body>
</html>
