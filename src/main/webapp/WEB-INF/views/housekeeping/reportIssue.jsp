<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/header.jsp" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/housekeeping.css">

<body class="dashboard-body"
      data-context-path="${pageContext.request.contextPath}">

    <!-- POPUP MESSAGE -->
    <div id="popupMessage" class="popup-message">
        <span id="popupText"></span>
    </div>

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
                <li class="menu-item">
                    <a href="${pageContext.request.contextPath}/housekeeping/handlemaintenance">
                        <i class="fa-solid fa-screwdriver-wrench"></i>
                        <span>Yêu cầu bảo trì</span>
                    </a>
                </li>
                <li class="menu-item active">
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
                    <span class="current">
                        Báo cáo sự cố phòng
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
                                <div class="report-title">
                                    <h2>
                                        Báo cáo sự cố phòng
                                        <span id="validateMessage" class="issue-warning" style="display:none;"></span>
                                    </h2>
                                    <c:if test="${not empty duplicateIssueMessage}">
                                        <span class="issue-warning">
                                            ${duplicateIssueMessage}
                                        </span>
                                    </c:if>
                                </div>
                            </div>
                        </div>

                        <!-- BODY -->
                        <div class="task-card-body">
                            <c:if test="${not empty sessionScope.successMessage}">
                                <script>
                                    window.addEventListener("load", function () {
                                        showPopup(
                                                "${fn:escapeXml(sessionScope.successMessage)}",
                                                "success"
                                                );
                                    });
                                </script>
                                <c:remove var="successMessage" scope="session"/>
                            </c:if>

                            <c:if test="${not empty sessionScope.errorMessage}">
                                <script>
                                    window.addEventListener("load", function () {
                                        showPopup(
                                                "${fn:escapeXml(sessionScope.errorMessage)}"
                                                );
                                    });
                                </script>
                                <c:remove var="errorMessage" scope="session"/>
                            </c:if>
                            <form method="post"
                                  action="${pageContext.request.contextPath}/housekeeping/reportIssue"
                                  class="task-form">
                                <!-- SỐ PHÒNG -->
                                <div class="report-row room-row">
                                    <div class="form-group">
                                        <label>
                                            Số phòng <span style="color:red">*</span>
                                        </label>
                                        <select name="roomId"
                                                class="status-select"
                                                >
                                            <option value="">
                                                -- Chọn số phòng --
                                            </option>
                                            <c:forEach items="${rooms}" var="room">
                                                <option value="${room.roomId}">
                                                    ${room.roomNumber}
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <button type="button"
                                            class="btn-task success"
                                            onclick="addIssueRow()">
                                        + Thêm sự cố
                                    </button>
                                </div>

                                <!-- DANH SÁCH SỰ CỐ -->
                                <div id="issueContainer">
                                    <div class="issue-row">
                                        <div class="form-group">
                                            <label>
                                                Loại sự cố
                                            </label>
                                            <select name="issueType"
                                                    class="status-select issue-type"
                                                    >
                                                <option value="">
                                                    -- Chọn sự cố --
                                                </option>
                                                <option value="Damage">
                                                    Hỏng hóc
                                                </option>
                                                <option value="Refill">
                                                    Thiếu vật tư
                                                </option>
                                                <option value="Cleaning">
                                                    Cần dọn dẹp
                                                </option>
                                                <option value="Other">
                                                    Khác
                                                </option>
                                            </select>
                                        </div>
                                        <div class="form-group">
                                            <label>
                                                Mức độ
                                            </label>
                                            <select name="severity"
                                                    class="status-select severity"
                                                    >
                                                <option value="">
                                                    -- Chọn mức độ --
                                                </option>
                                                <option value="Low">
                                                    Thấp
                                                </option>
                                                <option value="Medium">
                                                    Trung bình
                                                </option>
                                                <option value="High">
                                                    Cao
                                                </option>
                                            </select>
                                        </div>
                                        <div class="form-group description-box">
                                            <label>
                                                Mô tả
                                            </label>
                                            <textarea name="description"
                                                      rows="2"
                                                      ></textarea>
                                        </div>
                                        <button type="button"
                                                class="remove-btn"
                                                onclick="removeIssueRow(this)">
                                            X
                                        </button>
                                    </div>
                                </div>
                                <!-- GHI CHÚ -->
                                <div class="form-group note-box">
                                    <label>
                                        Ghi chú
                                    </label>
                                    <textarea name="note"
                                              rows="3"></textarea>
                                </div>
                                <div class="task-buttons">
                                    <button type="submit"
                                            class="btn-task success">
                                        Gửi báo cáo
                                    </button>
                                </div>
                            </form>
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
        function updateSeverity(select) {
            const row = select.closest(".issue-row");
            const severity =
                    row.querySelector(".severity");
            switch (select.value) {
                case "Damage":
                    severity.value = "High";
                    severity.disabled = true;
                    break;
                case "Refill":
                    severity.value = "Medium";
                    severity.disabled = true;
                    break;
                case "Cleaning":
                    severity.value = "Low";
                    severity.disabled = true;
                    break;
                case "Other":
                    severity.disabled = false;
                    severity.value = "";
                    break;
                default:
                    severity.value = "";
                    severity.disabled = true;
                    break;
            }
        }

        window.addEventListener("load", function () {
            document
                    .querySelectorAll(".issue-row")
                    .forEach(row => {
                        bindIssueEvent(row);
                    });
        });

        function addIssueRow() {
            const container =
                    document.getElementById("issueContainer");
            const row =
                    document.createElement("div");
            row.className = "issue-row";
            row.innerHTML = `

        <div class="form-group">
            <label>Loại sự cố</label>
            <select name="issueType"
                    class="status-select issue-type"
                    >
                <option value="">
                    -- Chọn sự cố--
                </option>
                <option value="Damage">
                    Hỏng hóc
                </option>
                <option value="Refill">
                    Thiếu vật tư
                </option>
                <option value="Cleaning">
                    Cần dọn dẹp
                </option>
                <option value="Other">
                    Khác
                </option>
            </select>
        </div>
        <div class="form-group">
            <label>Mức độ</label>
            <select name="severity"
                    class="status-select severity"
                    >
                <option value="">
                    -- Chọn mức độ--
                </option>
                <option value="Low">
                    Thấp
                </option>
                <option value="Medium">
                    Trung bình
                </option>
                <option value="High">
                    Cao
                </option>
            </select>
        </div>
        <div class="form-group description-box">

            <label>Mô tả</label>

            <textarea name="description"
                      rows="2">
            </textarea>
        </div>
        <button type="button"
                class="remove-btn"
                onclick="removeIssueRow(this)">
            X
        </button>
    `;
            container.appendChild(row);
            bindIssueEvent(row);
        }

        function removeIssueRow(btn) {
            const rows =
                    document.querySelectorAll(".issue-row");
            if (rows.length > 1) {
                btn.parentElement.remove();
            }
        }

        function bindIssueEvent(row) {
            const issueType =
                    row.querySelector(".issue-type");
            if (issueType) {
                issueType.addEventListener(
                        "change",
                        function () {
                            updateSeverity(this);
                        }
                );
            }
        }

        document.querySelector(".task-form")
                .addEventListener("submit", function (e) {
                    const roomId =
                            document.querySelector("select[name='roomId']").value;
                    const issueRows =
                            document.querySelectorAll(".issue-row");
                    let valid = true;
                    if (roomId === "") {
                        valid = false;
                    }
                    document.querySelectorAll(".severity")
                            .forEach(select => {
                                select.disabled = false;
                            });

                    issueRows.forEach(row => {
                        const type =
                                row.querySelector("select[name='issueType']").value;
                        const severity =
                                row.querySelector("select[name='severity']").value;
                        const description =
                                row.querySelector("textarea[name='description']").value.trim();
                        if (type === "" || severity === "" || description === "") {
                            valid = false;
                        }
                    });

                    if (!valid) {
                        e.preventDefault();
                        showValidateMessage(
                                "Vui lòng điền đầy đủ thông tin sự cố!"
                                );
                    }
                });

        function showValidateMessage(message) {
            const span =
                    document.getElementById("validateMessage");
            span.innerText = message;
            span.style.display = "inline";
            setTimeout(() => {
                span.style.display = "none";
            }, 3000);
        }

        function showPopup(message, type = "error") {
            const popup =
                    document.getElementById("popupMessage");
            const text =
                    document.getElementById("popupText");
            text.innerText = message;
            popup.classList.remove("success");
            if (type === "success") {
                popup.classList.add("success");
            }
            popup.classList.add("show");
            setTimeout(() => {
                popup.classList.remove("show");
            }, 3000);
        }
    </script>

</body>