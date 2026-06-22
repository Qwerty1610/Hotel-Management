<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ include file="../../includes/taglibs.jsp" %>
        <%@ include file="../../includes/header.jsp" %>

            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer_booking.css?v=21" />
            <fmt:setLocale value="vi_VN" />

            <style>
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

                .badge {
                    white-space: nowrap !important;
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
                                            <a href="${pageContext.request.contextPath}/customer/services">
                                                <i class="fa-solid fa-bell-concierge"
                                                    style="width: 20px; text-align: center;"></i> Yêu cầu dịch vụ
                                            </a>
                                        </li>
                                        <li>
                                            <a href="${pageContext.request.contextPath}/customer/services/history"
                                                class="active-sidebar-item">
                                                <i class="fa-solid fa-clock-rotate-left"
                                                    style="width: 20px; text-align: center;"></i> Lịch sử yêu cầu
                                            </a>
                                        </li>
                                    </ul>
                                </div>

                                <!-- Right Content Area -->
                                <div style="flex-grow: 1; display: flex; flex-direction: column; gap: 30px;">

                                    <!-- Lịch sử yêu cầu -->
                                    <div class="booking-card" style="padding: 0; overflow: auto; margin-bottom: 0;">
                                        <div style="padding: 30px 30px 20px 30px;">
                                            <h2
                                                style="font-size: 20px; font-weight: 800; color: var(--text-navy); margin: 0;">
                                                Lịch sử yêu cầu dịch vụ
                                            </h2>
                                            <p style="color: var(--text-muted); margin: 6px 0 0 0; font-size: 14.5px;">
                                                Xem danh sách và trạng thái các yêu cầu dịch vụ phòng của bạn</p>
                                        </div>

                                        <table class="booking-list-table">
                                            <thead>
                                                <tr>
                                                    <th>Mã yêu cầu</th>
                                                    <th>Ngày yêu cầu</th>
                                                    <th>Đặt phòng</th>
                                                    <th>Phòng</th>
                                                    <th>Dịch vụ</th>
                                                    <th>Mô tả</th>
                                                    <th>Trạng thái</th>
                                                    <th>Hành động</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:choose>
                                                    <c:when test="${not empty requests}">
                                                        <c:forEach var="r" items="${requests}">
                                                            <tr>
                                                                <td style="font-weight: 700;">#${r.requestId}</td>
                                                                <td>
                                                                    <fmt:formatDate value="${r.createdAt}"
                                                                        pattern="dd/MM/yyyy HH:mm" />
                                                                </td>
                                                                <td
                                                                    style="font-weight: 600; color: var(--primary-indigo);">
                                                                    #${r.bookingId}
                                                                </td>
                                                                <td style="font-weight: 600;">
                                                                    <c:choose>
                                                                        <c:when test="${not empty r.roomNumber}">
                                                                            Phòng ${r.roomNumber}
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span
                                                                                style="color: var(--text-muted); font-style: italic; font-weight: 500;">Chưa
                                                                                nhận phòng</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td style="font-weight: 700; color: var(--brand-blue);">
                                                                    ${r.title}
                                                                </td>
                                                                <td style="max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"
                                                                    title="${r.description}">
                                                                    ${r.description}
                                                                </td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${r.status eq 'Pending'}">
                                                                            <span class="badge badge-pending">Chờ xử lý</span>
                                                                        </c:when>
                                                                        <c:when test="${r.status eq 'InProgress'}">
                                                                            <span class="badge badge-checkedin">Đang thực hiện</span>
                                                                        </c:when>
                                                                        <c:when test="${r.status eq 'Completed'}">
                                                                            <span class="badge badge-confirmed">Đã hoàn thành</span>
                                                                        </c:when>
                                                                        <c:when test="${r.status eq 'Cancelled'}">
                                                                            <span class="badge badge-cancelled">Đã hủy</span>
                                                                        </c:when>
                                                                    </c:choose>
                                                                </td>
                                                                <td>
                                                                    <c:if test="${r.status eq 'Pending'}">
                                                                        <button type="button" class="btn-danger"
                                                                            style="padding: 6px 12px; font-size: 13px;"
                                                                            onclick="confirmCancelRequest('${r.requestId}')">
                                                                            Hủy
                                                                        </button>
                                                                    </c:if>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <tr>
                                                            <td colspan="8"
                                                                style="text-align: center; padding: 40px; color: var(--text-muted);">
                                                                <i class="fa-solid fa-bell-slash"
                                                                    style="font-size: 40px; margin-bottom: 15px; display: block; color: #cbd5e1;"></i>
                                                                Bạn chưa gửi yêu cầu dịch vụ nào.
                                                            </td>
                                                        </tr>
                                                    </c:otherwise>
                                                </c:choose>
                                            </tbody>
                                        </table>
                                    </div>

                                </div>
                            </div>
                    </div>

                    <%-- Cancel Request Confirmation Form --%>
                        <form action="${pageContext.request.contextPath}/customer/services/cancel" method="POST"
                            id="cancelRequestForm" style="display: none;">
                            <input type="hidden" name="requestId" id="cancelRequestId" value="" />
                        </form>

                        <%-- Footer --%>
                            <footer class="footer-white" id="lien-he" style="margin-top: 80px;">
                                <div class="footer-white-grid">
                                    <div class="footer-white-about">
                                        <h3>HotelOps Pro</h3>
                                        <p>Hệ thống quản lý và nghỉ dưỡng đẳng cấp quốc tế, đem lại trải nghiệm sang
                                            trọng vượt thời gian.</p>
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
                                        <span class="phone-number-white"><i class="fa-solid fa-phone"></i> 1900
                                            6789</span>
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

                                function confirmCancelRequest(requestId) {
                                    if (confirm("Bạn có chắc chắn muốn hủy yêu cầu dịch vụ #" + requestId + " không?")) {
                                        document.getElementById('cancelRequestId').value = requestId;
                                        document.getElementById('cancelRequestForm').submit();
                                    }
                                }
                            </script>
            </body>

            </html>