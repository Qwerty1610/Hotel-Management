<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer_booking.css?v=21" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/booking-requests.css?v=3" />
<fmt:setLocale value="vi_VN" />

<style>
    .btn-view-detail {
        text-decoration: none;
        padding: 5px 12px;
        font-size: 13px;
        background-color: #ffffff;
        color: var(--brand-blue);
        border: 1px solid var(--brand-blue);
        border-radius: 6px;
        font-weight: 600;
        white-space: nowrap;
        transition: all 0.2s;
        display: inline-block;
    }
    .btn-view-detail:hover {
        background-color: var(--brand-blue);
        color: #ffffff;
        transform: translateY(-1px);
        box-shadow: 0 4px 10px rgba(37, 99, 235, .25);
    }
    .btn-cancel-booking {
        padding: 5px 12px;
        font-size: 13px;
        background-color: #ffffff;
        color: #ef4444;
        border: 1px solid #ef4444;
        border-radius: 6px;
        cursor: pointer;
        font-weight: 600;
        transition: all 0.2s;
        white-space: nowrap;
    }
    .btn-cancel-booking:hover {
        background-color: #ef4444;
        color: #ffffff;
        transform: translateY(-1px);
        box-shadow: 0 4px 10px rgba(239, 68, 68, .25);
    }
</style>

<body>

    <%-- Header Navigation --%>
    <nav class="navbar-rooms">
<a href="${pageContext.request.contextPath}/" class="logo">${not empty hotelName ? hotelName : 'HotelOps'}</a>
        <ul class="nav-links">
            <li><a href="${pageContext.request.contextPath}/">Trang chá»§</a></li>
            <li><a href="${pageContext.request.contextPath}/rooms">PhÃ²ng</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/bookings" class="active">Äáº·t phÃ²ng cá»§a tÃ´i</a></li>
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
                            <i class="fa-solid fa-chevron-down" style="font-size: 10px; margin-left: 2px;"></i>
                        </button>
                        <div class="dropdown-menu">
                            <c:choose>
                                <c:when test="${sessionScope.role eq 'CUSTOMER'}">
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
                                <i class="fa-solid fa-right-from-bracket"></i> ÄÄƒng xuáº¥t
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/home/login" class="btn-login">ÄÄƒng nháº­p</a>
                </c:otherwise>
            </c:choose>
        </div>
    </nav>

    <div class="booking-container">
        <div class="booking-header">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
                <div>
                    <h1>Quáº£n lÃ½ Äáº·t PhÃ²ng Cá»§a TÃ´i</h1>
                    <p>Xem lá»‹ch sá»­ giao dá»‹ch vÃ  tráº¡ng thÃ¡i cÃ¡c Ä‘Æ¡n Ä‘áº·t phÃ²ng cá»§a báº¡n</p>
                </div>
                <div class="br-actions">
                    <a href="${pageContext.request.contextPath}/customer/booking/create" class="btn-primary" style="margin-top: 0; width: auto; padding: 10px 20px;">
                        <i class="fa-solid fa-calendar-plus"></i> Äáº·t phÃ²ng má»›i
                    </a>
                </div>
            </div>
        </div>

        <%-- Alerts --%>
        <c:if test="${not empty successMessage}">
            <div class="success-banner" id="serverSuccessMessage">
                <i class="fa-solid fa-circle-check" style="font-size: 20px;"></i>
                <div>
                    <strong>ThÃ nh cÃ´ng:</strong> ${successMessage}
                </div>
            </div>
        </c:if>
        <c:if test="${not empty errorCode}">
            <div class="error-banner" id="serverValidationError">
                <i class="fa-solid fa-circle-exclamation" style="font-size: 20px;"></i>
                <div>
                    <strong>YÃªu cáº§u tháº¥t báº¡i:</strong> ${errorMessage}
                </div>
            </div>
        </c:if>

        <%-- Filter & Search Form --%>
        <div class="booking-card" style="padding: 20px; margin-bottom: 25px;">
            <form action="${pageContext.request.contextPath}/customer/bookings" method="GET" id="filterForm">
                <div class="filter-bar">
                    <%-- Keyword Search --%>
                    <div class="search-input-group">
                        <input type="text" name="keyword" placeholder="TÃ¬m theo MÃ£ Ä‘áº·t phÃ²ng hoáº·c Há» tÃªn..." value="${keyword}" />
                        <button type="submit">
                            <i class="fa-solid fa-magnifying-glass"></i> TÃ¬m kiáº¿m
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
                        <th>MÃ£ Ä‘Æ¡n</th>
                        <th>NgÃ y Ä‘áº·t</th>
                        <th>Thá»i gian nghá»‰</th>
                        <th>Loáº¡i phÃ²ng</th>
                        <th>Sá»‘ phÃ²ng</th>
                        <th>Tá»•ng tiá»n</th>
                        <th>Äáº·t cá»c (30%)</th>
                        <th>Tráº¡ng thÃ¡i</th>
                        <th>HÃ nh Ä‘á»™ng</th>
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
                                        <small style="color: var(--text-muted);">${b.nights} Ä‘Ãªm</small>
                                    </td>
                                     <td style="max-width: 200px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="${b.groupRoomTypeNames}">
                                         ${b.groupRoomTypeNames}
                                     </td>
                                     <td style="font-weight: 600;">${b.totalRoomQuantity} phÃ²ng</td>
                                     <td style="font-weight: 700; color: var(--primary-indigo);">
                                         <fmt:formatNumber value="${b.overallTotalAmount}" type="currency" currencySymbol="" /> VND
                                     </td>
                                     <td style="font-weight: 600; color: var(--accent-gold);">
                                         <fmt:formatNumber value="${b.overallTotalAmount * 0.3}" type="currency" currencySymbol="" /> VND
                                     </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${b.status eq 'Pending'}">
                                                <span class="badge badge-pending">Chá» duyá»‡t</span>
                                            </c:when>
                                            <c:when test="${b.status eq 'Confirmed'}">
                                                <span class="badge badge-confirmed">ÄÃ£ xÃ¡c nháº­n</span>
                                            </c:when>
                                            <c:when test="${b.status eq 'CheckedIn'}">
                                                <span class="badge badge-checkedin">ÄÃ£ nháº­n phÃ²ng</span>
                                            </c:when>
                                            <c:when test="${b.status eq 'CheckedOut'}">
                                                <span class="badge badge-checkedout">ÄÃ£ tráº£ phÃ²ng</span>
                                            </c:when>
                                            <c:when test="${b.status eq 'Cancelled'}">
                                                <span class="badge badge-cancelled">ÄÃ£ há»§y</span>
                                            </c:when>
                                            <c:when test="${b.status eq 'Rejected'}">
                                                <span class="badge badge-rejected">Tá»« chá»‘i</span>
                                            </c:when>
                                        </c:choose>
                                    </td>
                                    <td style="white-space: nowrap;">
                                        <div style="display: flex; gap: 8px; align-items: center;">
                                            <a href="${pageContext.request.contextPath}/customer/booking/detail?id=${b.bookingId}" class="btn-view-detail">
                                                Chi tiáº¿t
                                            </a>
                                            <c:if test="${b.status eq 'Pending' || b.status eq 'Confirmed'}">
                                                <button type="button" class="btn-cancel-booking" onclick="confirmCancelBooking('${b.bookingId}')">
                                                    Há»§y
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
                                    Báº¡n chÆ°a cÃ³ Ä‘Æ¡n Ä‘áº·t phÃ²ng nÃ o phÃ¹ há»£p vá»›i bá»™ lá»c tÃ¬m kiáº¿m.
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>


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
                <p>Há»‡ thá»‘ng quáº£n lÃ½ vÃ  nghá»‰ dÆ°á»¡ng Ä‘áº³ng cáº¥p quá»‘c táº¿, Ä‘em láº¡i tráº£i nghiá»‡m sang trá»ng vÆ°á»£t thá»i gian.</p>
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
                <p><i class="fa-solid fa-location-dot"></i> 123 ÄÆ°á»ng LÃª Lá»£i, Quáº­n 1, TP. Há»“ ChÃ­ Minh</p>
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
            if (confirm("Báº¡n cÃ³ cháº¯c cháº¯n muá»‘n há»§y Ä‘Æ¡n Ä‘áº·t phÃ²ng #" + bookingId + " khÃ´ng? Tráº¡ng thÃ¡i phÃ²ng sáº½ Ä‘Æ°á»£c hoÃ n láº¡i vÃ  báº¡n cÃ³ thá»ƒ pháº£i tráº£ phÃ­ náº¿u chÃ­nh sÃ¡ch yÃªu cáº§u.")) {
                document.getElementById('cancelBookingId').value = bookingId;
                document.getElementById('cancelForm').submit();
            }
        }

    </script>
</body>
</html>
