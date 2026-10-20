# Nguồn RSS quốc tế — Nông nghiệp công nghệ cao / AIoT

> Dùng cho node RSS trong n8n workflow. Thêm từng URL vào node `rssFeedRead`.
> Trạng thái kiểm chứng: **đã xác nhận có feed** = mở được qua HTTP ngày 2026-10-19;
> **cần kiểm tra** = nguồn uy tín nhưng chưa mở thử feed.

## Đã xác nhận có feed

| Nguồn | URL feed | Ghi chú |
|-------|----------|---------|
| AgFunderNews | `https://agfundernews.com/feed` | Tin agrifoodtech, startup, đầu tư — rất hợp trụ cột "mô hình thực tế" |
| AgFunderNews (tag) | `https://agfundernews.com/tag/midstream-technologies/feed` | Lọc sẵn theo chủ đề |
| Future Farming | `https://www.futurefarming.com/feed/` | Kỹ thuật nông nghiệp chính xác, máy móc |

## Uy tín, cần kiểm tra feed khi triển khai

| Nguồn | Trang chủ | Ghi chú |
|-------|-----------|---------|
| PrecisionAg | precisionag.com | Tin công nghệ nông nghiệp chính xác (Mỹ) |
| Global Agriculture (Precision Ag) | global-agriculture.com/tag/precision-agriculture/ | Tổng hợp tin precision ag |
| FAO News | fao.org/news/en | Tin chính thống về nông nghiệp, an ninh lương thực |
| World Bank Agriculture | worldbank.org (mục Agriculture) | Báo cáo, xu hướng vĩ mô |
| Successful Farming | agriculture.com | Mẹo thực tế cho nông dân (Mỹ) — hợp trụ cột "mẹo hay" |
| Farm Progress | farmprogress.com | Kỹ thuật canh tác thực tế |

## Cách thêm nguồn mới

1. Mở trang tin → tìm biểu tượng RSS (hoặc thử thêm `/feed` vào cuối URL).
2. Thêm node `rssFeedRead` mới trong n8n, nối vào node "Gộp các nguồn".
3. Mỗi nguồn nên gắn nhãn trụ cột trong prompt lọc (mô hình / kiến thức / mẹo).

## Lưu ý bản quyền

Nội dung RSS chỉ dùng để **tham khảo và viết lại** bằng AI (không copy nguyên văn).
Luôn ghi "Nguồn tham khảo: <tên báo>" ở cuối bài — vừa tôn trọng tác giả,
vừa tăng độ tin cậy cho kênh.
