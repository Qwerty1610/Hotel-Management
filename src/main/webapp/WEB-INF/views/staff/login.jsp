<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ include file="../../includes/taglibs.jsp" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Cổng nhân sự - HotelOps Pro</title>

            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
                rel="stylesheet" />
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/login.css?v=3" />
        </head>

        <body class="login-body" style="background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);">

            <div class="login-container">
                <div class="login-card" style="box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.3);">
                    <div class="logo"><i class="fa-solid fa-hotel" style="color: #3a86ff;"></i>Hotel<span>Ops</span> <small style="font-size: 11px; font-weight: 700; letter-spacing: 1px; color: #3a86ff; text-transform: uppercase; display: block; margin-top: 4px;">Staff Portal</small></div>
                    <div class="subtitle">Đăng nhập cổng thông tin nội bộ dành cho nhân viên</div>

                    <c:if test="${not empty param.error}">
                        <div class="error-alert">
                            <i class="fa-solid fa-triangle-exclamation"></i>
                            <span>
                                <c:choose>
                                    <c:when test="${param.error eq 'invalid_credentials'}">
                                        Tên đăng nhập hoặc mật khẩu không chính xác!
                                    </c:when>
                                    <c:when test="${param.error eq 'unauthorized'}">
                                        Bạn cần đăng nhập bằng tài khoản nhân viên để tiếp tục.
                                    </c:when>
                                    <c:when test="${param.error eq 'not_staff'}">
                                        Tài khoản khách hàng không được truy cập cổng nhân sự!
                                    </c:when>
                                    <c:otherwise>
                                        Lỗi hệ thống khi đăng nhập. Vui lòng thử lại.
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/staff/login" method="POST" id="loginForm">
                        <div class="form-group">
                            <label for="username">Tài khoản Email nhân viên</label>
                            <div class="input-wrapper">
                                <input type="text" id="username" name="username" class="form-input"
                                    placeholder="email@hotel.com" required autofocus />
                                <i class="fa-solid fa-envelope"></i>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="password">Mật khẩu</label>
                            <div class="input-wrapper">
                                <input type="password" id="password" name="password" class="form-input form-input-password" style="padding-right: 48px !important;"
                                    placeholder="Nhập mật khẩu nội bộ" required />
                                <i class="fa-solid fa-lock"></i>
                                <i class="fa-regular fa-eye-slash toggle-password" id="togglePasswordBtn" style="position: absolute !important; right: 18px !important; left: auto !important; top: 50% !important; transform: translateY(-50%) !important; cursor: pointer !important; z-index: 10 !important; color: var(--text-light) !important;"></i>
                            </div>
                        </div>

                        <div class="form-options">
                            <label class="remember-me">
                                <input type="checkbox" name="remember" /> Ghi nhớ đăng nhập
                            </label>
                            <a href="${pageContext.request.contextPath}/home/forgot-password?portal=staff"
                                class="forgot-password">Quên mật khẩu?</a>
                        </div>

                        <button type="submit" class="btn-submit" style="background: #3a86ff;">
                            <i class="fa-solid fa-right-to-bracket"></i> Đăng nhập hệ thống
                        </button>
                    </form>

                    <div style="margin-top: 24px; border-top: 1px solid #f1f5f9; padding-top: 20px;">
                        <a href="${pageContext.request.contextPath}/home" class="back-link" style="margin-top: 0;">
                            <i class="fa-solid fa-arrow-left"></i>Quay lại trang chủ
                        </a>
                    </div>
                </div>
            </div>

            <script src="${pageContext.request.contextPath}/assets/js/login.js?v=2" charset="UTF-8"></script>
        </body>

        </html>
