// =================================================================
// RECEPTIONIST DASHBOARD LOGIC
// =================================================================

// =================================================================
//                          ITERATION 1
// =================================================================

document.addEventListener('DOMContentLoaded', function () {

    // ---- Tự đóng toast sau 4 giây ----
    const toast = document.querySelector('.toast-notify');
    if (toast) {
        setTimeout(() => {
            toast.style.opacity = '0';
            toast.style.transition = 'opacity .4s';
            setTimeout(() => toast.remove(), 400);
        }, 4000);
    }

    // ---- Đóng modal khi click overlay ----
    document.querySelectorAll('.modal-overlay').forEach(overlay => {
        overlay.addEventListener('click', function (e) {
            if (e.target === overlay) closeAllModals();
        });
    });

    // ---- Phím ESC đóng modal ----
    document.addEventListener('keydown', e => {
        if (e.key === 'Escape') closeAllModals();
    });

    // ---- Event Delegation cho các nút thao tác ----
    document.addEventListener('click', function (e) {
        // Chi tiết booking
        const btnDetail = e.target.closest('.btn-view-detail');
        if (btnDetail) {
            const id = btnDetail.getAttribute('data-id');
            const customer = btnDetail.getAttribute('data-customer-name');
            const roomtype = btnDetail.getAttribute('data-room-type-name');
            const qty = btnDetail.getAttribute('data-room-quantity');
            const checkin = btnDetail.getAttribute('data-check-in-date');
            const checkout = btnDetail.getAttribute('data-check-out-date');
            const amount = btnDetail.getAttribute('data-total-amount');
            const status = btnDetail.getAttribute('data-status');
            const note = btnDetail.getAttribute('data-note');

            openDetailModal(id, customer, roomtype, qty, checkin, checkout, amount, status, note);
            return;
        }

        // Xác nhận booking
        const btnConfirm = e.target.closest('.btn-open-confirm');
        if (btnConfirm) {
            const id = btnConfirm.getAttribute('data-id');
            const customer = btnConfirm.getAttribute('data-customer-name');
            openConfirmModal(id, customer);
            return;
        }

        // Từ chối booking
        const btnReject = e.target.closest('.btn-open-reject');
        if (btnReject) {
            const id = btnReject.getAttribute('data-id');
            const customer = btnReject.getAttribute('data-customer-name');
            openRejectModal(id, customer);
            return;
        }

        // Chỉnh sửa booking
        const btnEdit = e.target.closest('.btn-open-edit');
        if (btnEdit) {
            const id = btnEdit.getAttribute('data-id');
            const customer = btnEdit.getAttribute('data-customer-name');
            const roomtypeId = btnEdit.getAttribute('data-room-type-id');
            const qty = btnEdit.getAttribute('data-room-quantity');
            const checkin = btnEdit.getAttribute('data-check-in-date');
            const checkout = btnEdit.getAttribute('data-check-out-date');
            const amount = btnEdit.getAttribute('data-total-amount');
            const note = btnEdit.getAttribute('data-note');

            openEditModal(id, customer, roomtypeId, qty, checkin, checkout, amount, note);
            return;
        }

        // Huỷ booking
        const btnCancel = e.target.closest('.btn-open-cancel');
        if (btnCancel) {
            const id = btnCancel.getAttribute('data-id');
            const customer = btnCancel.getAttribute('data-customer-name');
            openCancelModal(id, customer);
            return;
        }
    });

    // ---- Client-side Validation & Double Submit Prevention cho Edit Form ----
    const formEdit = document.querySelector('#modalEdit form');
    if (formEdit) {
        formEdit.addEventListener('submit', function (e) {
            clearValidationErrors('modalEdit');

            const customerNameInput = document.getElementById('editCustomerName');
            const customerName = customerNameInput.value.trim();
            const checkIn = document.getElementById('editCheckIn').value;
            const checkOut = document.getElementById('editCheckOut').value;
            const qtyInput = document.getElementById('editRoomQuantity');
            const qty = parseInt(qtyInput.value) || 0;
            const amountInput = document.getElementById('editTotalAmount');
            const amount = parseFloat(amountInput.value) || 0;

            let hasError = false;

            if (!customerName) {
                showInputError('editCustomerName', 'Customer name cannot be empty.');
                hasError = true;
            } else if (customerName.length > 100) {
                showInputError('editCustomerName', 'Customer name cannot exceed 100 characters.');
                hasError = true;
            }

            if (!checkIn) {
                showInputError('editCheckIn', 'Check-in date is required.');
                hasError = true;
            }

            if (!checkOut) {
                showInputError('editCheckOut', 'Check-out date is required.');
                hasError = true;
            }

            if (checkIn && checkOut) {
                const checkInDate = new Date(checkIn);
                const checkOutDate = new Date(checkOut);
                
                // Tránh lỗi múi giờ khi so sánh ngày
                const today = new Date();
                today.setHours(0, 0, 0, 0);
                checkInDate.setHours(0, 0, 0, 0);
                checkOutDate.setHours(0, 0, 0, 0);

                if (checkInDate >= checkOutDate) {
                    showInputError('editCheckOut', 'Check-out date must be after check-in date.');
                    hasError = true;
                }
                if (checkInDate < today) {
                    showInputError('editCheckIn', 'Check-in date cannot be in the past.');
                    hasError = true;
                }
            }

            if (qty <= 0 || qty > 100) {
                showInputError('editRoomQuantity', 'Room quantity must be between 1 and 100.');
                hasError = true;
            }

            if (amount < 0) {
                showInputError('editTotalAmount', 'Total amount cannot be negative.');
                hasError = true;
            }

            if (hasError) {
                e.preventDefault();
                return;
            }

            // Disable nút submit đề phòng double submit
            const submitBtn = formEdit.querySelector('button[type="submit"]');
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Saving...';
            }
        });
    }

    // ---- Double Submit Prevention cho Confirm Form ----
    const formConfirm = document.getElementById('formConfirm');
    if (formConfirm) {
        formConfirm.addEventListener('submit', function () {
            const submitBtn = formConfirm.querySelector('button[type="submit"]');
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Confirming...';
            }
        });
    }

    // ---- Double Submit Prevention cho Cancel Form ----
    const formCancel = document.querySelector('#modalCancel form');
    if (formCancel) {
        formCancel.addEventListener('submit', function () {
            const submitBtn = formCancel.querySelector('button[type="submit"]');
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Cancelling...';
            }
        });
    }
});

/* ------------------------------------------------------------------ */
/*  Helpers                                                             */
/* ------------------------------------------------------------------ */

function closeAllModals() {
    document.querySelectorAll('.modal-overlay').forEach(m => m.classList.remove('open'));
}

function openModal(id) {
    closeAllModals();
    clearValidationErrors(id);
    const m = document.getElementById(id);
    if (m) m.classList.add('open');
}

function closeModal(id) {
    const m = document.getElementById(id);
    if (m) m.classList.remove('open');
}

function clearValidationErrors(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.querySelectorAll('.error').forEach(el => el.classList.remove('error'));
        modal.querySelectorAll('.error-message').forEach(el => el.remove());
    }
}

function showInputError(inputId, message) {
    const input = document.getElementById(inputId);
    if (input) {
        input.classList.add('error');
        // Tránh tạo nhiều thông báo lỗi cho 1 input
        let existingError = input.parentNode.querySelector('.error-message');
        if (!existingError) {
            const errorMsg = document.createElement('div');
            errorMsg.className = 'error-message';
            errorMsg.style.display = 'block';
            errorMsg.textContent = message;
            input.parentNode.appendChild(errorMsg);
        } else {
            existingError.textContent = message;
        }
    }
}

/* ------------------------------------------------------------------ */
/*  Modal XÁC NHẬN booking                                             */
/* ------------------------------------------------------------------ */

function openConfirmModal(bookingId, customerName) {
    document.getElementById('confirmBookingId').value   = bookingId;
    document.getElementById('confirmCustomerName').textContent = customerName;
    openModal('modalConfirm');
}

/* ------------------------------------------------------------------ */
/*  Modal TỪ CHỐI booking                                              */
/* ------------------------------------------------------------------ */

function openRejectModal(bookingId, customerName) {
    document.getElementById('rejectBookingId').value    = bookingId;
    document.getElementById('rejectCustomerName').textContent = customerName;
    document.getElementById('rejectReason').value       = '';
    openModal('modalReject');
}

function submitReject() {
    const reasonInput = document.getElementById('rejectReason');
    const reason = reasonInput.value.trim();
    
    clearValidationErrors('modalReject');

    if (!reason) {
        reasonInput.focus();
        showInputError('rejectReason', 'Please enter a rejection reason.');
        return;
    }
    if (reason.length > 500) {
        showInputError('rejectReason', 'Rejection reason cannot exceed 500 characters.');
        return;
    }

    const submitBtn = document.querySelector('#modalReject button.btn-modal-reject');
    if (submitBtn) {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Processing...';
    }
    document.getElementById('formReject').submit();
}

/* ------------------------------------------------------------------ */
/*  Modal CẬP NHẬT thông tin booking                                   */
/* ------------------------------------------------------------------ */

function openEditModal(bookingId, customerName, roomTypeId, roomQuantity,
                       checkIn, checkOut, totalAmount, note) {
    document.getElementById('editBookingId').value      = bookingId;
    document.getElementById('editCustomerName').value   = customerName;
    document.getElementById('editCheckIn').value        = checkIn;
    document.getElementById('editCheckOut').value       = checkOut;
    document.getElementById('editRoomQuantity').value   = roomQuantity;
    document.getElementById('editTotalAmount').value    = totalAmount;
    document.getElementById('editNote').value           = note || '';

    // Chọn đúng loại phòng trong select
    const sel = document.getElementById('editRoomTypeId');
    if (sel && roomTypeId) {
        sel.value = roomTypeId;
    }

    openModal('modalEdit');
}

/* Tự tính tổng tiền khi đổi ngày hoặc loại phòng trong modal edit */
function recalcAmount() {
    const checkIn  = document.getElementById('editCheckIn').value;
    const checkOut = document.getElementById('editCheckOut').value;
    const sel      = document.getElementById('editRoomTypeId');
    const qty      = parseInt(document.getElementById('editRoomQuantity').value) || 1;

    if (!checkIn || !checkOut || !sel) return;

    const diff = new Date(checkOut) - new Date(checkIn);
    const nights = Math.floor(diff / (1000 * 60 * 60 * 24));

    if (nights <= 0) {
        document.getElementById('editTotalAmount').value = 0;
        return;
    }

    const basePrice = parseFloat(sel.selectedOptions[0]?.dataset?.price || 0);
    if (basePrice > 0) {
        document.getElementById('editTotalAmount').value = (basePrice * nights * qty).toFixed(0);
    }
}

/* ------------------------------------------------------------------ */
/*  Modal XEM CHI TIẾT (view-only)                                     */
/* ------------------------------------------------------------------ */

function openDetailModal(bookingId, customerName, roomTypeName, roomQuantity,
                         checkIn, checkOut, totalAmount, status, note) {
    document.getElementById('detailBookingId').textContent    = '#' + bookingId;
    document.getElementById('detailCustomerName').textContent = customerName;
    document.getElementById('detailRoomType').textContent     = roomTypeName || '—';
    document.getElementById('detailQty').textContent          = roomQuantity;
    document.getElementById('detailCheckIn').textContent      = checkIn;
    document.getElementById('detailCheckOut').textContent     = checkOut;
    document.getElementById('detailAmount').textContent       = formatVND(totalAmount);
    document.getElementById('detailStatus').textContent       = status;
    document.getElementById('detailNote').textContent         = note || '(No notes)';
    openModal('modalDetail');
}

/* ------------------------------------------------------------------ */
/*  Modal HUỶ booking                                                  */
/* ------------------------------------------------------------------ */

function openCancelModal(bookingId, customerName) {
    document.getElementById('cancelBookingId').value  = bookingId;
    document.getElementById('cancelCustomerName').textContent = customerName;
    document.getElementById('cancelReason').value     = '';
    openModal('modalCancel');
}

/* ------------------------------------------------------------------ */
/*  Format tiền VND                                                    */
/* ------------------------------------------------------------------ */

function formatVND(amount) {
    const num = parseFloat(amount) || 0;
    return new Intl.NumberFormat('vi-VN', {
        style: 'currency', currency: 'VND'
    }).format(num);
}
