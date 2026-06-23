<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Quản lý yêu cầu dịch vụ - HotelOps Pro</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/receptionist.css?v=5" />
</head>
<fmt:setLocale value="vi_VN" />

<body class="dashboard-body">

<div class="dashboard-layout">

    <%-- ================= SIDEBAR ================= --%>
    <aside class="dashboard-sidebar">
        <div class="sidebar-brand">
            <i class="fa-solid fa-bell-concierge"></i> <span>HotelOps</span>
        </div>

        <ul class="sidebar-menu">
            <li class="menu-item">
                <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings">
                    <i class="fa-solid fa-calendar-check"></i> <span>Yêu cầu đặt phòng</span>
                </a>
            </li>
            
            <li class="menu-item">
                <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=checkin">
                    <i class="fa-solid fa-key"></i> <span>Nhận phòng (Check-in)</span>
                </a>
            </li>
            
            <li class="menu-item">
                <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=checkout">
                    <i class="fa-solid fa-right-from-bracket"></i> <span>Trả phòng & Thanh toán</span>
                </a>
            </li>

            <li class="menu-item active">
                <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=servicerequests">
                    <i class="fa-solid fa-bell-concierge"></i> <span>Quản lý yêu cầu dịch vụ</span>
                </a>
            </li>
        </ul>

        <div class="sidebar-footer">
            <a href="${pageContext.request.contextPath}/profile" class="user-profile-card" title="Xem hồ sơ cá nhân" style="text-decoration:none;cursor:pointer;">
                <div class="profile-avatar">RC</div>
                <div class="profile-info">
                    <span class="profile-name">${not empty sessionScope.user ? sessionScope.user : 'Receptionist'}</span>
                    <span class="profile-role">Lễ tân</span>
                </div>
            </a>
        </div>
    </aside>

    <%-- ================= MAIN CONTENT ================= --%>
    <div class="dashboard-main">

        <%-- TOPBAR --%>
        <header class="main-topbar">
            <div class="breadcrumb">
                <span>Receptionist</span>
                <span class="separator">&gt;</span>
                <span class="current">Quản lý yêu cầu dịch vụ</span>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
            </a>
        </header>

        <%-- WORKSPACE --%>
        <main class="workspace-content">
            
            <%-- Toast notification --%>
            <c:if test="${param.result eq 'success'}">
                <div class="toast-notify toast-success">
                    <i class="fa-solid fa-circle-check"></i>
                    <c:choose>
                        <c:when test="${param.action eq 'approve'}">Đã duyệt hoàn thành yêu cầu dịch vụ thành công!</c:when>
                        <c:when test="${param.action eq 'cancel'}">Đã hủy yêu cầu dịch vụ thành công!</c:when>
                        <c:otherwise>Thao tác thành công!</c:otherwise>
                    </c:choose>
                </div>
            </c:if>
            <c:if test="${param.result eq 'fail'}">
                <div class="toast-notify toast-error">
                    <i class="fa-solid fa-circle-xmark"></i>
                    Thao tác thất bại. Vui lòng thử lại sau.
                </div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div class="toast-notify toast-error">
                    <i class="fa-solid fa-circle-xmark"></i>
                    <c:choose>
                        <c:when test="${param.error eq 'invalid'}">Mã yêu cầu hoặc hành động không hợp lệ.</c:when>
                        <c:otherwise>Đã xảy ra lỗi. Vui lòng thử lại sau.</c:otherwise>
                    </c:choose>
                </div>
            </c:if>

    <body class="dashboard-body">

        <div class="dashboard-layout">

            <%-- ================= SIDEBAR ================= --%>
            <aside class="dashboard-sidebar">
                <div class="sidebar-brand">
                    <i class="fa-solid fa-bell-concierge"></i> <span>HotelOps</span>
                </div>

                <ul class="sidebar-menu">
                    <li class="menu-item ${currentTab eq 'bookings' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings">
                            <i class="fa-solid fa-calendar-check"></i> <span>Yêu cầu đặt phòng</span>
                        </a>
                    </li>

                    <li class="menu-item ${currentTab eq 'roommap' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=roommap">
                            <i class="fa-solid fa-calendar-check"></i> <span>sơ đồ phòng</span>
                        </a>
                    </li>

                    <li class="menu-item ${currentTab eq 'checkin' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=checkin">
                            <i class="fa-solid fa-key"></i> <span>Nhận phòng (Check-in)</span>
                        </a>
                    </li>

                    <li class="menu-item ${currentTab eq 'walkin-bookings' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=walkin-bookings">
                            <i class="fa-solid fa-calendar-check"></i> <span>Đặt phòng tại quầy</span>
                        </a>
                    </li>

                    <li class="menu-item ${currentTab eq 'checkout' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=checkout">
                            <i class="fa-solid fa-right-from-bracket"></i> <span>Trả phòng & Thanh toán</span>
                        </a>
                    </li>

                    <li class="menu-item ${currentTab eq 'servicerequests' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=servicerequests">
                            <i class="fa-solid fa-bell-concierge"></i> <span>Quản lý yêu cầu dịch vụ</span>
                        </a>
                    </li>
                </ul>

                <div class="sidebar-footer">
                    <div class="user-profile-card">
                        <div class="profile-avatar">RC</div>
                        <div class="profile-info">
                            <span class="profile-name">${not empty sessionScope.user ? sessionScope.user : 'Receptionist'}</span>
                            <span class="profile-role">Lễ tân</span>
                        </div>
                    </div>
                </div>
            </aside>

            <%-- ================= MAIN CONTENT ================= --%>
            <div class="dashboard-main">

                <%-- TOPBAR --%>
                <header class="main-topbar">
                    <div class="breadcrumb">
                        <span>Receptionist</span>
                        <span class="separator">&gt;</span>
                        <span class="current">Quản lý yêu cầu dịch vụ</span>
                    </div>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                        <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                    </a>
                </header>

                <%-- WORKSPACE --%>
                <main class="workspace-content">

                    <%-- Toast notification --%>
                    <c:if test="${param.result eq 'success'}">
                        <div class="toast-notify toast-success">
                            <i class="fa-solid fa-circle-check"></i>
                            <c:choose>
                                <c:when test="${param.action eq 'approve'}">Đã duyệt hoàn thành yêu cầu dịch vụ thành công!</c:when>
                                <c:when test="${param.action eq 'cancel'}">Đã hủy yêu cầu dịch vụ thành công!</c:when>
                                <c:otherwise>Thao tác thành công!</c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>
                    <c:if test="${param.result eq 'fail'}">
                        <div class="toast-notify toast-error">
                            <i class="fa-solid fa-circle-xmark"></i>
                            Thao tác thất bại. Vui lòng thử lại sau.
                        </div>
                    </c:if>
                    <c:if test="${not empty param.error}">
                        <div class="toast-notify toast-error">
                            <i class="fa-solid fa-circle-xmark"></i>
                            <c:choose>
                                <c:when test="${param.error eq 'invalid'}">Mã yêu cầu hoặc hành động không hợp lệ.</c:when>
                                <c:otherwise>Đã xảy ra lỗi. Vui lòng thử lại sau.</c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>

                    <%-- Header Title --%>
                    <div class="content-header-row">
                        <div>
                            <h2><i class="fa-solid fa-bell-concierge" style="color:var(--brand-blue);margin-right:8px"></i>Quản lý yêu cầu dịch vụ</h2>
                            <p>Xem, xác nhận, từ chối và cập nhật trạng thái các yêu cầu dịch vụ từ khách hàng.</p>
                        </div>
                    </div>

                    <%-- KPI Stats Cards --%>
                    <div class="stats-cards-container">
                        <div class="stats-card">
                            <div class="card-icon-wrapper card-icon-total">
                                <i class="fa-solid fa-list-check"></i>
                            </div>
                            <div class="card-info">
                                <span class="card-label">TỔNG YÊU CẦU</span>
                                <span class="card-value">${kpiTotal}</span>
                            </div>
                        </div>

                        <div class="stats-card stats-card-pending">
                            <div class="card-icon-wrapper card-icon-pending">
                                <i class="fa-solid fa-clipboard-list"></i>
                            </div>
                            <div class="card-info">
                                <span class="card-label">CHỜ XỬ LÝ</span>
                                <span class="card-value"><fmt:formatNumber value="${kpiPending}" pattern="00" /></span>
                            </div>
                        </div>

                        <div class="stats-card stats-card-completed">
                            <div class="card-icon-wrapper card-icon-completed">
                                <i class="fa-solid fa-circle-check"></i>
                            </div>
                            <div class="card-info">
                                <span class="card-label">ĐÃ CẤP</span>
                                <span class="card-value"><fmt:formatNumber value="${kpiCompleted}" pattern="00" /></span>
                            </div>
                        </div>

                        <div class="stats-card stats-card-cancelled">
                            <div class="card-icon-wrapper card-icon-cancelled">
                                <i class="fa-solid fa-circle-xmark"></i>
                            </div>
                            <div class="card-info">
                                <span class="card-label">ĐÃ HỦY</span>
                                <span class="card-value"><fmt:formatNumber value="${kpiCancelled}" pattern="00" /></span>
                            </div>
                        </div>
                    </div>

                    <%-- Search & Filters --%>
                    <div class="req-filter-bar">
                        <form method="get" action="${pageContext.request.contextPath}/receptionist/dashboard" class="req-search-form">
                            <input type="hidden" name="tab" value="servicerequests" />
                            <input type="hidden" name="status" value="${currentStatus}" />
                            <div class="search-wrapper" style="max-width: 100%;">
                                <i class="fa-solid fa-magnifying-glass"></i>
                                <input type="text" name="keyword" class="search-input"
                                       placeholder="Tìm tên khách, số phòng hoặc mã yêu cầu..."
                                       value="${keyword}" />
                            </div>
                        </form>

                        <div class="req-tabs">
                            <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=servicerequests&status=All&keyword=${keyword}"
                               class="req-tab ${currentStatus eq 'All' || empty currentStatus ? 'active' : ''}">Tất cả</a>
                            <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=servicerequests&status=Pending&keyword=${keyword}"
                               class="req-tab ${currentStatus eq 'Pending' ? 'active' : ''}">Chờ xử lý</a>
                            <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=servicerequests&status=Completed&keyword=${keyword}"
                               class="req-tab ${currentStatus eq 'Completed' ? 'active' : ''}">Đã cấp</a>
                            <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=servicerequests&status=Cancelled&keyword=${keyword}"
                               class="req-tab ${currentStatus eq 'Cancelled' ? 'active' : ''}">Đã hủy</a>
                        </div>
                    </div>

                    <%-- Table --%>
                    <div class="table-card">
                        <c:choose>
                            <c:when test="${empty requestList}">
                                <div class="empty-state">
                                    <i class="fa-solid fa-inbox"></i>
                                    <p>Không có yêu cầu dịch vụ nào.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <table class="booking-table">
                                    <thead>
                                        <tr>
                                            <th>Mã yêu cầu</th>
                                            <th>Phòng</th>
                                            <th>Khách hàng</th>
                                            <th>Loại dịch vụ</th>
                                            <th>Thời gian gửi</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="r" items="${requestList}">
                                            <tr>
                                                <%-- Mã yêu cầu --%>
                                                <td>
                                                    <span class="req-id-link">#${r.requestId}</span>
                                                </td>

                                                <%-- Phòng --%>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty r.roomNumber}">
                                                            Phòng ${r.roomNumber}
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="font-weight: 500; color: var(--text-muted);">Chưa nhận phòng</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>

                                                <%-- Khách hàng --%>
                                                <td>
                                                    <div class="customer-cell">
                                                        <div class="name"><c:out value="${r.customerName}" /></div>
                                                    </div>
                                                </td>

                                                <%-- Loại dịch vụ --%>
                                                <td>
                                                    <c:set var="serviceClass" value="service-default" />
                                                    <c:choose>
                                                        <c:when test="${fn:contains(fn:toLowerCase(r.title), 'giặt ủi') || fn:contains(fn:toLowerCase(r.title), 'giặt là') || fn:contains(fn:toLowerCase(r.title), 'laundry')}">
                                                            <c:set var="serviceClass" value="service-laundry" />
                                                        </c:when>
                                                        <c:when test="${fn:contains(fn:toLowerCase(r.title), 'gym') || fn:contains(fn:toLowerCase(r.title), 'phòng tập')}">
                                                            <c:set var="serviceClass" value="service-gym" />
                                                        </c:when>
                                                        <c:when test="${fn:contains(fn:toLowerCase(r.title), 'đưa đón') || fn:contains(fn:toLowerCase(r.title), 'sân bay') || fn:contains(fn:toLowerCase(r.title), 'shuttle') || fn:contains(fn:toLowerCase(r.title), 'xe')}">
                                                            <c:set var="serviceClass" value="service-shuttle" />
                                                        </c:when>
                                                        <c:when test="${fn:contains(fn:toLowerCase(r.title), 'spa') || fn:contains(fn:toLowerCase(r.title), 'massage') || fn:contains(fn:toLowerCase(r.title), 'trị liệu')}">
                                                            <c:set var="serviceClass" value="service-spa" />
                                                        </c:when>
                                                        <c:when test="${fn:contains(fn:toLowerCase(r.title), 'buffet') || fn:contains(fn:toLowerCase(r.title), 'ăn sáng') || fn:contains(fn:toLowerCase(r.title), 'nhà hàng') || fn:contains(fn:toLowerCase(r.title), 'ẩm thực')}">
                                                            <c:set var="serviceClass" value="service-buffet" />
                                                        </c:when>
                                                        <c:when test="${fn:contains(fn:toLowerCase(r.title), 'hồ bơi') || fn:contains(fn:toLowerCase(r.title), 'bể bơi') || fn:contains(fn:toLowerCase(r.title), 'pool')}">
                                                            <c:set var="serviceClass" value="service-pool" />
                                                        </c:when>
                                                    </c:choose>
                                                    <div class="service-type-cell">
                                                        <span class="service-pill ${serviceClass}">
                                                            <c:out value="${r.title}" />
                                                        </span>
                                                    </div>
                                                </td>

                                                <%-- Thời gian gửi --%>
                                                <td>
                                                    <div class="time-cell">
                                                        <span class="time"><fmt:formatDate value="${r.createdAt}" pattern="HH:mm" /></span>
                                                        <span class="date"><fmt:formatDate value="${r.createdAt}" pattern="dd/MM/yyyy" /></span>
                                                    </div>
                                                </td>

                                                <%-- Trạng thái --%>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${r.status eq 'Pending' || r.status eq 'InProgress'}">
                                                            <span class="status-pill pill-pending">
                                                                <i class="fa-solid fa-circle"></i> Chờ xử lý
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${r.status eq 'Completed'}">
                                                            <span class="status-pill pill-confirmed">
                                                                <i class="fa-solid fa-circle"></i> Đã cấp
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${r.status eq 'Cancelled'}">
                                                            <span class="status-pill pill-rejected">
                                                                <i class="fa-solid fa-circle"></i> Đã hủy
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="status-pill pill-cancelled"><c:out value="${r.status}" /></span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>

                                                <%-- Thao tác --%>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${r.status eq 'Pending' || r.status eq 'InProgress'}">
                                                            <div class="actions-cell">
                                                                <%-- Duyệt hoàn thành --%>
                                                                <form action="${pageContext.request.contextPath}/receptionist/servicerequest" method="POST" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn duyệt hoàn thành yêu cầu này không?');">
                                                                    <input type="hidden" name="requestId" value="${r.requestId}" />
                                                                    <input type="hidden" name="action" value="approve" />
                                                                    <button type="submit" class="btn-req-action btn-req-approve" title="Duyệt hoàn thành">
                                                                        <i class="fa-solid fa-check"></i>
                                                                    </button>
                                                                </form>

                                                                <%-- Hủy yêu cầu --%>
                                                                <form action="${pageContext.request.contextPath}/receptionist/servicerequest" method="POST" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn hủy yêu cầu này không?');">
                                                                    <input type="hidden" name="requestId" value="${r.requestId}" />
                                                                    <input type="hidden" name="action" value="cancel" />
                                                                    <button type="submit" class="btn-req-action btn-req-cancel" title="Hủy yêu cầu">
                                                                        <i class="fa-solid fa-xmark"></i>
                                                                    </button>
                                                                </form>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="color:var(--text-muted)">—</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:otherwise>
                        </c:choose>
                    </div><%-- end table-card --%>

                    <%-- Pagination --%>
                    <c:if test="${totalPages > 1}">
                        <div class="pagination-container">
                            <div class="pagination-info">
                                Hiển thị ${(currentPage-1)*pageSize + 1}-${currentPage*pageSize gt totalItems ? totalItems : currentPage*pageSize} trong số ${totalItems} yêu cầu dịch vụ
                            </div>
                            <div class="pagination-buttons">
                                <!-- Nút Trước -->
                                <a class="btn-page ${currentPage == 1 ? 'disabled' : ''}" 
                                   href="?tab=servicerequests&status=${currentStatus}&keyword=${keyword}&page=${currentPage-1}">
                                    <i class="fa-solid fa-chevron-left"></i>
                                </a>

                                <!-- Các trang số -->
                                <c:forEach var="p" begin="1" end="${totalPages}">
                                    <a class="btn-page ${p == currentPage ? 'active-page' : ''}" 
                                       href="?tab=servicerequests&status=${currentStatus}&keyword=${keyword}&page=${p}">
                                        ${p}
                                    </a>
                                </c:forEach>

                                <!-- Nút Tiếp theo -->
                                <a class="btn-page ${currentPage == totalPages ? 'disabled' : ''}" 
                                   href="?tab=servicerequests&status=${currentStatus}&keyword=${keyword}&page=${currentPage+1}">
                                    <i class="fa-solid fa-chevron-right"></i>
                                </a>
                            </div>
                        </div>
                    </c:if>

                </main>

                <footer class="dashboard-footer">
                    <span>HotelOps Pro &copy; 2026</span>
                    <span>Đăng nhập: <strong>${sessionScope.user}</strong></span>
                </footer>
            </div><%-- end dashboard-main --%>
        </div><%-- end dashboard-layout --%>

        <script src="${pageContext.request.contextPath}/assets/js/receptionist.js?v=5" charset="UTF-8"></script>
    </body>
</html>
