<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%-- Giao diện Dashboard quản trị hệ thống Admin. @author TùngNQ --%>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=3" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=5" />
<fmt:setLocale value="vi_VN" />

<body class="dashboard-body">

    <c:set var="currentTab"
        value="${requestScope.currentTab != null ? requestScope.currentTab : 'staff'}" />

    <div class="dashboard-layout">

        <c:set var="activePage" value="${currentTab}" scope="request" />
        <jsp:include page="../admin/includes/sidebar.jsp" />

        <div class="dashboard-main">

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

                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </a>
            </header>

            <main class="workspace-content">

                <c:if test="${not empty param.success}">
                    <div class="alert-toast success-toast">
                        <i class="fa-solid fa-circle-check"></i>
                        <span>
                            <c:choose>
                                <c:when test="${param.success eq 'created'}">Đã thêm tài khoản nhân viên
                                    thành công!</c:when>
                                <c:when test="${param.success eq 'updated'}">Đã cập nhật thông tin nhân
                                    viên thành công!</c:when>
                                <c:when test="${param.success eq 'status_changed'}">Đã thay đổi trạng
                                    thái tài khoản thành công!</c:when>
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
                                <c:when test="${param.error eq 'invalid_input'}">Lỗi (MSG02): Vui lòng điền đầy đủ các trường bắt buộc.</c:when>
                                <c:when test="${param.error eq 'email_exists'}">Lỗi (MSG09): Email này đã được sử dụng trong hệ thống!</c:when>
                                <c:when test="${param.error eq 'phone_exists'}">Lỗi (MSG09): Số điện thoại này đã được sử dụng trong hệ thống!</c:when>
                                <c:when test="${param.error eq 'invalid_email'}">Lỗi: Định dạng email không hợp lệ!</c:when>
                                <c:when test="${param.error eq 'invalid_phone'}">Lỗi: Số điện thoại phải bắt đầu bằng 0, theo sau là đầu số 3, 5, 7, 8, 9 và có đúng 10 chữ số!</c:when>
                                <c:when test="${param.error eq 'weak_password'}">Lỗi: Mật khẩu mới phải bao gồm cả chữ, số và ký tự đặc biệt!</c:when>
                                <c:when test="${param.error eq 'cannot_demote_admin'}">Lỗi (BR-65): Không thể thay đổi vai trò của tài khoản Admin duy nhất!</c:when>
                                <c:when test="${param.error eq 'cannot_lock_admin'}">Lỗi (BR-65): Không thể vô hiệu hóa tài khoản Admin duy nhất!</c:when>
                                <c:when test="${param.error eq 'create_failed'}">Lỗi: Không thể thêm tài khoản mới vào cơ sở dữ liệu.</c:when>
                                <c:when test="${param.error eq 'update_failed'}">Lỗi: Cập nhật thông tin tài khoản thất bại.</c:when>
                                <c:when test="${param.error eq 'status_change_failed'}">Lỗi: Không thể cập nhật trạng thái tài khoản.</c:when>
                                <c:otherwise>Lỗi (MSG55): Đã xảy ra lỗi không mong muốn. Vui lòng thử lại sau.</c:otherwise>
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
                                    <p>Tạo mới, chỉnh sửa thông tin, phân quyền vai trò và khóa/mở khóa
                                        tài khoản nhân viên hệ thống.</p>
                                </div>
                                <button type="button" class="btn-add-service" onclick="openAddModal()">
                                    <i class="fa-solid fa-user-plus"></i> Thêm Nhân viên
                                </button>
                            </div>

                            <div class="table-filter-bar" style="width: 100%; margin-bottom: 16px;">
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
                                    <option value="Admin">Quản trị viên (Admin)</option>
                                </select>
                            </div>

                            <div class="table-responsive" style="width: 100%; overflow-x: auto;">
                                <table class="services-table-element" style="width: 100%;">
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
                                                        <td>
                                                            <c:choose>
                                                                <c:when
                                                                    test="${empty staff.phone or staff.phone eq 'null' or staff.phone eq '-'}">
                                                                    <span class="text-muted">-</span>
                                                                </c:when>
                                                                <c:otherwise>${staff.phone}
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when
                                                                    test="${staff.roleName eq 'Manager'}">
                                                                    <span
                                                                        class="role-badge role-manager"><i
                                                                            class="fa-solid fa-user-gear"></i>
                                                                        Quản lý</span>
                                                                </c:when>
                                                                <c:when
                                                                    test="${staff.roleName eq 'Receptionist'}">
                                                                    <span
                                                                        class="role-badge role-receptionist"><i
                                                                            class="fa-solid fa-bell-concierge"></i>
                                                                        Lễ tân</span>
                                                                </c:when>
                                                                <c:when
                                                                    test="${staff.roleName eq 'Housekeeping'}">
                                                                    <span
                                                                        class="role-badge role-housekeeping"><i
                                                                            class="fa-solid fa-broom"></i>
                                                                        Buồng phòng</span>
                                                                </c:when>
                                                                <c:when
                                                                    test="${staff.roleName eq 'Admin'}">
                                                                    <span
                                                                        class="role-badge role-admin"
                                                                        style="background: #e0e7ff; color: #4338ca; border: 1px solid #c7d2fe; padding: 4px 10px; border-radius: 6px; font-weight: 600; font-size: 12.5px;"><i
                                                                            class="fa-solid fa-user-shield"></i>
                                                                        Quản trị viên</span>
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
                                                                            class="fa-solid fa-lock"></i>
                                                                        Đã khóa</span>
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
                                                                    method="post"
                                                                    style="display: inline;">
                                                                    <input type="hidden"
                                                                        name="accountId"
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

                                <div class="table-filter-bar" style="width: 100%; margin-bottom: 16px;">
                                    <div class="search-wrapper">
                                        <i class="fa-solid fa-magnifying-glass"></i>
                                        <input type="text" id="customerSearch"
                                            class="input-search-service"
                                            placeholder="Tìm tên, email hoặc số điện thoại..." />
                                    </div>
                                </div>

                                <div class="table-responsive" style="width: 100%; overflow-x: auto;">
                                    <table class="services-table-element" style="width: 100%;">
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
                                                            <td>
                                                                <c:choose>
                                                                    <c:when
                                                                        test="${empty customer.phone or customer.phone eq 'null' or customer.phone eq '-'}">
                                                                        <span
                                                                            class="text-muted">-</span>
                                                                    </c:when>
                                                                    <c:otherwise>${customer.phone}
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
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
                                                                        <input type="hidden"
                                                                            name="active"
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
            <div id="addStaffModal" class="modal-overlay">
                <div class="modal-container">
                    <div class="modal-header">
                        <h3><i class="fa-solid fa-user-plus"></i> Thêm Tài khoản Nhân viên</h3>
                        <button class="btn-close-modal" onclick="closeAddModal()">&times;</button>
                    </div>
                    <form
                        action="${pageContext.request.contextPath}/admin/dashboard?action=create-staff"
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
                                <span class="validation-msg" id="email-validation-msg"
                                    style="color: #ef4444; font-size: 12.5px; margin-top: 5px; font-weight: 500; display: none;"></span>
                            </div>
                            <div class="modal-form-group">
                                <label for="phone">Số điện thoại</label>
                                <input type="tel" id="phone" name="phone" class="modal-input"
                                    placeholder="Ví dụ: 0912345678" pattern="^0[35789][0-9]{8}$"
                                    title="Số điện thoại phải bắt đầu bằng số 0, theo sau là đầu số 3, 5, 7, 8, 9 và có đúng 10 chữ số" />
                                <span class="validation-msg" id="phone-validation-msg"
                                    style="color: #ef4444; font-size: 12.5px; margin-top: 5px; font-weight: 500; display: none;"></span>
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
                                    <option value="" disabled selected>-- Chọn vai trò nhân viên --
                                    </option>
                                    <c:forEach var="role" items="${roles}">
                                        <option value="${role.roleId}">
                                            <c:choose>
                                                <c:when test="${role.roleName eq 'Manager'}">Quản lý khách sạn (Manager)</c:when>
                                                <c:when test="${role.roleName eq 'Receptionist'}">Lễ tân (Receptionist)</c:when>
                                                <c:when test="${role.roleName eq 'Housekeeping'}">Nhân viên buồng phòng (Housekeeping)</c:when>
                                                <c:when test="${role.roleName eq 'Admin'}">Quản trị viên hệ thống (Admin)</c:when>
                                                <c:when test="${role.roleName eq 'Customer'}">Khách hàng (Customer)</c:when>
                                                <c:otherwise>${role.roleName} - ${role.description}</c:otherwise>
                                            </c:choose>
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="modal-footer-row">
                                <button type="button" class="btn-modal-cancel"
                                    onclick="closeAddModal()">Hủy bỏ</button>
                                <button type="submit" class="btn-modal-submit">Thêm tài khoản</button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>

            <div id="editStaffModal" class="modal-overlay">
                <div class="modal-container">
                    <div class="modal-header">
                        <h3><i class="fa-solid fa-user-pen"></i> Chỉnh sửa Tài khoản</h3>
                        <button class="btn-close-modal" onclick="closeEditModal()">&times;</button>
                    </div>
                    <form
                        action="${pageContext.request.contextPath}/admin/dashboard?action=update-staff"
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
                                <span class="validation-msg" id="editEmail-validation-msg"
                                    style="color: #ef4444; font-size: 12.5px; margin-top: 5px; font-weight: 500; display: none;"></span>
                            </div>
                            <div class="modal-form-group">
                                <label for="editPhone">Số điện thoại</label>
                                <input type="tel" id="editPhone" name="phone" class="modal-input"
                                    placeholder="Ví dụ: 0912345678" pattern="^0[35789][0-9]{8}$"
                                    title="Số điện thoại phải bắt đầu bằng số 0, theo sau là đầu số 3, 5, 7, 8, 9 và có đúng 10 chữ số" />
                                <span class="validation-msg" id="editPhone-validation-msg"
                                    style="color: #ef4444; font-size: 12.5px; margin-top: 5px; font-weight: 500; display: none;"></span>
                            </div>
                            <div class="modal-form-group">
                                <label for="editPassword">Mật khẩu mới (Để trống nếu không đổi)</label>
                                <input type="password" id="editPassword" name="password"
                                    class="modal-input"
                                    placeholder="Nhập mật khẩu mới nếu muốn thay đổi..."
                                    minlength="8" />
                            </div>
                            <div class="modal-form-group">
                                <label for="editRoleId">Vai trò & Phân quyền <span
                                        style="color:#ef4444;">*</span></label>
                                <select id="editRoleId" name="roleId" class="modal-select" required>
                                    <c:forEach var="role" items="${roles}">
                                        <option value="${role.roleId}">
                                            <c:choose>
                                                <c:when test="${role.roleName eq 'Manager'}">Quản lý khách sạn (Manager)</c:when>
                                                <c:when test="${role.roleName eq 'Receptionist'}">Lễ tân (Receptionist)</c:when>
                                                <c:when test="${role.roleName eq 'Housekeeping'}">Nhân viên buồng phòng (Housekeeping)</c:when>
                                                <c:when test="${role.roleName eq 'Admin'}">Quản trị viên hệ thống (Admin)</c:when>
                                                <c:when test="${role.roleName eq 'Customer'}">Khách hàng (Customer)</c:when>
                                                <c:otherwise>${role.roleName} - ${role.description}</c:otherwise>
                                            </c:choose>
                                        </option>
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
            <div id="editCustomerModal" class="modal-overlay">
                <div class="modal-container">
                    <div class="modal-header">
                        <h3><i class="fa-solid fa-user-pen"></i> Chỉnh sửa Tài khoản Khách hàng</h3>
                        <button class="btn-close-modal"
                            onclick="closeEditCustomerModal()">&times;</button>
                    </div>
                    <form
                        action="${pageContext.request.contextPath}/admin/dashboard?action=update-customer"
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
                                <input type="email" id="editCustomerEmail" name="email"
                                    class="modal-input" required />
                                <span class="validation-msg" id="editCustomerEmail-validation-msg"
                                    style="color: #ef4444; font-size: 12.5px; margin-top: 5px; font-weight: 500; display: none;"></span>
                            </div>
                            <div class="modal-form-group">
                                <label for="editCustomerPhone">Số điện thoại</label>
                                <input type="tel" id="editCustomerPhone" name="phone"
                                    class="modal-input" placeholder="Ví dụ: 0912345678"
                                    pattern="^0[35789][0-9]{8}$"
                                    title="Số điện thoại phải bắt đầu bằng số 0, theo sau là đầu số 3, 5, 7, 8, 9 và có đúng 10 chữ số" />
                                <span class="validation-msg" id="editCustomerPhone-validation-msg"
                                    style="color: #ef4444; font-size: 12.5px; margin-top: 5px; font-weight: 500; display: none;"></span>
                            </div>
                            <div class="modal-form-group">
                                <label for="editCustomerPassword">Mật khẩu mới (Để trống nếu không
                                    đổi)</label>
                                <input type="password" id="editCustomerPassword" name="password"
                                    class="modal-input"
                                    placeholder="Nhập mật khẩu mới nếu muốn thay đổi..."
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
                                    <input type="number" id="editCustomerLoyaltyPoints"
                                        name="loyaltyPoints" class="modal-input" min="0" required />
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

                    <div id="confirmAccountDetails"
                        style="background: #f8fafc; border-radius: 8px; padding: 12px 16px; margin-bottom: 24px; font-size: 13.5px; border: 1px solid var(--border-color); display: none;">
                        <div style="margin-bottom: 8px; display: flex; justify-content: space-between;">
                            <span style="color: var(--text-muted); font-weight: 500;">Email:</span>
                            <strong id="confirmEmail" style="color: var(--text-navy);"></strong>
                        </div>
                        <div style="margin-bottom: 8px; display: flex; justify-content: space-between;">
                            <span style="color: var(--text-muted); font-weight: 500;">Số điện
                                thoại:</span>
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
                            let displayRole = role;
                            if (role === 'Manager') displayRole = 'Quản lý';
                            else if (role === 'Receptionist') displayRole = 'Lễ tân';
                            else if (role === 'Housekeeping') displayRole = 'Buồng phòng';
                            else if (role === 'Customer') displayRole = 'Khách hàng';
                            else if (role === 'Admin') displayRole = 'Quản trị viên';
                            document.getElementById('confirmRole').textContent = displayRole || '—';
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

                    let displayPhone = phone;
                    if (!phone || phone === 'null' || phone === 'undefined' || phone === '-' || phone === '—') {
                        displayPhone = '';
                    }
                    document.getElementById('editPhone').value = displayPhone;
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

                    let displayPhone = phone;
                    if (!phone || phone === 'null' || phone === 'undefined' || phone === '-' || phone === '—') {
                        displayPhone = '';
                    }
                    document.getElementById('editCustomerPhone').value = displayPhone;
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

                    // Phone sanitization & validation helper
                    function sanitizePhoneField(inputElement) {
                        if (!inputElement) return;
                        let val = inputElement.value.trim();
                        if (!val || val.toLowerCase() === 'null' || val.toLowerCase() === 'undefined' || val === '-' || val === '—') {
                            inputElement.value = '';
                            return;
                        }
                        let cleaned = val.replace(/[\s\-\.\(\)]/g, '');
                        if (cleaned.startsWith('+84')) {
                            cleaned = '0' + cleaned.substring(3);
                        }
                        if (inputElement.value !== cleaned) {
                            inputElement.value = cleaned;
                        }
                    }

                    function validatePhoneField(inputElement) {
                        if (!inputElement) return true;
                        sanitizePhoneField(inputElement);
                        let val = inputElement.value;
                        if (!val) return true; // Optional field
                        const phoneRegex = /^0[35789]\d{8}$/;
                        return phoneRegex.test(val);
                    }

                    // Setup dynamic cleaning on blur & change events
                    ['phone', 'editPhone', 'editCustomerPhone'].forEach(id => {
                        const input = document.getElementById(id);
                        if (input) {
                            input.addEventListener('blur', function () {
                                sanitizePhoneField(this);
                            });
                            input.addEventListener('change', function () {
                                sanitizePhoneField(this);
                            });
                        }
                    });

                    // Real-time validation for duplicates (Email and Phone)
                    function checkDuplicate(fieldId, value, msgId, excludeId = -1) {
                        const msgSpan = document.getElementById(msgId);
                        if (!msgSpan) return;

                        if (!value || value.trim() === '') {
                            msgSpan.style.display = 'none';
                            msgSpan.innerText = '';
                            return;
                        }

                        const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/admin'));
                        let url = contextPath + '/admin/dashboard?action=check-duplicate';
                        if (fieldId === 'email' || fieldId === 'editEmail' || fieldId === 'editCustomerEmail') {
                            url += '&email=' + encodeURIComponent(value.trim());
                        } else {
                            url += '&phone=' + encodeURIComponent(value.trim());
                        }

                        if (excludeId && excludeId > 0) {
                            url += '&excludeId=' + excludeId;
                        }

                        fetch(url)
                            .then(res => res.json())
                            .then(data => {
                                if (fieldId === 'email' || fieldId === 'editEmail' || fieldId === 'editCustomerEmail') {
                                    if (data.emailExists) {
                                        msgSpan.innerText = 'Lỗi: Email này đã được sử dụng trong hệ thống!';
                                        msgSpan.style.display = 'block';
                                    } else {
                                        msgSpan.style.display = 'none';
                                        msgSpan.innerText = '';
                                    }
                                } else {
                                    if (data.phoneExists) {
                                        msgSpan.innerText = 'Lỗi: Số điện thoại này đã được sử dụng trong hệ thống!';
                                        msgSpan.style.display = 'block';
                                    } else {
                                        msgSpan.style.display = 'none';
                                        msgSpan.innerText = '';
                                    }
                                }
                            })
                            .catch(err => console.error("Error check duplicate:", err));
                    }

                    // Bind events for real-time validation
                    // Add Staff
                    const emailInput = document.getElementById('email');
                    if (emailInput) {
                        emailInput.addEventListener('blur', function () {
                            checkDuplicate('email', this.value, 'email-validation-msg');
                        });
                        emailInput.addEventListener('input', function () {
                            const msgSpan = document.getElementById('email-validation-msg');
                            if (msgSpan) msgSpan.style.display = 'none';
                        });
                    }
                    const phoneInput = document.getElementById('phone');
                    if (phoneInput) {
                        phoneInput.addEventListener('blur', function () {
                            checkDuplicate('phone', this.value, 'phone-validation-msg');
                        });
                        phoneInput.addEventListener('input', function () {
                            const msgSpan = document.getElementById('phone-validation-msg');
                            if (msgSpan) msgSpan.style.display = 'none';
                        });
                    }

                    // Edit Staff
                    const editEmailInput = document.getElementById('editEmail');
                    if (editEmailInput) {
                        editEmailInput.addEventListener('blur', function () {
                            const excludeId = document.getElementById('editAccountId').value;
                            checkDuplicate('editEmail', this.value, 'editEmail-validation-msg', excludeId);
                        });
                        editEmailInput.addEventListener('input', function () {
                            const msgSpan = document.getElementById('editEmail-validation-msg');
                            if (msgSpan) msgSpan.style.display = 'none';
                        });
                    }
                    const editPhoneInput = document.getElementById('editPhone');
                    if (editPhoneInput) {
                        editPhoneInput.addEventListener('blur', function () {
                            const excludeId = document.getElementById('editAccountId').value;
                            checkDuplicate('editPhone', this.value, 'editPhone-validation-msg', excludeId);
                        });
                        editPhoneInput.addEventListener('input', function () {
                            const msgSpan = document.getElementById('editPhone-validation-msg');
                            if (msgSpan) msgSpan.style.display = 'none';
                        });
                    }

                    // Edit Customer
                    const editCustomerEmailInput = document.getElementById('editCustomerEmail');
                    if (editCustomerEmailInput) {
                        editCustomerEmailInput.addEventListener('blur', function () {
                            const excludeId = document.getElementById('editCustomerAccountId').value;
                            checkDuplicate('editCustomerEmail', this.value, 'editCustomerEmail-validation-msg', excludeId);
                        });
                        editCustomerEmailInput.addEventListener('input', function () {
                            const msgSpan = document.getElementById('editCustomerEmail-validation-msg');
                            if (msgSpan) msgSpan.style.display = 'none';
                        });
                    }
                    const editCustomerPhoneInput = document.getElementById('editCustomerPhone');
                    if (editCustomerPhoneInput) {
                        editCustomerPhoneInput.addEventListener('blur', function () {
                            const excludeId = document.getElementById('editCustomerAccountId').value;
                            checkDuplicate('editCustomerPhone', this.value, 'editCustomerPhone-validation-msg', excludeId);
                        });
                        editCustomerPhoneInput.addEventListener('input', function () {
                            const msgSpan = document.getElementById('editCustomerPhone-validation-msg');
                            if (msgSpan) msgSpan.style.display = 'none';
                        });
                    }

                    // Add Staff Form Submit Handler
                    const addStaffModal = document.getElementById('addStaffModal');
                    if (addStaffModal) {
                        const form = addStaffModal.querySelector('form');
                        if (form) {
                            form.addEventListener('submit', function (e) {
                                const activeErrors = form.querySelectorAll('.validation-msg');
                                let hasValidationError = false;
                                activeErrors.forEach(msg => {
                                    if (msg.style.display === 'block') {
                                        hasValidationError = true;
                                    }
                                });
                                if (hasValidationError) {
                                    e.preventDefault();
                                    alert('Vui lòng sửa các thông tin trùng lặp (Email hoặc Số điện thoại) trước khi gửi.');
                                    return;
                                }

                                const phoneField = document.getElementById('phone');
                                if (!validatePhoneField(phoneField)) {
                                    e.preventDefault();
                                    alert('Số điện thoại không hợp lệ! Số điện thoại phải bắt đầu bằng 0, theo sau là đầu số 3, 5, 7, 8, 9 và có đúng 10 chữ số.');
                                    if (phoneField) phoneField.focus();
                                    return;
                                }

                                const submitBtn = form.querySelector('button[type="submit"]');
                                if (submitBtn) {
                                    setTimeout(() => {
                                        submitBtn.disabled = true;
                                        submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang thêm...';
                                    }, 0);
                                }
                            });
                        }
                    }

                    // Edit Staff Form Submit Handler
                    const editStaffModal = document.getElementById('editStaffModal');
                    if (editStaffModal) {
                        const form = editStaffModal.querySelector('form');
                        if (form) {
                            form.addEventListener('submit', function (e) {
                                const activeErrors = form.querySelectorAll('.validation-msg');
                                let hasValidationError = false;
                                activeErrors.forEach(msg => {
                                    if (msg.style.display === 'block') {
                                        hasValidationError = true;
                                    }
                                });
                                if (hasValidationError) {
                                    e.preventDefault();
                                    alert('Vui lòng sửa các thông tin trùng lặp (Email hoặc Số điện thoại) trước khi gửi.');
                                    return;
                                }

                                const phoneField = document.getElementById('editPhone');
                                if (!validatePhoneField(phoneField)) {
                                    e.preventDefault();
                                    alert('Số điện thoại không hợp lệ! Số điện thoại phải bắt đầu bằng 0, theo sau là đầu số 3, 5, 7, 8, 9 và có đúng 10 chữ số.');
                                    if (phoneField) phoneField.focus();
                                    return;
                                }

                                const submitBtn = form.querySelector('button[type="submit"]');
                                if (submitBtn) {
                                    setTimeout(() => {
                                        submitBtn.disabled = true;
                                        submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang lưu...';
                                    }, 0);
                                }
                            });
                        }
                    }

                    // Edit Customer Form Submit Handler
                    const editCustomerModal = document.getElementById('editCustomerModal');
                    if (editCustomerModal) {
                        const form = editCustomerModal.querySelector('form');
                        if (form) {
                            form.addEventListener('submit', function (e) {
                                const activeErrors = form.querySelectorAll('.validation-msg');
                                let hasValidationError = false;
                                activeErrors.forEach(msg => {
                                    if (msg.style.display === 'block') {
                                        hasValidationError = true;
                                    }
                                });
                                if (hasValidationError) {
                                    e.preventDefault();
                                    alert('Vui lòng sửa các thông tin trùng lặp (Email hoặc Số điện thoại) trước khi gửi.');
                                    return;
                                }

                                const name = document.getElementById('editCustomerFullName').value.trim();
                                const email = document.getElementById('editCustomerEmail').value.trim();
                                const points = parseInt(document.getElementById('editCustomerLoyaltyPoints').value) || 0;
                                const phoneField = document.getElementById('editCustomerPhone');

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
                                if (!validatePhoneField(phoneField)) {
                                    e.preventDefault();
                                    alert('Số điện thoại không hợp lệ! Số điện thoại phải bắt đầu bằng 0, theo sau là đầu số 3, 5, 7, 8, 9 và có đúng 10 chữ số.');
                                    if (phoneField) phoneField.focus();
                                    return;
                                }

                                const submitBtn = form.querySelector('button[type="submit"]');
                                if (submitBtn) {
                                    setTimeout(() => {
                                        submitBtn.disabled = true;
                                        submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang lưu...';
                                    }, 0);
                                }
                            });
                        }
                    }
                });

                // Đăng ký hàm đóng/mở modal lên window object toàn cục tránh cache JS
                window.openChangePasswordModal = function () {
                    const modal = document.getElementById('changePasswordModal');
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
                    if (modal) modal.style.display = 'none';
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
                    if (alertBox) alertBox.style.display = 'none';
                };
            </script>

            <jsp:include page="../admin/includes/change-password-modal.jsp" />
            <script src="${pageContext.request.contextPath}/assets/js/admin.js?v=5" charset="UTF-8"></script>

</body>

</html>