const normalize = s => (s || "").trim().toLowerCase();
let ALL_ROOMS = [];
const contextPath = document.body.dataset.contextPath || "";

function initRooms() {
    const rooms = document.querySelectorAll(".room-item");

    ALL_ROOMS = Array.from(rooms).map(r => ({
            id: r.dataset.roomId,
            number: r.querySelector(".room-num").innerText,
            type: r.querySelector(".room-type").innerText,
            status: r.dataset.roomStatus,
            floor: r.closest(".floor-card")
                    ?.querySelector(".floor-header span")
                    ?.textContent?.trim() || "Unknown"
        }));
    rooms.forEach(r => {
        const status = normalize(r.dataset.roomStatus);

        r.classList.remove(
                "status-outofservice",
                "status-available",
                "status-cleaning",
                "status-refilling",
                "status-maintenance"
                );

        r.classList.add("status-" + status);
    });
}

function extractNumber(text) {
    const match = (text || "").match(/\d+/);
    return match ? parseInt(match[0]) : 999;
}

function sortRooms(a, b) {
    const floorA = extractNumber(a.floor);
    const floorB = extractNumber(b.floor);

    if (floorA !== floorB)
        return floorA - floorB;

    return extractNumber(a.number) - extractNumber(b.number);
}

function goTaskDetail(roomId) {
    window.location.href = `${contextPath}/housekeeping/taskDetail?roomId=${roomId}`;
}

function getStatusClass(status) {
    switch (normalize(status)) {
        case "outofservice":
            return "status-outofservice";
        case "available":
            return "status-available";
        case "cleaning":
            return "status-cleaning";
        case "refilling":
            return "status-refilling";
        case "maintenance":
            return "status-maintenance";
        default:
            return "status-available";
    }
}

function applyStatusFilter(status, event) {

    document.querySelectorAll(".btn-filter")
            .forEach(b => b.classList.remove("active"));

    event?.currentTarget?.classList.add("active");
    localStorage.setItem("hk_filter_status", status);

    const container = document.querySelector(".floor-container");

    // 1. FADE OUT CURRENT CONTENT
    const oldFloors = document.querySelectorAll(".floor-card");

    oldFloors.forEach(f => {
        f.classList.add("is-hiding");
    });

    // delay để tạo cảm giác mượt
    setTimeout(() => {

        let filtered = ALL_ROOMS.filter(r => {

            const roomStatus = normalize(r.status);
            const filterStatus = normalize(status);


            if (filterStatus === "all") {
                return true;
            }


            // Cleaning + Refilling chung một nhóm
            if (filterStatus === "cleaning") {
                return roomStatus === "cleaning"
                        || roomStatus === "refilling";
            }


            return roomStatus === filterStatus;

        });

        filtered.sort(sortRooms);

        const grouped = {};
        filtered.forEach(r => {
            grouped[r.floor] ??= [];
            grouped[r.floor].push(r);
        });

        const sortedFloors = Object.keys(grouped)
                .sort((a, b) => extractNumber(a) - extractNumber(b));

        container.innerHTML = "";

        sortedFloors.forEach((floor, floorIndex) => {

            const rooms = grouped[floor];

            const floorHTML = `
                <div class="floor-card is-showing">

                    <div class="floor-header">
                        <span>${floor}</span>
                        <span class="floor-room-count">${rooms.length} rooms</span>
                    </div>

                    <div class="room-grid">
                        ${rooms.map((r, i) => `
                            <div class="room-item ${getStatusClass(r.status)} is-showing"
                                 data-room-status="${r.status}"
                                 data-room-id="${r.id}"
                                 onclick="goTaskDetail(${r.id})"
                                 style="animation-delay:${i * 40}ms">

                                <div class="maintenance-dot"></div>
                                <span class="room-num">${r.number}</span>
                                <span class="room-type">${r.type}</span>
                            </div>
                        `).join("")}
                    </div>

                </div>
            `;

            container.insertAdjacentHTML("beforeend", floorHTML);
        });

    }, 180);
}

document.addEventListener("DOMContentLoaded", () => {
    const container = document.querySelector(".floor-container");

    // 1. Đọc và áp dụng trạng thái active cho nút bộ lọc ngay lập tức
    const savedStatus = localStorage.getItem("hk_filter_status") || "ALL";
    document.querySelectorAll(".btn-filter").forEach(b => b.classList.remove("active"));
    const activeBtn = document.querySelector(`.btn-filter[data-status="${savedStatus}"]`);
    if (activeBtn)
        activeBtn.classList.add("active");

    // 2. Cấu trúc lại mảng dữ liệu trong bộ nhớ
    initRooms();

    // 3. Nếu bộ lọc là ALL, không cần render lại, hiển thị container gốc ngay
    if (savedStatus === "ALL") {
        if (container)
            container.classList.add("is-ready");
        return;
    }

    // 4. Nếu bộ lọc khác ALL, kết xuất HTML chuẩn ngay trong bộ nhớ (Không qua setTimeout)
    if (container) {
        const filtered = ALL_ROOMS.filter(r => {

            const roomStatus = normalize(r.status);
            const filterStatus = normalize(savedStatus);


            if (filterStatus === "all") {
                return true;
            }


            if (filterStatus === "cleaning") {

                return roomStatus === "cleaning"
                        || roomStatus === "refilling";
            }


            return roomStatus === filterStatus;

        }).sort(sortRooms);

        const grouped = {};
        filtered.forEach(r => {
            grouped[r.floor] ??= [];
            grouped[r.floor].push(r);
        });

        const sortedFloors = Object.keys(grouped).sort((a, b) => extractNumber(a) - extractNumber(b));

        container.innerHTML = "";

        sortedFloors.forEach(floor => {
            const rooms = grouped[floor];
            const floorHTML = `
                <div class="floor-card is-showing">
                    <div class="floor-header">
                        <span>${floor}</span>
                        <span class="floor-room-count">${rooms.length} phòng</span>
                    </div>
                    <div class="room-grid">
                        ${rooms.map((r, i) => `
                            <div class="room-item ${getStatusClass(r.status)} is-showing"
                                 data-room-status="${r.status}"
                                 data-room-id="${r.id}"
                                 onclick="goTaskDetail('${r.id}')"
                                 style="animation-delay: ${i * 30}ms">
                                <div class="maintenance-dot"></div>
                                <span class="room-num">${r.number}</span>
                                <span class="room-type">${r.type}</span>
                            </div>
                        `).join("")}
                    </div>
                </div>
            `;
            container.insertAdjacentHTML("beforeend", floorHTML);
        });

        // 5. Kích hoạt hiển thị mượt mà sau khi DOM đã hoàn thiện
        requestAnimationFrame(() => {
            container.classList.add("is-ready");
        });
    }
});