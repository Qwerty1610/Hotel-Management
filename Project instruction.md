# HMS — Hotel Management System

> **Hệ thống Quản lý Khách sạn Thông minh**  
> Dự án môn học SWP391 — FPT University, Hà Nội

[![Java](https://img.shields.io/badge/Java-17-orange?logo=java)](https://www.oracle.com/java/)
[![Jakarta EE](https://img.shields.io/badge/Jakarta%20EE-10-blue?logo=eclipse)](https://jakarta.ee/)
[![JSP/Servlet](https://img.shields.io/badge/JSP%20%2F%20Servlet-6.0-red)](https://jakarta.ee/specifications/servlet/)
[![SQL Server](https://img.shields.io/badge/SQL%20Server-2019%2B-red?logo=microsoftsqlserver)](https://www.microsoft.com/sql-server)
[![HikariCP](https://img.shields.io/badge/HikariCP-5.1.0-blue)](https://github.com/brettwooldridge/HikariCP)
[![Version](https://img.shields.io/badge/Version-1.0-blue)](.)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## Mục lục

- [Giới thiệu](#-giới-thiệu)
- [Tính năng chính](#-tính-năng-chính)
- [Kiến trúc hệ thống](#-kiến-trúc-hệ-thống)
- [Công nghệ sử dụng](#-công-nghệ-sử-dụng)
- [Yêu cầu hệ thống](#-yêu-cầu-hệ-thống)
- [Cài đặt & Chạy dự án](#-cài-đặt--chạy-dự-án)
- [Cấu trúc dự án](#-cấu-trúc-dự-án)

---

## Giới thiệu

**HMS (Hotel Management System)** là ứng dụng web full-stack được phát triển dựa trên kiến trúc **Monolithic JSP/Servlet (Jakarta EE 10)** truyền thống. Hệ thống giúp số hoá toàn bộ quy trình vận hành và quản lý của một khách sạn, bao gồm trọn vẹn vòng đời đặt phòng và phục vụ khách hàng:

```
Tìm phòng/Xem loại phòng → Đặt phòng trực tuyến (hoặc Offline tại quầy) → Xác nhận booking → Tiếp nhận/Check-in → Yêu cầu dịch vụ & Dọn phòng (Housekeeping) → Check-out → Thanh toán & Hoàn tiền → Xem báo cáo & Dashboard
```

Hệ thống phục vụ **5 nhóm người dùng** (Customer, Receptionist, Housekeeping, Hotel Manager, Admin) với phân quyền bảo mật đầy đủ thông qua cơ chế `HttpSession` và bộ lọc `AuthFilter`.

---

## Tính năng chính

### Module 1 — Authentication & Authorization
- Đăng ký / Đăng nhập tài khoản bằng email + mật khẩu (mã hóa mật khẩu bằng BCrypt).
- Đăng nhập bằng tài khoản Google (Google OAuth 2.0).
- Chức năng Quên mật khẩu / Đặt lại mật khẩu sử dụng mã xác nhận gửi qua email (Jakarta Mail).
- Ghi nhớ đăng nhập (Remember Me) bằng Cookie thời hạn 30 ngày.
- Phân quyền kiểm soát truy cập (RBAC) với 5 nhóm vai trò: Admin, Manager, Receptionist, Housekeeping, Customer.

### Module 2 — Room Type & Room Management (Manager)
- Quản lý danh mục loại phòng (Room Type): tên loại phòng, sức chứa, diện tích, kiểu giường, giá phòng theo ngày, giá phòng theo giờ, phần trăm đặt cọc bắt buộc, mô tả.
- Quản lý tiện ích phòng (Amenities): Gán các tiện ích (như Wifi, Điều hòa, Tivi, View thành phố, Mini bar, Bồn tắm...) cho từng loại phòng.
- Quản lý thư viện hình ảnh (`RoomImage`) đại diện cho từng loại phòng.
- Quản lý danh sách phòng (`Room`): số phòng, số tầng (floor), gán loại phòng, cập nhật trạng thái phòng (`Available`, `Occupied`, `Cleaning`, `Maintenance`).

### Module 3 — Booking Management (Customer & Receptionist)
- **Khách hàng**: 
  - Xem danh sách loại phòng kèm hình ảnh, tiện ích, mô tả chi tiết.
  - Lọc và tìm kiếm phòng trống theo khoảng giá, số khách và loại phòng.
  - Đặt phòng trực tuyến (chọn loại phòng, số lượng phòng, ngày nhận phòng/trả phòng, ghi chú yêu cầu).
- **Lễ tân (Receptionist)**:
  - Tiếp nhận và xử lý danh sách đặt phòng (Pending, Confirmed, CheckedIn, CheckedOut, Rejected, Cancelled).
  - Làm thủ tục nhận phòng (**Check-in**) trực tiếp tại quầy hoặc cho khách đã đặt trước (tự động chuyển trạng thái phòng sang `Occupied`).
  - Làm thủ tục trả phòng (**Check-out**) (tự động chuyển trạng thái phòng sang `Cleaning`).
  - Hủy đặt phòng theo yêu cầu hoặc từ chối đơn đặt phòng không hợp lệ.

### Module 4 — Hotel Service Management (Manager)
- Quản lý danh mục dịch vụ cộng thêm của khách sạn (như Buffet sáng, giặt ủi, đưa đón sân bay, spa, gym, hồ bơi...).
- Quản lý thông tin dịch vụ bao gồm: tên dịch vụ, mô tả, đơn giá, đơn vị tính (ví dụ: /khách, /kg, /chuyến, /ngày, /lượt) và trạng thái hoạt động (bật/tắt dịch vụ).

### Module 5 — Customer Requests & Housekeeping Task Tracking (Manager & Housekeeping)
- Tiếp nhận các yêu cầu phát sinh từ phòng lưu trú của khách hàng (yêu cầu thêm khăn tắm, thay ga giường, nước nóng yếu, hỏng bóng đèn...).
- **Quản lý (Manager)**:
  - Giám sát trạng thái hoạt động của nhân viên dọn phòng (Active, OnBreak, Offline).
  - Gán (Assign) yêu cầu cho nhân viên Housekeeping đang ở trạng thái `Active`.
- **Nhân viên dọn phòng (Housekeeping)**:
  - Xem danh sách công việc được giao tại Dashboard cá nhân.
  - Cập nhật trạng thái xử lý công việc (`Pending` → `InProgress` → `Completed` | `Cancelled`).
  - Khi hoàn tất dọn phòng, cập nhật trạng thái của phòng từ `Cleaning` sang `Available`.

### Module 6 — Invoice, Billing & Refund (Manager & Receptionist)
- Tự động tổng hợp chi phí hóa đơn khi làm thủ tục Check-out:
  - **Tiền phòng**: Tự động tính dựa trên đơn giá loại phòng nhân với số đêm lưu trú và số lượng phòng.
  - **Tiền dịch vụ**: Các dịch vụ khách hàng đã sử dụng trong thời gian lưu trú.
  - **Phụ phí (Surcharge)**: Các chi phí phát sinh ngoài (ví dụ: phí trả phòng muộn, hư hỏng đồ đạc thiết bị).
- Quản lý danh sách hóa đơn theo trạng thái: `Pending` (Chờ thanh toán), `Paid` (Đã thanh toán), `Refunding` (Đang chờ hoàn tiền), `Cancelled` (Đã hủy).
- Quản lý các khoản hoàn tiền (`Refund`):
  - Khi một đặt phòng (đã được thanh toán cọc) bị từ chối hoặc hủy, hệ thống tự động sinh một yêu cầu hoàn cọc ở trạng thái `Pending`.
  - Quản lý kiểm duyệt, hoàn tiền cho khách và cập nhật trạng thái khoản hoàn tiền sang `Done`.

### Module 7 — Manager Dashboard & Admin (Manager & Admin)
- **Manager Dashboard**:
  - Biểu đồ và số liệu thống kê tổng hợp: doanh thu hôm nay/tháng này, số lượng đặt phòng mới, số phòng trống, số phòng đang sử dụng, số phòng cần dọn dẹp.
  - Biểu đồ hiệu suất dọn dẹp và số lượng công việc đã hoàn thành của từng nhân viên Housekeeping.
  - Quản lý danh sách nhân sự khách sạn (Nhân viên lễ tân, nhân viên dọn phòng).
- **Admin**:
  - Quản lý danh sách tài khoản người dùng hệ thống (kích hoạt/hủy kích hoạt tài khoản).
  - Phân quyền vai trò hệ thống.

---

## Kiến trúc hệ thống

Dự án tuân thủ mô hình thiết kế **MVC (Model-View-Controller)** cổ điển, đóng gói dưới dạng tệp tin lưu trữ **WAR** để chạy trên Servlet Container (như Apache Tomcat):

```
┌─────────────────────────────────────────────────────────┐
│                     CLIENT (Browser)                     │
│               HTML5 + CSS3 + Bootstrap + JS             │
└─────────────────────────┬───────────────────────────────┘
                          │ HTTP Request / Response (JSP)
┌─────────────────────────▼───────────────────────────────┐
│           HMS APP (Jakarta EE Servlet Container)        │
│  ┌───────────────────────┐  ┌────────────────────────┐  │
│  │      Controllers      │  │         Views          │  │
│  │      (Servlets)       │  │         (JSPs)         │  │
│  └──────────┬────────────┘  └────────────────────────┘  │
│             │ gọi dịch vụ                               │
│  ┌──────────▼────────────┐                              │
│  │        Services       │ (Lớp xử lý nghiệp vụ chính)  │
│  └──────────┬────────────┘                              │
│             │ truy cập dữ liệu                          │
│  ┌──────────▼────────────┐                              │
│  │  Repositories / DAOs  │ (Lớp tương tác Database)      │
│  └──────────┬────────────┘                              │
│             │ SQL Queries / Connection Pool             │
│  ┌──────────▼────────────┐                              │
│  │  HikariCP DataSource  │                              │
│  └───────────────────────┘                              │
└─────────────────────────┬───────────────────────────────┘
                          │ JDBC Connection
┌─────────────────────────▼───────────────────────────────┐
│               Microsoft SQL Server Database             │
└─────────────────────────────────────────────────────────┘
          │                                      │
┌─────────▼────────┐                   ┌─────────▼────────┐
│   SMTP Service   │                   │ Google OAuth 2.0 │
│  (Gmail Server)  │                   │ (Identity API)   │
└──────────────────┘                   └──────────────────┘
```

- **Controller Layer (Servlets)**: Tiếp nhận các HTTP Request, xử lý tham số lọc/tìm kiếm, gọi đến lớp Service để xử lý nghiệp vụ, sau đó gán thuộc tính vào request và forward sang trang JSP.
- **View Layer (JSP & JSTL)**: Sử dụng các thẻ JSTL 3.0 để duyệt danh sách, hiển thị thông tin động và dựng giao diện HTML gửi về cho người dùng.
- **Service Layer**: Đảm nhận logic nghiệp vụ của hệ thống (ví dụ: kiểm tra điều kiện gán phòng, tính toán tổng tiền hóa đơn, băm mật khẩu, gửi email).
- **DAL Layer (Repositories/DAOs)**: Sử dụng JDBC thuần để thực thi các câu lệnh SQL đến SQL Server, tận dụng HikariCP để quản lý kết nối hiệu quả.

---

## Công nghệ sử dụng

| Tầng / Vai trò | Công nghệ | Phiên bản | Mô tả |
|---|---|---|---|
| **View (Frontend)** | JSP / JSTL | 3.0.x | Kỹ thuật dựng trang phía Server với Jakarta Server Pages |
| **Styling & Components**| Bootstrap / FontAwesome | 5.x / 6.x | Thiết kế giao diện responsive hiện đại |
| **Logic Client** | Vanilla Javascript | — | Xử lý tương tác, biểu đồ Dashboard và validate form |
| **Backend Framework** | Jakarta EE API | 10.0.0 | Nền tảng phát triển ứng dụng Java Web doanh nghiệp |
| **Servlet Specification**| Jakarta Servlet | 6.0 | Tiếp nhận định tuyến URL và điều khiển luồng |
| **Database Connection** | HikariCP | 5.1.0 | Thư viện quản lý Pool kết nối cơ sở dữ liệu hiệu năng cao |
| **Database Driver** | Microsoft JDBC Driver | 12.4.2 | Driver kết nối Java đến MS SQL Server |
| **Database Engine** | SQL Server | 2019+ | Hệ quản trị cơ sở dữ liệu quan hệ |
| **Password Hashing** | jBCrypt | 0.4 | Mã hóa mật khẩu người dùng an toàn |
| **Log Management** | SLF4J / Logback | 1.4.14 | Ghi nhật ký hoạt động hệ thống |
| **Email Service** | Jakarta Mail | 2.1.2 | API gửi mail khôi phục mật khẩu |
| **Build & Run Tool** | Maven / Tomcat | 3.8+ / 10.1.x| Trình quản lý dependency và máy chủ ứng dụng |

---

## Yêu cầu hệ thống

### Phần mềm cài đặt trên máy phát triển
- **Java JDK**: Phiên bản `17` trở lên.
- **Apache Tomcat**: Phiên bản `10.1.x` (bắt buộc hỗ trợ Jakarta EE 10, các bản Tomcat 9 trở xuống dùng Java EE cũ sẽ lỗi import).
- **Microsoft SQL Server**: Phiên bản `2019` hoặc mới hơn.
- **Build Tool**: Apache Maven `3.8.x` trở lên (hoặc sử dụng trình đóng gói Maven tích hợp sẵn trong IDE).
- **IDE**: NetBeans, IntelliJ IDEA, Eclipse hoặc VS Code (có cài đặt Extension Pack for Java và Community Server Connector).

### Phần cứng khuyến nghị
- **RAM**: Tối thiểu 8 GB.
- **CPU**: Bộ vi xử lý Core i5 thế hệ 8 hoặc tương đương trở lên.

---

## Cài đặt & Chạy dự án

### 1. Clone Source Code
```bash
git clone <url_repository_nhom_ban>
cd Hotel-Management-main
```

### 2. Thiết lập Cơ sở dữ liệu SQL Server
- Mở SQL Server Management Studio (SSMS).
- Mở tệp tin script SQL nằm tại đường dẫn: `sql/hotel_management.sql`.
- Nhấn **Execute** (F5) để khởi tạo Database `HotelManagementDB`, các bảng liên quan cùng với dữ liệu mẫu (Seeded Data bao gồm 30 khách hàng, lịch đặt phòng, hóa đơn và các tài khoản thử nghiệm).

### 3. Cấu hình Kết nối Cơ sở dữ liệu
Mở file [DBContext.java](file:///d:/Java/SWP/Clone/Hotel-Management-main/src/main/java/com/mycompany/hotelmanagement/config/DBContext.java) và chỉnh sửa thông tin tài khoản kết nối SQL Server của bạn (dòng 29-30):
```java
config.setUsername("sa"); // Tài khoản SQL Server của bạn
config.setPassword("123"); // Mật khẩu SQL Server của bạn
```

### 4. Cấu hình Dịch vụ gửi Mail và Google OAuth
Mở file [config.properties](file:///d:/Java/SWP/Clone/Hotel-Management-main/src/main/resources/config.properties) để chỉnh sửa các thông số:
- Cấu hình ID xác thực Google phục vụ đăng nhập: `GOOGLE_CLIENT_ID` và `GOOGLE_CLIENT_SECRET`.
- Cấu hình tài khoản email hệ thống gửi thư: `SMTP_USER` và `SMTP_PASSWORD` (sử dụng Mật khẩu ứng dụng - App Password của Gmail).

### 5. Build và Deploy lên Apache Tomcat
- **Sử dụng dòng lệnh Maven**:
  ```bash
  mvn clean package
  ```
  Sau khi build xong, copy file `.war` tạo ra trong thư mục `target/` vào thư mục `webapps/` của máy chủ Apache Tomcat 10.1.
- **Sử dụng IDE (NetBeans/IntelliJ)**:
  - Add dự án Maven vào IDE.
  - Cấu hình Server Run Target trỏ đến thư mục cài đặt Tomcat 10.1.
  - Chạy dự án trực tiếp bằng cách click nút **Run** (IDE sẽ tự động build, tạo WAR và hot-deploy lên Tomcat).
  - Truy cập địa chỉ mặc định: `http://localhost:8080/HotelManagementSystem/` hoặc `http://localhost:8080/` tùy thuộc vào cấu hình Context Path của Tomcat.

---

## Cấu trúc dự án

Dưới đây là sơ đồ cấu trúc thư mục của dự án **Hotel-Management**:

```
Hotel-Management-main/
├── sql/
│   └── hotel_management.sql              # Script SQL khởi tạo schema DB & seed dữ liệu
├── src/
│   └── main/
│       ├── java/
│       │   └── com/mycompany/hotelmanagement/
│       │       ├── config/               # Cấu hình kết nối DB, Email, đọc Properties
│       │       │   ├── DBContext.java    # HikariCP DataSource Provider
│       │       │   ├── ConfigUtil.java   # Helper đọc config.properties
│       │       │   └── EmailUtil.java    # Xử lý gửi email xác nhận đặt lại mật khẩu
│       │       ├── entity/               # Các lớp Model chứa thông tin đối tượng dữ liệu
│       │       │   ├── Account.java
│       │       │   ├── Booking.java
│       │       │   ├── CustomerRequest.java
│       │       │   ├── Room.java
│       │       │   └── ...
│       │       ├── dal/                  # Lớp Repositories/DAOs thực thi SQL
│       │       │   ├── AccountRepository.java
│       │       │   ├── BookingDAO.java
│       │       │   ├── CustomerRequestDAO.java
│       │       │   ├── RoomRepository.java
│       │       │   └── ...
│       │       ├── service/              # Xử lý các logic nghiệp vụ (Business Service)
│       │       │   ├── AuthService.java
│       │       │   ├── RoomTypeService.java
│       │       │   └── ...
│       │       ├── filter/               # Bộ lọc Servlet Filter kiểm soát request
│       │       │   ├── AuthFilter.java   # Phân quyền truy cập các role-based route
│       │       │   └── EncodingFilter.java # Filter thiết lập UTF-8 tiếng Việt
│       │       └── controller/           # Tầng tiếp nhận request, định tuyến luồng
│       │           ├── common/           # Login, Register, Home, RoomDetail, GoogleLogin
│       │           ├── admin/            # AdminDashboardController
│       │           ├── manager/          # Quản lý dịch vụ, loại phòng, phòng, hóa đơn
│       │           ├── receptionist/     # Xử lý check-in, check-out, đặt phòng lễ tân
│       │           └── housekeeping/     # Nhiệm vụ dọn dẹp phòng, cập nhật trạng thái
│       │
│       ├── resources/
│       │   └── config.properties         # File cấu hình bảo mật Google Client ID & SMTP Mail
│       │
│       └── webapp/                       # Thư mục chứa tài nguyên giao diện web
│           ├── assets/                   # CSS, JS, hình ảnh, icon tĩnh
│           ├── WEB-INF/
│           │   ├── web.xml               # Cấu hình tệp tin chào mừng và Metadata của Servlet
│           │   ├── beans.xml             # Khởi tạo CDI bean (nếu có)
│           │   ├── includes/             # Các khối giao diện dùng chung (Header, Sidebar, Footer)
│           │   └── views/                # Thư mục chứa các trang giao diện JSP
│           │       ├── home/             # Trang chủ, đăng ký, đăng nhập, quên mật khẩu
│           │       ├── customer/         # Màn hình xem phòng, đặt phòng của khách hàng
│           │       ├── housekeeping/     # Danh sách công việc của nhân viên dọn phòng
│           │       ├── manager/          # Màn hình quản trị phòng, loại phòng, hóa đơn
│           │       └── dashboard/        # Màn hình Dashboard phân chia theo vai trò
│           └── index.html
│
├── pom.xml                               # File khai báo Maven dependencies & Plugins
└── README.md                             # Tài liệu giới thiệu nhanh dự án
```

---

<div align="center">

**HMS — Hotel Management System**  
SWP391_2026_06 | FPT University | Hà Nội, 2026

</div>
