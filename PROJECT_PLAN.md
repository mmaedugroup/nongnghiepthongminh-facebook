# KẾ HOẠCH DỰ ÁN — Nông nghiệp thông minh và tử tế

> **File này là nguồn sự thật duy nhất (single source of truth) cho AI IDE/agent tiếp tục dự án.**
> Đọc toàn bộ file này trước khi làm bất kỳ việc gì. Cập nhật checklist khi hoàn thành một mục.

| Trường | Giá trị |
|---|---|
| Chủ dự án | mmaedgroup@gmail.com (GitHub: `mmaedugroup`) |
| Repo | https://github.com/mmaedugroup/nongnghiepthongminh-facebook |
| Trạng thái | GĐ 1 tài liệu hóa hoàn tất; GĐ 2 đang dựng baseline local/staging, chưa sẵn sàng production |
| Ngày cập nhật gần nhất | 2026-10-20 |
| Ngôn ngữ giao tiếp | Tiếng Việt |

---

## 1. Mục tiêu dự án

Xây dựng mô hình kinh tế – xã hội nông nghiệp thông minh, thí điểm tại **Bà Rịa – Vũng Tàu**:

- Giúp hộ nông dân nhỏ lẻ, người yếu thế, công nhân chuyển nghề và chủ trang trại ứng dụng
  công nghệ cao / AI / AIoT / tự động hóa trong sản xuất nông nghiệp.
- Liên kết các hộ nhỏ lẻ thành mạng lưới **mua chung – bán chung**, sản xuất đạt chuẩn
  **VietGAP/GlobalGAP**, có truy xuất nguồn gốc.
- Tham khảo mô hình **Moshav (Israel)**, hợp tác xã Nhật Bản – Hàn Quốc.
- Ưu tiên: tác động xã hội > cân bằng với tự chủ tài chính và tăng trưởng.

Chi tiết đầy đủ: `docs/bo-cau-hoi-dinh-hinh-du-an.md` (65 câu hỏi định hình + câu trả lời của chủ dự án).

**Việc đang làm hiện tại:** kênh truyền thông Facebook (fanpage + group) "Nông nghiệp thông minh và tử tế"
để lan tỏa kiến thức, là bước đi đầu tiên của dự án.

---

## 2. Nguyên tắc bắt buộc (không được phá)

- [ ] **Ngân sách tool = 0đ**: chỉ dùng tool miễn phí / free tier (Gemini API free, Pollinations.ai,
      Edge-TTS, n8n + Postiz tự host). Kiến trúc phải cho phép nâng cấp trả phí sau bằng cách thay API key.
- [ ] **Duyệt trước khi đăng**: AI chỉ tạo BẢN NHÁP. Con người duyệt rồi mới đăng. Không bao giờ tự ý đăng bài.
- [ ] **Credentials không đi qua chat/repo**: API key, token phải nhập qua form bảo mật của nền tảng
      hoặc file `.env` **không commit lên git** (đảm bảo `.env` nằm trong `.gitignore`).
- [ ] **Bản quyền nội dung**: pipeline chỉ *viết lại* từ nguồn quốc tế, không sao chép nguyên văn;
      luôn ghi nguồn trích dẫn cuối bài.
- [ ] **Hỏi trước khi hành động hệ trọng**: gửi mail, đăng bài, mua sắm, thay đổi quyền truy cập —
      phải có xác nhận của chủ dự án.

---

## 3. Sự thật kỹ thuật quan trọng (đã kiểm chứng 2026-10)

- **Meta đã đóng Facebook Groups API từ tháng 4/2024** (Graph API v19.0). Không có tool nào
  (kể cả Postiz, n8n, Buffer) đăng bài tự động vào Group được nữa.
  → Pipeline chỉ tự động đăng lên **Fanpage**. Bài quan trọng được **share thủ công** vào Group (~1 phút/bài).
- **AI hỗ trợ kiểm duyệt group** = chỉ dùng công cụ gốc của Facebook (phê duyệt bài,
  cảnh báo từ khóa, câu hỏi tham gia) — không có API đọc/xoá bài trong group.
- **Gemini API có free tier** (Flash/Flash-Lite, không cần thẻ, ~1.500 request/ngày) — dư cho 3–4 bài/tuần.
- **GitHub App `meta-muse-ai`** đã được cài vào repo này (quyền Contents write). Nếu đẩy code bị **403**,
  nghĩa là app chưa được cấp quyền trên repo đó — nhờ chủ dự án vào
  https://github.com/apps/meta-muse-ai/installations/new để chọn repo.

---

## 4. Quyết định đã chốt (do chủ dự án xác nhận ngày 2026-10-19)

| # | Hạng mục | Quyết định |
|---|---|---|
| 1 | Cấu trúc kênh | Cả hai: fanpage đăng nội dung + group làm cộng đồng |
| 2 | Mục tiêu 3–6 tháng đầu | Lan tỏa kiến thức |
| 3 | Định dạng nội dung | Kết hợp linh hoạt: video ngắn (mô hình/câu chuyện) + bài viết (kiến thức/mẹo) |
| 4 | Tần suất | 3–4 bài/tuần |
| 5 | Nguồn nội dung chính | Tổng hợp từ nguồn quốc tế, dịch + bản địa hoá |
| 6 | 3 trụ cột nội dung | Cân bằng: mô hình thực tế / kiến thức khoa học / mẹo hay áp dụng ngay |
| 7 | Chế độ đăng bài | Duyệt trước khi đăng (AI tạo nháp → người duyệt → đăng) |
| 8 | Kiểm duyệt group | AI hỗ trợ (công cụ gốc Facebook) + người xử lý ca khó |
| 9 | Thời điểm ra mắt | 2–4 tuần kể từ 2026-10-19 |
| 10 | Ngân sách tool AI | Ưu tiên miễn phí (0đ) |
| 11 | Quy tắc hỏi đáp | Hỏi từng câu một; khi có nhiều lựa chọn phải kèm đề xuất tối ưu + lý do |

---

## 5. Tiến độ tổng thể

- [x] **GĐ 1 — Tài liệu & thiết kế** (xong 2026-10-20)
- [ ] **GĐ 2 — Dựng pipeline tự động hoá** (baseline local/staging đã bổ sung; chưa chạy end-to-end)
- [ ] **GĐ 3 — Sản xuất kho nội dung mở đầu** (tuần 3–4)
- [ ] **GĐ 4 — Tạo kênh & ra mắt**
- [ ] **GĐ 5 — Vận hành thường xuyên & đo lường**
- [ ] **GĐ 6 — Mở rộng: app sản xuất AIoT** (dài hạn, sau khi kênh ổn định)

---

## 6. GĐ 1 — Tài liệu & thiết kế ✅ XONG

- [x] Đọc & chuyển file định hình dự án (65 Q&A) sang `docs/bo-cau-hoi-dinh-hinh-du-an.md`
- [x] Chốt 11 quyết định kênh (mục 4 ở trên) → `docs/ke-hoach-kenh-facebook.md`
- [x] Nghiên cứu repo GitHub cùng lĩnh vực → kết luận: **n8n** (automation), **Postiz** (đăng bài),
      **farmOS** (quản lý trang trại, dùng ở GĐ 6). ⚠️ Repo `facebook-auto-bot` không có giấy phép — chỉ đọc tham khảo.
- [x] Thiết kế kiến trúc pipeline → `pipeline/ARCHITECTURE.md`
- [x] Viết `pipeline/docker-compose.yml` (n8n + PostgreSQL + Redis + Postiz)
- [x] Viết workflow n8n mẫu → `pipeline/n8n-workflow-content-pipeline.json` (10 node, JSON hợp lệ, có validate structured output)
- [x] Liệt kê nguồn RSS → `pipeline/rss-sources.md` (AgFunderNews đã kiểm chứng hoạt động)
- [x] Bộ setup kênh → `docs/setup-kenh/` (mô tả fanpage, nội quy group, lịch nội dung 2 tuần đầu — 8 bài)
- [x] Demo app tạo video AI (chạy trong trình duyệt) → `demo-video-ai/index.html`
- [x] Viết hướng dẫn chọn hạ tầng 0đ (bản nháp, chờ duyệt) → `docs/trien-khai-pipeline/huong-dan-chon-vps.md`
- [x] Viết 2 bản nháp mẫu bài viết (bài 1 + bài 3 tuần 1) (bản nháp, chờ duyệt giọng văn) → `docs/ban-nhap-mau/bai-1-va-bai-3.md`

> GĐ1 chỉ được coi là hoàn tất về mặt tài liệu. Việc Docker, n8n, Postiz và API contract chạy thành công vẫn thuộc GĐ2.

---

## 7. GĐ 2 — Dựng pipeline tự động hoá (checklist chi tiết)

Kiến trúc: `RSS → n8n → Gemini (dịch + viết lại) → Pollinations.ai (ảnh) → Postiz (nháp)
→ Telegram báo duyệt → người duyệt → Postiz đăng Fanpage`.
Video 1/tuần: `kịch bản Gemini → Edge-TTS (giọng đọc) → ffmpeg ghép ảnh/phụ đề → Reel 9:16`.
Chi tiết: `pipeline/ARCHITECTURE.md`.

### 7.1 Chọn hạ tầng — ⏳ ĐANG CHỜ CHỦ DỰ ÁN QUYẾT ĐỊNH

- [ ] Chọn phương án (xem `docs/trien-khai-pipeline/huong-dan-chon-vps.md`):
  - **A — Oracle Cloud Always Free**: VPS ARM 2 OCPU + 12 GB RAM, 0đ vĩnh viễn, chạy 24/7.
    Lưu ý: cần thẻ thật xác minh; hay "out of capacity"; máy idle 7 ngày có thể bị thu hồi.
  - **B — Máy cá nhân**: cài Docker, chạy thử 15 phút, máy phải bật khi chạy lịch.
  - Đề xuất hiện tại: **B để chạy thử ngay → chuyển A trước ngày ra mắt.**

### 7.2 Dựng hạ tầng

- [ ] Cài Docker + Docker Compose trên máy/VPS đã chọn
- [x] Thêm `.env.example`, `.gitignore`, tách database n8n/Postiz, healthcheck và bind local mặc định
- [ ] Copy `.env.example` thành `.env`, thay toàn bộ giá trị mẫu và không commit secrets
- [ ] Chạy `docker compose --env-file .env -f pipeline/docker-compose.yml up -d`, kiểm tra các container healthy
- [ ] Nếu dùng VPS: đặt reverse proxy + HTTPS; không mở trực tiếp cổng quản trị n8n/Postiz

### 7.3 Cấu hình n8n

- [ ] Tạo tài khoản admin n8n, đổi mật khẩu mặc định
- [ ] Lấy **Gemini API key** free tại https://aistudio.google.com (chủ dự án tự lấy, nhập qua form bảo mật)
- [ ] Import `pipeline/n8n-workflow-content-pipeline.json` vào n8n
- [ ] Điền credentials trong workflow: Gemini key, Postiz token, Telegram bot (đều là placeholder hiện tại)
- [ ] Kiểm chứng lại từng RSS trong `pipeline/rss-sources.md` còn sống; xoá/thay nguồn chết
- [ ] Chạy thử workflow bằng tay: xác nhận ra được bản nháp tiếng Việt + thông báo Telegram

### 7.6 Baseline engineering — ✅ ĐÃ BỔ SUNG

- [x] Thêm CI kiểm tra JSON workflow, Compose interpolation, link Markdown nội bộ và placeholder triển khai
- [x] Bổ sung `docs/CONTENT_POLICY.md` về claims, an toàn, bản quyền và human approval
- [x] Bổ sung hai tài liệu mẫu bị checklist tham chiếu nhưng thiếu trong repo
- [x] Yêu cầu Gemini trả JSON có claims/uncertainties/safety note và validate trước khi tạo draft
- [x] Tham khảo farmOS, FarmBot, n8n, Postiz và hệ sinh thái Open Agriculture; ghi bài học vào `docs/REFERENCES-AND-BENCHMARKS.md`
- [x] Thêm state schema độc lập cho source/draft/publishing/audit → `pipeline/state-schema.sql`
- [x] Thêm contract staging của Postiz theo Public API → `pipeline/POSTIZ_API_CONTRACT.md`
- [x] Thêm workflow Error Trigger mẫu → `pipeline/n8n-error-handler-workflow.json`
- [ ] Thêm dedup/time-window, retry/dead-letter và audit log vào workflow thực tế

### 7.4 Cấu hình Postiz + kết nối Fanpage

- [ ] Tạo tài khoản admin Postiz, đổi mật khẩu mặc định
- [ ] Tạo **fanpage Facebook** (theo `docs/setup-kenh/mota-fanpage.md`) — việc này do chủ dự án làm
- [ ] Tạo Facebook App tại developers.facebook.com, lấy token có quyền đăng lên Page
      (quy trình chi tiết phải đối chiếu tài liệu Meta tại thời điểm thực hiện — API thay đổi thường xuyên)
- [ ] Kết nối Fanpage vào Postiz; đăng thử 1 bài test lên trang (hoặc bản nháp) và kiểm chứng hiển thị
- [ ] Đặt lịch đăng mặc định khớp lịch nội dung: T2/T4/T6/CN

### 7.5 Pipeline video

- [ ] Cài ffmpeg trên máy chạy pipeline
- [ ] Kiểm chứng Edge-TTS cho giọng tiếng Việt; ghép thử 1 video 9:16 từ ảnh + giọng đọc + phụ đề
- [ ] Chuẩn hoá quy trình: 1 video/tuần cho bài "mô hình thực tế" nổi bật nhất

**Tiêu chí hoàn thành GĐ 2:** một bài test đi trọn vòng RSS → nháp tiếng Việt → duyệt → đăng lên Fanpage thành công.

---

## 8. GĐ 3 — Sản xuất kho nội dung mở đầu (tuần 3–4)

Lịch chi tiết 8 bài: `docs/setup-kenh/lich-noi-dung-2-tuan-dau.md`.
Giọng văn mẫu đã duyệt: `docs/ban-nhap-mau/bai-1-va-bai-3.md` (sau khi chủ dự án chốt giọng văn).

- [ ] Chủ dự án duyệt giọng văn từ 2 bản nháp mẫu (giữ nguyên / trang trọng hơn / gần gũi hơn / ngắn hơn)
- [ ] Sản xuất đủ 8 bài theo lịch (6 bài viết + 2 video)
- [ ] Mở rộng kho lên 12 bài dự phòng (đủ ~3 tuần đăng)
- [ ] Mọi bài đều: đúng 1 trong 3 trụ cột, có CTA, có hashtag, ghi nguồn, đã qua duyệt của con người
- [ ] Lên lịch sẵn trong Postiz cho 2 tuần đầu

---

## 9. GĐ 4 — Tạo kênh & ra mắt

- [ ] Tạo fanpage với nội dung trong `docs/setup-kenh/mota-fanpage.md` (avatar, cover, mô tả, nút CTA)
- [ ] Tạo group với `docs/setup-kenh/noi-quy-group.md` (mô tả, 7 điều nội quy, 3 câu hỏi tham gia)
- [ ] Bật trên group: phê duyệt bài viết + cảnh báo từ khóa spam
- [ ] Gắn link group vào fanpage và ngược lại
- [ ] Đăng bài 1 (chào sân) → share vào group (thủ công — xem mục 3)
- [ ] Mời nhóm thành viên đầu tiên (từ các hội nhóm nông nghiệp Facebook, theo Q10 file định hình)
- [ ] Theo dõi 48h đầu: trả lời mọi comment/inbox trong ngày

---

## 10. GĐ 5 — Vận hành thường xuyên

- [ ] Chu kỳ tuần: pipeline chạy → duyệt nháp (~5 phút/bài) → đăng → share bài nổi bật vào group
- [ ] Duyệt group ~10–15 phút/ngày (ca khó mà công cụ gốc Facebook không xử lý được)
- [ ] Cuối mỗi tuần: ghi số liệu (reach, tương tác/bài, tăng trưởng thành viên) vào file theo dõi
- [ ] Cuối mỗi tháng: rà soát trụ cột nào hiệu quả nhất → điều chỉnh tỉ trọng nội dung
- [ ] Bảo trì: kiểm tra RSS còn sống, cập nhật n8n/Postiz, sao lưu thư mục dữ liệu Docker

---

## 11. GĐ 6 — Mở rộng dài hạn (chưa bắt đầu, chỉ ghi hướng)

- [ ] App sản xuất AIoT cho hộ nông dân (vấn đề đầu tiên cần giải quyết, theo Q15 file định hình)
- [ ] Đánh giá **farmOS** làm nền tảng quản lý trang trại; **ai-crop-disease-detection-agent** cho bệnh cây
- [ ] Truy xuất nguồn gốc: bắt đầu bằng QR + cơ sở dữ liệu đơn giản (chưa cần blockchain — tham khảo `foodprint`)
- [ ] Tưới tự động giá rẻ: tham khảo `growmax`
- [ ] Cơ chế liên kết mua chung – bán chung theo mô hình Moshav

---

## 12. Việc đang chờ quyết định của con người

| Việc | Ai quyết | Ghi chú |
|---|---|---|
| Chọn hạ tầng A hay B (mục 7.1) | Chủ dự án | Đề xuất: B chạy thử → A vận hành |
| Duyệt giọng văn 2 bản nháp mẫu | Chủ dự án | Ảnh hưởng toàn bộ nội dung về sau |
| Lấy Gemini API key | Chủ dự án | Miễn phí, tại aistudio.google.com |
| Tạo fanpage + group | Chủ dự án | Tài khoản Facebook cá nhân của chủ dự án |
| Tạo Facebook App + token đăng Page | Chủ dự án | Cần khi kết nối Postiz (mục 7.4) |

---

## 13. Cấu trúc repo

```
├── README.md                              # Tổng quan dự án
├── PROJECT_PLAN.md                        # FILE NÀY — kế hoạch + checklist
├── docs/
│   ├── bo-cau-hoi-dinh-hinh-du-an.md      # 65 câu hỏi định hình + câu trả lời
│   ├── ke-hoach-kenh-facebook.md          # Kế hoạch kênh chi tiết
│   ├── setup-kenh/                        # Mô tả fanpage, nội quy group, lịch 2 tuần đầu
│   ├── CONTENT_POLICY.md                  # Policy nội dung, claims, an toàn, bản quyền
│   ├── trien-khai-pipeline/               # Hướng dẫn chọn hạ tầng
│   └── ban-nhap-mau/                      # Bản nháp mẫu bài viết
├── pipeline/
│   ├── ARCHITECTURE.md                    # Kiến trúc pipeline chi tiết
│   ├── docker-compose.yml                 # n8n + Postgres + Redis + Postiz
│   ├── n8n-workflow-content-pipeline.json # Workflow mẫu (credentials = placeholder)
│   ├── n8n-error-handler-workflow.json    # Error Trigger mẫu
│   ├── state-schema.sql                    # State store + audit log độc lập
│   ├── POSTIZ_API_CONTRACT.md              # Contract Postiz staging
│   └── rss-sources.md                     # Nguồn nội dung quốc tế
├── demo-video-ai/                         # Demo app tạo video AI trong trình duyệt
├── .env.example                            # Mẫu cấu hình local, không chứa secret thật
└── .github/workflows/validate.yml          # Kiểm tra tự động khi push/PR
```

---

## 14. Hướng dẫn cho AI agent tiếp tục dự án

1. **Đọc trước khi làm:** file này → `README.md` → `docs/bo-cau-hoi-dinh-hinh-du-an.md`
   → tài liệu của giai đoạn đang làm.
2. **Cập nhật checklist** trong file này ngay khi hoàn thành một mục; commit kèm thay đổi liên quan.
3. **Không tự ý:** đăng bài lên Facebook, gửi mail, mua/vps trả phí, thay đổi quyền truy cập —
   các việc này cần xác nhận của chủ dự án.
4. **Không bịa thông tin kỹ thuật:** biến môi trường trong `docker-compose.yml` và quy trình lấy
   Facebook token phải đối chiếu tài liệu chính thức mới nhất tại thời điểm triển khai.
5. **Giữ ngân sách 0đ** (mục 2). Nếu một giải pháp cần trả phí, trình bày rõ chi phí và xin ý kiến trước.
6. **Giao tiếp tiếng Việt**, đi thẳng vào việc, mỗi lần kết thúc bằng bước tiếp theo cụ thể.
