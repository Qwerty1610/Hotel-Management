<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer_booking.css?v=21" />
<fmt:setLocale value="vi_VN" />

<style>
    /* =========================
       SIDEBAR MENU
    ========================= */
    .sidebar-menu a {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 12px 16px;
        border-radius: 8px;
        color: #475569;
        font-weight: 600;
        text-decoration: none;
        font-size: 14.5px;
        transition: all 0.2s ease;
    }
    .sidebar-menu a:hover {
        background-color: #f1f5f9;
        color: var(--brand-blue);
    }
    .sidebar-menu a.active-sidebar-item {
        color: var(--brand-blue);
        background-color: var(--brand-blue-light);
        font-weight: 700;
    }
    .sidebar-menu a.active-sidebar-item:hover {
        background-color: var(--brand-blue-light);
        color: var(--brand-blue);
    }
    /* =========================
       MAINTENANCE TABLE
    ========================= */
    .maintenance-table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0;
        margin-top: 20px;
        background: white;
        border-radius: 16px;
        overflow: hidden;
        border: 1px solid #e2e8f0;
    }
    .maintenance-table thead {
        background: #f8fafc;
    }
    .maintenance-table th {
        padding: 14px 16px;
        text-align: left;
        font-size: 14px;
        font-weight: 700;
        color: #475569;
        border-bottom: 1px solid #e2e8f0;
    }
    .maintenance-table td {
        padding: 16px;
        vertical-align: top;
        border-bottom: 1px solid #f1f5f9;
    }
    .maintenance-table tr:last-child td {
        border-bottom: none;
    }
    .maintenance-table tbody tr {
        transition: background 0.2s ease;
    }
    .maintenance-table tbody tr:hover {
        background: #f8fafc;
    }
    /* =========================
        MAINTENANCE FORM
     ========================= */
    .maintenance-card{
        background:#ffffff;
        border:1px solid #e2e8f0;
        border-radius:18px;
        box-shadow:0 4px 18px rgba(0,0,0,.05);
        overflow:hidden;
    }

    .maintenance-header{
        padding:24px 30px;
        border-bottom:1px solid #e2e8f0;
        background:#f8fafc;
    }

    .maintenance-header h3{
        margin:0;
        font-size:22px;
        font-weight:700;
        color:#1e293b;
    }

    .maintenance-header i{
        color:var(--brand-blue);
        margin-right:8px;
    }

    .maintenance-card form{
        padding:30px;
    }

    .form-group{
        margin-bottom:24px;
    }

    .form-group label{
        display:block;
        margin-bottom:8px;
        font-weight:600;
        color:#334155;
    }

    .form-control{
        width:100%;
        height:44px;
        padding:10px 14px;
        border:1px solid #cbd5e1;
        border-radius:10px;
        font-size:14px;
        background:#fff;
        box-sizing:border-box;
        transition:.2s;
    }

    .form-control:focus{
        outline:none;
        border-color:var(--brand-blue);
        box-shadow:0 0 0 3px rgba(37,99,235,.12);
    }

    textarea.form-control{
        height:140px;
        resize:vertical;
        padding-top:12px;
    }

    .submit-area{
        display:flex;
        justify-content:flex-end;
        margin-top:30px;
    }
    /* =========================
       FORM CONTROL
    ========================= */
    .maintenance-table .form-control {
        width: 100%;
        padding: 10px 12px;
        border-radius: 10px;
        border: 1px solid #cbd5e1;
        font-size: 14px;
        color: #334155;
        background: #ffffff;
        transition: all 0.2s ease;
        box-sizing: border-box;
    }
    .maintenance-table .form-control:focus {
        outline: none;
        border-color: var(--brand-blue);
        box-shadow: 0 0 0 3px rgba(37,99,235,0.1);
    }
    textarea.form-control {
        resize: vertical;
        min-height: 90px;
    }
    /* =========================
       BUTTON ADD ISSUE
    ========================= */
    .btn-add-room{
        height:44px;
        padding:0 18px;
        display:flex;
        align-items:center;
        gap:8px;
        border-radius:10px;
        background:var(--brand-blue);
        color:#fff;
        border:none;
        cursor:pointer;
        font-weight:600;
    }

    .btn-add-room:hover{
        opacity:.9;
    }
    /* =========================
       REMOVE ROW BUTTON
    ========================= */
    .btn-remove-row {
        width: 38px;
        height: 38px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 10px;
        border: none;
        background: #fee2e2;
        color: #dc2626;
        cursor: pointer;
        transition: all 0.2s ease;
    }
    .btn-remove-row:hover {
        background: #fecaca;
        transform: scale(1.05);
    }
    .top-row{
        display:flex;
        justify-content:space-between;
        align-items:flex-end;
        gap:20px;
        margin-bottom:24px;
    }
    .top-row .form-group{
        flex:1;
        margin-bottom:0;
    }
    .issue-row{
        display:flex;
        align-items:center;
        gap:12px;
        margin-bottom:14px;
    }
    .issue-row select{
        flex:1;
    }
    .issue-row .btn-remove-row{
        flex-shrink:0;
    }
    .issue-row:first-child .btn-remove-row{
        display:none;
    }
    /* =========================
        SUBMIT BUTTON
     ========================= */
    .submit-area{
        margin-top:30px;
        display:flex;
        justify-content:flex-end;
    }

    .submit-maintenance{
        display:inline-flex;
        align-items:center;
        gap:8px;
        padding:12px 28px;
        border:none;
        border-radius:10px;
        background:#22c55e !important;
        color:#fff !important;
        font-size:15px;
        font-weight:600;
        cursor:pointer;
        transition:all .2s ease;
        box-shadow:0 4px 12px rgba(34,197,94,.25);
    }

    .submit-maintenance:hover{
        background:#16a34a !important;
        transform:translateY(-2px);
        box-shadow:0 6px 18px rgba(34,197,94,.35);
    }

    .submit-maintenance:active{
        transform:translateY(0);
    }

    .submit-maintenance i{
        font-size:15px;
    }
    /* =========================
       MOBILE RESPONSIVE
    ========================= */
    @media(max-width:768px){
        .maintenance-table {
            display:block;
            overflow-x:auto;
        }
        .maintenance-table th,
        .maintenance-table td {
            min-width:160px;
        }
    }
</style>

<body>

    <%-- Header Navigation --%>
    <nav class="navbar-rooms">
        <div class="logo">HotelOps</div>
        <ul class="nav-links">
            <li><a href="${pageContext.request.contextPath}/">Trang chủ</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/services">Dịch vụ</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/maintenance" class="active">Sự cố</a></li>
        </ul>

        <div class="nav-actions">
            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <div class="user-dropdown">
                        <button class="dropdown-trigger" type="button">
                            <i class="fa-solid fa-user-circle"></i>
                            <span>${sessionScope.user}</span>
                            <i class="fa-solid fa-chevron-down"
                               style="font-size: 10px; margin-left: 2px;"></i>
                        </button>
                        <div class="dropdown-menu">
                            <c:choose>
                                <c:when test="${sessionScope.role eq 'CUSTOMER'}">
                                    <a href="${pageContext.request.contextPath}/customer/profile"
                                       class="dropdown-item">
                                        <i class="fa-solid fa-id-card"></i> Hồ sơ
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/bookings"
                                       class="dropdown-item">
                                        <i class="fa-solid fa-calendar-check"></i> Đặt phòng của tôi
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/services"
                                       class="dropdown-item">
                                        <i class="fa-solid fa-bell-concierge"></i> Yêu cầu dịch vụ
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/maintenance"
                                       class="dropdown-item">
                                        <i class="fa-solid fa-screwdriver-wrench"></i> Yêu cầu sửa chữa
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/services/history"
                                       class="dropdown-item">
                                        <i class="fa-solid fa-clock-rotate-left"></i> Lịch sử yêu cầu
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <c:choose>
                                        <c:when test="${sessionScope.role eq 'ADMIN'}">
                                            <a href="${pageContext.request.contextPath}/admin/dashboard"
                                               class="dropdown-item">
                                                <i class="fa-solid fa-chart-line"></i> Dashboard Admin
                                            </a>
                                        </c:when>
                                        <c:when test="${sessionScope.role eq 'MANAGER'}">
                                            <a href="${pageContext.request.contextPath}/manager/dashboard"
                                               class="dropdown-item">
                                                <i class="fa-solid fa-chart-line"></i> Dashboard Manager
                                            </a>
                                        </c:when>
                                        <c:when test="${sessionScope.role eq 'RECEPTIONIST'}">
                                            <a href="${pageContext.request.contextPath}/receptionist/dashboard"
                                               class="dropdown-item">
                                                <i class="fa-solid fa-chart-line"></i> Dashboard
                                                Receptionist
                                            </a>
                                        </c:when>
                                        <c:when test="${sessionScope.role eq 'HOUSEKEEPING'}">
                                            <a href="${pageContext.request.contextPath}/housekeeping/dashboard"
                                               class="dropdown-item">
                                                <i class="fa-solid fa-chart-line"></i> Dashboard
                                                Housekeeping
                                            </a>
                                        </c:when>
                                    </c:choose>
                                </c:otherwise>
                            </c:choose>
                            <div class="dropdown-divider"></div>
                            <a href="${pageContext.request.contextPath}/logout"
                               class="dropdown-item logout-item">
                                <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/home/login" class="btn-login">Đăng
                        nhập</a>
                    </c:otherwise>
                </c:choose>
        </div>
    </nav>

    <div class="booking-container">
        <%-- Top Alerts --%>
        <c:if test="${not empty successMessage}">
            <div class="success-banner" id="serverSuccessMessage">
                <i class="fa-solid fa-circle-check" style="font-size: 20px;"></i>
                <div>
                    <strong>Thành công:</strong> ${successMessage}
                </div>
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="error-banner" id="serverValidationError">
                <i class="fa-solid fa-circle-exclamation" style="font-size: 20px;"></i>
                <div>
                    <strong>Lỗi:</strong> ${errorMessage}
                </div>
            </div>
        </c:if>

        <div style="display: flex; gap: 30px; align-items: start; margin-top: 20px;">
            <!-- Left Sidebar Navigation -->
            <div class="sidebar-menu"
                 style="width: 260px; flex-shrink: 0; background: #ffffff; border-radius: 20px; border: 1px solid #e2e8f0; padding: 24px; box-shadow: 0 4px 20px rgba(0,0,0,0.04);">
                <h3
                    style="font-size: 11px; font-weight: 700; color: #94a3b8; text-transform: uppercase; letter-spacing: 1px; margin-top: 0; margin-bottom: 20px;">
                    Bảo trì</h3>
                <ul
                    style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 8px;">
                    <li>
                        <a href="${pageContext.request.contextPath}/customer/maintenance"
                           class="active-sidebar-item">
                            <i class="fa-solid fa-screwdriver-wrench"
                               style="width: 20px; text-align: center;"></i> Yêu cầu sửa chữa
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/customer/maintenance/history">
                            <i class="fa-solid fa-clock-rotate-left"
                               style="width: 20px; text-align: center;"></i> Lịch sử sự cố
                        </a>
                    </li>
                </ul>
            </div>

            <!-- Right Content Area -->
            <div style="flex:1;">

                <!-- Form -->
                <div class="maintenance-card">
                    <div class="maintenance-header">
                        <div>
                            <h3>
                                <i class="fa-solid fa-screwdriver-wrench"></i>
                                Tạo yêu cầu sửa chữa
                            </h3>
                        </div>
                    </div>
                    <form method="post"
                          action="${pageContext.request.contextPath}/customer/maintenance">
                        <div class="top-row">

                            <div class="form-group">
                                <label>Số phòng</label>

                                <select
                                    name="bookingId"
                                    class="form-control"
                                    required>

                                    <option value="">
                                        -- Chọn phòng --
                                    </option>

                                    <c:choose>

                                        <c:when test="${not empty bookings}">
                                            <c:forEach items="${bookings}" var="booking">

                                                <option value="${booking.bookingId}">
                                                    Phòng ${booking.assignedRoomsStr}
                                                </option>

                                            </c:forEach>
                                        </c:when>

                                        <c:otherwise>

                                            <option value="">
                                                Không có phòng đang lưu trú
                                            </option>

                                        </c:otherwise>

                                    </c:choose>

                                </select>

                            </div>

                            <button
                                type="button"
                                class="btn-add-room"
                                onclick="addIssueRow()">

                                <i class="fa-solid fa-plus"></i>

                                Thêm sự cố

                            </button>

                        </div>

                        <div class="form-group">

                            <label>Loại sự cố</label>

                            <div id="issueContainer">

                                <div class="issue-row">

                                    <select
                                        name="issueTypeId"
                                        class="form-control"
                                        required>

                                        <option value="">
                                            -- Chọn sự cố --
                                        </option>

                                        <c:forEach items="${issueTypes}" var="issue">

                                            <option value="${issue.issueTypeId}">
                                                ${issue.issueName}
                                            </option>

                                        </c:forEach>

                                    </select>

                                    <button
                                        type="button"
                                        class="btn-remove-row"
                                        onclick="removeIssueRow(this)">

                                        <i class="fa-solid fa-trash"></i>

                                    </button>

                                </div>

                            </div>

                        </div>

                        <div class="form-group">

                            <label>Mô tả chung</label>

                            <textarea
                                name="description"
                                class="form-control"
                                rows="5"
                                placeholder="Nhập mô tả chung cho các sự cố..."></textarea>

                        </div>
                        <div class="submit-area">
                            <button type="submit"
                                    class="btn-login submit-maintenance">
                                <i class="fa-solid fa-paper-plane"></i>
                                Gửi yêu cầu
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <%-- Footer --%>
    <footer class="footer-white" id="lien-he" style="margin-top: 80px;">
        <div class="footer-white-grid">
            <div class="footer-white-about">
                <h3>HotelOps Pro</h3>
                <p>Hệ thống quản lý và nghỉ dưỡng đẳng cấp quốc tế, đem lại trải nghiệm sang trọng
                    vượt thời gian.</p>
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
                <p><i class="fa-solid fa-location-dot"></i> 123 Đường Lê Lợi, Quận 1, TP. Hồ Chí
                    Minh</p>
                <p><i class="fa-solid fa-envelope"></i> contact@hotelopspro.com</p>
                <span class="phone-number-white"><i class="fa-solid fa-phone"></i> 1900 6789</span>
            </div>
        </div>
        <div class="footer-white-bottom text-center">
            <p>&copy; 2026 HotelOps Pro. All rights reserved.</p>
        </div>
    </footer>
    <script>
        function addIssueRow() {

            const container = document.getElementById("issueContainer");

            const row = container.querySelector(".issue-row").cloneNode(true);

            row.querySelector("select").selectedIndex = 0;

            container.appendChild(row);

            updateRemoveButton();

        }

        function removeIssueRow(button) {

            const container = document.getElementById("issueContainer");

            if (container.querySelectorAll(".issue-row").length == 1) {

                alert("Phải có ít nhất một sự cố.");

                return;

            }

            button.parentElement.remove();

            updateRemoveButton();

        }

        function updateRemoveButton() {

            const rows = document.querySelectorAll(".issue-row");

            rows.forEach((row, index) => {

                const btn = row.querySelector(".btn-remove-row");

                btn.style.display = index == 0 ? "none" : "flex";

            });

        }

        window.onload = updateRemoveButton;
    </script>
</body>

</html>