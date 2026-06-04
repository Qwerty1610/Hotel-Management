<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/login.css" />
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
                                Mật khẩu xác nhận mới không trùng khớp!
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

            <form action="${pageContext.request.contextPath}/home/reset-password" method="POST" id="resetPasswordForm">
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
                            placeholder="Tối thiểu 6 ký tự" required minlength="6" />
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
                Quay lại trang <a href="${pageContext.request.contextPath}/home/login">Đăng nhập ngay</a>
            </div>
        </div>
    </div>

</body>
</html>
