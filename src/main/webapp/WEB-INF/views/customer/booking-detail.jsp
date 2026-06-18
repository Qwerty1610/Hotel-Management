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
        <h1>Chi tiết đơn đặt phòng #${booking.bookingId}</h1>
        <p>Xem trạng thái, thời gian lưu trú và số phòng được chỉ định</p>
    </header>

    <main class="container">
        <div class="detail-container">
            <div class="detail-main-card">
                
                <%-- Status Banner --%>
                <c:choose>
                    <c:when test="${booking.status eq 'Pending'}">
                        <div class="detail-status-banner banner-pending">
                            <span class="detail-status-title"><i class="fa-solid fa-clock"></i> Chờ xác nhận</span>
                            <span>Đơn đặt phòng đang được hệ thống xử lý</span>
                        </div>
                    </c:when>
                    <c:when test="${booking.status eq 'Confirmed'}">
                        <div class="detail-status-banner banner-confirmed">
                            <span class="detail-status-title"><i class="fa-solid fa-circle-check"></i> Đã xác nhận</span>
                            <span>Đơn đặt phòng đã được duyệt thành công</span>
                        </div>
                    </c:when>
                    <c:when test="${booking.status eq 'CheckedIn'}">
                        <div class="detail-status-banner banner-checkedin">
                            <span class="detail-status-title"><i class="fa-solid fa-key"></i> Đã nhận phòng</span>
                            <span>Quý khách đang lưu trú tại khách sạn</span>
                        </div>
                    </c:when>
                    <c:when test="${booking.status eq 'CheckedOut'}">
                        <div class="detail-status-banner banner-checkedout">
                            <span class="detail-status-title"><i class="fa-solid fa-circle-user"></i> Đã trả phòng</span>
                            <span>Cảm ơn quý khách đã tin tưởng và lựa chọn HotelOps</span>
                        </div>
                    </c:when>
                    <c:when test="${booking.status eq 'Cancelled'}">
                        <div class="detail-status-banner banner-cancelled">
                            <span class="detail-status-title"><i class="fa-solid fa-ban"></i> Đã huỷ</span>
                            <span>Đơn đặt phòng này đã bị huỷ</span>
                        </div>
                    </c:when>
                    <c:when test="${booking.status eq 'Rejected'}">
                        <div class="detail-status-banner banner-rejected">
                            <span class="detail-status-title"><i class="fa-solid fa-circle-xmark"></i> Từ chối</span>
                            <span>Không thể sắp xếp phòng theo yêu cầu</span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="detail-status-banner banner-cancelled">
                            <span class="detail-status-title">${booking.status}</span>
                        </div>
                    </c:otherwise>
                </c:choose>

                <%-- Body Content --%>
                <div class="detail-body">
                    
                    <%-- Stay Info --%>
                    <div class="detail-section-title"><i class="fa-solid fa-calendar-days"></i> Thông tin thời gian & Phòng</div>
                    <div class="detail-grid-2">
                        <div class="detail-item-box">
                            <span class="detail-label">Ngày nhận phòng (Check-in)</span>
                            <span class="detail-value"><fmt:formatDate value="${booking.checkInDate}" pattern="dd/MM/yyyy" /> (14:00)</span>
                        </div>
                        <div class="detail-item-box">
                            <span class="detail-label">Ngày trả phòng (Check-out)</span>
                            <span class="detail-value"><fmt:formatDate value="${booking.checkOutDate}" pattern="dd/MM/yyyy" /> (12:00)</span>
                        </div>
                        <div class="detail-item-box">
                            <span class="detail-label">Thời gian lưu trú</span>
                            <span class="detail-value">${booking.nights} đêm</span>
                        </div>
                        <div class="detail-item-box">
                            <span class="detail-label">Loại phòng đặt</span>
                            <span class="detail-value"><c:out value="${booking.roomTypeName}" /> (${booking.roomQuantity} phòng)</span>
                        </div>
                    </div>

                    <%-- Physical Rooms --%>
                    <div class="detail-section-title"><i class="fa-solid fa-door-open"></i> Phòng vật lý được chỉ định</div>
                    <c:choose>
                        <c:when test="${not empty assignedRooms}">
                            <div class="assigned-rooms-container">
                                <c:forEach var="room" items="${assignedRooms}">
                                    <div class="room-badge-pill">
                                        <i class="fa-solid fa-door-closed"></i> Phòng ${room.roomNumber}
                                    </div>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <p style="font-size: 14px; color: var(--text-muted); margin: 0; font-style: italic;">
                                Nhân viên chưa xếp phòng cụ thể. Số phòng sẽ hiển thị trước giờ nhận phòng của bạn.
                            </p>
                        </c:otherwise>
                    </c:choose>

                    <%-- Guest Profile --%>
                    <div class="detail-section-title"><i class="fa-solid fa-user-tag"></i> Thông tin khách hàng</div>
                    <div class="detail-grid-2">
                        <div class="detail-item-box">
                            <span class="detail-label">Khách lưu trú</span>
                            <span class="detail-value"><c:out value="${booking.customerName}" /></span>
                        </div>
                        <c:if test="${not empty customer}">
                            <div class="detail-item-box">
                                <span class="detail-label">Tài khoản đặt</span>
                                <span class="detail-value"><c:out value="${customer.fullName}" /></span>
                            </div>
                            <div class="detail-item-box">
                                <span class="detail-label">Email liên hệ</span>
                                <span class="detail-value"><c:out value="${customer.email}" /></span>
                            </div>
                            <div class="detail-item-box">
                                <span class="detail-label">Số điện thoại</span>
                                <span class="detail-value"><c:out value="${customer.phone}" /></span>
                            </div>
                        </c:if>
                    </div>

                    <%-- Special Requests Note --%>
                    <c:if test="${not empty booking.note}">
                        <div class="detail-section-title"><i class="fa-solid fa-message"></i> Yêu cầu đặc biệt</div>
                        <div class="note-box"><c:out value="${booking.note}" /></div>
                    </c:if>

                    <%-- Billing Details --%>
                    <div class="detail-section-title"><i class="fa-solid fa-receipt"></i> Chi tiết thanh toán</div>
                    <div class="detail-grid-2">
                        <div class="detail-item-box">
                            <span class="detail-label">Tổng chi phí dự kiến</span>
                            <span class="detail-value" style="font-size: 18px; color: var(--brand-blue);"><fmt:formatNumber value="${booking.totalAmount}" pattern="#,###" />đ</span>
                        </div>
                        <c:if test="${not empty roomType}">
                            <div class="detail-item-box">
                                <span class="detail-label">Tiền cọc yêu cầu (${roomType.depositPercent}%)</span>
                                <span class="detail-value" style="font-size: 16px; color: var(--gold-price-dark);"><fmt:formatNumber value="${booking.totalAmount * roomType.depositPercent / 100}" pattern="#,###" />đ</span>
                            </div>
                        </c:if>
                    </div>

                    <%-- Actions area --%>
                    <div class="detail-actions-footer">
                        <a href="${pageContext.request.contextPath}/customer/booking/history" class="btn-outline-action" style="width: auto; margin: 0;">
                            <i class="fa-solid fa-arrow-left"></i> Quay lại lịch sử
                        </a>
                        
                        <c:if test="${booking.status eq 'Pending' or booking.status eq 'Confirmed'}">
                            <form action="${pageContext.request.contextPath}/customer/booking/history" method="POST" style="margin: 0;"
                                  onsubmit="return confirm('Bạn có chắc chắn muốn huỷ đơn đặt phòng này không?');">
                                <input type="hidden" name="action" value="cancel" />
                                <input type="hidden" name="bookingId" value="${booking.bookingId}" />
                                <button type="submit" class="btn-primary-action" style="background-color: #ef4444; width: auto; padding: 0 20px;">
                                    <i class="fa-solid fa-trash-can"></i> Huỷ đơn đặt phòng
                                </button>
                            </form>
                        </c:if>
                    </div>

                </div>

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
