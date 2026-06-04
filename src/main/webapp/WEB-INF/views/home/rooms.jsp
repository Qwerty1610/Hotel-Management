<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/rooms.css" />
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
                <c:when test="${not empty sessionScope.role and sessionScope.role == 'CUSTOMER'}">
                    <span class="user-greeting" style="color: var(--text-navy); margin-right: 15px; font-weight: 600; font-size: 14px;">
                        <i class="fa-solid fa-user-circle"></i> Xin chào, ${sessionScope.user}
                    </span>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-login" style="background: transparent; border: 1px solid var(--brand-blue); color: var(--brand-blue);">Đăng xuất</a>
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
                    
                    <!-- Room Type Dropdown -->
                    <div class="form-group">
                        <label for="typeId">Loại phòng</label>
                        <select name="typeId" id="typeId">
                            <option value="all" ${selectedTypeId == 'all' ? 'selected' : ''}>Tất cả loại phòng</option>
                            <option value="Standard" ${selectedTypeId == 'Standard' ? 'selected' : ''}>Phòng Standard</option>
                            <option value="Deluxe" ${selectedTypeId == 'Deluxe' ? 'selected' : ''}>Phòng Deluxe</option>
                            <option value="Family" ${selectedTypeId == 'Family' ? 'selected' : ''}>Phòng Family</option>
                            <option value="Suite" ${selectedTypeId == 'Suite' ? 'selected' : ''}>Phòng Suite</option>
                        </select>
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
                    var minInput = document.getElementById('minPrice');
                    var maxInput = document.getElementById('maxPrice');

                    // Real-time: clamp to 0 if user somehow types negative
                    [minInput, maxInput].forEach(function (input) {
                        input.addEventListener('input', function () {
                            if (this.value !== '' && parseFloat(this.value) < 0) {
                                this.value = 0;
                            }
                        });
                    });

                    // On submit: validate and prevent negative values
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

    <!-- Search Results Section -->
    <main class="results-section">
        <div class="container">
            
            <div class="results-header">
                Tìm thấy <strong>${resultsCount}</strong> loại phòng
            </div>

            <!-- Room Cards Grid -->
            <c:choose>
                <c:when test="${not empty roomTypes}">
                    <div class="rooms-grid">
                        <c:forEach var="rt" items="${roomTypes}">
                            <!-- Border highlight for Room Deluxe (typeId = 2) -->
                            <div class="room-card">
                                <div class="card-badges">
                                    <div class="badge-guests">
                                        <i class="fa-solid fa-user-group"></i> ${rt.capacity} khách
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

                                        <a href="${pageContext.request.contextPath}/rooms/detail?id=${rt.typeId}" class="btn-detail">
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
                        <h3>Không tìm thấy phòng phù hợp</h3>
                        <p>Vui lòng thử lại với các bộ lọc giá hoặc số khách khác.</p>
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
