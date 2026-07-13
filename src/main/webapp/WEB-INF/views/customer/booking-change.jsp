<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer_booking.css?v=21" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/booking-requests.css?v=3" />
<fmt:setLocale value="vi_VN" />

<body>

    <%-- Header Navigation --%>
    <nav class="navbar-rooms">
        <div class="logo">HotelOps</div>
        <ul class="nav-links">
            <li><a href="${pageContext.request.contextPath}/">Trang chủ</a></li>
            <li><a href="${pageContext.request.contextPath}/rooms">Phòng</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/bookings" class="active">Đặt phòng của tôi</a></li>
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
                            <div class="dropdown-divider"></div>
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
                    <strong>Yêu cầu thất bại:</strong> ${errorMessage}
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
                                        data-roomtypeid="${b.roomTypeId}"
                                        data-qty="${b.roomQuantity}"
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
                        <span>Loại phòng: <b id="curChangeType">—</b></span>
                        <span>Số phòng: <b id="curChangeQty">—</b></span>
                        <span>Nhận phòng: <b id="curChangeIn">—</b></span>
                        <span>Trả phòng: <b id="curChangeOut">—</b></span>
                    </div>
                </div>

                <div class="req-grid-2">
                    <div class="req-field">
                        <label>Ngày nhận phòng mới <span class="req-star">*</span></label>
                        <input type="date" name="newCheckInDate" id="changeNewIn" required />
                    </div>
                    <div class="req-field">
                        <label>Ngày trả phòng mới <span class="req-star">*</span></label>
                        <input type="date" name="newCheckOutDate" id="changeNewOut" required />
                    </div>
                </div>
                <div class="req-grid-2">
                    <div class="req-field">
                        <label>Loại phòng mong muốn <span class="req-star">*</span></label>
                        <select name="roomTypeId" id="changeRoomType" required>
                            <option value="">— Chọn loại phòng —</option>
                            <c:forEach var="rt" items="${roomTypes}">
                                <option value="${rt.typeId}" data-price="${rt.basePrice}">
                                    <c:out value="${rt.typeName}" /> — <fmt:formatNumber value="${rt.basePrice}" type="number" />đ/đêm
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="req-field">
                        <label>Số phòng <span class="req-star">*</span></label>
                        <input type="number" name="roomQuantity" id="changeQty" min="1" max="100" required />
                    </div>
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
                                        data-roomtypeid="${b.roomTypeId}"
                                        data-qty="${b.roomQuantity}"
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
                                    <td style="font-weight: 700;">#${r.bookingId}</td>
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
                                                <small style="color: var(--text-muted);">
                                                    ${r.newRoomTypeName} · ${r.newRoomQuantity} phòng
                                                </small>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="font-weight: 600; color: var(--gold-price);">
                                        <c:choose>
                                            <c:when test="${r.additionalCharge != null && r.additionalCharge > 0}">
                                                <fmt:formatNumber value="${r.additionalCharge}" type="number" /> VND
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

        function onChangeBookingSelect() {
            const opt = document.getElementById('changeBookingSelect').selectedOptions[0];
            const panel = document.getElementById('changeCurrent');
            if (!opt || !opt.value) { panel.classList.remove('show'); return; }
            document.getElementById('curChangeType').textContent = opt.dataset.roomtype || '—';
            document.getElementById('curChangeQty').textContent = opt.dataset.qty || '—';
            document.getElementById('curChangeIn').textContent = opt.dataset.checkin || '—';
            document.getElementById('curChangeOut').textContent = opt.dataset.checkout || '—';
            panel.classList.add('show');
            // Pre-fill the editable fields with the current values
            document.getElementById('changeNewIn').value = opt.dataset.checkin || '';
            document.getElementById('changeNewOut').value = opt.dataset.checkout || '';
            if (opt.dataset.roomtypeid) document.getElementById('changeRoomType').value = opt.dataset.roomtypeid;
            document.getElementById('changeQty').value = opt.dataset.qty || '1';
        }

        function validateChange() {
            const bid = document.getElementById('changeBookingSelect').value;
            const ci = document.getElementById('changeNewIn').value;
            const co = document.getElementById('changeNewOut').value;
            const rt = document.getElementById('changeRoomType').value;
            const qty = document.getElementById('changeQty').value;
            if (!bid || !ci || !co || !rt || !qty) {
                alert('Vui lòng điền đầy đủ các trường bắt buộc.');
                return false;
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

        function onExtBookingSelect() {
            const opt = document.getElementById('extBookingSelect').selectedOptions[0];
            const panel = document.getElementById('extCurrent');
            if (!opt || !opt.value) { panel.classList.remove('show'); return; }
            document.getElementById('curExtType').textContent = opt.dataset.roomtype || '—';
            document.getElementById('curExtQty').textContent = opt.dataset.qty || '—';
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
            const price = roomTypePrices[opt.dataset.roomtypeid] || 0;
            const qty = parseInt(opt.dataset.qty || '1', 10);
            document.getElementById('extNights').textContent = nights;
            document.getElementById('extCharge').textContent = fmtVND(price * qty * nights);
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
    </script>
</body>
</html>
