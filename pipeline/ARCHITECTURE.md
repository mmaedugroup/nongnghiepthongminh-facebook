# Kiến trúc Pipeline Tự động hóa Nội dung
## Dự án "Nông nghiệp thông minh và tử tế"

> Ngân sách tool: **0đ** (ưu tiên miễn phí) — Tần suất: **3–4 bài/tuần** — Chế độ: **AI tạo nháp → người duyệt → đăng**

---

## 1. Bức tranh tổng thể

```
NGUỒN (miễn phí)                XỬ LÝ (n8n tự host)                    ĐĂNG & DUYỆT
─────────────────               ──────────────────────                 ──────────────────

RSS quốc tế ──┐
(AgFunderNews, │   ┌──────────────────────────────────┐
 Future Farming│   │  n8n workflow "content-pipeline"  │
 FAO, ...     │   │                                  │   ┌──────────────┐
──────────────┘   │  1. Đọc RSS mỗi sáng             │   │   Postiz     │
                  │  2. Lọc theo 3 trụ cột:          │   │  (bản nháp)  │
                  │     - Mô hình thực tế            │──▶│              │──▶ Bạn duyệt ──▶ Đăng Fanpage
                  │     - Kiến thức khoa học         │   │              │    (1 click)      (tự động)
                  │     - Mẹo hay                   │   └──────────────┘
                  │  3. Gemini API (free):           │         │
                  │     dịch + viết lại tiếng Việt,  │         │ (bài quan trọng)
                  │     bản địa hóa cho nông dân VN  │         ▼
                  │  4. Tạo ảnh minh họa             │   Share thủ công
                  │     (Pollinations.ai, free)      │   vào Group
                  │  5. Đẩy bản nháp vào Postiz      │
                  │  6. Gửi Telegram báo "có bài    │
                  │     cần duyệt"                   │
                  └──────────────────────────────────┘

LUỒNG VIDEO (1 video/tuần, cho trụ cột "mô hình thực tế"):
  Chủ đề đã duyệt → Gemini viết kịch bản → Giọng đọc free (Edge-TTS)
  → Ghép ảnh/video stock (Pexels) + phụ đề (ffmpeg) → Video dọc 9:16
  → Đăng Fanpage dạng Reel (qua Postiz) → Share vào Group thủ công
```

---

## 2. Các thành phần (toàn bộ miễn phí)

| # | Thành phần | Vai trò | Tool | Giấy phép / Chi phí |
|---|-----------|---------|------|---------------------|
| 1 | **n8n** | Xương sống điều phối: đọc RSS → gọi AI → đẩy nháp → báo duyệt | n8n tự host (Docker) | Fair-code, tự dùng miễn phí |
| 2 | **Postiz** | Lịch đăng + nút duyệt + đăng tự động lên **Fanpage** | Postiz tự host (Docker) | AGPL-3.0, tự host miễn phí |
| 3 | **Gemini API** | Dịch + viết lại nội dung tiếng Việt, viết kịch bản video | Google AI Studio | Free tier, không cần thẻ (~1.500 req/ngày — dư cho 3–4 bài/tuần) |
| 4 | **Pollinations.ai** | Tạo ảnh minh họa cho bài viết | API công khai | Miễn phí, không cần key |
| 5 | **Edge-TTS** | Giọng đọc tiếng Việt cho video | Microsoft Edge Read Aloud | Miễn phí |
| 6 | **ffmpeg** | Ghép ảnh + giọng đọc + phụ đề thành video 9:16 | Dòng lệnh | Miễn phí, mã nguồn mở |
| 7 | **PostgreSQL + Redis** | Database cho n8n/Postiz | Docker | Miễn phí |

**Chi phí hạ tầng duy nhất:** nơi chạy Docker 24/7 — 2 phương án:
- **0đ tuyệt đối:** chạy trên máy tính cá nhân của bạn (cần máy bật khi đến giờ đăng).
- **~120k VNĐ/tháng:** VPS nhỏ (Hetzner/DigitalOcean) — ổn định, khuyến nghị khi kênh đã chạy đều.

---

## 3. Luồng chi tiết từng bước

### Luồng A — Bài viết + ảnh (3 bài/tuần)

1. **Thu thập (tự động, mỗi sáng):** n8n đọc RSS từ ~10 nguồn quốc tế (danh sách trong `rss-sources.md`), lấy bài mới trong 24h.
2. **Lọc trụ cột (tự động):** lọc theo từ khóa của 3 trụ cột — *mô hình thực tế* (farm, IoT, greenhouse, drone...), *kiến thức khoa học* (soil, fertilizer, disease...), *mẹo hay* (tips, save cost, yield...). Xoay vòng để mỗi tuần đủ 3 trụ cột.
3. **Viết lại (tự động):** Gemini API dịch + viết lại thành tiếng Việt đơn giản, thêm phần "Áp dụng ở Việt Nam thì sao?" (bản địa hóa) — bước này quan trọng nhất để nội dung quốc tế không bị xa rời nông dân trong nước.
4. **Ảnh minh họa (tự động):** Pollinations.ai tạo ảnh theo mô tả bài viết.
5. **Bản nháp (tự động):** đẩy vào Postiz ở trạng thái *draft*, đồng thời gửi tin nhắn Telegram cho bạn: "Có bài mới cần duyệt".
6. **Duyệt (thủ công, ~5 phút/bài):** bạn mở Postiz, đọc lướt, sửa nếu cần, bấm duyệt.
7. **Đăng (tự động):** Postiz đăng lên **Fanpage** theo lịch. Bài quan trọng → bạn share thủ công vào **Group** (xem mục 4).

### Luồng B — Video ngắn (1 video/tuần, trụ cột "mô hình thực tế")

1. Chọn 1 mô hình nổi bật nhất tuần từ Luồng A (bạn chọn khi duyệt).
2. Gemini viết kịch bản 45–60 giây, giọng văn kể chuyện.
3. Edge-TTS đọc kịch bản thành giọng tiếng Việt.
4. Lấy ảnh/video stock miễn phí (Pexels) + ffmpeg ghép thành video dọc 9:16, burn-in phụ đề.
5. Đẩy vào Postiz → bạn duyệt → đăng Fanpage dạng Reel → share vào Group thủ công.

### Luồng C — Kiểm duyệt Group (hỗ trợ bằng AI)

> **Nói thẳng:** Meta đã đóng Groups API từ tháng 4/2024 — **không tool nào** (kể cả Postiz, n8n, Buffer, Hootsuite) có thể tự động đăng/xóa/đọc bài trong Group qua API nữa.
> Vì vậy "AI hỗ trợ kiểm duyệt" được triển khai bằng:
> - **Công cụ có sẵn của Facebook:** bật *phê duyệt bài viết*, *cảnh báo từ khóa* (spam, bán hàng, link lạ), câu hỏi khi tham gia group.
> - **Quy trình thủ công nhẹ:** mỗi ngày bạn dành 10–15 phút duyệt bài chờ — với group mới thì khối lượng rất nhỏ.
> - Khi group lớn lên mới cần cân nhắc thêm mod hoặc tool trình duyệt.

---

## 4. Ràng buộc trung thực (đọc kỹ trước khi triển khai)

1. **Group không tự động đăng được.** Mọi nội dung vào Group đều qua tay người (share từ Page hoặc đăng trực tiếp + dùng lịch đăng sẵn của Facebook). Đây là giới hạn của Meta, không phải do tool kém.
2. **Gemini free tier đủ dùng** cho 3–4 bài/tuần (~12–16 bài/tháng, mỗi bài tốn vài request), nhưng Google có thể thay đổi giới hạn — pipeline có cơ chế báo lỗi rõ ràng khi hết quota.
3. **Video AI miễn phí không có text-to-video chất lượng cao.** Luồng video của mình là *ghép ảnh + giọng đọc + phụ đề* (kiểu video demo đã build), không phải video AI tạo hình chân thực như Veo/Runway (các tool đó đều trả phí).
4. **Postiz self-host cần Docker + chút kỹ thuật.** Nếu thấy nặng, phương án nhẹ hơn: bỏ Postiz, dùng thẳng node Facebook của n8n để đăng Page (kém đẹp hơn, mất giao diện duyệt).
5. **Nội dung AI luôn cần người duyệt** — đúng như bạn đã chọn. Đặc biệt với kiến thức nông nghiệp, một lời khuyên sai có thể gây thiệt hại thật.

---

## 5. Lộ trình 2–4 tuần (ngược từ ngày ra mắt)

| Tuần | Việc | Kết quả |
|------|------|---------|
| 1 | Dựng n8n + Postiz (Docker), kết nối Fanpage qua Facebook Graph API, lấy Gemini API key free | Hạ tầng chạy được |
| 2 | Nhập workflow mẫu (`n8n-workflow-content-pipeline.json`), cấu hình RSS + prompt viết lại, chạy thử Luồng A với 3–4 bài | Bài viết tự động đầu tiên |
| 3 | Dựng Luồng B (video), sản xuất 2 video thử nghiệm | Video đầu tiên |
| 4 | Sản xuất kho nội dung mở đầu (8–12 bài/video), thiết lập fanpage + group (mô tả, ảnh bìa, nội quy), **ra mắt** | Kênh đi vào hoạt động |

---

## 6. Nâng cấp sau này (khi có ngân sách hoặc nhu cầu)

- Thay Gemini free → trả phí (chỉ đổi API key, không viết lại).
- Video AI chân thực (Veo/Runway/HeyGen) cho 1 video/tuần.
- Thêm kênh: TikTok, YouTube Shorts (Postiz hỗ trợ sẵn).
- farmOS cho phần quản lý trang trại AIoT (giai đoạn 2 của dự án).
