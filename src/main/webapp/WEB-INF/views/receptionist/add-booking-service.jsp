<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Đặt yêu cầu dịch vụ - HotelOps Pro</title>

        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/receptionist.css?v=5"/>

        <style>
            /* ================= ALERT ================= */
            .alert {
                padding: 14px 18px;
                border-radius: 10px;
                margin-bottom: 20px;
                font-weight: 500;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .alert-success {
                background: #e8f8ee;
                color: #1b7f3b;
                border: 1px solid #b6e4c4;
            }

            .alert-danger {
                background: #fdecec;
                color: #c62828;
                border: 1px solid #f3b4b4;
            }

            /* ================= CARD ================= */

            .workspace-content{
                max-width:900px;
                margin:auto;
            }

            .service-card{
                background:#fff;
                border-radius:18px;
                padding:32px;
                box-shadow:0 8px 30px rgba(0,0,0,.08);
                border:1px solid #edf2f7;
            }

            .service-card h2{
                margin:0;
                font-size:26px;
                font-weight:700;
                color:#1f2937;
            }

            .service-card p{
                margin-top:8px;
                color:#6b7280;
                margin-bottom:28px;
            }

            /* ================= FORM ================= */

            .form-group{
                margin-bottom:22px;
            }

            .form-group label{
                display:block;
                margin-bottom:8px;
                font-weight:600;
                color:#374151;
            }

            .form-group select,
            .form-group input,
            .form-group textarea{
                width:100%;
                border:1px solid #d1d5db;
                border-radius:10px;
                padding:12px 15px;
                font-size:15px;
                font-family:inherit;
                transition:.25s;
                background:#fff;
                box-sizing:border-box;
            }

            .form-group textarea{
                resize:vertical;
                min-height:110px;
            }

            .form-group select:focus,
            .form-group input:focus,
            .form-group textarea:focus{
                outline:none;
                border-color:#2563eb;
                box-shadow:0 0 0 4px rgba(37,99,235,.15);
            }

            /* ================= BUTTON ================= */

            .form-actions{
                display:flex;
                justify-content:flex-end;
                margin-top:30px;
            }

            .btn-primary{
                background:#2563eb;
                color:white;
                border:none;
                border-radius:10px;
                padding:13px 28px;
                font-size:15px;
                font-weight:600;
                cursor:pointer;
                transition:.25s;
                display:flex;
                align-items:center;
                gap:10px;
            }

            .btn-primary:hover{
                background:#1d4ed8;
                transform:translateY(-2px);
                box-shadow:0 10px 20px rgba(37,99,235,.25);
            }

            .btn-primary:active{
                transform:translateY(0);
            }
            .total-box{
                margin-top:20px;
                padding:18px 22px;
                border-radius:12px;
                background:#f8fafc;
                border:1px solid #dbeafe;

                display:flex;
                justify-content:space-between;
                align-items:center;
            }

            .total-box span{
                font-size:15px;
                color:#475569;
                font-weight:600;
            }

            .total-box strong{
                color:#2563eb;
                font-size:24px;
                font-weight:700;
            }
            /* ================= RESPONSIVE ================= */

            @media(max-width:768px){

                .service-card{
                    padding:22px;
                }

                .form-actions{
                    justify-content:stretch;
                }

                .btn-primary{
                    width:100%;
                    justify-content:center;
                }

            }
        </style>
    </head>

    <body class="dashboard-body">

        <c:set var="currentTab" value="add-booking-service"/>

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

            <!-- ================= MAIN ================= -->
            <div class="dashboard-main">

                <!-- TOPBAR -->
                <header class="main-topbar">
                    <div class="breadcrumb">
                        <span>Receptionist</span>

                        <span class="separator">&gt;</span>

                        <span class="current">
                            Đặt yêu cầu cho khách
                        </span>
                    </div>

                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                        <i class="fa-solid fa-right-from-bracket"></i>
                        Đăng xuất
                    </a>
                </header>

                <main class="workspace-content">

                    <div class="service-card">

                        <h2>
                            <i class="fa-solid fa-bell-concierge"></i>
                            Đặt dịch vụ cho khách
                        </h2>

                        <p>
                            Chọn phòng đang sử dụng và dịch vụ khách yêu cầu.
                        </p>

                        <c:if test="${not empty success}">
                            <div class="alert alert-success">
                                <i class="fa-solid fa-circle-check"></i>
                                ${success}
                            </div>
                        </c:if>

                        <c:if test="${not empty error}">
                            <div class="alert alert-danger">
                                <i class="fa-solid fa-circle-exclamation"></i>
                                ${error}
                            </div>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/receptionist/add-booking-service"
                              method="post">

                            <div class="form-group">
                                <label>Phòng</label>
                                <select name="roomId" id="roomId" required>
                                    <option value="">-- Chọn phòng --</option>
                                    <c:forEach items="${rooms}" var="room">
                                        <option value="${room.roomId}"
                                                ${param.roomId == room.roomId.toString() ? 'selected' : ''}>
                                            Phòng ${room.roomNumber}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Dịch vụ</label>
                                <select name="serviceId" id="serviceId" required>
                                    <option value="">-- Chọn dịch vụ --</option>
                                    <c:forEach items="${services}" var="service">
                                        <option
                                            value="${service.serviceId}"
                                            data-price="${service.unitPrice}"
                                            ${param.serviceId == service.serviceId.toString() ? 'selected' : ''}>

                                            ${service.title}
                                            -
                                            <fmt:formatNumber value="${service.unitPrice}" type="number"/>
                                            /
                                            ${service.unit}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Số lượng</label>
                                <input
                                    type="number"
                                    id="quantity"
                                    name="quantity"
                                    min="1"
                                    value="${empty param.quantity ? 1 : param.quantity}"
                                    required>
                            </div>
                            <div class="total-box">
                                <span>Tổng tiền dịch vụ</span>

                                <strong id="totalPrice">
                                    0 VNĐ
                                </strong>
                            </div>
                            <div class="form-group">
                                <label>Ghi chú</label>
                                <textarea
                                    name="notes"
                                    rows="4">${fn:escapeXml(param.notes)}</textarea>
                            </div>
                            <div class="form-actions">
                                <button
                                    type="submit"
                                    class="btn btn-primary">
                                    <i class="fa-solid fa-check"></i>
                                    Xác nhận đặt dịch vụ
                                </button>
                            </div>
                        </form>
                    </div>
                </main>
            </div>
        </div>
    </body>
    <script>

        function updateTotal() {

            const service = document.getElementById("serviceId");
            const quantity = document.getElementById("quantity");

            const option = service.options[service.selectedIndex];

            let price = 0;

            if (option && option.dataset.price) {
                price = parseFloat(option.dataset.price);
            }

            let qty = parseInt(quantity.value);

            if (isNaN(qty) || qty < 1) {
                qty = 1;
            }

            const total = price * qty;

            document.getElementById("totalPrice").innerText =
                    total.toLocaleString('vi-VN') + " VNĐ";
        }

        document.getElementById("serviceId").addEventListener("change", updateTotal);

        document.getElementById("quantity").addEventListener("input", updateTotal);

        window.onload = updateTotal;

    </script>
</html>