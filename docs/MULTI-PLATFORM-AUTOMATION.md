# Tự động hóa sản xuất và đăng nội dung đa nền tảng

## Kết luận

Có thể tự động hóa gần như toàn bộ chuỗi:

```text
ý tưởng → nghiên cứu nguồn → viết kịch bản/bài → tạo ảnh/video/voice → kiểm tra chất lượng
→ biến thể theo từng nền tảng → xếp lịch → publish → đo lường → tái sử dụng
```

Tuy nhiên, không nên coi đây là một nút “đăng mọi nơi”. Mỗi nền tảng có OAuth, quyền ứng dụng, chuẩn media, rate limit và trạng thái publish khác nhau. Với nội dung nông nghiệp, vẫn nên giữ human approval cho claim, số liệu và khuyến nghị kỹ thuật.

## Khả năng thực tế theo nền tảng

### Facebook Page

Có thể tự động publish bài và Reel lên **Facebook Page** qua Meta API. Quy trình Reel gồm khởi tạo upload session, upload video rồi publish. Meta yêu cầu Page access token và các quyền như `pages_show_list`, `pages_read_engagement`, `pages_manage_posts`; Reels API giới hạn 30 bài API-published trong cửa sổ 24 giờ. Reel chỉ publish/crosspost tới Page, không phải Group. [1]

Video nên được render sẵn thành MP4 dọc 9:16, tối ưu 1080×1920, 3–90 giây, rồi đưa qua adapter Facebook. Vì giới hạn 30 Reel/24 giờ, scheduler phải có quota riêng cho Page.

### YouTube

Có thể upload và lên lịch video/Shorts bằng YouTube Data API `videos.insert`, OAuth scope upload và trường `status.publishAt`. API hỗ trợ resumable upload; metadata gồm title, description, tags, privacy status và thời gian publish. Quota upload và chính sách kênh cần được theo dõi riêng. [2]

YouTube phù hợp làm kênh lưu trữ video dài hơn và Shorts. Pipeline nên tạo title/description/tags riêng thay vì dùng nguyên caption Facebook.

### TikTok

Có thể Direct Post bằng TikTok Content Posting API, nhưng cần app đã đăng ký, bật sản phẩm Content Posting API, được duyệt scope `video.publish`, người dùng ủy quyền và thường cần audit để nội dung không bị giới hạn private. TikTok yêu cầu query Creator Info trước khi post; video có thể upload file hoặc kéo từ URL thuộc verified domain. [3]

Vì vậy TikTok là nền tảng có chi phí phối hợp/kiểm duyệt app cao nhất trong ba nền tảng. Nên triển khai sau Facebook Page và YouTube staging.

### Group Facebook

Không nên đưa Group vào mục tiêu tự động publish. Quy trình thực tế nên là Page publish → người quản trị share thủ công vào Group hoặc dùng công cụ gốc của Facebook.

## Kiến trúc tối đa hóa tự động hóa

```text
Content ideas / RSS
        ↓
Source registry + dedup + claims/provenance
        ↓
LLM content pack
(title, article, captions, script, claims, sources, CTA)
        ↓
Asset factory
(image, voice, subtitles, vertical video, thumbnail)
        ↓
Media QC
(codec, duration, aspect ratio, file size, no missing asset)
        ↓
Policy QC
(source, claims, safety, copyright, platform restrictions)
        ↓
Human approval
        ↓
Platform adapters
(Facebook Page / YouTube / TikTok)
        ↓
Queue + rate limit + idempotency
        ↓
Publish status + metrics + retry/dead-letter
```

Một `content_pack` nên tạo nhiều output từ một nguồn:

- Facebook Page: bài viết + ảnh hoặc Reel caption.
- YouTube: video, title, description, tags, thumbnail, `publishAt`.
- TikTok: video dọc, caption ngắn, privacy settings, cover timestamp.
- Group: bản copy ngắn để người quản trị share thủ công.

Tự động hóa phần sản xuất là hợp lý. Tự động publish 100% chỉ nên bật sau khi có policy gate, approval, quota, retry và audit log. Không nên để LLM tự quyết định claim y khoa/nông nghiệp hoặc tự đăng nội dung chưa có nguồn.

## Repo tham khảo gần nhất

### 1. TryPost — gần nhất về sản phẩm mục tiêu

[TryPost](https://github.com/trypostit/trypost) mô tả rõ mô hình AI agents + REST/MCP API + composer + calendar/queues + approval + workspaces + media repurpose + webhooks. README cũng liệt kê Facebook, TikTok và YouTube trong các mạng được publish qua API chính thức. [4]

Đây là repo nên tham khảo sát nhất về **product workflow**: một content pack có thể được biến thể theo kênh, xếp vào queue, chờ approval và phát sự kiện webhook khi created/scheduled/published/failed. Cần kiểm tra thêm độ trưởng thành, API thực tế và chất lượng connector trước khi chọn làm nền tảng thay thế.

### 2. Postiz — lựa chọn thực dụng nhất cho repo hiện tại

[Postiz](https://github.com/gitroomhq/postiz-app) hỗ trợ scheduling, automation, analytics, self-hosting, public API và tích hợp n8n. README liệt kê Facebook, TikTok và YouTube, đồng thời có Node SDK và custom n8n node. [5]

Postiz không thay thế asset factory. Nó phù hợp làm lớp **queue, approval, scheduling, publish và analytics** phía sau pipeline n8n/Gemini/ffmpeg của repo hiện tại. Đây là hướng nên ưu tiên vì repo hiện đã thiết kế quanh Postiz.

### 3. Mixpost — tham khảo media library và vận hành team

[Mixpost](https://github.com/inovector/mixpost) mạnh ở media library, post versions, conditions, workspaces, queue/calendar, templates, hashtag groups và analytics. [6] Nó phù hợp để học cách tổ chức nội dung và vận hành nhiều kênh, nhưng không sát bằng Postiz/TryPost ở phần AI agent và pipeline sinh video.

### 4. n8n — orchestration, không phải media publishing product

[n8n](https://github.com/n8n-io/n8n) phù hợp để điều phối RSS, LLM, render service, approval và gọi API. Nó có human approvals, code node, integrations và error workflow. [7] Không nên biến n8n thành nơi lưu toàn bộ media/state nghiệp vụ; state store và asset registry nên tách riêng.

## Khuyến nghị cho repo này

1. Giữ n8n làm orchestration và Postiz làm scheduling/publishing layer.
2. Xây `content_pack` làm contract trung tâm, thay vì tạo riêng từng caption rời rạc.
3. Thêm asset factory: script → TTS → ảnh/stock → ffmpeg → MP4 + thumbnail + metadata license.
4. Triển khai Facebook Page trước, YouTube sau, TikTok cuối cùng khi app/scope/audit đã sẵn sàng.
5. Tham khảo TryPost cho queue/approval/webhook/multi-variant; tham khảo Mixpost cho media library/versioning.
6. Chỉ bật auto-publish sau khi staging chứng minh được idempotency, quota, retry và approval gate.

## References

[1]: https://developers.facebook.com/documentation/video-api/guides/reels-publishing "Meta Reels Publishing API for Facebook Pages"
[2]: https://developers.google.com/youtube/v3/docs/videos/insert "YouTube Data API videos.insert"
[3]: https://developers.tiktok.com/doc/content-posting-api-get-started "TikTok Content Posting API Direct Post"
[4]: https://github.com/trypostit/trypost/blob/main/README.md "TryPost README — AI agents, queues, approvals and publishing"
[5]: https://github.com/gitroomhq/postiz-app/blob/main/README.md "Postiz README — scheduling, automation, analytics and self-hosting"
[6]: https://github.com/inovector/mixpost/blob/main/README.md "Mixpost README — media library, versions, workspaces and queues"
[7]: https://github.com/n8n-io/n8n/blob/master/README.md "n8n README — workflow automation and AI agents"
