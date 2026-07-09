<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer_booking.css?v=21" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/booking-requests.css?v=1" />
<fmt:setLocale value="vi_VN" />

<body>

    <%-- Header Navigation --%>
    <nav class="navbar-rooms">
        <div class="logo">HotelOps</div>
        <ul class="nav-links">
            <li><a href="${pageContext.request.contextPath}/">Trang chủ</a></li>
            <li><a href="${pageContext.request.contextPath}/rooms">Phòng</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/bookings" class="active">Đặt phòng của tôi</a></li>
        </ul>

        <div class="nav-actions">
            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <div class="user-dropdown">
                        <button class="dropdown-trigger" type="button">
                            <i class="fa-solid fa-user-circle"></i>
                            <span>${sessionScope.user}</span>
                            <i class="fa-solid fa-chevron-down" style="font-size: 10px; margin-left: 2px;"></i>
                        </button>
                        <div class="dropdown-menu">
                            <c:choose>
                                <c:when test="${sessionScope.role eq 'CUSTOMER'}">
                                    <a href="${pageContext.request.contextPath}/customer/profile" class="dropdown-item">
                                        <i class="fa-solid fa-id-card"></i> Hồ sơ
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/bookings" class="dropdown-item">
                                        <i class="fa-solid fa-calendar-check"></i> Đặt phòng của tôi
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/services" class="dropdown-item">
                                        <i class="fa-solid fa-bell-concierge"></i> Yêu cầu dịch vụ
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/maintenance" class="dropdown-item">
                                        <i class="fa-solid fa-screwdriver-wrench"></i> Yêu cầu sửa chữa
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/services/history" class="dropdown-item">
                                        <i class="fa-solid fa-clock-rotate-left"></i> Lịch sử yêu cầu
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <c:choose>
                                        <c:when test="${sessionScope.role eq 'ADMIN'}">
                                            <a href="${pageContext.request.contextPath}/admin/dashboard" class="dropdown-item">
                                                <i class="fa-solid fa-chart-line"></i> Dashboard Admin
                                            </a>
                                        </c:when>
                                        <c:when test="${sessionScope.role eq 'MANAGER'}">
                                            <a href="${pageContext.request.contextPath}/manager/dashboard" class="dropdown-item">
                                                <i class="fa-solid fa-chart-line"></i> Dashboard Manager
                                            </a>
                                        </c:when>
                                        <c:when test="${sessionScope.role eq 'RECEPTIONIST'}">
                                            <a href="${pageContext.request.contextPath}/receptionist/dashboard" class="dropdown-item">
                                                <i class="fa-solid fa-chart-line"></i> Dashboard Receptionist
                                            </a>
                                        </c:when>
                                        <c:when test="${sessionScope.role eq 'HOUSEKEEPING'}">
                                            <a href="${pageContext.request.contextPath}/housekeeping/dashboard" class="dropdown-item">
                                                <i class="fa-solid fa-chart-line"></i> Dashboard Housekeeping
                                            </a>
                                        </c:when>
                                    </c:choose>
                                </c:otherwise>
                            </c:choose>
                            <div class="dropdown-divider"></div>
                            <a href="${pageContext.request.contextPath}/logout" class="dropdown-item logout-item">
                                <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/home/login" class="btn-login">Đăng nhập</a>
                </c:otherwise>
            </c:choose>
        </div>
    </nav>

    <div class="booking-container">
        <div class="booking-header">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
                <div>
                    <h1>Quản lý Đặt Phòng Của Tôi</h1>
                    <p>Xem lịch sử giao dịch và trạng thái các đơn đặt phòng của bạn</p>
                </div>
                <div class="br-actions">
                    <button type="button" class="br-btn br-btn-change" onclick="openChangeModal()">
                        <i class="fa-solid fa-pen-to-square"></i> Yêu cầu thay đổi
                    </button>
                    <button type="button" class="br-btn br-btn-ext" onclick="openExtensionModal()">
                        <i class="fa-solid fa-calendar-plus"></i> Gia hạn lưu trú
                    </button>
                    <a href="${pageContext.request.contextPath}/customer/booking/create" class="btn-primary" style="margin-top: 0; width: auto; padding: 10px 20px;">
                        <i class="fa-solid fa-calendar-plus"></i> Đặt phòng mới
                    </a>
                </div>
            </div>
        </div>

        <%-- Alerts --%>
        <c:if test="${not empty successMessage}">
            <div class="success-banner" id="serverSuccessMessage">
                <i class="fa-solid fa-circle-check" style="font-size: 20px;"></i>
                <div>
                    <strong>Thành công:</strong> ${successMessage}
                </div>
            </div>
        </c:if>
        <c:if test="${not empty errorCode}">
            <div class="error-banner" id="serverValidationError">
                <i class="fa-solid fa-circle-exclamation" style="font-size: 20px;"></i>
                <div>
                    <strong>Yêu cầu thất bại:</strong> ${errorMessage}
                </div>
            </div>
        </c:if>

        <%-- Filter & Search Form --%>
        <div class="booking-card" style="padding: 20px; margin-bottom: 25px;">
            <form action="${pageContext.request.contextPath}/customer/bookings" method="GET" id="filterForm">
                <div class="filter-bar">
                    <%-- Keyword Search --%>
                    <div class="search-input-group">
                        <input type="text" name="keyword" placeholder="Tìm theo Mã đặt phòng hoặc Họ tên..." value="${keyword}" />
                        <button type="submit">
                            <i class="fa-solid fa-magnifying-glass"></i> Tìm kiếm
                        </button>
                    </div>


                </div>
            </form>
        </div>

        <%-- Bookings Table Card --%>
        <div class="booking-card" style="padding: 0; overflow-x: auto;">
            <table class="booking-list-table">
                <thead>
                    <tr>
                        <th>Mã đơn</th>
                        <th>Ngày đặt</th>
                        <th>Thời gian nghỉ</th>
                        <th>Loại phòng</th>
                        <th>Số phòng</th>
                        <th>Tổng tiền</th>
                        <th>Đặt cọc (30%)</th>
                        <th>Trạng thái</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty bookings}">
                            <c:forEach var="b" items="${bookings}">
                                <tr>
                                    <td style="font-weight: 700;">#${b.bookingId}</td>
                                    <td>
                                        <fmt:formatDate value="${b.createdAt}" pattern="dd/MM/yyyy" />
                                    </td>
                                    <td>
                                        <div style="font-weight: 600; color: var(--primary-indigo);">
                                            <fmt:formatDate value="${b.checkInDate}" pattern="dd/MM/yyyy" /> - 
                                            <fmt:formatDate value="${b.checkOutDate}" pattern="dd/MM/yyyy" />
                                        </div>
                                        <small style="color: var(--text-muted);">${b.nights} đêm</small>
                                    </td>
                                     <td style="max-width: 200px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="${b.groupRoomTypeNames}">
                                         ${b.groupRoomTypeNames}
                                     </td>
                                     <td style="font-weight: 600;">${b.totalRoomQuantity} phòng</td>
                                     <td style="font-weight: 700; color: var(--primary-indigo);">
                                         <fmt:formatNumber value="${b.overallTotalAmount}" type="currency" currencySymbol="" /> VND
                                     </td>
                                     <td style="font-weight: 600; color: var(--accent-gold);">
                                         <fmt:formatNumber value="${b.overallTotalAmount * 0.3}" type="currency" currencySymbol="" /> VND
                                     </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${b.status eq 'Pending'}">
                                                <span class="badge badge-pending">Chờ duyệt</span>
                                            </c:when>
                                            <c:when test="${b.status eq 'Confirmed'}">
                                                <span class="badge badge-confirmed">Đã xác nhận</span>
                                            </c:when>
                                            <c:when test="${b.status eq 'CheckedIn'}">
                                                <span class="badge badge-checkedin">Đã nhận phòng</span>
                                            </c:when>
                                            <c:when test="${b.status eq 'CheckedOut'}">
                                                <span class="badge badge-checkedout">Đã trả phòng</span>
                                            </c:when>
                                            <c:when test="${b.status eq 'Cancelled'}">
                                                <span class="badge badge-cancelled">Đã hủy</span>
                                            </c:when>
                                            <c:when test="${b.status eq 'Rejected'}">
                                                <span class="badge badge-rejected">Từ chối</span>
                                            </c:when>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div style="display: flex; gap: 8px;">
                                            <a href="${pageContext.request.contextPath}/customer/booking/detail?id=${b.bookingId}" class="btn-secondary" style="text-decoration: none; padding: 6px 12px; font-size: 13px;">
                                                Chi tiết
                                            </a>
                                            <c:if test="${b.status eq 'Pending' || b.status eq 'Confirmed'}">
                                                <button type="button" class="btn-danger" style="padding: 6px 12px; font-size: 13px;" onclick="confirmCancelBooking(${b.bookingId})">
                                                    Hủy
                                                </button>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="9" style="text-align: center; padding: 40px; color: var(--text-muted);">
                                    <i class="fa-solid fa-calendar-xmark" style="font-size: 40px; margin-bottom: 15px; display: block; color: #cbd5e1;"></i>
                                    Bạn chưa có đơn đặt phòng nào phù hợp với bộ lọc tìm kiếm.
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>

        <%-- Request tracking (booking change & stay extension) --%>
        <c:if test="${not empty myRequests}">
            <div class="booking-card req-track-card" style="padding: 24px;">
                <h2><i class="fa-solid fa-clipboard-list" style="color: var(--brand-blue);"></i> Yêu cầu thay đổi &amp; gia hạn của tôi</h2>
                <p>Theo dõi trạng thái các yêu cầu thay đổi đặt phòng và gia hạn lưu trú của bạn.</p>
                <div style="overflow-x: auto;">
                    <table class="booking-list-table">
                        <thead>
                            <tr>
                                <th>Mã đơn</th>
                                <th>Loại yêu cầu</th>
                                <th>Chi tiết yêu cầu</th>
                                <th>Phụ phí dự kiến</th>
                                <th>Ngày gửi</th>
                                <th>Trạng thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="r" items="${myRequests}">
                                <tr>
                                    <td style="font-weight: 700;">#${r.bookingId}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.extension}">
                                                <span class="req-type-pill extension">Gia hạn lưu trú</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="req-type-pill change">Thay đổi đặt phòng</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="font-size: 13px;">
                                        <c:choose>
                                            <c:when test="${r.extension}">
                                                Trả phòng mới:
                                                <strong><fmt:formatDate value="${r.newCheckOut}" pattern="dd/MM/yyyy" /></strong>
                                                <br/>
                                                <small style="color: var(--text-muted);">
                                                    (Hiện tại: <fmt:formatDate value="${r.oldCheckOut}" pattern="dd/MM/yyyy" />)
                                                </small>
                                            </c:when>
                                            <c:otherwise>
                                                <strong><fmt:formatDate value="${r.newCheckIn}" pattern="dd/MM/yyyy" /> -
                                                    <fmt:formatDate value="${r.newCheckOut}" pattern="dd/MM/yyyy" /></strong>
                                                <br/>
                                                <small style="color: var(--text-muted);">
                                                    ${r.newRoomTypeName} · ${r.newRoomQuantity} phòng
                                                </small>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="font-weight: 600; color: var(--gold-price);">
                                        <c:choose>
                                            <c:when test="${r.additionalCharge != null && r.additionalCharge > 0}">
                                                <fmt:formatNumber value="${r.additionalCharge}" type="number" /> VND
                                            </c:when>
                                            <c:otherwise><span style="color: var(--text-muted);">—</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><fmt:formatDate value="${r.createdAt}" pattern="dd/MM/yyyy" /></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.status eq 'Approved'}">
                                                <span class="req-status-pill approved">Đã duyệt</span>
                                            </c:when>
                                            <c:when test="${r.status eq 'Rejected'}">
                                                <span class="req-status-pill rejected">Từ chối</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="req-status-pill pending">Chờ duyệt</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:if>
    </div>

    <%-- Cancel Confirmation Form --%>
    <form action="${pageContext.request.contextPath}/customer/booking/cancel" method="POST" id="cancelForm" style="display: none;">
        <input type="hidden" name="id" id="cancelBookingId" value="" />
    </form>

    <%-- ============================================================
         MODAL: REQUEST BOOKING CHANGE (UC 2.3.9)
         ============================================================ --%>
    <div class="req-modal-overlay" id="changeModal">
        <div class="req-modal">
            <div class="req-modal-header">
                <h3><i class="fa-solid fa-pen-to-square"></i> Yêu cầu thay đổi đặt phòng</h3>
                <button type="button" class="req-modal-close" onclick="closeReqModal('changeModal')">&times;</button>
            </div>
            <div class="req-modal-body">
                <p class="req-hint">
                    <i class="fa-solid fa-circle-info"></i>
                    Chỉ áp dụng cho đơn <strong>Chờ duyệt</strong> hoặc <strong>Đã xác nhận</strong> và còn trước ngày nhận phòng.
                    Yêu cầu sẽ được gửi tới lễ tân/quản lý để duyệt.
                </p>
                <form action="${pageContext.request.contextPath}/customer/booking/change-request" method="POST"
                      id="changeForm" onsubmit="return validateChange();">
                    <div class="req-field">
                        <label>Chọn đơn đặt phòng <span class="req-star">*</span></label>
                        <select name="bookingId" id="changeBookingSelect" onchange="onChangeBookingSelect()" required>
                            <option value="">— Chọn đơn cần thay đổi —</option>
                            <c:forEach var="b" items="${bookings}">
                                <c:if test="${b.status eq 'Pending' || b.status eq 'Confirmed'}">
                                    <option value="${b.bookingId}"
                                            data-checkin="<fmt:formatDate value='${b.checkInDate}' pattern='yyyy-MM-dd' />"
                                            data-checkout="<fmt:formatDate value='${b.checkOutDate}' pattern='yyyy-MM-dd' />"
                                            data-roomtypeid="${b.roomTypeId}"
                                            data-qty="${b.roomQuantity}"
                                            data-roomtype="<c:out value='${b.groupRoomTypeNames}' />">
                                        #${b.bookingId} • <c:out value="${b.groupRoomTypeNames}" />
                                        (<fmt:formatDate value="${b.checkInDate}" pattern="dd/MM/yyyy" /> - <fmt:formatDate value="${b.checkOutDate}" pattern="dd/MM/yyyy" />)
                                    </option>
                                </c:if>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="req-current" id="changeCurrent">
                        <h4>Thông tin hiện tại</h4>
                        <div class="req-current-grid">
                            <span>Loại phòng: <b id="curChangeType">—</b></span>
                            <span>Số phòng: <b id="curChangeQty">—</b></span>
                            <span>Nhận phòng: <b id="curChangeIn">—</b></span>
                            <span>Trả phòng: <b id="curChangeOut">—</b></span>
                        </div>
                    </div>

                    <div class="req-grid-2">
                        <div class="req-field">
                            <label>Ngày nhận phòng mới <span class="req-star">*</span></label>
                            <input type="date" name="newCheckInDate" id="changeNewIn" required />
                        </div>
                        <div class="req-field">
                            <label>Ngày trả phòng mới <span class="req-star">*</span></label>
                            <input type="date" name="newCheckOutDate" id="changeNewOut" required />
                        </div>
                    </div>
                    <div class="req-grid-2">
                        <div class="req-field">
                            <label>Loại phòng mong muốn <span class="req-star">*</span></label>
                            <select name="roomTypeId" id="changeRoomType" required>
                                <option value="">— Chọn loại phòng —</option>
                                <c:forEach var="rt" items="${roomTypes}">
                                    <option value="${rt.typeId}" data-price="${rt.basePrice}">
                                        <c:out value="${rt.typeName}" /> — <fmt:formatNumber value="${rt.basePrice}" type="number" />đ/đêm
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="req-field">
                            <label>Số phòng <span class="req-star">*</span></label>
                            <input type="number" name="roomQuantity" id="changeQty" min="1" max="100" required />
                        </div>
                    </div>
                    <div class="req-field">
                        <label>Lý do thay đổi</label>
                        <textarea name="reason" maxlength="500" placeholder="VD: Thay đổi lịch trình công tác..."></textarea>
                    </div>

                    <div class="req-modal-footer">
                        <button type="button" class="br-btn br-btn-cancel" onclick="closeReqModal('changeModal')">Huỷ</button>
                        <button type="submit" class="br-btn br-btn-submit">
                            <i class="fa-solid fa-paper-plane"></i> Gửi yêu cầu
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%-- ============================================================
         MODAL: REQUEST STAY EXTENSION (UC 2.3.14)
         ============================================================ --%>
    <div class="req-modal-overlay" id="extModal">
        <div class="req-modal">
            <div class="req-modal-header">
                <h3><i class="fa-solid fa-calendar-plus"></i> Yêu cầu gia hạn lưu trú</h3>
                <button type="button" class="req-modal-close" onclick="closeReqModal('extModal')">&times;</button>
            </div>
            <div class="req-modal-body">
                <p class="req-hint">
                    <i class="fa-solid fa-circle-info"></i>
                    Chỉ áp dụng cho phòng bạn <strong>đang lưu trú (Đã nhận phòng)</strong>. Chọn ngày trả phòng mới muộn hơn để ở thêm.
                </p>
                <form action="${pageContext.request.contextPath}/customer/booking/extension-request" method="POST"
                      id="extForm" onsubmit="return validateExtension();">
                    <div class="req-field">
                        <label>Chọn phòng đang lưu trú <span class="req-star">*</span></label>
                        <select name="bookingId" id="extBookingSelect" onchange="onExtBookingSelect()" required>
                            <option value="">— Chọn đơn đang lưu trú —</option>
                            <c:forEach var="b" items="${bookings}">
                                <c:if test="${b.status eq 'CheckedIn'}">
                                    <option value="${b.bookingId}"
                                            data-checkout="<fmt:formatDate value='${b.checkOutDate}' pattern='yyyy-MM-dd' />"
                                            data-roomtypeid="${b.roomTypeId}"
                                            data-qty="${b.roomQuantity}"
                                            data-roomtype="<c:out value='${b.groupRoomTypeNames}' />">
                                        #${b.bookingId} • <c:out value="${b.groupRoomTypeNames}" />
                                        (Trả: <fmt:formatDate value="${b.checkOutDate}" pattern="dd/MM/yyyy" />)
                                    </option>
                                </c:if>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="req-current" id="extCurrent">
                        <h4>Thông tin hiện tại</h4>
                        <div class="req-current-grid">
                            <span>Loại phòng: <b id="curExtType">—</b></span>
                            <span>Số phòng: <b id="curExtQty">—</b></span>
                            <span>Ngày trả phòng hiện tại: <b id="curExtOut">—</b></span>
                        </div>
                    </div>

                    <div class="req-field">
                        <label>Ngày trả phòng mới <span class="req-star">*</span></label>
                        <input type="date" name="newCheckOutDate" id="extNewOut" onchange="updateExtEstimate()" required />
                    </div>

                    <div class="req-estimate" id="extEstimate">
                        Phụ phí dự kiến cho <span id="extNights">0</span> đêm:
                        <strong id="extCharge">0 VND</strong>
                    </div>

                    <div class="req-field">
                        <label>Lý do gia hạn</label>
                        <textarea name="reason" maxlength="500" placeholder="VD: Cần ở thêm vì công việc kéo dài..."></textarea>
                    </div>

                    <div class="req-modal-footer">
                        <button type="button" class="br-btn br-btn-cancel" onclick="closeReqModal('extModal')">Huỷ</button>
                        <button type="submit" class="br-btn br-btn-submit">
                            <i class="fa-solid fa-paper-plane"></i> Gửi yêu cầu
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%-- Footer --%>
    <footer class="footer-white" id="lien-he">
        <div class="footer-white-grid">
            <div class="footer-white-about">
                <h3>HotelOps Pro</h3>
                <p>Hệ thống quản lý và nghỉ dưỡng đẳng cấp quốc tế, đem lại trải nghiệm sang trọng vượt thời gian.</p>
            </div>
            
            <div class="footer-white-links">
                <h4>Liên kết nhanh</h4>
                <ul>
                    <li><a href="#">Trang chủ</a></li>
                    <li><a href="#">Phòng & Giá</a></li>
                    <li><a href="#">Dịch vụ</a></li>
                </ul>
            </div>

            <div class="footer-white-links">
                <h4>Chính sách</h4>
                <ul>
                    <li><a href="#">Chính sách bảo mật</a></li>
                    <li><a href="#">Điều khoản sử dụng</a></li>
                    <li><a href="#">Chính sách hoàn tiền</a></li>
                </ul>
            </div>

            <div class="footer-white-contact">
                <h4>Thông tin liên hệ</h4>
                <p><i class="fa-solid fa-location-dot"></i> 123 Đường Lê Lợi, Quận 1, TP. Hồ Chí Minh</p>
                <p><i class="fa-solid fa-envelope"></i> contact@hotelopspro.com</p>
                <span class="phone-number-white"><i class="fa-solid fa-phone"></i> 1900 6789</span>
            </div>
        </div>
        <div class="footer-white-bottom text-center">
            <p>&copy; 2026 HotelOps Pro. All rights reserved.</p>
        </div>
    </footer>

    <script>
        window.addEventListener('DOMContentLoaded', () => {
            const serverError = document.getElementById('serverValidationError');
            if (serverError) {
                setTimeout(() => {
                    serverError.style.display = 'none';
                }, 5000);
            }
            const serverSuccess = document.getElementById('serverSuccessMessage');
            if (serverSuccess) {
                setTimeout(() => {
                    serverSuccess.style.display = 'none';
                }, 5000);
            }
        });

        function confirmCancelBooking(bookingId) {
            if (confirm("Bạn có chắc chắn muốn hủy đơn đặt phòng #" + bookingId + " không? Trạng thái phòng sẽ được hoàn lại và bạn có thể phải trả phí nếu chính sách yêu cầu.")) {
                document.getElementById('cancelBookingId').value = bookingId;
                document.getElementById('cancelForm').submit();
            }
        }

        // ===== Booking Change & Stay Extension request modals =====
        const roomTypePrices = {
            <c:forEach var="rt" items="${roomTypes}">'${rt.typeId}': ${rt.basePrice},</c:forEach>
        };

        function todayISO() {
            const d = new Date();
            const m = String(d.getMonth() + 1).padStart(2, '0');
            const day = String(d.getDate()).padStart(2, '0');
            return d.getFullYear() + '-' + m + '-' + day;
        }
        function nightsBetween(a, b) {
            const d1 = new Date(a), d2 = new Date(b);
            return Math.round((d2 - d1) / (1000 * 60 * 60 * 24));
        }
        function fmtVND(n) {
            return new Intl.NumberFormat('vi-VN').format(Math.round(n)) + ' VND';
        }

        function openReqModal(id) { document.getElementById(id).classList.add('open'); }
        function closeReqModal(id) { document.getElementById(id).classList.remove('open'); }

        function openChangeModal() {
            const sel = document.getElementById('changeBookingSelect');
            if (sel.options.length <= 1) {
                alert('Bạn không có đơn đặt phòng nào đủ điều kiện để yêu cầu thay đổi (cần ở trạng thái Chờ duyệt hoặc Đã xác nhận).');
                return;
            }
            const minIn = todayISO();
            document.getElementById('changeNewIn').min = minIn;
            document.getElementById('changeNewOut').min = minIn;
            openReqModal('changeModal');
        }

        function onChangeBookingSelect() {
            const opt = document.getElementById('changeBookingSelect').selectedOptions[0];
            const panel = document.getElementById('changeCurrent');
            if (!opt || !opt.value) { panel.classList.remove('show'); return; }
            document.getElementById('curChangeType').textContent = opt.dataset.roomtype || '—';
            document.getElementById('curChangeQty').textContent = opt.dataset.qty || '—';
            document.getElementById('curChangeIn').textContent = opt.dataset.checkin || '—';
            document.getElementById('curChangeOut').textContent = opt.dataset.checkout || '—';
            panel.classList.add('show');
            // Pre-fill the editable fields with the current values
            document.getElementById('changeNewIn').value = opt.dataset.checkin || '';
            document.getElementById('changeNewOut').value = opt.dataset.checkout || '';
            if (opt.dataset.roomtypeid) document.getElementById('changeRoomType').value = opt.dataset.roomtypeid;
            document.getElementById('changeQty').value = opt.dataset.qty || '1';
        }

        function validateChange() {
            const bid = document.getElementById('changeBookingSelect').value;
            const ci = document.getElementById('changeNewIn').value;
            const co = document.getElementById('changeNewOut').value;
            const rt = document.getElementById('changeRoomType').value;
            const qty = document.getElementById('changeQty').value;
            if (!bid || !ci || !co || !rt || !qty) {
                alert('Vui lòng điền đầy đủ các trường bắt buộc.');
                return false;
            }
            if (nightsBetween(ci, co) < 1) {
                alert('Ngày trả phòng phải sau ngày nhận phòng.');
                return false;
            }
            if (ci < todayISO()) {
                alert('Ngày nhận phòng mới không được ở trong quá khứ.');
                return false;
            }
            return true;
        }

        function openExtensionModal() {
            const sel = document.getElementById('extBookingSelect');
            if (sel.options.length <= 1) {
                alert('Bạn không có phòng nào đang lưu trú (Đã nhận phòng) để gia hạn.');
                return;
            }
            openReqModal('extModal');
        }

        function onExtBookingSelect() {
            const opt = document.getElementById('extBookingSelect').selectedOptions[0];
            const panel = document.getElementById('extCurrent');
            if (!opt || !opt.value) { panel.classList.remove('show'); return; }
            document.getElementById('curExtType').textContent = opt.dataset.roomtype || '—';
            document.getElementById('curExtQty').textContent = opt.dataset.qty || '—';
            document.getElementById('curExtOut').textContent = opt.dataset.checkout || '—';
            panel.classList.add('show');
            // New check-out must be after the current one
            const out = document.getElementById('extNewOut');
            out.min = opt.dataset.checkout || todayISO();
            out.value = '';
            updateExtEstimate();
        }

        function updateExtEstimate() {
            const opt = document.getElementById('extBookingSelect').selectedOptions[0];
            const box = document.getElementById('extEstimate');
            const newOut = document.getElementById('extNewOut').value;
            if (!opt || !opt.value || !newOut) { box.classList.remove('show'); return; }
            const nights = nightsBetween(opt.dataset.checkout, newOut);
            if (nights < 1) { box.classList.remove('show'); return; }
            const price = roomTypePrices[opt.dataset.roomtypeid] || 0;
            const qty = parseInt(opt.dataset.qty || '1', 10);
            document.getElementById('extNights').textContent = nights;
            document.getElementById('extCharge').textContent = fmtVND(price * qty * nights);
            box.classList.add('show');
        }

        function validateExtension() {
            const opt = document.getElementById('extBookingSelect').selectedOptions[0];
            const newOut = document.getElementById('extNewOut').value;
            if (!opt || !opt.value || !newOut) {
                alert('Vui lòng chọn phòng và ngày trả phòng mới.');
                return false;
            }
            if (nightsBetween(opt.dataset.checkout, newOut) < 1) {
                alert('Ngày trả phòng mới phải muộn hơn ngày trả phòng hiện tại.');
                return false;
            }
            return true;
        }

        // Close a modal when clicking on the dimmed backdrop
        document.querySelectorAll('.req-modal-overlay').forEach(function (ov) {
            ov.addEventListener('click', function (e) {
                if (e.target === ov) ov.classList.remove('open');
            });
        });
    </script>
</body>
</html>
