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
            <li><a href="${pageContext.request.contextPath}/customer/bookings">Đặt phòng của tôi</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/payments" class="active">Thanh toán</a></li>
        </ul>
        <div class="nav-actions">
            <div class="user-dropdown">
                <button class="dropdown-trigger" type="button">
                    <i class="fa-solid fa-user-circle"></i>
                    <span>${sessionScope.user}</span>
                    <i class="fa-solid fa-chevron-down" style="font-size: 10px; margin-left: 2px;"></i>
                </button>
                <div class="dropdown-menu">
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
                    <a href="${pageContext.request.contextPath}/customer/services/history" class="dropdown-item">
                        <i class="fa-solid fa-clock-rotate-left"></i> Lịch sử yêu cầu
                    <a href="${pageContext.request.contextPath}/customer/maintenance" class="dropdown-item">
                        <i class="fa-solid fa-screwdriver-wrench"></i> Yêu cầu sửa chữa
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/payments" class="dropdown-item">
                        <i class="fa-solid fa-credit-card"></i> Thanh toán & Lịch sử
                    </a>
                    <div class="dropdown-divider"></div>
                    <a href="${pageContext.request.contextPath}/logout" class="dropdown-item logout-item">
                        <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                    </a>
                </div>
            </div>
        </div>
    </nav>

    <div class="booking-container">
        <div class="booking-header">
            <h1>Thanh Toán &amp; Lịch Sử Giao Dịch</h1>
            <p>Thanh toán hóa đơn online qua chuyển khoản ngân hàng (SePay) và xem lại các giao dịch đã thực hiện</p>
        </div>

        <%-- Alerts --%>
        <c:if test="${not empty successMessage}">
            <div class="success-banner">
                <i class="fa-solid fa-circle-check" style="font-size: 20px;"></i>
                <div><strong>Thành công:</strong> ${successMessage}</div>
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="error-banner">
                <i class="fa-solid fa-circle-exclamation" style="font-size: 20px;"></i>
                <div><strong>Không thể thanh toán:</strong> ${errorMessage}</div>
            </div>
        </c:if>

        <%-- ============ Đặt phòng chờ thanh toán cọc ============ --%>
        <h2 style="margin: 25px 0 12px; font-size: 20px;">
            <i class="fa-solid fa-hand-holding-dollar"></i> Đặt phòng chờ thanh toán cọc
        </h2>
        <div class="booking-card" style="padding: 0; overflow-x: auto; margin-bottom: 10px;">
            <table class="booking-list-table">
                <thead>
                    <tr>
                        <th>Mã đặt phòng</th>
                        <th>Loại phòng</th>
                        <th>Thời gian nghỉ</th>
                        <th>Tổng tiền phòng</th>
                        <th>Tiền cọc (30%)</th>
                        <th>Đã chuyển</th>
                        <th>Trạng thái</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="item" items="${depositItems}">
                        <tr>
                            <td><b>#${item.booking.bookingId}</b></td>
                            <td>${item.booking.groupRoomTypeNames}</td>
                            <td>
                                <fmt:formatDate value="${item.booking.checkInDate}" pattern="dd/MM/yyyy" />
                                &rarr;
                                <fmt:formatDate value="${item.booking.checkOutDate}" pattern="dd/MM/yyyy" />
                            </td>
                            <td><fmt:formatNumber value="${item.booking.overallTotalAmount}" maxFractionDigits="0" /> đ</td>
                            <td style="font-weight: 700; color: #b91c1c;">
                                <fmt:formatNumber value="${item.depositAmount}" maxFractionDigits="0" /> đ
                            </td>
                            <td><fmt:formatNumber value="${item.paidAmount}" maxFractionDigits="0" /> đ</td>
                            <td>
                                <c:choose>
                                    <c:when test="${item.fullyPaid}">
                                        <span class="badge badge-confirmed">Đã cọc — chờ xác nhận</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-pending">Chờ thanh toán cọc</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:if test="${not item.fullyPaid}">
                                    <a href="${pageContext.request.contextPath}/customer/payments/pay?bookingId=${item.booking.bookingId}"
                                       class="btn-primary" style="width: auto; padding: 8px 16px; margin-top: 0; text-decoration: none; display: inline-block;">
                                        <i class="fa-solid fa-qrcode"></i> Thanh toán cọc
                                    </a>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty depositItems}">
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 30px; color: #64748b;">
                                <i class="fa-solid fa-circle-check" style="font-size: 24px; color: #22c55e;"></i><br/>
                                Bạn không có đặt phòng nào đang chờ thanh toán cọc.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <%-- ============ Hóa đơn chờ thanh toán (Make Online Payment) ============ --%>
        <h2 style="margin: 25px 0 12px; font-size: 20px;">
            <i class="fa-solid fa-file-invoice-dollar"></i> Hóa đơn chờ thanh toán
        </h2>
        <div class="booking-card" style="padding: 0; overflow-x: auto;">
            <table class="booking-list-table">
                <thead>
                    <tr>
                        <th>Mã hóa đơn</th>
                        <th>Phòng</th>
                        <th>Ngày tạo</th>
                        <th>Tổng tiền</th>
                        <th>Cọc đã trả</th>
                        <th>Cần thanh toán</th>
                        <th>Trạng thái</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="inv" items="${unpaidInvoices}">
                        <tr>
                            <td><b>#${inv.invoiceId}</b></td>
                            <td>${empty inv.roomNumber ? '—' : inv.roomNumber}</td>
                            <td><fmt:formatDate value="${inv.createdAt}" pattern="dd/MM/yyyy HH:mm" /></td>
                            <td><fmt:formatNumber value="${inv.totalAmount}" maxFractionDigits="0" /> đ</td>
                            <td><fmt:formatNumber value="${inv.depositAmount}" maxFractionDigits="0" /> đ</td>
                            <td style="font-weight: 700; color: #b91c1c;">
                                <fmt:formatNumber value="${inv.netAmount}" maxFractionDigits="0" /> đ
                            </td>
                            <td><span class="badge badge-pending">Chờ thanh toán</span></td>
                            <td>
                                <c:if test="${inv.netAmount > 0}">
                                    <a href="${pageContext.request.contextPath}/customer/payments/pay?invoiceId=${inv.invoiceId}"
                                       class="btn-primary" style="width: auto; padding: 8px 16px; margin-top: 0; text-decoration: none; display: inline-block;">
                                        <i class="fa-solid fa-qrcode"></i> Thanh toán
                                    </a>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty unpaidInvoices}">
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 30px; color: #64748b;">
                                <i class="fa-solid fa-circle-check" style="font-size: 24px; color: #22c55e;"></i><br/>
                                Bạn không có hóa đơn nào đang chờ thanh toán.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <%-- ============ Lịch sử thanh toán (View Payment History) ============ --%>
        <h2 style="margin: 35px 0 12px; font-size: 20px;">
            <i class="fa-solid fa-clock-rotate-left"></i> Lịch sử thanh toán
        </h2>
        <div class="booking-card" style="padding: 0; overflow-x: auto;">
            <table class="booking-list-table">
                <thead>
                    <tr>
                        <th>Mã GD</th>
                        <th>Loại</th>
                        <th>Phòng</th>
                        <th>Số tiền</th>
                        <th>Ngân hàng</th>
                        <th>Mã tham chiếu</th>
                        <th>Thời gian</th>
                        <th>Trạng thái</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="p" items="${payments}">
                        <tr>
                            <td><b>#${p.paymentId}</b></td>
                            <td>
                                <c:choose>
                                    <c:when test="${p.deposit}">
                                        <i class="fa-solid fa-hand-holding-dollar" style="color: #b45309;"></i>
                                        Cọc đặt phòng #${p.bookingId}
                                    </c:when>
                                    <c:otherwise>
                                        <i class="fa-solid fa-file-invoice-dollar" style="color: #1d4ed8;"></i>
                                        Hóa đơn #${p.invoiceId}
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${empty p.roomNumber ? '—' : p.roomNumber}</td>
                            <td style="font-weight: 600; color: #15803d;">
                                + <fmt:formatNumber value="${p.amount}" maxFractionDigits="0" /> đ
                            </td>
                            <td>${empty p.gateway ? '—' : p.gateway}</td>
                            <td style="font-size: 13px; color: #64748b;">${empty p.referenceCode ? '—' : p.referenceCode}</td>
                            <td>
                                <fmt:formatDate value="${empty p.transactionDate ? p.createdAt : p.transactionDate}"
                                                pattern="dd/MM/yyyy HH:mm" />
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${p.deposit}">
                                        <span class="badge badge-confirmed">Đã nhận cọc</span>
                                    </c:when>
                                    <c:when test="${p.invoiceStatus eq 'Paid'}">
                                        <span class="badge badge-confirmed">Đã thanh toán</span>
                                    </c:when>
                                    <c:when test="${p.invoiceStatus eq 'Refunding'}">
                                        <span class="badge badge-pending">Đang hoàn tiền</span>
                                    </c:when>
                                    <c:when test="${p.invoiceStatus eq 'Refunded'}">
                                        <span class="badge badge-checkedout">Đã hoàn tiền</span>
                                    </c:when>
                                    <c:when test="${p.invoiceStatus eq 'Cancelled'}">
                                        <span class="badge badge-cancelled">Đã hủy</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-pending">Chưa đủ tiền</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty payments}">
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 30px; color: #64748b;">
                                <i class="fa-solid fa-receipt" style="font-size: 24px;"></i><br/>
                                Bạn chưa có giao dịch thanh toán nào.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
