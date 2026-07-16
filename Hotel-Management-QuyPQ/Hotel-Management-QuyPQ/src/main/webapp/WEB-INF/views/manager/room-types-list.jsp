<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=3" />
<fmt:setLocale value="vi_VN" />

<body class="dashboard-body">

    <c:set var="activePage" value="room-types" scope="request" />

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
                    <span class="current">Quản lý loại phòng</span>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </a>
            </header>

            <%-- PAGE CONTENT --%>
            <main class="workspace-content">

                <%-- Hidden data container for database records --%>
                <div id="roomTypeDataStorage" style="display: none;">
                    <c:forEach var="rt" items="${roomTypesList}">
                        <div class="roomtype-data-item" data-id="${rt.typeId}"
                            data-name="<c:out value="${rt.typeName}" />"
                            data-price="${rt.basePrice}"
                            data-capacity="${rt.capacity}"
                            data-bed-type="<c:out value="${rt.bedType}" />"
                            data-area="<c:out value="${rt.area}" />"
                            data-image-url="<c:out value="${rt.imageUrl}" />"
                            data-description="<c:out value="${rt.description}" />"
                            data-amenities="<c:forEach var="am" items="${rt.amenities}" varStatus="st">${am}${!st.last ? ',' : ''}</c:forEach>">
                        </div>
                    </c:forEach>
                </div>

                <%-- Alert messages --%>
                <c:if test="${param.success eq 'saved'}">
                    <div class="alert-banner alert-success">
                        <i class="fa-solid fa-circle-check"></i>
                        Lưu thông tin loại phòng thành công.
                    </div>
                </c:if>
                <c:if test="${param.error eq 'deleteError'}">
                    <div class="alert-banner alert-danger">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        Không thể xóa loại phòng này. Loại phòng đang được sử dụng bởi phòng khác trong hệ thống.
                    </div>
                </c:if>
                <c:if test="${param.error eq 'duplicateName'}">
                    <div class="alert-banner alert-danger">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        This Room Type is already available.
                    </div>
                </c:if>

                <div class="content-header-row">
                    <div>
                        <h1>Quản lý Loại Phòng</h1>
                        <p>Cập nhật và điều chỉnh thông tin các loại phòng nghỉ của khách sạn.</p>
                    </div>
                    <button class="btn-add-service" onclick="openAddRoomTypeModal()">
                        <i class="fa-solid fa-plus"></i> Thêm Loại Phòng
                    </button>
                </div>

                <%-- Room Types Table Wrapper --%>
                <div class="table-card">

                    <%-- Search & Dropdown Filters Bar --%>
                    <div class="table-filter-bar" style="display: grid; grid-template-columns: 1.5fr 1fr; gap: 16px; align-items: end;">
                        <div class="modal-form-group" style="margin-bottom: 0;">
                            <label>Tìm kiếm loại phòng</label>
                            <div class="search-wrapper" style="max-width: 100%;">
                                <i class="fa-solid fa-magnifying-glass"></i>
                                <input type="text" id="roomTypeSearch" class="input-search-service" placeholder="Tìm kiếm loại phòng..." onkeyup="filterRoomTypes()" />
                            </div>
                        </div>

                        <div class="modal-form-group" style="margin-bottom: 0;">
                            <label>Sức chứa</label>
                            <select id="capacityFilter" class="status-select" onchange="filterRoomTypes()" style="width: 100%;">
                                <option value="all">Tất cả sức chứa</option>
                                <option value="1">1 người</option>
                                <option value="2">2 người</option>
                                <option value="3">3 người</option>
                                <option value="4+">4 hoặc lớn hơn</option>
                            </select>
                        </div>
                    </div>

                    <%-- Table Content --%>
                    <table class="services-table-element">
                        <thead>
                            <tr>
                                <th style="width: 25%">Tên Loại Phòng</th>
                                <th style="width: 15%">Sức chứa</th>
                                <th style="width: 15%">Loại Giường</th>
                                <th style="width: 20%">Tiện nghi</th>
                                <th style="width: 15%">Giá Cơ Bản</th>
                                <th style="width: 10%">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody id="roomTypesTableBody">
                            <%-- Dynamic rows generated by JavaScript --%>
                        </tbody>
                    </table>

                    <%-- Table Pagination Footer --%>
                    <div class="table-pagination-bar">
                        <div class="pagination-info" id="roomTypePaginationInfo">
                            Đang tải...
                        </div>
                        <div class="pagination-controls" id="roomTypePaginationControls">
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

    <%-- ADD / EDIT ROOM TYPE MODAL DIALOG --%>
    <div class="modal-overlay" id="roomTypeModal">
        <div class="modal-container" style="max-width: 600px;">
            <div class="modal-header">
                <h3 id="roomTypeModalTitle">Thêm loại phòng mới</h3>
                <button class="btn-close-modal" onclick="closeRoomTypeModal()"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="modal-body">
                <form id="roomTypeForm" action="${pageContext.request.contextPath}/manager/roomtypes?action=save" method="post">
                    <input type="hidden" id="modalRtId" name="roomTypeId" value="" />

                    <div class="modal-form-group">
                        <label for="modalRtName">Tên loại phòng</label>
                        <input type="text" id="modalRtName" name="name" class="modal-input" placeholder="Ví dụ: Deluxe Ocean View" required />
                    </div>

                    <div class="modal-form-group" style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                        <div>
                            <label for="modalRtPrice">Giá cơ bản (VNĐ)</label>
                            <input type="number" id="modalRtPrice" name="price" class="modal-input" placeholder="Ví dụ: 2500000" required />
                        </div>
                        <div>
                            <label for="modalRtCapacity">Sức chứa (người lớn)</label>
                            <input type="number" id="modalRtCapacity" name="capacity" class="modal-input" placeholder="Ví dụ: 2" required />
                        </div>
                    </div>

                    <div class="modal-form-group" style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                        <div>
                            <label for="modalRtBedType">Loại Giường</label>
                            <input type="text" id="modalRtBedType" name="bedType" class="modal-input" placeholder="Ví dụ: King Bed" required />
                        </div>
                        <div>
                            <label for="modalRtArea">Diện tích (m²)</label>
                            <input type="text" id="modalRtArea" name="area" class="modal-input" placeholder="Ví dụ: 45 m²" required />
                        </div>
                    </div>

                    <div class="modal-form-group">
                        <label for="modalRtImageUrl">URL hình ảnh</label>
                        <input type="text" id="modalRtImageUrl" name="imageUrl" class="modal-input" placeholder="Ví dụ: https://..." required />
                    </div>

                    <div class="modal-form-group">
                        <label for="modalRtDescription">Mô tả loại phòng
                            <span style="font-weight: normal; color: var(--text-muted); font-size: 11px;">(Tùy chọn)</span>
                        </label>
                        <textarea id="modalRtDescription" name="description" class="modal-textarea" placeholder="Nhập mô tả chi tiết..."></textarea>
                    </div>

                    <div class="modal-form-group">
                        <label>Tiện nghi loại phòng</label>
                        <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 8px; margin-top: 6px;">
                            <c:forEach var="amenity" items="${amenitiesList}">
                                <label style="display: flex; align-items: center; gap: 8px; font-weight: 500; cursor: pointer;">
                                    <input type="checkbox" name="amenity" value="<c:out value="${amenity.name}" />" style="width: 16px; height: 16px;" /> 
                                    <i class="<c:out value="${amenity.icon}" />" style="color: #64748b; font-size: 14px;"></i>
                                    <c:out value="${amenity.name}" />
                                </label>
                            </c:forEach>
                        </div>
                    </div>

                    <div class="modal-footer-row">
                        <button type="button" class="btn-modal-cancel" onclick="closeRoomTypeModal()">Hủy bỏ</button>
                        <button type="submit" class="btn-modal-submit">Lưu lại</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%-- Shared pagination/table utility --%>
    <script src="${pageContext.request.contextPath}/assets/js/manager-table.js" charset="UTF-8"></script>

    <%-- JavaScript: Room Types Management Logic --%>
    <script>
        // Initialize ManagerTable utility for room types list
        window.addEventListener('DOMContentLoaded', function () {
            ManagerTable.init("roomTypesTable", {
                storageSelector: ".roomtype-data-item",
                tbodyId: "roomTypesTableBody",
                paginationInfoId: "roomTypePaginationInfo",
                paginationControlsId: "roomTypePaginationControls",
                pageSize: 5,
                emptyMessage: "Không tìm thấy loại phòng nào phù hợp",
                infoTextFn: (start, end, total) => `Hiển thị \${start}-\${end} trong số \${total} loại phòng`,
                hydrateItem: function (item) {
                    const amenitiesStr = item.getAttribute("data-amenities");
                    const amenitiesList = amenitiesStr ? amenitiesStr.split(",") : [];
                    return {
                        id: parseInt(item.getAttribute("data-id")),
                        name: (item.getAttribute("data-name") || "").trim(),
                        price: parseFloat(item.getAttribute("data-price")),
                        capacity: parseInt(item.getAttribute("data-capacity")),
                        bedType: (item.getAttribute("data-bed-type") || "").trim(),
                        area: (item.getAttribute("data-area") || "").trim(),
                        imageUrl: (item.getAttribute("data-image-url") || "").trim(),
                        description: (item.getAttribute("data-description") || "").trim(),
                        amenities: amenitiesList
                    };
                },
                renderRow: function (rt) {
                    const priceFormatted = new Intl.NumberFormat('vi-VN').format(rt.price);

                    let amenitiesHtml = "";
                    rt.amenities.forEach(am => {
                        if (am.trim()) {
                            let badgeText = am.toUpperCase();
                            if (badgeText.includes("WIFI")) badgeText = "WIFI";
                            else if (badgeText.includes("ĐIỀU HÒA")) badgeText = "AC";
                            else if (badgeText.includes("TIVI")) badgeText = "TV";
                            else if (badgeText.includes("VIEW THÀNH PHỐ")) badgeText = "CITY VIEW";
                            else if (badgeText.includes("BỒN TẮM")) badgeText = "BATHTUB";
                            else if (badgeText.includes("MINI BAR")) badgeText = "MINI BAR";
                            else if (badgeText.includes("BAN CÔNG")) badgeText = "BALCONY";
                            else if (badgeText.includes("MÁY PHA CÀ PHÊ")) badgeText = "COFFEE";
                            amenitiesHtml += `<span class="roomtype-badge">\${badgeText}</span>`;
                        }
                    });

                    return `
                        <td>
                            <div class="service-name-cell">
                                <img src="\${rt.imageUrl}" class="roomtype-img" alt="\${rt.name}"
                                     onerror="this.src='https://images.unsplash.com/photo-1618773928121-c32242e63f39?q=80&w=600'" />
                                <div>
                                    <span class="service-title">\${rt.name}</span>
                                    <span style="font-size: 11px; color: var(--text-muted); font-weight: 500;">ID: RT-00\${rt.id}</span>
                                </div>
                            </div>
                        </td>
                        <td>
                            <span class="service-desc-text" style="font-weight: 600; color: var(--text-navy); margin: 0;">\${rt.capacity} Người lớn</span>
                        </td>
                        <td>
                            <span class="service-desc-text" style="font-weight: 500; color: #475569; margin: 0;">\${rt.bedType}</span>
                        </td>
                        <td>
                            <div style="max-width: 220px;">\${amenitiesHtml || '<span style="color: var(--text-muted); font-style: italic; font-size: 12px;">Không có</span>'}</div>
                        </td>
                        <td>
                            <span class="service-price-text" style="font-size: 16px; color: var(--brand-blue); font-weight: bold;">\${priceFormatted}đ</span>
                        </td>
                        <td>
                            <div class="table-actions">
                                <button class="btn-action edit" onclick="openEditRoomTypeModal(\${rt.id})" title="Chỉnh sửa">
                                    <i class="fa-solid fa-pencil"></i>
                                </button>
                                <button class="btn-action delete" onclick="deleteRoomType(\${rt.id})" title="Xóa">
                                    <i class="fa-solid fa-trash-can"></i>
                                </button>
                            </div>
                        </td>
                    `;
                },
                filterPredicate: function (rt) {
                    const query = document.getElementById("roomTypeSearch").value.toLowerCase().trim();
                    const capacity = document.getElementById("capacityFilter").value;

                    const matchQuery = rt.name.toLowerCase().includes(query) ||
                        rt.bedType.toLowerCase().includes(query) ||
                        rt.description.toLowerCase().includes(query);

                    let matchCapacity = true;
                    if (capacity !== "all") {
                        if (capacity === "4+") {
                            matchCapacity = (rt.capacity >= 4);
                        } else {
                            matchCapacity = (rt.capacity === parseInt(capacity));
                        }
                    }

                    return matchQuery && matchCapacity;
                }
            });
        });

        // Filter trigger
        function filterRoomTypes() {
            ManagerTable.filter("roomTypesTable");
        }

        // Clear validation errors
        function clearRoomTypeErrors() {
            ['modalRtName', 'modalRtPrice', 'modalRtCapacity', 'modalRtBedType', 'modalRtArea', 'modalRtImageUrl', 'modalRtDescription']
                .forEach(id => {
                    const el = document.getElementById(id);
                    if (el) el.setCustomValidity("");
                });
        }

        // Modal Handlers
        function openAddRoomTypeModal() {
            clearRoomTypeErrors();
            document.getElementById("roomTypeModalTitle").innerText = "Thêm loại phòng mới";
            document.getElementById("modalRtId").value = "";
            document.getElementById("roomTypeForm").reset();
            document.querySelectorAll('#roomTypeForm input[name="amenity"]').forEach(cb => cb.checked = false);
            document.getElementById("roomTypeModal").style.display = "flex";
        }

        function openEditRoomTypeModal(id) {
            const table = ManagerTable.tables.roomTypesTable;
            if (!table) return;
            const rt = table.items.find(item => item.id === id);
            if (rt) {
                clearRoomTypeErrors();
                document.getElementById("roomTypeModalTitle").innerText = "Chỉnh sửa loại phòng";
                document.getElementById("modalRtId").value = rt.id;
                document.getElementById("modalRtName").value = rt.name;
                document.getElementById("modalRtPrice").value = rt.price;
                document.getElementById("modalRtCapacity").value = rt.capacity;
                document.getElementById("modalRtBedType").value = rt.bedType;
                document.getElementById("modalRtArea").value = rt.area;
                document.getElementById("modalRtImageUrl").value = rt.imageUrl;
                document.getElementById("modalRtDescription").value = rt.description;
                document.querySelectorAll('#roomTypeForm input[name="amenity"]').forEach(cb => {
                    cb.checked = rt.amenities.some(am => am.toLowerCase().trim() === cb.value.toLowerCase().trim());
                });
                document.getElementById("roomTypeModal").style.display = "flex";
            }
        }

        function closeRoomTypeModal() {
            clearRoomTypeErrors();
            document.getElementById("roomTypeModal").style.display = "none";
        }

        function deleteRoomType(id) {
            if (confirm("Bạn có chắc chắn muốn xóa loại phòng này không?\nLưu ý: Hành động này sẽ xóa tất cả phòng thuộc loại phòng này.")) {
                window.location.href = `${pageContext.request.contextPath}/manager/roomtypes?action=delete&id=` + id;
            }
        }

        // Input listeners for real-time validity clearing
        ['modalRtName', 'modalRtPrice', 'modalRtCapacity', 'modalRtBedType', 'modalRtArea', 'modalRtImageUrl', 'modalRtDescription']
            .forEach(id => {
                const el = document.getElementById(id);
                if (el) el.addEventListener('input', function () { this.setCustomValidity(""); });
            });

        // Form Submit Validation
        document.getElementById('roomTypeForm').addEventListener('submit', function (e) {
            clearRoomTypeErrors();

            const nameInput = document.getElementById('modalRtName');
            const priceInput = document.getElementById('modalRtPrice');
            const capacityInput = document.getElementById('modalRtCapacity');
            const bedTypeInput = document.getElementById('modalRtBedType');
            const areaInput = document.getElementById('modalRtArea');
            const imageUrlInput = document.getElementById('modalRtImageUrl');

            const nameVal = nameInput.value.trim();
            const priceVal = parseFloat(priceInput.value);
            const capacityVal = parseFloat(capacityInput.value);
            const bedTypeVal = bedTypeInput.value.trim();
            const areaVal = areaInput.value.trim();
            const imageUrlVal = imageUrlInput.value.trim();

            if (nameVal === "") {
                e.preventDefault();
                nameInput.setCustomValidity("Vui lòng điền vào trường này.");
                nameInput.reportValidity();
                return;
            }

            if (priceInput.value.trim() !== "" && (isNaN(priceVal) || priceVal <= 0)) {
                e.preventDefault();
                priceInput.setCustomValidity("Giá cơ bản phải lớn hơn 0.");
                priceInput.reportValidity();
                return;
            }

            if (capacityInput.value.trim() !== "" && (isNaN(capacityVal) || capacityVal <= 0)) {
                e.preventDefault();
                capacityInput.setCustomValidity("Sức chứa phải lớn hơn 0.");
                capacityInput.reportValidity();
                return;
            }

            if (bedTypeVal === "") {
                e.preventDefault();
                bedTypeInput.setCustomValidity("Vui lòng điền vào trường này.");
                bedTypeInput.reportValidity();
                return;
            }
            if (/-\s*\d/.test(bedTypeVal) || /^\s*-/.test(bedTypeVal) || /^\s*0\s/.test(bedTypeVal) || /^\s*0$/.test(bedTypeVal)) {
                e.preventDefault();
                bedTypeInput.setCustomValidity("Incorrect format");
                bedTypeInput.reportValidity();
                return;
            }

            if (areaVal !== "") {
                const numericArea = parseFloat(areaVal);
                if (isNaN(numericArea) || numericArea <= 0) {
                    e.preventDefault();
                    areaInput.setCustomValidity("Diện tích phải lớn hơn 0.");
                    areaInput.reportValidity();
                    return;
                }
                areaInput.value = numericArea + " m²";
            }

            if (imageUrlVal === "") {
                e.preventDefault();
                imageUrlInput.setCustomValidity("Vui lòng điền vào trường này.");
                imageUrlInput.reportValidity();
                return;
            }
        });
    </script>
</body>
</html>
