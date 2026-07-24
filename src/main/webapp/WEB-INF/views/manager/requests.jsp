<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=3" />

<body class="dashboard-body">

    <div class="dashboard-layout">

        <!-- SIDEBAR -->
        <c:set var="activePage" value="requests" scope="request" />
        <jsp:include page="sidebar.jsp" />

        <div class="dashboard-main">

            <header class="main-topbar">
                <div class="breadcrumb">
                    <span>Quản trị</span>
                    <span class="separator">&gt;</span>
                    <span class="current">Yêu cầu &amp; Nhân viên</span>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </a>
            </header>

            <main class="workspace-content">

                <div class="content-header-row">
                    <div>
                        <h1>Yêu cầu khách hàng &amp; công việc nhân viên</h1>
                        <p>Quản lý yêu cầu của khách, phân công và theo dõi hiệu suất nhân viên buồng phòng.
                        </p>
                    </div>
                </div>

                <!-- KPI -->
                <div class="stat-grid stat-grid-3">
                    <div class="stat-card">
                        <div class="stat-icon icon-pending"><i class="fa-solid fa-hourglass-half"></i></div>
                        <div class="stat-body">
                            <span class="stat-label">Yêu cầu đang chờ</span>
                            <span class="stat-value">${pendingCount}</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon icon-progress"><i class="fa-solid fa-spinner"></i></div>
                        <div class="stat-body">
                            <span class="stat-label">Đang thực hiện</span>
                            <span class="stat-value">${inProgressCount}</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon icon-occupancy"><i class="fa-solid fa-user-check"></i></div>
                        <div class="stat-body">
                            <span class="stat-label">Nhân viên đang trực</span>
                            <span class="stat-value">${activeStaffCount}</span>
                        </div>
                    </div>
                </div>

                <!-- CUSTOMER REQUESTS TABLE -->
                <div class="table-card" style="margin-bottom: 24px;">
                    <!-- BỘ LỌC (GET, server-side) -->
                    <form class="table-filter-bar" method="get"
                          action="${pageContext.request.contextPath}/manager/requests"
                          style="display:grid; grid-template-columns: 1.5fr 1fr 1fr 1fr auto; gap:16px; align-items:end;">
                        <div class="modal-form-group" style="margin-bottom:0;">
                            <label>Tìm theo phòng</label>
                            <div class="search-wrapper" style="max-width:100%;">
                                <i class="fa-solid fa-magnifying-glass"></i>
                                <input type="text" name="q" class="input-search-service"
                                       placeholder="Nhập số phòng..." value="<c:out value='${q}' />" />
                            </div>
                        </div>
                        <div class="modal-form-group" style="margin-bottom:0;">
                            <label>Mức độ ưu tiên</label>
                            <select name="priority" class="status-select" onchange="this.form.submit()"
                                    style="width:100%;">
                                <option value="all" ${priorityFilter eq 'all' ? 'selected' : '' }>Tất cả mức
                                    độ</option>
                                <option value="Urgent" ${priorityFilter eq 'Urgent' ? 'selected' : '' }>Khẩn
                                    cấp</option>
                                <option value="High" ${priorityFilter eq 'High' ? 'selected' : '' }>Cao
                                </option>
                                <option value="Medium" ${priorityFilter eq 'Medium' ? 'selected' : '' }>
                                    Trung bình</option>
                                <option value="Low" ${priorityFilter eq 'Low' ? 'selected' : '' }>Thấp
                                </option>
                            </select>
                        </div>
                        <div class="modal-form-group" style="margin-bottom:0;">
                            <label>Nhân viên được giao</label>
                            <select name="staff" class="status-select" onchange="this.form.submit()"
                                    style="width:100%;">
                                <option value="all" ${staffFilterVal eq 'all' ? 'selected' : '' }>Tất cả
                                    nhân viên</option>
                                <option value="unassigned" ${staffFilterVal eq 'unassigned' ? 'selected'
                                                             : '' }>Chưa gán</option>
                                <c:forEach var="s" items="${staffList}">
                                    <c:set var="sidStr">${s.accountId}</c:set>
                                    <option value="${s.accountId}" ${staffFilterVal eq sidStr ? 'selected'
                                                     : '' }>
                                            <c:out value="${s.fullName}" />
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="modal-form-group" style="margin-bottom:0;">
                            <label>Trạng thái</label>
                            <select name="status" class="status-select" onchange="this.form.submit()"
                                    style="width:100%;">
                                <option value="all" ${statusFilter eq 'all' ? 'selected' : '' }>Tất cả trạng
                                    thái</option>
                                <option value="Pending" ${statusFilter eq 'Pending' ? 'selected' : '' }>Đang
                                    chờ</option>
                                <option value="InProgress" ${statusFilter eq 'InProgress' ? 'selected' : ''
                                        }>Đang thực hiện</option>
                                <option value="Resolved" ${statusFilter eq 'Resolved' ? 'selected' : '' }>
                                    Đã xử lý</option>
                                <option value="Unresolvable" ${statusFilter eq 'Unresolvable' ? 'selected' : '' }>
                                    Không thể xử lý</option>
                                <option value="Cancelled" ${statusFilter eq 'Cancelled' ? 'selected' : '' }>
                                    Đã huỷ</option>
                            </select>
                        </div>
                        <button type="submit" class="btn-add-service" style="height:40px;"><i
                                class="fa-solid fa-magnifying-glass"></i> Lọc</button>
                    </form>

                    <table class="services-table-element">
                        <thead>
                            <tr>
                                <th style="width:34%">Yêu cầu</th>
                                <th style="width:13%">Ưu tiên</th>
                                <th style="width:18%">Nhân viên được giao</th>
                                <th style="width:15%">Trạng thái</th>
                                <th style="width:20%">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="r" items="${requests}">
                                <tr>
                                    <td>
                                        <div class="service-name-cell">
                                            <div>
                                                <span class="service-title">
                                                    <c:out value="${r.issueNames}" />
                                                </span>
                                                <c:if test="${not empty r.description}">
                                                    <br/><span class="request-sub"><c:out value="${r.description}" /></span>
                                                </c:if>
                                                <span class="request-sub">
                                                    <i class="fa-solid fa-bed"></i> Phòng
                                                    <c:out value="${r.roomNumbers}" />
                                                    &nbsp;•&nbsp; <i class="fa-regular fa-clock"></i>
                                                    ${r.createdAt.dayOfMonth}/${r.createdAt.monthValue}/${r.createdAt.year}
                                                    ${r.createdAt.hour}:${r.createdAt.minute}
                                                </span>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.priority eq 'Urgent'}"><span
                                                    class="prio-badge prio-urgent">KHẨN CẤP</span></c:when>
                                            <c:when test="${r.priority eq 'High'}"><span
                                                    class="prio-badge prio-high">CAO</span></c:when>
                                            <c:when test="${r.priority eq 'Low'}"><span
                                                    class="prio-badge prio-low">THẤP</span></c:when>
                                            <c:otherwise><span class="prio-badge prio-medium">TRUNG
                                                    BÌNH</span></c:otherwise>
                                            </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty r.assignedStaff}"><span
                                                    style="font-weight:600; color:var(--text-navy);">
                                                    <c:out value="${r.assignedStaff.fullName}" />
                                                </span></c:when>
                                            <c:otherwise><span
                                                    style="color:var(--text-muted); font-style:italic;">Chưa
                                                    gán</span></c:otherwise>
                                            </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.status eq 'InProgress'}"><span
                                                    class="status-pill status-occupied"><i
                                                        class="fa-solid fa-circle"></i> ĐANG THỰC
                                                    HIỆN</span></c:when>
                                            <c:when test="${r.status eq 'Resolved'}"><span
                                                    class="status-pill status-available"><i
                                                        class="fa-solid fa-circle"></i> ĐÃ XỬ LÝ</span>
                                                </c:when>
                                                <c:when test="${r.status eq 'Unresolvable'}"><span
                                                    class="status-pill status-unresolvable"><i
                                                        class="fa-solid fa-circle"></i> KHÔNG THỂ XỬ LÝ</span>
                                                </c:when>
                                                <c:when test="${r.status eq 'Cancelled'}"><span
                                                    class="status-pill status-maintenance"><i
                                                        class="fa-solid fa-circle"></i> ĐÃ HUỶ</span>
                                                </c:when>
                                                <c:otherwise><span class="status-pill status-cleaning"><i
                                                        class="fa-solid fa-circle"></i> ĐANG CHỜ</span>
                                                </c:otherwise>
                                            </c:choose>
                                    </td>
                                    <td>
                                        <div class="table-actions" style="display:flex; gap:8px;">
                                            <c:if test="${r.status ne 'Resolved'}">
                                                <button class="btn-action edit" title="Đổi mức ưu tiên"
                                                        onclick="openPriorityModal('${r.requestId}', '${r.priority}')"><i
                                                        class="fa-solid fa-flag"></i></button>
                                            </c:if>
                                            <c:choose>
                                                <c:when
                                                    test="${r.status eq 'Pending' or r.status eq 'InProgress'}">
                                                    <button class="btn-action assign"
                                                            title="${r.assignedStaffId != null ? 'Đổi NV' : 'Gán việc'}"
                                                            data-title="<c:out value='${r.issueNames}' />"
                                                            data-room="<c:out value='${r.roomNumbers}' />"
                                                            onclick="openAssignModal('${r.requestId}', this)"><i
                                                            class="fa-solid fa-user-plus"></i></button>
                                                    <button class="btn-action delete" title="Huỷ"
                                                            onclick="changeStatus('${r.requestId}', 'Cancelled')"><i
                                                            class="fa-solid fa-xmark"></i></button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:if test="${r.status eq 'Resolved'}">
                                                            <span style="color:var(--text-muted); font-size:12px;">—</span>
                                                        </c:if>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty requests}">
                                <tr>
                                    <td colspan="5"
                                        style="text-align:center; padding:40px; color:var(--text-muted);">
                                        <i class="fa-solid fa-folder-open"
                                           style="font-size:32px; margin-bottom:12px; display:block;"></i>
                                        Không tìm thấy yêu cầu nào phù hợp
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>

                    <div class="table-pagination-bar">
                        <div class="pagination-info">
                            <c:choose>
                                <c:when test="${totalItems == 0}">Hiển thị 0 yêu cầu</c:when>
                                <c:otherwise>Hiển thị ${(page-1)*pageSize + 1}-${page*pageSize gt totalItems
                                                        ? totalItems : page*pageSize} trong số ${totalItems} yêu cầu
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="pagination-controls">
                            <c:choose>
                                <c:when test="${page > 1}">
                                    <c:url var="prevUrl" value="/manager/requests">
                                        <c:param name="q" value="${q}" />
                                        <c:param name="priority" value="${priorityFilter}" />
                                        <c:param name="staff" value="${staffFilterVal}" />
                                        <c:param name="status" value="${statusFilter}" />
                                        <c:param name="page" value="${page-1}" />
                                    </c:url>
                                    <a class="btn-page" href="${prevUrl}"><i
                                            class="fa-solid fa-chevron-left"></i></a>
                                    </c:when>
                                    <c:otherwise><span class="btn-page disabled"><i
                                            class="fa-solid fa-chevron-left"></i></span></c:otherwise>
                                </c:choose>
                                <c:forEach var="p" begin="1" end="${totalPages}">
                                    <c:url var="pUrl" value="/manager/requests">
                                        <c:param name="q" value="${q}" />
                                        <c:param name="priority" value="${priorityFilter}" />
                                        <c:param name="staff" value="${staffFilterVal}" />
                                        <c:param name="status" value="${statusFilter}" />
                                        <c:param name="page" value="${p}" />
                                    </c:url>
                                <a class="btn-page ${p == page ? 'active' : ''}" href="${pUrl}">${p}</a>
                            </c:forEach>
                            <c:choose>
                                <c:when test="${page < totalPages}">
                                    <c:url var="nextUrl" value="/manager/requests">
                                        <c:param name="q" value="${q}" />
                                        <c:param name="priority" value="${priorityFilter}" />
                                        <c:param name="staff" value="${staffFilterVal}" />
                                        <c:param name="status" value="${statusFilter}" />
                                        <c:param name="page" value="${page+1}" />
                                    </c:url>
                                    <a class="btn-page" href="${nextUrl}"><i
                                            class="fa-solid fa-chevron-right"></i></a>
                                    </c:when>
                                    <c:otherwise><span class="btn-page disabled"><i
                                            class="fa-solid fa-chevron-right"></i></span></c:otherwise>
                                </c:choose>
                        </div>
                    </div>
                </div>

                <!-- STAFF TRACKING TABLE -->
                <div class="content-header-row" style="margin-bottom:16px;">
                    <div>
                        <h1 style="font-size:22px;">Theo dõi công việc nhân viên</h1>
                        <p>Trạng thái trực và số công việc đã hoàn thành của nhân viên buồng phòng. Bấm vào
                            một dòng để xem chi tiết.</p>
                    </div>
                </div>

                <div class="table-card">
                    <table class="services-table-element">
                        <thead>
                            <tr>
                                <th style="width:32%">Nhân viên</th>
                                <th style="width:18%">Trạng thái</th>
                                <th style="width:15%">Việc đang làm</th>
                                <th style="width:15%">Hoàn thành hôm nay</th>
                                <th style="width:20%">Hoàn thành tháng này</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="s" items="${staffList}">
                                <tr style="cursor:pointer;"
                                    onclick="window.location.href = '${pageContext.request.contextPath}/manager/staff?id=${s.accountId}'">
                                    <td>
                                        <div class="service-name-cell">
                                            <div class="staff-avatar-sm"><i class="fa-solid fa-user"></i>
                                            </div>
                                            <div><span class="service-title">
                                                    <c:out value="${s.fullName}" />
                                                </span>
                                                <span class="request-sub">
                                                    <c:out value="${s.email}" />
                                                </span>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${s.workStatus eq 'Active'}"><span
                                                    class="wk-badge wk-active"><i
                                                        class="fa-solid fa-circle"></i> Đang trực</span>
                                                </c:when>
                                                <c:when test="${s.workStatus eq 'OnBreak'}"><span
                                                    class="wk-badge wk-break"><i
                                                        class="fa-solid fa-circle"></i> Đang nghỉ</span>
                                                </c:when>
                                                <c:otherwise><span class="wk-badge wk-offline"><i
                                                        class="fa-solid fa-circle"></i> Ngoại tuyến</span>
                                                </c:otherwise>
                                            </c:choose>
                                    </td>
                                    <td><span style="font-weight:600;">${s.activeAssignments}</span></td>
                                    <td><span
                                            style="font-weight:700; color:var(--brand-blue);">${s.completedToday}</span>
                                    </td>
                                    <td><span style="font-weight:600;">${s.completedMonth} việc</span></td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty staffList}">
                                <tr>
                                    <td colspan="5"
                                        style="text-align:center; padding:40px; color:var(--text-muted);">
                                        Chưa có nhân viên buồng phòng</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>

            </main>

            <footer class="dashboard-footer">
                <span>© 2026 HotelOps Luxury Management. Hệ thống quản trị nội bộ.</span>
                <div class="footer-links-row">
                    <a href="#">Hỗ trợ</a><a href="#">Bảo mật</a><a href="#">Điều khoản</a>
                </div>
            </footer>
        </div>
    </div>

    <!-- ASSIGN MODAL -->
    <div class="modal-overlay" id="assignModal">
        <div class="modal-container">
            <div class="modal-header">
                <h3>Gán việc cho nhân viên</h3>
                <button class="btn-close-modal" onclick="closeAssignModal()"><i
                        class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="modal-body">
                <p id="assignContext" style="color:var(--text-muted); font-size:14px; margin-top:0;"></p>
                <form id="assignForm" action="${pageContext.request.contextPath}/manager/requests"
                      method="post">
                    <input type="hidden" name="action" value="assign" />
                    <input type="hidden" id="assignRequestId" name="requestId" value="" />
                    <div class="modal-form-group">
                        <label for="assignStaffId">Chọn nhân viên đang trực</label>
                        <select id="assignStaffId" name="staffId" class="modal-select" required>
                            <c:forEach var="s" items="${staffList}">
                                <c:if test="${s.workStatus eq 'Active'}">
                                    <option value="${s.accountId}">
                                        <c:out value="${s.fullName}" /> — đang làm ${s.activeAssignments}
                                        việc
                                    </option>
                                </c:if>
                            </c:forEach>
                        </select>
                        <small id="noActiveStaffHint"
                               style="display:none; color:#dc2626; font-weight:600;">Hiện không có nhân viên
                            nào đang trực.</small>
                    </div>
                    <div class="modal-footer-row">
                        <button type="button" class="btn-modal-cancel" onclick="closeAssignModal()">Hủy
                            bỏ</button>
                        <button type="submit" class="btn-modal-submit">Gán việc</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Hidden form for status updates -->
    <form id="statusForm" action="${pageContext.request.contextPath}/manager/requests" method="post"
          style="display:none;">
        <input type="hidden" name="action" value="status" />
        <input type="hidden" id="statusRequestId" name="requestId" value="" />
        <input type="hidden" id="statusValue" name="status" value="" />
    </form>

    <!-- PRIORITY MODAL -->
    <div class="modal-overlay" id="priorityModal">
        <div class="modal-container">
            <div class="modal-header">
                <h3>Đổi mức ưu tiên</h3>
                <button class="btn-close-modal" onclick="closePriorityModal()"><i
                        class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="modal-body">
                <form id="priorityForm" action="${pageContext.request.contextPath}/manager/requests"
                      method="post">
                    <input type="hidden" name="action" value="priority" />
                    <input type="hidden" id="priorityRequestId" name="requestId" value="" />
                    <div class="modal-form-group">
                        <label for="priorityValue">Mức độ ưu tiên</label>
                        <select id="priorityValue" name="priority" class="modal-select" required>
                            <option value="Urgent">Khẩn cấp</option>
                            <option value="High">Cao</option>
                            <option value="Medium">Trung bình</option>
                            <option value="Low">Thấp</option>
                        </select>
                    </div>
                    <div class="modal-footer-row">
                        <button type="button" class="btn-modal-cancel" onclick="closePriorityModal()">Hủy
                            bỏ</button>
                        <button type="submit" class="btn-modal-submit">Lưu</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        function openAssignModal(requestId, btn) {
            document.getElementById("assignRequestId").value = requestId;
            const title = btn ? (btn.dataset.title || "") : "";
            const room = btn ? (btn.dataset.room || "?") : "?";
            document.getElementById("assignContext").innerText = 'Yêu cầu: "' + title + '" — Phòng ' + room;
            const sel = document.getElementById("assignStaffId");
            const hint = document.getElementById("noActiveStaffHint");
            const hasActive = sel.options.length > 0;
            sel.style.display = hasActive ? "block" : "none";
            hint.style.display = hasActive ? "none" : "block";
            document.querySelector("#assignForm .btn-modal-submit").disabled = !hasActive;
            document.getElementById("assignModal").style.display = "flex";
        }
        function closeAssignModal() {
            document.getElementById("assignModal").style.display = "none";
        }

        function openPriorityModal(requestId, currentPriority) {
            document.getElementById("priorityRequestId").value = requestId;
            document.getElementById("priorityValue").value = currentPriority;
            document.getElementById("priorityModal").style.display = "flex";
        }
        function closePriorityModal() {
            document.getElementById("priorityModal").style.display = "none";
        }

        function changeStatus(requestId, status) {

            const msg = "Bạn có chắc muốn HUỶ yêu cầu này?";

            if (!confirm(msg))
                return;

            document.getElementById("statusRequestId").value = requestId;
            document.getElementById("statusValue").value = status;
            document.getElementById("statusForm").submit();
        }

        document.querySelectorAll(".modal-overlay").forEach(ov => {
            ov.addEventListener("click", e => {
                if (e.target === ov)
                    ov.style.display = "none";
            });
        });
    </script>

</body>

</html>