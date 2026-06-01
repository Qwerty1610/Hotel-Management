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

/* ================================================================= */
/*  RECEPTIONIST ITERATION 1 METHODS                                 */
/* ================================================================= */

/* 1. Modal Gán phòng vật lý */
function openAssignModal(bookingId, roomTypeId, roomTypeName) {
    document.getElementById('assignBookingId').value = bookingId;
    document.getElementById('assignRoomTypeName').textContent = roomTypeName;
    
    // Lọc options phòng trống của loại phòng tương ứng
    const select = document.getElementById('assignRoomId');
    select.value = "";
    Array.from(select.options).forEach(opt => {
        if (opt.value === "") return;
        if (opt.dataset.typeid == roomTypeId) {
            opt.style.display = "block";
        } else {
            opt.style.display = "none";
        }
    });
    openModal('modalAssign');
}

/* 2. Modal Xác nhận Check-in */
function openCheckinConfirmModal(bookingId, customerName, roomNumber) {
    document.getElementById('checkinBookingId').value = bookingId;
    document.getElementById('checkinCustomerName').textContent = customerName;
    document.getElementById('checkinRoomNumber').textContent = roomNumber;
    openModal('modalCheckinConfirm');
}

/* 3. Modal Trả phòng & stay services */
function openCheckoutBillModal(bookingId, customerName, roomNumber, basePrice, nights, totalAmount, deposit) {
    document.getElementById('outBookingId').value = bookingId;
    document.getElementById('outCustomerName').textContent = customerName;
    document.getElementById('outRoomNumber').textContent = roomNumber;
    
    const roomCharge = basePrice * nights;
    document.getElementById('outRoomCharge').textContent = formatVND(roomCharge);
    
    // Load các dịch vụ đã dùng
    const servContainer = document.getElementById('outServicesList');
    servContainer.innerHTML = "";
    
    let serviceTotal = 0;
    const services = window.globalBookingServicesMap[bookingId] || [];
    
    if (services.length === 0) {
        servContainer.innerHTML = `<div style="color:var(--text-muted);font-size:12px;padding:8px 0;text-align:center;">Chưa sử dụng dịch vụ nào</div>`;
    } else {
        services.forEach(s => {
            serviceTotal += s.price; // price đã nhân với quantity ở DAO
            const div = document.createElement('div');
            div.className = 'service-item-row';
            div.style.display = 'flex';
            div.style.justifyContent = 'space-between';
            div.style.alignItems = 'center';
            div.style.padding = '6px 0';
            div.style.borderBottom = '1px dashed var(--border-color)';
            
            const deleteForm = `
                <form method="post" action="${window.contextPath}/receptionist/booking" style="margin:0;">
                    <input type="hidden" name="action" value="remove_service" />
                    <input type="hidden" name="bookingId" value="${bookingId}" />
                    <input type="hidden" name="serviceId" value="${s.serviceId}" />
                    <button type="submit" class="btn-action-icon btn-reject" title="Xóa dịch vụ" style="padding:2px 6px;">
                        <i class="fa-solid fa-trash-can" style="font-size:11px;"></i>
                    </button>
                </form>
            `;
            
            div.innerHTML = `
                <span style="font-size:13px;font-weight:500;">${s.serviceName} <small style="color:var(--text-muted)">(${s.description})</small></span>
                <div style="display:flex;align-items:center;gap:12px;">
                    <span style="font-weight:700;">${formatVND(s.price)}</span>
                    ${deleteForm}
                </div>
            `;
            servContainer.appendChild(div);
        });
    }
    
    document.getElementById('outServiceCharge').textContent = formatVND(serviceTotal);
    
    const depositVal = deposit || (roomCharge * 0.1); 
    document.getElementById('outDeposit').textContent = formatVND(depositVal);
    
    const finalTotal = roomCharge + serviceTotal - depositVal;
    document.getElementById('outFinalTotal').textContent = formatVND(finalTotal);
    document.getElementById('outFinalTotalInput').value = (roomCharge + serviceTotal).toFixed(0);
    
    // Gán bookingId cho form Thêm dịch vụ
    document.querySelectorAll('.service-add-booking-id').forEach(el => el.value = bookingId);
    
    openModal('modalCheckoutBill');
}

/* Tự cập nhật đơn giá dịch vụ khi chọn trong checkout modal */
function updateServicePrice() {
    const sel = document.getElementById('addServiceId');
    const priceInput = document.getElementById('addServicePrice');
    if (sel) {
        const price = parseFloat(sel.selectedOptions[0]?.dataset?.price || 0);
        priceInput.value = price;
    }
}

/* 4. Walk-in Booking logic */
function loadWalkinRooms() {
    const typeId = document.getElementById('walkRoomTypeId').value;
    const roomSelect = document.getElementById('walkRoomId');
    roomSelect.innerHTML = '<option value="">— Chọn phòng vật lý —</option>';
    
    if (!typeId) return;
    
    const rooms = window.globalAvailableRoomsMap[typeId] || [];
    rooms.forEach(r => {
        const opt = document.createElement('option');
        opt.value = r.roomId;
        opt.textContent = `Phòng ${r.roomNumber} (${r.floor})`;
        roomSelect.appendChild(opt);
    });
}

function recalcWalkinCost() {
    const checkIn = document.getElementById('walkCheckIn').value;
    const checkOut = document.getElementById('walkCheckOut').value;
    const typeSelect = document.getElementById('walkRoomTypeId');
    
    const stayNightsLabel = document.getElementById('walkStayNights');
    const costText = document.getElementById('walkCostText');
    const walkAmtInput = document.getElementById('walkTotalAmount');
    
    if (!checkIn || !checkOut || !typeSelect.value) {
        stayNightsLabel.textContent = "0 đêm";
        costText.textContent = "0đ";
        walkAmtInput.value = "0";
        return;
    }
    
    const nights = Math.max(0, (new Date(checkOut) - new Date(checkIn)) / (1000 * 60 * 60 * 24));
    stayNightsLabel.textContent = nights + " đêm";
    
    const basePrice = parseFloat(typeSelect.selectedOptions[0]?.dataset?.price || 0);
    if (basePrice > 0 && nights > 0) {
        const total = basePrice * nights;
        costText.textContent = formatVND(total);
        walkAmtInput.value = total.toFixed(0);
    } else {
        costText.textContent = "0đ";
        walkAmtInput.value = "0";
    }
}

function validateWalkinForm() {
    const checkIn = document.getElementById('walkCheckIn').value;
    const checkOut = document.getElementById('walkCheckOut').value;
    if (new Date(checkOut) <= new Date(checkIn)) {
        alert("Ngày trả phòng phải sau ngày nhận phòng!");
        return false;
    }
    return true;
}
