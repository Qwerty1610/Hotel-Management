<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ include file="../../includes/taglibs.jsp" %>
        <%@ include file="../../includes/header.jsp" %>

            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/rooms.css?v=20" />
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/room_detail.css?v=2" />
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
                                                    <a href="${pageContext.request.contextPath}/customer/booking/change" class="dropdown-item">
                                                        <i class="fa-solid fa-pen-to-square"></i> Thay đổi đặt phòng
                                                    <a href="${pageContext.request.contextPath}/customer/feedbacks" class="dropdown-item">
                                                        <i class="fa-solid fa-star"></i> Đánh giá lưu trú
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/services" class="dropdown-item">
                                                        <i class="fa-solid fa-bell-concierge"></i> Yêu cầu dịch vụ
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/maintenance"
                                                        class="dropdown-item">
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

                    <%-- Main Content Grid --%>
                        <main class="detail-page-wrapper">

                            <%-- Breadcrumbs & Back Link --%>
                                <div class="breadcrumb-container">
                                    <div class="breadcrumbs">
                                        <a href="${pageContext.request.contextPath}/">Trang chủ</a>
                                        <span>&gt;</span>
                                        <a href="${pageContext.request.contextPath}/rooms">Phòng</a>
                                        <span>&gt;</span>
                                        <span class="current">${room.typeName}</span>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/rooms" class="back-link">
                                        <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách phòng
                                    </a>
                                </div>

                                <div class="detail-grid">

                                    <%-- LEFT COLUMN: Gallery, Description, Spec Cards --%>
                                        <div class="left-column">

                                            <%-- Main Image Gallery / Slider --%>
                                                <div class="gallery-section">
                                                    <div class="main-image-container">
                                                        <img id="main-gallery-img" src="${room.imageUrl}"
                                                            alt="${room.typeName}" />

                                                        <%-- Navigation Arrows --%>
                                                            <div class="gallery-nav">
                                                                <button class="nav-arrow" onclick="changeSlide(-1)"
                                                                    aria-label="Ảnh trước">
                                                                    <i class="fa-solid fa-chevron-left"></i>
                                                                </button>
                                                                <button class="nav-arrow" onclick="changeSlide(1)"
                                                                    aria-label="Ảnh tiếp theo">
                                                                    <i class="fa-solid fa-chevron-right"></i>
                                                                </button>
                                                            </div>
                                                    </div>

                                                    <%-- Thumbnails (limit 4, show overlay if more) --%>
                                                        <div class="thumbnails-container">
                                                            <c:forEach var="imgUrl" items="${room.imageUrls}"
                                                                varStatus="status" end="3">
                                                                <div class="thumbnail-item ${status.index == 0 ? 'active' : ''} ${status.index == 3 and room.imageUrls.size() gt 4 ? 'has-overlay' : ''}"
                                                                    data-index="${status.index}"
                                                                    data-more="+${room.imageUrls.size() - 3}"
                                                                    onclick="setGalleryActive(this.dataset.index)">
                                                                    <img src="${imgUrl}"
                                                                        alt="Thumbnail ${status.index + 1}" />
                                                                </div>
                                                            </c:forEach>
                                                        </div>
                                                </div>

                                                <%-- Room Description --%>
                                                    <div class="info-card">
                                                        <h2>Mô tả phòng</h2>
                                                        <p>${room.description}</p>

                                                        <%-- Spec Cards: Area & Bed Type --%>
                                                            <div class="spec-grid">
                                                                <div class="spec-item">
                                                                    <div class="spec-icon">
                                                                        <i class="fa-solid fa-maximize"></i>
                                                                    </div>
                                                                    <div class="spec-text">
                                                                        <span class="spec-label">Diện tích</span>
                                                                        <span class="spec-value">${room.area}</span>
                                                                    </div>
                                                                </div>
                                                                <div class="spec-item">
                                                                    <div class="spec-icon">
                                                                        <i class="fa-solid fa-bed"></i>
                                                                    </div>
                                                                    <div class="spec-text">
                                                                        <span class="spec-label">Loại giường</span>
                                                                        <span class="spec-value">${room.bedType}</span>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                    </div>

                                        </div>

                                        <%-- RIGHT COLUMN: Sticky Booking Card & Guarantees --%>
                                            <div class="right-column">

                                                <%-- Booking Card --%>
                                                    <div class="booking-card">
                                                        <h1>${room.typeName}</h1>

                                                        <div class="price-display">
                                                            <fmt:formatNumber value="${room.basePrice}"
                                                                pattern="#,###" />đ
                                                            <span>/ đêm</span>
                                                        </div>

                                                        <%-- Info Badges --%>
                                                            <div class="badges-container">
                                                                <div class="badge-item guests">
                                                                    <i class="fa-solid fa-user-group"></i> Tối đa
                                                                    ${room.capacity} khách
                                                                </div>

                                                                <c:choose>
                                                                    <c:when test="${room.availableCount > 0}">
                                                                        <div class="badge-item availability">
                                                                            <i class="fa-solid fa-circle-check"></i> Còn
                                                                            ${room.availableCount} phòng trống
                                                                        </div>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <div class="badge-item out-of-stock">
                                                                            <i class="fa-solid fa-circle-xmark"></i> Hết
                                                                            phòng trống
                                                                        </div>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>

                                                            <%-- Amenities Section --%>
                                                                <div class="amenities-section">
                                                                    <h3>Tiện nghi phòng</h3>
                                                                    <div class="amenity-detail-grid">
                                                                        <c:forEach var="amenity"
                                                                            items="${room.amenityDetails}">
                                                                            <div class="amenity-detail-item">
                                                                                <div class="amenity-detail-icon">
                                                                                    <i
                                                                                        class="fa-solid ${amenity.icon}"></i>
                                                                                </div>
                                                                                <span>${amenity.name}</span>
                                                                            </div>
                                                                        </c:forEach>
                                                                    </div>
                                                                </div>

                                                                <%-- Book Now Button --%>
                                                                    <c:choose>
                                                                        <c:when test="${room.availableCount > 0}">
                                                                            <c:choose>
                                                                                <c:when
                                                                                    test="${not empty sessionScope.role and sessionScope.role == 'CUSTOMER'}">
                                                                                    <a href="${pageContext.request.contextPath}/booking/start?id=${room.typeId}"
                                                                                        class="btn-book-now"
                                                                                        style="text-decoration: none;">Đặt
                                                                                        phòng ngay</a>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <a href="${pageContext.request.contextPath}/home/login"
                                                                                        class="btn-book-now"
                                                                                        style="text-decoration: none;">Đặt
                                                                                        phòng ngay</a>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <button class="btn-book-now"
                                                                                style="background-color: #cbd5e1; cursor: not-allowed; box-shadow: none;"
                                                                                disabled>
                                                                                Đặt phòng ngay
                                                                            </button>
                                                                        </c:otherwise>
                                                                    </c:choose>

                                                                    <span class="booking-subtext">Không mất phí đặt
                                                                        phòng • Xác nhận tức thì</span>
                                                    </div>

                                                    <%-- Trust / Guarantee Card --%>
                                                        <div class="trust-badge-card">
                                                            <div class="trust-icon">
                                                                <i class="fa-solid fa-shield-halved"></i>
                                                            </div>
                                                            <div class="trust-content">
                                                                <h4>Đảm bảo giá tốt nhất</h4>
                                                                <p>Cam kết giá thấp nhất khi đặt trực tiếp tại HotelOps
                                                                </p>
                                                            </div>
                                                        </div>

                                            </div>

                                </div>

                        </main>

                        <%-- Footer --%>
                            <footer class="footer-rooms">
                                <div class="container footer-rooms-grid">
                                    <div class="footer-brand">
                                        <h3>HotelOps</h3>
                                        <p>Kiến tạo trải nghiệm lưu trú đẳng cấp và quản lý vận hành chuyên nghiệp.</p>
                                    </div>

                                    <div class="footer-col">
                                        <h4>Liên kết</h4>
                                        <ul>
                                            <li><a href="#">Về chúng tôi</a></li>
                                            <li><a href="${pageContext.request.contextPath}/rooms">Phòng &amp;
                                                    Suites</a></li>
                                            <li><a href="#">Dịch vụ khách hàng</a></li>
                                        </ul>
                                    </div>

                                    <div class="footer-col">
                                        <h4>Pháp lý</h4>
                                        <ul>
                                            <li><a href="#">Chính sách bảo mật</a></li>
                                            <li><a href="#">Điều khoản sử dụng</a></li>
                                            <li><a href="#">Hỗ trợ khách hàng</a></li>
                                        </ul>
                                    </div>

                                    <div class="footer-col">
                                        <h4>Liên hệ</h4>
                                        <p style="font-size: 14px; color: var(--text-muted); margin-bottom: 8px;">
                                            123 Đường Lê Lợi, Quận 1, TP.HCM
                                        </p>
                                        <p style="font-size: 14px; color: var(--text-muted); margin-bottom: 16px;">
                                            +84 123 456 789
                                        </p>
                                        <div class="footer-social-links">
                                            <a href="#" class="social-circle"><i class="fa-solid fa-globe"></i></a>
                                            <a href="#" class="social-circle"><i class="fa-solid fa-at"></i></a>
                                        </div>
                                    </div>
                                </div>
                                <div class="footer-rooms-bottom">
                                    <p>© 2024 HotelOps Luxury Management. Tất cả quyền được bảo lưu.</p>
                                </div>
                            </footer>

                            <%-- Gallery Slider Logic --%>
                                <script>
                                    // Image URLs array populated from JSTL
                                    const slideImages = [];
                                    <c:forEach var="url" items="${room.imageUrls}">slideImages.push("${url}");</c:forEach>

                                    let currentSlideIndex = 0;

                                    function changeSlide(direction) {
                                        if (slideImages.length <= 1) return;
                                        currentSlideIndex = (currentSlideIndex + direction + slideImages.length) % slideImages.length;
                                        updateGallery();
                                    }

                                    function setGalleryActive(index) {
                                        currentSlideIndex = parseInt(index);
                                        updateGallery();
                                    }

                                    function updateGallery() {
                                        document.getElementById("main-gallery-img").src = slideImages[currentSlideIndex];

                                        const thumbnails = document.querySelectorAll(".thumbnail-item");
                                        thumbnails.forEach((thumb, idx) => {
                                            if (idx === currentSlideIndex || (idx === 3 && currentSlideIndex >= 3)) {
                                                thumb.classList.add("active");
                                            } else {
                                                thumb.classList.remove("active");
                                            }
                                        });
                                    }
                                </script>

            </body>

            </html>