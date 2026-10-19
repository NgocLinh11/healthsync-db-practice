# AI Prompt Log - HealthSync Database Redesign

## Prompt 1: Tìm hiểu Anti-pattern trong theo dõi vòng đời
- **User:** "Trong thiết kế cơ sở dữ liệu quan hệ, tại sao việc dùng một cột is_active (kiểu TINYINT/BOOLEAN) để theo dõi vòng đời của một Đơn hàng/Lịch hẹn lại là một thiết kế tồi (Anti-pattern)? Tôi nên thay thế bằng cấu trúc nào?"
- **AI Response:** Phân tích lý do kiểu Boolean không mở rộng được và đề xuất sử dụng kiểu `ENUM` hoặc bảng tra cứu trạng thái (`Status Lookup Table`).

## Prompt 2: Lựa chọn kiểu dữ liệu tài chính
- **User:** "Khi thiết kế cột deposit_amount và penalty_fee trong MySQL phục vụ tính toán tài chính, tôi nên dùng kiểu dữ liệu FLOAT, DOUBLE hay DECIMAL? Tại sao?"
- **AI Response:** Khuyên dùng `DECIMAL(10,2)` do `FLOAT`/`DOUBLE` gặp lỗi làm tròn số thực dấu phẩy động (floating-point precision error), gây lệch tiền trong kế toán.

## Prompt 3: Bảo vệ toàn vẹn bằng Trigger
- **User:** "Làm sao để viết một Trigger trong MySQL ngăn không cho INSERT một dòng vào bảng Prescriptions nếu trạng thái của Appointment tương ứng chưa phải là 'COMPLETED'?"
- **AI Response:** Hướng dẫn cú pháp `DELIMITER //`, tạo `BEFORE INSERT TRIGGER` và sử dụng `SIGNAL SQLSTATE '45000'` để quăng lỗi (throw exception).