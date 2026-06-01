<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=2" />
<fmt:setLocale value="vi_VN" />

<body class="dashboard-body">

    <div class="dashboard-layout">

        <!-- SIDEBAR -->
        <aside class="dashboard-sidebar">
            <div class="sidebar-brand">
                <i class="fa-solid fa-hotel"></i> <span>HotelOps</span>
            </div>
            <ul class="sidebar-menu">
                <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/dashboard?tab=overview"><i class="fa-solid fa-table-cells-large"></i> <span>Tổng quan</span></a></li>
                <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/dashboard?tab=roomtypes"><i class="fa-solid fa-door-open"></i> <span>Loại phòng</span></a></li>
                <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/dashboard?tab=rooms"><i class="fa-solid fa-bed"></i> <span>Phòng</span></a></li>
                <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/dashboard?tab=services"><i class="fa-solid fa-bell-concierge"></i> <span>Dịch vụ</span></a></li>
                <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/requests"><i class="fa-solid fa-headset"></i> <span>Yêu cầu &amp; Nhân viên</span></a></li>
                <li class="menu-item active"><a href="${pageContext.request.contextPath}/manager/invoices"><i class="fa-solid fa-file-invoice-dollar"></i> <span>Hóa đơn</span></a></li>
                <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/dashboard?tab=customers"><i class="fa-solid fa-user-group"></i> <span>Khách hàng</span></a></li>
            </ul>
            <div class="sidebar-footer">
                <div class="user-profile-card">
                    <div class="profile-avatar">AM</div>
                    <div class="profile-info">
                        <span class="profile-name">${not empty sessionScope.user ? sessionScope.user : 'Hotel Manager'}</span>
                        <span class="profile-role">Hotel Manager</span>
                    </div>
                </div>
            </div>
        </aside>

        <div class="dashboard-main">
            <header class="main-topbar">
                <div class="breadcrumb">
                    <span>Quản trị</span>
                    <span class="separator">&gt;</span>
                    <span class="current">Hóa đơn</span>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </a>
            </header>

            <main class="workspace-content">

                <div class="content-header-row">
                    <div>
                        <h1>Quản lý hóa đơn</h1>
                        <p>Theo dõi công nợ, xử lý phụ phí và hoàn tiền cho khách hàng.</p>
                    </div>
                </div>

                <!-- KPI -->
                <div class="stat-grid" style="grid-template-columns: repeat(2, 1fr);">
                    <div class="stat-card">
                        <div class="stat-icon icon-pending"><i class="fa-solid fa-file-invoice"></i></div>
                        <div class="stat-body">
                            <span class="stat-label">Tổng tiền chưa thanh toán</span>
                            <span class="stat-value"><fmt:formatNumber value="${unpaidTotal}" type="number" maxFractionDigits="0" /> đ</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon icon-refund"><i class="fa-solid fa-rotate-left"></i></div>
                        <div class="stat-body">
                            <span class="stat-label">Tổng tiền chờ hoàn</span>
                            <span class="stat-value"><fmt:formatNumber value="${refundingTotal}" type="number" maxFractionDigits="0" /> đ</span>
                        </div>
                    </div>
                </div>

                <!-- Hidden data -->
                <div id="invoiceDataStorage" style="display:none;">
                    <c:forEach var="inv" items="${invoices}">
                        <div class="invoice-data-item"
                             data-id="${inv.invoiceId}"
                             data-customer="<c:out value='${inv.customerName}' />"
                             data-room="<c:out value='${inv.roomNumber}' />"
                             data-status="<c:out value='${inv.status}' />"
                             data-total="${inv.totalAmount}"
                             data-created="<fmt:formatDate value='${inv.createdAt}' pattern='dd/MM/yyyy HH:mm' />">
                        </div>
                    </c:forEach>
                </div>

                <div class="table-card">
                    <div class="table-filter-bar">
                        <div class="search-wrapper" style="max-width:420px;">
                            <i class="fa-solid fa-magnifying-glass"></i>
                            <input type="text" id="invoiceSearch" class="input-search-service"
                                   placeholder="Tìm theo mã HĐ, tên khách hoặc số phòng..." onkeyup="filterInvoices()" />
                        </div>
                        <select id="invStatusFilter" class="status-select" onchange="filterInvoices()">
                            <option value="all">Tất cả trạng thái</option>
                            <option value="Pending">Chưa thanh toán</option>
                            <option value="Paid">Đã thanh toán</option>
                            <option value="Refunding">Chờ hoàn</option>
                            <option value="Refunded">Đã hoàn</option>
                            <option value="Cancelled">Đã huỷ</option>
                        </select>
                    </div>

                    <table class="services-table-element">
                        <thead>
                            <tr>
                                <th style="width:14%">Mã HĐ</th>
                                <th style="width:30%">Khách hàng</th>
                                <th style="width:18%">Ngày tạo</th>
                                <th style="width:16%">Tổng tiền</th>
                                <th style="width:12%">Trạng thái</th>
                                <th style="width:10%">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody id="invoicesTableBody"></tbody>
                    </table>

                    <div class="table-pagination-bar">
                        <div class="pagination-info" id="invPaginationInfo"></div>
                        <div class="pagination-controls" id="invPaginationControls"></div>
                    </div>
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

    <script>
        const ctx = "${pageContext.request.contextPath}";
        const invoices = [];
        document.querySelectorAll(".invoice-data-item").forEach(el => {
            invoices.push({
                id: parseInt(el.getAttribute("data-id")),
                customer: el.getAttribute("data-customer") || "",
                room: el.getAttribute("data-room") || "",
                status: el.getAttribute("data-status") || "Pending",
                total: parseFloat(el.getAttribute("data-total")) || 0,
                created: el.getAttribute("data-created") || ""
            });
        });

        const INV_STATUS = {
            Pending:   { text: "CHƯA TT",   cls: "inv-pending" },
            Paid:      { text: "ĐÃ TT",     cls: "inv-paid" },
            Refunding: { text: "CHỜ HOÀN",  cls: "inv-refunding" },
            Refunded:  { text: "ĐÃ HOÀN",   cls: "inv-refunded" },
            Cancelled: { text: "ĐÃ HUỶ",    cls: "inv-cancelled" }
        };
        const vn = new Intl.NumberFormat('vi-VN');
        function esc(s){ return String(s).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;"); }

        let invPage = 1;
        const invPageSize = 8;
        let filteredInv = [];

        function renderInvPagination(totalPages) {
            const c = document.getElementById("invPaginationControls");
            c.innerHTML = "";
            const prev = document.createElement("button");
            prev.type = "button";
            prev.className = "btn-page" + (invPage === 1 || totalPages === 0 ? " disabled" : "");
            prev.innerHTML = '<i class="fa-solid fa-chevron-left"></i>';
            if (invPage > 1 && totalPages > 0) prev.onclick = () => { invPage--; renderInvoices(); };
            c.appendChild(prev);
            for (let i = 1; i <= totalPages; i++) {
                const b = document.createElement("button");
                b.type = "button";
                b.className = "btn-page" + (i === invPage ? " active" : "");
                b.innerText = i;
                b.onclick = () => { invPage = i; renderInvoices(); };
                c.appendChild(b);
            }
            const next = document.createElement("button");
            next.type = "button";
            next.className = "btn-page" + (invPage === totalPages || totalPages === 0 ? " disabled" : "");
            next.innerHTML = '<i class="fa-solid fa-chevron-right"></i>';
            if (invPage < totalPages && totalPages > 0) next.onclick = () => { invPage++; renderInvoices(); };
            c.appendChild(next);
        }

        function renderInvoices() {
            const tbody = document.getElementById("invoicesTableBody");
            tbody.innerHTML = "";
            const total = filteredInv.length;
            const totalPages = Math.ceil(total / invPageSize);
            if (invPage > totalPages && totalPages > 0) invPage = totalPages;

            if (total === 0) {
                tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; padding:40px; color:var(--text-muted);">' +
                    '<i class="fa-solid fa-folder-open" style="font-size:32px; margin-bottom:12px; display:block;"></i>' +
                    'Không tìm thấy hóa đơn nào phù hợp</td></tr>';
                document.getElementById("invPaginationInfo").innerText = "Hiển thị 0 hóa đơn";
                renderInvPagination(0);
                return;
            }

            const start = (invPage - 1) * invPageSize;
            const end = Math.min(start + invPageSize, total);
            filteredInv.slice(start, end).forEach(inv => {
                const st = INV_STATUS[inv.status] || INV_STATUS.Pending;
                const code = "HD-" + String(inv.id).padStart(4, "0");
                const tr = document.createElement("tr");
                tr.innerHTML =
                    '<td><span style="font-weight:700; color:var(--brand-blue);">' + code + '</span></td>' +
                    '<td><div class="service-name-cell"><div>' +
                        '<span class="service-title">' + esc(inv.customer) + '</span>' +
                        '<span class="request-sub"><i class="fa-solid fa-bed"></i> Phòng ' + esc(inv.room || "?") + '</span>' +
                    '</div></div></td>' +
                    '<td><span style="color:#475569;">' + esc(inv.created) + '</span></td>' +
                    '<td><span style="font-weight:700; color:var(--text-navy);">' + vn.format(inv.total) + ' đ</span></td>' +
                    '<td><span class="inv-badge ' + st.cls + '">' + st.text + '</span></td>' +
                    '<td><a class="btn-detail" href="' + ctx + '/manager/invoices?id=' + inv.id + '">' +
                        '<i class="fa-solid fa-eye"></i> Chi tiết</a></td>';
                tbody.appendChild(tr);
            });

            document.getElementById("invPaginationInfo").innerText =
                "Hiển thị " + (start + 1) + "-" + end + " trong số " + total + " hóa đơn";
            renderInvPagination(totalPages);
        }

        function filterInvoices() {
            const q = document.getElementById("invoiceSearch").value.toLowerCase().trim();
            const status = document.getElementById("invStatusFilter").value;
            filteredInv = invoices.filter(inv => {
                const code = ("hd-" + String(inv.id).padStart(4, "0"));
                const mQ = (q === "") ||
                           code.includes(q) || String(inv.id).includes(q) ||
                           inv.customer.toLowerCase().includes(q) ||
                           inv.room.toLowerCase().includes(q);
                const mS = (status === "all") || (inv.status === status);
                return mQ && mS;
            });
            invPage = 1;
            renderInvoices();
        }

        window.addEventListener("load", filterInvoices);
    </script>

</body>
</html>
