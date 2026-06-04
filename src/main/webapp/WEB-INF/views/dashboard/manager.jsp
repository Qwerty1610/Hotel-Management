<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=3" />
<fmt:setLocale value="vi_VN" />

<body class="dashboard-body">

    <!-- Active Tab Resolution -->
    <c:set var="currentTab" value="${param.tab != null ? param.tab : 'overview'}" />

    <div class="dashboard-layout">
        
        <!-- SIDEBAR -->
        <c:set var="activePage" value="${currentTab}" scope="request" />
        <jsp:include page="../manager/includes/sidebar.jsp" />
        
        <!-- MAIN DASHBOARD CONTENT -->
        <div class="dashboard-main">
            
            <!-- TOP HEADER BAR -->
            <header class="main-topbar">
                <div class="breadcrumb">
                    <span>Quản trị</span>
                    <span class="separator">&gt;</span>
                    <span class="current">
                        <c:choose>
                            <c:when test="${currentTab eq 'overview'}">Tổng quan</c:when>
                            <c:when test="${currentTab eq 'customers'}">Khách hàng</c:when>
                            <c:otherwise>Tổng quan</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </a>
            </header>
            
            <!-- DYNAMIC TAB WORKSPACE -->
            <main class="workspace-content">
                <c:choose>
                    
                    <%-- 1. OVERVIEW TAB - Theo dõi doanh thu & công suất phòng --%>
                    <c:when test="${currentTab eq 'overview'}">

                        <div class="content-header-row">
                            <div>
                                <h1>Tổng quan vận hành</h1>
                                <p>Theo dõi doanh thu và công suất phòng của khách sạn theo khoảng thời gian.</p>
                            </div>
                        </div>

                        <!-- BỘ LỌC THEO NGÀY -->
                        <div class="filter-card">
                            <form method="get" action="${pageContext.request.contextPath}/manager/dashboard" class="date-filter-form">
                                <input type="hidden" name="tab" value="overview" />
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

                        <!-- THẺ KPI -->
                        <div class="stat-grid">
                            <div class="stat-card">
                                <div class="stat-icon icon-revenue"><i class="fa-solid fa-sack-dollar"></i></div>
                                <div class="stat-body">
                                    <span class="stat-label">Tổng doanh thu</span>
                                    <span class="stat-value">
                                        <fmt:formatNumber value="${stats.totalRevenue}" type="number" maxFractionDigits="0" /> đ
                                    </span>
                                </div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-icon icon-occupancy"><i class="fa-solid fa-chart-pie"></i></div>
                                <div class="stat-body">
                                    <span class="stat-label">Công suất phòng TB</span>
                                    <span class="stat-value">
                                        <fmt:formatNumber value="${stats.avgOccupancy}" maxFractionDigits="1" />%
                                    </span>
                                </div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-icon icon-bookings"><i class="fa-solid fa-calendar-check"></i></div>
                                <div class="stat-body">
                                    <span class="stat-label">Lượt đặt ghi nhận</span>
                                    <span class="stat-value">
                                        <fmt:formatNumber value="${stats.totalBookings}" type="number" />
                                    </span>
                                </div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-icon icon-nights"><i class="fa-solid fa-bed"></i></div>
                                <div class="stat-body">
                                    <span class="stat-label">Số đêm-phòng đã bán</span>
                                    <span class="stat-value">
                                        <fmt:formatNumber value="${stats.roomNightsSold}" type="number" />
                                        <span class="stat-suffix">/ ${stats.totalRooms} phòng</span>
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- BIỂU ĐỒ DOANH THU & CÔNG SUẤT THEO NGÀY -->
                        <div class="chart-card chart-full">
                            <div class="chart-card-header">
                                <h3>Doanh thu &amp; công suất phòng theo ngày</h3>
                            </div>
                            <div class="chart-canvas-wrap">
                                <canvas id="revenueOccupancyChart"></canvas>
                            </div>
                        </div>

                        <!-- BIỂU ĐỒ PHÂN TÍCH -->
                        <div class="chart-grid">
                            <div class="chart-card">
                                <div class="chart-card-header">
                                    <h3>Doanh thu theo loại phòng</h3>
                                </div>
                                <div class="chart-canvas-wrap">
                                    <canvas id="roomTypeChart"></canvas>
                                </div>
                            </div>
                            <div class="chart-card">
                                <div class="chart-card-header">
                                    <h3>Phân bổ trạng thái đặt phòng</h3>
                                </div>
                                <div class="chart-canvas-wrap">
                                    <canvas id="statusChart"></canvas>
                                </div>
                            </div>
                        </div>

                    </c:when>
                    
                    <%-- 4. CUSTOMERS TAB (PLACEHOLDER) --%>
                    <c:when test="${currentTab eq 'customers'}">
                        <div style="padding: 40px; text-align: center; color: var(--text-muted);">
                            <i class="fa-solid fa-user-group" style="font-size: 48px; margin-bottom: 16px;"></i>
                            <h3>Tính năng Quản lý Khách hàng đang được phát triển</h3>
                        </div>
                    </c:when>
                    
                </c:choose>
            </main>
            
            <!-- DASHBOARD FOOTER -->
            <footer class="dashboard-footer">
                <span>© 2024 HotelOps Luxury Management. Hệ thống quản trị nội bộ.</span>
                <div class="footer-links-row">
                    <a href="#">Hỗ trợ</a>
                    <a href="#">Bảo mật</a>
                    <a href="#">Điều khoản</a>
                </div>
            </footer>
            
        </div>
        
    </div>

    <%-- OVERVIEW TAB: biểu đồ doanh thu & công suất (Chart.js) --%>
    <c:if test="${currentTab eq 'overview'}">
        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
        <script>
            // ----- Dữ liệu từ server (đổ qua JSTL) -----
            const dayLabels = [<c:forEach var="l" items="${stats.dayLabels}" varStatus="st">"${l}"${!st.last ? ',' : ''}</c:forEach>];
            const dayRevenue = [<c:forEach var="v" items="${stats.dayRevenue}" varStatus="st">${v}${!st.last ? ',' : ''}</c:forEach>];
            const dayOccupancy = [<c:forEach var="v" items="${stats.dayOccupancy}" varStatus="st">${v}${!st.last ? ',' : ''}</c:forEach>];

            const roomTypeLabels = [<c:forEach var="l" items="${stats.roomTypeLabels}" varStatus="st">"${l}"${!st.last ? ',' : ''}</c:forEach>];
            const roomTypeRevenue = [<c:forEach var="v" items="${stats.roomTypeRevenue}" varStatus="st">${v}${!st.last ? ',' : ''}</c:forEach>];

            const statusLabels = [<c:forEach var="l" items="${stats.statusLabels}" varStatus="st">"${l}"${!st.last ? ',' : ''}</c:forEach>];
            const statusCounts = [<c:forEach var="v" items="${stats.statusCounts}" varStatus="st">${v}${!st.last ? ',' : ''}</c:forEach>];

            const vnCurrency = new Intl.NumberFormat('vi-VN');

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

            // ----- Biểu đồ doanh thu & công suất theo ngày -----
            new Chart(document.getElementById("revenueOccupancyChart"), {
                data: {
                    labels: dayLabels,
                    datasets: [
                        {
                            type: 'bar',
                            label: 'Doanh thu (đ)',
                            data: dayRevenue,
                            backgroundColor: 'rgba(0, 86, 179, 0.7)',
                            borderRadius: 4,
                            yAxisID: 'yRevenue',
                            order: 2
                        },
                        {
                            type: 'line',
                            label: 'Công suất (%)',
                            data: dayOccupancy,
                            borderColor: '#10b981',
                            backgroundColor: 'rgba(16, 185, 129, 0.15)',
                            borderWidth: 2,
                            tension: 0.35,
                            fill: true,
                            yAxisID: 'yOccupancy',
                            order: 1
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    interaction: { mode: 'index', intersect: false },
                    plugins: {
                        legend: { position: 'top' },
                        tooltip: {
                            callbacks: {
                                label: function(ctx) {
                                    if (ctx.dataset.yAxisID === 'yOccupancy') {
                                        return ' Công suất: ' + ctx.parsed.y + '%';
                                    }
                                    return ' Doanh thu: ' + vnCurrency.format(ctx.parsed.y) + ' đ';
                                }
                            }
                        }
                    },
                    scales: {
                        yRevenue: {
                            position: 'left',
                            beginAtZero: true,
                            title: { display: true, text: 'Doanh thu (đ)' },
                            ticks: { callback: v => vnCurrency.format(v) }
                        },
                        yOccupancy: {
                            position: 'right',
                            beginAtZero: true,
                            max: 100,
                            title: { display: true, text: 'Công suất (%)' },
                            grid: { drawOnChartArea: false },
                            ticks: { callback: v => v + '%' }
                        }
                    }
                }
            });

            // ----- Doanh thu theo loại phòng -----
            const palette = ['#0056b3', '#10b981', '#f59e0b', '#8b5cf6', '#ef4444', '#06b6d4'];
            if (roomTypeLabels.length > 0) {
                new Chart(document.getElementById("roomTypeChart"), {
                    type: 'doughnut',
                    data: {
                        labels: roomTypeLabels,
                        datasets: [{
                            data: roomTypeRevenue,
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
                                    label: ctx => ' ' + ctx.label + ': ' + vnCurrency.format(ctx.parsed) + ' đ'
                                }
                            }
                        }
                    }
                });
            }

            // ----- Phân bổ trạng thái đặt phòng -----
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
        </script>
    </c:if>

</body>
</html>
