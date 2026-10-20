# Benchmark repo public và bài học áp dụng

Ngày khảo sát: 2026-10-20

Phạm vi khảo sát tập trung vào các thành phần mà repo hiện cần để đi từ proof-of-concept tới Media MVP: dữ liệu có lịch sử, automation có lỗi/quan sát được, self-hosting an toàn và kết nối social publishing.

## Những pattern đáng học

### farmOS — record/log là đơn vị dữ liệu, không phải một chuỗi thao tác rời

[farmOS](https://github.com/farmOS/farmOS) mô tả mình là nền tảng quản lý, lập kế hoạch và ghi chép hoạt động trang trại, được xây như một nền tảng chuẩn để nông dân, developer và researcher mở rộng. Bài học phù hợp với dự án này là mỗi RSS item, bản nháp, lần duyệt và lần đăng cần trở thành record có ID, trạng thái và timestamp; không nên chỉ truyền dữ liệu trực tiếp qua các node n8n. Repo đã thêm `pipeline/state-schema.sql` theo hướng này.

### n8n — lỗi phải là một workflow có chủ đích

Tài liệu n8n khuyến nghị tạo một workflow bắt đầu bằng Error Trigger, gán workflow đó vào workflow chính, lưu execution và gửi cảnh báo. Vì vậy repo thêm `pipeline/n8n-error-handler-workflow.json`; nó chưa được bật tự động vì cần người vận hành nhập Telegram credential và workflow ID trong instance n8n.

### Postiz — dùng Public API contract, không đoán endpoint/payload

README Postiz nêu rõ sản phẩm hỗ trợ scheduling, analytics, self-hosting và API; tài liệu Public API cung cấp endpoint `/public/v1/posts`, authentication bằng API key/OAuth token, schema riêng theo từng provider và rate limit cho create-post. Tài liệu cũng có SDK Node và custom n8n node. Vì vậy repo thêm `pipeline/POSTIZ_API_CONTRACT.md` và đánh dấu node hiện tại là staging-only cho tới khi có integration ID, request test và response fixture thật.

### FarmBot — ranh giới hệ thống và cảnh báo self-hosting phải rõ

README FarmBot tách web UI, REST JSON API và MQTT realtime server; đồng thời cảnh báo self-hosting cần năng lực vận hành và có rủi ro mất dữ liệu/bảo mật. Bài học cho dự án là tách Media MVP khỏi AIoT platform, không đưa sensor/automation sản xuất vào cùng workflow nội dung khi chưa có data contract và người vận hành.

### CommonGarden/awesome-open-ag — dùng như bản đồ hệ sinh thái, không dùng như dependency

Danh mục [awesome-open-ag](https://github.com/CommonGarden/awesome-open-ag) liệt kê farmOS, Tania, FarmData, ISOBlue và FarmBot theo các lớp farm management, connected machinery và open hardware. Nó hữu ích để định hướng GĐ6, nhưng bản thân là danh mục cũ và không phải nền tảng chạy production; repo mục tiêu không nên phụ thuộc vào nó.

## So sánh và quyết định cho repo này

| Pattern | Giá trị cho Media MVP | Quyết định |
|---|---|---|
| Record/log có trạng thái | Chống duplicate, truy vết chỉnh sửa và retry an toàn | Làm ngay bằng Postgres schema |
| Error Workflow | Biết lỗi RSS/Gemini/Postiz/Telegram và chạy lại có kiểm soát | Làm ngay bằng workflow mẫu |
| API contract theo provider | Tránh payload Postiz giả định và lỗi khi đổi phiên bản | Làm ngay bằng contract + request fixture |
| Tách platform theo boundary | Không trộn content media với AIoT quá sớm | Giữ ở roadmap GĐ6 |
| Ecosystem directory | Tìm hướng mở rộng và đối tác kỹ thuật | Chỉ dùng tham khảo, không coi là evidence production |

## Hành động ưu tiên

1. Chạy migration `pipeline/state-schema.sql` trên database được chọn và lưu `source_guid/url_hash` trước khi gọi Gemini.
2. Thêm trạng thái `discovered → eligible → drafted → needs_review → approved/rejected → scheduled → published/failed` vào mọi record.
3. Import workflow Error Trigger, nhập Telegram credential và kiểm tra cảnh báo bằng lỗi giả lập.
4. Tạo một Postiz integration test trên staging; lưu response đã ẩn token vào fixture, sau đó mới sửa node production.
5. Đo các KPI về duplicate rate, draft approval rate, publish failure rate và thời gian từ discovered tới approved trước khi tối ưu AI.

## References

[1]: https://github.com/farmOS/farmOS "farmOS README — farm management, planning and record keeping"
[2]: https://docs.n8n.io/flow-logic/error-handling/ "n8n documentation — Handle errors gracefully"
[3]: https://github.com/gitroomhq/postiz-app/blob/main/README.md "Postiz README — scheduling, analytics, self-hosting and API integrations"
[4]: https://docs.postiz.com/public-api "Postiz Public API — authentication, limits, errors and provider schemas"
[5]: https://github.com/FarmBot/Farmbot-Web-App/blob/staging/README.md "FarmBot Web App README — API, MQTT and self-hosting boundaries"
[6]: https://github.com/CommonGarden/awesome-open-ag "CommonGarden awesome-open-ag — open agriculture ecosystem map"
