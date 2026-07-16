<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Check-in Detail - HotelOps Pro</title>

        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/receptionist.css?v=5"/>

        <style>
            /* ================= PMS GLOBAL STYLE ================= */
            body{
                background:#f4f6f9;
                font-family:'Inter',sans-serif;
            }

            .section-card{
                background:#fff;
                border-radius:14px;
                padding:18px;
                margin-bottom:16px;
                box-shadow:0 2px 12px rgba(0,0,0,0.06);
                border:1px solid #eef2f7;
            }

            .section-card h3{
                font-size:14px;
                font-weight:700;
                color:#1e293b;
                margin-bottom:12px;
            }

            /* ================= SECTION 1 LAYOUT ================= */
            .grid-top{
                display:grid;
                grid-template-columns:repeat(4,1fr);
                gap:10px;
                margin-bottom:10px;
            }

            .grid-bottom{
                display:grid;
                grid-template-columns:repeat(2,1fr);
                gap:10px;
            }

            .field{
                padding:10px 12px;
                background:#f8fafc;
                border-radius:10px;
                font-size:13px;
            }

            /* ================= TABLE PMS STYLE ================= */
            .room-table{
                width:100%;
                border-collapse:collapse;
                font-size:13px;
            }

            .room-table th{
                text-align:left;
                padding:10px;
                background:#f1f5f9;
                font-size:12px;
                color:#64748b;
            }

            .room-table td{
                padding:10px;
                border-bottom:1px solid #f1f5f9;
            }

            .room-table tr:hover{
                background:#f8fafc;
            }

            /* ================= COMPANION LAYOUT ================= */
            #companionBody td:first-child{
                width:85%;
            }

            #companionBody td:last-child{
                width:15%;
                text-align:center;
            }

            #companionBody input{
                width:100%;
                padding:10px 12px;
                border:1px solid #e2e8f0;
                border-radius:10px;
                transition:0.2s;
            }

            #companionBody input:focus{
                border-color:#0ea5e9;
                outline:none;
                box-shadow:0 0 0 3px rgba(14,165,233,0.15);
            }

            /* ================= BUTTON STYLE ================= */
            .add-btn{
                background:#0ea5e9;
                color:#fff;
                border:none;
                padding:8px 12px;
                border-radius:10px;
                cursor:pointer;
                transition:0.2s;
            }

            .add-btn:hover{
                background:#0284c7;
                transform:translateY(-1px);
            }

            .btn-back{
                background:#64748b;
                color:#fff;
                border:none;
                padding:10px 14px;
                border-radius:10px;
                cursor:pointer;
                transition:0.2s;
            }

            .btn-back:hover{
                background:#475569;
            }

            .btn-confirm{
                background:#16a34a;
                color:#fff;
                border:none;
                padding:10px 14px;
                border-radius:10px;
                cursor:pointer;
                transition:0.2s;
            }

            .btn-confirm:hover{
                background:#15803d;
                transform:translateY(-1px);
            }

            .danger-btn{
                background:#ef4444;
                color:#fff;
                border:none;
                padding:6px 10px;
                border-radius:8px;
                cursor:pointer;
                transition:0.2s;
            }

            .danger-btn:hover{
                background:#dc2626;
            }

            /* ================= FOOTER ================= */
            .footer-bar{
                display:flex;
                justify-content:space-between;
                align-items:center;
                margin-top:20px;
                padding-top:10px;
                border-top:1px solid #e2e8f0;
            }
            .actions{
                display:flex;
                align-items:center;
                gap:16px;
            }

            .actions form{
                margin:0;
            }

            .actions button{
                min-width:180px;
                height:50px;
                font-size:15px;
                font-weight:600;
            }

            /* ================= MODAL ================= */
            .modal{
                display:none;
                position:fixed;
                inset:0;
                background:rgba(0,0,0,0.45);
                justify-content:center;
                align-items:center;
            }

            .modal-box{
                background:#fff;
                padding:22px;
                border-radius:14px;
                width:380px;
                text-align:center;
            }
            .btn-disabled {
                background: #94a3b8;
                color: #fff;
                cursor: not-allowed;
                opacity: 0.8;
                border: none;
            }

            .btn-confirm:hover {
                background: #15803d;
                transform: translateY(-1px);
                transition: 0.2s ease;
            }

            .btn-back:hover {
                background: #475569;
                transition: 0.2s ease;
            }

            .btn-danger:hover {
                background: #dc2626;
                transform: scale(1.05);
                transition: 0.2s ease;
            }
        </style>
    </head>

    <body class="dashboard-body">

        <c:set var="currentTab" value="checkin"/>

        <div class="dashboard-layout">

            <!-- ================= SIDEBAR ================= -->
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

            <!-- ================= MAIN ================= -->
            <div class="dashboard-main">

                <!-- TOPBAR -->
                <header class="main-topbar">
                    <div class="breadcrumb">
                        <span>Receptionist</span>

                        <span class="separator">&gt;</span>

                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=checkin"
                           style="text-decoration:none;color:var(--text-muted)">
                            Nhận phòng (Check-in)
                        </a>

                        <span class="separator">&gt;</span>

                        <span class="current">
                            Chi tiết Check-in #${booking.bookingId}
                        </span>
                    </div>

                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                        <i class="fa-solid fa-right-from-bracket"></i>
                        Đăng xuất
                    </a>
                </header>

                <main class="workspace-content">

                    <!-- ================= 1. BOOKING INFO ================= -->
                    <div class="section-card">
                        <h3>1. Chi tiết đặt phòng</h3>

                        <div class="grid-top">
                            <div class="field"><b>Mã:</b> #${booking.bookingId}</div>
                            <div class="field"><b>Khách:</b> ${booking.customerName}</div>
                            <div class="field"><b>SĐT:</b> ${displayPhone}</div>
                            <div class="field"><b>Email:</b> ${displayEmail}</div>
                        </div>

                        <div class="grid-bottom">
                            <div class="field"><b>Ngày đến:</b> ${booking.checkInDate}</div>
                            <div class="field"><b>Ngày đi:</b> ${booking.checkOutDate}</div>
                        </div>
                    </div>

                    <!-- ================= 2. ROOM ASSIGN ================= -->
                    <div class="section-card">
                        <h3>2. Danh sách phòng được xếp</h3>

                        <table class="room-table">
                            <thead>
                                <tr>
                                    <th>Số phòng</th>
                                    <th>Loại phòng</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="r" items="${rooms}">
                                    <tr>
                                        <td>${r.roomNumber}</td>
                                        <td>${r.typeName}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <!-- ================= 3. COMPANION ================= -->
                    <div class="section-card">
                        <div style="display:flex;justify-content:space-between;align-items:center;">
                            <h3>3. Bạn đồng hành</h3>
                            <button class="add-btn" type="button" onclick="addCompanion()">+ Thêm bạn đồng hành</button>
                        </div>

                        <table class="room-table">
                            <thead>
                                <tr>
                                    <th>Họ và tên</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody id="companionBody"></tbody>
                        </table>
                    </div>

                    <!-- ================= 4. REQUEST ================= -->
                    <div class="section-card">
                        <h3>4. Yêu cầu khách hàng</h3>
                        <textarea id="specialRequest" style="width:100%;height:80px"></textarea>
                    </div>

                    <!-- ================= 5. NOTES ================= -->
                    <div class="section-card">
                        <h3>5. Ghi chú</h3>
                        <textarea id="notes" style="width:100%;height:80px"></textarea>
                    </div>

                    <!-- ================= FOOTER ================= -->
                    <div class="footer-bar">

                        <div class="shield">
                            <i class="fa-solid fa-shield-halved" style="font-size:28px;color:#0ea5e9;"></i>
                            <span>Cam kết chính sách bảo mật của HotelOps</span>
                        </div>

                        <div class="actions">

                            <button class="btn-back" onclick="goBack()" type="button">
                                Quay lại
                            </button>

                            <c:choose>
                                <c:when test="${booking.status eq 'CheckedIn'}">
                                    <button class="btn btn-disabled" disabled>
                                        ✓ Đã check in
                                    </button>
                                </c:when>

                                <c:otherwise>
                                    <form method="post"
                                          action="${pageContext.request.contextPath}/receptionist/checkin-detail"
                                          onsubmit="prepareSubmit()">

                                        <input type="hidden" name="bookingId" value="${booking.bookingId}"/>
                                        <input type="hidden" name="specialRequest" id="hiddenRequest"/>
                                        <input type="hidden" name="notes" id="hiddenNotes"/>

                                        <div id="hiddenCompanions"></div>

                                        <button type="submit" class="btn btn-confirm">
                                            Xác nhận check in
                                        </button>

                                    </form>
                                </c:otherwise>
                            </c:choose>

                        </div>

                    </div>

                </main>
            </div>
        </div>

        <script>
            let i = 0;

            function addCompanion() {
                const body = document.getElementById("companionBody");

                const row = document.createElement("tr");

                row.innerHTML = `
        <td>
            <input type="text"
                   name="companions"
                   placeholder="Nhập họ và tên">
        </td>
        <td>
            <button type="button"
                    class="danger-btn"
                    onclick="this.closest('tr').remove()">
                Xóa
            </button>
        </td>
    `;

                body.appendChild(row);
            }

            function goBack() {
                window.location.href = "${pageContext.request.contextPath}/receptionist/dashboard?tab=checkin";
            }
            function lockCheckInButton() {
                const btn = document.getElementById("checkinBtn");

                btn.disabled = true;
                btn.innerText = "Đã check in";
                btn.style.background = "#94a3b8";
                btn.style.cursor = "not-allowed";
            }

            function prepareSubmit() {

                document.getElementById("hiddenRequest").value =
                        document.getElementById("specialRequest").value;

                document.getElementById("hiddenNotes").value =
                        document.getElementById("notes").value;

                const container = document.getElementById("hiddenCompanions");
                container.innerHTML = "";

                document.querySelectorAll("input[name='companions']").forEach(input => {
                    if (input.value.trim() !== "") {
                        const hidden = document.createElement("input");
                        hidden.type = "hidden";
                        hidden.name = "companions";
                        hidden.value = input.value;
                        container.appendChild(hidden);
                    }
                });
            }
        </script>

    </body>
</html>