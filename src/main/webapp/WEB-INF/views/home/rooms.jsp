<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/rooms.css?v=21" />
<fmt:setLocale value="vi_VN" />

<body>

    <!-- Header Navigation (White Background Premium Style) -->
    <nav class="navbar-rooms">
        <a href="${pageContext.request.contextPath}/" class="logo">HotelOps</a>
        <ul class="nav-links">
            <li><a href="${pageContext.request.contextPath}/">Trang chủ</a></li>
            <li><a href="${pageContext.request.contextPath}/#gioi-thieu">Giới thiệu</a></li>
            <li><a href="${pageContext.request.contextPath}/rooms" class="active">Phòng</a></li>
            <li><a href="${pageContext.request.contextPath}/#dich-vu">Dịch vụ</a></li>
            <li><a href="${pageContext.request.contextPath}/#lien-he">Liên hệ</a></li>
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
                                    <a href="${pageContext.request.contextPath}/customer/feedbacks" class="dropdown-item">
                                        <i class="fa-solid fa-star"></i> Đánh giá lưu trú
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/services" class="dropdown-item">
                                        <i class="fa-solid fa-bell-concierge"></i> Yêu cầu dịch vụ
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/maintenance" class="dropdown-item">
                                        <i class="fa-solid fa-screwdriver-wrench"></i> Yêu cầu sửa chữa
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
                                        <c:when test="${sessionScope.role eq 'HOTEL_MANAGER'}">
                                            <a href="${pageContext.request.contextPath}/manager/dashboard" class="dropdown-item">
                                                <i class="fa-solid fa-chart-line"></i> Dashboard Manager
                                            </a>
                                        </c:when>
                                        <c:when test="${sessionScope.role eq 'RECEPTIONIST'}">
                                            <a href="${pageContext.request.contextPath}/receptionist/dashboard" class="dropdown-item">
                                                <i class="fa-solid fa-chart-line"></i> Dashboard Lễ tân
                                            </a>
                                        </c:when>
                                        <c:when test="${sessionScope.role eq 'HOUSEKEEPING'}">
                                            <a href="${pageContext.request.contextPath}/housekeeping/dashboard" class="dropdown-item">
                                                <i class="fa-solid fa-broom"></i> Dashboard Dọn phòng
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
                    <a href="#" class="btn-register">Đăng ký</a>
                </c:otherwise>
            </c:choose>
        </div>
    </nav>

    <!-- Search Hero Section -->
    <header class="search-hero">
        <h1>Tìm kiếm phòng</h1>
        <p>Đa dạng loại phòng phù hợp với mọi nhu cầu của quý khách</p>
    </header>

    <!-- Floating Search Form -->
    <div class="search-container">
        <div class="search-card">
            <form action="${pageContext.request.contextPath}/rooms" method="GET">
                <div class="search-grid">
                    
                    <!-- Check-in Date -->
                    <div class="form-group">
                        <label for="checkIn">Ngày nhận phòng</label>
                        <input type="date" name="checkIn" id="checkIn" value="${selectedCheckIn}" min="${todayDate}" required />
                    </div>

                    <!-- Check-out Date -->
                    <div class="form-group">
                        <label for="checkOut">Ngày trả phòng</label>
                        <input type="date" name="checkOut" id="checkOut" value="${selectedCheckOut}" min="${not empty selectedCheckIn ? selectedCheckIn : todayDate}" required />
                    </div>

                    <!-- Min Price Input -->
                    <div class="form-group">
                        <label for="minPrice">Giá tối thiểu</label>
                        <input type="number" name="minPrice" id="minPrice" placeholder="0 VNĐ" value="${selectedMinPrice}" min="0" step="1000" />
                    </div>

                    <!-- Max Price Input -->
                    <div class="form-group">
                        <label for="maxPrice">Giá tối đa</label>
                        <input type="number" name="maxPrice" id="maxPrice" placeholder="Không giới hạn" value="${selectedMaxPrice}" min="0" step="1000" />
                    </div>

                    <!-- Guests Dropdown -->
                    <div class="form-group">
                        <label for="guests">Số khách</label>
                        <select name="guests" id="guests">
                            <option value="all" ${selectedGuests == 'all' ? 'selected' : ''}>Tất cả</option>
                            <option value="1" ${selectedGuests == '1' ? 'selected' : ''}>1 khách</option>
                            <option value="2" ${selectedGuests == '2' ? 'selected' : ''}>2 khách</option>
                            <option value="3" ${selectedGuests == '3' ? 'selected' : ''}>3 khách</option>
                            <option value="4" ${selectedGuests == '4' ? 'selected' : ''}>4 khách hoặc hơn</option>
                        </select>
                    </div>

                    <!-- Search Button -->
                    <button type="submit" class="btn-search">
                        <i class="fa-solid fa-magnifying-glass"></i> Tìm kiếm
                    </button>

                    <!-- Reset Button -->
                    <a href="${pageContext.request.contextPath}/rooms" class="btn-reset" title="Xóa bộ lọc">
                        <i class="fa-solid fa-xmark"></i>
                    </a>

                </div>
            </form>

            <script>
                (function () {
                    var form = document.querySelector('.search-card form');
                    var checkInInput = document.getElementById('checkIn');
                    var checkOutInput = document.getElementById('checkOut');
                    var minInput = document.getElementById('minPrice');
                    var maxInput = document.getElementById('maxPrice');

                    // Set min date to today (local timezone formatted YYYY-MM-DD)
                    var d = new Date();
                    var month = '' + (d.getMonth() + 1);
                    var day = '' + d.getDate();
                    var year = d.getFullYear();
                    if (month.length < 2) month = '0' + month;
                    if (day.length < 2) day = '0' + day;
                    var todayStr = [year, month, day].join('-');

                    if (checkInInput) {
                        checkInInput.min = todayStr;
                        checkInInput.addEventListener('input', function () {
                            this.setCustomValidity('');
                            if (checkOutInput) {
                                checkOutInput.min = this.value || todayStr;
                                if (checkOutInput.value && checkOutInput.value <= this.value) {
                                    checkOutInput.value = '';
                                }
                            }
                        });
                    }

                    if (checkOutInput) {
                        checkOutInput.min = (checkInInput && checkInInput.value) ? checkInInput.value : todayStr;
                        checkOutInput.addEventListener('input', function () {
                            this.setCustomValidity('');
                        });
                    }

                    // Real-time: clear custom validity on input for price fields
                    [minInput, maxInput].forEach(function (input) {
                        if (input) {
                            input.addEventListener('input', function () {
                                this.setCustomValidity('');
                                if (this.value !== '' && parseFloat(this.value) < 0) {
                                    this.value = 0;
                                }
                            });
                        }
                    });

                    // On submit: validate inputs with native HTML5 tooltip
                    form.addEventListener('submit', function (e) {
                        if (checkInInput) checkInInput.setCustomValidity('');
                        if (checkOutInput) checkOutInput.setCustomValidity('');
                        minInput.setCustomValidity('');
                        maxInput.setCustomValidity('');

                        if (checkInInput && checkOutInput) {
                            var inVal = checkInInput.value.trim();
                            var outVal = checkOutInput.value.trim();
                            if (!inVal) {
                                e.preventDefault();
                                checkInInput.setCustomValidity('Vui lòng chọn ngày nhận phòng.');
                                checkInInput.reportValidity();
                                return;
                            }
                            if (!outVal) {
                                e.preventDefault();
                                checkOutInput.setCustomValidity('Vui lòng chọn ngày trả phòng.');
                                checkOutInput.reportValidity();
                                return;
                            }
                            if (inVal < todayStr) {
                                e.preventDefault();
                                checkInInput.setCustomValidity('Ngày nhận phòng không được ở trong quá khứ.');
                                checkInInput.reportValidity();
                                return;
                            }
                            if (inVal >= outVal) {
                                e.preventDefault();
                                checkOutInput.setCustomValidity('Ngày trả phòng phải sau ngày nhận phòng.');
                                checkOutInput.reportValidity();
                                return;
                            }
                        }

                        var minVal = minInput.value.trim();
                        var maxVal = maxInput.value.trim();
                        var min = parseFloat(minVal);
                        var max = parseFloat(maxVal);

                        if (minVal !== '' && min < 0) {
                            e.preventDefault();
                            minInput.value = 0;
                            minInput.setCustomValidity('Giá tối thiểu phải lớn hơn hoặc bằng 0.');
                            minInput.reportValidity();
                            return;
                        }
                        if (maxVal !== '' && max < 0) {
                            e.preventDefault();
                            maxInput.value = 0;
                            maxInput.setCustomValidity('Giá tối đa phải lớn hơn hoặc bằng 0.');
                            maxInput.reportValidity();
                            return;
                        }
                        if (minVal !== '' && maxVal !== '' && !isNaN(min) && !isNaN(max) && min > max) {
                            e.preventDefault();
                            minInput.setCustomValidity('Giá tối thiểu không được lớn hơn giá tối đa.');
                            minInput.reportValidity();
                            return;
                        }
                    });

                    // Unified Vietnamese HTML5 Validation Messages
                    document.addEventListener('invalid', function (e) {
                        var el = e.target;
                        if (!el || !['INPUT', 'SELECT', 'TEXTAREA'].includes(el.tagName)) return;
                        if (el.validity.valueMissing) {
                            if (el.id === 'checkIn') {
                                el.setCustomValidity('Vui lòng chọn ngày nhận phòng.');
                            } else if (el.id === 'checkOut') {
                                el.setCustomValidity('Vui lòng chọn ngày trả phòng.');
                            } else if (el.tagName === 'SELECT') {
                                el.setCustomValidity('Vui lòng chọn một tùy chọn trong danh sách.');
                            } else {
                                el.setCustomValidity('Vui lòng điền vào trường này.');
                            }
                        } else if (el.validity.rangeUnderflow) {
                            el.setCustomValidity('Giá trị phải lớn hơn hoặc bằng ' + el.min + '.');
                        } else if (el.validity.rangeOverflow) {
                            el.setCustomValidity('Giá trị không được vượt quá ' + el.max + '.');
                        } else if (el.validity.typeMismatch || el.validity.badInput) {
                            el.setCustomValidity('Định dạng dữ liệu không hợp lệ.');
                        }
                    }, true);
                })();
            </script>
        </div>
    </div>

    <!-- Search Results Section -->
    <main class="results-section">
        <div class="container">
            
            <c:if test="${not empty dateError}">
                <div class="alert-banner alert-danger" style="margin-bottom: 20px; background:#fee2e2; color:#b91c1c; border:1px solid #fca5a5; padding:12px 16px; border-radius:8px; display:flex; align-items:center; gap:8px; font-weight:600;">
                    <i class="fa-solid fa-circle-exclamation"></i> ${dateError}
                </div>
            </c:if>

            <div class="results-header">
                Tìm thấy <strong>${resultsCount}</strong> loại phòng trống (${selectedCheckIn} → ${selectedCheckOut})
            </div>

            <!-- Room Cards Grid -->
            <c:choose>
                <c:when test="${not empty roomTypes}">
                    <div class="rooms-grid">
                        <c:forEach var="rt" items="${roomTypes}">
                            <!-- Border highlight for Room Deluxe (typeId = 2) -->
                            <div class="room-card">
                                <div class="card-badges" style="display:flex; justify-content:space-between; align-items:center;">
                                    <div class="badge-guests">
                                        <i class="fa-solid fa-user-group"></i> ${rt.capacity} khách
                                    </div>
                                    <div class="badge-avail" style="font-size:12px; font-weight:700; color:#15803d; background:#dcfce7; padding:3px 10px; border-radius:12px;">
                                        <i class="fa-solid fa-check"></i> Còn ${rt.availableCount} phòng
                                    </div>
                                </div>

                                <div class="room-img-container">
                                    <img src="${rt.imageUrl}" alt="${rt.typeName}" />
                                </div>

                                <div class="room-info">
                                    <div class="room-category">
                                        <i class="fa-regular fa-star"></i> LUXURY HOTEL
                                    </div>
                                    <h3 class="room-title">${rt.typeName}</h3>
                                    <p class="room-desc">${rt.description}</p>
                                    
                                    <div class="room-amenities">
                                        <c:forEach var="amenity" items="${rt.amenities}">
                                            <span class="amenity-pill">
                                                <i class="fa-solid fa-circle-check"></i> ${amenity}
                                            </span>
                                        </c:forEach>
                                    </div>

                                    <div class="room-card-footer">
                                        <div class="price-box">
                                            <span class="current-price">
                                                <fmt:formatNumber value="${rt.basePrice}" pattern="#,###" />đ 
                                                <span class="price-unit">/ đêm</span>
                                            </span>
                                        </div>

                                        <a href="${pageContext.request.contextPath}/rooms/detail?id=${rt.typeId}&checkIn=${selectedCheckIn}&checkOut=${selectedCheckOut}" class="btn-detail">
                                            Chi tiết <i class="fa-solid fa-arrow-right"></i>
                                        </a>
                                    </div>
                                </div>

                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                
                <c:otherwise>
                    <!-- No Rooms Found Fallback -->
                    <div class="no-results">
                        <i class="fa-solid fa-bed-pulse"></i>
                        <c:choose>
                            <c:when test="${not empty priceError}">
                                <h3 style="color: #dc3545;">${priceError}</h3>
                                <p>Vui lòng điều chỉnh lại bộ lọc để giá tối thiểu nhỏ hơn hoặc bằng giá tối đa.</p>
                            </c:when>
                            <c:otherwise>
                                <h3>Không tìm thấy phòng phù hợp</h3>
                                <p>Vui lòng thử lại với các bộ lọc giá hoặc số khách khác.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:otherwise>
            </c:choose>

        </div>
    </main>

    <!-- Modern Clean Footer -->
    <footer class="footer-rooms">
        <div class="container footer-rooms-grid">
            <div class="footer-brand">
                <h3>HotelOps</h3>
                <p>© 2024 HotelOps Luxury Management. Tất cả quyền được bảo lưu.</p>
            </div>
            
            <div class="footer-col">
                <h4>Khám phá</h4>
                <ul>
                    <li><a href="#">Chính sách bảo mật</a></li>
                    <li><a href="#">Điều khoản sử dụng</a></li>
                </ul>
            </div>

            <div class="footer-col">
                <h4>Hỗ trợ</h4>
                <ul>
                    <li><a href="#">Hỗ trợ khách hàng</a></li>
                    <li><a href="#">Tuyển dụng</a></li>
                </ul>
            </div>

            <div class="footer-col">
                <h4>Kết nối</h4>
                <div class="footer-social-links">
                    <a href="#" class="social-circle"><i class="fa-solid fa-globe"></i></a>
                    <a href="#" class="social-circle"><i class="fa-solid fa-at"></i></a>
                </div>
            </div>
        </div>
        <div class="footer-rooms-bottom">
            <p>HotelOps Management System. Elevating hospitalities.</p>
        </div>
    </footer>

</body>
</html>
