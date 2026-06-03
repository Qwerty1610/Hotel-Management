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

                            <!-- ACTION -->
                            <div class="task-action">

                                <!-- NO WORK -->
                                <c:if test="${status == 'Occupied' or status == 'Available'}">
                                    <button class="btn-task disabled" disabled>
                                        No work yet
                                    </button>
                                </c:if>

                                <!-- CAN COMPLETE -->
                                <c:if test="${status == 'Cleaning' or status == 'Maintenance'}">

                                    <button type="button"
                                            class="btn-task success"
                                            onclick="openConfirmModal()">
                                        Complete
                                    </button>

                                    <form id="completeForm"
                                          method="post"
                                          action="${pageContext.request.contextPath}/housekeeping/task"
                                          style="display:none;">
                                        <input type="hidden" name="roomId" value="${room.roomId}" />
                                    </form>

                                </c:if>

                                <!-- COMPLETED -->
                                <c:if test="${status == 'Completed'}">
                                    <button class="btn-task completed" disabled>
                                        Completed
                                    </button>
                                </c:if>

                            </div>

                        </div>
                    </div>

                </div>

            </main>

        </div>
    </div>

    <!-- CONFIRM MODAL -->
    <div id="confirmModal" class="modal-overlay">
        <div class="modal-container">

            <div class="modal-header">
                <h3>Confirm Action</h3>
                <button class="btn-close-modal" onclick="closeConfirmModal()">×</button>
            </div>

            <div class="modal-body">
                <p>Are you sure you want to mark this room as <b>Completed</b>?</p>
            </div>

            <div class="modal-footer-row">

                <button class="btn-modal-cancel" onclick="closeConfirmModal()">
                    Cancel
                </button>

                <button class="btn-modal-submit" onclick="submitComplete()">
                    Yes, Complete
                </button>

            </div>

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