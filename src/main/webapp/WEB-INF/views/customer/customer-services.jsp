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
                        <div class="logo">HotelOps</div>
                        <ul class="nav-links">
                            <li><a href="${pageContext.request.contextPath}/">Trang chủ</a></li>
                            <li><a href="${pageContext.request.contextPath}/customer/services" class="active">Dịch vụ</a></li>
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
                                                        <i class="fa-solid fa-id-card"></i> Hồ sơ
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/bookings"
                                                        class="dropdown-item">
                                                        <i class="fa-solid fa-calendar-check"></i> Đặt phòng của tôi
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/services"
                                                        class="dropdown-item">
                                                        <i class="fa-solid fa-bell-concierge"></i> Yêu cầu dịch vụ
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/services/history"
                                                        class="dropdown-item">
                                                        <i class="fa-solid fa-clock-rotate-left"></i> Lịch sử yêu cầu
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
                                                <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                                            </a>
                                        </div>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/home/login" class="btn-login">Đăng
                                        nhập</a>
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
                                        <strong>Thành công:</strong> ${successMessage}
                                    </div>
                                </div>
                            </c:if>
                            <c:if test="${not empty errorMessage}">
                                <div class="error-banner" id="serverValidationError">
                                    <i class="fa-solid fa-circle-exclamation" style="font-size: 20px;"></i>
                                    <div>
                                        <strong>Lỗi:</strong> ${errorMessage}
                                    </div>
                                </div>
                            </c:if>

                            <div style="display: flex; gap: 30px; align-items: start; margin-top: 20px;">
                                <!-- Left Sidebar Navigation -->
                                <div class="sidebar-menu"
                                    style="width: 260px; flex-shrink: 0; background: #ffffff; border-radius: 20px; border: 1px solid #e2e8f0; padding: 24px; box-shadow: 0 4px 20px rgba(0,0,0,0.04);">
                                    <h3
                                        style="font-size: 11px; font-weight: 700; color: #94a3b8; text-transform: uppercase; letter-spacing: 1px; margin-top: 0; margin-bottom: 20px;">
                                        Dịch vụ</h3>
                                    <ul
                                        style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 8px;">
                                        <li>
                                            <a href="${pageContext.request.contextPath}/customer/services"
                                                class="active-sidebar-item">
                                                <i class="fa-solid fa-bell-concierge"
                                                    style="width: 20px; text-align: center;"></i> Yêu cầu dịch vụ
                                            </a>
                                        </li>
                                        <li>
                                            <a href="${pageContext.request.contextPath}/customer/services/history">
                                                <i class="fa-solid fa-clock-rotate-left"
                                                    style="width: 20px; text-align: center;"></i> Lịch sử yêu cầu
                                            </a>
                                        </li>
                                    </ul>
                                </div>

                                <!-- Right Content Area -->
                                <div style="flex-grow: 1; display: flex; flex-direction: column; gap: 30px;">

                                    <!-- Tạo yêu cầu mới -->
                                    <div class="booking-card" style="padding: 30px; margin-bottom: 0;">
                                        <h2
                                            style="font-size: 20px; font-weight: 800; color: var(--text-navy); margin-top: 0; margin-bottom: 24px; display: flex; align-items: center; gap: 10px;">
                                            <i class="fa-solid fa-circle-plus"
                                                style="color: var(--brand-blue); font-size: 22px;"></i> Tạo yêu cầu mới
                                        </h2>

                                        <c:choose>
                                            <c:when test="${empty bookings}">
                                                <div
                                                    style="padding: 20px; text-align: center; background-color: #f8fafc; border-radius: 12px; color: var(--text-muted); font-size: 14.5px;">
                                                    <i class="fa-solid fa-hotel"
                                                        style="font-size: 32px; display: block; margin-bottom: 12px; color: #cbd5e1;"></i>
                                                    Bạn cần có đơn đặt phòng đang hoạt động (Đã xác nhận hoặc Đã nhận
                                                    phòng) để gửi yêu cầu dịch vụ.
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <form action="${pageContext.request.contextPath}/customer/services"
                                                    method="POST">
                                                    <div class="form-grid"
                                                        style="grid-template-columns: 1fr 1fr; gap: 24px;">
                                                        <div class="form-group">
                                                            <label for="bookingId">Đặt phòng</label>
                                                            <select name="bookingId" id="bookingId" required>
                                                                <c:forEach var="b" items="${bookings}">
                                                                    <option value="${b.bookingId}">
                                                                        #${b.bookingId} (${b.roomTypeName}) <c:if
                                                                            test="${not empty b.assignedRoomsStr}">-
                                                                            Phòng ${b.assignedRoomsStr}</c:if>
                                                                    </option>
                                                                </c:forEach>
                                                            </select>
                                                        </div>
                                                        <div class="form-group">
                                                            <label for="serviceName">Loại dịch vụ</label>
                                                            <select name="serviceName" id="serviceName" required>
                                                                <c:forEach var="s" items="${allActiveServices}">
                                                                    <option value="${s.serviceName}">
                                                                        ${s.serviceName}
                                                                    </option>
                                                                </c:forEach>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div
                                                        style="display: flex; justify-content: flex-end; margin-top: 24px;">
                                                        <button type="submit" class="btn-primary"
                                                            style="margin-top: 0; width: auto; padding: 12px 30px; font-weight: 700; font-size: 15px; display: flex; align-items: center; gap: 8px;">
                                                            <i class="fa-solid fa-paper-plane"></i> Gửi yêu cầu
                                                        </button>
                                                    </div>
                                                </form>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <!-- Danh sách dịch vụ khách sạn -->
                                    <div class="booking-card" style="padding: 30px; margin-bottom: 0;">
                                        <h2
                                            style="font-size: 20px; font-weight: 800; color: var(--text-navy); margin-top: 0; margin-bottom: 24px;">
                                            Danh sách dịch vụ khách sạn
                                        </h2>

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

                                        <!-- PHÂN TRANG -->
                                        <c:if test="${totalPages > 1}">
                                            <div class="table-pagination-bar">
                                                <div class="pagination-info">
                                                    Hiển thị ${(currentPage-1)*pageSize + 1}-${currentPage*pageSize gt totalItems ? totalItems : currentPage*pageSize} trong số ${totalItems} dịch vụ
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
                                    <p>Hệ thống quản lý và nghỉ dưỡng đẳng cấp quốc tế, đem lại trải nghiệm sang trọng
                                        vượt thời gian.</p>
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
                                    <p><i class="fa-solid fa-location-dot"></i> 123 Đường Lê Lợi, Quận 1, TP. Hồ Chí
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
                            });
                        </script>
            </body>

            </html>