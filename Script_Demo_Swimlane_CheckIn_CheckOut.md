# Kịch bản Demo Swimlane: Check-In / Check-Out (QuyPQ)

> Diagram (bản mới, đã bỏ node Assign room): **Customer – Receptionist – System** (Arrive → Verify → có đặt trước? / Walk-in → Check-in với companion + ảnh CCCD → System: CheckedIn + Occupied + Invoice unpaid → Sử dụng dịch vụ → Check-out → Invoice Paid + phòng Cleaning).
> Toàn bộ các bước dưới đây đã được đối chiếu với code thật, chạy đúng, **không đứt luồng**. Vì diagram không còn bước xếp phòng, data demo được chuẩn bị sẵn ở trạng thái **Confirmed + đã xếp phòng** (việc duyệt đơn/xếp phòng thuộc use case Process Booking Request diễn ra trước đó).

---

## 0. CHUẨN BỊ TRƯỚC DEMO (5 phút)

1. **Chạy app**: deploy Tomcat → `http://localhost:8080/HotelManagement`
   - ⚠️ **Cần có Internet**: bước check-in mới yêu cầu upload **ảnh căn cước (CCCD)** lên Cloudinary — mất mạng là check-in lỗi 500 ngay giữa demo.
2. **Chuẩn bị ảnh CCCD mẫu**: lưu sẵn **2 file ảnh** (jpg/png) ra Desktop, đặt tên dễ thấy:
   - `cccd_khach_demo.jpg` — cho khách đại diện (BẮT BUỘC khi check-in)
   - `cccd_nguoi_di_kem.jpg` — cho người đi kèm (tùy chọn, nhưng demo cho đẹp)
3. **Chạy SQL chuẩn bị data**: mở `sql/demo_swimlane_checkin_checkout.sql`:
   - Chạy **PHẦN A0** trước — bổ sung cột ảnh CCCD/phụ phí cho DB cũ (nếu DB tạo trước bản code mới, thiếu cột này thì check-in sẽ fail).
   - Chạy **PHẦN A**.
   - Kết quả: Booking **Confirmed** cho khách **"Tran Van Demo"** (nhận phòng HÔM NAY, trả NGÀY MAI), **đã được xếp sẵn 1 phòng cụ thể**, **đã cọc 30%** (giả lập chuyển khoản SePay), và **chưa có hóa đơn** — hóa đơn sẽ do hệ thống tạo đúng lúc check-in, khớp node "Create invoice with unpaid status" của diagram.
   - Ghi lại **Booking ID** và **số phòng** in ra ở tab Messages.
4. **Tài khoản dùng trong demo**:

   | Vai trò | URL đăng nhập | Email | Mật khẩu |
   |---|---|---|---|
   | Lễ tân | `/HotelManagement/staff/login` | `receptionist@hotel.com` | `receptionist123` |
   | Khách (tùy chọn) | `/HotelManagement/home/login` | `customer@hotel.com` | `customer123` |

5. Mở sẵn 2 tab trình duyệt: **Lễ tân** (dashboard) + **SSMS** (PHẦN B của file SQL để "soi" trạng thái System sau mỗi bước).

---

## 1. LUỒNG CHÍNH — NHÁNH "YES: CÓ ĐẶT PHÒNG TRƯỚC"

### Bước 1 — [Customer] *Arrive at the hotel with booking information*
🗣 *"Khách hàng Trần Văn Demo đã đặt phòng online từ trước — đơn đã được duyệt, xếp phòng và khách đã chuyển khoản cọc 30%. Hôm nay khách đến quầy lễ tân, cung cấp thông tin đặt phòng và giấy tờ tùy thân."*
- (Không thao tác — chỉ dẫn chuyện. Có thể mở tab khách hàng cho xem booking + đã cọc nếu muốn.)

### Bước 2 — [Receptionist] *Verify booking and identity documents* → rẽ nhánh **Yes**
- Đăng nhập lễ tân → sidebar **Nhận phòng (Check-in)** (`/receptionist/dashboard?tab=checkin`).
- Gõ tên **"Tran Van Demo"** (hoặc Booking ID) vào ô tìm kiếm → đơn hiện ra với nút check-in (tab này chỉ hiện đơn **Confirmed** — chính là "có đặt phòng trước").
- Mở **chi tiết check-in**: đối chiếu thông tin đặt phòng (tên, SĐT, ngày đến/đi) và **phòng đã được xếp sẵn** hiển thị trong trang; đồng thời nhận giấy tờ tùy thân của khách.
- 🗣 *"Lễ tân đối chiếu thông tin đặt phòng với giấy tờ của khách. Hệ thống xác nhận khách CÓ đặt phòng trước — ta đi theo nhánh Yes, chuyển thẳng sang thủ tục check-in."*
- 💡 (Tùy chọn) Chạy **PHẦN B** lúc này để chốt hiện trạng: booking **Confirmed**, phòng đã gán, **chưa có hóa đơn** — lát nữa so sánh với sau check-in.

### Bước 3 — [Receptionist] *Process check-in with companion* (kèm ảnh căn cước)
- Ngay trong trang **chi tiết check-in** đang mở → nhập theo thứ tự:
  1. **Ảnh CCCD khách đại diện** (`cccd_khach_demo.jpg`) — ô upload có preview, **BẮT BUỘC**, không chọn ảnh là form không cho submit.
  2. **Người đi kèm (companions)**: bấm thêm dòng → nhập tên "Nguyễn Thị B" (bắt buộc) + **ảnh CCCD người đi kèm** (`cccd_nguoi_di_kem.jpg`, tùy chọn) + chọn **độ tuổi** (Dưới 6 tuổi / Trẻ em 6-14 / Người lớn từ 15).
  3. Special request / ghi chú (tùy ý).
- 💡 **Điểm cộng khi demo**: nếu thêm số người **vượt sức chứa phòng**, hệ thống tự hiện khung **"Phụ phí phát sinh"** tính theo độ tuổi × số đêm — có thể show nhanh rồi xóa bớt người để về 0 phụ phí.
- Bấm xác nhận check-in → ảnh được upload lên **Cloudinary** (chờ 1-2 giây) → quay về tab check-in với **toast "Đã check in thành công"**.
- 🗣 *"Theo quy định lưu trú, lễ tân thu nhận và lưu ảnh căn cước của khách đại diện — đây là bước bắt buộc — và ghi nhận cả người đi kèm kèm giấy tờ, độ tuổi. Nếu số người vượt sức chứa phòng, hệ thống tự động tính phụ phí. Sau đó lễ tân thực hiện check-in."*
- 💡 Mở lại chính trang chi tiết check-in sau khi xong: với booking đã CheckedIn, trang hiển thị lại **ảnh CCCD đã lưu** + danh sách người đi kèm — bằng chứng trực quan hệ thống đã lưu giấy tờ.

### Bước 4 — [System] *Set booking status to checked-in and room status to occupied* + *Create invoice for customer with unpaid status*
- Chạy lại **PHẦN B** và so với trước check-in: booking = **CheckedIn**, có bản ghi `CheckIn` (kèm cột `customer_cccd_image` = link Cloudinary ảnh căn cước, `extra_fee`) + `CheckInCompanion` (tên, độ tuổi, ảnh CCCD người đi kèm), và **Invoice VỪA xuất hiện với trạng thái Pending (unpaid)** — trước check-in query này trả về rỗng, khớp chính xác node "Create invoice" của diagram.
- Mở tab **Sơ đồ phòng** (`?tab=roommap`) → phòng của khách hiển thị **Occupied** (màu đỏ).
- 🗣 *"Hệ thống tự động: booking sang Checked-In, phòng sang Occupied, và tạo hóa đơn cho khách ở trạng thái chưa thanh toán."*

### Bước 5 — [Customer] *Stay and using hotel services*
- Lễ tân → **`/receptionist/add-booking-service`**: chọn phòng đang CheckedIn của khách → thêm dịch vụ (nước suối, giặt là...).
- 🗣 *"Trong thời gian lưu trú, khách sử dụng thêm dịch vụ; các dịch vụ này được cộng dồn vào hóa đơn."*
- 💡 **Dự phòng**: nếu không muốn demo màn thêm dịch vụ, chạy **PHẦN C** trong file SQL để chèn sẵn 2 dịch vụ vào hóa đơn.

### Bước 6 — [Customer → Receptionist] *Request check-out* → *Review final charges*
- 🗣 *"Đến ngày trả phòng, khách yêu cầu check-out."*
- Sidebar → **Trả phòng & Thanh toán** (`?tab=checkout`) → chỉ liệt kê các booking **CheckedIn** → chọn khách → trang **chi tiết trả phòng** hiện:
  - Tiền phòng + tiền dịch vụ + phụ phí = **Tổng**
  - **Đã trả** (tiền cọc 30%) và **Còn lại phải thanh toán**
- 🗣 *"Lễ tân rà soát toàn bộ chi phí với khách: tiền phòng, dịch vụ, đã trừ khoản cọc."*

### Bước 7 — [Customer] *Settle remaining amount* → [System] *Completes check-out, marks invoices as Paid and set room to cleaning*
- Chọn **phương thức thanh toán** (Cash), ghi chú nếu cần → bấm **xác nhận trả phòng** → toast thành công.
- ✅ Chạy lại **PHẦN B** (chốt hạ của demo — khớp đúng node cuối diagram):
  - Booking = **CheckedOut**
  - Invoice = **Paid**
  - Phòng = **Cleaning** (mở lại Sơ đồ phòng cho trực quan)
- 🗣 *"Khách thanh toán nốt phần còn lại. Hệ thống hoàn tất check-out: hóa đơn Paid, phòng chuyển sang trạng thái chờ dọn dẹp cho bộ phận buồng phòng."* → **Kết thúc luồng.**

---

## 2. NHÁNH PHỤ — "NO: KHÁCH VÃNG LAI (WALK-IN)" (demo nhanh 1-2 phút)

> Không cần chuẩn bị data — chỉ cần còn phòng Available.

1. 🗣 *"Trường hợp khách đến trực tiếp không đặt trước, lễ tân tạo booking walk-in ngay tại quầy."*
2. Sidebar → **Đặt phòng tại quầy** (`?tab=walkin-bookings`):
   - Nhập tên khách mới (vd: "Lê Văn Vãng Lai"), SĐT **(bắt buộc)**, chọn ngày **hôm nay → mai** (ngày trả phải **sau** ngày nhận).
   - Chọn loại phòng, số lượng, **chọn đủ số phòng cụ thể**, nhập người đi kèm.
   - Chọn chế độ **Check-In ngay** (bookingMode = CHECKIN) → Lưu.
3. ✅ Hệ thống tạo booking **CheckedIn** ngay + bản ghi CheckIn + companion + **Invoice unpaid** trong 1 giao dịch — đúng nhánh "No" của diagram (Create walk-in booking → nhập lại luồng check-in).
   - ℹ️ Lưu ý: màn walk-in **hiện chưa có bước upload ảnh CCCD** (chỉ luồng check-in từ booking Confirmed mới yêu cầu ảnh). Khi thuyết trình nên demo phần ảnh căn cước ở **nhánh chính**; nếu bị hỏi thì trả lời: "với walk-in, ảnh giấy tờ được bổ sung ở phần cải tiến tiếp theo".
4. Sau đó luồng check-out **giống hệt Bước 6-7** ở trên.

---

## 3. CÁC ĐIỂM DỄ "ĐỨT LUỒNG" & CÁCH XỬ LÝ

| # | Rủi ro | Nguyên nhân trong code | Cách xử lý |
|---|---|---|---|
| 1 | Booking **không hiện ở tab Check-in** | Tab chỉ hiện đơn `Confirmed/CheckedIn/CheckedOut` và là **đơn gốc** (`group_booking_id IS NULL`) | Dùng booking do PHẦN A tạo (đã Confirmed sẵn). Nếu tự tạo booking Pending qua UI thì phải duyệt đơn + xếp phòng ở màn Quản lý đặt phòng trước (nút "Xác nhận duyệt" chỉ mở khi đã cọc 30% — chạy `sql/test_force_deposit.sql` nếu cần) |
| 2 | Booking **không hiện ở tab Trả phòng** | Tab checkout chỉ liệt kê đơn `CheckedIn` | Phải hoàn tất check-in (Bước 3) trước |
| 3 | Walk-in báo lỗi "Thiếu phòng đã chọn" | Số phòng tick chọn < tổng số lượng khai báo | Chọn đủ số phòng cụ thể trước khi lưu |
| 4 | Walk-in báo lỗi ngày | Ngày trả phòng phải **sau** ngày nhận | Chọn hôm nay → ngày mai |
| 5 | Đăng nhập lễ tân bị đá về login | Sai URL đăng nhập | Nhân viên dùng `/staff/login`, không dùng `/home/login` |
| 6 | Checkout không thấy dịch vụ | Chưa thêm dịch vụ vào hóa đơn | Làm Bước 5 (UI) hoặc chạy PHẦN C (SQL) |
| 7 | Cột `Room.status` trong DB vẫn "Available" sau khi gán phòng | Trạng thái **Occupied trên Sơ đồ phòng được tính động** từ booking Confirmed/CheckedIn (cột status trong DB chỉ đổi thành Cleaning khi checkout) | Khi demo lane System ở Bước 4, hãy chỉ vào **Sơ đồ phòng** hoặc cột `display_status` trong query PHẦN B, đừng chỉ vào cột status thô |
| 8 | Form check-in **không submit được** | Thiếu **ảnh CCCD khách đại diện** (input có `required`) hoặc dòng người đi kèm thiếu tên | Chuẩn bị sẵn ảnh mẫu trên Desktop; xóa dòng companion thừa trước khi submit |
| 9 | Bấm check-in bị **lỗi 500 / error=exception** | Upload ảnh lên **Cloudinary** thất bại (mất Internet) hoặc DB cũ **thiếu cột** `image_url`/`extra_fee`/`age_range` | Kiểm tra mạng trước demo; chạy **PHẦN A0** của file SQL để bổ sung cột |
| 10 | PHẦN A báo "khong con phong trong hom nay" | Tất cả phòng của loại được chọn đã dính booking khác trong hôm nay | Chạy PHẦN D dọn data demo cũ rồi chạy lại PHẦN A, hoặc giải phóng bớt phòng |

## 4. DỌN DẸP SAU DEMO
Chạy **PHẦN D** trong `sql/demo_swimlane_checkin_checkout.sql` (điền booking id của đơn walk-in nếu có) — xóa toàn bộ dữ liệu demo và trả phòng về **Available**.
