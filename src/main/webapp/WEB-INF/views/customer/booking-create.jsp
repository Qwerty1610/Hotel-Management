<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer_booking.css?v=22" />
<fmt:setLocale value="vi_VN" />

<body>

    <%-- Header Navigation --%>
    <nav class="navbar-rooms">
        <div class="logo">HotelOps</div>
        <ul class="nav-links">
            <li><a href="${pageContext.request.contextPath}/">Trang chủ</a></li>
            <li><a href="${pageContext.request.contextPath}/rooms">Phòng</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/bookings" class="active">Đặt phòng của tôi</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/payments">Thanh toán</a></li>
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
                                        <i class="fa-solid fa-id-card"></i> Hồ sơ
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/bookings" class="dropdown-item">
                                        <i class="fa-solid fa-calendar-check"></i> Đặt phòng của tôi
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/booking/change" class="dropdown-item">
                                        <i class="fa-solid fa-pen-to-square"></i> Thay đổi đặt phòng
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
                                <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/home/login" class="btn-login">Đăng nhập</a>
                </c:otherwise>
            </c:choose>
        </div>
    </nav>

    <div class="booking-container">
        <div class="booking-header">
            <h1>Tạo Đặt Phòng Mới</h1>
            <p>Trải nghiệm kỳ nghỉ hoàn hảo tại hệ thống khách sạn cao cấp HotelOps Pro</p>
        </div>

        <%-- Error Alert --%>
        <c:if test="${not empty errorCode}">
            <div class="error-banner" id="serverValidationError">
                <i class="fa-solid fa-circle-exclamation" style="font-size: 20px;"></i>
                <div>
                    <strong>Lỗi đặt phòng:</strong> ${errorMessage}
                </div>
            </div>
        </c:if>

        <%-- Client Validation Alert --%>
        <div class="error-banner" id="clientValidationError" style="display: none;">
            <i class="fa-solid fa-circle-exclamation" style="font-size: 20px;"></i>
            <div id="validationErrorMessage">
                <strong>Cảnh báo:</strong> Số lượng khách vượt quá sức chứa tối đa của phòng đã chọn!
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
                                Hình thức đặt phòng
                            </h2>
                            
                            <div class="type-selector">
                                <div class="type-card ${bookingType eq 'multi' ? '' : 'active'}" id="typeSingleCard" onclick="switchBookingType('single')">
                                    <input type="radio" name="bookingType" id="typeSingle" value="single" ${bookingType eq 'multi' ? '' : 'checked'} />
                                    <h3>Đặt phòng đơn</h3>
                                    <p>Đặt 1 loại phòng phù hợp với số lượng khách tiêu chuẩn.</p>
                                </div>
                                <div class="type-card ${bookingType eq 'multi' ? 'active' : ''}" id="typeMultiCard" onclick="switchBookingType('multi')">
                                    <input type="radio" name="bookingType" id="typeMulti" value="multi" ${bookingType eq 'multi' ? 'checked' : ''} />
                                    <h3>Đặt nhiều phòng (Multi-room)</h3>
                                    <p>Đăng ký nhiều phòng khác nhau trong cùng một đơn đặt phòng và phân chia danh sách khách đi cùng.</p>
                                </div>
                            </div>
                        </div>

                        <%-- 2. General Stay Information --%>
                        <div class="booking-section">
                            <h2 style="font-size: 18px; margin-top: 0; color: var(--primary-dark); margin-bottom: 20px;">
                                <i class="fa-solid fa-calendar-days" style="color: var(--accent-gold); margin-right: 8px;"></i>
                                Thông tin thời gian & Liên hệ
                            </h2>
                            
                            <div class="form-grid">
                                <div class="form-group">
                                    <label for="customerName">Họ tên người đặt *</label>
                                    <input type="text" name="customerName" id="customerName" required placeholder="Nhập họ tên đầy đủ"
                                           value="${not empty customerName ? customerName : sessionScope.user}" />
                                </div>
                                <div class="form-group">
                                    <label for="phone">Số điện thoại *</label>
                                    <input type="tel" name="phone" id="phone" required placeholder="Nhập số điện thoại"
                                           value="${phone}" />
                                </div>
                                <div class="form-group">
                                    <label for="email">Email *</label>
                                    <input type="email" name="email" id="email" required placeholder="Nhập email liên hệ"
                                           value="${email}" />
                                </div>
                                <div class="form-group">
                                    <label for="checkInDate">Ngày nhận phòng *</label>
                                    <input type="date" name="checkInDate" id="checkInDate" required value="${checkInDate}" onchange="calculatePricing()" />
                                </div>
                                <div class="form-group">
                                    <label for="checkOutDate">Ngày trả phòng *</label>
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
                                    Chọn loại phòng & Khách nghỉ
                                </h2>
                                <div class="single-room-grid">
                                    <div class="form-group">
                                        <label for="roomTypeId">Loại phòng</label>
                                        <select name="roomTypeId" id="roomTypeId" onchange="calculatePricing(); validateForm()">
                                            <c:forEach var="rt" items="${roomTypes}">
                                                <option value="${rt.typeId}" data-price="${rt.basePrice}" data-capacity="${rt.capacity}">
                                                    ${rt.typeName} - <fmt:formatNumber value="${rt.basePrice}" type="number" pattern="#,##0" /> VND / đêm (Tối đa ${rt.capacity} khách)
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="form-group">
                                        <label for="roomQuantity">Số lượng phòng</label>
                                        <input type="number" name="roomQuantity" id="roomQuantity" min="1" max="10" value="1" required oninput="calculatePricing(); validateForm()" />
                                    </div>
                                    <div class="form-group">
                                        <label for="guestCount">Lượng người ở *</label>
                                        <input type="number" name="guestCount" id="guestCount" min="1" value="1" required oninput="validateForm()" />
                                    </div>
                                </div>
                            </div>

                            <%-- Multi Room Selection Form --%>
                            <div id="multiRoomFields" style="display: ${bookingType eq 'multi' ? 'block' : 'none'};">
                                <div class="room-selection-header" style="margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center;">
                                    <h2 style="font-size: 18px; margin-top: 0; margin-bottom: 0; color: var(--primary-dark); border-bottom: none; padding-bottom: 0;">
                                        <i class="fa-solid fa-circle-info" style="color: var(--accent-gold); margin-right: 8px;"></i>
                                        Danh sách phòng chọn đặt
                                    </h2>
                                    <button type="button" class="btn-secondary" onclick="addRoomRow()">
                                        <i class="fa-solid fa-plus"></i> Thêm phòng
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
                                Yêu cầu đặc biệt (Tùy chọn)
                            </h2>
                            
                            <div class="form-group form-group-full">
                                <label for="note">Nội dung ghi chú / yêu cầu</label>
                                <textarea name="note" id="note" rows="4" placeholder="Nhập các yêu cầu đặc biệt của bạn (ví dụ: phòng tầng cao, giường phụ, yên tĩnh...)">${note}</textarea>
                            </div>
                        </div>
                        
                    </div>
                </div>

                <%-- Sticky Right Column Summary --%>
                <div class="booking-sidebar">
                    <div class="receipt-card">
                        <h3>Tóm tắt đặt phòng</h3>
                        
                        <div class="receipt-row">
                            <span>Số đêm nghỉ:</span>
                            <span id="summaryNights">--</span>
                        </div>
                        <div class="receipt-row">
                            <span>Tổng tiền phòng:</span>
                            <span id="summarySubtotal">0 VND</span>
                        </div>
                        
                        <div class="receipt-row total">
                            <span>TỔNG CỘNG:</span>
                            <span id="summaryGrandTotal" class="grand-total-amount">0 VND</span>
                        </div>
                        
                        <div class="receipt-row deposit" style="margin-top: 15px;">
                            <span class="deposit-label">Tiền đặt cọc (30%):</span>
                            <span id="summaryDeposit" class="deposit-amount">0 VND</span>
                        </div>

                        <button type="submit" class="btn-primary" id="submitBtn">
                            <i class="fa-solid fa-credit-card"></i> Tiến hành đặt phòng
                        </button>
                        <a href="${pageContext.request.contextPath}/rooms" class="btn-secondary" style="margin-top: 10px; display: block; text-align: center; text-decoration: none; padding: 12px; border-radius: var(--radius-md);">
                            Hủy đặt phòng
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
                <p>Hệ thống quản lý và nghỉ dưỡng đẳng cấp quốc tế, đem lại trải nghiệm sang trọng vượt thời gian.</p>
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
                <p><i class="fa-solid fa-location-dot"></i> 123 Đường Lê Lợi, Quận 1, TP. Hồ Chí Minh</p>
                <p><i class="fa-solid fa-envelope"></i> contact@hotelopspro.com</p>
                <span class="phone-number-white"><i class="fa-solid fa-phone"></i> 1900 6789</span>
            </div>
        </div>
        <div class="footer-white-bottom text-center">
            <p>&copy; 2026 HotelOps Pro. All rights reserved.</p>
        </div>
    </footer>


    <script>
        // Set default dates if empty
        window.addEventListener('DOMContentLoaded', (event) => {
            const checkInInput = document.getElementById('checkInDate');
            const checkOutInput = document.getElementById('checkOutDate');

            if (!checkInInput.value) {
                const today = new Date();
                today.setDate(today.getDate() + 1); // tomorrow
                checkInInput.value = today.toISOString().split('T')[0];
            }
            if (!checkOutInput.value) {
                const tomorrow = new Date();
                tomorrow.setDate(tomorrow.getDate() + 2); // day after tomorrow
                checkOutInput.value = tomorrow.toISOString().split('T')[0];
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
                    '${rt.typeName} - <fmt:formatNumber value="${rt.basePrice}" type="number" pattern="#,##0" /> VND / đêm (Tối đa ${rt.capacity} khách)' +
                '</option>';
            </c:forEach>

            row.innerHTML = 
                '<div class="form-group">' +
                '    <label>Loại phòng</label>' +
                '    <select name="roomTypeId[]" required onchange="calculatePricing(); validateForm()">' +
                optionsHtml +
                '    </select>' +
                '</div>' +
                '<div class="form-group">' +
                '    <label>Số lượng</label>' +
                '    <input type="number" name="roomQuantity[]" min="1" max="10" value="' + qty + '" required oninput="calculatePricing(); validateForm()" />' +
                '</div>' +
                '<div class="form-group">' +
                '    <label>Lượng người ở</label>' +
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
                nightsSpan.innerText = '0 đêm';
                subtotalSpan.innerText = '0 VND';
                totalSpan.innerText = '0 VND';
                depositSpan.innerText = '0 VND';
                return;
            }

            nightsSpan.innerText = diffDays + ' đêm';

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

            const deposit = totalPrice * 0.3;

            // Formatter
            const formatter = new Intl.NumberFormat('vi-VN', {
                style: 'currency',
                currency: 'VND'
            });

            subtotalSpan.innerText = formatter.format(totalPrice);
            totalSpan.innerText = formatter.format(totalPrice);
            depositSpan.innerText = formatter.format(deposit);
        }

        let validationTimeoutId = null;

        function validateForm(showErrorBanner = false) {
            const errorBanner = document.getElementById('clientValidationError');
            const errorMessageDiv = document.getElementById('validationErrorMessage');
            
            let isValid = true;
            let errorMsg = '';
            
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
                    errorMsg = 'Số lượng phòng phải lớn hơn hoặc bằng 1.';
                } else if (guests <= 0) {
                    isValid = false;
                    errorMsg = 'Lượng người ở phải lớn hơn hoặc bằng 1.';
                } else if (guests > totalCapacity) {
                    isValid = false;
                    errorMsg = 'Lượng người ở (' + guests + ' người) vượt quá sức chứa tối đa của phòng đã chọn.';
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
                            errorMsg = 'Phòng thứ ' + (i + 1) + ': Số lượng phòng phải lớn hơn hoặc bằng 1.';
                            break;
                        } else if (guests <= 0) {
                            isValid = false;
                            errorMsg = 'Phòng thứ ' + (i + 1) + ': Lượng người ở phải lớn hơn hoặc bằng 1.';
                            break;
                        } else if (guests > totalCapacity) {
                            isValid = false;
                            errorMsg = 'Phòng thứ ' + (i + 1) + ' (' + roomTypeName + '): Lượng người ở (' + guests + ' người) vượt quá sức chứa tối đa của số phòng đã chọn.';
                            break;
                        }
                    }
                }
            }
            
            if (!isValid) {
                if (showErrorBanner) {
                    errorMessageDiv.innerHTML = '<strong>Cảnh báo:</strong> ' + errorMsg;
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
