<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../../includes/header.jsp" %>
<%--
    Trang Há»“ sÆ¡ cÃ¡ nhÃ¢n (xem & chá»‰nh sá»­a) dÃ¹ng chung cho má»i vai trÃ².
    - Customer: vÃ o tá»« menu "Há»“ sÆ¡" (chrome thanh Ä‘iá»u hÆ°á»›ng trÃªn cÃ¹ng).
    - CÃ¡c vai trÃ² cÃ²n láº¡i: vÃ o báº±ng cÃ¡ch báº¥m avatar/tÃªn (chrome dashboard).
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
        <c:set var="roleLabel" value="Quáº£n trá»‹ viÃªn" />
    </c:when>
    <c:when test="${role eq 'HOTEL_MANAGER'}">
        <c:set var="dashboardUrl" value="${ctx}/manager/dashboard" />
        <c:set var="roleLabel" value="Quáº£n lÃ½ khÃ¡ch sáº¡n" />
    </c:when>
    <c:when test="${role eq 'RECEPTIONIST'}">
        <c:set var="dashboardUrl" value="${ctx}/receptionist/dashboard" />
        <c:set var="roleLabel" value="Lá»… tÃ¢n" />
    </c:when>
    <c:when test="${role eq 'HOUSEKEEPING'}">
        <c:set var="dashboardUrl" value="${ctx}/housekeeping/dashboard" />
        <c:set var="roleLabel" value="NhÃ¢n viÃªn buá»“ng phÃ²ng" />
    </c:when>
    <c:otherwise>
        <c:set var="dashboardUrl" value="${ctx}/home" />
        <c:set var="roleLabel" value="KhÃ¡ch hÃ ng" />
    </c:otherwise>
</c:choose>

<link rel="stylesheet" href="${ctx}/assets/css/profile.css?v=2" />
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
<a href="${pageContext.request.contextPath}/" class="logo">${not empty hotelName ? hotelName : 'HotelOps'}</a>
        <ul class="nav-links">
            <li><a href="${ctx}/">Trang chá»§</a></li>
            <li><a href="${ctx}/rooms">PhÃ²ng</a></li>
            <li><a href="${ctx}/customer/bookings">Äáº·t phÃ²ng cá»§a tÃ´i</a></li>
            <li><a href="${ctx}/customer/feedbacks">ÄÃ¡nh giÃ¡ lÆ°u trÃº</a></li>
            <li><a href="${ctx}/customer/services">Dá»‹ch vá»¥</a></li>
            <li><a href="${ctx}/customer/maintenance">Sá»± cá»‘</a></li>
            <li><a href="${ctx}/customer/payments">Thanh toÃ¡n</a></li>
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
                        <i class="fa-solid fa-id-card"></i> Há»“ sÆ¡
                    </a>
                    <a href="${ctx}/customer/bookings" class="dropdown-item">
                        <i class="fa-solid fa-calendar-check"></i> Äáº·t phÃ²ng cá»§a tÃ´i
                    </a>
                    <a href="${ctx}/customer/booking/change" class="dropdown-item">
                        <i class="fa-solid fa-pen-to-square"></i> Thay Ä‘á»•i Ä‘áº·t phÃ²ng
                    </a>
                    <a href="${ctx}/customer/feedbacks" class="dropdown-item">
                        <i class="fa-solid fa-star"></i> ÄÃ¡nh giÃ¡ lÆ°u trÃº
                    </a>
                    <a href="${ctx}/customer/services" class="dropdown-item">
                        <i class="fa-solid fa-bell-concierge"></i> YÃªu cáº§u dá»‹ch vá»¥
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/maintenance" class="dropdown-item">
                        <i class="fa-solid fa-screwdriver-wrench"></i> YÃªu cáº§u sá»­a chá»¯a
                    </a>
                    <a href="${ctx}/customer/payments" class="dropdown-item">
                        <i class="fa-solid fa-credit-card"></i> Thanh toÃ¡n & Lá»‹ch sá»­
                    </a>
                    <div class="dropdown-divider"></div>
                    <a href="${ctx}/logout" class="dropdown-item logout-item">
                        <i class="fa-solid fa-right-from-bracket"></i> ÄÄƒng xuáº¥t
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
                <span>TÃ i khoáº£n</span>
                <span class="separator">&gt;</span>
                <span class="current">Há»“ sÆ¡ cÃ¡ nhÃ¢n</span>
            </div>
            <div style="display:flex;align-items:center;gap:12px;">
                <a href="${dashboardUrl}" class="btn-logout" style="background:#f1f5f9;color:#1c2541;">
                    <i class="fa-solid fa-arrow-left"></i> Quay láº¡i
                </a>
                <a href="${ctx}/logout" class="btn-logout">
                    <i class="fa-solid fa-right-from-bracket"></i> ÄÄƒng xuáº¥t
                </a>
            </div>
        </header>
</c:if>

        <%-- ============== SHARED PROFILE CONTENT ============== --%>
        <main class="profile-shell ${isCustomer ? 'profile-shell-customer' : 'workspace-content'}">
            <div class="profile-container">

                <div class="profile-page-head">
                    <h1>Há»“ sÆ¡ cÃ¡ nhÃ¢n</h1>
                    <p>Xem vÃ  cáº­p nháº­t thÃ´ng tin tÃ i khoáº£n cá»§a báº¡n.</p>
                </div>

                <%-- ----- Toast feedback ----- --%>
                <c:if test="${param.result eq 'success'}">
                    <div class="profile-toast is-success">
                        <i class="fa-solid fa-circle-check"></i>
                        <span>Cáº­p nháº­t há»“ sÆ¡ thÃ nh cÃ´ng.</span>
                    </div>
                </c:if>
                <c:if test="${not empty param.error}">
                    <div class="profile-toast is-error">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        <span>
                            <c:choose>
                                <c:when test="${param.error eq 'name_required'}">Vui lÃ²ng nháº­p há» vÃ  tÃªn.</c:when>
                                <c:when test="${param.error eq 'name_too_long'}">Há» vÃ  tÃªn vÆ°á»£t quÃ¡ Ä‘á»™ dÃ i cho phÃ©p (tá»‘i Ä‘a 100 kÃ½ tá»±).</c:when>
                                <c:when test="${param.error eq 'invalid_phone'}">Sá»‘ Ä‘iá»‡n thoáº¡i khÃ´ng há»£p lá»‡. Äá»‹nh dáº¡ng: báº¯t Ä‘áº§u báº±ng 0, theo sau lÃ  3/5/7/8/9 vÃ  8 chá»¯ sá»‘.</c:when>
                                <c:when test="${param.error eq 'phone_exists'}">Sá»‘ Ä‘iá»‡n thoáº¡i Ä‘Ã£ Ä‘Æ°á»£c sá»­ dá»¥ng bá»Ÿi má»™t tÃ i khoáº£n khÃ¡c.</c:when>
                                <c:otherwise>ÄÃ£ cÃ³ lá»—i xáº£y ra. Vui lÃ²ng thá»­ láº¡i sau.</c:otherwise>
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
                                <span class="dot"></span>${profile.active ? 'Äang hoáº¡t Ä‘á»™ng' : 'ÄÃ£ khoÃ¡'}
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
                                <label>Sá»‘ Ä‘iá»‡n thoáº¡i</label>
                                <c:choose>
                                    <c:when test="${not empty profile.phone}">
                                        <span class="value"><i class="fa-solid fa-phone"></i><c:out value="${profile.phone}" /></span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="value muted"><i class="fa-solid fa-phone"></i>ChÆ°a cáº­p nháº­t</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="profile-info-item">
                                <label>Vai trÃ²</label>
                                <span class="value"><i class="fa-solid fa-user-shield"></i>${roleLabel}</span>
                            </div>
                            <div class="profile-info-item">
                                <label>NgÃ y táº¡o tÃ i khoáº£n</label>
                                <span class="value"><i class="fa-solid fa-calendar-day"></i>
                                    <c:choose>
                                        <c:when test="${not empty profile.createdAt}">
                                            <fmt:formatDate value="${profile.createdAt}" pattern="dd/MM/yyyy" />
                                        </c:when>
                                        <c:otherwise>â€”</c:otherwise>
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
                                        <small>Äiá»ƒm tÃ­ch luá»¹</small>
                                        <strong><fmt:formatNumber value="${profile.loyaltyPoints}" type="number" /></strong>
                                    </div>
                                </div>
                                <div class="profile-chip member">
                                    <div class="chip-icon"><i class="fa-solid fa-gem"></i></div>
                                    <div class="chip-text">
                                        <small>Háº¡ng thÃ nh viÃªn</small>
                                        <strong><c:out value="${empty profile.membershipLevel ? 'Standard' : profile.membershipLevel}" /></strong>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                        <div class="profile-actions" style="display: flex; gap: 12px; flex-wrap: wrap;">
                            <button type="button" class="profile-btn profile-btn-primary" onclick="profileShowEdit()">
                                <i class="fa-solid fa-pen-to-square"></i> Chá»‰nh sá»­a há»“ sÆ¡
                            </button>
                            <button type="button" class="profile-btn profile-btn-ghost" onclick="openChangePasswordModal()" style="border: 1px solid var(--pf-border);">
                                <i class="fa-solid fa-key" style="color: var(--pf-blue);"></i> Äá»•i máº­t kháº©u
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
                                <h3 class="profile-section-title">ThÃ´ng tin tÃ i khoáº£n</h3>
                                <p class="profile-section-sub">Cáº­p nháº­t há» tÃªn vÃ  sá»‘ Ä‘iá»‡n thoáº¡i liÃªn há»‡ cá»§a báº¡n.</p>
                                <div class="profile-form-grid">
                                    <div class="profile-field full">
                                        <label>Há» vÃ  tÃªn <span class="req">*</span></label>
                                        <input type="text" name="fullName" id="pfFullName" maxlength="100"
                                               value="${fn:escapeXml(profile.fullName)}" required />
                                    </div>
                                    <div class="profile-field">
                                        <label>Email</label>
                                        <input type="email" value="${fn:escapeXml(profile.email)}" disabled />
                                        <span class="hint">Email khÃ´ng thá»ƒ thay Ä‘á»•i.</span>
                                    </div>
                                    <div class="profile-field">
                                        <label>Sá»‘ Ä‘iá»‡n thoáº¡i <span class="req">*</span></label>
                                        <input type="text" name="phone" id="pfPhone" maxlength="10"
                                               value="${fn:escapeXml(profile.phone)}"
                                               placeholder="VD: 0901234567" required />
                                        <span class="hint">Báº¯t Ä‘áº§u báº±ng 0, theo sau lÃ  3/5/7/8/9 vÃ  8 chá»¯ sá»‘.</span>
                                    </div>
                                </div>
                            </div>

                            <div class="profile-actions">
                                <button type="submit" class="profile-btn profile-btn-primary">
                                    <i class="fa-solid fa-floppy-disk"></i> LÆ°u thay Ä‘á»•i
                                </button>
                                <button type="button" class="profile-btn profile-btn-ghost" onclick="profileShowView()">
                                    <i class="fa-solid fa-xmark"></i> Huá»·
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
            alert('Vui lÃ²ng nháº­p há» vÃ  tÃªn.');
            return false;
        }
        var phone = document.getElementById('pfPhone').value.trim();
        if (!/^0[35789]\d{8}$/.test(phone)) {
            alert('Sá»‘ Ä‘iá»‡n thoáº¡i khÃ´ng há»£p lá»‡. Báº¯t Ä‘áº§u báº±ng 0, theo sau lÃ  3/5/7/8/9 vÃ  8 chá»¯ sá»‘.');
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
