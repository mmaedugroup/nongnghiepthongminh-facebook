# Nông nghiệp thông minh và tử tế

> **Trạng thái kỹ thuật:** Media MVP đang ở giai đoạn dựng baseline local/staging. Repo chưa chứng minh
> pipeline n8n/Postiz chạy end-to-end và chưa được phép tự động đăng production.

> Mô hình kinh tế – xã hội nông nghiệp thông minh, thí điểm tại **Bà Rịa – Vũng Tàu**.
> Giúp hộ nông dân nhỏ lẻ, công nhân chuyển nghề và chủ trang trại ứng dụng công nghệ cao,
> AI, AIoT và tự động hóa trong sản xuất — liên kết mua chung, bán chung, truy xuất nguồn gốc,
> đạt chuẩn VietGAP/GlobalGAP. Tham khảo mô hình Moshav (Israel), hợp tác xã Nhật Bản, Hàn Quốc.

## Kênh truyền thông

**Fanpage + Group Facebook: "Nông nghiệp thông minh và tử tế"** (ra mắt trong 2–4 tuần)

| Quyết định | Nội dung |
|---|---|
| Cấu trúc | Fanpage đăng nội dung + Group làm cộng đồng thảo luận |
| Mục tiêu 3–6 tháng đầu | Lan tỏa kiến thức |
| Định dạng | Kết hợp linh hoạt (video ngắn + bài viết + ảnh) |
| Tần suất | 3–4 bài/tuần, xoay vòng 3 trụ cột |
| 3 trụ cột nội dung | Mô hình thực tế · Kiến thức khoa học · Mẹo hay áp dụng ngay |
| Nguồn nội dung | Tổng hợp từ nguồn quốc tế, biên tập lại cho nông dân Việt Nam |
| Vận hành | AI tạo bản nháp → người duyệt → đăng; AI hỗ trợ kiểm duyệt group |
| Ngân sách tool | Ưu tiên miễn phí (0đ) |

Chi tiết: [`docs/ke-hoach-kenh-facebook.md`](docs/ke-hoach-kenh-facebook.md)

## Pipeline tự động hóa nội dung (0đ tiền tool)

```
RSS quốc tế → n8n → Gemini API (free): dịch + viết lại tiếng Việt
→ Ảnh minh họa (Pollinations.ai) → Bản nháp trong Postiz
→ Telegram báo duyệt → Bạn duyệt → Tự động đăng Fanpage
```

Video (1 video/tuần): kịch bản (Gemini) → giọng đọc (Edge-TTS, free)
→ ghép ảnh/stock + phụ đề (ffmpeg) → Reel 9:16.

> ⚠️ **Lưu ý quan trọng:** Meta đã đóng Groups API từ tháng 4/2024 —
> không tool nào tự động đăng bài vào Group được nữa.
> Pipeline tự động đăng lên **Fanpage**; bài quan trọng share thủ công vào **Group**.

Chi tiết kiến trúc: [`pipeline/ARCHITECTURE.md`](pipeline/ARCHITECTURE.md)

Định hướng tự động hóa sản xuất và publish đa nền tảng: [`docs/MULTI-PLATFORM-AUTOMATION.md`](docs/MULTI-PLATFORM-AUTOMATION.md)

Kiến trúc thử nghiệm tách riêng luồng YouTube và Facebook, dùng chung Gemini content pack
và tận dụng OpenShorts/Hugging Face cho media: [`docs/AUTOMATION-ARCHITECTURE-YOUTUBE-FACEBOOK.md`](docs/AUTOMATION-ARCHITECTURE-YOUTUBE-FACEBOOK.md)

### Chạy baseline local

```bash
cp .env.example .env
# thay mọi giá trị replace-* trong .env
docker compose --env-file .env -f pipeline/docker-compose.yml config
docker compose --env-file .env -f pipeline/docker-compose.yml up -d
```

Các cổng n8n/Postiz chỉ bind vào `127.0.0.1`. Khi chuyển sang VPS phải đặt reverse proxy + HTTPS,
kiểm thử backup/restore và không mở trực tiếp cổng quản trị ra Internet. Xem
[`docs/trien-khai-pipeline/huong-dan-chon-vps.md`](docs/trien-khai-pipeline/huong-dan-chon-vps.md).

Chính sách claims, an toàn nông nghiệp, bản quyền và quy trình duyệt nằm trong
[`docs/CONTENT_POLICY.md`](docs/CONTENT_POLICY.md).

Các bài học từ repo public và quyết định áp dụng được ghi trong
[`docs/REFERENCES-AND-BENCHMARKS.md`](docs/REFERENCES-AND-BENCHMARKS.md). State store chuẩn hóa nằm ở
[`pipeline/state-schema.sql`](pipeline/state-schema.sql); contract Postiz staging nằm ở
[`pipeline/POSTIZ_API_CONTRACT.md`](pipeline/POSTIZ_API_CONTRACT.md).

Khi có máy staging, làm theo [`pipeline/STAGING_RUNBOOK.md`](pipeline/STAGING_RUNBOOK.md). Hai script
`pipeline/scripts/apply-state-schema.sh` và `pipeline/scripts/test-postiz-contract.sh` mặc định chỉ
dry-run; lệnh tạo bài staging yêu cầu cờ xác nhận riêng và không chạy được nếu thiếu credentials.

## Cấu trúc repo

```
├── README.md                              # Tổng quan dự án
├── PROJECT_PLAN.md                        # Kế hoạch + checklist cho AI tiếp tục
├── docs/
│   ├── bo-cau-hoi-dinh-hinh-du-an.md   # 65 câu hỏi định hình + câu trả lời
│   ├── ke-hoach-kenh-facebook.md       # Kế hoạch kênh Facebook chi tiết
│   ├── CONTENT_POLICY.md                # Policy nội dung và kiểm duyệt
│   ├── AUTOMATION-ARCHITECTURE-YOUTUBE-FACEBOOK.md # Kiến trúc hai luồng YouTube/Facebook
│   └── setup-kenh/                     # Bộ setup khi tạo kênh
│       ├── mota-fanpage.md             # Mô tả fanpage (copy-paste khi tạo trang)
│       ├── noi-quy-group.md            # Mô tả + nội quy + câu hỏi tham gia group
│       └── lich-noi-dung-2-tuan-dau.md # Lịch 8 bài mở đầu chi tiết
├── pipeline/
│   ├── ARCHITECTURE.md                 # Kiến trúc pipeline tự động hóa
│   ├── docker-compose.yml              # Dựng n8n + Postiz bằng 1 lệnh
│   ├── n8n-workflow-content-pipeline.json  # Workflow mẫu import vào n8n
│   ├── n8n-error-handler-workflow.json # Workflow Error Trigger mẫu
│   ├── state-schema.sql                 # Source/draft/publishing/audit tables
│   ├── POSTIZ_API_CONTRACT.md           # Contract staging theo Public API
│   └── rss-sources.md                  # Nguồn RSS quốc tế đã kiểm chứng
├── .env.example                          # Mẫu biến môi trường, không phải secret
├── .github/workflows/validate.yml        # CI kiểm tra cấu hình và link
└── demo-video-ai/
    ├── index.html                      # Demo app tạo video AI (mở bằng Chrome)
    └── README.md
```

## Tài liệu gốc

- File Word gốc: `01-bo-cau-hoi-dinh-hinh-du-an.docx` (bản markdown đầy đủ tại `docs/bo-cau-hoi-dinh-hinh-du-an.md`)

## Giấy phép

Chưa xác định — sẽ bổ sung khi dự án chốt mô hình tổ chức.
