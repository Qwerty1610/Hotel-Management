<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ include file="../../includes/taglibs.jsp" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Đăng nhập hệ thống - HotelOps Pro</title>

            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
                rel="stylesheet" />
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/login.css" />
        </head>

        <body class="login-body">

            <div class="login-container">
                <div class="login-card">
                    <div class="logo"><i class="fa-solid fa-hotel"></i>Hotel<span>Ops</span></div>
                    <div class="subtitle">Đăng nhập để quản lý đặt phòng của bạn</div>

                    <c:if test="${not empty param.error}">
                        <div class="error-alert">
                            <i class="fa-solid fa-triangle-exclamation"></i>
                            <span>
                                <c:choose>
                                    <c:when test="${param.error eq 'invalid_credentials'}">
                                        Tên đăng nhập hoặc mật khẩu không đúng!
                                    </c:when>
                                    <c:when test="${param.error eq 'unauthorized'}">
                                        Vui lòng đăng nhập để truy cập hệ thống.
                                    </c:when>
                                    <c:otherwise>
                                        Lỗi hệ thống. Vui lòng thử lại.
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/home/login" method="POST" id="loginForm">
                        <div class="form-group">
                            <label for="username">Địa chỉ Email</label>
                            <div class="input-wrapper">
                                <input type="text" id="username" name="username" class="form-input"
                                    placeholder="email@example.com" required autofocus />
                                <i class="fa-solid fa-envelope"></i>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="password">Mật khẩu</label>
                            <div class="input-wrapper">
                                <input type="password" id="password" name="password" class="form-input"
                                    placeholder="Nhập mật khẩu" required />
                                <i class="fa-solid fa-lock"></i>
                            </div>
                        </div>

                        <div class="form-options">
                            <label class="remember-me">
                                <input type="checkbox" name="remember" /> Ghi nhớ đăng nhập
                            </label>
                            <a href="#" class="forgot-password">Quên mật khẩu?</a>
                        </div>

                        <button type="submit" class="btn-submit">
                            <i class="fa-solid fa-right-to-bracket"></i> Đăng nhập
                        </button>
                    </form>

                    <div class="separator">
                        <span>hoặc</span>
                    </div>

                    <a href="${pageContext.request.contextPath}/auth/google" class="btn-google">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="18" height="18">
                            <path fill="#4285F4"
                                d="M23.745 12.27c0-.7-.06-1.4-.19-2.07H12v3.92h6.69c-.29 1.5-1.14 2.78-2.4 3.62v3.02h3.87c2.26-2.08 3.58-5.15 3.58-8.49z" />
                            <path fill="#34A853"
                                d="M12 24c3.24 0 5.97-1.08 7.96-2.91l-3.87-3.02c-1.08.72-2.45 1.16-4.09 1.16-3.15 0-5.81-2.13-6.76-5.01H1.28v3.13C3.26 21.31 7.33 24 12 24z" />
                            <path fill="#FBBC05"
                                d="M5.24 14.22A7.16 7.16 0 0 1 4.8 12c0-.79.13-1.57.38-2.31V6.56H1.28A11.94 11.94 0 0 0 0 12c0 1.92.45 3.74 1.28 5.44l3.96-3.22z" />
                            <path fill="#EA4335"
                                d="M12 4.75c1.77 0 3.35.61 4.6 1.8l3.42-3.42C17.96 1.19 15.24 0 12 0 7.33 0 3.26 2.69 1.28 6.56l3.96 3.22c.95-2.88 3.61-5.03 6.76-5.03z" />
                        </svg>
                        Đăng nhập bằng Google
                    </a>

                    <div class="signup-prompt">
                        Chưa có tài khoản? <a href="#">Đăng ký ngay</a>
                    </div>

                    <a href="${pageContext.request.contextPath}/home" class="back-link">
                        <i class="fa-solid fa-arrow-left"></i>Quay lại trang chủ
                    </a>
                </div>
            </div>

            <script src="${pageContext.request.contextPath}/assets/js/login.js"></script>
        </body>

        </html>