<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
    Giao diện Dashboard quản trị hệ thống Admin.
    @author TùngNQ
--%>
    <%@ include file="../../includes/taglibs.jsp" %>
        <%@ include file="../../includes/header.jsp" %>

            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=3" />
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=5" />
            <fmt:setLocale value="vi_VN" />

            <body class="dashboard-body">

                <!-- Tab Resolution -->
                <c:set var="currentTab"
                    value="${requestScope.currentTab != null ? requestScope.currentTab : 'staff'}" />

                <div class="dashboard-layout">

                    <!-- SIDEBAR -->
                    <c:set var="activePage" value="${currentTab}" scope="request" />
                    <jsp:include page="../admin/includes/sidebar.jsp" />

                    <!-- MAIN DASHBOARD CONTENT -->
                    <div class="dashboard-main">

                        <!-- TOP HEADER BAR -->
                        <header class="main-topbar">
                            <div class="breadcrumb">
                                <span>Quản trị viên</span>
                                <span class="separator">&gt;</span>
                                <span class="current">
                                    <c:choose>
                                        <c:when test="${currentTab eq 'staff'}">Nhân viên hệ thống</c:when>
                                        <c:when test="${currentTab eq 'customers'}">Khách hàng</c:when>
                                        <c:otherwise>Nhân viên hệ thống</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>

                            <div class="topbar-actions" style="display: flex; align-items: center; gap: 12px;">
                                <a href="${pageContext.request.contextPath}/logout" class="btn-logout"
                                    style="margin-left: 0;">
                                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                                </a>
                            </div>
                        </header>

                        <!-- DYNAMIC TAB WORKSPACE -->
                        <main class="workspace-content">

                            <!-- Feedback Toast Messages -->
                            <c:if test="${not empty param.success}">
                                <div class="alert-toast success-toast">
                                    <i class="fa-solid fa-circle-check"></i>
                                    <span>
                                        <c:choose>
                                            <c:when test="${param.success eq 'created'}">Đã thêm tài khoản nhân viên
                                                thành công!</c:when>
                                            <c:when test="${param.success eq 'updated'}">Đã cập nhật thông tin nhân viên
                                                thành công!</c:when>
                                            <c:when test="${param.success eq 'status_changed'}">Đã thay đổi trạng thái
                                                tài khoản thành công!</c:when>
                                            <c:otherwise>Thực hiện thao tác thành công.</c:otherwise>
                                        </c:choose>
                                    </span>
                                    <button class="toast-close-btn"
                                        onclick="this.parentElement.remove()">&times;</button>
                                </div>
                            </c:if>
                            <c:if test="${not empty param.error}">
                                <div class="alert-toast error-toast">
                                    <i class="fa-solid fa-circle-exclamation"></i>
                                    <span>
                                        <c:choose>
                                            <c:when test="${param.error eq 'email_exists'}">Lỗi: Email này đã được sử
                                                dụng trong hệ thống!</c:when>
                                            <c:when test="${param.error eq 'phone_exists'}">Lỗi: Số điện thoại này đã được sử
                                                dụng trong hệ thống!</c:when>
                                            <c:when test="${param.error eq 'invalid_email'}">Lỗi: Định dạng email không hợp lệ!</c:when>
                                            <c:when test="${param.error eq 'invalid_phone'}">Lỗi: Số điện thoại phải bắt đầu bằng 0, theo sau là đầu số 3, 5, 7, 8, 9 và có đúng 10 chữ số!</c:when>
                                            <c:when test="${param.error eq 'weak_password'}">Lỗi: Mật khẩu phải từ 8 ký tự trở lên, chứa cả chữ, số và ký tự đặc biệt!</c:when>
                                            <c:when test="${param.error eq 'create_failed'}">Lỗi: Không thể thêm tài
                                                khoản mới vào cơ sở dữ liệu.</c:when>
                                            <c:when test="${param.error eq 'update_failed'}">Lỗi: Cập nhật thông tin tài
                                                khoản thất bại.</c:when>
                                            <c:when test="${param.error eq 'status_change_failed'}">Lỗi: Không thể cập
                                                nhật trạng thái tài khoản.</c:when>
                                            <c:otherwise>Có lỗi hệ thống xảy ra. Vui lòng thử lại sau.</c:otherwise>
                                        </c:choose>
                                    </span>
                                    <button class="toast-close-btn"
                                        onclick="this.parentElement.remove()">&times;</button>
                                </div>
                            </c:if>

                            <c:choose>

                                <%-- 1. TAB STAFF: QUẢN LÝ NHÂN VIÊN --%>
                                    <c:when test="${currentTab eq 'staff'}">
                                        <div class="content-header-row">
                                            <div>
                                                <h1>Quản lý tài khoản Nhân viên</h1>
                                                <p>Tạo mới, chỉnh sửa thông tin, phân quyền vai trò và khóa/mở khóa tài
                                                    khoản nhân viên hệ thống.</p>
                                            </div>
                                            <button type="button" class="btn-add-service" onclick="openAddModal()">
                                                <i class="fa-solid fa-user-plus"></i> Thêm Nhân viên
                                            </button>
                                        </div>

                                        <!-- SEARCH & FILTERS -->
                                        <div class="table-card">
                                            <div class="table-filter-bar">
                                                <div class="search-wrapper">
                                                    <i class="fa-solid fa-magnifying-glass"></i>
                                                    <input type="text" id="staffSearch" class="input-search-service"
                                                        placeholder="Tìm tên, email hoặc số điện thoại..." />
                                                </div>
                                                <select id="roleFilter" class="status-select"
                                                    onchange="filterStaffByRole()">
                                                    <option value="">Tất cả vai trò</option>
                                                    <option value="Manager">Quản lý (Manager)</option>
                                                    <option value="Receptionist">Lễ tân (Receptionist)</option>
                                                    <option value="Housekeeping">Buồng phòng (Housekeeping)</option>
                                                </select>
                                            </div>

                                            <!-- DATA TABLE -->
                                            <table class="services-table-element">
                                                <thead>
                                                    <tr>
                                                        <th>Họ và Tên</th>
                                                        <th>Email</th>
                                                        <th>Số điện thoại</th>
                                                        <th>Vai trò</th>
                                                        <th>Trạng thái</th>
                                                        <th>Ngày tạo</th>
                                                        <th style="text-align: right;">Hành động</th>
                                                    </tr>
                                                </thead>
                                                <tbody id="staffTableBody">
                                                    <c:choose>
                                                        <c:when test="${empty staffList}">
                                                            <tr>
                                                                <td colspan="7"
                                                                    style="text-align: center; color: var(--text-muted); padding: 40px;">
                                                                    <i class="fa-solid fa-users-slash"
                                                                        style="font-size: 32px; margin-bottom: 12px; display: block;"></i>
                                                                    Không có tài khoản nhân viên nào trong hệ thống.
                                                                </td>
                                                            </tr>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:forEach var="staff" items="${staffList}">
                                                                <tr class="data-row staff-row"
                                                                    data-role="${staff.roleName}">
                                                                    <td
                                                                        style="font-weight: 700; color: var(--text-navy);">
                                                                        ${staff.fullName}</td>
                                                                    <td>${staff.email}</td>
                                                                    <td>${empty staff.phone ? '<span
                                                                            class="text-muted">-</span>' : staff.phone}
                                                                    </td>
                                                                    <td>
                                                                        <c:choose>
                                                                            <c:when
                                                                                test="${staff.roleName eq 'Manager'}">
                                                                                <span class="role-badge role-manager"><i
                                                                                        class="fa-solid fa-user-gear"></i>
                                                                                    Manager</span>
                                                                            </c:when>
                                                                            <c:when
                                                                                test="${staff.roleName eq 'Receptionist'}">
                                                                                <span
                                                                                    class="role-badge role-receptionist"><i
                                                                                        class="fa-solid fa-bell-concierge"></i>
                                                                                    Receptionist</span>
                                                                            </c:when>
                                                                            <c:when
                                                                                test="${staff.roleName eq 'Housekeeping'}">
                                                                                <span
                                                                                    class="role-badge role-housekeeping"><i
                                                                                        class="fa-solid fa-broom"></i>
                                                                                    Housekeeping</span>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span
                                                                                    class="role-badge role-default">${staff.roleName}</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </td>
                                                                    <td>
                                                                        <c:choose>
                                                                            <c:when test="${staff.active}">
                                                                                <span
                                                                                    class="status-pill status-available"><i
                                                                                        class="fa-solid fa-circle"></i>
                                                                                    Đang hoạt động</span>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span
                                                                                    class="status-pill status-maintenance"><i
                                                                                        class="fa-solid fa-lock"></i> Đã
                                                                                    khóa</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </td>
                                                                    <td>
                                                                        <fmt:formatDate value="${staff.createdAt}"
                                                                            pattern="dd/MM/yyyy HH:mm" />
                                                                    </td>
                                                                    <td style="text-align: right;">
                                                                        <div class="table-actions"
                                                                            style="justify-content: flex-end;">
                                                                            <button class="btn-action edit"
                                                                                onclick="openEditModal(${staff.accountId}, '${staff.email}', '${staff.fullName}', '${staff.phone}', ${staff.roleId})"
                                                                                title="Chỉnh sửa tài khoản">
                                                                                <i
                                                                                    class="fa-solid fa-pen-to-square"></i>
                                                                            </button>

                                                                            <form
                                                                                action="${pageContext.request.contextPath}/admin/dashboard?action=toggle-staff"
                                                                                method="post" style="display: inline;">
                                                                                <input type="hidden" name="accountId"
                                                                                    value="${staff.accountId}" />
                                                                                <input type="hidden" name="active"
                                                                                    value="${not staff.active}" />
                                                                                <c:choose>
                                                                                    <c:when test="${staff.active}">
                                                                                        <button type="submit"
                                                                                            class="btn-action delete"
                                                                                            title="Khóa tài khoản"
                                                                                            onclick="showConfirmModal(event, this.form, '${staff.fullName}', 'false', '${staff.email}', '${staff.phone}', '${staff.roleName}')">
                                                                                            <i
                                                                                                class="fa-solid fa-user-slash"></i>
                                                                                        </button>
                                                                                    </c:when>
                                                                                    <c:otherwise>
                                                                                        <button type="submit"
                                                                                            class="btn-action edit"
                                                                                            style="color: var(--success-green) !important;"
                                                                                            title="Mở khóa tài khoản"
                                                                                            onclick="showConfirmModal(event, this.form, '${staff.fullName}', 'true', '${staff.email}', '${staff.phone}', '${staff.roleName}')">
                                                                                            <i
                                                                                                class="fa-solid fa-user-check"></i>
                                                                                        </button>
                                                                                    </c:otherwise>
                                                                                </c:choose>
                                                                            </form>
                                                                        </div>
                                                                    </td>
                                                                </tr>
                                                            </c:forEach>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </tbody>
                                            </table>
                                        </div>
                                    </c:when>

                                    <%-- 2. TAB CUSTOMERS: QUẢN LÝ KHÁCH HÀNG --%>
                                        <c:when test="${currentTab eq 'customers'}">
                                            <div class="content-header-row">
                                                <div>
                                                    <h1>Quản lý tài khoản Khách hàng</h1>
                                                    <p>Xem thông tin chi tiết, điểm tích lũy thành viên và thực hiện
                                                        khóa/mở khóa tài khoản khách hàng.</p>
                                                </div>
                                            </div>

                                            <!-- SEARCH BAR -->
                                            <div class="table-card">
                                                <div class="table-filter-bar">
                                                    <div class="search-wrapper">
                                                        <i class="fa-solid fa-magnifying-glass"></i>
                                                        <input type="text" id="customerSearch"
                                                            class="input-search-service"
                                                            placeholder="Tìm tên, email hoặc số điện thoại..." />
                                                    </div>
                                                </div>

                                                <!-- DATA TABLE -->
                                                <table class="services-table-element">
                                                    <thead>
                                                        <tr>
                                                            <th>Khách hàng</th>
                                                            <th>Email</th>
                                                            <th>Số điện thoại</th>
                                                            <th>Hạng thành viên</th>
                                                            <th>Điểm tích lũy</th>
                                                            <th>Trạng thái</th>
                                                            <th>Ngày tạo</th>
                                                            <th style="text-align: right;">Hành động</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody id="customerTableBody">
                                                        <c:choose>
                                                            <c:when test="${empty customerList}">
                                                                <tr>
                                                                    <td colspan="8"
                                                                        style="text-align: center; color: var(--text-muted); padding: 40px;">
                                                                        <i class="fa-solid fa-users-slash"
                                                                            style="font-size: 32px; margin-bottom: 12px; display: block;"></i>
                                                                        Không có tài khoản khách hàng nào đăng ký.
                                                                    </td>
                                                                </tr>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:forEach var="customer" items="${customerList}">
                                                                    <tr class="data-row customer-row">
                                                                        <td
                                                                            style="font-weight: 700; color: var(--text-navy);">
                                                                            ${customer.fullName}</td>
                                                                        <td>${customer.email}</td>
                                                                        <td>${empty customer.phone ? '<span
                                                                                class="text-muted">-</span>' :
                                                                            customer.phone}</td>
                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when
                                                                                    test="${customer.membershipLevel eq 'VIP'}">
                                                                                    <span class="badge-vip"><i
                                                                                            class="fa-solid fa-crown"></i>
                                                                                        VIP</span>
                                                                                </c:when>
                                                                                <c:when
                                                                                    test="${customer.membershipLevel eq 'Gold'}">
                                                                                    <span class="badge-gold"><i
                                                                                            class="fa-solid fa-medal"></i>
                                                                                        Gold</span>
                                                                                </c:when>
                                                                                <c:when
                                                                                    test="${customer.membershipLevel eq 'Silver'}">
                                                                                    <span class="badge-silver"><i
                                                                                            class="fa-solid fa-award"></i>
                                                                                        Silver</span>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <span
                                                                                        class="badge-standard">Standard</span>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </td>
                                                                        <td style="font-weight: 600;">
                                                                            ${customer.loyaltyPoints}đ</td>
                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when test="${customer.active}">
                                                                                    <span
                                                                                        class="status-pill status-available"><i
                                                                                            class="fa-solid fa-circle"></i>
                                                                                        Hoạt động</span>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <span
                                                                                        class="status-pill status-maintenance"><i
                                                                                            class="fa-solid fa-lock"></i>
                                                                                        Bị khóa</span>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </td>
                                                                        <td>
                                                                            <fmt:formatDate
                                                                                value="${customer.createdAt}"
                                                                                pattern="dd/MM/yyyy HH:mm" />
                                                                        </td>
                                                                        <td style="text-align: right;">
                                                                            <div class="table-actions"
                                                                                style="justify-content: flex-end;">
                                                                                <button class="btn-action edit"
                                                                                    onclick="openEditCustomerModal(${customer.accountId}, '${customer.email}', '${customer.fullName}', '${customer.phone}', ${customer.loyaltyPoints}, '${customer.membershipLevel}')"
                                                                                    title="Chỉnh sửa tài khoản khách hàng">
                                                                                    <i
                                                                                        class="fa-solid fa-pen-to-square"></i>
                                                                                </button>

                                                                                <form
                                                                                    action="${pageContext.request.contextPath}/admin/dashboard?action=toggle-customer"
                                                                                    method="post"
                                                                                    style="display: inline;">
                                                                                    <input type="hidden"
                                                                                        name="accountId"
                                                                                        value="${customer.accountId}" />
                                                                                    <input type="hidden" name="active"
                                                                                        value="${not customer.active}" />
                                                                                    <c:choose>
                                                                                        <c:when
                                                                                            test="${customer.active}">
                                                                                            <button type="submit"
                                                                                                class="btn-action delete"
                                                                                                title="Khóa tài khoản khách hàng"
                                                                                                onclick="showConfirmModal(event, this.form, '${customer.fullName}', 'false', '${customer.email}', '${customer.phone}', 'Customer')">
                                                                                                <i
                                                                                                    class="fa-solid fa-user-slash"></i>
                                                                                            </button>
                                                                                        </c:when>
                                                                                        <c:otherwise>
                                                                                            <button type="submit"
                                                                                                class="btn-action edit"
                                                                                                style="color: var(--success-green) !important;"
                                                                                                title="Mở khóa tài khoản khách hàng"
                                                                                                onclick="showConfirmModal(event, this.form, '${customer.fullName}', 'true', '${customer.email}', '${customer.phone}', 'Customer')">
                                                                                                <i
                                                                                                    class="fa-solid fa-user-check"></i>
                                                                                            </button>
                                                                                        </c:otherwise>
                                                                                    </c:choose>
                                                                                </form>
                                                                            </div>
                                                                        </td>
                                                                    </tr>
                                                                </c:forEach>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </c:when>

                            </c:choose>
                        </main>

                        <!-- DASHBOARD FOOTER -->
                        <footer class="dashboard-footer">
                            <span>© 2026 HotelOps Luxury Management.</span>
                            <div class="footer-links-row">
                                <a href="#">Hỗ trợ kỹ thuật</a>
                                <a href="#">Chính sách bảo mật</a>
                            </div>
                        </footer>

                    </div>

                </div>

                <%-- 3. DIALOGS & OVERLAY MODALS --%>
                    <c:if test="${currentTab eq 'staff'}">
                        <!-- 3.1 MODAL THÊM MỚI NHÂN VIÊN -->
                        <div id="addStaffModal" class="modal-overlay">
                            <div class="modal-container">
                                <div class="modal-header">
                                    <h3><i class="fa-solid fa-user-plus"></i> Thêm Tài khoản Nhân viên</h3>
                                    <button class="btn-close-modal" onclick="closeAddModal()">&times;</button>
                                </div>
                                <form action="${pageContext.request.contextPath}/admin/dashboard?action=create-staff"
                                    method="post">
                                    <div class="modal-body">
                                        <div class="modal-form-group">
                                            <label for="fullName">Họ và Tên <span
                                                    style="color:#ef4444;">*</span></label>
                                            <input type="text" id="fullName" name="fullName" class="modal-input"
                                                placeholder="Nhập họ và tên nhân viên..." required />
                                        </div>
                                        <div class="modal-form-group">
                                            <label for="email">Địa chỉ Email (Tài khoản) <span
                                                    style="color:#ef4444;">*</span></label>
                                            <input type="email" id="email" name="email" class="modal-input"
                                                placeholder="email@hotel.com" required />
                                        </div>
                                        <div class="modal-form-group">
                                            <label for="phone">Số điện thoại</label>
                                            <input type="tel" id="phone" name="phone" class="modal-input"
                                                placeholder="Ví dụ: 0912345678" pattern="^0[35789][0-9]{8}$"
                                                title="Số điện thoại phải bắt đầu bằng số 0, theo sau là đầu số 3, 5, 7, 8, 9 và có đúng 10 chữ số" />
                                        </div>
                                        <div class="modal-form-group">
                                            <label for="password">Mật khẩu ban đầu <span
                                                    style="color:#ef4444;">*</span></label>
                                            <input type="password" id="password" name="password" class="modal-input"
                                                placeholder="Nhập mật khẩu (tối thiểu 8 ký tự)..." required
                                                minlength="8" />
                                        </div>
                                        <div class="modal-form-group">
                                            <label for="roleId">Vai trò & Phân quyền <span
                                                    style="color:#ef4444;">*</span></label>
                                            <select id="roleId" name="roleId" class="modal-select" required>
                                                <option value="" disabled selected>-- Chọn vai trò nhân viên --</option>
                                                <c:forEach var="role" items="${roles}">
                                                    <option value="${role.roleId}">${role.roleName} -
                                                        ${role.description}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="modal-footer-row">
                                            <button type="button" class="btn-modal-cancel" onclick="closeAddModal()">Hủy
                                                bỏ</button>
                                            <button type="submit" class="btn-modal-submit">Thêm tài khoản</button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <!-- 3.2 MODAL CẬP NHẬT THÔNG TIN NHÂN VIÊN -->
                        <div id="editStaffModal" class="modal-overlay">
                            <div class="modal-container">
                                <div class="modal-header">
                                    <h3><i class="fa-solid fa-user-pen"></i> Chỉnh sửa Tài khoản</h3>
                                    <button class="btn-close-modal" onclick="closeEditModal()">&times;</button>
                                </div>
                                <form action="${pageContext.request.contextPath}/admin/dashboard?action=update-staff"
                                    method="post">
                                    <input type="hidden" id="editAccountId" name="accountId" />
                                    <div class="modal-body">
                                        <div class="modal-form-group">
                                            <label for="editFullName">Họ và Tên <span
                                                    style="color:#ef4444;">*</span></label>
                                            <input type="text" id="editFullName" name="fullName" class="modal-input"
                                                required />
                                        </div>
                                        <div class="modal-form-group">
                                            <label for="editEmail">Địa chỉ Email <span
                                                    style="color:#ef4444;">*</span></label>
                                            <input type="email" id="editEmail" name="email" class="modal-input"
                                                required />
                                        </div>
                                        <div class="modal-form-group">
                                            <label for="editPhone">Số điện thoại</label>
                                            <input type="tel" id="editPhone" name="phone" class="modal-input"
                                                placeholder="Ví dụ: 0912345678" pattern="^0[35789][0-9]{8}$"
                                                title="Số điện thoại phải bắt đầu bằng số 0, theo sau là đầu số 3, 5, 7, 8, 9 và có đúng 10 chữ số" />
                                        </div>
                                        <div class="modal-form-group">
                                            <label for="editPassword">Mật khẩu mới (Để trống nếu không đổi)</label>
                                            <input type="password" id="editPassword" name="password" class="modal-input"
                                                placeholder="Nhập mật khẩu mới nếu muốn thay đổi..." minlength="8" />
                                        </div>
                                        <div class="modal-form-group">
                                            <label for="editRoleId">Vai trò & Phân quyền <span
                                                    style="color:#ef4444;">*</span></label>
                                            <select id="editRoleId" name="roleId" class="modal-select" required>
                                                <c:forEach var="role" items="${roles}">
                                                    <option value="${role.roleId}">${role.roleName} -
                                                        ${role.description}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="modal-footer-row">
                                            <button type="button" class="btn-modal-cancel"
                                                onclick="closeEditModal()">Hủy bỏ</button>
                                            <button type="submit" class="btn-modal-submit">Lưu thay đổi</button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </c:if>

                    <c:if test="${currentTab eq 'customers'}">
                        <!-- 3.4 MODAL CẬP NHẬT THÔNG TIN KHÁCH HÀNG -->
                        <div id="editCustomerModal" class="modal-overlay">
                            <div class="modal-container">
                                <div class="modal-header">
                                    <h3><i class="fa-solid fa-user-pen"></i> Chỉnh sửa Tài khoản Khách hàng</h3>
                                    <button class="btn-close-modal" onclick="closeEditCustomerModal()">&times;</button>
                                </div>
                                <form action="${pageContext.request.contextPath}/admin/dashboard?action=update-customer"
                                    method="post">
                                    <input type="hidden" id="editCustomerAccountId" name="accountId" />
                                    <div class="modal-body">
                                        <div class="modal-form-group">
                                            <label for="editCustomerFullName">Họ và Tên <span
                                                    style="color:#ef4444;">*</span></label>
                                            <input type="text" id="editCustomerFullName" name="fullName"
                                                class="modal-input" required />
                                        </div>
                                        <div class="modal-form-group">
                                            <label for="editCustomerEmail">Địa chỉ Email <span
                                                    style="color:#ef4444;">*</span></label>
                                            <input type="email" id="editCustomerEmail" name="email" class="modal-input"
                                                required />
                                        </div>
                                        <div class="modal-form-group">
                                            <label for="editCustomerPhone">Số điện thoại</label>
                                            <input type="tel" id="editCustomerPhone" name="phone" class="modal-input"
                                                placeholder="Ví dụ: 0912345678" pattern="^0[35789][0-9]{8}$"
                                                title="Số điện thoại phải bắt đầu bằng số 0, theo sau là đầu số 3, 5, 7, 8, 9 và có đúng 10 chữ số" />
                                        </div>
                                        <div class="modal-form-group">
                                            <label for="editCustomerPassword">Mật khẩu mới (Để trống nếu không
                                                đổi)</label>
                                            <input type="password" id="editCustomerPassword" name="password"
                                                class="modal-input" placeholder="Nhập mật khẩu mới nếu muốn thay đổi..."
                                                minlength="8" />
                                        </div>
                                        <div class="modal-grid-2">
                                            <div class="modal-form-group">
                                                <label for="editCustomerMembership">Hạng thành viên <span
                                                        style="color:#ef4444;">*</span></label>
                                                <select id="editCustomerMembership" name="membershipLevel"
                                                    class="modal-select" required>
                                                    <option value="Standard">Standard</option>
                                                    <option value="Silver">Silver</option>
                                                    <option value="Gold">Gold</option>
                                                    <option value="VIP">VIP</option>
                                                </select>
                                            </div>
                                            <div class="modal-form-group">
                                                <label for="editCustomerLoyaltyPoints">Điểm tích lũy <span
                                                        style="color:#ef4444;">*</span></label>
                                                <input type="number" id="editCustomerLoyaltyPoints" name="loyaltyPoints"
                                                    class="modal-input" min="0" required />
                                            </div>
                                        </div>
                                        <div class="modal-footer-row">
                                            <button type="button" class="btn-modal-cancel"
                                                onclick="closeEditCustomerModal()">Hủy bỏ</button>
                                            <button type="submit" class="btn-modal-submit">Lưu thay đổi</button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </c:if>

                    <!-- 3.3 MODAL XÁC NHẬN KHÓA/KÍCH HOẠT TÀI KHOẢN -->
                    <div id="customConfirmModal" class="modal-overlay">
                        <div class="modal-container" style="max-width: 440px;">
                            <div class="modal-header" style="border-bottom: none; padding: 24px 24px 12px;">
                                <h3 id="confirmModalTitle"
                                    style="display: flex; align-items: center; gap: 10px; font-size: 19px;">
                                    Xác nhận thao tác
                                </h3>
                                <button class="btn-close-modal" onclick="closeConfirmModal()">&times;</button>
                            </div>
                            <div class="modal-body" style="padding: 12px 24px 24px;">
                                <p id="confirmModalMessage"
                                    style="color: #475569; font-size: 14.5px; line-height: 1.6; margin-bottom: 20px; text-align: left;">
                                </p>

                                <!-- Hộp hiển thị chi tiết tài khoản -->
                                <div id="confirmAccountDetails"
                                    style="background: #f8fafc; border-radius: 8px; padding: 12px 16px; margin-bottom: 24px; font-size: 13.5px; border: 1px solid var(--border-color); display: none;">
                                    <div style="margin-bottom: 8px; display: flex; justify-content: space-between;">
                                        <span style="color: var(--text-muted); font-weight: 500;">Email:</span>
                                        <strong id="confirmEmail" style="color: var(--text-navy);"></strong>
                                    </div>
                                    <div style="margin-bottom: 8px; display: flex; justify-content: space-between;">
                                        <span style="color: var(--text-muted); font-weight: 500;">Số điện thoại:</span>
                                        <strong id="confirmPhone" style="color: var(--text-navy);"></strong>
                                    </div>
                                    <div style="display: flex; justify-content: space-between;">
                                        <span style="color: var(--text-muted); font-weight: 500;">Vai trò:</span>
                                        <strong id="confirmRole" style="color: var(--text-navy);"></strong>
                                    </div>
                                </div>

                                <div class="modal-footer-row" style="margin-top: 0;">
                                    <button type="button" class="btn-modal-cancel" onclick="closeConfirmModal()">Hủy
                                        bỏ</button>
                                    <button type="button" id="btnConfirmAction" onclick="executePendingAction()"
                                        class="btn-modal-submit" style="min-width: 120px;">Xác nhận</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- 4. JAVASCRIPT FOR DYNAMIC FILTERING & MODALS --%>
                        <script>
                            // Modal Handling
                            // Confirm Modal Handling
                            let pendingFormToSubmit = null;

                            function showConfirmModal(event, formElement, name, isActive, email, phone, role) {
                                event.preventDefault(); // Ngăn submit form mặc định
                                pendingFormToSubmit = formElement;

                                const isUnlocking = isActive === 'true';
                                const titleText = isUnlocking ? 'Kích hoạt tài khoản' : 'Khóa tài khoản';
                                const msgText = isUnlocking
                                    ? `Bạn có chắc chắn muốn <strong>MỞ KHÓA (Kích hoạt)</strong> tài khoản của <strong>${name}</strong>?`
                                    : `Bạn có chắc chắn muốn <strong>KHÓA</strong> tài khoản của <strong>${name}</strong>? Người dùng sẽ không thể đăng nhập hệ thống sau khi khóa.`;

                                document.getElementById('confirmModalTitle').innerHTML = isUnlocking
                                    ? `<i class="fa-solid fa-circle-check" style="color: #10b981;"></i> ${titleText}`
                                    : `<i class="fa-solid fa-triangle-exclamation" style="color: #ef4444;"></i> ${titleText}`;

                                document.getElementById('confirmModalMessage').innerHTML = msgText;

                                // Điền thông tin chi tiết tài khoản
                                const detailsBox = document.getElementById('confirmAccountDetails');
                                if (detailsBox) {
                                    if (email || phone || role) {
                                        document.getElementById('confirmEmail').textContent = email || '—';
                                        document.getElementById('confirmPhone').textContent = (phone && phone !== '-') ? phone : '—';
                                        document.getElementById('confirmRole').textContent = role || '—';
                                        detailsBox.style.display = 'block';
                                    } else {
                                        detailsBox.style.display = 'none';
                                    }
                                }

                                const confirmBtn = document.getElementById('btnConfirmAction');
                                if (isUnlocking) {
                                    confirmBtn.style.backgroundColor = '#10b981';
                                    confirmBtn.style.color = '#ffffff';
                                    confirmBtn.innerText = 'Kích hoạt';
                                } else {
                                    confirmBtn.style.backgroundColor = '#ef4444';
                                    confirmBtn.style.color = '#ffffff';
                                    confirmBtn.innerText = 'Khóa tài khoản';
                                }

                                const modal = document.getElementById('customConfirmModal');
                                if (modal) modal.style.display = 'flex';
                            }

                            function closeConfirmModal() {
                                const modal = document.getElementById('customConfirmModal');
                                if (modal) modal.style.display = 'none';
                                pendingFormToSubmit = null;
                            }

                            function executePendingAction() {
                                if (pendingFormToSubmit) {
                                    pendingFormToSubmit.submit();
                                }
                            }

                            function openAddModal() {
                                const modal = document.getElementById('addStaffModal');
                                if (modal) modal.style.display = 'flex';
                            }
                            function closeAddModal() {
                                const modal = document.getElementById('addStaffModal');
                                if (modal) modal.style.display = 'none';
                            }
                            function openEditModal(id, email, name, phone, roleId) {
                                const modal = document.getElementById('editStaffModal');
                                if (!modal) return;
                                document.getElementById('editAccountId').value = id;
                                document.getElementById('editEmail').value = email;
                                document.getElementById('editFullName').value = name;
                                document.getElementById('editPhone').value = phone === '-' ? '' : phone;
                                document.getElementById('editRoleId').value = roleId;
                                document.getElementById('editPassword').value = '';
                                modal.style.display = 'flex';
                            }
                            function closeEditModal() {
                                const modal = document.getElementById('editStaffModal');
                                if (modal) modal.style.display = 'none';
                            }

                            function openEditCustomerModal(id, email, name, phone, loyaltyPoints, membershipLevel) {
                                const modal = document.getElementById('editCustomerModal');
                                if (!modal) return;
                                document.getElementById('editCustomerAccountId').value = id;
                                document.getElementById('editCustomerEmail').value = email;
                                document.getElementById('editCustomerFullName').value = name;
                                document.getElementById('editCustomerPhone').value = (phone === '-' || phone === '—') ? '' : phone;
                                document.getElementById('editCustomerLoyaltyPoints').value = loyaltyPoints;
                                document.getElementById('editCustomerMembership').value = membershipLevel;
                                document.getElementById('editCustomerPassword').value = '';
                                modal.style.display = 'flex';
                            }
                            function closeEditCustomerModal() {
                                const modal = document.getElementById('editCustomerModal');
                                if (modal) modal.style.display = 'none';
                            }

                            // Live Search Staff
                            const staffSearch = document.getElementById('staffSearch');
                            if (staffSearch) {
                                staffSearch.addEventListener('input', function () {
                                    applyStaffFilters();
                                });
                            }

                            // Dropdown Role Filter
                            function filterStaffByRole() {
                                applyStaffFilters();
                            }

                            // Apply filters combined (Search + Role)
                            function applyStaffFilters() {
                                const filterText = document.getElementById('staffSearch').value.toUpperCase();
                                const filterRole = document.getElementById('roleFilter').value;
                                const rows = document.querySelectorAll('.staff-row');

                                rows.forEach(row => {
                                    const textContent = row.textContent || row.innerText;
                                    const matchesSearch = textContent.toUpperCase().includes(filterText);

                                    const rowRole = row.getAttribute('data-role');
                                    const matchesRole = !filterRole || rowRole === filterRole;

                                    if (matchesSearch && matchesRole) {
                                        row.style.display = '';
                                    } else {
                                        row.style.display = 'none';
                                    }
                                });
                            }

                            // Live Search Customers
                            const customerSearch = document.getElementById('customerSearch');
                            if (customerSearch) {
                                customerSearch.addEventListener('input', function () {
                                    const filterText = this.value.toUpperCase();
                                    const rows = document.querySelectorAll('.customer-row');

                                    rows.forEach(row => {
                                        const textContent = row.textContent || row.innerText;
                                        if (textContent.toUpperCase().includes(filterText)) {
                                            row.style.display = '';
                                        } else {
                                            row.style.display = 'none';
                                        }
                                    });
                                });
                            }

                            // Auto Close Toasts
                            window.addEventListener('DOMContentLoaded', () => {
                                const toasts = document.querySelectorAll('.alert-toast');
                                toasts.forEach(toast => {
                                    setTimeout(() => {
                                        toast.style.opacity = '0';
                                        toast.style.transform = 'translateY(-10px)';
                                        toast.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
                                        setTimeout(() => toast.remove(), 500);
                                    }, 4000);
                                });

                                // Validation & Double-submit prevention for Edit Customer Form
                                const editCustomerModal = document.getElementById('editCustomerModal');
                                if (editCustomerModal) {
                                    const form = editCustomerModal.querySelector('form');
                                    if (form) {
                                        form.addEventListener('submit', function (e) {
                                            const name = document.getElementById('editCustomerFullName').value.trim();
                                            const email = document.getElementById('editCustomerEmail').value.trim();
                                            const points = parseInt(document.getElementById('editCustomerLoyaltyPoints').value) || 0;

                                            if (!name || !email) {
                                                e.preventDefault();
                                                alert('Vui lòng điền đầy đủ Họ tên và Email.');
                                                return;
                                            }
                                            if (points < 0) {
                                                e.preventDefault();
                                                alert('Điểm tích lũy không được nhỏ hơn 0.');
                                                return;
                                            }

                                            const submitBtn = form.querySelector('button[type="submit"]');
                                            if (submitBtn) {
                                                submitBtn.disabled = true;
                                                submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang lưu...';
                                            }
                                        });
                                    }
                                }
                            });

                            // Trực tiếp khai báo hàm đóng/mở modal lên đối tượng window toàn cục để tránh lỗi cache JS từ trình duyệt
                            window.openChangePasswordModal = function () {
                                console.log("openChangePasswordModal (inline admin.jsp) has been called!");
                                const modal = document.getElementById('changePasswordModal');
                                console.log("Modal element found:", modal);
                                if (modal) {
                                    modal.style.display = 'flex';
                                    window.hideModalAlert();
                                    const form = document.getElementById('changePasswordForm');
                                    if (form) form.reset();

                                    ['currentPassword', 'newPassword', 'confirmNewPassword'].forEach(id => {
                                        const el = document.getElementById(id);
                                        if (el) el.setAttribute('type', 'password');
                                    });
                                    document.querySelectorAll('#changePasswordModal .password-toggle-btn i').forEach(icon => {
                                        icon.className = 'fa-solid fa-eye-slash';
                                    });
                                }
                            };

                            window.closeChangePasswordModal = function () {
                                const modal = document.getElementById('changePasswordModal');
                                if (modal) {
                                    modal.style.display = 'none';
                                }
                            };

                            window.togglePasswordVisibility = function (inputId, btn) {
                                const input = document.getElementById(inputId);
                                if (!input) return;

                                const icon = btn.querySelector('i');
                                if (input.getAttribute('type') === 'password') {
                                    input.setAttribute('type', 'text');
                                    if (icon) icon.className = 'fa-solid fa-eye';
                                } else {
                                    input.setAttribute('type', 'password');
                                    if (icon) icon.className = 'fa-solid fa-eye-slash';
                                }
                            };

                            window.showModalAlert = function (type, message) {
                                const alertBox = document.getElementById('changePasswordAlert');
                                const alertText = document.getElementById('changePasswordAlertText');
                                if (!alertBox || !alertText) return;

                                alertBox.className = 'alert-toast-inline ' + (type === 'success' ? 'success-alert' : 'error-alert');

                                const icon = alertBox.querySelector('i');
                                if (icon) {
                                    icon.className = type === 'success' ? 'fa-solid fa-circle-check' : 'fa-solid fa-triangle-exclamation';
                                }

                                alertText.innerText = message;
                                alertBox.style.display = 'flex';
                            };

                            window.hideModalAlert = function () {
                                const alertBox = document.getElementById('changePasswordAlert');
                                if (alertBox) {
                                    alertBox.style.display = 'none';
                                }
                            };
                        </script>

                        <!-- Include Change Password Modal -->
                        <jsp:include page="../admin/includes/change-password-modal.jsp" />
                        <!-- Load Admin Dashboard JavaScript logic -->
                        <script src="${pageContext.request.contextPath}/assets/js/admin.js?v=5"></script>

            </body>

            </html>