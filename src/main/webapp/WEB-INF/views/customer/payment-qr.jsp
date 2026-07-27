<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer_booking.css?v=21" />
<fmt:setLocale value="vi_VN" />

<body>

    <%-- Header Navigation --%>
    <nav class="navbar-rooms">
<a href="${pageContext.request.contextPath}/" class="logo">${not empty hotelName ? hotelName : 'HotelOps'}</a>
        <ul class="nav-links">
            <li><a href="${pageContext.request.contextPath}/">Trang chá»§</a></li>
            <li><a href="${pageContext.request.contextPath}/rooms">PhÃ²ng</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/bookings">Äáº·t phÃ²ng cá»§a tÃ´i</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/feedbacks">ÄÃ¡nh giÃ¡ lÆ°u trÃº</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/services">Dá»‹ch vá»¥</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/maintenance">Sá»± cá»‘</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/payments" class="active">Thanh toÃ¡n</a></li>
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
                        <i class="fa-solid fa-id-card"></i> Há»“ sÆ¡
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/bookings" class="dropdown-item">
                        <i class="fa-solid fa-calendar-check"></i> Äáº·t phÃ²ng cá»§a tÃ´i
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/booking/change" class="dropdown-item">
                        <i class="fa-solid fa-pen-to-square"></i> Thay Ä‘á»•i Ä‘áº·t phÃ²ng
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/feedbacks" class="dropdown-item">
                        <i class="fa-solid fa-star"></i> ÄÃ¡nh giÃ¡ lÆ°u trÃº
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/services" class="dropdown-item">
                        <i class="fa-solid fa-bell-concierge"></i> YÃªu cáº§u dá»‹ch vá»¥
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/maintenance" class="dropdown-item">
                        <i class="fa-solid fa-screwdriver-wrench"></i> YÃªu cáº§u sá»­a chá»¯a
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/payments" class="dropdown-item">
                        <i class="fa-solid fa-credit-card"></i> Thanh toÃ¡n & Lá»‹ch sá»­
                    </a>
                    <div class="dropdown-divider"></div>
                    <a href="${pageContext.request.contextPath}/logout" class="dropdown-item logout-item">
                        <i class="fa-solid fa-right-from-bracket"></i> ÄÄƒng xuáº¥t
                    </a>
                </div>
            </div>
        </div>
    </nav>

    <div class="booking-container">
        <div class="booking-header">
            <c:choose>
                <c:when test="${mode eq 'deposit'}">
                    <h1>Thanh ToÃ¡n Tiá»n Cá»c â€” Äáº·t PhÃ²ng #${booking.bookingId}</h1>
                    <p>Chuyá»ƒn tiá»n cá»c Ä‘á»ƒ giá»¯ phÃ²ng. Sau khi nháº­n Ä‘á»§ cá»c, lá»… tÃ¢n sáº½ xÃ¡c nháº­n Ä‘áº·t phÃ²ng cá»§a báº¡n.</p>
                </c:when>
                <c:otherwise>
                    <h1>Thanh ToÃ¡n HÃ³a ÄÆ¡n #${invoice.invoiceId}</h1>
                    <p>QuÃ©t mÃ£ QR báº±ng á»©ng dá»¥ng ngÃ¢n hÃ ng Ä‘á»ƒ thanh toÃ¡n. Há»‡ thá»‘ng tá»± Ä‘á»™ng xÃ¡c nháº­n sau vÃ i giÃ¢y.</p>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="booking-card" style="padding: 30px;">
            <div style="display: flex; gap: 40px; flex-wrap: wrap; justify-content: center; align-items: flex-start;">

                <%-- Cá»™t trÃ¡i: mÃ£ QR --%>
                <div style="text-align: center;">
                    <img src="${qrUrl}" alt="MÃ£ QR thanh toÃ¡n SePay"
                         style="width: 280px; height: 280px; border: 1px solid #e2e8f0; border-radius: 12px; padding: 10px; background: #fff;" />
                    <div id="waitingBox" style="margin-top: 15px; color: #b45309; font-weight: 600;">
                        <i class="fa-solid fa-spinner fa-spin"></i>
                        Äang chá» thanh toÃ¡n...
                    </div>
                    <div id="paidBox" style="margin-top: 15px; color: #15803d; font-weight: 700; display: none;">
                        <i class="fa-solid fa-circle-check"></i>
                        ÄÃ£ nháº­n thanh toÃ¡n! Äang chuyá»ƒn trang...
                    </div>
                </div>

                <%-- Cá»™t pháº£i: thÃ´ng tin chuyá»ƒn khoáº£n --%>
                <div style="min-width: 300px; flex: 1; max-width: 480px;">
                    <h3 style="margin-bottom: 15px;">ThÃ´ng tin chuyá»ƒn khoáº£n</h3>
                    <table style="width: 100%; border-collapse: collapse; font-size: 15px;">
                        <tr style="border-bottom: 1px solid #f1f5f9;">
                            <td style="padding: 10px 0; color: #64748b;">NgÃ¢n hÃ ng</td>
                            <td style="padding: 10px 0; text-align: right; font-weight: 600;">${bankCode}</td>
                        </tr>
                        <tr style="border-bottom: 1px solid #f1f5f9;">
                            <td style="padding: 10px 0; color: #64748b;">Sá»‘ tÃ i khoáº£n</td>
                            <td style="padding: 10px 0; text-align: right; font-weight: 600;">${bankAccount}</td>
                        </tr>
                        <c:if test="${not empty accountHolder}">
                            <tr style="border-bottom: 1px solid #f1f5f9;">
                                <td style="padding: 10px 0; color: #64748b;">Chá»§ tÃ i khoáº£n</td>
                                <td style="padding: 10px 0; text-align: right; font-weight: 600;">${accountHolder}</td>
                            </tr>
                        </c:if>

                        <c:choose>
                            <c:when test="${mode eq 'deposit'}">
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 10px 0; color: #64748b;">Loáº¡i phÃ²ng</td>
                                    <td style="padding: 10px 0; text-align: right;">${booking.groupRoomTypeNames}</td>
                                </tr>
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 10px 0; color: #64748b;">Thá»i gian nghá»‰</td>
                                    <td style="padding: 10px 0; text-align: right;">
                                        <fmt:formatDate value="${booking.checkInDate}" pattern="dd/MM/yyyy" />
                                        &rarr;
                                        <fmt:formatDate value="${booking.checkOutDate}" pattern="dd/MM/yyyy" />
                                    </td>
                                </tr>
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 10px 0; color: #64748b;">Tá»•ng tiá»n phÃ²ng</td>
                                    <td style="padding: 10px 0; text-align: right;">
                                        <fmt:formatNumber value="${booking.overallTotalAmount}" maxFractionDigits="0" /> Ä‘
                                    </td>
                                </tr>
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 10px 0; color: #64748b;">Tiá»n cá»c giá»¯ phÃ²ng (30%)</td>
                                    <td style="padding: 10px 0; text-align: right;">
                                        <fmt:formatNumber value="${depositAmount}" maxFractionDigits="0" /> Ä‘
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 10px 0; color: #64748b;">Tá»•ng hÃ³a Ä‘Æ¡n</td>
                                    <td style="padding: 10px 0; text-align: right;">
                                        <fmt:formatNumber value="${invoice.totalAmount}" maxFractionDigits="0" /> Ä‘
                                    </td>
                                </tr>
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 10px 0; color: #64748b;">Tiá»n cá»c Ä‘Ã£ tráº£ (30% tiá»n phÃ²ng)</td>
                                    <td style="padding: 10px 0; text-align: right;">
                                        &minus; <fmt:formatNumber value="${invoice.depositAmount}" maxFractionDigits="0" /> Ä‘
                                    </td>
                                </tr>
                                <c:if test="${invoice.refundedAmount > 0}">
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="padding: 10px 0; color: #64748b;">ÄÃ£ hoÃ n</td>
                                        <td style="padding: 10px 0; text-align: right;">
                                            &minus; <fmt:formatNumber value="${invoice.refundedAmount}" maxFractionDigits="0" /> Ä‘
                                        </td>
                                    </tr>
                                </c:if>
                            </c:otherwise>
                        </c:choose>

                        <tr style="border-bottom: 1px solid #f1f5f9;">
                            <td style="padding: 10px 0; color: #64748b;">Sá»‘ tiá»n cáº§n thanh toÃ¡n</td>
                            <td style="padding: 10px 0; text-align: right; font-weight: 700; color: #b91c1c; font-size: 18px;">
                                <fmt:formatNumber value="${remainingAmount}" maxFractionDigits="0" /> Ä‘
                            </td>
                        </tr>
                        <tr>
                            <td style="padding: 10px 0; color: #64748b;">Ná»™i dung chuyá»ƒn khoáº£n</td>
                            <td style="padding: 10px 0; text-align: right; font-weight: 700; color: #1d4ed8;">${transferContent}</td>
                        </tr>
                    </table>

                    <div style="margin-top: 15px; padding: 12px 15px; background: #fffbeb; border: 1px solid #fde68a; border-radius: 8px; font-size: 14px; color: #92400e;">
                        <i class="fa-solid fa-triangle-exclamation"></i>
                        Náº¿u nháº­p tay, vui lÃ²ng ghi <b>chÃ­nh xÃ¡c ná»™i dung ${transferContent}</b> vÃ 
                        <b>Ä‘Ãºng sá»‘ tiá»n</b> Ä‘á»ƒ há»‡ thá»‘ng xÃ¡c nháº­n tá»± Ä‘á»™ng.
                    </div>

                    <c:if test="${mode eq 'deposit'}">
                        <div style="margin-top: 10px; padding: 12px 15px; background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 8px; font-size: 14px; color: #1e40af;">
                            <i class="fa-solid fa-circle-info"></i>
                            Sau khi nháº­n Ä‘á»§ tiá»n cá»c, Ä‘áº·t phÃ²ng sáº½ hiá»ƒn thá»‹ "ÄÃ£ cá»c" vÃ 
                            <b>chá» lá»… tÃ¢n xÃ¡c nháº­n</b> Ä‘á»ƒ chuyá»ƒn sang tráº¡ng thÃ¡i ÄÃ£ xÃ¡c nháº­n.
                        </div>
                    </c:if>

                    <a href="${pageContext.request.contextPath}/customer/payments"
                       class="btn-secondary" style="display: inline-block; margin-top: 20px; text-decoration: none;">
                        <i class="fa-solid fa-arrow-left"></i> Quay láº¡i trang thanh toÃ¡n
                    </a>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Poll tráº¡ng thÃ¡i 3s/láº§n; webhook SePay ghi nháº­n Ä‘á»§ tiá»n thÃ¬ chuyá»ƒn trang
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
                // Bá» qua lá»—i máº¡ng táº¡m thá»i, láº§n poll sau thá»­ láº¡i
            }
        }, 3000);
    </script>
</body>
</html>
