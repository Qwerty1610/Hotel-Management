<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer_booking.css?v=22" />
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
            <h1>Táº¡o Äáº·t PhÃ²ng Má»›i</h1>
            <p>Tráº£i nghiá»‡m ká»³ nghá»‰ hoÃ n háº£o táº¡i há»‡ thá»‘ng khÃ¡ch sáº¡n cao cáº¥p HotelOps Pro</p>
        </div>

        <%-- Error Alert --%>
        <c:if test="${not empty errorCode}">
            <div class="error-banner" id="serverValidationError">
                <i class="fa-solid fa-circle-exclamation" style="font-size: 20px;"></i>
                <div>
                    <strong>Lá»—i Ä‘áº·t phÃ²ng:</strong> ${errorMessage}
                </div>
            </div>
        </c:if>

        <%-- Client Validation Alert --%>
        <div class="error-banner" id="clientValidationError" style="display: none;">
            <i class="fa-solid fa-circle-exclamation" style="font-size: 20px;"></i>
            <div id="validationErrorMessage">
                <strong>Cáº£nh bÃ¡o:</strong> Sá»‘ lÆ°á»£ng khÃ¡ch vÆ°á»£t quÃ¡ sá»©c chá»©a tá»‘i Ä‘a cá»§a phÃ²ng Ä‘Ã£ chá»n!
            </div>
        </div>

        <form action="${pageContext.request.contextPath}/customer/booking/create" method="POST" id="bookingForm">
            <div class="wizard-layout">
                
                <%-- Main Form Left Card --%>
                <div class="booking-main">
                    <div class="booking-card">
                        
                        <%-- 1. Selection Mode --%>
                        <div class="booking-section">
                            <h2 style="font-size: 18px; margin-top: 0; color: var(--primary-dark); margin-bottom: 20px;">
                                <i class="fa-solid fa-bed" style="color: var(--accent-gold); margin-right: 8px;"></i>
                                HÃ¬nh thá»©c Ä‘áº·t phÃ²ng
                            </h2>
                            
                            <div class="type-selector">
                                <div class="type-card ${bookingType eq 'multi' ? '' : 'active'}" id="typeSingleCard" onclick="switchBookingType('single')">
                                    <input type="radio" name="bookingType" id="typeSingle" value="single" ${bookingType eq 'multi' ? '' : 'checked'} />
                                    <h3>Äáº·t phÃ²ng Ä‘Æ¡n</h3>
                                    <p>Äáº·t 1 loáº¡i phÃ²ng phÃ¹ há»£p vá»›i sá»‘ lÆ°á»£ng khÃ¡ch tiÃªu chuáº©n.</p>
                                </div>
                                <div class="type-card ${bookingType eq 'multi' ? 'active' : ''}" id="typeMultiCard" onclick="switchBookingType('multi')">
                                    <input type="radio" name="bookingType" id="typeMulti" value="multi" ${bookingType eq 'multi' ? 'checked' : ''} />
                                    <h3>Äáº·t nhiá»u phÃ²ng (Multi-room)</h3>
                                    <p>ÄÄƒng kÃ½ nhiá»u phÃ²ng khÃ¡c nhau trong cÃ¹ng má»™t Ä‘Æ¡n Ä‘áº·t phÃ²ng vÃ  phÃ¢n chia danh sÃ¡ch khÃ¡ch Ä‘i cÃ¹ng.</p>
                                </div>
                            </div>
                        </div>

                        <%-- 2. General Stay Information --%>
                        <div class="booking-section">
                            <h2 style="font-size: 18px; margin-top: 0; color: var(--primary-dark); margin-bottom: 20px;">
                                <i class="fa-solid fa-calendar-days" style="color: var(--accent-gold); margin-right: 8px;"></i>
                                ThÃ´ng tin thá»i gian & LiÃªn há»‡
                            </h2>
                            
                            <div class="form-grid">
                                <div class="form-group">
                                    <label for="customerName">Há» tÃªn ngÆ°á»i Ä‘áº·t *</label>
                                    <input type="text" name="customerName" id="customerName" required placeholder="Nháº­p há» tÃªn Ä‘áº§y Ä‘á»§"
                                           value="${not empty customerName ? customerName : sessionScope.user}" />
                                </div>
                                <div class="form-group">
                                    <label for="phone">Sá»‘ Ä‘iá»‡n thoáº¡i *</label>
                                    <input type="tel" name="phone" id="phone" required placeholder="Nháº­p sá»‘ Ä‘iá»‡n thoáº¡i"
                                           value="${phone}" />
                                </div>
                                <div class="form-group">
                                    <label for="email">Email *</label>
                                    <input type="email" name="email" id="email" required placeholder="Nháº­p email liÃªn há»‡"
                                           value="${email}" />
                                </div>
                                <div class="form-group">
                                    <label for="checkInDate">NgÃ y nháº­n phÃ²ng *</label>
                                    <input type="date" name="checkInDate" id="checkInDate" required value="${checkInDate}" onchange="calculatePricing()" min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>" />
                                </div>
                                <div class="form-group">
                                    <label for="checkOutDate">NgÃ y tráº£ phÃ²ng *</label>
                                    <input type="date" name="checkOutDate" id="checkOutDate" required value="${checkOutDate}" onchange="calculatePricing()" />
                                </div>
                            </div>
                        </div>

                        <%-- 3. Room & Guests Selection --%>
                        <div class="booking-section" id="roomSelectionSection">
                            
                            <%-- Single Room Selection Form --%>
                            <div id="singleRoomFields" style="display: ${bookingType eq 'multi' ? 'none' : 'block'};">
                                <h2 style="font-size: 18px; margin-top: 0; color: var(--primary-dark); margin-bottom: 20px;">
                                    <i class="fa-solid fa-circle-info" style="color: var(--accent-gold); margin-right: 8px;"></i>
                                    Chá»n loáº¡i phÃ²ng & KhÃ¡ch nghá»‰
                                </h2>
                                <div class="single-room-grid">
                                    <div class="form-group">
                                        <label for="roomTypeId">Loáº¡i phÃ²ng</label>
                                        <select name="roomTypeId" id="roomTypeId" onchange="calculatePricing(); validateForm()">
                                            <c:forEach var="rt" items="${roomTypes}">
                                                <option value="${rt.typeId}" data-price="${rt.basePrice}" data-capacity="${rt.capacity}"
                                                        <c:if test="${not empty selectedRoomTypeId and selectedRoomTypeId eq rt.typeId}">selected</c:if>>
                                                    ${rt.typeName} - <fmt:formatNumber value="${rt.basePrice}" type="number" pattern="#,##0" /> VND / Ä‘Ãªm (Tá»‘i Ä‘a ${rt.capacity} khÃ¡ch)
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="form-group">
                                        <label for="roomQuantity">Sá»‘ lÆ°á»£ng phÃ²ng</label>
                                        <input type="number" name="roomQuantity" id="roomQuantity" min="1" max="10" value="1" required oninput="calculatePricing(); validateForm()" />
                                    </div>
                                    <div class="form-group">
                                        <label for="guestCount">LÆ°á»£ng ngÆ°á»i á»Ÿ *</label>
                                        <input type="number" name="guestCount" id="guestCount" min="1" value="1" required oninput="validateForm()" />
                                    </div>
                                </div>
                            </div>

                            <%-- Multi Room Selection Form --%>
                            <div id="multiRoomFields" style="display: ${bookingType eq 'multi' ? 'block' : 'none'};">
                                <div class="room-selection-header" style="margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center;">
                                    <h2 style="font-size: 18px; margin-top: 0; margin-bottom: 0; color: var(--primary-dark); border-bottom: none; padding-bottom: 0;">
                                        <i class="fa-solid fa-circle-info" style="color: var(--accent-gold); margin-right: 8px;"></i>
                                        Danh sÃ¡ch phÃ²ng chá»n Ä‘áº·t
                                    </h2>
                                    <button type="button" class="btn-secondary" onclick="addRoomRow()">
                                        <i class="fa-solid fa-plus"></i> ThÃªm phÃ²ng
                                    </button>
                                </div>
                                
                                <div id="multiRoomRowsContainer">
                                    <%-- Rows added dynamically by JS --%>
                                </div>
                            </div>
                        </div>

                        <%-- 4. Special Request / Note --%>
                        <div class="booking-section" style="border-bottom: none; margin-bottom: 0; padding-bottom: 0;">
                            <h2 style="font-size: 18px; margin-top: 0; color: var(--primary-dark); margin-bottom: 20px;">
                                <i class="fa-solid fa-comment-dots" style="color: var(--accent-gold); margin-right: 8px;"></i>
                                YÃªu cáº§u Ä‘áº·c biá»‡t (TÃ¹y chá»n)
                            </h2>
                            
                            <div class="form-group form-group-full">
                                <label for="note">Ná»™i dung ghi chÃº / yÃªu cáº§u</label>
                                <textarea name="note" id="note" rows="4" placeholder="Nháº­p cÃ¡c yÃªu cáº§u Ä‘áº·c biá»‡t cá»§a báº¡n (vÃ­ dá»¥: phÃ²ng táº§ng cao, giÆ°á»ng phá»¥, yÃªn tÄ©nh...)">${note}</textarea>
                            </div>
                        </div>
                        
                    </div>
                </div>

                <%-- Sticky Right Column Summary --%>
                <div class="booking-sidebar">
                    <div class="receipt-card">
                        <h3>TÃ³m táº¯t Ä‘áº·t phÃ²ng</h3>
                        
                        <div class="receipt-row">
                            <span>Sá»‘ Ä‘Ãªm nghá»‰:</span>
                            <span id="summaryNights">--</span>
                        </div>
                        <div class="receipt-row">
                            <span>Tá»•ng tiá»n phÃ²ng:</span>
                            <span id="summarySubtotal">0 VND</span>
                        </div>
                        <div class="receipt-row" id="discountRow" style="display: none; color: #e74c3c;">
                            <span>Giáº£m giÃ¡:</span>
                            <span id="summaryDiscount">-0 VND</span>
                        </div>
                        
                        <div class="receipt-row total">
                            <span>Tá»”NG Cá»˜NG:</span>
                            <span id="summaryGrandTotal" class="grand-total-amount">0 VND</span>
                        </div>
                        
                        <div class="receipt-row deposit" style="margin-top: 15px;">
                            <span class="deposit-label">Tiá»n Ä‘áº·t cá»c (30%):</span>
                            <span id="summaryDeposit" class="deposit-amount">0 VND</span>
                        </div>

                        <div class="promo-code-section" style="margin-top: 20px; border-top: 1px dashed var(--border-color); padding-top: 15px; margin-bottom: 20px;">
                            <label for="promoCode" style="font-size: 14px; font-weight: 600; color: var(--primary-dark); display: block; margin-bottom: 8px;">
                                <i class="fa-solid fa-ticket" style="color: var(--accent-gold); margin-right: 5px;"></i>MÃ£ giáº£m giÃ¡
                            </label>
                            <div style="display: flex; gap: 8px;">
                                <input type="text" id="promoCode" name="promotionCode" placeholder="Nháº­p mÃ£ (náº¿u cÃ³)" style="flex: 1; padding: 10px 12px; border: 1px solid var(--border-color); border-radius: var(--radius-sm); font-size: 14px; text-transform: uppercase; outline: none;">
                                <button type="button" class="btn-secondary" style="padding: 10px 15px; font-size: 14px; margin: 0; white-space: nowrap; border-radius: var(--radius-sm); background-color: var(--brand-blue); color: white; border: none; box-shadow: none;" onclick="applyPromotionCode()">Ãp dá»¥ng</button>
                            </div>
                            <div id="promoMessage" style="font-size: 13px; margin-top: 8px; display: none;"></div>
                        </div>

                        <button type="submit" class="btn-primary" id="submitBtn">
                            <i class="fa-solid fa-credit-card"></i> Tiáº¿n hÃ nh Ä‘áº·t phÃ²ng
                        </button>
                        <a href="${pageContext.request.contextPath}/rooms" class="btn-secondary" style="margin-top: 10px; display: block; text-align: center; text-decoration: none; padding: 12px; border-radius: var(--radius-md);">
                            Há»§y Ä‘áº·t phÃ²ng
                        </a>
                    </div>
                </div>

            </div>
        </form>
    </div>

    <%-- Footer --%>
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
        window.addEventListener('DOMContentLoaded', (event) => {
            const checkInInput = document.getElementById('checkInDate');
            const checkOutInput = document.getElementById('checkOutDate');

            if (!checkInInput.value) {
                checkInInput.value = checkInInput.min;
            }
            if (!checkOutInput.value) {
                const tomorrow = new Date();
                tomorrow.setDate(tomorrow.getDate() + 1);
                const tYear = tomorrow.getFullYear();
                const tMonth = String(tomorrow.getMonth() + 1).padStart(2, '0');
                const tDay = String(tomorrow.getDate()).padStart(2, '0');
                checkOutInput.value = `${tYear}-${tMonth}-${tDay}`;
            }

            // If we are in multi mode initially, initialize rows
            const initialType = document.querySelector('input[name="bookingType"]:checked').value;
            if (initialType === 'multi') {
                <c:choose>
                    <c:when test="${not empty paramValues['roomTypeId[]']}">
                        <c:forEach var="rtId" items="${paramValues['roomTypeId[]']}" varStatus="status">
                            addRoomRow('${rtId}', '${paramValues["roomQuantity[]"][status.index]}', '${paramValues["guestCount[]"][status.index]}');
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        addRoomRow(); // add at least one row
                    </c:otherwise>
                </c:choose>
            }

            calculatePricing();
            validateForm(); // Run initial validation

            // Hide server error after 5s
            const serverError = document.getElementById('serverValidationError');
            if (serverError) {
                setTimeout(() => {
                    serverError.style.display = 'none';
                }, 5000);
            }
        });

        function switchBookingType(type) {
            const singleCard = document.getElementById('typeSingleCard');
            const multiCard = document.getElementById('typeMultiCard');
            const singleRadio = document.getElementById('typeSingle');
            const multiRadio = document.getElementById('typeMulti');
            const singleFields = document.getElementById('singleRoomFields');
            const multiFields = document.getElementById('multiRoomFields');

            if (type === 'single') {
                singleCard.classList.add('active');
                multiCard.classList.remove('active');
                singleRadio.checked = true;
                singleFields.style.display = 'block';
                multiFields.style.display = 'none';
                
                // Clear validation requirements on multi rows
                document.querySelectorAll('#multiRoomRowsContainer select, #multiRoomRowsContainer input').forEach(el => {
                    el.removeAttribute('required');
                });
                document.getElementById('guestCount').setAttribute('required', 'required');
            } else {
                multiCard.classList.add('active');
                singleCard.classList.remove('active');
                multiRadio.checked = true;
                singleFields.style.display = 'none';
                multiFields.style.display = 'block';
                
                // Set requirements on multi rows
                document.querySelectorAll('#multiRoomRowsContainer select, #multiRoomRowsContainer input').forEach(el => {
                    el.setAttribute('required', 'required');
                });
                document.getElementById('guestCount').removeAttribute('required');

                // If no rows are added, add one
                const container = document.getElementById('multiRoomRowsContainer');
                if (container.children.length === 0) {
                    addRoomRow();
                }
            }
            calculatePricing();
            validateForm();
        }

        // Add room selection row for multi-room booking
        function addRoomRow(typeId = '', qty = '1', guests = '1') {
            const container = document.getElementById('multiRoomRowsContainer');
            const index = container.children.length;
            
            const row = document.createElement('div');
            row.className = 'room-row';
            row.id = 'roomRow_' + index;

            let optionsHtml = '';
            <c:forEach var="rt" items="${roomTypes}">
                optionsHtml += '<option value="${rt.typeId}" data-price="${rt.basePrice}" data-capacity="${rt.capacity}" ' + (typeId == '${rt.typeId}' ? 'selected' : '') + '>' +
                    '${rt.typeName} - <fmt:formatNumber value="${rt.basePrice}" type="number" pattern="#,##0" /> VND / Ä‘Ãªm (Tá»‘i Ä‘a ${rt.capacity} khÃ¡ch)' +
                '</option>';
            </c:forEach>

            row.innerHTML = 
                '<div class="form-group">' +
                '    <label>Loáº¡i phÃ²ng</label>' +
                '    <select name="roomTypeId[]" required onchange="calculatePricing(); validateForm()">' +
                optionsHtml +
                '    </select>' +
                '</div>' +
                '<div class="form-group">' +
                '    <label>Sá»‘ lÆ°á»£ng</label>' +
                '    <input type="number" name="roomQuantity[]" min="1" max="10" value="' + qty + '" required oninput="calculatePricing(); validateForm()" />' +
                '</div>' +
                '<div class="form-group">' +
                '    <label>LÆ°á»£ng ngÆ°á»i á»Ÿ</label>' +
                '    <input type="number" name="guestCount[]" min="1" value="' + guests + '" required oninput="validateForm()" />' +
                '</div>' +
                '<button type="button" class="btn-danger" style="margin-bottom: 2px;" onclick="removeRoomRow(' + index + ')">' +
                '    <i class="fa-solid fa-trash-can"></i>' +
                '</button>';

            container.appendChild(row);
            calculatePricing();
            validateForm();
        }

        function removeRoomRow(index) {
            const row = document.getElementById('roomRow_' + index);
            if (row) {
                row.remove();
            }
            // Re-index remaining rows to prevent ID conflicts
            const container = document.getElementById('multiRoomRowsContainer');
            Array.from(container.children).forEach((child, i) => {
                child.id = 'roomRow_' + i;
                const deleteBtn = child.querySelector('.btn-danger');
                if (deleteBtn) {
                    deleteBtn.setAttribute('onclick', 'removeRoomRow(' + i + ')');
                }
            });
            calculatePricing();
            validateForm();
        }

        function calculatePricing() {
            const checkInVal = document.getElementById('checkInDate').value;
            const checkOutVal = document.getElementById('checkOutDate').value;
            const nightsSpan = document.getElementById('summaryNights');
            const subtotalSpan = document.getElementById('summarySubtotal');
            const totalSpan = document.getElementById('summaryGrandTotal');
            const depositSpan = document.getElementById('summaryDeposit');

            if (!checkInVal || !checkOutVal) {
                nightsSpan.innerText = '--';
                return;
            }

            const checkIn = new Date(checkInVal);
            const checkOut = new Date(checkOutVal);

            const diffTime = checkOut - checkIn;
            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

            if (diffDays <= 0) {
                nightsSpan.innerText = '0 Ä‘Ãªm';
                subtotalSpan.innerText = '0 VND';
                totalSpan.innerText = '0 VND';
                depositSpan.innerText = '0 VND';
                return;
            }

            nightsSpan.innerText = diffDays + ' Ä‘Ãªm';

            let totalPrice = 0;
            const bookingType = document.querySelector('input[name="bookingType"]:checked').value;

            if (bookingType === 'single') {
                const roomSelect = document.getElementById('roomTypeId');
                const quantitySelect = document.getElementById('roomQuantity');
                
                const selectedOption = roomSelect.options[roomSelect.selectedIndex];
                const price = parseFloat(selectedOption.getAttribute('data-price')) || 0;
                const qty = parseInt(quantitySelect.value) || 1;

                totalPrice = price * qty * diffDays;
            } else {
                const container = document.getElementById('multiRoomRowsContainer');
                const rows = container.querySelectorAll('.room-row');
                
                rows.forEach(row => {
                    const select = row.querySelector('select[name="roomTypeId[]"]');
                    const qtySelect = row.querySelector('input[name="roomQuantity[]"]');
                    if (select && qtySelect) {
                        const selectedOption = select.options[select.selectedIndex];
                        const price = parseFloat(selectedOption.getAttribute('data-price')) || 0;
                        const qty = parseInt(qtySelect.value) || 1;
                        totalPrice += price * qty * diffDays;
                    }
                });
            }

            let unDiscountedTotal = totalPrice;
            if (window.currentDiscountAmount) {
                // Äáº£m báº£o khÃ´ng giáº£m quÃ¡ tá»•ng tiá»n
                if (window.currentDiscountAmount > totalPrice) {
                    window.currentDiscountAmount = totalPrice;
                }
                totalPrice -= window.currentDiscountAmount;
            }

            const deposit = totalPrice * 0.3;

            // Formatter
            const formatter = new Intl.NumberFormat('vi-VN', {
                style: 'currency',
                currency: 'VND'
            });

            subtotalSpan.innerText = formatter.format(unDiscountedTotal);
            totalSpan.innerText = formatter.format(totalPrice);
            depositSpan.innerText = formatter.format(deposit);
            
            if (window.currentDiscountAmount) {
                document.getElementById('discountRow').style.display = 'flex';
                document.getElementById('summaryDiscount').innerText = '-' + formatter.format(window.currentDiscountAmount);
            } else {
                document.getElementById('discountRow').style.display = 'none';
            }
        }

        window.currentDiscountAmount = 0;
        window.appliedPromoCode = "";

        async function applyPromotionCode() {
            const promoInput = document.getElementById('promoCode').value.trim();
            const msgDiv = document.getElementById('promoMessage');
            
            if (!promoInput) {
                msgDiv.style.display = 'block';
                msgDiv.style.color = '#e74c3c';
                msgDiv.innerText = 'Vui lÃ²ng nháº­p mÃ£ giáº£m giÃ¡.';
                return;
            }

            // TÃ­nh tá»•ng tiá»n hiá»‡n táº¡i trÆ°á»›c khi giáº£m
            calculatePricing(); // update subtotal
            const subtotalText = document.getElementById('summarySubtotal').innerText;
            // Parse VND string back to number
            const subtotal = parseFloat(subtotalText.replace(/[^\d]/g, ''));
            if (subtotal <= 0) {
                msgDiv.style.display = 'block';
                msgDiv.style.color = '#e74c3c';
                msgDiv.innerText = 'Vui lÃ²ng chá»n ngÃ y vÃ  phÃ²ng trÆ°á»›c khi Ã¡p dá»¥ng mÃ£.';
                return;
            }

            msgDiv.style.display = 'block';
            msgDiv.style.color = 'var(--brand-blue)';
            msgDiv.innerText = 'Äang kiá»ƒm tra mÃ£...';

            try {
                const formData = new URLSearchParams();
                formData.append('promoCode', promoInput);
                formData.append('totalAmount', subtotal);

                const response = await fetch('${pageContext.request.contextPath}/customer/booking/check-promotion', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: formData.toString()
                });

                const result = await response.json();
                if (result.success) {
                    msgDiv.style.color = '#27ae60';
                    msgDiv.innerText = result.message;
                    window.currentDiscountAmount = result.discountAmount;
                    window.appliedPromoCode = promoInput;
                    calculatePricing();
                } else {
                    msgDiv.style.color = '#e74c3c';
                    msgDiv.innerText = result.message;
                    window.currentDiscountAmount = 0;
                    window.appliedPromoCode = "";
                    calculatePricing();
                }
            } catch (error) {
                msgDiv.style.color = '#e74c3c';
                msgDiv.innerText = 'CÃ³ lá»—i xáº£y ra khi kiá»ƒm tra mÃ£.';
                window.currentDiscountAmount = 0;
                window.appliedPromoCode = "";
                calculatePricing();
            }
        }

        let validationTimeoutId = null;

        function validateForm(showErrorBanner = false) {
            const errorBanner = document.getElementById('clientValidationError');
            const errorMessageDiv = document.getElementById('validationErrorMessage');
            
            let isValid = true;
            let errorMsg = '';
            
            const checkInInput = document.getElementById('checkInDate');
            if (checkInInput && checkInInput.value) {
                const now = new Date();
                const year = now.getFullYear();
                const month = String(now.getMonth() + 1).padStart(2, '0');
                const day = String(now.getDate()).padStart(2, '0');
                const todayStr = `${year}-${month}-${day}`;
                if (checkInInput.value < todayStr) {
                    isValid = false;
                    errorMsg = 'NgÃ y nháº­n phÃ²ng khÃ´ng Ä‘Æ°á»£c á»Ÿ trong quÃ¡ khá»© so vá»›i ngÃ y hiá»‡n táº¡i.';
                }
            }
            
            const bookingType = document.querySelector('input[name="bookingType"]:checked').value;
            
            if (bookingType === 'single') {
                const roomSelect = document.getElementById('roomTypeId');
                const qtyInput = document.getElementById('roomQuantity');
                const guestInput = document.getElementById('guestCount');
                
                if (!roomSelect || !qtyInput || !guestInput) return;
                
                const selectedOpt = roomSelect.options[roomSelect.selectedIndex];
                const capacity = parseInt(selectedOpt.getAttribute('data-capacity')) || 2;
                const qty = parseInt(qtyInput.value) || 0;
                const guests = parseInt(guestInput.value) || 0;
                const totalCapacity = capacity * qty;
                
                if (qty <= 0) {
                    isValid = false;
                    errorMsg = 'Sá»‘ lÆ°á»£ng phÃ²ng pháº£i lá»›n hÆ¡n hoáº·c báº±ng 1.';
                } else if (guests <= 0) {
                    isValid = false;
                    errorMsg = 'LÆ°á»£ng ngÆ°á»i á»Ÿ pháº£i lá»›n hÆ¡n hoáº·c báº±ng 1.';
                } else if (guests > totalCapacity) {
                    isValid = false;
                    errorMsg = 'LÆ°á»£ng ngÆ°á»i á»Ÿ (' + guests + ' ngÆ°á»i) vÆ°á»£t quÃ¡ sá»©c chá»©a tá»‘i Ä‘a cá»§a phÃ²ng Ä‘Ã£ chá»n.';
                }
            } else {
                const container = document.getElementById('multiRoomRowsContainer');
                const rows = container.querySelectorAll('.room-row');
                
                for (let i = 0; i < rows.length; i++) {
                    const row = rows[i];
                    const roomSelect = row.querySelector('select[name="roomTypeId[]"]');
                    const qtyInput = row.querySelector('input[name="roomQuantity[]"]');
                    const guestInput = row.querySelector('input[name="guestCount[]"]');
                    
                    if (roomSelect && qtyInput && guestInput) {
                        const selectedOpt = roomSelect.options[roomSelect.selectedIndex];
                        const capacity = parseInt(selectedOpt.getAttribute('data-capacity')) || 2;
                        const qty = parseInt(qtyInput.value) || 0;
                        const guests = parseInt(guestInput.value) || 0;
                        const totalCapacity = capacity * qty;
                        const roomTypeName = selectedOpt.text.split('(')[0].trim();
                        
                        if (qty <= 0) {
                            isValid = false;
                            errorMsg = 'PhÃ²ng thá»© ' + (i + 1) + ': Sá»‘ lÆ°á»£ng phÃ²ng pháº£i lá»›n hÆ¡n hoáº·c báº±ng 1.';
                            break;
                        } else if (guests <= 0) {
                            isValid = false;
                            errorMsg = 'PhÃ²ng thá»© ' + (i + 1) + ': LÆ°á»£ng ngÆ°á»i á»Ÿ pháº£i lá»›n hÆ¡n hoáº·c báº±ng 1.';
                            break;
                        } else if (guests > totalCapacity) {
                            isValid = false;
                            errorMsg = 'PhÃ²ng thá»© ' + (i + 1) + ' (' + roomTypeName + '): LÆ°á»£ng ngÆ°á»i á»Ÿ (' + guests + ' ngÆ°á»i) vÆ°á»£t quÃ¡ sá»©c chá»©a tá»‘i Ä‘a cá»§a sá»‘ phÃ²ng Ä‘Ã£ chá»n.';
                            break;
                        }
                    }
                }
            }
            
            if (!isValid) {
                if (showErrorBanner) {
                    errorMessageDiv.innerHTML = '<strong>Cáº£nh bÃ¡o:</strong> ' + errorMsg;
                    errorBanner.style.display = 'flex';
                    
                    if (validationTimeoutId) {
                        clearTimeout(validationTimeoutId);
                    }
                    validationTimeoutId = setTimeout(() => {
                        errorBanner.style.display = 'none';
                    }, 5000);
                }
            } else {
                errorBanner.style.display = 'none';
                if (validationTimeoutId) {
                    clearTimeout(validationTimeoutId);
                }
            }
            
            return isValid;
        }

        // Add submit-time block
        document.getElementById('bookingForm').addEventListener('submit', function(event) {
            if (!validateForm(true)) {
                event.preventDefault();
            }
        });
    </script>
</body>
</html>
