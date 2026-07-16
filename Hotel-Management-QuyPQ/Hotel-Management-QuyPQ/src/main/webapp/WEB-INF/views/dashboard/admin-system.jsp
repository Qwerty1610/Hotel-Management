<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
    Bảng điều khiển hệ thống của Admin (UC 2.7.4 - View System Dashboard).
    - 4 thẻ KPI bấm được để mở danh sách chi tiết (render backend, 20 dòng/trang).
    - Thẻ "Lượt đặt phòng" & "Tổng doanh thu" có bộ lọc kỳ riêng (tháng/quý/năm/tùy chỉnh).
    - 4 biểu đồ, mỗi biểu đồ một khoảng lọc riêng; chuỗi thời gian tự gom nhóm
      ngày → tháng → quý khi khoảng lọc rộng để không bị chi chít.
    @author QuyPQ
--%>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=3" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=6" />
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
                        <p>Giám sát tổng quan hệ thống: tài khoản, đặt phòng và doanh thu. Bấm vào một thẻ để xem danh sách chi tiết.</p>
                    </div>
                </div>

                <c:set var="ctx" value="${pageContext.request.contextPath}" />
                <c:set var="bp" value="${stats.bookingPeriod}" />
                <c:set var="rp" value="${stats.revenuePeriod}" />

                <!-- ================= THẺ KPI (bấm để xem danh sách) ================= -->
                <div class="stat-grid stat-grid-cards">

                    <!-- Tổng tài khoản -->
                    <div class="stat-card stat-card-col">
                        <a class="stat-main" href="?${baseQuery}view=accounts#detail-panel" title="Xem danh sách tài khoản">
                            <div class="stat-icon icon-bookings"><i class="fa-solid fa-users"></i></div>
                            <div class="stat-body">
                                <span class="stat-label">Tổng tài khoản</span>
                                <span class="stat-value"><fmt:formatNumber value="${stats.totalAccounts}" type="number" /></span>
                            </div>
                            <i class="fa-solid fa-chevron-right stat-open-icon"></i>
                        </a>
                        <div class="stat-foot"><i class="fa-solid fa-globe"></i> Toàn hệ thống</div>
                    </div>

                    <!-- Đang hoạt động -->
                    <div class="stat-card stat-card-col">
                        <a class="stat-main" href="?${baseQuery}view=active#detail-panel" title="Xem tài khoản đang hoạt động">
                            <div class="stat-icon icon-checkin"><i class="fa-solid fa-user-check"></i></div>
                            <div class="stat-body">
                                <span class="stat-label">Đang hoạt động</span>
                                <span class="stat-value">
                                    <fmt:formatNumber value="${stats.activeAccounts}" type="number" />
                                    <c:if test="${stats.lockedAccounts > 0}">
                                        <span class="stat-suffix">/ ${stats.lockedAccounts} khóa</span>
                                    </c:if>
                                </span>
                            </div>
                            <i class="fa-solid fa-chevron-right stat-open-icon"></i>
                        </a>
                        <div class="stat-foot"><i class="fa-solid fa-globe"></i> Toàn hệ thống</div>
                    </div>

                    <!-- Lượt đặt phòng (bộ lọc kỳ riêng) -->
                    <div class="stat-card stat-card-col">
                        <a class="stat-main" href="?${baseQuery}view=bookings#detail-panel" title="Xem danh sách đặt phòng trong kỳ">
                            <div class="stat-icon icon-occupancy"><i class="fa-solid fa-calendar-check"></i></div>
                            <div class="stat-body">
                                <span class="stat-label">Lượt đặt phòng</span>
                                <span class="stat-value"><fmt:formatNumber value="${stats.totalBookings}" type="number" /></span>
                                <span class="stat-period">${bp.label}</span>
                            </div>
                            <i class="fa-solid fa-chevron-right stat-open-icon"></i>
                        </a>
                        <form class="stat-filter" onsubmit="applyFilter(this); return false;">
                            <select name="bkMode" class="stat-filter-select" onchange="applyFilter(this.form)">
                                <option value="month" ${bp.mode eq 'month' ? 'selected' : ''}>Theo tháng</option>
                                <option value="quarter" ${bp.mode eq 'quarter' ? 'selected' : ''}>Theo quý</option>
                                <option value="year" ${bp.mode eq 'year' ? 'selected' : ''}>Theo năm</option>
                                <option value="custom" ${bp.mode eq 'custom' ? 'selected' : ''}>Tùy chỉnh</option>
                            </select>
                            <c:choose>
                                <c:when test="${bp.mode eq 'quarter'}">
                                    <select name="bkQuarter" class="stat-filter-select" onchange="applyFilter(this.form)">
                                        <c:forEach var="opt" items="${quarterOptions}">
                                            <option value="${opt[0]}" ${opt[0] eq bp.quarterValue ? 'selected' : ''}>${opt[1]}</option>
                                        </c:forEach>
                                    </select>
                                </c:when>
                                <c:when test="${bp.mode eq 'year'}">
                                    <select name="bkYear" class="stat-filter-select" onchange="applyFilter(this.form)">
                                        <c:forEach var="y" items="${yearOptions}">
                                            <option value="${y}" ${y eq bp.yearValue ? 'selected' : ''}>Năm ${y}</option>
                                        </c:forEach>
                                    </select>
                                </c:when>
                                <c:when test="${bp.mode eq 'custom'}">
                                    <input type="date" name="bkFrom" class="stat-filter-date" value="${bp.fromValue}" />
                                    <input type="date" name="bkTo" class="stat-filter-date" value="${bp.toValue}" />
                                    <button type="submit" class="stat-filter-apply" title="Áp dụng"><i class="fa-solid fa-check"></i></button>
                                </c:when>
                                <c:otherwise>
                                    <input type="month" name="bkMonth" class="stat-filter-date" value="${bp.monthValue}" onchange="applyFilter(this.form)" />
                                </c:otherwise>
                            </c:choose>
                        </form>
                    </div>

                    <!-- Tổng doanh thu (bộ lọc kỳ riêng) -->
                    <div class="stat-card stat-card-col">
                        <a class="stat-main" href="?${baseQuery}view=revenue#detail-panel" title="Xem các đơn được tính doanh thu trong kỳ">
                            <div class="stat-icon icon-revenue"><i class="fa-solid fa-sack-dollar"></i></div>
                            <div class="stat-body">
                                <span class="stat-label">Tổng doanh thu</span>
                                <span class="stat-value"><fmt:formatNumber value="${stats.totalRevenue}" type="number" maxFractionDigits="0" /> đ</span>
                                <span class="stat-period">${rp.label}</span>
                            </div>
                            <i class="fa-solid fa-chevron-right stat-open-icon"></i>
                        </a>
                        <form class="stat-filter" onsubmit="applyFilter(this); return false;">
                            <select name="rvMode" class="stat-filter-select" onchange="applyFilter(this.form)">
                                <option value="month" ${rp.mode eq 'month' ? 'selected' : ''}>Theo tháng</option>
                                <option value="quarter" ${rp.mode eq 'quarter' ? 'selected' : ''}>Theo quý</option>
                                <option value="year" ${rp.mode eq 'year' ? 'selected' : ''}>Theo năm</option>
                                <option value="custom" ${rp.mode eq 'custom' ? 'selected' : ''}>Tùy chỉnh</option>
                            </select>
                            <c:choose>
                                <c:when test="${rp.mode eq 'quarter'}">
                                    <select name="rvQuarter" class="stat-filter-select" onchange="applyFilter(this.form)">
                                        <c:forEach var="opt" items="${quarterOptions}">
                                            <option value="${opt[0]}" ${opt[0] eq rp.quarterValue ? 'selected' : ''}>${opt[1]}</option>
                                        </c:forEach>
                                    </select>
                                </c:when>
                                <c:when test="${rp.mode eq 'year'}">
                                    <select name="rvYear" class="stat-filter-select" onchange="applyFilter(this.form)">
                                        <c:forEach var="y" items="${yearOptions}">
                                            <option value="${y}" ${y eq rp.yearValue ? 'selected' : ''}>Năm ${y}</option>
                                        </c:forEach>
                                    </select>
                                </c:when>
                                <c:when test="${rp.mode eq 'custom'}">
                                    <input type="date" name="rvFrom" class="stat-filter-date" value="${rp.fromValue}" />
                                    <input type="date" name="rvTo" class="stat-filter-date" value="${rp.toValue}" />
                                    <button type="submit" class="stat-filter-apply" title="Áp dụng"><i class="fa-solid fa-check"></i></button>
                                </c:when>
                                <c:otherwise>
                                    <input type="month" name="rvMonth" class="stat-filter-date" value="${rp.monthValue}" onchange="applyFilter(this.form)" />
                                </c:otherwise>
                            </c:choose>
                        </form>
                    </div>
                </div>

                <!-- ================= DANH SÁCH CHI TIẾT (khi bấm một thẻ KPI) ================= -->
                <c:if test="${not empty stats.detail}">
                    <c:set var="detail" value="${stats.detail}" />
                    <div class="chart-card detail-panel" id="detail-panel">
                        <div class="detail-head">
                            <div>
                                <h3>${detail.title}</h3>
                                <p class="detail-sub">
                                    <c:if test="${not empty detail.subtitle}">Kỳ lọc: <strong>${detail.subtitle}</strong> • </c:if>
                                    Tổng cộng <strong><fmt:formatNumber value="${detail.totalRows}" type="number" /></strong> dòng
                                </p>
                            </div>
                            <a class="detail-close" href="?${baseQuery}" title="Đóng danh sách">
                                <i class="fa-solid fa-xmark"></i>
                            </a>
                        </div>

                        <c:choose>
                            <c:when test="${detail.totalRows == 0}">
                                <div class="empty-chart-note">Không có dữ liệu trong khoảng đã chọn.</div>
                            </c:when>

                            <%-- Danh sách tài khoản --%>
                            <c:when test="${detail.accountView}">
                                <div class="detail-table-wrap">
                                    <table class="services-table-element">
                                        <thead>
                                            <tr>
                                                <th>Mã</th>
                                                <th>Họ tên</th>
                                                <th>Email</th>
                                                <th>Vai trò</th>
                                                <th>Trạng thái</th>
                                                <th>Ngày tạo</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="row" items="${detail.accounts}">
                                                <tr>
                                                    <td style="font-weight: 700; color: var(--text-navy);">#${row.accountId}</td>
                                                    <td><c:out value="${row.fullName}" /></td>
                                                    <td><c:out value="${row.email}" /></td>
                                                    <td><c:out value="${row.roleName}" /></td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${row.active}">
                                                                <span class="status-pill status-available"><i class="fa-solid fa-circle-check"></i> Hoạt động</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="status-pill status-maintenance"><i class="fa-solid fa-lock"></i> Bị khóa</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td><fmt:formatDate value="${row.createdAt}" pattern="dd/MM/yyyy HH:mm" /></td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>

                            <%-- Danh sách đặt phòng / đơn doanh thu --%>
                            <c:otherwise>
                                <div class="detail-table-wrap">
                                    <table class="services-table-element">
                                        <thead>
                                            <tr>
                                                <th>Mã</th>
                                                <th>Khách hàng</th>
                                                <th>Nhận phòng</th>
                                                <th>Trả phòng</th>
                                                <th style="text-align: right;">Tổng tiền</th>
                                                <th>Trạng thái</th>
                                                <th>Ngày tạo</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="row" items="${detail.bookings}">
                                                <tr>
                                                    <td style="font-weight: 700; color: var(--text-navy);">#${row.bookingId}</td>
                                                    <td><c:out value="${row.customerName}" /></td>
                                                    <td><fmt:formatDate value="${row.checkInDate}" pattern="dd/MM/yyyy" /></td>
                                                    <td><fmt:formatDate value="${row.checkOutDate}" pattern="dd/MM/yyyy" /></td>
                                                    <td style="text-align: right; font-weight: 600;">
                                                        <fmt:formatNumber value="${row.totalAmount}" type="number" maxFractionDigits="0" /> đ
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${row.status eq 'Pending'}"><span class="status-pill status-maintenance"><i class="fa-solid fa-clock"></i> Chờ xử lý</span></c:when>
                                                            <c:when test="${row.status eq 'Confirmed'}"><span class="status-pill status-available"><i class="fa-solid fa-circle-check"></i> Đã xác nhận</span></c:when>
                                                            <c:when test="${row.status eq 'CheckedIn'}"><span class="status-pill status-available"><i class="fa-solid fa-right-to-bracket"></i> Đã nhận phòng</span></c:when>
                                                            <c:when test="${row.status eq 'CheckedOut'}"><span class="status-pill status-maintenance"><i class="fa-solid fa-right-from-bracket"></i> Đã trả phòng</span></c:when>
                                                            <c:when test="${row.status eq 'Rejected'}"><span class="status-pill status-maintenance"><i class="fa-solid fa-ban"></i> Từ chối</span></c:when>
                                                            <c:when test="${row.status eq 'Cancelled'}"><span class="status-pill status-maintenance"><i class="fa-solid fa-ban"></i> Đã hủy</span></c:when>
                                                            <c:otherwise><span class="status-pill status-maintenance"><c:out value="${row.status}" /></span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td><fmt:formatDate value="${row.createdAt}" pattern="dd/MM/yyyy HH:mm" /></td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>

                                </c:otherwise>
                        </c:choose>

                        <%-- Phân trang (20 dòng / trang) --%>
                        <c:if test="${detail.totalPages > 1}">
                            <div class="pagination-bar">
                                <c:if test="${detail.page > 1}">
                                    <a class="page-btn" href="?${baseQuery}view=${detail.view}&page=1#detail-panel" title="Trang đầu"><i class="fa-solid fa-angles-left"></i></a>
                                    <a class="page-btn" href="?${baseQuery}view=${detail.view}&page=${detail.page - 1}#detail-panel" title="Trang trước"><i class="fa-solid fa-chevron-left"></i></a>
                                </c:if>
                                <span class="page-info">Trang <strong>${detail.page}</strong> / ${detail.totalPages}</span>
                                <c:if test="${detail.page < detail.totalPages}">
                                    <a class="page-btn" href="?${baseQuery}view=${detail.view}&page=${detail.page + 1}#detail-panel" title="Trang sau"><i class="fa-solid fa-chevron-right"></i></a>
                                    <a class="page-btn" href="?${baseQuery}view=${detail.view}&page=${detail.totalPages}#detail-panel" title="Trang cuối"><i class="fa-solid fa-angles-right"></i></a>
                                </c:if>
                            </div>
                        </c:if>
                    </div>
                </c:if>

                <!-- ================= BIỂU ĐỒ HÀNG 1: DOANH THU THEO THỜI GIAN & TRẠNG THÁI ================= -->
                <div class="chart-grid">

                    <div class="chart-card">
                        <div class="chart-head-row">
                            <div class="chart-head-title">
                                <h3>Doanh thu theo thời gian</h3>
                                <span class="gran-chip">${stats.revenueSeries.granularityLabel}</span>
                            </div>
                            <form class="chart-filter" onsubmit="applyFilter(this); return false;">
                                <input type="date" name="c1From" value="${stats.revenueSeries.fromDate}" />
                                <span class="chart-filter-sep">–</span>
                                <input type="date" name="c1To" value="${stats.revenueSeries.toDate}" />
                                <button type="submit" class="stat-filter-apply" title="Áp dụng"><i class="fa-solid fa-filter"></i></button>
                            </form>
                        </div>
                        <div class="chart-canvas-wrap">
                            <c:choose>
                                <c:when test="${stats.revenueSeries.emptySeries}">
                                    <div class="empty-chart-note">Không có doanh thu trong khoảng đã chọn.</div>
                                </c:when>
                                <c:otherwise>
                                    <canvas id="revenueChart"></canvas>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="chart-card">
                        <div class="chart-head-row">
                            <div class="chart-head-title">
                                <h3>Phân bổ trạng thái đặt phòng</h3>
                            </div>
                            <form class="chart-filter" onsubmit="applyFilter(this); return false;">
                                <input type="date" name="c2From" value="${stats.statusSeries.fromDate}" />
                                <span class="chart-filter-sep">–</span>
                                <input type="date" name="c2To" value="${stats.statusSeries.toDate}" />
                                <button type="submit" class="stat-filter-apply" title="Áp dụng"><i class="fa-solid fa-filter"></i></button>
                            </form>
                        </div>
                        <div class="chart-canvas-wrap">
                            <c:choose>
                                <c:when test="${empty stats.statusSeries.labels}">
                                    <div class="empty-chart-note">Không có dữ liệu đặt phòng trong khoảng đã chọn.</div>
                                </c:when>
                                <c:otherwise>
                                    <canvas id="statusChart"></canvas>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- ================= BIỂU ĐỒ HÀNG 2: XU HƯỚNG ĐẶT PHÒNG & DOANH THU THEO LOẠI PHÒNG ================= -->
                <div class="chart-grid" style="margin-top: 24px;">

                    <div class="chart-card">
                        <div class="chart-head-row">
                            <div class="chart-head-title">
                                <h3>Xu hướng lượt đặt phòng</h3>
                                <span class="gran-chip">${stats.bookingTrendSeries.granularityLabel}</span>
                            </div>
                            <form class="chart-filter" onsubmit="applyFilter(this); return false;">
                                <input type="date" name="c3From" value="${stats.bookingTrendSeries.fromDate}" />
                                <span class="chart-filter-sep">–</span>
                                <input type="date" name="c3To" value="${stats.bookingTrendSeries.toDate}" />
                                <button type="submit" class="stat-filter-apply" title="Áp dụng"><i class="fa-solid fa-filter"></i></button>
                            </form>
                        </div>
                        <div class="chart-canvas-wrap">
                            <c:choose>
                                <c:when test="${stats.bookingTrendSeries.emptySeries}">
                                    <div class="empty-chart-note">Không có lượt đặt phòng trong khoảng đã chọn.</div>
                                </c:when>
                                <c:otherwise>
                                    <canvas id="trendChart"></canvas>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="chart-card">
                        <div class="chart-head-row">
                            <div class="chart-head-title">
                                <h3>Doanh thu theo loại phòng</h3>
                            </div>
                            <form class="chart-filter" onsubmit="applyFilter(this); return false;">
                                <input type="date" name="c4From" value="${stats.roomTypeRevenueSeries.fromDate}" />
                                <span class="chart-filter-sep">–</span>
                                <input type="date" name="c4To" value="${stats.roomTypeRevenueSeries.toDate}" />
                                <button type="submit" class="stat-filter-apply" title="Áp dụng"><i class="fa-solid fa-filter"></i></button>
                            </form>
                        </div>
                        <div class="chart-canvas-wrap">
                            <c:choose>
                                <c:when test="${empty stats.roomTypeRevenueSeries.labels}">
                                    <div class="empty-chart-note">Không có doanh thu trong khoảng đã chọn.</div>
                                </c:when>
                                <c:otherwise>
                                    <canvas id="roomTypeChart"></canvas>
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

    <%-- BỘ LỌC: gộp tham số của form vào query hiện tại rồi tải lại trang --%>
    <script>
        function applyFilter(form) {
            const params = new URLSearchParams(window.location.search);
            new FormData(form).forEach((value, key) => params.set(key, value));
            params.delete("page"); // đổi bộ lọc thì quay về trang 1 của danh sách
            const hash = params.get("view") ? "#detail-panel" : "";
            window.location.href = window.location.pathname + "?" + params.toString() + hash;
        }
    </script>

    <%-- BIỂU ĐỒ (Chart.js) --%>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
    <script>
        // ----- Dữ liệu từ server (đổ qua JSTL) -----
        const revenueSeries = {
            labels: [<c:forEach var="l" items="${stats.revenueSeries.labels}" varStatus="st">"${fn:escapeXml(l)}"<c:if test="${!st.last}">,</c:if></c:forEach>],
            values: [<c:forEach var="v" items="${stats.revenueSeries.values}" varStatus="st">${v}<c:if test="${!st.last}">,</c:if></c:forEach>]
        };
        const statusSeries = {
            labels: [<c:forEach var="l" items="${stats.statusSeries.labels}" varStatus="st">"${fn:escapeXml(l)}"<c:if test="${!st.last}">,</c:if></c:forEach>],
            values: [<c:forEach var="v" items="${stats.statusSeries.values}" varStatus="st">${v}<c:if test="${!st.last}">,</c:if></c:forEach>]
        };
        const trendSeries = {
            labels: [<c:forEach var="l" items="${stats.bookingTrendSeries.labels}" varStatus="st">"${fn:escapeXml(l)}"<c:if test="${!st.last}">,</c:if></c:forEach>],
            values: [<c:forEach var="v" items="${stats.bookingTrendSeries.values}" varStatus="st">${v}<c:if test="${!st.last}">,</c:if></c:forEach>]
        };
        const roomTypeSeries = {
            labels: [<c:forEach var="l" items="${stats.roomTypeRevenueSeries.labels}" varStatus="st">"${fn:escapeXml(l)}"<c:if test="${!st.last}">,</c:if></c:forEach>],
            values: [<c:forEach var="v" items="${stats.roomTypeRevenueSeries.values}" varStatus="st">${v}<c:if test="${!st.last}">,</c:if></c:forEach>]
        };

        const vnNumber = new Intl.NumberFormat('vi-VN');
        // Màu theo thực thể: doanh thu = xanh dương thương hiệu, lượt đặt phòng = xanh lục.
        const REVENUE_COLOR = '#0056b3';
        const BOOKING_COLOR = '#0e9f6e';

        const money = v => vnNumber.format(v) + ' đ';
        const gridStyle = { color: 'rgba(100, 116, 139, 0.12)' };

        // ----- 1. Doanh thu theo thời gian (CỘT) -----
        if (document.getElementById("revenueChart")) {
            new Chart(document.getElementById("revenueChart"), {
                type: 'bar',
                data: {
                    labels: revenueSeries.labels,
                    datasets: [{
                        label: 'Doanh thu',
                        data: revenueSeries.values,
                        backgroundColor: REVENUE_COLOR,
                        borderRadius: 4,
                        maxBarThickness: 28
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            callbacks: { label: ctx => ' Doanh thu: ' + money(ctx.parsed.y) }
                        }
                    },
                    scales: {
                        x: { grid: { display: false }, ticks: { maxRotation: 60, autoSkip: true, maxTicksLimit: 20 } },
                        y: { beginAtZero: true, grid: gridStyle, ticks: { callback: v => vnNumber.format(v) } }
                    }
                }
            });
        }

        // ----- 2. Phân bổ trạng thái đặt phòng (THANH NGANG) -----
        if (document.getElementById("statusChart")) {
            new Chart(document.getElementById("statusChart"), {
                type: 'bar',
                data: {
                    labels: statusSeries.labels,
                    datasets: [{
                        label: 'Số đơn',
                        data: statusSeries.values,
                        backgroundColor: BOOKING_COLOR,
                        borderRadius: 4,
                        maxBarThickness: 26
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    indexAxis: 'y',
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            callbacks: { label: ctx => ' ' + vnNumber.format(ctx.parsed.x) + ' đơn' }
                        }
                    },
                    scales: {
                        x: { beginAtZero: true, grid: gridStyle, ticks: { precision: 0 } },
                        y: { grid: { display: false } }
                    }
                }
            });
        }

        // ----- 3. Xu hướng lượt đặt phòng (ĐƯỜNG) -----
        if (document.getElementById("trendChart")) {
            new Chart(document.getElementById("trendChart"), {
                type: 'line',
                data: {
                    labels: trendSeries.labels,
                    datasets: [{
                        label: 'Lượt đặt phòng',
                        data: trendSeries.values,
                        borderColor: BOOKING_COLOR,
                        backgroundColor: 'rgba(14, 159, 110, 0.08)',
                        borderWidth: 2,
                        fill: true,
                        tension: 0.25,
                        pointRadius: trendSeries.labels.length > 45 ? 0 : 3,
                        pointHoverRadius: 5,
                        pointBackgroundColor: BOOKING_COLOR
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    interaction: { mode: 'index', intersect: false },
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            callbacks: { label: ctx => ' ' + vnNumber.format(ctx.parsed.y) + ' lượt' }
                        }
                    },
                    scales: {
                        x: { grid: { display: false }, ticks: { maxRotation: 60, autoSkip: true, maxTicksLimit: 20 } },
                        y: { beginAtZero: true, grid: gridStyle, ticks: { precision: 0 } }
                    }
                }
            });
        }

        // ----- 4. Doanh thu theo loại phòng (THANH NGANG) -----
        if (document.getElementById("roomTypeChart")) {
            new Chart(document.getElementById("roomTypeChart"), {
                type: 'bar',
                data: {
                    labels: roomTypeSeries.labels,
                    datasets: [{
                        label: 'Doanh thu',
                        data: roomTypeSeries.values,
                        backgroundColor: REVENUE_COLOR,
                        borderRadius: 4,
                        maxBarThickness: 26
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    indexAxis: 'y',
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            callbacks: { label: ctx => ' Doanh thu: ' + money(ctx.parsed.x) }
                        }
                    },
                    scales: {
                        x: { beginAtZero: true, grid: gridStyle, ticks: { callback: v => vnNumber.format(v) } },
                        y: { grid: { display: false } }
                    }
                }
            });
        }
    </script>

</body>
</html>
