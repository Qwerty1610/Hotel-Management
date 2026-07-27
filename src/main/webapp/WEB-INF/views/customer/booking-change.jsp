<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer_booking.css?v=21" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/booking-requests.css?v=3" />
<fmt:setLocale value="vi_VN" />

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
                    <h1>Thay Äá»•i Äáº·t PhÃ²ng</h1>
                    <p>Gá»­i yÃªu cáº§u thay Ä‘á»•i Ä‘áº·t phÃ²ng hoáº·c gia háº¡n lÆ°u trÃº. YÃªu cáº§u sáº½ Ä‘Æ°á»£c lá»… tÃ¢n/quáº£n lÃ½ duyá»‡t.</p>
                </div>
                <a href="${pageContext.request.contextPath}/customer/bookings" class="btn-secondary" style="text-decoration: none; padding: 10px 20px;">
                    <i class="fa-solid fa-arrow-left"></i> Vá» lá»‹ch sá»­ Ä‘áº·t phÃ²ng
                </a>
            </div>
        </div>

        <%-- Alerts --%>
        <c:if test="${not empty errorCode}">
            <div class="error-banner" id="serverValidationError">
                <i class="fa-solid fa-circle-exclamation" style="font-size: 20px;"></i>
                <div>
                    <strong>YÃªu cáº§u tháº¥t báº¡i:</strong> ${errorMessage}
                </div>
            </div>
        </c:if>

        <%-- Chooser: 2 loáº¡i yÃªu cáº§u (UC 2.3.9 Booking Change) --%>
        <div class="booking-card" style="padding: 24px; margin-bottom: 25px;">
            <div class="req-choice-list req-choice-row">
                <button type="button" class="req-choice-card" id="chooseChangeCard" onclick="showRequestSection('change')">
                    <span class="req-choice-icon change"><i class="fa-solid fa-pen-to-square"></i></span>
                    <span class="req-choice-text">
                        <strong>YÃªu cáº§u thay Ä‘á»•i Ä‘áº·t phÃ²ng</strong>
                        <small>Äá»•i ngÃ y nháº­n/tráº£ phÃ²ng, loáº¡i phÃ²ng hoáº·c sá»‘ phÃ²ng cho Ä‘Æ¡n chÆ°a nháº­n phÃ²ng.</small>
                    </span>
                    <i class="fa-solid fa-chevron-right req-choice-arrow"></i>
                </button>
                <button type="button" class="req-choice-card" id="chooseExtCard" onclick="showRequestSection('extension')">
                    <span class="req-choice-icon extension"><i class="fa-solid fa-calendar-plus"></i></span>
                    <span class="req-choice-text">
                        <strong>YÃªu cáº§u gia háº¡n lÆ°u trÃº</strong>
                        <small>KÃ©o dÃ i ngÃ y tráº£ phÃ²ng cho phÃ²ng báº¡n Ä‘ang lÆ°u trÃº (Ä‘Ã£ nháº­n phÃ²ng).</small>
                    </span>
                    <i class="fa-solid fa-chevron-right req-choice-arrow"></i>
                </button>
            </div>
        </div>

        <%-- ============================================================
             SECTION: REQUEST BOOKING CHANGE (UC 2.3.9 - luá»“ng thay Ä‘á»•i)
             ============================================================ --%>
        <div class="booking-card req-section" id="changeSection" style="padding: 24px; margin-bottom: 25px; display: none;">
            <h2 class="req-section-title"><i class="fa-solid fa-pen-to-square" style="color: var(--br-blue);"></i> YÃªu cáº§u thay Ä‘á»•i Ä‘áº·t phÃ²ng</h2>
            <p class="req-hint">
                <i class="fa-solid fa-circle-info"></i>
                Chá»‰ Ã¡p dá»¥ng cho Ä‘Æ¡n <strong>Chá» duyá»‡t</strong> hoáº·c <strong>ÄÃ£ xÃ¡c nháº­n</strong> vÃ  cÃ²n trÆ°á»›c ngÃ y nháº­n phÃ²ng.
            </p>
            <form action="${pageContext.request.contextPath}/customer/booking/change-request" method="POST"
                  id="changeForm" onsubmit="return validateChange();">
                <div class="req-field">
                    <label>Chá»n Ä‘Æ¡n Ä‘áº·t phÃ²ng <span class="req-star">*</span></label>
                    <select name="bookingId" id="changeBookingSelect" onchange="onChangeBookingSelect()" required>
                        <option value="">â€” Chá»n Ä‘Æ¡n cáº§n thay Ä‘á»•i â€”</option>
                        <c:forEach var="b" items="${bookings}">
                            <c:if test="${b.status eq 'Pending' || b.status eq 'Confirmed'}">
                                <option value="${b.bookingId}"
                                        data-checkin="<fmt:formatDate value='${b.checkInDate}' pattern='yyyy-MM-dd' />"
                                        data-checkout="<fmt:formatDate value='${b.checkOutDate}' pattern='yyyy-MM-dd' />"
                                        data-roomtypeid="${b.roomTypeId}"
                                        data-qty="${b.roomQuantity}"
                                        data-roomtype="<c:out value='${b.groupRoomTypeNames}' />">
                                    #${b.bookingId} â€¢ <c:out value="${b.groupRoomTypeNames}" />
                                    (<fmt:formatDate value="${b.checkInDate}" pattern="dd/MM/yyyy" /> - <fmt:formatDate value="${b.checkOutDate}" pattern="dd/MM/yyyy" />)
                                </option>
                            </c:if>
                        </c:forEach>
                    </select>
                </div>

                <div class="req-current" id="changeCurrent">
                    <h4>ThÃ´ng tin hiá»‡n táº¡i</h4>
                    <div class="req-current-grid">
                        <span>Loáº¡i phÃ²ng: <b id="curChangeType">â€”</b></span>
                        <span>Sá»‘ phÃ²ng: <b id="curChangeQty">â€”</b></span>
                        <span>Nháº­n phÃ²ng: <b id="curChangeIn">â€”</b></span>
                        <span>Tráº£ phÃ²ng: <b id="curChangeOut">â€”</b></span>
                    </div>
                </div>

                <div class="req-grid-2">
                    <div class="req-field">
                        <label>NgÃ y nháº­n phÃ²ng má»›i <span class="req-star">*</span></label>
                        <input type="date" name="newCheckInDate" id="changeNewIn" required />
                    </div>
                    <div class="req-field">
                        <label>NgÃ y tráº£ phÃ²ng má»›i <span class="req-star">*</span></label>
                        <input type="date" name="newCheckOutDate" id="changeNewOut" required />
                    </div>
                </div>
                <div class="req-grid-2">
                    <div class="req-field">
                        <label>Loáº¡i phÃ²ng mong muá»‘n <span class="req-star">*</span></label>
                        <select name="roomTypeId" id="changeRoomType" required>
                            <option value="">â€” Chá»n loáº¡i phÃ²ng â€”</option>
                            <c:forEach var="rt" items="${roomTypes}">
                                <option value="${rt.typeId}" data-price="${rt.basePrice}">
                                    <c:out value="${rt.typeName}" /> â€” <fmt:formatNumber value="${rt.basePrice}" type="number" />Ä‘/Ä‘Ãªm
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="req-field">
                        <label>Sá»‘ phÃ²ng <span class="req-star">*</span></label>
                        <input type="number" name="roomQuantity" id="changeQty" min="1" max="100" required />
                    </div>
                </div>
                <div class="req-field">
                    <label>LÃ½ do thay Ä‘á»•i</label>
                    <textarea name="reason" maxlength="500" placeholder="VD: Thay Ä‘á»•i lá»‹ch trÃ¬nh cÃ´ng tÃ¡c..."></textarea>
                </div>

                <div class="req-modal-footer">
                    <button type="submit" class="br-btn br-btn-submit">
                        <i class="fa-solid fa-paper-plane"></i> Gá»­i yÃªu cáº§u
                    </button>
                </div>
            </form>
        </div>

        <%-- ============================================================
             SECTION: REQUEST STAY EXTENSION (UC 2.3.9 - luá»“ng gia háº¡n)
             ============================================================ --%>
        <div class="booking-card req-section" id="extSection" style="padding: 24px; margin-bottom: 25px; display: none;">
            <h2 class="req-section-title"><i class="fa-solid fa-calendar-plus" style="color: var(--br-gold);"></i> YÃªu cáº§u gia háº¡n lÆ°u trÃº</h2>
            <p class="req-hint">
                <i class="fa-solid fa-circle-info"></i>
                Chá»‰ Ã¡p dá»¥ng cho phÃ²ng báº¡n <strong>Ä‘ang lÆ°u trÃº (ÄÃ£ nháº­n phÃ²ng)</strong>. Chá»n ngÃ y tráº£ phÃ²ng má»›i muá»™n hÆ¡n Ä‘á»ƒ á»Ÿ thÃªm.
            </p>
            <form action="${pageContext.request.contextPath}/customer/booking/extension-request" method="POST"
                  id="extForm" onsubmit="return validateExtension();">
                <div class="req-field">
                    <label>Chá»n phÃ²ng Ä‘ang lÆ°u trÃº <span class="req-star">*</span></label>
                    <select name="bookingId" id="extBookingSelect" onchange="onExtBookingSelect()" required>
                        <option value="">â€” Chá»n Ä‘Æ¡n Ä‘ang lÆ°u trÃº â€”</option>
                        <c:forEach var="b" items="${bookings}">
                            <c:if test="${b.status eq 'CheckedIn'}">
                                <option value="${b.bookingId}"
                                        data-checkout="<fmt:formatDate value='${b.checkOutDate}' pattern='yyyy-MM-dd' />"
                                        data-roomtypeid="${b.roomTypeId}"
                                        data-qty="${b.roomQuantity}"
                                        data-roomtype="<c:out value='${b.groupRoomTypeNames}' />">
                                    #${b.bookingId} â€¢ <c:out value="${b.groupRoomTypeNames}" />
                                    (Tráº£: <fmt:formatDate value="${b.checkOutDate}" pattern="dd/MM/yyyy" />)
                                </option>
                            </c:if>
                        </c:forEach>
                    </select>
                </div>

                <div class="req-current" id="extCurrent">
                    <h4>ThÃ´ng tin hiá»‡n táº¡i</h4>
                    <div class="req-current-grid">
                        <span>Loáº¡i phÃ²ng: <b id="curExtType">â€”</b></span>
                        <span>Sá»‘ phÃ²ng: <b id="curExtQty">â€”</b></span>
                        <span>NgÃ y tráº£ phÃ²ng hiá»‡n táº¡i: <b id="curExtOut">â€”</b></span>
                    </div>
                </div>

                <div class="req-field">
                    <label>NgÃ y tráº£ phÃ²ng má»›i <span class="req-star">*</span></label>
                    <input type="date" name="newCheckOutDate" id="extNewOut" onchange="updateExtEstimate()" required />
                </div>

                <div class="req-estimate" id="extEstimate">
                    Phá»¥ phÃ­ dá»± kiáº¿n cho <span id="extNights">0</span> Ä‘Ãªm:
                    <strong id="extCharge">0 VND</strong>
                </div>

                <div class="req-field">
                    <label>LÃ½ do gia háº¡n</label>
                    <textarea name="reason" maxlength="500" placeholder="VD: Cáº§n á»Ÿ thÃªm vÃ¬ cÃ´ng viá»‡c kÃ©o dÃ i..."></textarea>
                </div>

                <div class="req-modal-footer">
                    <button type="submit" class="br-btn br-btn-submit">
                        <i class="fa-solid fa-paper-plane"></i> Gá»­i yÃªu cáº§u
                    </button>
                </div>
            </form>
        </div>

        <%-- Request tracking (booking change & stay extension) --%>
        <c:if test="${not empty myRequests}">
            <div class="booking-card req-track-card" style="padding: 24px;">
                <h2><i class="fa-solid fa-clipboard-list" style="color: var(--brand-blue);"></i> YÃªu cáº§u thay Ä‘á»•i &amp; gia háº¡n cá»§a tÃ´i</h2>
                <p>Theo dÃµi tráº¡ng thÃ¡i cÃ¡c yÃªu cáº§u thay Ä‘á»•i Ä‘áº·t phÃ²ng vÃ  gia háº¡n lÆ°u trÃº cá»§a báº¡n.</p>
                <div style="overflow-x: auto;">
                    <table class="booking-list-table">
                        <thead>
                            <tr>
                                <th>MÃ£ Ä‘Æ¡n</th>
                                <th>Loáº¡i yÃªu cáº§u</th>
                                <th>Chi tiáº¿t yÃªu cáº§u</th>
                                <th>Phá»¥ phÃ­ dá»± kiáº¿n</th>
                                <th>NgÃ y gá»­i</th>
                                <th>Tráº¡ng thÃ¡i</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="r" items="${myRequests}">
                                <tr>
                                    <td style="font-weight: 700;">#${r.bookingId}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.extension}">
                                                <span class="req-type-pill extension">Gia háº¡n lÆ°u trÃº</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="req-type-pill change">Thay Ä‘á»•i Ä‘áº·t phÃ²ng</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="font-size: 13px;">
                                        <c:choose>
                                            <c:when test="${r.extension}">
                                                Tráº£ phÃ²ng má»›i:
                                                <strong><fmt:formatDate value="${r.newCheckOut}" pattern="dd/MM/yyyy" /></strong>
                                                <br/>
                                                <small style="color: var(--text-muted);">
                                                    (Hiá»‡n táº¡i: <fmt:formatDate value="${r.oldCheckOut}" pattern="dd/MM/yyyy" />)
                                                </small>
                                            </c:when>
                                            <c:otherwise>
                                                <strong><fmt:formatDate value="${r.newCheckIn}" pattern="dd/MM/yyyy" /> -
                                                    <fmt:formatDate value="${r.newCheckOut}" pattern="dd/MM/yyyy" /></strong>
                                                <br/>
                                                <small style="color: var(--text-muted);">
                                                    ${r.newRoomTypeName} Â· ${r.newRoomQuantity} phÃ²ng
                                                </small>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="font-weight: 600; color: var(--gold-price);">
                                        <c:choose>
                                            <c:when test="${r.additionalCharge != null && r.additionalCharge > 0}">
                                                <fmt:formatNumber value="${r.additionalCharge}" type="number" /> VND
                                            </c:when>
                                            <c:otherwise><span style="color: var(--text-muted);">â€”</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><fmt:formatDate value="${r.createdAt}" pattern="dd/MM/yyyy" /></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.status eq 'Approved'}">
                                                <span class="req-status-pill approved">ÄÃ£ duyá»‡t</span>
                                            </c:when>
                                            <c:when test="${r.status eq 'Rejected'}">
                                                <span class="req-status-pill rejected">Tá»« chá»‘i</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="req-status-pill pending">Chá» duyá»‡t</span>
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
        });

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

        // ===== Chooser: hiá»ƒn thá»‹ form theo loáº¡i yÃªu cáº§u Ä‘Æ°á»£c chá»n =====
        function showRequestSection(type) {
            const isChange = type === 'change';

            if (isChange) {
                const sel = document.getElementById('changeBookingSelect');
                if (sel.options.length <= 1) {
                    alert('Báº¡n khÃ´ng cÃ³ Ä‘Æ¡n Ä‘áº·t phÃ²ng nÃ o Ä‘á»§ Ä‘iá»u kiá»‡n Ä‘á»ƒ yÃªu cáº§u thay Ä‘á»•i (cáº§n á»Ÿ tráº¡ng thÃ¡i Chá» duyá»‡t hoáº·c ÄÃ£ xÃ¡c nháº­n).');
                    return;
                }
                const minIn = todayISO();
                document.getElementById('changeNewIn').min = minIn;
                document.getElementById('changeNewOut').min = minIn;
            } else {
                const sel = document.getElementById('extBookingSelect');
                if (sel.options.length <= 1) {
                    alert('Báº¡n khÃ´ng cÃ³ phÃ²ng nÃ o Ä‘ang lÆ°u trÃº (ÄÃ£ nháº­n phÃ²ng) Ä‘á»ƒ gia háº¡n.');
                    return;
                }
            }

            document.getElementById('changeSection').style.display = isChange ? 'block' : 'none';
            document.getElementById('extSection').style.display = isChange ? 'none' : 'block';
            document.getElementById('chooseChangeCard').classList.toggle('active', isChange);
            document.getElementById('chooseExtCard').classList.toggle('active', !isChange);

            const section = document.getElementById(isChange ? 'changeSection' : 'extSection');
            section.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }

        function onChangeBookingSelect() {
            const opt = document.getElementById('changeBookingSelect').selectedOptions[0];
            const panel = document.getElementById('changeCurrent');
            if (!opt || !opt.value) { panel.classList.remove('show'); return; }
            document.getElementById('curChangeType').textContent = opt.dataset.roomtype || 'â€”';
            document.getElementById('curChangeQty').textContent = opt.dataset.qty || 'â€”';
            document.getElementById('curChangeIn').textContent = opt.dataset.checkin || 'â€”';
            document.getElementById('curChangeOut').textContent = opt.dataset.checkout || 'â€”';
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
                alert('Vui lÃ²ng Ä‘iá»n Ä‘áº§y Ä‘á»§ cÃ¡c trÆ°á»ng báº¯t buá»™c.');
                return false;
            }
            if (nightsBetween(ci, co) < 1) {
                alert('NgÃ y tráº£ phÃ²ng pháº£i sau ngÃ y nháº­n phÃ²ng.');
                return false;
            }
            if (ci < todayISO()) {
                alert('NgÃ y nháº­n phÃ²ng má»›i khÃ´ng Ä‘Æ°á»£c á»Ÿ trong quÃ¡ khá»©.');
                return false;
            }
            return true;
        }

        function onExtBookingSelect() {
            const opt = document.getElementById('extBookingSelect').selectedOptions[0];
            const panel = document.getElementById('extCurrent');
            if (!opt || !opt.value) { panel.classList.remove('show'); return; }
            document.getElementById('curExtType').textContent = opt.dataset.roomtype || 'â€”';
            document.getElementById('curExtQty').textContent = opt.dataset.qty || 'â€”';
            document.getElementById('curExtOut').textContent = opt.dataset.checkout || 'â€”';
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
                alert('Vui lÃ²ng chá»n phÃ²ng vÃ  ngÃ y tráº£ phÃ²ng má»›i.');
                return false;
            }
            if (nightsBetween(opt.dataset.checkout, newOut) < 1) {
                alert('NgÃ y tráº£ phÃ²ng má»›i pháº£i muá»™n hÆ¡n ngÃ y tráº£ phÃ²ng hiá»‡n táº¡i.');
                return false;
            }
            return true;
        }
    </script>
</body>
</html>
