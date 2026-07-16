<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ include file="../../includes/taglibs.jsp" %>
        <%@ include file="../../includes/header.jsp" %>

            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer_booking.css?v=21" />
            <fmt:setLocale value="vi_VN" />

            <style>
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
                    transition: all 0.2s;
                }

                .sidebar-menu a:hover {
                    background-color: #f1f5f9 !important;
                    color: var(--brand-blue) !important;
                }

                .sidebar-menu a.active-sidebar-item {
                    color: var(--brand-blue) !important;
                    background-color: var(--brand-blue-light) !important;
                    font-weight: 700;
                }

                .sidebar-menu a.active-sidebar-item:hover {
                    background-color: var(--brand-blue-light) !important;
                    color: var(--brand-blue) !important;
                }

                .badge {
                    white-space: nowrap !important;
                }

                .filter-btn {
                    padding: 8px 18px;
                    border-radius: 20px;
                    font-size: 13.5px;
                    font-weight: 600;
                    color: var(--text-muted);
                    background-color: #ffffff;
                    border: 1px solid var(--border-color);
                    text-decoration: none;
                    transition: all 0.2s;
                    cursor: pointer;
                    display: inline-block;
                }

                .filter-btn:hover {
                    background-color: var(--bg-light);
                    color: var(--brand-blue);
                    border-color: #cbd5e1;
                }

                .filter-btn.active {
                    background-color: var(--brand-blue-light);
                    color: var(--brand-blue);
                    border-color: var(--brand-blue);
                }
            </style>

            <body>

                <%-- Header Navigation --%>
                    <nav class="navbar-rooms">
                        <div class="logo">HotelOps</div>
                        <ul class="nav-links">
                            <li><a href="${pageContext.request.contextPath}/">Trang chủ</a></li>
                            <li><a href="${pageContext.request.contextPath}/customer/services" class="active">Dịch vụ</a></li>
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
                                        Dịch vụ</h3>
                                    <ul
                                        style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 8px;">
                                        <li>
                                            <a href="${pageContext.request.contextPath}/customer/services">
                                                <i class="fa-solid fa-bell-concierge"
                                                    style="width: 20px; text-align: center;"></i> Yêu cầu dịch vụ
                                            </a>
                                        </li>
                                        <li>
                                            <a href="${pageContext.request.contextPath}/customer/services/history"
                                                class="active-sidebar-item">
                                                <i class="fa-solid fa-clock-rotate-left"
                                                    style="width: 20px; text-align: center;"></i> Lịch sử yêu cầu
                                            </a>
                                        </li>
                                    </ul>
                                </div>

                                <!-- Right Content Area -->
                                <div style="flex-grow: 1; display: flex; flex-direction: column; gap: 30px;">

                                    <!-- Lịch sử yêu cầu -->
                                    <div class="booking-card" style="padding: 0; overflow: auto; margin-bottom: 0;">
                                        <div style="padding: 30px 30px 20px 30px;">
                                            <h2
                                                style="font-size: 20px; font-weight: 800; color: var(--text-navy); margin: 0;">
                                                Lịch sử yêu cầu dịch vụ
                                            </h2>
                                            <p style="color: var(--text-muted); margin: 6px 0 0 0; font-size: 14.5px;">
                                                Xem danh sách và trạng thái các yêu cầu dịch vụ phòng của bạn</p>
                                            <div style="display: flex; gap: 8px; margin-top: 15px; flex-wrap: wrap;">
                                                <a href="${pageContext.request.contextPath}/customer/services/history?status=All" 
                                                   class="filter-btn ${selectedStatus eq 'All' || empty selectedStatus ? 'active' : ''}">Tất cả</a>
                                                <a href="${pageContext.request.contextPath}/customer/services/history?status=Pending" 
                                                   class="filter-btn ${selectedStatus eq 'Pending' ? 'active' : ''}">Chờ xử lý</a>
                                                <a href="${pageContext.request.contextPath}/customer/services/history?status=Completed" 
                                                   class="filter-btn ${selectedStatus eq 'Completed' ? 'active' : ''}">Đã duyệt</a>
                                                <a href="${pageContext.request.contextPath}/customer/services/history?status=Cancelled" 
                                                   class="filter-btn ${selectedStatus eq 'Cancelled' ? 'active' : ''}">Đã hủy</a>
                                            </div>
                                        </div>

                                        <table class="booking-list-table">
                                            <thead>
                                                <tr>
                                                    <th>Mã yêu cầu</th>
                                                    <th>Ngày yêu cầu</th>
                                                    <th>Đặt phòng</th>
                                                    <th>Phòng</th>
                                                    <th>Dịch vụ</th>
                                                    <th>Số lượng</th>
                                                    <th>Tạm tính</th>
                                                    <th>Ghi chú</th>
                                                    <th>Trạng thái</th>
                                                    <th>Hành động</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:choose>
                                                    <c:when test="${not empty requests}">
                                                        <c:forEach var="r" items="${requests}">
                                                            <tr>
                                                                <td style="font-weight: 700;">#${r.requestId}</td>
                                                                <td>
                                                                    <fmt:formatDate value="${r.createdAt}"
                                                                        pattern="dd/MM/yyyy HH:mm" />
                                                                </td>
                                                                <td
                                                                    style="font-weight: 600; color: var(--primary-indigo);">
                                                                    #${r.bookingId}
                                                                </td>
                                                                <td style="font-weight: 600;">
                                                                    <c:choose>
                                                                        <c:when test="${not empty r.roomNumber}">
                                                                            Phòng ${r.roomNumber}
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span
                                                                                style="color: var(--text-muted); font-style: italic; font-weight: 500;">Chưa
                                                                                nhận phòng</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td style="font-weight: 700; color: var(--brand-blue);">
                                                                    ${r.title}
                                                                </td>
                                                                <td style="font-weight: 600;">
                                                                    ${r.quantity} <c:if test="${not empty r.unit}">/ ${r.unit}</c:if>
                                                                </td>
                                                                <td style="font-weight: 700; color: var(--brand-blue);">
                                                                    <fmt:formatNumber value="${r.estimatedAmount}" type="currency" currencySymbol="" /> VND
                                                                </td>
                                                                <td style="max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"
                                                                    title="${r.description}">
                                                                    <c:choose>
                                                                        <c:when test="${not empty r.description}">
                                                                            <c:out value="${r.description}" />
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span style="color: var(--text-muted);">—</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${r.status eq 'Pending'}">
                                                                            <span class="badge badge-pending">Chờ xử lý</span>
                                                                        </c:when>
                                                                        <c:when test="${r.status eq 'InProgress'}">
                                                                            <span class="badge badge-checkedin">Đang thực hiện</span>
                                                                        </c:when>
                                                                        <c:when test="${r.status eq 'Completed'}">
                                                                            <span class="badge badge-confirmed">Đã duyệt</span>
                                                                        </c:when>
                                                                        <c:when test="${r.status eq 'Cancelled'}">
                                                                            <span class="badge badge-cancelled">Đã hủy</span>
                                                                        </c:when>
                                                                    </c:choose>
                                                                </td>
                                                                <td>
                                                                     <div style="display: flex; gap: 8px; align-items: center;">
                                                                         <c:if test="${r.status eq 'Pending'}">
                                                                             <button type="button" class="btn-danger"
                                                                                 style="padding: 6px 12px; font-size: 13px;"
                                                                                 onclick="confirmCancelRequest('${r.requestId}')">
                                                                                 Hủy
                                                                             </button>
                                                                         </c:if>
                                                                         <c:if test="${r.status eq 'Completed' || r.status eq 'Cancelled'}">
                                                                             <button type="button" class="btn-secondary"
                                                                                 style="padding: 5px 12px; font-size: 13px; background-color: #ffffff; color: var(--brand-blue); border: 1px solid var(--brand-blue); border-radius: 6px; cursor: pointer; font-weight: 600; transition: all 0.2s;"
                                                                                 data-id="${r.requestId}"
                                                                                 data-status="${r.status}"
                                                                                 data-date="<fmt:formatDate value="${not empty r.completedAt ? r.completedAt : r.updatedAt}" pattern="dd/MM/yyyy HH:mm" />"
                                                                                 data-reason="<c:out value="${r.cancelReason}" />"
                                                                                 onclick="openDetailModal(this)">
                                                                                 Chi tiết
                                                                             </button>
                                                                         </c:if>
                                                                     </div>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <tr>
                                                            <td colspan="10"
                                                                style="text-align: center; padding: 40px; color: var(--text-muted);">
                                                                <i class="fa-solid fa-bell-slash"
                                                                    style="font-size: 40px; margin-bottom: 15px; display: block; color: #cbd5e1;"></i>
                                                                Bạn chưa gửi yêu cầu dịch vụ nào.
                                                            </td>
                                                        </tr>
                                                    </c:otherwise>
                                                </c:choose>
                                            </tbody>
                                        </table>
                                    </div>

                                </div>
                            </div>
                    </div>

                    <%-- Cancel Request Confirmation Form --%>
                        <form action="${pageContext.request.contextPath}/customer/services/cancel" method="POST"
                            id="cancelRequestForm" style="display: none;">
                            <input type="hidden" name="requestId" id="cancelRequestId" value="" />
                        </form>

                        <%-- Footer --%>
                            <footer class="footer-white" id="lien-he" style="margin-top: 80px;">
                                <div class="footer-white-grid">
                                    <div class="footer-white-about">
                                        <h3>HotelOps Pro</h3>
                                        <p>Hệ thống quản lý và nghỉ dưỡng đẳng cấp quốc tế, đem lại trải nghiệm sang
                                            trọng vượt thời gian.</p>
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
                                        <span class="phone-number-white"><i class="fa-solid fa-phone"></i> 1900
                                            6789</span>
                                    </div>
                                </div>
                                <div class="footer-white-bottom text-center">
                                    <p>&copy; 2026 HotelOps Pro. All rights reserved.</p>
                                </div>
                            </footer>

                            <script>
                                window.addEventListener('DOMContentLoaded', () => {
                                    const serverError = document.getElementById('serverValidationError');
                                    if (serverError) {
                                        setTimeout(() => {
                                            serverError.style.display = 'none';
                                        }, 5000);
                                    }
                                    const serverSuccess = document.getElementById('serverSuccessMessage');
                                    if (serverSuccess) {
                                        setTimeout(() => {
                                            serverSuccess.style.display = 'none';
                                        }, 5000);
                                    }
                                });

                                function confirmCancelRequest(requestId) {
                                    if (confirm("Bạn có chắc chắn muốn hủy yêu cầu dịch vụ #" + requestId + " không?")) {
                                        document.getElementById('cancelRequestId').value = requestId;
                                        document.getElementById('cancelRequestForm').submit();
                                    }
                                }

                                function openDetailModal(button) {
                                    var id = button.getAttribute("data-id");
                                    var status = button.getAttribute("data-status");
                                    var date = button.getAttribute("data-date");
                                    var reason = button.getAttribute("data-reason");

                                    document.getElementById("modalTitle").innerText = "Chi tiết yêu cầu #" + id;

                                    var statusEl = document.getElementById("modalStatus");
                                    var dateLabelEl = document.getElementById("modalDateLabel");
                                    var reasonContainer = document.getElementById("modalReasonContainer");

                                    if (status === "Completed") {
                                        statusEl.innerText = "Đã duyệt";
                                        statusEl.style.color = "#10b981";
                                        dateLabelEl.innerText = "Ngày duyệt yêu cầu";
                                        reasonContainer.style.display = "none";
                                    } else if (status === "Cancelled") {
                                        statusEl.innerText = "Đã hủy";
                                        statusEl.style.color = "#ef4444";
                                        dateLabelEl.innerText = "Ngày hủy yêu cầu";
                                        reasonContainer.style.display = "flex";

                                        var reasonText = reason ? reason.trim() : "";
                                        if (!reasonText) {
                                            reasonText = "Không mô tả lý do";
                                            document.getElementById("modalReason").style.color = "#64748b";
                                            document.getElementById("modalReason").style.backgroundColor = "#f8fafc";
                                            document.getElementById("modalReason").style.borderColor = "#e2e8f0";
                                        } else {
                                            document.getElementById("modalReason").style.color = "#ef4444";
                                            document.getElementById("modalReason").style.backgroundColor = "#fef2f2";
                                            document.getElementById("modalReason").style.borderColor = "#fee2e2";
                                        }
                                        document.getElementById("modalReason").innerText = reasonText;
                                    } else {
                                        statusEl.innerText = status;
                                        statusEl.style.color = "#64748b";
                                        dateLabelEl.innerText = "Ngày xử lý";
                                        reasonContainer.style.display = "none";
                                    }

                                    document.getElementById("modalDate").innerText = date ? date : "—";

                                    var modal = document.getElementById("detailModal");
                                    modal.style.display = "flex";
                                }

                                function closeDetailModal() {
                                    document.getElementById("detailModal").style.display = "none";
                                }

                                window.addEventListener("click", function(event) {
                                    var modal = document.getElementById("detailModal");
                                    if (event.target === modal) {
                                        closeDetailModal();
                                    }
                                });
                            </script>

                            <div id="detailModal" style="display: none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(15, 23, 42, 0.6); backdrop-filter: blur(4px); align-items: center; justify-content: center;">
                                <div style="background-color: #ffffff; border-radius: 16px; width: 90%; max-width: 450px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04); border: 1px solid #e2e8f0; overflow: hidden; animation: modalFadeIn 0.25s ease-out; margin: auto;">
                                    <div style="padding: 20px 24px; border-bottom: 1px solid #f1f5f9; display: flex; justify-content: space-between; align-items: center; background-color: #f8fafc;">
                                        <h3 style="margin: 0; font-size: 16.5px; font-weight: 700; color: #0b132b;" id="modalTitle">Chi tiết yêu cầu dịch vụ</h3>
                                        <button onclick="closeDetailModal()" style="background: none; border: none; font-size: 24px; color: #94a3b8; cursor: pointer; line-height: 1; padding: 0;">&times;</button>
                                    </div>
                                    <div style="padding: 24px; display: flex; flex-direction: column; gap: 16px;">
                                        <div style="display: flex; flex-direction: column; gap: 6px;">
                                            <span style="font-size: 11px; font-weight: 700; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.5px;">Trạng thái</span>
                                            <span id="modalStatus" style="font-size: 14.5px; font-weight: 700;"></span>
                                        </div>
                                        <div style="display: flex; flex-direction: column; gap: 6px;">
                                            <span style="font-size: 11px; font-weight: 700; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.5px;" id="modalDateLabel">Ngày xử lý</span>
                                            <span id="modalDate" style="font-size: 14.5px; color: #1c2541; font-weight: 600;"></span>
                                        </div>
                                        <div id="modalReasonContainer" style="display: flex; flex-direction: column; gap: 6px;">
                                            <span style="font-size: 11px; font-weight: 700; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.5px;">Lý do từ chối/hủy</span>
                                            <div id="modalReason" style="font-size: 14.5px; color: #ef4444; background-color: #fef2f2; border: 1px solid #fee2e2; padding: 12px; border-radius: 8px; font-weight: 500; line-height: 1.5; text-align: justify; word-break: break-word;"></div>
                                        </div>
                                    </div>
                                    <div style="padding: 16px 24px; border-top: 1px solid #f1f5f9; display: flex; justify-content: flex-end; background-color: #f8fafc;">
                                        <button onclick="closeDetailModal()" style="padding: 10px 20px; background-color: var(--brand-blue); color: white; border: none; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; transition: background-color 0.2s;">Đóng</button>
                                    </div>
                                </div>
                            </div>

                            <style>
                                @keyframes modalFadeIn {
                                    from { opacity: 0; transform: scale(0.95); }
                                    to { opacity: 1; transform: scale(1); }
                                }
                            </style>
            </body>

            </html>