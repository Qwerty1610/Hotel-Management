// =================================================================
// 1. HIỆU ỨNG NAVBAR: ĐỔI MÀU NỀN & ACTIVE MENU
// =================================================================

window.addEventListener('scroll', function () {

    const navbar = document.querySelector('.navbar');

    const sections = document.querySelectorAll(
        'section[id], header[id], footer[id]'
    );

    const navLinks = document.querySelectorAll('.nav-links li a');

    // Navbar đổi màu khi cuộn
    if (window.scrollY > 50) {

        navbar.classList.add('scrolled');

    } else {

        navbar.classList.remove('scrolled');
    }

    // Active menu theo section
    let currentSectionId = '';

    sections.forEach(section => {

        const sectionTop = section.offsetTop - 120;
        const sectionHeight = section.offsetHeight;

        if (
            window.scrollY >= sectionTop &&
            window.scrollY < sectionTop + sectionHeight
        ) {
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
// 2. SMOOTH SCROLL
// =================================================================

document.addEventListener('DOMContentLoaded', function () {

    const navLinks = document.querySelectorAll('.nav-links li a');

    navLinks.forEach(link => {

        link.addEventListener('click', function (e) {

            const targetId = this.getAttribute('href');

            if (targetId && targetId.startsWith('#')) {

                e.preventDefault();

                const targetElement = document.querySelector(targetId);

                if (targetElement) {

                    const offsetPosition =
                        targetElement.offsetTop - 80;

                    window.scrollTo({
                        top: offsetPosition,
                        behavior: 'smooth'
                    });
                }
            }
        });
    });
});
