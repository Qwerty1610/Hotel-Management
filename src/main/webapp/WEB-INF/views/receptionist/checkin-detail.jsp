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
                border-radius:16px;
                padding:22px;
                margin-bottom:20px;
                box-shadow:0 8px 24px rgba(15,23,42,.06);
                border:1px solid #e6edf5;
                position:relative;
                overflow:hidden;
            }
            .section-card::before{
                content:"";
                position:absolute;
                left:0;
                top:0;
                width:5px;
                height:100%;
                background:linear-gradient(
                    180deg,
                    #0ea5e9,
                    #2563eb
                    );
            }

            .section-card::before{
                content:"";
                position:absolute;
                left:0;
                top:0;
                width:5px;
                height:100%;
                background:linear-gradient(
                    180deg,
                    #0ea5e9,
                    #2563eb
                    );
            }
            .section-card h3::before{
                content:"";
                width:10px;
                height:10px;
                border-radius:50%;
                background:#0ea5e9;
            }
            .section-card h3{
                display:flex;
                align-items:center;
                gap:10px;

                margin:0 0 18px;

                color:#1e293b;
                font-size:20px;
                font-weight:700;
            }
            .section-divider{
                margin:30px 0;
                border-top:1px solid #e5e7eb;
            }
            /* ================= CARD HEADER ================= */
            .card-detail-header{
                display:flex;
                justify-content:space-between;
                align-items:center;
                gap:16px;
                margin-bottom:22px;
                padding-bottom:18px;
                border-bottom:1px solid #e5e7eb;
            }
            .card-detail-title{
                margin:0;
                font-size:20px;
                font-weight:700;
                color:#1e293b;
            }

            /* ================= 2-COLUMN ROW LAYOUT ================= */
            .detail-row{
                display:grid;
                gap:24px;
                align-items:start;
            }
            .row-60-40{
                grid-template-columns:3fr 2fr;
            }
            .row-50-50{
                grid-template-columns:1fr 1fr;
            }
            .detail-col{
                display:flex;
                flex-direction:column;
                min-width:0;
            }
            .info-list{
                display:flex;
                flex-direction:column;
                gap:10px;
            }
            .info-item{
                display:flex;
                justify-content:space-between;
                align-items:center;
                gap:12px;
                background:#f8fbff;
                border:1px solid #dbeafe;
                border-radius:12px;
                padding:12px 16px;
                transition:.25s;
            }
            .info-item:hover{
                border-color:#60a5fa;
                box-shadow:0 6px 18px rgba(59,130,246,.08);
            }
            .info-item b{
                color:#64748b;
                font-size:12px;
                font-weight:600;
            }
            .info-item span{
                color:#1e293b;
                font-weight:700;
                font-size:14px;
                text-align:right;
            }

            /* ================= TÓM TẮT ĐẶT PHÒNG ================= */
            /* Đặt tên riêng (booking-summary-*) để tránh trùng với .summary-label/.summary-value
               dùng cho khối tổng tiền walk-in trong receptionist.css (đó là layout hàng ngang
               label-trái/value-phải, còn đây là layout xếp dọc theo từng cột). */
            .booking-summary-box{
                display:grid;
                grid-template-columns:repeat(4,1fr);
                gap:10px;
                background:#f8fafc;
                border:1px solid #e2e8f0;
                border-radius:12px;
                padding:16px 18px;
            }
            .booking-summary-item{
                display:flex;
                flex-direction:column;
                gap:6px;
                text-align:left;
            }
            .booking-summary-label{
                font-size:11px;
                font-weight:700;
                letter-spacing:.3px;
                text-transform:uppercase;
                color:#94a3b8;
                text-align:left;
            }
            .booking-summary-value{
                font-size:15px;
                font-weight:700;
                color:#1e293b;
                text-align:left;
            }

            .field{
                background:#f8fbff;
                border:1px solid #dbeafe;
                border-radius:12px;
                padding:14px 16px;

                display:flex;
                flex-direction:column;
                gap:6px;

                transition:.25s;
            }
            .field:hover{
                border-color:#60a5fa;
                box-shadow:0 6px 18px rgba(59,130,246,.08);
            }
            .field b{
                color:#64748b;
                font-size:12px;
                font-weight:600;
            }

            /* ================= TABLE PMS STYLE ================= */
            .room-table-wrap{
                border:1px solid #e2e8f0;
                border-radius:12px;
                overflow:hidden;
            }
            .room-table{
                width:100%;
                border-collapse:collapse;
                font-size:13px;
            }

            .room-table th{
                background:#f8fafc;
                color:#475569;
                font-weight:700;
                font-size:12px;
                text-transform:uppercase;
                letter-spacing:.3px;
                padding:14px;
                border-bottom:1px solid #e2e8f0;
            }

            .room-table td{
                padding:14px;
                border-bottom:1px solid #f1f5f9;
            }

            .room-table tbody tr:last-child td{
                border-bottom:none;
            }

            .room-table tbody tr:hover{
                background:#f1f5f9;
                transition:.2s;
            }

            /* ================= COMPANION LAYOUT ================= */
            #companionBody td{
                padding:10px;
                vertical-align:middle;
            }
            #companionBody td:first-child{
                width:auto;
            }

            #companionBody td:last-child{
                width:120px;
                text-align:center;
            }

            #companionBody input{
                width:100%;
                box-sizing:border-box;
                padding:10px 12px;
                border:1px solid #cbd5e1;
                border-radius:8px;
                background:#fff;
                transition:.2s;
            }

            #companionBody input:focus{
                outline:none;
                border-color:#3b82f6;
                box-shadow:0 0 0 3px rgba(59,130,246,.15);
            }
            #companionBody select{
                width:100%;
                padding:10px 12px;
                border:1px solid #cbd5e1;
                border-radius:8px;
                background:#fff;
            }

            #companionBody select:invalid{
                border:1px solid #ef4444;
            }

            #companionBody select:focus{
                outline:none;
                border-color:#3b82f6;
            }
            /* ================= BUTTON STYLE ================= */

            /* ---------- Add Companion ---------- */
            .add-btn{
                background:linear-gradient(135deg,#0ea5e9,#2563eb);
                color:#fff;
                border:none;
                border-radius:10px;
                padding:10px 16px;
                font-weight:600;
                cursor:pointer;

                box-shadow:0 5px 14px rgba(37,99,235,.18);

                transition:
                    transform .25s ease,
                    box-shadow .25s ease;
            }

            .add-btn:hover{
                transform:translateY(-3px);
                box-shadow:0 10px 24px rgba(37,99,235,.28);
            }


            /* ---------- Confirm ---------- */
            .btn-confirm{
                background:linear-gradient(135deg,#22c55e,#16a34a);
                color:#fff;

                border:none;
                outline:none;

                border-radius:10px;

                min-width:180px;
                height:50px;

                padding:10px 18px;

                display:flex;
                justify-content:center;
                align-items:center;

                font-size:15px;
                font-weight:600;

                cursor:pointer;

                box-shadow:0 5px 14px rgba(34,197,94,.20);

                transition:
                    transform .25s ease,
                    box-shadow .25s ease;
            }

            .btn-confirm:hover{
                transform:translateY(-3px);
                box-shadow:0 10px 24px rgba(34,197,94,.30);
            }


            /* ---------- Back ---------- */
            .btn-back{
                background:#64748b;
                color:#fff;
                border:none;
                border-radius:10px;

                padding:10px 14px;

                cursor:pointer;

                transition:
                    transform .25s ease,
                    box-shadow .25s ease,
                    background .25s ease;
            }

            .btn-back:hover{
                background:#475569;
                transform:translateY(-3px);
            }


            /* ---------- Danger ---------- */
            .danger-btn{
                background:#fee2e2;
                color:#dc2626;
                border:1px solid #fecaca;
                border-radius:8px;
                padding:8px 12px;
                font-weight:600;
                cursor:pointer;
                transition:
                    transform .25s ease,
                    box-shadow .25s ease,
                    background .25s ease,
                    color .25s ease;
            }

            .danger-btn:hover{
                background:#dc2626;
                color:#fff;
                transform:translateY(-2px);
            }

            /* ================= FOOTER ================= */
            .footer-bar{
                margin-top:40px;
                padding-top:20px;
                border-top:2px solid #e5e7eb;
                display:flex;
                justify-content:space-between;
                align-items:center;
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
            input[type=text],
            textarea{
                width:100%;
                box-sizing:border-box;
                border:1px solid #d6dce5;
                border-radius:12px;
                padding:12px 14px;
                font-size:14px;
                font-family:'Inter',sans-serif;
                background:#fff;
                transition:.25s;
            }
            input[type=text]:focus,
            textarea:focus{
                outline:none;
                border-color:#0ea5e9;
                box-shadow:
                    0 0 0 4px rgba(14,165,233,.15);
            }
            textarea{
                resize:vertical;
                min-height:80px;
                max-height:220px;
                line-height:1.6;
            }
            .extra-fee-box{
                margin-top:18px;
                background:#fff7ed;
                border:1px solid #fdba74;
                border-left:5px solid #f97316;
                padding:16px;
                border-radius:10px;
            }
            .extra-fee-box h4{
                margin:0 0 10px;
                color:#c2410c;
            }
            .extra-fee-box ul{
                margin:0;
                padding-left:18px;
            }
            .extra-fee-box li{
                margin-bottom:6px;
            }
            .extra-fee-total{
                margin-top:10px;
                font-weight:bold;
                color:#dc2626;
                font-size:18px;
            }
            .upload-box{
                width:260px;
            }
            .upload-label{
                display:block;
                cursor:pointer;
            }
            .upload-label input[type=file]{
                display:none;
            }
            .upload-content{
                border:2px dashed #3b82f6;
                border-radius:14px;
                padding:30px 20px;
                text-align:center;
                background:#f8fbff;
                transition:.25s;
            }
            .upload-content:hover{
                background:#eef6ff;
                border-color:#2563eb;
            }
            .upload-content i{
                font-size:42px;
                color:#3b82f6;
                margin-bottom:10px;
            }
            .upload-content span{
                display:block;
                font-weight:600;
                color:#1e293b;
            }
            .upload-content small{
                color:#64748b;
            }
            .preview-image{
                display:none;
                width:260px;
                height:170px;
                object-fit:cover;
                border-radius:12px;
                border:1px solid #dbeafe;
                margin-top:12px;
            }
            .upload-mini{
                border:2px dashed #cbd5e1;
                border-radius:10px;
                padding:12px;
                text-align:center;
                cursor:pointer;
                background:#fafafa;
            }
            .upload-mini:hover{
                border-color:#3b82f6;
            }
            .preview-small{
                display:none;
                width:120px;
                height:90px;
                object-fit:cover;
                border-radius:8px;
                border:1px solid #ddd;
            }
            .upload-box input[type=file],
            .upload-small input[type=file]{
                display:none;
            }
            .btn-confirm:disabled{
                background:#94a3b8;
                cursor:not-allowed;
                box-shadow:none;
                transform:none;
            }
            .btn-confirm:disabled:hover{
                background:#94a3b8;
                transform:none;
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

                    <li class="menu-item ${currentTab eq 'changerequests' ? 'active' : ''}">
                        <a
                            href="${pageContext.request.contextPath}/receptionist/dashboard?tab=changerequests">
                            <i class="fa-solid fa-pen-to-square"></i> <span>Thay đổi đặt phòng</span>
                        </a>
                    </li>

                    <li class="menu-item ${currentTab eq 'checkin' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=checkin">
                            <i class="fa-solid fa-key"></i> <span>Nhận phòng</span>
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

                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=checkin"
                           style="text-decoration:none;color:var(--text-muted)">
                            Nhận phòng
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
                    <form method="post"
                          enctype="multipart/form-data"
                          action="${pageContext.request.contextPath}/receptionist/checkin-detail">
                        <input type="hidden" name="bookingId" value="${booking.bookingId}"/>
                        <input type="hidden"
                               id="totalCapacity"
                               value="${totalCapacity}"/>
                        <input
                            type="hidden"
                            id="checkInDate"
                            value="${booking.checkInDate}"/>

                        <input
                            type="hidden"
                            id="checkOutDate"
                            value="${booking.checkOutDate}"/>
                        <input
                            type="hidden"
                            id="extraFee"
                            name="extraFee"
                            value="0"/>
                        <!-- ================= BOOKING INFO ================= -->
                        <div class="section-card">

                            <!-- ================= HEADER ================= -->
                            <div class="card-detail-header">
                                <h3 class="card-detail-title">Chi tiết đặt phòng #${booking.bookingId}</h3>
                                <c:choose>
                                    <c:when test="${booking.status eq 'Confirmed'}">
                                        <span class="status-pill pill-confirmed">
                                            <i class="fa-solid fa-circle"></i> Đã xác nhận
                                        </span>
                                    </c:when>
                                    <c:when test="${booking.status eq 'CheckedIn'}">
                                        <span class="status-pill pill-checkedin">
                                            <i class="fa-solid fa-circle"></i> Đã nhận phòng
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-pill pill-cancelled">${booking.status}</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <!-- ================= TÓM TẮT ĐẶT PHÒNG ================= -->
                            <h3>Tóm tắt đặt phòng</h3>
                            <div class="booking-summary-box">
                                <div class="booking-summary-item">
                                    <span class="booking-summary-label">Mã đặt phòng</span>
                                    <span class="booking-summary-value">#${booking.bookingId}</span>
                                </div>
                                <div class="booking-summary-item">
                                    <span class="booking-summary-label">Ngày đến</span>
                                    <span class="booking-summary-value">${booking.checkInDate}</span>
                                </div>
                                <div class="booking-summary-item">
                                    <span class="booking-summary-label">Ngày đi</span>
                                    <span class="booking-summary-value">${booking.checkOutDate}</span>
                                </div>
                                <div class="booking-summary-item">
                                    <span class="booking-summary-label">Số đêm</span>
                                    <span class="booking-summary-value">${booking.nights} đêm</span>
                                </div>
                            </div>

                            <div class="room-table-wrap" style="margin-top:14px;">
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

                            <!-- ================= XÁC MINH GIẤY TỜ ================= -->
                            <div class="section-divider"></div>
                            <h3>Xác minh giấy tờ</h3>
                            <div class="detail-row row-60-40">
                                <div class="detail-col">
                                    <div class="info-list">
                                        <div class="info-item"><b>Họ và tên</b><span>${booking.customerName}</span></div>
                                        <div class="info-item"><b>Số điện thoại</b><span>${booking.phone}</span></div>
                                        <div class="info-item"><b>Email</b><span>${booking.email}</span></div>
                                    </div>
                                </div>
                                <div class="detail-col">
                                    <c:choose>
                                        <c:when test="${booking.status eq 'Confirmed'}">
                                            <label>
                                                <b>Ảnh CCCD khách đại diện</b>
                                            </label>
                                            <div class="upload-box">
                                                <label class="upload-label">
                                                    <input
                                                        type="file"
                                                        id="customerImage"
                                                        name="customerImage"
                                                        accept="image/*"
                                                        onchange="
                                                                previewCustomerImage(this);
                                                                validateCheckIn();">

                                                    <div class="upload-content">
                                                        <i class="fa-solid fa-cloud-arrow-up"></i>

                                                        <span>Chọn ảnh CCCD</span>

                                                        <small>PNG, JPG, JPEG</small>
                                                    </div>

                                                    <img id="customerPreview" class="preview-image">
                                                </label>
                                            </div>
                                            <span id="customerImageError" class="error-message" style="display:none;">Khách phải có ảnh CCCD</span>
                                        </c:when>
                                        <c:when test="${booking.status eq 'CheckedIn'}">
                                            <label>
                                                <b>Ảnh CCCD khách đại diện</b>
                                            </label>
                                            <br>
                                            <img
                                                src="${checkIn.imageUrl}"
                                                style="
                                                width:220px;
                                                height:150px;
                                                object-fit:cover;
                                                border-radius:12px;
                                                border:1px solid #ddd;
                                                "
                                                />
                                        </c:when>
                                    </c:choose>
                                </div>
                            </div>

                            <!-- ================= BẠN ĐỒNG HÀNH ================= -->
                            <div class="section-divider"></div>
                            <div style="display:flex;justify-content:space-between;align-items:center;">
                                <h3>Bạn đồng hành <span id="companionError" class="error-message" style="display:none; margin-left:10px;"></span></h3>
                                <c:if test="${booking.status eq 'Confirmed'}">
                                    <button
                                        class="add-btn"
                                        type="button"
                                        onclick="addCompanion()">
                                        + Thêm bạn đồng hành
                                    </button>
                                </c:if>
                            </div>

                            <div class="room-table-wrap">
                                <table class="room-table">
                                    <thead>
                                        <tr>
                                            <th>Họ và tên</th>
                                            <th>Ảnh CCCD / Giấy khai sinh</th>
                                            <th>Độ tuổi</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody id="companionBody">
                                        <c:choose>
                                            <c:when test="${booking.status eq 'Confirmed'}">
                                            </c:when>
                                            <c:when test="${booking.status eq 'CheckedIn'}">
                                                <c:forEach var="c" items="${companions}">
                                                    <tr>
                                                        <td>
                                                            ${c.fullName}
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${not empty c.imageUrl}">
                                                                    <img
                                                                        src="${c.imageUrl}"
                                                                        style="
                                                                        width:120px;
                                                                        height:90px;
                                                                        object-fit:cover;
                                                                        border-radius:10px;
                                                                        "
                                                                        />
                                                                </c:when>
                                                                <c:otherwise>
                                                                    Không có ảnh
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            ${c.ageRange}
                                                        </td>
                                                        <td>
                                                            <span style="
                                                                  color:#10b981;
                                                                  font-weight:600;
                                                                  ">
                                                                Đã nhận phòng
                                                            </span>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                            <div id="extraFeeArea"
                                 style="margin-top:20px;">
                            </div>

                            <!-- ================= YÊU CẦU & GHI CHÚ (50/50) ================= -->
                            <div class="section-divider"></div>
                            <div class="detail-row row-50-50">
                                <div class="detail-col">
                                    <h3>Yêu cầu khách hàng</h3>
                                    <c:choose>
                                        <c:when test="${booking.status eq 'Confirmed'}">
                                            <textarea
                                                id="specialRequest"
                                                name="specialRequest"
                                                placeholder="Ví dụ: Phòng tầng cao..."></textarea>
                                        </c:when>
                                        <c:when test="${booking.status eq 'CheckedIn'}">
                                            <div class="field">
                                                <p>
                                                    <c:choose>
                                                        <c:when test="${not empty checkIn.specialRequest}">${checkIn.specialRequest}</c:when>
                                                        <c:otherwise><span style="color:#94a3b8;font-style:italic;">Không có yêu cầu</span></c:otherwise>
                                                    </c:choose>
                                                </p>
                                            </div>
                                        </c:when>
                                    </c:choose>
                                </div>
                                <div class="detail-col">
                                    <h3>Ghi chú nhân viên</h3>
                                    <c:choose>
                                        <c:when test="${booking.status eq 'Confirmed'}">
                                            <textarea
                                                id="notes"
                                                name="notes"
                                                placeholder="Ghi chú của nhân viên"></textarea>
                                        </c:when>
                                        <c:when test="${booking.status eq 'CheckedIn'}">
                                            <div class="field">
                                                <p>
                                                    <c:choose>
                                                        <c:when test="${not empty checkIn.notes}">${checkIn.notes}</c:when>
                                                        <c:otherwise><span style="color:#94a3b8;font-style:italic;">Không có ghi chú</span></c:otherwise>
                                                    </c:choose>
                                                </p>
                                            </div>
                                        </c:when>
                                    </c:choose>
                                </div>
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
                                            <button
                                                class="btn btn-disabled"
                                                disabled>
                                                ✓ Đã nhận phòng
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button
                                                id="checkinBtn"
                                                type="submit"
                                                class="btn-confirm">
                                                Xác nhận check in
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </form>
                </main>
            </div>
        </div>

        <script>
            let companionIndex = 0;
            const FEE = {
                Baby: 0,
                Child: 150000,
                Adult: 300000
            };
            function calculateExtraFee() {

                const capacity = parseInt(document.getElementById("totalCapacity").value);
                const checkIn = new Date(document.getElementById("checkInDate").value);
                const checkOut = new Date(document.getElementById("checkOutDate").value);

                const nights = Math.round(
                        (checkOut - checkIn) / (1000 * 60 * 60 * 24)
                        );

                // +1 vì có khách đại diện
                const totalPeople = document.querySelectorAll("#companionBody tr").length + 1;

                const extra = totalPeople - capacity;

                const area = document.getElementById("extraFeeArea");

                if (extra <= 0) {
                    area.innerHTML = "";
                    document.getElementById("extraFee").value = 0;
                    return;
                }

                const ages = [];

                document.querySelectorAll(".age-select").forEach(s => {
                    if (s.value)
                        ages.push(s.value);
                });

                const order = {
                    Baby: 1,
                    Child: 2,
                    Adult: 3
                };

                ages.sort((a, b) => order[a] - order[b]);

                const charged = ages.slice(0, extra);

                let html = `
                    <div class="extra-fee-box">
                        <h4>Phụ phí phát sinh</h4>
                        <ul>
                    `;

                let feePerNight = 0;
                charged.forEach(type => {
                    feePerNight += FEE[type];
                });
                const total = feePerNight * nights;

                html += `
                    </ul>
                    <div class="extra-fee-total">
                        Phụ phí mỗi đêm: \${feePerNight.toLocaleString()} VNĐ
                        <br>

                        Số đêm lưu trú: \${nights}
                        <br>

                        <strong>
                            Tổng phụ phí: \${total.toLocaleString()} VNĐ
                        </strong>
                    </div>

                    `;

                area.innerHTML = html;
                document.getElementById("extraFee").value = total;

            }
            function addCompanion() {
                const body = document.getElementById("companionBody");

                const index = companionIndex++;
                const row = document.createElement("tr");

                row.innerHTML = `
                    <td>
                        <input
                            type="text"
                            name="companions"
                            class="companion-name"
                            placeholder="Nhập họ và tên"
                            oninput="validateCheckIn()">
                    </td>
                    <td>
                        <div class="upload-small">
                            <label>
                                <input
                                    type="file"
                                    name="companionImage"
                                    class="companion-image"
                                    accept="image/*"
                                    onchange="
                                        previewCompanion(this);
                                        validateCheckIn();">
                                <div class="upload-mini">
                                    <i class="fa-solid fa-image"></i>
                                    Chọn ảnh
                                </div>
                                <img class="preview-small">
                            </label>
                        </div>
                    </td>
                    <td>
                        <select
                            name="ageRanges"
                            class="age-select"
                            onchange="
                                calculateExtraFee();
                                validateCheckIn();">

                            <option value="">-- Chọn --</option>
                            <option value="Baby">Dưới 6 tuổi</option>
                            <option value="Child">Trẻ em (6 - 14 tuổi)</option>
                            <option value="Adult">Người lớn (Từ 15 tuổi)</option>

                        </select>
                    </td>
                    <td>
                        <button
                            type="button"
                            class="danger-btn"
                            onclick="
                                this.closest('tr').remove();
                                calculateExtraFee();
                                validateCheckIn();
                            ">
                            Xóa
                        </button>
                    </td>
                `;

                body.appendChild(row);
                calculateExtraFee();
                validateCheckIn();
            }

            function goBack() {
                window.location.href = "${pageContext.request.contextPath}/receptionist/dashboard?tab=checkin";
            }
            function lockCheckInButton() {
                const btn = document.getElementById("checkinBtn");

                btn.disabled = true;
                btn.innerText = "Đã nhận phòng";
                btn.style.background = "#94a3b8";
                btn.style.cursor = "not-allowed";
            }

            function previewCustomerImage(input) {

                if (!input.files || !input.files[0]) {
                    return;
                }

                const reader = new FileReader();

                reader.onload = function (e) {

                    const img = document.getElementById("customerPreview");

                    img.src = e.target.result;
                    img.style.display = "block";

                    document.querySelector(".upload-content").style.display = "none";
                };

                reader.readAsDataURL(input.files[0]);
            }
            function previewCompanion(input) {

                if (!input.files.length)
                    return;

                const reader = new FileReader();

                reader.onload = function (e) {

                    const img = input.parentNode.querySelector(".preview-small");

                    img.src = e.target.result;
                    img.style.display = "block";

                    input.parentNode.querySelector(".upload-mini").style.display = "none";
                }

                reader.readAsDataURL(input.files[0]);
            }

            let submitAttempted = false;

            function validateCheckIn() {

                let valid = true;

                // CHECK CUSTOMER IMAGE
                const customerImage =
                        document.getElementById("customerImage");
                const customerImageError =
                        document.getElementById("customerImageError");
                let customerInvalid = false;

                if (customerImage && customerImage.files.length === 0) {
                    customerInvalid = true;
                    valid = false;
                }

                if (customerImageError) {
                    customerImageError.style.display =
                            (submitAttempted && customerInvalid) ? "inline" : "none";
                }

                // CHECK COMPANIONS
                let missingName = false;
                let missingImage = false;
                let missingAge = false;

                document.querySelectorAll("#companionBody tr").forEach(row => {
                    const name = row.querySelector(".companion-name");
                    const image = row.querySelector(".companion-image");
                    const age = row.querySelector(".age-select");

                    if (!name || name.value.trim() === "") {
                        missingName = true;
                    }
                    if (!image || image.files.length === 0) {
                        missingImage = true;
                    }
                    if (!age || age.value === "") {
                        missingAge = true;
                    }
                });

                const companionInvalid = missingName || missingImage || missingAge;
                if (companionInvalid) {
                    valid = false;
                }

                const companionError = document.getElementById("companionError");
                if (companionError) {
                    if (submitAttempted && companionInvalid) {
                        const parts = [];
                        if (missingName) {
                            parts.push("Họ và tên");
                        }
                        if (missingImage) {
                            parts.push("Ảnh CCCD / giấy khai sinh");
                        }
                        if (missingAge) {
                            parts.push("Độ tuổi");
                        }
                        companionError.innerText = "Hãy điền đầy đủ " + parts.join(", ");
                        companionError.style.display = "inline";
                    } else {
                        companionError.style.display = "none";
                    }
                }

                return valid;
            }

            document.addEventListener("DOMContentLoaded", function () {
                const form = document.querySelector("form");
                if (!form) {
                    return;
                }
                form.addEventListener("submit", function (e) {
                    submitAttempted = true;
                    if (!validateCheckIn()) {
                        e.preventDefault();
                    }
                });
            });
        </script>

    </body>
</html>