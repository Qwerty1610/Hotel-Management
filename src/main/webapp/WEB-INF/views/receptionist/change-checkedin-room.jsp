<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Đổi phòng #${booking.bookingId} - HotelOps Pro</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
              rel="stylesheet" />
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/receptionist.css?v=4" />
        <style>
            /* ================= CHANGE ROOM ================= */

            .change-room-box{
                width:auto;
                margin:0 10px 24px 10px;

                border:1px solid #dbe3ee;
                border-radius:12px;
                background:#fff;

                padding:18px;
                box-sizing:border-box;
            }

            .change-room-box h4{
                margin:0 0 18px;
                font-size:17px;
                font-weight:700;
            }

            .change-room-table{
                width:100%;
                border-collapse:collapse;
                font-size:13px;
            }

            .change-room-table th{
                text-align:left;
                padding:8px 12px;
                background:#f8fafc;
                border-bottom:2px solid var(--border-color);
                font-weight:700;
                color:var(--text-navy);
            }

            .change-room-table td{
                padding:10px 12px;
                border-bottom:1px solid #f1f5f9;
            }

            .change-room-table .room-row{
                cursor:pointer;
                transition:background .15s;
            }

            .change-room-table .room-row:hover{
                background:#f8fafc;
            }

            .change-room-table .room-row.selected{
                background:#eff6ff;
                box-shadow:inset 3px 0 0 #2563eb;
            }

            #targetRoomContext{
                font-weight:400;
                color:#64748b;
                font-size:13px;
            }
        </style>
    </head>
    <fmt:setLocale value="vi_VN" />

    <body class="dashboard-body">

        <div class="dashboard-layout">

            <%--=================SIDEBAR=================--%>
            <aside class="dashboard-sidebar">
                <div class="sidebar-brand">
                    <i class="fa-solid fa-bell-concierge"></i> <span>HotelOps</span>
                </div>

                <ul class="sidebar-menu">
                    <li class="menu-item ${currentTab eq 'bookings' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings">
                            <i class="fa-solid fa-calendar-check"></i> <span>Yêu cầu đặt phòng</span>
                        </a>
                    </li>

                    <li class="menu-item ${currentTab eq 'changerequests' ? 'active' : ''}">
                        <a
                            href="${pageContext.request.contextPath}/receptionist/dashboard?tab=changerequests">
                            <i class="fa-solid fa-pen-to-square"></i> <span>Thay đổi đặt phòng</span>
                        </a>
                    </li>

                    <li class="menu-item ${currentTab eq 'checkin' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=checkin">
                            <i class="fa-solid fa-key"></i> <span>Nhận phòng (Check-in)</span>
                        </a>
                    </li>

                    <li class="menu-item ${currentTab eq 'checkout' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=checkout">
                            <i class="fa-solid fa-right-from-bracket"></i> <span>Trả phòng & Thanh
                                toán</span>
                        </a>
                    </li>

                    <li class="menu-item ${currentTab eq 'roommap' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=roommap">
                            <i class="fa-solid fa-map"></i> <span>Sơ đồ phòng</span>
                        </a>
                    </li>

                    <li class="menu-item ${currentTab eq 'walkin-bookings' ? 'active' : ''}">
                        <a
                            href="${pageContext.request.contextPath}/receptionist/dashboard?tab=walkin-bookings">
                            <i class="fa-solid fa-user-plus"></i> <span>Đặt phòng tại quầy</span>
                        </a>
                    </li>


                    <li class="menu-item ${currentTab eq 'servicerequests' ? 'active' : ''}">
                        <a
                            href="${pageContext.request.contextPath}/receptionist/dashboard?tab=servicerequests">
                            <i class="fa-solid fa-bell-concierge"></i> <span>Quản lý yêu cầu dịch vụ</span>
                        </a>
                    </li>
                    <li class="menu-item ${currentTab eq 'add-booking-service' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/receptionist/add-booking-service">
                            <i class="fa-solid fa-circle-plus"></i>
                            <span>Đặt dịch vụ cho khách</span>
                        </a>
                    </li>
                </ul>

                <div class="sidebar-footer">
                    <a href="${pageContext.request.contextPath}/profile" class="user-profile-card"
                       title="Xem hồ sơ cá nhân" style="text-decoration:none;cursor:pointer;">
                        <div class="profile-avatar">RC</div>
                        <div class="profile-info">
                            <span class="profile-name">${not empty sessionScope.user ? sessionScope.user :
                                                         'Receptionist'}</span>
                            <span class="profile-role">Lễ tân</span>
                        </div>
                    </a>
                </div>
            </aside>

            <%--=================MAIN CONTENT=================--%>
            <div class="dashboard-main">

                <%-- TOPBAR --%>
                <header class="main-topbar">
                    <div class="breadcrumb">
                        <span>Receptionist</span>
                        <span class="separator">&gt;</span>
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings"
                           style="text-decoration:none;color:var(--text-muted)">Quản lý đặt
                            phòng</a>
                        <span class="separator">&gt;</span>
                        <span class="current">Đổi phòng #${booking.bookingId}</span>
                    </div>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                        <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                    </a>
                </header>

                <%-- WORKSPACE --%>
                <main class="workspace-content">

                    <div class="content-header-row">
                        <div>
                            <h2>
                                <i class="fa-solid fa-right-left"
                                   style="color:var(--brand-blue);margin-right:8px"></i>
                                Đổi phòng #${booking.bookingId}
                            </h2>
                            <p>
                                Thay đổi phòng lưu trú hiện tại cho khách đang check-in.
                            </p>
                        </div>
                        <div style="display:flex; gap:12px">
                            <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings"
                               class="btn-modal-cancel"
                               style="display:inline-flex;align-items:center;justify-content:center;text-decoration:none;line-height:40px;height:40px">
                                <i class="fa-solid fa-chevron-left" style="margin-right:6px"></i>
                                Quay lại danh sách
                            </a>
                        </div>
                    </div>

                    <div class="process-grid">
                        <!-- Cột trái: Thông tin Khách hàng & Đặt phòng -->
                        <div class="process-left">

                            <!-- Khách hàng -->
                            <div class="detail-card">
                                <div class="card-header">
                                    <h3><i class="fa-solid fa-user"></i> Thông tin khách hàng
                                    </h3>
                                </div>
                                <div class="card-body">
                                    <c:choose>
                                        <c:when test="${not empty customer}">
                                            <div class="info-row">
                                                <label>Họ và tên:</label>
                                                <span>
                                                    <c:out value="${customer.fullName}" />
                                                </span>
                                            </div>
                                            <div class="info-row">
                                                <label>Email:</label>
                                                <span>
                                                    <c:out
                                                        value="${not empty booking.email ? booking.email : (not empty customer ? customer.email : '—')}" />
                                                </span>
                                            </div>
                                            <div class="info-row"
                                                 style="border-bottom:none; padding-bottom:0">
                                                <label>Số điện thoại:</label>
                                                <span>
                                                    <c:out
                                                        value="${not empty booking.phone ? booking.phone : (not empty customer and not empty customer.phone ? customer.phone : '—')}" />
                                                </span>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="info-row">
                                                <label>Họ và tên khách:</label>
                                                <span>
                                                    <c:out value="${booking.customerName}" />
                                                </span>
                                            </div>
                                            <div class="info-row">
                                                <label>Email:</label>
                                                <span>
                                                    <c:out
                                                        value="${not empty booking.email ? booking.email : '—'}" />
                                                </span>
                                            </div>
                                            <div class="info-row"
                                                 style="border-bottom:none; padding-bottom:0">
                                                <label>Số điện thoại:</label>
                                                <span>
                                                    <c:out
                                                        value="${not empty booking.phone ? booking.phone : '—'}" />
                                                </span>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <!-- Đặt phòng -->
                            <div class="detail-card" style="margin-top:24px">
                                <div class="card-header">
                                    <h3><i class="fa-solid fa-calendar-days"></i> Chi tiết yêu
                                        cầu đặt phòng</h3>
                                </div>
                                <div class="card-body">
                                    <div class="info-row">
                                        <label>Mã Đặt Phòng:</label>
                                        <span class="booking-id-badge">#${booking.bookingId}</span>
                                    </div>
                                    <div class="info-row">
                                        <label>Trạng thái đặt phòng:</label>
                                        <span>
                                            <c:choose>
                                                <c:when test="${booking.status eq 'Pending'}">
                                                    <span class="status-pill pill-pending"><i
                                                            class="fa-solid fa-circle"></i> Chờ
                                                        xử lý</span>
                                                    </c:when>
                                                    <c:when test="${booking.status eq 'Confirmed'}">
                                                    <span class="status-pill pill-confirmed"><i
                                                            class="fa-solid fa-circle"></i> Đã
                                                        xác nhận</span>
                                                    </c:when>
                                                    <c:when test="${booking.status eq 'Rejected'}">
                                                    <span class="status-pill pill-rejected"><i
                                                            class="fa-solid fa-circle"></i> Từ
                                                        chối</span>
                                                    </c:when>
                                                    <c:when test="${booking.status eq 'Cancelled'}">
                                                    <span class="status-pill pill-cancelled"><i
                                                            class="fa-solid fa-circle"></i> Đã
                                                        huỷ</span>
                                                    </c:when>
                                                    <c:when test="${booking.status eq 'CheckedIn'}">
                                                    <span class="status-pill pill-checkedin"><i
                                                            class="fa-solid fa-circle"></i> Đã
                                                        check-in</span>
                                                    </c:when>
                                                    <c:when test="${booking.status eq 'CheckedOut'}">
                                                    <span class="status-pill pill-checkedout"><i
                                                            class="fa-solid fa-circle"></i> Đã
                                                        trả phòng</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                    <span
                                                        class="status-pill pill-cancelled">${booking.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>

                                    <%-- Room type breakdown table --%>
                                    <div style="margin-top: 16px; margin-bottom: 16px;">
                                        <label
                                            style="font-size: 12px; font-weight: 700; color: var(--text-navy); display: block; margin-bottom: 8px;">
                                            <i class="fa-solid fa-layer-group"
                                               style="margin-right: 4px;"></i> Chi tiết các
                                            loại phòng:
                                        </label>
                                        <table
                                            style="width: 100%; border-collapse: collapse; font-size: 13px;">
                                            <thead>
                                                <tr
                                                    style="background: #f8fafc; border-bottom: 2px solid var(--border-color);">
                                                    <th
                                                        style="padding: 8px 12px; text-align: left; font-weight: 700; color: var(--text-navy);">
                                                        Loại phòng</th>
                                                    <th
                                                        style="padding: 8px 12px; text-align: center; font-weight: 700; color: var(--text-navy);">
                                                        Số lượng</th>
                                                    <th
                                                        style="padding: 8px 12px; text-align: right; font-weight: 700; color: var(--text-navy);">
                                                        Thành tiền</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="b" items="${groupBookings}">
                                                    <tr style="border-bottom:1px solid #f1f5f9;">
                                                        <td style="padding:8px 12px;">
                                                            <span class="roomtype-badge">
                                                                ${b.roomTypeName}
                                                            </span>
                                                        </td>

                                                        <td style="padding:8px 12px;text-align:center;font-weight:600;">
                                                            ${b.roomQuantity}
                                                        </td>

                                                        <td style="padding:8px 12px;text-align:right;font-weight:600;">
                                                            <fmt:formatNumber
                                                                value="${b.totalAmount}"
                                                                type="number"
                                                                groupingUsed="true"/>đ
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                                <%-- Total row --%>
                                                <tr
                                                    style="border-top: 2px solid var(--border-color); background: #f0f9ff;">
                                                    <td
                                                        style="padding: 8px 12px; font-weight: 700; color: var(--text-navy);">
                                                        Tổng cộng</td>
                                                    <td
                                                        style="padding: 8px 12px; text-align: center; font-weight: 700; color: var(--text-navy);">
                                                        ${booking.totalRoomQuantity}
                                                        phòng</td>
                                                    <td
                                                        style="padding: 8px 12px; text-align: right; font-weight: 800; color: var(--brand-blue); font-size: 15px;">
                                                        <fmt:formatNumber
                                                            value="${booking.overallTotalAmount}"
                                                            type="number"
                                                            groupingUsed="true" />đ
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>

                                    <div class="info-row">
                                        <label>Ngày Check-in:</label>
                                        <span>${booking.checkInDate}</span>
                                    </div>
                                    <div class="info-row">
                                        <label>Ngày Check-out:</label>
                                        <span>${booking.checkOutDate}</span>
                                    </div>
                                    <div class="info-row"
                                         style="border-bottom:none; padding-bottom:0">
                                        <label>Số đêm lưu trú:</label>
                                        <span>${booking.nights} đêm</span>
                                    </div>
                                    <c:if test="${not empty booking.note}">
                                        <div class="info-row-full"
                                             style="margin-top: 12px; padding: 12px; background: #fffbeb; border-radius: 8px; border: 1px solid #fde68a;">
                                            <label
                                                style="display:block; font-size:11px; font-weight:700; color:#d97706; margin-bottom:4px"><i
                                                    class="fa-solid fa-comment-dots"></i> Ghi
                                                chú của khách:</label>
                                            <span style="font-size:13px; color:#b45309">
                                                <c:out value="${booking.note}" />
                                            </span>
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </div>

                        <!-- Cột phải: Phân phòng & Trạng thái phê duyệt -->
                        <div class="process-right">

                            <!-- Đổi phòng -->
                            <div class="detail-card">
                                <div class="card-header">
                                    <h3 style="display:flex;align-items:center;gap:10px;">
                                        <i class="fa-solid fa-right-left"></i>
                                        Đổi phòng
                                    </h3>
                                </div>
                                <div class="card-body">

                                    <c:if test="${not empty success}">
                                        <div class="toast-notify toast-success">
                                            <i class="fa-solid fa-circle-check"></i>
                                            Đổi phòng thành công!
                                        </div>
                                    </c:if>
                                    <c:if test="${not empty error}">
                                        <div class="toast-notify toast-error">
                                            <i class="fa-solid fa-circle-xmark"></i>
                                            <c:choose>
                                                <c:when test="${error eq 'noroom'}">Vui lòng chọn phòng hiện tại và phòng muốn đổi sang.</c:when>
                                                <c:when test="${error eq 'reason'}">Vui lòng nhập lý do đổi phòng.</c:when>
                                                <c:when test="${error eq 'sameroom'}">Không thể đổi sang chính phòng hiện tại.</c:when>
                                                <c:when test="${error eq 'failed'}">Đổi phòng thất bại. Vui lòng thử lại.</c:when>
                                                <c:otherwise>Đã xảy ra lỗi. Vui lòng thử lại.</c:otherwise>
                                            </c:choose>
                                        </div>
                                    </c:if>

                                    <!-- BẢNG 1: PHÒNG HIỆN TẠI -->
                                    <div class="change-room-box">
                                        <h4>
                                            <i class="fa-solid fa-bed"></i>
                                            Phòng hiện tại
                                        </h4>
                                        <table class="change-room-table">
                                            <thead>
                                                <tr>
                                                    <th>Số phòng</th>
                                                    <th>Loại phòng</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="room" items="${assignedRooms}">
                                                    <tr class="room-row"
                                                        data-room-id="${room.roomId}"
                                                        data-room-type="${room.typeName}"
                                                        data-room-number="${room.roomNumber}"
                                                        onclick="selectOldRoom(this)">
                                                        <td>${room.roomNumber}</td>
                                                        <td>${room.typeName}</td>
                                                    </tr>
                                                </c:forEach>
                                                <c:if test="${empty assignedRooms}">
                                                    <tr>
                                                        <td colspan="2" style="text-align:center;color:var(--text-muted);">
                                                            Không có phòng nào.
                                                        </td>
                                                    </tr>
                                                </c:if>
                                            </tbody>
                                        </table>
                                    </div>

                                    <!-- BẢNG 2: PHÒNG MUỐN ĐỔI SANG (ẩn cho tới khi chọn phòng ở bảng 1) -->
                                    <div class="change-room-box" id="targetRoomSection" style="display:none; margin-top:20px;">
                                        <h4>
                                            <i class="fa-solid fa-right-left"></i>
                                            Phòng muốn đổi sang
                                            <span id="targetRoomContext"></span>
                                        </h4>

                                        <c:forEach var="entry" items="${availableRoomMap}">
                                            <table class="change-room-table target-room-group"
                                                   data-type="${entry.key}"
                                                   style="display:none;">
                                                <thead>
                                                    <tr>
                                                        <th>Số phòng</th>
                                                        <th>Loại phòng</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="room" items="${entry.value}">
                                                        <tr class="room-row"
                                                            data-room-id="${room.roomId}"
                                                            data-room-number="${room.roomNumber}"
                                                            onclick="selectNewRoom(this)">
                                                            <td>${room.roomNumber}</td>
                                                            <td>${room.typeName}</td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </c:forEach>
                                        <p id="noAvailableRoomMsg" style="display:none;color:var(--text-muted);font-style:italic;">
                                            Không còn phòng trống cùng loại trong thời gian khách ở.
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </main>
                <footer class="dashboard-footer">
                    <span>HotelOps Pro &copy; 2026</span>
                    <span>Đăng nhập: <strong>${sessionScope.user}</strong></span>
                </footer>
            </div>
        </div>

        <!-- MODAL: XÁC NHẬN ĐỔI PHÒNG (lý do bắt buộc) -->
        <div class="modal-overlay" id="reasonModal">
            <div class="modal-container">
                <div class="modal-header">
                    <h3>Xác nhận đổi phòng</h3>
                    <button class="btn-close-modal" onclick="closeModal('reasonModal')"><i class="fa-solid fa-xmark"></i></button>
                </div>
                <div class="modal-body">
                    <p id="reasonContext" style="color:var(--text-muted); font-size:14px; margin-top:0;"></p>
                    <form id="changeRoomForm" method="post"
                          action="${pageContext.request.contextPath}/receptionist/change-room">
                        <input type="hidden" name="bookingId" value="${booking.bookingId}">
                        <input type="hidden" id="oldRoomIdInput" name="oldRoomId" value="">
                        <input type="hidden" id="newRoomIdInput" name="newRoomId" value="">
                        <div class="modal-form-group">
                            <label for="reasonInput">Lý do đổi phòng</label>
                            <textarea id="reasonInput" name="reason" class="modal-textarea" required
                                      placeholder="Nhập lý do đổi phòng..."></textarea>
                            <small id="reasonRequiredHint"
                                   style="display:none; color:#dc2626; font-weight:600;">Vui lòng nhập lý do đổi phòng.</small>
                        </div>
                        <div class="modal-footer-row">
                            <button type="button" class="btn-modal-cancel" onclick="closeModal('reasonModal')">Hủy bỏ</button>
                            <button type="submit" class="btn-modal-confirm">Xác nhận đổi phòng</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

    </body>
    <script src="${pageContext.request.contextPath}/assets/js/receptionist.js?v=5" charset="UTF-8"></script>
    <script>
        let selectedOldRoomId = null;
        let selectedOldRoomType = null;

        function selectOldRoom(tr) {

            document.querySelectorAll(".change-room-table .room-row.selected")
                    .forEach(r => r.classList.remove("selected"));
            tr.classList.add("selected");

            selectedOldRoomId = tr.dataset.roomId;
            selectedOldRoomType = tr.dataset.roomType;
            const roomNumber = tr.dataset.roomNumber;

            document.getElementById("targetRoomContext").innerText = "— cho phòng " + roomNumber;

            let hasAvailable = false;
            document.querySelectorAll(".target-room-group").forEach(group => {
                const match = group.dataset.type === selectedOldRoomType;
                group.style.display = match ? "table" : "none";
                if (match && group.querySelector("tbody tr")) {
                    hasAvailable = true;
                }
            });

            document.getElementById("noAvailableRoomMsg").style.display = hasAvailable ? "none" : "block";
            document.getElementById("targetRoomSection").style.display = "block";
        }

        function selectNewRoom(tr) {

            const newRoomId = tr.dataset.roomId;
            const newRoomNumber = tr.dataset.roomNumber;

            document.getElementById("oldRoomIdInput").value = selectedOldRoomId;
            document.getElementById("newRoomIdInput").value = newRoomId;
            document.getElementById("reasonContext").innerText =
                    "Đổi sang phòng " + newRoomNumber + ".";

            const reasonInput = document.getElementById("reasonInput");
            reasonInput.value = "";
            document.getElementById("reasonRequiredHint").style.display = "none";

            openModal("reasonModal");
        }

        document.getElementById("changeRoomForm").addEventListener("submit", function (e) {
            const reason = document.getElementById("reasonInput").value.trim();
            if (reason === "") {
                e.preventDefault();
                document.getElementById("reasonRequiredHint").style.display = "inline";
            }
        });
    </script>
</html>