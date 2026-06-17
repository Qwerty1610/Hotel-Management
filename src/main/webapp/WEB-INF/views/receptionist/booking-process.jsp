<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ include file="../../includes/taglibs.jsp" %>
        <%@ include file="../../includes/header.jsp" %>

            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/receptionist.css?v=3" />
            <fmt:setLocale value="vi_VN" />

            <body class="dashboard-body">

                <div class="dashboard-layout">

                    <%--=================SIDEBAR=================--%>
                        <aside class="dashboard-sidebar">
                            <div class="sidebar-brand">
                                <i class="fa-solid fa-bell-concierge"></i> <span>HotelOps</span>
                            </div>

                            <ul class="sidebar-menu">
                                <li class="menu-item active">
                                    <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings">
                                        <i class="fa-solid fa-calendar-check"></i> <span>Yêu cầu đặt phòng</span>
                                    </a>
                                </li>

                                <li class="menu-item">
                                    <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=checkin">
                                        <i class="fa-solid fa-key"></i> <span>Nhận phòng (Check-in)</span>
                                    </a>
                                </li>

                                <li class="menu-item">
                                    <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=checkout">
                                        <i class="fa-solid fa-right-from-bracket"></i> <span>Trả phòng & Thanh
                                            toán</span>
                                    </a>
                                </li>
                            </ul>

                            <div class="sidebar-footer">
                                <div class="user-profile-card">
                                    <div class="profile-avatar">RC</div>
                                    <div class="profile-info">
                                        <span class="profile-name">${not empty sessionScope.user ? sessionScope.user :
                                            'Receptionist'}</span>
                                        <span class="profile-role">Lễ tân</span>
                                    </div>
                                </div>
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
                                            <span class="current">Cập nhật & Duyệt đặt phòng
                                                #${booking.bookingId}</span>
                                        </div>
                                        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                                            <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                                        </a>
                                    </header>

                                    <%-- WORKSPACE --%>
                                        <main class="workspace-content">

                                            <c:if test="${param.error eq 'validation'}">
                                                <div class="toast-notify toast-error" style="margin-bottom: 24px">
                                                    <i class="fa-solid fa-circle-xmark"></i>
                                                    Thông tin không hợp lệ: vui lòng chọn đủ số phòng trống theo yêu
                                                    cầu.
                                                </div>
                                            </c:if>

                                            <div class="content-header-row">
                                                <div>
                                                    <h2><i class="fa-solid fa-file-invoice"
                                                            style="color:var(--brand-blue);margin-right:8px"></i>Cập
                                                        nhật & Duyệt đặt phòng #${booking.bookingId}</h2>
                                                    <p>Chỉnh sửa toàn bộ thông tin đặt phòng, gán phòng trống và phê
                                                        duyệt trạng thái đặt phòng.</p>
                                                </div>
                                                <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings"
                                                    class="btn-modal-cancel"
                                                    style="display:inline-flex;align-items:center;justify-content:center;text-decoration:none;line-height:40px;height:40px">
                                                    <i class="fa-solid fa-chevron-left" style="margin-right:6px"></i>
                                                    Quay lại danh sách
                                                </a>
                                            </div>

                                            <c:choose>
                                                <c:when test="${booking.status eq 'Pending'}">
                                                    <form id="processForm" method="post"
                                                        action="${pageContext.request.contextPath}/receptionist/booking/process">
                                                        <input type="hidden" name="bookingId"
                                                            value="${booking.bookingId}" />
                                                        <input type="hidden" id="actionField" name="action"
                                                            value="update" />
                                                        <div id="hiddenRoomIdsContainer"></div>

                                                        <div class="process-grid">
                                                            <!-- Cột trái: Thông tin Khách hàng & Đặt phòng (EDITABLE) -->
                                                            <div class="process-left">
                                                                <!-- Khách hàng -->
                                                                <div class="detail-card">
                                                                    <div class="card-header">
                                                                        <h3><i class="fa-solid fa-user"></i> Thông tin
                                                                            khách hàng</h3>
                                                                    </div>
                                                                    <div class="card-body">
                                                                        <div class="modal-form-group"
                                                                            style="margin-bottom:0">
                                                                            <label>Họ và tên khách <span
                                                                                    style="color:#ef4444">*</span></label>
                                                                            <input type="text" name="customerName"
                                                                                id="editCustomerName"
                                                                                value="<c:out value="
                                                                                ${booking.customerName}" />"
                                                                            class="modal-input" required maxlength="100"
                                                                            />
                                                                        </div>
                                                                        <c:if test="${not empty customer}">
                                                                            <div class="info-row"
                                                                                style="margin-top:12px">
                                                                                <label>Email:</label>
                                                                                <span>
                                                                                    <c:out value="${customer.email}" />
                                                                                </span>
                                                                            </div>
                                                                            <div class="info-row"
                                                                                style="border-bottom:none; padding-bottom:0">
                                                                                <label>Số điện thoại:</label>
                                                                                <span>
                                                                                    <c:out
                                                                                        value="${not empty customer.phone ? customer.phone : '—'}" />
                                                                                </span>
                                                                            </div>
                                                                        </c:if>
                                                                    </div>
                                                                </div>

                                                                <!-- Đặt phòng -->
                                                                <div class="detail-card" style="margin-top:24px">
                                                                    <div class="card-header">
                                                                        <h3><i class="fa-solid fa-calendar-days"></i>
                                                                            Chi tiết yêu cầu đặt phòng</h3>
                                                                    </div>
                                                                    <div class="card-body">
                                                                        <div class="info-row">
                                                                            <label>Mã Đặt Phòng:</label>
                                                                            <span
                                                                                class="booking-id-badge">#${booking.bookingId}</span>
                                                                        </div>
                                                                        <div class="info-row">
                                                                            <label>Trạng thái đặt phòng:</label>
                                                                            <span>
                                                                                <span
                                                                                    class="status-pill pill-pending"><i
                                                                                        class="fa-solid fa-circle"></i>
                                                                                    Chờ xử lý</span>
                                                                            </span>
                                                                        </div>
                                                                        <div class="modal-form-group"
                                                                            style="margin-top:12px">
                                                                            <label>Loại phòng yêu cầu <span
                                                                                    style="color:#ef4444">*</span></label>
                                                                            <select id="editRoomTypeId"
                                                                                name="roomTypeId" class="modal-select"
                                                                                onchange="recalcAmount(); filterRooms();">
                                                                                <c:forEach var="rt"
                                                                                    items="${roomTypesList}">
                                                                                    <option value="${rt.typeId}"
                                                                                        data-price="${rt.basePrice}"
                                                                                        data-type-name="<c:out value="
                                                                                        ${rt.typeName}" />" ${rt.typeId
                                                                                    eq booking.roomTypeId ? 'selected' :
                                                                                    ''}>
                                                                                    <c:out value="${rt.typeName}" /> —
                                                                                    <fmt:formatNumber
                                                                                        value="${rt.basePrice}"
                                                                                        type="number" />đ/đêm
                                                                                    </option>
                                                                                </c:forEach>
                                                                            </select>
                                                                        </div>
                                                                        <div class="modal-form-group">
                                                                            <label>Số lượng phòng <span
                                                                                    style="color:#ef4444">*</span></label>
                                                                            <input type="number" id="editRoomQuantity"
                                                                                name="roomQuantity" class="modal-input"
                                                                                min="1" max="100"
                                                                                value="${booking.roomQuantity}"
                                                                                onchange="recalcAmount(); updateSelection();"
                                                                                required />
                                                                        </div>
                                                                        <div class="modal-grid-2">
                                                                            <div class="modal-form-group">
                                                                                <label>Ngày Check-in <span
                                                                                        style="color:#ef4444">*</span></label>
                                                                                <input type="date" id="editCheckIn"
                                                                                    name="checkInDate"
                                                                                    class="modal-input"
                                                                                    value="${booking.checkInDate}"
                                                                                    onchange="recalcAmount()"
                                                                                    required />
                                                                            </div>
                                                                            <div class="modal-form-group">
                                                                                <label>Ngày Check-out <span
                                                                                        style="color:#ef4444">*</span></label>
                                                                                <input type="date" id="editCheckOut"
                                                                                    name="checkOutDate"
                                                                                    class="modal-input"
                                                                                    value="${booking.checkOutDate}"
                                                                                    onchange="recalcAmount()"
                                                                                    required />
                                                                            </div>
                                                                        </div>
                                                                        <div class="info-row">
                                                                            <label>Số đêm lưu trú:</label>
                                                                            <span id="displayNights">${booking.nights}
                                                                                đêm</span>
                                                                        </div>
                                                                        <div class="modal-form-group">
                                                                            <label>Tổng số tiền (VND) <span
                                                                                    style="color:#ef4444">*</span></label>
                                                                            <input type="number" id="editTotalAmount"
                                                                                name="totalAmount" class="modal-input"
                                                                                min="0" value="<fmt:formatNumber value="
                                                                                ${booking.totalAmount}"
                                                                                pattern="#####.##" />" required />
                                                                        </div>
                                                                        <div class="modal-form-group"
                                                                            style="margin-bottom:0">
                                                                            <label>Ghi chú đặt phòng</label>
                                                                            <textarea name="note" class="modal-textarea"
                                                                                style="height:60px"
                                                                                placeholder="Yêu cầu đặc biệt..."
                                                                                maxlength="500"><c:out value="${booking.note}" /></textarea>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>

                                                            <!-- Cột phải: Phân phòng & Duyệt trạng thái -->
                                                            <div class="process-right">
                                                                <!-- Phân phòng -->
                                                                <div class="detail-card">
                                                                    <div class="card-header">
                                                                        <h3><i class="fa-solid fa-door-open"></i> Phân
                                                                            phòng (Gán phòng thực tế)</h3>
                                                                    </div>
                                                                    <div class="card-body">
                                                                        <span id="selection-counter"
                                                                            style="display:none"></span>
                                                                        <div class="room-grid" id="roomGrid">
                                                                            <c:forEach var="rm" items="${rooms}">
                                                                                <%-- Check if this room is already
                                                                                    assigned to this booking --%>
                                                                                    <c:set var="isAssigned"
                                                                                        value="false" />
                                                                                    <c:forEach var="ar"
                                                                                        items="${assignedRooms}">
                                                                                        <c:if
                                                                                            test="${ar.roomId eq rm.roomId}">
                                                                                            <c:set var="isAssigned"
                                                                                                value="true" />
                                                                                        </c:if>
                                                                                    </c:forEach>

                                                                                    <c:set var="isAvailable"
                                                                                        value="${rm.status eq 'Available'}" />
                                                                                    <c:set var="isCleaning"
                                                                                        value="${rm.status eq 'Cleaning'}" />
                                                                                    <c:set var="isOccupied"
                                                                                        value="${rm.status eq 'Occupied'}" />
                                                                                    <c:set var="isMaintenance"
                                                                                        value="${rm.status eq 'Maintenance'}" />

                                                                                    <div class="room-card ${isAvailable || isAssigned ? 'card-avail' : 'card-disabled'} ${isAssigned ? 'selected' : ''}"
                                                                                        data-room-id="${rm.roomId}"
                                                                                        data-room-type-name="<c:out value="
                                                                                        ${rm.typeName}" />"
                                                                                    style="display:none;">
                                                                                    <div class="room-card-header">
                                                                                        <span class="room-number">P.
                                                                                            ${rm.roomNumber}</span>
                                                                                        <span
                                                                                            class="room-floor">${rm.floor}</span>
                                                                                    </div>
                                                                                    <div class="room-card-body">
                                                                                        <c:choose>
                                                                                            <c:when
                                                                                                test="${isAssigned}">
                                                                                                <span
                                                                                                    class="badge-status badge-avail">Đang
                                                                                                    gán</span>
                                                                                            </c:when>
                                                                                            <c:when
                                                                                                test="${isAvailable}">
                                                                                                <span
                                                                                                    class="badge-status badge-avail">Trống</span>
                                                                                            </c:when>
                                                                                            <c:when
                                                                                                test="${isCleaning}">
                                                                                                <span
                                                                                                    class="badge-status badge-clean">Dọn
                                                                                                    dẹp</span>
                                                                                            </c:when>
                                                                                            <c:when
                                                                                                test="${isOccupied}">
                                                                                                <span
                                                                                                    class="badge-status badge-occupied">Có
                                                                                                    khách</span>
                                                                                            </c:when>
                                                                                            <c:otherwise>
                                                                                                <span
                                                                                                    class="badge-status badge-maint">Bảo
                                                                                                    trì</span>
                                                                                            </c:otherwise>
                                                                                        </c:choose>
                                                                                    </div>
                                                                                    <c:if
                                                                                        test="${isAvailable || isAssigned}">
                                                                                        <div
                                                                                            class="room-checkbox-wrapper">
                                                                                            <input type="checkbox"
                                                                                                name="selectedRooms"
                                                                                                value="${rm.roomId}"
                                                                                                class="room-checkbox"
                                                                                                onchange="updateSelection()"
                                                                                                ${isAssigned ? 'checked'
                                                                                                : '' } />
                                                                                        </div>
                                                                                    </c:if>
                                                                        </div>
                                                                        </c:forEach>
                                                                    </div>
                                                                    <div id="selection-error" class="error-message"
                                                                        style="display:none; margin-top:10px"></div>
                                                                </div>
                                                            </div>

                                                            <!-- Phê duyệt -->
                                                            <div class="detail-card" style="margin-top:24px">
                                                                <div class="card-header">
                                                                    <h3><i class="fa-solid fa-circle-check"></i> Phê
                                                                        duyệt trạng thái đặt phòng</h3>
                                                                </div>
                                                                <div class="card-body">
                                                                    <div class="form-section confirm-section"
                                                                        id="sectionConfirm">
                                                                        <div class="modal-form-group">
                                                                            <label>Ghi chú duyệt đặt phòng (Tùy
                                                                                chọn)</label>
                                                                            <input type="text" name="approvalNote"
                                                                                class="modal-input"
                                                                                placeholder="Ví dụ: Đã xác nhận phòng sẵn sàng..."
                                                                                maxlength="250" />
                                                                        </div>

                                                                        <button type="button" class="btn-modal-confirm"
                                                                            style="width:100%; height:44px; font-size:14px; margin-bottom:12px"
                                                                            id="btnConfirmBooking"
                                                                            onclick="submitAction('confirm')" disabled>
                                                                            <i class="fa-solid fa-check"></i> Xác nhận
                                                                            duyệt đặt phòng
                                                                        </button>

                                                                        <button type="button" class="btn-modal-save"
                                                                            style="width:100%; height:44px; background:var(--brand-blue); color:#fff; font-size:14px"
                                                                            id="btnUpdateBooking"
                                                                            onclick="submitAction('update')">
                                                                            <i class="fa-solid fa-floppy-disk"></i> Lưu
                                                                            cập nhật thông tin
                                                                        </button>
                                                                    </div>

                                                                    <div class="or-separator">Hoặc từ chối / hủy đặt
                                                                        phòng</div>

                                                                    <div class="action-buttons-row">
                                                                        <button type="button" class="btn-modal-reject"
                                                                            style="flex:1; height:40px"
                                                                            onclick="showReasonArea('reject')">Từ chối
                                                                            duyệt</button>
                                                                        <button type="button" class="btn-modal-cancel"
                                                                            style="flex:1; height:40px"
                                                                            onclick="showReasonArea('cancel')">Hủy đặt
                                                                            phòng</button>
                                                                    </div>

                                                                    <!-- Nhập lý do -->
                                                                    <div class="reason-input-container"
                                                                        id="reasonContainer"
                                                                        style="display:none; margin-top:20px">
                                                                        <div class="modal-form-group">
                                                                            <label id="reasonLabel">Lý do từ chối <span
                                                                                    style="color:#ef4444">*</span></label>
                                                                            <textarea id="reasonTextArea" name="reason"
                                                                                class="modal-textarea"
                                                                                placeholder="Nhập lý do..."
                                                                                maxlength="500"></textarea>
                                                                            <div id="reason-error" class="error-message"
                                                                                style="display:none"></div>
                                                                        </div>
                                                                        <div class="action-buttons-row"
                                                                            style="margin-top:10px">
                                                                            <button type="button"
                                                                                class="btn-modal-cancel" style="flex:1"
                                                                                onclick="hideReasonArea()">Hủy
                                                                                bỏ</button>
                                                                            <button type="button"
                                                                                class="btn-modal-confirm" style="flex:1"
                                                                                id="btnSubmitReason"
                                                                                onclick="submitReasonAction(event)">Xác
                                                                                nhận gửi</button>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                            </div>
                            </form>
                            </c:when>

                            <c:otherwise>
                                <%-- Read-only mode for bookings that are NOT Pending (should not happen on process
                                    page, but just in case) --%>
                                    <div class="process-grid">
                                        <!-- Cột trái: Thông tin Khách hàng & Đặt phòng (READ-ONLY) -->
                                        <div class="process-left">
                                            <!-- Khách hàng -->
                                            <div class="detail-card">
                                                <div class="card-header">
                                                    <h3><i class="fa-solid fa-user"></i> Thông tin khách hàng</h3>
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
                                                                    <c:out value="${customer.email}" />
                                                                </span>
                                                            </div>
                                                            <div class="info-row" style="border-bottom:none; padding-bottom:0">
                                                                <label>Số điện thoại:</label>
                                                                <span>
                                                                    <c:out
                                                                        value="${not empty customer.phone ? customer.phone : '—'}" />
                                                                </span>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="info-row"
                                                                style="border-bottom:none; padding-bottom:0">
                                                                <label>Họ và tên khách:</label>
                                                                <span>
                                                                    <c:out value="${booking.customerName}" />
                                                                </span>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <!-- Đặt phòng -->
                                            <div class="detail-card" style="margin-top:24px">
                                                <div class="card-header">
                                                    <h3><i class="fa-solid fa-calendar-days"></i> Chi tiết yêu cầu đặt
                                                        phòng</h3>
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
                                                                <c:when test="${booking.status eq 'Confirmed'}">
                                                                    <span class="status-pill pill-confirmed"><i
                                                                            class="fa-solid fa-circle"></i> Đã xác
                                                                        nhận</span>
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
                                                                            class="fa-solid fa-circle"></i> Đã trả
                                                                        phòng</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span
                                                                        class="status-pill pill-cancelled">${booking.status}</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </span>
                                                    </div>
                                                    <div class="info-row">
                                                        <label>Loại phòng yêu cầu:</label>
                                                        <span class="roomtype-badge">
                                                            <c:out value="${booking.roomTypeName}" />
                                                        </span>
                                                    </div>
                                                    <div class="info-row">
                                                        <label>Số lượng phòng:</label>
                                                        <span style="font-weight:700">${booking.roomQuantity}
                                                            phòng</span>
                                                    </div>
                                                    <div class="info-row">
                                                        <label>Ngày Check-in:</label>
                                                        <span>${booking.checkInDate}</span>
                                                    </div>
                                                    <div class="info-row">
                                                        <label>Ngày Check-out:</label>
                                                        <span>${booking.checkOutDate}</span>
                                                    </div>
                                                    <div class="info-row">
                                                        <label>Số đêm lưu trú:</label>
                                                        <span>${booking.nights} đêm</span>
                                                    </div>
                                                    <div class="info-row" style="border-bottom:none; padding-bottom:0">
                                                        <label>Tổng số tiền:</label>
                                                        <span
                                                            style="color:var(--brand-blue); font-size: 18px; font-weight: 800">
                                                            <fmt:formatNumber value="${booking.totalAmount}"
                                                                type="number" groupingUsed="true" />đ
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Cột phải: Phân phòng & Phê duyệt -->
                                        <div class="process-right">
                                            <!-- Phân phòng -->
                                            <div class="detail-card">
                                                <div class="card-header">
                                                    <h3><i class="fa-solid fa-door-open"></i> Phân phòng (Gán phòng thực
                                                        tế)</h3>
                                                </div>
                                                <div class="card-body">
                                                    <c:choose>
                                                        <c:when test="${booking.status eq 'Confirmed'}">
                                                            <div
                                                                style="background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px; padding: 16px; text-align: center; margin-bottom: 20px;">
                                                                <span
                                                                    style="font-size: 14px; font-weight: 700; color: #16a34a">
                                                                    <i class="fa-solid fa-circle-check"
                                                                        style="font-size: 16px; margin-right: 6px;"></i>
                                                                    Đã đặt phòng thành công
                                                                </span>
                                                            </div>
                                                            <div class="assigned-rooms-list">
                                                                <c:forEach var="ar" items="${assignedRooms}">
                                                                    <div class="assigned-room-item">
                                                                        <div class="room-icon"><i
                                                                                class="fa-solid fa-door-closed"></i>
                                                                        </div>
                                                                        <div class="room-info">
                                                                            <span class="room-num">Phòng
                                                                                ${ar.roomNumber}</span>
                                                                            <span class="room-fl">${ar.floor}</span>
                                                                        </div>
                                                                    </div>
                                                                </c:forEach>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <p
                                                                style="font-size: 13px; color: var(--text-muted); text-align: center; padding: 20px">
                                                                <i class="fa-solid fa-ban"
                                                                    style="font-size:24px; display:block; margin-bottom:8px; opacity:0.3"></i>
                                                                Đặt phòng này đang ở trạng thái
                                                                <strong>
                                                                    <c:choose>
                                                                        <c:when test="${booking.status eq 'CheckedIn'}">
                                                                            Đã check-in</c:when>
                                                                        <c:when
                                                                            test="${booking.status eq 'CheckedOut'}">Đã
                                                                            trả phòng</c:when>
                                                                        <c:otherwise>${booking.status}</c:otherwise>
                                                                    </c:choose>
                                                                </strong>. Không có phòng nào được phân phối.
                                                            </p>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <!-- Phê duyệt -->
                                            <div class="detail-card" style="margin-top:24px">
                                                <div class="card-header">
                                                    <h3><i class="fa-solid fa-circle-check"></i> Trạng thái phê duyệt
                                                    </h3>
                                                </div>
                                                <div class="card-body">
                                                    <c:choose>
                                                        <c:when test="${booking.status eq 'Confirmed'}">
                                                            <div
                                                                style="background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px; padding: 16px; text-align: center; margin-bottom: 20px;">
                                                                <span
                                                                    style="font-size: 14px; font-weight: 700; color: #16a34a">
                                                                    <i class="fa-solid fa-circle-check"></i> Đặt phòng
                                                                    đã được xác nhận thành công
                                                                </span>
                                                            </div>
                                                            <form id="cancelForm" method="post"
                                                                action="${pageContext.request.contextPath}/receptionist/booking/process">
                                                                <input type="hidden" name="bookingId"
                                                                    value="${booking.bookingId}" />
                                                                <input type="hidden" name="action" value="cancel" />

                                                                <div class="modal-form-group">
                                                                    <label>Lý do hủy đặt phòng (Tùy chọn)</label>
                                                                    <textarea name="reason" class="modal-textarea"
                                                                        placeholder="Ví dụ: Khách gọi báo hủy..."
                                                                        maxlength="500"></textarea>
                                                                </div>
                                                                <button type="submit" class="btn-modal-save"
                                                                    style="width:100%; height:44px; background:#64748b; font-size:14px"
                                                                    id="btnSubmitCancelOnly">
                                                                    <i class="fa-solid fa-ban"></i> Hủy đặt phòng
                                                                </button>
                                                            </form>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div
                                                                style="background: #f8fafc; border: 1px solid var(--border-color); border-radius: 8px; padding: 16px; text-align: center;">
                                                                <span
                                                                    style="font-size: 13px; color: var(--text-muted)">Đặt
                                                                    phòng đã hoàn tất xử lý. Không thể thao tác
                                                                    thêm.</span>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                            </c:otherwise>
                            </c:choose>

                            </main>

                            <footer class="dashboard-footer">
                                <span>HotelOps Pro &copy; 2026</span>
                                <span>Đăng nhập: <strong>${sessionScope.user}</strong></span>
                            </footer>
                </div>
                </div>

                <script>
                    function getRequiredQty() {
                        const qtyInput = document.getElementById('editRoomQuantity');
                        return parseInt(qtyInput ? qtyInput.value : "${booking.roomQuantity}") || 0;
                    }

                    function filterRooms() {
                        const sel = document.getElementById('editRoomTypeId');
                        if (!sel) return;
                        const selectedTypeName = sel.selectedOptions[0]?.dataset?.typeName;

                        document.querySelectorAll('.room-card').forEach(card => {
                            const cardTypeName = card.dataset.roomTypeName;
                            if (cardTypeName === selectedTypeName) {
                                card.style.display = 'block';
                            } else {
                                card.style.display = 'none';
                                const cb = card.querySelector('.room-checkbox');
                                if (cb && cb.checked) {
                                    cb.checked = false;
                                    card.classList.remove('selected');
                                }
                            }
                        });
                        updateSelection();
                    }

                    function updateSelection() {
                        const checkboxes = document.querySelectorAll('.room-checkbox:checked');
                        const count = checkboxes.length;
                        const reqQty = getRequiredQty();

                        // Làm nổi bật card phòng được chọn
                        document.querySelectorAll('.room-card').forEach(card => {
                            const cb = card.querySelector('.room-checkbox');
                            if (cb) {
                                if (cb.checked) {
                                    card.classList.add('selected');
                                } else {
                                    card.classList.remove('selected');
                                }
                            }
                        });

                        // Vô hiệu/Kích hoạt nút duyệt đặt phòng
                        const btnConfirm = document.getElementById('btnConfirmBooking');
                        if (btnConfirm) {
                            if (count === reqQty) {
                                btnConfirm.disabled = false;
                            } else {
                                btnConfirm.disabled = true;
                            }
                        }
                    }

                    /* Tính toán lại tổng tiền trên form khi sửa ngày/loại phòng/số lượng */
                    function recalcAmount() {
                        const checkIn = document.getElementById('editCheckIn').value;
                        const checkOut = document.getElementById('editCheckOut').value;
                        const sel = document.getElementById('editRoomTypeId');
                        const qtyInput = document.getElementById('editRoomQuantity');
                        const qty = parseInt(qtyInput ? qtyInput.value : 1) || 1;

                        const displayNights = document.getElementById('displayNights');
                        const totalAmountInput = document.getElementById('editTotalAmount');

                        if (!checkIn || !checkOut) return;

                        const diff = new Date(checkOut) - new Date(checkIn);
                        const nights = Math.floor(diff / (1000 * 60 * 60 * 24));

                        if (nights <= 0) {
                            if (displayNights) displayNights.textContent = "0 đêm";
                            if (totalAmountInput) totalAmountInput.value = 0;
                            return;
                        }

                        if (displayNights) displayNights.textContent = nights + " đêm";

                        if (!sel) return;
                        const basePrice = parseFloat(sel.selectedOptions[0]?.dataset?.price || 0);
                        if (basePrice > 0 && totalAmountInput) {
                            totalAmountInput.value = (basePrice * nights * qty).toFixed(0);
                        }
                    }

                    document.addEventListener("DOMContentLoaded", function () {
                        filterRooms();
                        updateSelection();

                        // Double submit prevention cho cancelForm
                        const cForm = document.getElementById('cancelForm');
                        if (cForm) {
                            cForm.addEventListener('submit', function () {
                                const btn = document.getElementById('btnSubmitCancelOnly');
                                if (btn) {
                                    btn.disabled = true;
                                    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang hủy...';
                                }
                            });
                        }
                    });

                    let currentReasonMode = ''; // 'reject' or 'cancel'

                    function showReasonArea(mode) {
                        currentReasonMode = mode;
                        const container = document.getElementById('reasonContainer');
                        const sectionConfirm = document.getElementById('sectionConfirm');
                        const reasonLabel = document.getElementById('reasonLabel');
                        const reasonText = document.getElementById('reasonTextArea');

                        container.style.display = 'block';
                        sectionConfirm.style.display = 'none';
                        reasonText.value = '';
                        reasonText.focus();

                        if (mode === 'reject') {
                            reasonLabel.innerHTML = 'Lý do từ chối <span style="color:#ef4444">*</span>';
                            reasonText.placeholder = 'Nhập lý do từ chối (bắt buộc)...';
                        } else {
                            reasonLabel.innerHTML = 'Lý do hủy đặt phòng';
                            reasonText.placeholder = 'Nhập lý do hủy đặt phòng (tùy chọn)...';
                        }

                        document.getElementById('reason-error').style.display = 'none';
                        reasonText.classList.remove('error');
                    }

                    function hideReasonArea() {
                        document.getElementById('reasonContainer').style.display = 'none';
                        document.getElementById('sectionConfirm').style.display = 'block';
                    }

                    function submitAction(action) {
                        const checkboxes = document.querySelectorAll('.room-checkbox:checked');
                        document.getElementById('actionField').value = action;
                        const reqQty = getRequiredQty();

                        if (action === 'confirm') {
                            if (checkboxes.length !== reqQty) {
                                const errDiv = document.getElementById('selection-error');
                                errDiv.textContent = `Vui lòng chọn đúng ${reqQty} phòng trống.`;
                                errDiv.style.display = 'block';
                                return;
                            }

                            // Ngăn chặn double submit
                            const btn = document.getElementById('btnConfirmBooking');
                            if (btn) {
                                btn.disabled = true;
                                btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang duyệt...';
                            }
                        }

                        // Đẩy các phòng đã chọn vào hidden input cho cả confirm và update (chỉ khi số lượng chọn bằng số lượng phòng yêu cầu)
                        const container = document.getElementById('hiddenRoomIdsContainer');
                        if (container) {
                            container.innerHTML = '';
                            if (checkboxes.length === reqQty) {
                                checkboxes.forEach(cb => {
                                    const hiddenInput = document.createElement('input');
                                    hiddenInput.type = 'hidden';
                                    hiddenInput.name = 'roomIds';
                                    hiddenInput.value = cb.value;
                                    container.appendChild(hiddenInput);
                                });
                            }
                        }

                        if (action === 'update') {
                            // Ngăn chặn double submit
                            const btn = document.getElementById('btnUpdateBooking');
                            if (btn) {
                                btn.disabled = true;
                                btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang lưu...';
                            }
                        }

                        document.getElementById('processForm').submit();
                    }

                    function submitReasonAction(event) {
                        event.preventDefault();
                        const reasonText = document.getElementById('reasonTextArea').value.trim();
                        const errDiv = document.getElementById('reason-error');
                        const reasonInput = document.getElementById('reasonTextArea');

                        errDiv.style.display = 'none';
                        reasonInput.classList.remove('error');

                        if (currentReasonMode === 'reject' && !reasonText) {
                            reasonInput.focus();
                            reasonInput.classList.add('error');
                            errDiv.textContent = 'Vui lòng nhập lý do từ chối.';
                            errDiv.style.display = 'block';
                            return;
                        }

                        if (reasonText.length > 500) {
                            reasonInput.focus();
                            reasonInput.classList.add('error');
                            errDiv.textContent = 'Lý do không được vượt quá 500 ký tự.';
                            errDiv.style.display = 'block';
                            return;
                        }

                        document.getElementById('actionField').value = currentReasonMode;

                        // Ngăn chặn double submit
                        const btn = document.getElementById('btnSubmitReason');
                        if (btn) {
                            btn.disabled = true;
                            btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang gửi...';
                        }

                        document.getElementById('processForm').submit();
                    }
                </script>
            </body>

            </html>