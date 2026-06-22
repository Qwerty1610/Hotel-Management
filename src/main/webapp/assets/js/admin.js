// =================================================================
// ADMIN DASHBOARD LOGIC - CHANGE PASSWORD FUNCTIONALITY
// =================================================================

document.addEventListener('DOMContentLoaded', function () {
    console.log("Admin Dashboard initialized successfully.");
    
    // Bind change password form submit event
    const changePasswordForm = document.getElementById('changePasswordForm');
    if (changePasswordForm) {
        changePasswordForm.addEventListener('submit', function (e) {
            e.preventDefault();
            
            const currentPassword = document.getElementById('currentPassword').value;
            const newPassword = document.getElementById('newPassword').value;
            const confirmNewPassword = document.getElementById('confirmNewPassword').value;
            
            // 1. Kiểm tra tính hợp lệ dữ liệu ở Front-end (trùng khớp với trang Đăng ký)
            let errorMessage = '';
            
            if (!currentPassword || !newPassword || !confirmNewPassword) {
                errorMessage = 'Vui lòng điền đầy đủ các trường mật khẩu!';
            } else {
                const hasLetter = /[a-zA-Z]/.test(newPassword);
                const hasDigit = /[0-9]/.test(newPassword);
                const hasSpecial = /[^a-zA-Z0-9]/.test(newPassword);
                
                if (newPassword.length < 8) {
                    errorMessage = 'Mật khẩu mới phải tối thiểu từ 8 ký tự trở lên!';
                } else if (!hasLetter || !hasDigit || !hasSpecial) {
                    errorMessage = 'Mật khẩu mới phải bao gồm cả chữ, số và ký tự đặc biệt!';
                } else if (newPassword !== confirmNewPassword) {
                    errorMessage = 'Mật khẩu xác nhận không trùng khớp!';
                } else if (currentPassword === newPassword) {
                    errorMessage = 'Mật khẩu mới không được trùng với mật khẩu hiện tại!';
                }
            }
            
            if (errorMessage) {
                showModalAlert('error', errorMessage);
                return;
            }
            
            // 2. Gửi API bằng Fetch PUT dưới dạng JSON
            const submitBtn = document.getElementById('btnChangePasswordSubmit');
            const originalBtnContent = submitBtn.innerHTML;
            
            // Thiết lập trạng thái loading trên button
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang cập nhật...';
            hideModalAlert();
            
            // Tìm contextPath động dựa trên URL hiện tại
            const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/admin'));
            const apiUrl = contextPath + '/admin/change-password';
            
            fetch(apiUrl, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({
                    oldPassword: currentPassword,
                    newPassword: newPassword,
                    confirmPassword: confirmNewPassword
                })
            })
            .then(response => {
                return response.json().then(data => {
                    if (!response.ok) {
                        throw new Error(data.message || 'Lỗi hệ thống khi cập nhật mật khẩu.');
                    }
                    return data;
                });
            })
            .then(data => {
                showModalAlert('success', data.message || 'Đổi mật khẩu thành công!');
                changePasswordForm.reset();
                
                // Tự động đóng modal sau 2 giây
                setTimeout(() => {
                    closeChangePasswordModal();
                }, 2000);
            })
            .catch(error => {
                showModalAlert('error', error.message);
            })
            .finally(() => {
                submitBtn.disabled = false;
                submitBtn.innerHTML = originalBtnContent;
            });
        });
    }
});

/* Hiển thị / Ẩn Modal Đổi mật khẩu */
function openChangePasswordModal() {
    const modal = document.getElementById('changePasswordModal');
    if (modal) {
        modal.style.display = 'flex';
        hideModalAlert();
        const form = document.getElementById('changePasswordForm');
        if (form) form.reset();
        
        // Reset các trường mật khẩu về kiểu ẩn 'password'
        ['currentPassword', 'newPassword', 'confirmNewPassword'].forEach(id => {
            const el = document.getElementById(id);
            if (el) el.setAttribute('type', 'password');
        });
        document.querySelectorAll('#changePasswordModal .password-toggle-btn i').forEach(icon => {
            icon.className = 'fa-solid fa-eye-slash';
        });
    }
}

function closeChangePasswordModal() {
    const modal = document.getElementById('changePasswordModal');
    if (modal) {
        modal.style.display = 'none';
    }
}

/* Ẩn/Hiện mật khẩu trực tiếp */
function togglePasswordVisibility(inputId, btn) {
    const input = document.getElementById(inputId);
    if (!input) return;
    
    const icon = btn.querySelector('i');
    if (input.getAttribute('type') === 'password') {
        input.setAttribute('type', 'text');
        if (icon) icon.className = 'fa-solid fa-eye';
    } else {
        input.setAttribute('type', 'password');
        if (icon) icon.className = 'fa-solid fa-eye-slash';
    }
}

/* Quản lý hộp thông báo alert bên trong Modal */
function showModalAlert(type, message) {
    const alertBox = document.getElementById('changePasswordAlert');
    const alertText = document.getElementById('changePasswordAlertText');
    if (!alertBox || !alertText) return;
    
    alertBox.className = 'alert-toast-inline ' + (type === 'success' ? 'success-alert' : 'error-alert');
    
    const icon = alertBox.querySelector('i');
    if (icon) {
        icon.className = type === 'success' ? 'fa-solid fa-circle-check' : 'fa-solid fa-triangle-exclamation';
    }
    
    alertText.innerText = message;
    alertBox.style.display = 'flex';
}

function hideModalAlert() {
    const alertBox = document.getElementById('changePasswordAlert');
    if (alertBox) {
        alertBox.style.display = 'none';
    }
}
