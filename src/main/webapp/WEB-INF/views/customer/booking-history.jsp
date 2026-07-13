<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer_booking.css?v=21" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/booking-requests.css?v=3" />
<fmt:setLocale value="vi_VN" />

<body>

    <%-- Header Navigation --%>
    <nav class="navbar-rooms">
        <div class="logo">HotelOps</div>
        <ul class="nav-links">
            <li><a href="${pageContext.request.contextPath}/">Trang chủ</a></li>
            <li><a href="${pageContext.request.contextPath}/rooms">Phòng</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/bookings" class="active">Đặt phòng của tôi</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/payments">Thanh toán</a></li>
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
                                    <a href="${pageContext.request.contextPath}/customer/booking/change" class="dropdown-item">
                                        <i class="fa-solid fa-pen-to-square"></i> Thay đổi đặt phòng
                                    <a href="${pageContext.request.contextPath}/customer/feedbacks" class="dropdown-item">
                                        <i class="fa-solid fa-star"></i> Đánh giá lưu trú
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/services" class="dropdown-item">
                                        <i class="fa-solid fa-bell-concierge"></i> Yêu cầu dịch vụ
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/maintenance" class="dropdown-item">
                                        <i class="fa-solid fa-screwdriver-wrench"></i> Yêu cầu sửa chữa
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/payments" class="dropdown-item">
                                        <i class="fa-solid fa-credit-card"></i> Thanh toán & Lịch sử
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

    </script>
</body>
</html>
