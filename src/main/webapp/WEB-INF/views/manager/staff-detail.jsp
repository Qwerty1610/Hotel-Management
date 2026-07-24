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
                    <a href="${pageContext.request.contextPath}/manager/requests" style="color:var(--text-muted); text-decoration:none;">Yêu cầu &amp; Nhân viên</a>
                    <span class="separator">&gt;</span>
                    <span class="current"><c:out value="${staff.fullName}" /></span>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </a>
            </header>

            <main class="workspace-content">

                <div class="content-header-row">
                    <div>
                        <a href="${pageContext.request.contextPath}/manager/requests" class="btn-back">
                            <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
                        </a>
                        <h1 style="margin-top:12px;">Thông tin nhân viên</h1>
                    </div>
                </div>

                <div class="invoice-detail-grid">

                    <!-- CỘT TRÁI -->
                    <div>
                        <div class="table-card" style="margin-bottom:24px;">
                            <div style="padding:22px 24px;">
                                <div class="staff-detail-head">
                                    <div class="staff-detail-avatar"><i class="fa-solid fa-user"></i></div>
                                    <div>
                                        <div class="staff-detail-name"><c:out value="${staff.fullName}" /></div>
                                        <div class="staff-detail-email"><c:out value="${staff.email}" /></div>
                                        <c:choose>
                                            <c:when test="${staff.workStatus eq 'Active'}"><span class="wk-badge wk-active"><i class="fa-solid fa-circle"></i> Đang trực</span></c:when>
                                            <c:when test="${staff.workStatus eq 'OnBreak'}"><span class="wk-badge wk-break"><i class="fa-solid fa-circle"></i> Đang nghỉ</span></c:when>
                                            <c:otherwise><span class="wk-badge wk-offline"><i class="fa-solid fa-circle"></i> Ngoại tuyến</span></c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                                <div class="staff-detail-stats">
                                    <div class="detail-stat"><span class="detail-stat-value">${staff.completedToday}</span><span class="detail-stat-label">Hoàn thành hôm nay</span></div>
                                    <div class="detail-stat"><span class="detail-stat-value">${staff.completedMonth}</span><span class="detail-stat-label">Hoàn thành tháng này</span></div>
                                    <div class="detail-stat"><span class="detail-stat-value">${staff.activeAssignments}</span><span class="detail-stat-label">Việc đang làm</span></div>
                                </div>
                            </div>
                        </div>

                        <!-- Công việc đang thực hiện -->
                        <div class="table-card">
                            <div class="card-section-title"><i class="fa-solid fa-spinner"></i> Công việc đang thực hiện</div>
                            <div style="padding:8px 24px 20px;">
                                <c:choose>
                                    <c:when test="${empty inProgress}">
                                        <p style="color:var(--text-muted); font-style:italic; margin:8px 0 0;">Không có việc đang thực hiện.</p>
                                    </c:when>
                                    <c:otherwise>
                                        <ul class="staff-task-list" style="max-height:none;">
                                            <c:forEach var="t" items="${inProgress}">
                                                <li>
                                                    <c:choose>
                                                        <c:when test="${t.priority eq 'Urgent'}"><span class="prio-badge prio-urgent">KHẨN CẤP</span></c:when>
                                                        <c:when test="${t.priority eq 'High'}"><span class="prio-badge prio-high">CAO</span></c:when>
                                                        <c:when test="${t.priority eq 'Low'}"><span class="prio-badge prio-low">THẤP</span></c:when>
                                                        <c:otherwise><span class="prio-badge prio-medium">TRUNG BÌNH</span></c:otherwise>
                                                    </c:choose>
                                                    <c:out value="${t.issueNames}" /> <span style="color:var(--text-muted);">— Phòng <c:out value="${t.roomNumbers}" /></span>
                                                </li>
                                            </c:forEach>
                                        </ul>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <!-- CỘT PHẢI: công việc đã nhận / được gán (phân trang 5/trang) -->
                    <div class="invoice-actions-col">
                        <div class="table-card">
                            <div class="card-section-title"><i class="fa-solid fa-list-check"></i> Công việc đã nhận / được gán</div>
                            <div style="padding:8px 24px 12px;">
                                <c:choose>
                                    <c:when test="${empty assigned}">
                                        <p style="color:var(--text-muted); font-style:italic; margin:8px 0 0;">Chưa nhận công việc nào.</p>
                                    </c:when>
                                    <c:otherwise>
                                        <ul class="staff-task-list" style="max-height:none;">
                                            <c:forEach var="t" items="${assigned}">
                                                <li>
                                                    <c:choose>
                                                        <c:when test="${t.priority eq 'Urgent'}"><span class="prio-badge prio-urgent">KHẨN CẤP</span></c:when>
                                                        <c:when test="${t.priority eq 'High'}"><span class="prio-badge prio-high">CAO</span></c:when>
                                                        <c:when test="${t.priority eq 'Low'}"><span class="prio-badge prio-low">THẤP</span></c:when>
                                                        <c:otherwise><span class="prio-badge prio-medium">TRUNG BÌNH</span></c:otherwise>
                                                    </c:choose>
                                                    <c:out value="${t.issueNames}" />
                                                    <span style="color:var(--text-muted);">— Phòng <c:out value="${t.roomNumbers}" /></span>
                                                    <c:choose>
                                                        <c:when test="${t.status eq 'InProgress'}"><span class="status-pill status-occupied" style="margin-left:4px;"><i class="fa-solid fa-circle"></i> ĐANG THỰC HIỆN</span></c:when>
                                                        <c:when test="${t.status eq 'Resolved'}"><span class="status-pill status-available" style="margin-left:4px;"><i class="fa-solid fa-circle"></i> ĐÃ XỬ LÝ</span></c:when>
                                                        <c:when test="${t.status eq 'Unresolvable'}"><span class="status-pill status-unresolvable" style="margin-left:4px;"><i class="fa-solid fa-circle"></i> KHÔNG THỂ XỬ LÝ</span></c:when>
                                                        <c:when test="${t.status eq 'Cancelled'}"><span class="status-pill status-maintenance" style="margin-left:4px;"><i class="fa-solid fa-circle"></i> ĐÃ HUỶ</span></c:when>
                                                        <c:otherwise><span class="status-pill status-cleaning" style="margin-left:4px;"><i class="fa-solid fa-circle"></i> ĐANG CHỜ</span></c:otherwise>
                                                    </c:choose>
                                                </li>
                                            </c:forEach>
                                        </ul>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="table-pagination-bar">
                                <div class="pagination-info">
                                    <c:choose>
                                        <c:when test="${totalItems == 0}">Hiển thị 0 công việc</c:when>
                                        <c:otherwise>Hiển thị ${(page-1)*pageSize + 1}-${page*pageSize gt totalItems ? totalItems : page*pageSize} / ${totalItems} công việc</c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="pagination-controls">
                                    <c:if test="${totalPages > 1}">
                                        <c:choose>
                                            <c:when test="${page > 1}">
                                                <a class="btn-page" href="${pageContext.request.contextPath}/manager/staff?id=${staff.accountId}&page=${page-1}"><i class="fa-solid fa-chevron-left"></i></a>
                                            </c:when>
                                            <c:otherwise><span class="btn-page disabled"><i class="fa-solid fa-chevron-left"></i></span></c:otherwise>
                                        </c:choose>
                                        <c:forEach var="p" begin="1" end="${totalPages}">
                                            <a class="btn-page ${p == page ? 'active' : ''}" href="${pageContext.request.contextPath}/manager/staff?id=${staff.accountId}&page=${p}">${p}</a>
                                        </c:forEach>
                                        <c:choose>
                                            <c:when test="${page < totalPages}">
                                                <a class="btn-page" href="${pageContext.request.contextPath}/manager/staff?id=${staff.accountId}&page=${page+1}"><i class="fa-solid fa-chevron-right"></i></a>
                                            </c:when>
                                            <c:otherwise><span class="btn-page disabled"><i class="fa-solid fa-chevron-right"></i></span></c:otherwise>
                                        </c:choose>
                                    </c:if>
                                </div>
                            </div>
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
