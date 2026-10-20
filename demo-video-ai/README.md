# Demo: App tạo video AI tự động

Bản demo chạy 100% trên trình duyệt — mở file `index.html` là dùng ngay, không cần cài đặt hay API key.

## Cách dùng

1. Mở `index.html` bằng Chrome hoặc Edge (khuyên dùng Chrome).
2. Nhập/sửa kịch bản tiếng Việt.
3. Chọn giọng đọc (ưu tiên giọng có mã `vi-VN` nếu máy bạn có).
4. Nhấn **Xem thử** để xem nhân vật nói + phụ đề.
5. Nhấn **Xuất video WebM** để ghi lại thành file video khổ 9:16.

## Demo này mô phỏng pipeline nào?

| Bước pipeline thật | Trong demo |
|---|---|
| 1. Kịch bản → chia đoạn, căn thời gian | `chunkText()` chia theo câu, ≤ 80 ký tự/đoạn |
| 2. Text-to-Speech → file giọng đọc | Xem thử: Web Speech API của trình duyệt (miễn phí, có sẵn). Xuất video: thu âm thanh của tab qua `getDisplayMedia()` (không cần API key) — lúc bấm xuất, chọn đúng tab này và bật "Chia sẻ âm thanh của tab" là file có tiếng thật |
| 3. Nhân vật AI nói + khớp khẩu hình | Nhân vật vẽ bằng Canvas: chớp mắt, miệng mở theo nhịp nói, lắc đầu nhẹ |
| 4. Burn-in phụ đề, xuất 9:16 | Phụ đề vẽ trực tiếp lên canvas 540×960, ghi bằng MediaRecorder → `.webm` |

## Giới hạn trung thực của bản demo

- **Xuất video có tiếng bằng cách thu âm thanh của tab** (thêm 2026-10-11): lúc bấm "Xuất video WebM", trình duyệt hiện hộp xin quyền — hãy chọn đúng tab này và bật "Chia sẻ âm thanh của tab", file xuất ra sẽ có giọng đọc thật mà không cần API key. Cách cũ (ghép giọng TTS online qua `captureStream()`) bị trình duyệt tắt tiếng vì thiếu header CORS nên chỉ còn là nhánh dự phòng trung thực.
- **Nhân vật là hình vẽ tay**, chưa chân thực như người thật. Bản thật dùng HeyGen / Hedra / D-ID / Kling để tạo người nói như thật.

## Muốn nâng lên bản "thật" thì làm gì tiếp?

1. Đăng ký ElevenLabs (giọng Việt rất tự nhiên) → API text-to-speech → file `voice.mp3`.
2. Đăng ký HeyGen hoặc Hedra → upload ảnh nhân vật + `voice.mp3` → nhận video người nói.
3. Dùng `ffmpeg` burn-in phụ đề `.srt` + nhạc nền, xuất 9:16, đăng tự động qua API TikTok/Facebook.

Muốn mình build tiếp bước nào (ví dụ: script Python gọi ElevenLabs + HeyGen + ffmpeg tự động từ kịch bản), cứ nói nhé.
