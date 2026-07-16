// =================================================================
// 1. HIỆU ỨNG NAVBAR: ĐỔI MÀU NỀN & ACTIVE MENU
// =================================================================
window.addEventListener('scroll', function () {
    const navbar = document.querySelector('.navbar');
    const sections = document.querySelectorAll('section[id], header[id], footer[id]');
    const navLinks = document.querySelectorAll('.nav-links li a');

    if (window.scrollY > 50) {
        navbar.classList.add('scrolled');
    } else {
        navbar.classList.remove('scrolled');
    }

    let currentSectionId = '';
    sections.forEach(section => {
        const sectionTop = section.offsetTop - 120;
        const sectionHeight = section.offsetHeight;

        if (window.scrollY >= sectionTop && window.scrollY < sectionTop + sectionHeight) {
            currentSectionId = section.getAttribute('id');
        }
    });

    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href') === `#${currentSectionId}`) {
            link.classList.add('active');
        }
    });
});

// =================================================================
// 2. XỬ LÝ BẮT ĐƯỜNG DẪN VÀO TRANG CHỦ (LOẠI TRỪ NAV TRANG CHỦ TẠI CHỖ)
// =================================================================
document.addEventListener('DOMContentLoaded', function () {
    const loader = document.getElementById('page-loader');

    // Bắt tất cả các phần tử click (Thẻ a, Nút bấm, Logo) dẫn đến trang chủ
    document.body.addEventListener('click', function (e) {
        const anchor = e.target.closest('a');

        if (anchor) {
            const href = anchor.getAttribute('href');

            // TRƯỜNG HỢP 1: Nhấn nút "Trang chủ" (#trang-chu) khi đang ở sẵn trên trang chủ
            if (href === '#trang-chu') {
                e.preventDefault(); // Chặn hành vi mặc định để không nhảy link đột ngột

                // Chỉ cuộn mượt lên đầu trang mà KHÔNG hiển thị loader
                window.scrollTo({
                    top: 0,
                    behavior: 'smooth'
                });
                return; // Thoát hàm luôn, chặn hoàn toàn logic bật loader phía dưới
            }

            // TRƯỜNG HỢP 2: Kích hoạt loader cho các đường dẫn chuyển hướng từ trang khác về trang chủ
            if (href === '/' || href === '/home' || href.endsWith('/home.jsp') || href === '') {
                if (loader) {
                    loader.classList.remove('fade-out');
                }
            }

            // Đối với các section nội bộ khác (Giới thiệu #gioi-thieu, Phòng #phong-gia...), giữ nguyên cuộn mượt
            if (href && href.startsWith('#') && href !== '#trang-chu') {
                e.preventDefault();
                const targetElement = document.querySelector(href);
                if (targetElement) {
                    const offsetPosition = targetElement.offsetTop - 80;
                    window.scrollTo({
                        top: offsetPosition,
                        behavior: 'smooth'
                    });
                }
            }
        }
    });

    // Bắt sự kiện khi người dùng Submit bất kỳ Form nào điều hướng về trang chủ
    document.addEventListener('submit', function (e) {
        const action = e.target.getAttribute('action');
        if (action === '/' || action === '/home' || action.endsWith('/home.jsp')) {
            if (loader) {
                loader.classList.remove('fade-out');
            }
        }
    });
});

// =================================================================
// 3. ĐÓN ĐẦU MŨI TÊN BACK/FORWARD & ẨN LOADER KHI TẢI XONG
// =================================================================
window.addEventListener('pageshow', function (event) {
    const loader = document.getElementById('page-loader');

    // Nếu trang được lật lại từ bộ nhớ đệm (nhấn nút mũi tên quay lại của trình duyệt)
    if (event.persisted) {
        if (loader) {
            loader.classList.remove('fade-out'); // Kích hoạt hiển thị lại loader ngay lập tức
        }
    }

    // Đặt thời gian chờ ngắn 600ms để vòng xoay Neon hiển thị đẹp mắt rồi ẩn đi mượt mà
    if (loader) {
        setTimeout(function () {
            loader.classList.add('fade-out');
        }, 600);
    }
});