<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
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
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/login.css?v=3" />
        </head>

        <body class="login-body">

            <div class="login-container">
                <c:choose>
                    <c:when test="${not empty sessionScope.user and sessionScope.role eq 'CUSTOMER'}">
                        <div class="login-card" style="text-align: center;">
                            <div class="logo"><i class="fa-solid fa-hotel"></i>Hotel<span>Ops</span></div>
                            <div class="subtitle" style="margin-bottom: 20px;">Chào mừng quay trở lại!</div>
                            
                            <div style="background: rgba(15, 23, 42, 0.03); border: 1px solid rgba(15, 23, 42, 0.08); padding: 20px; border-radius: 16px; margin-bottom: 24px; text-align: center;">
                                <div style="width: 64px; height: 64px; background: #c29a30; color: #fff; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 24px; font-weight: 700; margin: 0 auto 12px;">
                                    ${sessionScope.user.substring(0, 1).toUpperCase()}
                                </div>
                                <h3 style="margin: 0; font-size: 18px; color: #0b132b;">${sessionScope.user}</h3>
                                <p style="margin: 4px 0 0; font-size: 13.5px; color: #6c757d;">Tài khoản Khách hàng</p>
                            </div>

                            <div style="display: flex; flex-direction: column; gap: 12px; margin-bottom: 20px;">
                                <a href="${pageContext.request.contextPath}/home" class="btn-submit" style="text-decoration: none; display: flex; align-items: center; justify-content: center; gap: 8px;">
                                    <i class="fa-solid fa-house"></i> Đi tới Trang chủ
                                </a>
                                <a href="${pageContext.request.contextPath}/customer/bookings" class="btn-submit" style="background: #0f172a; text-decoration: none; display: flex; align-items: center; justify-content: center; gap: 8px;">
                                    <i class="fa-solid fa-calendar-days"></i> Lịch sử đặt phòng
                                </a>
                            </div>

                            <a href="${pageContext.request.contextPath}/logout" class="back-link" style="color: #ef4444; font-weight: 600; text-decoration: none;">
                                <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất tài khoản
                            </a>
                        </div>
                    </c:when>
                    <c:otherwise>
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
                                            <c:when test="${param.error eq 'not_customer'}">
                                                Tài khoản nhân sự không được phép đăng nhập cổng này!
                                            </c:when>
                                            <c:otherwise>
                                                Lỗi hệ thống. Vui lòng thử lại.
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                            </c:if>

                            <c:if test="${not empty param.success}">
                                <div class="success-alert"
                                    style="background: rgba(16, 185, 129, 0.08); border: 1px solid rgba(16, 185, 129, 0.15); color: #10b981; padding: 12px 16px; border-radius: 12px; font-size: 13.5px; font-weight: 600; margin-bottom: 24px; display: flex; align-items: center; gap: 10px; text-align: left;">
                                    <i class="fa-solid fa-circle-check"></i>
                                    <span>
                                        <c:choose>
                                            <c:when test="${param.success eq 'registered'}">
                                                Đăng ký tài khoản thành công! Vui lòng đăng nhập.
                                            </c:when>
                                            <c:when test="${param.success eq 'password_reset'}">
                                                Đặt lại mật khẩu thành công! Hãy đăng nhập bằng mật khẩu mới.
                                            </c:when>
                                            <c:otherwise>
                                                Thực hiện thành công.
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
                                        <input type="password" id="password" name="password" class="form-input form-input-password" style="padding-right: 48px !important;"
                                            placeholder="Nhập mật khẩu" required />
                                        <i class="fa-solid fa-lock"></i>
                                        <i class="fa-regular fa-eye-slash toggle-password" id="togglePasswordBtn" style="position: absolute !important; right: 18px !important; left: auto !important; top: 50% !important; transform: translateY(-50%) !important; cursor: pointer !important; z-index: 10 !important; color: var(--text-light) !important;"></i>
                                    </div>
                                </div>

                                <div class="form-options">
                                    <label class="remember-me">
                                        <input type="checkbox" name="remember" /> Ghi nhớ đăng nhập
                                    </label>
                                    <a href="${pageContext.request.contextPath}/home/forgot-password"
                                        class="forgot-password">Quên mật khẩu?</a>
                                </div>

                                <button type="submit" class="btn-submit">
                                    <i class="fa-solid fa-right-to-bracket"></i> Đăng nhập
                                </button>
                            </form>

                            <div class="separator">
                                <span>hoặc</span>
                            </div>

                            <a href="https://accounts.google.com/o/oauth2/v2/auth?client_id=${googleClientId}&redirect_uri=http://localhost:8080/HotelManagement/login-google&response_type=code&scope=email%20profile"
                                class="btn-google">
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
                                Chưa có tài khoản? <a href="${pageContext.request.contextPath}/home/register">Đăng ký ngay</a>
                            </div>


                            <a href="${pageContext.request.contextPath}/home" class="back-link">
                                <i class="fa-solid fa-arrow-left"></i>Quay lại trang chủ
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <script src="${pageContext.request.contextPath}/assets/js/login.js?v=2" charset="UTF-8"></script>
        </body>

        </html>