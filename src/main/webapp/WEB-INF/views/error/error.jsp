<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../../includes/taglibs.jsp" %>
<%@ include file="../../includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/rooms.css?v=20" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css" />

<style>
    .error-section {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        padding: 80px 20px;
        min-height: calc(100vh - 80px - 320px);
        background-color: var(--bg-light);
        text-align: center;
    }

    .error-container {
        max-width: 650px;
        width: 100%;
        margin: 0 auto;
        background: var(--white);
        padding: 50px 40px;
        border-radius: 20px;
        box-shadow: var(--shadow-md);
        border: 1px solid var(--border-color);
        transition: var(--transition);
    }

    .error-container:hover {
        box-shadow: var(--shadow-lg);
    }

    .error-image-wrapper {
        max-width: 320px;
        margin: 0 auto 35px auto;
        display: flex;
        justify-content: center;
    }

    .error-image-wrapper img {
        width: 100%;
        height: auto;
        border-radius: 12px;
        box-shadow: var(--shadow-sm);
    }

    .error-container h1 {
        font-size: 2.2rem;
        color: var(--primary-color);
        margin-bottom: 15px;
        font-weight: 700;
        letter-spacing: -0.5px;
    }

    .error-container p {
        color: var(--text-light);
        font-size: 1.05rem;
        line-height: 1.6;
        margin-bottom: 40px;
    }

    .error-actions {
        display: flex;
        gap: 15px;
        justify-content: center;
        flex-wrap: wrap;
    }

    .btn-action {
        display: inline-flex;
        align-items: center;
        gap: 10px;
        padding: 14px 28px;
        border-radius: 50px;
        font-weight: 600;
        font-size: 0.95rem;
        transition: var(--transition);
        cursor: pointer;
        border: none;
    }

    .btn-home {
        background-color: var(--accent-color);
        color: var(--white);
        box-shadow: 0 4px 15px rgba(58, 134, 255, 0.3);
    }

    .btn-home:hover {
        background-color: #2563eb;
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(58, 134, 255, 0.4);
    }

    .btn-back {
        background-color: var(--white);
        color: var(--primary-color);
        border: 1px solid var(--border-color);
        box-shadow: var(--shadow-sm);
    }

    .btn-back:hover {
        background-color: var(--bg-light);
        transform: translateY(-2px);
    }
</style>

<body>

    <!-- Header Navigation (White Background Premium Style) -->
    <nav class="navbar-rooms">
        <a href="${pageContext.request.contextPath}/" class="logo">HotelOps</a>
        <ul class="nav-links">
            <li><a href="${pageContext.request.contextPath}/"><fmt:message key="nav.home" /></a></li>
            <li><a href="${pageContext.request.contextPath}/#gioi-thieu"><fmt:message key="nav.about" /></a></li>
            <li><a href="${pageContext.request.contextPath}/rooms"><fmt:message key="nav.rooms" /></a></li>
            <li><a href="${pageContext.request.contextPath}/#dich-vu"><fmt:message key="nav.services" /></a></li>
            <li><a href="${pageContext.request.contextPath}/#lien-he"><fmt:message key="nav.contact" /></a></li>
        </ul>
        <!-- Placeholder to keep the menu links centered in flex space-between -->
        <div class="nav-actions" style="width: 120px;"></div>
    </nav>

    <!-- Error Content Section -->
    <section class="error-section">
        <div class="error-container">
            <div class="error-image-wrapper">
                <c:choose>
                    <c:when test="${errorCode eq 403}">
                        <img src="${pageContext.request.contextPath}/assets/images/error-403.png" alt="Bellhop Lạc Lối 403" />
                    </c:when>
                    <c:otherwise>
                        <img src="${pageContext.request.contextPath}/assets/images/error-404.png" alt="Bellhop Lạc Lối 404" />
                    </c:otherwise>
                </c:choose>
            </div>
            
            <c:choose>
                <c:when test="${errorCode eq 403}">
                    <h1><fmt:message key="error.title.403" /></h1>
                    <p><fmt:message key="error.desc.403" /></p>
                </c:when>
                <c:otherwise>
                    <h1><fmt:message key="error.title.404" /></h1>
                    <p><fmt:message key="error.desc.404" /></p>
                </c:otherwise>
            </c:choose>
            
            <div class="error-actions">
                <a href="${pageContext.request.contextPath}/" class="btn-action btn-home">
                    <i class="fa-solid fa-house"></i> <fmt:message key="error.btn.home" />
                </a>
                <button onclick="window.history.back()" class="btn-action btn-back">
                    <i class="fa-solid fa-arrow-left"></i> <fmt:message key="error.btn.back" />
                </button>
            </div>
        </div>
    </section>

    <!-- Include Footer -->
    <%@ include file="../../includes/footer.jsp" %>
