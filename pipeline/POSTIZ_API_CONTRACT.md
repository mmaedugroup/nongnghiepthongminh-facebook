# Postiz Public API contract — staging

> Tài liệu chính thức: https://docs.postiz.com/public-api
>
> **Không dùng endpoint/payload trong tài liệu này cho production nếu chưa chạy request test trên đúng phiên bản Postiz đang self-host.**

## Base URL và authentication

- Base URL local trong mạng Docker: `http://postiz:5000`.
- Public API path: `/public/v1`.
- Header: `Authorization: <POSTIZ_API_KEY>` hoặc OAuth token bắt đầu bằng `pos_`.
- Không ghi token vào workflow JSON, log hoặc fixture.

## Tạo bài

Public API dùng `POST /public/v1/posts`. Payload có `type` (`schedule` hoặc `now`), `date`, `shortLink`, `tags`, và `posts[]`. Mỗi phần tử trong `posts[]` cần `integration.id`, `value[]` và `settings.__type`; Facebook có provider type `facebook`.

Ví dụ fixture đã ẩn thông tin thật:

```json
{
  "type": "schedule",
  "date": "2026-10-21T10:00:00.000Z",
  "shortLink": false,
  "tags": [],
  "posts": [{
    "integration": {"id": "STAGING_FACEBOOK_INTEGRATION_ID"},
    "value": [{"content": "Bản nháp staging", "image": []}],
    "settings": {"__type": "facebook"}
  }]
}
```

Workflow hiện tại của repo vẫn gọi endpoint legacy/giả định để tạo draft trong Postiz. Không bật lịch tự động dựa trên node đó. Trước khi sửa node, cần lưu một response staging đã ẩn token và chốt cách biểu diễn `needs_review` trong Postiz; Public API tạo post/schedule không đồng nghĩa với quy trình phê duyệt nội bộ.

## Lỗi, retry và giới hạn

Theo tài liệu API: `400` là body/path sai, `401` token sai, `403` không có quyền, `404` không có endpoint/resource, `413` payload quá lớn, `429` vượt rate limit và `5xx` cần retry có exponential backoff. Create-post có giới hạn mặc định 90 request/giờ cho self-host; có thể điều chỉnh bằng `API_LIMIT`.

Quy tắc retry của Media MVP:

- Không retry `400`, `401`, `403` nếu chưa sửa cấu hình.
- Retry tối đa 3 lần cho `429` và `5xx`, backoff 30s/120s/600s.
- Mỗi lần retry dùng cùng `idempotency_key` ở `publishing_jobs`.
- Sau lần cuối, ghi `failed`, lưu error code/message và gửi cảnh báo Telegram.
- Không log Authorization header hoặc payload chứa dữ liệu cá nhân.

## Điều kiện nghiệm thu staging

- [ ] Có integration ID Facebook staging.
- [ ] Request đúng `/public/v1/posts` và response 2xx.
- [ ] Nội dung có quote, emoji, newline vẫn tạo được.
- [ ] Retry 429/5xx không tạo duplicate.
- [ ] Không có request nào được gửi trước khi `approved_at` tồn tại.
- [ ] Response và error fixture đã ẩn token, được lưu trong thư mục test riêng.

## Sources

- [Postiz Public API](https://docs.postiz.com/public-api)
- [Postiz README](https://github.com/gitroomhq/postiz-app/blob/main/README.md)
