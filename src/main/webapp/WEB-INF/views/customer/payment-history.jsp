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
            <h1>Thanh ToÃ¡n &amp; Lá»‹ch Sá»­ Giao Dá»‹ch</h1>
            <p>Thanh toÃ¡n hÃ³a Ä‘Æ¡n online qua chuyá»ƒn khoáº£n ngÃ¢n hÃ ng (SePay) vÃ  xem láº¡i cÃ¡c giao dá»‹ch Ä‘Ã£ thá»±c hiá»‡n</p>
        </div>

        <%-- Alerts --%>
        <c:if test="${not empty successMessage}">
            <div class="success-banner">
                <i class="fa-solid fa-circle-check" style="font-size: 20px;"></i>
                <div><strong>ThÃ nh cÃ´ng:</strong> ${successMessage}</div>
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="error-banner">
                <i class="fa-solid fa-circle-exclamation" style="font-size: 20px;"></i>
                <div><strong>KhÃ´ng thá»ƒ thanh toÃ¡n:</strong> ${errorMessage}</div>
            </div>
        </c:if>

        <%-- ============ Äáº·t phÃ²ng chá» thanh toÃ¡n cá»c ============ --%>
        <h2 style="margin: 25px 0 12px; font-size: 20px;">
            <i class="fa-solid fa-hand-holding-dollar"></i> Äáº·t phÃ²ng chá» thanh toÃ¡n cá»c
        </h2>
        <div class="booking-card" style="padding: 0; overflow-x: auto; margin-bottom: 10px;">
            <table class="booking-list-table">
                <thead>
                    <tr>
                        <th>MÃ£ Ä‘áº·t phÃ²ng</th>
                        <th>Loáº¡i phÃ²ng</th>
                        <th>Thá»i gian nghá»‰</th>
                        <th>Tá»•ng tiá»n phÃ²ng</th>
                        <th>Tiá»n cá»c (30%)</th>
                        <th>ÄÃ£ chuyá»ƒn</th>
                        <th>Tráº¡ng thÃ¡i</th>
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
                            <td><fmt:formatNumber value="${item.booking.overallTotalAmount}" maxFractionDigits="0" /> Ä‘</td>
                            <td style="font-weight: 700; color: #b91c1c;">
                                <fmt:formatNumber value="${item.depositAmount}" maxFractionDigits="0" /> Ä‘
                            </td>
                            <td><fmt:formatNumber value="${item.paidAmount}" maxFractionDigits="0" /> Ä‘</td>
                            <td>
                                <c:choose>
                                    <c:when test="${item.fullyPaid}">
                                        <span class="badge badge-confirmed">ÄÃ£ cá»c â€” chá» xÃ¡c nháº­n</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-pending">Chá» thanh toÃ¡n cá»c</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:if test="${not item.fullyPaid}">
                                    <a href="${pageContext.request.contextPath}/customer/payments/pay?bookingId=${item.booking.bookingId}"
                                       class="btn-primary" style="width: auto; padding: 8px 16px; margin-top: 0; text-decoration: none; display: inline-block;">
                                        <i class="fa-solid fa-qrcode"></i> Thanh toÃ¡n cá»c
                                    </a>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty depositItems}">
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 30px; color: #64748b;">
                                <i class="fa-solid fa-circle-check" style="font-size: 24px; color: #22c55e;"></i><br/>
                                Báº¡n khÃ´ng cÃ³ Ä‘áº·t phÃ²ng nÃ o Ä‘ang chá» thanh toÃ¡n cá»c.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <%-- ============ HÃ³a Ä‘Æ¡n chá» thanh toÃ¡n (Make Online Payment) ============ --%>
        <h2 style="margin: 25px 0 12px; font-size: 20px;">
            <i class="fa-solid fa-file-invoice-dollar"></i> HÃ³a Ä‘Æ¡n chá» thanh toÃ¡n
        </h2>
        <div class="booking-card" style="padding: 0; overflow-x: auto;">
            <table class="booking-list-table">
                <thead>
                    <tr>
                        <th>MÃ£ hÃ³a Ä‘Æ¡n</th>
                        <th>PhÃ²ng</th>
                        <th>NgÃ y táº¡o</th>
                        <th>Tá»•ng tiá»n</th>
                        <th>Cá»c Ä‘Ã£ tráº£</th>
                        <th>Cáº§n thanh toÃ¡n</th>
                        <th>Tráº¡ng thÃ¡i</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="inv" items="${unpaidInvoices}">
                        <tr>
                            <td><b>#${inv.invoiceId}</b></td>
                            <td>${empty inv.roomNumber ? 'â€”' : inv.roomNumber}</td>
                            <td><fmt:formatDate value="${inv.createdAt}" pattern="dd/MM/yyyy HH:mm" /></td>
                            <td><fmt:formatNumber value="${inv.totalAmount}" maxFractionDigits="0" /> Ä‘</td>
                            <td><fmt:formatNumber value="${inv.depositAmount}" maxFractionDigits="0" /> Ä‘</td>
                            <td style="font-weight: 700; color: #b91c1c;">
                                <fmt:formatNumber value="${inv.netAmount}" maxFractionDigits="0" /> Ä‘
                            </td>
                            <td><span class="badge badge-pending">Chá» thanh toÃ¡n</span></td>
                            <td>
                                <c:if test="${inv.netAmount > 0}">
                                    <a href="${pageContext.request.contextPath}/customer/payments/pay?invoiceId=${inv.invoiceId}"
                                       class="btn-primary" style="width: auto; padding: 8px 16px; margin-top: 0; text-decoration: none; display: inline-block;">
                                        <i class="fa-solid fa-qrcode"></i> Thanh toÃ¡n
                                    </a>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty unpaidInvoices}">
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 30px; color: #64748b;">
                                <i class="fa-solid fa-circle-check" style="font-size: 24px; color: #22c55e;"></i><br/>
                                Báº¡n khÃ´ng cÃ³ hÃ³a Ä‘Æ¡n nÃ o Ä‘ang chá» thanh toÃ¡n.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <%-- ============ Lá»‹ch sá»­ thanh toÃ¡n (View Payment History) ============ --%>
        <h2 style="margin: 35px 0 12px; font-size: 20px;">
            <i class="fa-solid fa-clock-rotate-left"></i> Lá»‹ch sá»­ thanh toÃ¡n
        </h2>
        <div class="booking-card" style="padding: 0; overflow-x: auto;">
            <table class="booking-list-table">
                <thead>
                    <tr>
                        <th>MÃ£ GD</th>
                        <th>Loáº¡i</th>
                        <th>PhÃ²ng</th>
                        <th>Sá»‘ tiá»n</th>
                        <th>NgÃ¢n hÃ ng</th>
                        <th>MÃ£ tham chiáº¿u</th>
                        <th>Thá»i gian</th>
                        <th>Tráº¡ng thÃ¡i</th>
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
                                        Cá»c Ä‘áº·t phÃ²ng #${p.bookingId}
                                    </c:when>
                                    <c:otherwise>
                                        <i class="fa-solid fa-file-invoice-dollar" style="color: #1d4ed8;"></i>
                                        HÃ³a Ä‘Æ¡n #${p.invoiceId}
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${empty p.roomNumber ? 'â€”' : p.roomNumber}</td>
                            <td style="font-weight: 600; color: #15803d;">
                                + <fmt:formatNumber value="${p.amount}" maxFractionDigits="0" /> Ä‘
                            </td>
                            <td>${empty p.gateway ? 'â€”' : p.gateway}</td>
                            <td style="font-size: 13px; color: #64748b;">${empty p.referenceCode ? 'â€”' : p.referenceCode}</td>
                            <td>
                                <fmt:formatDate value="${empty p.transactionDate ? p.createdAt : p.transactionDate}"
                                                pattern="dd/MM/yyyy HH:mm" />
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${p.deposit}">
                                        <span class="badge badge-confirmed">ÄÃ£ nháº­n cá»c</span>
                                    </c:when>
                                    <c:when test="${p.invoiceStatus eq 'Paid'}">
                                        <span class="badge badge-confirmed">ÄÃ£ thanh toÃ¡n</span>
                                    </c:when>
                                    <c:when test="${p.invoiceStatus eq 'Refunding'}">
                                        <span class="badge badge-pending">Äang hoÃ n tiá»n</span>
                                    </c:when>
                                    <c:when test="${p.invoiceStatus eq 'Refunded'}">
                                        <span class="badge badge-checkedout">ÄÃ£ hoÃ n tiá»n</span>
                                    </c:when>
                                    <c:when test="${p.invoiceStatus eq 'Cancelled'}">
                                        <span class="badge badge-cancelled">ÄÃ£ há»§y</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-pending">ChÆ°a Ä‘á»§ tiá»n</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty payments}">
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 30px; color: #64748b;">
                                <i class="fa-solid fa-receipt" style="font-size: 24px;"></i><br/>
                                Báº¡n chÆ°a cÃ³ giao dá»‹ch thanh toÃ¡n nÃ o.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
