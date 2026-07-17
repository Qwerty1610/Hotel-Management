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

            .change-room-type{
                margin-bottom:20px;
            }

            .change-room-type:last-child{
                margin-bottom:0;
            }

            .change-room-type-name{
                font-size:15px;
                font-weight:700;
                color:#2563eb;
                margin-bottom:10px;
            }

            .change-room-grid{
                display:flex;
                flex-wrap:wrap;
                gap:12px;
            }

            .change-room-item{
                flex:0 0 auto;
            }

            .change-room-item input{
                display:none;
            }

            .change-room-card{

                width:110px;
                height:68px;

                border:2px solid #dbe3ee;
                border-radius:10px;

                display:flex;
                flex-direction:column;
                justify-content:center;
                align-items:center;

                background:#fff;

                transition:.2s;
            }

            .change-room-card:hover{
                border-color:#3b82f6;
            }

            .change-room-item input:checked + .change-room-card{
                border-color:#2563eb;
                background:#eff6ff;
                box-shadow:0 0 0 3px rgba(37,99,235,.15);
            }

            .change-room-no{
                font-size:19px;
                font-weight:700;
                color:#111827;
                line-height:1;
            }

            .change-room-roomtype{
                margin-top:6px;
                font-size:12px;
                color:#64748b;
            }
            .room-error-msg{
                display:inline-block;
                font-size:13px;
                color:#dc2626;
                background:#fef2f2;
                border:1px solid #fecaca;
                padding:4px 10px;
                border-radius:20px;

                opacity:0;
                visibility:hidden;

                transition:.3s;
            }

            .room-error-msg.show{
                opacity:1;
                visibility:visible;
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

                                        <span id="roomTypeError" class="room-error-msg">
                                            Không thể đổi sang phòng khác loại.
                                        </span>
                                    </h3>
                                </div>
                                <div class="card-body">
                                    <form method="post"
                                          action="${pageContext.request.contextPath}/receptionist/change-room">
                                        <input type="hidden"
                                               name="bookingId"
                                               value="${booking.bookingId}">
                                        <!-- Phòng hiện tại -->
                                        <div class="change-room-box">
                                            <h4>
                                                <i class="fa-solid fa-bed"></i>
                                                Phòng hiện tại
                                            </h4>
                                            <c:forEach var="entry" items="${assignedRoomMap}">
                                                <div class="change-room-type">
                                                    <div class="change-room-type-name">
                                                        ${entry.value[0].typeName}
                                                    </div>
                                                    <div class="change-room-grid">
                                                        <c:forEach var="room" items="${entry.value}">
                                                            <div class="change-room-item">
                                                                <input
                                                                    type="hidden"
                                                                    name="oldRoomIds"
                                                                    value="${room.roomId}">
                                                                <div class="change-room-card">
                                                                    <div class="change-room-no">
                                                                        ${room.roomNumber}
                                                                    </div>
                                                                    <div class="change-room-roomtype">
                                                                        ${room.typeName}
                                                                    </div>
                                                                </div>
                                                                <div
                                                                    style="
                                                                    margin:10px 0;
                                                                    font-size:14px;
                                                                    font-weight:bold;
                                                                    color:#2563eb;">
                                                                    ↓
                                                                    Chọn phòng mới
                                                                </div>
                                                                <div class="change-room-grid"
                                                                     style="margin-top:12px;">
                                                                    <c:forEach
                                                                        var="newRoom"
                                                                        items="${availableRoomMap[room.typeName]}">
                                                                        <label class="change-room-item">
                                                                            <input
                                                                                type="radio"
                                                                                name="newRoom_${room.roomId}"
                                                                                value="${newRoom.roomId}">
                                                                            <div class="change-room-card">
                                                                                <div class="change-room-no">
                                                                                    ${newRoom.roomNumber}
                                                                                </div>
                                                                                <div class="change-room-roomtype">
                                                                                    ${newRoom.typeName}
                                                                                </div>
                                                                            </div>
                                                                        </label>
                                                                    </c:forEach>
                                                                </div>
                                                            </div>
                                                        </c:forEach>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>
                                        <!-- Form đổi phòng -->
                                        <!-- LÝ DO -->
                                        <div style="margin-top:20px">
                                            <label style="
                                                   font-weight:700;
                                                   display:block;
                                                   margin-bottom:8px">
                                                Lý do đổi phòng
                                            </label>
                                            <textarea 
                                                name="reason"
                                                id="changeReason"
                                                placeholder="Nhập lý do đổi phòng..."
                                                required
                                                style="
                                                width:100%;
                                                height:120px;
                                                padding:12px;
                                                border-radius:8px;
                                                border:1px solid var(--border-color);
                                                resize:none"></textarea>
                                        </div>
                                        <button type="submit"
                                                id="btnChangeRoom"
                                                class="btn-modal-confirm"
                                                disabled
                                                style="
                                                width:100%;
                                                margin-top:20px;
                                                height:42px;
                                                opacity:0.5;
                                                cursor:not-allowed">
                                            <i class="fa-solid fa-right-left"></i>
                                            Xác nhận đổi phòng
                                        </button>
                                    </form>
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

    </body>
    <script>
        const errorMsg = document.getElementById("roomTypeError");
        let errorTimeout = null;

        document.addEventListener("DOMContentLoaded", function () {

            const reasonInput = document.getElementById("changeReason");
            const roomRadios =
                    document.querySelectorAll(
                            "input[type='radio']"
                            );
            const submitBtn = document.getElementById("btnChangeRoom");


            function validateChangeRoom() {
                const reason = reasonInput.value.trim();
                let valid = true;
                // lấy tất cả group radio
                const groups = {};
                roomRadios.forEach(radio => {
                    groups[radio.name] = true;
                });
                // mỗi group phải chọn đúng 1 phòng
                for (const name in groups) {
                    const checked =
                            document.querySelector(
                                    "input[name='" + name + "']:checked"
                                    );
                    if (!checked) {
                        valid = false;
                        break;
                    }
                }
                if (reason === "") {
                    valid = false;
                }
                submitBtn.disabled = !valid;
                submitBtn.style.opacity = valid ? "1" : "0.5";
                submitBtn.style.cursor = valid ? "pointer" : "not-allowed";
            }

            // nhập lý do
            reasonInput.addEventListener(
                    "input",
                    validateChangeRoom
                    );
            // chọn phòng
            roomRadios.forEach(radio => {
                radio.addEventListener(
                        "change",
                        validateChangeRoom
                        );
            });
            // chạy lần đầu khi load trang
            validateChangeRoom();
        });
    </script>
</html>