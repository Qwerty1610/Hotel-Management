# Hướng dẫn thêm UC Header Comment cho source code

## 1. Mục đích

Tài liệu này yêu cầu Agent đọc source code, lịch sử Git, SRS và Project
Tracking trước khi thêm comment ở đầu các file code thuộc phạm vi công việc
của **KhanhTD**.

Agent phải:

- Giải thích chính xác file/class đang làm gì.
- Ghi đúng Use Case liên quan.
- Xác định ngày file được tạo từ lịch sử Git.
- Ghi tác giả là `KhanhTD`.
- Chỉ bổ sung comment, không tự ý thay đổi logic chương trình.
- Tuân theo Oracle Java Coding Standards và coding convention hiện tại của
  project.

---

## 2. Phạm vi Use Case của KhanhTD

Chỉ ánh xạ một file vào Use Case khi source code thực sự triển khai hoặc hỗ
trợ trực tiếp cho Use Case đó.

### Room Browsing và Feedback

| UC ID | Use Case Name |
|---|---|
| UC-03 | Search Available Rooms |
| UC-29 | Browse Available Room Types |
| UC-30 | View Room Type Detail |
| UC-63 | View Room Type Reviews |
| UC-35 | Submit Stay Feedback |

### Customer Service Request

| UC ID | Use Case Name |
|---|---|
| UC-08 | View Available Services |
| UC-09 | Submit Service Request |
| UC-62 | View Service Request History |

### Receptionist Service Request

| UC ID | Use Case Name |
|---|---|
| UC-34 | View Service Requests |

### Manager Room Type Management

| UC ID | Use Case Name |
|---|---|
| UC-53 | View Room Type Records |
| UC-54 | Add Room Type |
| UC-55 | Edit Room Type |

### Manager Room Management

| UC ID | Use Case Name |
|---|---|
| UC-56 | View Room List |
| UC-57 | Add Room |
| UC-58 | Edit Room |

### Manager Service Management

| UC ID | Use Case Name |
|---|---|
| UC-59 | View Service Records |
| UC-60 | Add Service |
| UC-61 | Edit Service |

### Manager Promotion Management

| UC ID | Use Case Name |
|---|---|
| UC-46 | View Promotions |
| UC-64 | Add Promotion |
| UC-65 | Edit Promotion |

> Project Tracking và SRS hiện tại là nguồn chuẩn cho mã UC và tên UC.
> Không sử dụng mã UC cũ còn sót lại trong comment source code nếu mã đó
> mâu thuẫn với SRS hoặc Project Tracking.

---

## 3. Quy trình bắt buộc trước khi thêm comment

### Bước 1: Đọc toàn bộ file

Không được viết Description chỉ dựa vào tên class.

Phải xác định:

- Class thuộc tầng Controller, Service, DAO/Repository, Entity hay Utility.
- URL mapping hoặc action mà class xử lý.
- Dữ liệu đầu vào và validation quan trọng.
- Trạng thái nghiệp vụ được thay đổi.
- Redirect hoặc forward tới trang nào.
- Service, DAO hoặc Repository được gọi.
- Transaction hoặc thao tác database quan trọng.
- File hỗ trợ một hay nhiều Use Case.

### Bước 2: Đối chiếu UC

Đối chiếu theo thứ tự:

1. `Project Tracking Group 6`.
2. `SRS Document`.
3. Source code thực tế.
4. Tên file và đường dẫn package.

Không đoán UC chỉ dựa vào tên file.

Nếu một file hỗ trợ nhiều UC, phải liệt kê đầy đủ từng UC:

```java
 * Related Use Cases:
 * - UC-53 View Room Type Records
 * - UC-54 Add Room Type
 * - UC-55 Edit Room Type
```

### Bước 3: Kiểm tra lịch sử Git để lấy ngày tạo file

Ngày trong header là ngày file lần đầu được thêm vào repository, không phải
ngày hiện tại và không phải ngày sửa gần nhất.

Ưu tiên dùng lệnh:

```bash
git log --follow --diff-filter=A \
    --format="%ad" \
    --date=format:"%d-%m-%Y" \
    -- "src/main/java/path/FileName.java"
```

Nếu lệnh trên không trả kết quả, dùng:

```bash
git log --follow --reverse \
    --format="%ad" \
    --date=format:"%d-%m-%Y" \
    -- "src/main/java/path/FileName.java"
```

Lấy dòng đầu tiên của kết quả thứ hai.

Có thể kiểm tra commit tạo file bằng:

```bash
git log --follow --reverse \
    --format="%h | %ad | %an | %s" \
    --date=format:"%d-%m-%Y" \
    -- "src/main/java/path/FileName.java"
```

Quy tắc:

- Không tự đoán ngày.
- Không dùng ngày sửa cuối cùng.
- Phải dùng `--follow` để theo dõi file đã bị đổi tên.
- Nếu file chưa được commit hoặc Git không có lịch sử, dùng:
  `Date: Not available in Git history`.
- Không thay thế bằng ngày hiện tại để che giấu việc thiếu lịch sử.

### Bước 4: Kiểm tra comment hiện có

- Nếu file chưa có UC header: thêm header mới.
- Nếu file đã có header đúng format: cập nhật nội dung, không tạo header thứ
  hai.
- Nếu mã UC cũ hoặc sai: sửa theo SRS và Project Tracking.
- Nếu file có copyright/license header: giữ nguyên license ở đầu file và đặt
  UC header ngay sau license, trước câu lệnh `package`.
- Không xóa comment kỹ thuật vẫn còn giá trị.

---

## 4. Format bắt buộc cho file Java

Dùng đúng format sau:

```java
/**
 * Project: Hotel Management System
 * Class: ClassName
 *
 * Description:
 * Mô tả ngắn gọn bằng tiếng Việt về trách nhiệm thực tế của class.
 * Nêu các action chính, validation, thay đổi trạng thái, điều hướng
 * và việc ủy quyền xử lý cho Service hoặc DAO khi có liên quan.
 *
 * Related Use Cases:
 * - UC-xx Use Case Name
 *
 * Date: dd-MM-yyyy
 *
 * @author KhanhTD
 * @version 1.0
 */
```

Ví dụ cho `RoomTypeController`:

```java
/**
 * Project: Hotel Management System
 * Class: RoomTypeController
 *
 * Description:
 * Controller quản lý danh sách loại phòng cho Hotel Manager, xử lý hiển thị,
 * thêm, chỉnh sửa và xóa loại phòng. Class kiểm tra dữ liệu đầu vào, tên loại
 * phòng trùng lặp, điều hướng kết quả về trang quản lý và ủy quyền thao tác
 * lưu trữ cho RoomTypeService.
 *
 * Related Use Cases:
 * - UC-53 View Room Type Records
 * - UC-54 Add Room Type
 * - UC-55 Edit Room Type
 *
 * Date: 01-06-2026
 *
 * @author KhanhTD
 * @version 1.0
 */
```

Ngày trong ví dụ chỉ minh họa. Agent phải thay bằng ngày lấy từ Git.

---

## 5. Cách viết Description theo từng loại class

### Controller

Description nên đề cập:

- Actor sử dụng chức năng.
- URL hoặc nhóm action chính.
- Validation đầu vào quan trọng.
- Thay đổi trạng thái nghiệp vụ.
- Redirect hoặc forward.
- Service hoặc DAO được gọi.

Ví dụ cách diễn đạt:

> Controller xử lý các yêu cầu quản lý dịch vụ của Hotel Manager, bao gồm
> hiển thị danh sách, thêm, chỉnh sửa, bật/tắt và xóa dịch vụ. Class kiểm tra
> dữ liệu đầu vào, xử lý thông báo kết quả và ủy quyền nghiệp vụ cho
> HotelServiceService.

### Service

Description nên đề cập:

- Nghiệp vụ chính.
- Business Rule được kiểm tra.
- Transaction hoặc phối hợp nhiều DAO.
- Kết quả trả về cho Controller.

Không mô tả Service như Controller nếu class không xử lý request/response.

### DAO hoặc Repository

Description nên đề cập:

- Entity hoặc bảng dữ liệu được truy cập.
- Các thao tác tìm kiếm, thêm, sửa, xóa hoặc cập nhật trạng thái.
- Điều kiện truy vấn đặc biệt.
- Transaction support nếu có.

Không ghi rằng DAO “hiển thị trang” hoặc “redirect”.

### Entity hoặc Model

Description nên đề cập:

- Đối tượng nghiệp vụ được biểu diễn.
- Các thuộc tính chính.
- Logic nhỏ nằm trong entity như tính trạng thái hiệu lực, validation hoặc
  giá trị dẫn xuất.

Không gán mọi UC có sử dụng entity vào header. Chỉ liệt kê UC khi entity được
tạo hoặc sửa chủ yếu để hỗ trợ trực tiếp các UC của KhanhTD.

### JSP

Chỉ thêm header cho JSP khi được yêu cầu. Dùng JSP comment để không xuất
comment ra HTML:

```jsp
<%--
    Project: Hotel Management System
    File: file-name.jsp

    Description:
    Mô tả vai trò của trang JSP và dữ liệu được hiển thị.

    Related Use Cases:
    - UC-xx Use Case Name

    Date: dd-MM-yyyy
    Author: KhanhTD
    Version: 1.0
--%>
```

### JavaScript

Chỉ thêm khi được yêu cầu:

```javascript
/**
 * Project: Hotel Management System
 * File: file-name.js
 *
 * Description:
 * Mô tả hành vi giao diện mà file JavaScript xử lý.
 *
 * Related Use Cases:
 * - UC-xx Use Case Name
 *
 * Date: dd-MM-yyyy
 *
 * @author KhanhTD
 * @version 1.0
 */
```

---

## 6. Quy tắc về tác giả và phiên bản

### Author

Luôn ghi:

```java
@author KhanhTD
```

Không tự động lấy tên người tạo commit để thay thế `KhanhTD`.

Lịch sử Git chỉ được dùng để xác định ngày tạo file. Nếu cần báo cáo người tạo
commit, đưa thông tin đó vào báo cáo riêng, không thay đổi trường `@author`.

### Version

- File chưa có version: dùng `@version 1.0`.
- File đã có version hợp lệ: giữ nguyên.
- Không tự tăng version chỉ vì thêm comment.
- Không sử dụng version của Java, Maven hoặc project làm version của class.

---

## 7. Coding convention phải tuân theo

- Thụt lề 4 spaces.
- Không dùng tab để căn chỉnh Javadoc.
- Cố gắng giữ mỗi dòng không quá 80 ký tự.
- Một dòng Javadoc bắt đầu bằng ` * `.
- Có một dòng trống giữa các phần trong header.
- Class dùng PascalCase.
- Method và variable dùng camelCase.
- Constant dùng UPPER_SNAKE_CASE.
- Không thêm comment lặp lại điều code đã thể hiện rõ.
- Không thêm comment sai với hành vi thực tế.
- Không thay đổi package, import, annotation hoặc logic khi chỉ được yêu cầu
  thêm header.
- Không format toàn bộ file nếu việc đó tạo ra thay đổi ngoài phạm vi.

---

## 8. Các lỗi Agent không được mắc

Không được:

- Ghi ngày hiện tại mà không kiểm tra Git.
- Ghi một ngày giống nhau cho tất cả file.
- Lấy ngày commit sửa gần nhất làm ngày tạo.
- Ghi `Created by` trong header thay cho `@author`.
- Ghi tên tác giả khác `KhanhTD`.
- Dùng mã UC cũ trong source khi SRS đã đổi mã.
- Gán UC theo suy đoán.
- Liệt kê UC không liên quan trực tiếp.
- Tạo hai header trong cùng một file.
- Copy cùng một Description cho nhiều class khác chức năng.
- Mô tả Controller, Service và DAO giống nhau.
- Chèn header trước license bắt buộc.
- Thay đổi nghiệp vụ, query hoặc giao diện khi chỉ được yêu cầu comment.
- Ghi thông tin không thể kiểm chứng từ source code hoặc Git.

---

## 9. Quy trình thực hiện hàng loạt

Khi được yêu cầu comment toàn bộ code của KhanhTD:

1. Liệt kê các file dự kiến sửa.
2. Đọc từng file.
3. Ánh xạ file với UC.
4. Chạy Git history cho từng file.
5. Tạo hoặc cập nhật header.
6. Kiểm tra không trùng header.
7. Chạy `git diff --check`.
8. Chạy build hoặc test phù hợp nếu project cho phép.
9. Kiểm tra `git diff` để bảo đảm chỉ có thay đổi comment.
10. Xuất báo cáo kết quả.

Lệnh kiểm tra:

```bash
git diff --check
git diff --stat
git diff
```

Nếu project dùng Maven:

```bash
mvn -q -DskipTests compile
```

Nếu compile không thành công do môi trường hoặc cấu hình ngoài phạm vi, phải
báo rõ lỗi. Không được tuyên bố build thành công khi chưa chạy.

---

## 10. Format báo cáo sau khi hoàn thành

Agent phải báo cáo theo bảng:

| File | Class | Related UC | Git creation date | Result |
|---|---|---|---|---|
| `path/File.java` | `File` | UC-xx | dd-MM-yyyy | Added/Updated |

Sau bảng, báo rõ:

- Số file đã thêm header.
- Số file đã cập nhật header.
- File nào không có Git history.
- File nào chưa thể xác định UC.
- Build/test đã chạy và kết quả.
- Có hay không thay đổi logic.

---

## 11. Mệnh lệnh thực thi cho Agent

Khi nhận yêu cầu áp dụng tài liệu này, hãy thực hiện theo nguyên tắc:

> Đọc code trước, đối chiếu SRS và Project Tracking, kiểm tra ngày tạo bằng
> Git, sau đó mới thêm UC header. Tác giả luôn là KhanhTD. Chỉ sửa comment,
> không thay đổi logic và không bịa ngày hoặc mã UC.
