<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../includes/taglibs.jsp" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký tài khoản - HotelOps Pro</title>

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
        rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/login.css?v=3" />
</head>

<body class="login-body">

    <div class="login-container">
        <div class="login-card">
            <div class="logo"><i class="fa-solid fa-hotel"></i>Hotel<span>Ops</span></div>
            <div class="subtitle">Đăng ký tài khoản khách hàng mới</div>

            <c:if test="${not empty param.error}">
                <div class="error-alert">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                    <span>
                        <c:choose>
                            <c:when test="${param.error eq 'email_exists'}">
                                Email này đã được đăng ký trong hệ thống!
                            </c:when>
                            <c:when test="${param.error eq 'phone_exists'}">
                                Số điện thoại này đã được đăng ký trong hệ thống!
                            </c:when>
                            <c:when test="${param.error eq 'passwords_dont_match'}">
                                Mật khẩu xác nhận không trùng khớp!
                            </c:when>
                            <c:when test="${param.error eq 'invalid_email'}">
                                Định dạng Email không hợp lệ!
                            </c:when>
                            <c:when test="${param.error eq 'invalid_phone'}">
                                Số điện thoại phải bắt đầu bằng số 0, theo sau là đầu số 3, 5, 7, 8, 9 và có đúng 10 chữ số!
                            </c:when>
                            <c:when test="${param.error eq 'invalid_password'}">
                                Mật khẩu mới phải bao gồm cả chữ, số và ký tự đặc biệt!
                            </c:when>
                            <c:when test="${param.error eq 'invalid_input'}">
                                Vui lòng điền đầy đủ và đúng định dạng các trường!
                            </c:when>
                            <c:otherwise>
                                Lỗi hệ thống khi đăng ký. Vui lòng thử lại.
                            </c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/home/register" method="POST" id="registerForm">
                <div class="form-group">
                    <label for="fullName">Họ và Tên</label>
                    <div class="input-wrapper">
                        <input type="text" id="fullName" name="fullName" class="form-input"
                            placeholder="Nguyễn Văn A" required autofocus value="${param.fullName}" />
                        <i class="fa-solid fa-user"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label for="email">Địa chỉ Email</label>
                    <div class="input-wrapper">
                        <input type="email" id="email" name="email" class="form-input"
                            placeholder="email@example.com" required value="${param.email}" />
                        <i class="fa-solid fa-envelope"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label for="phone">Số điện thoại</label>
                    <div class="input-wrapper">
                        <input type="tel" id="phone" name="phone" class="form-input"
                            placeholder="0912345678" required pattern="^0[35789][0-9]{8}$" title="Số điện thoại phải bắt đầu bằng số 0, theo sau là đầu số 3, 5, 7, 8, 9 và có đúng 10 chữ số" value="${param.phone}" />
                        <i class="fa-solid fa-phone"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label for="password">Mật khẩu</label>
                    <div class="input-wrapper">
                        <input type="password" id="password" name="password" class="form-input"
                            placeholder="Tối thiểu 8 ký tự (chữ, số, ký tự đặc biệt)" required minlength="8" />
                        <i class="fa-solid fa-lock"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Xác nhận mật khẩu</label>
                    <div class="input-wrapper">
                        <input type="password" id="confirmPassword" name="confirmPassword" class="form-input"
                            placeholder="Nhập lại mật khẩu" required />
                        <i class="fa-solid fa-lock"></i>
                    </div>
                </div>

                <button type="submit" class="btn-submit" style="margin-top: 20px;">
                    <i class="fa-solid fa-user-plus"></i> Đăng ký
                </button>
            </form>

            <div class="signup-prompt" style="margin-top: 25px;">
                Đã có tài khoản? <a href="${pageContext.request.contextPath}/home/login">Đăng nhập ngay</a>
            </div>

            <a href="${pageContext.request.contextPath}/home" class="back-link">
                <i class="fa-solid fa-arrow-left"></i>Quay lại trang chủ
            </a>
        </div>
    </div>

    <script>
        document.getElementById('registerForm').addEventListener('submit', function (e) {
            const fullName = document.getElementById('fullName').value.trim();
            const email = document.getElementById('email').value.trim();
            const phone = document.getElementById('phone').value.trim();
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            let errorMessage = '';
            
            // 1. Basic empty check
            if (!fullName || !email || !phone || !password || !confirmPassword) {
                errorMessage = 'Vui lòng điền đầy đủ tất cả các trường!';
            }
            // 2. Email format validation
            else if (!/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(email)) {
                errorMessage = 'Định dạng Email không hợp lệ!';
            }
            // 3. Phone validation
            else if (!/^0[35789][0-9]{8}$/.test(phone)) {
                errorMessage = 'Số điện thoại phải bắt đầu bằng số 0, theo sau là đầu số 3, 5, 7, 8, 9 và có đúng 10 chữ số!';
            }
            // 4. Password strength validation
            else {
                const hasLetter = /[a-zA-Z]/.test(password);
                const hasDigit = /[0-9]/.test(password);
                const hasSpecial = /[^a-zA-Z0-9]/.test(password);
                
                if (password.length < 8) {
                    errorMessage = 'Mật khẩu phải tối thiểu từ 8 ký tự trở lên!';
                } else if (!hasLetter || !hasDigit || !hasSpecial) {
                    errorMessage = 'Mật khẩu mới phải bao gồm cả chữ, số và ký tự đặc biệt!';
                }
                // 5. Confirm password validation
                else if (password !== confirmPassword) {
                    errorMessage = 'Mật khẩu xác nhận không trùng khớp!';
                }
            }
            
            if (errorMessage) {
                e.preventDefault(); // Stop submission
                
                // Display error message in the .error-alert div
                let alertContainer = document.querySelector('.error-alert');
                if (!alertContainer) {
                    // Create dynamic error alert container if it doesn't exist
                    alertContainer = document.createElement('div');
                    alertContainer.className = 'error-alert';
                    alertContainer.innerHTML = '<i class="fa-solid fa-triangle-exclamation"></i> <span></span>';
                    const card = document.querySelector('.login-card');
                    const form = document.getElementById('registerForm');
                    card.insertBefore(alertContainer, form);
                }
                
                // Update text and scroll to top of card
                alertContainer.querySelector('span').innerText = errorMessage;
                alertContainer.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }
        });
    </script>
</body>
</html>
