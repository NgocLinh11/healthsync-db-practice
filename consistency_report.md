# Báo Cáo Phân Tích Bất Nhất Dữ Liệu (Consistency Gap Analysis Report)

## Tổng quan
Báo cáo này chỉ ra sự không nhất quán nghiêm trọng giữa UML Activity Diagram và thiết kế CSDL MySQL cũ (Legacy SQL) của hệ thống phòng khám HealthSync.

## 3 Điểm Vênh Nghiêm Trọng Nhất:

1. **Sai lệch mô hình quản lý vòng đời (Lifecycle Model Gap):**
   - *Nghiệp vụ (UML):* Lịch hẹn đi qua 5 trạng thái liên tục (`PENDING` -> `CONFIRMED` -> `CHECKED_IN` -> `COMPLETED` / `CANCELLED`).
   - *Legacy SQL:* Sử dụng `is_active BOOLEAN`. Thiết kế này khiến hệ thống hoàn toàn không thể nhận biết các trạng thái trung gian.

2. **Thiếu hụt dữ liệu tài chính & Vết hủy (Financial & Audit Gap):**
   - *Nghiệp vụ (UML):* Yêu cầu quản lý tiền cọc (`Deposit`), phạt tiền cọc (`Penalty Fee`) khi hủy muộn và lý do hủy lịch.
   - *Legacy SQL:* Bỏ sót toàn bộ các trường dữ liệu tài chính. Hậu quả là kế toán không thể đối soát dòng tiền và phòng khám không tra cứu được lý do hủy.

3. **Vắng mặt thực thể Đơn thuốc (Missing Entity Gap):**
   - *Nghiệp vụ (UML):* Bác sĩ xuất đơn thuốc gắn liền với lịch hẹn sau khi hoàn thành khám (`COMPLETED`).
   - *Legacy SQL:* Không có bảng `Prescriptions`. Điều này làm đứt gãy luồng nghiệp vụ cốt lõi của phòng khám.