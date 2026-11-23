# IDA-MCP Agent

AI Agent lấy **IDA Pro headless** làm backend dịch ngược, nói chuyện với **mô hình ngôn ngữ nhỏ (SLM) chạy local** qua giao thức **MCP**, tự động phân tích hành vi mã độc và sinh báo cáo.

> Trạng thái: khung repo (đang ở giai đoạn thiết kế kiến trúc). Mã nguồn agent, MCP server và bộ sinh báo cáo sẽ được thêm theo từng mốc.

## Kiến trúc dự kiến

```
            ┌──────────────────────────────┐
            │  Agent (planner + tool loop) │
            │  điều phối theo kịch bản     │
            └───────┬──────────────┬───────┘
                    │ MCP (stdio)  │ HTTP/JSON
                    ▼              ▼
        ┌────────────────────┐  ┌──────────────────────┐
        │ ida-headless MCP   │  │ LLM nhỏ local         │
        │ server             │  │ (Ollama / llama.cpp)  │
        │ idat64 -A -S ...   │  │ 1B–8B, chạy offline   │
        └─────────┬──────────┘  └──────────────────────┘
                  ▼
        ┌────────────────────┐        ┌──────────────────────┐
        │ IDA Pro headless   │───────▶│ Report builder        │
        │ (idat64, plugin)   │  JSON  │ Markdown / HTML / PDF │
        └────────────────────┘        └──────────────────────┘
```

Thành phần:

| Thành phần | Vai trò |
| --- | --- |
| `idat64 -A -S<script>` | chạy IDA không GUI, nạp mẫu, chạy script trích xuất |
| MCP server | bọc các thao tác tĩnh (function list, xref, string, decompile, rename) thành tool cho agent |
| Agent | lập kế hoạch phân tích, gọi tool theo vòng lặp, tổng hợp bằng chứng |
| SLM local | sinh nhận định hành vi, ánh xạ sang ATT&CK, viết mục báo cáo |
| Report builder | kết xuất báo cáo có trích dẫn địa chỉ/function làm bằng chứng |

## Yêu cầu môi trường

- IDA Pro (bản có quyền dùng `idat64`), không commit binary của IDA vào repo.
- Python 3.11+
- Một runtime LLM local (Ollama hoặc llama.cpp) nếu chạy offline.

## Bắt đầu

```bash
git clone https://github.com/BDTG/ida-mcp-agent.git
cd ida-mcp-agent
```

Không cần cài hook hay công cụ gì thêm. Repo chỉ chặn một việc: commit phải do người thật đứng tên (xem `.github/workflows/no-ai-author.yml`). Dùng AI viết code, viết commit message hay thêm `Co-Authored-By` đều không bị chặn.

## Cấu trúc repo (dự kiến)

```
agent/            vòng lặp agent, planner, prompt
mcp_server/       MCP server bọc IDA headless
ida_scripts/      script IDAPython chạy bằng idat64 -S
report/           builder Markdown/HTML/PDF
samples/          mẫu benign tự sinh để test (không chứa mã độc thật)
scripts/          setup, kiểm tra
docs/             thiết kế, kết quả thực nghiệm
```
