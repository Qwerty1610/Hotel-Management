<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/booking.css" />
<fmt:setLocale value="vi_VN" />

<body>

    <%-- Header Navigation --%>
    <nav class="navbar-rooms" style="background: #ffffff !important; box-shadow: 0 2px 15px rgba(0, 0, 0, 0.05); border-bottom: 1px solid #f1f5f9; position: sticky; top: 0; width: 100%; z-index: 1000; padding: 16px 7%; display: flex; align-items: center; justify-content: space-between;">
        <div class="logo" style="color: var(--text-navy) !important; font-size: 28px; font-weight: 800;">HotelOps</div>
        <ul class="nav-links" style="list-style: none; display: flex; gap: 30px; margin: 0; padding: 0;">
            <li><a href="${pageContext.request.contextPath}/" style="color: #475569; font-size: 15px; font-weight: 600; text-decoration: none; transition: color 0.2s ease;">Trang chủ</a></li>
            <li><a href="${pageContext.request.contextPath}/#gioi-thieu" style="color: #475569; font-size: 15px; font-weight: 600; text-decoration: none; transition: color 0.2s ease;">Giới thiệu</a></li>
            <li><a href="${pageContext.request.contextPath}/rooms" class="active" style="color: var(--brand-blue) !important; font-size: 15px; font-weight: 600; text-decoration: none; transition: color 0.2s ease;">Phòng</a></li>
            <li><a href="${pageContext.request.contextPath}/#dich-vu" style="color: #475569; font-size: 15px; font-weight: 600; text-decoration: none; transition: color 0.2s ease;">Dịch vụ</a></li>
            <li><a href="${pageContext.request.contextPath}/#lien-he" style="color: #475569; font-size: 15px; font-weight: 600; text-decoration: none; transition: color 0.2s ease;">Liên hệ</a></li>
        </ul>

        <div class="nav-actions" style="display: flex; align-items: center; gap: 15px;">
            <c:choose>
                <c:when test="${not empty sessionScope.role and sessionScope.role == 'CUSTOMER'}">
                    <span class="user-greeting" style="color: var(--text-navy); font-weight: 600; font-size: 14px;">
                        <i class="fa-solid fa-user-circle"></i> Xin chào, ${sessionScope.user}
                    </span>
                    <a href="${pageContext.request.contextPath}/customer/booking/history" class="btn-login"
                       style="background: transparent; border: 1px solid var(--brand-blue); color: var(--brand-blue); padding: 8px 16px; border-radius: 100px; font-size: 14px; font-weight: 600; text-decoration: none; transition: all 0.2s ease;">Lịch sử</a>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-login"
                       style="background: transparent; border: 1px solid var(--brand-blue); color: var(--brand-blue); padding: 8px 16px; border-radius: 100px; font-size: 14px; font-weight: 600; text-decoration: none; transition: all 0.2s ease;">Đăng xuất</a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/home/login" class="btn-login" style="border: 1px solid var(--brand-blue); color: var(--brand-blue); padding: 8px 16px; border-radius: 100px; font-size: 14px; font-weight: 600; text-decoration: none;">Đăng nhập</a>
                    <a href="#" class="btn-register" style="background: var(--brand-blue); color: white; padding: 8px 16px; border-radius: 100px; font-size: 14px; font-weight: 600; text-decoration: none;">Đăng ký</a>
                </c:otherwise>
            </c:choose>
        </div>
    </nav>

    <%-- Hero Banner --%>
    <header class="page-header">
        <h1>Đặt phòng trực tuyến</h1>
        <p>Hoàn thành biểu mẫu dưới đây để bắt đầu kỳ nghỉ dưỡng của bạn</p>
    </header>

    <main class="container">
        <%-- Form Grid --%>
        <div class="booking-grid">
            
            <%-- Form details card --%>
            <div class="booking-card">
                <h2 class="booking-card-title">Thông tin đặt phòng</h2>

                <%-- Error Notification --%>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        <i class="fa-solid fa-triangle-exclamation"></i>
                        <span>${error}</span>
                    </div>
                </c:if>

                <form id="bookingForm" action="${pageContext.request.contextPath}/booking/start" method="POST" class="booking-form">
                    <input type="hidden" name="roomTypeId" value="${roomType.typeId}" />

                    <%-- Guest Name --%>
                    <div class="form-group">
                        <label for="customerName">Tên khách lưu trú *</label>
                        <input type="text" id="customerName" name="customerName" 
                               value="${not empty customerName ? customerName : sessionScope.user}" placeholder="Nhập họ và tên khách lưu trú" required />
                    </div>

                    <%-- Dates --%>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="checkInDate">Ngày nhận phòng *</label>
                            <input type="date" id="checkInDate" name="checkInDate" value="${checkInDate}" required />
                        </div>
                        <div class="form-group">
                            <label for="checkOutDate">Ngày trả phòng *</label>
                            <input type="date" id="checkOutDate" name="checkOutDate" value="${checkOutDate}" required />
                        </div>
                    </div>

                    <%-- Qty & Guests count --%>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="roomQuantity">Số lượng phòng *</label>
                            <input type="number" id="roomQuantity" name="roomQuantity" value="${not empty roomQuantity ? roomQuantity : 1}" min="1" max="100" required />
                        </div>
                        <div class="form-group">
                            <label for="guests">Số lượng khách *</label>
                            <input type="number" id="guests" name="guests" value="${not empty guests ? guests : 1}" min="1" required />
                        </div>
                    </div>

                    <%-- Special Requests Note --%>
                    <div class="form-group">
                        <label for="note">Yêu cầu đặc biệt (Ghi chú)</label>
                        <textarea id="note" name="note" placeholder="Ví dụ: phòng tầng cao, giường phụ, check-in muộn..." maxlength="500">${note}</textarea>
                        <span class="char-counter" id="charCounter">0 / 500 ký tự</span>
                    </div>

                    <%-- Error alert placeholder for client-side JS --%>
                    <div id="jsErrorAlert" class="alert alert-danger" style="display: none;">
                        <i class="fa-solid fa-triangle-exclamation"></i>
                        <span id="jsErrorMessage"></span>
                    </div>

                    <button type="submit" class="btn-primary-action">
                        Tiếp tục <i class="fa-solid fa-arrow-right"></i>
                    </button>
                    <a href="${pageContext.request.contextPath}/rooms/detail?id=${roomType.typeId}" class="btn-outline-action">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại chi tiết phòng
                    </a>
                </form>
            </div>

            <%-- Sidebar Room Details --%>
            <div class="room-summary-card">
                <div class="room-summary-img">
                    <img src="${roomType.imageUrl}" alt="${roomType.typeName}" />
                </div>
                <div class="room-summary-details">
                    <h3>${roomType.typeName}</h3>
                    <div class="price-row">
                        <fmt:formatNumber value="${roomType.basePrice}" pattern="#,###" />đ<span> / đêm</span>
                    </div>
                    <ul class="room-spec-list">
                        <li><i class="fa-solid fa-users"></i> Sức chứa tối đa: ${roomType.capacity} khách / phòng</li>
                        <li><i class="fa-solid fa-maximize"></i> Diện tích: ${roomType.area}</li>
                        <li><i class="fa-solid fa-bed"></i> Giường: ${roomType.bedType}</li>
                        <li><i class="fa-solid fa-credit-card"></i> Tiền đặt cọc: ${roomType.depositPercent}% tổng tiền</li>
                    </ul>
                </div>
            </div>

        </div>
    </main>

    <%-- Footer --%>
    <footer class="footer-rooms" style="background-color: #ffffff; border-top: 1px solid #e2e8f0; padding: 60px 0 30px; color: var(--text-navy); margin-top: 50px;">
        <div class="container footer-rooms-grid" style="display: grid; grid-template-columns: 2fr 1fr 1fr 1fr; gap: 40px; margin-bottom: 40px;">
            <div class="footer-brand">
                <h3 style="font-size: 26px; font-weight: 800; color: var(--brand-blue); margin-bottom: 16px;">HotelOps</h3>
                <p style="color: var(--text-muted); font-size: 14px; line-height: 1.6; max-width: 320px;">© 2024 HotelOps Luxury Management. Tất cả quyền được bảo lưu.</p>
            </div>
            
            <div class="footer-col">
                <h4 style="font-size: 15px; font-weight: 700; color: var(--text-navy); margin-bottom: 20px; text-transform: uppercase; letter-spacing: 0.5px;">Khám phá</h4>
                <ul style="list-style: none; padding: 0; margin: 0;">
                    <li style="margin-bottom: 12px;"><a href="#" style="color: var(--text-muted); font-size: 14px; text-decoration: none; transition: color 0.2s ease;">Chính sách bảo mật</a></li>
                    <li style="margin-bottom: 12px;"><a href="#" style="color: var(--text-muted); font-size: 14px; text-decoration: none; transition: color 0.2s ease;">Điều khoản sử dụng</a></li>
                </ul>
            </div>

            <div class="footer-col">
                <h4 style="font-size: 15px; font-weight: 700; color: var(--text-navy); margin-bottom: 20px; text-transform: uppercase; letter-spacing: 0.5px;">Hỗ trợ</h4>
                <ul style="list-style: none; padding: 0; margin: 0;">
                    <li style="margin-bottom: 12px;"><a href="#" style="color: var(--text-muted); font-size: 14px; text-decoration: none; transition: color 0.2s ease;">Hỗ trợ khách hàng</a></li>
                    <li style="margin-bottom: 12px;"><a href="#" style="color: var(--text-muted); font-size: 14px; text-decoration: none; transition: color 0.2s ease;">Tuyển dụng</a></li>
                </ul>
            </div>

            <div class="footer-col">
                <h4 style="font-size: 15px; font-weight: 700; color: var(--text-navy); margin-bottom: 20px; text-transform: uppercase; letter-spacing: 0.5px;">Kết nối</h4>
                <div class="footer-social-links" style="display: flex; gap: 12px;">
                    <a href="#" class="social-circle" style="width: 38px; height: 38px; border-radius: 50%; background-color: #f1f5f9; color: #475569; display: flex; align-items: center; justify-content: center; font-size: 16px; text-decoration: none;"><i class="fa-solid fa-globe"></i></a>
                    <a href="#" class="social-circle" style="width: 38px; height: 38px; border-radius: 50%; background-color: #f1f5f9; color: #475569; display: flex; align-items: center; justify-content: center; font-size: 16px; text-decoration: none;"><i class="fa-solid fa-at"></i></a>
                </div>
            </div>
        </div>
        <div class="footer-rooms-bottom" style="border-top: 1px solid #f1f5f9; padding-top: 24px; text-align: center;">
            <p style="font-size: 13px; color: #94a3b8; margin: 0;">HotelOps Management System. Elevating hospitalities.</p>
        </div>
    </footer>

    <%-- Client-side Validation Script --%>
    <script>
        (function() {
            var form = document.getElementById('bookingForm');
            var checkInInput = document.getElementById('checkInDate');
            var checkOutInput = document.getElementById('checkOutDate');
            var roomQtyInput = document.getElementById('roomQuantity');
            var guestsInput = document.getElementById('guests');
            var noteTextarea = document.getElementById('note');
            var counterLabel = document.getElementById('charCounter');
            
            var errorAlert = document.getElementById('jsErrorAlert');
            var errorMessage = document.getElementById('jsErrorMessage');
            
            var maxCapacityPerRoom = ${roomType.capacity};

            // Setup default dates if empty
            var today = new Date();
            var dd = String(today.getDate()).padStart(2, '0');
            var mm = String(today.getMonth() + 1).padStart(2, '0');
            var yyyy = today.getFullYear();
            var todayStr = yyyy + '-' + mm + '-' + dd;
            
            if (!checkInInput.value) {
                checkInInput.value = todayStr;
            }
            checkInInput.min = todayStr;

            var tomorrow = new Date(today);
            tomorrow.setDate(tomorrow.getDate() + 1);
            var ddTom = String(tomorrow.getDate()).padStart(2, '0');
            var mmTom = String(tomorrow.getMonth() + 1).padStart(2, '0');
            var yyyyTom = tomorrow.getFullYear();
            var tomorrowStr = yyyyTom + '-' + mmTom + '-' + ddTom;

            if (!checkOutInput.value) {
                checkOutInput.value = tomorrowStr;
            }
            checkOutInput.min = tomorrowStr;

            // Update character counter
            function updateCharCount() {
                var len = noteTextarea.value.length;
                counterLabel.textContent = len + ' / 500 ký tự';
                if (len > 500) {
                    counterLabel.style.color = '#ef4444';
                } else {
                    counterLabel.style.color = '#94a3b8';
                }
            }

            noteTextarea.addEventListener('input', updateCharCount);
            updateCharCount(); // Initial execution

            // Real-time validations
            roomQtyInput.addEventListener('input', function() {
                var val = parseInt(this.value, 10);
                if (isNaN(val) || val < 1) {
                    this.value = 1;
                } else if (val > 100) {
                    this.value = 100;
                }
            });

            guestsInput.addEventListener('input', function() {
                var val = parseInt(this.value, 10);
                if (isNaN(val) || val < 1) {
                    this.value = 1;
                }
            });

            // Form Submit validation
            form.addEventListener('submit', function(e) {
                errorAlert.style.display = 'none';
                
                var inDate = new Date(checkInInput.value);
                var outDate = new Date(checkOutInput.value);
                var qty = parseInt(roomQtyInput.value, 10);
                var guests = parseInt(guestsInput.value, 10);
                var customerName = document.getElementById('customerName').value.trim();
                var note = noteTextarea.value;

                if (!customerName) {
                    e.preventDefault();
                    showError('Vui lòng nhập tên khách lưu trú.');
                    return;
                }

                if (inDate < new Date(todayStr)) {
                    e.preventDefault();
                    showError('Ngày nhận phòng không được ở quá khứ.');
                    return;
                }

                if (outDate <= inDate) {
                    e.preventDefault();
                    showError('Ngày trả phòng phải sau ngày nhận phòng.');
                    return;
                }

                var maxGuestsAllowed = qty * maxCapacityPerRoom;
                if (guests > maxGuestsAllowed) {
                    e.preventDefault();
                    showError('Số khách (' + guests + ') vượt quá sức chứa tối đa của số lượng phòng đã chọn (' + maxGuestsAllowed + ' khách).');
                    return;
                }

                if (note.length > 500) {
                    e.preventDefault();
                    showError('Ghi chú yêu cầu đặc biệt không được quá 500 ký tự.');
                    return;
                }
            });

            function showError(msg) {
                errorMessage.textContent = msg;
                errorAlert.style.display = 'flex';
                window.scrollTo({ top: errorAlert.offsetTop - 120, behavior: 'smooth' });
            }
        })();
    </script>
</body>
</html>
