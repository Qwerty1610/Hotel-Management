<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ include file="../../includes/taglibs.jsp" %>
        <%@ include file="../../includes/header.jsp" %>

            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer_booking.css?v=21" />
            <fmt:setLocale value="vi_VN" />

            <body>

                <%-- Header Navigation --%>
                    <nav class="navbar-rooms">
                        <div class="logo">HotelOps</div>
                        <ul class="nav-links">
                            <li><a href="${pageContext.request.contextPath}/">Trang chủ</a></li>
                            <li><a href="${pageContext.request.contextPath}/rooms">Phòng</a></li>
                            <li><a href="${pageContext.request.contextPath}/customer/bookings" class="active">Đặt phòng
                                    của tôi</a></li>
                        </ul>

                        <div class="nav-actions">
                            <c:choose>
                                <c:when test="${not empty sessionScope.user}">
                                    <div class="user-dropdown">
                                        <button class="dropdown-trigger" type="button">
                                            <i class="fa-solid fa-user-circle"></i>
                                            <span>${sessionScope.user}</span>
                                            <i class="fa-solid fa-chevron-down"
                                                style="font-size: 10px; margin-left: 2px;"></i>
                                        </button>
                                        <div class="dropdown-menu">
                                            <c:choose>
                                                <c:when test="${sessionScope.role eq 'CUSTOMER'}">
                                                    <a href="${pageContext.request.contextPath}/customer/profile"
                                                        class="dropdown-item">
                                                        <i class="fa-solid fa-id-card"></i> Hồ sơ
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/bookings"
                                                        class="dropdown-item">
                                                        <i class="fa-solid fa-calendar-check"></i> Đặt phòng của tôi
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/booking/change" class="dropdown-item">
                                                        <i class="fa-solid fa-pen-to-square"></i> Thay đổi đặt phòng
                                                    <a href="${pageContext.request.contextPath}/customer/feedbacks"
                                                        class="dropdown-item">
                                                        <i class="fa-solid fa-star"></i> Đánh giá lưu trú
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/services"
                                                        class="dropdown-item">
                                                        <i class="fa-solid fa-bell-concierge"></i> Yêu cầu dịch vụ
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/maintenance"
                                                        class="dropdown-item">
                                                        <i class="fa-solid fa-screwdriver-wrench"></i> Yêu cầu sửa chữa
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/payments" class="dropdown-item">
                                                        <i class="fa-solid fa-credit-card"></i> Thanh toán & Lịch sử
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/payments" class="dropdown-item">
                                                        <i class="fa-solid fa-credit-card"></i> Thanh toán & Lịch sử
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:choose>
                                                        <c:when test="${sessionScope.role eq 'ADMIN'}">
                                                            <a href="${pageContext.request.contextPath}/admin/dashboard"
                                                                class="dropdown-item">
                                                                <i class="fa-solid fa-chart-line"></i> Dashboard Admin
                                                            </a>
                                                        </c:when>
                                                        <c:when test="${sessionScope.role eq 'MANAGER'}">
                                                            <a href="${pageContext.request.contextPath}/manager/dashboard"
                                                                class="dropdown-item">
                                                                <i class="fa-solid fa-chart-line"></i> Dashboard Manager
                                                            </a>
                                                        </c:when>
                                                        <c:when test="${sessionScope.role eq 'RECEPTIONIST'}">
                                                            <a href="${pageContext.request.contextPath}/receptionist/dashboard"
                                                                class="dropdown-item">
                                                                <i class="fa-solid fa-chart-line"></i> Dashboard
                                                                Receptionist
                                                            </a>
                                                        </c:when>
                                                        <c:when test="${sessionScope.role eq 'HOUSEKEEPING'}">
                                                            <a href="${pageContext.request.contextPath}/housekeeping/dashboard"
                                                                class="dropdown-item">
                                                                <i class="fa-solid fa-chart-line"></i> Dashboard
                                                                Housekeeping
                                                            </a>
                                                        </c:when>
                                                    </c:choose>
                                                </c:otherwise>
                                            </c:choose>
                                            <div class="dropdown-divider"></div>
                                            <a href="${pageContext.request.contextPath}/logout"
                                                class="dropdown-item logout-item">
                                                <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                                            </a>
                                        </div>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/home/login" class="btn-login">Đăng
                                        nhập</a>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </nav>

                    <div class="booking-container">
                        <div class="receipt-layout">

                            <%-- Receipt card --%>
                                <div class="booking-card" style="padding: 40px; position: relative;">

                                    <div class="receipt-header">
                                        <div class="logo">HotelOps</div>
                                        <h2>ĐƠN ĐẶT PHÒNG KHÁCH SẠN</h2>
                                        <p style="color: var(--text-muted); font-size: 14px; margin-top: 5px;">Mã đặt
                                            phòng: #${booking.bookingId}</p>

                                        <div style="margin-top: 15px;">
                                            <c:choose>
                                                <c:when test="${booking.status eq 'Pending'}">
                                                    <span class="badge badge-pending"
                                                        style="font-size: 14px; padding: 6px 14px;">Chờ duyệt</span>
                                                </c:when>
                                                <c:when test="${booking.status eq 'Confirmed'}">
                                                    <span class="badge badge-confirmed"
                                                        style="font-size: 14px; padding: 6px 14px;">Đã xác nhận</span>
                                                </c:when>
                                                <c:when test="${booking.status eq 'CheckedIn'}">
                                                    <span class="badge badge-checkedin"
                                                        style="font-size: 14px; padding: 6px 14px;">Đã nhận phòng</span>
                                                </c:when>
                                                <c:when test="${booking.status eq 'CheckedOut'}">
                                                    <span class="badge badge-checkedout"
                                                        style="font-size: 14px; padding: 6px 14px;">Đã trả phòng</span>
                                                </c:when>
                                                <c:when test="${booking.status eq 'Cancelled'}">
                                                    <span class="badge badge-cancelled"
                                                        style="font-size: 14px; padding: 6px 14px;">Đã hủy</span>
                                                </c:when>
                                                <c:when test="${booking.status eq 'Rejected'}">
                                                    <span class="badge badge-rejected"
                                                        style="font-size: 14px; padding: 6px 14px;">Từ chối</span>
                                                </c:when>
                                            </c:choose>
                                        </div>
                                    </div>

                                    <div class="receipt-grid-2">
                                        <div class="receipt-info-section">
                                            <h3>Thông tin khách hàng</h3>
                                            <div class="receipt-info-row">
                                                <span>Người đặt:</span>
                                                <span>${booking.customerName}</span>
                                            </div>
                                            <div class="receipt-info-row">
                                                <span>Email:</span>
                                                <span>${booking.email != null && not empty booking.email ? booking.email
                                                    : sessionScope.email}</span>
                                            </div>
                                            <div class="receipt-info-row">
                                                <span>Số điện thoại:</span>
                                                <span>${booking.phone != null && not empty booking.phone ? booking.phone
                                                    : 'Chưa cung cấp'}</span>
                                            </div>
                                            <div class="receipt-info-row">
                                                <span>Ngày lập đơn:</span>
                                                <span>
                                                    <fmt:formatDate value="${booking.createdAt}" pattern="dd/MM/yyyy" />
                                                </span>
                                            </div>
                                        </div>

                                        <div class="receipt-info-section">
                                            <h3>Thời gian lưu trú</h3>
                                            <div class="receipt-info-row">
                                                <span>Ngày nhận phòng:</span>
                                                <span>
                                                    <fmt:formatDate value="${booking.checkInDate}"
                                                        pattern="dd/MM/yyyy" />
                                                </span>
                                            </div>
                                            <div class="receipt-info-row">
                                                <span>Ngày trả phòng:</span>
                                                <span>
                                                    <fmt:formatDate value="${booking.checkOutDate}"
                                                        pattern="dd/MM/yyyy" />
                                                </span>
                                            </div>
                                            <div class="receipt-info-row">
                                                <span>Số đêm nghỉ:</span>
                                                <span
                                                    style="font-weight: 700; color: var(--primary-indigo);">${booking.nights}
                                                    đêm</span>
                                            </div>
                                            <div class="receipt-info-row">
                                                <span>Số loại phòng:</span>
                                                <span
                                                    style="font-weight: 700; color: var(--primary-indigo);">${booking.totalRoomTypes}
                                                    loại</span>
                                            </div>
                                            <div class="receipt-info-row">
                                                <span>Tổng số phòng:</span>
                                                <span
                                                    style="font-weight: 700; color: var(--primary-indigo);">${booking.totalRoomQuantity}
                                                    phòng</span>
                                            </div>
                                        </div>
                                    </div>

                                    <h3
                                        style="font-size: 16px; color: var(--primary-indigo); margin: 30px 0 15px 0; border-bottom: 1px solid var(--border-color); padding-bottom: 5px;">
                                        Chi tiết các phòng đã chọn đặt
                                    </h3>

                                    <table class="table-receipt">
                                        <thead>
                                            <tr>
                                                <th style="width: 50px;">STT</th>
                                                <th>Loại phòng</th>
                                                <th style="text-align: center;">Số lượng</th>
                                                <th style="text-align: right;">Đơn giá / đêm</th>
                                                <th>Họ tên khách nghỉ</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${not empty rooms}">
                                                    <c:forEach var="r" items="${rooms}" varStatus="status">
                                                        <tr>
                                                            <td>${status.index + 1}</td>
                                                            <td style="font-weight: 600;">${r.roomTypeName}</td>
                                                            <td
                                                                style="text-align: center; font-weight: 600; color: var(--primary-indigo);">
                                                                ${r.quantity}</td>
                                                            <td style="text-align: right;">
                                                                <fmt:formatNumber value="${r.price}" type="currency"
                                                                    currencySymbol="" /> VND
                                                            </td>
                                                            <td style="font-style: italic;">
                                                                <c:out
                                                                    value="${not empty r.guestName ? r.guestName : 'N/A'}" />
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:when>
                                                <c:otherwise>
                                                    <tr>
                                                        <td>1</td>
                                                        <td style="font-weight: 600;">${booking.roomTypeName}</td>
                                                        <td
                                                            style="text-align: center; font-weight: 600; color: var(--primary-indigo);">
                                                            ${booking.roomQuantity}</td>
                                                        <td style="text-align: right;">
                                                            <fmt:formatNumber
                                                                value="${booking.totalAmount / booking.roomQuantity / booking.nights}"
                                                                type="currency" currencySymbol="" /> VND
                                                        </td>
                                                        <td style="font-style: italic;">${booking.customerName} (Theo
                                                            đơn đặt)</td>
                                                    </tr>
                                                </c:otherwise>
                                            </c:choose>
                                        </tbody>
                                    </table>

                                    <c:if test="${not empty booking.note}">
                                        <div
                                            style="background-color: #fffbeb; border: 1px solid #fef3c7; border-radius: 8px; padding: 15px; margin-bottom: 30px;">
                                            <h4 style="margin: 0 0 5px 0; font-size: 14px; color: #b45309;"><i
                                                    class="fa-solid fa-comment-dots"></i> Ghi chú / Yêu cầu đặc biệt:
                                            </h4>
                                            <p style="margin: 0; font-size: 13.5px; color: #78350f; line-height: 1.5;">
                                                ${booking.note}</p>
                                        </div>
                                    </c:if>

                                    <%-- Pricing breakdown --%>
                                        <div
                                            style="border-top: 2px dashed var(--border-color); padding-top: 20px; width: 300px; margin-left: auto;">
                                            <div class="receipt-info-row" style="margin-bottom: 12px;">
                                                <span>Tổng tiền phòng:</span>
                                                <span style="font-weight: 600; font-size: 15px;">
                                                    <fmt:formatNumber value="${booking.totalAmount}" type="currency"
                                                        currencySymbol="" /> VND
                                                </span>
                                            </div>
                                            <div class="receipt-info-row"
                                                style="margin-bottom: 12px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
                                                <span>Tiền đặt cọc (30%):</span>
                                                <span
                                                    style="font-weight: 600; color: var(--accent-gold); font-size: 15px;">
                                                    <fmt:formatNumber value="${booking.totalAmount * 0.3}"
                                                        type="currency" currencySymbol="" /> VND
                                                </span>
                                            </div>
                                            <div class="receipt-info-row"
                                                style="font-size: 18px; font-weight: 700; color: var(--primary-dark);">
                                                <span>TỔNG TIỀN:</span>
                                                <span>
                                                    <fmt:formatNumber value="${booking.totalAmount}" type="currency"
                                                        currencySymbol="" /> VND
                                                </span>
                                            </div>
                                        </div>

                                        <%-- Controls --%>
                                            <div
                                                style="display: flex; justify-content: space-between; align-items: center; margin-top: 40px; border-top: 1px solid var(--border-color); padding-top: 20px;">
                                                <a href="${pageContext.request.contextPath}/customer/bookings"
                                                    class="btn-secondary"
                                                    style="text-decoration: none; padding: 10px 20px;">
                                                    <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
                                                </a>

                                                <c:if
                                                    test="${booking.status eq 'Pending' || booking.status eq 'Confirmed'}">
                                                    <button type="button" class="btn-danger"
                                                        style="padding: 10px 20px; width: auto; max-width: none; height: auto;"
                                                        onclick="confirmCancel(${booking.bookingId})">
                                                        <i class="fa-solid fa-calendar-xmark"></i> Hủy đặt phòng này
                                                    </button>
                                                </c:if>
                                            </div>

                                </div>

                        </div>
                    </div>

                    <%-- Form Cancel for Post --%>
                        <form action="${pageContext.request.contextPath}/customer/booking/cancel" method="POST"
                            id="cancelForm" style="display: none;">
                            <input type="hidden" name="id" value="${booking.bookingId}" />
                        </form>

                        <%-- Footer --%>
                            <footer class="footer-white" id="lien-he">
                                <div class="footer-white-grid">
                                    <div class="footer-white-about">
                                        <h3>HotelOps Pro</h3>
                                        <p>Hệ thống quản lý và nghỉ dưỡng đẳng cấp quốc tế, đem lại trải nghiệm sang
                                            trọng vượt thời gian.</p>
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
                                        <p><i class="fa-solid fa-location-dot"></i> 123 Đường Lê Lợi, Quận 1, TP. Hồ Chí
                                            Minh</p>
                                        <p><i class="fa-solid fa-envelope"></i> contact@hotelopspro.com</p>
                                        <span class="phone-number-white"><i class="fa-solid fa-phone"></i> 1900
                                            6789</span>
                                    </div>
                                </div>
                                <div class="footer-white-bottom text-center">
                                    <p>&copy; 2026 HotelOps Pro. All rights reserved.</p>
                                </div>
                            </footer>

                            <script>
                                function confirmCancel(bookingId) {
                                    if (confirm("Bạn có chắc chắn muốn hủy đơn đặt phòng #" + bookingId + " này? Trạng thái sẽ cập nhật thành Đã hủy và phòng nghỉ sẽ được giải phóng.")) {
                                        document.getElementById('cancelForm').submit();
                                    }
                                }
                            </script>
            </body>

            </html>