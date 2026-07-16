// =================================================================
// RECEPTIONIST DASHBOARD LOGIC
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
            if (e.target === overlay)
                closeAllModals();
        });
    });

    // ---- Phím ESC đóng modal ----
    document.addEventListener('keydown', e => {
        if (e.key === 'Escape')
            closeAllModals();
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
    if (m)
        m.classList.add('open');
}

function closeModal(id) {
    const m = document.getElementById(id);
    if (m)
        m.classList.remove('open');
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
    document.getElementById('confirmBookingId').value = bookingId;
    document.getElementById('confirmCustomerName').textContent = customerName;
    openModal('modalConfirm');
}

/* ------------------------------------------------------------------ */
/*  Modal TỪ CHỐI booking                                              */
/* ------------------------------------------------------------------ */

function openRejectModal(bookingId, customerName) {
    document.getElementById('rejectBookingId').value = bookingId;
    document.getElementById('rejectCustomerName').textContent = customerName;
    document.getElementById('rejectReason').value = '';
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
    document.getElementById('editBookingId').value = bookingId;
    document.getElementById('editCustomerName').value = customerName;
    document.getElementById('editCheckIn').value = checkIn;
    document.getElementById('editCheckOut').value = checkOut;
    document.getElementById('editRoomQuantity').value = roomQuantity;
    document.getElementById('editTotalAmount').value = totalAmount;
    document.getElementById('editNote').value = note || '';

    // Chọn đúng loại phòng trong select
    const sel = document.getElementById('editRoomTypeId');
    if (sel && roomTypeId) {
        sel.value = roomTypeId;
    }

    openModal('modalEdit');
}

/* Tự tính tổng tiền khi đổi ngày hoặc loại phòng trong modal edit */
function recalcAmount() {
    const checkIn = document.getElementById('editCheckIn').value;
    const checkOut = document.getElementById('editCheckOut').value;
    const sel = document.getElementById('editRoomTypeId');
    const qty = parseInt(document.getElementById('editRoomQuantity').value) || 1;

    if (!checkIn || !checkOut || !sel)
        return;

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
    document.getElementById('detailBookingId').textContent = '#' + bookingId;
    document.getElementById('detailCustomerName').textContent = customerName;
    document.getElementById('detailRoomType').textContent = roomTypeName || '—';
    document.getElementById('detailQty').textContent = roomQuantity;
    document.getElementById('detailCheckIn').textContent = checkIn;
    document.getElementById('detailCheckOut').textContent = checkOut;
    document.getElementById('detailAmount').textContent = formatVND(totalAmount);
    document.getElementById('detailStatus').textContent = status;
    document.getElementById('detailNote').textContent = note || '(No notes)';
    openModal('modalDetail');
}

/* ------------------------------------------------------------------ */
/*  Modal HUỶ booking                                                  */
/* ------------------------------------------------------------------ */

function openCancelModal(bookingId, customerName) {
    document.getElementById('cancelBookingId').value = bookingId;
    document.getElementById('cancelCustomerName').textContent = customerName;
    document.getElementById('cancelReason').value = '';
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
// =====================================================================
// WALK-IN BOOKING
// =====================================================================

let roomRowIndex = 0;
let maxRoomTypeCount = 0;
let roomTypeMessageTimer = null;
let walkInToastTimer = null;
let modePopupTimer = null;
let hasSubmittedWalkIn = false;
let isSubmittingWalkIn = false;
const WALKIN_STORAGE_KEY = "walkinFormState";
const WALKIN_MODE_KEY = "walkinMode";

/*
 ==================================================
 INIT
 ==================================================
 */
function getWalkInState() {
    const data = sessionStorage.getItem(WALKIN_STORAGE_KEY);

    if (!data) {
        return {};
    }

    try {
        return JSON.parse(data);
    } catch (e) {
        return {};
    }
}

function saveWalkInState() {

    const state = {};
    state.mode = document.getElementById("bookingMode")?.value || "BOOKING";
    state.customerName = document.getElementById("customerName")?.value || "";
    state.phone = document.getElementById("phone")?.value || "";
    state.email = document.getElementById("email")?.value || "";
    state.note = document.getElementById("note")?.value || "";
    state.checkInDate = document.getElementById("checkInDate")?.value || "";
    state.checkOutDate = document.getElementById("checkOutDate")?.value || "";
    state.roomRows = [];

    document.querySelectorAll(".room-row").forEach(row => {
        state.roomRows.push({
            roomTypeId:
                    row.querySelector(".room-type-select")?.value || "",
            qty:
                    row.querySelector(".room-qty-input")?.value || 1,
            guest:
                    row.querySelector(".guest-input")?.value || 1
        });
    });
    state.selectedRooms = [];
    document.querySelectorAll(".room-checkbox:checked").forEach(cb => {
        state.selectedRooms.push(cb.value);
    });
    state.companions = [];
    document.querySelectorAll("input[name='companions[]']").forEach(input => {

        state.companions.push(input.value);
    });
    sessionStorage.setItem(
            WALKIN_STORAGE_KEY,
            JSON.stringify(state)
            );
}
function saveWalkInMode() {
    const selected = document.querySelector('input[name="walkinMode"]:checked')?.value;
    if (!selected)
        return;
    const mode = selected.toUpperCase();
    sessionStorage.setItem(WALKIN_MODE_KEY, mode);
    const hidden = document.getElementById("bookingMode");
    if (hidden)
        hidden.value = mode;
}
document.querySelectorAll('input[name="walkinMode"]').forEach(r => {
    r.addEventListener("change", () => {
        saveWalkInMode();
    });
});
function clearWalkInState() {
    sessionStorage.removeItem(WALKIN_STORAGE_KEY);
}
function autoSaveWalkIn() {
    document.addEventListener("input", () => {
        if (!isSubmittingWalkIn && document.getElementById("customerName")) {
            saveWalkInState();
        }
    });
    document.addEventListener("change", () => {
        if (!isSubmittingWalkIn && document.getElementById("customerName")) {
            saveWalkInState();
        }
    });
}
async function restoreWalkInState() {

    const state = getWalkInState();
    if (!state || Object.keys(state).length === 0) {
        return;
    }
    if (isSubmittingWalkIn)
        return;
    document.getElementById("customerName").value = state.customerName || "";
    document.getElementById("phone").value = state.phone || "";
    document.getElementById("email").value = state.email || "";
    document.getElementById("note").value = state.note || "";
    document.getElementById("checkInDate").value = state.checkInDate || "";
    document.getElementById("checkOutDate").value = state.checkOutDate || "";
    if (state.mode) {
        document.getElementById("bookingMode").value = state.mode;
        const radio = document.querySelector(
                `input[name="walkinMode"][value="${state.mode.toLowerCase()}"]`
                );
        if (radio) {
            radio.checked = true;
            updateModeUI(state.mode.toLowerCase());
        }
    }
    await loadRoomTypes();
    const container = document.getElementById("roomRowsContainer");
    container.querySelectorAll(".room-row:not(.first-room-row)")
            .forEach(r => r.remove());
    roomRowIndex = 0;
    if (state.roomRows && state.roomRows.length > 0) {
        const firstRow = container.querySelector(".first-room-row");
        firstRow.querySelector(".room-type-select").value =
                state.roomRows[0].roomTypeId || "";
        firstRow.querySelector(".room-qty-input").value =
                state.roomRows[0].qty || 1;
        firstRow.querySelector(".guest-input").value =
                state.roomRows[0].guest || 1;
        for (let i = 1; i < state.roomRows.length; i++) {
            addRoomRow();
            const row = container.lastElementChild;
            row.querySelector(".room-type-select").value =
                    state.roomRows[i].roomTypeId || "";
            row.querySelector(".room-qty-input").value =
                    state.roomRows[i].qty || 1;
            row.querySelector(".guest-input").value =
                    state.roomRows[i].guest || 1;
        }
    }
    refreshRoomTypeOptions();
    await loadAvailableRooms();

    document.querySelectorAll(".room-checkbox").forEach(cb => {

        if (state.selectedRooms &&
                state.selectedRooms.includes(cb.value)) {

            cb.checked = true;
            cb.closest(".walkin-room-card")
                    ?.classList.add("selected");
        }

    });

    const companionContainer =
            document.getElementById("companionContainer");
    companionContainer.innerHTML = "";
    if (state.companions) {
        state.companions.forEach(name => {
            addCompanionRow();
            companionContainer
                    .lastElementChild
                    .querySelector("input")
                    .value = name;
        });
    }
    updateSummary();
}
function restoreWalkInMode() {
    const mode = sessionStorage.getItem(WALKIN_MODE_KEY) || "BOOKING";
    const radioValue = mode.toLowerCase();
    const radio = document.querySelector(
            `input[name="walkinMode"][value="${radioValue}"]`
            );
    if (radio) {
        radio.checked = true;
        updateModeUI(radioValue);
    }
    const hidden = document.getElementById("bookingMode");
    if (hidden)
        hidden.value = mode;
}
window.addEventListener("pageshow", function () {
    isSubmittingWalkIn = false;
});
function updateModeUI(selected) {
    const companionCard = document.getElementById("companionCard");
    const bookingBtn = document.getElementById("bookingBtn");
    const checkinBtn = document.getElementById("checkinBtn");
    const modeOptions = document.querySelectorAll(".mode-option");

    modeOptions.forEach(o => o.classList.remove("active"));

    document.querySelector(`input[name="walkinMode"][value="${selected}"]`)
            ?.closest(".mode-option")
            ?.classList.add("active");

    if (selected === "checkin") {
        companionCard.style.display = "block";
        bookingBtn.style.display = "none";
        checkinBtn.style.display = "inline-flex";
    } else {
        companionCard.style.display = "none";
        bookingBtn.style.display = "inline-flex";
        checkinBtn.style.display = "none";
    }
}
function clearWalkInAllState() {
    sessionStorage.removeItem(WALKIN_STORAGE_KEY);
    sessionStorage.removeItem(WALKIN_MODE_KEY);
}
function resetWalkInFormKeepMode() {

    const mode = sessionStorage.getItem(WALKIN_MODE_KEY);
    sessionStorage.removeItem(WALKIN_STORAGE_KEY); // FIX QUAN TRỌNG
    document.querySelector("#customerName").value = "";
    document.querySelector("#phone").value = "";
    document.querySelector("#email").value = "";
    document.querySelector("#checkInDate").value = "";
    document.querySelector("#checkOutDate").value = "";
    document.querySelector("#note").value = "";
    document.querySelector("#receptionistNote").value = "";
    const container = document.getElementById("roomRowsContainer");
    container.innerHTML = "";
    addRoomRow();
    document.querySelectorAll(".room-checkbox").forEach(cb => {
        cb.checked = false;
    });
    document.getElementById("companionContainer").innerHTML = "";
    updateSummary();

    const radio = document.querySelector(
            `input[name="walkinMode"][value="${mode?.toLowerCase()}"]`
            );
    if (radio) {
        radio.checked = true;
        updateModeUI(mode?.toLowerCase());
    }
}
document.addEventListener("DOMContentLoaded", async () => {
    restoreWalkInMode();
    if (document.getElementById("checkInDate")) {
        await initWalkInBooking();
        await restoreWalkInState();
    }
    const checkIn = document.getElementById("checkInDate");
    const checkOut = document.getElementById("checkOutDate");
    const customerName = document.getElementById("customerName");
    const phone = document.getElementById("phone");
    [
        customerName,
        phone,
        checkIn,
        checkOut
    ].forEach(input => {
        if (input) {
            input.addEventListener("input", validateCustomerInfoMessage);
            input.addEventListener("change", validateCustomerInfoMessage);
        }
    });
    if (checkIn && checkOut) {
        checkIn.addEventListener("change", loadRoomTypes);
        checkOut.addEventListener("change", loadRoomTypes);
    }

// WALK-IN MODE INIT
    const modeRadios = document.querySelectorAll('input[name="walkinMode"]');
    const companionCard = document.getElementById("companionCard");
    const bookingBtn = document.getElementById("bookingBtn");
    const checkinBtn = document.getElementById("checkinBtn");
    const modeOptions = document.querySelectorAll(".mode-option");

    function updateMode() {
        const selected = document.querySelector('input[name="walkinMode"]:checked')?.value;
        if (!selected)
            return;
        updateModeUI(selected);
        saveWalkInMode();
    }

    modeRadios.forEach(r => {
        r.addEventListener("change", () => {
            updateMode();
            const selected = document.querySelector(
                    'input[name="walkinMode"]:checked'
                    )?.value;
            if (selected === "booking") {
                showModePopup("Bạn đang ở chế độ ĐẶT PHÒNG");
            } else {
                showModePopup("Bạn đang ở chế độ CHECK IN");
            }
        });
    });
    updateMode();
    if (window.walkInSuccessMessage) {
        showWalkInToast(window.walkInSuccessMessage, "success");
    }
    if (window.walkInErrorMessage) {
        showWalkInToast(window.walkInErrorMessage, "error");
    }
});

async function initWalkInBooking() {

    const checkIn = document.getElementById("checkInDate");
    const checkOut = document.getElementById("checkOutDate");

    if (checkIn && checkOut) {

        const trigger = () => {
            loadRoomTypes();
            loadAvailableRooms();
            updateSummary();
        };

        checkIn.addEventListener("change", trigger);
        checkOut.addEventListener("change", trigger);

        trigger();
    }
    autoSaveWalkIn();
    updateSummary();
}

/*==================================================
 ROOM TYPE ROW
 ==================================================*/

function addRoomRow() {

    const container =
            document.getElementById("roomRowsContainer");

    const currentRows = container.querySelectorAll(".room-row").length;

    if (!window.roomTypeOptionsHtml || maxRoomTypeCount === 0) {
        showRoomTypeMessage("Chưa tải loại phòng");
        return;
    }

    if (currentRows >= maxRoomTypeCount) {
        showRoomTypeMessage("Không thể thêm thêm loại phòng nữa");
        return;
    }

    const html = `
        <div class="room-row">
            <span class="room-row-error hidden"></span>
            <select name="roomTypeIds[]"
                    class="walkin-input room-type-select"
                    onchange="roomTypeChanged(this)">
                <option value="">-- Chọn loại phòng --</option>
                ${window.roomTypeOptionsHtml}
            </select>
            <input
                type="number"
                name="roomQuantities[]"
                class="walkin-input room-qty-input"
                min="1"
                value="1"
                onchange="roomQtyChanged(this)">
            <input
                type="number"
                name="guestCounts[]"
                class="walkin-input guest-input"
                min="1"
                value="1"
                oninput="updateSummary()">
            <button
                type="button"
                class="btn-delete-row"
                onclick="removeRoomRow(this)">
                <i class="fa-solid fa-trash"></i>
            </button>
        </div>
    `;
    container.insertAdjacentHTML(
            "beforeend",
            html
            );
    refreshRoomTypeOptions();
    updateSummary();
    saveWalkInState();
}

function removeRoomRow(btn) {
    const rows =
            document.querySelectorAll(".room-row");
    if (rows.length <= 1) {
        alert(
                "Phải có ít nhất 1 loại phòng"
                );
        return;
    }
    btn.closest(".room-row").remove();
    refreshRoomTypeOptions();
    updateSummary();
    loadAvailableRooms();
    saveWalkInState();
}

/*
 ==================================================
 ROOM TYPE CHANGE
 ==================================================
 */

function roomTypeChanged(select) {
    refreshRoomTypeOptions();

    const option =
            select.selectedOptions[0];
    const capacity =
            parseInt(
                    option.dataset.capacity || 1
                    );
    const row =
            select.closest(".room-row");
    const qty =
            parseInt(
                    row.querySelector(
                            ".room-qty-input"
                            ).value
                    ) || 1;
    const guestInput =
            row.querySelector(
                    ".guest-input"
                    );
    guestInput.max =
            qty * capacity;
    loadAvailableRooms();
    setTimeout(() => {
        validateRoomQuantityAvailable();
    }, 100);
    updateSummary();
    if (hasSubmittedWalkIn) {
        validateRoomSelection(false);
    }
    saveWalkInState();
}

function roomQtyChanged(input) {
    const row =
            input.closest(".room-row");
    const qty =
            parseInt(input.value) || 1;
    const select =
            row.querySelector(
                    ".room-type-select"
                    );
    const capacity =
            parseInt(
                    select.selectedOptions[0]
                    ?.dataset.capacity || 1
                    );
    const guestInput =
            row.querySelector(
                    ".guest-input"
                    );
    guestInput.max =
            qty * capacity;
    if (
            parseInt(
                    guestInput.value
                    ) > guestInput.max
            ) {
        guestInput.value =
                guestInput.max;
    }
    updateSummary();
    loadAvailableRooms();
    setTimeout(() => {
        validateRoomQuantityAvailable();
    }, 100);

    if (hasSubmittedWalkIn) {
        validateRoomSelection(false);
    }
    saveWalkInState();
}

/*
 ==================================================
 LOAD AVAILABLE ROOMS
 ==================================================
 */

async function loadAvailableRooms() {
    const selectedRooms = [];
    document.querySelectorAll(".room-checkbox:checked").forEach(cb => {
        selectedRooms.push(cb.value);
    });

    const checkInDate =
            document.getElementById("checkInDate").value;

    const checkOutDate =
            document.getElementById("checkOutDate").value;

    if (!checkInDate || !checkOutDate) {
        return;
    }

    const container =
            document.getElementById(
                    "availableRoomsContainer");

    container.innerHTML = "";

    const selects =
            document.querySelectorAll(
                    ".room-type-select");

    for (const select of selects) {

        const typeId =
                select.value;
        if (!typeId) {
            continue;
        }

        try {

            const response =
                    await fetch(
                            `${contextPath}/receptionist/available-rooms`
                            + `?typeId=${typeId}`
                            + `&checkInDate=${checkInDate}`
                            + `&checkOutDate=${checkOutDate}`
                            );

            const rooms =
                    await response.json();

            renderRoomGroup(
                    select,
                    rooms
                    );

        } catch (e) {

            console.error(
                    "Load rooms error",
                    e
                    );
        }
    }
    document.querySelectorAll(".room-checkbox").forEach(cb => {
        if (selectedRooms.includes(cb.value)) {
            cb.checked = true;
            cb.closest(".walkin-room-card")
                    ?.classList.add("selected");
        }
    });
    saveWalkInState();
}
function renderRoomGroup(select, rooms) {

    const container = document.getElementById("availableRoomsContainer");

    let html = `
        <div class="room-type-box"
            data-type-id="${select.value}">

            <h4 class="room-group-title">
                ${select.selectedOptions[0].text}
                <span class="room-selection-message hidden"></span>
            </h4>

            <div class="available-room-grid">
    `;

    rooms.forEach(room => {

        html += `
            <div
                class="walkin-room-card"
                onclick="toggleRoomCard(this)">

                <input
                    type="checkbox"
                    class="room-hidden-checkbox room-checkbox"
                    name="roomIds"
                    value="${room.roomId}">

                <div class="walkin-room-number">
                    ${room.roomNumber}
                </div>

                <div class="walkin-room-type">
                    ${select.selectedOptions[0].text}
                </div>

            </div>
        `;
    });

    html += `
            </div>
        </div>
    `;

    container.insertAdjacentHTML("beforeend", html);
}
function toggleRoomCard(card) {

    const checkbox =
            card.querySelector(".room-hidden-checkbox");

    checkbox.checked = !checkbox.checked;

    card.classList.toggle(
            "selected",
            checkbox.checked
            );

    updateSummary();
    if (hasSubmittedWalkIn) {
        validateRoomSelection(false);
    }
    saveWalkInState();
}

/*
 ==================================================
 RENDER AVAILABLE ROOMS
 ==================================================
 */

function renderAvailableRooms(data) {
    const container =
            document.getElementById("availableRoomsContainer");
    if (!container)
        return;
    container.innerHTML = "";
    Object.keys(data).forEach(typeName => {
        const rooms = data[typeName];
        let html = `
            <div class="room-type-section">
                <h4>${typeName}</h4>
                <div class="room-grid">
        `;

        rooms.forEach(room => {
            html += `
                <label class="room-card">
                    <input type="checkbox"
                           class="room-checkbox"
                           value="${room.roomId}"
                           onchange="updateSummary()">
                    <span class="room-number">
                        ${room.roomNumber}
                    </span>
                    <span class="room-price">
                        ${formatVND(room.price)}
                    </span>
                </label>
            `;
        });
        html += `
                </div>
            </div>
        `;
        container.insertAdjacentHTML("beforeend", html);
    });
}

/*
 ==================================================
 SUMMARY
 ==================================================
 */

function updateSummary() {

    const summary = document.getElementById("bookingSummary");
    if (!summary)
        return;

    const checkIn = document.getElementById("checkInDate")?.value;
    const checkOut = document.getElementById("checkOutDate")?.value;

    let nights = 0;

    if (checkIn && checkOut) {
        nights = (new Date(checkOut) - new Date(checkIn))
                / (1000 * 60 * 60 * 24);
    }

    let total = 0;

    let html = `
        <table class="summary-table">
            <thead>
                <tr>
                    <th>Loại phòng</th>
                    <th>Số phòng</th>
                    <th>Giá</th>
                </tr>
            </thead>
            <tbody>
    `;

    document.querySelectorAll(".room-row").forEach(row => {

        const select = row.querySelector(".room-type-select");
        const option = select.selectedOptions[0];

        const qty =
                parseInt(row.querySelector(".room-qty-input").value) || 0;

        const price =
                parseFloat(option?.dataset.price || 0);

        total += qty * price * nights;

        html += `
            <tr>
                <td>${option?.text || "-"}</td>
                <td>${qty}</td>
                <td>${formatVND(price)}</td>
            </tr>
        `;
    });

    html += `
            </tbody>
        </table>

        <div class="summary-line">
            <span>Số đêm lưu trú</span>
            <span>${nights}</span>
        </div>

        <div class="summary-total">
            <span>Tổng số tiền</span>
            <span>${formatVND(total)}</span>
        </div>
    `;

    summary.innerHTML = html;
}

/*
 ==================================================
 VALIDATE BEFORE SUBMIT
 ==================================================
 */

function validateWalkInBooking() {

    const customerName =
            document.getElementById("customerName").value.trim();

    const phone =
            document.getElementById("phone").value.trim();

    const email =
            document.getElementById("email").value.trim();

    const checkIn =
            document.getElementById("checkInDate").value;

    const checkOut =
            document.getElementById("checkOutDate").value;

    if (customerName === "") {

        alert("Vui lòng nhập họ tên");
        return false;
    }

    if (phone === "" && email === "") {

        alert("Phải nhập SĐT hoặc Email");
        return false;
    }

    if (!checkIn || !checkOut) {

        alert("Chọn ngày check-in/check-out");
        return false;
    }

    const selectedRooms =
            document.querySelectorAll(
                    ".room-checkbox:checked"
                    );

    if (selectedRooms.length === 0) {

        alert("Vui lòng chọn phòng");
        return false;
    }

    return true;
}

async function loadRoomTypes() {

    const checkInDate =
            document.getElementById("checkInDate").value;

    const checkOutDate =
            document.getElementById("checkOutDate").value;

    if (!checkInDate || !checkOutDate) {
        return;
    }

    try {

        const response =
                await fetch(
                        contextPath
                        + "/receptionist/available-room-types"
                        + "?checkInDate="
                        + checkInDate
                        + "&checkOutDate="
                        + checkOutDate);

        const roomTypes =
                await response.json();
        if (!Array.isArray(roomTypes)) {
            console.warn("roomTypes invalid:", roomTypes);
            return;
        }
        maxRoomTypeCount = roomTypes.length || 0;
        if (!roomTypes || roomTypes.length === 0) {
            maxRoomTypeCount = 0;
            window.roomTypeOptionsHtml = `
                <option value="">-- Chọn loại phòng --</option>
            `;
            refreshRoomTypeOptions();
            return;
        }

        window.roomTypeOptionsHtml = `
            <option value="">-- Chọn loại phòng --</option>
        `;

        roomTypes.forEach(rt => {

            window.roomTypeOptionsHtml += `
                <option
                    value="${rt.typeId}"
                    data-price="${rt.basePrice}"
                    data-capacity="${rt.capacity}">
                    ${rt.typeName}
                </option>
            `;
        });
        if (!window.roomTypeOptionsHtml || window.roomTypeOptionsHtml.trim() === "") {
            window.roomTypeOptionsHtml = `
                <option value="">-- Chọn loại phòng --</option>
            `;
        }
        refreshRoomTypeOptions();

    } catch (e) {

        console.error(
                "Load room types error",
                e
                );
    }
}
function getRequiredRoomCount() {
    let total = 0;
    document
            .querySelectorAll(".room-qty-input")
            .forEach(input => {

                total += parseInt(input.value) || 0;
            });
    return total;
}
function getSelectedRoomCount() {
    return document
            .querySelectorAll(
                    ".room-checkbox:checked"
                    )
            .length;
}
function validateRoomSelection(scroll = false) {
    let valid = true;
    document.querySelectorAll(".room-type-box").forEach(box => {
        const typeId = box.dataset.typeId;
        const row = [...document.querySelectorAll(".room-row")]
                .find(r =>
                    r.querySelector(".room-type-select").value === typeId
                );
        if (!row)
            return;
        const required =
                parseInt(row.querySelector(".room-qty-input").value) || 0;
        const selected =
                box.querySelectorAll(".room-checkbox:checked").length;
        if (selected !== required) {
            showRoomSelectionMessage(
                    box,
                    `Bạn cần phải chọn ${required} phòng`
                    );
            valid = false;
        } else {
            showRoomSelectionMessage(box, "");
        }
    });
    if (!valid && scroll) {
        scrollToRoomMapCard();
    }
    return valid;
}
function validateRoomQuantityAvailable() {
    let valid = true;
    document.querySelectorAll(".room-type-box").forEach(box => {
        const typeId = box.dataset.typeId;
        const row = [...document.querySelectorAll(".room-row")]
                .find(r =>
                    r.querySelector(".room-type-select").value === typeId
                );
        if (!row)
            return;
        const required =
                parseInt(row.querySelector(".room-qty-input").value) || 0;
        const available =
                box.querySelectorAll(".room-checkbox").length;
        if (required > available) {
            showRoomRowError(
                    row,
                    `Chỉ còn ${available} phòng trống`
                    );
            valid = false;
        } else {
            showRoomRowError(row, "");
        }
    });
    document.querySelectorAll(".room-row").forEach(row => {
        const select = row.querySelector(".room-type-select");
        if (!select.value) {
            showRoomRowError(row, "");
        }
    });
    return valid;
}
function validateWalkInSubmit() {

    hasSubmittedWalkIn = true;

    if (!validateCustomerInfoMessage()) {
        return false;
    }

    if (!validateRoomTypeMessage()) {
        return false;
    }
    if (!validateRoomQuantityAvailable()) {
        return false;
    }

    if (!validateRoomSelection(true)) {
        return false;
    }

    return true;
}
function addCompanionRow() {

    const container =
            document.getElementById(
                    "companionContainer"
                    );

    container.insertAdjacentHTML(
            "beforeend",
            `
        <div class="companion-row">

            <input
                type="text"
                name="companions[]"
                class="walkin-input"
                placeholder="Tên bạn đồng hành">

            <button
                type="button"
                class="btn-remove-companion"
                onclick="removeCompanion(this)">
                <i class="fa-solid fa-trash"></i>
            </button>

        </div>
        `
            );
    saveWalkInState();
}
function removeCompanion(btn) {
    btn.closest(
            ".companion-row"
            ).remove();
    saveWalkInState();
}
function setBookingMode(mode) {
    document.getElementById(
            "bookingMode"
            ).value = mode;
    if (mode === "CHECKIN") {
        document
                .getElementById(
                        "companionCard"
                        )
                .style.display = "block";
    }
    document.querySelector("form").submit();
}

function refreshRoomTypeOptions() {
    if (!window.roomTypeOptionsHtml)
        return;

    const selects = document.querySelectorAll(".room-type-select");

    const selectedIds = [];
    selects.forEach(select => {
        if (select.value)
            selectedIds.push(select.value);
    });

    selects.forEach(currentSelect => {

        const currentValue = currentSelect.value;

        currentSelect.innerHTML =
                `<option value="">-- Chọn loại phòng --</option>` +
                window.roomTypeOptionsHtml.replace(
                        `<option value="">-- Chọn loại phòng --</option>`,
                        ""
                        );

        currentSelect.querySelectorAll("option").forEach(option => {

            if (!option.value)
                return;

            if (
                    option.value !== currentValue &&
                    selectedIds.includes(option.value)
                    ) {
                option.remove();
            }
        });

        currentSelect.value = currentValue;
    });
}
function showModePopup(message) {
    const popup = document.getElementById("modePopup");
    document.getElementById("modePopupMessage").textContent = message;
    popup.classList.remove("hidden");
    requestAnimationFrame(() => {
        popup.classList.add("show");
    });
    clearTimeout(modePopupTimer);
    modePopupTimer = setTimeout(() => {
        hideModePopup();
    }, 3000);
}

function hideModePopup() {
    const popup = document.getElementById("modePopup");
    popup.classList.remove("show");
    setTimeout(() => {
        popup.classList.add("hidden");
    }, 250);
}
function showWalkInToast(message, type = "success") {
    const toast = document.getElementById("walkinToast");
    const text = document.getElementById("walkinToastMessage");
    if (!toast)
        return;
    toast.classList.remove("success", "error");
    toast.classList.add(type);
    text.textContent = message;
    toast.classList.add("show");
    clearTimeout(walkInToastTimer);
    walkInToastTimer = setTimeout(() => {
        hideWalkInToast();
    }, 4000);
}

function hideWalkInToast() {
    const toast = document.getElementById("walkinToast");
    if (!toast)
        return;
    toast.classList.remove("show");
}

function hideWalkInToast() {
    const toast = document.getElementById("walkinToast");
    if (!toast)
        return;
    toast.classList.remove("show");
}
function showRoomTypeMessage(text) {

    const box = document.getElementById("roomTypeMessage");
    if (!box)
        return;

    if (roomTypeMessageTimer) {
        clearTimeout(roomTypeMessageTimer);
        roomTypeMessageTimer = null;
    }

    if (!text) {
        box.textContent = "";
        box.classList.add("hidden");
        return;
    }

    box.textContent = text;
    box.classList.remove("hidden");

    roomTypeMessageTimer = setTimeout(() => {
        box.textContent = "";
        box.classList.add("hidden");
        roomTypeMessageTimer = null;
    }, 3000);
}
function showRoomRowError(row, text) {

    const span = row.querySelector(".room-row-error");

    if (!span)
        return;

    if (!text) {
        span.textContent = "";
        span.classList.add("hidden");
        return;
    }

    span.textContent = text;
    span.classList.remove("hidden");
}
function showCustomerInfoMessage(text) {

    const box = document.getElementById("customerInfoMessage");
    if (!box)
        return;

    if (!text) {
        box.textContent = "";
        box.classList.add("hidden");
        return;
    }

    box.textContent = text;
    box.classList.remove("hidden");
}
function showRoomSelectionMessage(roomBox, text) {

    const span = roomBox.querySelector(".room-selection-message");
    if (!span)
        return;

    if (!text) {
        span.textContent = "";
        span.classList.add("hidden");
        return;
    }

    span.textContent = text;
    span.classList.remove("hidden");
}
function scrollToCustomerCard() {

    const card = document.getElementById("customerName")?.closest(".walkin-card");

    if (!card)
        return;

    card.scrollIntoView({
        behavior: "smooth",
        block: "start"
    });
}
function scrollToRoomTypeCard() {

    const card = document.querySelector(".room-type-select")?.closest(".walkin-card");

    if (!card)
        return;

    card.scrollIntoView({
        behavior: "smooth",
        block: "start"
    });
}
function scrollToRoomMapCard() {

    const card = document.getElementById("availableRoomsContainer")?.closest(".walkin-card");

    if (!card)
        return;

    card.scrollIntoView({
        behavior: "smooth",
        block: "start"
    });
}
function validateRoomTypeMessage() {

    const selects = document.querySelectorAll(".room-type-select");

    for (const select of selects) {
        if (!select.value) {
            showRoomTypeMessage("Hãy chọn loại phòng");
            scrollToRoomTypeCard();
            return false;
        }
    }

    showRoomTypeMessage("");
    return true;
}
function validateCustomerInfoMessage() {
    if (!hasSubmittedWalkIn) {
        showCustomerInfoMessage("");
        return true;
    }

    const customerName = document.getElementById("customerName").value.trim();
    const phone = document.getElementById("phone").value.trim();
    const checkIn = document.getElementById("checkInDate").value;
    const checkOut = document.getElementById("checkOutDate").value;
    if (!customerName) {
        showCustomerInfoMessage("Hãy điền Họ và tên");
        scrollToCustomerCard();
        return false;
    }
    if (!phone) {
        showCustomerInfoMessage("Hãy điền Số điện thoại");
        scrollToCustomerCard();
        return false;
    }
    const phoneRegex = /^(0|\+84)(3|5|7|8|9)\d{8}$/;
    if (!phoneRegex.test(phone)) {
        showCustomerInfoMessage("Số điện thoại không hợp lệ");
        scrollToCustomerCard();
        return false;
    }
    if (!checkIn) {
        showCustomerInfoMessage("Hãy điền Ngày nhận phòng");
        scrollToCustomerCard();
        return false;
    }
    if (!checkOut) {
        showCustomerInfoMessage("Hãy điền Ngày trả phòng");
        scrollToCustomerCard();
        return false;
    }
    if (new Date(checkOut) <= new Date(checkIn)) {
        showCustomerInfoMessage("Ngày trả phòng phải lớn hơn ngày nhận phòng");
        scrollToCustomerCard();
        return false;
    }
    showCustomerInfoMessage("");
    return true;
}
document.addEventListener("DOMContentLoaded", function () {

    const phone = document.getElementById("phone");

    if (phone) {
        phone.addEventListener("input", function () {
            this.value = this.value.replace(/\D/g, "");
        });
    }

});
function beforeWalkInSubmit(mode, event) {
    document.getElementById("bookingMode").value = mode;
    sessionStorage.setItem(WALKIN_MODE_KEY, mode);

    hasSubmittedWalkIn = true;
    isSubmittingWalkIn = true;

    if (!validateWalkInSubmit()) {
        isSubmittingWalkIn = false;
        event?.preventDefault();
        return false;
    }

    return true;
}