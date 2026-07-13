<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer_booking.css?v=21" />
<fmt:setLocale value="vi_VN" />

<style>
    .filter-btn {
        padding: 8px 18px;
        border-radius: 20px;
        font-size: 13.5px;
        font-weight: 600;
        color: #64748b;
        background-color: #ffffff;
        border: 1px solid #e2e8f0;
        text-decoration: none;
        transition: all 0.2s;
        cursor: pointer;
        display: inline-block;
    }
    .filter-btn:hover {
        background-color: #f8fafc;
        color: var(--brand-blue);
        border-color: #cbd5e1;
    }
    .filter-btn.active {
        background-color: var(--brand-blue-light);
        color: var(--brand-blue);
        border-color: var(--brand-blue);
    }
    
    /* Modal Styles */
    .modal {
        display: none;
        position: fixed;
        z-index: 1000;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        overflow: auto;
        background-color: rgba(0,0,0,0.4);
        align-items: center;
        justify-content: center;
        backdrop-filter: blur(4px);
        transition: all 0.3s ease;
    }
    .modal.open {
        display: flex;
    }
    .modal-content {
        background-color: #fff;
        border-radius: 16px;
        width: 90%;
        max-width: 500px;
        box-shadow: 0 10px 25px rgba(0,0,0,0.1);
        animation: slideDown 0.3s ease;
        overflow: hidden;
    }
    @keyframes slideDown {
        from { transform: translateY(-30px); opacity: 0; }
        to { transform: translateY(0); opacity: 1; }
    }
    .modal-header {
        padding: 20px 24px;
        background: #f8fafc;
        border-bottom: 1px solid #e2e8f0;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .modal-header h3 {
        margin: 0;
        font-size: 18px;
        font-weight: 700;
        color: #1e293b;
    }
    .close-btn {
        background: none;
        border: none;
        font-size: 20px;
        color: #94a3b8;
        cursor: pointer;
        transition: color 0.2s;
    }
    .close-btn:hover {
        color: #475569;
    }
    .modal-body {
        padding: 24px;
    }
    .modal-footer {
        padding: 16px 24px;
        background: #f8fafc;
        border-top: 1px solid #e2e8f0;
        display: flex;
        justify-content: flex-end;
        gap: 12px;
    }
    .star-display i {
        color: #fbbf24;
        margin-right: 2px;
    }
    .btn-review {
        width: auto;
        padding: 8px 16px;
        margin-top: 0;
        text-decoration: none;
        display: inline-block;
        background-color: var(--brand-blue);
        color: white;
        border: none;
        border-radius: 8px;
        font-weight: 600;
        cursor: pointer;
        font-size: 14px;
        transition: background 0.2s;
    }
    .btn-review:hover {
        background-color: #1d4ed8;
    }
</style>

<body>

    <%-- Header Navigation --%>
    <nav class="navbar-rooms">
        <div class="logo">HotelOps</div>
        <ul class="nav-links">
            <li><a href="${pageContext.request.contextPath}/">Trang chủ</a></li>
            <li><a href="${pageContext.request.contextPath}/rooms">Phòng</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/bookings">Đặt phòng của tôi</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/payments">Thanh toán</a></li>
        </ul>

        <div class="nav-actions">
            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <div class="user-dropdown">
                        <button class="dropdown-trigger" type="button">
                            <i class="fa-solid fa-user-circle"></i>
                            <span>${sessionScope.user}</span>
                            <i class="fa-solid fa-chevron-down" style="font-size: 10px; margin-left: 2px;"></i>
                        </button>
                        <div class="dropdown-menu">
                            <a href="${pageContext.request.contextPath}/customer/profile" class="dropdown-item">
                                <i class="fa-solid fa-id-card"></i> Hồ sơ
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/bookings" class="dropdown-item">
                                <i class="fa-solid fa-calendar-check"></i> Đặt phòng của tôi
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/feedbacks" class="dropdown-item">
                                <i class="fa-solid fa-star"></i> Đánh giá lưu trú
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/services" class="dropdown-item">
                                <i class="fa-solid fa-bell-concierge"></i> Yêu cầu dịch vụ
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/maintenance" class="dropdown-item">
                                <i class="fa-solid fa-screwdriver-wrench"></i> Yêu cầu sửa chữa
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/payments" class="dropdown-item">
                                <i class="fa-solid fa-credit-card"></i> Thanh toán & Lịch sử
                            </a>
                            <div class="dropdown-divider"></div>
                            <a href="${pageContext.request.contextPath}/logout" class="dropdown-item logout-item">
                                <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/home/login" class="btn-login">Đăng nhập</a>
                </c:otherwise>
            </c:choose>
        </div>
    </nav>

    <div class="booking-container">
        <div class="booking-header">
            <h1>Đánh Giá Lưu Trú</h1>
            <p>Chia sẻ trải nghiệm của bạn sau những kỳ lưu trú đã hoàn thành.</p>
        </div>

        <%-- Alerts --%>
        <c:if test="${not empty successMessage}">
            <div class="success-banner" id="serverSuccessMessage">
                <i class="fa-solid fa-circle-check" style="font-size: 20px;"></i>
                <div>
                    <strong>Thành công:</strong> ${successMessage}
                </div>
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="error-banner" id="serverValidationError">
                <i class="fa-solid fa-circle-exclamation" style="font-size: 20px;"></i>
                <div>
                    <strong>Lỗi:</strong> ${errorMessage}
                </div>
            </div>
        </c:if>

        <%-- Filter & Search Form --%>
        <div class="booking-card" style="padding: 20px; margin-bottom: 25px;">
            <form action="${pageContext.request.contextPath}/customer/feedbacks" method="GET" id="filterForm">
                <div class="filter-bar">
                    <div class="search-input-group">
                        <input type="text" name="keyword" placeholder="Tìm theo Mã đơn, Số phòng, Loại phòng..." value="${fn:escapeXml(keyword)}" />
                        <input type="hidden" name="filter" value="${fn:escapeXml(filter)}" />
                        <button type="submit">
                            <i class="fa-solid fa-magnifying-glass"></i> Tìm kiếm
                        </button>
                    </div>

                    <div style="display: flex; gap: 10px; flex-wrap: wrap; margin-top: 15px; align-items: center;">
                        <span style="font-weight: 600; color: #475569; font-size: 14px;">Trạng thái:</span>
                        <a href="?filter=All&keyword=${fn:escapeXml(keyword)}" class="filter-btn ${filter eq 'All' || empty filter ? 'active' : ''}">Tất cả</a>
                        <a href="?filter=NotReviewed&keyword=${fn:escapeXml(keyword)}" class="filter-btn ${filter eq 'NotReviewed' ? 'active' : ''}">Chưa đánh giá</a>
                        <a href="?filter=Reviewed&keyword=${fn:escapeXml(keyword)}" class="filter-btn ${filter eq 'Reviewed' ? 'active' : ''}">Đã đánh giá</a>
                    </div>
                </div>
            </form>
        </div>

        <%-- Feedback List Card --%>
        <div class="booking-card" style="padding: 0; overflow-x: auto;">
            <table class="booking-list-table">
                <thead>
                    <tr>
                        <th>Mã đơn</th>
                        <th>Số phòng</th>
                        <th>Loại phòng</th>
                        <th>Thời gian nghỉ</th>
                        <th>Thời điểm trả phòng</th>
                        <th>Trạng thái</th>
                        <th>Hành động / Đánh giá</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty feedbacks}">
                            <c:forEach var="fb" items="${feedbacks}">
                                <tr>
                                    <td style="font-weight: 700;">#${fb.bookingId}</td>
                                    <td style="font-weight: 600;">Phòng ${fb.roomNumber}</td>
                                    <td>${fb.roomTypeName}</td>
                                    <td>
                                        <div style="color: var(--primary-indigo); font-weight: 500;">
                                            <fmt:formatDate value="${fb.checkInDate}" pattern="dd/MM/yyyy" />
                                            &rarr;
                                            <fmt:formatDate value="${fb.checkOutDate}" pattern="dd/MM/yyyy" />
                                        </div>
                                    </td>
                                    <td>
                                        <fmt:formatDate value="${fb.checkedOutAt}" pattern="dd/MM/yyyy HH:mm" />
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${fb.reviewed}">
                                                <span class="badge badge-confirmed">Đã đánh giá</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-pending">Chưa đánh giá</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${fb.reviewed}">
                                                <div class="star-display" style="margin-bottom: 4px;">
                                                    <c:forEach begin="1" end="${fb.rating}">
                                                        <i class="fa-solid fa-star"></i>
                                                    </c:forEach>
                                                    <c:forEach begin="${fb.rating + 1}" end="5">
                                                        <i class="fa-regular fa-star"></i>
                                                    </c:forEach>
                                                </div>
                                                <c:if test="${not empty fb.comment}">
                                                    <div style="font-size: 13px; color: #475569; max-width: 250px; white-space: normal; word-break: break-word;">
                                                        " <c:out value="${fb.comment}" /> "
                                                    </div>
                                                </c:if>
                                                <div style="font-size: 11px; color: #94a3b8; margin-top: 4px;">
                                                    Gửi lúc: <fmt:formatDate value="${fb.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <button type="button" class="btn-review" 
                                                        onclick="openFeedbackModal('${fb.bookingId}', '${fb.roomId}', '${fb.roomNumber}', '${fb.roomTypeName}')">
                                                    <i class="fa-solid fa-star"></i> Đánh giá
                                                </button>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="7" style="text-align: center; padding: 40px; color: #64748b;">
                                    <i class="fa-solid fa-circle-info" style="font-size: 28px; color: #94a3b8; margin-bottom: 10px;"></i><br/>
                                    Bạn chưa có kỳ lưu trú nào đã hoàn thành để đánh giá.
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>

    <%-- Feedback Modal --%>
    <div id="feedbackModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Đánh Giá Lưu Trú</h3>
                <button type="button" class="close-btn" onclick="closeFeedbackModal()">&times;</button>
            </div>
            <form action="${pageContext.request.contextPath}/customer/feedbacks" method="POST" onsubmit="return validateForm()">
                <div class="modal-body">
                    <input type="hidden" name="bookingId" id="modalBookingId" />
                    <input type="hidden" name="roomId" id="modalRoomId" />
                    
                    <div style="margin-bottom: 15px; font-size: 14.5px; color: #475569;">
                        <div>Đơn đặt phòng: <strong id="modalBookingText"></strong></div>
                        <div>Phòng: <strong id="modalRoomText"></strong></div>
                    </div>

                    <div style="margin-bottom: 10px;">
                        <label style="font-weight: 600; display: block; margin-bottom: 5px; color: #334155;">Đánh giá của bạn:</label>
                        <div class="rating-stars" style="display: flex; gap: 8px; font-size: 30px; margin: 10px 0;">
                            <i class="fa-regular fa-star star-btn" data-value="1" style="cursor: pointer; color: #fbbf24;"></i>
                            <i class="fa-regular fa-star star-btn" data-value="2" style="cursor: pointer; color: #fbbf24;"></i>
                            <i class="fa-regular fa-star star-btn" data-value="3" style="cursor: pointer; color: #fbbf24;"></i>
                            <i class="fa-regular fa-star star-btn" data-value="4" style="cursor: pointer; color: #fbbf24;"></i>
                            <i class="fa-regular fa-star star-btn" data-value="5" style="cursor: pointer; color: #fbbf24;"></i>
                        </div>
                        <input type="hidden" name="rating" id="ratingInput" required />
                        <div id="ratingText" style="font-weight: 600; color: #64748b; font-size: 14px;">Chọn số sao để đánh giá</div>
                    </div>

                    <div style="margin-top: 15px;">
                        <label style="font-weight: 600; display: block; margin-bottom: 8px; color: #334155;">Nhận xét của bạn (không bắt buộc):</label>
                        <textarea name="comment" id="commentText" class="form-control" rows="4" 
                                  maxlength="1000" placeholder="Chia sẻ thêm chi tiết về kỳ nghỉ của bạn tại phòng này..." 
                                  style="width: 100%; border: 1px solid #cbd5e1; border-radius: 8px; padding: 10px; resize: none; box-sizing: border-box;"
                                  oninput="updateCharCount()"></textarea>
                        <div style="text-align: right; font-size: 12px; color: #94a3b8; margin-top: 4px;">
                            <span id="charCount">0</span> / 1000 ký tự
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-secondary" style="margin-top: 0; padding: 10px 20px;" onclick="closeFeedbackModal()">Hủy</button>
                    <button type="submit" class="btn-primary" style="margin-top: 0; width: auto; padding: 10px 20px;">Gửi đánh giá</button>
                </div>
            </form>
        </div>
    </div>

    <%-- Footer --%>
    <footer class="footer-white" id="lien-he" style="margin-top: 80px;">
        <div class="footer-white-grid">
            <div class="footer-white-about">
                <h3>HotelOps Pro</h3>
                <p>Hệ thống quản lý và nghỉ dưỡng đẳng cấp quốc tế, đem lại trải nghiệm sang trọng vượt thời gian.</p>
            </div>
            <div class="footer-white-links">
                <h4>Liên kết nhanh</h4>
                <ul>
                    <li><a href="#">Trang chủ</a></li>
                    <li><a href="#">Phòng & Giá</a></li>
                    <li><a href="#">Dịch vụ</a></li>
                </ul>
            </div>
            <div class="footer-white-links">
                <h4>Chính sách</h4>
                <ul>
                    <li><a href="#">Chính sách bảo mật</a></li>
                    <li><a href="#">Điều khoản sử dụng</a></li>
                    <li><a href="#">Chính sách hoàn tiền</a></li>
                </ul>
            </div>
            <div class="footer-white-contact">
                <h4>Thông tin liên hệ</h4>
                <p><i class="fa-solid fa-location-dot"></i> 123 Đường Lê Lợi, Quận 1, TP. Hồ Chí Minh</p>
                <p><i class="fa-solid fa-envelope"></i> contact@hotelopspro.com</p>
                <span class="phone-number-white"><i class="fa-solid fa-phone"></i> 1900 6789</span>
            </div>
        </div>
        <div class="footer-white-bottom text-center">
            <p>&copy; 2026 HotelOps Pro. All rights reserved.</p>
        </div>
    </footer>

    <script>
        window.addEventListener('DOMContentLoaded', () => {
            const serverError = document.getElementById('serverValidationError');
            if (serverError) {
                setTimeout(() => { serverError.style.display = 'none'; }, 5000);
            }
            const serverSuccess = document.getElementById('serverSuccessMessage');
            if (serverSuccess) {
                setTimeout(() => { serverSuccess.style.display = 'none'; }, 5000);
            }
        });

        function openFeedbackModal(bookingId, roomId, roomNumber, roomTypeName) {
            document.getElementById('modalBookingId').value = bookingId;
            document.getElementById('modalRoomId').value = roomId;
            document.getElementById('modalBookingText').textContent = '#' + bookingId;
            document.getElementById('modalRoomText').textContent = 'Phòng ' + roomNumber + ' (' + roomTypeName + ')';
            
            // Reset modal values
            document.getElementById('ratingInput').value = '';
            document.getElementById('commentText').value = '';
            document.getElementById('charCount').textContent = '0';
            document.getElementById('ratingText').textContent = 'Chọn số sao để đánh giá';
            document.getElementById('ratingText').style.color = '#64748b';
            
            const stars = document.querySelectorAll('.star-btn');
            stars.forEach(s => {
                s.classList.remove('fa-solid');
                s.classList.add('fa-regular');
            });

            document.getElementById('feedbackModal').classList.add('open');
        }

        function closeFeedbackModal() {
            document.getElementById('feedbackModal').classList.remove('open');
        }

        // Star click selection handler
        const stars = document.querySelectorAll('.star-btn');
        const ratingInput = document.getElementById('ratingInput');
        const ratingText = document.getElementById('ratingText');

        const ratingMeanings = {
            1: '1 sao - Rất không hài lòng',
            2: '2 sao - Không hài lòng',
            3: '3 sao - Bình thường',
            4: '4 sao - Hài lòng',
            5: '5 sao - Rất hài lòng'
        };

        stars.forEach(star => {
            star.addEventListener('click', () => {
                const val = parseInt(star.getAttribute('data-value'));
                ratingInput.value = val;
                ratingText.textContent = ratingMeanings[val];
                ratingText.style.color = '#1e293b';
                
                stars.forEach(s => {
                    const sVal = parseInt(s.getAttribute('data-value'));
                    if (sVal <= val) {
                        s.classList.remove('fa-regular');
                        s.classList.add('fa-solid');
                    } else {
                        s.classList.remove('fa-solid');
                        s.classList.add('fa-regular');
                    }
                });
            });
        });

        function updateCharCount() {
            const comment = document.getElementById('commentText').value;
            document.getElementById('charCount').textContent = comment.length;
        }

        function validateForm() {
            const rating = document.getElementById('ratingInput').value;
            if (!rating || rating < 1 || rating > 5) {
                alert('Vui lòng chọn số sao để đánh giá.');
                return false;
            }
            const comment = document.getElementById('commentText').value;
            if (comment.length > 1000) {
                alert('Nội dung đánh giá không được vượt quá 1000 ký tự.');
                return false;
            }
            return true;
        }
    </script>
</body>
</html>
