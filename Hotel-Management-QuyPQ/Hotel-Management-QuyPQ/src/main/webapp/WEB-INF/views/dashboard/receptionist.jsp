<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ include file="../../includes/taglibs.jsp" %>
        <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>Quản lý đặt phòng - HotelOps Pro</title>
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
                    rel="stylesheet" />
                <link rel="stylesheet"
                    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/receptionist.css?v=5" />
            </head>
            <fmt:setLocale value="vi_VN" />

            <body class="dashboard-body">

                <%--==========Active Tab==========--%>
                    <c:set var="currentTab" value="${param.tab != null ? param.tab : 'bookings'}" />

                    <div class="dashboard-layout">

                        <!-- ================= SIDEBAR ================= -->
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

                                <li class="menu-item ${currentTab eq 'checkin' ? 'active' : ''}">
                                    <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=checkin">
                                        <i class="fa-solid fa-key"></i> <span>Nhận phòng (Check-in)</span>
                                    </a>
                                </li>

                                <li class="menu-item ${currentTab eq 'checkout' ? 'active' : ''}">
                                    <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=checkout">
                                        <i class="fa-solid fa-right-from-bracket"></i> <span>Trả phòng & Thanh
                                            toán</span>
                                    </a>
                                </li>

                                <li class="menu-item ${currentTab eq 'roommap' ? 'active' : ''}">
                                    <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=roommap">
                                        <i class="fa-solid fa-map"></i> <span>Sơ đồ phòng</span>
                                    </a>
                                </li>

                                <li class="menu-item ${currentTab eq 'walkin-bookings' ? 'active' : ''}">
                                    <a
                                        href="${pageContext.request.contextPath}/receptionist/dashboard?tab=walkin-bookings">
                                        <i class="fa-solid fa-user-plus"></i> <span>Đặt phòng tại quầy</span>
                                    </a>
                                </li>


                                <li class="menu-item ${currentTab eq 'servicerequests' ? 'active' : ''}">
                                    <a
                                        href="${pageContext.request.contextPath}/receptionist/dashboard?tab=servicerequests">
                                        <i class="fa-solid fa-bell-concierge"></i> <span>Quản lý yêu cầu dịch vụ</span>
                                    </a>
                                </li>
                            </ul>

                            <div class="sidebar-footer">
                                <a href="${pageContext.request.contextPath}/profile" class="user-profile-card"
                                    title="Xem hồ sơ cá nhân" style="text-decoration:none;cursor:pointer;">
                                    <div class="profile-avatar">RC</div>
                                    <div class="profile-info">
                                        <span class="profile-name">${not empty sessionScope.user ? sessionScope.user :
                                            'Receptionist'}</span>
                                        <span class="profile-role">Lễ tân</span>
                                    </div>
                                </a>
                            </div>
                        </aside>

                        <%--=================MAIN CONTENT=================--%>
                            <div class="dashboard-main">

                                <%-- TOPBAR --%>
                                    <header class="main-topbar">
                                        <div class="breadcrumb">
                                            <span>Receptionist</span>
                                            <span class="separator">&gt;</span>
                                            <span class="current">
                                                <c:choose>
                                                    <c:when test="${currentTab eq 'bookings'}">Quản lý đặt phòng
                                                    </c:when>
                                                    <c:when test="${currentTab eq 'roommap'}">Sơ đồ phòng</c:when>
                                                    <c:when test="${currentTab eq 'checkin'}">Nhận phòng (Check-in)
                                                    </c:when>
                                                    <c:when test="${currentTab eq 'walkin-bookings'}">Đặt phòng tại quầy
                                                    </c:when>
                                                    <c:when test="${currentTab eq 'checkout'}">Trả phòng & Thanh toán
                                                    </c:when>
                                                    <c:when test="${currentTab eq 'servicerequests'}">Quản lý yêu cầu
                                                        dịch vụ</c:when>
                                                    <c:otherwise>Receptionist Dashboard</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                                            <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                                        </a>
                                    </header>

                                    <%-- WORKSPACE --%>
                                        <main class="workspace-content">

                                            <%--=====BOOKING TAB=====--%>
                                                <c:if test="${currentTab eq 'bookings'}">

                                                    <%-- Toast notification --%>
                                                        <c:if test="${param.result eq 'success'}">
                                                            <div class="toast-notify toast-success">
                                                                <i class="fa-solid fa-circle-check"></i>
                                                                <c:choose>
                                                                    <c:when test="${param.action eq 'confirm'}">Đã xác
                                                                        nhận booking thành công!</c:when>
                                                                    <c:when test="${param.action eq 'reject'}">Đã từ
                                                                        chối booking.</c:when>
                                                                    <c:when test="${param.action eq 'update'}">Đã cập
                                                                        nhật thông tin booking!</c:when>
                                                                    <c:when test="${param.action eq 'cancel'}">Đã huỷ
                                                                        booking.</c:when>
                                                                    <c:otherwise>Thao tác thành công!</c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </c:if>
                                                        <c:if test="${param.result eq 'fail'}">
                                                            <div class="toast-notify toast-error">
                                                                <i class="fa-solid fa-circle-xmark"></i>
                                                                Thao tác thất bại. Vui lòng kiểm tra lại dữ liệu.
                                                            </div>
                                                        </c:if>
                                                        <c:if test="${not empty param.error}">
                                                            <div class="toast-notify toast-error">
                                                                <i class="fa-solid fa-circle-xmark"></i>
                                                                <c:choose>
                                                                    <c:when test="${param.error eq 'parse'}">Lỗi định
                                                                        dạng dữ liệu (ngày hoặc số không hợp lệ).
                                                                    </c:when>
                                                                    <c:when test="${param.error eq 'invalid'}">Mã yêu
                                                                        cầu hoặc trạng thái không hợp lệ.</c:when>
                                                                    <c:when test="${param.error eq 'validation'}">Thông
                                                                        tin không hợp lệ: vui lòng kiểm tra lại điều
                                                                        kiện nhập liệu.</c:when>
                                                                    <c:otherwise>Đã có lỗi xảy ra. Vui lòng thử lại sau.
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </c:if>

                                                        <%-- Header --%>
                                                            <div class="content-header-row">
                                                                <div>
                                                                    <h2><i class="fa-solid fa-calendar-check"
                                                                            style="color:var(--brand-blue);margin-right:8px"></i>Yêu
                                                                        cầu đặt phòng</h2>
                                                                    <p>Xem, xác nhận, từ chối và cập nhật các yêu cầu
                                                                        đặt phòng của khách hàng.</p>
                                                                </div>
                                                            </div>

                                                            <%-- Status filter tabs --%>
                                                                <div class="status-tabs">
                                                                    <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings&status=All"
                                                                        class="status-tab ${currentStatus eq 'All' ? 'active' : ''}">
                                                                        Tất cả <span class="tab-count">${cntAll}</span>
                                                                    </a>
                                                                    <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings&status=Pending"
                                                                        class="status-tab ${currentStatus eq 'Pending' ? 'active' : ''}">
                                                                        <i class="fa-solid fa-clock"
                                                                            style="font-size:11px"></i>
                                                                        Chờ xử lý <span
                                                                            class="tab-count">${cntPending}</span>
                                                                    </a>
                                                                    <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings&status=Confirmed"
                                                                        class="status-tab ${currentStatus eq 'Confirmed' ? 'active' : ''}">
                                                                        <i class="fa-solid fa-circle-check"
                                                                            style="font-size:11px"></i>
                                                                        Đã xác nhận <span
                                                                            class="tab-count">${cntConfirmed}</span>
                                                                    </a>
                                                                    <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings&status=Rejected"
                                                                        class="status-tab ${currentStatus eq 'Rejected' ? 'active' : ''}">
                                                                        <i class="fa-solid fa-circle-xmark"
                                                                            style="font-size:11px"></i>
                                                                        Đã từ chối <span
                                                                            class="tab-count">${cntRejected}</span>
                                                                    </a>
                                                                    <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings&status=Cancelled"
                                                                        class="status-tab ${currentStatus eq 'Cancelled' ? 'active' : ''}">
                                                                        Đã huỷ <span
                                                                            class="tab-count">${cntCancelled}</span>
                                                                    </a>
                                                                </div>

                                                                <%-- Search bar --%>
                                                                    <form method="get"
                                                                        action="${pageContext.request.contextPath}/receptionist/dashboard">
                                                                        <input type="hidden" name="tab"
                                                                            value="bookings" />
                                                                        <input type="hidden" name="status"
                                                                            value="${currentStatus}" />
                                                                        <div class="table-filter-bar">

                                                                            <!-- Search bên trái -->
                                                                            <div
                                                                                style="display:flex;align-items:center;gap:8px;">

                                                                                <div class="search-wrapper">
                                                                                    <i
                                                                                        class="fa-solid fa-magnifying-glass"></i>
                                                                                    <input type="text" name="keyword"
                                                                                        class="search-input"
                                                                                        placeholder="Tìm tên khách hoặc mã booking..."
                                                                                        value="${keyword}" />
                                                                                </div>

                                                                                <button type="submit"
                                                                                    style="height:40px;padding:0 16px;background:var(--brand-blue);color:#fff;border:none;border-radius:8px;font-weight:600;font-size:13px;cursor:pointer;">
                                                                                    Tìm kiếm
                                                                                </button>

                                                                                <c:if test="${not empty keyword}">
                                                                                    <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings&status=${currentStatus}"
                                                                                        style="height:40px;padding:0 14px;display:inline-flex;align-items:center;border:1px solid var(--border-color);border-radius:8px;font-size:13px;color:var(--text-muted);text-decoration:none;">
                                                                                        <i class="fa-solid fa-xmark"
                                                                                            style="margin-right:6px"></i>
                                                                                        Xoá lọc
                                                                                    </a>
                                                                                </c:if>

                                                                            </div>

                                                                            <!-- Pagination bên phải -->
                                                                            <div
                                                                                style="margin-left:auto;display:flex;align-items:center;gap:8px;">

                                                                                <%-- Gmail-style counter --%>
                                                                                    <span
                                                                                        style="font-size:13px; color:var(--text-muted); white-space:nowrap;">
                                                                                        ${(currentPage - 1) * 8 +
                                                                                        1}–${(currentPage - 1) * 8 +
                                                                                        fn:length(bookingList)}
                                                                                        trong số
                                                                                        <strong>${totalItems}</strong>
                                                                                    </span>

                                                                                    <c:if test="${currentPage > 1}">
                                                                                        <a class="btn-action-icon"
                                                                                            href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings&page=${currentPage-1}&status=${currentStatus}&keyword=${keyword}">
                                                                                            <i
                                                                                                class="fa-solid fa-chevron-left"></i>
                                                                                        </a>
                                                                                    </c:if>
                                                                                    <c:if
                                                                                        test="${currentPage < totalPages}">
                                                                                        <a class="btn-action-icon"
                                                                                            href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings&page=${currentPage+1}&status=${currentStatus}&keyword=${keyword}">
                                                                                            <i
                                                                                                class="fa-solid fa-chevron-right"></i>
                                                                                        </a>
                                                                                    </c:if>

                                                                            </div>

                                                                        </div>
                                                                    </form>

                                                                    <%-- Table --%>
                                                                        <div class="table-card">
                                                                            <c:choose>

                                                                                <c:when test="${empty bookingList}">
                                                                                    <div class="empty-state">
                                                                                        <i
                                                                                            class="fa-solid fa-inbox"></i>
                                                                                        <p>Không có yêu cầu đặt phòng
                                                                                            nào.</p>
                                                                                    </div>
                                                                                </c:when>

                                                                                <c:otherwise>
                                                                                    <table class="booking-table">
                                                                                        <thead>
                                                                                            <tr>
                                                                                                <th>Mã</th>
                                                                                                <th>Khách hàng</th>
                                                                                                <th>Loại phòng</th>
                                                                                                <th>Ngày nhận / trả</th>
                                                                                                <th>Tổng tiền</th>
                                                                                                <th>Trạng thái</th>
                                                                                                <th>Thao tác</th>
                                                                                            </tr>
                                                                                        </thead>
                                                                                        <tbody>
                                                                                            <c:forEach var="b"
                                                                                                items="${bookingList}">
                                                                                                <tr>
                                                                                                    <%-- Mã --%>
                                                                                                        <td>
                                                                                                            <span
                                                                                                                class="booking-id-badge">#${b.bookingId}</span>
                                                                                                        </td>

                                                                                                        <%-- Khách hàng
                                                                                                            --%>
                                                                                                            <td>
                                                                                                                <div
                                                                                                                    class="customer-cell">
                                                                                                                    <div
                                                                                                                        class="name">
                                                                                                                        <c:out
                                                                                                                            value="${b.customerName}" />
                                                                                                                    </div>
                                                                                                                    <div
                                                                                                                        class="meta">
                                                                                                                        Đặt:
                                                                                                                        ${b.createdAt}
                                                                                                                    </div>
                                                                                                                </div>
                                                                                                            </td>

                                                                                                            <%-- Loại
                                                                                                                phòng
                                                                                                                --%>
                                                                                                                <td>
                                                                                                                    <c:choose>
                                                                                                                        <c:when
                                                                                                                            test="${not empty b.groupRoomTypeNames}">
                                                                                                                            <span
                                                                                                                                class="roomtype-badge">
                                                                                                                                <c:out
                                                                                                                                    value="${b.groupRoomTypeNames}" />
                                                                                                                            </span>
                                                                                                                            <br /><small
                                                                                                                                style="color:var(--text-muted)">${b.totalRoomQuantity}
                                                                                                                                phòng</small>
                                                                                                                        </c:when>
                                                                                                                        <c:otherwise>
                                                                                                                            <span
                                                                                                                                style="color:var(--text-muted)">—</span>
                                                                                                                        </c:otherwise>
                                                                                                                    </c:choose>
                                                                                                                </td>

                                                                                                                <%-- Ngày
                                                                                                                    --%>
                                                                                                                    <td>
                                                                                                                        <div
                                                                                                                            class="date-range">
                                                                                                                            ${b.checkInDate}
                                                                                                                            →
                                                                                                                            ${b.checkOutDate}
                                                                                                                            <span
                                                                                                                                class="nights">${b.nights}
                                                                                                                                đêm</span>
                                                                                                                        </div>
                                                                                                                        <div
                                                                                                                            style="margin-top: 4px; font-size: 11px;">
                                                                                                                            <c:choose>
                                                                                                                                <c:when
                                                                                                                                    test="${not empty b.assignedRoomsStr}">
                                                                                                                                    <span
                                                                                                                                        style="color: var(--brand-blue); font-weight: 600;">
                                                                                                                                        <i class="fa-solid fa-door-open"
                                                                                                                                            style="margin-right: 4px;"></i>
                                                                                                                                        Phòng:
                                                                                                                                        ${b.assignedRoomsStr}
                                                                                                                                    </span>
                                                                                                                                </c:when>
                                                                                                                                <c:otherwise>
                                                                                                                                    <span
                                                                                                                                        style="color: var(--text-muted); font-style: italic;">
                                                                                                                                        <i class="fa-solid fa-door-closed"
                                                                                                                                            style="margin-right: 4px; opacity: 0.5;"></i>
                                                                                                                                        Chưa
                                                                                                                                        phân
                                                                                                                                        phòng
                                                                                                                                    </span>
                                                                                                                                </c:otherwise>
                                                                                                                            </c:choose>
                                                                                                                        </div>
                                                                                                                    </td>


                                                                                                                    <%-- Tổng
                                                                                                                        tiền
                                                                                                                        --%>
                                                                                                                        <td
                                                                                                                            class="amount-cell">
                                                                                                                            <fmt:formatNumber
                                                                                                                                value="${b.overallTotalAmount}"
                                                                                                                                type="number"
                                                                                                                                groupingUsed="true" />
                                                                                                                            đ
                                                                                                                        </td>

                                                                                                                        <%-- Trạng
                                                                                                                            thái
                                                                                                                            --%>
                                                                                                                            <td>
                                                                                                                                <c:choose>
                                                                                                                                    <c:when
                                                                                                                                        test="${b.status eq 'Pending'}">
                                                                                                                                        <span
                                                                                                                                            class="status-pill pill-pending">
                                                                                                                                            <i
                                                                                                                                                class="fa-solid fa-circle"></i>
                                                                                                                                            Chờ
                                                                                                                                            xử
                                                                                                                                            lý
                                                                                                                                        </span>
                                                                                                                                    </c:when>
                                                                                                                                    <c:when
                                                                                                                                        test="${b.status eq 'Confirmed'}">
                                                                                                                                        <span
                                                                                                                                            class="status-pill pill-confirmed">
                                                                                                                                            <i
                                                                                                                                                class="fa-solid fa-circle"></i>
                                                                                                                                            Đã
                                                                                                                                            xác
                                                                                                                                            nhận
                                                                                                                                        </span>
                                                                                                                                    </c:when>
                                                                                                                                    <c:when
                                                                                                                                        test="${b.status eq 'Rejected'}">
                                                                                                                                        <span
                                                                                                                                            class="status-pill pill-rejected">
                                                                                                                                            <i
                                                                                                                                                class="fa-solid fa-circle"></i>
                                                                                                                                            Từ
                                                                                                                                            chối
                                                                                                                                        </span>
                                                                                                                                    </c:when>
                                                                                                                                    <c:when
                                                                                                                                        test="${b.status eq 'Cancelled'}">
                                                                                                                                        <span
                                                                                                                                            class="status-pill pill-cancelled">
                                                                                                                                            <i
                                                                                                                                                class="fa-solid fa-circle"></i>
                                                                                                                                            Đã
                                                                                                                                            huỷ
                                                                                                                                        </span>
                                                                                                                                    </c:when>
                                                                                                                                    <c:when
                                                                                                                                        test="${b.status eq 'CheckedIn'}">
                                                                                                                                        <span
                                                                                                                                            class="status-pill pill-checkedin">
                                                                                                                                            <i
                                                                                                                                                class="fa-solid fa-circle"></i>
                                                                                                                                            Đã
                                                                                                                                            check-in
                                                                                                                                        </span>
                                                                                                                                    </c:when>
                                                                                                                                    <c:when
                                                                                                                                        test="${b.status eq 'CheckedOut'}">
                                                                                                                                        <span
                                                                                                                                            class="status-pill pill-checkedout">
                                                                                                                                            <i
                                                                                                                                                class="fa-solid fa-circle"></i>
                                                                                                                                            Đã
                                                                                                                                            trả
                                                                                                                                            phòng
                                                                                                                                        </span>
                                                                                                                                    </c:when>
                                                                                                                                    <c:otherwise>
                                                                                                                                        <span
                                                                                                                                            class="status-pill pill-cancelled">
                                                                                                                                            <c:out
                                                                                                                                                value="${b.status}" />
                                                                                                                                        </span>
                                                                                                                                    </c:otherwise>
                                                                                                                                </c:choose>
                                                                                                                            </td>

                                                                                                                            <%-- Thao
                                                                                                                                tác
                                                                                                                                --%>
                                                                                                                                <td>
                                                                                                                                    <div
                                                                                                                                        class="actions-cell">
                                                                                                                                        <%-- Xem
                                                                                                                                            chi
                                                                                                                                            tiết
                                                                                                                                            --%>
                                                                                                                                            <a href="${pageContext.request.contextPath}/receptionist/booking/detail?bookingId=${b.bookingId}"
                                                                                                                                                class="btn-action-icon btn-edit"
                                                                                                                                                title="Xem chi tiết">
                                                                                                                                                <i
                                                                                                                                                    class="fa-solid fa-eye"></i>
                                                                                                                                            </a>

                                                                                                                                            <%-- Cập
                                                                                                                                                nhật
                                                                                                                                                thông
                                                                                                                                                tin
                                                                                                                                                (chỉ
                                                                                                                                                Pending
                                                                                                                                                hoặc
                                                                                                                                                Confirmed)
                                                                                                                                                --%>
                                                                                                                                                <c:if
                                                                                                                                                    test="${b.status eq 'Pending' || b.status eq 'Confirmed'}">
                                                                                                                                                    <a href="${pageContext.request.contextPath}/receptionist/booking/process?bookingId=${b.bookingId}"
                                                                                                                                                        class="btn-action-icon btn-edit"
                                                                                                                                                        title="Cập nhật & Duyệt">
                                                                                                                                                        <i
                                                                                                                                                            class="fa-solid fa-pen-to-square"></i>
                                                                                                                                                    </a>
                                                                                                                                                </c:if>
                                                                                                                                    </div>
                                                                                                                                </td>
                                                                                                </tr>
                                                                                            </c:forEach>
                                                                                        </tbody>
                                                                                    </table>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </div><%-- end table-card --%>

                                                </c:if><%-- end bookings tab --%>
                                                    <%--=====ROOM MAP TAB=====--%>
                                                        <c:if test="${currentTab eq 'roommap'}">

                                                            <div class="content-header-row">
                                                                <div>
                                                                    <h2>
                                                                        <i class="fa-solid fa-map"
                                                                            style="color:var(--brand-blue);margin-right:8px"></i>
                                                                        Sơ đồ phòng
                                                                    </h2>
                                                                    <p>Danh sách toàn bộ phòng theo từng tầng</p>
                                                                </div>
                                                            </div>

                                                            <!-- FILTER -->
                                                            <!-- FORM TÌM KIẾM THEO NGÀY -->
                                                            <form method="get"
                                                                action="${pageContext.request.contextPath}/receptionist/dashboard"
                                                                class="roommap-filter-form">

                                                                <input type="hidden" name="tab" value="roommap" />

                                                                <div class="roommap-filter-row">

                                                                    <div class="form-group">
                                                                        <label>Từ ngày</label>
                                                                        <input type="date" name="fromDate"
                                                                            value="${fromDate}" class="walkin-input">
                                                                    </div>

                                                                    <div class="form-group">
                                                                        <label>Đến ngày</label>
                                                                        <input type="date" name="toDate"
                                                                            value="${toDate}" class="walkin-input">
                                                                    </div>

                                                                    <button type="submit" class="btn-roommap-search">
                                                                        <i class="fa-solid fa-magnifying-glass"></i>
                                                                        Kiểm tra phòng
                                                                    </button>

                                                                </div>
                                                            </form>
                                                            <form method="get"
                                                                action="${pageContext.request.contextPath}/receptionist/dashboard">

                                                                <input type="hidden" name="tab" value="roommap" />

                                                                <input type="hidden" name="fromDate"
                                                                    value="${fromDate}" />

                                                                <input type="hidden" name="toDate" value="${toDate}" />

                                                                <div class="status-tabs">

                                                                    <button type="submit" name="status" value="All"
                                                                        class="status-tab ${currentStatus eq 'All' ? 'active' : ''}">
                                                                        Tất cả
                                                                    </button>

                                                                    <button type="submit" name="status"
                                                                        value="Available"
                                                                        class="status-tab ${currentStatus eq 'Available' ? 'active' : ''}">
                                                                        Trống
                                                                    </button>

                                                                    <button type="submit" name="status" value="Occupied"
                                                                        class="status-tab ${currentStatus eq 'Occupied' ? 'active' : ''}">
                                                                        Đang sử dụng
                                                                    </button>

                                                                    <button type="submit" name="status"
                                                                        value="Maintenance"
                                                                        class="status-tab ${currentStatus eq 'Maintenance' ? 'active' : ''}">
                                                                        Bảo trì
                                                                    </button>
                                                                </div>
                                                            </form>

                                                            <!-- ROOM MAP -->
                                                            <div class="roommap-container">

                                                                <c:choose>

                                                                    <c:when test="${empty roomByFloor}">
                                                                        <div class="empty-state">
                                                                            <i class="fa-solid fa-door-closed"></i>
                                                                            <p>Không có phòng nào</p>
                                                                        </div>
                                                                    </c:when>

                                                                    <c:otherwise>

                                                                        <c:forEach var="entry" items="${roomByFloor}">

                                                                            <div class="floor-block">

                                                                                <div class="floor-title">
                                                                                    <div class="floor-name">
                                                                                        Tầng ${entry.key}
                                                                                    </div>
                                                                                    <div class="floor-room-count">
                                                                                        ${fn:length(entry.value)} phòng
                                                                                    </div>
                                                                                </div>

                                                                                <div class="room-grid">

                                                                                    <c:forEach var="room"
                                                                                        items="${entry.value}">

                                                                                        <div
                                                                                            class="room-card status-${room.status}">

                                                                                            <div
                                                                                                class="room-card-header">
                                                                                                <div
                                                                                                    class="room-number">
                                                                                                    ${room.roomNumber}
                                                                                                </div>
                                                                                                <div class="room-floor">
                                                                                                    ${room.typeName}
                                                                                                </div>
                                                                                            </div>

                                                                                            <div class="room-card-body">
                                                                                                <span
                                                                                                    class="badge-status badge-${room.status}">
                                                                                                    ${room.status}
                                                                                                </span>
                                                                                            </div>

                                                                                        </div>
                                                                                    </c:forEach>
                                                                                </div>
                                                                            </div>
                                                                        </c:forEach>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </c:if>
                                                        <%--=====CHECK-IN TAB (ITERATION 2/3)=====--%>
                                                            <c:if test="${currentTab eq 'checkin'}">
                                                                <c:if test="${param.checkinSuccess == '1'}">
                                                                    <div id="toastCheckin" class="checkin-toast">
                                                                        <span>
                                                                            Đã check in thành công cho khách
                                                                            <b>${param.customerName}</b>
                                                                        </span>

                                                                        <button class="toast-close"
                                                                            onclick="closeCheckinToast()">×</button>
                                                                    </div>
                                                                </c:if>
                                                                <div class="content-header-row">
                                                                    <div>
                                                                        <h2>
                                                                            <i class="fa-solid fa-key"
                                                                                style="color:var(--brand-blue);margin-right:8px"></i>
                                                                            Nhận phòng (Check-in)
                                                                        </h2>
                                                                        <p>Quản lý khách nhận phòng.</p>
                                                                    </div>
                                                                </div>

                                                                <form method="get"
                                                                    action="${pageContext.request.contextPath}/receptionist/dashboard">

                                                                    <input type="hidden" name="tab" value="checkin" />
                                                                    <input type="hidden" name="page" value="1" />

                                                                    <div class="table-filter-bar">

                                                                        <div class="search-wrapper">
                                                                            <i class="fa-solid fa-magnifying-glass"></i>

                                                                            <input type="text" name="keyword"
                                                                                class="search-input"
                                                                                placeholder="Tên khách hoặc Booking ID"
                                                                                value="${keyword}" />
                                                                        </div>

                                                                        <button type="submit"
                                                                            style="height:40px;padding:0 16px;background:var(--brand-blue);color:white;border:none;border-radius:8px;">
                                                                            Tìm kiếm
                                                                        </button>

                                                                        <div
                                                                            style="margin-left:auto;display:flex;gap:8px;">
                                                                            <c:if test="${currentPage > 1}">
                                                                                <a class="btn-action-icon"
                                                                                    href="?tab=checkin&page=${currentPage - 1}&keyword=${keyword}">
                                                                                    <i
                                                                                        class="fa-solid fa-chevron-left"></i>
                                                                                </a>
                                                                            </c:if>

                                                                            <c:if test="${currentPage < totalPages}">
                                                                                <a class="btn-action-icon"
                                                                                    href="?tab=checkin&page=${currentPage + 1}&keyword=${keyword}">
                                                                                    <i
                                                                                        class="fa-solid fa-chevron-right"></i>
                                                                                </a>
                                                                            </c:if>
                                                                        </div>

                                                                    </div>

                                                                </form>

                                                                <div class="table-card">

                                                                    <table class="booking-table">

                                                                        <thead>
                                                                            <tr>
                                                                                <th>Mã đặt phòng</th>
                                                                                <th>Khách hàng</th>
                                                                                <th>Loại phòng</th>
                                                                                <th>Ngày đến</th>
                                                                                <th>Ngày đi</th>
                                                                                <th>Trạng thái</th>
                                                                                <th>Thao tác</th>
                                                                            </tr>
                                                                        </thead>

                                                                        <tbody>

                                                                            <c:forEach var="b" items="${checkInList}">

                                                                                <tr>

                                                                                    <td>
                                                                                        <span class="booking-id-badge">
                                                                                            #${b.bookingId}
                                                                                        </span>
                                                                                    </td>

                                                                                    <td>${b.customerName}</td>

                                                                                    <td>${b.groupRoomTypeNames}</td>

                                                                                    <td>${b.checkInDate}</td>

                                                                                    <td>${b.checkOutDate}</td>

                                                                                    <td>

                                                                                        <c:choose>

                                                                                            <c:when
                                                                                                test="${b.status eq 'Confirmed'}">
                                                                                                <span
                                                                                                    class="status-pill pill-confirmed">
                                                                                                    Đã xác nhận
                                                                                                </span>
                                                                                            </c:when>

                                                                                            <c:when
                                                                                                test="${b.status eq 'CheckedIn'}">
                                                                                                <span
                                                                                                    class="status-pill pill-checkedin">
                                                                                                    Đã check in
                                                                                                </span>
                                                                                            </c:when>

                                                                                            <c:when
                                                                                                test="${b.status eq 'CheckedOut'}">
                                                                                                <span
                                                                                                    class="status-pill pill-checkedout">
                                                                                                    Đã check out
                                                                                                </span>
                                                                                            </c:when>

                                                                                        </c:choose>

                                                                                    </td>

                                                                                    <td>

                                                                                        <c:choose>

                                                                                            <c:when
                                                                                                test="${b.status eq 'Confirmed'}">

                                                                                                <a class="btn-action-icon btn-edit"
                                                                                                    href="${pageContext.request.contextPath}/receptionist/checkin-detail?bookingId=${b.bookingId}">
                                                                                                    <i
                                                                                                        class="fa-solid fa-key"></i>
                                                                                                    Check In
                                                                                                </a>
                                                                                            </c:when>

                                                                                            <c:when
                                                                                                test="${b.status eq 'CheckedIn'}">

                                                                                                <span
                                                                                                    style="color:#10b981;font-weight:600">
                                                                                                    Đã check in
                                                                                                </span>

                                                                                            </c:when>

                                                                                            <c:when
                                                                                                test="${b.status eq 'CheckedOut'}">

                                                                                                <span
                                                                                                    style="color:#64748b;font-weight:600">
                                                                                                    Đã check out
                                                                                                </span>
                                                                                            </c:when>
                                                                                        </c:choose>
                                                                                    </td>
                                                                                </tr>
                                                                            </c:forEach>
                                                                        </tbody>
                                                                    </table>
                                                                </div>
                                                            </c:if>
                                                            <%--=====WALK-IN BOOKING TAB=====--%>
                                                                <c:if test="${currentTab eq 'walkin-bookings'}">
                                                                    <form method="post"
                                                                        action="${pageContext.request.contextPath}/receptionist/walkin-booking"
                                                                        onsubmit="return validateWalkInSubmit()">
                                                                        <input type="hidden" id="bookingMode"
                                                                            name="bookingMode" value="BOOKING">
                                                                        <%--=================HEADER=================--%>
                                                                            <div class="content-header-row">
                                                                                <div>
                                                                                    <h2>
                                                                                        <i class="fa-solid fa-user-plus"
                                                                                            style="color:var(--brand-blue);margin-right:8px"></i>
                                                                                        Đặt phòng tại quầy
                                                                                    </h2>
                                                                                    <p>
                                                                                        Tạo booking trực tiếp cho khách
                                                                                        hàng tại quầy lễ tân.
                                                                                    </p>
                                                                                </div>
                                                                                <div class="walkin-mode-card">
                                                                                    <label class="mode-option">
                                                                                        <input type="radio"
                                                                                            name="walkinMode"
                                                                                            value="booking" checked>
                                                                                        <span>📅 Đặt phòng</span>
                                                                                    </label>
                                                                                    <label class="mode-option">
                                                                                        <input type="radio"
                                                                                            name="walkinMode"
                                                                                            value="checkin">
                                                                                        <span>🏨 Check In</span>
                                                                                    </label>
                                                                                </div>
                                                                            </div>
                                                                            <div id="searchAccountMessage"
                                                                                class="search-account-message hidden">
                                                                            </div>
                                                                            <div class="walkin-search-account">
                                                                                <input id="searchAccountKeyword"
                                                                                    class="walkin-input"
                                                                                    placeholder="Nhập Email hoặc SĐT">
                                                                                <button type="button"
                                                                                    class="btn-search-account"
                                                                                    onclick="searchAccount()">
                                                                                    <i
                                                                                        class="fa-solid fa-magnifying-glass"></i>
                                                                                    Tìm tài khoản
                                                                                </button>
                                                                            </div>
                                                                            <!-- ========================================================= 
                                    CARD 1 - THÔNG TIN KHÁCH HÀNG 
                            ========================================================= -->
                                                                            <div class="walkin-card">
                                                                                <div class="walkin-section-header">
                                                                                    <div>
                                                                                        <i class="fa-solid fa-user"></i>
                                                                                        Thông tin khách hàng
                                                                                        <span id="customerInfoMessage"
                                                                                            class="customer-info-message hidden"></span>
                                                                                    </div>
                                                                                </div>
                                                                                <div class="walkin-grid">
                                                                                    <!-- HÀNG 1 -->
                                                                                    <div class="walkin-row-3">
                                                                                        <div
                                                                                            class="form-group form-group-large">
                                                                                            <label>Họ và tên *</label>
                                                                                            <input type="text"
                                                                                                id="customerName"
                                                                                                name="customerName"
                                                                                                class="walkin-input">
                                                                                        </div>
                                                                                        <div class="form-group">
                                                                                            <label>Số điện thoại
                                                                                                *</label>
                                                                                            <input type="text"
                                                                                                id="phone" name="phone"
                                                                                                class="walkin-input"
                                                                                                maxlength="10"
                                                                                                inputmode="numeric">
                                                                                        </div>
                                                                                        <div class="form-group">
                                                                                            <label>Email</label>
                                                                                            <input type="email"
                                                                                                id="email" name="email"
                                                                                                class="walkin-input">
                                                                                        </div>
                                                                                    </div>
                                                                                    <!-- HÀNG 2 -->
                                                                                    <div class="walkin-row-2">
                                                                                        <div class="form-group">
                                                                                            <label>Ngày nhận phòng
                                                                                                *</label>
                                                                                            <input type="date"
                                                                                                id="checkInDate"
                                                                                                name="checkInDate"
                                                                                                class="walkin-input">
                                                                                        </div>
                                                                                        <div class="form-group">
                                                                                            <label>Ngày trả phòng
                                                                                                *</label>
                                                                                            <input type="date"
                                                                                                id="checkOutDate"
                                                                                                name="checkOutDate"
                                                                                                class="walkin-input">
                                                                                        </div>
                                                                                    </div>
                                                                                </div>
                                                                            </div>
                                                                            <%--=========================================================CARD
                                                                                2 - CHỌN LOẠI
                                                                                PHÒNG=========================================================--%>
                                                                                <div class="walkin-card">
                                                                                    <div class="walkin-section-header">
                                                                                        <div>
                                                                                            <i
                                                                                                class="fa-solid fa-bed"></i>
                                                                                            Chọn loại phòng
                                                                                            <span id="roomTypeMessage"
                                                                                                class="room-type-message hidden">
                                                                                            </span>
                                                                                        </div>
                                                                                        <button type="button"
                                                                                            class="btn-add-room-type"
                                                                                            onclick="addRoomRow()">
                                                                                            <i
                                                                                                class="fa-solid fa-plus"></i>
                                                                                            Thêm loại phòng
                                                                                        </button>
                                                                                    </div>
                                                                                    <div class="room-header-row">
                                                                                        <span>Loại phòng</span>
                                                                                        <span>Số phòng</span>
                                                                                        <span>Số người</span>
                                                                                        <span></span>
                                                                                    </div>
                                                                                    <div id="roomRowsContainer">
                                                                                        <div
                                                                                            class="room-row first-room-row">
                                                                                            <span
                                                                                                class="room-row-error hidden"></span>
                                                                                            <select name="roomTypeIds[]"
                                                                                                class="walkin-input room-type-select"
                                                                                                onchange="roomTypeChanged(this)">
                                                                                                <option value="">
                                                                                                    -- Chọn loại phòng
                                                                                                    --
                                                                                                </option>
                                                                                                <c:forEach var="rt"
                                                                                                    items="${roomTypesList}">
                                                                                                    <option
                                                                                                        value="${rt.typeId}"
                                                                                                        data-price="${rt.basePrice}"
                                                                                                        data-capacity="${rt.capacity}">
                                                                                                        ${rt.typeName}
                                                                                                    </option>
                                                                                                </c:forEach>
                                                                                            </select>
                                                                                            <input type="number"
                                                                                                name="roomQuantities[]"
                                                                                                class="walkin-input room-qty-input"
                                                                                                min="1" value="1"
                                                                                                onchange="roomQtyChanged(this)"
                                                                                                required>
                                                                                            <input type="number"
                                                                                                name="guestCounts[]"
                                                                                                class="walkin-input guest-input"
                                                                                                min="1" value="1"
                                                                                                oninput="updateSummary()"
                                                                                                required>
                                                                                            <button type="button"
                                                                                                class="btn-delete-row"
                                                                                                style="display:none">
                                                                                                <i
                                                                                                    class="fa-solid fa-trash"></i>
                                                                                            </button>
                                                                                        </div>
                                                                                    </div>
                                                                                </div>
                                                                                <%--=========================================================CARD
                                                                                    3 - SƠ ĐỒ
                                                                                    PHÒNG=========================================================--%>
                                                                                    <div class="walkin-card">
                                                                                        <div
                                                                                            class="walkin-section-header">
                                                                                            <div>
                                                                                                <i
                                                                                                    class="fa-solid fa-map"></i>
                                                                                                Sơ đồ phòng
                                                                                            </div>
                                                                                        </div>
                                                                                        <div
                                                                                            id="availableRoomsContainer">
                                                                                            <div
                                                                                                class="empty-room-message">
                                                                                                Chọn ngày nhận phòng,
                                                                                                trả phòng và loại phòng
                                                                                            </div>
                                                                                        </div>
                                                                                        <%--=========================================================CARD
                                                                                            3.1 - BẠN ĐỒNG
                                                                                            HÀNH=========================================================--%>
                                                                                    </div>
                                                                                    <div class="walkin-card"
                                                                                        id="companionCard"
                                                                                        style="display:none;">
                                                                                        <div
                                                                                            class="walkin-section-header">
                                                                                            <div>
                                                                                                <i
                                                                                                    class="fa-solid fa-users"></i>
                                                                                                Bạn đồng hành
                                                                                            </div>
                                                                                            <button type="button"
                                                                                                class="btn-add-companion"
                                                                                                onclick="addCompanionRow()">
                                                                                                + Thêm bạn đồng hành
                                                                                            </button>
                                                                                        </div>
                                                                                        <div id="companionContainer">
                                                                                        </div>
                                                                                    </div>
                                                                                    <%--=========================================================CARD
                                                                                        4 - YÊU CẦU KHÁCH
                                                                                        HÀNG=========================================================--%>
                                                                                        <div class="walkin-card">
                                                                                            <div
                                                                                                class="walkin-section-header">
                                                                                                <div>
                                                                                                    <i
                                                                                                        class="fa-solid fa-comment-dots"></i>
                                                                                                    Yêu cầu khách hàng
                                                                                                </div>
                                                                                            </div>
                                                                                            <textarea name="note"
                                                                                                id="note"
                                                                                                class="walkin-note"
                                                                                                rows="5"
                                                                                                placeholder="Ví dụ: phòng tầng cao, gần thang máy, giường phụ, yên tĩnh...">
                                </textarea>
                                                                                        </div>
                                                                                        <%--=========================================================CARD
                                                                                            5 - TÓM TẮT ĐẶT
                                                                                            PHÒNG=========================================================--%>
                                                                                            <div class="walkin-card">
                                                                                                <div
                                                                                                    class="walkin-section-header">
                                                                                                    <div>
                                                                                                        <i
                                                                                                            class="fa-solid fa-receipt"></i>
                                                                                                        Tóm tắt đặt
                                                                                                        phòng
                                                                                                    </div>
                                                                                                </div>
                                                                                                <div
                                                                                                    id="bookingSummary">
                                                                                                    <!-- Bảng loại phòng -->
                                                                                                    <table
                                                                                                        class="summary-room-table">
                                                                                                        <thead>
                                                                                                            <tr>
                                                                                                                <th>Loại
                                                                                                                    phòng
                                                                                                                </th>
                                                                                                                <th>Số
                                                                                                                    phòng
                                                                                                                </th>
                                                                                                                <th>Giá
                                                                                                                </th>
                                                                                                            </tr>
                                                                                                        </thead>
                                                                                                        <tbody
                                                                                                            id="summaryRoomTableBody">
                                                                                                        </tbody>
                                                                                                    </table>
                                                                                                    <div
                                                                                                        class="summary-row">
                                                                                                        <span
                                                                                                            class="summary-label">
                                                                                                            Số đêm lưu
                                                                                                            trú
                                                                                                        </span>
                                                                                                        <span
                                                                                                            class="summary-value"
                                                                                                            id="summaryNight">
                                                                                                            0
                                                                                                        </span>
                                                                                                    </div>

                                                                                                    <div
                                                                                                        class="summary-row total">
                                                                                                        <span
                                                                                                            class="summary-label">
                                                                                                            Tổng số tiền
                                                                                                        </span>
                                                                                                        <span
                                                                                                            class="summary-value total-price"
                                                                                                            id="summaryTotal">
                                                                                                            0 VNĐ
                                                                                                        </span>
                                                                                                    </div>
                                                                                                </div>
                                                                                            </div>
                                                                                            <%--=========================================================CARD
                                                                                                6- GHI
                                                                                                CHÚ=========================================================--%>
                                                                                                <div
                                                                                                    class="walkin-card">
                                                                                                    <div
                                                                                                        class="walkin-section-header">
                                                                                                        <div>
                                                                                                            <i
                                                                                                                class="fa-solid fa-clipboard"></i>
                                                                                                            Ghi chú lễ
                                                                                                            tân
                                                                                                        </div>
                                                                                                    </div>
                                                                                                    <textarea
                                                                                                        name="receptionistNote"
                                                                                                        class="walkin-note"
                                                                                                        rows="4"
                                                                                                        placeholder="Ghi chú nội bộ...">
                                </textarea>
                                                                                                </div>
                                                                                                <%--=========================================================FOOTER=========================================================--%>
                                                                                                    <div
                                                                                                        class="walkin-footer">
                                                                                                        <div
                                                                                                            class="privacy-note">
                                                                                                            <i
                                                                                                                class="fa-solid fa-shield-halved"></i>
                                                                                                            <span> Cam
                                                                                                                kết
                                                                                                                chính
                                                                                                                sách bảo
                                                                                                                mật của
                                                                                                                HotelOps
                                                                                                            </span>
                                                                                                        </div>
                                                                                                        <button
                                                                                                            type="submit"
                                                                                                            id="bookingBtn"
                                                                                                            class="btn-booking-submit"
                                                                                                            onclick="return beforeWalkInSubmit('BOOKING')">
                                                                                                            <i
                                                                                                                class="fa-solid fa-calendar-check"></i>
                                                                                                            Đặt phòng
                                                                                                        </button>
                                                                                                        <button
                                                                                                            type="submit"
                                                                                                            id="checkinBtn"
                                                                                                            class="btn-booking-submit"
                                                                                                            onclick="return beforeWalkInSubmit('CHECKIN')">
                                                                                                            <i
                                                                                                                class="fa-solid fa-door-open"></i>
                                                                                                            Check In
                                                                                                        </button>
                                                                                                    </div>
                                                                    </form>
                                                                    <div id="modePopup" class="mode-popup hidden">
                                                                        <div class="mode-popup-icon">
                                                                            <i class="fa-solid fa-circle-info"></i>
                                                                        </div>
                                                                        <div class="mode-popup-content">
                                                                            <div class="mode-popup-title">
                                                                                Chế độ
                                                                            </div>
                                                                            <div id="modePopupMessage">
                                                                            </div>
                                                                        </div>
                                                                        <button type="button" class="mode-popup-close"
                                                                            onclick="hideModePopup()">
                                                                            <i class="fa-solid fa-xmark"></i>
                                                                        </button>
                                                                    </div>
                                                                    <div id="walkinToast" class="walkin-toast">
                                                                        <c:if test="${not empty success}">
                                                                            <script>
                                                                                window.walkInSuccessMessage = "${fn:escapeXml(success)}";
                                                                            </script>
                                                                            <c:remove var="success" scope="session" />
                                                                        </c:if>

                                                                        <c:if test="${not empty error}">
                                                                            <script>
                                                                                window.walkInErrorMessage = "${fn:escapeXml(error)}";
                                                                            </script>
                                                                            <c:remove var="error" scope="session" />
                                                                        </c:if>
                                                                        <span id="walkinToastMessage"></span>

                                                                        <button type="button" class="walkin-toast-close"
                                                                            onclick="hideWalkInToast()">
                                                                            ×
                                                                        </button>
                                                                    </div>
                                                                    <c:if test="${not empty success}">
                                                                        <script>
                                                                            window.addEventListener("DOMContentLoaded", function () {
                                                                                clearWalkInAllState();
                                                                                resetWalkInFormKeepMode();
                                                                            });
                                                                        </script>
                                                                    </c:if>
                                                                    <script>
                                                                        window.roomTypeOptionsHtml = `
                            <c:forEach items="${roomTypesList}" var="rt">
                            <option value="${rt.typeId}"
                                    data-price="${rt.basePrice}"
                                    data-capacity="${rt.capacity}">
                                ${rt.typeName}
                            </option>
                            </c:forEach>
                        `;
                                                                    </script>
                                                                </c:if>
                                                                <%--=====CHECK-OUT TAB (ITERATION 3)=====--%>
                                                                    <c:if test="${currentTab eq 'checkout'}">
                                                                        <%-- Toast notification --%>
                                                                            <c:if test="${not empty param.msg}">
                                                                                <div class="toast-notify toast-success">
                                                                                    <i
                                                                                        class="fa-solid fa-circle-check"></i>
                                                                                    Đã làm thủ tục trả phòng thành công!
                                                                                </div>
                                                                            </c:if>
                                                                            <c:if test="${not empty param.error}">
                                                                                <div class="toast-notify toast-error">
                                                                                    <i
                                                                                        class="fa-solid fa-circle-xmark"></i>
                                                                                    Thao tác thất bại. Vui lòng kiểm tra
                                                                                    lại.
                                                                                </div>
                                                                            </c:if>

                                                                            <div class="content-header-row">
                                                                                <div>
                                                                                    <h2><i class="fa-solid fa-file-invoice-dollar"
                                                                                            style="color:var(--brand-blue);margin-right:8px"></i>
                                                                                        Trả phòng & Thanh toán</h2>
                                                                                    <p>Quản lý các phòng đang được sử
                                                                                        dụng (Đã check-in) và thực hiện
                                                                                        thủ tục trả phòng, tính hóa
                                                                                        đơn (Iteration 3).</p>
                                                                                </div>
                                                                            </div>

                                                                            <form method="get"
                                                                                action="${pageContext.request.contextPath}/receptionist/dashboard">
                                                                                <input type="hidden" name="tab"
                                                                                    value="checkout" />
                                                                                <div class="table-filter-bar"
                                                                                    style="display:flex; gap: 8px;">
                                                                                    <div class="search-wrapper"
                                                                                        style="flex: 1;">
                                                                                        <i
                                                                                            class="fa-solid fa-magnifying-glass"></i>
                                                                                        <input type="text" name="search"
                                                                                            class="search-input"
                                                                                            placeholder="Tìm tên khách hoặc số phòng..."
                                                                                            value="${search}" />
                                                                                    </div>
                                                                                    <button type="submit"
                                                                                        style="height:40px;padding:0 16px;background:var(--brand-blue);color:#fff;border:none;border-radius:8px;font-weight:600;font-size:13px;cursor:pointer;">
                                                                                        Tìm kiếm
                                                                                    </button>
                                                                                </div>
                                                                            </form>

                                                                            <div class="table-card">
                                                                                <c:choose>
                                                                                    <c:when
                                                                                        test="${empty checkOutList}">
                                                                                        <div class="empty-state">
                                                                                            <i
                                                                                                class="fa-solid fa-inbox"></i>
                                                                                            <p>Không có phòng nào đang ở
                                                                                                (CheckedIn).</p>
                                                                                        </div>
                                                                                    </c:when>
                                                                                    <c:otherwise>
                                                                                        <table class="booking-table">
                                                                                            <thead>
                                                                                                <tr>
                                                                                                    <th>Mã Đặt Phòng
                                                                                                    </th>
                                                                                                    <th>Khách Hàng</th>
                                                                                                    <th>Loại Phòng</th>
                                                                                                    <th>Ngày Đến</th>
                                                                                                    <th>Ngày Đi</th>
                                                                                                    <th>Trạng Thái</th>
                                                                                                    <th>Thao Tác</th>
                                                                                                </tr>
                                                                                            </thead>
                                                                                            <tbody>
                                                                                                <c:forEach var="b"
                                                                                                    items="${checkOutList}">
                                                                                                    <tr>
                                                                                                        <td><span
                                                                                                                class="booking-id-badge">#${b.bookingId}</span>
                                                                                                        </td>
                                                                                                        <td>
                                                                                                            <div
                                                                                                                class="customer-cell">
                                                                                                                <div
                                                                                                                    class="name">
                                                                                                                    ${b.customerName}
                                                                                                                </div>
                                                                                                                <div
                                                                                                                    class="meta">
                                                                                                                    Đặt:
                                                                                                                    ${b.createdAt}
                                                                                                                </div>
                                                                                                            </div>
                                                                                                        </td>
                                                                                                        <td>
                                                                                                            <c:choose>
                                                                                                                <c:when
                                                                                                                    test="${not empty b.groupRoomTypeNames}">
                                                                                                                    <span
                                                                                                                        class="roomtype-badge">${b.groupRoomTypeNames}</span><br />
                                                                                                                    <small
                                                                                                                        style="color:var(--text-muted)">${b.totalRoomQuantity}
                                                                                                                        phòng</small>
                                                                                                                </c:when>
                                                                                                                <c:otherwise>
                                                                                                                    <span
                                                                                                                        style="color:var(--text-muted)">—</span>
                                                                                                                </c:otherwise>
                                                                                                            </c:choose>
                                                                                                        </td>
                                                                                                        <td>${b.checkInDate}
                                                                                                        </td>
                                                                                                        <td>${b.checkOutDate}
                                                                                                        </td>
                                                                                                        <td>
                                                                                                            <span
                                                                                                                class="status-pill pill-checkedin">
                                                                                                                <i
                                                                                                                    class="fa-solid fa-circle"></i>
                                                                                                                Đã
                                                                                                                check-in
                                                                                                            </span>
                                                                                                        </td>
                                                                                                        <td>
                                                                                                            <a class="btn-action-icon btn-edit"
                                                                                                                href="${pageContext.request.contextPath}/receptionist/checkout?bookingId=${b.bookingId}">
                                                                                                                <i
                                                                                                                    class="fa-solid fa-right-from-bracket"></i>
                                                                                                                Check
                                                                                                                Out
                                                                                                            </a>
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                </c:forEach>
                                                                                            </tbody>
                                                                                        </table>
                                                                                    </c:otherwise>
                                                                                </c:choose>
                                                                            </div>
                                                                    </c:if>



                                        </main>

                                        <footer class="dashboard-footer">
                                            <span>HotelOps Pro &copy; 2026</span>
                                            <span>Đăng nhập: <strong>${sessionScope.user}</strong></span>
                                        </footer>
                            </div><%-- end dashboard-main --%>
                    </div><%-- end dashboard-layout --%>


                        <%--================================================================MODAL: XÁC NHẬN
                            booking================================================================--%>
                            <div id="modalConfirm" class="modal-overlay">
                                <div class="modal-container">
                                    <div class="modal-header">
                                        <h3><i class="fa-solid fa-check-circle"
                                                style="color:#10b981;margin-right:8px"></i>Xác nhận đặt phòng</h3>
                                        <button class="btn-close-modal" onclick="closeModal('modalConfirm')">
                                            <i class="fa-solid fa-xmark"></i>
                                        </button>
                                    </div>
                                    <form id="formConfirm" method="post"
                                        action="${pageContext.request.contextPath}/receptionist/booking">
                                        <input type="hidden" name="action" value="confirm" />
                                        <input type="hidden" id="confirmBookingId" name="bookingId" />
                                        <div class="modal-body">
                                            <p style="font-size:14px;color:var(--text-navy-light);margin-bottom:16px">
                                                Bạn đang xác nhận yêu cầu đặt phòng của khách
                                                <strong id="confirmCustomerName"></strong>.
                                                Hành động này sẽ chuyển trạng thái sang <strong>Đã xác nhận</strong>.
                                            </p>
                                            <div class="modal-form-group">
                                                <label>Ghi chú (tuỳ chọn)</label>
                                                <input type="text" name="note" class="modal-input"
                                                    placeholder="VD: Đã kiểm tra phòng sẵn sàng..." />
                                            </div>
                                            <div class="modal-footer-row">
                                                <button type="button" class="btn-modal-cancel"
                                                    onclick="closeModal('modalConfirm')">Huỷ</button>
                                                <button type="submit" class="btn-modal-confirm">
                                                    <i class="fa-solid fa-check"></i> Xác nhận
                                                </button>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </div>

                            <%--================================================================MODAL: TỪ CHỐI
                                booking================================================================--%>
                                <div id="modalReject" class="modal-overlay">
                                    <div class="modal-container">
                                        <div class="modal-header">
                                            <h3><i class="fa-solid fa-times-circle"
                                                    style="color:#ef4444;margin-right:8px"></i>Từ chối đặt phòng</h3>
                                            <button class="btn-close-modal" onclick="closeModal('modalReject')">
                                                <i class="fa-solid fa-xmark"></i>
                                            </button>
                                        </div>
                                        <form id="formReject" method="post"
                                            action="${pageContext.request.contextPath}/receptionist/booking">
                                            <input type="hidden" name="action" value="reject" />
                                            <input type="hidden" id="rejectBookingId" name="bookingId" />
                                            <div class="modal-body">
                                                <p
                                                    style="font-size:14px;color:var(--text-navy-light);margin-bottom:16px">
                                                    Từ chối yêu cầu của khách <strong id="rejectCustomerName"></strong>.
                                                    Vui lòng nhập lý do để thông báo cho khách.
                                                </p>
                                                <div class="modal-form-group">
                                                    <label>Lý do từ chối <span style="color:#ef4444">*</span></label>
                                                    <textarea id="rejectReason" name="reason" class="modal-textarea"
                                                        placeholder="VD: Phòng không còn trống trong khoảng thời gian yêu cầu..."
                                                        maxlength="500" required></textarea>
                                                </div>
                                                <div class="modal-footer-row">
                                                    <button type="button" class="btn-modal-cancel"
                                                        onclick="closeModal('modalReject')">Huỷ</button>
                                                    <button type="button" class="btn-modal-reject"
                                                        onclick="submitReject()">
                                                        <i class="fa-solid fa-times"></i> Từ chối
                                                    </button>
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                </div>

                                <%--================================================================MODAL: CẬP NHẬT
                                    thông tin
                                    booking================================================================--%>
                                    <div id="modalEdit" class="modal-overlay">
                                        <div class="modal-container modal-lg">
                                            <div class="modal-header">
                                                <h3><i class="fa-solid fa-pen-to-square"
                                                        style="color:var(--brand-blue);margin-right:8px"></i>Cập nhật
                                                    thông tin booking</h3>
                                                <button class="btn-close-modal" onclick="closeModal('modalEdit')">
                                                    <i class="fa-solid fa-xmark"></i>
                                                </button>
                                            </div>
                                            <form method="post"
                                                action="${pageContext.request.contextPath}/receptionist/booking">
                                                <input type="hidden" name="action" value="update" />
                                                <input type="hidden" id="editBookingId" name="bookingId" />
                                                <div class="modal-body">
                                                    <p
                                                        style="font-size:12px;color:var(--text-muted);margin-bottom:16px">
                                                        <i class="fa-solid fa-circle-info"></i>
                                                        Chỉ có thể cập nhật khi booking ở trạng thái <strong>Chờ xử
                                                            lý</strong>.
                                                    </p>

                                                    <div class="modal-form-group">
                                                        <label>Tên khách hàng <span
                                                                style="color:#ef4444">*</span></label>
                                                        <input type="text" id="editCustomerName" name="customerName"
                                                            class="modal-input" maxlength="100" required />
                                                    </div>

                                                    <div class="modal-grid-2">
                                                        <div class="modal-form-group">
                                                            <label>Ngày nhận phòng <span
                                                                    style="color:#ef4444">*</span></label>
                                                            <input type="date" id="editCheckIn" name="checkInDate"
                                                                class="modal-input" onchange="recalcAmount()"
                                                                required />
                                                        </div>
                                                        <div class="modal-form-group">
                                                            <label>Ngày trả phòng <span
                                                                    style="color:#ef4444">*</span></label>
                                                            <input type="date" id="editCheckOut" name="checkOutDate"
                                                                class="modal-input" onchange="recalcAmount()"
                                                                required />
                                                        </div>
                                                    </div>

                                                    <%-- Dropdown loại phòng từ DB --%>
                                                        <div class="modal-grid-2">
                                                            <div class="modal-form-group">
                                                                <label>Loại phòng</label>
                                                                <select id="editRoomTypeId" name="roomTypeId"
                                                                    class="modal-select" onchange="recalcAmount()">
                                                                    <option value="">— Chọn loại phòng —</option>
                                                                    <c:if test="${not empty roomTypesList}">
                                                                        <c:forEach var="rt" items="${roomTypesList}">
                                                                            <option value="${rt.typeId}"
                                                                                data-price="${rt.basePrice}">
                                                                                <c:out value="${rt.typeName}" /> —
                                                                                <fmt:formatNumber
                                                                                    value="${rt.basePrice}"
                                                                                    type="number" />đ/đêm
                                                                            </option>
                                                                        </c:forEach>
                                                                    </c:if>
                                                                </select>
                                                            </div>
                                                            <div class="modal-form-group">
                                                                <label>Số phòng <span
                                                                        style="color:#ef4444">*</span></label>
                                                                <input type="number" id="editRoomQuantity"
                                                                    name="roomQuantity" class="modal-input" min="1"
                                                                    max="100" onchange="recalcAmount()" required />
                                                            </div>
                                                        </div>

                                                        <div class="modal-form-group">
                                                            <label>Tổng tiền (VND) <span
                                                                    style="color:#ef4444">*</span></label>
                                                            <input type="number" id="editTotalAmount" name="totalAmount"
                                                                class="modal-input" min="0" required />
                                                        </div>

                                                        <div class="modal-form-group">
                                                            <label>Ghi chú</label>
                                                            <textarea id="editNote" name="note" class="modal-textarea"
                                                                placeholder="Ghi chú yêu cầu đặc biệt..."
                                                                maxlength="500"></textarea>
                                                        </div>

                                                        <div class="modal-footer-row">
                                                            <button type="button" class="btn-modal-cancel"
                                                                onclick="closeModal('modalEdit')">Huỷ</button>
                                                            <button type="submit" class="btn-modal-save">
                                                                <i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi
                                                            </button>
                                                        </div>
                                                </div>
                                            </form>
                                        </div>
                                    </div>

                                    <%--================================================================MODAL: XEM CHI
                                        TIẾT
                                        (view-only)================================================================--%>
                                        <div id="modalDetail" class="modal-overlay">
                                            <div class="modal-container">
                                                <div class="modal-header">
                                                    <h3><i class="fa-solid fa-file-lines"
                                                            style="color:var(--brand-blue);margin-right:8px"></i>
                                                        Chi tiết yêu cầu <span id="detailBookingId"></span>
                                                    </h3>
                                                    <button class="btn-close-modal" onclick="closeModal('modalDetail')">
                                                        <i class="fa-solid fa-xmark"></i>
                                                    </button>
                                                </div>
                                                <div class="modal-body">
                                                    <div class="detail-grid">
                                                        <div class="detail-item">
                                                            <label>Khách hàng</label>
                                                            <span id="detailCustomerName"></span>
                                                        </div>
                                                        <div class="detail-item">
                                                            <label>Trạng thái</label>
                                                            <span id="detailStatus"></span>
                                                        </div>
                                                        <div class="detail-item">
                                                            <label>Loại phòng</label>
                                                            <span id="detailRoomType"></span>
                                                        </div>
                                                        <div class="detail-item">
                                                            <label>Số phòng</label>
                                                            <span id="detailQty"></span>
                                                        </div>
                                                        <div class="detail-item">
                                                            <label>Ngày nhận phòng</label>
                                                            <span id="detailCheckIn"></span>
                                                        </div>
                                                        <div class="detail-item">
                                                            <label>Ngày trả phòng</label>
                                                            <span id="detailCheckOut"></span>
                                                        </div>
                                                        <div class="detail-item" style="grid-column:span 2">
                                                            <label>Tổng tiền</label>
                                                            <span id="detailAmount"
                                                                style="color:var(--brand-blue);font-size:16px"></span>
                                                        </div>
                                                        <div class="detail-item" style="grid-column:span 2">
                                                            <label>Ghi chú / Lý do</label>
                                                            <span id="detailNote"
                                                                style="font-weight:400;color:var(--text-muted)"></span>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer-row">
                                                        <button type="button" class="btn-modal-cancel"
                                                            onclick="closeModal('modalDetail')">Đóng</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <%--================================================================MODAL: HUỶ
                                            booking================================================================--%>
                                            <div id="modalCancel" class="modal-overlay">
                                                <div class="modal-container">
                                                    <div class="modal-header">
                                                        <h3><i class="fa-solid fa-ban"
                                                                style="color:#64748b;margin-right:8px"></i>Huỷ đặt phòng
                                                        </h3>
                                                        <button class="btn-close-modal"
                                                            onclick="closeModal('modalCancel')">
                                                            <i class="fa-solid fa-xmark"></i>
                                                        </button>
                                                    </div>
                                                    <form method="post"
                                                        action="${pageContext.request.contextPath}/receptionist/booking">
                                                        <input type="hidden" name="action" value="cancel" />
                                                        <input type="hidden" id="cancelBookingId" name="bookingId" />
                                                        <div class="modal-body">
                                                            <p
                                                                style="font-size:14px;color:var(--text-navy-light);margin-bottom:16px">
                                                                Huỷ yêu cầu đặt phòng của khách <strong
                                                                    id="cancelCustomerName"></strong>.
                                                            </p>
                                                            <div class="modal-form-group">
                                                                <label>Lý do huỷ (tuỳ chọn)</label>
                                                                <textarea id="cancelReason" name="reason"
                                                                    class="modal-textarea"
                                                                    placeholder="VD: Huỷ theo yêu cầu của khách..."
                                                                    maxlength="500"></textarea>
                                                            </div>
                                                            <div class="modal-footer-row">
                                                                <button type="button" class="btn-modal-cancel"
                                                                    onclick="closeModal('modalCancel')">Không
                                                                    huỷ</button>
                                                                <button type="submit" class="btn-modal-save"
                                                                    style="background:#64748b;">
                                                                    <i class="fa-solid fa-ban"></i> Xác nhận huỷ
                                                                </button>
                                                            </div>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                            <script>
                                                const contextPath = '${pageContext.request.contextPath}';
                                            </script>
                                            <script>
                                                function closeCheckinToast() {
                                                    const toast = document.getElementById("toastCheckin");
                                                    if (toast) {
                                                        toast.remove();
                                                    }

                                                    const url = new URL(window.location);
                                                    url.searchParams.delete("checkinSuccess");
                                                    url.searchParams.delete("customerName");
                                                    window.history.replaceState({}, document.title, url.pathname + url.search);
                                                }

                                                window.addEventListener("DOMContentLoaded", function () {
                                                    const toast = document.getElementById("toastCheckin");

                                                    if (!toast)
                                                        return;

                                                    setTimeout(() => {
                                                        toast.style.opacity = "0";

                                                        setTimeout(() => {
                                                            toast.remove();

                                                            const url = new URL(window.location);
                                                            url.searchParams.delete("checkinSuccess");
                                                            url.searchParams.delete("customerName");
                                                            window.history.replaceState({}, document.title, url.pathname + url.search);

                                                        }, 400);

                                                    }, 3000);
                                                });
                                                async function searchAccount() {

                                                    hideSearchAccountMessage();

                                                    const keyword = document
                                                        .getElementById("searchAccountKeyword")
                                                        .value
                                                        .trim();

                                                    if (!keyword) {
                                                        showSearchAccountMessage("Vui lòng nhập Email hoặc SĐT");
                                                        return;
                                                    }

                                                    try {

                                                        const response = await fetch(
                                                            contextPath
                                                            + "/receptionist/walkin-booking"
                                                            + "?action=searchAccount"
                                                            + "&keyword="
                                                            + encodeURIComponent(keyword)
                                                        );

                                                        const account = await response.json();

                                                        if (!account.fullName) {
                                                            showSearchAccountMessage("Không tìm thấy tài khoản");
                                                            return;
                                                        }

                                                        document.getElementById("customerName").value = account.fullName || "";
                                                        document.getElementById("phone").value = account.phone || "";
                                                        document.getElementById("email").value = account.email || "";

                                                        saveWalkInState();

                                                        showSearchAccountMessage("Đã tìm thấy tài khoản", "success");

                                                    } catch (e) {

                                                        console.error(e);
                                                        showSearchAccountMessage("Có lỗi xảy ra khi tìm kiếm");

                                                    }
                                                }
                                                function showSearchAccountError(message) {
                                                    const box = document.getElementById("searchAccountError");

                                                    box.textContent = message;
                                                    box.classList.remove("hidden");
                                                }

                                                function hideSearchAccountError() {
                                                    const box = document.getElementById("searchAccountError");

                                                    box.textContent = "";
                                                    box.classList.add("hidden");
                                                }
                                                let searchAccountTimer = null;

                                                function showSearchAccountMessage(message, type = "error") {

                                                    const box = document.getElementById("searchAccountMessage");
                                                    if (!box)
                                                        return;

                                                    clearTimeout(searchAccountTimer);

                                                    box.className = "search-account-message " + type;
                                                    box.textContent = message;
                                                    box.classList.remove("hidden");

                                                    searchAccountTimer = setTimeout(() => {
                                                        hideSearchAccountMessage();
                                                    }, 3000);
                                                }

                                                function hideSearchAccountMessage() {

                                                    const box = document.getElementById("searchAccountMessage");
                                                    if (!box)
                                                        return;

                                                    box.classList.add("hidden");
                                                    box.textContent = "";
                                                }
                                            </script>
                                            <script
                                                src="${pageContext.request.contextPath}/assets/js/receptionist.js?v=5"
                                                charset="UTF-8"></script>
            </body>

            </html>