<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/header.jsp" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/housekeeping.css">
<style>
    /* ===================================
   MAINTENANCE ACTION BUTTON STATUS
=================================== */

    /* Nút Xử lý - Pending chưa có người nhận */
    .btn-task {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 6px;

        padding: 10px 18px;
        border-radius: 10px;

        font-size: 13px;
        font-weight: 700;

        text-decoration: none;
        transition: all .2s ease;
    }

    /* ==========================
       XỬ LÝ
    ========================== */
    .btn-task.process {
        background:#2563eb;
        color:white;
    }

    .btn-task.process:hover {
        background:#1d4ed8;
        transform:translateY(-2px);
    }


    /* ==========================
       TIẾP TỤC
    ========================== */
    .btn-task.continue {
        background:#f59e0b;
        color:white;
    }

    .btn-task.continue:hover {
        background:#d97706;
        transform:translateY(-2px);
    }


    /* ==========================
       ĐÃ HOÀN THÀNH
    ========================== */
    .btn-task.completed {
        background:#dcfce7;
        color:#166534;
        border:1px solid #bbf7d0;

        cursor:not-allowed;
    }


    /* ==========================
       ĐÃ CÓ NGƯỜI NHẬN
    ========================== */
    .btn-task.disabled {
        background:#f1f5f9;
        color:#64748b;
        border:1px solid #e2e8f0;

        cursor:not-allowed;
    }


    /* ==========================
       ĐÃ HỦY
    ========================== */
    .btn-task.cancelled {
        background:#fee2e2;
        color:#991b1b;
        border:1px solid #fecaca;

        cursor:not-allowed;
    }
</style>
<body class="dashboard-body"
      data-context-path="${pageContext.request.contextPath}">

    <c:set var="room" value="${room}" />
    <c:set var="status" value="${room.status}" />

    <div class="dashboard-layout">
        <aside class="dashboard-sidebar">
            <div class="sidebar-brand">
                <i class="fa-solid fa-hotel"></i>
                <span>HotelOps</span>
            </div>
            <ul class="sidebar-menu">
                <li class="menu-item">
                    <a href="${pageContext.request.contextPath}/housekeeping/dashboard?tab=overview">
                        <i class="fa-solid fa-table-cells-large"></i>
                        <span>Tổng quan</span>
                    </a>
                </li>
                <li class="menu-item">
                    <a href="${pageContext.request.contextPath}/housekeeping/dashboard?tab=task">
                        <i class="fa-solid fa-bed-pulse"></i>
                        <span>Sơ đồ phòng</span>
                    </a>
                </li>
                <li class="menu-item active">
                    <a href="${pageContext.request.contextPath}/housekeeping/handlemaintenance">
                        <i class="fa-solid fa-screwdriver-wrench"></i>
                        <span>Yêu cầu bảo trì</span>
                    </a>
                </li>
                <li class="menu-item">
                    <a href="${pageContext.request.contextPath}/housekeeping/reportIssue">
                        <i class="fa-solid fa-triangle-exclamation"></i>
                        <span>Báo cáo sự cố phòng</span>
                    </a>
                </li>
            </ul>
            <div class="sidebar-footer">
                <div class="menu-item">
                    <a href="#" style="display:flex;align-items:center;gap:12px;padding:12px 16px;color:#475569;text-decoration:none;font-weight:600;font-size:14px;">
                        <i class="fa-solid fa-gear"></i>
                        <span>Cài đặt</span>
                    </a>
                </div>
                <a href="${pageContext.request.contextPath}/profile" class="user-profile-card" title="Xem hồ sơ cá nhân" style="text-decoration:none;cursor:pointer;">
                    <div class="profile-avatar">HK</div>
                    <div class="profile-info">
                        <span class="profile-name">
                            ${not empty sessionScope.user ? sessionScope.user : 'Housekeeping'}
                        </span>
                        <span class="profile-role">Housekeeping</span>
                    </div>
                </a>
            </div>
        </aside>
        <div class="dashboard-main">

            <!-- HEADER -->
            <header class="main-topbar">
                <div class="breadcrumb">
                    <span>Quản trị</span>
                    <span class="separator">&gt;</span>
                    <span class="breadcrumb-link">
                        Yêu cầu bảo trì
                    </span>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </a>
            </header>

            <!-- CONTENT -->
            <main class="workspace-content">
                <div class="maintenance-wrapper">
                    <div class="page-header">
                        <h2>Yêu cầu bảo trì</h2>
                        <p>Theo dõi và xử lý các yêu cầu bảo trì từ khách hàng.</p>
                    </div>
                    <div class="maintenance-filter">
                        <a href="${pageContext.request.contextPath}/housekeeping/handlemaintenance?status=all"
                           class="filter-card ${currentStatus=='all'?'active':''}">
                            <span>Tất cả</span>
                            <strong>${countAll}</strong>
                        </a>
                        <a href="${pageContext.request.contextPath}/housekeeping/handlemaintenance?status=Pending"
                           class="filter-card ${currentStatus=='Pending'?'active':''}">
                            <span>Chờ xử lý</span>
                            <strong>${countPending}</strong>
                        </a>
                        <a href="${pageContext.request.contextPath}/housekeeping/handlemaintenance?status=InProgress"
                           class="filter-card ${currentStatus=='InProgress'?'active':''}">
                            <span>Đang xử lý</span>
                            <strong>${countInProgress}</strong>
                        </a>
                        <a href="${pageContext.request.contextPath}/housekeeping/handlemaintenance?status=Resolved"
                           class="filter-card ${currentStatus=='Resolved'?'active':''}">
                            <span>Hoàn thành</span>
                            <strong>${countResolved}</strong>
                        </a>
                        <a href="${pageContext.request.contextPath}/housekeeping/handlemaintenance?status=Unresolvable"
                           class="filter-card ${currentStatus=='Unresolvable'?'active':''}">
                            <span>Không thể xử lý ngay</span>
                            <strong>${countUnresolvable}</strong>
                        </a>
                        <a href="${pageContext.request.contextPath}/housekeeping/handlemaintenance?status=Cancelled"
                           class="filter-card filter-card-danger ${currentStatus=='Cancelled'?'active':''}">
                            <span>Đã hủy</span>
                            <strong>${countCancelled}</strong>
                        </a>
                    </div>
                    <div class="maintenance-table-card">
                        <table class="maintenance-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Phòng</th>
                                    <th>Khách hàng</th>
                                    <th>Vấn đề</th>
                                    <th>Mức độ</th>
                                    <th>Trạng thái</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${maintenanceRequests}" var="m">
                                    <tr>
                                        <td>#${m.requestId}</td>
                                        <td>${m.roomNumbers}</td>
                                        <td>${m.customer.fullName}</td>
                                        <td>${m.issueNames}</td>
                                        <td>
                                            <span class="priority-badge priority-${fn:toLowerCase(m.priority)}">
                                                ${m.priority}
                                            </span>
                                        </td>
                                        <td>
                                            <span class="status-badge status-${fn:toLowerCase(m.status)}">
                                                ${m.status}
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${m.status == 'Resolved'}">
                                                    <span class="btn-task completed">
                                                        <i class="fa-solid fa-circle-check"></i>
                                                        Đã hoàn thành
                                                    </span>
                                                </c:when>
                                                <c:when test="${m.status == 'Cancelled'}">
                                                    <span class="btn-task disabled">
                                                        Đã hủy
                                                    </span>
                                                </c:when>
                                                <c:when test="${m.status == 'Unresolvable'}">
                                                    <a class="btn-task continue"
                                                       href="${pageContext.request.contextPath}/housekeeping/handlemaintenance?action=detail&id=${m.requestId}">
                                                        Xử lý tiếp
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <a class="btn-task process"
                                                       href="${pageContext.request.contextPath}/housekeeping/handlemaintenance?action=detail&id=${m.requestId}">
                                                        Bắt đầu xử lý
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>

                        <div class="table-pagination-bar">
                            <div class="pagination-info">
                                <c:choose>
                                    <c:when test="${totalItems == 0}">Hiển thị 0 việc</c:when>
                                    <c:otherwise>Hiển thị ${(page-1)*pageSize + 1}-${page*pageSize gt totalItems ? totalItems : page*pageSize} trong số ${totalItems} việc</c:otherwise>
                                </c:choose>
                            </div>
                            <div class="pagination-controls">
                                <c:choose>
                                    <c:when test="${page > 1}">
                                        <c:url var="prevUrl" value="/housekeeping/handlemaintenance">
                                            <c:param name="status" value="${currentStatus}" />
                                            <c:param name="page" value="${page-1}" />
                                        </c:url>
                                        <a class="btn-page" href="${prevUrl}"><i class="fa-solid fa-chevron-left"></i></a>
                                    </c:when>
                                    <c:otherwise><span class="btn-page disabled"><i class="fa-solid fa-chevron-left"></i></span></c:otherwise>
                                </c:choose>
                                <c:forEach var="p" begin="1" end="${totalPages}">
                                    <c:url var="pUrl" value="/housekeeping/handlemaintenance">
                                        <c:param name="status" value="${currentStatus}" />
                                        <c:param name="page" value="${p}" />
                                    </c:url>
                                    <a class="btn-page ${p == page ? 'active' : ''}" href="${pUrl}">${p}</a>
                                </c:forEach>
                                <c:choose>
                                    <c:when test="${page < totalPages}">
                                        <c:url var="nextUrl" value="/housekeeping/handlemaintenance">
                                            <c:param name="status" value="${currentStatus}" />
                                            <c:param name="page" value="${page+1}" />
                                        </c:url>
                                        <a class="btn-page" href="${nextUrl}"><i class="fa-solid fa-chevron-right"></i></a>
                                    </c:when>
                                    <c:otherwise><span class="btn-page disabled"><i class="fa-solid fa-chevron-right"></i></span></c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
            <footer class="dashboard-footer">
                <span>© 2026 HotelOps Luxury Management.</span>
            </footer>
        </div>
    </div>

</body>