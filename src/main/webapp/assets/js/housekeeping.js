let ALL_ROOMS = [];
const contextPath = document.body.dataset.contextPath || "";

function initRooms() {
    const rooms = document.querySelectorAll(".room-item");

    ALL_ROOMS = Array.from(rooms).map(r => ({
        id: r.dataset.roomId,
        number: r.querySelector(".room-num").innerText,
        type: r.querySelector(".room-type").innerText,
        status: (r.dataset.roomStatus || "").trim(),
        floor: r.closest(".floor-card")
            .querySelector(".floor-header span").innerText
    }));
}

function extractNumber(text) {
    return parseInt((text || "").replace(/\D/g, "")) || 999;
}

function sortRooms(a, b) {
    const floorA = extractNumber(a.floor);
    const floorB = extractNumber(b.floor);

    if (floorA !== floorB) return floorA - floorB;

    return extractNumber(a.number) - extractNumber(b.number);
}

function goTaskDetail(roomId) {
    window.location.href = `${contextPath}/housekeeping/taskDetail?roomId=${roomId}`;
}

function getStatusClass(status) {
    switch (status) {
        case "Occupied": return "status-occupied";
        case "Available": return "status-available";
        case "Cleaning": return "status-cleaning";
        case "Maintenance": return "status-maintenance";
        case "Completed": return "status-completed";
        default: return "status-available";
    }
}

function applyStatusFilter(status, event) {

    document.querySelectorAll(".btn-filter")
        .forEach(b => b.classList.remove("active"));

    if (event?.currentTarget) {
        event.currentTarget.classList.add("active");
    }

    let filtered = ALL_ROOMS.filter(r =>
        status === "ALL" ? true : r.status === status
    );

    filtered.sort(sortRooms);

    const grouped = {};
    filtered.forEach(r => {
        if (!grouped[r.floor]) grouped[r.floor] = [];
        grouped[r.floor].push(r);
    });

    const sortedFloors = Object.keys(grouped)
        .sort((a, b) => extractNumber(a) - extractNumber(b));

    const container = document.querySelector(".floor-container");
    container.innerHTML = "";

    sortedFloors.forEach(floor => {

        const rooms = grouped[floor];

        container.insertAdjacentHTML("beforeend", `
            <div class="floor-card">

                <div class="floor-header">
                    <span>${floor}</span>
                    <span class="floor-room-count">${rooms.length} rooms</span>
                </div>

                <div class="room-grid">
                    ${rooms.map(r => `
                        <div class="room-item ${getStatusClass(r.status)}"
                             data-room-status="${r.status}"
                             data-room-id="${r.id}"
                             onclick="goTaskDetail(${r.id})">

                            <div class="dirty-dot"></div>
                            <span class="room-num">${r.number}</span>
                            <span class="room-type">${r.type}</span>
                        </div>
                    `).join("")}
                </div>

            </div>
        `);
    });
}

document.addEventListener("DOMContentLoaded", initRooms);