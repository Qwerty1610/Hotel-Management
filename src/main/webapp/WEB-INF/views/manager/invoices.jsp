<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=3" />
<fmt:setLocale value="vi_VN" />

<body class="dashboard-body">

    <div class="dashboard-layout">

        <!-- SIDEBAR -->
        <c:set var="activePage" value="invoices" scope="request" />
        <jsp:include page="sidebar.jsp" />

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

                <div class="table-card">
                    <!-- BỘ LỌC (GET, server-side) -->
                    <form class="table-filter-bar" method="get" action="${pageContext.request.contextPath}/manager/invoices">
                        <div class="search-wrapper" style="max-width:420px;">
                            <i class="fa-solid fa-magnifying-glass"></i>
                            <input type="text" name="q" class="input-search-service"
                                   value="<c:out value='${q}' />"
                                   placeholder="Tìm theo mã HĐ, tên khách hoặc số phòng..." />
                        </div>
                        <select name="status" class="status-select" onchange="this.form.submit()">
                            <option value="all"       ${statusFilter eq 'all'       ? 'selected' : ''}>Tất cả trạng thái</option>
                            <option value="Pending"   ${statusFilter eq 'Pending'   ? 'selected' : ''}>Chưa thanh toán</option>
                            <option value="Paid"      ${statusFilter eq 'Paid'      ? 'selected' : ''}>Đã thanh toán</option>
                            <option value="Refunding" ${statusFilter eq 'Refunding' ? 'selected' : ''}>Chờ hoàn</option>
                            <option value="Cancelled" ${statusFilter eq 'Cancelled' ? 'selected' : ''}>Đã huỷ</option>
                        </select>
                        <button type="submit" class="btn-add-service" style="height:40px;">
                            <i class="fa-solid fa-magnifying-glass"></i> Tìm
                        </button>
                    </form>

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
                        <tbody>
                            <c:forEach var="inv" items="${invoices}">
                                <tr>
                                    <td>
                                        <span style="font-weight:700; color:var(--brand-blue);">HD-<fmt:formatNumber value="${inv.invoiceId}" minIntegerDigits="4" groupingUsed="false" /></span>
                                    </td>
                                    <td>
                                        <div class="service-name-cell"><div>
                                            <span class="service-title"><c:out value="${inv.customerName}" /></span>
                                            <span class="request-sub"><i class="fa-solid fa-bed"></i> Phòng <c:out value="${inv.roomNumber}" /></span>
                                        </div></div>
                                    </td>
                                    <td><span style="color:#475569;"><fmt:formatDate value="${inv.createdAt}" pattern="dd/MM/yyyy HH:mm" /></span></td>
                                    <td><span style="font-weight:700; color:var(--text-navy);"><fmt:formatNumber value="${inv.totalAmount}" type="number" maxFractionDigits="0" /> đ</span></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${inv.status eq 'Pending'}"><span class="inv-badge inv-pending">CHƯA TT</span></c:when>
                                            <c:when test="${inv.status eq 'Paid'}"><span class="inv-badge inv-paid">ĐÃ TT</span></c:when>
                                            <c:when test="${inv.status eq 'Refunding'}"><span class="inv-badge inv-refunding">CHỜ HOÀN</span></c:when>
                                            <c:otherwise><span class="inv-badge inv-cancelled">ĐÃ HUỶ</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <a class="btn-detail" href="${pageContext.request.contextPath}/manager/invoices?id=${inv.invoiceId}">
                                            <i class="fa-solid fa-eye"></i> Chi tiết
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty invoices}">
                                <tr>
                                    <td colspan="6" style="text-align:center; padding:40px; color:var(--text-muted);">
                                        <i class="fa-solid fa-folder-open" style="font-size:32px; margin-bottom:12px; display:block;"></i>
                                        Không tìm thấy hóa đơn nào phù hợp
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>

                    <!-- PHÂN TRANG (server-side) -->
                    <div class="table-pagination-bar">
                        <div class="pagination-info">
                            <c:choose>
                                <c:when test="${totalItems == 0}">Hiển thị 0 hóa đơn</c:when>
                                <c:otherwise>
                                    Hiển thị ${(page-1)*pageSize + 1}-${page*pageSize gt totalItems ? totalItems : page*pageSize} trong số ${totalItems} hóa đơn
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="pagination-controls">
                            <c:choose>
                                <c:when test="${page > 1}">
                                    <c:url var="prevUrl" value="/manager/invoices">
                                        <c:param name="q" value="${q}" /><c:param name="status" value="${statusFilter}" /><c:param name="page" value="${page-1}" />
                                    </c:url>
                                    <a class="btn-page" href="${prevUrl}"><i class="fa-solid fa-chevron-left"></i></a>
                                </c:when>
                                <c:otherwise><span class="btn-page disabled"><i class="fa-solid fa-chevron-left"></i></span></c:otherwise>
                            </c:choose>

                            <c:forEach var="p" begin="1" end="${totalPages}">
                                <c:url var="pUrl" value="/manager/invoices">
                                    <c:param name="q" value="${q}" /><c:param name="status" value="${statusFilter}" /><c:param name="page" value="${p}" />
                                </c:url>
                                <a class="btn-page ${p == page ? 'active' : ''}" href="${pUrl}">${p}</a>
                            </c:forEach>

                            <c:choose>
                                <c:when test="${page < totalPages}">
                                    <c:url var="nextUrl" value="/manager/invoices">
                                        <c:param name="q" value="${q}" /><c:param name="status" value="${statusFilter}" /><c:param name="page" value="${page+1}" />
                                    </c:url>
                                    <a class="btn-page" href="${nextUrl}"><i class="fa-solid fa-chevron-right"></i></a>
                                </c:when>
                                <c:otherwise><span class="btn-page disabled"><i class="fa-solid fa-chevron-right"></i></span></c:otherwise>
                            </c:choose>
                        </div>
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

</body>
</html>
