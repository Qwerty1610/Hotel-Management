<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Check-out & Thanh toán - HotelOps Pro</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
              rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/receptionist.css?v=5">
        <style>
            .invoice-card {
                background: #fff;
                border-radius: 12px;
                box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
                padding: 32px;
                max-width: 800px;
                margin: 0 auto;
            }

            .invoice-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                border-bottom: 2px dashed #eee;
                padding-bottom: 24px;
                margin-bottom: 24px;
            }

            .invoice-header h2 {
                font-size: 24px;
                color: #1e293b;
                margin-bottom: 8px;
            }

            .invoice-header p {
                color: #64748b;
                font-size: 14px;
            }

            .invoice-details {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
                margin-bottom: 32px;
            }

            .detail-item {
                background: #f8fafc;
                padding: 16px;
                border-radius: 8px;
            }

            .detail-item strong {
                display: block;
                color: #475569;
                font-size: 13px;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                margin-bottom: 4px;
            }

            .detail-item span {
                color: #0f172a;
                font-size: 16px;
                font-weight: 500;
            }

            .invoice-table {
                width: 100%;
                border-collapse: collapse;
                margin-bottom: 32px;
            }

            .invoice-table th,
            .invoice-table td {
                padding: 16px;
                text-align: left;
                border-bottom: 1px solid #e2e8f0;
            }

            .invoice-table th {
                color: #64748b;
                font-size: 14px;
                font-weight: 600;
                text-transform: uppercase;
            }

            .invoice-table td {
                color: #1e293b;
                font-weight: 500;
            }

            .invoice-table .amount-col {
                text-align: right;
            }

            .total-section {
                display: flex;
                justify-content: flex-end;
                margin-bottom: 32px;
            }

            .total-box {
                background: #f1f5f9;
                padding: 24px;
                border-radius: 12px;
                width: 300px;
            }

            .total-row {
                display: flex;
                justify-content: space-between;
                margin-bottom: 12px;
                color: #475569;
                font-size: 15px;
            }

            .total-row.grand-total {
                border-top: 2px solid #cbd5e1;
                padding-top: 12px;
                margin-top: 12px;
                color: #0f172a;
                font-size: 20px;
                font-weight: 700;
                margin-bottom: 0;
            }

            .payment-form {
                background: #fff;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                padding: 24px;
            }

            .form-group {
                margin-bottom: 16px;
            }

            .form-group label {
                display: block;
                margin-bottom: 8px;
                color: #475569;
                font-weight: 500;
            }

            .form-control {
                width: 100%;
                padding: 12px;
                border: 1px solid #cbd5e1;
                border-radius: 6px;
                font-family: inherit;
            }

            .btn-checkout {
                background: #2563eb;
                color: white;
                border: none;
                padding: 16px 24px;
                width: 100%;
                border-radius: 8px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.2s;
                display: flex;
                justify-content: center;
                align-items: center;
                gap: 10px;
            }

            .btn-checkout:hover {
                background: #1d4ed8;
            }

            .btn-back {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                color: #64748b;
                text-decoration: none;
                font-weight: 500;
                margin-bottom: 20px;
                transition: color 0.2s;
            }

            .btn-back:hover {
                color: #1e293b;
            }
        </style>
    </head>
    <fmt:setLocale value="vi_VN" />

    <body class="dashboard-body">

        <c:set var="currentTab" value="checkout" />

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
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=checkout"
                           style="text-decoration:none;color:var(--text-muted)">
                            Trả phòng & Thanh toán
                        </a>
                        <span class="separator">&gt;</span>
                        <span class="current">
                            Thủ tục Trả Phòng #${summary.bookingId}
                        </span>
                    </div>

                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                        <i class="fa-solid fa-right-from-bracket"></i>
                        Đăng xuất
                    </a>
                </header>

                <main class="workspace-content">

                    <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=checkout"
                       class="btn-back">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại
                    </a>

                    <div class="invoice-card">
                        <div class="invoice-header">
                            <div>
                                <h2>Thủ tục Trả Phòng (Check-out)</h2>
                                <p>Mã Booking: <strong style="color: #2563eb;">#${summary.bookingId}</strong></p>
                            </div>
                            <div style="text-align: right;">
                                <div style="font-size: 28px; color: #2563eb;"><i class="fa-solid fa-hotel"></i>
                                </div>
                                <div style="font-weight: 600; color: #1e293b; margin-top: 4px;">HotelOps Pro</div>
                            </div>
                        </div>

                        <div class="invoice-details">
                            <div class="detail-item">
                                <strong>Khách hàng</strong>
                                <span>${summary.customerName}</span>
                            </div>
                            <div class="detail-item">
                                <strong>Hạng phòng</strong>
                                <span>${summary.roomTypeName}</span>
                            </div>
                            <div class="detail-item">
                                <strong>Phòng số</strong>
                                <span style="color: #2563eb;">${summary.roomNumber}</span>
                            </div>
                            <div class="detail-item">
                                <strong>Thời gian lưu trú</strong>
                                <span style="font-size: 14px;">
                                    <fmt:formatDate value="${summary.checkInDate}" pattern="dd/MM/yyyy" />
                                    <i class="fa-solid fa-arrow-right" style="margin: 0 5px; color: #94a3b8;"></i>
                                    <fmt:formatDate value="${summary.checkOutDate}" pattern="dd/MM/yyyy" />
                                </span>
                            </div>
                            <div class="detail-item">
                                <strong>Trạng thái</strong>
                                <span style="color: #10b981;"><i class="fa-solid fa-circle-check"></i> Đang
                                    Check-in</span>
                            </div>
                        </div>

                        <table class="invoice-table">
                            <thead>
                                <tr>
                                    <th>Hạng mục</th>
                                    <th class="amount-col">Thành tiền</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>Tiền phòng</td>
                                    <td class="amount-col">
                                        <fmt:formatNumber value="${summary.roomCharge}" type="number"
                                                          groupingUsed="true" /> đ
                                    </td>
                                </tr>
                                <tr>
                                    <td>Dịch vụ (Minibar, Giặt ủi, v.v...)</td>
                                    <td class="amount-col">
                                        <fmt:formatNumber value="${summary.serviceCharge}" type="number"
                                                          groupingUsed="true" /> đ
                                    </td>
                                </tr>
                                <c:if test="${not empty summary.serviceItems}">
                                    <tr>
                                        <td colspan="2"
                                            style="padding: 0; background-color: #f8fafc; border-bottom: 1px solid #e2e8f0;">
                                            <table style="width: 100%; border-collapse: collapse; font-size: 13px;">
                                                <tbody>
                                                    <c:forEach var="item" items="${summary.serviceItems}">
                                                        <tr>
                                                            <td
                                                                style="padding: 8px 16px; border-bottom: 1px dashed #cbd5e1; color: #475569;">
                                                                <i class="fa-solid fa-caret-right"
                                                                   style="margin-right: 8px;"></i>
                                                                <c:out value="${item.description}" />
                                                                (x${item.quantity})
                                                            </td>
                                                            <td
                                                                style="padding: 8px 16px; border-bottom: 1px dashed #cbd5e1; text-align: right; color: #475569;">
                                                                <fmt:formatNumber value="${item.amount}"
                                                                                  type="number" groupingUsed="true" /> đ
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </td>
                                    </tr>
                                </c:if>
                                <tr>
                                    <td>Phụ phí quá số người ở</td>
                                    <td class="amount-col">
                                        <fmt:formatNumber value="${summary.extraCharge}" type="number"
                                                          groupingUsed="true" /> đ
                                    </td>
                                </tr>
                            </tbody>
                        </table>

                        <div class="total-section">
                            <div class="total-box">
                                <div class="total-row">
                                    <span>Tổng hóa đơn:</span>
                                    <span>
                                        <fmt:formatNumber value="${summary.totalAmount}" type="number"
                                                          groupingUsed="true" /> đ
                                    </span>
                                </div>
                                <div class="total-row" style="color: #10b981;">
                                    <span>Đã thanh toán: </span>
                                    <span>-
                                        <fmt:formatNumber value="${summary.amountPaid}" type="number"
                                                          groupingUsed="true" /> đ
                                    </span>
                                </div>
                                <div class="total-row grand-total"
                                     style="color: ${summary.remainingAmount > 0 ? '#ef4444' : '#10b981'}">
                                    <span>Cần phải trả:</span>
                                    <span>
                                        <fmt:formatNumber value="${summary.remainingAmount}" type="number"
                                                          groupingUsed="true" /> đ
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- Payment History -->
                        <div style="margin-top: 32px; margin-bottom: 32px;">
                            <h3 style="margin-top: 0; margin-bottom: 16px; color: #1e293b; font-size: 18px;"><i
                                    class="fa-solid fa-clock-rotate-left"></i> Lịch sử thanh toán</h3>
                                <c:choose>
                                    <c:when test="${not empty summary.paymentHistory}">
                                    <table class="invoice-table" style="margin-bottom: 0;">
                                        <thead>
                                            <tr style="background: #f8fafc;">
                                                <th>Thời gian</th>
                                                <th>Nội dung</th>
                                                <th>Hình thức</th>
                                                <th class="amount-col">Số tiền</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="pay" items="${summary.paymentHistory}">
                                                <tr>
                                                    <td>
                                                        <fmt:formatDate value="${pay.createdAt}"
                                                                        pattern="dd/MM/yyyy HH:mm" />
                                                    </td>
                                                    <td>
                                                        <c:out value="${pay.content}" />
                                                    </td>
                                                    <td>
                                                        <c:out value="${pay.gateway}" />
                                                    </td>
                                                    <td class="amount-col" style="color: #10b981;">+
                                                        <fmt:formatNumber value="${pay.amount}" type="number"
                                                                          groupingUsed="true" /> đ
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </c:when>
                                <c:otherwise>
                                    <div
                                        style="padding: 16px; background: #f8fafc; border-radius: 8px; color: #64748b; font-style: italic;">
                                        Chưa có giao dịch thanh toán nào.
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <form action="${pageContext.request.contextPath}/receptionist/checkout" method="post"
                              class="payment-form">
                            <input type="hidden" name="bookingId" value="${summary.bookingId}">

                            <h3 style="margin-top: 0; margin-bottom: 20px; color: #1e293b;">Thông tin thanh toán
                            </h3>

                            <div class="form-group">
                                <label>Phương thức thanh toán <span style="color: #ef4444;">*</span></label>
                                <select name="paymentMethod" class="form-control" required>
                                    <option value="">-- Chọn phương thức --</option>
                                    <option value="Cash">Tiền mặt (Cash)</option>
                                    <option value="Credit Card">Thẻ tín dụng/Ghi nợ (Card)</option>
                                    <option value="Bank Transfer">Chuyển khoản ngân hàng (QRPay)</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label>Ghi chú (Tùy chọn)</label>
                                <textarea name="notes" class="form-control" rows="3"
                                          placeholder="Ghi chú về thanh toán, phụ phí..."></textarea>
                            </div>

                            <button type="submit" class="btn-checkout"
                                    onclick="return confirm('Xác nhận hoàn tất trả phòng cho booking #${summary.bookingId}?');">
                                <i class="fa-solid fa-check-circle"></i> Hoàn tất Check-out
                            </button>
                        </form>

                    </div>

                </main>
            </div>
        </div>
    </body>

</html>