/**
 * ManagerTable Utility Module
 * Used to handle client-side table rendering, pagination, and real-time filtering
 * for management pages in the Hotel Management System.
 */

const ManagerTable = {
    // Stores configurations by tableId
    tables: {},

    /**
     * Initializes a manager table control instance
     * @param {string} tableId Identifier for the table config
     * @param {object} config Configuration options
     */
    init: function (tableId, config) {
        const table = {
            id: tableId,
            items: [],
            filteredItems: [],
            currentPage: 1,
            pageSize: config.pageSize || 5,
            
            // DOM element IDs
            tbodyId: config.tbodyId,
            paginationInfoId: config.paginationInfoId,
            paginationControlsId: config.paginationControlsId,
            
            // Custom functions
            hydrateItem: config.hydrateItem, // (itemEl) => object
            renderRow: config.renderRow, // (item) => tr string or DOM element
            filterPredicate: config.filterPredicate, // (item) => boolean
            onAfterRender: config.onAfterRender || null, // (table) => void
            
            emptyMessage: config.emptyMessage || "Không tìm thấy dữ liệu nào phù hợp",
            infoTextFn: config.infoTextFn || ((start, end, total) => `Hiển thị ${start}-${end} trong số ${total} mục`)
        };

        // Hydrate items from DOM storage elements if selector and hydration function are provided
        if (config.storageSelector && config.hydrateItem) {
            document.querySelectorAll(config.storageSelector).forEach(el => {
                table.items.push(config.hydrateItem(el));
            });
        } else if (config.items) {
            table.items = [...config.items];
        }

        this.tables[tableId] = table;

        // Perform initial filter and render
        this.filter(tableId);
    },

    /**
     * Filters the dataset based on filterPredicate and resets page to 1
     * @param {string} tableId Table identifier
     */
    filter: function (tableId) {
        const table = this.tables[tableId];
        if (!table) return;

        if (table.filterPredicate) {
            table.filteredItems = table.items.filter(item => table.filterPredicate(item));
        } else {
            table.filteredItems = [...table.items];
        }

        const savedPage = sessionStorage.getItem("ManagerTable_page_" + tableId);
        if (savedPage) {
            table.currentPage = parseInt(savedPage, 10);
            sessionStorage.removeItem("ManagerTable_page_" + tableId);
        } else {
            table.currentPage = 1;
        }
        
        this.render(tableId);
    },

    /**
     * Renders the table body and pagination controls
     * @param {string} tableId Table identifier
     */
    render: function (tableId) {
        const table = this.tables[tableId];
        if (!table) return;

        const tbody = document.getElementById(table.tbodyId);
        if (!tbody) return;
        tbody.innerHTML = "";

        const totalFiltered = table.filteredItems.length;
        const totalPages = Math.ceil(totalFiltered / table.pageSize);

        // Adjust currentPage if it goes out of bounds (e.g. after dynamic filter)
        if (table.currentPage > totalPages && totalPages > 0) {
            table.currentPage = totalPages;
        }

        if (totalFiltered === 0) {
            // Render empty message
            tbody.innerHTML = `
                <tr>
                    <td colspan="20" style="text-align: center; padding: 40px; color: var(--text-muted);">
                        <i class="fa-solid fa-folder-open" style="font-size: 32px; margin-bottom: 12px; display: block;"></i>
                        ${table.emptyMessage}
                    </td>
                </tr>
            `;
            const infoEl = document.getElementById(table.paginationInfoId);
            if (infoEl) {
                infoEl.innerText = table.infoTextFn(0, 0, 0);
            }
            this.renderControls(tableId, 0);
            if (table.onAfterRender) table.onAfterRender(table);
            return;
        }

        const startIndex = (table.currentPage - 1) * table.pageSize;
        const endIndex = Math.min(startIndex + table.pageSize, totalFiltered);
        const pageData = table.filteredItems.slice(startIndex, endIndex);

        pageData.forEach(item => {
            const rowContent = table.renderRow(item);
            if (typeof rowContent === 'string') {
                const tr = document.createElement("tr");
                tr.innerHTML = rowContent;
                tbody.appendChild(tr);
            } else if (rowContent instanceof HTMLElement) {
                tbody.appendChild(rowContent);
            }
        });

        const infoEl = document.getElementById(table.paginationInfoId);
        if (infoEl) {
            infoEl.innerText = table.infoTextFn(startIndex + 1, endIndex, totalFiltered);
        }

        this.renderControls(tableId, totalPages);

        if (table.onAfterRender) {
            table.onAfterRender(table);
        }
    },

    /**
     * Renders controls for pagination
     * @param {string} tableId Table identifier
     * @param {number} totalPages Total number of pages
     */
    renderControls: function (tableId, totalPages) {
        const table = this.tables[tableId];
        if (!table) return;

        const controlsContainer = document.getElementById(table.paginationControlsId);
        if (!controlsContainer) return;
        controlsContainer.innerHTML = "";

        const prevButton = document.createElement("button");
        prevButton.type = "button";
        prevButton.className = "btn-page" + (table.currentPage === 1 || totalPages === 0 ? " disabled" : "");
        prevButton.innerHTML = '<i class="fa-solid fa-chevron-left"></i>';
        if (table.currentPage > 1 && totalPages > 0) {
            prevButton.onclick = () => {
                table.currentPage--;
                this.render(tableId);
            };
        }
        controlsContainer.appendChild(prevButton);

        for (let i = 1; i <= totalPages; i++) {
            const pageButton = document.createElement("button");
            pageButton.type = "button";
            pageButton.className = "btn-page" + (i === table.currentPage ? " active" : "");
            pageButton.innerText = i;
            pageButton.onclick = () => {
                table.currentPage = i;
                this.render(tableId);
            };
            controlsContainer.appendChild(pageButton);
        }

        if (totalPages === 0) {
            const pageButton = document.createElement("button");
            pageButton.type = "button";
            pageButton.className = "btn-page active";
            pageButton.innerText = 1;
            controlsContainer.appendChild(pageButton);
        }

        const nextButton = document.createElement("button");
        nextButton.type = "button";
        nextButton.className = "btn-page" + (table.currentPage === totalPages || totalPages === 0 ? " disabled" : "");
        nextButton.innerHTML = '<i class="fa-solid fa-chevron-right"></i>';
        if (table.currentPage < totalPages && totalPages > 0) {
            nextButton.onclick = () => {
                table.currentPage++;
                this.render(tableId);
            };
        }
        controlsContainer.appendChild(nextButton);
    }
};
