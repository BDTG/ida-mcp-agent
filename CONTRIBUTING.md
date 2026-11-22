# Đóng góp cho IDA-MCP Agent

## 1. Quy trình

1. Cập nhật `main`: `git switch main && git pull`
2. Tạo nhánh: `git switch -c feat/<việc-ngắn>` (hoặc `fix/`, `docs/`, `exp/`)
3. Commit theo Conventional Commits: `feat(mcp): them tool xref_to`
4. Push nhánh và mở pull request vào `main`
5. Chờ check `no-ai-coauthor` xanh (xem mục 3). `main` đã bật bảo vệ nhánh nên không push thẳng được, kể cả khi bạn có quyền Write

Có quyền Write thì vẫn phải đi qua pull request. Không có quyền Write thì fork rồi mở PR, cách này không cần được mời làm collaborator.

## 2. Không dẫn tên AI vào commit

Repo này giữ bảng contributor chỉ gồm người thật. Vì vậy mọi commit phải **không** chứa:

- trailer `Co-Authored-By: Claude <...>`, `Co-authored-by: ... Anthropic ...`, hoặc bất kỳ biến thể nào nhắc tới Claude/Anthropic;
- dòng quảng cáo kiểu `Generated with Claude Code`, `🤖 Generated with ...`;
- commit author là `Claude`, `claude[bot]`, hoặc email `*@anthropic.com`.

Cơ chế chặn gồm 4 lớp, xem chi tiết ở `docs/no-ai-attribution.md`:

| Lớp | Tệp | Việc nó làm |
| --- | --- | --- |
| Cấu hình công cụ | `.claude/settings.json` | tắt attribution của Claude Code ngay khi mở repo |
| Chỉ dẫn agent | `AGENTS.md`, `CLAUDE.md` | dặn mọi AI agent không thêm trailer |
| Hook cục bộ | `.githooks/commit-msg` | chặn ngay lúc `git commit` trên máy bạn |
| CI + bảo vệ nhánh | `.github/workflows/no-ai-coauthor.yml` | chặn merge PR có dấu vết AI |

### Cài hook (bắt buộc, một lần cho mỗi máy clone)

```bash
bash scripts/setup-hooks.sh
```

Script này chạy `git config core.hooksPath .githooks` cho repo hiện tại và cấp quyền thực thi cho hook. Hook chỉ là lớp tiện lợi, CI mới là lớp chặn thật.

### Tự kiểm tra trước khi push

```bash
bash scripts/check-ai-attribution.sh            # quét toàn bộ commit trong nhánh hiện tại
bash scripts/check-ai-attribution.sh origin/main..HEAD   # chỉ quét phần mới
```

Nếu bạn dùng Claude Code hoặc agent khác, kiểm tra lại cấu hình: đặt `attribution.commit` và `attribution.pr` thành chuỗi rỗng (hoặc `attribution: false` với bản mới) trong `~/.claude/settings.json`, và không bật GitHub App `Claude` trên repo này (app đó tạo commit dưới danh tính `claude[bot]` và bot này có mặt trong bảng contributors).

## 3. Check tự động

- `no-ai-coauthor`: quét toàn bộ commit của PR và commit vừa push lên `main`. Đỏ nghĩa là có dấu vết AI, phải sửa lịch sử nhánh rồi push lại.
- `contributors-guard`: chạy hằng tuần, gọi API contributors của repo, báo đỏ nếu xuất hiện tài khoản khớp `claude|anthropic|*[bot]`.

Sửa lịch sử nhánh trước khi mở PR:

```bash
git rebase -i origin/main          # bỏ dòng trailer trong commit message
# hoặc viết lại toàn bộ nhánh:
git filter-repo --message-callback 'return re.sub(rb"(?im)^co-authored-by:.*(claude|anthropic).*\n", b"", message)'
```

## 4. Nội dung không được commit

- Mẫu mã độc thật, mẫu có chứa thông tin cá nhân, hoặc bất kỳ tệp nào vi phạm pháp luật về lưu trữ mã độc.
- File cơ sở dữ liệu IDA: `*.i64`, `*.idb`, `*.til`.
- Binary hoặc license của IDA Pro.
- Khóa API, token, log có chứa dữ liệu thật.

Mẫu để test đặt trong `samples/` phải là tệp tự sinh (ví dụ hello world có nhúng chuỗi đặc trưng), ghi rõ nguồn gốc trong `samples/README.md`.

## 5. Chuẩn mã nguồn

- Python: `ruff check` và `ruff format`, type hint cho chữ ký hàm công khai.
- Mỗi tool MCP có docstring mô tả input/output và một test trong `tests/`.
- Commit nhỏ, mỗi commit một mục đích.
