<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer_booking.css?v=21" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/booking-requests.css?v=3" />
<fmt:setLocale value="vi_VN" />

<body>

    <%-- Header Navigation --%>
    <nav class="navbar-rooms">
        <a href="${pageContext.request.contextPath}/" class="logo">HotelOps</a>
        <ul class="nav-links">
            <li><a href="${pageContext.request.contextPath}/">Trang chủ</a></li>
            <li><a href="${pageContext.request.contextPath}/rooms">Phòng</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/bookings" class="active">Đặt phòng của tôi</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/feedbacks">Đánh giá lưu trú</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/services">Dịch vụ</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/maintenance">Sự cố</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/payments">Thanh toán</a></li>
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
                            <a href="${pageContext.request.contextPath}/customer/profile"
                                                        class="dropdown-item">
                                                        <i class="fa-solid fa-id-card"></i> Hồ sơ
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/bookings"
                                                        class="dropdown-item">
                                                        <i class="fa-solid fa-calendar-check"></i> Đặt phòng của tôi
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/booking/change" class="dropdown-item">
                                                        <i class="fa-solid fa-pen-to-square"></i> Thay đổi đặt phòng
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/feedbacks"
                                                        class="dropdown-item">
                                                        <i class="fa-solid fa-star"></i> Đánh giá lưu trú
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/services"
                                                        class="dropdown-item">
                                                        <i class="fa-solid fa-bell-concierge"></i> Yêu cầu dịch vụ
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/maintenance"
                                                        class="dropdown-item">
                                                        <i class="fa-solid fa-screwdriver-wrench"></i> Yêu cầu sửa chữa
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/customer/payments" class="dropdown-item">
                                                        <i class="fa-solid fa-credit-card"></i> Thanh toán & Lịch sử
                                                    </a>
                            <a href="${pageContext.request.contextPath}/logout" class="dropdown-item logout-item">
                                <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/home/login" class="btn-login">Đăng nhập</a>
                </c:otherwise>
            </c:choose>
        </div>
    </nav>

    <div class="booking-container">
        <div class="booking-header">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
                <div>
                    <h1>Thay Đổi Đặt Phòng</h1>
                    <p>Gửi yêu cầu thay đổi đặt phòng hoặc gia hạn lưu trú. Yêu cầu sẽ được lễ tân/quản lý duyệt.</p>
                </div>
                <a href="${pageContext.request.contextPath}/customer/bookings" class="btn-secondary" style="text-decoration: none; padding: 10px 20px;">
                    <i class="fa-solid fa-arrow-left"></i> Về lịch sử đặt phòng
                </a>
            </div>
        </div>

        <%-- Alerts --%>
        <c:if test="${not empty errorCode}">
            <div class="error-banner" id="serverValidationError">
                <i class="fa-solid fa-circle-exclamation" style="font-size: 20px;"></i>
                <div>
                    <strong>Yêu cầu thất bại:</strong> <c:out value="${errorMessage}" />
                </div>
            </div>
        </c:if>

        <%-- Chooser: 2 loại yêu cầu (UC 2.3.9 Booking Change) --%>
        <div class="booking-card" style="padding: 24px; margin-bottom: 25px;">
            <div class="req-choice-list req-choice-row">
                <button type="button" class="req-choice-card" id="chooseChangeCard" onclick="showRequestSection('change')">
                    <span class="req-choice-icon change"><i class="fa-solid fa-pen-to-square"></i></span>
                    <span class="req-choice-text">
                        <strong>Yêu cầu thay đổi đặt phòng</strong>
                        <small>Đổi ngày nhận/trả phòng, loại phòng hoặc số phòng cho đơn chưa nhận phòng.</small>
                    </span>
                    <i class="fa-solid fa-chevron-right req-choice-arrow"></i>
                </button>
                <button type="button" class="req-choice-card" id="chooseExtCard" onclick="showRequestSection('extension')">
                    <span class="req-choice-icon extension"><i class="fa-solid fa-calendar-plus"></i></span>
                    <span class="req-choice-text">
                        <strong>Yêu cầu gia hạn lưu trú</strong>
                        <small>Kéo dài ngày trả phòng cho phòng bạn đang lưu trú (đã nhận phòng).</small>
                    </span>
                    <i class="fa-solid fa-chevron-right req-choice-arrow"></i>
                </button>
            </div>
        </div>

        <%-- ============================================================
             SECTION: REQUEST BOOKING CHANGE (UC 2.3.9 - luồng thay đổi)
             ============================================================ --%>
        <div class="booking-card req-section" id="changeSection" style="padding: 24px; margin-bottom: 25px; display: none;">
            <h2 class="req-section-title"><i class="fa-solid fa-pen-to-square" style="color: var(--br-blue);"></i> Yêu cầu thay đổi đặt phòng</h2>
            <p class="req-hint">
                <i class="fa-solid fa-circle-info"></i>
                Chỉ áp dụng cho đơn <strong>Chờ duyệt</strong> hoặc <strong>Đã xác nhận</strong> và còn trước ngày nhận phòng.
            </p>
            <form action="${pageContext.request.contextPath}/customer/booking/change-request" method="POST"
                  id="changeForm" onsubmit="return validateChange();">
                <div class="req-field">
                    <label>Chọn đơn đặt phòng <span class="req-star">*</span></label>
                    <select name="bookingId" id="changeBookingSelect" onchange="onChangeBookingSelect()" required>
                        <option value="">— Chọn đơn cần thay đổi —</option>
                        <c:forEach var="b" items="${bookings}">
                            <c:if test="${b.status eq 'Pending' || b.status eq 'Confirmed'}">
                                <option value="${b.bookingId}"
                                        data-checkin="<fmt:formatDate value='${b.checkInDate}' pattern='yyyy-MM-dd' />"
                                        data-checkout="<fmt:formatDate value='${b.checkOutDate}' pattern='yyyy-MM-dd' />"
                                        data-roomtype="<c:out value='${b.groupRoomTypeNames}' />">
                                    #${b.bookingId} • <c:out value="${b.groupRoomTypeNames}" />
                                    (<fmt:formatDate value="${b.checkInDate}" pattern="dd/MM/yyyy" /> - <fmt:formatDate value="${b.checkOutDate}" pattern="dd/MM/yyyy" />)
                                </option>
                            </c:if>
                        </c:forEach>
                    </select>
                </div>

                <div class="req-current" id="changeCurrent">
                    <h4>Thông tin hiện tại</h4>
                    <div class="req-current-grid">
                        <span>Các loại phòng: <b id="curChangeType">—</b></span>
                        <span>Tổng số phòng: <b id="curChangeQty">—</b></span>
                        <span>Nhận phòng: <b id="curChangeIn">—</b></span>
                        <span>Trả phòng: <b id="curChangeOut">—</b></span>
                    </div>
                </div>

                <div class="req-grid-2">
                    <div class="req-field">
                        <label>Ngày nhận phòng mới <span class="req-star">*</span></label>
                        <input type="date" name="newCheckInDate" id="changeNewIn"
                               onchange="renderChangeEstimate(); refreshAvailability();" required />
                    </div>
                    <div class="req-field">
                        <label>Ngày trả phòng mới <span class="req-star">*</span></label>
                        <input type="date" name="newCheckOutDate" id="changeNewOut"
                               onchange="renderChangeEstimate(); refreshAvailability();" required />
                    </div>
                </div>

                <%-- Bảng dòng phòng: đơn nhiều loại phòng gồm nhiều dòng, mỗi dòng
                     sửa được độc lập. Ngày nhận/trả ở trên áp cho cả đơn. --%>
                <div class="req-field">
                    <label>Các loại phòng trong đơn <span class="req-star">*</span></label>
                    <div style="overflow-x: auto;">
                        <table class="booking-list-table" id="changeRowsTable">
                            <thead>
                                <tr>
                                    <th style="min-width: 220px;">Loại phòng</th>
                                    <th style="width: 120px;">Số phòng</th>
                                    <th style="width: 160px;">Thành tiền / đêm</th>
                                    <th style="width: 60px;"></th>
                                </tr>
                            </thead>
                            <tbody id="changeRowsBody"></tbody>
                        </table>
                    </div>
                    <button type="button" class="btn-secondary" style="margin-top: 10px; padding: 8px 16px;"
                            onclick="addChangeRow()">
                        <i class="fa-solid fa-plus"></i> Thêm loại phòng
                    </button>
                </div>

                <div class="req-estimate" id="changeEstimate">
                    Tổng tiền dự kiến cho <span id="changeNights">0</span> đêm:
                    <strong id="changeNewTotal">0 VND</strong>
                    <div id="changeDeltaLine" style="margin-top: 6px;"></div>
                    <small style="display:block; margin-top:6px; color: var(--text-muted);">
                        Số liệu mang tính tham khảo, chưa gồm khuyến mãi đã áp. Lễ tân sẽ xác nhận số tiền chính thức khi duyệt.
                    </small>
                </div>

                <div class="req-field">
                    <label>Lý do thay đổi</label>
                    <textarea name="reason" maxlength="500" placeholder="VD: Thay đổi lịch trình công tác..."></textarea>
                </div>

                <div class="req-modal-footer">
                    <button type="submit" class="br-btn br-btn-submit">
                        <i class="fa-solid fa-paper-plane"></i> Gửi yêu cầu
                    </button>
                </div>
            </form>
        </div>

        <%-- ============================================================
             SECTION: REQUEST STAY EXTENSION (UC 2.3.9 - luồng gia hạn)
             ============================================================ --%>
        <div class="booking-card req-section" id="extSection" style="padding: 24px; margin-bottom: 25px; display: none;">
            <h2 class="req-section-title"><i class="fa-solid fa-calendar-plus" style="color: var(--br-gold);"></i> Yêu cầu gia hạn lưu trú</h2>
            <p class="req-hint">
                <i class="fa-solid fa-circle-info"></i>
                Chỉ áp dụng cho phòng bạn <strong>đang lưu trú (Đã nhận phòng)</strong>. Chọn ngày trả phòng mới muộn hơn để ở thêm.
            </p>
            <form action="${pageContext.request.contextPath}/customer/booking/extension-request" method="POST"
                  id="extForm" onsubmit="return validateExtension();">
                <div class="req-field">
                    <label>Chọn phòng đang lưu trú <span class="req-star">*</span></label>
                    <select name="bookingId" id="extBookingSelect" onchange="onExtBookingSelect()" required>
                        <option value="">— Chọn đơn đang lưu trú —</option>
                        <c:forEach var="b" items="${bookings}">
                            <c:if test="${b.status eq 'CheckedIn'}">
                                <option value="${b.bookingId}"
                                        data-checkout="<fmt:formatDate value='${b.checkOutDate}' pattern='yyyy-MM-dd' />"
                                        data-roomtype="<c:out value='${b.groupRoomTypeNames}' />">
                                    #${b.bookingId} • <c:out value="${b.groupRoomTypeNames}" />
                                    (Trả: <fmt:formatDate value="${b.checkOutDate}" pattern="dd/MM/yyyy" />)
                                </option>
                            </c:if>
                        </c:forEach>
                    </select>
                </div>

                <div class="req-current" id="extCurrent">
                    <h4>Thông tin hiện tại</h4>
                    <div class="req-current-grid">
                        <span>Loại phòng: <b id="curExtType">—</b></span>
                        <span>Số phòng: <b id="curExtQty">—</b></span>
                        <span>Ngày trả phòng hiện tại: <b id="curExtOut">—</b></span>
                    </div>
                </div>

                <div class="req-field">
                    <label>Ngày trả phòng mới <span class="req-star">*</span></label>
                    <input type="date" name="newCheckOutDate" id="extNewOut" onchange="updateExtEstimate()" required />
                </div>

                <div class="req-estimate" id="extEstimate">
                    Phụ phí dự kiến cho <span id="extNights">0</span> đêm:
                    <strong id="extCharge">0 VND</strong>
                </div>

                <div class="req-field">
                    <label>Lý do gia hạn</label>
                    <textarea name="reason" maxlength="500" placeholder="VD: Cần ở thêm vì công việc kéo dài..."></textarea>
                </div>

                <div class="req-modal-footer">
                    <button type="submit" class="br-btn br-btn-submit">
                        <i class="fa-solid fa-paper-plane"></i> Gửi yêu cầu
                    </button>
                </div>
            </form>
        </div>

        <%-- Request tracking (booking change & stay extension) --%>
        <c:if test="${not empty myRequests}">
            <div class="booking-card req-track-card" style="padding: 24px;">
                <h2><i class="fa-solid fa-clipboard-list" style="color: var(--brand-blue);"></i> Yêu cầu thay đổi &amp; gia hạn của tôi</h2>
                <p>Theo dõi trạng thái các yêu cầu thay đổi đặt phòng và gia hạn lưu trú của bạn.</p>
                <div style="overflow-x: auto;">
                    <table class="booking-list-table">
                        <thead>
                            <tr>
                                <th>Mã đơn</th>
                                <th>Loại yêu cầu</th>
                                <th>Chi tiết yêu cầu</th>
                                <th>Phụ phí dự kiến</th>
                                <th>Ngày gửi</th>
                                <th>Trạng thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="r" items="${myRequests}">
                                <tr>
                                    <%-- Yêu cầu thay đổi được duyệt sẽ sinh ra một đơn mới thay cho
                                         đơn cũ, nên mã đơn của khách thay đổi — phải chỉ rõ đơn mới. --%>
                                    <td style="font-weight: 700;">
                                        #${r.bookingId}
                                        <c:if test="${not empty r.newBookingId}">
                                            <br/>
                                            <small style="color: var(--text-muted); font-weight: 500;">
                                                &rarr; đơn mới <strong>#${r.newBookingId}</strong>
                                            </small>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.extension}">
                                                <span class="req-type-pill extension">Gia hạn lưu trú</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="req-type-pill change">Thay đổi đặt phòng</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="font-size: 13px;">
                                        <c:choose>
                                            <c:when test="${r.extension}">
                                                Trả phòng mới:
                                                <strong><fmt:formatDate value="${r.newCheckOut}" pattern="dd/MM/yyyy" /></strong>
                                                <br/>
                                                <small style="color: var(--text-muted);">
                                                    (Hiện tại: <fmt:formatDate value="${r.oldCheckOut}" pattern="dd/MM/yyyy" />)
                                                </small>
                                            </c:when>
                                            <c:otherwise>
                                                <strong><fmt:formatDate value="${r.newCheckIn}" pattern="dd/MM/yyyy" /> -
                                                    <fmt:formatDate value="${r.newCheckOut}" pattern="dd/MM/yyyy" /></strong>
                                                <br/>
                                                <c:choose>
                                                    <c:when test="${not empty r.items}">
                                                        <c:forEach var="it" items="${r.items}">
                                                            <small style="color: var(--text-muted); display: block;">
                                                                <c:choose>
                                                                    <c:when test="${it.remove}">
                                                                        Bỏ <c:out value="${it.oldRoomTypeName}" /> (${it.oldRoomQuantity} phòng)
                                                                    </c:when>
                                                                    <c:when test="${it.add}">
                                                                        Thêm <c:out value="${it.newRoomTypeName}" /> · ${it.newRoomQuantity} phòng
                                                                    </c:when>
                                                                    <c:when test="${it.unchanged}">
                                                                        Giữ <c:out value="${it.newRoomTypeName}" /> · ${it.newRoomQuantity} phòng
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <c:out value="${it.oldRoomTypeName}" /> (${it.oldRoomQuantity})
                                                                        &rarr; <c:out value="${it.newRoomTypeName}" /> · ${it.newRoomQuantity} phòng
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </small>
                                                        </c:forEach>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <small style="color: var(--text-muted);">Giữ nguyên loại phòng, chỉ đổi ngày</small>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="font-weight: 600; color: var(--gold-price);">
                                        <c:choose>
                                            <c:when test="${r.additionalCharge != null && r.additionalCharge > 0}">
                                                +<fmt:formatNumber value="${r.additionalCharge}" type="number" /> VND
                                            </c:when>
                                            <%-- Đổi sang phương án rẻ hơn thì chênh lệch âm: khách được hoàn lại --%>
                                            <c:when test="${r.additionalCharge != null && r.additionalCharge lt 0}">
                                                <span style="color: #16a34a;">
                                                    Hoàn <fmt:formatNumber value="${-r.additionalCharge}" type="number" /> VND
                                                </span>
                                            </c:when>
                                            <c:otherwise><span style="color: var(--text-muted);">—</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><fmt:formatDate value="${r.createdAt}" pattern="dd/MM/yyyy" /></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.status eq 'Approved'}">
                                                <span class="req-status-pill approved">Đã duyệt</span>
                                            </c:when>
                                            <c:when test="${r.status eq 'Rejected'}">
                                                <span class="req-status-pill rejected">Từ chối</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="req-status-pill pending">Chờ duyệt</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:if>
    </div>

    <%-- Footer --%>
    <footer class="footer-white" id="lien-he">
        <div class="footer-white-grid">
            <div class="footer-white-about">
                <h3>HotelOps Pro</h3>
                <p>Hệ thống quản lý và nghỉ dưỡng đẳng cấp quốc tế, đem lại trải nghiệm sang trọng vượt thời gian.</p>
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
                <p><i class="fa-solid fa-location-dot"></i> 123 Đường Lê Lợi, Quận 1, TP. Hồ Chí Minh</p>
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
        });

        const roomTypePrices = {
            <c:forEach var="rt" items="${roomTypes}">'${rt.typeId}': ${rt.basePrice},</c:forEach>
        };

        // Chi tiết từng dòng phòng của mỗi đơn, do controller dựng sẵn. Đơn nhiều
        // loại phòng có nhiều dòng nên form phải sửa được từng dòng một.
        const bookingRows = ${not empty bookingRowsJson ? bookingRowsJson : '{}'};

        // Tên loại phòng, dựng <option> bằng textContent để tên phòng dù chứa ký
        // tự đặc biệt cũng không phá cấu trúc trang.
        const roomTypeNames = {
            <c:forEach var="rt" items="${roomTypes}">'${rt.typeId}': '<c:out value="${rt.typeName}" />',</c:forEach>
        };

        // Số phòng còn trống theo loại cho khoảng ngày đang chọn, nạp từ
        // /customer/booking/availability. Rỗng nghĩa là chưa tra được — khi đó
        // form không tự chặn, cứ để server kiểm tra khi gửi.
        let availableByType = {};

        function buildRoomTypeSelect(selectedTypeId) {
            const select = document.createElement('select');
            select.name = 'itemRoomTypeId[]';
            select.required = true;
            Object.keys(roomTypeNames).forEach(id => {
                const opt = document.createElement('option');
                opt.value = id;
                select.appendChild(opt);
            });
            if (selectedTypeId) select.value = String(selectedTypeId);
            return select;
        }

        /**
         * Đồng bộ danh sách lựa chọn của mọi dòng:
         *  - loại phòng đã chọn ở dòng khác thì ẩn đi (mỗi loại chỉ một dòng),
         *  - loại phòng hết sạch phòng thì khoá lại,
         *  - nhãn kèm số phòng còn trống, và ô số lượng bị chặn trần theo đó.
         */
        /**
         * Tổng số phòng đang yêu cầu theo từng loại. Một đơn cũ có thể sẵn có
         * hai dòng cùng loại phòng (form tạo đơn không chặn), nên phải cộng lại
         * rồi mới so với tồn kho — giống hệt cách server gộp desiredByType.
         */
        function requestedByType() {
            const totals = {};
            Array.from(document.getElementById('changeRowsBody').children).forEach(tr => {
                if (tr.dataset.removed) return;
                const id = tr.querySelector('select').value;
                const qty = parseInt(tr.querySelector('input[name="itemRoomQuantity[]"]').value || '0', 10);
                totals[id] = (totals[id] || 0) + (isNaN(qty) ? 0 : qty);
            });
            return totals;
        }

        function syncRowOptions() {
            const rows = Array.from(document.getElementById('changeRowsBody').children);
            const totals = requestedByType();
            const takenElsewhere = new Set();
            rows.forEach(tr => {
                if (!tr.dataset.removed) takenElsewhere.add(tr.querySelector('select').value);
            });

            rows.forEach(tr => {
                const sel = tr.querySelector('select');
                const qty = tr.querySelector('input[name="itemRoomQuantity[]"]');
                const avail = availableByType[sel.value];

                Array.from(sel.options).forEach(opt => {
                    const isSelf = opt.value === sel.value;
                    const usedByOtherRow = takenElsewhere.has(opt.value) && !isSelf;
                    const optAvail = availableByType[opt.value];
                    const soldOut = optAvail !== undefined && optAvail <= 0;

                    opt.hidden = usedByOtherRow;
                    opt.disabled = usedByOtherRow || (soldOut && !isSelf);

                    let label = roomTypeNames[opt.value] + ' — ' + fmtVND(roomTypePrices[opt.value] || 0) + '/đêm';
                    if (optAvail !== undefined) {
                        label += optAvail > 0 ? ' · còn ' + optAvail + ' phòng' : ' · hết phòng';
                    }
                    opt.textContent = label;
                });

                // Trần số lượng theo số phòng thực còn. So theo TỔNG của loại
                // phòng đó trên mọi dòng, không so riêng từng dòng.
                if (!tr.dataset.removed && avail !== undefined) {
                    qty.max = String(Math.max(1, avail));
                    const note = tr.querySelector('.row-avail');
                    const askedForType = totals[sel.value] || 0;
                    if (avail <= 0) {
                        note.textContent = 'Hết phòng trong khoảng ngày này';
                        note.style.color = '#dc2626';
                    } else if (askedForType > avail) {
                        note.textContent = 'Chỉ còn ' + avail + ' phòng';
                        note.style.color = '#dc2626';
                    } else {
                        note.textContent = 'Còn ' + avail + ' phòng';
                        note.style.color = 'var(--text-muted)';
                    }
                }
            });
        }

        /** Tra số phòng còn trống cho khoảng ngày đang chọn rồi vẽ lại bảng. */
        function refreshAvailability() {
            const bookingId = document.getElementById('changeBookingSelect').value;
            const ci = document.getElementById('changeNewIn').value;
            const co = document.getElementById('changeNewOut').value;
            if (!bookingId || !ci || !co || nightsBetween(ci, co) < 1) {
                availableByType = {};
                syncRowOptions();
                return;
            }
            const url = '${pageContext.request.contextPath}/customer/booking/availability'
                + '?bookingId=' + encodeURIComponent(bookingId)
                + '&checkIn=' + encodeURIComponent(ci)
                + '&checkOut=' + encodeURIComponent(co);
            fetch(url)
                .then(r => r.json())
                .then(data => {
                    availableByType = (data && data.success) ? data.available : {};
                    syncRowOptions();
                })
                .catch(() => {
                    // Tra không được thì thôi, server vẫn chặn khi gửi
                    availableByType = {};
                    syncRowOptions();
                });
        }

        function todayISO() {
            const d = new Date();
            const m = String(d.getMonth() + 1).padStart(2, '0');
            const day = String(d.getDate()).padStart(2, '0');
            return d.getFullYear() + '-' + m + '-' + day;
        }
        function nightsBetween(a, b) {
            const d1 = new Date(a), d2 = new Date(b);
            return Math.round((d2 - d1) / (1000 * 60 * 60 * 24));
        }
        function fmtVND(n) {
            return new Intl.NumberFormat('vi-VN').format(Math.round(n)) + ' VND';
        }

        // ===== Chooser: hiển thị form theo loại yêu cầu được chọn =====
        function showRequestSection(type) {
            const isChange = type === 'change';

            if (isChange) {
                const sel = document.getElementById('changeBookingSelect');
                if (sel.options.length <= 1) {
                    alert('Bạn không có đơn đặt phòng nào đủ điều kiện để yêu cầu thay đổi (cần ở trạng thái Chờ duyệt hoặc Đã xác nhận).');
                    return;
                }
                const minIn = todayISO();
                document.getElementById('changeNewIn').min = minIn;
                document.getElementById('changeNewOut').min = minIn;
            } else {
                const sel = document.getElementById('extBookingSelect');
                if (sel.options.length <= 1) {
                    alert('Bạn không có phòng nào đang lưu trú (Đã nhận phòng) để gia hạn.');
                    return;
                }
            }

            document.getElementById('changeSection').style.display = isChange ? 'block' : 'none';
            document.getElementById('extSection').style.display = isChange ? 'none' : 'block';
            document.getElementById('chooseChangeCard').classList.toggle('active', isChange);
            document.getElementById('chooseExtCard').classList.toggle('active', !isChange);

            const section = document.getElementById(isChange ? 'changeSection' : 'extSection');
            section.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }

        // ===== Bảng dòng phòng của yêu cầu thay đổi =====

        /** Dựng một dòng trong bảng. bookingId rỗng = dòng phòng mới thêm. */
        function buildChangeRow(bookingId, roomTypeId, quantity) {
            const tr = document.createElement('tr');
            const isNew = !bookingId;

            const tdType = document.createElement('td');
            const select = buildRoomTypeSelect(roomTypeId);
            // Đổi loại phòng ở một dòng làm thay đổi tập loại còn chọn được ở
            // các dòng khác, nên phải vẽ lại cả bảng chứ không chỉ tính lại tiền.
            select.addEventListener('change', () => { syncRowOptions(); renderChangeEstimate(); });
            tdType.appendChild(select);
            if (isNew) {
                const badge = document.createElement('small');
                badge.style.cssText = 'display:block;margin-top:4px;color:var(--text-muted);';
                badge.textContent = 'Loại phòng thêm mới';
                tdType.appendChild(badge);
            }

            const tdQty = document.createElement('td');
            const qtyInput = document.createElement('input');
            qtyInput.type = 'number';
            qtyInput.name = 'itemRoomQuantity[]';
            qtyInput.min = '1';
            qtyInput.max = '100';
            qtyInput.required = true;
            qtyInput.value = quantity || 1;
            qtyInput.addEventListener('input', () => { syncRowOptions(); renderChangeEstimate(); });
            tdQty.appendChild(qtyInput);

            const availNote = document.createElement('small');
            availNote.className = 'row-avail';
            availNote.style.cssText = 'display:block;margin-top:4px;color:var(--text-muted);';
            tdQty.appendChild(availNote);

            const hidden = document.createElement('input');
            hidden.type = 'hidden';
            hidden.name = 'itemBookingId[]';
            hidden.value = bookingId ? String(bookingId) : '';
            tdQty.appendChild(hidden);

            const tdMoney = document.createElement('td');
            tdMoney.className = 'row-money';
            tdMoney.textContent = '—';

            const tdAction = document.createElement('td');
            const removeBtn = document.createElement('button');
            removeBtn.type = 'button';
            removeBtn.className = 'btn-secondary';
            removeBtn.style.cssText = 'padding:6px 10px;';
            removeBtn.title = 'Bỏ loại phòng này khỏi đơn';
            removeBtn.innerHTML = '<i class="fa-solid fa-trash"></i>';
            removeBtn.addEventListener('click', () => removeChangeRow(tr));
            tdAction.appendChild(removeBtn);

            tr.append(tdType, tdQty, tdMoney, tdAction);
            return tr;
        }

        /**
         * Bỏ một dòng phòng. Dòng đã có trong đơn không xoá khỏi DOM mà gửi lên
         * số lượng 0 — server cần biết dòng nào bị bỏ để huỷ đúng dòng đó.
         */
        function removeChangeRow(tr) {
            const body = document.getElementById('changeRowsBody');
            const remaining = Array.from(body.children).filter(r => !r.dataset.removed);
            if (remaining.length <= 1) {
                alert('Đơn phải còn ít nhất một loại phòng. Nếu không còn nhu cầu, vui lòng huỷ đơn đặt phòng.');
                return;
            }
            const hidden = tr.querySelector('input[name="itemBookingId[]"]');
            if (!hidden.value) {
                tr.remove();
            } else {
                tr.dataset.removed = '1';
                tr.style.opacity = '0.45';
                const qty = tr.querySelector('input[name="itemRoomQuantity[]"]');
                qty.value = 0;
                qty.min = '0';
                qty.readOnly = true;
                tr.querySelector('td:last-child').innerHTML =
                    '<span style="color:var(--text-muted);font-size:12px;">Sẽ bỏ</span>';
                tr.querySelector('.row-avail').textContent = '';
            }
            syncRowOptions();
            renderChangeEstimate();
        }

        function addChangeRow() {
            const rows = Array.from(document.getElementById('changeRowsBody').children);
            const taken = new Set(rows.filter(tr => !tr.dataset.removed)
                                      .map(tr => tr.querySelector('select').value));
            // Chọn sẵn loại phòng chưa dùng ở dòng nào và còn phòng trống, để
            // dòng mới không sinh ra đã trùng hoặc đã hết phòng ngay.
            const candidates = Object.keys(roomTypeNames).filter(id => !taken.has(id));
            if (candidates.length === 0) {
                alert('Bạn đã thêm hết các loại phòng hiện có.');
                return;
            }
            const preferred = candidates.find(id => (availableByType[id] === undefined || availableByType[id] > 0))
                            || candidates[0];
            document.getElementById('changeRowsBody').appendChild(buildChangeRow('', preferred, 1));
            syncRowOptions();
            renderChangeEstimate();
        }

        function onChangeBookingSelect() {
            const opt = document.getElementById('changeBookingSelect').selectedOptions[0];
            const panel = document.getElementById('changeCurrent');
            const body = document.getElementById('changeRowsBody');
            body.innerHTML = '';
            if (!opt || !opt.value) {
                panel.classList.remove('show');
                renderChangeEstimate();
                return;
            }

            const info = bookingRows[opt.value];
            const rows = info ? info.rows : [];
            let totalQty = 0;
            rows.forEach(r => {
                totalQty += r.quantity;
                body.appendChild(buildChangeRow(r.bookingId, r.roomTypeId, r.quantity));
            });

            document.getElementById('curChangeType').textContent = opt.dataset.roomtype || '—';
            document.getElementById('curChangeQty').textContent = totalQty || '—';
            document.getElementById('curChangeIn').textContent = opt.dataset.checkin || '—';
            document.getElementById('curChangeOut').textContent = opt.dataset.checkout || '—';
            panel.classList.add('show');

            document.getElementById('changeNewIn').value = opt.dataset.checkin || '';
            document.getElementById('changeNewOut').value = opt.dataset.checkout || '';
            syncRowOptions();
            renderChangeEstimate();
            refreshAvailability();
        }

        /** Ước tính tổng tiền mới và chênh lệch so với đơn hiện tại. */
        function renderChangeEstimate() {
            const box = document.getElementById('changeEstimate');
            const opt = document.getElementById('changeBookingSelect').selectedOptions[0];
            const ci = document.getElementById('changeNewIn').value;
            const co = document.getElementById('changeNewOut').value;
            const rows = Array.from(document.getElementById('changeRowsBody').children);

            rows.forEach(tr => {
                const cell = tr.querySelector('.row-money');
                if (tr.dataset.removed) { cell.textContent = '—'; return; }
                const price = roomTypePrices[tr.querySelector('select').value] || 0;
                const qty = parseInt(tr.querySelector('input[name="itemRoomQuantity[]"]').value || '0', 10);
                cell.textContent = fmtVND(price * qty);
            });

            if (!opt || !opt.value || !ci || !co) { box.classList.remove('show'); return; }
            const nights = nightsBetween(ci, co);
            if (nights < 1) { box.classList.remove('show'); return; }

            let perNight = 0;
            rows.forEach(tr => {
                if (tr.dataset.removed) return;
                const price = roomTypePrices[tr.querySelector('select').value] || 0;
                const qty = parseInt(tr.querySelector('input[name="itemRoomQuantity[]"]').value || '0', 10);
                perNight += price * qty;
            });

            const newTotal = perNight * nights;
            const oldTotal = (bookingRows[opt.value] || {}).totalAmount || 0;
            const delta = newTotal - oldTotal;

            document.getElementById('changeNights').textContent = nights;
            document.getElementById('changeNewTotal').textContent = fmtVND(newTotal);
            const deltaLine = document.getElementById('changeDeltaLine');
            if (Math.abs(delta) < 1) {
                deltaLine.textContent = 'Không thay đổi so với số tiền hiện tại.';
            } else if (delta > 0) {
                deltaLine.innerHTML = 'Cần thanh toán thêm: <strong>' + fmtVND(delta) + '</strong>';
            } else {
                deltaLine.innerHTML = 'Được hoàn lại: <strong>' + fmtVND(-delta) + '</strong>';
            }
            box.classList.add('show');
        }

        function validateChange() {
            const bid = document.getElementById('changeBookingSelect').value;
            const ci = document.getElementById('changeNewIn').value;
            const co = document.getElementById('changeNewOut').value;
            const rows = Array.from(document.getElementById('changeRowsBody').children);
            if (!bid || !ci || !co) {
                alert('Vui lòng điền đầy đủ các trường bắt buộc.');
                return false;
            }
            if (!rows.some(tr => !tr.dataset.removed)) {
                alert('Đơn phải còn ít nhất một loại phòng.');
                return false;
            }
            for (const tr of rows) {
                if (tr.dataset.removed) continue;
                const qty = parseInt(tr.querySelector('input[name="itemRoomQuantity[]"]').value || '0', 10);
                if (!tr.querySelector('select').value || qty < 1) {
                    alert('Mỗi loại phòng phải có số lượng từ 1 trở lên.');
                    return false;
                }
            }
            // Chặn sớm khi vượt tồn kho để khách sửa ngay trên form, khỏi phải
            // gửi đi rồi bị trả về. So theo tổng của từng loại phòng, đúng như
            // server làm. Server vẫn kiểm tra lại — đây chỉ là tiện ích.
            const totals = requestedByType();
            for (const typeId of Object.keys(totals)) {
                const avail = availableByType[typeId];
                if (avail === undefined) continue;   // chưa tra được thì để server quyết
                if (avail <= 0) {
                    alert('Loại phòng "' + roomTypeNames[typeId] + '" đã hết phòng trong khoảng ngày bạn chọn. '
                        + 'Vui lòng đổi ngày hoặc chọn loại phòng khác.');
                    return false;
                }
                if (totals[typeId] > avail) {
                    alert('Loại phòng "' + roomTypeNames[typeId] + '" chỉ còn ' + avail
                        + ' phòng trống trong khoảng ngày bạn chọn, trong khi bạn đang yêu cầu '
                        + totals[typeId] + ' phòng.');
                    return false;
                }
            }
            if (nightsBetween(ci, co) < 1) {
                alert('Ngày trả phòng phải sau ngày nhận phòng.');
                return false;
            }
            if (ci < todayISO()) {
                alert('Ngày nhận phòng mới không được ở trong quá khứ.');
                return false;
            }
            return true;
        }

        /** Tổng số phòng và tiền phòng mỗi đêm của cả đơn (gồm mọi loại phòng). */
        function groupTotals(bookingId) {
            const info = bookingRows[bookingId];
            let quantity = 0, perNight = 0;
            if (info) {
                info.rows.forEach(r => {
                    quantity += r.quantity;
                    perNight += (roomTypePrices[r.roomTypeId] || 0) * r.quantity;
                });
            }
            return { quantity, perNight };
        }

        function onExtBookingSelect() {
            const opt = document.getElementById('extBookingSelect').selectedOptions[0];
            const panel = document.getElementById('extCurrent');
            if (!opt || !opt.value) { panel.classList.remove('show'); return; }
            const totals = groupTotals(opt.value);
            document.getElementById('curExtType').textContent = opt.dataset.roomtype || '—';
            document.getElementById('curExtQty').textContent = totals.quantity || '—';
            document.getElementById('curExtOut').textContent = opt.dataset.checkout || '—';
            panel.classList.add('show');
            // New check-out must be after the current one
            const out = document.getElementById('extNewOut');
            out.min = opt.dataset.checkout || todayISO();
            out.value = '';
            updateExtEstimate();
        }

        function updateExtEstimate() {
            const opt = document.getElementById('extBookingSelect').selectedOptions[0];
            const box = document.getElementById('extEstimate');
            const newOut = document.getElementById('extNewOut').value;
            if (!opt || !opt.value || !newOut) { box.classList.remove('show'); return; }
            const nights = nightsBetween(opt.dataset.checkout, newOut);
            if (nights < 1) { box.classList.remove('show'); return; }
            // Phụ phí tính trên MỌI phòng của đơn, không chỉ loại phòng đầu tiên
            const totals = groupTotals(opt.value);
            document.getElementById('extNights').textContent = nights;
            document.getElementById('extCharge').textContent = fmtVND(totals.perNight * nights);
            box.classList.add('show');
        }

        function validateExtension() {
            const opt = document.getElementById('extBookingSelect').selectedOptions[0];
            const newOut = document.getElementById('extNewOut').value;
            if (!opt || !opt.value || !newOut) {
                alert('Vui lòng chọn phòng và ngày trả phòng mới.');
                return false;
            }
            if (nightsBetween(opt.dataset.checkout, newOut) < 1) {
                alert('Ngày trả phòng mới phải muộn hơn ngày trả phòng hiện tại.');
                return false;
            }
            return true;
        }

        <%-- Vào trang từ nút "Thay đổi đặt phòng" ở màn hình chi tiết đơn: tự
             chọn sẵn đơn và mở form. Chỉ cần một mã đơn — mọi dữ liệu prefill
             (ngày, bảng dòng phòng) đã nằm trong bookingRows và các data-* của
             <option>, nên tái dùng luôn hai hàm sẵn có. --%>
        <c:if test="${not empty booking}">
        (function () {
            const sel = document.getElementById('changeBookingSelect');
            const preselectId = '${booking.bookingId}';
            if (!sel || !Array.from(sel.options).some(o => o.value === preselectId)) {
                return;   // đơn không nằm trong danh sách đủ điều kiện
            }
            sel.value = preselectId;
            showRequestSection('change');
            onChangeBookingSelect();
        })();
        </c:if>
    </script>
</body>
</html>
