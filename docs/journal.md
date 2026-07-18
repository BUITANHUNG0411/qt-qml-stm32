# 📔 Project Journal (Chronological Decision Log)

> **AI Context**: File này dùng để AI ghi chép lại các quyết định kỹ thuật quan trọng và lý do đằng sau chúng theo trình tự thời gian. Đọc file này giúp AI khôi phục lại "trí nhớ" về bối cảnh dự án.

## 2026-07-17

### Cập nhật Kiến trúc Documentation (Vibe Coding Optimization)
- **Vấn đề**: Cấu trúc Markdown hiện tại tốt nhưng thiếu các cơ chế lưu trữ trí nhớ dài hạn (Memory) và luồng công việc (Workflows) rõ ràng cho AI.
- **Quyết định**: 
  - Khởi tạo file `journal.md` này để giữ lịch sử quyết định (Chronological log).
  - Giữ nguyên cấu trúc Metadata `> **AI Context**:` vì Gemini 3.1 Pro đọc cực kỳ tốt mà không tốn token như YAML.
  - Tạo thư mục `.agents/workflows/` để chứa các quy trình nhiều bước, bắt đầu bằng `brainstorming.md`.
  - Ban hành `DOCUMENTATION_STANDARDS.md` để quy chuẩn hóa cách viết Markdown (sử dụng GFM Alerts `> [!WARNING]`, định danh code blocks rõ ràng).
