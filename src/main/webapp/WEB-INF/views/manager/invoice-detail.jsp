<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=4" />
<fmt:setLocale value="vi_VN" />

<body class="dashboard-body">

    <div class="dashboard-layout">

        <!-- SIDEBAR -->
        <c:set var="activePage" value="invoices" scope="request" />
        <jsp:include page="includes/sidebar.jsp" />

        <div class="dashboard-main">
            <header class="main-topbar">
                <div class="breadcrumb">
                    <span>Quản trị</span>
                    <span class="separator">&gt;</span>
                    <a href="${pageContext.request.contextPath}/manager/invoices" style="color:var(--text-muted); text-decoration:none;">Hóa đơn</a>
                    <span class="separator">&gt;</span>
                    <span class="current">HD-<fmt:formatNumber value="${invoice.invoiceId}" minIntegerDigits="4" groupingUsed="false" /></span>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </a>
            </header>

            <main class="workspace-content">

                <div class="content-header-row">
                    <div>
                        <a href="${pageContext.request.contextPath}/manager/invoices" class="btn-back">
                            <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
                        </a>
                        <h1 style="margin-top:12px;">Hóa đơn HD-<fmt:formatNumber value="${invoice.invoiceId}" minIntegerDigits="4" groupingUsed="false" /></h1>
                        <p>
                            Khách hàng: <strong><c:out value="${invoice.customerName}" /></strong>
                            &nbsp;•&nbsp; Phòng <strong><c:out value="${invoice.roomNumber}" /></strong>
                            &nbsp;•&nbsp; Ngày tạo: <fmt:formatDate value="${invoice.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                        </p>
                    </div>
                    <div>
                        <c:choose>
                            <c:when test="${invoice.status eq 'Pending'}"><span class="inv-badge inv-pending">CHƯA THANH TOÁN</span></c:when>
                            <c:when test="${invoice.status eq 'Paid'}"><span class="inv-badge inv-paid">ĐÃ THANH TOÁN</span></c:when>
                            <c:when test="${invoice.status eq 'Refunding'}"><span class="inv-badge inv-refunding">CHỜ HOÀN</span></c:when>
                            <c:when test="${invoice.status eq 'Refunded'}"><span class="inv-badge inv-refunded">ĐÃ HOÀN</span></c:when>
                            <c:otherwise><span class="inv-badge inv-cancelled">ĐÃ HUỶ</span></c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="invoice-detail-grid">

                    <!-- CỘT TRÁI: chi tiết hóa đơn -->
                    <div>
                        <div class="table-card" style="margin-bottom:24px;">
                            <div class="card-section-title"><i class="fa-solid fa-list-ul"></i> Chi tiết hóa đơn</div>
                            <table class="services-table-element">
                                <thead>
                                    <tr>
                                        <th style="width:14%">Loại</th>
                                        <th style="width:40%">Nội dung</th>
                                        <th style="width:10%">SL</th>
                                        <th style="width:18%">Đơn giá</th>
                                        <th style="width:18%">Thành tiền</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="it" items="${items}">
                                        <tr>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${it.itemType eq 'Room'}"><span class="item-type-badge it-room">PHÒNG</span></c:when>
                                                    <c:when test="${it.itemType eq 'Service'}"><span class="item-type-badge it-service">DỊCH VỤ</span></c:when>
                                                    <c:otherwise><span class="item-type-badge it-surcharge">PHỤ PHÍ</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td><c:out value="${it.description}" /></td>
                                            <td>${it.quantity}</td>
                                            <td><fmt:formatNumber value="${it.unitPrice}" type="number" maxFractionDigits="0" /> đ</td>
                                            <td style="font-weight:600;"><fmt:formatNumber value="${it.amount}" type="number" maxFractionDigits="0" /> đ</td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty items}">
                                        <tr><td colspan="5" style="text-align:center; padding:30px; color:var(--text-muted);">Chưa có dòng chi tiết</td></tr>
                                    </c:if>
                                </tbody>
                            </table>

                            <div class="invoice-totals">
                                <div class="total-row">
                                    <span>Tổng cộng</span>
                                    <span><fmt:formatNumber value="${invoice.totalAmount}" type="number" maxFractionDigits="0" /> đ</span>
                                </div>
                                <div class="total-row">
                                    <span>Tiền cọc đã trả (30% tiền phòng)</span>
                                    <span style="color:#dc2626;">- <fmt:formatNumber value="${invoice.depositAmount}" type="number" maxFractionDigits="0" /> đ</span>
                                </div>
                                <div class="total-row">
                                    <span>Đã hoàn</span>
                                    <span style="color:#dc2626;">- <fmt:formatNumber value="${invoice.refundedAmount}" type="number" maxFractionDigits="0" /> đ</span>
                                </div>
                                <div class="total-row total-net">
                                    <span>Thực thu</span>
                                    <span><fmt:formatNumber value="${invoice.netAmount}" type="number" maxFractionDigits="0" /> đ</span>
                                </div>
                            </div>
                        </div>

                        <!-- Số tiền chờ hoàn: danh sách khoản chờ hoàn, có thể xác nhận -->
                        <c:if test="${not empty pendingRefunds}">
                            <div class="table-card refund-pending-card" style="margin-bottom:24px;">
                                <div class="card-section-title">
                                    <i class="fa-solid fa-hourglass-half"></i> Số tiền chờ hoàn
                                    <span class="pending-total-badge"><fmt:formatNumber value="${invoice.pendingRefundAmount}" type="number" maxFractionDigits="0" /> đ</span>
                                </div>
                                <div class="pending-toolbar">
                                    <label class="pending-checkall">
                                        <input type="checkbox" id="refundCheckAll" onclick="toggleAllRefunds(this)" /> Chọn tất cả
                                    </label>
                                    <button type="button" class="btn-confirm-refund" onclick="confirmSelectedRefunds()">
                                        <i class="fa-solid fa-check-double"></i> Xác nhận khoản đã chọn
                                    </button>
                                </div>
                                <table class="services-table-element">
                                    <thead>
                                        <tr>
                                            <th style="width:8%"></th>
                                            <th style="width:26%">Số tiền</th>
                                            <th style="width:40%">Lý do</th>
                                            <th style="width:26%">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="pr" items="${pendingRefunds}">
                                            <tr>
                                                <td><input type="checkbox" class="refund-check" value="${pr.refundId}" /></td>
                                                <td style="font-weight:700; color:#ea580c;"><fmt:formatNumber value="${pr.amount}" type="number" maxFractionDigits="0" /> đ</td>
                                                <td><c:out value="${pr.reason}" /></td>
                                                <td>
                                                    <button type="button" class="btn-confirm-one" onclick="confirmOneRefund(${pr.refundId})">
                                                        <i class="fa-solid fa-check"></i> Xác nhận đã hoàn
                                                    </button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:if>

                        <!-- Lịch sử hoàn tiền -->
                        <div class="table-card">
                            <div class="card-section-title"><i class="fa-solid fa-clock-rotate-left"></i> Lịch sử hoàn tiền</div>
                            <c:choose>
                                <c:when test="${empty refunds}">
                                    <p style="padding:8px 24px 20px; color:var(--text-muted); font-style:italic;">Chưa có khoản hoàn tiền nào.</p>
                                </c:when>
                                <c:otherwise>
                                    <table class="services-table-element">
                                        <thead>
                                            <tr>
                                                <th style="width:22%">Số tiền</th>
                                                <th style="width:50%">Lý do</th>
                                                <th style="width:28%">Thời gian</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="rf" items="${refunds}">
                                                <tr>
                                                    <td style="font-weight:700; color:#dc2626;"><fmt:formatNumber value="${rf.amount}" type="number" maxFractionDigits="0" /> đ</td>
                                                    <td><c:out value="${rf.reason}" /></td>
                                                    <td><fmt:formatDate value="${rf.confirmedAt}" pattern="dd/MM/yyyy HH:mm" /></td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- CỘT PHẢI: thao tác -->
                    <div class="invoice-actions-col">

                        <!-- Thêm phụ phí (mọi hóa đơn trừ đã thanh toán) -->
                        <div class="action-card">
                            <div class="card-section-title"><i class="fa-solid fa-plus"></i> Thêm phụ phí</div>
                            <c:choose>
                                <c:when test="${invoice.status ne 'Paid'}">
                                    <form action="${pageContext.request.contextPath}/manager/invoices" method="post">
                                        <input type="hidden" name="action" value="surcharge" />
                                        <input type="hidden" name="invoiceId" value="${invoice.invoiceId}" />
                                        <div class="modal-form-group">
                                            <label>Nội dung phụ phí</label>
                                            <input type="text" name="description" class="modal-input" placeholder="VD: Hư hỏng nội thất, trả phòng muộn..." required />
                                        </div>
                                        <div class="modal-form-group" style="display:grid; grid-template-columns:1fr 1.4fr; gap:12px;">
                                            <div>
                                                <label>Số lượng</label>
                                                <input type="number" name="quantity" class="modal-input" value="1" min="1" required />
                                            </div>
                                            <div>
                                                <label>Đơn giá (đ)</label>
                                                <input type="number" name="unitPrice" class="modal-input" placeholder="VD: 200000" min="2" step="1" title="Đơn giá phụ phí phải lớn hơn 1" required />
                                            </div>
                                        </div>
                                        <button type="submit" class="btn-add-service" style="width:100%; justify-content:center;">
                                            <i class="fa-solid fa-plus"></i> Thêm vào hóa đơn
                                        </button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <p style="padding:4px 24px 20px; color:var(--text-muted); font-style:italic;">
                                        Hóa đơn đã thanh toán — không thể thêm phụ phí.
                                    </p>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Thêm khoản cần hoàn tiền (vào danh sách chờ hoàn) -->
                        <div class="action-card">
                            <div class="card-section-title"><i class="fa-solid fa-rotate-left"></i> Thêm khoản cần hoàn tiền</div>
                            <c:choose>
                                <c:when test="${invoice.status eq 'Paid'}">
                                    <p style="padding:4px 24px 20px; color:var(--text-muted); font-style:italic;">Hóa đơn đã thanh toán — không thể hoàn tiền.</p>
                                </c:when>
                                <c:when test="${invoice.refundableAmount le 0}">
                                    <p style="padding:4px 24px 20px; color:var(--text-muted); font-style:italic;">Đã tạo đủ các khoản hoàn cho hóa đơn này.</p>
                                </c:when>
                                <c:otherwise>
                                    <form action="${pageContext.request.contextPath}/manager/invoices" method="post">
                                        <input type="hidden" name="action" value="refund" />
                                        <input type="hidden" name="invoiceId" value="${invoice.invoiceId}" />
                                        <p style="font-size:13px; color:var(--text-muted); margin-top:0;">
                                            Tối đa có thể thêm: <strong><fmt:formatNumber value="${invoice.refundableAmount}" type="number" maxFractionDigits="0" /> đ</strong>
                                        </p>
                                        <div class="modal-form-group">
                                            <label>Số tiền cần hoàn (đ)</label>
                                            <input type="number" name="amount" class="modal-input" placeholder="VD: 500000"
                                                   min="2" step="1" max="${invoice.refundableAmount}" title="Số tiền hoàn phải lớn hơn 1" required />
                                        </div>
                                        <div class="modal-form-group">
                                            <label>Lý do hoàn tiền</label>
                                            <textarea name="reason" class="modal-textarea" placeholder="Nhập lý do hoàn tiền..." required></textarea>
                                        </div>
                                        <button type="submit" class="btn-refund" style="width:100%; justify-content:center;">
                                            <i class="fa-solid fa-plus"></i> Thêm khoản cần hoàn tiền
                                        </button>
                                    </form>
                                </c:otherwise>
                            </c:choose>
                        </div>

                    </div>
                </div>

            </main>

            <footer class="dashboard-footer">
                <span>© 2026 HotelOps Luxury Management. Hệ thống quản trị nội bộ.</span>
                <div class="footer-links-row">
                    <a href="#">Hỗ trợ</a><a href="#">Bảo mật</a><a href="#">Điều khoản</a>
                </div>
            </footer>
        </div>
    </div>

    <!-- Form ẩn để xác nhận đã hoàn các khoản chờ hoàn -->
    <form id="confirmRefundForm" action="${pageContext.request.contextPath}/manager/invoices" method="post" style="display:none;">
        <input type="hidden" name="action" value="confirmRefunds" />
        <input type="hidden" name="invoiceId" value="${invoice.invoiceId}" />
        <input type="hidden" name="refundIds" id="refundIdsInput" value="" />
    </form>

    <script>
        // Chọn / bỏ chọn tất cả khoản chờ hoàn
        function toggleAllRefunds(master) {
            document.querySelectorAll(".refund-check").forEach(cb => { cb.checked = master.checked; });
        }

        // Xác nhận đã hoàn 1 khoản
        function confirmOneRefund(id) {
            if (!confirm("Xác nhận đã hoàn khoản này? Khoản sẽ chuyển xuống lịch sử hoàn tiền.")) return;
            document.getElementById("refundIdsInput").value = id;
            document.getElementById("confirmRefundForm").submit();
        }

        // Xác nhận đã hoàn các khoản đang được chọn
        function confirmSelectedRefunds() {
            const ids = Array.from(document.querySelectorAll(".refund-check"))
                             .filter(cb => cb.checked)
                             .map(cb => cb.value);
            if (ids.length === 0) {
                alert("Vui lòng chọn ít nhất một khoản chờ hoàn.");
                return;
            }
            if (!confirm("Xác nhận đã hoàn " + ids.length + " khoản đã chọn?")) return;
            document.getElementById("refundIdsInput").value = ids.join(",");
            document.getElementById("confirmRefundForm").submit();
        }
    </script>

</body>
</html>
