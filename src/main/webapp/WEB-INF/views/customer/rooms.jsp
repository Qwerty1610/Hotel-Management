<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/rooms.css?v=20" />
<fmt:setLocale value="vi_VN" />

<body>

    <%-- Header Navigation --%>
    <nav class="navbar-rooms">
        <div class="logo">HotelOps</div>
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

    <%-- Search Hero Section --%>
    <header class="search-hero">
        <h1>Tìm kiếm phòng</h1>
        <p>Đa dạng loại phòng phù hợp với mọi nhu cầu của quý khách</p>
    </header>

    <%-- Floating Search / Filter Form --%>
    <div class="search-container">
        <div class="search-card">
            <form action="${pageContext.request.contextPath}/rooms" method="GET">
                <div class="search-grid">

                    <%-- Room Type Dropdown --%>
                    <div class="form-group">
                        <label for="typeId">Loại phòng</label>
                        <select name="typeId" id="typeId">
                            <option value="all" ${selectedTypeId == 'all' ? 'selected' : ''}>Tất cả loại phòng</option>
                            <c:forEach var="rt" items="${roomTypes}">
                                <option value="${rt.typeId}" ${selectedTypeId == rt.typeId ? 'selected' : ''}>
                                    <c:out value="${rt.typeName}" />
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <%-- Min Price --%>
                    <div class="form-group">
                        <label for="minPrice">Giá tối thiểu</label>
                        <input type="number" name="minPrice" id="minPrice"
                               placeholder="0 VNĐ" value="${selectedMinPrice}" min="0" step="1000" />
                    </div>

                    <%-- Max Price --%>
                    <div class="form-group">
                        <label for="maxPrice">Giá tối đa</label>
                        <input type="number" name="maxPrice" id="maxPrice"
                               placeholder="Không giới hạn" value="${selectedMaxPrice}" min="0" step="1000" />
                    </div>

                    <%-- Number of Guests --%>
                    <div class="form-group">
                        <label for="guests">Số khách</label>
                        <select name="guests" id="guests">
                            <option value="all"  ${selectedGuests == 'all'  ? 'selected' : ''}>Tất cả</option>
                            <option value="1"    ${selectedGuests == '1'    ? 'selected' : ''}>1 khách</option>
                            <option value="2"    ${selectedGuests == '2'    ? 'selected' : ''}>2 khách</option>
                            <option value="3"    ${selectedGuests == '3'    ? 'selected' : ''}>3 khách</option>
                            <option value="4"    ${selectedGuests == '4'    ? 'selected' : ''}>4 khách hoặc hơn</option>
                        </select>
                    </div>

                    <%-- Search Button --%>
                    <button type="submit" class="btn-search">
                        <i class="fa-solid fa-magnifying-glass"></i> Tìm kiếm
                    </button>

                    <%-- Reset Button --%>
                    <a href="${pageContext.request.contextPath}/rooms" class="btn-reset" title="Xóa bộ lọc">
                        <i class="fa-solid fa-xmark"></i>
                    </a>

                </div>
            </form>

            <%-- Client-side price validation --%>
            <script>
                (function () {
                    var form     = document.querySelector('.search-card form');
                    var minInput = document.getElementById('minPrice');
                    var maxInput = document.getElementById('maxPrice');

                    [minInput, maxInput].forEach(function (input) {
                        input.addEventListener('input', function () {
                            if (this.value !== '' && parseFloat(this.value) < 0) {
                                this.value = 0;
                            }
                        });
                    });

                    form.addEventListener('submit', function (e) {
                        var min = parseFloat(minInput.value);
                        var max = parseFloat(maxInput.value);

                        if (minInput.value !== '' && min < 0) {
                            e.preventDefault();
                            minInput.value = 0;
                            minInput.focus();
                            alert('Giá tối thiểu phải lớn hơn hoặc bằng 0.');
                            return;
                        }
                        if (maxInput.value !== '' && max < 0) {
                            e.preventDefault();
                            maxInput.value = 0;
                            maxInput.focus();
                            alert('Giá tối đa phải lớn hơn hoặc bằng 0.');
                            return;
                        }
                    });
                })();
            </script>
        </div>
    </div>

    <%-- Search Results Section --%>
    <main class="results-section">
        <div class="container">

            <div class="results-header">
                Tìm thấy <strong>${resultsCount}</strong> loại phòng
            </div>

            <%-- Room Cards Grid --%>
            <c:choose>
                <c:when test="${not empty roomTypes}">
                    <div class="rooms-grid">
                        <c:forEach var="rt" items="${roomTypes}">
                            <div class="room-card">
                                <div class="card-badges">
                                    <div class="badge-guests">
                                        <i class="fa-solid fa-user-group"></i> ${rt.capacity} khách
                                    </div>
                                </div>

                                <div class="room-img-container">
                                    <img src="${rt.imageUrl}" alt="<c:out value="${rt.typeName}" />" loading="lazy" />
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

                                        <a href="${pageContext.request.contextPath}/rooms/detail?id=${rt.typeId}"
                                           class="btn-detail">
                                            Chi tiết <i class="fa-solid fa-arrow-right"></i>
                                        </a>
                                    </div>
                                </div>

                            </div>
                        </c:forEach>
                    </div>
                </c:when>

                <c:otherwise>
                    <%-- No Rooms Found --%>
                    <div class="no-results">
                        <i class="fa-solid fa-bed-pulse"></i>
                        <h3>Không tìm thấy phòng phù hợp</h3>
                        <p>Vui lòng thử lại với các bộ lọc giá hoặc số khách khác.</p>
                        <a href="${pageContext.request.contextPath}/rooms" class="btn-search" style="text-decoration: none; margin-top: 12px; display: inline-block;">
                            Xem tất cả phòng
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>

        </div>
    </main>

    <%-- Footer --%>
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
