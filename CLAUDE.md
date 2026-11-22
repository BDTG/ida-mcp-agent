@AGENTS.md

# Nhắc riêng cho Claude Code

Repo này không cho phép tác giả AI trong lịch sử git.

- Không thêm `Co-Authored-By: Claude ...` và không thêm dòng `Generated with Claude Code` vào commit hoặc PR.
- Không đổi `user.name`/`user.email` sang danh tính AI.
- Không chạy `git commit --no-verify`.

Cấu hình đã tắt sẵn trong `.claude/settings.json` (`attribution.commit` và `attribution.pr` là chuỗi rỗng). Hook `.githooks/commit-msg` và check CI `no-ai-coauthor` sẽ chặn nếu trailer lọt vào.
