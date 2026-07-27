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
<a href="${pageContext.request.contextPath}/" class="logo">${not empty hotelName ? hotelName : 'HotelOps'}</a>
        <ul class="nav-links">
            <li><a href="${pageContext.request.contextPath}/">Trang chá»§</a></li>
            <li><a href="${pageContext.request.contextPath}/rooms">PhÃ²ng</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/bookings">Äáº·t phÃ²ng cá»§a tÃ´i</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/feedbacks" class="active">ÄÃ¡nh giÃ¡ lÆ°u trÃº</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/services">Dá»‹ch vá»¥</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/maintenance">Sá»± cá»‘</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/payments">Thanh toÃ¡n</a></li>
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
                                        <i class="fa-solid fa-id-card"></i> Há»“ sÆ¡
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/bookings" class="dropdown-item">
                                        <i class="fa-solid fa-calendar-check"></i> Äáº·t phÃ²ng cá»§a tÃ´i
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/booking/change" class="dropdown-item">
                                        <i class="fa-solid fa-pen-to-square"></i> Thay Ä‘á»•i Ä‘áº·t phÃ²ng
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/feedbacks" class="dropdown-item">
                                        <i class="fa-solid fa-star"></i> ÄÃ¡nh giÃ¡ lÆ°u trÃº
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/services" class="dropdown-item">
                                        <i class="fa-solid fa-bell-concierge"></i> YÃªu cáº§u dá»‹ch vá»¥
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/maintenance" class="dropdown-item">
                                        <i class="fa-solid fa-screwdriver-wrench"></i> YÃªu cáº§u sá»­a chá»¯a
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/payments" class="dropdown-item">
                                        <i class="fa-solid fa-credit-card"></i> Thanh toÃ¡n & Lá»‹ch sá»­
                                    </a>
                            <a href="${pageContext.request.contextPath}/logout" class="dropdown-item logout-item">
                                <i class="fa-solid fa-right-from-bracket"></i> ÄÄƒng xuáº¥t
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/home/login" class="btn-login">ÄÄƒng nháº­p</a>
                </c:otherwise>
            </c:choose>
        </div>
    </nav>

    <div class="booking-container">
        <div class="booking-header">
            <h1>ÄÃ¡nh GiÃ¡ LÆ°u TrÃº</h1>
            <p>Chia sáº» tráº£i nghiá»‡m cá»§a báº¡n sau nhá»¯ng ká»³ lÆ°u trÃº Ä‘Ã£ hoÃ n thÃ nh.</p>
        </div>

        <%-- Alerts --%>
        <c:if test="${not empty successMessage}">
            <div class="success-banner" id="serverSuccessMessage">
                <i class="fa-solid fa-circle-check" style="font-size: 20px;"></i>
                <div>
                    <strong>ThÃ nh cÃ´ng:</strong> ${successMessage}
                </div>
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="error-banner" id="serverValidationError">
                <i class="fa-solid fa-circle-exclamation" style="font-size: 20px;"></i>
                <div>
                    <strong>Lá»—i:</strong> ${errorMessage}
                </div>
            </div>
        </c:if>

        <%-- Filter & Search Form --%>
        <div class="booking-card" style="padding: 20px; margin-bottom: 25px;">
            <form action="${pageContext.request.contextPath}/customer/feedbacks" method="GET" id="filterForm">
                <div class="filter-bar">
                    <div class="search-input-group">
                        <input type="text" name="keyword" placeholder="TÃ¬m theo MÃ£ Ä‘Æ¡n, Sá»‘ phÃ²ng, Loáº¡i phÃ²ng..." value="${fn:escapeXml(keyword)}" />
                        <input type="hidden" name="filter" value="${fn:escapeXml(filter)}" />
                        <button type="submit">
                            <i class="fa-solid fa-magnifying-glass"></i> TÃ¬m kiáº¿m
                        </button>
                    </div>

                    <div style="display: flex; gap: 10px; flex-wrap: wrap; margin-top: 15px; align-items: center;">
                        <span style="font-weight: 600; color: #475569; font-size: 14px;">Tráº¡ng thÃ¡i:</span>
                        <a href="?filter=All&keyword=${fn:escapeXml(keyword)}" class="filter-btn ${filter eq 'All' || empty filter ? 'active' : ''}">Táº¥t cáº£</a>
                        <a href="?filter=NotReviewed&keyword=${fn:escapeXml(keyword)}" class="filter-btn ${filter eq 'NotReviewed' ? 'active' : ''}">ChÆ°a Ä‘Ã¡nh giÃ¡</a>
                        <a href="?filter=Reviewed&keyword=${fn:escapeXml(keyword)}" class="filter-btn ${filter eq 'Reviewed' ? 'active' : ''}">ÄÃ£ Ä‘Ã¡nh giÃ¡</a>
                    </div>
                </div>
            </form>
        </div>

        <%-- Feedback List Card --%>
        <div class="booking-card" style="padding: 0; overflow-x: auto;">
            <table class="booking-list-table">
                <thead>
                    <tr>
                        <th>MÃ£ Ä‘Æ¡n</th>
                        <th>Sá»‘ phÃ²ng</th>
                        <th>Loáº¡i phÃ²ng</th>
                        <th>Thá»i gian nghá»‰</th>
                        <th>Thá»i Ä‘iá»ƒm tráº£ phÃ²ng</th>
                        <th>Tráº¡ng thÃ¡i</th>
                        <th>HÃ nh Ä‘á»™ng / ÄÃ¡nh giÃ¡</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty feedbacks}">
                            <c:forEach var="fb" items="${feedbacks}">
                                <tr>
                                    <td style="font-weight: 700;">#${fb.bookingId}</td>
                                    <td style="font-weight: 600;">PhÃ²ng ${fb.roomNumber}</td>
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
                                                <span class="badge badge-confirmed">ÄÃ£ Ä‘Ã¡nh giÃ¡</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-pending">ChÆ°a Ä‘Ã¡nh giÃ¡</span>
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
                                                    Gá»­i lÃºc: <fmt:formatDate value="${fb.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <button type="button" class="btn-review" 
                                                        onclick="openFeedbackModal('${fb.bookingId}', '${fb.roomId}', '${fb.roomNumber}', '${fb.roomTypeName}')">
                                                    <i class="fa-solid fa-star"></i> ÄÃ¡nh giÃ¡
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
                                    Báº¡n chÆ°a cÃ³ ká»³ lÆ°u trÃº nÃ o Ä‘Ã£ hoÃ n thÃ nh Ä‘á»ƒ Ä‘Ã¡nh giÃ¡.
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
                <h3>ÄÃ¡nh GiÃ¡ LÆ°u TrÃº</h3>
                <button type="button" class="close-btn" onclick="closeFeedbackModal()">&times;</button>
            </div>
            <form action="${pageContext.request.contextPath}/customer/feedbacks" method="POST" onsubmit="return validateForm()">
                <div class="modal-body">
                    <input type="hidden" name="bookingId" id="modalBookingId" />
                    <input type="hidden" name="roomId" id="modalRoomId" />
                    
                    <div style="margin-bottom: 15px; font-size: 14.5px; color: #475569;">
                        <div>ÄÆ¡n Ä‘áº·t phÃ²ng: <strong id="modalBookingText"></strong></div>
                        <div>PhÃ²ng: <strong id="modalRoomText"></strong></div>
                    </div>

                    <div style="margin-bottom: 10px;">
                        <label style="font-weight: 600; display: block; margin-bottom: 5px; color: #334155;">ÄÃ¡nh giÃ¡ cá»§a báº¡n:</label>
                        <div class="rating-stars" style="display: flex; gap: 8px; font-size: 30px; margin: 10px 0;">
                            <i class="fa-regular fa-star star-btn" data-value="1" style="cursor: pointer; color: #fbbf24;"></i>
                            <i class="fa-regular fa-star star-btn" data-value="2" style="cursor: pointer; color: #fbbf24;"></i>
                            <i class="fa-regular fa-star star-btn" data-value="3" style="cursor: pointer; color: #fbbf24;"></i>
                            <i class="fa-regular fa-star star-btn" data-value="4" style="cursor: pointer; color: #fbbf24;"></i>
                            <i class="fa-regular fa-star star-btn" data-value="5" style="cursor: pointer; color: #fbbf24;"></i>
                        </div>
                        <input type="hidden" name="rating" id="ratingInput" />
                        <div id="ratingText" style="font-weight: 600; color: #64748b; font-size: 14px;">Chá»n sá»‘ sao Ä‘á»ƒ Ä‘Ã¡nh giÃ¡</div>
                        <div id="ratingError" style="color: #ef4444; font-size: 12.5px; font-weight: 500; display: none; margin-top: 4px;">
                            <i class="fa-solid fa-circle-exclamation"></i> Vui lÃ²ng chá»n sá»‘ sao Ä‘á»ƒ Ä‘Ã¡nh giÃ¡.
                        </div>
                    </div>

                    <div style="margin-top: 15px;">
                        <label style="font-weight: 600; display: block; margin-bottom: 8px; color: #334155;">Nháº­n xÃ©t cá»§a báº¡n (khÃ´ng báº¯t buá»™c):</label>
                        <textarea name="comment" id="commentText" class="form-control" rows="4" 
                                  placeholder="Chia sáº» thÃªm chi tiáº¿t vá» ká»³ nghá»‰ cá»§a báº¡n táº¡i phÃ²ng nÃ y..." 
                                  style="width: 100%; border: 1px solid #cbd5e1; border-radius: 8px; padding: 10px; resize: none; box-sizing: border-box;"
                                  oninput="updateCharCount()"></textarea>
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 4px;">
                            <div id="commentError" style="color: #ef4444; font-size: 12.5px; font-weight: 500; display: none;">
                                <i class="fa-solid fa-circle-exclamation"></i> Ná»™i dung Ä‘Ã¡nh giÃ¡ khÃ´ng Ä‘Æ°á»£c vÆ°á»£t quÃ¡ 1000 kÃ½ tá»±.
                            </div>
                            <div style="font-size: 12px; color: #94a3b8; margin-left: auto;">
                                <span id="charCount">0</span> / 1000 kÃ½ tá»±
                            </div>
                        </div>
                    </div>
                </div>

                    <%-- Warning notice --%>
                    <div style="margin: 12px 20px 0 20px; padding: 10px 14px; background: #fff7ed; border: 1px solid #fed7aa; border-radius: 8px; display: flex; align-items: flex-start; gap: 8px;">
                        <i class="fa-solid fa-triangle-exclamation" style="color: #f97316; font-size: 15px; margin-top: 2px; flex-shrink: 0;"></i>
                        <span style="font-size: 13px; color: #9a3412; line-height: 1.5;">
                            <strong>LÆ°u Ã½:</strong> Sau khi gá»­i Ä‘Ã¡nh giÃ¡, báº¡n <strong>sáº½ khÃ´ng thá»ƒ chá»‰nh sá»­a hoáº·c xÃ³a</strong> Ä‘Ã¡nh giÃ¡ nÃ y. Vui lÃ²ng kiá»ƒm tra ká»¹ trÆ°á»›c khi xÃ¡c nháº­n.
                        </span>
                    </div>

                <div class="modal-footer">
                    <button type="button" class="btn-secondary" style="margin-top: 0; padding: 10px 20px;" onclick="closeFeedbackModal()">Há»§y</button>
                    <button type="submit" class="btn-primary" style="margin-top: 0; width: auto; padding: 10px 20px;">Gá»­i Ä‘Ã¡nh giÃ¡</button>
                </div>
            </form>
        </div>
    </div>

    <%-- Footer --%>
    <footer class="footer-white" id="lien-he" style="margin-top: 80px;">
        <div class="footer-white-grid">
            <div class="footer-white-about">
                <h3>HotelOps Pro</h3>
                <p>Há»‡ thá»‘ng quáº£n lÃ½ vÃ  nghá»‰ dÆ°á»¡ng Ä‘áº³ng cáº¥p quá»‘c táº¿, Ä‘em láº¡i tráº£i nghiá»‡m sang trá»ng vÆ°á»£t thá»i gian.</p>
            </div>
            <div class="footer-white-links">
                <h4>LiÃªn káº¿t nhanh</h4>
                <ul>
                    <li><a href="#">Trang chá»§</a></li>
                    <li><a href="#">PhÃ²ng & GiÃ¡</a></li>
                    <li><a href="#">Dá»‹ch vá»¥</a></li>
                </ul>
            </div>
            <div class="footer-white-links">
                <h4>ChÃ­nh sÃ¡ch</h4>
                <ul>
                    <li><a href="#">ChÃ­nh sÃ¡ch báº£o máº­t</a></li>
                    <li><a href="#">Äiá»u khoáº£n sá»­ dá»¥ng</a></li>
                    <li><a href="#">ChÃ­nh sÃ¡ch hoÃ n tiá»n</a></li>
                </ul>
            </div>
            <div class="footer-white-contact">
                <h4>ThÃ´ng tin liÃªn há»‡</h4>
                <p><i class="fa-solid fa-location-dot"></i> 123 ÄÆ°á»ng LÃª Lá»£i, Quáº­n 1, TP. Há»“ ChÃ­ Minh</p>
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
            document.getElementById('modalRoomText').textContent = 'PhÃ²ng ' + roomNumber + ' (' + roomTypeName + ')';
            
            // Reset modal values
            document.getElementById('ratingInput').value = '';
            document.getElementById('commentText').value = '';
            document.getElementById('ratingText').textContent = 'Chá»n sá»‘ sao Ä‘á»ƒ Ä‘Ã¡nh giÃ¡';
            document.getElementById('ratingText').style.color = '#64748b';
            
            const commentTextEl = document.getElementById('commentText');
            commentTextEl.style.borderColor = '#cbd5e1';

            const charCountEl = document.getElementById('charCount');
            charCountEl.textContent = '0';
            charCountEl.style.color = '#94a3b8';
            charCountEl.style.fontWeight = 'normal';

            const commentErrorEl = document.getElementById('commentError');
            if (commentErrorEl) commentErrorEl.style.display = 'none';

            const ratingErrorEl = document.getElementById('ratingError');
            if (ratingErrorEl) ratingErrorEl.style.display = 'none';

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
            1: '1 sao - Ráº¥t khÃ´ng hÃ i lÃ²ng',
            2: '2 sao - KhÃ´ng hÃ i lÃ²ng',
            3: '3 sao - BÃ¬nh thÆ°á»ng',
            4: '4 sao - HÃ i lÃ²ng',
            5: '5 sao - Ráº¥t hÃ i lÃ²ng'
        };

        stars.forEach(star => {
            star.addEventListener('click', () => {
                const val = parseInt(star.getAttribute('data-value'));
                ratingInput.value = val;
                ratingText.textContent = ratingMeanings[val];
                ratingText.style.color = '#1e293b';
                
                const ratingErrorEl = document.getElementById('ratingError');
                if (ratingErrorEl) ratingErrorEl.style.display = 'none';

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
            const commentTextEl = document.getElementById('commentText');
            const comment = commentTextEl.value;
            const charCountEl = document.getElementById('charCount');
            const commentErrorEl = document.getElementById('commentError');

            charCountEl.textContent = comment.length;

            if (comment.length > 1000) {
                charCountEl.style.color = '#ef4444';
                charCountEl.style.fontWeight = 'bold';
                if (commentErrorEl) commentErrorEl.style.display = 'block';
                commentTextEl.style.borderColor = '#ef4444';
            } else {
                charCountEl.style.color = '#94a3b8';
                charCountEl.style.fontWeight = 'normal';
                if (commentErrorEl) commentErrorEl.style.display = 'none';
                commentTextEl.style.borderColor = '#cbd5e1';
            }
        }

        function validateForm() {
            let isValid = true;

            const rating = document.getElementById('ratingInput').value;
            const ratingErrorEl = document.getElementById('ratingError');
            if (!rating || rating < 1 || rating > 5) {
                if (ratingErrorEl) ratingErrorEl.style.display = 'block';
                isValid = false;
            } else {
                if (ratingErrorEl) ratingErrorEl.style.display = 'none';
            }

            const commentTextEl = document.getElementById('commentText');
            const comment = commentTextEl.value;
            const commentErrorEl = document.getElementById('commentError');
            const charCountEl = document.getElementById('charCount');

            if (comment.length > 1000) {
                if (commentErrorEl) commentErrorEl.style.display = 'block';
                commentTextEl.style.borderColor = '#ef4444';
                charCountEl.style.color = '#ef4444';
                charCountEl.style.fontWeight = 'bold';
                commentTextEl.focus();
                isValid = false;
            }

            return isValid;
        }
    </script>
</body>
</html>
