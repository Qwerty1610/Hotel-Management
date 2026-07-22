<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=4" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=6" />
<fmt:setLocale value="vi_VN" />

<%--
    Trang Tổng quan của Manager, thiết kế đồng bộ với Bảng điều khiển hệ thống của Admin:
    - 4 thẻ KPI chuẩn ngành khách sạn (Tổng doanh thu, RevPAR, ADR, Tỷ lệ hủy)
      tính trên một kỳ báo cáo chung (tháng / quý / năm / tùy chỉnh).
    - Thẻ "Tổng doanh thu" & "Tỷ lệ hủy" bấm được để mở danh sách chi tiết
      (render backend, 20 dòng/trang).
    - 4 biểu đồ, mỗi biểu đồ một khoảng lọc riêng; chuỗi thời gian tự gom nhóm
      ngày → tháng → quý khi khoảng lọc rộng để không bị chi chít.
    - Doanh thu được rải đều theo đêm lưu trú nên chuỗi doanh thu phản ánh đúng
      phần doanh thu thuộc về từng ngày.
    @author Pham Quoc Quy
--%>
<body class="dashboard-body">

    <!-- Active Tab Resolution -->
    <c:set var="currentTab" value="${param.tab != null ? param.tab : 'overview'}" />

    <div class="dashboard-layout">

        <!-- SIDEBAR -->
        <c:set var="activePage" value="${currentTab}" scope="request" />
        <jsp:include page="../manager/sidebar.jsp" />

        <!-- MAIN DASHBOARD CONTENT -->
        <div class="dashboard-main">

            <!-- TOP HEADER BAR -->
            <header class="main-topbar">
                <div class="breadcrumb">
                    <span>Quản trị</span>
                    <span class="separator">&gt;</span>
                    <span class="current">
                        <c:choose>
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

                    <%-- 1. OVERVIEW TAB - KPI hiệu suất & phân tích doanh thu --%>
                    <c:when test="${currentTab eq 'overview'}">

                        <c:set var="ctx" value="${pageContext.request.contextPath}" />
                        <c:set var="kp" value="${stats.kpiPeriod}" />

                        <div class="content-header-row">
                            <div>
                                <h1>Tổng quan vận hành</h1>
                                <p>Hiệu suất kinh doanh của khách sạn theo kỳ báo cáo. Bấm vào thẻ Doanh thu / Tỷ lệ hủy để xem danh sách chi tiết.</p>
                            </div>
                        </div>

                        <!-- BỘ LỌC KỲ BÁO CÁO (áp dụng cho cả 4 thẻ KPI) -->
                        <div class="filter-card">
                            <form class="date-filter-form" onsubmit="applyFilter(this); return false;">
                                <div class="date-field">
                                    <label for="kpMode">Kỳ báo cáo</label>
                                    <select id="kpMode" name="kpMode" class="stat-filter-select" style="height:40px;"
                                            onchange="applyFilter(this.form)">
                                        <option value="month" ${kp.mode eq 'month' ? 'selected' : ''}>Theo tháng</option>
                                        <option value="quarter" ${kp.mode eq 'quarter' ? 'selected' : ''}>Theo quý</option>
                                        <option value="year" ${kp.mode eq 'year' ? 'selected' : ''}>Theo năm</option>
                                        <option value="custom" ${kp.mode eq 'custom' ? 'selected' : ''}>Tùy chỉnh</option>
                                    </select>
                                </div>
                                <c:choose>
                                    <c:when test="${kp.mode eq 'quarter'}">
                                        <div class="date-field">
                                            <label for="kpQuarter">Quý</label>
                                            <select id="kpQuarter" name="kpQuarter" class="stat-filter-select" style="height:40px;"
                                                    onchange="applyFilter(this.form)">
                                                <c:forEach var="opt" items="${quarterOptions}">
                                                    <option value="${opt[0]}" ${opt[0] eq kp.quarterValue ? 'selected' : ''}>${opt[1]}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                    </c:when>
                                    <c:when test="${kp.mode eq 'year'}">
                                        <div class="date-field">
                                            <label for="kpYear">Năm</label>
                                            <select id="kpYear" name="kpYear" class="stat-filter-select" style="height:40px;"
                                                    onchange="applyFilter(this.form)">
                                                <c:forEach var="y" items="${yearOptions}">
                                                    <option value="${y}" ${y eq kp.yearValue ? 'selected' : ''}>Năm ${y}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                    </c:when>
                                    <c:when test="${kp.mode eq 'custom'}">
                                        <div class="date-field">
                                            <label for="kpFrom">Từ ngày</label>
                                            <input type="date" id="kpFrom" name="kpFrom" value="${kp.fromValue}" />
                                        </div>
                                        <div class="date-field">
                                            <label for="kpTo">Đến ngày</label>
                                            <input type="date" id="kpTo" name="kpTo" value="${kp.toValue}" />
                                        </div>
                                        <button type="submit" class="btn-add-service" style="height: 40px;">
                                            <i class="fa-solid fa-filter"></i> Áp dụng
                                        </button>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="date-field">
                                            <label for="kpMonth">Tháng</label>
                                            <input type="month" id="kpMonth" name="kpMonth" value="${kp.monthValue}"
                                                   class="stat-filter-date" style="height:40px;"
                                                   onchange="applyFilter(this.form)" />
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                                <div class="quick-ranges">
                                    <span class="stat-period" style="align-self:center;">Kỳ hiện tại: ${kp.label}</span>
                                </div>
                            </form>
                        </div>

                        <!-- ================= THẺ KPI ================= -->
                        <div class="stat-grid stat-grid-cards">

                            <!-- Tổng doanh thu (bấm để xem danh sách đơn) -->
                            <div class="stat-card stat-card-col">
                                <a class="stat-main" href="?${baseQuery}view=revenue#detail-panel" title="Xem các đơn được tính doanh thu trong kỳ">
                                    <div class="stat-icon icon-revenue"><i class="fa-solid fa-sack-dollar"></i></div>
                                    <div class="stat-body">
                                        <span class="stat-label">Tổng doanh thu</span>
                                        <span class="stat-value">
                                            <fmt:formatNumber value="${stats.totalRevenue}" type="number" maxFractionDigits="0" /> đ
                                        </span>
                                        <span class="stat-period">${kp.label}</span>
                                    </div>
                                    <i class="fa-solid fa-chevron-right stat-open-icon"></i>
                                </a>
                                <div class="stat-foot">
                                    <i class="fa-solid fa-file-invoice"></i>
                                    <fmt:formatNumber value="${stats.revenueBookings}" type="number" /> đơn được tính trong kỳ
                                </div>
                            </div>

                            <!-- RevPAR -->
                            <div class="stat-card stat-card-col">
                                <div class="stat-main" style="cursor: default;">
                                    <div class="stat-icon icon-nights"><i class="fa-solid fa-chart-line"></i></div>
                                    <div class="stat-body">
                                        <span class="stat-label">RevPAR (doanh thu / phòng sẵn có)</span>
                                        <span class="stat-value">
                                            <fmt:formatNumber value="${stats.revPar}" type="number" maxFractionDigits="0" /> đ
                                        </span>
                                        <span class="stat-period">${kp.label}</span>
                                    </div>
                                </div>
                                <div class="stat-foot">
                                    <i class="fa-solid fa-calculator"></i>
                                    Doanh thu ÷ (${stats.totalRooms} phòng × số ngày kỳ)
                                </div>
                            </div>

                            <!-- ADR + Công suất TB -->
                            <div class="stat-card stat-card-col">
                                <div class="stat-main" style="cursor: default;">
                                    <div class="stat-icon icon-occupancy"><i class="fa-solid fa-tag"></i></div>
                                    <div class="stat-body">
                                        <span class="stat-label">ADR (giá bình quân / phòng-đêm)</span>
                                        <span class="stat-value">
                                            <fmt:formatNumber value="${stats.adr}" type="number" maxFractionDigits="0" /> đ
                                        </span>
                                        <span class="stat-period">
                                            <fmt:formatNumber value="${stats.roomNightsSold}" type="number" /> phòng-đêm đã bán
                                        </span>
                                    </div>
                                </div>
                                <div class="stat-foot">
                                    <i class="fa-solid fa-chart-pie"></i>
                                    Công suất phòng TB:&nbsp;<strong><fmt:formatNumber value="${stats.avgOccupancy}" maxFractionDigits="1" />%</strong>
                                </div>
                            </div>

                            <!-- Tỷ lệ hủy (bấm để xem danh sách đơn hủy) -->
                            <div class="stat-card stat-card-col">
                                <a class="stat-main" href="?${baseQuery}view=cancelled#detail-panel" title="Xem các đơn hủy / từ chối trong kỳ">
                                    <div class="stat-icon icon-checkout"><i class="fa-solid fa-ban"></i></div>
                                    <div class="stat-body">
                                        <span class="stat-label">Tỷ lệ hủy</span>
                                        <span class="stat-value">
                                            <fmt:formatNumber value="${stats.cancellationRate}" maxFractionDigits="1" />%
                                        </span>
                                        <span class="stat-period">
                                            ${stats.cancelledBookings} / ${stats.createdBookings} đơn tạo trong kỳ
                                        </span>
                                    </div>
                                    <i class="fa-solid fa-chevron-right stat-open-icon"></i>
                                </a>
                                <div class="stat-foot">
                                    <i class="fa-solid fa-circle-info"></i>
                                    Đơn Cancelled / Rejected trên tổng đơn tạo trong kỳ
                                </div>
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
                                                        <c:if test="${detail.view eq 'cancelled'}">
                                                            <th>Ghi chú</th>
                                                        </c:if>
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
                                                            <c:if test="${detail.view eq 'cancelled'}">
                                                                <td><c:out value="${row.note}" /></td>
                                                            </c:if>
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

                        <!-- ================= BIỂU ĐỒ HÀNG 1: DOANH THU & CÔNG SUẤT THEO THỜI GIAN ================= -->
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
                                        <h3>Công suất phòng theo thời gian</h3>
                                        <span class="gran-chip">${stats.occupancySeries.granularityLabel}</span>
                                    </div>
                                    <form class="chart-filter" onsubmit="applyFilter(this); return false;">
                                        <input type="date" name="c2From" value="${stats.occupancySeries.fromDate}" />
                                        <span class="chart-filter-sep">–</span>
                                        <input type="date" name="c2To" value="${stats.occupancySeries.toDate}" />
                                        <button type="submit" class="stat-filter-apply" title="Áp dụng"><i class="fa-solid fa-filter"></i></button>
                                    </form>
                                </div>
                                <div class="chart-canvas-wrap">
                                    <c:choose>
                                        <c:when test="${stats.occupancySeries.emptySeries}">
                                            <div class="empty-chart-note">Không có phòng được sử dụng trong khoảng đã chọn.</div>
                                        </c:when>
                                        <c:otherwise>
                                            <canvas id="occupancyChart"></canvas>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <!-- ================= BIỂU ĐỒ HÀNG 2: LOẠI PHÒNG & CƠ CẤU DOANH THU ================= -->
                        <div class="chart-grid" style="margin-top: 24px;">

                            <div class="chart-card">
                                <div class="chart-head-row">
                                    <div class="chart-head-title">
                                        <h3>Doanh thu theo loại phòng</h3>
                                    </div>
                                    <form class="chart-filter" onsubmit="applyFilter(this); return false;">
                                        <input type="date" name="c3From" value="${stats.roomTypeRevenueSeries.fromDate}" />
                                        <span class="chart-filter-sep">–</span>
                                        <input type="date" name="c3To" value="${stats.roomTypeRevenueSeries.toDate}" />
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

                            <div class="chart-card">
                                <div class="chart-head-row">
                                    <div class="chart-head-title">
                                        <h3>Cơ cấu doanh thu (theo hóa đơn)</h3>
                                    </div>
                                    <form class="chart-filter" onsubmit="applyFilter(this); return false;">
                                        <input type="date" name="c4From" value="${stats.revenueMixSeries.fromDate}" />
                                        <span class="chart-filter-sep">–</span>
                                        <input type="date" name="c4To" value="${stats.revenueMixSeries.toDate}" />
                                        <button type="submit" class="stat-filter-apply" title="Áp dụng"><i class="fa-solid fa-filter"></i></button>
                                    </form>
                                </div>
                                <div class="chart-canvas-wrap">
                                    <c:choose>
                                        <c:when test="${empty stats.revenueMixSeries.labels}">
                                            <div class="empty-chart-note">Không có hóa đơn trong khoảng đã chọn.</div>
                                        </c:when>
                                        <c:otherwise>
                                            <canvas id="mixChart"></canvas>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <!-- ================= TOP DỊCH VỤ BÁN CHẠY ================= -->
                        <div class="chart-card" style="margin-top: 24px;">
                            <div class="chart-head-row">
                                <div class="chart-head-title">
                                    <h3>Top dịch vụ bán chạy</h3>
                                    <span class="gran-chip">Cùng khoảng lọc với Cơ cấu doanh thu</span>
                                </div>
                            </div>
                            <c:choose>
                                <c:when test="${empty stats.topServices}">
                                    <div class="empty-chart-note">Chưa có dịch vụ hoàn thành trong khoảng đã chọn.</div>
                                </c:when>
                                <c:otherwise>
                                    <div class="detail-table-wrap">
                                        <table class="services-table-element">
                                            <thead>
                                                <tr>
                                                    <th style="width: 60px;">#</th>
                                                    <th>Dịch vụ</th>
                                                    <th style="text-align: right;">Số lượng hoàn thành</th>
                                                    <th style="text-align: right;">Doanh thu ước tính</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="svc" items="${stats.topServices}" varStatus="st">
                                                    <tr>
                                                        <td style="font-weight: 700; color: var(--text-navy);">${st.index + 1}</td>
                                                        <td><c:out value="${svc.serviceName}" /></td>
                                                        <td style="text-align: right;"><fmt:formatNumber value="${svc.quantity}" type="number" /></td>
                                                        <td style="text-align: right; font-weight: 600;">
                                                            <fmt:formatNumber value="${svc.revenue}" type="number" maxFractionDigits="0" /> đ
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                    </c:when>

                    <%-- 2. CUSTOMERS TAB (PLACEHOLDER) --%>
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
                <span>© 2026 HotelOps Luxury Management. Hệ thống quản trị nội bộ.</span>
                <div class="footer-links-row">
                    <a href="#">Hỗ trợ</a>
                    <a href="#">Bảo mật</a>
                    <a href="#">Điều khoản</a>
                </div>
            </footer>

        </div>

    </div>

    <%-- OVERVIEW TAB: bộ lọc + biểu đồ (Chart.js) --%>
    <c:if test="${currentTab eq 'overview'}">
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

        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
        <script>
            // ----- Dữ liệu từ server (đổ qua JSTL) -----
            const revenueSeries = {
                labels: [<c:forEach var="l" items="${stats.revenueSeries.labels}" varStatus="st">"${fn:escapeXml(l)}"<c:if test="${!st.last}">,</c:if></c:forEach>],
                values: [<c:forEach var="v" items="${stats.revenueSeries.values}" varStatus="st">${v}<c:if test="${!st.last}">,</c:if></c:forEach>]
            };
            const occupancySeries = {
                labels: [<c:forEach var="l" items="${stats.occupancySeries.labels}" varStatus="st">"${fn:escapeXml(l)}"<c:if test="${!st.last}">,</c:if></c:forEach>],
                values: [<c:forEach var="v" items="${stats.occupancySeries.values}" varStatus="st">${v}<c:if test="${!st.last}">,</c:if></c:forEach>]
            };
            const roomTypeSeries = {
                labels: [<c:forEach var="l" items="${stats.roomTypeRevenueSeries.labels}" varStatus="st">"${fn:escapeXml(l)}"<c:if test="${!st.last}">,</c:if></c:forEach>],
                values: [<c:forEach var="v" items="${stats.roomTypeRevenueSeries.values}" varStatus="st">${v}<c:if test="${!st.last}">,</c:if></c:forEach>]
            };
            const mixSeries = {
                labels: [<c:forEach var="l" items="${stats.revenueMixSeries.labels}" varStatus="st">"${fn:escapeXml(l)}"<c:if test="${!st.last}">,</c:if></c:forEach>],
                values: [<c:forEach var="v" items="${stats.revenueMixSeries.values}" varStatus="st">${v}<c:if test="${!st.last}">,</c:if></c:forEach>]
            };

            const vnNumber = new Intl.NumberFormat('vi-VN');
            // Màu theo thực thể: doanh thu = xanh dương thương hiệu, phòng / công suất = xanh lục.
            const REVENUE_COLOR = '#0056b3';
            const ROOM_COLOR = '#0e9f6e';

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

            // ----- 2. Công suất phòng theo thời gian (ĐƯỜNG, 0–100%) -----
            if (document.getElementById("occupancyChart")) {
                new Chart(document.getElementById("occupancyChart"), {
                    type: 'line',
                    data: {
                        labels: occupancySeries.labels,
                        datasets: [{
                            label: 'Công suất (%)',
                            data: occupancySeries.values,
                            borderColor: ROOM_COLOR,
                            backgroundColor: 'rgba(14, 159, 110, 0.08)',
                            borderWidth: 2,
                            fill: true,
                            tension: 0.25,
                            pointRadius: occupancySeries.labels.length > 45 ? 0 : 3,
                            pointHoverRadius: 5,
                            pointBackgroundColor: ROOM_COLOR
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        interaction: { mode: 'index', intersect: false },
                        plugins: {
                            legend: { display: false },
                            tooltip: {
                                callbacks: { label: ctx => ' Công suất: ' + ctx.parsed.y + '%' }
                            }
                        },
                        scales: {
                            x: { grid: { display: false }, ticks: { maxRotation: 60, autoSkip: true, maxTicksLimit: 20 } },
                            y: { beginAtZero: true, max: 100, grid: gridStyle, ticks: { callback: v => v + '%' } }
                        }
                    }
                });
            }

            // ----- 3. Doanh thu theo loại phòng (THANH NGANG) -----
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

            // ----- 4. Cơ cấu doanh thu Phòng / Dịch vụ / Phụ phí (THANH NGANG) -----
            if (document.getElementById("mixChart")) {
                new Chart(document.getElementById("mixChart"), {
                    type: 'bar',
                    data: {
                        labels: mixSeries.labels,
                        datasets: [{
                            label: 'Doanh thu',
                            data: mixSeries.values,
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
                                callbacks: { label: ctx => ' ' + ctx.label + ': ' + money(ctx.parsed.x) }
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
    </c:if>

</body>
</html>
