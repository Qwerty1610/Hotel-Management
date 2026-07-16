<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=3" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
<fmt:setLocale value="vi_VN" />

<style>
.alert-banner {
    padding: 12px 16px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 20px;
    font-size: 14px;
    font-weight: 600;
}

.alert-success {
    background-color: #f0fdf4;
    border: 1px solid #bbf7d0;
    color: #16a34a;
}

.alert-danger {
    background-color: #fef2f2;
    border: 1px solid #fecaca;
    color: #dc2626;
}
</style>

<body class="dashboard-body">

    <c:set var="activePage" value="amenities" scope="request" />

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
                    <span class="current">Quản lý tiện nghi</span>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </a>
            </header>

            <%-- PAGE CONTENT --%>
            <main class="workspace-content">

                <%-- Hidden data container for database records --%>
                <div id="amenityDataStorage" style="display: none;">
                    <c:forEach var="amenity" items="${amenitiesList}">
                        <div class="amenity-data-item" data-id="${amenity.amenityId}"
                            data-name="<c:out value="${amenity.name}" />"
                            data-icon="<c:out value="${amenity.icon}" />"
                            data-active="${amenity.active}">
                        </div>
                    </c:forEach>
                </div>

                <%-- Alert messages --%>
                <c:if test="${not empty param.error}">
                    <div class="alert-banner alert-danger" id="errorBanner">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        <c:choose>
                            <c:when test="${param.error eq 'duplicateName'}">Tên tiện nghi này đã tồn tại trong hệ thống. Vui lòng chọn tên khác.</c:when>
                            <c:when test="${param.error eq 'invalidData'}">Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.</c:when>
                            <c:otherwise>Có lỗi xảy ra.</c:otherwise>
                        </c:choose>
                    </div>
                </c:if>
                <c:if test="${not empty param.success}">
                    <div class="alert-banner alert-success" id="successBanner">
                        <i class="fa-solid fa-circle-check"></i>
                        <c:choose>
                            <c:when test="${param.success eq 'saved'}">Lưu thông tin tiện nghi thành công!</c:when>
                            <c:when test="${param.success eq 'deleted'}">Xóa tiện nghi thành công!</c:when>
                            <c:when test="${param.success eq 'assigned'}">Áp dụng tiện nghi cho loại phòng thành công!</c:when>
                            <c:otherwise>Thao tác thành công!</c:otherwise>
                        </c:choose>
                    </div>
                </c:if>

                <div class="content-header-row">
                    <div>
                        <h1>Quản lý Tiện nghi</h1>
                        <p>Cập nhật và điều chỉnh các tiện ích đi kèm với từng loại phòng.</p>
                    </div>
                    <button class="btn-add-service" onclick="openAddModal()">
                        <i class="fa-solid fa-plus"></i> Thêm tiện nghi mới
                    </button>
                </div>

                <%-- Amenities Main Table Wrapper --%>
                <div class="table-card">

                    <%-- Search, Filter & Statistics Bar --%>
                    <div class="table-filter-bar"
                        style="display: grid; grid-template-columns: 1.5fr 1fr 1fr 1fr 1fr; gap: 16px; align-items: end;">
                        <div class="modal-form-group" style="margin-bottom: 0;">
                            <label>Tìm kiếm tiện nghi</label>
                            <div class="search-wrapper" style="max-width: 100%;">
                                <i class="fa-solid fa-magnifying-glass"></i>
                                <input type="text" id="amenitySearch"
                                    class="input-search-service"
                                    placeholder="Tìm kiếm tiện nghi..."
                                    onkeyup="filterAmenities()" />
                            </div>
                        </div>

                        <div class="modal-form-group" style="margin-bottom: 0;">
                            <label>Trạng thái</label>
                            <select id="statusFilter" class="status-select"
                                onchange="filterAmenities()" style="width: 100%;">
                                <option value="all">Tất cả trạng thái</option>
                                <option value="active">Đang kích hoạt</option>
                                <option value="inactive">Đang tạm khóa</option>
                            </select>
                        </div>

                        <%-- Statistic chips --%>
                        <div class="modal-form-group" style="margin-bottom: 0;">
                            <label>Tổng tiện nghi</label>
                            <div style="display: flex; align-items: center; justify-content: center; background: #f1f5f9; border-radius: 8px; border: 1px solid #cbd5e1; height: 40px; box-sizing: border-box;">
                                <span id="statTotal" style="font-size: 16px; font-weight: 800; color: #1e293b;">0</span>
                            </div>
                        </div>

                        <div class="modal-form-group" style="margin-bottom: 0;">
                            <label style="color: #16a34a;">Kích hoạt</label>
                            <div style="display: flex; align-items: center; justify-content: center; gap: 8px; background: #f0fdf4; border-radius: 8px; border: 1px solid #bbf7d0; height: 40px; box-sizing: border-box;">
                                <i class="fa-solid fa-circle-check" style="color: #16a34a; font-size: 14px;"></i>
                                <span id="statActive" style="font-size: 16px; font-weight: 800; color: #16a34a;">0</span>
                            </div>
                        </div>

                        <div class="modal-form-group" style="margin-bottom: 0;">
                            <label style="color: #dc2626;">Tạm khóa</label>
                            <div style="display: flex; align-items: center; justify-content: center; gap: 8px; background: #fef2f2; border-radius: 8px; border: 1px solid #fecaca; height: 40px; box-sizing: border-box;">
                                <i class="fa-solid fa-circle-xmark" style="color: #dc2626; font-size: 14px;"></i>
                                <span id="statInactive" style="font-size: 16px; font-weight: 800; color: #dc2626;">0</span>
                            </div>
                        </div>
                    </div>

                    <%-- Table Content --%>
                    <table class="services-table-element">
                        <thead>
                            <tr>
                                <th style="width: 15%">Icon</th>
                                <th style="width: 45%">Tên tiện nghi</th>
                                <th style="width: 20%">Trạng thái</th>
                                <th style="width: 20%">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody id="amenitiesTableBody">
                            <%-- Dynamic rows generated by JavaScript --%>
                        </tbody>
                    </table>

                    <%-- Table Pagination Footer --%>
                    <div class="table-pagination-bar">
                        <div class="pagination-info" id="paginationInfo">
                            Đang tải...
                        </div>
                        <div class="pagination-controls" id="paginationControls">
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

    <%-- ADD / EDIT AMENITY MODAL DIALOG --%>
    <div class="modal-overlay" id="amenityModal">
        <div class="modal-container" style="max-width: 500px;">
            <div class="modal-header">
                <h3 id="modalTitle">Thêm tiện nghi mới</h3>
                <button class="btn-close-modal" onclick="closeModal()"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="modal-body">
                <form id="amenityForm" action="${pageContext.request.contextPath}/manager/amenities?action=save" method="post">
                    <input type="hidden" id="amenityId" name="amenityId" value="" />

                    <div class="modal-form-group">
                        <label for="modalName">Tên tiện nghi</label>
                        <input type="text" id="modalName" name="name" class="modal-input" placeholder="Ví dụ: Wi-Fi miễn phí" required />
                    </div>

                    <style>
                        .icon-picker-grid { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 8px; }
                        .icon-btn { border: 1px solid #cbd5e1; background: #fff; width: 42px; height: 42px; border-radius: 6px; cursor: pointer; font-size: 16px; color: #475569; display: flex; align-items: center; justify-content: center; transition: all 0.2s; }
                        .icon-btn:hover { background: #f1f5f9; border-color: #94a3b8; }
                        .icon-btn.selected { background: #2563eb; color: #fff; border-color: #2563eb; }
                    </style>
                    <div class="modal-form-group">
                        <label>Biểu tượng (Icon)</label>
                        <input type="hidden" id="modalIcon" name="icon" required />
                        
                        <div class="icon-picker-grid" id="iconPickerGrid">
                            <button type="button" class="icon-btn" onclick="selectIcon('fa-solid fa-wifi')"><i class="fa-solid fa-wifi"></i></button>
                            <button type="button" class="icon-btn" onclick="selectIcon('fa-solid fa-snowflake')"><i class="fa-solid fa-snowflake"></i></button>
                            <button type="button" class="icon-btn" onclick="selectIcon('fa-solid fa-tv')"><i class="fa-solid fa-tv"></i></button>
                            <button type="button" class="icon-btn" onclick="selectIcon('fa-solid fa-city')"><i class="fa-solid fa-city"></i></button>
                            <button type="button" class="icon-btn" onclick="selectIcon('fa-solid fa-martini-glass')"><i class="fa-solid fa-martini-glass"></i></button>
                            <button type="button" class="icon-btn" onclick="selectIcon('fa-solid fa-hot-tub-person')"><i class="fa-solid fa-hot-tub-person"></i></button>
                            <button type="button" class="icon-btn" onclick="selectIcon('fa-solid fa-mug-hot')"><i class="fa-solid fa-mug-hot"></i></button>
                            <button type="button" class="icon-btn" onclick="selectIcon('fa-solid fa-bed')"><i class="fa-solid fa-bed"></i></button>
                            <button type="button" class="icon-btn" onclick="selectIcon('fa-solid fa-bath')"><i class="fa-solid fa-bath"></i></button>
                            <button type="button" class="icon-btn" onclick="selectIcon('fa-solid fa-wind')"><i class="fa-solid fa-wind"></i></button>
                            <button type="button" class="icon-btn" onclick="selectIcon('fa-solid fa-phone')"><i class="fa-solid fa-phone"></i></button>
                            <button type="button" class="icon-btn" onclick="selectIcon('fa-solid fa-water-ladder')"><i class="fa-solid fa-water-ladder"></i></button>
                            <button type="button" class="icon-btn" onclick="selectIcon('fa-solid fa-dumbbell')"><i class="fa-solid fa-dumbbell"></i></button>
                            <button type="button" class="icon-btn" onclick="selectIcon('fa-solid fa-utensils')"><i class="fa-solid fa-utensils"></i></button>
                            <button type="button" class="icon-btn" onclick="selectIcon('fa-solid fa-car')"><i class="fa-solid fa-car"></i></button>
                            <button type="button" class="icon-btn" onclick="selectIcon('fa-solid fa-fan')"><i class="fa-solid fa-fan"></i></button>
                            <button type="button" class="icon-btn" onclick="selectIcon('fa-solid fa-vault')"><i class="fa-solid fa-vault"></i></button>
                            <button type="button" class="icon-btn" onclick="selectIcon('fa-solid fa-shirt')"><i class="fa-solid fa-shirt"></i></button>
                            <button type="button" class="icon-btn" onclick="selectIcon('fa-solid fa-tree')"><i class="fa-solid fa-tree"></i></button>
                            <button type="button" class="icon-btn" onclick="selectIcon('fa-solid fa-temperature-arrow-down')"><i class="fa-solid fa-temperature-arrow-down"></i></button>
                        </div>
                        <span id="iconErrorMsg" style="color: #dc2626; font-size: 12px; display: none; margin-top: 4px;">Vui lòng chọn 1 biểu tượng</span>
                    </div>

                    <div class="modal-footer-row">
                        <button type="button" class="btn-modal-cancel" onclick="closeModal()">Hủy bỏ</button>
                        <button type="submit" class="btn-modal-submit">Lưu lại</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%-- ASSIGN AMENITY TO ROOM TYPES MODAL --%>
    <div class="modal-overlay" id="assignModal">
        <div class="modal-container" style="max-width: 500px;">
            <div class="modal-header">
                <h3>Áp dụng cho loại phòng</h3>
                <button class="btn-close-modal" onclick="closeAssignModal()"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="modal-body">
                <form id="assignForm" action="${pageContext.request.contextPath}/manager/amenities?action=assign" method="post">
                    <input type="hidden" id="assignAmenityId" name="amenityId" value="" />
                    <p style="margin-bottom: 15px; color: #475569;">Chọn các loại phòng sẽ có tiện nghi <strong id="assignAmenityName"></strong>:</p>

                    <div class="modal-form-group">
                        <div style="display: flex; flex-direction: column; max-height: 280px; overflow-y: auto; padding-right: 5px;">
                            <c:forEach var="rt" items="${roomTypesList}">
                                <div style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border: 1px solid #e2e8f0; border-radius: 8px; margin-bottom: 10px; background: #fff; transition: all 0.2s ease-in-out;" onmouseover="this.style.boxShadow='0 2px 4px rgba(0,0,0,0.05)'; this.style.borderColor='#cbd5e1'" onmouseout="this.style.boxShadow='none'; this.style.borderColor='#e2e8f0'">
                                    <div style="display: flex; flex-direction: column;">
                                        <span style="font-weight: 600; color: #1e293b; font-size: 15px;">${rt.typeName}</span>
                                    </div>
                                    <label class="switch switch-active">
                                        <input type="checkbox" name="roomTypeIds" value="${rt.typeId}" class="assign-checkbox" />
                                        <span class="slider"></span>
                                    </label>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <div class="modal-footer-row" style="margin-top: 20px;">
                        <button type="button" class="btn-modal-cancel" onclick="closeAssignModal()">Hủy bỏ</button>
                        <button type="submit" class="btn-modal-submit">Lưu áp dụng</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%-- Shared pagination/table utility --%>
    <script src="${pageContext.request.contextPath}/assets/js/manager-table.js" charset="UTF-8"></script>

    <%-- JavaScript: Amenities Management Logic --%>
    <script>
        const assignedRoomTypesMap = ${assignedRoomTypesMapJson != null ? assignedRoomTypesMapJson : '{}'};

        function selectIcon(iconClass) {
            document.getElementById("modalIcon").value = iconClass;
            document.getElementById("iconErrorMsg").style.display = "none";
            
            // Highlight selected
            const buttons = document.querySelectorAll(".icon-btn");
            buttons.forEach(btn => {
                const i = btn.querySelector("i");
                if (i && i.className === iconClass) {
                    btn.classList.add("selected");
                } else {
                    btn.classList.remove("selected");
                }
            });
        }

        window.addEventListener('DOMContentLoaded', function () {
            // Hide alerts after 5 seconds
            setTimeout(function() {
                const successBanner = document.getElementById('successBanner');
                if (successBanner) {
                    successBanner.style.transition = 'opacity 0.5s ease';
                    successBanner.style.opacity = '0';
                    setTimeout(() => successBanner.style.display = 'none', 500);
                }
                const errorBanner = document.getElementById('errorBanner');
                if (errorBanner) {
                    errorBanner.style.transition = 'opacity 0.5s ease';
                    errorBanner.style.opacity = '0';
                    setTimeout(() => errorBanner.style.display = 'none', 500);
                }
            }, 5000);

            ManagerTable.init("amenitiesTable", {
                storageSelector: ".amenity-data-item",
                tbodyId: "amenitiesTableBody",
                paginationInfoId: "paginationInfo",
                paginationControlsId: "paginationControls",
                pageSize: 5,
                emptyMessage: "Không tìm thấy tiện nghi nào phù hợp",
                infoTextFn: (start, end, total) => `Hiển thị \${start}-\${end} trong số \${total} tiện nghi`,
                hydrateItem: function (item) {
                    return {
                        id: parseInt(item.getAttribute("data-id")),
                        name: (item.getAttribute("data-name") || "").trim(),
                        icon: (item.getAttribute("data-icon") || "").trim(),
                        isActive: item.getAttribute("data-active") === "true"
                    };
                },
                renderRow: function (amenity) {
                    return `
                        <td>
                            <div style="display: flex; align-items: center; justify-content: center; width: 40px; height: 40px; background: #f8fafc; border-radius: 8px; border: 1px solid #e2e8f0; font-size: 16px; color: #475569;">
                                <i class="\${amenity.icon}"></i>
                            </div>
                        </td>
                        <td>
                            <div class="service-name-cell">
                                <span class="service-title">\${amenity.name}</span>
                            </div>
                        </td>
                        <td>
                            <label class="switch switch-active">
                                <input type="checkbox" \${amenity.isActive ? 'checked' : ''} onchange="toggleStatus(\${amenity.id}, this.checked)" />
                                <span class="slider"></span>
                            </label>
                        </td>
                        <td>
                            <div class="table-actions" style="display: flex; gap: 12px; align-items: center; justify-content: center;">
                                <button class="btn-action" style="color: #2563eb; background: transparent; border: none; font-size: 16px; cursor: pointer;" onclick="openEditModal(\${amenity.id})" title="Chỉnh sửa">
                                    <i class="fa-solid fa-pencil"></i>
                                </button>
                                <button class="btn-action" style="color: #10b981; background: transparent; border: none; font-size: 16px; cursor: pointer;" onclick="openAssignModal(\${amenity.id}, '\${amenity.name}')" title="Áp dụng loại phòng">
                                    <i class="fa-solid fa-link"></i>
                                </button>
                                <button class="btn-action" style="color: #ef4444; background: transparent; border: none; font-size: 16px; cursor: pointer;" onclick="deleteAmenity(\${amenity.id})" title="Xóa">
                                    <i class="fa-solid fa-trash-can"></i>
                                </button>
                            </div>
                        </td>
                    `;
                },
                filterPredicate: function (amenity) {
                    const query = document.getElementById("amenitySearch").value.toLowerCase().trim();
                    const status = document.getElementById("statusFilter").value;

                    const matchQuery = amenity.name.toLowerCase().includes(query) ||
                                       amenity.icon.toLowerCase().includes(query);
                    const matchStatus = (status === "all") ||
                                        (status === "active" && amenity.isActive) ||
                                        (status === "inactive" && !amenity.isActive);
                    return matchQuery && matchStatus;
                },
                onAfterRender: function (table) {
                    const total = table.items.length;
                    const active = table.items.filter(s => s.isActive).length;
                    const inactive = total - active;
                    document.getElementById('statTotal').innerText = total;
                    document.getElementById('statActive').innerText = active;
                    document.getElementById('statInactive').innerText = inactive;
                }
            });
        });

        // Filter trigger
        function filterAmenities() {
            ManagerTable.filter("amenitiesTable");
        }

        // Toggle active status via background fetch
        function toggleStatus(id, checked) {
            const url = `${pageContext.request.contextPath}/manager/amenities?action=toggle&id=` + id + `&status=` + checked;
            fetch(url)
                .then(response => {
                    if (!response.ok) {
                        alert("Có lỗi xảy ra khi cập nhật trạng thái!");
                        filterAmenities();
                    } else {
                        const table = ManagerTable.tables.amenitiesTable;
                        if (table) {
                            const amenity = table.items.find(s => s.id === id);
                            if (amenity) {
                                amenity.isActive = checked;
                                // Update stats in header
                                const total = table.items.length;
                                const active = table.items.filter(s => s.isActive).length;
                                const inactive = total - active;
                                document.getElementById('statTotal').innerText = total;
                                document.getElementById('statActive').innerText = active;
                                document.getElementById('statInactive').innerText = inactive;
                            }
                        }
                    }
                })
                .catch(error => {
                    console.error("Error toggling status:", error);
                    alert("Có lỗi xảy ra khi kết nối máy chủ!");
                    filterAmenities();
                });
        }

        // Clear validation errors
        function clearAmenityErrors() {
            ['modalName', 'modalIcon'].forEach(id => {
                const el = document.getElementById(id);
                if (el) el.setCustomValidity("");
            });
        }

        // Modal Handlers
        function openAddModal() {
            clearAmenityErrors();
            document.getElementById("modalTitle").innerText = "Thêm tiện nghi mới";
            document.getElementById("amenityId").value = "";
            document.getElementById("amenityForm").reset();
            selectIcon(""); // reset icon picker
            document.getElementById("amenityModal").style.display = "flex";
        }

        function openEditModal(id) {
            const table = ManagerTable.tables.amenitiesTable;
            if (!table) return;
            const amenity = table.items.find(s => s.id === id);
            if (amenity) {
                clearAmenityErrors();
                document.getElementById("modalTitle").innerText = "Chỉnh sửa tiện nghi";
                document.getElementById("amenityId").value = amenity.id;
                document.getElementById("modalName").value = amenity.name;
                selectIcon(amenity.icon);
                document.getElementById("amenityModal").style.display = "flex";
            }
        }

        function closeModal() {
            document.getElementById("amenityModal").style.display = "none";
        }

        function openAssignModal(id, name) {
            document.getElementById("assignAmenityId").value = id;
            document.getElementById("assignAmenityName").innerText = name;
            
            // Check checkboxes based on map
            const assignedIds = assignedRoomTypesMap[id] || [];
            document.querySelectorAll('.assign-checkbox').forEach(cb => {
                cb.checked = assignedIds.includes(parseInt(cb.value));
            });

            document.getElementById("assignModal").style.display = "flex";
        }

        function closeAssignModal() {
            document.getElementById("assignModal").style.display = "none";
        }

        function deleteAmenity(id) {
            if (confirm("Bạn có chắc chắn muốn xóa tiện nghi này không? Tất cả phòng có tiện nghi này sẽ bị gỡ bỏ tiện nghi.")) {
                window.location.href = `${pageContext.request.contextPath}/manager/amenities?action=delete&id=` + id;
            }
        }

        // Input listeners
        ['modalName', 'modalIcon'].forEach(id => {
            const el = document.getElementById(id);
            if (el) el.addEventListener('input', function () { this.setCustomValidity(""); });
        });

        // Form Submit Validation
        document.getElementById('amenityForm').addEventListener('submit', function (e) {
            clearAmenityErrors();

            const nameInput = document.getElementById('modalName');
            const iconInput = document.getElementById('modalIcon');

            const nameVal = nameInput.value.trim();
            const iconVal = iconInput.value.trim();

            if (nameVal === "") {
                e.preventDefault();
                nameInput.setCustomValidity("Vui lòng điền vào trường này.");
                nameInput.reportValidity();
                return;
            }

            if (iconVal === "") {
                e.preventDefault();
                document.getElementById("iconErrorMsg").style.display = "block";
                return;
            }

            // Check for duplicate amenity name
            const currentIdVal = document.getElementById("amenityId").value;
            const currentId = currentIdVal ? parseInt(currentIdVal) : -1;
            const table = ManagerTable.tables.amenitiesTable;
            if (table && table.items) {
                const isDuplicate = table.items.some(s => {
                    return s.name.toLowerCase() === nameVal.toLowerCase() && s.id !== currentId;
                });
                if (isDuplicate) {
                    e.preventDefault();
                    nameInput.setCustomValidity("Tên tiện nghi này đã tồn tại.");
                    nameInput.reportValidity();
                    return;
                }
            }
        });
    </script>
</body>
</html>
