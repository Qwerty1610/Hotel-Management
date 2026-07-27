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
                            <li><a href="${pageContext.request.contextPath}/customer/bookings" class="active">Äáº·t phÃ²ng
                                    cá»§a tÃ´i</a></li>
                            <li><a href="${pageContext.request.contextPath}/customer/feedbacks">ÄÃ¡nh giÃ¡ lÆ°u trÃº</a></li>
                            <li><a href="${pageContext.request.contextPath}/customer/services">Dá»‹ch vá»¥</a></li>
                            <li><a href="${pageContext.request.contextPath}/customer/maintenance">Sá»± cá»‘</a></li>
                            <li><a href="${pageContext.request.contextPath}/customer/payments">Thanh toÃ¡n</a></li>
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
                                                        <i class="fa-solid fa-id-card"></i> Há»“ sÆ¡
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/bookings"
                                                        class="dropdown-item">
                                                        <i class="fa-solid fa-calendar-check"></i> Äáº·t phÃ²ng cá»§a tÃ´i
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/booking/change" class="dropdown-item">
                                                        <i class="fa-solid fa-pen-to-square"></i> Thay Ä‘á»•i Ä‘áº·t phÃ²ng
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/feedbacks"
                                                        class="dropdown-item">
                                                        <i class="fa-solid fa-star"></i> ÄÃ¡nh giÃ¡ lÆ°u trÃº
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/services"
                                                        class="dropdown-item">
                                                        <i class="fa-solid fa-bell-concierge"></i> YÃªu cáº§u dá»‹ch vá»¥
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/maintenance"
                                                        class="dropdown-item">
                                                        <i class="fa-solid fa-screwdriver-wrench"></i> YÃªu cáº§u sá»­a chá»¯a
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/payments" class="dropdown-item">
                                                        <i class="fa-solid fa-credit-card"></i> Thanh toÃ¡n & Lá»‹ch sá»­
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
                                                <i class="fa-solid fa-right-from-bracket"></i> ÄÄƒng xuáº¥t
                                            </a>
                                        </div>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/home/login" class="btn-login">ÄÄƒng
                                        nháº­p</a>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </nav>

                    <div class="booking-container">
                        <div class="receipt-layout">

                            <%-- Receipt card --%>
                                <div class="booking-card" style="padding: 40px; position: relative;">

                                    <div class="receipt-header">
<a href="${pageContext.request.contextPath}/" class="logo">${not empty hotelName ? hotelName : 'HotelOps'}</a>
                                        <h2>ÄÆ N Äáº¶T PHÃ’NG KHÃCH Sáº N</h2>
                                        <p style="color: var(--text-muted); font-size: 14px; margin-top: 5px;">MÃ£ Ä‘áº·t
                                            phÃ²ng: #${booking.bookingId}</p>

                                        <div style="margin-top: 15px;">
                                            <c:choose>
                                                <c:when test="${booking.status eq 'Pending'}">
                                                    <span class="badge badge-pending"
                                                        style="font-size: 14px; padding: 6px 14px;">Chá» duyá»‡t</span>
                                                </c:when>
                                                <c:when test="${booking.status eq 'Confirmed'}">
                                                    <span class="badge badge-confirmed"
                                                        style="font-size: 14px; padding: 6px 14px;">ÄÃ£ xÃ¡c nháº­n</span>
                                                </c:when>
                                                <c:when test="${booking.status eq 'CheckedIn'}">
                                                    <span class="badge badge-checkedin"
                                                        style="font-size: 14px; padding: 6px 14px;">ÄÃ£ nháº­n phÃ²ng</span>
                                                </c:when>
                                                <c:when test="${booking.status eq 'CheckedOut'}">
                                                    <span class="badge badge-checkedout"
                                                        style="font-size: 14px; padding: 6px 14px;">ÄÃ£ tráº£ phÃ²ng</span>
                                                </c:when>
                                                <c:when test="${booking.status eq 'Cancelled'}">
                                                    <span class="badge badge-cancelled"
                                                        style="font-size: 14px; padding: 6px 14px;">ÄÃ£ há»§y</span>
                                                </c:when>
                                                <c:when test="${booking.status eq 'Rejected'}">
                                                    <span class="badge badge-rejected"
                                                        style="font-size: 14px; padding: 6px 14px;">Tá»« chá»‘i</span>
                                                </c:when>
                                            </c:choose>
                                        </div>
                                    </div>

                                    <div class="receipt-grid-2">
                                        <div class="receipt-info-section">
                                            <h3>ThÃ´ng tin khÃ¡ch hÃ ng</h3>
                                            <div class="receipt-info-row">
                                                <span>NgÆ°á»i Ä‘áº·t:</span>
                                                <span>${booking.customerName}</span>
                                            </div>
                                            <div class="receipt-info-row">
                                                <span>Email:</span>
                                                <span>${booking.email != null && not empty booking.email ? booking.email
                                                    : sessionScope.email}</span>
                                            </div>
                                            <div class="receipt-info-row">
                                                <span>Sá»‘ Ä‘iá»‡n thoáº¡i:</span>
                                                <span>${booking.phone != null && not empty booking.phone ? booking.phone
                                                    : 'ChÆ°a cung cáº¥p'}</span>
                                            </div>
                                            <div class="receipt-info-row">
                                                <span>NgÃ y láº­p Ä‘Æ¡n:</span>
                                                <span>
                                                    <fmt:formatDate value="${booking.createdAt}" pattern="dd/MM/yyyy" />
                                                </span>
                                            </div>
                                        </div>

                                        <div class="receipt-info-section">
                                            <h3>Thá»i gian lÆ°u trÃº</h3>
                                            <div class="receipt-info-row">
                                                <span>NgÃ y nháº­n phÃ²ng:</span>
                                                <span>
                                                    <fmt:formatDate value="${booking.checkInDate}"
                                                        pattern="dd/MM/yyyy" />
                                                </span>
                                            </div>
                                            <div class="receipt-info-row">
                                                <span>NgÃ y tráº£ phÃ²ng:</span>
                                                <span>
                                                    <fmt:formatDate value="${booking.checkOutDate}"
                                                        pattern="dd/MM/yyyy" />
                                                </span>
                                            </div>
                                            <div class="receipt-info-row">
                                                <span>Sá»‘ Ä‘Ãªm nghá»‰:</span>
                                                <span
                                                    style="font-weight: 700; color: var(--primary-indigo);">${booking.nights}
                                                    Ä‘Ãªm</span>
                                            </div>
                                            <div class="receipt-info-row">
                                                <span>Sá»‘ loáº¡i phÃ²ng:</span>
                                                <span
                                                    style="font-weight: 700; color: var(--primary-indigo);">${booking.totalRoomTypes}
                                                    loáº¡i</span>
                                            </div>
                                            <div class="receipt-info-row">
                                                <span>Tá»•ng sá»‘ phÃ²ng:</span>
                                                <span
                                                    style="font-weight: 700; color: var(--primary-indigo);">${booking.totalRoomQuantity}
                                                    phÃ²ng</span>
                                            </div>
                                        </div>
                                    </div>

                                    <h3
                                        style="font-size: 16px; color: var(--primary-indigo); margin: 30px 0 15px 0; border-bottom: 1px solid var(--border-color); padding-bottom: 5px;">
                                        Chi tiáº¿t cÃ¡c phÃ²ng Ä‘Ã£ chá»n Ä‘áº·t
                                    </h3>

                                    <table class="table-receipt">
                                        <thead>
                                            <tr>
                                                <th style="width: 50px;">STT</th>
                                                <th>Loáº¡i phÃ²ng</th>
                                                <th style="text-align: center;">Sá»‘ lÆ°á»£ng</th>
                                                <th style="text-align: right;">ÄÆ¡n giÃ¡ / Ä‘Ãªm</th>
                                                <th>Há» tÃªn khÃ¡ch nghá»‰</th>
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
                                                            Ä‘Æ¡n Ä‘áº·t)</td>
                                                    </tr>
                                                </c:otherwise>
                                            </c:choose>
                                        </tbody>
                                    </table>

                                    <c:if test="${not empty booking.note}">
                                        <div
                                            style="background-color: #fffbeb; border: 1px solid #fef3c7; border-radius: 8px; padding: 15px; margin-bottom: 30px;">
                                            <h4 style="margin: 0 0 5px 0; font-size: 14px; color: #b45309;"><i
                                                    class="fa-solid fa-comment-dots"></i> Ghi chÃº / YÃªu cáº§u Ä‘áº·c biá»‡t:
                                            </h4>
                                            <p style="margin: 0; font-size: 13.5px; color: #78350f; line-height: 1.5;">
                                                ${booking.note}</p>
                                        </div>
                                    </c:if>

                                    <%-- Pricing breakdown --%>
                                        <div
                                            style="border-top: 2px dashed var(--border-color); padding-top: 20px; width: 300px; margin-left: auto;">
                                            <div class="receipt-info-row" style="margin-bottom: 12px;">
                                                <span>Tá»•ng tiá»n phÃ²ng:</span>
                                                <span style="font-weight: 600; font-size: 15px;">
                                                    <fmt:formatNumber value="${booking.totalAmount}" type="currency"
                                                        currencySymbol="" /> VND
                                                </span>
                                            </div>
                                            <div class="receipt-info-row"
                                                style="margin-bottom: 12px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
                                                <span>Tiá»n Ä‘áº·t cá»c (30%):</span>
                                                <span
                                                    style="font-weight: 600; color: var(--accent-gold); font-size: 15px;">
                                                    <fmt:formatNumber value="${booking.totalAmount * 0.3}"
                                                        type="currency" currencySymbol="" /> VND
                                                </span>
                                            </div>
                                            <div class="receipt-info-row"
                                                style="font-size: 18px; font-weight: 700; color: var(--primary-dark);">
                                                <span>Tá»”NG TIá»€N:</span>
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
                                                    <i class="fa-solid fa-arrow-left"></i> Quay láº¡i danh sÃ¡ch
                                                </a>

                                                <c:if
                                                    test="${booking.status eq 'Pending' || booking.status eq 'Confirmed'}">
                                                    <button type="button" class="btn-danger"
                                                        style="padding: 10px 20px; width: auto; max-width: none; height: auto;"
                                                        onclick="confirmCancel(${booking.bookingId})">
                                                        <i class="fa-solid fa-calendar-xmark"></i> Há»§y Ä‘áº·t phÃ²ng nÃ y
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
                                        <p>Há»‡ thá»‘ng quáº£n lÃ½ vÃ  nghá»‰ dÆ°á»¡ng Ä‘áº³ng cáº¥p quá»‘c táº¿, Ä‘em láº¡i tráº£i nghiá»‡m sang
                                            trá»ng vÆ°á»£t thá»i gian.</p>
                                    </div>

                                    <div class="footer-white-links">
                                        <h4>LiÃªn káº¿t nhanh</h4>
                                        <ul>
                                            <li><a href="#">Trang chá»§</a></li>
                                            <li><a href="#">PhÃ²ng & GiÃ¡</a></li>
                                            <li><a href="#">Dá»‹ch vá»¥</a></li>
                                        </ul>
                                    </div>

                                    <div class="footer-white-links">
                                        <h4>ChÃ­nh sÃ¡ch</h4>
                                        <ul>
                                            <li><a href="#">ChÃ­nh sÃ¡ch báº£o máº­t</a></li>
                                            <li><a href="#">Äiá»u khoáº£n sá»­ dá»¥ng</a></li>
                                            <li><a href="#">ChÃ­nh sÃ¡ch hoÃ n tiá»n</a></li>
                                        </ul>
                                    </div>

                                    <div class="footer-white-contact">
                                        <h4>ThÃ´ng tin liÃªn há»‡</h4>
                                        <p><i class="fa-solid fa-location-dot"></i> 123 ÄÆ°á»ng LÃª Lá»£i, Quáº­n 1, TP. Há»“ ChÃ­
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
                                    if (confirm("Báº¡n cÃ³ cháº¯c cháº¯n muá»‘n há»§y Ä‘Æ¡n Ä‘áº·t phÃ²ng #" + bookingId + " nÃ y? Tráº¡ng thÃ¡i sáº½ cáº­p nháº­t thÃ nh ÄÃ£ há»§y vÃ  phÃ²ng nghá»‰ sáº½ Ä‘Æ°á»£c giáº£i phÃ³ng.")) {
                                        document.getElementById('cancelForm').submit();
                                    }
                                }
                            </script>
            </body>

            </html>