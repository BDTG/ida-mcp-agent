# Quy tắc cho AI agent làm việc trong repo này

Áp dụng cho Claude Code, Codex, Copilot, Cursor, Hermes và mọi agent khác.

## Bắt buộc

1. **Không thêm tác giả AI vào commit.** Không `Co-Authored-By: Claude <noreply@anthropic.com>`, không `Co-authored-by: ... Anthropic ...`, không dòng `Generated with Claude Code` / `🤖 Generated with ...`, không `Signed-off-by` mang tên AI.
2. **Không đặt danh tính commit là AI.** Không `git config user.name "Claude"`, không commit dưới `claude[bot]` hay email `*@anthropic.com`.
3. **Không bật GitHub App/action của Claude trên repo này.** App đó tạo commit mang danh tính `claude[bot]` và đưa bot vào bảng contributors.
4. **Không tự đổi cấu hình attribution.** `.claude/settings.json` trong repo đặt `attribution` rỗng, hãy giữ nguyên.
5. **Không vô hiệu hóa lớp chặn.** Không sửa, không bỏ qua, không thêm `--no-verify` vào lệnh commit, không sửa `.githooks/`, `scripts/check-ai-attribution.sh` hay workflow `no-ai-coauthor` để lách luật.

## Cách làm đúng

- Commit bằng danh tính người thật (git config của chủ máy), viết message mô tả thay đổi.
- Nếu công cụ tự thêm trailer, xóa trước khi commit:
  `git commit --amend -m "<message sạch>"`
- Nếu cần ghi nhận AI đã hỗ trợ, ghi trong **thân PR** hoặc `docs/` (ví dụ "phần này do agent soạn, người kiểm lại"), không ghi vào commit metadata.

Lý do: repo dùng bảng contributor để tính đóng góp của từng thành viên trong nhóm, tác giả AI làm sai lệch số liệu đó.
