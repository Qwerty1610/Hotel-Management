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
                        <span>Trạng thái phòng</span>
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
                    <span class="current">
                        <c:choose>
                            <c:when test="${param.tab == 'task'}">Trạng thái phòng</c:when>
                            <c:otherwise>Tổng quan</c:otherwise>
                        </c:choose>
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
                                <h2>Room ${room.roomNumber}</h2>
                                <p>${room.typeName}</p>
                            </div>

                            <span class="status-pill 
                                  ${status == 'OutOfService' ? 'status-outofservice' : ''}
                                  ${status == 'Available' ? 'status-available' : ''}
                                  ${status == 'Cleaning' ? 'status-cleaning' : ''}
                                  ${status == 'Maintenance' ? 'status-maintenance' : ''}
                                  ${status == 'Completed' ? 'status-completed' : ''}">
                                ${status}
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

                            <div class="task-info-grid">
                                <div>
                                    <label>Room Name</label>
                                    <span>${room.typeName}</span>
                                </div>

                                <div>
                                    <label>Room Number</label>
                                    <span>${room.roomNumber}</span>
                                </div>
                            </div>

                            <div class="task-action">

                                <form method="post"
                                      action="${pageContext.request.contextPath}/housekeeping/task"
                                      class="task-form">

                                    <input type="hidden" name="roomId" value="${room.roomId}">

                                    <div class="status-update-group">
                                        <label>Status</label>

                                        <c:choose>

                                            <c:when test="${status == 'OutOfService'}">
                                                <div class="status-message">
                                                    Phòng đang ngừng hoạt động
                                                </div>
                                            </c:when>

                                            <c:otherwise>
                                                <select name="status" class="status-select">

                                                    <option value="Available" ${status == 'Available' ? 'selected' : ''}>
                                                        Available
                                                    </option>

                                                    <option value="Cleaning" ${status == 'Cleaning' ? 'selected' : ''}>
                                                        Cleaning
                                                    </option>

                                                    <option value="Maintenance" ${status == 'Maintenance' ? 'selected' : ''}>
                                                        Maintenance
                                                    </option>

                                                </select>
                                            </c:otherwise>

                                        </c:choose>
                                    </div>
                                    <div class="task-buttons">
                                        <button type="button"
                                                class="btn-task secondary"
                                                onclick="history.back()">
                                            Back
                                        </button>

                                        <c:if test="${status != 'OutOfService'}">
                                            <button type="submit" class="btn-task success">
                                                Save
                                            </button>
                                        </c:if>
                                    </div>

                                </form>

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