package com.mycompany.hotelmanagement.controller.housekeeping;

import com.mycompany.hotelmanagement.dal.RoomIssueDAO;
import com.mycompany.hotelmanagement.dal.RoomDAO;
import com.mycompany.hotelmanagement.entity.RoomIssue;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author MinhTDP
 * Created: 10/07/2026
 */
@WebServlet("/housekeeping/reportIssue")
public class HousekeepingReportIssueController extends HttpServlet {

    private final RoomDAO roomRepository = new RoomDAO();
    private final RoomIssueDAO roomIssueDAO = new RoomIssueDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute(
                "rooms",
                roomRepository.getRoomsForIssueReport());

        request.getRequestDispatcher(
                "/WEB-INF/views/housekeeping/reportIssue.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {

            int roomId = Integer.parseInt(
                    request.getParameter("roomId")
            );

            String note = request.getParameter("note");

            String[] issueTypes
                    = request.getParameterValues("issueType");

            String[] severities
                    = request.getParameterValues("severity");

            String[] descriptions
                    = request.getParameterValues("description");

            Integer accountId
                    = (Integer) request.getSession()
                            .getAttribute("accountId");

            for (int i = 0; i < issueTypes.length; i++) {

                // Kiểm tra issue đang Pending
                boolean existed
                        = roomIssueDAO.existsPendingIssue(
                                roomId,
                                issueTypes[i]
                        );

                if (existed) {

                    request.getSession().setAttribute(
                            "errorMessage",
                            "Sự cố đã được báo cáo và đang chờ xử lý"
                    );

                    response.sendRedirect(
                            request.getContextPath()
                            + "/housekeeping/reportIssue"
                    );

                    return;
                }

                RoomIssue issue = new RoomIssue();

                issue.setRoomId(roomId);

                issue.setIssueType(
                        issueTypes[i]
                );

                issue.setSeverity(
                        severities[i]
                );

                issue.setDescription(
                        descriptions[i]
                );

                issue.setNote(note);

                issue.setReportedBy(accountId);

                boolean inserted
                        = roomIssueDAO.insert(issue);

                if (!inserted) {

                    request.getSession().setAttribute(
                            "errorMessage",
                            "Có lỗi khi lưu báo cáo sự cố."
                    );

                    response.sendRedirect(
                            request.getContextPath()
                            + "/housekeeping/reportIssue"
                    );

                    return;
                }

                // Cập nhật trạng thái phòng sau khi lưu sự cố
                boolean updatedStatus
                        = roomRepository.updateRoomStatusByIssue(
                                roomId,
                                issueTypes[i],
                                severities[i]
                        );

                if (!updatedStatus) {

                    request.getSession().setAttribute(
                            "errorMessage",
                            "Lưu sự cố thành công nhưng không cập nhật được trạng thái phòng."
                    );

                    response.sendRedirect(
                            request.getContextPath()
                            + "/housekeeping/reportIssue"
                    );

                    return;
                }

            }

            // Lưu thành công
            request.getSession().setAttribute(
                    "successMessage",
                    "Gửi báo cáo sự cố thành công"
            );

            response.sendRedirect(
                    request.getContextPath()
                    + "/housekeeping/reportIssue"
            );

        } catch (NumberFormatException e) {

            request.getSession().setAttribute(
                    "errorMessage",
                    "Số phòng không hợp lệ."
            );

            response.sendRedirect(
                    request.getContextPath()
                    + "/housekeeping/reportIssue"
            );

        } catch (Exception e) {

            e.printStackTrace();

            request.getSession().setAttribute(
                    "errorMessage",
                    "Đã xảy ra lỗi trong quá trình xử lý."
            );

            response.sendRedirect(
                    request.getContextPath()
                    + "/housekeeping/reportIssue"
            );
        }
    }

    private void loadRooms(HttpServletRequest request) {
        request.setAttribute(
                "rooms",
                roomRepository.getRoomsForIssueReport()
        );
    }

    private int getSeverityLevel(String severity) {
        if ("High".equals(severity)) {
            return 3;
        }
        if ("Medium".equals(severity)) {
            return 2;
        }
        return 1;
    }
}
