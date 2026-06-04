<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=3" />
<fmt:setLocale value="vi_VN" />

<body class="dashboard-body">

    <div class="dashboard-layout">

        <!-- SIDEBAR -->
        <aside class="dashboard-sidebar">
            <div class="sidebar-brand">
                <i class="fa-solid fa-hotel"></i> <span>HotelOps</span>
            </div>
            <ul class="sidebar-menu">
                <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/dashboard?tab=overview"><i class="fa-solid fa-table-cells-large"></i> <span>Tổng quan</span></a></li>
                <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/dashboard?tab=roomtypes"><i class="fa-solid fa-door-open"></i> <span>Loại phòng</span></a></li>
                <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/dashboard?tab=rooms"><i class="fa-solid fa-bed"></i> <span>Phòng</span></a></li>
                <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/dashboard?tab=services"><i class="fa-solid fa-bell-concierge"></i> <span>Dịch vụ</span></a></li>
                <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/requests"><i class="fa-solid fa-headset"></i> <span>Yêu cầu &amp; Nhân viên</span></a></li>
                <li class="menu-item active"><a href="${pageContext.request.contextPath}/manager/invoices"><i class="fa-solid fa-file-invoice-dollar"></i> <span>Hóa đơn</span></a></li>
                <li class="menu-item"><a href="${pageContext.request.contextPath}/manager/dashboard?tab=customers"><i class="fa-solid fa-user-group"></i> <span>Khách hàng</span></a></li>
            </ul>
            <div class="sidebar-footer">
                <div class="user-profile-card">
                    <div class="profile-avatar">AM</div>
                    <div class="profile-info">
                        <span class="profile-name">${not empty sessionScope.user ? sessionScope.user : 'Hotel Manager'}</span>
                        <span class="profile-role">Hotel Manager</span>
                    </div>
                </div>
            </div>
        </aside>

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
                                    <span>Đã hoàn</span>
                                    <span style="color:#dc2626;">- <fmt:formatNumber value="${invoice.refundedAmount}" type="number" maxFractionDigits="0" /> đ</span>
                                </div>
                                <div class="total-row total-net">
                                    <span>Thực thu</span>
                                    <span><fmt:formatNumber value="${invoice.netAmount}" type="number" maxFractionDigits="0" /> đ</span>
                                </div>
                            </div>
                        </div>

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
                                                    <td><fmt:formatDate value="${rf.createdAt}" pattern="dd/MM/yyyy HH:mm" /></td>
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

                        <!-- Thêm phụ phí -->
                        <div class="action-card">
                            <div class="card-section-title"><i class="fa-solid fa-plus"></i> Thêm phụ phí</div>
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
                                        <input type="number" name="unitPrice" class="modal-input" placeholder="VD: 200000" min="0" step="1000" required />
                                    </div>
                                </div>
                                <button type="submit" class="btn-add-service" style="width:100%; justify-content:center;">
                                    <i class="fa-solid fa-plus"></i> Thêm vào hóa đơn
                                </button>
                            </form>
                        </div>

                        <!-- Hoàn tiền -->
                        <div class="action-card">
                            <div class="card-section-title"><i class="fa-solid fa-rotate-left"></i> Hoàn tiền</div>
                            <c:choose>
                                <c:when test="${invoice.status eq 'Cancelled'}">
                                    <p style="color:var(--text-muted); font-style:italic;">Hóa đơn đã huỷ, không thể hoàn tiền.</p>
                                </c:when>
                                <c:when test="${invoice.netAmount le 0}">
                                    <p style="color:var(--text-muted); font-style:italic;">Hóa đơn đã được hoàn toàn bộ.</p>
                                </c:when>
                                <c:otherwise>
                                    <p style="font-size:13px; color:var(--text-muted); margin-top:0;">
                                        Tối đa có thể hoàn: <strong><fmt:formatNumber value="${invoice.netAmount}" type="number" maxFractionDigits="0" /> đ</strong>
                                    </p>
                                    <form action="${pageContext.request.contextPath}/manager/invoices" method="post"
                                          onsubmit="return confirm('Xác nhận hoàn tiền cho hóa đơn này?');">
                                        <input type="hidden" name="action" value="refund" />
                                        <input type="hidden" name="invoiceId" value="${invoice.invoiceId}" />
                                        <div class="modal-form-group">
                                            <label>Số tiền hoàn (đ)</label>
                                            <input type="number" name="amount" class="modal-input" placeholder="VD: 500000"
                                                   min="1" max="${invoice.netAmount}" step="1000" required />
                                        </div>
                                        <div class="modal-form-group">
                                            <label>Lý do hoàn tiền</label>
                                            <textarea name="reason" class="modal-textarea" placeholder="Nhập lý do hoàn tiền..." required></textarea>
                                        </div>
                                        <button type="submit" class="btn-refund" style="width:100%; justify-content:center;">
                                            <i class="fa-solid fa-rotate-left"></i> Thực hiện hoàn tiền
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

</body>
</html>
