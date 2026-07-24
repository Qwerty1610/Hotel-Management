<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/header.jsp" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/housekeeping.css">
<style>
    .maintenance-detail-wrapper{
        max-width:1200px;
        margin:auto;
    }

    .detail-grid{
        display:grid;
        grid-template-columns:1fr 1fr;
        gap:24px;
        margin-bottom:24px;
    }

    .detail-card{
        background:#fff;
        border-radius:14px;
        padding:24px;
        box-shadow:0 2px 10px rgba(0,0,0,.05);
    }

    .detail-card h3{
        margin-bottom:18px;
        font-size:18px;
    }

    .detail-row{
        display:flex;
        justify-content:space-between;
        padding:12px 0;
        border-bottom:1px solid #eee;
    }

    .detail-row label{
        color:#64748b;
        font-weight:600;
    }

    .description-box{
        background:#f8fafc;
        border-radius:10px;
        padding:18px;
        min-height:150px;
        white-space:pre-wrap;
    }

    .form-control{
        width:100%;
        border:1px solid #dbe2ea;
        border-radius:10px;
        padding:12px;
        resize:vertical;
    }

    .action-buttons{
        margin-top:20px;
        display:flex;
        gap:12px;
    }

    .btn-primary,
    .btn-success,
    .btn-danger{
        border:none;
        color:white;
        padding:10px 18px;
        border-radius:8px;
        cursor:pointer;
        font-weight:600;
        transition:background .2s ease, transform .2s ease;
    }

    .btn-primary{
        background:#2563eb;
    }

    .btn-primary:hover{
        background:#1d4ed8;
        transform:translateY(-2px);
    }

    .btn-success{
        background:#16a34a;
    }

    .btn-success:hover{
        background:#15803d;
        transform:translateY(-2px);
    }

    .btn-danger{
        background:#dc2626;
    }

    .btn-danger:hover{
        background:#b91c1c;
        transform:translateY(-2px);
    }

    .btn-secondary{
        border:1px solid #dbe2ea;
        color:#475569;
        background:#fff;
        padding:10px 18px;
        border-radius:8px;
        cursor:pointer;
        font-weight:600;
        text-decoration:none;
        display:inline-flex;
        align-items:center;
        gap:8px;
        transition:background .2s ease, transform .2s ease;
    }

    .btn-secondary:hover{
        background:#f1f5f9;
        transform:translateY(-2px);
    }
    .status-badge{
        display:inline-flex;
        align-items:center;
        padding:6px 14px;
        border-radius:999px;
        font-size:12px;
        font-weight:700;
        text-transform:uppercase;
    }

    /* Pending */
    .status-pending{
        background:#fef3c7;
        color:#92400e;
    }

    /* In Progress */
    .status-inprogress{
        background:#dbeafe;
        color:#1d4ed8;
    }

    /* Resolved */
    .status-resolved{
        background:#dcfce7;
        color:#166534;
    }

    /* Unresolvable */
    .status-unresolvable{
        background:#fee2e2;
        color:#991b1b;
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
                    <a href="${pageContext.request.contextPath}/housekeeping/handlemaintenance"
                       class="breadcrumb-link">
                        Yêu cầu bảo trì
                    </a>
                    <span class="separator">&gt;</span>
                    <span class="current">
                        Yêu cầu #${maintenance.requestId}
                    </span>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </a>
            </header>

            <!-- CONTENT -->
            <main class="workspace-content">
                <div class="maintenance-detail-wrapper">
                    <!-- Tiêu đề -->
                    <div class="page-header">
                        <div>
                            <h2>Yêu cầu bảo trì #${maintenance.requestId}</h2>
                            <p>Chi tiết yêu cầu và trạng thái xử lý.</p>
                        </div>
                    </div>
                    <!-- Thông tin -->
                    <div class="detail-grid">
                        <div class="detail-card">
                            <h3>Thông tin yêu cầu</h3>
                            <div class="detail-row">
                                <label>Phòng</label>
                                <span>${maintenance.roomNumbers}</span>
                            </div>
                            <div class="detail-row">
                                <label>Khách hàng</label>
                                <span>${maintenance.customer.fullName}</span>
                            </div>
                            <div class="detail-row">
                                <label>Loại sự cố</label>
                                <span>${maintenance.issueNames}</span>
                            </div>
                            <div class="detail-row">
                                <label>Mức ưu tiên</label>
                                <span class="priority-badge priority-${fn:toLowerCase(maintenance.priority)}">
                                    <c:choose>
                                        <c:when test="${maintenance.priority == 'Urgent'}">Khẩn cấp</c:when>
                                        <c:when test="${maintenance.priority == 'High'}">Cao</c:when>
                                        <c:when test="${maintenance.priority == 'Medium'}">Trung bình</c:when>
                                        <c:when test="${maintenance.priority == 'Low'}">Thấp</c:when>
                                        <c:otherwise>${maintenance.priority}</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                            <div class="detail-row">
                                <label>Ngày tạo</label>
                                <span>${maintenance.createdAt}</span>
                            </div>
                        </div>
                        <div class="detail-card">
                            <h3>Mô tả của khách</h3>
                            <div class="description-box">${maintenance.description}</div>
                        </div>
                    </div>
                    <!-- Người xử lý -->
                    <div class="detail-card">
                        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:18px;">
                            <h3 style="margin:0;">
                                Thông tin xử lý
                            </h3>

                            <span class="status-badge status-${fn:toLowerCase(maintenance.status)}">
                                <c:choose>
                                    <c:when test="${maintenance.status == 'Pending'}">Chờ xử lý</c:when>
                                    <c:when test="${maintenance.status == 'InProgress'}">Đang xử lý</c:when>
                                    <c:when test="${maintenance.status == 'Resolved'}">Đã xử lý</c:when>
                                    <c:when test="${maintenance.status == 'Unresolvable'}">Không thể xử lý</c:when>
                                    <c:when test="${maintenance.status == 'Cancelled'}">Đã huỷ</c:when>
                                    <c:otherwise>${maintenance.status}</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <div class="detail-row">
                            <label>Nhân viên phụ trách</label>
                            <span>
                                <c:choose>
                                    <c:when test="${maintenance.assignedStaff != null}">
                                        ${maintenance.assignedStaff.fullName}
                                    </c:when>
                                    <c:otherwise>
                                        Chưa có
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <div class="detail-row">
                            <label>
                                Ghi chú xử lý
                                <span id="noteError" style="color:#dc2626;font-size:12px;margin-left:8px;display:none;">
                                    * Vui lòng nhập lý do
                                </span>
                            </label>
                        </div>
                        <form method="post"
                              action="${pageContext.request.contextPath}/housekeeping/handlemaintenance">
                            <input type="hidden"
                                   name="requestId"
                                   value="${maintenance.requestId}">
                            <textarea
                                id="resolutionNote"
                                name="resolutionNote"
                                rows="5"
                                class="form-control"
                                placeholder="Nhập kết quả xử lý...">${maintenance.resolutionNote}</textarea>
                            <div class="action-buttons">
                                <c:if test="${maintenance.status=='InProgress' || maintenance.status=='Unresolvable'}">

                                    <button
                                        class="btn-success"
                                        type="submit"
                                        name="action"
                                        value="resolve">
                                        <i class="fa-solid fa-circle-check"></i>
                                        Hoàn thành
                                    </button>
                                    <c:if test="${maintenance.status!='Unresolvable'}">
                                        <button
                                            id="btnUnresolvable"
                                            class="btn-danger"
                                            type="submit"
                                            name="action"
                                            value="unresolvable">
                                            <i class="fa-solid fa-ban"></i>
                                            Không thể xử lý
                                        </button>
                                    </c:if>
                                </c:if>
                                <a href="${pageContext.request.contextPath}/housekeeping/handlemaintenance"
                                   class="btn-secondary"
                                   style="margin-left:auto;">
                                    <i class="fa-solid fa-arrow-left"></i>
                                    Quay lại
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </main>
            <footer class="dashboard-footer">
                <span>© 2026 HotelOps Luxury Management.</span>
            </footer>
        </div>
    </div>
    <script>
        document.addEventListener("DOMContentLoaded", function () {

            const form = document.querySelector("form");
            const note = document.getElementById("resolutionNote");
            const error = document.getElementById("noteError");
            const btnUnresolvable = document.getElementById("btnUnresolvable");


            if (btnUnresolvable) {

                btnUnresolvable.addEventListener("click", function (e) {

                    if (note.value.trim() === "") {

                        e.preventDefault();

                        error.style.display = "inline";

                        note.style.borderColor = "#dc2626";

                        note.focus();

                    } else {

                        error.style.display = "none";

                        note.style.borderColor = "#dbe2ea";
                    }

                });

            }

            note.addEventListener("input", function () {

                if (note.value.trim() !== "") {

                    error.style.display = "none";

                    note.style.borderColor = "#dbe2ea";

                }

            });

        });
    </script>
</body>