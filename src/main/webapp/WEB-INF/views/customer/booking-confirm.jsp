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
        <h1>Xác nhận thông tin đặt phòng</h1>
        <p>Vui lòng kiểm tra lại kỹ các thông tin trước khi hoàn tất thủ tục</p>
    </header>

    <main class="container">
        <div class="confirm-container">
            <div class="booking-card">
                <h2 class="booking-card-title">Chi tiết đặt phòng</h2>

                <%-- Error Notification --%>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        <i class="fa-solid fa-triangle-exclamation"></i>
                        <span>${error}</span>
                    </div>
                </c:if>

                <div class="confirm-details-list">
                    <div class="confirm-item">
                        <span class="confirm-label">Khách lưu trú</span>
                        <span class="confirm-val"><c:out value="${booking.customerName}" /></span>
                    </div>
                    <div class="confirm-item">
                        <span class="confirm-label">Loại phòng</span>
                        <span class="confirm-val"><c:out value="${booking.roomTypeName}" /></span>
                    </div>
                    <div class="confirm-item">
                        <span class="confirm-label">Số lượng phòng</span>
                        <span class="confirm-val">${booking.roomQuantity} phòng</span>
                    </div>
                    <div class="confirm-item">
                        <span class="confirm-label">Ngày nhận phòng (Check-in)</span>
                        <span class="confirm-val"><fmt:formatDate value="${booking.checkInDate}" pattern="dd/MM/yyyy" /></span>
                    </div>
                    <div class="confirm-item">
                        <span class="confirm-label">Ngày trả phòng (Check-out)</span>
                        <span class="confirm-val"><fmt:formatDate value="${booking.checkOutDate}" pattern="dd/MM/yyyy" /></span>
                    </div>
                    <div class="confirm-item">
                        <span class="confirm-label">Số đêm lưu trú</span>
                        <span class="confirm-val">${sessionScope.draftNights} đêm</span>
                    </div>
                    <div class="confirm-item">
                        <span class="confirm-label">Đơn giá phòng / đêm</span>
                        <span class="confirm-val"><fmt:formatNumber value="${sessionScope.draftBasePrice}" pattern="#,###" />đ</span>
                    </div>
                    <c:if test="${not empty booking.note}">
                        <div class="confirm-item" style="flex-direction: column; align-items: flex-start; gap: 8px;">
                            <span class="confirm-label">Yêu cầu đặc biệt</span>
                            <div class="note-box" style="width: 100%; box-sizing: border-box; text-align: left;"><c:out value="${booking.note}" /></div>
                        </div>
                    </c:if>
                </div>

                <%-- Pricing calculations card --%>
                <div class="confirm-total-box">
                    <div class="confirm-total-row">
                        <span class="confirm-total-title">Tổng tiền phòng</span>
                        <span class="confirm-total-val"><fmt:formatNumber value="${booking.totalAmount}" pattern="#,###" />đ</span>
                    </div>
                    
                    <%-- Deposit amount calculation --%>
                    <c:set var="depositValue" value="${booking.totalAmount * sessionScope.draftDepositPercent / 100}" />
                    <div class="confirm-total-row" style="margin-top: 10px; padding-top: 10px; border-top: 1px solid rgba(0, 86, 179, 0.1);">
                        <span class="confirm-deposit-title">Tiền cọc yêu cầu (${sessionScope.draftDepositPercent}%)</span>
                        <span class="confirm-deposit-val"><fmt:formatNumber value="${depositValue}" pattern="#,###" />đ</span>
                    </div>
                </div>

                <%-- Form to submit booking --%>
                <form action="${pageContext.request.contextPath}/booking/confirm" method="POST" style="margin-top: 30px;">
                    <button type="submit" class="btn-primary-action">
                        <i class="fa-solid fa-circle-check"></i> Xác nhận và hoàn tất đặt phòng
                    </button>
                    <button type="button" onclick="window.history.back();" class="btn-outline-action">
                        <i class="fa-solid fa-pen-to-square"></i> Quay lại chỉnh sửa thông tin
                    </button>
                </form>

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

</body>
</html>
