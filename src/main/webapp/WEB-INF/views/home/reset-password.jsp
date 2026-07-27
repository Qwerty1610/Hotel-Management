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
                                Đã xảy ra lỗi không mong muốn. Vui lòng thử lại sau.
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

                <!-- BƯỚC 1: NHẬP VÀ XÁC THỰC MÃ OTP -->
                <div id="stepOtpSection">
                    <div class="form-group">
                        <label for="otp">Mã xác thực OTP</label>
                        <div class="input-wrapper">
                            <input type="text" id="otp" name="otp" class="form-input"
                                placeholder="Nhập 6 chữ số OTP" required pattern="[0-9]{6}" maxlength="6" autofocus />
                            <i class="fa-solid fa-key"></i>
                        </div>
                    </div>

                    <button type="button" id="btnVerifyOtp" class="btn-submit" style="margin-top: 15px;">
                        <i class="fa-solid fa-shield-halved"></i> Xác thực mã OTP
                    </button>
                </div>

                <!-- BƯỚC 2: KHUNG NHẬP MẬT KHẨU MỚI (Ẩn ban đầu, chỉ hiện khi nhập ĐÚNG mã OTP) -->
                <div id="stepPasswordSection" style="display: none; margin-top: 15px;">
                    <div class="success-alert" id="otpSuccessAlert" style="margin-bottom: 20px;">
                        <i class="fa-solid fa-circle-check"></i>
                        <span>Mã OTP hợp lệ! Vui lòng thiết lập mật khẩu mới bên dưới.</span>
                    </div>

                    <div class="form-group">
                        <label for="newPassword">Mật khẩu mới</label>
                        <div class="input-wrapper">
                            <input type="password" id="newPassword" name="newPassword" class="form-input"
                                placeholder="Tối thiểu 8 ký tự (chữ, số, ký tự đặc biệt)" minlength="8" />
                            <i class="fa-solid fa-lock"></i>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="confirmPassword">Xác nhận mật khẩu mới</label>
                        <div class="input-wrapper">
                            <input type="password" id="confirmPassword" name="confirmPassword" class="form-input"
                                placeholder="Nhập lại mật khẩu mới" />
                            <i class="fa-solid fa-lock"></i>
                        </div>
                    </div>

                    <button type="submit" class="btn-submit" style="margin-top: 20px;">
                        <i class="fa-solid fa-circle-check"></i> Đổi mật khẩu
                    </button>
                </div>
            </form>

            <div class="signup-prompt" style="margin-top: 25px;">
                Quay lại trang <a href="${pageContext.request.contextPath}/${portal eq 'staff' ? 'staff/login' : 'home/login'}">Đăng nhập ngay</a>
            </div>
        </div>
    </div>

    <script>
        let isOtpVerified = false;

        document.getElementById('btnVerifyOtp').addEventListener('click', async function () {
            const email = document.getElementById('email').value.trim();
            const otp = document.getElementById('otp').value.trim();

            if (!otp || !/^[0-9]{6}$/.test(otp)) {
                showError('Vui lòng nhập mã OTP gồm 6 chữ số!');
                return;
            }

            const btn = this;
            btn.disabled = true;
            btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang xác thực...';

            try {
                const response = await fetch('${pageContext.request.contextPath}/home/reset-password', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'action=verify_otp&email=' + encodeURIComponent(email) + '&otp=' + encodeURIComponent(otp)
                });
                const data = await response.json();

                if (data.valid) {
                    isOtpVerified = true;
                    clearError();
                    
                    // Khóa ô OTP & ẩn nút xác thực OTP
                    document.getElementById('otp').readOnly = true;
                    btn.style.display = 'none';

                    // Hiển thị phần nhập mật khẩu mới
                    const passSection = document.getElementById('stepPasswordSection');
                    passSection.style.display = 'block';
                    document.getElementById('newPassword').required = true;
                    document.getElementById('confirmPassword').required = true;
                    document.getElementById('newPassword').focus();
                } else {
                    showError(data.message || 'Mã OTP không chính xác hoặc đã hết hạn!');
                    btn.disabled = false;
                    btn.innerHTML = '<i class="fa-solid fa-shield-halved"></i> Xác thực mã OTP';
                }
            } catch (err) {
                showError('Lỗi kết nối máy chủ! Vui lòng thử lại sau.');
                btn.disabled = false;
                btn.innerHTML = '<i class="fa-solid fa-shield-halved"></i> Xác thực mã OTP';
            }
        });

        function showError(msg) {
            let alertContainer = document.querySelector('.error-alert');
            if (!alertContainer) {
                alertContainer = document.createElement('div');
                alertContainer.className = 'error-alert';
                alertContainer.innerHTML = '<i class="fa-solid fa-triangle-exclamation"></i> <span></span>';
                const card = document.querySelector('.login-card');
                const form = document.getElementById('resetPasswordForm');
                card.insertBefore(alertContainer, form);
            }
            const successAlert = document.querySelector('.success-alert');
            if (successAlert) successAlert.style.display = 'none';

            alertContainer.querySelector('span').innerText = msg;
            alertContainer.style.display = 'flex';
        }

        function clearError() {
            const alertContainer = document.querySelector('.error-alert');
            if (alertContainer) alertContainer.style.display = 'none';
        }

        document.getElementById('resetPasswordForm').addEventListener('submit', function (e) {
            if (!isOtpVerified) {
                e.preventDefault();
                showError('Vui lòng xác thực mã OTP trước!');
                return;
            }

            const newPassword = document.getElementById('newPassword').value;
            const confirmPassword = document.getElementById('confirmPassword').value;

            let errorMessage = '';
            const hasLetter = /[a-zA-Z]/.test(newPassword);
            const hasDigit = /[0-9]/.test(newPassword);
            const hasSpecial = /[^a-zA-Z0-9]/.test(newPassword);

            if (newPassword.length < 8) {
                errorMessage = 'Mật khẩu phải tối thiểu từ 8 ký tự trở lên!';
            } else if (!hasLetter || !hasDigit || !hasSpecial) {
                errorMessage = 'Mật khẩu mới phải bao gồm cả chữ, số và ký tự đặc biệt!';
            } else if (newPassword !== confirmPassword) {
                errorMessage = 'Mật khẩu xác nhận không trùng khớp!';
            }

            if (errorMessage) {
                e.preventDefault();
                showError(errorMessage);
            }
        });

        document.querySelectorAll('input[required], select[required], textarea[required]').forEach(function (input) {
            input.addEventListener('invalid', function () {
                if (this.validity.valueMissing) {
                    this.setCustomValidity('Vui lòng điền vào trường này.');
                }
            });
            input.addEventListener('input', function () {
                this.setCustomValidity('');
            });
        });

        <c:if test="${not empty param.error and param.error ne 'invalid_otp'}">
            // Trong trường hợp server trả về lỗi mật khẩu (không phải lỗi OTP), tự động giữ mở Bước 2
            isOtpVerified = true;
            document.getElementById('otp').readOnly = true;
            document.getElementById('btnVerifyOtp').style.display = 'none';
            document.getElementById('stepPasswordSection').style.display = 'block';
            document.getElementById('newPassword').required = true;
            document.getElementById('confirmPassword').required = true;
        </c:if>
    </script>
</body>
</html>
