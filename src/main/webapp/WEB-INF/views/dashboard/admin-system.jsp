<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
    Bảng điều khiển hệ thống của Admin (UC 2.7.4 - View System Dashboard).
    Hiển thị KPI tài khoản, đặt phòng, doanh thu và hoạt động gần đây.
    @author QuyPQ
--%>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=3" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=5" />
<fmt:setLocale value="vi_VN" />

<body class="dashboard-body">

    <div class="dashboard-layout">

        <!-- SIDEBAR -->
        <c:set var="activePage" value="system-dashboard" scope="request" />
        <jsp:include page="../admin/includes/sidebar.jsp" />

        <!-- MAIN DASHBOARD CONTENT -->
        <div class="dashboard-main">

            <!-- TOP HEADER BAR -->
            <header class="main-topbar">
                <div class="breadcrumb">
                    <span>Quản trị viên</span>
                    <span class="separator">&gt;</span>
                    <span class="current">Bảng điều khiển hệ thống</span>
                </div>

                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </a>
            </header>

            <!-- DASHBOARD WORKSPACE -->
            <main class="workspace-content">

                <div class="content-header-row">
                    <div>
                        <h1>Bảng điều khiển hệ thống</h1>
                        <p>Giám sát tổng quan hệ thống: tài khoản, người dùng, đặt phòng, doanh thu và hoạt động gần đây.</p>
                    </div>
                </div>

                <!-- BỘ LỌC KHOẢNG THỜI GIAN BÁO CÁO (AF-2) -->
                <div class="filter-card">
                    <form method="get" action="${pageContext.request.contextPath}/admin/system-dashboard" class="date-filter-form">
                        <div class="date-field">
                            <label for="fromDate">Từ ngày</label>
                            <input type="date" id="fromDate" name="fromDate" value="${stats.fromDate}" />
                        </div>
                        <div class="date-field">
                            <label for="toDate">Đến ngày</label>
                            <input type="date" id="toDate" name="toDate" value="${stats.toDate}" />
                        </div>
                        <button type="submit" class="btn-add-service" style="height: 40px;">
                            <i class="fa-solid fa-filter"></i> Áp dụng
                        </button>
                        <div class="quick-ranges">
                            <button type="button" class="btn-quick" onclick="setQuickRange(7)">7 ngày</button>
                            <button type="button" class="btn-quick" onclick="setQuickRange(30)">30 ngày</button>
                            <button type="button" class="btn-quick" onclick="setQuickRange(90)">90 ngày</button>
                        </div>
                    </form>
                </div>

                <!-- THẺ KPI TỔNG QUAN -->
                <div class="stat-grid">
                    <div class="stat-card">
                        <div class="stat-icon icon-bookings"><i class="fa-solid fa-users"></i></div>
                        <div class="stat-body">
                            <span class="stat-label">Tổng tài khoản</span>
                            <span class="stat-value">
                                <fmt:formatNumber value="${stats.totalAccounts}" type="number" />
                            </span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon icon-checkin"><i class="fa-solid fa-user-check"></i></div>
                        <div class="stat-body">
                            <span class="stat-label">Đang hoạt động</span>
                            <span class="stat-value">
                                <fmt:formatNumber value="${stats.activeAccounts}" type="number" />
                                <c:if test="${stats.lockedAccounts > 0}">
                                    <span style="font-size: 13px; font-weight: 500; color: var(--text-muted);">
                                        / ${stats.lockedAccounts} khóa
                                    </span>
                                </c:if>
                            </span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon icon-occupancy"><i class="fa-solid fa-calendar-check"></i></div>
                        <div class="stat-body">
                            <span class="stat-label">Lượt đặt phòng (trong kỳ)</span>
                            <span class="stat-value">
                                <fmt:formatNumber value="${stats.totalBookings}" type="number" />
                            </span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon icon-revenue"><i class="fa-solid fa-sack-dollar"></i></div>
                        <div class="stat-body">
                            <span class="stat-label">Tổng doanh thu (trong kỳ)</span>
                            <span class="stat-value">
                                <fmt:formatNumber value="${stats.totalRevenue}" type="number" maxFractionDigits="0" /> đ
                            </span>
                        </div>
                    </div>
                </div>

                <!-- BIỂU ĐỒ: DOANH THU THEO NGÀY & TRẠNG THÁI ĐẶT PHÒNG -->
                <div class="chart-grid">
                    <div class="chart-card">
                        <div class="chart-card-header">
                            <h3>Doanh thu theo ngày</h3>
                        </div>
                        <div class="chart-canvas-wrap">
                            <canvas id="revenueChart"></canvas>
                        </div>
                    </div>
                    <div class="chart-card">
                        <div class="chart-card-header">
                            <h3>Phân bổ trạng thái đặt phòng</h3>
                        </div>
                        <div class="chart-canvas-wrap">
                            <c:choose>
                                <c:when test="${empty stats.statusLabels}">
                                    <div class="empty-chart-note">Không có dữ liệu đặt phòng trong khoảng đã chọn.</div>
                                </c:when>
                                <c:otherwise>
                                    <canvas id="statusChart"></canvas>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- BIỂU ĐỒ: TÀI KHOẢN THEO VAI TRÒ & HOẠT ĐỘNG GẦN ĐÂY -->
                <div class="chart-grid" style="margin-top: 24px;">
                    <div class="chart-card">
                        <div class="chart-card-header">
                            <h3>Tài khoản theo vai trò</h3>
                        </div>
                        <div class="chart-canvas-wrap">
                            <c:choose>
                                <c:when test="${empty stats.roleLabels}">
                                    <div class="empty-chart-note">Chưa có tài khoản nào trong hệ thống.</div>
                                </c:when>
                                <c:otherwise>
                                    <canvas id="roleChart"></canvas>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="chart-card">
                        <div class="chart-card-header">
                            <h3>Hoạt động gần đây</h3>
                        </div>
                        <div style="padding: 4px 4px 8px;">
                            <c:choose>
                                <c:when test="${empty stats.recentActivities}">
                                    <div class="empty-chart-note">Chưa có hoạt động đặt phòng nào.</div>
                                </c:when>
                                <c:otherwise>
                                    <table class="services-table-element">
                                        <thead>
                                            <tr>
                                                <th>Mã</th>
                                                <th>Khách hàng</th>
                                                <th>Trạng thái</th>
                                                <th style="text-align: right;">Giá trị</th>
                                                <th>Thời gian</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="act" items="${stats.recentActivities}">
                                                <tr>
                                                    <td style="font-weight: 700; color: var(--text-navy);">#${act.bookingId}</td>
                                                    <td>${act.customerName}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${act.status eq 'Confirmed'}">
                                                                <span class="status-pill status-available"><i class="fa-solid fa-circle-check"></i> Đã xác nhận</span>
                                                            </c:when>
                                                            <c:when test="${act.status eq 'CheckedIn'}">
                                                                <span class="status-pill status-available"><i class="fa-solid fa-right-to-bracket"></i> Đã nhận phòng</span>
                                                            </c:when>
                                                            <c:when test="${act.status eq 'CheckedOut'}">
                                                                <span class="status-pill status-maintenance"><i class="fa-solid fa-right-from-bracket"></i> Đã trả phòng</span>
                                                            </c:when>
                                                            <c:when test="${act.status eq 'Cancelled'}">
                                                                <span class="status-pill status-maintenance"><i class="fa-solid fa-ban"></i> Đã hủy</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="status-pill status-maintenance"><i class="fa-solid fa-clock"></i> ${act.status}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td style="text-align: right; font-weight: 600;">
                                                        <fmt:formatNumber value="${act.totalAmount}" type="number" maxFractionDigits="0" /> đ
                                                    </td>
                                                    <td>
                                                        <fmt:formatDate value="${act.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

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

    <%-- BIỂU ĐỒ (Chart.js) --%>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
    <script>
        // ----- Dữ liệu từ server (đổ qua JSTL) -----
        const dayLabels = [<c:forEach var="l" items="${stats.dayLabels}" varStatus="st">"${l}"${!st.last ? ',' : ''}</c:forEach>];
        const dayRevenue = [<c:forEach var="v" items="${stats.dayRevenue}" varStatus="st">${v}${!st.last ? ',' : ''}</c:forEach>];

        const statusLabels = [<c:forEach var="l" items="${stats.statusLabels}" varStatus="st">"${l}"${!st.last ? ',' : ''}</c:forEach>];
        const statusCounts = [<c:forEach var="v" items="${stats.statusCounts}" varStatus="st">${v}${!st.last ? ',' : ''}</c:forEach>];

        const roleLabels = [<c:forEach var="l" items="${stats.roleLabels}" varStatus="st">"${l}"${!st.last ? ',' : ''}</c:forEach>];
        const roleCounts = [<c:forEach var="v" items="${stats.roleCounts}" varStatus="st">${v}${!st.last ? ',' : ''}</c:forEach>];

        const vnCurrency = new Intl.NumberFormat('vi-VN');
        const palette = ['#0056b3', '#10b981', '#f59e0b', '#8b5cf6', '#ef4444', '#06b6d4'];

        // ----- Bộ lọc nhanh theo ngày -----
        function setQuickRange(days) {
            const to = new Date();
            const from = new Date();
            from.setDate(from.getDate() - (days - 1));
            const fmt = d => d.toISOString().slice(0, 10);
            document.getElementById("fromDate").value = fmt(from);
            document.getElementById("toDate").value = fmt(to);
            document.querySelector(".date-filter-form").submit();
        }

        // ----- Doanh thu theo ngày (CỘT) -----
        new Chart(document.getElementById("revenueChart"), {
            type: 'bar',
            data: {
                labels: dayLabels,
                datasets: [{
                    label: 'Doanh thu (đ)',
                    data: dayRevenue,
                    backgroundColor: 'rgba(0, 86, 179, 0.7)',
                    borderRadius: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: ctx => ' Doanh thu: ' + vnCurrency.format(ctx.parsed.y) + ' đ'
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: { callback: v => vnCurrency.format(v) }
                    }
                }
            }
        });

        // ----- Phân bổ trạng thái đặt phòng (THANH NGANG) -----
        if (statusLabels.length > 0) {
            new Chart(document.getElementById("statusChart"), {
                type: 'bar',
                data: {
                    labels: statusLabels,
                    datasets: [{
                        label: 'Số đơn',
                        data: statusCounts,
                        backgroundColor: '#0056b3',
                        borderRadius: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    indexAxis: 'y',
                    plugins: { legend: { display: false } },
                    scales: { x: { beginAtZero: true, ticks: { precision: 0 } } }
                }
            });
        }

        // ----- Tài khoản theo vai trò (TRÒN) -----
        if (roleLabels.length > 0) {
            new Chart(document.getElementById("roleChart"), {
                type: 'doughnut',
                data: {
                    labels: roleLabels,
                    datasets: [{
                        data: roleCounts,
                        backgroundColor: palette,
                        borderWidth: 2,
                        borderColor: '#ffffff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { position: 'bottom' },
                        tooltip: {
                            callbacks: {
                                label: ctx => ' ' + ctx.label + ': ' + ctx.parsed + ' tài khoản'
                            }
                        }
                    }
                }
            });
        }
    </script>

</body>
</html>
