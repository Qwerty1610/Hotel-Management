<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%--
    Modal đổi mật khẩu tài khoản Admin.
    @author TùngNQ
--%>
<!-- MODAL ĐỔI MẬT KHẨU ADMIN -->
<script>
    window.MSG_CHANGE_PASSWORD = {
        emptyFields: 'Vui lòng điền đầy đủ các trường mật khẩu!',
        passwordShort: 'Mật khẩu mới phải tối thiểu từ 8 ký tự trở lên!',
        passwordWeak: 'Mật khẩu mới phải bao gồm cả chữ, số và ký tự đặc biệt!',
        passwordMismatch: 'Mật khẩu xác nhận không trùng khớp!',
        passwordSameAsCurrent: 'Mật khẩu mới không được trùng với mật khẩu hiện tại!',
        updating: '<i class="fa-solid fa-spinner fa-spin"></i> Đang cập nhật...',
        systemError: 'Lỗi hệ thống khi cập nhật mật khẩu.',
        success: 'Đổi mật khẩu thành công!'
    };
</script>
<div id="changePasswordModal" class="modal-overlay" style="display: none;">
    <div class="modal-container" style="max-width: 440px;">
        <div class="modal-header">
            <h3><i class="fa-solid fa-key" style="color: var(--brand-blue);"></i> Đổi mật khẩu tài khoản</h3>
            <button type="button" class="btn-close-modal" onclick="closeChangePasswordModal()">&times;</button>
        </div>
        <form id="changePasswordForm" novalidate>
            <div class="modal-body">
                <!-- Hộp thông báo phản hồi (Error/Success Alert) -->
                <div id="changePasswordAlert" class="alert-toast-inline" style="display: none;">
                    <i class="fa-solid"></i>
                    <span id="changePasswordAlertText"></span>
                </div>
                
                <!-- Trường Mật khẩu cũ -->
                <div class="modal-form-group">
                    <label for="currentPassword">Mật khẩu hiện tại <span style="color:#ef4444;">*</span></label>
                    <div class="password-input-wrapper">
                        <input type="password" id="currentPassword" class="modal-input"
                               placeholder="Nhập mật khẩu hiện tại..." required />
                        <button type="button" class="password-toggle-btn" onclick="togglePasswordVisibility('currentPassword', this)">
                            <i class="fa-solid fa-eye-slash"></i>
                        </button>
                    </div>
                </div>

                <!-- Trường Mật khẩu mới -->
                <div class="modal-form-group">
                    <label for="newPassword">Mật khẩu mới <span style="color:#ef4444;">*</span></label>
                    <div class="password-input-wrapper">
                        <input type="password" id="newPassword" class="modal-input"
                               placeholder="Tối thiểu 8 ký tự (chữ, số, ký tự đặc biệt)" required />
                        <button type="button" class="password-toggle-btn" onclick="togglePasswordVisibility('newPassword', this)">
                            <i class="fa-solid fa-eye-slash"></i>
                        </button>
                    </div>
                    <small class="password-strength-hint">
                        <i class="fa-solid fa-circle-info"></i> Mật khẩu mới phải bao gồm cả chữ, số và ký tự đặc biệt!
                    </small>
                </div>

                <!-- Trường Xác nhận mật khẩu mới -->
                <div class="modal-form-group">
                    <label for="confirmNewPassword">Xác nhận mật khẩu mới <span style="color:#ef4444;">*</span></label>
                    <div class="password-input-wrapper">
                        <input type="password" id="confirmNewPassword" class="modal-input"
                               placeholder="Nhập lại mật khẩu mới..." required />
                        <button type="button" class="password-toggle-btn" onclick="togglePasswordVisibility('confirmNewPassword', this)">
                            <i class="fa-solid fa-eye-slash"></i>
                        </button>
                    </div>
                </div>
                
                <!-- Footer buttons -->
                <div class="modal-footer-row" style="margin-top: 24px;">
                    <button type="button" class="btn-modal-cancel" onclick="closeChangePasswordModal()">Hủy bỏ</button>
                    <button type="submit" id="btnChangePasswordSubmit" class="btn-modal-submit">
                        <i class="fa-solid fa-check"></i> Xác nhận đổi
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>
