<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ include file="../../includes/taglibs.jsp" %>
        <%@ include file="../../includes/header.jsp" %>

            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=3" />
            <fmt:setLocale value="vi_VN" />

            <body class="dashboard-body">

                <c:set var="activePage" value="promotions" scope="request" />

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
                                            <span class="current">Quản lý Khuyến mãi</span>
                                        </div>
                                        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                                            <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                                        </a>
                                    </header>

                                    <%-- PAGE CONTENT --%>
                                        <main class="workspace-content">

                                            <%-- Hidden data container for database records --%>
                                                <div id="promotionDataStorage" style="display: none;">
                                                    <c:forEach var="promo" items="${promotionList}">
                                                        <div class="promotion-data-item"
                                                            data-id="${promo.promotionId}"
                                                            data-code="<c:out value="${promo.promotionCode}" />"
                                                            data-name="<c:out value="${promo.promotionName}" />"
                                                            data-description="<c:out value="${promo.description}" />"
                                                            data-discount-type="${promo.discountType}"
                                                            data-discount-value="${promo.discountValue}"
                                                            data-start-date="${promo.startDate}"
                                                            data-end-date="${promo.endDate}"
                                                            data-event-name="<c:out value="${promo.eventName}" />"
                                                            data-min-booking="${promo.minBookingAmount}"
                                                            data-max-discount="${promo.maxDiscountAmount}"
                                                            data-usage-limit="${promo.usageLimit}"
                                                            data-used-count="${promo.usedCount}"
                                                            data-status="${promo.status}"
                                                            data-effective-status="${promo.effectiveStatus}">
                                                        </div>
                                                    </c:forEach>
                                                </div>

                                            <%-- Alert messages --%>
                                                <c:if test="${param.error eq 'duplicateCode'}">
                                                    <div class="alert-banner alert-danger">
                                                        <i class="fa-solid fa-circle-exclamation"></i>
                                                        Mã khuyến mãi này đã tồn tại trong hệ thống. Vui lòng chọn mã khác.
                                                    </div>
                                                </c:if>
                                                <c:if test="${param.error eq 'invalidCode'}">
                                                    <div class="alert-banner alert-danger">
                                                        <i class="fa-solid fa-circle-exclamation"></i>
                                                        Mã khuyến mãi không hợp lệ. Chỉ được dùng chữ in hoa, số và dấu gạch dưới.
                                                    </div>
                                                </c:if>
                                                <c:if test="${param.error eq 'invalidName'}">
                                                    <div class="alert-banner alert-danger">
                                                        <i class="fa-solid fa-circle-exclamation"></i>
                                                        Tên khuyến mãi không được để trống.
                                                    </div>
                                                </c:if>
                                                <c:if test="${param.error eq 'invalidType'}">
                                                    <div class="alert-banner alert-danger">
                                                        <i class="fa-solid fa-circle-exclamation"></i>
                                                        Loại giảm giá không hợp lệ. Chỉ được chọn PERCENT hoặc FIXED.
                                                    </div>
                                                </c:if>
                                                <c:if test="${param.error eq 'invalidValue'}">
                                                    <div class="alert-banner alert-danger">
                                                        <i class="fa-solid fa-circle-exclamation"></i>
                                                        Giá trị giảm không hợp lệ. Phải lớn hơn 0 và không vượt quá 100% nếu là loại phần trăm.
                                                    </div>
                                                </c:if>
                                                <c:if test="${param.error eq 'invalidDate'}">
                                                    <div class="alert-banner alert-danger">
                                                        <i class="fa-solid fa-circle-exclamation"></i>
                                                        Ngày bắt đầu hoặc ngày kết thúc không hợp lệ.
                                                    </div>
                                                </c:if>
                                                <c:if test="${param.error eq 'dateRange'}">
                                                    <div class="alert-banner alert-danger">
                                                        <i class="fa-solid fa-circle-exclamation"></i>
                                                        Ngày bắt đầu phải nhỏ hơn hoặc bằng ngày kết thúc.
                                                    </div>
                                                </c:if>
                                                <c:if test="${param.error eq 'invalidLimit'}">
                                                    <div class="alert-banner alert-danger">
                                                        <i class="fa-solid fa-circle-exclamation"></i>
                                                        Giới hạn sử dụng phải lớn hơn 0 nếu có nhập.
                                                    </div>
                                                </c:if>
                                                <c:if test="${param.error eq 'invalidMin'}">
                                                    <div class="alert-banner alert-danger">
                                                        <i class="fa-solid fa-circle-exclamation"></i>
                                                        Giá trị đặt phòng tối thiểu phải >= 0.
                                                    </div>
                                                </c:if>
                                                <c:if test="${param.error eq 'invalidMax'}">
                                                    <div class="alert-banner alert-danger">
                                                        <i class="fa-solid fa-circle-exclamation"></i>
                                                        Mức giảm tối đa phải >= 0.
                                                    </div>
                                                </c:if>
                                                <c:if test="${param.error eq 'cannotDelete'}">
                                                    <div class="alert-banner alert-danger">
                                                        <i class="fa-solid fa-circle-exclamation"></i>
                                                        Không thể xóa khuyến mãi đã được sử dụng. Bạn có thể tạm khóa thay thế.
                                                    </div>
                                                </c:if>
                                                <c:if test="${param.success eq 'saved'}">
                                                    <div class="alert-banner alert-success">
                                                        <i class="fa-solid fa-circle-check"></i>
                                                        Lưu thông tin khuyến mãi thành công.
                                                    </div>
                                                </c:if>
                                                <c:if test="${param.success eq 'deleted'}">
                                                    <div class="alert-banner alert-success">
                                                        <i class="fa-solid fa-circle-check"></i>
                                                        Xóa khuyến mãi thành công.
                                                    </div>
                                                </c:if>
                                                <c:if test="${param.success eq 'toggled'}">
                                                    <div class="alert-banner alert-success">
                                                        <i class="fa-solid fa-circle-check"></i>
                                                        Cập nhật trạng thái khuyến mãi thành công.
                                                    </div>
                                                </c:if>

                                                <%-- Page Header Row --%>
                                                    <div class="content-header-row">
                                                        <div>
                                                            <h1>Quản lý Khuyến mãi</h1>
                                                            <p>Tạo và điều chỉnh mã giảm giá theo ngày lễ hoặc chiến dịch để tăng doanh thu đặt phòng.</p>
                                                        </div>
                                                        <button class="btn-add-service" onclick="openAddModal()">
                                                            <i class="fa-solid fa-plus"></i> Thêm khuyến mãi mới
                                                        </button>
                                                    </div>

                                                <%-- Promotions Main Table Wrapper --%>
                                                    <div class="table-card">

                                                        <%-- Search, Filter & Statistics Bar --%>
                                                            <div class="table-filter-bar"
                                                                style="display: grid; grid-template-columns: 1.5fr 1fr 1fr 1fr 1fr 1fr; gap: 16px; align-items: end;">

                                                                <div class="modal-form-group" style="margin-bottom: 0;">
                                                                    <label>Tìm kiếm khuyến mãi</label>
                                                                    <div class="search-wrapper" style="max-width: 100%;">
                                                                        <i class="fa-solid fa-magnifying-glass"></i>
                                                                        <input type="text" id="promoSearch"
                                                                            class="input-search-service"
                                                                            placeholder="Tìm theo mã hoặc tên..."
                                                                            onkeyup="filterPromotions()" />
                                                                    </div>
                                                                </div>

                                                                <div class="modal-form-group" style="margin-bottom: 0;">
                                                                    <label>Trạng thái</label>
                                                                    <select id="statusFilter" class="status-select"
                                                                        onchange="filterPromotions()" style="width: 100%;">
                                                                        <option value="all">Tất cả trạng thái</option>
                                                                        <option value="Active">Đang kích hoạt</option>
                                                                        <option value="Inactive">Tạm khóa</option>
                                                                        <option value="Expired">Hết hạn</option>
                                                                    </select>
                                                                </div>

                                                                <%-- Statistic chips --%>
                                                                    <div class="modal-form-group" style="margin-bottom: 0;">
                                                                        <label>Tổng khuyến mãi</label>
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

                                                                    <div class="modal-form-group" style="margin-bottom: 0;">
                                                                        <label style="color: #64748b;">Hết hạn</label>
                                                                        <div style="display: flex; align-items: center; justify-content: center; gap: 8px; background: #f8fafc; border-radius: 8px; border: 1px solid #e2e8f0; height: 40px; box-sizing: border-box;">
                                                                            <i class="fa-solid fa-clock" style="color: #64748b; font-size: 14px;"></i>
                                                                            <span id="statExpired" style="font-size: 16px; font-weight: 800; color: #64748b;">0</span>
                                                                        </div>
                                                                    </div>
                                                            </div>

                                                            <%-- Table Content --%>
                                                                <table class="services-table-element">
                                                                    <thead>
                                                                        <tr>
                                                                            <th style="width: 11%">Mã khuyến mãi</th>
                                                                            <th style="width: 18%">Tên khuyến mãi</th>
                                                                            <th style="width: 9%">Loại giảm</th>
                                                                            <th style="width: 10%">Giá trị giảm</th>
                                                                            <th style="width: 16%">Thời gian áp dụng</th>
                                                                            <th style="width: 12%">Sự kiện</th>
                                                                            <th style="width: 10%">Đã dùng / Giới hạn</th>
                                                                            <th style="width: 8%">Trạng thái</th>
                                                                            <th style="width: 6%">Thao tác</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody id="promotionsTableBody">
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

                <%-- ADD / EDIT PROMOTION MODAL DIALOG --%>
                    <div class="modal-overlay" id="promotionModal">
                        <div class="modal-container" style="max-width: 680px;">
                            <div class="modal-header">
                                <h3 id="modalTitle">Thêm khuyến mãi mới</h3>
                                <button class="btn-close-modal" onclick="closeModal()"><i class="fa-solid fa-xmark"></i></button>
                            </div>
                            <div class="modal-body">
                                <form id="promotionForm"
                                    action="${pageContext.request.contextPath}/manager/promotions?action=save"
                                    method="post">
                                    <input type="hidden" id="promotionId" name="promotionId" value="" />

                                    <%-- Row 1: Code + Name --%>
                                        <div class="modal-form-group" style="display: grid; grid-template-columns: 1fr 2fr; gap: 16px;">
                                            <div>
                                                <label for="modalCode">Mã khuyến mãi <span style="color:#dc2626;">*</span></label>
                                                <input type="text" id="modalCode" name="code" class="modal-input"
                                                    placeholder="Ví dụ: SUMMER2025"
                                                    style="text-transform: uppercase;"
                                                    required />
                                                <small style="color: #64748b; font-size: 11px;">Chỉ dùng chữ in hoa, số và dấu _</small>
                                            </div>
                                            <div>
                                                <label for="modalName">Tên khuyến mãi <span style="color:#dc2626;">*</span></label>
                                                <input type="text" id="modalName" name="name" class="modal-input"
                                                    placeholder="Ví dụ: Khuyến mãi Hè 2025" required />
                                            </div>
                                        </div>

                                    <%-- Row 2: Description --%>
                                        <div class="modal-form-group">
                                            <label for="modalDescription">Mô tả
                                                <span style="font-weight: normal; color: var(--text-muted); font-size: 11px;">(Tùy chọn)</span>
                                            </label>
                                            <textarea id="modalDescription" name="description" class="modal-textarea"
                                                placeholder="Nhập mô tả ngắn về chương trình khuyến mãi..."></textarea>
                                        </div>

                                    <%-- Row 3: DiscountType + DiscountValue --%>
                                        <div class="modal-form-group" style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                                            <div>
                                                <label for="modalDiscountType">Loại giảm giá <span style="color:#dc2626;">*</span></label>
                                                <select id="modalDiscountType" name="discountType" class="status-select"
                                                    style="width: 100%;" onchange="onDiscountTypeChange()" required>
                                                    <option value="PERCENT">Phần trăm (%)</option>
                                                    <option value="FIXED">Số tiền cố định (VNĐ)</option>
                                                </select>
                                            </div>
                                            <div>
                                                <label for="modalDiscountValue" id="discountValueLabel">Giá trị giảm (%) <span style="color:#dc2626;">*</span></label>
                                                <input type="number" id="modalDiscountValue" name="discountValue"
                                                    class="modal-input" placeholder="Ví dụ: 20"
                                                    min="0.01" step="0.01" required />
                                            </div>
                                        </div>

                                    <%-- Row 4: StartDate + EndDate --%>
                                        <div class="modal-form-group" style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                                            <div>
                                                <label for="modalStartDate">Ngày bắt đầu <span style="color:#dc2626;">*</span></label>
                                                <input type="date" id="modalStartDate" name="startDate"
                                                    class="modal-input" required />
                                            </div>
                                            <div>
                                                <label for="modalEndDate">Ngày kết thúc <span style="color:#dc2626;">*</span></label>
                                                <input type="date" id="modalEndDate" name="endDate"
                                                    class="modal-input" required />
                                            </div>
                                        </div>

                                    <%-- Row 5: EventName + UsageLimit --%>
                                        <div class="modal-form-group" style="display: grid; grid-template-columns: 2fr 1fr; gap: 16px;">
                                            <div>
                                                <label for="modalEventName">Tên sự kiện / dịp lễ
                                                    <span style="font-weight: normal; color: var(--text-muted); font-size: 11px;">(Tùy chọn)</span>
                                                </label>
                                                <input type="text" id="modalEventName" name="eventName"
                                                    class="modal-input" placeholder="Ví dụ: Tết Nguyên Đán 2025" />
                                            </div>
                                            <div>
                                                <label for="modalUsageLimit">Giới hạn lượt dùng
                                                    <span style="font-weight: normal; color: var(--text-muted); font-size: 11px;">(Tùy chọn)</span>
                                                </label>
                                                <input type="number" id="modalUsageLimit" name="usageLimit"
                                                    class="modal-input" placeholder="Ví dụ: 100" min="1" step="1" />
                                            </div>
                                        </div>

                                    <%-- Row 6: MinBookingAmount + MaxDiscountAmount --%>
                                        <div class="modal-form-group" style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                                            <div>
                                                <label for="modalMinBooking">Đặt phòng tối thiểu (VNĐ)
                                                    <span style="font-weight: normal; color: var(--text-muted); font-size: 11px;">(Tùy chọn)</span>
                                                </label>
                                                <input type="number" id="modalMinBooking" name="minBookingAmount"
                                                    class="modal-input" placeholder="Ví dụ: 1000000" min="0" step="1000" />
                                            </div>
                                            <div>
                                                <label for="modalMaxDiscount">Giảm tối đa (VNĐ)
                                                    <span style="font-weight: normal; color: var(--text-muted); font-size: 11px;">(Tùy chọn)</span>
                                                </label>
                                                <input type="number" id="modalMaxDiscount" name="maxDiscountAmount"
                                                    class="modal-input" placeholder="Ví dụ: 500000" min="0" step="1000" />
                                            </div>
                                        </div>

                                    <div class="modal-footer-row">
                                        <button type="button" class="btn-modal-cancel" onclick="closeModal()">Hủy bỏ</button>
                                        <button type="submit" class="btn-modal-submit">Lưu lại</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <%-- Shared pagination/table utility --%>
                        <script src="${pageContext.request.contextPath}/assets/js/manager-table.js" charset="UTF-8"></script>

                        <%-- JavaScript: Promotions Management Logic --%>
                            <script>
                                const CTX = '${pageContext.request.contextPath}';

                                // Initialize ManagerTable utility for promotions list
                                window.addEventListener('DOMContentLoaded', function () {
                                    ManagerTable.init("promotionsTable", {
                                        storageSelector: ".promotion-data-item",
                                        tbodyId: "promotionsTableBody",
                                        paginationInfoId: "paginationInfo",
                                        paginationControlsId: "paginationControls",
                                        pageSize: 8,
                                        emptyMessage: "Không tìm thấy khuyến mãi nào phù hợp",
                                        infoTextFn: (start, end, total) => `Hiển thị \${start}-\${end} trong số \${total} khuyến mãi`,
                                        hydrateItem: function (item) {
                                            return {
                                                id:              parseInt(item.getAttribute("data-id")),
                                                code:            (item.getAttribute("data-code") || "").trim(),
                                                name:            (item.getAttribute("data-name") || "").trim(),
                                                description:     (item.getAttribute("data-description") || "").trim(),
                                                discountType:    (item.getAttribute("data-discount-type") || "").trim(),
                                                discountValue:   parseFloat(item.getAttribute("data-discount-value")) || 0,
                                                startDate:       (item.getAttribute("data-start-date") || "").trim(),
                                                endDate:         (item.getAttribute("data-end-date") || "").trim(),
                                                eventName:       (item.getAttribute("data-event-name") || "").trim(),
                                                minBooking:      item.getAttribute("data-min-booking"),
                                                maxDiscount:     item.getAttribute("data-max-discount"),
                                                usageLimit:      item.getAttribute("data-usage-limit"),
                                                usedCount:       parseInt(item.getAttribute("data-used-count")) || 0,
                                                status:          (item.getAttribute("data-status") || "").trim(),
                                                effectiveStatus: (item.getAttribute("data-effective-status") || "").trim()
                                            };
                                        },
                                        renderRow: function (promo) {
                                            const discountLabel = promo.discountType === 'PERCENT'
                                                ? `<span style="background:#eff6ff;color:#1d4ed8;padding:2px 8px;border-radius:20px;font-size:11px;font-weight:700;">%</span>`
                                                : `<span style="background:#fef3c7;color:#b45309;padding:2px 8px;border-radius:20px;font-size:11px;font-weight:700;">VNĐ</span>`;

                                            const discountDisplay = promo.discountType === 'PERCENT'
                                                ? `\${promo.discountValue}%`
                                                : `\${new Intl.NumberFormat('vi-VN').format(promo.discountValue)} VNĐ`;

                                            const limitDisplay = promo.usageLimit
                                                ? `\${promo.usedCount} / \${promo.usageLimit}`
                                                : `\${promo.usedCount} / ∞`;

                                            let statusBadge = '';
                                            if (promo.effectiveStatus === 'Active') {
                                                statusBadge = `<span style="background:#dcfce7;color:#15803d;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:700;">Kích hoạt</span>`;
                                            } else if (promo.effectiveStatus === 'Inactive') {
                                                statusBadge = `<span style="background:#fee2e2;color:#b91c1c;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:700;">Tạm khóa</span>`;
                                            } else {
                                                statusBadge = `<span style="background:#f1f5f9;color:#475569;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:700;">Hết hạn</span>`;
                                            }

                                            const isExpired = promo.effectiveStatus === 'Expired';
                                            const isActive  = promo.effectiveStatus === 'Active';
                                            const toggleTitle   = isActive ? 'Tạm khóa' : 'Kích hoạt';
                                            const toggleNewStat = isActive ? 'Inactive' : 'Active';
                                            const toggleIcon    = isActive
                                                ? `<i class="fa-solid fa-toggle-on" style="color:#16a34a;font-size:18px;"></i>`
                                                : `<i class="fa-solid fa-toggle-off" style="color:#94a3b8;font-size:18px;"></i>`;

                                            const toggleBtn = isExpired ? '' :
                                                `<button class="btn-action edit" onclick="toggleStatus(\${promo.id}, '\${toggleNewStat}')" title="\${toggleTitle}" style="background:transparent;border:none;cursor:pointer;padding:4px;">
                                                    \${toggleIcon}
                                                 </button>`;

                                            const deleteBtn = promo.usedCount === 0
                                                ? `<button class="btn-action delete" onclick="deletePromotion(\${promo.id})" title="Xóa">
                                                       <i class="fa-solid fa-trash-can"></i>
                                                   </button>`
                                                : `<button class="btn-action" title="Đã được sử dụng, không thể xóa"
                                                       style="opacity:0.35;cursor:not-allowed;" disabled>
                                                       <i class="fa-solid fa-trash-can"></i>
                                                   </button>`;

                                            return `
                                                <td>
                                                    <span style="font-family:monospace;font-weight:700;font-size:12px;color:#1e293b;">\${promo.code}</span>
                                                </td>
                                                <td>
                                                    <span class="service-title">\${promo.name}</span>
                                                </td>
                                                <td style="text-align:center;">\${discountLabel}</td>
                                                <td style="font-weight:700;color:#1e293b;">\${discountDisplay}</td>
                                                <td style="font-size:12px;color:#475569;">
                                                    \${promo.startDate}<br><small>→ \${promo.endDate}</small>
                                                </td>
                                                <td style="font-size:12px;color:#64748b;">\${promo.eventName || '—'}</td>
                                                <td style="text-align:center;font-size:13px;">\${limitDisplay}</td>
                                                <td style="text-align:center;">\${statusBadge}</td>
                                                <td>
                                                    <div class="table-actions" style="justify-content:center;">
                                                        <button class="btn-action edit" onclick="openEditModal(\${promo.id})" title="Chỉnh sửa">
                                                            <i class="fa-solid fa-pencil"></i>
                                                        </button>
                                                        \${toggleBtn}
                                                        \${deleteBtn}
                                                    </div>
                                                </td>
                                            `;
                                        },
                                        filterPredicate: function (promo) {
                                            const query  = document.getElementById("promoSearch").value.toLowerCase().trim();
                                            const status = document.getElementById("statusFilter").value;

                                            const matchQuery = promo.code.toLowerCase().includes(query) ||
                                                               promo.name.toLowerCase().includes(query);
                                            const matchStatus = (status === "all") ||
                                                                (status === promo.effectiveStatus);
                                            return matchQuery && matchStatus;
                                        },
                                        onAfterRender: function (table) {
                                            const total    = table.items.length;
                                            const active   = table.items.filter(p => p.effectiveStatus === 'Active').length;
                                            const inactive = table.items.filter(p => p.effectiveStatus === 'Inactive').length;
                                            const expired  = table.items.filter(p => p.effectiveStatus === 'Expired').length;
                                            document.getElementById('statTotal').innerText   = total;
                                            document.getElementById('statActive').innerText  = active;
                                            document.getElementById('statInactive').innerText = inactive;
                                            document.getElementById('statExpired').innerText  = expired;
                                        }
                                    });
                                });

                                // Filter trigger
                                function filterPromotions() {
                                    ManagerTable.filter("promotionsTable");
                                }

                                // Discount type change → update label
                                function onDiscountTypeChange() {
                                    const type = document.getElementById('modalDiscountType').value;
                                    const lbl  = document.getElementById('discountValueLabel');
                                    const inp  = document.getElementById('modalDiscountValue');
                                    if (type === 'PERCENT') {
                                        lbl.innerHTML = 'Giá trị giảm (%) <span style="color:#dc2626;">*</span>';
                                        inp.setAttribute('max', '100');
                                        inp.placeholder = 'Ví dụ: 20';
                                    } else {
                                        lbl.innerHTML = 'Giá trị giảm (VNĐ) <span style="color:#dc2626;">*</span>';
                                        inp.removeAttribute('max');
                                        inp.placeholder = 'Ví dụ: 200000';
                                    }
                                }

                                // Toggle status
                                function toggleStatus(id, newStatus) {
                                    const label = newStatus === 'Active' ? 'kích hoạt' : 'tạm khóa';
                                    if (confirm(`Bạn có chắc muốn \${label} khuyến mãi này không?`)) {
                                        window.location.href = CTX + '/manager/promotions?action=toggle&id=' + id + '&status=' + newStatus;
                                    }
                                }

                                // Modal Handlers
                                function openAddModal() {
                                    document.getElementById("modalTitle").innerText = "Thêm khuyến mãi mới";
                                    document.getElementById("promotionId").value = "";
                                    document.getElementById("promotionForm").reset();
                                    onDiscountTypeChange();
                                    document.getElementById("promotionModal").style.display = "flex";
                                }

                                function openEditModal(id) {
                                    const table = ManagerTable.tables.promotionsTable;
                                    if (!table) return;
                                    const promo = table.items.find(p => p.id === id);
                                    if (!promo) return;

                                    document.getElementById("modalTitle").innerText = "Chỉnh sửa khuyến mãi";
                                    document.getElementById("promotionId").value           = promo.id;
                                    document.getElementById("modalCode").value             = promo.code;
                                    document.getElementById("modalName").value             = promo.name;
                                    document.getElementById("modalDescription").value      = promo.description;
                                    document.getElementById("modalDiscountType").value     = promo.discountType;
                                    document.getElementById("modalDiscountValue").value    = promo.discountValue;
                                    document.getElementById("modalStartDate").value        = promo.startDate;
                                    document.getElementById("modalEndDate").value          = promo.endDate;
                                    document.getElementById("modalEventName").value        = promo.eventName;
                                    document.getElementById("modalUsageLimit").value       = promo.usageLimit || '';
                                    document.getElementById("modalMinBooking").value       = promo.minBooking || '';
                                    document.getElementById("modalMaxDiscount").value      = promo.maxDiscount || '';
                                    onDiscountTypeChange();
                                    document.getElementById("promotionModal").style.display = "flex";
                                }

                                function closeModal() {
                                    document.getElementById("promotionModal").style.display = "none";
                                }

                                // Delete promotion
                                function deletePromotion(id) {
                                    if (confirm("Bạn có chắc chắn muốn xóa khuyến mãi này không?")) {
                                        window.location.href = CTX + '/manager/promotions?action=delete&id=' + id;
                                    }
                                }

                                // Client-side form validation before submit
                                document.getElementById('promotionForm').addEventListener('submit', function (e) {
                                    const code      = document.getElementById('modalCode').value.trim();
                                    const name      = document.getElementById('modalName').value.trim();
                                    const type      = document.getElementById('modalDiscountType').value;
                                    const value     = parseFloat(document.getElementById('modalDiscountValue').value);
                                    const startDate = document.getElementById('modalStartDate').value;
                                    const endDate   = document.getElementById('modalEndDate').value;

                                    const codeInput = document.getElementById('modalCode');
                                    if (!/^[A-Z0-9_]+$/.test(code)) {
                                        e.preventDefault();
                                        codeInput.setCustomValidity("Chỉ được dùng chữ in hoa, số và dấu gạch dưới.");
                                        codeInput.reportValidity();
                                        return;
                                    } else {
                                        codeInput.setCustomValidity("");
                                    }

                                    if (name === '') {
                                        e.preventDefault();
                                        const nameInput = document.getElementById('modalName');
                                        nameInput.setCustomValidity("Tên khuyến mãi không được để trống.");
                                        nameInput.reportValidity();
                                        return;
                                    }

                                    const valueInput = document.getElementById('modalDiscountValue');
                                    if (isNaN(value) || value <= 0) {
                                        e.preventDefault();
                                        valueInput.setCustomValidity("Giá trị giảm phải lớn hơn 0.");
                                        valueInput.reportValidity();
                                        return;
                                    }
                                    if (type === 'PERCENT' && value > 100) {
                                        e.preventDefault();
                                        valueInput.setCustomValidity("Giá trị phần trăm không được vượt quá 100%.");
                                        valueInput.reportValidity();
                                        return;
                                    }
                                    valueInput.setCustomValidity("");

                                    if (startDate && endDate && startDate > endDate) {
                                        e.preventDefault();
                                        const endInput = document.getElementById('modalEndDate');
                                        endInput.setCustomValidity("Ngày kết thúc phải sau hoặc bằng ngày bắt đầu.");
                                        endInput.reportValidity();
                                        return;
                                    }
                                });

                                // Clear custom validity on input
                                ['modalCode', 'modalName', 'modalDiscountValue', 'modalEndDate'].forEach(function (id) {
                                    const el = document.getElementById(id);
                                    if (el) el.addEventListener('input', function () { this.setCustomValidity(''); });
                                });

                                // Auto-uppercase promotion code input
                                const codeInput = document.getElementById('modalCode');
                                if (codeInput) {
                                    codeInput.addEventListener('input', function () {
                                        const sel = this.selectionStart;
                                        this.value = this.value.toUpperCase().replace(/[^A-Z0-9_]/g, '');
                                        this.setSelectionRange(sel, sel);
                                    });
                                }
                            </script>
            </body>

            </html>
