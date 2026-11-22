# Chặn tác giả AI khỏi bảng contributors

Mục tiêu: bảng `Contributors` của repo chỉ có người thật trong nhóm.

## Vì sao "claude" xuất hiện

Có hai đường khác nhau, phải chặn cả hai:

| Đường vào | Cơ chế | Có lên bảng contributors? |
| --- | --- | --- |
| Trailer `Co-Authored-By: Claude <noreply@anthropic.com>` | Claude Code tự thêm vào commit message | Không được tính như người đóng góp (email `noreply@anthropic.com` không gắn với tài khoản GitHub nào), nhưng hiện tên trên commit và trong log, gây nhầm lẫn khi đọc lịch sử |
| GitHub App/action `Claude` | Bot tạo commit với danh tính `claude[bot]`, type `Bot` | **Có**, và thực tế đây là lý do chính khiến bot xuất hiện trong bảng contributors |

Kiểm chứng: `GET /repos/anthropics/claude-code/contributors` trả về một mục `claude[bot]` với `type: "Bot"`. Nghĩa là chỉ xóa trailer là chưa đủ, phải không cài app Claude trên repo.

## Bốn lớp chặn

1. `.claude/settings.json`, tắt attribution tại nguồn:

   ```json
   {
     "attribution": { "commit": "", "pr": "", "sessionUrl": false },
     "includeCoAuthoredBy": false
   }
   ```

   `attribution` là khóa hiện hành, `includeCoAuthoredBy` là khóa cũ vẫn được tôn trọng. Đặt cả hai để máy nào chạy bản Claude Code cũ vẫn tắt được.

2. `AGENTS.md` + `CLAUDE.md`, dặn mọi agent (Claude Code, Codex, Copilot, Cursor, Hermes) không thêm trailer, không đổi danh tính commit, không dùng `--no-verify`.

3. `.githooks/commit-msg` + `scripts/setup-hooks.sh`, chặn ngay trên máy khi `git commit`:

   ```bash
   bash scripts/setup-hooks.sh
   ```

   Hook từ chối: trailer co-author trỏ tới Claude/Anthropic, dòng `Generated with Claude Code`, email `*@anthropic.com`, và trường hợp commit author là AI.

4. GitHub Actions + bảo vệ nhánh:

   - `no-ai-coauthor` chạy trên mọi push vào `main` và mọi PR, quét toàn bộ commit trong phạm vi PR.
   - `contributors-guard` chạy hằng tuần, đọc API contributors, báo đỏ khi có `claude`, `anthropic` hoặc bất kỳ `type: Bot`.
   - Bảo vệ nhánh `main` bắt buộc PR đi qua check `no-ai-coauthor`, nên commit mang dấu vết AI không merge được.

## Nếu lỡ lọt vào

1. Gỡ app: Settings ▸ Applications ▸ Claude ▸ Configure ▸ bỏ quyền truy cập repo này.
2. Viết lại lịch sử nhánh để bỏ trailer, rồi force push nhánh đó (không force push `main` đã bảo vệ):

   ```bash
   git filter-repo --message-callback \
     'return re.sub(rb"(?im)^co-authored-by:.*(claude|anthropic).*\n", b"", message)'
   ```

3. Với `main` đã public và đã có người fork, thay đổi lịch sử là việc lớn: hoặc chấp nhận, hoặc nhờ GitHub Support gỡ mục contributors (bảng contributors có cache, xóa commit chưa chắc làm mất tên ngay).
4. Chạy lại `contributors-guard` bằng `workflow_dispatch` để xác nhận đã sạch.
