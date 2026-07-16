<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Xử lý thay đổi đặt phòng - HotelOps Pro</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/receptionist.css?v=5" />
        <style>
            /* Pills phân loại yêu cầu (UC 2.4.5 Process Booking Change) */
            .bcr-type-pill {
                display: inline-block;
                padding: 4px 12px;
                border-radius: 999px;
                font-size: 12px;
                font-weight: 600;
                white-space: nowrap;
            }
            .bcr-type-pill.change {
                background: #e0edff;
                color: #0056b3;
            }
            .bcr-type-pill.extension {
                background: #fef3c7;
                color: #92400e;
            }
            .bcr-detail {
                font-size: 13px;
                line-height: 1.5;
            }
            .bcr-detail .old {
                color: var(--text-muted);
                text-decoration: line-through;
            }
            .bcr-detail .new {
                font-weight: 600;
                color: var(--text-navy);
            }
        </style>
    </head>
    <fmt:setLocale value="vi_VN" />
    <c:set var="currentTab" value="changerequests" />

    <body class="dashboard-body">

        <div class="dashboard-layout">

            <%-- ================= SIDEBAR ================= --%>
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

            <%-- ================= MAIN CONTENT ================= --%>
            <div class="dashboard-main">

                <%-- TOPBAR --%>
                <header class="main-topbar">
                    <div class="breadcrumb">
                        <span>Receptionist</span>
                        <span class="separator">&gt;</span>
                        <span class="current">Xử lý thay đổi đặt phòng</span>
                    </div>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                        <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                    </a>
                </header>

                <%-- WORKSPACE --%>
                <main class="workspace-content">

                    <%-- Toast notification --%>
                    <c:if test="${param.result eq 'success'}">
                        <div class="toast-notify toast-success">
                            <i class="fa-solid fa-circle-check"></i>
                            <c:choose>
                                <c:when test="${param.action eq 'approve'}">Đã duyệt yêu cầu và cập nhật đơn đặt phòng thành công!</c:when>
                                <c:when test="${param.action eq 'reject'}">Đã từ chối yêu cầu thành công!</c:when>
                                <c:otherwise>Thao tác thành công!</c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>
                    <c:if test="${not empty param.error}">
                        <div class="toast-notify toast-error">
                            <i class="fa-solid fa-circle-xmark"></i>
                            <c:choose>
                                <c:when test="${param.error eq 'invalid'}">Mã yêu cầu hoặc hành động không hợp lệ.</c:when>
                                <c:when test="${param.error eq 'notfound'}">Không tìm thấy yêu cầu hoặc đơn đặt phòng.</c:when>
                                <c:when test="${param.error eq 'not_pending'}">Yêu cầu này đã được xử lý trước đó.</c:when>
                                <c:when test="${param.error eq 'not_eligible'}">Đơn đặt phòng không còn đủ điều kiện để áp dụng yêu cầu này.</c:when>
                                <c:when test="${param.error eq 'no_room'}">Không còn phòng trống phù hợp cho lựa chọn / khoảng ngày mới.</c:when>
                                <c:otherwise>Đã xảy ra lỗi. Vui lòng thử lại sau.</c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>

                    <%-- Header Title --%>
                    <div class="content-header-row">
                        <div>
                            <h2><i class="fa-solid fa-pen-to-square" style="color:var(--brand-blue);margin-right:8px"></i>Xử lý thay đổi đặt phòng</h2>
                            <p>Duyệt hoặc từ chối các yêu cầu thay đổi đặt phòng và gia hạn lưu trú của khách hàng.</p>
                        </div>
                    </div>

                    <%-- KPI Stats Cards --%>
                    <div class="stats-cards-container">
                        <div class="stats-card">
                            <div class="card-icon-wrapper card-icon-total">
                                <i class="fa-solid fa-list-check"></i>
                            </div>
                            <div class="card-info">
                                <span class="card-label">TỔNG YÊU CẦU</span>
                                <span class="card-value">${kpiTotal}</span>
                            </div>
                        </div>

                        <div class="stats-card stats-card-pending">
                            <div class="card-icon-wrapper card-icon-pending">
                                <i class="fa-solid fa-clipboard-list"></i>
                            </div>
                            <div class="card-info">
                                <span class="card-label">CHỜ DUYỆT</span>
                                <span class="card-value"><fmt:formatNumber value="${kpiPending}" pattern="00" /></span>
                            </div>
                        </div>

                        <div class="stats-card stats-card-completed">
                            <div class="card-icon-wrapper card-icon-completed">
                                <i class="fa-solid fa-circle-check"></i>
                            </div>
                            <div class="card-info">
                                <span class="card-label">ĐÃ DUYỆT</span>
                                <span class="card-value"><fmt:formatNumber value="${kpiApproved}" pattern="00" /></span>
                            </div>
                        </div>

                        <div class="stats-card stats-card-cancelled">
                            <div class="card-icon-wrapper card-icon-cancelled">
                                <i class="fa-solid fa-circle-xmark"></i>
                            </div>
                            <div class="card-info">
                                <span class="card-label">ĐÃ TỪ CHỐI</span>
                                <span class="card-value"><fmt:formatNumber value="${kpiRejected}" pattern="00" /></span>
                            </div>
                        </div>
                    </div>

                    <%-- Search & Filters --%>
                    <div class="req-filter-bar">
                        <form method="get" action="${pageContext.request.contextPath}/receptionist/dashboard" class="req-search-form">
                            <input type="hidden" name="tab" value="changerequests" />
                            <input type="hidden" name="status" value="${currentStatus}" />
                            <div class="search-wrapper" style="max-width: 100%;">
                                <i class="fa-solid fa-magnifying-glass"></i>
                                <input type="text" name="keyword" class="search-input"
                                       placeholder="Tìm theo tên khách hoặc mã đơn đặt phòng..."
                                       value="${keyword}" />
                            </div>
                        </form>

                        <div class="req-tabs">
                            <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=changerequests&status=All&keyword=${keyword}"
                               class="req-tab ${currentStatus eq 'All' || empty currentStatus ? 'active' : ''}">Tất cả</a>
                            <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=changerequests&status=Pending&keyword=${keyword}"
                               class="req-tab ${currentStatus eq 'Pending' ? 'active' : ''}">Chờ duyệt</a>
                            <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=changerequests&status=Approved&keyword=${keyword}"
                               class="req-tab ${currentStatus eq 'Approved' ? 'active' : ''}">Đã duyệt</a>
                            <a href="${pageContext.request.contextPath}/receptionist/dashboard?tab=changerequests&status=Rejected&keyword=${keyword}"
                               class="req-tab ${currentStatus eq 'Rejected' ? 'active' : ''}">Đã từ chối</a>
                        </div>
                    </div>

                    <%-- Table --%>
                    <div class="table-card">
                        <c:choose>
                            <c:when test="${empty requestList}">
                                <div class="empty-state">
                                    <i class="fa-solid fa-inbox"></i>
                                    <p>Không có yêu cầu thay đổi đặt phòng nào.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <table class="booking-table">
                                    <thead>
                                        <tr>
                                            <th>Mã YC</th>
                                            <th>Mã đơn</th>
                                            <th>Khách hàng</th>
                                            <th>Loại yêu cầu</th>
                                            <th>Chi tiết yêu cầu</th>
                                            <th>Phụ phí dự kiến</th>
                                            <th>Lý do</th>
                                            <th>Ngày gửi</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="r" items="${requestList}">
                                            <tr>
                                                <td><span class="req-id-link">#${r.requestId}</span></td>

                                                <td style="font-weight: 700;">#${r.bookingId}</td>

                                                <td>
                                                    <div class="customer-cell">
                                                        <div class="name"><c:out value="${r.customerName}" /></div>
                                                    </div>
                                                </td>

                                                <%-- Loại yêu cầu --%>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${r.extension}">
                                                            <span class="bcr-type-pill extension">Gia hạn lưu trú</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="bcr-type-pill change">Thay đổi đặt phòng</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>

                                                <%-- Chi tiết yêu cầu --%>
                                                <td>
                                                    <div class="bcr-detail">
                                                        <c:choose>
                                                            <c:when test="${r.extension}">
                                                                Trả phòng:
                                                                <span class="old"><fmt:formatDate value="${r.oldCheckOut}" pattern="dd/MM/yyyy" /></span>
                                                                &rarr;
                                                                <span class="new"><fmt:formatDate value="${r.newCheckOut}" pattern="dd/MM/yyyy" /></span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="old"><fmt:formatDate value="${r.oldCheckIn}" pattern="dd/MM" /> - <fmt:formatDate value="${r.oldCheckOut}" pattern="dd/MM/yyyy" /></span>
                                                                &rarr;
                                                                <span class="new"><fmt:formatDate value="${r.newCheckIn}" pattern="dd/MM" /> - <fmt:formatDate value="${r.newCheckOut}" pattern="dd/MM/yyyy" /></span>
                                                                <br/>
                                                                <span class="new"><c:out value="${r.newRoomTypeName}" /> · ${r.newRoomQuantity} phòng</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </td>

                                                <%-- Phụ phí dự kiến --%>
                                                <td style="font-weight: 700; color: var(--brand-blue);">
                                                    <c:choose>
                                                        <c:when test="${r.additionalCharge != null && r.additionalCharge > 0}">
                                                            <fmt:formatNumber value="${r.additionalCharge}" type="number" /> VND
                                                        </c:when>
                                                        <c:otherwise><span style="color: var(--text-muted);">—</span></c:otherwise>
                                                    </c:choose>
                                                </td>

                                                <%-- Lý do --%>
                                                <td style="max-width: 160px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${fn:escapeXml(r.reason)}">
                                                    <c:choose>
                                                        <c:when test="${not empty r.reason}"><c:out value="${r.reason}" /></c:when>
                                                        <c:otherwise><span style="color: var(--text-muted); font-style: italic;">—</span></c:otherwise>
                                                    </c:choose>
                                                </td>

                                                <%-- Ngày gửi --%>
                                                <td>
                                                    <div class="time-cell">
                                                        <span class="time"><fmt:formatDate value="${r.createdAt}" pattern="HH:mm" /></span>
                                                        <span class="date"><fmt:formatDate value="${r.createdAt}" pattern="dd/MM/yyyy" /></span>
                                                    </div>
                                                </td>

                                                <%-- Trạng thái --%>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${r.status eq 'Pending'}">
                                                            <span class="status-pill pill-pending">
                                                                <i class="fa-solid fa-circle"></i> Chờ duyệt
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${r.status eq 'Approved'}">
                                                            <span class="status-pill pill-confirmed">
                                                                <i class="fa-solid fa-circle"></i> Đã duyệt
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${r.status eq 'Rejected'}">
                                                            <span class="status-pill pill-rejected">
                                                                <i class="fa-solid fa-circle"></i> Đã từ chối
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="status-pill pill-cancelled"><c:out value="${r.status}" /></span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>

                                                <%-- Thao tác --%>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${r.status eq 'Pending'}">
                                                            <div class="actions-cell">
                                                                <button type="button" class="btn-req-action btn-req-approve" title="Duyệt và áp dụng vào đơn"
                                                                        onclick="openApproveChangeModal('${r.requestId}', '${r.bookingId}', '${fn:escapeXml(r.customerName)}', ${r.extension})">
                                                                    <i class="fa-solid fa-check"></i>
                                                                </button>
                                                                <button type="button" class="btn-req-action btn-req-cancel" title="Từ chối yêu cầu"
                                                                        onclick="openRejectChangeModal('${r.requestId}', '${r.bookingId}', '${fn:escapeXml(r.customerName)}', ${r.extension})">
                                                                    <i class="fa-solid fa-xmark"></i>
                                                                </button>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="color:var(--text-muted)">—</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:otherwise>
                        </c:choose>
                    </div><%-- end table-card --%>

                    <%-- Pagination --%>
                    <c:if test="${totalPages > 1}">
                        <div class="pagination-container">
                            <div class="pagination-info">
                                Hiển thị ${(currentPage-1)*pageSize + 1}-${currentPage*pageSize gt totalItems ? totalItems : currentPage*pageSize} trong số ${totalItems} yêu cầu
                            </div>
                            <div class="pagination-buttons">
                                <a class="btn-page ${currentPage == 1 ? 'disabled' : ''}"
                                   href="?tab=changerequests&status=${currentStatus}&keyword=${keyword}&page=${currentPage-1}">
                                    <i class="fa-solid fa-chevron-left"></i>
                                </a>

                                <c:forEach var="p" begin="1" end="${totalPages}">
                                    <a class="btn-page ${p == currentPage ? 'active-page' : ''}"
                                       href="?tab=changerequests&status=${currentStatus}&keyword=${keyword}&page=${p}">
                                        ${p}
                                    </a>
                                </c:forEach>

                                <a class="btn-page ${currentPage == totalPages ? 'disabled' : ''}"
                                   href="?tab=changerequests&status=${currentStatus}&keyword=${keyword}&page=${currentPage+1}">
                                    <i class="fa-solid fa-chevron-right"></i>
                                </a>
                            </div>
                        </div>
                    </c:if>

                </main>

                <footer class="dashboard-footer">
                    <span>HotelOps Pro &copy; 2026</span>
                    <span>Đăng nhập: <strong>${sessionScope.user}</strong></span>
                </footer>
            </div><%-- end dashboard-main --%>
        </div><%-- end dashboard-layout --%>

        <%-- MODAL DIALOGS --%>
        <!-- Approve Modal -->
        <div class="modal-overlay" id="approveChangeModal">
            <div class="modal-container" style="max-width: 480px;">
                <div class="modal-header">
                    <h3>Xác nhận duyệt yêu cầu</h3>
                    <button class="btn-close-modal" onclick="closeModal('approveChangeModal')"><i class="fa-solid fa-xmark"></i></button>
                </div>
                <div class="modal-body">
                    <form id="approveChangeForm" action="${pageContext.request.contextPath}/receptionist/bookingchange" method="post">
                        <input type="hidden" name="requestId" id="approveChangeRequestId" value="" />
                        <input type="hidden" name="action" value="approve" />

                        <div style="margin-bottom: 20px; text-align: center; color: var(--text-navy);">
                            <i class="fa-solid fa-circle-question" style="font-size: 48px; color: var(--brand-blue); margin-bottom: 16px;"></i>
                            <p style="font-size: 15px; font-weight: 600; line-height: 1.5; margin: 0 0 8px 0;">
                                Duyệt yêu cầu này và áp dụng thay đổi vào đơn đặt phòng?
                            </p>
                            <p style="font-size: 13px; color: var(--text-muted); margin: 0;" id="approveChangeDetail">
                                Yêu cầu #...
                            </p>
                        </div>

                        <div class="modal-footer-row">
                            <button type="button" class="btn-modal-cancel" onclick="closeModal('approveChangeModal')">Hủy bỏ</button>
                            <button type="submit" class="btn-modal-save">Duyệt yêu cầu</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Reject Modal -->
        <div class="modal-overlay" id="rejectChangeModal">
            <div class="modal-container" style="max-width: 480px;">
                <div class="modal-header">
                    <h3>Xác nhận từ chối yêu cầu</h3>
                    <button class="btn-close-modal" onclick="closeModal('rejectChangeModal')"><i class="fa-solid fa-xmark"></i></button>
                </div>
                <div class="modal-body">
                    <form id="rejectChangeForm" action="${pageContext.request.contextPath}/receptionist/bookingchange" method="post">
                        <input type="hidden" name="requestId" id="rejectChangeRequestId" value="" />
                        <input type="hidden" name="action" value="reject" />

                        <div style="margin-bottom: 20px; text-align: center; color: var(--text-navy);">
                            <i class="fa-solid fa-circle-exclamation" style="font-size: 48px; color: #ef4444; margin-bottom: 16px;"></i>
                            <p style="font-size: 15px; font-weight: 600; line-height: 1.5; margin: 0 0 8px 0;">
                                Từ chối yêu cầu này? Đơn đặt phòng sẽ giữ nguyên như cũ.
                            </p>
                            <p style="font-size: 13px; color: var(--text-muted); margin: 0;" id="rejectChangeDetail">
                                Yêu cầu #...
                            </p>
                        </div>

                        <div class="modal-footer-row">
                            <button type="button" class="btn-modal-cancel" onclick="closeModal('rejectChangeModal')">Hủy bỏ</button>
                            <button type="submit" class="btn-modal-reject">Từ chối yêu cầu</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="${pageContext.request.contextPath}/assets/js/receptionist.js?v=5" charset="UTF-8"></script>
        <script>
                                function describeChangeRequest(requestId, bookingId, customerName, isExtension) {
                                    var type = isExtension ? "Gia hạn lưu trú" : "Thay đổi đặt phòng";
                                    return "Yêu cầu #" + requestId + " (" + type + " - Đơn #" + bookingId + " - Khách: " + customerName + ")";
                                }

                                function openApproveChangeModal(requestId, bookingId, customerName, isExtension) {
                                    document.getElementById('approveChangeRequestId').value = requestId;
                                    document.getElementById('approveChangeDetail').innerText = describeChangeRequest(requestId, bookingId, customerName, isExtension);
                                    openModal('approveChangeModal');
                                }

                                function openRejectChangeModal(requestId, bookingId, customerName, isExtension) {
                                    document.getElementById('rejectChangeRequestId').value = requestId;
                                    document.getElementById('rejectChangeDetail').innerText = describeChangeRequest(requestId, bookingId, customerName, isExtension);
                                    openModal('rejectChangeModal');
                                }
        </script>
    </body>
</html>
