# Staging runbook

Runbook này dành cho máy đã có Docker, n8n, Postiz và PostgreSQL staging. Sandbox phát triển không có các dịch vụ đó nên chỉ chạy được dry-run.

## 1. Apply state schema

Trên staging host, đặt `STATE_DATABASE_URL` trỏ tới database riêng của Media MVP, không dùng database nội bộ của n8n/Postiz:

```bash
export STATE_DATABASE_URL='postgresql://media_state:***@postgres-state:5432/media_state'
./pipeline/scripts/apply-state-schema.sh
```

Script dùng `ON_ERROR_STOP=1`; nếu thiếu `psql` hoặc URL sẽ dừng, không đoán cấu hình. Có thể xem trước bằng:

```bash
./pipeline/scripts/apply-state-schema.sh --dry-run
```

## 2. Import Error Workflow

1. Mở n8n staging, vào **Workflows → Import from file**.
2. Chọn `pipeline/n8n-error-handler-workflow.json`.
3. Gán Telegram credential staging cho node `Bao Telegram loi`.
4. Đặt biến `TELEGRAM_CHAT_ID` trong n8n staging.
5. Lưu workflow, ghi lại workflow ID.
6. Mở workflow content pipeline → **Settings → Error workflow** → chọn `NNTT - Error Handler`.
7. Test bằng cách tạm thời dùng một Code node `throw new Error('staging error test')`, chạy manual và xác nhận Telegram nhận cảnh báo.
8. Xóa node test hoặc khôi phục workflow trước khi bật lịch.

Sau khi lưu Error Workflow, ghi lại **workflow ID**. Trong phần Settings của cả
`NNTT - Content Pipeline` và `NNTT - Publish approved drafts (Postiz)`, chọn
workflow lỗi này. Không dùng tên workflow hoặc ID từ một instance n8n khác.

Không bật `active` cho Error Workflow trước khi credential đã được gán; không copy credential ID từ một instance khác.

## 3. Read-only Postiz check

Trên máy có thể truy cập Postiz staging:

```bash
export POSTIZ_BASE_URL='http://postiz:5000'
export POSTIZ_API_KEY='***' # nhập trực tiếp trên shell/secret manager, không commit
./pipeline/scripts/test-postiz-contract.sh --check
```

Lệnh `--check` chỉ đọc danh sách integrations. Nếu nhận `401/403`, dừng và sửa credential; không retry mù.

## 4. Create staging test

Chỉ chạy sau khi đã xác minh đúng Facebook integration ID staging và chấp nhận tạo một bài test được đặt lịch 15 phút sau:

```bash
export POSTIZ_FACEBOOK_INTEGRATION_ID='staging-integration-id'
export POSTIZ_CONFIRM_CREATE='I_UNDERSTAND_STAGING_POST'
./pipeline/scripts/test-postiz-contract.sh --create
```

Response phải được lưu ngoài Git sau khi xóa Authorization/token. Xác nhận bài nằm đúng staging/Page test, không phải Page production. Nếu API trả `400`, kiểm tra payload/provider schema; nếu `429` hoặc `5xx`, áp dụng backoff theo `POSTIZ_API_CONTRACT.md`.

## 5. Exit criteria

- [ ] State schema có đủ bốn bảng và unique constraints.
- [ ] Error Workflow gửi được cảnh báo lỗi giả lập.
- [ ] Read-only Postiz check trả 2xx.
- [ ] Staging create request trả 2xx với quote, emoji và newline.
- [ ] Không có token trong log, fixture hoặc commit.
- [ ] Chưa bật lịch production nếu chưa có `approved_at` và người duyệt thật.
