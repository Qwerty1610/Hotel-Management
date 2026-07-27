<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
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
    .status-badge{
        display:inline-flex;
        align-items:center;
        justify-content:center;
        min-width:110px;
        padding:6px 14px;
        border-radius:999px;
        font-size:13px;
        font-weight:600;
    }

    .status-pending{
        background:#fef3c7;
        color:#b45309;
    }

    .status-progress{
        background:#dbeafe;
        color:#2563eb;
    }

    .status-resolved{
        background:#dcfce7;
        color:#15803d;
    }

    .status-unresolvable{
        background:#fee2e2;
        color:#dc2626;
    }

    .status-cancelled{
        background:#fee2e2;
        color:#dc2626;
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
    .pagination-wrapper{
        display:flex;
        justify-content:flex-end;
        align-items:center;
        gap:12px;
        margin-top:20px;
    }
    .history-header{
        display:flex;
        justify-content:space-between;
        align-items:center;
    }

    .history-pagination{
        display:flex;
        align-items:center;
        gap:10px;
    }

    .page-btn{
        width:36px;
        height:36px;
        border:none;
        border-radius:10px;
        background:#2563eb;
        color:#fff;
        cursor:pointer;
        transition:.2s;
    }

    .page-btn:hover{
        background:#1d4ed8;
    }

    .page-btn:disabled{
        background:#cbd5e1;
        cursor:not-allowed;
    }

    #pageInfo{
        min-width:55px;
        text-align:center;
        font-weight:600;
        color:#475569;
    }
</style>

<body>

    <%-- Header Navigation --%>
    <nav class="navbar-rooms">
<a href="${pageContext.request.contextPath}/" class="logo">${not empty hotelName ? hotelName : 'HotelOps'}</a>
        <ul class="nav-links">
            <li><a href="${pageContext.request.contextPath}/">Trang chá»§</a></li>
            <li><a href="${pageContext.request.contextPath}/rooms">PhÃ²ng</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/bookings">Äáº·t phÃ²ng cá»§a tÃ´i</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/feedbacks">ÄÃ¡nh giÃ¡ lÆ°u trÃº</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/services">Dá»‹ch vá»¥</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/maintenance" class="active">Sá»± cá»‘</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/payments">Thanh toÃ¡n</a></li>
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
                                        <i class="fa-solid fa-id-card"></i> Há»“ sÆ¡
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/bookings"
                                       class="dropdown-item">
                                        <i class="fa-solid fa-calendar-check"></i> Äáº·t phÃ²ng cá»§a tÃ´i
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/feedbacks"
                                       class="dropdown-item">
                                        <i class="fa-solid fa-star"></i> ÄÃ¡nh giÃ¡ lÆ°u trÃº
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/services"
                                       class="dropdown-item">
                                        <i class="fa-solid fa-bell-concierge"></i> YÃªu cáº§u dá»‹ch vá»¥
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/maintenance"
                                       class="dropdown-item">
                                        <i class="fa-solid fa-screwdriver-wrench"></i> YÃªu cáº§u sá»­a chá»¯a
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/payments"
                                       class="dropdown-item">
                                        <i class="fa-solid fa-credit-card"></i> Thanh toÃ¡n &amp; Lá»‹ch sá»­
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
                                <i class="fa-solid fa-right-from-bracket"></i> ÄÄƒng xuáº¥t
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/home/login" class="btn-login">ÄÄƒng
                        nháº­p</a>
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
                    <strong>ThÃ nh cÃ´ng:</strong> ${successMessage}
                </div>
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="error-banner" id="serverValidationError">
                <i class="fa-solid fa-circle-exclamation" style="font-size: 20px;"></i>
                <div>
                    <strong>Lá»—i:</strong> ${errorMessage}
                </div>
            </div>
        </c:if>

        <div style="display: flex; gap: 30px; align-items: start; margin-top: 20px;">
            <!-- Left Sidebar Navigation -->
            <div class="sidebar-menu"
                 style="width: 260px; flex-shrink: 0; background: #ffffff; border-radius: 20px; border: 1px solid #e2e8f0; padding: 24px; box-shadow: 0 4px 20px rgba(0,0,0,0.04);">
                <h3
                    style="font-size: 11px; font-weight: 700; color: #94a3b8; text-transform: uppercase; letter-spacing: 1px; margin-top: 0; margin-bottom: 20px;">
                    Báº£o trÃ¬</h3>
                <ul
                    style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 8px;">
                    <li>
                        <a href="${pageContext.request.contextPath}/customer/maintenance">
                            <i class="fa-solid fa-screwdriver-wrench"
                               style="width: 20px; text-align: center;"></i> YÃªu cáº§u sá»­a chá»¯a
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/customer/maintenance/history"
                           class="active-sidebar-item">
                            <i class="fa-solid fa-clock-rotate-left"
                               style="width: 20px; text-align: center;"></i> Lá»‹ch sá»­ sá»­a chá»¯a
                        </a>
                    </li>
                </ul>
            </div>

            <!-- Right Content Area -->
            <div style="flex:1;">
                <div class="maintenance-card">
                    <div class="maintenance-header history-header">

                        <h3>
                            <i class="fa-solid fa-clock-rotate-left"></i>
                            Lá»‹ch sá»­ yÃªu cáº§u sá»­a chá»¯a
                        </h3>

                        <div class="history-pagination">

                            <button id="prevPage" class="page-btn">
                                <i class="fa-solid fa-chevron-left"></i>
                            </button>

                            <span id="pageInfo"></span>

                            <button id="nextPage" class="page-btn">
                                <i class="fa-solid fa-chevron-right"></i>
                            </button>

                        </div>

                    </div>
                    <div style="padding:30px;">
                        <c:choose>
                            <c:when test="${not empty maintenanceHistory}">
                                <table class="maintenance-table">
                                    <thead>
                                        <tr>
                                            <th>MÃ£ YC</th>
                                            <th>PhÃ²ng</th>
                                            <th>Sá»± cá»‘</th>
                                            <th>MÃ´ táº£</th>
                                            <th>Ghi chÃº nhÃ¢n viÃªn</th>
                                            <th>NgÃ y táº¡o</th>
                                            <th>Tráº¡ng thÃ¡i</th>
                                        </tr>
                                    </thead>
                                    <tbody id="historyTableBody">
                                        <c:forEach items="${maintenanceHistory}" var="item">
                                            <tr>
                                                <td>#${item.requestId}</td>
                                                <td>${item.roomNumbers}</td>

                                                <td>
                                                    <c:forEach items="${fn:split(item.issueNames, ',')}" var="issue">
                                                        <span>
                                                            ${issue}
                                                        </span>
                                                        <br>
                                                    </c:forEach>
                                                </td>

                                                <td>
                                                    <c:choose>
                                                        <c:when test="${empty item.description}">
                                                            <span style="color:#94a3b8;">
                                                                KhÃ´ng cÃ³
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            ${item.description}
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${empty item.resolutionNote}">
                                                            <span style="color:#94a3b8;">
                                                                ChÆ°a cÃ³
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            ${item.resolutionNote}
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    ${item.createdAt.dayOfMonth}/${item.createdAt.monthValue}/${item.createdAt.year}
                                                    ${item.createdAt.hour}:${item.createdAt.minute}
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${item.status eq 'Pending'}">
                                                            <span class="status-badge status-pending">
                                                                Chá» xá»­ lÃ½
                                                            </span>
                                                        </c:when>

                                                        <c:when test="${item.status eq 'InProgress'}">
                                                            <span class="status-badge status-progress">
                                                                Äang xá»­ lÃ½
                                                            </span>
                                                        </c:when>

                                                        <c:when test="${item.status eq 'Resolved'}">
                                                            <span class="status-badge status-resolved">
                                                                ÄÃ£ xá»­ lÃ½
                                                            </span>
                                                        </c:when>

                                                        <c:when test="${item.status eq 'Unresolvable'}">
                                                            <span class="status-badge status-unresolvable">
                                                                KhÃ´ng thá»ƒ xá»­ lÃ½
                                                            </span>
                                                        </c:when>

                                                        <c:when test="${item.status eq 'Cancelled'}">
                                                            <span class="status-badge status-cancelled">
                                                                ÄÃ£ há»§y
                                                            </span>
                                                        </c:when>

                                                        <c:otherwise>
                                                            <span class="status-badge">
                                                                ${item.status}
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:when>
                            <c:otherwise>
                                <div style="padding:70px 20px;text-align:center;color:#64748b;">
                                    <i class="fa-solid fa-box-open"
                                       style="font-size:60px;margin-bottom:18px;color:#cbd5e1;"></i>

                                    <h3 style="margin-bottom:8px;">
                                        ChÆ°a cÃ³ bÃ¡o cÃ¡o sá»± cá»‘ nÃ o
                                    </h3>

                                    <p>
                                        Khi báº¡n gá»­i yÃªu cáº§u sá»­a chá»¯a, lá»‹ch sá»­ sáº½ hiá»ƒn thá»‹ táº¡i Ä‘Ã¢y.
                                    </p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- Footer --%>
    <footer class="footer-white" id="lien-he" style="margin-top: 80px;">
        <div class="footer-white-grid">
            <div class="footer-white-about">
                <h3>HotelOps Pro</h3>
                <p>Há»‡ thá»‘ng quáº£n lÃ½ vÃ  nghá»‰ dÆ°á»¡ng Ä‘áº³ng cáº¥p quá»‘c táº¿, Ä‘em láº¡i tráº£i nghiá»‡m sang trá»ng
                    vÆ°á»£t thá»i gian.</p>
            </div>

            <div class="footer-white-links">
                <h4>LiÃªn káº¿t nhanh</h4>
                <ul>
                    <li><a href="#">Trang chá»§</a></li>
                    <li><a href="#">PhÃ²ng & GiÃ¡</a></li>
                    <li><a href="#">Dá»‹ch vá»¥</a></li>
                </ul>
            </div>

            <div class="footer-white-links">
                <h4>ChÃ­nh sÃ¡ch</h4>
                <ul>
                    <li><a href="#">ChÃ­nh sÃ¡ch báº£o máº­t</a></li>
                    <li><a href="#">Äiá»u khoáº£n sá»­ dá»¥ng</a></li>
                    <li><a href="#">ChÃ­nh sÃ¡ch hoÃ n tiá»n</a></li>
                </ul>
            </div>

            <div class="footer-white-contact">
                <h4>ThÃ´ng tin liÃªn há»‡</h4>
                <p><i class="fa-solid fa-location-dot"></i> 123 ÄÆ°á»ng LÃª Lá»£i, Quáº­n 1, TP. Há»“ ChÃ­
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
        const rowsPerPage = 10;
        const tbody = document.getElementById("historyTableBody");
        const rows = Array.from(tbody.querySelectorAll("tr"));
        let currentPage = 1;
        const totalPages = Math.ceil(rows.length / rowsPerPage);
        function showPage(page) {
            currentPage = page;
            rows.forEach((row, index) => {

                const start = (page - 1) * rowsPerPage;
                const end = start + rowsPerPage;
                row.style.display =
                        (index >= start && index < end)
                        ? ""
                        : "none";
            });
            document.getElementById("pageInfo").innerHTML =
                    totalPages === 0
                    ? "0 / 0"
                    : page + " / " + totalPages;
            document.getElementById("prevPage").disabled =
                    page === 1;
            document.getElementById("nextPage").disabled =
                    page === totalPages || totalPages === 0;
        }

        document.getElementById("prevPage").onclick = function () {

            if (currentPage > 1) {
                showPage(currentPage - 1);
            }

        }

        document.getElementById("nextPage").onclick = function () {

            if (currentPage < totalPages) {
                showPage(currentPage + 1);
            }

        }

        showPage(1);

    </script>
</body>

</html>