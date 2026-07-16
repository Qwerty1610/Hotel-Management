<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên mật khẩu - HotelOps Pro</title>

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
        rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/login.css?v=3" />
</head>

<body class="login-body">

    <div class="login-container">
        <div class="login-card">
            <div class="logo"><i class="fa-solid fa-hotel"></i>Hotel<span>Ops</span></div>
            <div class="subtitle">Khôi phục tài khoản của bạn</div>

            <p style="color: var(--text-light); font-size: 13.5px; margin-bottom: 25px; line-height: 1.5;">
                Nhập email của bạn dưới đây. Hệ thống sẽ gửi một mã xác thực OTP gồm 6 chữ số đến hòm thư của bạn để khôi phục mật khẩu.
            </p>

            <c:if test="${not empty param.error}">
                <div class="error-alert">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                    <span>
                        <c:choose>
                            <c:when test="${param.error eq 'email_not_found'}">
                                Email này chưa được đăng ký trong hệ thống!
                            </c:when>
                            <c:when test="${param.error eq 'invalid_input'}">
                                Vui lòng điền đúng địa chỉ email!
                            </c:when>
                            <c:otherwise>
                                Lỗi hệ thống. Vui lòng thử lại sau.
                            </c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/home/forgot-password?portal=${portal}" method="POST" id="forgotPasswordForm">
                <div class="form-group">
                    <label for="email">Địa chỉ Email</label>
                    <div class="input-wrapper">
                        <input type="email" id="email" name="email" class="form-input"
                            placeholder="email@example.com" required autofocus value="${param.email}" />
                        <i class="fa-solid fa-envelope"></i>
                    </div>
                </div>

                <button type="submit" class="btn-submit" style="margin-top: 15px;">
                    <i class="fa-solid fa-paper-plane"></i> Gửi mã OTP
                </button>
            </form>

            <div class="signup-prompt" style="margin-top: 30px;">
                Nhớ mật khẩu? <a href="${pageContext.request.contextPath}/${portal eq 'staff' ? 'staff/login' : 'home/login'}">Đăng nhập ngay</a>
            </div>

            <a href="${pageContext.request.contextPath}/home" class="back-link">
                <i class="fa-solid fa-arrow-left"></i>Quay lại trang chủ
            </a>
        </div>
    </div>

    <script>
        document.getElementById('forgotPasswordForm').addEventListener('submit', function (e) {
            const email = document.getElementById('email').value.trim();
            let errorMessage = '';
            
            if (!email) {
                errorMessage = 'Vui lòng nhập địa chỉ email!';
            } else if (!/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(email)) {
                errorMessage = 'Định dạng Email không hợp lệ!';
            }
            
            if (errorMessage) {
                e.preventDefault(); // Stop submission
                
                // Display error message in the .error-alert div
                let alertContainer = document.querySelector('.error-alert');
                if (!alertContainer) {
                    alertContainer = document.createElement('div');
                    alertContainer.className = 'error-alert';
                    alertContainer.innerHTML = '<i class="fa-solid fa-triangle-exclamation"></i> <span></span>';
                    const card = document.querySelector('.login-card');
                    const form = document.getElementById('forgotPasswordForm');
                    card.insertBefore(alertContainer, form);
                }
                
                alertContainer.querySelector('span').innerText = errorMessage;
                alertContainer.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }
        });
    </script>
</body>
</html>
