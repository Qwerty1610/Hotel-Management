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