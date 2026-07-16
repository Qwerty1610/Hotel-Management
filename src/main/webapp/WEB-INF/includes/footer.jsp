<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="hotelName" value='<%= com.mycompany.hotelmanagement.config.ConfigUtil.get("hotel.name", "HotelOps Pro") %>' />
<c:set var="hotelIntro" value='<%= com.mycompany.hotelmanagement.config.ConfigUtil.get("hotel.intro", "Hệ thống quản lý và nghỉ dưỡng đẳng cấp quốc tế, đem lại trải nghiệm sang trọng vượt thời gian.") %>' />
<c:set var="hotelAddress" value='<%= com.mycompany.hotelmanagement.config.ConfigUtil.get("hotel.address", "123 Đường Lê Lợi, Quận 1, TP. Hồ Chí Minh") %>' />
<c:set var="hotelEmail" value='<%= com.mycompany.hotelmanagement.config.ConfigUtil.get("hotel.email", "contact@hotelopspro.com") %>' />
<c:set var="hotelPhone" value='<%= com.mycompany.hotelmanagement.config.ConfigUtil.get("hotel.phone", "1900 6789") %>' />

    <footer class="footer" id="lien-he">
        <div class="container footer-grid">
            <div class="footer-about">
                <h3>${hotelName}</h3>
                <p>${hotelIntro}</p>
            </div>
            
            <div class="footer-links">
                <h4>Liên kết nhanh</h4>
                <ul>
                    <li><a href="#">Trang chủ</a></li>
                    <li><a href="#">Phòng & Giá</a></li>
                    <li><a href="#">Dịch vụ</a></li>
                </ul>
            </div>

            <div class="footer-links">
                <h4>Chính sách</h4>
                <ul>
                    <li><a href="#">Chính sách bảo mật</a></li>
                    <li><a href="#">Điều khoản sử dụng</a></li>
                    <li><a href="#">Chính sách hoàn tiền</a></li>
                </ul>
            </div>

            <div class="footer-contact">
                <h4>Thông tin liên hệ</h4>
                <p><i class="fa-solid fa-location-dot"></i> ${hotelAddress}</p>
                <p><i class="fa-solid fa-envelope"></i> ${hotelEmail}</p>
                <span class="phone-number"><i class="fa-solid fa-phone"></i> ${hotelPhone}</span>
            </div>
        </div>
        <div class="footer-bottom text-center">
            <p>&copy; 2026 ${hotelName}. All rights reserved.</p>
        </div>
    </footer>

    <script src="${pageContext.request.contextPath}/assets/js/home.js"></script>
</body>
</html>