<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../../includes/header.jsp" %>
<%--
    Trang Hồ sơ cá nhân (xem & chỉnh sửa) dùng chung cho mọi vai trò.
    - Customer: vào từ menu "Hồ sơ" (chrome thanh điều hướng trên cùng).
    - Các vai trò còn lại: vào bằng cách bấm avatar/tên (chrome dashboard).
    @author QuyPQ
--%>
<fmt:setLocale value="vi_VN" />

<%-- Resolve role-specific chrome & labels --%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="role" value="${sessionScope.role}" />
<c:set var="isCustomer" value="${role eq 'CUSTOMER'}" />
<c:set var="formAction" value="${ctx}${isCustomer ? '/customer/profile' : '/profile'}" />
<c:choose>
    <c:when test="${role eq 'ADMIN'}">
        <c:set var="dashboardUrl" value="${ctx}/admin/dashboard" />
        <c:set var="roleLabel" value="Quản trị viên" />
    </c:when>
    <c:when test="${role eq 'HOTEL_MANAGER'}">
        <c:set var="dashboardUrl" value="${ctx}/manager/dashboard" />
        <c:set var="roleLabel" value="Quản lý khách sạn" />
    </c:when>
    <c:when test="${role eq 'RECEPTIONIST'}">
        <c:set var="dashboardUrl" value="${ctx}/receptionist/dashboard" />
        <c:set var="roleLabel" value="Lễ tân" />
    </c:when>
    <c:when test="${role eq 'HOUSEKEEPING'}">
        <c:set var="dashboardUrl" value="${ctx}/housekeeping/dashboard" />
        <c:set var="roleLabel" value="Nhân viên buồng phòng" />
    </c:when>
    <c:otherwise>
        <c:set var="dashboardUrl" value="${ctx}/home" />
        <c:set var="roleLabel" value="Khách hàng" />
    </c:otherwise>
</c:choose>

<link rel="stylesheet" href="${ctx}/assets/css/profile.css?v=1" />
<c:choose>
    <c:when test="${isCustomer}">
        <link rel="stylesheet" href="${ctx}/assets/css/customer_booking.css?v=21" />
    </c:when>
    <c:otherwise>
        <link rel="stylesheet" href="${ctx}/assets/css/manager.css?v=3" />
    </c:otherwise>
</c:choose>

<body class="${isCustomer ? '' : 'dashboard-body'}">

<%-- ============== CUSTOMER CHROME: top navbar ============== --%>
<c:if test="${isCustomer}">
    <nav class="navbar-rooms">
        <div class="logo">HotelOps</div>
        <ul class="nav-links">
            <li><a href="${ctx}/">Trang chủ</a></li>
            <li><a href="${ctx}/rooms">Phòng</a></li>
            <li><a href="${ctx}/customer/bookings">Đặt phòng của tôi</a></li>
            <li><a href="${ctx}/customer/payments">Thanh toán</a></li>
        </ul>
        <div class="nav-actions">
            <div class="user-dropdown">
                <button class="dropdown-trigger" type="button">
                    <i class="fa-solid fa-user-circle"></i>
                    <span>${sessionScope.user}</span>
                    <i class="fa-solid fa-chevron-down" style="font-size: 10px; margin-left: 2px;"></i>
                </button>
                <div class="dropdown-menu">
                    <a href="${ctx}/customer/profile" class="dropdown-item">
                        <i class="fa-solid fa-id-card"></i> Hồ sơ
                    </a>
                    <a href="${ctx}/customer/bookings" class="dropdown-item">
                        <i class="fa-solid fa-calendar-check"></i> Đặt phòng của tôi
                    </a>
                    <a href="${ctx}/customer/services" class="dropdown-item">
                        <i class="fa-solid fa-bell-concierge"></i> Yêu cầu dịch vụ
                    </a>
                    <a href="${ctx}/customer/services/history" class="dropdown-item">
                        <i class="fa-solid fa-clock-rotate-left"></i> Lịch sử yêu cầu
                    </a>
                    <a href="${ctx}/customer/payments" class="dropdown-item">
                        <i class="fa-solid fa-credit-card"></i> Thanh toán & Lịch sử
                    </a>
                    <div class="dropdown-divider"></div>
                    <a href="${ctx}/logout" class="dropdown-item logout-item">
                        <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                    </a>
                </div>
            </div>
        </div>
    </nav>
</c:if>

<%-- ============== STAFF/ADMIN CHROME: dashboard topbar ============== --%>
<c:if test="${not isCustomer}">
<div class="dashboard-layout">
    <div class="dashboard-main" style="margin-left:0;width:100%;">
        <header class="main-topbar">
            <div class="breadcrumb">
                <span>Tài khoản</span>
                <span class="separator">&gt;</span>
                <span class="current">Hồ sơ cá nhân</span>
            </div>
            <div style="display:flex;align-items:center;gap:12px;">
                <a href="${dashboardUrl}" class="btn-logout" style="background:#f1f5f9;color:#1c2541;">
                    <i class="fa-solid fa-arrow-left"></i> Quay lại
                </a>
                <a href="${ctx}/logout" class="btn-logout">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </a>
            </div>
        </header>
</c:if>

        <%-- ============== SHARED PROFILE CONTENT ============== --%>
        <main class="profile-shell ${isCustomer ? 'profile-shell-customer' : 'workspace-content'}">
            <div class="profile-container">

                <div class="profile-page-head">
                    <h1>Hồ sơ cá nhân</h1>
                    <p>Xem và cập nhật thông tin tài khoản của bạn.</p>
                </div>

                <%-- ----- Toast feedback ----- --%>
                <c:if test="${param.result eq 'success'}">
                    <div class="profile-toast is-success">
                        <i class="fa-solid fa-circle-check"></i>
                        <span>Cập nhật hồ sơ thành công.</span>
                    </div>
                </c:if>
                <c:if test="${not empty param.error}">
                    <div class="profile-toast is-error">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        <span>
                            <c:choose>
                                <c:when test="${param.error eq 'name_required'}">Vui lòng nhập họ và tên.</c:when>
                                <c:when test="${param.error eq 'name_too_long'}">Họ và tên vượt quá độ dài cho phép (tối đa 100 ký tự).</c:when>
                                <c:when test="${param.error eq 'invalid_phone'}">Số điện thoại không hợp lệ. Định dạng: bắt đầu bằng 0, theo sau là 3/5/7/8/9 và 8 chữ số.</c:when>
                                <c:when test="${param.error eq 'phone_exists'}">Số điện thoại đã được sử dụng bởi một tài khoản khác.</c:when>
                                <c:otherwise>Đã có lỗi xảy ra. Vui lòng thử lại sau.</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </c:if>

                <%-- ===== VIEW PANEL ===== --%>
                <div id="profileViewPanel" class="profile-card">
                    <div class="profile-card-header">
                        <div class="profile-avatar-big">
                            <c:choose>
                                <c:when test="${not empty profile.fullName}">${fn:toUpperCase(fn:substring(profile.fullName,0,1))}</c:when>
                                <c:otherwise>U</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="profile-head-meta">
                            <h2><c:out value="${profile.fullName}" /></h2>
                            <span class="profile-role-badge">${roleLabel}</span>
                            <span class="profile-status-dot ${profile.active ? '' : 'inactive'}">
                                <span class="dot"></span>${profile.active ? 'Đang hoạt động' : 'Đã khoá'}
                            </span>
                        </div>
                    </div>
                    <div class="profile-card-body">
                        <div class="profile-info-grid">
                            <div class="profile-info-item">
                                <label>Email</label>
                                <span class="value"><i class="fa-solid fa-envelope"></i><c:out value="${profile.email}" /></span>
                            </div>
                            <div class="profile-info-item">
                                <label>Số điện thoại</label>
                                <c:choose>
                                    <c:when test="${not empty profile.phone}">
                                        <span class="value"><i class="fa-solid fa-phone"></i><c:out value="${profile.phone}" /></span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="value muted"><i class="fa-solid fa-phone"></i>Chưa cập nhật</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="profile-info-item">
                                <label>Vai trò</label>
                                <span class="value"><i class="fa-solid fa-user-shield"></i>${roleLabel}</span>
                            </div>
                            <div class="profile-info-item">
                                <label>Ngày tạo tài khoản</label>
                                <span class="value"><i class="fa-solid fa-calendar-day"></i>
                                    <c:choose>
                                        <c:when test="${not empty profile.createdAt}">
                                            <fmt:formatDate value="${profile.createdAt}" pattern="dd/MM/yyyy" />
                                        </c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                        </div>

                        <%-- Customer-only loyalty info (AF-2) --%>
                        <c:if test="${profile.customer}">
                            <div class="profile-loyalty">
                                <div class="profile-chip points">
                                    <div class="chip-icon"><i class="fa-solid fa-star"></i></div>
                                    <div class="chip-text">
                                        <small>Điểm tích luỹ</small>
                                        <strong><fmt:formatNumber value="${profile.loyaltyPoints}" type="number" /></strong>
                                    </div>
                                </div>
                                <div class="profile-chip member">
                                    <div class="chip-icon"><i class="fa-solid fa-gem"></i></div>
                                    <div class="chip-text">
                                        <small>Hạng thành viên</small>
                                        <strong><c:out value="${empty profile.membershipLevel ? 'Standard' : profile.membershipLevel}" /></strong>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                        <div class="profile-actions" style="display: flex; gap: 12px; flex-wrap: wrap;">
                            <button type="button" class="profile-btn profile-btn-primary" onclick="profileShowEdit()">
                                <i class="fa-solid fa-pen-to-square"></i> Chỉnh sửa hồ sơ
                            </button>
                            <button type="button" class="profile-btn profile-btn-ghost" onclick="openChangePasswordModal()" style="border: 1px solid var(--pf-border);">
                                <i class="fa-solid fa-key" style="color: var(--pf-blue);"></i> Đổi mật khẩu
                            </button>
                        </div>
                    </div>
                </div>

                <%-- ===== EDIT PANEL ===== --%>
                <div id="profileEditPanel" class="profile-card" style="display:none;">
                    <div class="profile-card-body">
                        <form method="post" action="${formAction}"
                              onsubmit="return profileValidate();">

                            <%-- Account info --%>
                            <div class="profile-form-section">
                                <h3 class="profile-section-title">Thông tin tài khoản</h3>
                                <p class="profile-section-sub">Cập nhật họ tên và số điện thoại liên hệ của bạn.</p>
                                <div class="profile-form-grid">
                                    <div class="profile-field full">
                                        <label>Họ và tên <span class="req">*</span></label>
                                        <input type="text" name="fullName" id="pfFullName" maxlength="100"
                                               value="${fn:escapeXml(profile.fullName)}" required />
                                    </div>
                                    <div class="profile-field">
                                        <label>Email</label>
                                        <input type="email" value="${fn:escapeXml(profile.email)}" disabled />
                                        <span class="hint">Email không thể thay đổi.</span>
                                    </div>
                                    <div class="profile-field">
                                        <label>Số điện thoại <span class="req">*</span></label>
                                        <input type="text" name="phone" id="pfPhone" maxlength="10"
                                               value="${fn:escapeXml(profile.phone)}"
                                               placeholder="VD: 0901234567" required />
                                        <span class="hint">Bắt đầu bằng 0, theo sau là 3/5/7/8/9 và 8 chữ số.</span>
                                    </div>
                                </div>
                            </div>

                            <div class="profile-actions">
                                <button type="submit" class="profile-btn profile-btn-primary">
                                    <i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi
                                </button>
                                <button type="button" class="profile-btn profile-btn-ghost" onclick="profileShowView()">
                                    <i class="fa-solid fa-xmark"></i> Huỷ
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

            </div>
        </main>

<c:if test="${not isCustomer}">
    </div><%-- end dashboard-main --%>
</div><%-- end dashboard-layout --%>
</c:if>

<script>
    function profileShowEdit() {
        document.getElementById('profileViewPanel').style.display = 'none';
        document.getElementById('profileEditPanel').style.display = 'block';
        var n = document.getElementById('pfFullName');
        if (n) { n.focus(); }
    }
    function profileShowView() {
        document.getElementById('profileEditPanel').style.display = 'none';
        document.getElementById('profileViewPanel').style.display = 'block';
    }
    function profileValidate() {
        var name = document.getElementById('pfFullName').value.trim();
        if (name === '') {
            alert('Vui lòng nhập họ và tên.');
            return false;
        }
        var phone = document.getElementById('pfPhone').value.trim();
        if (!/^0[35789]\d{8}$/.test(phone)) {
            alert('Số điện thoại không hợp lệ. Bắt đầu bằng 0, theo sau là 3/5/7/8/9 và 8 chữ số.');
            return false;
        }
        return true;
    }
    // Auto-open edit form when the server reported a validation error.
    (function () {
        var params = new URLSearchParams(window.location.search);
        if (params.has('error')) {
            profileShowEdit();
        }
    })();
</script>
<script>
    window.CHANGE_PASSWORD_API_URL = "${pageContext.request.contextPath}/${sessionScope.role eq 'ADMIN' ? 'admin' : (sessionScope.role eq 'HOTEL_MANAGER' ? 'manager' : (sessionScope.role eq 'RECEPTIONIST' ? 'receptionist' : (sessionScope.role eq 'HOUSEKEEPING' ? 'housekeeping' : 'customer')))}/change-password";
</script>
<script src="${pageContext.request.contextPath}/assets/js/change-password.js" charset="UTF-8"></script>
<jsp:include page="/WEB-INF/views/admin/includes/change-password-modal.jsp" />
</body>
</html>
