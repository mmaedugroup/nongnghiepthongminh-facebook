# Kế hoạch kênh Facebook "Nông nghiệp thông minh và tử tế"

> Tổng hợp từ 10 câu hỏi định hình (thảo luận ngày 2026-10-19).
> Trạng thái: đã chốt định hướng — triển khai trong 2–4 tuần.

## 1. Cấu trúc kênh: cả hai

- **Fanpage**: kênh phát ngôn chính thức, đăng nội dung đều đặn, chạy quảng cáo, gắn tool đăng bài tự động.
- **Group**: cộng đồng nông dân/chủ trang trại hỏi đáp, chia sẻ kinh nghiệm thực tế.

## 2. Mục tiêu 3–6 tháng đầu: lan tỏa kiến thức

Đăng đều đặn về mô hình nông nghiệp công nghệ cao, AIoT, kiến thức khoa học và mẹo hay.

## 3. Định dạng: kết hợp linh hoạt

- **Video ngắn**: mô hình thực tế, câu chuyện người thật (dễ lan tỏa, hợp xem trên điện thoại).
- **Bài viết + ảnh**: kiến thức khoa học, mẹo hay (làm nhanh, duy trì đều đặn).

## 4. Tần suất: 3–4 bài/tuần

Đủ đều để Facebook ưu tiên hiển thị, vừa sức duy trì chất lượng (~12–16 nội dung/tháng).

## 5. Nguồn nội dung: tổng hợp từ quốc tế

App tự động tìm kiếm, dịch và biên tập lại từ các nguồn nông nghiệp công nghệ cao thế giới,
bản địa hóa cho phù hợp với nông dân Việt Nam (danh sách nguồn: `pipeline/rss-sources.md`).

## 6. Ba trụ cột nội dung (cân bằng)

| Trụ cột | Ví dụ | Định dạng chủ đạo |
|---|---|---|
| Mô hình thực tế | Trang trại AIoT thành công trên thế giới | Video ngắn |
| Kiến thức khoa học | Đất, phân bón, sâu bệnh, tưới tiêu | Bài viết + ảnh |
| Mẹo hay áp dụng ngay | Tiết kiệm chi phí, tăng năng suất | Bài viết + ảnh |

Lịch gợi ý mỗi tuần (3–4 bài): xoay vòng 3 trụ cột, 1 video/tuần cho mô hình nổi bật nhất.

## 7. Quy trình vận hành: AI tạo nháp → người duyệt → đăng

1. n8n tự động thu thập RSS → Gemini viết lại tiếng Việt → tạo ảnh minh họa.
2. Bản nháp đẩy vào Postiz + báo qua Telegram.
3. Người duyệt (~5 phút/bài), sửa nếu cần, bấm duyệt.
4. Postiz tự đăng lên **Fanpage** theo lịch.
5. Bài quan trọng → share thủ công vào **Group** (Meta đóng Groups API từ 4/2024 nên không tự động được).

## 8. Kiểm duyệt group: AI hỗ trợ

- Bật công cụ có sẵn của Facebook: phê duyệt bài viết, cảnh báo từ khóa (spam, bán hàng, link lạ), câu hỏi khi tham gia.
- Người xử lý các ca khó (~10–15 phút/ngày với group mới).

## 9. Ngân sách tool: ưu tiên miễn phí (0đ)

n8n + Postiz tự host, Gemini API free tier, Pollinations.ai, Edge-TTS, ffmpeg.
Chi phí hạ tầng duy nhất: nơi chạy Docker (0đ nếu dùng máy cá nhân, ~120k VNĐ/tháng nếu thuê VPS nhỏ).
Thiết kế cho phép nâng cấp lên trả phí sau này chỉ bằng cách thay API key.

## 10. Lộ trình ra mắt (2–4 tuần)

| Tuần | Việc |
|------|------|
| 1 | Dựng n8n + Postiz, kết nối Fanpage, lấy Gemini API key free |
| 2 | Nhập workflow mẫu, cấu hình RSS + prompt, chạy thử 3–4 bài |
| 3 | Dựng pipeline video, sản xuất 2 video thử nghiệm |
| 4 | Kho nội dung mở đầu (8–12 bài/video), thiết lập fanpage + group, **ra mắt** |

Kiến trúc kỹ thuật chi tiết: [`pipeline/ARCHITECTURE.md`](../pipeline/ARCHITECTURE.md)
