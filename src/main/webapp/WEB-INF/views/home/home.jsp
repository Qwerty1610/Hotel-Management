<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%-- Nhúng Header cấu trúc --%>
<%@ include file="../../includes/header.jsp" %>

<body>
    <div class="loader-container" id="page-loader">
        <div class="neon-circle"></div>
    </div>
    <header class="hero-section" id="trang-chu">
        <nav class="navbar">
            <a href="#trang-chu" class="logo">HotelOps</a>
            <ul class="nav-links">
                <li><a href="#trang-chu" class="active">Trang chủ</a></li>
                <li><a href="#gioi-thieu">Giới thiệu</a></li>
                <li><a href="#phong-gia">Phòng</a></li>
                <li><a href="#dich-vu">Dịch vụ</a></li>
                <li><a href="#lien-he">Liên hệ</a></li>
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
                        <a href="${pageContext.request.contextPath}/home/register" class="btn-register">Đăng ký</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </nav>

        <div class="hero-content">
            <h1>Trải nghiệm kỳ nghỉ<br>tuyệt vời tại HotelOps</h1>
            <p>Nơi sang trọng gặp gỡ sự tinh tế, mang đến cho bạn trải nghiệm nghỉ dưỡng đích thực tại trung tâm thành phố.</p>
        </div>

    </header>

    <section class="about-section container" id="gioi-thieu">
        <div class="about-image">
            <img src="https://images.unsplash.com/photo-1439066615861-d1af74d74000?q=80&w=1200" alt="Resort HotelOps">
        </div>
        <div class="about-text">
            <span class="sub-title">VỀ HOTELOPS</span>
            <h2>Định nghĩa lại lòng hiếu khách</h2>
            <p>
                HotelOps cung cấp không gian lưu trú sạch sẽ, tiện nghi và thoải mái
                dành cho cá nhân, gia đình và khách du lịch. Chúng tôi luôn cố gắng
                mang đến trải nghiệm nghỉ ngơi thuận tiện với mức giá phù hợp cho mọi khách hàng.
            </p>
            <div class="about-features">
                <div class="feat-item">
                    <i class="fa-solid fa-shield-halved"></i>
                    <div>
                        <h4>An ninh và Bảo mật tối đa</h4>
                        <p>Đảm bảo sự riêng tư tuyệt đối cho khách hàng.</p>
                    </div>
                </div>
                <div class="feat-item">
                    <i class="fa-solid fa-bell"></i>
                    <div>
                        <h4>Phục vụ phòng 24/7</h4>
                        <p>Luôn sẵn sàng đáp ứng mọi yêu cầu của bạn bất cứ lúc nào.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="values-section">
        <div class="container text-center">
            <span class="sub-title">TẠI SAO CHỌN CHÚNG TÔI</span>

            <div class="values-grid">

                <div class="value-card">
                    <i class="fa-solid fa-wallet"></i>
                    <h3>Giá cả hợp lý</h3>
                    <p>
                        Phù hợp với nhu cầu lưu trú phổ thông và tiết kiệm chi phí.
                    </p>
                </div>

                <div class="value-card">
                    <i class="fa-solid fa-bed"></i>
                    <h3>Phòng sạch sẽ</h3>
                    <p>
                        Không gian nghỉ ngơi được vệ sinh thường xuyên và gọn gàng.
                    </p>
                </div>

                <div class="value-card">
                    <i class="fa-solid fa-map-location-dot"></i>
                    <h3>Vị trí thuận tiện</h3>
                    <p>
                        Dễ dàng di chuyển đến các khu vực trung tâm và địa điểm du lịch.
                    </p>
                </div>

                <div class="value-card">
                    <i class="fa-solid fa-headset"></i>
                    <h3>Hỗ trợ thân thiện</h3>
                    <p>
                        Nhân viên luôn sẵn sàng hỗ trợ khách hàng nhanh chóng và nhiệt tình.
                    </p>
                </div>

            </div>
        </div>
    </section>

    <section class="rooms-section container" id="phong-gia">
        <div class="section-header">
            <div>
                <span class="sub-title">PHÒNG & SUITES</span>
                <h2>Không gian sống thoải mái</h2>
            </div>
            <a href="${pageContext.request.contextPath}/rooms" class="btn-outline" style="display: inline-block; text-align: center;">Xem tất cả phòng</a>
        </div>

        <div class="rooms-grid">

            <c:forEach items="${featuredRooms}" var="room">

                <div class="room-card">

                    <div class="room-img-container">

                        <img src="${room.imageUrl}"
                             alt="${room.typeName}">

                        <c:if test="${room.availableCount > 0}">
                            <span class="room-tag">Còn phòng</span>
                        </c:if>

                    </div>

                    <div class="room-info">

                        <h3>${room.typeName}</h3>

                        <p>${room.description}</p>

                        <div class="room-meta">

                            <span>
                                <i class="fa-solid fa-maximize"></i>
                                ${room.area}
                            </span>

                            <span>
                                <i class="fa-solid fa-bed"></i>
                                ${room.bedType}
                            </span>

                        </div>

                        <div class="room-footer">

                            <span class="room-price">
                                <fmt:formatNumber value="${room.basePrice}"
                                                  type="number"/>
                                đ
                                <span>/ đêm</span>
                            </span>

                            <a href="${pageContext.request.contextPath}/rooms/detail?id=${room.typeId}"
                               class="btn-sm"
                               style="display:inline-block;text-align:center;">
                                Chi tiết
                            </a>

                        </div>

                    </div>

                </div>

            </c:forEach>

        </div>
    </section>

    <section class="services-section" id="dich-vu">
    <div class="container text-center">

        <span class="sub-title">DỊCH VỤ</span>
        <h2>Các tiện ích cơ bản</h2>

        <div class="services-grid">

            <c:forEach items="${services}" var="service">

                <div class="service-card">

                    <div class="service-icon">

                        <c:choose>

                            <c:when test="${service.serviceName eq 'Bữa sáng Buffet'}">
                                <i class="fa-solid fa-utensils"></i>
                            </c:when>

                            <c:when test="${service.serviceName eq 'Giặt ủi quần áo'}">
                                <i class="fa-solid fa-shirt"></i>
                            </c:when>

                            <c:when test="${service.serviceName eq 'Đưa đón sân bay'}">
                                <i class="fa-solid fa-car-side"></i>
                            </c:when>

                            <c:when test="${service.serviceName eq 'Spa thư giãn'}">
                                <i class="fa-solid fa-spa"></i>
                            </c:when>

                            <c:otherwise>
                                <i class="fa-solid fa-concierge-bell"></i>
                            </c:otherwise>

                        </c:choose>

                    </div>

                    <h3>${service.serviceName}</h3>

                    <p>${service.description}</p>

                </div>

            </c:forEach>

        </div>

    </div>
</section>

    <section class="testimonial-section text-center">
        <div class="container">
            <i class="fa-solid fa-quote-left quote-icon"></i>
            <p class="testimonial-text">"Kỳ nghỉ tại đây thật sự vượt xa mong đợi của tôi. Từ quy trình nhận phòng thông minh đến sự chu đáo của đội ngũ nhân viên, tất cả đều toát lên vẻ chuyên nghiệp và sang trọng."</p>
            <div class="stars">
                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
            </div>
            <div class="client-info">
                <h4>Nguyễn Thúy Vân</h4>
                <span>Giám đốc Điều hành - VinTech</span>
            </div>
        </div>
    </section>

    <%-- Nhúng Footer kết thúc trang --%>
    <%@ include file="../../includes/footer.jsp" %>