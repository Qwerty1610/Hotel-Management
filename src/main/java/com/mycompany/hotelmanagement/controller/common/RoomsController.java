package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.mycompany.hotelmanagement.service.RoomTypeService;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;

/**
 * Project: Hotel Management System
 * Class: RoomsController
 *
 * Description:
 * Controller hiển thị và tìm kiếm danh sách loại phòng cho khách hàng
 * (Customer). Xử lý lọc theo loại phòng, số lượng khách và khoảng giá,
 * gọi RoomTypeService để lấy dữ liệu và chuyển tiếp kết quả đến trang
 * rooms.jsp.
 *
 * Related Use Cases:
 * - UC-03 Search Available Rooms
 * - UC-29 Browse Available Room Types
 *
 * Date: 31-05-2026
 *
 * @author KhanhTD
 * @version 1.0
 */
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.stream.Collectors;

@WebServlet(name = "RoomsController", urlPatterns = {"/rooms"})
public class RoomsController extends HttpServlet {

    private final RoomTypeService roomTypeService = new RoomTypeService();

    public static class DateRangeResult {
        public LocalDate checkIn;
        public LocalDate checkOut;
        public String error;
        public boolean hasExplicitDates;

        public DateRangeResult(LocalDate checkIn, LocalDate checkOut, String error, boolean hasExplicitDates) {
            this.checkIn = checkIn;
            this.checkOut = checkOut;
            this.error = error;
            this.hasExplicitDates = hasExplicitDates;
        }

        public boolean isValid() {
            return error == null && checkIn != null && checkOut != null;
        }
    }

    public static DateRangeResult parseAndValidateDateRange(String checkInStr, String checkOutStr) {
        boolean hasIn = checkInStr != null && !checkInStr.trim().isEmpty();
        boolean hasOut = checkOutStr != null && !checkOutStr.trim().isEmpty();

        LocalDate defaultIn = LocalDate.now();
        LocalDate defaultOut = LocalDate.now().plusDays(1);

        if (!hasIn && !hasOut) {
            return new DateRangeResult(defaultIn, defaultOut, null, false);
        }

        if (hasIn && !hasOut) {
            return new DateRangeResult(null, null, "Vui lòng chọn ngày trả phòng (check-out).", true);
        }

        if (!hasIn && hasOut) {
            return new DateRangeResult(null, null, "Vui lòng chọn ngày nhận phòng (check-in).", true);
        }

        LocalDate inDate;
        LocalDate outDate;
        try {
            inDate = LocalDate.parse(checkInStr.trim());
        } catch (DateTimeParseException e) {
            return new DateRangeResult(null, null, "Định dạng ngày nhận phòng không hợp lệ.", true);
        }

        try {
            outDate = LocalDate.parse(checkOutStr.trim());
        } catch (DateTimeParseException e) {
            return new DateRangeResult(null, null, "Định dạng ngày trả phòng không hợp lệ.", true);
        }

        LocalDate today = LocalDate.now();

        if (inDate.isBefore(today)) {
            return new DateRangeResult(inDate, outDate, "Ngày nhận phòng không được ở trong quá khứ.", true);
        }

        if (!outDate.isAfter(inDate)) {
            return new DateRangeResult(inDate, outDate, "Ngày trả phòng (check-out) phải sau ngày nhận phòng (check-in).", true);
        }

        return new DateRangeResult(inDate, outDate, null, true);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Get search filter parameters
        String checkInParam = request.getParameter("checkIn");
        String checkOutParam = request.getParameter("checkOut");
        String minPriceParam = request.getParameter("minPrice");
        String maxPriceParam = request.getParameter("maxPrice");
        String guestsParam = request.getParameter("guests");

        // Validate date range
        DateRangeResult dateResult = parseAndValidateDateRange(checkInParam, checkOutParam);

        double minPriceFilter = 0.0;
        double maxPriceFilter = Double.MAX_VALUE;
        int guestsFilter = -1;

        try {
            if (minPriceParam != null && !minPriceParam.trim().isEmpty()) {
                minPriceFilter = Double.parseDouble(minPriceParam.replaceAll("[^0-9.]", ""));
            }
        } catch (NumberFormatException e) {
            // keep 0.0
        }

        try {
            if (maxPriceParam != null && !maxPriceParam.trim().isEmpty() && !"Không giới hạn".equalsIgnoreCase(maxPriceParam)) {
                maxPriceFilter = Double.parseDouble(maxPriceParam.replaceAll("[^0-9.]", ""));
            }
        } catch (NumberFormatException e) {
            // keep Double.MAX_VALUE
        }

        try {
            if (guestsParam != null && !guestsParam.trim().isEmpty() && !"all".equalsIgnoreCase(guestsParam)) {
                guestsFilter = Integer.parseInt(guestsParam);
            }
        } catch (NumberFormatException e) {
            // keep -1
        }

        boolean hasMinPrice = minPriceParam != null && !minPriceParam.trim().isEmpty();
        boolean hasMaxPrice = maxPriceParam != null && !maxPriceParam.trim().isEmpty() && !"Không giới hạn".equalsIgnoreCase(maxPriceParam);

        List<RoomTypeInfo> allRoomTypes;
        List<RoomTypeInfo> filteredRoomTypes;

        if (!dateResult.isValid()) {
            request.setAttribute("dateError", dateResult.error);
            allRoomTypes = roomTypeService.getAllRoomTypes(java.time.LocalDate.now(), java.time.LocalDate.now().plusDays(1));
            filteredRoomTypes = java.util.Collections.emptyList();
        } else if (hasMinPrice && hasMaxPrice && minPriceFilter > maxPriceFilter) {
            request.setAttribute("priceError", "Giá tối thiểu không được lớn hơn giá tối đa.");
            allRoomTypes = roomTypeService.getAllRoomTypes(dateResult.checkIn, dateResult.checkOut);
            filteredRoomTypes = java.util.Collections.emptyList();
        } else {
            // Fetch all room types with availability calculated for requested checkIn -> checkOut
            allRoomTypes = roomTypeService.getAllRoomTypes(dateResult.checkIn, dateResult.checkOut);

            // Filter room types by criteria AND exclude room types with availableCount == 0
            final int fGuestsFilter = guestsFilter;
            final double fMinPrice = minPriceFilter;
            final double fMaxPrice = maxPriceFilter;

            filteredRoomTypes = allRoomTypes.stream().filter(rt -> {
                if (rt.getAvailableCount() <= 0) {
                    return false;
                }
                if (fGuestsFilter > 0 && rt.getCapacity() < fGuestsFilter) {
                    return false;
                }
                if (rt.getBasePrice() < fMinPrice || rt.getBasePrice() > fMaxPrice) {
                    return false;
                }
                return true;
            }).collect(Collectors.toList());
        }

        // Set attributes for view rendering
        request.setAttribute("roomTypes", filteredRoomTypes);
        request.setAttribute("allRoomTypesList", allRoomTypes); // For selection dropdown
        request.setAttribute("todayDate", LocalDate.now().toString());
        request.setAttribute("selectedCheckIn", dateResult.checkIn != null ? dateResult.checkIn.toString() : (checkInParam != null ? checkInParam : ""));
        request.setAttribute("selectedCheckOut", dateResult.checkOut != null ? dateResult.checkOut.toString() : (checkOutParam != null ? checkOutParam : ""));
        request.setAttribute("selectedMinPrice", minPriceParam != null ? minPriceParam : "");
        request.setAttribute("selectedMaxPrice", maxPriceParam != null ? maxPriceParam : "");
        request.setAttribute("selectedGuests", guestsParam != null ? guestsParam : "all");
        request.setAttribute("resultsCount", filteredRoomTypes.size());

        // Forward to rooms.jsp
        request.getRequestDispatcher("/WEB-INF/views/home/rooms.jsp").forward(request, response);
    }
}
