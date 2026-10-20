# Hướng dẫn chọn hạ tầng cho Media MVP

## Quyết định đề xuất

Bắt đầu bằng **phương án B — máy cá nhân** để kiểm thử khô (dry-run) trong 1–2 tuần. Chỉ chuyển sang VPS sau khi pipeline đã có một vòng RSS → bản nháp → người duyệt chạy ổn định và có backup/restore test.

## Phương án A — VPS Always Free hoặc VPS nhỏ

Phù hợp khi cần chạy lịch 24/7. Trước khi chọn nhà cung cấp, xác nhận tại thời điểm triển khai: vùng khả dụng, giới hạn tài nguyên, điều kiện tài khoản, chính sách thu hồi máy idle, phí phát sinh và khả năng snapshot/backup.

Checklist tối thiểu:

- Docker Compose và cập nhật bảo mật tự động.
- Reverse proxy với HTTPS; không mở trực tiếp cổng n8n/Postiz ra Internet.
- Firewall chỉ cho SSH đã giới hạn IP và cổng HTTPS.
- Backup mã hóa cho dữ liệu n8n/Postiz/Postgres, kèm kiểm thử restore.
- Monitoring dung lượng đĩa, RAM, lỗi container và thời điểm chạy workflow.

## Phương án B — máy cá nhân

Dùng cho local/staging, không phải vận hành liên tục. Copy `.env.example` thành `.env`, thay toàn bộ giá trị mẫu rồi chạy:

```bash
cp .env.example .env
docker compose --env-file .env -f pipeline/docker-compose.yml up -d
```

Các cổng chỉ bind vào `127.0.0.1`. Nếu cần truy cập từ máy khác, dùng VPN hoặc reverse proxy có xác thực; không đổi thành `0.0.0.0` chỉ để tiện thử.

## Tiêu chí chuyển sang VPS

Chỉ chuyển khi tất cả điều kiện sau đạt:

- [ ] Workflow không xử lý trùng khi chạy lại cùng RSS item.
- [ ] Nội dung LLM có schema, nguồn, claims và cảnh báo an toàn.
- [ ] Người duyệt là điều kiện bắt buộc trước khi schedule/publish.
- [ ] Đã chạy staging ít nhất 5 bài với quote, emoji, newline và nội dung dài.
- [ ] Có backup và restore test được ghi lại.
- [ ] Có người chịu trách nhiệm xử lý lỗi và dừng lịch đăng.
