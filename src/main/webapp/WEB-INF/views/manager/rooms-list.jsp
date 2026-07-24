<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=4" />
<fmt:setLocale value="vi_VN" />

<body class="dashboard-body">

    <c:set var="activePage" value="rooms" scope="request" />

    <div class="dashboard-layout">

        <%-- SIDEBAR --%>
        <jsp:include page="sidebar.jsp" />

        <%-- MAIN CONTENT --%>
        <div class="dashboard-main">

            <%-- TOP HEADER BAR --%>
            <header class="main-topbar">
                <div class="breadcrumb">
                    <span>Quản trị</span>
                    <span class="separator">&gt;</span>
                    <span class="current">Quản lý phòng</span>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </a>
            </header>

            <%-- PAGE CONTENT --%>
            <main class="workspace-content">

                <%-- Hidden data container for room database records --%>
                <div id="roomDataStorage" style="display: none;">
                    <c:forEach var="r" items="${roomsList}">
                        <div class="room-data-item" data-id="${r.roomId}"
                            data-number="<c:out value="${r.roomNumber}" />"
                            data-type-id="${r.typeId}"
                            data-status="<c:out value="${r.status}" />"
                            data-operational-status="<c:out value="${r.operationalStatus}" />"
                            data-display-status="<c:out value="${r.displayStatus}" />"
                            data-currently-occupied="${r.currentlyOccupied}"
                            data-has-future-booking="${r.hasActiveOrFutureBooking}"
                            data-floor="<c:out value="${r.floor}" />"
                            data-type-name="<c:out value="${r.typeName}" />"
                            data-base-price="${r.basePrice}"
                            data-bed-type="<c:out value="${r.bedType}" />"
                            data-area="<c:out value="${r.area}" />">
                        </div>
                    </c:forEach>
                </div>

                <%-- Alert messages --%>
                <c:if test="${param.error eq 'duplicateNumber'}">
                    <div class="alert-banner alert-danger">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        Số phòng này đã tồn tại trong hệ thống. Vui lòng chọn số khác.
                    </div>
                </c:if>
                <c:if test="${param.error eq 'roomHasActiveOrFutureBooking'}">
                    <div class="alert-banner alert-danger">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        Không thể xóa phòng vì phòng đang được sử dụng hoặc đã được phân cho một đơn đặt phòng trong tương lai.
                    </div>
                </c:if>
                <c:if test="${param.error eq 'deleteError'}">
                    <div class="alert-banner alert-danger">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        Không thể xóa phòng này vì phòng đang được sử dụng, có lịch đặt trong tương lai, hoặc ở trạng thái không khả dụng.
                    </div>
                </c:if>
                <c:if test="${param.error eq 'roomCurrentlyOccupied'}">
                    <div class="alert-banner alert-danger">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        Không thể thay đổi trạng thái phòng vì phòng hiện đang có khách lưu trú.
                    </div>
                </c:if>
                <c:if test="${param.error eq 'invalidStatus'}">
                    <div class="alert-banner alert-danger">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        Trạng thái phòng không hợp lệ.
                    </div>
                </c:if>
                <c:if test="${param.error eq 'saveError'}">
                    <div class="alert-banner alert-danger">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        Đã xảy ra lỗi khi lưu thông tin phòng. Vui lòng thử lại sau.
                    </div>
                </c:if>
                <c:if test="${param.success eq 'saved'}">
                    <div class="alert-banner alert-success">
                        <i class="fa-solid fa-circle-check"></i>
                        Lưu thông tin phòng thành công.
                    </div>
                </c:if>
                <c:if test="${param.success eq 'deleted'}">
                    <div class="alert-banner alert-success">
                        <i class="fa-solid fa-circle-check"></i>
                        Xóa phòng thành công.
                    </div>
                </c:if>

                <div class="content-header-row">
                    <div>
                        <h1>Quản lý danh sách phòng</h1>
                        <p>Hệ thống vận hành và điều phối phòng lưu trú khách sạn.</p>
                    </div>
                    <button class="btn-add-service" onclick="openAddRoomModal()">
                        <i class="fa-solid fa-plus"></i> Thêm phòng mới
                    </button>
                </div>

                <%-- Rooms Table Wrapper --%>
                <div class="table-card">

                    <%-- Search & Dropdown Filters Bar --%>
                    <div class="table-filter-bar" style="display: grid; grid-template-columns: 1.2fr 0.9fr 1fr 1fr 1fr; gap: 12px; align-items: end;">
                        <div class="modal-form-group" style="margin-bottom: 0;">
                            <label>Tìm kiếm phòng</label>
                            <div class="search-wrapper" style="max-width: 100%;">
                                <i class="fa-solid fa-magnifying-glass"></i>
                                <input type="text" id="roomSearch" class="input-search-service" placeholder="Nhập số phòng..." onkeyup="filterRooms()" />
                            </div>
                        </div>

                        <div class="modal-form-group" style="margin-bottom: 0;">
                            <label>Tầng</label>
                            <select id="floorFilter" class="status-select" onchange="filterRooms()" style="width: 100%;">
                                <option value="all">Tất cả tầng</option>
                                <option value="Tầng 1">Tầng 1</option>
                                <option value="Tầng 2">Tầng 2</option>
                                <option value="Tầng 3">Tầng 3</option>
                                <option value="Tầng 4">Tầng 4</option>
                            </select>
                        </div>

                        <div class="modal-form-group" style="margin-bottom: 0;">
                            <label>Loại phòng</label>
                            <select id="roomTypeFilter" class="status-select" onchange="filterRooms()" style="width: 100%;">
                                <option value="all">Tất cả loại</option>
                                <c:forEach var="rt" items="${roomTypesList}">
                                    <option value="${rt.typeId}">
                                        <c:out value="${rt.typeName}" />
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="modal-form-group" style="margin-bottom: 0;">
                            <label>Ngày kiểm tra</label>
                            <input type="date" id="selectedDateInput" class="date-filter-input" value="${selectedDate}" onchange="changeSelectedDate(this.value)" style="width: 100%;" />
                        </div>

                        <div class="modal-form-group" style="margin-bottom: 0;">
                            <label>Trạng thái</label>
                            <select id="statusFilter" class="status-select" onchange="filterRooms()" style="width: 100%;">
                                <option value="all">Tất cả trạng thái</option>
                                <option value="Available">Trống</option>
                                <option value="Confirmed">Đã đặt</option>
                                <option value="Occupied">Có khách</option>
                                <option value="Cleaning">Đang dọn</option>
                                <option value="Refilling">Đang bổ sung vật dụng</option>
                                <option value="Maintenance">Bảo trì</option>
                                <option value="OutOfService">Ngừng hoạt động</option>
                            </select>
                        </div>
                    </div>

                    <%-- Table Content --%>
                    <table class="services-table-element">
                        <thead>
                            <tr>
                                <th style="width: 15%">Phòng</th>
                                <th style="width: 15%">Tầng</th>
                                <th style="width: 25%">Loại phòng</th>
                                <th style="width: 20%">
                                    Trạng thái
                                    <span style="display: block; font-size: 10px; text-transform: none; font-weight: 500; color: #64748b; margin-top: 2px;">
                                        Trạng thái vào ngày ${selectedDateFormatted}
                                    </span>
                                </th>
                                <th style="width: 13%">Giá niêm yết</th>
                                <th style="width: 12%">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody id="roomsTableBody">
                            <%-- Dynamic rows generated by JavaScript --%>
                        </tbody>
                    </table>

                    <%-- Table Pagination Footer --%>
                    <div class="table-pagination-bar">
                        <div class="pagination-info" id="roomPaginationInfo">
                            Đang tải...
                        </div>
                        <div class="pagination-controls" id="roomPaginationControls">
                        </div>
                    </div>

                </div>

            </main>

            <%-- FOOTER --%>
            <footer class="dashboard-footer">
                <span>© 2024 HotelOps Luxury Management. Hệ thống quản trị nội bộ.</span>
                <div class="footer-links-row">
                    <a href="#">Hỗ trợ</a>
                    <a href="#">Bảo mật</a>
                    <a href="#">Điều khoản</a>
                </div>
            </footer>

        </div>
    </div>

    <%-- ADD / EDIT ROOM MODAL DIALOG --%>
    <div class="modal-overlay" id="roomModal">
        <div class="modal-container">
            <div class="modal-header">
                <h3 id="roomModalTitle">Thêm phòng mới</h3>
                <button class="btn-close-modal" onclick="closeRoomModal()"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="modal-body">
                <form id="roomForm" action="${pageContext.request.contextPath}/manager/rooms?action=save" method="post">
                    <input type="hidden" id="modalRoomId" name="roomId" value="" />
                    <input type="hidden" id="modalSelectedDate" name="selectedDate" value="${selectedDate}" />

                    <div class="modal-form-group">
                        <label for="modalRoomNumber">Số phòng</label>
                        <input type="text" id="modalRoomNumber" name="roomNumber" class="modal-input" placeholder="Ví dụ: 101" required oninput="this.value = this.value.replace(/\s/g, '')" />
                        <small id="roomNumberError" style="color: #e53e3e; font-size: 12px; display: none; margin-top: 4px;"></small>
                    </div>

                    <div class="modal-form-group">
                        <label for="modalRoomFloor">Tầng</label>
                        <select id="modalRoomFloor" name="floor" class="modal-select" required>
                            <option value="Tầng 1">Tầng 1</option>
                            <option value="Tầng 2">Tầng 2</option>
                            <option value="Tầng 3">Tầng 3</option>
                            <option value="Tầng 4">Tầng 4</option>
                        </select>
                    </div>

                    <div class="modal-form-group">
                        <label for="modalRoomType">Loại phòng</label>
                        <select id="modalRoomType" name="typeId" class="modal-select" required>
                            <c:forEach var="rt" items="${roomTypesList}">
                                <option value="${rt.typeId}">
                                    <c:out value="${rt.typeName}" />
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="modal-form-group">
                        <label for="modalRoomStatus">Trạng thái vận hành</label>
                        <select id="modalRoomStatus" name="status" class="modal-select" required>
                            <option value="Available">Trống (Available)</option>
                            <option value="Cleaning">Đang dọn (Cleaning)</option>
                            <option value="Maintenance">Bảo trì (Maintenance)</option>
                            <option value="OutOfService">Ngừng hoạt động (OutOfService)</option>
                        </select>
                        <div id="occupiedWarning" class="occupied-warning-note" style="display: none;">
                            <i class="fa-solid fa-triangle-exclamation"></i>
                            Không thể thay đổi trạng thái vì phòng hiện đang có khách lưu trú.
                        </div>
                        <input type="hidden" id="modalRoomStatusHidden" name="status" value="" disabled />
                    </div>

                    <div class="modal-footer-row">
                        <button type="button" class="btn-modal-cancel" onclick="closeRoomModal()">Hủy bỏ</button>
                        <button type="submit" class="btn-modal-submit">Lưu lại</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%-- Shared pagination/table utility --%>
    <script src="${pageContext.request.contextPath}/assets/js/manager-table.js" charset="UTF-8"></script>

    <%-- JavaScript: Rooms Management Logic --%>
    <script>
        // Initialize ManagerTable control for rooms
        window.addEventListener('DOMContentLoaded', function () {
            ManagerTable.init("roomsTable", {
                storageSelector: ".room-data-item",
                tbodyId: "roomsTableBody",
                paginationInfoId: "roomPaginationInfo",
                paginationControlsId: "roomPaginationControls",
                pageSize: 5,
                emptyMessage: "Không tìm thấy phòng nào phù hợp",
                infoTextFn: (start, end, total) => `Hiển thị \${start}-\${end} trong số \${total} phòng`,
                hydrateItem: function (item) {
                    return {
                        id: parseInt(item.getAttribute("data-id")),
                        number: (item.getAttribute("data-number") || "").trim(),
                        typeId: parseInt(item.getAttribute("data-type-id")),
                        status: (item.getAttribute("data-display-status") || item.getAttribute("data-status") || "").trim(),
                        operationalStatus: (item.getAttribute("data-operational-status") || "").trim(),
                        displayStatus: (item.getAttribute("data-display-status") || "").trim(),
                        currentlyOccupied: item.getAttribute("data-currently-occupied") === "true",
                        hasFutureBooking: item.getAttribute("data-has-future-booking") === "true",
                        floor: (item.getAttribute("data-floor") || "").trim(),
                        typeName: (item.getAttribute("data-type-name") || "").trim(),
                        basePrice: parseFloat(item.getAttribute("data-base-price")),
                        bedType: (item.getAttribute("data-bed-type") || "").trim(),
                        area: (item.getAttribute("data-area") || "").trim()
                    };
                },
                renderRow: function (room) {
                    const priceFormatted = new Intl.NumberFormat('vi-VN').format(room.basePrice);

                    let statusClass = "", statusText = "";
                    const s = room.displayStatus || room.status;
                    if (s === "Available") { statusClass = "status-available"; statusText = "TRỐNG"; }
                    else if (s === "Confirmed") { statusClass = "status-confirmed"; statusText = "ĐÃ ĐẶT"; }
                    else if (s === "Occupied") { statusClass = "status-occupied"; statusText = "CÓ KHÁCH"; }
                    else if (s === "Cleaning") { statusClass = "status-cleaning"; statusText = "ĐANG DỌN"; }
                    else if (s === "Refilling") { statusClass = "status-refilling"; statusText = "BỔ SUNG VẬT DỤNG"; }
                    else if (s === "Maintenance") { statusClass = "status-maintenance"; statusText = "BẢO TRÌ"; }
                    else if (s === "OutOfService") { statusClass = "status-outofservice"; statusText = "NGỪNG HOẠT ĐỘNG"; }

                    const canDelete = !room.hasFutureBooking && !room.currentlyOccupied && (room.operationalStatus === "Available") && (s === "Available");
                    const deleteBtnHtml = canDelete
                        ? `<button class="btn-action delete" onclick="deleteRoom(\${room.id})" title="Xóa">
                            <i class="fa-solid fa-trash-can"></i>
                           </button>`
                        : `<button class="btn-action delete" style="opacity: 0.35; cursor: not-allowed;" title="Không thể xóa phòng đang có khách, có đơn đặt trong tương lai, đang dọn dẹp hoặc bảo trì">
                            <i class="fa-solid fa-trash-can"></i>
                           </button>`;

                    return `
                        <td>
                            <span class="room-number-cell" style="font-weight: bold; color: var(--brand-blue); font-size: 16px;">\${room.number}</span>
                        </td>
                        <td>
                            <span style="font-weight: 500; color: #475569;">\${room.floor}</span>
                        </td>
                        <td>
                            <div>
                                <span style="font-weight: 600; color: var(--text-navy); display: block;">\${room.typeName}</span>
                                <span style="font-size: 11px; color: var(--text-muted); display: block;">\${room.bedType}, \${room.area}</span>
                            </div>
                        </td>
                        <td>
                            <span class="status-pill \${statusClass}"><i class="fa-solid fa-circle"></i> \${statusText}</span>
                        </td>
                        <td>
                            <span style="font-size: 15px; color: #1e293b; font-weight: bold;">\${priceFormatted}đ</span>
                        </td>
                        <td>
                            <div class="table-actions" style="display: flex; gap: 8px; align-items: center;">
                                <button class="btn-action edit" onclick="openEditRoomModal(\${room.id})" title="Chỉnh sửa">
                                    <i class="fa-solid fa-pencil"></i>
                                </button>
                                \${deleteBtnHtml}
                            </div>
                        </td>
                    `;
                },
                filterPredicate: function (room) {
                    const query = document.getElementById("roomSearch").value.toLowerCase().trim();
                    const floor = document.getElementById("floorFilter").value;
                    const typeId = document.getElementById("roomTypeFilter").value;
                    const status = document.getElementById("statusFilter").value;

                    const matchQuery = room.number.toLowerCase().includes(query);
                    const matchFloor = (floor === "all") || (room.floor === floor);
                    const matchType = (typeId === "all") || (room.typeId === parseInt(typeId));
                    const matchStatus = (status === "all") || ((room.displayStatus || room.status) === status);
                    return matchQuery && matchFloor && matchType && matchStatus;
                }
            });
        });

        // Filter trigger
        function filterRooms() {
            ManagerTable.filter("roomsTable");
        }

        // Change selected date
        function changeSelectedDate(dateVal) {
            if (!dateVal) return;
            window.location.href = `${pageContext.request.contextPath}/manager/rooms?selectedDate=` + encodeURIComponent(dateVal);
        }

        // Delete Room
        function deleteRoom(id) {
            const table = ManagerTable.tables.roomsTable;
            if (table && table.items) {
                const room = table.items.find(r => r.id === id);
                if (room) {
                    const opStatus = room.operationalStatus || room.status;
                    const dispStatus = room.displayStatus || room.status;
                    if (room.hasFutureBooking || room.currentlyOccupied || opStatus !== "Available" || dispStatus !== "Available") {
                        alert("Không thể xóa phòng vì phòng đang được sử dụng hoặc đã được phân cho một đơn đặt phòng trong tương lai.");
                        return;
                    }
                }
            }
            if (confirm("Bạn có chắc chắn muốn xóa phòng này không?")) {
                const selDate = document.getElementById("selectedDateInput").value;
                window.location.href = `${pageContext.request.contextPath}/manager/rooms?action=delete&id=` + id + "&selectedDate=" + encodeURIComponent(selDate);
            }
        }

        // Modal Handlers
        function openAddRoomModal() {
            document.getElementById("roomModalTitle").innerText = "Thêm phòng mới";
            document.getElementById("modalRoomId").value = "";
            document.getElementById("roomForm").reset();

            const statusSelect = document.getElementById("modalRoomStatus");
            const warningNote = document.getElementById("occupiedWarning");
            const hiddenStatus = document.getElementById("modalRoomStatusHidden");

            statusSelect.disabled = false;
            statusSelect.value = "Available";
            warningNote.style.display = "none";
            hiddenStatus.disabled = true;

            document.getElementById("roomModal").style.display = "flex";
        }

        // Open edit room modal
        function openEditRoomModal(id) {
            const table = ManagerTable.tables.roomsTable;
            if (!table) return;
            const room = table.items.find(r => r.id === id);
            if (room) {
                document.getElementById("roomModalTitle").innerText = "Chỉnh sửa thông tin phòng";
                document.getElementById("modalRoomId").value = room.id;
                document.getElementById("modalRoomNumber").value = room.number;
                document.getElementById("modalRoomFloor").value = room.floor;
                document.getElementById("modalRoomType").value = room.typeId;

                const statusSelect = document.getElementById("modalRoomStatus");
                const warningNote = document.getElementById("occupiedWarning");
                const hiddenStatus = document.getElementById("modalRoomStatusHidden");

                const currentOpStatus = room.operationalStatus || room.status;

                if (room.currentlyOccupied) {
                    statusSelect.value = currentOpStatus;
                    statusSelect.disabled = true;
                    warningNote.style.display = "flex";
                    hiddenStatus.value = currentOpStatus;
                    hiddenStatus.disabled = false;
                } else {
                    statusSelect.value = currentOpStatus;
                    statusSelect.disabled = false;
                    warningNote.style.display = "none";
                    hiddenStatus.disabled = true;
                }

                document.getElementById("roomModal").style.display = "flex";
            }
        }

        // Close Modal
        function closeRoomModal() {
            document.getElementById("roomModal").style.display = "none";
        }

        // Room form submit validation
        document.getElementById('roomForm').addEventListener('submit', function (e) {
            var roomNumberInput = document.getElementById('modalRoomNumber');
            var val = roomNumberInput.value.trim();

            roomNumberInput.setCustomValidity("");

            if (val === "") {
                e.preventDefault();
                roomNumberInput.setCustomValidity("Vui lòng điền vào trường này.");
                roomNumberInput.reportValidity();
                return;
            }

            if (val.indexOf('-') !== -1) {
                e.preventDefault();
                roomNumberInput.setCustomValidity("Số phòng không thể là số âm.");
                roomNumberInput.reportValidity();
                return;
            }

            var numVal = parseFloat(val);
            if (!isNaN(numVal) && numVal <= 0) {
                e.preventDefault();
                roomNumberInput.setCustomValidity("Số phòng phải lớn hơn 0.");
                roomNumberInput.reportValidity();
                return;
            }

            // Check duplicate room number
            const currentRoomIdVal = document.getElementById("modalRoomId").value;
            const currentRoomId = currentRoomIdVal ? parseInt(currentRoomIdVal) : -1;
            const table = ManagerTable.tables.roomsTable;
            if (table && table.items) {
                const isDuplicate = table.items.some(r => {
                    return r.number.toLowerCase() === val.toLowerCase() && r.id !== currentRoomId;
                });
                if (isDuplicate) {
                    e.preventDefault();
                    roomNumberInput.setCustomValidity("Số phòng này đã tồn tại trong hệ thống. Vui lòng chọn số khác.");
                    roomNumberInput.reportValidity();
                    return;
                }
            }
        });

        document.getElementById("modalRoomNumber").addEventListener('input', function () {
            this.setCustomValidity("");
        });

        // Unified Vietnamese HTML5 Validation Messages
        document.addEventListener('invalid', function (e) {
            const el = e.target;
            if (!el || !['INPUT', 'SELECT', 'TEXTAREA'].includes(el.tagName)) return;
            if (el.validity.valueMissing) {
                if (el.tagName === 'SELECT') {
                    el.setCustomValidity('Vui lòng chọn một tùy chọn trong danh sách.');
                } else {
                    el.setCustomValidity('Vui lòng điền vào trường này.');
                }
            } else if (el.validity.rangeUnderflow) {
                el.setCustomValidity('Giá trị phải lớn hơn hoặc bằng ' + el.min + '.');
            } else if (el.validity.rangeOverflow) {
                el.setCustomValidity('Giá trị không được vượt quá ' + el.max + '.');
            } else if (el.validity.typeMismatch) {
                el.setCustomValidity('Định dạng dữ liệu không hợp lệ.');
            }
        }, true);
    </script>
</body>
</html>
