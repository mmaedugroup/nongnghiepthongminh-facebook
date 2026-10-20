# Chính sách nội dung Media MVP

## Nguyên tắc biên tập

- AI chỉ tạo bản nháp; không tự động xuất bản.
- Mỗi bài có đúng một trụ cột: mô hình thực tế, kiến thức khoa học hoặc mẹo áp dụng ngay.
- Nguồn gốc phải được lưu bằng URL và ngày truy cập. Không sao chép nguyên văn; việc diễn giải phải giữ đúng điều kiện, đơn vị và phạm vi của nguồn.
- Số liệu, tuyên bố về năng suất/chi phí/tiết kiệm và khuyến nghị kỹ thuật phải có nguồn hoặc bị đưa vào hàng chờ kiểm tra.

## An toàn nông nghiệp

Không đăng liều lượng thuốc bảo vệ thực vật, phân bón, xử lý bệnh, thiết kế điện/nước hoặc hướng dẫn có thể gây hại nếu không có nguồn chuyên môn và người có năng lực rà soát. Khi chưa đủ dữ liệu, dùng ngôn ngữ thử nghiệm có kiểm soát và khuyến nghị hỏi cán bộ kỹ thuật địa phương.

Bài có nội dung khuyến nghị phải ghi rõ điều kiện áp dụng và không thay thế tư vấn chuyên môn. Không suy đoán nguyên nhân bệnh chỉ từ ảnh hoặc mô tả ngắn.

## Quy trình trạng thái

`discovered → eligible → drafted → needs_review → approved/rejected → scheduled → published/failed`

Chỉ người duyệt mới được chuyển sang `approved`; workflow không được gọi API đăng thật trước trạng thái đó. Mọi lần sửa, duyệt, lỗi và phiên bản prompt/model cần được ghi vào audit log khi pipeline production được triển khai.

## Bản quyền và dữ liệu

Lưu license/attribution của ảnh, video, font, nhạc và asset tạo bởi dịch vụ bên ngoài. Không thu thập hoặc lưu thông tin cá nhân của thành viên group ngoài mục đích đã thông báo. Đặt thời hạn lưu dữ liệu RSS thô, nội dung nháp và log; khi có yêu cầu gỡ nội dung, dừng đăng và xử lý thủ công trước khi chạy lại.
