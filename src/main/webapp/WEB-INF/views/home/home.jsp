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
                <li><a href="#trang-chu" class="active"><fmt:message key="nav.home" /></a></li>
                <li><a href="#gioi-thieu"><fmt:message key="nav.about" /></a></li>
                <li><a href="#phong-gia"><fmt:message key="nav.rooms" /></a></li>
                <li><a href="#dich-vu"><fmt:message key="nav.services" /></a></li>
                <li><a href="#lien-he"><fmt:message key="nav.contact" /></a></li>
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
                                            <i class="fa-solid fa-id-card"></i> <fmt:message key="nav.profile" />
                                        </a>
                                        <a href="${pageContext.request.contextPath}/customer/bookings" class="dropdown-item">
                                            <i class="fa-solid fa-calendar-check"></i> <fmt:message key="nav.mybookings" />
                                        </a>
                                        <a href="${pageContext.request.contextPath}/customer/feedbacks" class="dropdown-item">
                                            <i class="fa-solid fa-star"></i> Đánh giá lưu trú
                                        </a>
                                        <a href="${pageContext.request.contextPath}/customer/booking/change" class="dropdown-item">
                                            <i class="fa-solid fa-pen-to-square"></i> Thay đổi đặt phòng
                                        </a>
                                        <a href="${pageContext.request.contextPath}/customer/services" class="dropdown-item">
                                            <i class="fa-solid fa-bell-concierge"></i> <fmt:message key="nav.servicerequests" />
                                        </a>
                                        <a href="${pageContext.request.contextPath}/customer/services/history" class="dropdown-item">
                                            <i class="fa-solid fa-clock-rotate-left"></i> <fmt:message key="nav.servicehistory" />
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
                                                    <i class="fa-solid fa-chart-line"></i> <fmt:message key="nav.dashboard.admin" />
                                                </a>
                                            </c:when>
                                            <c:when test="${sessionScope.role eq 'HOTEL_MANAGER'}">
                                                <a href="${pageContext.request.contextPath}/manager/dashboard" class="dropdown-item">
                                                    <i class="fa-solid fa-chart-line"></i> <fmt:message key="nav.dashboard.manager" />
                                                </a>
                                            </c:when>
                                            <c:when test="${sessionScope.role eq 'RECEPTIONIST'}">
                                                <a href="${pageContext.request.contextPath}/receptionist/dashboard" class="dropdown-item">
                                                    <i class="fa-solid fa-chart-line"></i> <fmt:message key="nav.dashboard.receptionist" />
                                                </a>
                                            </c:when>
                                            <c:when test="${sessionScope.role eq 'HOUSEKEEPING'}">
                                                <a href="${pageContext.request.contextPath}/housekeeping/dashboard" class="dropdown-item">
                                                    <i class="fa-solid fa-broom"></i> <fmt:message key="nav.dashboard.housekeeping" />
                                                </a>
                                            </c:when>
                                        </c:choose>
                                    </c:otherwise>
                                </c:choose>
                                <div class="dropdown-divider"></div>
                                <a href="${pageContext.request.contextPath}/logout" class="dropdown-item logout-item">
                                    <i class="fa-solid fa-right-from-bracket"></i> <fmt:message key="nav.logout" />
                                </a>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/home/login" class="btn-login"><fmt:message key="nav.login" /></a>
                        <a href="${pageContext.request.contextPath}/home/register" class="btn-register"><fmt:message key="nav.register" /></a>
                    </c:otherwise>
                </c:choose>
            </div>
        </nav>

        <div class="hero-content">
            <h1><fmt:message key="hero.title" /></h1>
            <p><fmt:message key="hero.subtitle" /></p>
        </div>

    </header>

    <section class="about-section container" id="gioi-thieu">
        <div class="about-image">
            <img src="https://images.unsplash.com/photo-1439066615861-d1af74d74000?q=80&w=1200" alt="Resort HotelOps">
        </div>
        <div class="about-text">
            <span class="sub-title"><fmt:message key="about.tag" /></span>
            <h2><fmt:message key="about.title" /></h2>
            <p>
                <fmt:message key="about.desc" />
            </p>
            <div class="about-features">
                <div class="feat-item">
                    <i class="fa-solid fa-shield-halved"></i>
                    <div>
                        <h4><fmt:message key="about.feat1.title" /></h4>
                        <p><fmt:message key="about.feat1.desc" /></p>
                    </div>
                </div>
                <div class="feat-item">
                    <i class="fa-solid fa-bell"></i>
                    <div>
                        <h4><fmt:message key="about.feat2.title" /></h4>
                        <p><fmt:message key="about.feat2.desc" /></p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="values-section">
        <div class="container text-center">
            <span class="sub-title"><fmt:message key="values.tag" /></span>

            <div class="values-grid">

                <div class="value-card">
                    <i class="fa-solid fa-wallet"></i>
                    <h3><fmt:message key="values.card1.title" /></h3>
                    <p>
                        <fmt:message key="values.card1.desc" />
                    </p>
                </div>

                <div class="value-card">
                    <i class="fa-solid fa-bed"></i>
                    <h3><fmt:message key="values.card2.title" /></h3>
                    <p>
                        <fmt:message key="values.card2.desc" />
                    </p>
                </div>

                <div class="value-card">
                    <i class="fa-solid fa-map-location-dot"></i>
                    <h3><fmt:message key="values.card3.title" /></h3>
                    <p>
                        <fmt:message key="values.card3.desc" />
                    </p>
                </div>

                <div class="value-card">
                    <i class="fa-solid fa-headset"></i>
                    <h3><fmt:message key="values.card4.title" /></h3>
                    <p>
                        <fmt:message key="values.card4.desc" />
                    </p>
                </div>

            </div>
        </div>
    </section>

    <section class="rooms-section container" id="phong-gia">
        <div class="section-header">
            <div>
                <span class="sub-title"><fmt:message key="rooms.tag" /></span>
                <h2><fmt:message key="rooms.title" /></h2>
            </div>
            <a href="${pageContext.request.contextPath}/rooms" class="btn-outline" style="display: inline-block; text-align: center;"><fmt:message key="rooms.all" /></a>
        </div>

        <div class="rooms-grid">

            <c:forEach items="${featuredRooms}" var="room">

                <div class="room-card">

                    <div class="room-img-container">

                        <img src="${room.imageUrl}"
                             alt="${room.typeName}">

                        <c:if test="${room.availableCount > 0}">
                            <span class="room-tag"><fmt:message key="rooms.available" /></span>
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
                                <fmt:message key="rooms.currency" />
                                <span>/ <fmt:message key="rooms.night" /></span>
                            </span>

                            <a href="${pageContext.request.contextPath}/rooms/detail?id=${room.typeId}"
                               class="btn-sm"
                               style="display:inline-block;text-align:center;">
                                <fmt:message key="rooms.detail" />
                            </a>

                        </div>

                    </div>

                </div>

            </c:forEach>

        </div>
    </section>

    <section class="services-section" id="dich-vu">
    <div class="container text-center">

        <span class="sub-title"><fmt:message key="services.tag" /></span>
        <h2><fmt:message key="services.title" /></h2>

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
            <p class="testimonial-text"><fmt:message key="testi.quote" /></p>
            <div class="stars">
                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
            </div>
            <div class="client-info">
                <h4><fmt:message key="testi.author" /></h4>
                <span><fmt:message key="testi.role" /></span>
            </div>
        </div>
    </section>

    <%-- Nhúng Footer kết thúc trang --%>
    <%@ include file="../../includes/footer.jsp" %>