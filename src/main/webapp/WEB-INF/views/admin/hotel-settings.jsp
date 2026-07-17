<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=3" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=5" />

<style>
    .settings-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 30px;
        margin-top: 20px;
    }

    @media (max-width: 992px) {
        .settings-grid {
            grid-template-columns: 1fr;
        }
    }

    .settings-card {
        background: var(--white);
        padding: 30px;
        border-radius: 16px;
        box-shadow: var(--shadow-sm);
        border: 1px solid var(--border-color);
        transition: var(--transition);
    }

    .settings-card:hover {
        box-shadow: var(--shadow-md);
    }

    .settings-card-title {
        font-size: 1.25rem;
        font-weight: 700;
        color: var(--text-navy);
        margin-bottom: 20px;
        display: flex;
        align-items: center;
        gap: 10px;
        border-bottom: 2px solid var(--bg-light);
        padding-bottom: 12px;
    }

    .settings-card-title i {
        color: var(--brand-blue);
    }

    .form-group-settings {
        margin-bottom: 20px;
    }

    .form-group-settings label {
        display: block;
        font-weight: 600;
        font-size: 0.9rem;
        color: #475569;
        margin-bottom: 8px;
    }

    .form-group-settings input {
        width: 100%;
        padding: 12px 16px;
        border-radius: 8px;
        border: 1px solid var(--border-color);
        font-size: 0.95rem;
        transition: var(--transition);
        background-color: var(--bg-light);
        color: var(--text-navy);
    }

    .form-group-settings input:focus {
        border-color: var(--brand-blue);
        background-color: var(--white);
        outline: none;
        box-shadow: 0 0 0 4px rgba(58, 134, 255, 0.1);
    }

    .settings-footer {
        display: flex;
        justify-content: flex-end;
        margin-top: 30px;
        padding-top: 20px;
        border-top: 1px solid var(--border-color);
    }

    .btn-save-settings {
        background-color: var(--brand-blue);
        color: var(--white);
        padding: 14px 35px;
        border-radius: 8px;
        font-weight: 600;
        border: none;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 10px;
        transition: var(--transition);
        box-shadow: 0 4px 15px rgba(58, 134, 255, 0.2);
    }

    .btn-save-settings:hover {
        background-color: #2563eb;
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(58, 134, 255, 0.3);
    }

    .alert-settings {
        padding: 15px 20px;
        border-radius: 8px;
        margin-bottom: 25px;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .alert-success-settings {
        background-color: #dcfce7;
        color: #15803d;
        border: 1px solid #bbf7d0;
    }

    .alert-error-settings {
        background-color: #fee2e2;
        color: #b91c1c;
        border: 1px solid #fecaca;
    }
</style>

<body class="dashboard-body">

    <div class="dashboard-layout">

        <!-- SIDEBAR -->
        <c:set var="activePage" value="hotel-settings" scope="request" />
        <jsp:include page="includes/sidebar.jsp" />

        <!-- MAIN DASHBOARD CONTENT -->
        <div class="dashboard-main">

            <!-- TOP HEADER BAR -->
            <header class="main-topbar">
                <div class="breadcrumb">
                    <span>Quản trị viên</span>
                    <span class="separator">&gt;</span>
                    <span class="current">Thông tin khách sạn</span>
                </div>

                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </a>
            </header>

            <!-- SETTINGS WORKSPACE -->
            <main class="workspace-content">

                <div class="content-header-row">
                    <div>
                        <h1>Cấu hình thông tin khách sạn & trang chủ</h1>
                    </div>
                </div>

                <!-- ALERTS -->
                <c:if test="${not empty success}">
                    <div class="alert-settings alert-success-settings">
                        <i class="fa-solid fa-circle-check"></i> <span>${success}</span>
                    </div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert-settings alert-error-settings">
                        <i class="fa-solid fa-circle-exclamation"></i> <span>${error}</span>
                    </div>
                </c:if>

                <form method="post" action="${pageContext.request.contextPath}/admin/hotel-settings">
                    <div class="settings-grid">
                        
                        <!-- HOTEL & WEBSITE INFORMATION CONFIGURATION CARD -->
                        <div class="settings-card" style="grid-column: span 2;">
                            <h2 class="settings-card-title">
                                <i class="fa-solid fa-hotel"></i> Thông tin Khách sạn & Nội dung trang chủ
                            </h2>
                            
                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                                <div>
                                    <div class="form-group-settings">
                                        <label for="hotelName">Tên khách sạn</label>
                                        <input type="text" id="hotelName" name="hotelName" 
                                               value="${configs['hotel.name']}" required />
                                    </div>
                                    <div class="form-group-settings">
                                        <label for="hotelPhone">Số điện thoại liên hệ</label>
                                        <input type="text" id="hotelPhone" name="hotelPhone" 
                                               value="${configs['hotel.phone']}" required />
                                    </div>
                                    <div class="form-group-settings">
                                        <label for="hotelEmail">Email liên hệ</label>
                                        <input type="email" id="hotelEmail" name="hotelEmail" 
                                               value="${configs['hotel.email']}" required />
                                    </div>
                                    <div class="form-group-settings">
                                        <label for="hotelAddress">Địa chỉ khách sạn</label>
                                        <input type="text" id="hotelAddress" name="hotelAddress" 
                                               value="${configs['hotel.address']}" required />
                                    </div>
                                    <div class="form-group-settings">
                                        <label for="hotelIntro">Giới thiệu ngắn (Chân trang/Footer)</label>
                                        <textarea id="hotelIntro" name="hotelIntro" required style="width: 100%; padding: 12px 16px; border-radius: 8px; border: 1px solid var(--border-color); font-size: 0.95rem; background-color: var(--bg-light); color: var(--text-navy); height: 90px; resize: vertical; font-family: inherit;">${configs['hotel.intro']}</textarea>
                                    </div>
                                </div>
                                <div>
                                    <div class="form-group-settings">
                                        <label for="hotelHeroTitle">Tiêu đề biểu ngữ (Hero Title)</label>
                                        <input type="text" id="hotelHeroTitle" name="hotelHeroTitle" 
                                               value="${configs['hotel.hero.title']}" required />
                                    </div>
                                    <div class="form-group-settings">
                                        <label for="hotelHeroSubtitle">Phụ đề biểu ngữ (Hero Subtitle)</label>
                                        <input type="text" id="hotelHeroSubtitle" name="hotelHeroSubtitle" 
                                               value="${configs['hotel.hero.subtitle']}" required />
                                    </div>
                                    <div class="form-group-settings">
                                        <label for="hotelAboutTag">Thẻ tiêu đề Giới thiệu (About Tagline)</label>
                                        <input type="text" id="hotelAboutTag" name="hotelAboutTag" 
                                               value="${configs['hotel.about.tag']}" required />
                                    </div>
                                    <div class="form-group-settings">
                                        <label for="hotelAboutTitle">Tiêu đề phần Giới thiệu (About Title)</label>
                                        <input type="text" id="hotelAboutTitle" name="hotelAboutTitle" 
                                               value="${configs['hotel.about.title']}" required />
                                    </div>
                                    <div class="form-group-settings">
                                        <label for="hotelAboutDesc">Nội dung phần Giới thiệu (About Description)</label>
                                        <textarea id="hotelAboutDesc" name="hotelAboutDesc" required style="width: 100%; padding: 12px 16px; border-radius: 8px; border: 1px solid var(--border-color); font-size: 0.95rem; background-color: var(--bg-light); color: var(--text-navy); height: 90px; resize: vertical; font-family: inherit;">${configs['hotel.about.desc']}</textarea>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>

                    <div class="settings-footer">
                        <button type="submit" class="btn-save-settings">
                            <i class="fa-solid fa-floppy-disk"></i> Lưu thông tin khách sạn
                        </button>
                    </div>
                </form>

            </main>

        </div>

    </div>

</body>
