<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/housekeeping.css">

<body class="dashboard-body"
      data-context-path="${pageContext.request.contextPath}">

    <c:set var="room" value="${room}" />
    <c:set var="status" value="${room.status}" />

    <div class="dashboard-layout">

        <div class="dashboard-main" style="margin-left:0;">

            <!-- BACK NAV -->
            <header class="main-topbar">
                <a href="${pageContext.request.contextPath}/housekeeping/dashboard?tab=task"
                   class="btn-logout"
                   style="display:flex;align-items:center;gap:8px;">
                    <i class="fa-solid fa-arrow-left"></i>
                    Back
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
                                  ${status == 'Occupied' ? 'status-occupied' : ''}
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

                                <div>
                                    <label>Description</label>
                                    <span class="muted">Chưa có dữ liệu</span>
                                </div>

                                <div>
                                    <label>Work Description</label>
                                    <span class="muted">Chưa triển khai</span>
                                </div>
                            </div>

                            <div class="task-action">

                                <form method="post"
                                      action="${pageContext.request.contextPath}/housekeeping/task"
                                      class="task-form">

                                    <input type="hidden" name="roomId" value="${room.roomId}">

                                    <div class="status-update-group">
                                        <label>Status</label>

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

                                            <option value="Occupied" ${status == 'Occupied' ? 'selected' : ''}>
                                                Occupied
                                            </option>

                                        </select>
                                    </div>

                                    <button type="submit" class="btn-task success">
                                        Save
                                    </button>

                                </form>

                            </div>

                        </div>
                    </div>

                </div>

            </main>

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