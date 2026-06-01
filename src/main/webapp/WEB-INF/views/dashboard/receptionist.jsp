<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/receptionist.css?v=1" />
<fmt:setLocale value="vi_VN" />

<body class="dashboard-body">

<%-- ========== Active Tab ========== --%>
<c:set var="currentTab" value="${param.tab != null ? param.tab : 'bookings'}" />

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
            
            <li class="menu-item ${currentTab eq 'checkin' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=checkin">
                    <i class="fa-solid fa-key"></i> <span>Nhận phòng (Check-in)</span>
                </a>
            </li>
            
            <li class="menu-item ${currentTab eq 'checkout' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=checkout">
                    <i class="fa-solid fa-file-invoice-dollar"></i> <span>Trả phòng & Thanh toán</span>
                </a>
            </li>

            <li class="menu-item ${currentTab eq 'walkin' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=walkin">
                    <i class="fa-solid fa-square-plus"></i> <span>Đặt phòng tại quầy</span>
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
                <span class="current">
                    <c:choose>
                        <c:when test="${currentTab eq 'bookings'}">Quản lý đặt phòng</c:when>
                        <c:when test="${currentTab eq 'checkin'}">Gán phòng & Nhận phòng</c:when>
                        <c:when test="${currentTab eq 'checkout'}">Trả phòng & Dịch vụ</c:when>
                        <c:when test="${currentTab eq 'walkin'}">Đặt phòng Walk-in</c:when>
                    </c:choose>
                </span>
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
                        <c:when test="${param.action eq 'confirm'}">Đã xác nhận booking thành công!</c:when>
                        <c:when test="${param.action eq 'reject'}">Đã từ chối booking.</c:when>
                        <c:when test="${param.action eq 'update'}">Đã cập nhật thông tin booking!</c:when>
                        <c:when test="${param.action eq 'cancel'}">Đã huỷ booking.</c:when>
                        <c:when test="${param.action eq 'assign'}">Gán phòng cho khách thành công!</c:when>
                        <c:when test="${param.action eq 'checkin'}">Khách đã nhận phòng thành công!</c:when>
                        <c:when test="${param.action eq 'checkout'}">Đã hoàn tất thủ tục trả phòng & thanh toán!</c:when>
                        <c:when test="${param.action eq 'walkin'}">Đã tạo booking walk-in & check-in thành công!</c:when>
                        <c:when test="${param.action eq 'add_service'}">Đã thêm dịch vụ vào stay!</c:when>
                        <c:when test="${param.action eq 'remove_service'}">Đã xóa dịch vụ khỏi stay!</c:when>
                        <c:otherwise>Thao tác thành công!</c:otherwise>
                    </c:choose>
                </div>
            </c:if>
            <c:if test="${param.result eq 'fail'}">
                <div class="toast-notify toast-error">
                    <i class="fa-solid fa-circle-xmark"></i>
                    Thao tác thất bại. Vui lòng kiểm tra lại dữ liệu hoặc trạng thái phòng.
                </div>
            </c:if>

            <%-- ===== BOOKING TAB ===== --%>
            <c:if test="${currentTab eq 'bookings'}">
                <%-- Header --%>
                <div class="content-header-row">
                    <div>
                        <h2><i class="fa-solid fa-calendar-check" style="color:var(--brand-blue);margin-right:8px"></i>Yêu cầu đặt phòng</h2>
                        <p>Xem, xác nhận, từ chối và cập nhật các yêu cầu đặt phòng của khách hàng.</p>
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
                        <i class="fa-solid fa-clock" style="font-size:11px"></i>
                        Chờ xử lý <span class="tab-count">${cntPending}</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings&status=Confirmed"
                       class="status-tab ${currentStatus eq 'Confirmed' ? 'active' : ''}">
                        <i class="fa-solid fa-circle-check" style="font-size:11px"></i>
                        Đã xác nhận <span class="tab-count">${cntConfirmed}</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings&status=Rejected"
                       class="status-tab ${currentStatus eq 'Rejected' ? 'active' : ''}">
                        <i class="fa-solid fa-circle-xmark" style="font-size:11px"></i>
                        Đã từ chối <span class="tab-count">${cntRejected}</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings&status=Cancelled"
                       class="status-tab ${currentStatus eq 'Cancelled' ? 'active' : ''}">
                        Đã huỷ <span class="tab-count">${cntCancelled}</span>
                    </a>
                </div>

                <%-- Search bar --%>
                <form method="get" action="${pageContext.request.contextPath}/receptionist/dashboard">
                    <input type="hidden" name="tab" value="bookings" />
                    <input type="hidden" name="status" value="${currentStatus}" />
                    <div class="table-filter-bar">
                        <div class="search-wrapper">
                            <i class="fa-solid fa-magnifying-glass"></i>
                            <input type="text" name="keyword" class="search-input"
                                   placeholder="Tìm tên khách hoặc mã booking..."
                                   value="${keyword}" />
                        </div>
                        <button type="submit" style="height:40px;padding:0 16px;background:var(--brand-blue);color:#fff;border:none;border-radius:8px;font-weight:600;font-size:13px;cursor:pointer;">
                            Tìm kiếm
                        </button>
                        <c:if test="${not empty keyword}">
                            <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings&status=${currentStatus}"
                               style="height:40px;padding:0 14px;display:inline-flex;align-items:center;border:1px solid var(--border-color);border-radius:8px;font-size:13px;color:var(--text-muted);text-decoration:none;">
                                <i class="fa-solid fa-xmark" style="margin-right:6px"></i>Xoá lọc
                            </a>
                        </c:if>
                    </div>
                </form>

                <%-- Table --%>
                <div class="table-card">
                    <c:choose>
                        <c:when test="${empty bookingList}">
                            <div class="empty-state">
                                <i class="fa-solid fa-inbox"></i>
                                <p>Không có yêu cầu đặt phòng nào.</p>
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
                                <c:forEach var="b" items="${bookingList}">
                                    <tr>
                                        <td><span class="booking-id-badge">#${b.bookingId}</span></td>
                                        <td>
                                            <div class="customer-cell">
                                                <div class="name"><c:out value="${b.customerName}" /></div>
                                                <div class="meta">Đặt: ${b.createdAt}</div>
                                            </div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty b.roomTypeName}">
                                                    <span class="roomtype-badge"><c:out value="${b.roomTypeName}" /></span>
                                                    <br/><small style="color:var(--text-muted)">${b.roomQuantity} phòng</small>
                                                </c:when>
                                                <c:otherwise><span style="color:var(--text-muted)">—</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="date-range">
                                                ${b.checkInDate} → ${b.checkOutDate}
                                                <span class="nights">${b.nights} đêm</span>
                                            </div>
                                        </td>
                                        <td class="amount-cell">
                                            <fmt:formatNumber value="${b.totalAmount}" type="number" groupingUsed="true"/>đ
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${b.status eq 'Pending'}">
                                                    <span class="status-pill pill-pending"><i class="fa-solid fa-circle"></i> Chờ xử lý</span>
                                                </c:when>
                                                <c:when test="${b.status eq 'Confirmed'}">
                                                    <span class="status-pill pill-confirmed"><i class="fa-solid fa-circle"></i> Đã xác nhận</span>
                                                </c:when>
                                                <c:when test="${b.status eq 'Rejected'}">
                                                    <span class="status-pill pill-rejected"><i class="fa-solid fa-circle"></i> Từ chối</span>
                                                </c:when>
                                                <c:when test="${b.status eq 'Cancelled'}">
                                                    <span class="status-pill pill-cancelled"><i class="fa-solid fa-circle"></i> Đã huỷ</span>
                                                </c:when>
                                                <c:when test="${b.status eq 'CheckedIn'}">
                                                    <span class="status-pill pill-checkedin"><i class="fa-solid fa-circle"></i> Đã check-in</span>
                                                </c:when>
                                                <c:when test="${b.status eq 'CheckedOut'}">
                                                    <span class="status-pill pill-checkedout"><i class="fa-solid fa-circle"></i> Đã trả phòng</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-pill pill-cancelled"><c:out value="${b.status}" /></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="actions-cell">
                                                <button type="button" class="btn-action-icon btn-edit" title="Xem chi tiết"
                                                        onclick="openDetailModal(${b.bookingId}, '<c:out value="${b.customerName}" escapeXml="false"/>', '<c:out value="${b.roomTypeName}" escapeXml="false"/>', ${b.roomQuantity}, '${b.checkInDate}','${b.checkOutDate}', ${b.totalAmount}, '<c:out value="${b.status}"/>', '<c:out value="${b.note}" escapeXml="false"/>')">
                                                    <i class="fa-solid fa-eye"></i>
                                                </button>
                                                <c:if test="${b.status eq 'Pending'}">
                                                    <button type="button" class="btn-action-icon btn-confirm" title="Xác nhận"
                                                            onclick="openConfirmModal(${b.bookingId}, '<c:out value="${b.customerName}" escapeXml="false"/>')">
                                                        <i class="fa-solid fa-check-circle"></i>
                                                    </button>
                                                    <button type="button" class="btn-action-icon btn-reject" title="Từ chối"
                                                            onclick="openRejectModal(${b.bookingId}, '<c:out value="${b.customerName}" escapeXml="false"/>')">
                                                        <i class="fa-solid fa-times-circle"></i>
                                                    </button>
                                                    <button type="button" class="btn-action-icon btn-edit" title="Cập nhật"
                                                            onclick="openEditModal(${b.bookingId}, '<c:out value="${b.customerName}" escapeXml="false"/>', '${b.roomTypeId}', ${b.roomQuantity}, '${b.checkInDate}','${b.checkOutDate}', ${b.totalAmount}, '<c:out value="${b.note}" escapeXml="false"/>')">
                                                        <i class="fa-solid fa-pen-to-square"></i>
                                                    </button>
                                                </c:if>
                                                <c:if test="${b.status eq 'Pending' or b.status eq 'Confirmed'}">
                                                    <button type="button" class="btn-action-icon btn-cancel" title="Huỷ"
                                                            onclick="openCancelModal(${b.bookingId}, '<c:out value="${b.customerName}" escapeXml="false"/>')">
                                                        <i class="fa-solid fa-ban"></i>
                                                    </button>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:if>

            <%-- ===== CHECK-IN TAB ===== --%>
            <c:if test="${currentTab eq 'checkin'}">
                <div class="content-header-row">
                    <div>
                        <h2><i class="fa-solid fa-key" style="color:var(--brand-blue);margin-right:8px"></i>Gán phòng & Nhận phòng</h2>
                        <p>Tìm kiếm các booking đã xác nhận để thực hiện gán phòng vật lý và check-in cho khách lưu trú.</p>
                    </div>
                </div>

                <div class="table-card">
                    <div style="padding: 16px 20px; background: #f8fafc; font-weight: 700; color: var(--text-navy); border-bottom: 1px solid var(--border-color)">
                        Danh sách đặt phòng chờ Check-in
                    </div>
                    <c:choose>
                        <c:when test="${empty confirmedList}">
                            <div class="empty-state">
                                <i class="fa-solid fa-bell-concierge"></i>
                                <p>Không có booking nào chờ nhận phòng.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <table class="booking-table">
                                <thead>
                                <tr>
                                    <th>Mã Booking</th>
                                    <th>Khách hàng</th>
                                    <th>Loại phòng</th>
                                    <th>Ngày nhận / trả</th>
                                    <th>Phòng vật lý</th>
                                    <th>Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="b" items="${confirmedList}">
                                    <c:set var="assignedRoom" value="${assignedRoomsMap[b.bookingId]}" />
                                    <tr>
                                        <td><span class="booking-id-badge">#${b.bookingId}</span></td>
                                        <td><div class="customer-cell"><div class="name"><c:out value="${b.customerName}"/></div></div></td>
                                        <td><span class="roomtype-badge"><c:out value="${b.roomTypeName}"/></span></td>
                                        <td><div class="date-range">${b.checkInDate} → ${b.checkOutDate}</div></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty assignedRoom}">
                                                    <span style="font-weight:700;color:var(--success-green);">
                                                        Phòng ${assignedRoom.roomNumber} (${assignedRoom.floor})
                                                    </span>
                                                    <button type="button" class="btn-action-icon btn-edit" title="Đổi phòng" style="margin-left:6px;"
                                                            onclick="openAssignModal(${b.bookingId}, ${b.roomTypeId}, '<c:out value="${b.roomTypeName}" escapeXml="false"/>')">
                                                        <i class="fa-solid fa-arrows-rotate" style="font-size:12px;"></i>
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color:var(--danger-red);font-style:italic;">Chưa gán phòng</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty assignedRoom}">
                                                    <button type="button" style="height:32px;padding:0 12px;background:var(--success-green);color:#fff;border:none;border-radius:6px;font-weight:700;font-size:11px;cursor:pointer;"
                                                            onclick="openCheckinConfirmModal(${b.bookingId}, '<c:out value="${b.customerName}" escapeXml="false"/>', '${assignedRoom.roomNumber}')">
                                                        <i class="fa-solid fa-key" style="margin-right:4px;"></i> Nhận phòng
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <button type="button" style="height:32px;padding:0 12px;background:var(--brand-blue);color:#fff;border:none;border-radius:6px;font-weight:700;font-size:11px;cursor:pointer;"
                                                            onclick="openAssignModal(${b.bookingId}, ${b.roomTypeId}, '<c:out value="${b.roomTypeName}" escapeXml="false"/>')">
                                                        <i class="fa-solid fa-hotel" style="margin-right:4px;"></i> Gán phòng
                                                    </button>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:if>

            <%-- ===== CHECK-OUT TAB ===== --%>
            <c:if test="${currentTab eq 'checkout'}">
                <div class="content-header-row">
                    <div>
                        <h2><i class="fa-solid fa-file-invoice-dollar" style="color:var(--brand-blue);margin-right:8px"></i>Trả phòng & Thanh toán</h2>
                        <p>Quản lý các stays đang hoạt động, cập nhật dịch vụ giặt ủi, buffet và thực hiện thanh toán hóa đơn Checkout.</p>
                    </div>
                </div>

                <div class="table-card">
                    <div style="padding: 16px 20px; background: #f8fafc; font-weight: 700; color: var(--text-navy); border-bottom: 1px solid var(--border-color)">
                        Danh sách stays đang lưu trú
                    </div>
                    <c:choose>
                        <c:when test="${empty stayingList}">
                            <div class="empty-state">
                                <i class="fa-solid fa-bed"></i>
                                <p>Không có khách nào đang lưu trú tại khách sạn.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <table class="booking-table">
                                <thead>
                                <tr>
                                    <th>Mã stay</th>
                                    <th>Khách hàng</th>
                                    <th>Phòng</th>
                                    <th>Thời gian lưu trú</th>
                                    <th>Số dịch vụ</th>
                                    <th>Tổng tiền</th>
                                    <th>Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="b" items="${stayingList}">
                                    <c:set var="assignedRoom" value="${assignedRoomsMap[b.bookingId]}" />
                                    <c:set var="srvList" value="${bookingServicesMap[b.bookingId]}" />
                                    <tr>
                                        <td><span class="booking-id-badge">#${b.bookingId}</span></td>
                                        <td><div class="customer-cell"><div class="name"><c:out value="${b.customerName}"/></div></div></td>
                                        <td>
                                            <span class="roomtype-badge" style="background:#f5f3ff;color:#7c3aed;">
                                                Phòng ${not empty assignedRoom ? assignedRoom.roomNumber : '—'}
                                            </span>
                                        </td>
                                        <td><div class="date-range">${b.checkInDate} → ${b.checkOutDate} (${b.nights} đêm)</div></td>
                                        <td><span style="font-weight:700;color:var(--text-navy);">${fn:length(srvList)}</span></td>
                                        <td class="amount-cell">
                                            <fmt:formatNumber value="${b.totalAmount}" type="number" groupingUsed="true"/>đ
                                        </td>
                                        <td>
                                            <div style="display:flex;gap:6px;">
                                                <button type="button" style="height:32px;padding:0 12px;background:#f1f5f9;border:1px solid var(--border-color);border-radius:6px;font-weight:700;font-size:11px;color:#475569;cursor:pointer;"
                                                        onclick="openCheckoutBillModal(${b.bookingId}, '<c:out value="${b.customerName}" escapeXml="false"/>', '${assignedRoom.roomNumber}', ${assignedRoom.basePrice}, ${b.nights}, ${b.totalAmount}, ${assignedRoom.basePrice * b.nights * 0.1})">
                                                    <i class="fa-solid fa-bell" style="margin-right:4px;"></i> Stay Service
                                                </button>
                                                <button type="button" style="height:32px;padding:0 12px;background:var(--brand-blue);color:#fff;border:none;border-radius:6px;font-weight:700;font-size:11px;cursor:pointer;"
                                                        onclick="openCheckoutBillModal(${b.bookingId}, '<c:out value="${b.customerName}" escapeXml="false"/>', '${assignedRoom.roomNumber}', ${assignedRoom.basePrice}, ${b.nights}, ${b.totalAmount}, ${assignedRoom.basePrice * b.nights * 0.1})">
                                                    <i class="fa-solid fa-right-from-bracket" style="margin-right:4px;"></i> Trả phòng & Bill
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:if>

            <%-- ===== WALK-IN TAB ===== --%>
            <c:if test="${currentTab eq 'walkin'}">
                <div class="content-header-row">
                    <div>
                        <h2><i class="fa-solid fa-square-plus" style="color:var(--brand-blue);margin-right:8px"></i>Đặt phòng trực tiếp tại quầy (Walk-in)</h2>
                        <p>Đăng ký lưu trú trực tiếp cho khách vãng lai, tự động chọn phòng và nhận phòng ngay lập tức.</p>
                    </div>
                </div>

                <div class="table-card" style="max-width:680px; margin:0 auto; padding:24px;">
                    <form method="post" action="${pageContext.request.contextPath}/receptionist/booking" onsubmit="return validateWalkinForm()">
                        <input type="hidden" name="action" value="walkin" />
                        <input type="hidden" id="walkTotalAmount" name="totalAmount" value="0" />
                        
                        <div class="modal-form-group">
                            <label>Họ tên khách hàng <span style="color:var(--danger-red)">*</span></label>
                            <input type="text" name="customerName" class="modal-input" placeholder="Nhập tên khách..." required />
                        </div>

                        <div class="modal-grid-2">
                            <div class="modal-form-group">
                                <label>Ngày nhận phòng <span style="color:var(--danger-red)">*</span></label>
                                <input type="date" id="walkCheckIn" name="checkInDate" class="modal-input" onchange="recalcWalkinCost()" required />
                            </div>
                            <div class="modal-form-group">
                                <label>Ngày trả phòng <span style="color:var(--danger-red)">*</span></label>
                                <input type="date" id="walkCheckOut" name="checkOutDate" class="modal-input" onchange="recalcWalkinCost()" required />
                            </div>
                        </div>

                        <div class="modal-grid-2">
                            <div class="modal-form-group">
                                <label>Loại phòng <span style="color:var(--danger-red)">*</span></label>
                                <select id="walkRoomTypeId" name="roomTypeId" class="modal-select" onchange="loadWalkinRooms(); recalcWalkinCost()" required>
                                    <option value="">— Chọn loại phòng —</option>
                                    <c:forEach var="rt" items="${roomTypesList}">
                                        <option value="${rt.typeId}" data-price="${rt.basePrice}">
                                            <c:out value="${rt.typeName}"/> (đơn giá: <fmt:formatNumber value="${rt.basePrice}" type="number"/>đ)
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="modal-form-group">
                                <label>Phòng vật lý trống <span style="color:var(--danger-red)">*</span></label>
                                <select id="walkRoomId" name="roomId" class="modal-select" required>
                                    <option value="">— Chọn phòng vật lý —</option>
                                </select>
                            </div>
                        </div>

                        <div style="background:var(--bg-light); border:1px solid var(--border-color); border-radius:10px; padding:16px; margin:20px 0;">
                            <div style="display:flex; justify-content:space-between; margin-bottom:8px;">
                                <span style="font-weight:600; color:var(--text-muted);">Stay Duration:</span>
                                <span id="walkStayNights" style="font-weight:700; color:var(--text-navy);">0 đêm</span>
                            </div>
                            <div style="display:flex; justify-content:space-between;">
                                <span style="font-weight:600; color:var(--text-muted); font-size:15px;">Tổng chi phí dự kiến:</span>
                                <span id="walkCostText" style="font-weight:800; color:var(--brand-blue); font-size:18px;">0đ</span>
                            </div>
                        </div>

                        <div class="modal-form-group">
                            <label>Ghi chú đặt phòng</label>
                            <textarea name="note" class="modal-textarea" placeholder="Ghi chú thêm..."></textarea>
                        </div>

                        <div style="display:flex; justify-content:flex-end; gap:12px; margin-top:20px;">
                            <button type="reset" class="btn-modal-cancel" style="height:40px;">Reset Form</button>
                            <button type="submit" class="btn-modal-save" style="height:40px; padding:0 24px;">
                                <i class="fa-solid fa-check"></i> Xác nhận & Nhận phòng ngay
                            </button>
                        </div>
                    </form>
                </div>
            </c:if>
            
        </main>

        <footer class="dashboard-footer">
            <span>HotelOps Pro &copy; 2026</span>
            <span>Đăng nhập: <strong>${sessionScope.user}</strong></span>
        </footer>
    </div><%-- end dashboard-main --%>
</div><%-- end dashboard-layout --%>


<%-- ================================================================
     MODAL: GÁN PHÒNG VẬT LÝ (ASSIGN ROOM)
     ================================================================ --%>
<div id="modalAssign" class="modal-overlay">
    <div class="modal-container">
        <div class="modal-header">
            <h3><i class="fa-solid fa-hotel" style="color:var(--brand-blue);margin-right:8px"></i>Gán phòng vật lý</h3>
            <button class="btn-close-modal" onclick="closeModal('modalAssign')">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/receptionist/booking">
            <input type="hidden" name="action" value="assign" />
            <input type="hidden" id="assignBookingId" name="bookingId" />
            <div class="modal-body">
                <p style="font-size:13px;color:var(--text-muted);margin-bottom:16px;">
                    Vui lòng chọn phòng vật lý trống phù hợp cho loại phòng: <strong id="assignRoomTypeName"></strong>.
                </p>
                <div class="modal-form-group">
                    <label>Phòng vật lý trống</label>
                    <select id="assignRoomId" name="roomId" class="modal-select" required>
                        <option value="">— Chọn phòng vật lý —</option>
                        <c:forEach var="entry" items="${availableRoomsMap}">
                            <c:forEach var="r" items="${entry.value}">
                                <option value="${r.roomId}" data-typeid="${r.typeId}">
                                    Phòng ${r.roomNumber} (${r.floor}) — Trống/Sạch
                                </option>
                            </c:forEach>
                        </c:forEach>
                    </select>
                </div>
                <div class="modal-footer-row">
                    <button type="button" class="btn-modal-cancel" onclick="closeModal('modalAssign')">Đóng</button>
                    <button type="submit" class="btn-modal-save">
                        <i class="fa-solid fa-hotel"></i> Xác nhận gán phòng
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<%-- ================================================================
     MODAL: CONFIRM CHECK-IN
     ================================================================ --%>
<div id="modalCheckinConfirm" class="modal-overlay">
    <div class="modal-container">
        <div class="modal-header">
            <h3><i class="fa-solid fa-key" style="color:var(--success-green);margin-right:8px"></i>Xác nhận nhận phòng (Check-in)</h3>
            <button class="btn-close-modal" onclick="closeModal('modalCheckinConfirm')">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/receptionist/booking">
            <input type="hidden" name="action" value="checkin" />
            <input type="hidden" id="checkinBookingId" name="bookingId" />
            <div class="modal-body">
                <div style="background:var(--brand-blue-light); border:1px solid #d0e3f8; border-radius:10px; padding:16px; font-size:14px; margin-bottom:16px;">
                    Xác nhận cho khách hàng <strong id="checkinCustomerName"></strong> nhận phòng vật lý: <strong id="checkinRoomNumber" style="color:var(--brand-blue);font-size:16px;"></strong>.
                    <br/><br/>
                    Hệ thống sẽ cập nhật trạng thái đặt phòng thành <strong>Checked-in</strong> và phòng vật lý thành <strong>Occupied</strong>.
                </div>
                <div class="modal-footer-row">
                    <button type="button" class="btn-modal-cancel" onclick="closeModal('modalCheckinConfirm')">Hủy bỏ</button>
                    <button type="submit" class="btn-modal-confirm">
                        <i class="fa-solid fa-key"></i> Xác nhận Check-in
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<%-- ================================================================
     MODAL: CHECKOUT & SERVICE MANAGEMENT
     ================================================================ --%>
<div id="modalCheckoutBill" class="modal-overlay">
    <div class="modal-container modal-lg">
        <div class="modal-header">
            <h3><i class="fa-solid fa-file-invoice-dollar" style="color:var(--brand-blue);margin-right:8px"></i>Trả phòng & Thanh toán Stay</h3>
            <button class="btn-close-modal" onclick="closeModal('modalCheckoutBill')">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <div class="modal-body">
            <div class="detail-grid">
                <div class="detail-item">
                    <label>Tên khách hàng</label>
                    <span id="outCustomerName"></span>
                </div>
                <div class="detail-item">
                    <label>Phòng vật lý</label>
                    <span id="outRoomNumber" style="color:var(--brand-blue);font-weight:700;"></span>
                </div>
            </div>

            <hr style="border:none; border-top:1px solid var(--border-color); margin:16px 0;" />

            <%-- Stay Service Add Form --%>
            <div style="background:var(--bg-light); border:1px solid var(--border-color); border-radius:10px; padding:16px; margin-bottom:20px;">
                <h4 style="margin:0 0 12px 0; color:var(--text-navy); font-size:13px; font-weight:700;">
                    <i class="fa-solid fa-plus-circle" style="color:var(--brand-blue)"></i> Thêm dịch vụ lưu trú
                </h4>
                <form id="formAddService" method="post" action="${pageContext.request.contextPath}/receptionist/booking">
                    <input type="hidden" name="action" value="add_service" />
                    <input type="hidden" class="service-add-booking-id" name="bookingId" />
                    <div style="display:grid; grid-template-columns: 2fr 1fr 1fr; gap:10px; align-items:flex-end;">
                        <div class="modal-form-group" style="margin:0;">
                            <label>Dịch vụ</label>
                            <select id="addServiceId" name="serviceId" class="modal-select" onchange="updateServicePrice()" required>
                                <option value="">— Chọn dịch vụ —</option>
                                <c:forEach var="s" items="${servicesList}">
                                    <option value="${s.serviceId}" data-price="${s.price}">
                                        <c:out value="${s.serviceName}"/> (<fmt:formatNumber value="${s.price}" type="number"/>đ)
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="modal-form-group" style="margin:0;">
                            <label>Số lượng</label>
                            <input type="number" id="addServiceQty" name="quantity" class="modal-input" min="1" value="1" required />
                        </div>
                        <input type="hidden" id="addServicePrice" name="price" value="0" />
                        <button type="submit" class="btn-modal-save" style="height:40px; font-weight:700; width:100%; border-radius:8px;">
                            Thêm dịch vụ
                        </button>
                    </div>
                </form>
            </div>

            <%-- Services List --%>
            <div style="margin-bottom:20px;">
                <h4 style="margin:0 0 10px 0; color:var(--text-navy); font-size:13px;">Dịch vụ đã sử dụng</h4>
                <div id="outServicesList" style="max-height:160px; overflow-y:auto; padding:0 4px;">
                    <%-- Loaded via JS --%>
                </div>
            </div>

            <hr style="border:none; border-top:1px solid var(--border-color); margin:16px 0;" />

            <%-- Price calculations --%>
            <div style="display:flex; flex-direction:column; gap:8px; background:var(--bg-light); border:1px solid var(--border-color); border-radius:10px; padding:16px;">
                <div style="display:flex; justify-content:space-between;">
                    <span style="color:var(--text-muted); font-weight:600;">Tiền phòng (Base stay cost):</span>
                    <span id="outRoomCharge" style="font-weight:700;">0đ</span>
                </div>
                <div style="display:flex; justify-content:space-between;">
                    <span style="color:var(--text-muted); font-weight:600;">Tổng phí dịch vụ:</span>
                    <span id="outServiceCharge" style="font-weight:700;">0đ</span>
                </div>
                <div style="display:flex; justify-content:space-between;">
                    <span style="color:var(--text-muted); font-weight:600;">Tiền đặt cọc (Khấu trừ):</span>
                    <span id="outDeposit" style="font-weight:700; color:var(--danger-red);">-0đ</span>
                </div>
                <hr style="border:none; border-top:1px dashed var(--border-color); margin:8px 0;" />
                <div style="display:flex; justify-content:space-between;">
                    <span style="font-size:16px; font-weight:800; color:var(--text-navy);">Số tiền cần thanh toán:</span>
                    <span id="outFinalTotal" style="font-size:20px; font-weight:800; color:var(--brand-blue);">0đ</span>
                </div>
            </div>

            <%-- Checkout execution form --%>
            <form id="formCheckout" method="post" action="${pageContext.request.contextPath}/receptionist/booking">
                <input type="hidden" name="action" value="checkout" />
                <input type="hidden" id="outBookingId" name="bookingId" />
                <input type="hidden" id="outFinalTotalInput" name="totalAmount" />
                
                <div class="modal-footer-row">
                    <button type="button" class="btn-modal-cancel" onclick="closeModal('modalCheckoutBill')">Hủy bỏ</button>
                    <button type="submit" class="btn-modal-confirm" style="height:44px; padding:0 28px; font-size:14px;">
                        <i class="fa-solid fa-file-invoice-dollar"></i> Xác nhận thanh toán & Trả phòng
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- ================================================================
     MODAL: XEM CHI TIẾT (view-only)
     ================================================================ --%>
<div id="modalDetail" class="modal-overlay">
    <div class="modal-container">
        <div class="modal-header">
            <h3><i class="fa-solid fa-file-lines" style="color:var(--brand-blue);margin-right:8px"></i>
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
                    <span id="detailAmount" style="color:var(--brand-blue);font-size:16px"></span>
                </div>
                <div class="detail-item" style="grid-column:span 2">
                    <label>Ghi chú / Lý do</label>
                    <span id="detailNote" style="font-weight:400;color:var(--text-muted)"></span>
                </div>
            </div>
            <div class="modal-footer-row">
                <button type="button" class="btn-modal-cancel" onclick="closeModal('modalDetail')">Đóng</button>
            </div>
        </div>
    </div>
</div>

<%-- ================================================================
     MODAL: HUỶ booking
     ================================================================ --%>
<div id="modalCancel" class="modal-overlay">
    <div class="modal-container">
        <div class="modal-header">
            <h3><i class="fa-solid fa-ban" style="color:#64748b;margin-right:8px"></i>Huỷ đặt phòng</h3>
            <button class="btn-close-modal" onclick="closeModal('modalCancel')">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/receptionist/booking">
            <input type="hidden" name="action" value="cancel" />
            <input type="hidden" id="cancelBookingId" name="bookingId" />
            <div class="modal-body">
                <p style="font-size:14px;color:var(--text-navy-light);margin-bottom:16px">
                    Huỷ yêu cầu đặt phòng của khách <strong id="cancelCustomerName"></strong>.
                </p>
                <div class="modal-form-group">
                    <label>Lý do huỷ (tuỳ chọn)</label>
                    <textarea id="cancelReason" name="reason" class="modal-textarea"
                               placeholder="VD: Huỷ theo yêu cầu của khách..."></textarea>
                </div>
                <div class="modal-footer-row">
                    <button type="button" class="btn-modal-cancel" onclick="closeModal('modalCancel')">Không huỷ</button>
                    <button type="submit" style="height:40px;padding:0 20px;background:#64748b;border:none;border-radius:8px;font-weight:700;font-size:13px;color:#fff;cursor:pointer;">
                        <i class="fa-solid fa-ban"></i> Xác nhận huỷ
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>


<%-- JS Global variables --%>
<script>
    window.contextPath = '${pageContext.request.contextPath}';
    window.globalBookingServicesMap = {
        <c:forEach var="entry" items="${bookingServicesMap}" varStatus="mapLoop">
            "${entry.key}": [
                <c:forEach var="s" items="${entry.value}" varStatus="srvLoop">
                    {
                        serviceId: ${s.serviceId},
                        serviceName: "<c:out value="${s.serviceName}"/>",
                        description: "<c:out value="${s.description}"/>",
                        price: ${s.price}
                    }${not srvLoop.last ? ',' : ''}
                </c:forEach>
            ]${not mapLoop.last ? ',' : ''}
        </c:forEach>
    };
    
    // Global room type list for walkin select options
    window.globalAvailableRoomsMap = {
        <c:forEach var="entry" items="${availableRoomsMap}" varStatus="mapLoop">
            "${entry.key}": [
                <c:forEach var="r" items="${entry.value}" varStatus="roomLoop">
                    {
                        roomId: ${r.roomId},
                        roomNumber: "<c:out value="${r.roomNumber}"/>",
                        floor: "<c:out value="${r.floor}"/>",
                        typeId: ${r.typeId}
                    }${not roomLoop.last ? ',' : ''}
                </c:forEach>
            ]${not mapLoop.last ? ',' : ''}
        </c:forEach>
    };
</script>

<script src="${pageContext.request.contextPath}/assets/js/receptionist.js?v=1.1"></script>
</body>
</html>
