<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="lang" value='<%= com.mycompany.hotelmanagement.config.ConfigUtil.get("web.language", "vi") %>' scope="request" />
<fmt:setLocale value="${lang eq 'en' ? 'en' : 'vi'}" scope="request" />
<fmt:setBundle basename="messages" scope="request" />
<!DOCTYPE html>
<html lang="${lang}">
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>HotelOps - Gửi gắm sự an tâm trên mỗi chuyến đi</title>

        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css" />
    </head>
