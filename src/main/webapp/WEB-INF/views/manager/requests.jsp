<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=3" />

<body class="dashboard-body">

    <div class="dashboard-layout">

        <!-- SIDEBAR -->
        <c:set var="activePage" value="requests" scope="request" />
        <jsp:include page="includes/sidebar.jsp" />

        <!-- MAIN -->
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
                        <p>Quản lý yêu cầu của khách, phân công và theo dõi hiệu suất nhân viên buồng phòng.</p>
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

                <!-- Hidden data: requests -->
                <div id="requestDataStorage" style="display:none;">
                    <c:forEach var="r" items="${requests}">
                        <div class="request-data-item"
                             data-id="${r.requestId}"
                             data-room="<c:out value='${r.roomNumber}' />"
                             data-title="<c:out value='${r.title}' />"
                             data-desc="<c:out value='${r.description}' />"
                             data-priority="<c:out value='${r.priority}' />"
                             data-status="<c:out value='${r.status}' />"
                             data-staff-id="${r.assignedStaffId}"
                             data-staff-name="<c:out value='${r.assignedStaffName}' />"
                             data-created="<fmt:formatDate value='${r.createdAt}' pattern='dd/MM/yyyy HH:mm' />">
                        </div>
                    </c:forEach>
                </div>

                <!-- Hidden data: staff -->
                <div id="staffDataStorage" style="display:none;">
                    <c:forEach var="s" items="${staffList}">
                        <div class="staff-data-item"
                             data-id="${s.accountId}"
                             data-name="<c:out value='${s.fullName}' />"
                             data-email="<c:out value='${s.email}' />"
                             data-status="<c:out value='${s.workStatus}' />"
                             data-today="${s.completedToday}"
                             data-month="${s.completedMonth}"
                             data-active="${s.activeAssignments}">
                        </div>
                    </c:forEach>
                </div>

                <!-- CUSTOMER REQUESTS TABLE -->
                <div class="table-card" style="margin-bottom: 24px;">
                    <div class="table-filter-bar" style="display:grid; grid-template-columns: 1.5fr 1fr 1fr 1fr; gap:16px; align-items:end;">
                        <div class="modal-form-group" style="margin-bottom:0;">
                            <label>Tìm theo phòng</label>
                            <div class="search-wrapper" style="max-width:100%;">
                                <i class="fa-solid fa-magnifying-glass"></i>
                                <input type="text" id="reqSearch" class="input-search-service" placeholder="Nhập số phòng..." onkeyup="filterRequests()" />
                            </div>
                        </div>
                        <div class="modal-form-group" style="margin-bottom:0;">
                            <label>Mức độ ưu tiên</label>
                            <select id="priorityFilter" class="status-select" onchange="filterRequests()" style="width:100%;">
                                <option value="all">Tất cả mức độ</option>
                                <option value="Urgent">Khẩn cấp</option>
                                <option value="High">Cao</option>
                                <option value="Medium">Trung bình</option>
                                <option value="Low">Thấp</option>
                            </select>
                        </div>
                        <div class="modal-form-group" style="margin-bottom:0;">
                            <label>Nhân viên được giao</label>
                            <select id="staffFilter" class="status-select" onchange="filterRequests()" style="width:100%;">
                                <option value="all">Tất cả nhân viên</option>
                                <option value="unassigned">Chưa gán</option>
                                <c:forEach var="s" items="${staffList}">
                                    <option value="${s.accountId}"><c:out value="${s.fullName}" /></option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="modal-form-group" style="margin-bottom:0;">
                            <label>Trạng thái</label>
                            <select id="reqStatusFilter" class="status-select" onchange="filterRequests()" style="width:100%;">
                                <option value="all">Tất cả trạng thái</option>
                                <option value="Pending">Đang chờ</option>
                                <option value="InProgress">Đang thực hiện</option>
                                <option value="Completed">Hoàn thành</option>
                                <option value="Cancelled">Đã huỷ</option>
                            </select>
                        </div>
                    </div>

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
                        <tbody id="requestsTableBody"></tbody>
                    </table>

                    <div class="table-pagination-bar">
                        <div class="pagination-info" id="reqPaginationInfo"></div>
                        <div class="pagination-controls" id="reqPaginationControls"></div>
                    </div>
                </div>

                <!-- STAFF TRACKING TABLE -->
                <div class="content-header-row" style="margin-bottom:16px;">
                    <div>
                        <h1 style="font-size:22px;">Theo dõi công việc nhân viên</h1>
                        <p>Trạng thái trực và số công việc đã hoàn thành của nhân viên buồng phòng.</p>
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
                        <tbody id="staffTableBody"></tbody>
                    </table>
                </div>

            </main>

            <footer class="dashboard-footer">
                <span>© 2026 HotelOps Luxury Management. Hệ thống quản trị nội bộ.</span>
                <div class="footer-links-row">
                    <a href="#">Hỗ trợ</a>
                    <a href="#">Bảo mật</a>
                    <a href="#">Điều khoản</a>
                </div>
            </footer>
        </div>
    </div>

    <!-- ASSIGN MODAL -->
    <div class="modal-overlay" id="assignModal">
        <div class="modal-container">
            <div class="modal-header">
                <h3>Gán việc cho nhân viên</h3>
                <button class="btn-close-modal" onclick="closeAssignModal()"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="modal-body">
                <p id="assignContext" style="color:var(--text-muted); font-size:14px; margin-top:0;"></p>
                <form id="assignForm" action="${pageContext.request.contextPath}/manager/requests" method="post">
                    <input type="hidden" name="action" value="assign" />
                    <input type="hidden" id="assignRequestId" name="requestId" value="" />
                    <div class="modal-form-group">
                        <label for="assignStaffId">Chọn nhân viên đang trực</label>
                        <select id="assignStaffId" name="staffId" class="modal-select" required>
                            <c:forEach var="s" items="${staffList}">
                                <c:if test="${s.workStatus eq 'Active'}">
                                    <option value="${s.accountId}"><c:out value="${s.fullName}" /> — đang làm ${s.activeAssignments} việc</option>
                                </c:if>
                            </c:forEach>
                        </select>
                        <small id="noActiveStaffHint" style="display:none; color:#dc2626; font-weight:600;">
                            Hiện không có nhân viên nào đang trực.
                        </small>
                    </div>
                    <div class="modal-footer-row">
                        <button type="button" class="btn-modal-cancel" onclick="closeAssignModal()">Hủy bỏ</button>
                        <button type="submit" class="btn-modal-submit">Gán việc</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- STAFF DETAIL MODAL -->
    <div class="modal-overlay" id="staffModal">
        <div class="modal-container">
            <div class="modal-header">
                <h3>Thông tin nhân viên</h3>
                <button class="btn-close-modal" onclick="closeStaffModal()"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="modal-body">
                <div class="staff-detail-head">
                    <div class="staff-detail-avatar" id="staffAvatar">NV</div>
                    <div>
                        <div class="staff-detail-name" id="staffName"></div>
                        <div class="staff-detail-email" id="staffEmail"></div>
                        <span id="staffStatusBadge"></span>
                    </div>
                </div>
                <div class="staff-detail-stats">
                    <div class="detail-stat"><span class="detail-stat-value" id="staffToday">0</span><span class="detail-stat-label">Hoàn thành hôm nay</span></div>
                    <div class="detail-stat"><span class="detail-stat-value" id="staffMonth">0</span><span class="detail-stat-label">Hoàn thành tháng này</span></div>
                    <div class="detail-stat"><span class="detail-stat-value" id="staffActive">0</span><span class="detail-stat-label">Việc đang làm</span></div>
                </div>
                <h4 style="margin:18px 0 8px; font-size:14px; color:var(--text-navy);">Công việc đang thực hiện</h4>
                <ul class="staff-task-list" id="staffTaskList"></ul>
            </div>
        </div>
    </div>

    <!-- Hidden form for status updates -->
    <form id="statusForm" action="${pageContext.request.contextPath}/manager/requests" method="post" style="display:none;">
        <input type="hidden" name="action" value="status" />
        <input type="hidden" id="statusRequestId" name="requestId" value="" />
        <input type="hidden" id="statusValue" name="status" value="" />
    </form>

    <script>
        // ---------- Hydrate data ----------
        const requests = [];
        document.querySelectorAll(".request-data-item").forEach(el => {
            const staffIdRaw = el.getAttribute("data-staff-id");
            requests.push({
                id: parseInt(el.getAttribute("data-id")),
                room: el.getAttribute("data-room") || "",
                title: el.getAttribute("data-title") || "",
                desc: el.getAttribute("data-desc") || "",
                priority: el.getAttribute("data-priority") || "Medium",
                status: el.getAttribute("data-status") || "Pending",
                staffId: (staffIdRaw && staffIdRaw !== "") ? parseInt(staffIdRaw) : null,
                staffName: el.getAttribute("data-staff-name") || "",
                created: el.getAttribute("data-created") || ""
            });
        });

        const staff = [];
        document.querySelectorAll(".staff-data-item").forEach(el => {
            staff.push({
                id: parseInt(el.getAttribute("data-id")),
                name: el.getAttribute("data-name") || "",
                email: el.getAttribute("data-email") || "",
                status: el.getAttribute("data-status") || "Offline",
                today: parseInt(el.getAttribute("data-today")) || 0,
                month: parseInt(el.getAttribute("data-month")) || 0,
                active: parseInt(el.getAttribute("data-active")) || 0
            });
        });

        // ---------- Label / badge helpers ----------
        const PRIORITY = {
            Urgent: { text: "KHẨN CẤP", cls: "prio-urgent" },
            High:   { text: "CAO",       cls: "prio-high" },
            Medium: { text: "TRUNG BÌNH",cls: "prio-medium" },
            Low:    { text: "THẤP",      cls: "prio-low" }
        };
        const REQ_STATUS = {
            Pending:    { text: "ĐANG CHỜ",       cls: "status-cleaning" },
            InProgress: { text: "ĐANG THỰC HIỆN", cls: "status-occupied" },
            Completed:  { text: "HOÀN THÀNH",     cls: "status-available" },
            Cancelled:  { text: "ĐÃ HUỶ",         cls: "status-maintenance" }
        };
        const STAFF_STATUS = {
            Active:  { text: "Đang trực",  cls: "wk-active" },
            OnBreak: { text: "Đang nghỉ",  cls: "wk-break" },
            Offline: { text: "Ngoại tuyến",cls: "wk-offline" }
        };
        function esc(s) {
            return String(s).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;");
        }

        // ---------- Requests table (filter + pagination) ----------
        let reqPage = 1;
        const reqPageSize = 6;
        let filteredReqs = [];

        function renderReqPagination(totalPages) {
            const c = document.getElementById("reqPaginationControls");
            c.innerHTML = "";
            const prev = document.createElement("button");
            prev.type = "button";
            prev.className = "btn-page" + (reqPage === 1 || totalPages === 0 ? " disabled" : "");
            prev.innerHTML = '<i class="fa-solid fa-chevron-left"></i>';
            if (reqPage > 1 && totalPages > 0) prev.onclick = () => { reqPage--; renderRequests(); };
            c.appendChild(prev);
            for (let i = 1; i <= totalPages; i++) {
                const b = document.createElement("button");
                b.type = "button";
                b.className = "btn-page" + (i === reqPage ? " active" : "");
                b.innerText = i;
                b.onclick = () => { reqPage = i; renderRequests(); };
                c.appendChild(b);
            }
            const next = document.createElement("button");
            next.type = "button";
            next.className = "btn-page" + (reqPage === totalPages || totalPages === 0 ? " disabled" : "");
            next.innerHTML = '<i class="fa-solid fa-chevron-right"></i>';
            if (reqPage < totalPages && totalPages > 0) next.onclick = () => { reqPage++; renderRequests(); };
            c.appendChild(next);
        }

        function renderRequests() {
            const tbody = document.getElementById("requestsTableBody");
            tbody.innerHTML = "";
            const total = filteredReqs.length;
            const totalPages = Math.ceil(total / reqPageSize);
            if (reqPage > totalPages && totalPages > 0) reqPage = totalPages;

            if (total === 0) {
                tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding:40px; color:var(--text-muted);">' +
                    '<i class="fa-solid fa-folder-open" style="font-size:32px; margin-bottom:12px; display:block;"></i>' +
                    'Không tìm thấy yêu cầu nào phù hợp</td></tr>';
                document.getElementById("reqPaginationInfo").innerText = "Hiển thị 0 yêu cầu";
                renderReqPagination(0);
                return;
            }

            const start = (reqPage - 1) * reqPageSize;
            const end = Math.min(start + reqPageSize, total);
            filteredReqs.slice(start, end).forEach(r => {
                const p = PRIORITY[r.priority] || PRIORITY.Medium;
                const st = REQ_STATUS[r.status] || REQ_STATUS.Pending;
                const staffCell = r.staffName
                    ? '<span style="font-weight:600; color:var(--text-navy);">' + esc(r.staffName) + '</span>'
                    : '<span style="color:var(--text-muted); font-style:italic;">Chưa gán</span>';

                // Hành động theo trạng thái
                let actions = "";
                if (r.status === "Pending" || r.status === "InProgress") {
                    const assignLabel = r.staffId ? "Đổi NV" : "Gán việc";
                    actions += '<button class="btn-action assign" title="' + assignLabel + '" onclick="openAssignModal(' + r.id + ')"><i class="fa-solid fa-user-plus"></i></button>';
                    actions += '<button class="btn-action done" title="Hoàn thành" onclick="changeStatus(' + r.id + ', \'Completed\')"><i class="fa-solid fa-check"></i></button>';
                    actions += '<button class="btn-action delete" title="Huỷ" onclick="changeStatus(' + r.id + ', \'Cancelled\')"><i class="fa-solid fa-xmark"></i></button>';
                } else {
                    actions = '<span style="color:var(--text-muted); font-size:12px;">—</span>';
                }

                const tr = document.createElement("tr");
                tr.innerHTML =
                    '<td><div class="service-name-cell"><div>' +
                        '<span class="service-title">' + esc(r.title) + '</span>' +
                        '<span class="request-sub"><i class="fa-solid fa-bed"></i> Phòng ' + esc(r.room || "?") +
                        ' &nbsp;•&nbsp; <i class="fa-regular fa-clock"></i> ' + esc(r.created) + '</span>' +
                    '</div></div></td>' +
                    '<td><span class="prio-badge ' + p.cls + '">' + p.text + '</span></td>' +
                    '<td>' + staffCell + '</td>' +
                    '<td><span class="status-pill ' + st.cls + '"><i class="fa-solid fa-circle"></i> ' + st.text + '</span></td>' +
                    '<td><div class="table-actions" style="display:flex; gap:8px;">' + actions + '</div></td>';
                tbody.appendChild(tr);
            });

            document.getElementById("reqPaginationInfo").innerText =
                "Hiển thị " + (start + 1) + "-" + end + " trong số " + total + " yêu cầu";
            renderReqPagination(totalPages);
        }

        function filterRequests() {
            const q = document.getElementById("reqSearch").value.toLowerCase().trim();
            const prio = document.getElementById("priorityFilter").value;
            const staffSel = document.getElementById("staffFilter").value;
            const status = document.getElementById("reqStatusFilter").value;

            filteredReqs = requests.filter(r => {
                const mQ = r.room.toLowerCase().includes(q);
                const mP = (prio === "all") || (r.priority === prio);
                const mS = (status === "all") || (r.status === status);
                let mStaff = true;
                if (staffSel === "unassigned") mStaff = (r.staffId === null);
                else if (staffSel !== "all") mStaff = (r.staffId === parseInt(staffSel));
                return mQ && mP && mS && mStaff;
            });
            reqPage = 1;
            renderRequests();
        }

        // ---------- Staff table ----------
        function renderStaff() {
            const tbody = document.getElementById("staffTableBody");
            tbody.innerHTML = "";
            if (staff.length === 0) {
                tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding:40px; color:var(--text-muted);">Chưa có nhân viên buồng phòng</td></tr>';
                return;
            }
            staff.forEach(s => {
                const ws = STAFF_STATUS[s.status] || STAFF_STATUS.Offline;
                const initials = s.name.trim().split(/\s+/).slice(-2).map(w => w[0]).join("").toUpperCase();
                const tr = document.createElement("tr");
                tr.style.cursor = "pointer";
                tr.onclick = () => openStaffDetail(s.id);
                tr.innerHTML =
                    '<td><div class="service-name-cell"><div class="staff-avatar-sm">' + esc(initials) + '</div>' +
                        '<div><span class="service-title">' + esc(s.name) + '</span>' +
                        '<span class="request-sub">' + esc(s.email) + '</span></div></div></td>' +
                    '<td><span class="wk-badge ' + ws.cls + '"><i class="fa-solid fa-circle"></i> ' + ws.text + '</span></td>' +
                    '<td><span style="font-weight:600;">' + s.active + '</span></td>' +
                    '<td><span style="font-weight:700; color:var(--brand-blue);">' + s.today + '</span></td>' +
                    '<td><span style="font-weight:600;">' + s.month + ' việc</span></td>';
                tbody.appendChild(tr);
            });
        }

        // ---------- Assign modal ----------
        function openAssignModal(requestId) {
            const r = requests.find(x => x.id === requestId);
            document.getElementById("assignRequestId").value = requestId;
            document.getElementById("assignContext").innerText =
                r ? ('Yêu cầu: "' + r.title + '" — Phòng ' + (r.room || "?")) : "";
            const sel = document.getElementById("assignStaffId");
            const hint = document.getElementById("noActiveStaffHint");
            const hasActive = sel.options.length > 0;
            sel.style.display = hasActive ? "block" : "none";
            hint.style.display = hasActive ? "none" : "block";
            document.querySelector("#assignForm .btn-modal-submit").disabled = !hasActive;
            document.getElementById("assignModal").style.display = "flex";
        }
        function closeAssignModal() { document.getElementById("assignModal").style.display = "none"; }

        // ---------- Status change ----------
        function changeStatus(requestId, status) {
            const msg = status === "Completed"
                ? "Đánh dấu yêu cầu này là ĐÃ HOÀN THÀNH?"
                : "Bạn có chắc muốn HUỶ yêu cầu này?";
            if (!confirm(msg)) return;
            document.getElementById("statusRequestId").value = requestId;
            document.getElementById("statusValue").value = status;
            document.getElementById("statusForm").submit();
        }

        // ---------- Staff detail modal ----------
        function openStaffDetail(staffId) {
            const s = staff.find(x => x.id === staffId);
            if (!s) return;
            const ws = STAFF_STATUS[s.status] || STAFF_STATUS.Offline;
            const initials = s.name.trim().split(/\s+/).slice(-2).map(w => w[0]).join("").toUpperCase();
            document.getElementById("staffAvatar").innerText = initials;
            document.getElementById("staffName").innerText = s.name;
            document.getElementById("staffEmail").innerText = s.email;
            document.getElementById("staffStatusBadge").innerHTML =
                '<span class="wk-badge ' + ws.cls + '"><i class="fa-solid fa-circle"></i> ' + ws.text + '</span>';
            document.getElementById("staffToday").innerText = s.today;
            document.getElementById("staffMonth").innerText = s.month;
            document.getElementById("staffActive").innerText = s.active;

            const list = document.getElementById("staffTaskList");
            list.innerHTML = "";
            const tasks = requests.filter(r => r.staffId === staffId && r.status === "InProgress");
            if (tasks.length === 0) {
                list.innerHTML = '<li style="color:var(--text-muted); font-style:italic;">Không có việc đang thực hiện.</li>';
            } else {
                tasks.forEach(t => {
                    const p = PRIORITY[t.priority] || PRIORITY.Medium;
                    const li = document.createElement("li");
                    li.innerHTML = '<span class="prio-badge ' + p.cls + '">' + p.text + '</span> ' +
                        esc(t.title) + ' <span style="color:var(--text-muted);">— Phòng ' + esc(t.room || "?") + '</span>';
                    list.appendChild(li);
                });
            }
            document.getElementById("staffModal").style.display = "flex";
        }
        function closeStaffModal() { document.getElementById("staffModal").style.display = "none"; }

        // Đóng modal khi bấm nền tối
        document.querySelectorAll(".modal-overlay").forEach(ov => {
            ov.addEventListener("click", e => { if (e.target === ov) ov.style.display = "none"; });
        });

        // Init
        window.addEventListener("load", function() {
            filterRequests();
            renderStaff();
        });
    </script>

</body>
</html>
