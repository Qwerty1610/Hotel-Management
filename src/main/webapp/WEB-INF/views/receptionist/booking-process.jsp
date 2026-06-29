<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Cập nhật & Duyệt đặt phòng #${booking.bookingId} - HotelOps Pro</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/receptionist.css?v=4" />
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

                    <li class="menu-item ${currentTab eq 'checkin' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=checkin">
                            <i class="fa-solid fa-key"></i> <span>Nhận phòng (Check-in)</span>
                        </a>
                    </li>
                    <li class="menu-item ${currentTab eq 'roommap' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=roommap">
                            <i class="fa-solid fa-map"></i> <span>sơ đồ phòng</span>
                        </a>
                    </li>

                    <li class="menu-item ${currentTab eq 'walkin-bookings' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=walkin-bookings">
                            <i class="fa-solid fa-user-plus"></i> <span>Đặt phòng tại quầy</span>
                        </a>
                    </li>

                    <li class="menu-item ${currentTab eq 'checkout' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=checkout">
                            <i class="fa-solid fa-right-from-bracket"></i> <span>Trả phòng & Thanh toán</span>
                        </a>
                    </li>

                    <li class="menu-item ${currentTab eq 'servicerequests' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=servicerequests">
                            <i class="fa-solid fa-bell-concierge"></i> <span>Quản lý yêu cầu dịch vụ</span>
                        </a>
                    </li>
                </ul>

                <div class="sidebar-footer">
                    <div class="user-profile-card">
                        <div class="profile-avatar">RC</div>
                        <div class="profile-info">
                            <span class="profile-name">${not empty sessionScope.user ? sessionScope.user : 'Receptionist'}</span>
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
                            Thông tin không hợp lệ: vui lòng chọn đủ số phòng trống theo yêu cầu.
                        </div>
                    </c:if>

                    <c:if test="${param.error eq 'conflict'}">
                        <div class="toast-notify toast-error" style="margin-bottom: 24px">
                            <i class="fa-solid fa-circle-xmark"></i>
                            Một hoặc nhiều phòng đã được phân cho khách khác trong khoảng thời gian này.
                        </div>
                    </c:if>

                    <c:if test="${param.error eq 'duplicate_room'}">
                        <div class="toast-notify toast-error" style="margin-bottom: 24px">
                            <i class="fa-solid fa-circle-xmark"></i>
                            Bạn không thể phân cùng một phòng cho nhiều yêu cầu trong cùng một đơn đặt.
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
                                                           value="${booking.customerName}"
                                                           class="modal-input" required maxlength="100"
                                                           />
                                                </div>
                                                <div class="info-row"
                                                     style="margin-top:12px">
                                                    <label>Email:</label>
                                                    <span>
                                                        <c:out value="${not empty booking.email ? booking.email : (not empty customer ? customer.email : '—')}" />
                                                    </span>
                                                </div>
                                                <div class="info-row"
                                                     style="border-bottom:none; padding-bottom:0">
                                                    <label>Số điện thoại:</label>
                                                    <span>
                                                        <c:out value="${not empty booking.phone ? booking.phone : (not empty customer and not empty customer.phone ? customer.phone : '—')}" />
                                                    </span>
                                                </div>
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
                                                <div style="border-bottom:1px solid #e2e8f0; margin-bottom:16px; padding-bottom:12px;">
                                                    <div style="font-weight:600; color:var(--text-navy); margin-bottom:8px;">Loại phòng 1 (Parent)</div>
                                                    <div class="modal-form-group">
                                                        <label>Loại phòng yêu cầu <span style="color:#ef4444">*</span></label>
                                                        <select id="editRoomTypeId_parent" 
                                                                name="roomTypeId" 
                                                                class="modal-select" 
                                                                onchange="onParentRoomTypeChange()">
                                                            <c:forEach var="rt" items="${roomTypesList}">
                                                                <option value="${rt.typeId}" data-price="${rt.basePrice}" data-type-name="${rt.typeName}" ${rt.typeId eq booking.roomTypeId ? 'selected' : ''}>
                                                                    <c:out value="${rt.typeName}" /> — <fmt:formatNumber value="${rt.basePrice}" type="number" />đ/đêm
                                                                </option>
                                                            </c:forEach>
                                                        </select>
                                                    </div>
                                                    <div class="modal-form-group">
                                                        <label>Số lượng phòng <span style="color:#ef4444">*</span></label>
                                                        <input type="number" id="editRoomQuantity_parent" name="roomQuantity" class="modal-input" min="1" max="100" value="${booking.roomQuantity}" onchange="recalcAmount(); updateSelection('parent');" required />
                                                    </div>
                                                </div>

                                                <c:forEach var="child" items="${childBookings}" varStatus="status">
                                                    <div style="border-bottom:1px solid #e2e8f0; margin-bottom:16px; padding-bottom:12px;">
                                                        <div style="font-weight:600; color:var(--text-navy); margin-bottom:8px;">Loại phòng ${status.index + 2}</div>
                                                        <div class="modal-form-group">
                                                            <label>Loại phòng yêu cầu</label>
                                                            <select id="editRoomTypeId_${child.bookingId}"
                                                                    name="childRoomTypeId_${child.bookingId}"
                                                                    class="modal-select"
                                                                    onchange="onChildRoomTypeChange('${child.bookingId}')">

                                                                <c:forEach var="rt" items="${roomTypesList}">
                                                                    <option value="${rt.typeId}"
                                                                            data-price="${rt.basePrice}"
                                                                            data-type-name="${rt.typeName}"
                                                                            ${rt.typeId eq child.roomTypeId ? 'selected' : ''}>
                                                                        <c:out value="${rt.typeName}" /> — 
                                                                        <fmt:formatNumber value="${rt.basePrice}" type="number" />đ/đêm
                                                                    </option>
                                                                </c:forEach>

                                                            </select>
                                                        </div>
                                                        <div class="modal-form-group">
                                                            <label>Số lượng phòng <span style="color:#ef4444">*</span></label>
                                                            <input type="number" id="editRoomQuantity_${child.bookingId}" name="childRoomQuantity_${child.bookingId}" class="modal-input" min="1" max="100" value="${child.roomQuantity}" onchange="recalcAmount(); updateSelection('${child.bookingId}');" required />
                                                        </div>
                                                    </div>
                                                </c:forEach>
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
                                                    <label>Tổng số tiền</label>
                                                    <div id="displayTotalAmount" class="total-amount-display">
                                                        0 VND
                                                    </div>
                                                    <input
                                                        type="hidden"
                                                        id="editTotalAmount"
                                                        name="totalAmount">
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
                                                <div id="gridsContainer">
                                                    <%-- Parent Grid --%>
                                                    <div class="booking-grid-section" id="sectionGrid_parent" style="margin-bottom:20px;">
                                                        <h4 style="font-size: 13px; color: var(--text-navy); margin-bottom: 8px;"><i class="fa-solid fa-bed"></i> Loại 1 (Parent): <span id="typeName_parent"><c:out value="${booking.roomTypeName}" /></span></h4>
                                                        <div class="room-grid" id="roomGrid_parent">
                                                            <c:forEach var="rm" items="${rooms}">
                                                                <c:set var="isAssigned" value="false" />
                                                                <c:forEach var="ar" items="${assignedRooms}">
                                                                    <c:if test="${ar.roomId eq rm.roomId}">
                                                                        <c:set var="isAssigned" value="true" />
                                                                    </c:if>
                                                                </c:forEach>
                                                                <c:set var="isAvailable" value="${rm.status eq 'Available'}" />
                                                                <c:set var="isCleaning" value="${rm.status eq 'Cleaning'}" />
                                                                <c:set var="isOccupied" value="${rm.status eq 'Occupied'}" />
                                                                <c:set var="isMaintenance" value="${rm.status eq 'Maintenance'}" />

                                                                <div class="room-card ${isAvailable || isAssigned ? 'card-avail' : 'card-disabled'} ${isAssigned ? 'selected' : ''}"
                                                                     data-room-id="${rm.roomId}" data-room-type-name="${rm.typeName}" style="display:none;">
                                                                    <div class="room-card-header">
                                                                        <span class="room-number">P. ${rm.roomNumber}</span>
                                                                        <span class="room-floor">${rm.floor}</span>
                                                                    </div>
                                                                    <div class="room-card-body">
                                                                        <c:choose>
                                                                            <c:when test="${isAssigned}"><span class="badge-status badge-avail">Đang gán</span></c:when>
                                                                            <c:when test="${isAvailable}"><span class="badge-status badge-avail">Trống</span></c:when>
                                                                            <c:when test="${isCleaning}"><span class="badge-status badge-clean">Dọn dẹp</span></c:when>
                                                                            <c:when test="${isOccupied}"><span class="badge-status badge-occupied">Có khách</span></c:when>
                                                                            <c:otherwise><span class="badge-status badge-maint">Bảo trì</span></c:otherwise>
                                                                        </c:choose>
                                                                    </div>
                                                                    <c:if test="${isAvailable || isAssigned}">
                                                                        <div class="room-checkbox-wrapper">
                                                                            <input type="checkbox" name="selectedRooms" value="${rm.roomId}" class="room-checkbox cb-parent" onchange="updateSelection('parent')" ${isAssigned ? 'checked' : '' } />
                                                                        </div>
                                                                    </c:if>
                                                                </div>
                                                            </c:forEach>
                                                        </div>
                                                    </div>

                                                    <%-- Child Grids --%>
                                                    <c:forEach var="child" items="${childBookings}" varStatus="status">
                                                        <div class="booking-grid-section" id="sectionGrid_${child.bookingId}" style="margin-bottom:20px;">
                                                            <h4 style="font-size: 13px; color: var(--text-navy); margin-bottom: 8px;"><i class="fa-solid fa-bed"></i> Loại ${status.index + 2}: <c:out value="${child.roomTypeName}" /></h4>
                                                            <div class="room-grid" id="roomGrid_${child.bookingId}">
                                                                <c:set var="childRooms"
                                                                       value="${empty childAssignedRoomsMap ? null : childAssignedRoomsMap[child.bookingId]}" />
                                                                <c:forEach var="rm" items="${rooms}">
                                                                    <c:set var="isAssigned" value="false" />
                                                                    <c:if test="${not empty childRooms}">
                                                                        <c:forEach var="ar" items="${childRooms}">
                                                                            <c:if test="${ar.roomId eq rm.roomId}">
                                                                                <c:set var="isAssigned" value="true" />
                                                                            </c:if>
                                                                        </c:forEach>
                                                                    </c:if>
                                                                    <c:set var="isAvailable" value="${rm.status eq 'Available'}" />
                                                                    <c:set var="isCleaning" value="${rm.status eq 'Cleaning'}" />
                                                                    <c:set var="isOccupied" value="${rm.status eq 'Occupied'}" />
                                                                    <c:set var="isMaintenance" value="${rm.status eq 'Maintenance'}" />

                                                                    <div class="room-card ${isAvailable || isAssigned ? 'card-avail' : 'card-disabled'} ${isAssigned ? 'selected' : ''}"
                                                                         data-room-id="${rm.roomId}" data-room-type-name="${rm.typeName}" style="display:none;">
                                                                        <div class="room-card-header">
                                                                            <span class="room-number">P. ${rm.roomNumber}</span>
                                                                            <span class="room-floor">${rm.floor}</span>
                                                                        </div>
                                                                        <div class="room-card-body">
                                                                            <c:choose>
                                                                                <c:when test="${isAssigned}"><span class="badge-status badge-avail">Đang gán</span></c:when>
                                                                                <c:when test="${isAvailable}"><span class="badge-status badge-avail">Trống</span></c:when>
                                                                                <c:when test="${isCleaning}"><span class="badge-status badge-clean">Dọn dẹp</span></c:when>
                                                                                <c:when test="${isOccupied}"><span class="badge-status badge-occupied">Có khách</span></c:when>
                                                                                <c:otherwise><span class="badge-status badge-maint">Bảo trì</span></c:otherwise>
                                                                            </c:choose>
                                                                        </div>
                                                                        <c:if test="${isAvailable || isAssigned}">
                                                                            <div class="room-checkbox-wrapper">
                                                                                <input type="checkbox" name="selectedRooms" value="${rm.roomId}" class="room-checkbox cb-${child.bookingId}" onchange="updateSelection('${child.bookingId}')" ${isAssigned ? 'checked' : '' } />
                                                                            </div>
                                                                        </c:if>
                                                                    </div>
                                                                </c:forEach>
                                                            </div>
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
                                                    <c:out value="${booking.groupRoomTypeNames}" />
                                                </span>
                                            </div>

                                            <%-- Room type breakdown table --%>
                                            <div style="margin-top: 12px; margin-bottom: 16px;">
                                                <label style="font-size: 12px; font-weight: 700; color: var(--text-navy); display: block; margin-bottom: 8px;">
                                                    <i class="fa-solid fa-layer-group" style="margin-right: 4px;"></i> Chi tiết các loại phòng:
                                                </label>
                                                <table style="width: 100%; border-collapse: collapse; font-size: 13px;">
                                                    <thead>
                                                        <tr style="background: #f8fafc; border-bottom: 2px solid var(--border-color);">
                                                            <th style="padding: 8px 10px; text-align: left; font-weight: 700; color: var(--text-navy);">Loại phòng</th>
                                                            <th style="padding: 8px 10px; text-align: center; font-weight: 700; color: var(--text-navy);">SL</th>
                                                            <th style="padding: 8px 10px; text-align: right; font-weight: 700; color: var(--text-navy);">Thành tiền</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <tr style="border-bottom: 1px solid #f1f5f9;">
                                                            <td style="padding: 6px 10px;"><span class="roomtype-badge"><c:out value="${booking.roomTypeName}" /></span></td>
                                                            <td style="padding: 6px 10px; text-align: center; font-weight: 600;">${booking.roomQuantity}</td>
                                                            <td style="padding: 6px 10px; text-align: right; font-weight: 600;">
                                                                <fmt:formatNumber value="${booking.totalAmount}" type="number" groupingUsed="true" />đ
                                                            </td>
                                                        </tr>
                                                        <c:forEach var="child" items="${empty childBookings ? [] : childBookings}">
                                                            <tr style="border-bottom: 1px solid #f1f5f9;">
                                                                <td style="padding: 6px 10px;"><span class="roomtype-badge"><c:out value="${child.roomTypeName}" /></span></td>
                                                                <td style="padding: 6px 10px; text-align: center; font-weight: 600;">${child.roomQuantity}</td>
                                                                <td style="padding: 6px 10px; text-align: right; font-weight: 600;">
                                                                    <fmt:formatNumber value="${child.totalAmount}" type="number" groupingUsed="true" />đ
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                        <tr style="border-top: 2px solid var(--border-color); background: #f0f9ff;">
                                                            <td style="padding: 8px 10px; font-weight: 700; color: var(--text-navy);">Tổng cộng</td>
                                                            <td style="padding: 8px 10px; text-align: center; font-weight: 700;">${booking.totalRoomQuantity} phòng</td>
                                                            <td style="padding: 8px 10px; text-align: right; font-weight: 800; color: var(--brand-blue); font-size: 15px;">
                                                                <fmt:formatNumber value="${booking.overallTotalAmount}" type="number" groupingUsed="true" />đ
                                                            </td>
                                                        </tr>
                                                    </tbody>
                                                </table>
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

                                                    <%-- Parent booking rooms --%>
                                                    <div style="margin-bottom: 16px;">
                                                        <div style="font-size: 12px; font-weight: 700; color: var(--text-navy); margin-bottom: 8px; padding-bottom: 6px; border-bottom: 1px solid #e2e8f0;">
                                                            <i class="fa-solid fa-bed" style="margin-right: 4px; color: var(--brand-blue);"></i>
                                                            <c:out value="${booking.roomTypeName}" /> (${booking.roomQuantity} phòng)
                                                        </div>
                                                        <div class="assigned-rooms-list">
                                                            <c:choose>
                                                                <c:when test="${not empty assignedRooms}">
                                                                    <c:forEach var="ar" items="${assignedRooms}">
                                                                        <div class="assigned-room-item">
                                                                            <div class="room-icon"><i class="fa-solid fa-door-closed"></i></div>
                                                                            <div class="room-info">
                                                                                <span class="room-num">Phòng ${ar.roomNumber}</span>
                                                                                <span class="room-fl">${ar.floor}</span>
                                                                            </div>
                                                                        </div>
                                                                    </c:forEach>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span style="font-size: 12px; color: var(--text-muted); font-style: italic;">Chưa gán phòng</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                    </div>

                                                    <%-- Child booking rooms --%>
                                                    <c:forEach var="child" items="${empty childBookings ? [] : childBookings}">
                                                        <div style="margin-bottom: 16px;">
                                                            <div style="font-size: 12px; font-weight: 700; color: var(--text-navy); margin-bottom: 8px; padding-bottom: 6px; border-bottom: 1px solid #e2e8f0;">
                                                                <i class="fa-solid fa-bed" style="margin-right: 4px; color: var(--brand-blue);"></i>
                                                                <c:out value="${child.roomTypeName}" /> (${child.roomQuantity} phòng)
                                                            </div>
                                                            <div class="assigned-rooms-list">
                                                                <c:set var="childRooms"
                                                                       value="${empty childAssignedRoomsMap ? null : childAssignedRoomsMap[child.bookingId]}" />
                                                                <c:choose>
                                                                    <c:when test="${not empty childRooms}">
                                                                        <c:forEach var="ar" items="${childRooms}">
                                                                            <div class="assigned-room-item">
                                                                                <div class="room-icon"><i class="fa-solid fa-door-closed"></i></div>
                                                                                <div class="room-info">
                                                                                    <span class="room-num">Phòng ${ar.roomNumber}</span>
                                                                                    <span class="room-fl">${ar.floor}</span>
                                                                                </div>
                                                                            </div>
                                                                        </c:forEach>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span style="font-size: 12px; color: var(--text-muted); font-style: italic;">Chưa gán phòng</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                    </c:forEach>
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
            const roomPrices = {
            <c:forEach items="${roomTypesList}" var="rt">
                ${rt.typeId}: ${rt.basePrice},
            </c:forEach>
            };
            let childIds = [
            <c:forEach var="child" items="${childBookings}" varStatus="st">
            '${child.bookingId}'<c:if test="${!st.last}">,</c:if>
            </c:forEach>
            ];
            childIds = childIds.map(id => id.toString());

            function getRequiredQty(suffix) {
                const qtyInput = document.getElementById('editRoomQuantity_' + suffix);
                return parseInt(qtyInput ? qtyInput.value : "${booking.roomQuantity}") || 0;
            }

            function filterRooms(suffix) {
            let typeName = "";

            const sel = document.getElementById(
                suffix === 'parent'
                    ? 'editRoomTypeId_parent'
                    : 'editRoomTypeId_' + suffix
            );

            if (!sel) return;

            typeName = sel.selectedOptions?.[0]?.dataset?.typeName;

            const grid = document.getElementById('roomGrid_' + suffix);
            if (!grid) return;

            grid.querySelectorAll('.room-card').forEach(card => {

                const cardTypeName = card.dataset.roomTypeName;

                const match = typeName && cardTypeName === typeName;

                if (match) {
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

            updateSelection(suffix);
        }

            function updateSelection(suffix) {
                const grid = document.getElementById("roomGrid_" + suffix);
                if (!grid)
                    return;

                grid.querySelectorAll(".room-card").forEach(card => {
                    const cb = card.querySelector(".room-checkbox");
                    if (cb && cb.checked) {
                        card.classList.add("selected");
                    } else {
                        card.classList.remove("selected");
                    }
                });

                validateAllSelections();
            }

            function validateAllSelections() {
                let allValid = true;

                const pReq = getRequiredQty("parent");
                const pChecked = document.querySelectorAll(
                        "#roomGrid_parent .room-checkbox:checked"
                        ).length;

                if (pChecked !== pReq) {
                    allValid = false;
                }

                childIds.forEach(cid => {
                    const required = getRequiredQty(cid);
                    const checked = document.querySelectorAll(
                            "#roomGrid_" + cid + " .room-checkbox:checked"
                            ).length;

                    if (checked !== required) {
                        allValid = false;
                    }
                });
                
                const btn = document.getElementById("btnConfirmBooking");
                if (btn) {
                    btn.disabled = !allValid;
                }
            }

            /* Tính toán lại tổng tiền trên form khi sửa ngày/loại phòng/số lượng */
            function recalcAmount() {
                const checkIn = document.getElementById('editCheckIn').value;
                const checkOut = document.getElementById('editCheckOut').value;

                const displayNights = document.getElementById('displayNights');
                const totalAmountInput = document.getElementById('editTotalAmount');

                if (!checkIn || !checkOut)
                    return;

                const diff = new Date(checkOut) - new Date(checkIn);
                const nights = Math.floor(diff / (1000 * 60 * 60 * 24));

                if (nights <= 0) {
                    if (displayNights)
                        displayNights.textContent = "0 đêm";
                    if (totalAmountInput)
                        totalAmountInput.value = 0;
                    return;
                }

                if (displayNights)
                    displayNights.textContent = nights + " đêm";

                let total = 0;

                // Parent price
                const pSel = document.getElementById('editRoomTypeId_parent');
                const pQty = getRequiredQty('parent');
                if (pSel) {
                    const price = parseFloat(pSel.selectedOptions[0]?.dataset?.price || 0);
                    total += price * nights * pQty;
                }

                // Children price
                for (let cid of childIds) {
                    const cSel = document.getElementById('editRoomTypeId_' + cid);
                    const cQty = getRequiredQty(cid);

                    if (!cSel)
                        continue;

                    const price = parseFloat(
                            cSel.options[cSel.selectedIndex]?.dataset?.price || 0
                            );

                    total += price * nights * cQty;
                }

                const display = document.getElementById('displayTotalAmount');
                if (totalAmountInput) {
                    totalAmountInput.value = total.toFixed(0);
                }
                if (display) {
                    display.textContent =
                            Number(total).toLocaleString('vi-VN') + " VND";
                }
            }
            function onParentRoomTypeChange() {
                filterRooms("parent");
                document.querySelectorAll("#roomGrid_parent .room-checkbox").forEach(cb=>{
                    cb.checked=false;
                    cb.closest(".room-card").classList.remove("selected");
                });
                updateSelection("parent");
                recalcAmount();
                refreshRoomTypeOptions();
            }

            document.addEventListener("DOMContentLoaded", function () {
                const parentQty = document.getElementById("editRoomQuantity_parent");
                if (parentQty) {
                    parentQty.addEventListener("input", recalcAmount);
                }
                const checkIn = document.getElementById("editCheckIn");
                if (checkIn) {
                    checkIn.addEventListener("change", onDateChange);
                }
                const checkOut = document.getElementById("editCheckOut");
                if (checkOut) {
                    checkOut.addEventListener("change", onDateChange);
                }
                for (let cid of childIds) {
                    const qty = document.getElementById("editRoomQuantity_" + cid);
                    if (qty) {
                        qty.addEventListener("input", recalcAmount);
                    }
                    const type = document.getElementById("editRoomTypeId_" + cid);
                    if (type) {
                        type.addEventListener("change", function () {
                            onChildRoomTypeChange(cid);
                        });
                    }
                }
                recalcAmount();
                refreshRoomTypeOptions();

                requestAnimationFrame(() => {
                    filterRooms('parent');
                    updateSelection('parent');

                    if (Array.isArray(childIds)) {
                        childIds.forEach(cid => {
                            filterRooms(cid);
                            updateSelection(cid);
                        });
                    }
                });
                refreshRoomTypeOptions();

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
                recalcAmount();
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
                document.getElementById('actionField').value = action;
                const errDiv = document.getElementById('selection-error');
                errDiv.style.display = 'none';

                let allValid = true;

                const pReq = getRequiredQty('parent');
                const pChecked = document.querySelectorAll('#roomGrid_parent .room-checkbox:checked').length;

                if (pChecked !== pReq) allValid = false;

                for (let cid of childIds) {
                    const cReq = getRequiredQty(cid);
                    const cChecked = document.querySelectorAll('#roomGrid_' + cid + ' .room-checkbox:checked').length;
                    if (cChecked !== cReq) allValid = false;
                }

                if (action === 'confirm' && !allValid) {
                    errDiv.textContent = "Vui lòng chọn đủ phòng cho tất cả loại phòng.";
                    errDiv.style.display = 'block';
                    return;
                }

                const container = document.getElementById('hiddenRoomIdsContainer');
                container.innerHTML = '';

                document.querySelectorAll('#roomGrid_parent .room-checkbox:checked').forEach(cb => {
                    const input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = 'roomIds';
                    input.value = cb.value;
                    container.appendChild(input);
                });

                for (let cid of childIds) {
                    const typeSel = document.getElementById('editRoomTypeId_' + cid);

                    if (typeSel) {
                        const hiddenType = document.createElement('input');
                        hiddenType.type = 'hidden';
                        hiddenType.name = 'childRoomTypeId_' + cid;
                        hiddenType.value = typeSel.value;
                        container.appendChild(hiddenType);
                    }

                    document.querySelectorAll('#roomGrid_' + cid + ' .room-checkbox:checked')
                        .forEach(cb => {
                            const input = document.createElement('input');
                            input.type = 'hidden';
                            input.name = 'childRoomIds_' + cid;
                            input.value = cb.value;
                            container.appendChild(input);
                        });
                }

                if (action === 'confirm') {
                    const btn = document.getElementById('btnConfirmBooking');
                    if (btn) {
                        btn.disabled = true;
                        btn.innerHTML = 'Đang duyệt...';
                    }
                }

                if (action === 'update') {
                    const btn = document.getElementById('btnUpdateBooking');
                    if (btn) {
                        btn.disabled = true;
                        btn.innerHTML = 'Đang lưu...';
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
            function onChildRoomTypeChange(childId) {
                filterRooms(childId);
                document.querySelectorAll("#roomGrid_"+childId+" .room-checkbox").forEach(cb=>{
                    cb.checked=false;
                    cb.closest(".room-card").classList.remove("selected");
                });
                updateSelection(childId);
                recalcAmount();
                refreshRoomTypeOptions();
            }
            function applyRoomFilterAllGrids() {
                filterRooms('parent');

                for (let cid of childIds) {
                    filterRooms(cid);
                }
            }
            let debounceTimer;

            function reloadRooms() {
                clearTimeout(debounceTimer);

                debounceTimer = setTimeout(() => {
                    fetchAvailableRooms();
                }, 300);
            }
            function fetchAvailableRooms() {
                const checkIn = document.getElementById("editCheckIn").value;
                const checkOut = document.getElementById("editCheckOut").value;

                if (!checkIn || !checkOut) return Promise.resolve();

                const url = `${window.contextPath || ''}/receptionist/room/available`
                    + `?checkIn=${checkIn}&checkOut=${checkOut}`;

                fetch(url)
                    .then(res => res.json())
                    .then(data => {
                        updateRoomGrid(data);
                    })
                    .catch(err => console.error("Room fetch error:", err));
            }
            function updateRoomGrid(availableRooms) {
                const availableSet = new Set(
                    availableRooms.map(r => String(r.roomId))
                );

                document.querySelectorAll(".room-card").forEach(card => {
                    const roomId = String(card.dataset.roomId);

                    const checkbox = card.querySelector(".room-checkbox");

                    const isAvailable = availableSet.has(roomId);

                    // reset trạng thái cơ bản
                    card.classList.remove("card-disabled");

                    if (isAvailable) {
                        card.classList.add("card-avail");

                        if (checkbox) checkbox.disabled = false;

                    } else {
                        card.classList.add("card-disabled");

                        if (checkbox) {
                            checkbox.checked = false;
                            checkbox.disabled = true;
                        }
                    }
                });

                applyRoomFilterAllGrids();
                validateAllSelections();
            }
            function onDateChange() {
                recalcAmount();

                fetchAvailableRooms().then(() => {
                    applyRoomFilterAllGrids();
                });
            }
            function refreshRoomTypeOptions() {
                const selects = [];
                const parent = document.getElementById("editRoomTypeId_parent");

                if(parent){
                    selects.push(parent);
                }

                childIds.forEach(id=>{
                    const s=document.getElementById("editRoomTypeId_"+id);
                    if(s){
                        selects.push(s);
                    }
                });

                selects.forEach(select=>{
                    [...select.options].forEach(option=>{
                        option.disabled=false;
                    });
                });

                selects.forEach(current=>{
                    const used=new Set();
                    selects.forEach(other=>{
                        if(other===current) return;
                        used.add(other.value);
                    });
                    [...current.options].forEach(option=>{
                        if(option.value===current.value){
                            return;
                        }
                        if(used.has(option.value)){
                            option.disabled=true;
                        }
                    });
                });
            }
        </script>
    </body>
</html>