# Kiến trúc tự động hóa hai luồng: YouTube và Facebook

> Quyết định kiến trúc cho giai đoạn thử nghiệm và mở rộng của dự án “Nông nghiệp thông minh và tử tế”.
>
> Mục tiêu: tận dụng các nền tảng/repo phù hợp thay vì ép một công cụ làm toàn bộ pipeline.

## 1. Quyết định chính

Tách hệ thống thành hai luồng chuyên biệt nhưng dùng chung một `content_pack`:

```text
RSS / website / ý tưởng nông nghiệp
                  ↓
        Gemini 3.8 Flash API
  tóm tắt nguồn · claims · cảnh báo · content pack
             ↙                         ↘
  Luồng YouTube                  Luồng Facebook
  video dài + Shorts             bài viết + ảnh + Reel
```

Không chạy lại nghiên cứu và viết nội dung độc lập cho từng nền tảng. Gemini tạo dữ liệu nguồn một lần, sau đó sinh biến thể theo đặc tính của YouTube và Facebook.

## 2. Luồng chung

### Đầu vào

- RSS quốc tế trong `pipeline/rss-sources.md`.
- Bài viết hoặc URL do người vận hành thêm thủ công.
- Chủ đề ưu tiên theo ba trụ cột: mô hình thực tế, kiến thức khoa học, mẹo áp dụng ngay.

### Gemini 3.8 Flash API

Model ID chuẩn: `gemini-3.8-flash`.

Gemini xử lý:

1. Tóm tắt và viết lại nguồn bằng tiếng Việt.
2. Trích xuất claims và URL nguồn.
3. Ghi uncertainties và safety notes.
4. Phân loại trụ cột nội dung.
5. Tạo `content_pack` cho hai nền tảng.
6. Viết script YouTube dài, script Shorts và caption Facebook.

Gemini API key phải được lưu trong secret manager hoặc Google Apps Script Properties, không đưa vào Git, Google Sheet công khai hoặc frontend.

### Content pack tối thiểu

```json
{
  "topic": "Chủ đề",
  "source_urls": ["https://example.com/source"],
  "source_summary": "Tóm tắt có nguồn",
  "pillar": "mo_hinh_thuc_te",
  "claims": [],
  "uncertainties": [],
  "safety_notes": [],
  "youtube": {
    "title": "",
    "long_script": "",
    "short_script": "",
    "description": "",
    "tags": []
  },
  "facebook": {
    "page_caption": "",
    "reel_caption": "",
    "group_share_text": "",
    "hashtags": []
  },
  "assets": {
    "youtube_video": null,
    "short_video": null,
    "facebook_image": null,
    "thumbnail": null
  }
}
```

## 3. Luồng YouTube

### Vai trò công cụ

- **YouTube Automation Agent:** điều phối strategy, script, thumbnail, queue, upload, schedule và analytics cho YouTube.
- **OpenShorts:** xử lý video, trích clip, reframe 9:16, voice, B-roll, phụ đề và render Shorts.
- **Gemini 3.8 Flash:** tạo brief, script, title, description, tags và biến thể nội dung.
- **Hugging Face:** lớp bổ sung cho ASR, TTS, xử lý video hoặc model media; không coi Hugging Face Space miễn phí là scheduler 24/7.
- **YouTube Data API:** kênh publish chính thức.

### Luồng đề xuất

```text
content_pack
→ Gemini tạo script dài + script Shorts
→ OpenShorts tạo voice, cảnh, phụ đề và MP4
→ QC codec/thời lượng/tỷ lệ/thumbnail
→ YouTube Automation Agent
→ upload + schedule YouTube
→ analytics
```

Một chủ đề có thể tái sử dụng thành:

- Một video YouTube dài 4–8 phút.
- Một đến ba YouTube Shorts.
- Thumbnail và title riêng.
- Description có nguồn và lưu ý an toàn.

## 4. Luồng Facebook

### Vai trò công cụ

- **Postiz:** lớp quản lý kênh, calendar, upload, schedule, publish và analytics cho Facebook Page.
- **Meta Business Suite:** phương án web miễn phí/dự phòng khi chưa dùng Postiz Cloud.
- **Gemini 3.8 Flash:** page caption, Reel caption, CTA, hashtag và bản rút gọn để share Group.
- **Canva hoặc OpenShorts:** ảnh, infographic và video dọc.
- **Hugging Face:** model tạo/biến đổi media nếu license và chi phí phù hợp.

### Luồng đề xuất

```text
content_pack
→ Gemini tạo biến thể Facebook
→ tạo ảnh/infographic hoặc Reel
→ Postiz / Meta Business Suite
→ schedule hoặc publish Facebook Page
→ theo dõi analytics
```

Postiz Cloud thuận tiện hơn nhưng không có free tier vĩnh viễn. Nếu ưu tiên ngân sách 0đ, bắt đầu bằng Meta Business Suite và chỉ chuyển sang Postiz khi số lượng kênh/bài đủ lớn.

## 5. Hugging Face dùng ở đâu?

Hugging Face là model hub và nền tảng chạy Spaces, không phải social scheduler. Có thể dùng cho:

- ASR/transcription.
- TTS tiếng Việt thử nghiệm.
- Image/video generation.
- Caption và xử lý media.
- Inference API khi model/provider phù hợp.

Không dùng Hugging Face làm nơi duy nhất để:

- Đọc RSS định kỳ 24/7.
- Lưu hàng đợi publish lâu dài.
- Đăng Facebook/YouTube thay cho API chính thức.
- Vượt giới hạn Facebook Group.

Free Space có thể sleep khi không được sử dụng, disk mặc định không persistent và GPU thường tính phí. API key phải lưu trong Secrets của Space. Model `hynt/F5-TTS-Vietnamese-ViVoice` phù hợp thử nghiệm TTS tiếng Việt nhưng license CC-BY-NC-SA-4.0 là phi thương mại; phải kiểm tra license trước khi dùng cho hoạt động thương mại.

## 6. Giới hạn Facebook Group

Luồng chính chỉ publish tự động lên **Facebook Page**. Không cam kết đăng tự động vào Facebook Group bằng API chính thức.

Quy trình Group:

```text
Facebook Page đăng bài
→ quản trị viên chọn bài nổi bật
→ share thủ công vào Group
```

Không dùng browser automation không chính thức cho production vì có rủi ro checkpoint, khóa tài khoản, sai quyền và vi phạm điều khoản nền tảng.

## 7. Approval và mức tự động hóa

Mặc định vẫn giữ approval cho nội dung có rủi ro:

- Liều lượng thuốc, phân bón hoặc hóa chất.
- Chẩn đoán bệnh cây hoặc sâu bệnh.
- Thiết kế điện, nước, máy móc.
- Claims về năng suất, chi phí, lợi nhuận.
- Nội dung có asset hoặc bản quyền chưa rõ.

Có thể cho unattended publish ở nhóm nội dung rủi ro thấp sau khi kiểm thử:

- Tin công nghệ đã có nguồn rõ.
- Mô tả mô hình thực tế không có khuyến nghị nguy hiểm.
- Nội dung tái sử dụng đã được duyệt trước.

Mọi job tự động cần có deduplication, idempotency key, retry, dead-letter, audit log và cảnh báo lỗi.

## 8. Lộ trình triển khai

### Giai đoạn A — thử nghiệm ít chi phí

- Gemini 3.8 Flash API.
- Google Sheets/Apps Script làm intake và content pack.
- Meta Business Suite cho Facebook Page.
- YouTube Studio hoặc YouTube Automation Agent cho YouTube.
- OpenShorts/Hugging Face chỉ xử lý video khi cần.
- Group share thủ công.

### Giai đoạn B — tăng tự động hóa

- Worker đọc RSS và gọi Gemini.
- OpenShorts/API render video.
- Postiz Cloud hoặc Postiz self-host làm social control-plane.
- YouTube Automation Agent chạy queue và analytics.
- Shared state store và webhook.

### Giai đoạn C — vận hành production

- Pin phiên bản các repo và model.
- Test OAuth, token refresh, quota và retry.
- Kiểm tra quyền asset và bản quyền nguồn.
- Giám sát queue, storage, upload và publish status.
- Chỉ bật auto-publish theo policy risk tier.

## 9. Repo và tài liệu tham khảo

- [Postiz](https://github.com/gitroomhq/postiz-app): social publishing, calendar, API/MCP, Facebook Page.
- [TryPost](https://github.com/trypostit/trypost): publishing, approval và API đa nền tảng.
- [OpenShorts](https://github.com/mutonby/openshorts): video clipping, Shorts, MCP/API và workflow media.
- [YouTube Automation Agent](https://github.com/darkzOGx/youtube-automation-agent): YouTube strategy, video, schedule và analytics.
- [Gemini 3.8 Flash](https://ai.google.dev/gemini-api/docs/models/gemini-3.8-flash): model text/multimodal và structured output.
- [Hugging Face Spaces](https://huggingface.co/docs/hub/spaces-overview): web app, hardware, sleep và secrets.
- [Hugging Face Inference Providers](https://huggingface.co/docs/inference-providers/index): API thống nhất cho nhiều provider/model.
