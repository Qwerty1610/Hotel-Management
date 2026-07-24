<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/header.jsp" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/housekeeping.css">

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
                <li class="menu-item active">
                    <a href="${pageContext.request.contextPath}/housekeeping/dashboard?tab=task">
                        <i class="fa-solid fa-bed-pulse"></i>
                        <span>Sơ đồ phòng</span>
                    </a>
                </li>
                <li class="menu-item">
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
                    <a href="${pageContext.request.contextPath}/housekeeping/dashboard?tab=task"
                       class="breadcrumb-link">
                        Sơ đồ trạng thái phòng
                    </a>
                    <span class="separator">&gt;</span>
                    <span class="current">
                        Phòng ${room.roomNumber}
                    </span>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </a>
            </header>

            <!-- CONTENT -->
            <main class="workspace-content">

                <div class="task-card-wrapper">

                    <div class="task-card">

                        <!-- HEADER -->
                        <div class="task-card-header">
                            <div>
                                <h2>Phòng ${room.roomNumber}</h2>
                                <p>${room.typeName}</p>
                            </div>

                            <span class="status-pill
                                  ${status == 'OutOfService' ? 'status-outofservice' : ''}
                                  ${status == 'Available' ? 'status-available' : ''}
                                  ${status == 'Cleaning' ? 'status-cleaning' : ''}
                                  ${status == 'Refilling' ? 'status-refilling' : ''}
                                  ${status == 'Maintenance' ? 'status-maintenance' : ''}
                                  ${status == 'Completed' ? 'status-completed' : ''}">
                                <c:choose>
                                    <c:when test="${status == 'OutOfService'}">Ngừng hoạt động</c:when>
                                    <c:when test="${status == 'Available'}">Sẵn sàng</c:when>
                                    <c:when test="${status == 'Cleaning'}">Đang dọn phòng</c:when>
                                    <c:when test="${status == 'Refilling'}">Đang bổ sung vật dụng</c:when>
                                    <c:when test="${status == 'Maintenance'}">Bảo trì</c:when>
                                    <c:when test="${status == 'Completed'}">Đã hoàn thành</c:when>
                                    <c:otherwise>${status}</c:otherwise>
                                </c:choose>
                            </span>
                        </div>

                        <!-- IMAGE -->
                        <div class="task-card-image">
                            <img src="${not empty room.imageUrl 
                                        ? room.imageUrl 
                                        : pageContext.request.contextPath.concat('/assets/img/room-default.jpg')}"
                                 alt="Room Image">
                        </div>

                        <!-- BODY -->
                        <div class="task-card-body">

                            <c:choose>

                                <c:when test="${status == 'OutOfService'}">

                                    <div class="issue-section">
                                        <h3 class="issue-title">
                                            Trạng thái phòng
                                        </h3>

                                        <div class="empty-issue outofservice-message">
                                            <i class="fa-solid fa-ban"></i>
                                            Phòng đang ngừng hoạt động.
                                        </div>
                                    </div>

                                </c:when>

                                <c:otherwise>

                                    <div class="issue-section">
                                        <h3 class="issue-title">
                                            Danh sách sự cố phòng
                                        </h3>

                                        <c:choose>
                                            <c:when test="${empty issues}">
                                                <div class="empty-issue">
                                                    Không có sự cố nào cho phòng này.
                                                </div>
                                            </c:when>

                                            <c:otherwise>

                                                <div class="issue-table-wrapper">
                                                    <table class="issue-table">
                                                        <thead>
                                                            <tr>
                                                                <th>ID</th>
                                                                <th>Loại sự cố</th>
                                                                <th>Mức độ</th>
                                                                <th>Mô tả</th>
                                                                <th>Ghi chú</th>
                                                                <th>Trạng thái</th>
                                                                <th>Thao tác</th>
                                                            </tr>
                                                        </thead>

                                                        <tbody>
                                                            <c:forEach var="issue" items="${issues}">
                                                                <tr>
                                                                    <td>${issue.issueId}</td>
                                                                    <td>
                                                                        <c:choose>
                                                                            <c:when test="${issue.issueType == 'Damage'}">Hỏng hóc</c:when>
                                                                            <c:when test="${issue.issueType == 'Refill'}">Thiếu vật tư</c:when>
                                                                            <c:when test="${issue.issueType == 'Cleaning'}">Cần dọn dẹp</c:when>
                                                                            <c:when test="${issue.issueType == 'Other'}">Khác</c:when>
                                                                            <c:otherwise>${issue.issueType}</c:otherwise>
                                                                        </c:choose>
                                                                    </td>
                                                                    <td>
                                                                        <c:choose>
                                                                            <c:when test="${issue.severity == 'Low'}">Thấp</c:when>
                                                                            <c:when test="${issue.severity == 'Medium'}">Trung bình</c:when>
                                                                            <c:when test="${issue.severity == 'High'}">Cao</c:when>
                                                                            <c:otherwise>${issue.severity}</c:otherwise>
                                                                        </c:choose>
                                                                    </td>
                                                                    <td>${issue.description}</td>
                                                                    <td>
                                                                        ${empty issue.note ? '-' : issue.note}
                                                                    </td>

                                                                    <td>
                                                                        <span class="issue-status ${issue.status == 'Pending' ? 'pending' : 'success'}">
                                                                            <c:choose>
                                                                                <c:when test="${issue.status == 'Pending'}">Chờ xử lý</c:when>
                                                                                <c:otherwise>Đã hoàn thành</c:otherwise>
                                                                            </c:choose>
                                                                        </span>
                                                                    </td>

                                                                    <td>
                                                                        <c:choose>

                                                                            <c:when test="${issue.status == 'Pending'}">

                                                                                <form method="post"
                                                                                      action="${pageContext.request.contextPath}/housekeeping/taskDetail">

                                                                                    <input type="hidden"
                                                                                           name="issueId"
                                                                                           value="${issue.issueId}">

                                                                                    <input type="hidden"
                                                                                           name="roomId"
                                                                                           value="${room.roomId}">

                                                                                    <input type="hidden"
                                                                                           name="issueType"
                                                                                           value="${issue.issueType}">

                                                                                    <input type="hidden"
                                                                                           name="severity"
                                                                                           value="${issue.severity}">

                                                                                    <button type="submit"
                                                                                            class="btn-complete">
                                                                                        Hoàn thành
                                                                                    </button>

                                                                                </form>

                                                                            </c:when>

                                                                            <c:otherwise>

                                                                                <span class="completed-text">
                                                                                    Đã hoàn thành
                                                                                </span>

                                                                            </c:otherwise>

                                                                        </c:choose>
                                                                    </td>
                                                                </tr>
                                                            </c:forEach>
                                                        </tbody>

                                                    </table>
                                                </div>

                                            </c:otherwise>

                                        </c:choose>

                                    </div>

                                </c:otherwise>

                            </c:choose>

                            <div class="task-buttons-bottom">
                                <a href="${pageContext.request.contextPath}/housekeeping/dashboard?tab=task"
                                   class="btn-task secondary">
                                    Quay lại
                                </a>
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

    <script>
        function openConfirmModal() {
            document.getElementById("confirmModal").style.display = "flex";
        }

        function closeConfirmModal() {
            document.getElementById("confirmModal").style.display = "none";
        }

        function submitComplete() {
            document.getElementById("completeForm").submit();
        }

        window.onclick = function (e) {
            const modal = document.getElementById("confirmModal");
            if (e.target === modal)
                closeConfirmModal();
        };
    </script>

</body>