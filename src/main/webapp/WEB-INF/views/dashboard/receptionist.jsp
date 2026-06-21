<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Quản lý đặt phòng - HotelOps Pro</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/receptionist.css?v=4" />
</head>
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
                    <i class="fa-solid fa-right-from-bracket"></i> <span>Trả phòng & Thanh toán</span>
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
                <span class="current">Quản lý đặt phòng</span>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
            </a>
        </header>

        <%-- WORKSPACE --%>
        <main class="workspace-content">

            <%-- ===== BOOKING TAB ===== --%>
            <c:if test="${currentTab eq 'bookings'}">

                <%-- Toast notification --%>
                <c:if test="${param.result eq 'success'}">
                    <div class="toast-notify toast-success">
                        <i class="fa-solid fa-circle-check"></i>
                        <c:choose>
                            <c:when test="${param.action eq 'confirm'}">Đã xác nhận booking thành công!</c:when>
                            <c:when test="${param.action eq 'reject'}">Đã từ chối booking.</c:when>
                            <c:when test="${param.action eq 'update'}">Đã cập nhật thông tin booking!</c:when>
                            <c:when test="${param.action eq 'cancel'}">Đã huỷ booking.</c:when>
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
                            <c:when test="${param.error eq 'parse'}">Lỗi định dạng dữ liệu (ngày hoặc số không hợp lệ).</c:when>
                            <c:when test="${param.error eq 'invalid'}">Mã yêu cầu hoặc trạng thái không hợp lệ.</c:when>
                            <c:when test="${param.error eq 'validation'}">Thông tin không hợp lệ: vui lòng kiểm tra lại điều kiện nhập liệu.</c:when>
                            <c:otherwise>Đã có lỗi xảy ra. Vui lòng thử lại sau.</c:otherwise>
                        </c:choose>
                    </div>
                </c:if>

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
                                        <%-- Mã --%>
                                        <td>
                                            <span class="booking-id-badge">#${b.bookingId}</span>
                                        </td>

                                        <%-- Khách hàng --%>
                                        <td>
                                            <div class="customer-cell">
                                                <div class="name"><c:out value="${b.customerName}" /></div>
                                                <div class="meta">Đặt: ${b.createdAt}</div>
                                            </div>
                                        </td>

                                        <%-- Loại phòng --%>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty b.roomTypeName}">
                                                    <span class="roomtype-badge"><c:out value="${b.roomTypeName}" /></span>
                                                    <br/><small style="color:var(--text-muted)">${b.roomQuantity} phòng</small>
                                                </c:when>
                                                <c:otherwise><span style="color:var(--text-muted)">—</span></c:otherwise>
                                            </c:choose>
                                        </td>

                                        <%-- Ngày --%>
                                        <td>
                                            <div class="date-range">
                                                ${b.checkInDate} → ${b.checkOutDate}
                                                <span class="nights">${b.nights} đêm</span>
                                            </div>
                                            <div style="margin-top: 4px; font-size: 11px;">
                                                <c:choose>
                                                    <c:when test="${not empty b.assignedRoomsStr}">
                                                        <span style="color: var(--brand-blue); font-weight: 600;">
                                                            <i class="fa-solid fa-door-open" style="margin-right: 4px;"></i> Phòng: ${b.assignedRoomsStr}
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="color: var(--text-muted); font-style: italic;">
                                                            <i class="fa-solid fa-door-closed" style="margin-right: 4px; opacity: 0.5;"></i> Chưa phân phòng
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>


                                        <%-- Tổng tiền --%>
                                        <td class="amount-cell">
                                            <fmt:formatNumber value="${b.totalAmount}" type="number" groupingUsed="true"/>đ
                                        </td>

                                        <%-- Trạng thái --%>
                                        <td>
                                            <c:choose>
                                                <c:when test="${b.status eq 'Pending'}">
                                                    <span class="status-pill pill-pending">
                                                        <i class="fa-solid fa-circle"></i> Chờ xử lý
                                                    </span>
                                                </c:when>
                                                <c:when test="${b.status eq 'Confirmed'}">
                                                    <span class="status-pill pill-confirmed">
                                                        <i class="fa-solid fa-circle"></i> Đã xác nhận
                                                    </span>
                                                </c:when>
                                                <c:when test="${b.status eq 'Rejected'}">
                                                    <span class="status-pill pill-rejected">
                                                        <i class="fa-solid fa-circle"></i> Từ chối
                                                    </span>
                                                </c:when>
                                                <c:when test="${b.status eq 'Cancelled'}">
                                                    <span class="status-pill pill-cancelled">
                                                        <i class="fa-solid fa-circle"></i> Đã huỷ
                                                    </span>
                                                </c:when>
                                                <c:when test="${b.status eq 'CheckedIn'}">
                                                    <span class="status-pill pill-checkedin">
                                                        <i class="fa-solid fa-circle"></i> Đã check-in
                                                    </span>
                                                </c:when>
                                                <c:when test="${b.status eq 'CheckedOut'}">
                                                    <span class="status-pill pill-checkedout">
                                                        <i class="fa-solid fa-circle"></i> Đã trả phòng
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-pill pill-cancelled"><c:out value="${b.status}" /></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <%-- Thao tác --%>
                                        <td>
                                            <div class="actions-cell">
                                                <%-- Xem chi tiết --%>
                                                <a href="${pageContext.request.contextPath}/receptionist/booking/detail?bookingId=${b.bookingId}"
                                                   class="btn-action-icon btn-edit"
                                                   title="Xem chi tiết">
                                                    <i class="fa-solid fa-eye"></i>
                                                </a>

                                                <%-- Cập nhật thông tin (chỉ Pending hoặc Confirmed) --%>
                                                <c:if test="${b.status eq 'Pending' || b.status eq 'Confirmed'}">
                                                    <a href="${pageContext.request.contextPath}/receptionist/booking/process?bookingId=${b.bookingId}"
                                                       class="btn-action-icon btn-edit"
                                                       title="Cập nhật & Duyệt">
                                                        <i class="fa-solid fa-pen-to-square"></i>
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
            
            <%-- ===== CHECK-IN TAB (ITERATION 2/3) ===== --%>
            <c:if test="${currentTab eq 'checkin'}">
                <div class="content-header-row">
                    <div>
                        <h2><i class="fa-solid fa-key" style="color:var(--brand-blue);margin-right:8px"></i>Nhận phòng (Check-in)</h2>
                        <p>Tính năng hỗ trợ khách hàng nhận phòng đang được phát triển.</p>
                    </div>
                </div>
                <div class="table-card" style="padding: 80px 20px; text-align: center; color: var(--text-muted);">
                    <i class="fa-solid fa-person-digging" style="font-size: 64px; margin-bottom: 20px; opacity: 0.2;"></i>
                    <h3>Tính năng đang phát triển</h3>
                </div>
            </c:if>
            
            <%-- ===== CHECK-OUT TAB (ITERATION 3) ===== --%>
            <c:if test="${currentTab eq 'checkout'}">
                <div class="content-header-row">
                    <div>
                        <h2><i class="fa-solid fa-file-invoice-dollar" style="color:var(--brand-blue);margin-right:8px"></i>Trả phòng & Thanh toán</h2>
                        <p>Xử lý thanh toán, phụ phí và xuất hoá đơn (Iteration 3).</p>
                    </div>
                </div>
                <div class="table-card" style="padding: 80px 20px; text-align: center; color: var(--text-muted);">
                    <i class="fa-solid fa-person-digging" style="font-size: 64px; margin-bottom: 20px; opacity: 0.2;"></i>
                    <h3>Tính năng đang phát triển</h3>
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
     MODAL: XÁC NHẬN booking
     ================================================================ --%>
<div id="modalConfirm" class="modal-overlay">
    <div class="modal-container">
        <div class="modal-header">
            <h3><i class="fa-solid fa-check-circle" style="color:#10b981;margin-right:8px"></i>Xác nhận đặt phòng</h3>
            <button class="btn-close-modal" onclick="closeModal('modalConfirm')">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <form id="formConfirm" method="post" action="${pageContext.request.contextPath}/receptionist/booking">
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
                    <button type="button" class="btn-modal-cancel" onclick="closeModal('modalConfirm')">Huỷ</button>
                    <button type="submit" class="btn-modal-confirm">
                        <i class="fa-solid fa-check"></i> Xác nhận
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<%-- ================================================================
     MODAL: TỪ CHỐI booking
     ================================================================ --%>
<div id="modalReject" class="modal-overlay">
    <div class="modal-container">
        <div class="modal-header">
            <h3><i class="fa-solid fa-times-circle" style="color:#ef4444;margin-right:8px"></i>Từ chối đặt phòng</h3>
            <button class="btn-close-modal" onclick="closeModal('modalReject')">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <form id="formReject" method="post" action="${pageContext.request.contextPath}/receptionist/booking">
            <input type="hidden" name="action" value="reject" />
            <input type="hidden" id="rejectBookingId" name="bookingId" />
            <div class="modal-body">
                <p style="font-size:14px;color:var(--text-navy-light);margin-bottom:16px">
                    Từ chối yêu cầu của khách <strong id="rejectCustomerName"></strong>.
                    Vui lòng nhập lý do để thông báo cho khách.
                </p>
                <div class="modal-form-group">
                    <label>Lý do từ chối <span style="color:#ef4444">*</span></label>
                    <textarea id="rejectReason" name="reason" class="modal-textarea"
                              placeholder="VD: Phòng không còn trống trong khoảng thời gian yêu cầu..." maxlength="500" required></textarea>
                </div>
                <div class="modal-footer-row">
                    <button type="button" class="btn-modal-cancel" onclick="closeModal('modalReject')">Huỷ</button>
                    <button type="button" class="btn-modal-reject" onclick="submitReject()">
                        <i class="fa-solid fa-times"></i> Từ chối
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<%-- ================================================================
     MODAL: CẬP NHẬT thông tin booking
     ================================================================ --%>
<div id="modalEdit" class="modal-overlay">
    <div class="modal-container modal-lg">
        <div class="modal-header">
            <h3><i class="fa-solid fa-pen-to-square" style="color:var(--brand-blue);margin-right:8px"></i>Cập nhật thông tin booking</h3>
            <button class="btn-close-modal" onclick="closeModal('modalEdit')">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/receptionist/booking">
            <input type="hidden" name="action" value="update" />
            <input type="hidden" id="editBookingId" name="bookingId" />
            <div class="modal-body">
                <p style="font-size:12px;color:var(--text-muted);margin-bottom:16px">
                    <i class="fa-solid fa-circle-info"></i>
                    Chỉ có thể cập nhật khi booking ở trạng thái <strong>Chờ xử lý</strong>.
                </p>

                <div class="modal-form-group">
                    <label>Tên khách hàng <span style="color:#ef4444">*</span></label>
                    <input type="text" id="editCustomerName" name="customerName" class="modal-input" maxlength="100" required />
                </div>

                <div class="modal-grid-2">
                    <div class="modal-form-group">
                        <label>Ngày nhận phòng <span style="color:#ef4444">*</span></label>
                        <input type="date" id="editCheckIn" name="checkInDate" class="modal-input"
                               onchange="recalcAmount()" required />
                    </div>
                    <div class="modal-form-group">
                        <label>Ngày trả phòng <span style="color:#ef4444">*</span></label>
                        <input type="date" id="editCheckOut" name="checkOutDate" class="modal-input"
                               onchange="recalcAmount()" required />
                    </div>
                </div>

                <%-- Dropdown loại phòng từ DB --%>
                <div class="modal-grid-2">
                    <div class="modal-form-group">
                        <label>Loại phòng</label>
                        <select id="editRoomTypeId" name="roomTypeId" class="modal-select"
                                onchange="recalcAmount()">
                            <option value="">— Chọn loại phòng —</option>
                            <c:if test="${not empty roomTypesList}">
                                <c:forEach var="rt" items="${roomTypesList}">
                                    <option value="${rt.typeId}" data-price="${rt.basePrice}">
                                        <c:out value="${rt.typeName}" /> — <fmt:formatNumber value="${rt.basePrice}" type="number"/>đ/đêm
                                    </option>
                                </c:forEach>
                            </c:if>
                        </select>
                    </div>
                    <div class="modal-form-group">
                        <label>Số phòng <span style="color:#ef4444">*</span></label>
                        <input type="number" id="editRoomQuantity" name="roomQuantity" class="modal-input"
                               min="1" max="100" onchange="recalcAmount()" required />
                    </div>
                </div>

                <div class="modal-form-group">
                    <label>Tổng tiền (VND) <span style="color:#ef4444">*</span></label>
                    <input type="number" id="editTotalAmount" name="totalAmount" class="modal-input" min="0" required />
                </div>

                <div class="modal-form-group">
                    <label>Ghi chú</label>
                    <textarea id="editNote" name="note" class="modal-textarea"
                              placeholder="Ghi chú yêu cầu đặc biệt..." maxlength="500"></textarea>
                </div>

                <div class="modal-footer-row">
                    <button type="button" class="btn-modal-cancel" onclick="closeModal('modalEdit')">Huỷ</button>
                    <button type="submit" class="btn-modal-save">
                        <i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi
                    </button>
                </div>
            </div>
        </form>
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
                              placeholder="VD: Huỷ theo yêu cầu của khách..." maxlength="500"></textarea>
                </div>
                <div class="modal-footer-row">
                    <button type="button" class="btn-modal-cancel" onclick="closeModal('modalCancel')">Không huỷ</button>
                    <button type="submit" class="btn-modal-save" style="background:#64748b;">
                        <i class="fa-solid fa-ban"></i> Xác nhận huỷ
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/receptionist.js?v=4" charset="UTF-8"></script>
</body>
</html>
