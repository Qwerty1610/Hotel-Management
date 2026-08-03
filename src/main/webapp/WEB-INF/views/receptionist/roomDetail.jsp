<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Phòng ${room.roomNumber} - HotelOps Pro</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
              rel="stylesheet" />
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/receptionist.css?v=4" />
        <style>
            /* ================= ROOM DETAIL ================= */

            .room-detail-image{
                width:100%;
                max-width:320px;
                height:200px;
                object-fit:cover;
                border-radius:12px;
                border:1px solid #e2e8f0;
            }

            .room-detail-header{
                display:flex;
                align-items:flex-start;
                gap:24px;
            }

            .room-detail-image-col{
                flex-shrink:0;
                width:320px;
                max-width:100%;
            }

            .room-detail-info-col{
                flex:1;
                min-width:0;
                display:flex;
                flex-direction:column;
                gap:0;
            }

            .room-detail-info-col .badge-status{
                align-self:flex-start;
                margin-top:12px;
            }

            @media(max-width:768px){
                .room-detail-header{
                    flex-direction:column;
                }
                .room-detail-image-col{
                    width:100%;
                }
                .room-detail-image{
                    max-width:100%;
                }
            }

            .empty-history{
                text-align:center;
                color:var(--text-muted);
                padding:32px 0;
            }
        </style>
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
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=bookings">
                            <i class="fa-solid fa-calendar-check"></i> <span>Yêu cầu đặt phòng</span>
                        </a>
                    </li>

                    <li class="menu-item">
                        <a
                            href="${pageContext.request.contextPath}/receptionist/dashboard?tab=changerequests">
                            <i class="fa-solid fa-pen-to-square"></i> <span>Thay đổi đặt phòng</span>
                        </a>
                    </li>

                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=checkin">
                            <i class="fa-solid fa-key"></i> <span>Nhận phòng</span>
                        </a>
                    </li>

                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=checkout">
                            <i class="fa-solid fa-right-from-bracket"></i> <span>Trả phòng & Thanh
                                toán</span>
                        </a>
                    </li>

                    <li class="menu-item active">
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=roommap">
                            <i class="fa-solid fa-map"></i> <span>Sơ đồ phòng</span>
                        </a>
                    </li>

                    <li class="menu-item">
                        <a
                            href="${pageContext.request.contextPath}/receptionist/dashboard?tab=walkin-bookings">
                            <i class="fa-solid fa-user-plus"></i> <span>Đặt phòng tại quầy</span>
                        </a>
                    </li>


                    <li class="menu-item">
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

            <%--=================MAIN CONTENT=================--%>
            <div class="dashboard-main">

                <%-- TOPBAR --%>
                <header class="main-topbar">
                    <div class="breadcrumb">
                        <span>Receptionist</span>
                        <span class="separator">&gt;</span>
                        <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=roommap"
                           style="text-decoration:none;color:var(--text-muted)">Sơ đồ phòng</a>
                        <span class="separator">&gt;</span>
                        <span class="current">Phòng ${room.roomNumber}</span>
                    </div>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                        <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                    </a>
                </header>

                <%-- WORKSPACE --%>
                <main class="workspace-content">

                    <div class="content-header-row">
                        <div>
                            <h2>
                                <i class="fa-solid fa-door-open"
                                   style="color:var(--brand-blue);margin-right:8px"></i>
                                Phòng ${room.roomNumber}
                            </h2>
                            <p>
                                Thông tin phòng và lịch sử đặt phòng.
                            </p>
                        </div>
                        <div style="display:flex; gap:12px">
                            <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=roommap"
                               class="btn-modal-cancel"
                               style="display:inline-flex;align-items:center;justify-content:center;text-decoration:none;line-height:40px;height:40px">
                                <i class="fa-solid fa-chevron-left" style="margin-right:6px"></i>
                                Quay lại sơ đồ phòng
                            </a>
                        </div>
                    </div>

                    <!-- Thông tin phòng -->
                    <div class="detail-card">
                        <div class="card-header">
                            <h3><i class="fa-solid fa-bed"></i> Thông tin phòng</h3>
                        </div>
                        <div class="card-body">
                            <div class="room-detail-header">
                                <div class="room-detail-image-col">
                                    <c:if test="${not empty room.imageUrl}">
                                        <img src="${room.imageUrl}" class="room-detail-image" alt="Room Image" />
                                    </c:if>
                                </div>

                                <div class="room-detail-info-col">
                                    <div class="info-row">
                                        <label>Số phòng:</label>
                                        <span class="booking-id-badge">${room.roomNumber}</span>
                                    </div>
                                    <div class="info-row">
                                        <label>Loại phòng:</label>
                                        <span class="roomtype-badge">${room.typeName}</span>
                                    </div>
                                    <div class="info-row" style="border-bottom:none; padding-bottom:0">
                                        <label>Tầng:</label>
                                        <span>${room.floor}</span>
                                    </div>

                                    <span class="badge-status
                                          ${room.displayStatus eq 'Available' ? 'badge-Available' : ''}
                                          ${room.displayStatus eq 'Confirmed' ? 'badge-Confirmed' : ''}
                                          ${room.displayStatus eq 'Occupied' ? 'badge-Occupied' : ''}
                                          ${room.displayStatus eq 'Cleaning' ? 'badge-Cleaning' : ''}
                                          ${room.displayStatus eq 'Refilling' ? 'badge-Refilling' : ''}
                                          ${room.displayStatus eq 'Maintenance' ? 'badge-Maintenance' : ''}"
                                          style="font-size:13px;padding:8px 16px;">
                                        <c:choose>
                                            <c:when test="${room.displayStatus eq 'Available'}">Trống</c:when>
                                            <c:when test="${room.displayStatus eq 'Confirmed'}">Đã đặt</c:when>
                                            <c:when test="${room.displayStatus eq 'Occupied'}">Đang sử dụng</c:when>
                                            <c:when test="${room.displayStatus eq 'Cleaning'}">Đang dọn</c:when>
                                            <c:when test="${room.displayStatus eq 'Refilling'}">Đang bổ sung vật dụng</c:when>
                                            <c:when test="${room.displayStatus eq 'Maintenance'}">Bảo trì</c:when>
                                            <c:when test="${room.displayStatus eq 'OutOfService'}">Ngừng hoạt động</c:when>
                                            <c:otherwise>${room.displayStatus}</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Lịch sử đặt phòng -->
                    <div class="detail-card" style="margin-top:24px">
                        <div class="card-header">
                            <h3><i class="fa-solid fa-clock-rotate-left"></i> Lịch sử đặt phòng</h3>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${empty bookings}">
                                    <div class="empty-history">
                                        Phòng này chưa từng được đặt.
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="table-card" style="box-shadow:none;border:1px solid #e2e8f0;">
                                        <table class="booking-table">
                                            <thead>
                                                <tr>
                                                    <th>Mã</th>
                                                    <th>Khách hàng</th>
                                                    <th>Loại phòng</th>
                                                    <th>Ngày nhận / trả</th>
                                                    <th>Tổng tiền</th>
                                                    <th>Trạng thái</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="b" items="${bookings}">
                                                    <tr>
                                                        <td>
                                                            <span class="booking-id-badge">#${b.bookingId}</span>
                                                        </td>

                                                        <td>
                                                            <div class="customer-cell">
                                                                <div class="name">
                                                                    <c:out value="${b.customerName}" />
                                                                </div>
                                                                <div class="meta">
                                                                    Đặt: ${b.createdAt}
                                                                </div>
                                                            </div>
                                                        </td>

                                                        <td>
                                                            <span class="roomtype-badge">${b.roomTypeName}</span>
                                                        </td>

                                                        <td>
                                                            <div class="date-range">
                                                                ${b.checkInDate} &rarr; ${b.checkOutDate}
                                                            </div>
                                                        </td>

                                                        <td>
                                                            <fmt:formatNumber value="${b.totalAmount}" type="number" groupingUsed="true" />đ
                                                        </td>

                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${b.status eq 'Pending'}">
                                                                    <span class="status-pill pill-pending">
                                                                        <i class="fa-solid fa-circle"></i> Chờ xử lý
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${b.status eq 'Confirmed'}">
                                                                    <span class="status-pill pill-confirmed">
                                                                        <i class="fa-solid fa-circle"></i> Đã xác nhận
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${b.status eq 'Rejected'}">
                                                                    <span class="status-pill pill-rejected">
                                                                        <i class="fa-solid fa-circle"></i> Từ chối
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${b.status eq 'Cancelled'}">
                                                                    <span class="status-pill pill-cancelled">
                                                                        <i class="fa-solid fa-circle"></i> Đã huỷ
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${b.status eq 'CheckedIn'}">
                                                                    <span class="status-pill pill-checkedin">
                                                                        <i class="fa-solid fa-circle"></i> Đã nhận phòng
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${b.status eq 'CheckedOut'}">
                                                                    <span class="status-pill pill-checkedout">
                                                                        <i class="fa-solid fa-circle"></i> Đã trả phòng
                                                                    </span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="status-pill pill-cancelled">${b.status}</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </main>
                <footer class="dashboard-footer">
                    <span>HotelOps Pro &copy; 2026</span>
                    <span>Đăng nhập: <strong>${sessionScope.user}</strong></span>
                </footer>
            </div>
        </div>

    </body>
</html>
