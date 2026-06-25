<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ include file="../../includes/taglibs.jsp" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />
            <title>Chi tiết đặt phòng #${booking.bookingId} - HotelOps Pro</title>
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
                rel="stylesheet" />
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/receptionist.css?v=4" />
        </head>
        <fmt:setLocale value="vi_VN" />

        <body class="dashboard-body">

            <div class="dashboard-layout">

                <%--=================SIDEBAR=================--%>
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
                            <li class="menu-item ${currentTab eq 'roommap' ? 'active' : ''}">
                                <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=roommap">
                                    <i class="fa-solid fa-map"></i> <span>Sơ đồ phòng</span>
                                </a>
                            </li>

                            <li class="menu-item ${currentTab eq 'walkin-bookings' ? 'active' : ''}">
                                <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=walkin-bookings">
                                    <i class="fa-solid fa-user-plus"></i> <span>Đặt phòng tại quầy</span>
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
                                    <span class="profile-name">${not empty sessionScope.user ? sessionScope.user :
                                        'Receptionist'}</span>
                                    <span class="profile-role">Lễ tân</span>
                                </div>
                            </div>
                        </div>
                    </aside>

                    <%--=================MAIN CONTENT=================--%>
                        <div class="dashboard-main">

                            <%-- TOPBAR --%>
                                <header class="main-topbar">
                                    <div class="breadcrumb">
                                        <span>Receptionist</span>
                                        <span class="separator">&gt;</span>
                                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings"
                                            style="text-decoration:none;color:var(--text-muted)">Quản lý đặt
                                            phòng</a>
                                        <span class="separator">&gt;</span>
                                        <span class="current">Chi tiết đặt phòng #${booking.bookingId}</span>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                                        <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                                    </a>
                                </header>

                                <%-- WORKSPACE --%>
                                    <main class="workspace-content">

                                        <div class="content-header-row">
                                            <div>
                                                <h2><i class="fa-solid fa-file-invoice"
                                                        style="color:var(--brand-blue);margin-right:8px"></i>Chi
                                                    tiết đặt phòng #${booking.bookingId}</h2>
                                                <p>Xem chi tiết thông tin khách hàng, yêu cầu đặt phòng và các phòng
                                                    được gán thực tế.</p>
                                            </div>
                                            <div style="display:flex; gap:12px">
                                                <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings"
                                                    class="btn-modal-cancel"
                                                    style="display:inline-flex;align-items:center;justify-content:center;text-decoration:none;line-height:40px;height:40px">
                                                    <i class="fa-solid fa-chevron-left" style="margin-right:6px"></i>
                                                    Quay lại danh sách
                                                </a>
                                            </div>
                                        </div>

                                        <div class="process-grid">
                                            <!-- Cột trái: Thông tin Khách hàng & Đặt phòng -->
                                            <div class="process-left">

                                                <!-- Khách hàng -->
                                                <div class="detail-card">
                                                    <div class="card-header">
                                                        <h3><i class="fa-solid fa-user"></i> Thông tin khách hàng
                                                        </h3>
                                                    </div>
                                                    <div class="card-body">
                                                        <c:choose>
                                                            <c:when test="${not empty customer}">
                                                                <div class="info-row">
                                                                    <label>Họ và tên:</label>
                                                                    <span>
                                                                        <c:out value="${customer.fullName}" />
                                                                    </span>
                                                                </div>
                                                                <div class="info-row">
                                                                    <label>Email:</label>
                                                                    <span>
                                                                        <c:out
                                                                            value="${not empty booking.email ? booking.email : (not empty customer ? customer.email : '—')}" />
                                                                    </span>
                                                                </div>
                                                                <div class="info-row"
                                                                    style="border-bottom:none; padding-bottom:0">
                                                                    <label>Số điện thoại:</label>
                                                                    <span>
                                                                        <c:out
                                                                            value="${not empty booking.phone ? booking.phone : (not empty customer and not empty customer.phone ? customer.phone : '—')}" />
                                                                    </span>
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="info-row">
                                                                    <label>Họ và tên khách:</label>
                                                                    <span>
                                                                        <c:out value="${booking.customerName}" />
                                                                    </span>
                                                                </div>
                                                                <div class="info-row">
                                                                    <label>Email:</label>
                                                                    <span>
                                                                        <c:out
                                                                            value="${not empty booking.email ? booking.email : '—'}" />
                                                                    </span>
                                                                </div>
                                                                <div class="info-row"
                                                                    style="border-bottom:none; padding-bottom:0">
                                                                    <label>Số điện thoại:</label>
                                                                    <span>
                                                                        <c:out
                                                                            value="${not empty booking.phone ? booking.phone : '—'}" />
                                                                    </span>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>

                                                <!-- Đặt phòng -->
                                                <div class="detail-card" style="margin-top:24px">
                                                    <div class="card-header">
                                                        <h3><i class="fa-solid fa-calendar-days"></i> Chi tiết yêu
                                                            cầu đặt phòng</h3>
                                                    </div>
                                                    <div class="card-body">
                                                        <div class="info-row">
                                                            <label>Mã Đặt Phòng:</label>
                                                            <span class="booking-id-badge">#${booking.bookingId}</span>
                                                        </div>
                                                        <div class="info-row">
                                                            <label>Trạng thái đặt phòng:</label>
                                                            <span>
                                                                <c:choose>
                                                                    <c:when test="${booking.status eq 'Pending'}">
                                                                        <span class="status-pill pill-pending"><i
                                                                                class="fa-solid fa-circle"></i> Chờ
                                                                            xử lý</span>
                                                                    </c:when>
                                                                    <c:when test="${booking.status eq 'Confirmed'}">
                                                                        <span class="status-pill pill-confirmed"><i
                                                                                class="fa-solid fa-circle"></i> Đã
                                                                            xác nhận</span>
                                                                    </c:when>
                                                                    <c:when test="${booking.status eq 'Rejected'}">
                                                                        <span class="status-pill pill-rejected"><i
                                                                                class="fa-solid fa-circle"></i> Từ
                                                                            chối</span>
                                                                    </c:when>
                                                                    <c:when test="${booking.status eq 'Cancelled'}">
                                                                        <span class="status-pill pill-cancelled"><i
                                                                                class="fa-solid fa-circle"></i> Đã
                                                                            huỷ</span>
                                                                    </c:when>
                                                                    <c:when test="${booking.status eq 'CheckedIn'}">
                                                                        <span class="status-pill pill-checkedin"><i
                                                                                class="fa-solid fa-circle"></i> Đã
                                                                            check-in</span>
                                                                    </c:when>
                                                                    <c:when test="${booking.status eq 'CheckedOut'}">
                                                                        <span class="status-pill pill-checkedout"><i
                                                                                class="fa-solid fa-circle"></i> Đã
                                                                            trả phòng</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span
                                                                            class="status-pill pill-cancelled">${booking.status}</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </span>
                                                        </div>

                                                        <%-- Room type breakdown table --%>
                                                            <div style="margin-top: 16px; margin-bottom: 16px;">
                                                                <label
                                                                    style="font-size: 12px; font-weight: 700; color: var(--text-navy); display: block; margin-bottom: 8px;">
                                                                    <i class="fa-solid fa-layer-group"
                                                                        style="margin-right: 4px;"></i> Chi tiết các
                                                                    loại phòng:
                                                                </label>
                                                                <table
                                                                    style="width: 100%; border-collapse: collapse; font-size: 13px;">
                                                                    <thead>
                                                                        <tr
                                                                            style="background: #f8fafc; border-bottom: 2px solid var(--border-color);">
                                                                            <th
                                                                                style="padding: 8px 12px; text-align: left; font-weight: 700; color: var(--text-navy);">
                                                                                Loại phòng</th>
                                                                            <th
                                                                                style="padding: 8px 12px; text-align: center; font-weight: 700; color: var(--text-navy);">
                                                                                Số lượng</th>
                                                                            <th
                                                                                style="padding: 8px 12px; text-align: right; font-weight: 700; color: var(--text-navy);">
                                                                                Thành tiền</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody>
                                                                        <%-- Parent booking row --%>
                                                                            <tr
                                                                                style="border-bottom: 1px solid #f1f5f9;">
                                                                                <td style="padding: 8px 12px;">
                                                                                    <span class="roomtype-badge">
                                                                                        <c:out
                                                                                            value="${booking.roomTypeName}" />
                                                                                    </span>
                                                                                </td>
                                                                                <td
                                                                                    style="padding: 8px 12px; text-align: center; font-weight: 600;">
                                                                                    ${booking.roomQuantity}</td>
                                                                                <td
                                                                                    style="padding: 8px 12px; text-align: right; font-weight: 600;">
                                                                                    <fmt:formatNumber
                                                                                        value="${booking.totalAmount}"
                                                                                        type="number"
                                                                                        groupingUsed="true" />đ
                                                                                </td>
                                                                            </tr>
                                                                            <%-- Child booking rows --%>
                                                                                <c:forEach var="child"
                                                                                    items="${childBookings}">
                                                                                    <tr
                                                                                        style="border-bottom: 1px solid #f1f5f9;">
                                                                                        <td style="padding: 8px 12px;">
                                                                                            <span
                                                                                                class="roomtype-badge">
                                                                                                <c:out
                                                                                                    value="${child.roomTypeName}" />
                                                                                            </span>
                                                                                        </td>
                                                                                        <td
                                                                                            style="padding: 8px 12px; text-align: center; font-weight: 600;">
                                                                                            ${child.roomQuantity}</td>
                                                                                        <td
                                                                                            style="padding: 8px 12px; text-align: right; font-weight: 600;">
                                                                                            <fmt:formatNumber
                                                                                                value="${child.totalAmount}"
                                                                                                type="number"
                                                                                                groupingUsed="true" />đ
                                                                                        </td>
                                                                                    </tr>
                                                                                </c:forEach>
                                                                                <%-- Total row --%>
                                                                                    <tr
                                                                                        style="border-top: 2px solid var(--border-color); background: #f0f9ff;">
                                                                                        <td
                                                                                            style="padding: 8px 12px; font-weight: 700; color: var(--text-navy);">
                                                                                            Tổng cộng</td>
                                                                                        <td
                                                                                            style="padding: 8px 12px; text-align: center; font-weight: 700; color: var(--text-navy);">
                                                                                            ${booking.totalRoomQuantity}
                                                                                            phòng</td>
                                                                                        <td
                                                                                            style="padding: 8px 12px; text-align: right; font-weight: 800; color: var(--brand-blue); font-size: 15px;">
                                                                                            <fmt:formatNumber
                                                                                                value="${booking.overallTotalAmount}"
                                                                                                type="number"
                                                                                                groupingUsed="true" />đ
                                                                                        </td>
                                                                                    </tr>
                                                                    </tbody>
                                                                </table>
                                                            </div>

                                                            <div class="info-row">
                                                                <label>Ngày Check-in:</label>
                                                                <span>${booking.checkInDate}</span>
                                                            </div>
                                                            <div class="info-row">
                                                                <label>Ngày Check-out:</label>
                                                                <span>${booking.checkOutDate}</span>
                                                            </div>
                                                            <div class="info-row"
                                                                style="border-bottom:none; padding-bottom:0">
                                                                <label>Số đêm lưu trú:</label>
                                                                <span>${booking.nights} đêm</span>
                                                            </div>
                                                            <c:if test="${not empty booking.note}">
                                                                <div class="info-row-full"
                                                                    style="margin-top: 12px; padding: 12px; background: #fffbeb; border-radius: 8px; border: 1px solid #fde68a;">
                                                                    <label
                                                                        style="display:block; font-size:11px; font-weight:700; color:#d97706; margin-bottom:4px"><i
                                                                            class="fa-solid fa-comment-dots"></i> Ghi
                                                                        chú của khách:</label>
                                                                    <span style="font-size:13px; color:#b45309">
                                                                        <c:out value="${booking.note}" />
                                                                    </span>
                                                                </div>
                                                            </c:if>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Cột phải: Phân phòng & Trạng thái phê duyệt -->
                                            <div class="process-right">

                                                <!-- Phân phòng -->
                                                <div class="detail-card">
                                                    <div class="card-header">
                                                        <h3><i class="fa-solid fa-door-open"></i> Phân phòng (Gán
                                                            phòng thực tế)</h3>
                                                    </div>
                                                    <div class="card-body">
                                                        <c:choose>
                                                            <c:when
                                                                test="${booking.status eq 'Confirmed' || booking.status eq 'CheckedIn' || booking.status eq 'CheckedOut'}">
                                                                <div
                                                                    style="background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px; padding: 12px; text-align: center; margin-bottom: 16px;">
                                                                    <span
                                                                        style="font-size: 13px; font-weight: 700; color: #16a34a">
                                                                        <i class="fa-solid fa-circle-check"></i> Đã
                                                                        gán phòng thành công
                                                                    </span>
                                                                </div>

                                                                <%-- Parent booking rooms --%>
                                                                    <div style="margin-bottom: 16px;">
                                                                        <div
                                                                            style="font-size: 12px; font-weight: 700; color: var(--text-navy); margin-bottom: 8px; padding-bottom: 6px; border-bottom: 1px solid #e2e8f0;">
                                                                            <i class="fa-solid fa-bed"
                                                                                style="margin-right: 4px; color: var(--brand-blue);"></i>
                                                                            <c:out value="${booking.roomTypeName}" />
                                                                            (${booking.roomQuantity} phòng)
                                                                        </div>
                                                                        <div class="assigned-rooms-list">
                                                                            <c:choose>
                                                                                <c:when
                                                                                    test="${not empty assignedRooms}">
                                                                                    <c:forEach var="ar"
                                                                                        items="${assignedRooms}">
                                                                                        <div class="assigned-room-item">
                                                                                            <div class="room-icon"><i
                                                                                                    class="fa-solid fa-door-closed"></i>
                                                                                            </div>
                                                                                            <div class="room-info">
                                                                                                <span
                                                                                                    class="room-num">Phòng
                                                                                                    ${ar.roomNumber}</span>
                                                                                                <span
                                                                                                    class="room-fl">${ar.floor}</span>
                                                                                            </div>
                                                                                        </div>
                                                                                    </c:forEach>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <span
                                                                                        style="font-size: 12px; color: var(--text-muted); font-style: italic;">Chưa
                                                                                        gán phòng</span>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </div>
                                                                    </div>

                                                                    <%-- Child booking rooms --%>
                                                                        <c:forEach var="child" items="${childBookings}">
                                                                            <div style="margin-bottom: 16px;">
                                                                                <div
                                                                                    style="font-size: 12px; font-weight: 700; color: var(--text-navy); margin-bottom: 8px; padding-bottom: 6px; border-bottom: 1px solid #e2e8f0;">
                                                                                    <i class="fa-solid fa-bed"
                                                                                        style="margin-right: 4px; color: var(--brand-blue);"></i>
                                                                                    <c:out
                                                                                        value="${child.roomTypeName}" />
                                                                                    (${child.roomQuantity} phòng)
                                                                                </div>
                                                                                <div class="assigned-rooms-list">
                                                                                    <c:set var="childRooms"
                                                                                        value="${childAssignedRoomsMap[child.bookingId]}" />
                                                                                    <c:choose>
                                                                                        <c:when
                                                                                            test="${not empty childRooms}">
                                                                                            <c:forEach var="ar"
                                                                                                items="${childRooms}">
                                                                                                <div
                                                                                                    class="assigned-room-item">
                                                                                                    <div
                                                                                                        class="room-icon">
                                                                                                        <i
                                                                                                            class="fa-solid fa-door-closed"></i>
                                                                                                    </div>
                                                                                                    <div
                                                                                                        class="room-info">
                                                                                                        <span
                                                                                                            class="room-num">Phòng
                                                                                                            ${ar.roomNumber}</span>
                                                                                                        <span
                                                                                                            class="room-fl">${ar.floor}</span>
                                                                                                    </div>
                                                                                                </div>
                                                                                            </c:forEach>
                                                                                        </c:when>
                                                                                        <c:otherwise>
                                                                                            <span
                                                                                                style="font-size: 12px; color: var(--text-muted); font-style: italic;">Chưa
                                                                                                gán phòng</span>
                                                                                        </c:otherwise>
                                                                                    </c:choose>
                                                                                </div>
                                                                            </div>
                                                                        </c:forEach>
                                                            </c:when>

                                                            <c:otherwise>
                                                                <p
                                                                    style="font-size: 13px; color: var(--text-muted); text-align: center; padding: 20px">
                                                                    <i class="fa-solid fa-circle-info"
                                                                        style="font-size:24px; display:block; margin-bottom:8px; opacity:0.3"></i>
                                                                    Đặt phòng đang ở trạng thái
                                                                    <strong>
                                                                        <c:choose>
                                                                            <c:when
                                                                                test="${booking.status eq 'Pending'}">
                                                                                Chờ xử lý</c:when>
                                                                            <c:when
                                                                                test="${booking.status eq 'Rejected'}">
                                                                                Đã từ chối</c:when>
                                                                            <c:when
                                                                                test="${booking.status eq 'Cancelled'}">
                                                                                Đã huỷ</c:when>
                                                                            <c:otherwise>${booking.status}
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </strong>. Chưa có phòng thực tế nào được phân
                                                                    phối.
                                                                </p>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>

                                                <!-- Trạng thái phê duyệt -->
                                                <div class="detail-card" style="margin-top:24px">
                                                    <div class="card-header">
                                                        <h3><i class="fa-solid fa-circle-info"></i> Thông tin phê
                                                            duyệt</h3>
                                                    </div>
                                                    <div class="card-body">
                                                        <c:choose>
                                                            <c:when test="${booking.status eq 'Pending'}">
                                                                <div
                                                                    style="background: #fffbeb; border: 1px solid #fde68a; border-radius: 8px; padding: 20px; text-align: center;">
                                                                    <i class="fa-solid fa-clock"
                                                                        style="font-size: 24px; color: #d97706; display: block; margin-bottom: 8px;"></i>
                                                                    <span
                                                                        style="font-size: 14px; font-weight: 700; color: #d97706; display: block; margin-bottom: 4px;">Đang
                                                                        chờ xử lý</span>
                                                                </div>
                                                            </c:when>

                                                            <c:when test="${booking.status eq 'Confirmed'}">
                                                                <div
                                                                    style="background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px; padding: 20px; text-align: center;">
                                                                    <i class="fa-solid fa-circle-check"
                                                                        style="font-size: 24px; color: #16a34a; display: block; margin-bottom: 8px;"></i>
                                                                    <span
                                                                        style="font-size: 14px; font-weight: 700; color: #16a34a; display: block; margin-bottom: 4px;">Đã
                                                                        xác nhận đặt phòng thành công</span>
                                                                    <span
                                                                        style="font-size: 12px; color: var(--text-muted)">Đặt
                                                                        phòng đã hoàn tất xác nhận và gán phòng. Lễ
                                                                        tân vẫn có thể thực hiện Hủy đặt phòng bằng
                                                                        nút Cập nhật ở trên.</span>
                                                                </div>
                                                            </c:when>

                                                            <c:when test="${booking.status eq 'Rejected'}">
                                                                <div
                                                                    style="background: #fef2f2; border: 1px solid #fca5a5; border-radius: 8px; padding: 20px; text-align: center;">
                                                                    <i class="fa-solid fa-circle-xmark"
                                                                        style="font-size: 24px; color: #dc2626; display: block; margin-bottom: 8px;"></i>
                                                                    <span
                                                                        style="font-size: 14px; font-weight: 700; color: #dc2626; display: block; margin-bottom: 4px;">Đặt
                                                                        phòng đã bị từ chối</span>
                                                                    <c:if test="${not empty booking.note}">
                                                                        <span
                                                                            style="font-size: 12px; color: #b91c1c; display: block; margin-top: 8px; text-align: left; padding: 8px; background: #fff5f5; border-radius: 4px;">
                                                                            <strong>Lý do từ chối:</strong>
                                                                            <c:out value="${booking.note}" />
                                                                        </span>
                                                                    </c:if>
                                                                </div>
                                                            </c:when>

                                                            <c:when test="${booking.status eq 'Cancelled'}">
                                                                <div
                                                                    style="background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; padding: 20px; text-align: center;">
                                                                    <i class="fa-solid fa-ban"
                                                                        style="font-size: 24px; color: #64748b; display: block; margin-bottom: 8px;"></i>
                                                                    <span
                                                                        style="font-size: 14px; font-weight: 700; color: #64748b; display: block; margin-bottom: 4px;">Đặt
                                                                        phòng đã bị hủy</span>
                                                                    <c:if test="${not empty booking.note}">
                                                                        <span
                                                                            style="font-size: 12px; color: #475569; display: block; margin-top: 8px; text-align: left; padding: 8px; background: #f1f5f9; border-radius: 4px;">
                                                                            <strong>Lý do hủy:</strong>
                                                                            <c:out value="${booking.note}" />
                                                                        </span>
                                                                    </c:if>
                                                                </div>
                                                            </c:when>

                                                            <c:otherwise>
                                                                <div
                                                                    style="background: #f8fafc; border: 1px solid var(--border-color); border-radius: 8px; padding: 20px; text-align: center;">
                                                                    <span
                                                                        style="font-size: 14px; font-weight: 700; color: var(--text-navy); display: block; margin-bottom: 4px;">
                                                                        Trạng thái:
                                                                        <c:choose>
                                                                            <c:when
                                                                                test="${booking.status eq 'CheckedIn'}">
                                                                                Đã check-in</c:when>
                                                                            <c:when
                                                                                test="${booking.status eq 'CheckedOut'}">
                                                                                Đã trả phòng</c:when>
                                                                            <c:otherwise>${booking.status}
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </span>
                                                                    <span
                                                                        style="font-size: 12px; color: var(--text-muted)">Đặt
                                                                        phòng đã hoàn tất xử lý. Không thể thao tác
                                                                        thêm.</span>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>

                                            </div>
                                        </div>

                                    </main>

                                    <footer class="dashboard-footer">
                                        <span>HotelOps Pro &copy; 2026</span>
                                        <span>Đăng nhập: <strong>${sessionScope.user}</strong></span>
                                    </footer>
                        </div>
            </div>

        </body>

        </html>