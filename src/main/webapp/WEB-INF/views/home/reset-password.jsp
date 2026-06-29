<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../includes/taglibs.jsp" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt lại mật khẩu - HotelOps Pro</title>

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
        rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/login.css?v=3" />
    <style>
        .success-alert {
            background: rgba(16, 185, 129, 0.08);
            border: 1px solid rgba(16, 185, 129, 0.15);
            color: #10b981;
            padding: 12px 16px;
            border-radius: 12px;
            font-size: 13.5px;
            font-weight: 600;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 10px;
            text-align: left;
        }
    </style>
</head>

<body class="login-body">

    <div class="login-container">
        <div class="login-card">
            <div class="logo"><i class="fa-solid fa-hotel"></i>Hotel<span>Ops</span></div>
            <div class="subtitle">Đặt lại mật khẩu mới</div>

            <c:if test="${param.success eq 'otp_sent'}">
                <div class="success-alert">
                    <i class="fa-solid fa-circle-check"></i>
                    <span>Mã OTP đã được gửi đến hòm thư của bạn! Vui lòng kiểm tra email.</span>
                </div>
            </c:if>

            <c:if test="${not empty param.error}">
                <div class="error-alert">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                    <span>
                        <c:choose>
                            <c:when test="${param.error eq 'invalid_otp'}">
                                Mã OTP không chính xác hoặc đã hết hạn!
                            </c:when>
                            <c:when test="${param.error eq 'passwords_dont_match'}">
                                Mật khẩu xác nhận không trùng khớp!
                            </c:when>
                            <c:when test="${param.error eq 'invalid_password'}">
                                Mật khẩu mới phải bao gồm cả chữ, số và ký tự đặc biệt!
                            </c:when>
                            <c:when test="${param.error eq 'invalid_input'}">
                                Vui lòng nhập đầy đủ thông tin yêu cầu!
                            </c:when>
                            <c:otherwise>
                                Lỗi hệ thống. Vui lòng thử lại sau.
                            </c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/home/reset-password?portal=${portal}" method="POST" id="resetPasswordForm">
                <div class="form-group">
                    <label for="email">Địa chỉ Email</label>
                    <div class="input-wrapper">
                        <input type="email" id="email" name="email" class="form-input"
                            placeholder="email@example.com" required readonly value="${param.email}" />
                        <i class="fa-solid fa-envelope"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label for="otp">Mã xác thực OTP</label>
                    <div class="input-wrapper">
                        <input type="text" id="otp" name="otp" class="form-input"
                            placeholder="Nhập 6 chữ số OTP" required pattern="[0-9]{6}" maxlength="6" autofocus />
                        <i class="fa-solid fa-key"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label for="newPassword">Mật khẩu mới</label>
                    <div class="input-wrapper">
                        <input type="password" id="newPassword" name="newPassword" class="form-input"
                            placeholder="Tối thiểu 8 ký tự (chữ, số, ký tự đặc biệt)" required minlength="8" />
                        <i class="fa-solid fa-lock"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Xác nhận mật khẩu mới</label>
                    <div class="input-wrapper">
                        <input type="password" id="confirmPassword" name="confirmPassword" class="form-input"
                            placeholder="Nhập lại mật khẩu mới" required />
                        <i class="fa-solid fa-lock"></i>
                    </div>
                </div>

                <button type="submit" class="btn-submit" style="margin-top: 20px;">
                    <i class="fa-solid fa-circle-check"></i> Đổi mật khẩu
                </button>
            </form>

            <div class="signup-prompt" style="margin-top: 25px;">
                Quay lại trang <a href="${pageContext.request.contextPath}/${portal eq 'staff' ? 'staff/login' : 'home/login'}">Đăng nhập ngay</a>
            </div>
        </div>
    </div>

    <script>
        document.getElementById('resetPasswordForm').addEventListener('submit', function (e) {
            const email = document.getElementById('email').value.trim();
            const otp = document.getElementById('otp').value.trim();
            const newPassword = document.getElementById('newPassword').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            let errorMessage = '';
            
            // 1. Basic empty check
            if (!email || !otp || !newPassword || !confirmPassword) {
                errorMessage = 'Vui lòng điền đầy đủ tất cả các trường!';
            }
            // 2. OTP format validation (6 digits)
            else if (!/^[0-9]{6}$/.test(otp)) {
                errorMessage = 'Mã OTP phải gồm 6 chữ số!';
            }
            // 3. Password strength validation
            else {
                const hasLetter = /[a-zA-Z]/.test(newPassword);
                const hasDigit = /[0-9]/.test(newPassword);
                const hasSpecial = /[^a-zA-Z0-9]/.test(newPassword);
                
                if (newPassword.length < 8) {
                    errorMessage = 'Mật khẩu phải tối thiểu từ 8 ký tự trở lên!';
                } else if (!hasLetter || !hasDigit || !hasSpecial) {
                    errorMessage = 'Mật khẩu mới phải bao gồm cả chữ, số và ký tự đặc biệt!';
                }
                // 4. Confirm password validation
                else if (newPassword !== confirmPassword) {
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
                    const form = document.getElementById('resetPasswordForm');
                    card.insertBefore(alertContainer, form);
                    
                    // Remove success alert if it exists
                    const successAlert = document.querySelector('.success-alert');
                    if (successAlert) {
                        successAlert.remove();
                    }
                }
                
                // Update text and scroll to top of card
                alertContainer.querySelector('span').innerText = errorMessage;
                alertContainer.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }
        });
    </script>
</body>
</html>
