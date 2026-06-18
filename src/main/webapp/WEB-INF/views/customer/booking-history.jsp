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
                       style="background: var(--brand-blue); color: white; padding: 8px 16px; border-radius: 100px; font-size: 14px; font-weight: 600; text-decoration: none; transition: all 0.2s ease;">Lịch sử</a>
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
        <h1>Lịch sử đặt phòng</h1>
        <p>Theo dõi và quản lý các kỳ nghỉ dưỡng của bạn tại HotelOps</p>
    </header>

    <main class="container">
        
        <%-- Alerts --%>
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success">
                <i class="fa-solid fa-circle-check"></i>
                <span>${successMessage}</span>
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger">
                <i class="fa-solid fa-circle-xmark"></i>
                <span>${errorMessage}</span>
            </div>
        </c:if>

        <div class="history-section">
            <div class="history-title-row">
                <h2>Danh sách đơn đặt phòng</h2>
                <a href="${pageContext.request.contextPath}/rooms" class="btn-primary-action" style="width: auto; height: 38px; padding: 0 16px; font-size: 13px;">
                    <i class="fa-solid fa-plus"></i> Đặt thêm phòng
                </a>
            </div>

            <c:choose>
                <c:when test="${not empty bookings}">
                    <div class="history-table-container">
                        <table class="history-table">
                            <thead>
                                <tr>
                                    <th>Mã đặt phòng</th>
                                    <th>Loại phòng</th>
                                    <th>Số lượng</th>
                                    <th>Thời gian lưu trú</th>
                                    <th>Tổng tiền</th>
                                    <th>Trạng thái</th>
                                    <th style="text-align: center;">Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="b" items="${bookings}">
                                    <tr>
                                        <td class="booking-id">#${b.bookingId}</td>
                                        <td style="font-weight: 600; color: var(--text-navy);"><c:out value="${b.roomTypeName}" /></td>
                                        <td>${b.roomQuantity} phòng</td>
                                        <td class="booking-dates">
                                            <fmt:formatDate value="${b.checkInDate}" pattern="dd/MM/yyyy" /> 
                                            <i class="fa-solid fa-arrow-right-long" style="font-size: 11px; margin: 0 6px; color: #94a3b8;"></i>
                                            <fmt:formatDate value="${b.checkOutDate}" pattern="dd/MM/yyyy" />
                                        </td>
                                        <td class="booking-amount"><fmt:formatNumber value="${b.totalAmount}" pattern="#,###" />đ</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${b.status eq 'Pending'}">
                                                    <span class="status-badge status-pending">
                                                        <i class="fa-solid fa-clock"></i> Chờ xác nhận
                                                    </span>
                                                </c:when>
                                                <c:when test="${b.status eq 'Confirmed'}">
                                                    <span class="status-badge status-confirmed">
                                                        <i class="fa-solid fa-circle-check"></i> Đã xác nhận
                                                    </span>
                                                </c:when>
                                                <c:when test="${b.status eq 'CheckedIn'}">
                                                    <span class="status-badge status-checkedin">
                                                        <i class="fa-solid fa-key"></i> Đã nhận phòng
                                                    </span>
                                                </c:when>
                                                <c:when test="${b.status eq 'CheckedOut'}">
                                                    <span class="status-badge status-checkedout">
                                                        <i class="fa-solid fa-circle-user"></i> Đã trả phòng
                                                    </span>
                                                </c:when>
                                                <c:when test="${b.status eq 'Cancelled'}">
                                                    <span class="status-badge status-cancelled">
                                                        <i class="fa-solid fa-ban"></i> Đã huỷ
                                                    </span>
                                                </c:when>
                                                <c:when test="${b.status eq 'Rejected'}">
                                                    <span class="status-badge status-rejected">
                                                        <i class="fa-solid fa-circle-xmark"></i> Từ chối
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge status-cancelled">${b.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align: center;">
                                            <div class="history-actions" style="justify-content: center;">
                                                <a href="${pageContext.request.contextPath}/customer/booking/detail?bookingId=${b.bookingId}" 
                                                   class="btn-sm-action btn-sm-view" title="Xem chi tiết đơn đặt phòng">
                                                    <i class="fa-solid fa-eye"></i> Chi tiết
                                                </a>
                                                
                                                <%-- Check if cancelable: Pending or Confirmed --%>
                                                <c:if test="${b.status eq 'Pending' or b.status eq 'Confirmed'}">
                                                    <form action="${pageContext.request.contextPath}/customer/booking/history" method="POST" style="margin: 0;"
                                                          onsubmit="return confirm('Bạn có chắc chắn muốn huỷ đơn đặt phòng #${b.bookingId} này không?');">
                                                        <input type="hidden" name="action" value="cancel" />
                                                        <input type="hidden" name="bookingId" value="${b.bookingId}" />
                                                        <button type="submit" class="btn-sm-action btn-sm-cancel" title="Huỷ đơn đặt phòng">
                                                            <i class="fa-solid fa-trash-can"></i> Huỷ
                                                        </button>
                                                    </form>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                
                <c:otherwise>
                    <%-- Empty State --%>
                    <div class="history-empty">
                        <i class="fa-solid fa-box-open"></i>
                        <h3>Bạn chưa có giao dịch đặt phòng nào</h3>
                        <p>Hãy khám phá các loại phòng sang trọng và đặt ngay kỳ nghỉ đầu tiên của bạn.</p>
                        <a href="${pageContext.request.contextPath}/rooms" class="btn-primary-action" style="display: inline-flex; width: auto; padding: 0 24px; text-decoration: none;">
                            Tìm kiếm phòng ngay
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>

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

</body>
</html>
