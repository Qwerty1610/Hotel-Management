<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ include file="../../includes/taglibs.jsp" %>
        <%@ include file="../../includes/header.jsp" %>

            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=3" />
            <fmt:setLocale value="vi_VN" />

            <body class="dashboard-body">

                <c:set var="activePage" value="services" scope="request" />

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
                                            <span class="current">Quản lý dịch vụ</span>
                                        </div>
                                        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                                            <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                                        </a>
                                    </header>

                                    <%-- PAGE CONTENT --%>
                                        <main class="workspace-content">

                                            <%-- Hidden data container for database records --%>
                                                <div id="serviceDataStorage" style="display: none;">
                                                    <c:forEach var="service" items="${servicesList}">
                                                        <div class="service-data-item" data-id="${service.serviceId}"
                                                            data-name="<c:out value="${service.serviceName}" />"
                                                            data-description="<c:out value="${service.description}" />"
                                                            data-price="${service.price}"
                                                            data-unit="<c:out value="${service.unit}" />"
                                                            data-active="${service.isActive}"
                                                            data-has-usage="${service.hasUsage}">
                                                        </div>
                                                    </c:forEach>
                                                </div>

                            <%-- Alert messages --%>
                                <c:if test="${param.error eq 'duplicateName'}">
                                    <div class="alert-banner alert-danger">
                                        <i class="fa-solid fa-circle-exclamation"></i>
                                        Tên dịch vụ này đã tồn tại trong hệ thống. Vui lòng chọn tên khác.
                                    </div>
                                </c:if>
                                <c:if test="${param.error eq 'hasUsage'}">
                                    <div class="alert-banner alert-danger">
                                        <i class="fa-solid fa-circle-exclamation"></i>
                                        Không thể xóa dịch vụ này vì đang có khách hàng đăng ký hoặc sử dụng.
                                    </div>
                                </c:if>
                                <c:if test="${param.success eq 'saved'}">
                                    <div class="alert-banner alert-success">
                                        <i class="fa-solid fa-circle-check"></i>
                                        Lưu thông tin dịch vụ thành công.
                                    </div>
                                </c:if>
                                <c:if test="${param.success eq 'deleted'}">
                                    <div class="alert-banner alert-success">
                                        <i class="fa-solid fa-circle-check"></i>
                                        Xóa dịch vụ thành công.
                                    </div>
                                </c:if>

                                <div class="content-header-row">
                                    <div>
                                        <h1>Quản lý Dịch vụ</h1>
                                        <p>Cập nhật và điều chỉnh các dịch vụ tiện ích tại khách sạn dành cho khách
                                            hàng.</p>
                                    </div>
                                    <button class="btn-add-service" onclick="openAddModal()">
                                        <i class="fa-solid fa-plus"></i> Thêm dịch vụ mới
                                    </button>
                                </div>

                                <%-- Services Main Table Wrapper --%>
                                    <div class="table-card">

                                        <%-- Search, Filter & Statistics Bar --%>
                                            <div class="table-filter-bar"
                                                style="display: grid; grid-template-columns: 1.5fr 1fr 1fr 1fr 1fr; gap: 16px; align-items: end;">
                                                <div class="modal-form-group" style="margin-bottom: 0;">
                                                    <label>Tìm kiếm dịch vụ</label>
                                                    <div class="search-wrapper" style="max-width: 100%;">
                                                        <i class="fa-solid fa-magnifying-glass"></i>
                                                        <input type="text" id="serviceSearch"
                                                            class="input-search-service"
                                                            placeholder="Tìm kiếm dịch vụ..."
                                                            onkeyup="filterServices()" />
                                                    </div>
                                                </div>

                                                <div class="modal-form-group" style="margin-bottom: 0;">
                                                    <label>Trạng thái</label>
                                                    <select id="statusFilter" class="status-select"
                                                        onchange="filterServices()" style="width: 100%;">
                                                        <option value="all">Tất cả trạng thái</option>
                                                        <option value="active">Đang kích hoạt</option>
                                                        <option value="inactive">Đang tạm khóa</option>
                                                    </select>
                                                </div>

                                                <%-- Statistic chips --%>
                                                    <div class="modal-form-group" style="margin-bottom: 0;">
                                                        <label>Tổng dịch vụ</label>
                                                        <div
                                                            style="display: flex; align-items: center; justify-content: center; background: #f1f5f9; border-radius: 8px; border: 1px solid #cbd5e1; height: 40px; box-sizing: border-box;">
                                                            <span id="statTotal"
                                                                style="font-size: 16px; font-weight: 800; color: #1e293b;">0</span>
                                                        </div>
                                                    </div>

                                                    <div class="modal-form-group" style="margin-bottom: 0;">
                                                        <label style="color: #16a34a;">Kích hoạt</label>
                                                        <div
                                                            style="display: flex; align-items: center; justify-content: center; gap: 8px; background: #f0fdf4; border-radius: 8px; border: 1px solid #bbf7d0; height: 40px; box-sizing: border-box;">
                                                            <i class="fa-solid fa-circle-check"
                                                                style="color: #16a34a; font-size: 14px;"></i>
                                                            <span id="statActive"
                                                                style="font-size: 16px; font-weight: 800; color: #16a34a;">0</span>
                                                        </div>
                                                    </div>

                                                    <div class="modal-form-group" style="margin-bottom: 0;">
                                                        <label style="color: #dc2626;">Tạm khóa</label>
                                                        <div
                                                            style="display: flex; align-items: center; justify-content: center; gap: 8px; background: #fef2f2; border-radius: 8px; border: 1px solid #fecaca; height: 40px; box-sizing: border-box;">
                                                            <i class="fa-solid fa-circle-xmark"
                                                                style="color: #dc2626; font-size: 14px;"></i>
                                                            <span id="statInactive"
                                                                style="font-size: 16px; font-weight: 800; color: #dc2626;">0</span>
                                                        </div>
                                                    </div>
                                            </div>

                                            <%-- Table Content --%>
                                                <table class="services-table-element">
                                                    <thead>
                                                        <tr>
                                                            <th style="width: 25%">Dịch vụ</th>
                                                            <th style="width: 35%">Mô tả</th>
                                                            <th style="width: 15%">Đơn giá</th>
                                                            <th style="width: 13%">Trạng thái</th>
                                                            <th style="width: 12%">Thao tác</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody id="servicesTableBody">
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

                <%-- ADD / EDIT SERVICE MODAL DIALOG --%>
                    <div class="modal-overlay" id="serviceModal">
                        <div class="modal-container">
                            <div class="modal-header">
                                <h3 id="modalTitle">Thêm dịch vụ mới</h3>
                                <button class="btn-close-modal" onclick="closeModal()"><i
                                        class="fa-solid fa-xmark"></i></button>
                            </div>
                            <div class="modal-body">
                                <form id="serviceForm"
                                    action="${pageContext.request.contextPath}/manager/services?action=save"
                                    method="post">
                                    <input type="hidden" id="serviceId" name="serviceId" value="" />

                                    <div class="modal-form-group">
                                        <label for="modalName">Tên dịch vụ</label>
                                        <input type="text" id="modalName" name="name" class="modal-input"
                                            placeholder="Ví dụ: Bữa sáng Buffet" required />
                                    </div>

                                    <div class="modal-form-group">
                                        <label for="modalDescription">Mô tả dịch vụ
                                            <span
                                                style="font-weight: normal; color: var(--text-muted); font-size: 11px;">(Tùy
                                                chọn)</span>
                                        </label>
                                        <textarea id="modalDescription" name="description" class="modal-textarea"
                                            placeholder="Nhập mô tả ngắn..."></textarea>
                                    </div>

                                    <div class="modal-form-group"
                                        style="display: grid; grid-template-columns: 2fr 1fr; gap: 16px;">
                                        <div>
                                            <label for="modalPrice">Đơn giá (VNĐ)</label>
                                            <input type="number" id="modalPrice" name="price" class="modal-input"
                                                placeholder="Ví dụ: 350000" required />
                                        </div>
                                        <div>
                                            <label for="modalUnit">Đơn vị tính</label>
                                            <input type="text" id="modalUnit" name="unit" class="modal-input"
                                                placeholder="Ví dụ: /khách" required />
                                        </div>
                                    </div>

                                    <div class="modal-footer-row">
                                        <button type="button" class="btn-modal-cancel" onclick="closeModal()">Hủy
                                            bỏ</button>
                                        <button type="submit" class="btn-modal-submit">Lưu lại</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <%-- Shared pagination/table utility --%>
                        <script src="${pageContext.request.contextPath}/assets/js/manager-table.js" charset="UTF-8"></script>

                        <%-- JavaScript: Services Management Logic --%>
                            <script>
                                // Initialize ManagerTable utility for services list
                                window.addEventListener('DOMContentLoaded', function () {
                                    ManagerTable.init("servicesTable", {
                                        storageSelector: ".service-data-item",
                                        tbodyId: "servicesTableBody",
                                        paginationInfoId: "paginationInfo",
                                        paginationControlsId: "paginationControls",
                                        pageSize: 5,
                                        emptyMessage: "Không tìm thấy dịch vụ nào phù hợp",
                                        infoTextFn: (start, end, total) => `Hiển thị \${start}-\${end} trong số \${total} dịch vụ`,
                                        hydrateItem: function (item) {
                                            return {
                                                id: parseInt(item.getAttribute("data-id")),
                                                name: (item.getAttribute("data-name") || "").trim(),
                                                description: (item.getAttribute("data-description") || "").trim(),
                                                price: parseFloat(item.getAttribute("data-price")),
                                                unit: (item.getAttribute("data-unit") || "").trim(),
                                                isActive: item.getAttribute("data-active") === "true",
                                                hasUsage: item.getAttribute("data-has-usage") === "true"
                                            };
                                        },
                                        renderRow: function (service) {
                                            const priceFormatted = new Intl.NumberFormat('vi-VN').format(service.price);

                                            const deleteBtnHtml = service.hasUsage
                                                ? `<button class="btn-action delete" style="opacity: 0.35; cursor: not-allowed;" title="Không thể xóa dịch vụ đang có khách hàng đăng ký hoặc sử dụng">
                                                       <i class="fa-solid fa-trash-can"></i>
                                                   </button>`
                                                : `<button class="btn-action delete" onclick="deleteService(\${service.id})" title="Xóa">
                                                       <i class="fa-solid fa-trash-can"></i>
                                                   </button>`;

                                            return `
                        <td>
                            <div class="service-name-cell">
                                <span class="service-title">\${service.name}</span>
                            </div>
                        </td>
                        <td>
                            <span class="service-desc-text">\${service.description}</span>
                        </td>
                        <td>
                            <span class="service-price-text">
                                \${priceFormatted} VNĐ <span class="unit">\${service.unit}</span>
                            </span>
                        </td>
                        <td>
                            <label class="switch switch-active">
                                <input type="checkbox" \${service.isActive ? 'checked' : ''} onchange="toggleStatus(\${service.id}, this.checked)" />
                                <span class="slider"></span>
                            </label>
                        </td>
                        <td>
                            <div class="table-actions">
                                <button class="btn-action edit" onclick="openEditModal(\${service.id})" title="Chỉnh sửa">
                                    <i class="fa-solid fa-pencil"></i>
                                </button>
                                \${deleteBtnHtml}
                            </div>
                        </td>
                    `;
                                        },
                                        filterPredicate: function (service) {
                                            const query = document.getElementById("serviceSearch").value.toLowerCase().trim();
                                            const status = document.getElementById("statusFilter").value;

                                            const matchQuery = service.name.toLowerCase().includes(query) ||
                                                service.description.toLowerCase().includes(query);
                                            const matchStatus = (status === "all") ||
                                                (status === "active" && service.isActive) ||
                                                (status === "inactive" && !service.isActive);
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
                                function filterServices() {
                                    ManagerTable.filter("servicesTable");
                                }

                                // Toggle active status via background fetch
                                function toggleStatus(id, checked) {
                                    const url = `${pageContext.request.contextPath}/manager/services?action=toggle&id=` + id + `&status=` + checked;
                                    fetch(url)
                                        .then(response => {
                                            if (!response.ok) {
                                                alert("Có lỗi xảy ra khi cập nhật trạng thái!");
                                                filterServices();
                                            } else {
                                                const table = ManagerTable.tables.servicesTable;
                                                if (table) {
                                                    const service = table.items.find(s => s.id === id);
                                                    if (service) {
                                                        service.isActive = checked;
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
                                            filterServices();
                                        });
                                }

                                // Clear validation errors
                                function clearServiceErrors() {
                                    ['modalName', 'modalPrice', 'modalUnit'].forEach(id => {
                                        const el = document.getElementById(id);
                                        if (el) el.setCustomValidity("");
                                    });
                                }

                                // Modal Handlers
                                // Open Add Modal
                                function openAddModal() {
                                    clearServiceErrors();
                                    document.getElementById("modalTitle").innerText = "Thêm dịch vụ mới";
                                    document.getElementById("serviceId").value = "";
                                    document.getElementById("serviceForm").reset();
                                    document.getElementById("serviceModal").style.display = "flex";
                                }

                                // Open edit modal
                                function openEditModal(id) {
                                    const table = ManagerTable.tables.servicesTable;
                                    if (!table) return;
                                    const service = table.items.find(s => s.id === id);
                                    if (service) {
                                        clearServiceErrors();
                                        document.getElementById("modalTitle").innerText = "Chỉnh sửa dịch vụ";
                                        document.getElementById("serviceId").value = service.id;
                                        document.getElementById("modalName").value = service.name;
                                        document.getElementById("modalDescription").value = service.description;
                                        document.getElementById("modalPrice").value = service.price;
                                        document.getElementById("modalUnit").value = service.unit;
                                        document.getElementById("serviceModal").style.display = "flex";
                                    }
                                }

                                function closeModal() {
                                    clearServiceErrors();
                                    document.getElementById("serviceModal").style.display = "none";
                                }

                                // Delete Service
                                function deleteService(id) {
                                    const table = ManagerTable.tables.servicesTable;
                                    if (table && table.items) {
                                        const service = table.items.find(s => s.id === id);
                                        if (service && service.hasUsage) {
                                            return;
                                        }
                                    }
                                    if (confirm("Bạn có chắc chắn muốn xóa dịch vụ này không?")) {
                                        window.location.href = `${pageContext.request.contextPath}/manager/services?action=delete&id=` + id;
                                    }
                                }

                                // Input listeners
                                ['modalName', 'modalPrice', 'modalUnit'].forEach(id => {
                                    const el = document.getElementById(id);
                                    if (el) el.addEventListener('input', function () { this.setCustomValidity(""); });
                                });

                                // Form Submit Validation
                                document.getElementById('serviceForm').addEventListener('submit', function (e) {
                                    clearServiceErrors();

                                    const nameInput = document.getElementById('modalName');
                                    const priceInput = document.getElementById('modalPrice');
                                    const unitInput = document.getElementById('modalUnit');

                                    const nameVal = nameInput.value.trim();
                                    const priceVal = parseFloat(priceInput.value);
                                    const unitVal = unitInput.value.trim();

                                    if (nameVal === "") {
                                        e.preventDefault();
                                        nameInput.setCustomValidity("Vui lòng điền vào trường này.");
                                        nameInput.reportValidity();
                                        return;
                                    }

                                    // Check for duplicate service name
                                    const currentServiceIdVal = document.getElementById("serviceId").value;
                                    const currentServiceId = currentServiceIdVal ? parseInt(currentServiceIdVal) : -1;
                                    const table = ManagerTable.tables.servicesTable;
                                    if (table && table.items) {
                                        const isDuplicate = table.items.some(s => {
                                            return s.name.toLowerCase() === nameVal.toLowerCase() && s.id !== currentServiceId;
                                        });
                                        if (isDuplicate) {
                                            e.preventDefault();
                                            nameInput.setCustomValidity("Dịch vụ này đã tồn tại trong hệ thống. Vui lòng chọn tên khác.");
                                            nameInput.reportValidity();
                                            return;
                                        }
                                    }

                                    if (priceInput.value.trim() !== "" && (isNaN(priceVal) || priceVal <= 0)) {
                                        e.preventDefault();
                                        priceInput.setCustomValidity("Đơn giá phải lớn hơn 0.");
                                        priceInput.reportValidity();
                                        return;
                                    }

                                    if (unitVal === "") {
                                        e.preventDefault();
                                        unitInput.setCustomValidity("Vui lòng điền vào trường này.");
                                        unitInput.reportValidity();
                                        return;
                                    }
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