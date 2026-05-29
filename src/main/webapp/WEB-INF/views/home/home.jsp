<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%-- Nhúng Header cấu trúc --%>
<%@ include file="../../includes/header.jsp" %>

<body>

    <header class="hero-section" id="trang-chu">
        <nav class="navbar">
            <div class="logo">HotelOps</div>
            <ul class="nav-links">
                <li><a href="#trang-chu" class="active">Trang chủ</a></li>
                <li><a href="#gioi-thieu">Giới thiệu</a></li>
                <li><a href="#phong-gia">Phòng</a></li>
                <li><a href="#dich-vu">Dịch vụ</a></li>
                <li><a href="#lien-he">Liên hệ</a></li>
            </ul>

            <div class="nav-actions">
                <a href="${pageContext.request.contextPath}/home/login" class="btn-login">Đăng nhập</a>
                <a href="#" class="btn-register">Đăng ký</a>
            </div>
        </nav>

        <div class="hero-content">
            <h1>Trải nghiệm kỳ nghỉ<br>tuyệt vời tại HotelOps</h1>
            <p>Nơi sang trọng gặp gỡ sự tinh tế, mang đến cho bạn trải nghiệm nghỉ dưỡng đích thực tại trung tâm thành phố.</p>
        </div>

    </header>

    <section class="about-section container" id="gioi-thieu">
        <div class="about-image">
            <img src="https://images.unsplash.com/photo-1439066615861-d1af74d74000?q=80&w=1200" alt="Resort HotelOps">
        </div>
        <div class="about-text">
            <span class="sub-title">VỀ HOTELOPS</span>
            <h2>Định nghĩa lại lòng hiếu khách</h2>
            <p>
                HotelOps cung cấp không gian lưu trú sạch sẽ, tiện nghi và thoải mái
                dành cho cá nhân, gia đình và khách du lịch. Chúng tôi luôn cố gắng
                mang đến trải nghiệm nghỉ ngơi thuận tiện với mức giá phù hợp cho mọi khách hàng.
            </p>
            <div class="about-features">
                <div class="feat-item">
                    <i class="fa-solid fa-shield-halved"></i>
                    <div>
                        <h4>An ninh và Bảo mật tối đa</h4>
                        <p>Đảm bảo sự riêng tư tuyệt đối cho khách hàng.</p>
                    </div>
                </div>
                <div class="feat-item">
                    <i class="fa-solid fa-bell"></i>
                    <div>
                        <h4>Phục vụ phòng 24/7</h4>
                        <p>Luôn sẵn sàng đáp ứng mọi yêu cầu của bạn bất cứ lúc nào.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="values-section">
        <div class="container text-center">
            <span class="sub-title">TẠI SAO CHỌN CHÚNG TÔI</span>

            <div class="values-grid">

                <div class="value-card">
                    <i class="fa-solid fa-wallet"></i>
                    <h3>Giá cả hợp lý</h3>
                    <p>
                        Phù hợp với nhu cầu lưu trú phổ thông và tiết kiệm chi phí.
                    </p>
                </div>

                <div class="value-card">
                    <i class="fa-solid fa-bed"></i>
                    <h3>Phòng sạch sẽ</h3>
                    <p>
                        Không gian nghỉ ngơi được vệ sinh thường xuyên và gọn gàng.
                    </p>
                </div>

                <div class="value-card">
                    <i class="fa-solid fa-map-location-dot"></i>
                    <h3>Vị trí thuận tiện</h3>
                    <p>
                        Dễ dàng di chuyển đến các khu vực trung tâm và địa điểm du lịch.
                    </p>
                </div>

                <div class="value-card">
                    <i class="fa-solid fa-headset"></i>
                    <h3>Hỗ trợ thân thiện</h3>
                    <p>
                        Nhân viên luôn sẵn sàng hỗ trợ khách hàng nhanh chóng và nhiệt tình.
                    </p>
                </div>

            </div>
        </div>
    </section>

    <section class="rooms-section container" id="phong-gia">
        <div class="section-header">
            <div>
                <span class="sub-title">PHÒNG & SUITES</span>
                <h2>Không gian sống thoải mái</h2>
            </div>
            <button class="btn-outline">Xem tất cả phòng</button>
        </div>

        <div class="rooms-grid">
            <div class="room-card">
                <div class="room-img-container">
                    <img src="https://images.unsplash.com/photo-1618773928121-c32242e63f39?q=80&w=600" alt="Deluxe City View">
                    <span class="room-tag">Phổ biến</span>
                </div>
                <div class="room-info">
                    <h3>Deluxe City View</h3>
                    <p>Không gian rộng rãi hướng toàn cảnh thành phố lung linh về đêm.</p>
                    <div class="room-meta"><span><i class="fa-solid fa-maximize"></i> 45 m²</span> <span><i class="fa-solid fa-bed"></i> 1 Giường đôi lớn</span></div>
                    <div class="room-footer">
                        <span class="room-price">2.950.000đ <span>/ đêm</span></span>
                        <button class="btn-sm">Chi tiết</button>
                    </div>
                </div>
            </div>

            <div class="room-card">
                <div class="room-img-container">
                    <img src="https://images.unsplash.com/photo-1590490360182-c33d57733427?q=80&w=600" alt="Executive Suite">
                    <span class="room-tag premium">Ưu đãi</span>
                </div>
                <div class="room-info">
                    <h3>Executive Suite</h3>
                    <p>Tích hợp phòng khách sang trọng và quầy bar nhỏ đẳng cấp cao.</p>
                    <div class="room-meta"><span><i class="fa-solid fa-maximize"></i> 75 m²</span> <span><i class="fa-solid fa-bed"></i> 1 Giường King size</span></div>
                    <div class="room-footer">
                        <span class="room-price">5.500.000đ <span>/ đêm</span></span>
                        <button class="btn-sm">Chi tiết</button>
                    </div>
                </div>
            </div>

            <div class="room-card">
                <div class="room-img-container">
                    <img src="https://images.unsplash.com/photo-1566665797739-1674de7a421a?q=80&w=600" alt="Presidential Suite">
                </div>
                <div class="room-info">
                    <h3>Presidential Suite</h3>
                    <p>Căn hộ Tổng thống xa hoa bậc nhất với lối đi riêng và quản gia phục vụ.</p>
                    <div class="room-meta"><span><i class="fa-solid fa-maximize"></i> 180 m²</span> <span><i class="fa-solid fa-bed"></i> 2 Giường King</span></div>
                    <div class="room-footer">
                        <span class="room-price">12.500.000đ <span>/ đêm</span></span>
                        <button class="btn-sm">Chi tiết</button>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="services-section" id="dich-vu">
        <div class="container text-center">

            <span class="sub-title">DỊCH VỤ</span>

            <h2>Các tiện ích cơ bản</h2>

            <div class="services-grid">

                <div class="service-card">
                    <i class="fa-solid fa-utensils"></i>
                    <h3>Khu ăn uống</h3>
                    <p>
                        Phục vụ đồ ăn và nước uống cơ bản cho khách lưu trú.
                    </p>
                </div>

                <div class="service-card">
                    <i class="fa-solid fa-tv"></i>
                    <h3>Khu sinh hoạt chung</h3>
                    <p>
                        Không gian thư giãn và nghỉ ngơi dành cho khách hàng.
                    </p>
                </div>

                <div class="service-card">
                    <i class="fa-solid fa-shirt"></i>
                    <h3>Dịch vụ giặt ủi</h3>
                    <p>
                        Hỗ trợ giặt ủi với mức chi phí hợp lý và tiện lợi.
                    </p>
                </div>

                <div class="service-card">
                    <i class="fa-solid fa-square-parking"></i>
                    <h3>Bãi giữ xe</h3>
                    <p>
                        Khu vực giữ xe an toàn dành cho khách lưu trú.
                    </p>
                </div>

            </div>
        </div>
    </section>

    <section class="testimonial-section text-center">
        <div class="container">
            <i class="fa-solid fa-quote-left quote-icon"></i>
            <p class="testimonial-text">"Kỳ nghỉ tại đây thật sự vượt xa mong đợi của tôi. Từ quy trình nhận phòng thông minh đến sự chu đáo của đội ngũ nhân viên, tất cả đều toát lên vẻ chuyên nghiệp và sang trọng."</p>
            <div class="stars">
                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
            </div>
            <div class="client-info">
                <h4>Nguyễn Thúy Vân</h4>
                <span>Giám đốc Điều hành - VinTech</span>
            </div>
        </div>
    </section>

    <%-- Nhúng Footer kết thúc trang --%>
    <%@ include file="../../includes/footer.jsp" %>