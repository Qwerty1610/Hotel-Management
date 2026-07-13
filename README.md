# Hotel-Management (HotelOps)

Hệ thống quản lý khách sạn — Java 17, Jakarta EE 10 (Servlet/JSP), SQL Server, tích hợp thanh toán online qua SePay.

## 1. Yêu cầu môi trường

| Phần mềm | Phiên bản | Ghi chú |
|---|---|---|
| JDK | 17 | |
| Apache NetBeans | 17+ | Đã kèm Maven |
| Apache Tomcat | 10.1.x | Jakarta EE 10 (KHÔNG dùng Tomcat 9) |
| SQL Server | 2019+ / Express | Kèm SSMS để chạy script |

## 2. Cấu hình SQL Server

Chuỗi kết nối được khai báo trong `src/main/java/.../config/DBContext.java`:

```
jdbc:sqlserver://localhost:1433;databaseName=HotelManagementDB
username: sa
password: 123
```

Trên máy mới cần đảm bảo 3 điều (hoặc sửa `DBContext.java` theo máy mình):

1. **Bật SQL Server Authentication** và tài khoản `sa` với mật khẩu `123`
   (SSMS → chuột phải server → Properties → Security → chọn "SQL Server and Windows Authentication mode", rồi bật login `sa`).
2. **Bật TCP/IP port 1433**: mở *SQL Server Configuration Manager* → SQL Server Network Configuration → Protocols → TCP/IP = Enabled, tab IP Addresses → IPAll → TCP Port = `1433` → restart service SQL Server.
   (Bắt buộc với bản Express vì mặc định dùng dynamic port.)
3. **Chạy script tạo DB**: mở `sql/hotel_management.sql` trong SSMS và Execute — script idempotent, tạo database `HotelManagementDB`, toàn bộ bảng (gồm bảng `Payment` cho SePay) và dữ liệu mẫu.
   Nếu DB đã có từ trước, chạy thêm `sql/sepay_payment.sql` để bổ sung bảng thanh toán.

**Tài khoản mẫu** (từ seed): 30 khách hàng `cust01@hotel.com` → `cust30@hotel.com`, mật khẩu `customer123`. Các tài khoản có sẵn dữ liệu test thanh toán: `cust25`–`cust27` (hóa đơn chờ thanh toán), `cust28` (booking chờ cọc).

## 3. Tạo file config.properties (bắt buộc)

File cấu hình thật **không được commit** (đã gitignore). Trên máy mới:

```
copy src\main\resources\config.properties.example src\main\resources\config.properties
```

rồi mở `config.properties` điền giá trị thật:

```properties
# SePay - xin giá trị thật từ người giữ tài khoản SePay của nhóm
sepay.bank.account=<tham số acc trong "Mã nhúng QR" trên my.sepay.vn>
sepay.bank.code=BIDV
sepay.account.holder=<tên chủ TK viết hoa không dấu>
sepay.webhook.apikey=<API key webhook của nhóm>
sepay.payment.prefix=HD
sepay.deposit.prefix=COC

# Google OAuth2 / SMTP: chỉ cần nếu dùng đăng nhập Google / gửi mail
```

Lưu ý: mỗi lần sửa `config.properties` phải **Clean and Build + Run lại** vì file được đóng gói vào WAR.

## 4. Chạy dự án

1. Mở project bằng NetBeans (File → Open Project).
2. Khai báo Tomcat 10.1 trong NetBeans (Tools → Servers) nếu chưa có.
3. Chuột phải project → **Clean and Build** → **Run**.
4. Truy cập: `http://localhost:8080/HotelManagement` (context path khai báo trong `src/main/webapp/META-INF/context.xml`).

## 5. Thanh toán SePay — test trên máy local

Luồng: khách quét QR chuyển khoản → SePay phát hiện tiền vào → gọi webhook `POST /api/sepay-webhook` → hệ thống khớp nội dung CK (`HD{mã hóa đơn}` hoặc `COC{mã booking}`) → cập nhật trạng thái.

### Cách A — Giả lập webhook (không cần ngrok, không cần tiền thật)

Chạy app xong, gửi request giả lập bằng PowerShell (sửa API key + nội dung + số tiền; trường `id` phải là số MỚI mỗi lần vì có ràng buộc chống trùng):

```powershell
Invoke-RestMethod -Method Post -Uri "http://localhost:8080/HotelManagement/api/sepay-webhook" `
  -Headers @{ Authorization = "Apikey <API_KEY_TRONG_CONFIG>" } `
  -ContentType "application/json" `
  -Body '{"id": 999001, "gateway": "BIDV", "transactionDate": "2026-07-08 15:30:00", "accountNumber": "x", "content": "HD25 chuyen tien", "transferType": "in", "transferAmount": 1350000, "referenceCode": "FT_TEST", "code": null, "subAccount": null, "accumulated": 0, "description": ""}'
```

### Cách B — Nhận webhook thật từ SePay (cần ngrok)

Webhook trên my.sepay.vn chỉ trỏ về **một URL duy nhất**, nên tại một thời điểm chỉ một máy nhận được webhook thật. Người muốn test:

1. Cài ngrok (https://ngrok.com/download), đăng ký free, nạp authtoken:
   `ngrok config add-authtoken <token>`
2. Lấy dev domain miễn phí tại https://dashboard.ngrok.com/domains rồi chạy:
   `ngrok http --url=<ten-domain>.ngrok-free.dev 8080`
3. Vào my.sepay.vn → Tích hợp Webhooks → sửa **URL nhận webhook** thành:
   `https://<ten-domain>.ngrok-free.dev/HotelManagement/api/sepay-webhook`
   (nhớ có `/HotelManagement`), chứng thực **API Key** trùng với `sepay.webhook.apikey`.
4. Quét QR chuyển khoản thật → xem SePay → Webhooks → Lịch sử gửi để debug (200 = OK, 401 = sai API key, 404 = sai URL).
