package com.mycompany.hotelmanagement.controller.common;

import com.mycompany.hotelmanagement.dal.RoomTypeDAO;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import com.mycompany.hotelmanagement.dal.HotelServiceDAO;
import com.mycompany.hotelmanagement.entity.HotelService;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

// Cấu hình khi người dùng truy cập trang chủ qua url "/" hoặc "/home"
@WebServlet(name = "HomeController", urlPatterns = {"", "/home"})
public class HomeController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        RoomTypeDAO repo = new RoomTypeDAO();

        List<RoomTypeInfo> roomTypes = repo.getAllRoomTypes();

        HotelServiceDAO serviceRepo = new HotelServiceDAO();

        List<HotelService> services = serviceRepo.getActiveServices();
        System.out.println("Services count = " + services.size());

        for (HotelService s : services) {
            System.out.println(s.getServiceName());
        }

        if (services.size() > 4) {
            services = services.subList(0, 4);
        }

        request.setAttribute("services", services);

        // lấy ảnh đại diện
        roomTypes.forEach(room -> {
            List<String> images = repo.getRoomImagesByTypeId(room.getTypeId());

            if (images != null && !images.isEmpty()) {
                room.setImageUrl(images.get(0));
            }
        });

        // chỉ hiển thị tối đa 3 phòng ở trang chủ
        if (roomTypes.size() > 3) {
            roomTypes = roomTypes.subList(0, 3);
        }

        request.setAttribute("featuredRooms", roomTypes);
        // Đường dẫn nội bộ tính từ thư mục Web Pages (nhưng ẩn với người dùng)
        String url = "/WEB-INF/views/home/home.jsp";

        // Forward yêu cầu và phản hồi tới trang JSP
        request.getRequestDispatcher(url).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
