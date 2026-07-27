<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/rooms.css?v=21" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/room_detail.css?v=2" />
<fmt:setLocale value="vi_VN" />

<body>

    <!-- Header Navigation (White Background Premium Style) -->
    <nav class="navbar-rooms">
<a href="${pageContext.request.contextPath}/" class="logo">${not empty hotelName ? hotelName : 'HotelOps'}</a>
        <ul class="nav-links">
            <li><a href="${pageContext.request.contextPath}/">Trang chá»§</a></li>
            <li><a href="${pageContext.request.contextPath}/#gioi-thieu">Giá»›i thiá»‡u</a></li>
            <li><a href="${pageContext.request.contextPath}/rooms" class="active">PhÃ²ng</a></li>
            <li><a href="${pageContext.request.contextPath}/#dich-vu">Dá»‹ch vá»¥</a></li>
            <li><a href="${pageContext.request.contextPath}/#lien-he">LiÃªn há»‡</a></li>
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
                            <c:choose>
                                <c:when test="${sessionScope.role eq 'CUSTOMER'}">
                                    <a href="${pageContext.request.contextPath}/customer/profile" class="dropdown-item">
                                        <i class="fa-solid fa-id-card"></i> Há»“ sÆ¡
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/bookings" class="dropdown-item">
                                        <i class="fa-solid fa-calendar-check"></i> Äáº·t phÃ²ng cá»§a tÃ´i
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/booking/change" class="dropdown-item">
                                        <i class="fa-solid fa-pen-to-square"></i> Thay Ä‘á»•i Ä‘áº·t phÃ²ng
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
                                </c:when>
                                <c:otherwise>
                                    <c:choose>
                                        <c:when test="${sessionScope.role eq 'ADMIN'}">
                                            <a href="${pageContext.request.contextPath}/admin/dashboard" class="dropdown-item">
                                                <i class="fa-solid fa-chart-line"></i> Dashboard Admin
                                            </a>
                                        </c:when>
                                        <c:when test="${sessionScope.role eq 'HOTEL_MANAGER'}">
                                            <a href="${pageContext.request.contextPath}/manager/dashboard" class="dropdown-item">
                                                <i class="fa-solid fa-chart-line"></i> Dashboard Manager
                                            </a>
                                        </c:when>
                                        <c:when test="${sessionScope.role eq 'RECEPTIONIST'}">
                                            <a href="${pageContext.request.contextPath}/receptionist/dashboard" class="dropdown-item">
                                                <i class="fa-solid fa-chart-line"></i> Dashboard Lá»… tÃ¢n
                                            </a>
                                        </c:when>
                                        <c:when test="${sessionScope.role eq 'HOUSEKEEPING'}">
                                            <a href="${pageContext.request.contextPath}/housekeeping/dashboard" class="dropdown-item">
                                                <i class="fa-solid fa-broom"></i> Dashboard Dá»n phÃ²ng
                                            </a>
                                        </c:when>
                                    </c:choose>
                                </c:otherwise>
                            </c:choose>
                            <div class="dropdown-divider"></div>
                            <a href="${pageContext.request.contextPath}/logout" class="dropdown-item logout-item">
                                <i class="fa-solid fa-right-from-bracket"></i> ÄÄƒng xuáº¥t
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/home/login" class="btn-login">ÄÄƒng nháº­p</a>
                    <a href="#" class="btn-register">ÄÄƒng kÃ½</a>
                </c:otherwise>
            </c:choose>
        </div>
    </nav>

    <!-- Main Content Grid -->
    <main class="detail-page-wrapper">
        
        <!-- Breadcrumbs & Back Link -->
        <div class="breadcrumb-container">
            <div class="breadcrumbs">
                <a href="${pageContext.request.contextPath}/">Trang chá»§</a>
                <span>&gt;</span>
                <a href="${pageContext.request.contextPath}/rooms?checkIn=${selectedCheckIn}&checkOut=${selectedCheckOut}">PhÃ²ng</a>
                <span>&gt;</span>
                <span class="current">${room.typeName}</span>
            </div>
            <a href="${pageContext.request.contextPath}/rooms?checkIn=${selectedCheckIn}&checkOut=${selectedCheckOut}" class="back-link">
                <i class="fa-solid fa-arrow-left"></i> Quay láº¡i danh sÃ¡ch phÃ²ng
            </a>
        </div>

        <div class="detail-grid">
            
            <!-- LEFT COLUMN: Gallery, Description, Spec Cards -->
            <div class="left-column">
                
                <!-- Main Image Slider -->
                <div class="gallery-section">
                    <div class="main-image-container">
                        <img id="main-gallery-img" src="${room.imageUrl}" alt="${room.typeName}" />
                        
                        <!-- Navigation Arrows -->
                        <div class="gallery-nav">
                            <button class="nav-arrow" onclick="changeSlide(-1)" aria-label="Previous image">
                                <i class="fa-solid fa-chevron-left"></i>
                            </button>
                            <button class="nav-arrow" onclick="changeSlide(1)" aria-label="Next image">
                                <i class="fa-solid fa-chevron-right"></i>
                            </button>
                        </div>
                    </div>

                    <!-- Thumbnails List (limit to 4, show overlay on 4th if there are more) -->
                    <div class="thumbnails-container">
                        <c:forEach var="imgUrl" items="${room.imageUrls}" varStatus="status" end="3">
                            <div class="thumbnail-item ${status.index == 0 ? 'active' : ''} ${status.index == 3 && room.imageUrls.size() > 4 ? 'has-overlay' : ''}"
                                 data-index="${status.index}"
                                 data-more="+${room.imageUrls.size() - 3}"
                                 onclick="setGalleryActive('${status.index}', '${imgUrl}')">
                                <img src="${imgUrl}" alt="Thumbnail ${status.index + 1}" />
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <!-- Room Description -->
                <div class="info-card">
                    <h2>MÃ´ táº£ phÃ²ng</h2>
                    <p>${room.description}</p>
                    
                    <!-- Spec Cards (Area and Bed Type) -->
                    <div class="spec-grid">
                        <div class="spec-item">
                            <div class="spec-icon">
                                <i class="fa-solid fa-maximize"></i>
                            </div>
                            <div class="spec-text">
                                <span class="spec-label">Diá»‡n tÃ­ch</span>
                                <span class="spec-value">${room.area}</span>
                            </div>
                        </div>
                        <div class="spec-item">
                            <div class="spec-icon">
                                <i class="fa-solid fa-bed"></i>
                            </div>
                            <div class="spec-text">
                                <span class="spec-label">Loáº¡i giÆ°á»ng</span>
                                <span class="spec-value">${room.bedType}</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ÄÃ¡nh giÃ¡ cá»§a khÃ¡ch hÃ ng -->
                <div class="info-card" id="reviews-section" style="margin-top: 30px;">
                    <h2>ÄÃ¡nh giÃ¡ cá»§a khÃ¡ch hÃ ng</h2>
                    
                    <c:choose>
                        <c:when test="${not empty feedbackList}">
                            <!-- Header ÄÃ¡nh giÃ¡ -->
                            <div class="rating-header-summary" style="display: flex; align-items: center; gap: 24px; padding-bottom: 20px; border-bottom: 1px solid var(--border-color); margin-bottom: 20px; flex-wrap: wrap;">
                                <div class="average-score-box" style="text-align: center; background: var(--brand-blue-light); padding: 15px 25px; border-radius: 12px; min-width: 100px;">
                                    <div style="font-size: 32px; font-weight: 800; color: var(--brand-blue); line-height: 1;">
                                        <fmt:formatNumber value="${averageRating}" pattern="0.0" />
                                    </div>
                                    <div style="font-size: 13px; font-weight: 600; color: #475569; margin-top: 4px;">trÃªn 5</div>
                                </div>
                                <div>
                                    <div style="display: flex; align-items: center; gap: 4px; font-size: 18px; color: #fbbf24; margin-bottom: 4px;">
                                        <!-- Hiá»ƒn thá»‹ sao trung bÃ¬nh lÃ m trÃ²n -->
                                        <fmt:formatNumber var="roundedRating" value="${averageRating}" pattern="#" />
                                        <c:forEach begin="1" end="5" var="i">
                                            <c:choose>
                                                <c:when test="${i <= roundedRating}">
                                                    <i class="fa-solid fa-star"></i>
                                                </c:when>
                                                <c:otherwise>
                                                    <i class="fa-regular fa-star"></i>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:forEach>
                                    </div>
                                    <div style="font-size: 15px; font-weight: 600; color: var(--text-navy);">
                                        ${totalReviews} lÆ°á»£t Ä‘Ã¡nh giÃ¡
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Danh sÃ¡ch nháº­n xÃ©t -->
                            <div class="feedback-items-list" style="display: flex; flex-direction: column; gap: 20px;">
                                <c:forEach var="fb" items="${feedbackList}">
                                    <div class="feedback-item-card" style="padding-bottom: 20px; border-bottom: 1px dashed var(--border-color);">
                                        <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 10px;">
                                            <div>
                                                <div style="font-weight: 700; color: var(--text-navy); font-size: 15px; display: flex; align-items: center; gap: 8px;">
                                                    <i class="fa-solid fa-circle-user" style="color: #94a3b8; font-size: 18px;"></i>
                                                    <c:out value="${fb.customerName}" />
                                                </div>
                                                <div style="display: flex; align-items: center; gap: 4px; font-size: 13px; color: #fbbf24; margin-top: 4px;">
                                                    <c:forEach begin="1" end="${fb.rating}">
                                                        <i class="fa-solid fa-star"></i>
                                                    </c:forEach>
                                                    <c:forEach begin="${fb.rating + 1}" end="5">
                                                        <i class="fa-regular fa-star"></i>
                                                    </c:forEach>
                                                    <span style="color: #64748b; font-size: 12px; margin-left: 6px; font-weight: 500;">
                                                        PhÃ²ng ${fb.roomNumber}
                                                    </span>
                                                </div>
                                            </div>
                                            <div style="font-size: 12px; color: var(--text-muted); font-weight: 500;">
                                                <fmt:formatDate value="${fb.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                            </div>
                                        </div>
                                        
                                        <c:if test="${not empty fb.comment}">
                                            <div style="margin-top: 10px; font-size: 14.5px; color: #334155; line-height: 1.5; background: #f8fafc; padding: 12px 16px; border-radius: 8px; border-left: 3px solid #cbd5e1;">
                                                "<c:out value="${fb.comment}" />"
                                            </div>
                                        </c:if>
                                    </div>
                                </c:forEach>
                            </div>

                            <!-- PhÃ¢n trang Ä‘Ã¡nh giÃ¡ (5 comment / trang) -->
                            <c:if test="${totalPages > 1}">
                                <c:url var="feedbackPageBaseUrl" value="/rooms/detail">
                                    <c:param name="id" value="${room.typeId}" />
                                    <c:if test="${not empty selectedCheckIn}">
                                        <c:param name="checkIn" value="${selectedCheckIn}" />
                                    </c:if>
                                    <c:if test="${not empty selectedCheckOut}">
                                        <c:param name="checkOut" value="${selectedCheckOut}" />
                                    </c:if>
                                </c:url>

                                <div class="feedback-pagination" style="display: flex; justify-content: space-between; align-items: center; margin-top: 25px; border-top: 1px solid var(--border-color); flex-wrap: wrap; gap: 12px; padding-top: 15px;">
                                    <div style="font-size: 13.5px; color: var(--text-muted); font-weight: 500;">
                                        Hiá»ƒn thá»‹ Trang <strong>${currentPage}</strong> / <strong>${totalPages}</strong> (${totalReviews} Ä‘Ã¡nh giÃ¡)
                                    </div>
                                    <div style="display: flex; gap: 6px; align-items: center;">
                                        <!-- NÃºt TrÆ°á»›c -->
                                        <c:choose>
                                            <c:when test="${currentPage > 1}">
                                                <a href="${feedbackPageBaseUrl}&page=${currentPage - 1}#reviews-section" class="feedback-page-btn" title="Trang trÆ°á»›c">
                                                    <i class="fa-solid fa-chevron-left"></i>
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="feedback-page-btn disabled">
                                                    <i class="fa-solid fa-chevron-left"></i>
                                                </span>
                                            </c:otherwise>
                                        </c:choose>

                                        <!-- CÃ¡c trang sá»‘ -->
                                        <c:forEach var="p" begin="1" end="${totalPages}">
                                            <a href="${feedbackPageBaseUrl}&page=${p}#reviews-section" class="feedback-page-btn ${p == currentPage ? 'active' : ''}">
                                                ${p}
                                            </a>
                                        </c:forEach>

                                        <!-- NÃºt Tiáº¿p theo -->
                                        <c:choose>
                                            <c:when test="${currentPage < totalPages}">
                                                <a href="${feedbackPageBaseUrl}&page=${currentPage + 1}#reviews-section" class="feedback-page-btn" title="Trang tiáº¿p">
                                                    <i class="fa-solid fa-chevron-right"></i>
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="feedback-page-btn disabled">
                                                    <i class="fa-solid fa-chevron-right"></i>
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </c:if>
                        </c:when>
                        
                        <c:otherwise>
                            <!-- Empty State -->
                            <div class="empty-rating-state" style="text-align: center; padding: 30px 10px; color: #64748b;">
                                <i class="fa-regular fa-comments" style="font-size: 40px; color: #cbd5e1; margin-bottom: 12px; display: block;"></i>
                                <span style="font-size: 16px; font-weight: 700; color: var(--text-navy); display: block; margin-bottom: 4px;">Hiá»‡n táº¡i chÆ°a Ä‘Æ°á»£c Ä‘Ã¡nh giÃ¡.</span>
                                <span style="font-size: 13.5px; color: var(--text-muted);">HÃ£y lÃ  ngÆ°á»i Ä‘áº§u tiÃªn chia sáº» tráº£i nghiá»‡m vá» loáº¡i phÃ²ng nÃ y.</span>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

            </div>

            <!-- RIGHT COLUMN: Sticky Booking Card & Guarantees -->
            <div class="right-column">
                
                <!-- Booking details -->
                <div class="booking-card">
                    <h1>${room.typeName}</h1>
                    
                    <div class="price-display">
                        <fmt:formatNumber value="${room.basePrice}" pattern="#,###" />Ä‘
                        <span>/ Ä‘Ãªm</span>
                    </div>

                    <!-- Badges -->
                    <div class="badges-container">
                        <div class="badge-item guests">
                            <i class="fa-solid fa-user-group"></i> Tá»‘i Ä‘a ${room.capacity} khÃ¡ch
                        </div>
                        
                        <c:choose>
                            <c:when test="${room.availableCount > 0}">
                                <div class="badge-item availability">
                                    <i class="fa-solid fa-circle-check"></i> CÃ²n ${room.availableCount} phÃ²ng trá»‘ng
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="badge-item out-of-stock">
                                    <i class="fa-solid fa-circle-xmark"></i> Háº¿t phÃ²ng trá»‘ng
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Amenities Section -->
                    <div class="amenities-section">
                        <h3>Tiá»‡n nghi phÃ²ng</h3>
                        <div class="amenity-detail-grid">
                            <c:forEach var="amenity" items="${room.amenityDetails}">
                                <div class="amenity-detail-item">
                                    <div class="amenity-detail-icon">
                                        <i class="fa-solid ${amenity.icon}"></i>
                                    </div>
                                    <span>${amenity.name}</span>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- Selected Dates Display -->
                    <div style="font-size:13px; color:#475569; margin-bottom:12px; background:#f8fafc; border:1px solid #e2e8f0; padding:8px 12px; border-radius:6px;">
                        <i class="fa-regular fa-calendar-days" style="color:#2563eb;"></i> Khoáº£ng ngÃ y: <strong>${selectedCheckIn}</strong> â†’ <strong>${selectedCheckOut}</strong>
                    </div>

                    <!-- Action Button -->
                    <c:choose>
                        <c:when test="${room.availableCount > 0}">
                            <c:choose>
                                <c:when test="${not empty sessionScope.role and sessionScope.role == 'CUSTOMER'}">
                                    <a href="${pageContext.request.contextPath}/booking/start?id=${room.typeId}&checkIn=${selectedCheckIn}&checkOut=${selectedCheckOut}" class="btn-book-now" style="text-decoration: none;">Äáº·t phÃ²ng ngay</a>
                                </c:when>
                                <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/home/login" class="btn-book-now" style="text-decoration: none;">Äáº·t phÃ²ng ngay</a>
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:otherwise>
                            <button class="btn-book-now" style="background-color: #cbd5e1; cursor: not-allowed; box-shadow: none;" disabled>Äáº·t phÃ²ng ngay</button>
                        </c:otherwise>
                    </c:choose>
                    
                    <span class="booking-subtext">KhÃ´ng máº¥t phÃ­ Ä‘áº·t phÃ²ng â€¢ XÃ¡c nháº­n tá»©c thÃ¬</span>
                </div>

                <!-- Guarantee Card -->
                <div class="trust-badge-card">
                    <div class="trust-icon">
                        <i class="fa-solid fa-shield-halved"></i>
                    </div>
                    <div class="trust-content">
                        <h4>Äáº£m báº£o giÃ¡ tá»‘t nháº¥t</h4>
                        <p>Cam káº¿t giÃ¡ tháº¥p nháº¥t khi Ä‘áº·t trá»±c tiáº¿p táº¡i HotelOps</p>
                    </div>
                </div>

            </div>

        </div>

    </main>

    <!-- Modern Clean Footer -->
    <footer class="footer-rooms">
        <div class="container footer-rooms-grid">
            <div class="footer-brand">
                <h3>HotelOps</h3>
                <p>Kiáº¿n táº¡o tráº£i nghiá»‡m lÆ°u trÃº Ä‘áº³ng cáº¥p vÃ  quáº£n lÃ½ váº­n hÃ nh chuyÃªn nghiá»‡p.</p>
            </div>
            
            <div class="footer-col">
                <h4>LiÃªn káº¿t</h4>
                <ul>
                    <li><a href="#">Vá» chÃºng tÃ´i</a></li>
                    <li><a href="${pageContext.request.contextPath}/rooms">PhÃ²ng & Suites</a></li>
                    <li><a href="#">Dá»‹ch vá»¥ khÃ¡ch hÃ ng</a></li>
                </ul>
            </div>

            <div class="footer-col">
                <h4>PhÃ¡p lÃ½</h4>
                <ul>
                    <li><a href="#">ChÃ­nh sÃ¡ch báº£o máº­t</a></li>
                    <li><a href="#">Äiá»u khoáº£n sá»­ dá»¥ng</a></li>
                    <li><a href="#">Há»— trá»£ khÃ¡ch hÃ ng</a></li>
                </ul>
            </div>

            <div class="footer-col">
                <h4>LiÃªn há»‡</h4>
                <p style="font-size: 14px; color: var(--text-muted); margin-bottom: 8px;">
                    123 ÄÆ°á»ng LÃª Lá»£i, Quáº­n 1, TP.HCM
                </p>
                <p style="font-size: 14px; color: var(--text-muted); margin-bottom: 16px;">
                    +84 123 456 789
                </p>
                <div class="footer-social-links">
                    <a href="#" class="social-circle"><i class="fa-solid fa-globe"></i></a>
                    <a href="#" class="social-circle"><i class="fa-solid fa-at"></i></a>
                </div>
            </div>
        </div>
        <div class="footer-rooms-bottom">
            <p>Â© 2024 HotelOps Luxury Management. Táº¥t cáº£ quyá»n Ä‘Æ°á»£c báº£o lÆ°u.</p>
        </div>
    </footer>

    <!-- Javascript Slider Control Logic -->
    <script>
        const slideImages = [];
        <c:forEach var="url" items="${room.imageUrls}">slideImages.push("${url}");</c:forEach>
        
        let currentSlideIndex = 0;

        function changeSlide(direction) {
            if (slideImages.length <= 1) return;
            currentSlideIndex = (currentSlideIndex + direction + slideImages.length) % slideImages.length;
            updateGallery();
        }

        function setGalleryActive(index, url) {
            currentSlideIndex = parseInt(index);
            updateGallery();
        }

        function updateGallery() {
            const mainImg = document.getElementById("main-gallery-img");
            mainImg.src = slideImages[currentSlideIndex];
            
            // Update active states on thumbnail borders
            const thumbnails = document.querySelectorAll(".thumbnail-item");
            thumbnails.forEach((thumb, idx) => {
                // If it's the active one (or index 3 represents current active if index is >= 3)
                if (idx === currentSlideIndex || (idx === 3 && currentSlideIndex >= 3)) {
                    thumb.classList.add("active");
                } else {
                    thumb.classList.remove("active");
                }
            });
        }
    </script>

</body>
</html>
