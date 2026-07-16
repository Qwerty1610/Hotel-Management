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
                    <a href="${pageContext.request.contextPath}/customer/services" class="dropdown-item">
                        <i class="fa-solid fa-bell-concierge"></i> Yêu cầu dịch vụ
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/services/history" class="dropdown-item">
                        <i class="fa-solid fa-clock-rotate-left"></i> Lịch sử yêu cầu
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
            <c:choose>
                <c:when test="${mode eq 'deposit'}">
                    <h1>Thanh Toán Tiền Cọc — Đặt Phòng #${booking.bookingId}</h1>
                    <p>Chuyển tiền cọc để giữ phòng. Sau khi nhận đủ cọc, lễ tân sẽ xác nhận đặt phòng của bạn.</p>
                </c:when>
                <c:otherwise>
                    <h1>Thanh Toán Hóa Đơn #${invoice.invoiceId}</h1>
                    <p>Quét mã QR bằng ứng dụng ngân hàng để thanh toán. Hệ thống tự động xác nhận sau vài giây.</p>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="booking-card" style="padding: 30px;">
            <div style="display: flex; gap: 40px; flex-wrap: wrap; justify-content: center; align-items: flex-start;">

                <%-- Cột trái: mã QR --%>
                <div style="text-align: center;">
                    <img src="${qrUrl}" alt="Mã QR thanh toán SePay"
                         style="width: 280px; height: 280px; border: 1px solid #e2e8f0; border-radius: 12px; padding: 10px; background: #fff;" />
                    <div id="waitingBox" style="margin-top: 15px; color: #b45309; font-weight: 600;">
                        <i class="fa-solid fa-spinner fa-spin"></i>
                        Đang chờ thanh toán...
                    </div>
                    <div id="paidBox" style="margin-top: 15px; color: #15803d; font-weight: 700; display: none;">
                        <i class="fa-solid fa-circle-check"></i>
                        Đã nhận thanh toán! Đang chuyển trang...
                    </div>
                </div>

                <%-- Cột phải: thông tin chuyển khoản --%>
                <div style="min-width: 300px; flex: 1; max-width: 480px;">
                    <h3 style="margin-bottom: 15px;">Thông tin chuyển khoản</h3>
                    <table style="width: 100%; border-collapse: collapse; font-size: 15px;">
                        <tr style="border-bottom: 1px solid #f1f5f9;">
                            <td style="padding: 10px 0; color: #64748b;">Ngân hàng</td>
                            <td style="padding: 10px 0; text-align: right; font-weight: 600;">${bankCode}</td>
                        </tr>
                        <tr style="border-bottom: 1px solid #f1f5f9;">
                            <td style="padding: 10px 0; color: #64748b;">Số tài khoản</td>
                            <td style="padding: 10px 0; text-align: right; font-weight: 600;">${bankAccount}</td>
                        </tr>
                        <c:if test="${not empty accountHolder}">
                            <tr style="border-bottom: 1px solid #f1f5f9;">
                                <td style="padding: 10px 0; color: #64748b;">Chủ tài khoản</td>
                                <td style="padding: 10px 0; text-align: right; font-weight: 600;">${accountHolder}</td>
                            </tr>
                        </c:if>

                        <c:choose>
                            <c:when test="${mode eq 'deposit'}">
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 10px 0; color: #64748b;">Loại phòng</td>
                                    <td style="padding: 10px 0; text-align: right;">${booking.groupRoomTypeNames}</td>
                                </tr>
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 10px 0; color: #64748b;">Thời gian nghỉ</td>
                                    <td style="padding: 10px 0; text-align: right;">
                                        <fmt:formatDate value="${booking.checkInDate}" pattern="dd/MM/yyyy" />
                                        &rarr;
                                        <fmt:formatDate value="${booking.checkOutDate}" pattern="dd/MM/yyyy" />
                                    </td>
                                </tr>
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 10px 0; color: #64748b;">Tổng tiền phòng</td>
                                    <td style="padding: 10px 0; text-align: right;">
                                        <fmt:formatNumber value="${booking.overallTotalAmount}" maxFractionDigits="0" /> đ
                                    </td>
                                </tr>
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 10px 0; color: #64748b;">Tiền cọc giữ phòng (30%)</td>
                                    <td style="padding: 10px 0; text-align: right;">
                                        <fmt:formatNumber value="${depositAmount}" maxFractionDigits="0" /> đ
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 10px 0; color: #64748b;">Tổng hóa đơn</td>
                                    <td style="padding: 10px 0; text-align: right;">
                                        <fmt:formatNumber value="${invoice.totalAmount}" maxFractionDigits="0" /> đ
                                    </td>
                                </tr>
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 10px 0; color: #64748b;">Tiền cọc đã trả (30% tiền phòng)</td>
                                    <td style="padding: 10px 0; text-align: right;">
                                        &minus; <fmt:formatNumber value="${invoice.depositAmount}" maxFractionDigits="0" /> đ
                                    </td>
                                </tr>
                                <c:if test="${invoice.refundedAmount > 0}">
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="padding: 10px 0; color: #64748b;">Đã hoàn</td>
                                        <td style="padding: 10px 0; text-align: right;">
                                            &minus; <fmt:formatNumber value="${invoice.refundedAmount}" maxFractionDigits="0" /> đ
                                        </td>
                                    </tr>
                                </c:if>
                            </c:otherwise>
                        </c:choose>

                        <tr style="border-bottom: 1px solid #f1f5f9;">
                            <td style="padding: 10px 0; color: #64748b;">Số tiền cần thanh toán</td>
                            <td style="padding: 10px 0; text-align: right; font-weight: 700; color: #b91c1c; font-size: 18px;">
                                <fmt:formatNumber value="${remainingAmount}" maxFractionDigits="0" /> đ
                            </td>
                        </tr>
                        <tr>
                            <td style="padding: 10px 0; color: #64748b;">Nội dung chuyển khoản</td>
                            <td style="padding: 10px 0; text-align: right; font-weight: 700; color: #1d4ed8;">${transferContent}</td>
                        </tr>
                    </table>

                    <div style="margin-top: 15px; padding: 12px 15px; background: #fffbeb; border: 1px solid #fde68a; border-radius: 8px; font-size: 14px; color: #92400e;">
                        <i class="fa-solid fa-triangle-exclamation"></i>
                        Nếu nhập tay, vui lòng ghi <b>chính xác nội dung ${transferContent}</b> và
                        <b>đúng số tiền</b> để hệ thống xác nhận tự động.
                    </div>

                    <c:if test="${mode eq 'deposit'}">
                        <div style="margin-top: 10px; padding: 12px 15px; background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 8px; font-size: 14px; color: #1e40af;">
                            <i class="fa-solid fa-circle-info"></i>
                            Sau khi nhận đủ tiền cọc, đặt phòng sẽ hiển thị "Đã cọc" và
                            <b>chờ lễ tân xác nhận</b> để chuyển sang trạng thái Đã xác nhận.
                        </div>
                    </c:if>

                    <a href="${pageContext.request.contextPath}/customer/payments"
                       class="btn-secondary" style="display: inline-block; margin-top: 20px; text-decoration: none;">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại trang thanh toán
                    </a>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Poll trạng thái 3s/lần; webhook SePay ghi nhận đủ tiền thì chuyển trang
        <c:choose>
            <c:when test="${mode eq 'deposit'}">
        const statusUrl = '${pageContext.request.contextPath}/customer/payments/status?bookingId=${booking.bookingId}';
        const successUrl = '${pageContext.request.contextPath}/customer/payments?success=deposit_paid';
            </c:when>
            <c:otherwise>
        const statusUrl = '${pageContext.request.contextPath}/customer/payments/status?invoiceId=${invoice.invoiceId}';
        const successUrl = '${pageContext.request.contextPath}/customer/payments?success=paid';
            </c:otherwise>
        </c:choose>
        const timer = setInterval(async function () {
            try {
                const res = await fetch(statusUrl);
                if (!res.ok) return;
                const data = await res.json();
                if (data.paid) {
                    clearInterval(timer);
                    document.getElementById('waitingBox').style.display = 'none';
                    document.getElementById('paidBox').style.display = 'block';
                    setTimeout(function () { window.location.href = successUrl; }, 1500);
                }
            } catch (e) {
                // Bỏ qua lỗi mạng tạm thời, lần poll sau thử lại
            }
        }, 3000);
    </script>
</body>
</html>
