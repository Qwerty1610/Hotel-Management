<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ include file="../../includes/taglibs.jsp" %>
        <%@ include file="../../includes/header.jsp" %>

            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer_booking.css?v=21" />
            <fmt:setLocale value="vi_VN" />

            <style>
                .service-item-card {
                    transition: all 0.25s ease;
                }

                .service-item-card:hover {
                    border-color: var(--brand-blue) !important;
                    background: #ffffff !important;
                    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.05);
                    transform: translateY(-2px);
                }

                .sidebar-menu a {
                    display: flex;
                    align-items: center;
                    gap: 12px;
                    padding: 12px 16px;
                    border-radius: 8px;
                    color: #475569;
                    font-weight: 600;
                    text-decoration: none;
                    font-size: 14.5px;
                    transition: all 0.2s;
                }

                .sidebar-menu a:hover {
                    background-color: #f1f5f9 !important;
                    color: var(--brand-blue) !important;
                }

                .sidebar-menu a.active-sidebar-item {
                    color: var(--brand-blue) !important;
                    background-color: var(--brand-blue-light) !important;
                    font-weight: 700;
                }

                .sidebar-menu a.active-sidebar-item:hover {
                    background-color: var(--brand-blue-light) !important;
                    color: var(--brand-blue) !important;
                }

                .table-pagination-bar {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin-top: 30px;
                    padding-top: 20px;
                    border-top: 1px solid #e2e8f0;
                }

                .pagination-info {
                    font-size: 14px;
                    color: var(--text-muted);
                    font-weight: 500;
                }

                .pagination-controls {
                    display: flex;
                    gap: 8px;
                }

                .btn-page {
                    min-width: 36px;
                    height: 36px;
                    padding: 0 10px;
                    border: 1px solid #e2e8f0;
                    border-radius: 8px;
                    background: #ffffff;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 14px;
                    font-weight: 600;
                    color: #475569;
                    cursor: pointer;
                    transition: all 0.2s ease;
                    text-decoration: none;
                    box-sizing: border-box;
                }

                .btn-page:hover {
                    background-color: #f1f5f9;
                    border-color: #cbd5e1;
                    color: var(--brand-blue);
                }

                .btn-page.active {
                    background-color: var(--brand-blue);
                    border-color: var(--brand-blue);
                    color: #ffffff;
                }

                .btn-page.disabled {
                    opacity: 0.5;
                    cursor: not-allowed;
                    pointer-events: none;
                }
            </style>

            <body>

                <%-- Header Navigation --%>
                    <nav class="navbar-rooms">
<a href="${pageContext.request.contextPath}/" class="logo">${not empty hotelName ? hotelName : 'HotelOps'}</a>
                        <ul class="nav-links">
                            <li><a href="${pageContext.request.contextPath}/">Trang chá»§</a></li>
                            <li><a href="${pageContext.request.contextPath}/rooms">PhÃ²ng</a></li>
                            <li><a href="${pageContext.request.contextPath}/customer/bookings">Äáº·t phÃ²ng cá»§a tÃ´i</a></li>
                            <li><a href="${pageContext.request.contextPath}/customer/feedbacks">ÄÃ¡nh giÃ¡ lÆ°u trÃº</a></li>
                            <li><a href="${pageContext.request.contextPath}/customer/services" class="active">Dá»‹ch vá»¥</a></li>
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
                        <%-- Top Alerts --%>
                            <c:if test="${not empty successMessage}">
                                <div class="success-banner" id="serverSuccessMessage">
                                    <i class="fa-solid fa-circle-check" style="font-size: 20px;"></i>
                                    <div>
                                        <strong>ThÃ nh cÃ´ng:</strong> ${successMessage}
                                    </div>
                                </div>
                            </c:if>
                            <c:if test="${not empty errorMessage}">
                                <div class="error-banner" id="serverValidationError">
                                    <i class="fa-solid fa-circle-exclamation" style="font-size: 20px;"></i>
                                    <div>
                                        <strong>Lá»—i:</strong> ${errorMessage}
                                    </div>
                                </div>
                            </c:if>

                            <div style="display: flex; gap: 30px; align-items: start; margin-top: 20px;">
                                <!-- Left Sidebar Navigation -->
                                <div class="sidebar-menu"
                                    style="width: 260px; flex-shrink: 0; background: #ffffff; border-radius: 20px; border: 1px solid #e2e8f0; padding: 24px; box-shadow: 0 4px 20px rgba(0,0,0,0.04);">
                                    <h3
                                        style="font-size: 11px; font-weight: 700; color: #94a3b8; text-transform: uppercase; letter-spacing: 1px; margin-top: 0; margin-bottom: 20px;">
                                        Dá»‹ch vá»¥</h3>
                                    <ul
                                        style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 8px;">
                                        <li>
                                            <a href="${pageContext.request.contextPath}/customer/services"
                                                class="active-sidebar-item">
                                                <i class="fa-solid fa-bell-concierge"
                                                    style="width: 20px; text-align: center;"></i> YÃªu cáº§u dá»‹ch vá»¥
                                            </a>
                                        </li>
                                        <li>
                                            <a href="${pageContext.request.contextPath}/customer/services/history">
                                                <i class="fa-solid fa-clock-rotate-left"
                                                    style="width: 20px; text-align: center;"></i> Lá»‹ch sá»­ yÃªu cáº§u
                                            </a>
                                        </li>
                                    </ul>
                                </div>

                                <!-- Right Content Area -->
                                <div style="flex-grow: 1; display: flex; flex-direction: column; gap: 30px;">

                                    <!-- Táº¡o yÃªu cáº§u má»›i -->
                                    <div class="booking-card" style="padding: 30px; margin-bottom: 0;">
                                        <h2
                                            style="font-size: 20px; font-weight: 800; color: var(--text-navy); margin-top: 0; margin-bottom: 24px; display: flex; align-items: center; gap: 10px;">
                                            <i class="fa-solid fa-circle-plus"
                                                style="color: var(--brand-blue); font-size: 22px;"></i> Táº¡o yÃªu cáº§u má»›i
                                        </h2>

                                        <c:choose>
                                            <c:when test="${empty bookings}">
                                                <div
                                                    style="padding: 20px; text-align: center; background-color: #f8fafc; border-radius: 12px; color: var(--text-muted); font-size: 14.5px;">
                                                    <i class="fa-solid fa-hotel"
                                                        style="font-size: 32px; display: block; margin-bottom: 12px; color: #cbd5e1;"></i>
                                                     Báº¡n cáº§n Ä‘Ã£ nháº­n phÃ²ng (Check-in) Ä‘á»ƒ cÃ³ thá»ƒ gá»­i yÃªu cáº§u dá»‹ch vá»¥.
                                                    Vui lÃ²ng liÃªn há»‡ lá»… tÃ¢n Ä‘á»ƒ nháº­n phÃ²ng trÆ°á»›c.
                                                </div>
                                            </c:when>
                                            <c:when test="${empty allActiveServices}">
                                                <div
                                                    style="padding: 20px; text-align: center; background-color: #f8fafc; border-radius: 12px; color: var(--text-muted); font-size: 14.5px;">
                                                    <i class="fa-solid fa-bell-slash"
                                                        style="font-size: 32px; display: block; margin-bottom: 12px; color: #cbd5e1;"></i>
                                                    Hiá»‡n táº¡i khÃ´ng cÃ³ dá»‹ch vá»¥ nÃ o kháº£ dá»¥ng Ä‘á»ƒ táº¡o yÃªu cáº§u má»›i.
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <form action="${pageContext.request.contextPath}/customer/services"
                                                    method="POST">
                                                    <div class="form-grid"
                                                        style="grid-template-columns: 1fr 1fr; gap: 24px;">
                                                        <div class="form-group">
                                                            <label for="bookingId">Äáº·t phÃ²ng</label>
                                                            <select name="bookingId" id="bookingId" required>
                                                                <option value="">-- Chá»n phÃ²ng --</option>
                                                                <c:forEach var="b" items="${bookings}">
                                                                    <option value="${b.bookingId}">
                                                                        <c:choose>
                                                                            <c:when test="${not empty b.assignedRoomsStr}">
                                                                                PhÃ²ng ${b.assignedRoomsStr}
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                PhÃ²ng #${b.bookingId} (${b.roomTypeName})
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </option>
                                                                </c:forEach>
                                                            </select>
                                                        </div>
                                                        <div class="form-group">
                                                            <label for="serviceName">Loáº¡i dá»‹ch vá»¥</label>
                                                            <select name="serviceName" id="serviceName" required>
                                                                <option value="" data-price="0" data-unit="">-- Chá»n dá»‹ch vá»¥ --</option>
                                                                <c:forEach var="s" items="${allActiveServices}">
                                                                    <option value="${s.serviceName}" data-price="${s.price}" data-unit="${s.unit}">
                                                                        ${s.serviceName}
                                                                    </option>
                                                                </c:forEach>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="form-grid"
                                                        style="grid-template-columns: 1fr 1fr; gap: 24px; margin-top: 24px;">
                                                        <div class="form-group">
                                                            <label for="quantity">Sá»‘ lÆ°á»£ng</label>
                                                            <input type="number" name="quantity" id="quantity" min="1" max="99" value="1" required />
                                                        </div>
                                                        <div class="form-group" style="display: flex; flex-direction: column; justify-content: center; gap: 4px;">
                                                            <div id="servicePriceDisplay" style="font-size: 14.5px; font-weight: 600; color: #475569;">
                                                                ÄÆ¡n giÃ¡: <span id="unitPrice" style="color: var(--text-navy);">0</span> VND <span id="unitName"></span>
                                                            </div>
                                                            <div id="serviceEstimatedDisplay" style="font-size: 16px; font-weight: 700; color: var(--brand-blue);">
                                                                Táº¡m tÃ­nh: <span id="estimatedAmount">0</span> VND
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="form-group" style="margin-top: 24px;">
                                                        <label for="notes">Ghi chÃº yÃªu cáº§u</label>
                                                        <textarea name="notes" id="notes" maxlength="500" placeholder="VÃ­ dá»¥: Giáº·t 2kg quáº§n Ã¡o, dÃ¹ng gym 2 ngÃ y..." style="min-height: 100px; resize: vertical;"></textarea>
                                                    </div>
                                                    <div
                                                        style="display: flex; justify-content: flex-end; margin-top: 24px;">
                                                        <button type="submit" class="btn-primary"
                                                            style="margin-top: 0; width: auto; padding: 12px 30px; font-weight: 700; font-size: 15px; display: flex; align-items: center; gap: 8px;">
                                                            <i class="fa-solid fa-paper-plane"></i> Gá»­i yÃªu cáº§u
                                                        </button>
                                                    </div>
                                                </form>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <!-- Danh sÃ¡ch dá»‹ch vá»¥ khÃ¡ch sáº¡n -->
                                    <div class="booking-card" style="padding: 30px; margin-bottom: 0;">
                                        <h2
                                            style="font-size: 20px; font-weight: 800; color: var(--text-navy); margin-top: 0; margin-bottom: 24px;">
                                            Danh sÃ¡ch dá»‹ch vá»¥ khÃ¡ch sáº¡n
                                        </h2>

                                        <c:choose>
                                            <c:when test="${not empty services}">
                                                <div
                                                    style="display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 24px;">
                                                    <c:forEach var="s" items="${services}">
                                                        <div class="service-item-card"
                                                            style="display: flex; flex-direction: column; justify-content: space-between; padding: 24px; background: #ffffff; border-radius: 16px; border: 1px solid #e2e8f0; box-shadow: 0 2px 10px rgba(0,0,0,0.02);">
                                                            <div>
                                                                <h3
                                                                    style="margin: 0; font-size: 16px; font-weight: 700; color: var(--text-navy);">
                                                                    ${s.serviceName}</h3>
                                                                <p
                                                                    style="margin: 8px 0; font-size: 13.5px; color: var(--text-muted); line-height: 1.5; text-align: justify;">
                                                                    ${s.description}</p>
                                                            </div>
                                                            <div style="margin-top: 12px;">
                                                                <span
                                                                    style="font-size: 14.5px; font-weight: 800; color: var(--brand-blue);">
                                                                    <fmt:formatNumber value="${s.price}" type="currency"
                                                                        currencySymbol="" /> VND<span
                                                                        style="font-weight: 500; font-size: 12px; color: var(--text-muted);">${s.unit}</span>
                                                                </span>
                                                            </div>
                                                        </div>
                                                    </c:forEach>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div
                                                    style="padding: 40px; text-align: center; background-color: #f8fafc; border-radius: 16px; color: var(--text-muted); font-size: 14.5px; border: 1px dashed #cbd5e1;">
                                                    <i class="fa-solid fa-bell-slash"
                                                        style="font-size: 40px; display: block; margin-bottom: 15px; color: #cbd5e1;"></i>
                                                    Hiá»‡n táº¡i khÃ´ng cÃ³ dá»‹ch vá»¥ nÃ o kháº£ dá»¥ng.
                                                </div>
                                            </c:otherwise>
                                        </c:choose>

                                        <!-- PHÃ‚N TRANG -->
                                        <c:if test="${totalPages > 1}">
                                            <div class="table-pagination-bar">
                                                <div class="pagination-info">
                                                    Hiá»ƒn thá»‹ ${(currentPage-1)*pageSize + 1}-${currentPage*pageSize gt totalItems ? totalItems : currentPage*pageSize} trong sá»‘ ${totalItems} dá»‹ch vá»¥
                                                </div>
                                                <div class="pagination-controls">
                                                    <c:choose>
                                                        <c:when test="${currentPage > 1}">
                                                            <a class="btn-page" href="?page=${currentPage-1}"><i class="fa-solid fa-chevron-left"></i></a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="btn-page disabled"><i class="fa-solid fa-chevron-left"></i></span>
                                                        </c:otherwise>
                                                    </c:choose>

                                                    <c:forEach var="p" begin="1" end="${totalPages}">
                                                        <a class="btn-page ${p == currentPage ? 'active' : ''}" href="?page=${p}">${p}</a>
                                                    </c:forEach>

                                                    <c:choose>
                                                        <c:when test="${currentPage < totalPages}">
                                                            <a class="btn-page" href="?page=${currentPage+1}"><i class="fa-solid fa-chevron-right"></i></a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="btn-page disabled"><i class="fa-solid fa-chevron-right"></i></span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                        </c:if>
                                    </div>

                                </div>
                            </div>
                    </div>

                    <%-- Footer --%>
                        <footer class="footer-white" id="lien-he" style="margin-top: 80px;">
                            <div class="footer-white-grid">
                                <div class="footer-white-about">
                                    <h3>HotelOps Pro</h3>
                                    <p>Há»‡ thá»‘ng quáº£n lÃ½ vÃ  nghá»‰ dÆ°á»¡ng Ä‘áº³ng cáº¥p quá»‘c táº¿, Ä‘em láº¡i tráº£i nghiá»‡m sang trá»ng
                                        vÆ°á»£t thá»i gian.</p>
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

                                const bookingSelect = document.getElementById('bookingId');
                                const serviceSelect = document.getElementById('serviceName');
                                const quantityInput = document.getElementById('quantity');
                                const unitPriceSpan = document.getElementById('unitPrice');
                                const unitNameSpan = document.getElementById('unitName');
                                const estimatedAmountSpan = document.getElementById('estimatedAmount');

                                function formatCurrency(number) {
                                    return new Intl.NumberFormat('vi-VN').format(number);
                                }

                                function updateEstimation() {
                                    if (!serviceSelect || !quantityInput) return;
                                    const selectedOption = serviceSelect.options[serviceSelect.selectedIndex];
                                    if (!selectedOption || !selectedOption.value) {
                                        unitPriceSpan.textContent = "0";
                                        unitNameSpan.textContent = "";
                                        estimatedAmountSpan.textContent = "0";
                                        return;
                                    }
                                    
                                    const price = parseFloat(selectedOption.getAttribute('data-price')) || 0;
                                    const unit = selectedOption.getAttribute('data-unit') || '';
                                    
                                    let quantity = parseInt(quantityInput.value);
                                    if (isNaN(quantity) || quantity < 1) {
                                        quantity = 0;
                                    }
                                    
                                    unitPriceSpan.textContent = formatCurrency(price);
                                    unitNameSpan.textContent = unit ? "/ " + unit : "";
                                    estimatedAmountSpan.textContent = formatCurrency(price * quantity);
                                }

                                if (bookingSelect) {
                                    bookingSelect.addEventListener('invalid', function() {
                                        if (this.validity.valueMissing) {
                                            this.setCustomValidity('Vui lÃ²ng chá»n phÃ²ng trong danh sÃ¡ch.');
                                        }
                                    });
                                    bookingSelect.addEventListener('change', function() {
                                        this.setCustomValidity('');
                                    });
                                }

                                if (serviceSelect) {
                                    serviceSelect.addEventListener('invalid', function() {
                                        if (this.validity.valueMissing) {
                                            this.setCustomValidity('Vui lÃ²ng chá»n má»™t má»¥c trong danh sÃ¡ch.');
                                        }
                                    });
                                    serviceSelect.addEventListener('change', function() {
                                        this.setCustomValidity('');
                                        updateEstimation();
                                    });
                                }

                                if (quantityInput) {
                                    quantityInput.addEventListener('invalid', function() {
                                        if (this.validity.valueMissing) {
                                            this.setCustomValidity('Vui lÃ²ng nháº­p sá»‘ lÆ°á»£ng.');
                                        } else if (this.validity.rangeUnderflow) {
                                            this.setCustomValidity('GiÃ¡ trá»‹ pháº£i lá»›n hÆ¡n hoáº·c báº±ng 1.');
                                        } else if (this.validity.rangeOverflow) {
                                            this.setCustomValidity('GiÃ¡ trá»‹ pháº£i nhá» hÆ¡n hoáº·c báº±ng 99.');
                                        } else if (this.validity.badInput) {
                                            this.setCustomValidity('Vui lÃ²ng nháº­p má»™t sá»‘ há»£p lá»‡.');
                                        }
                                    });
                                    quantityInput.addEventListener('input', function() {
                                        this.setCustomValidity('');
                                        updateEstimation();
                                    });
                                    quantityInput.addEventListener('change', updateEstimation);
                                }

                                updateEstimation();
                            });
                        </script>
            </body>

            </html>