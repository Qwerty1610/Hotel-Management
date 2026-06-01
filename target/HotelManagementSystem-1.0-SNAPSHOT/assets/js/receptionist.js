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
});

/* ------------------------------------------------------------------ */
/*  Helpers                                                             */
/* ------------------------------------------------------------------ */

function closeAllModals() {
    document.querySelectorAll('.modal-overlay').forEach(m => m.classList.remove('open'));
}

function openModal(id) {
    closeAllModals();
    const m = document.getElementById(id);
    if (m) m.classList.add('open');
}

function closeModal(id) {
    const m = document.getElementById(id);
    if (m) m.classList.remove('open');
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
    const reason = document.getElementById('rejectReason').value.trim();
    if (!reason) {
        document.getElementById('rejectReason').focus();
        document.getElementById('rejectReason').style.borderColor = '#ef4444';
        return;
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

    const nights = Math.max(0,
        (new Date(checkOut) - new Date(checkIn)) / (1000 * 60 * 60 * 24));

    const basePrice = parseFloat(sel.selectedOptions[0]?.dataset?.price || 0);
    if (basePrice > 0 && nights > 0) {
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
    document.getElementById('detailNote').textContent         = note || '(Không có ghi chú)';
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
    return new Intl.NumberFormat('vi-VN', {
        style: 'currency', currency: 'VND'
    }).format(amount);
}
