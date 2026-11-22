## Việc này làm gì

<!-- một đoạn ngắn, mô tả thay đổi và lý do -->

## Cách kiểm chứng

<!-- lệnh đã chạy, kết quả thật, ảnh log nếu có -->

## Checklist

- [ ] Đã chạy `bash scripts/check-ai-attribution.sh origin/main..HEAD` và xanh
- [ ] Đã cài hook: `bash scripts/setup-hooks.sh`
- [ ] Commit không có trailer `Co-Authored-By` liên quan tới AI, không có dòng `Generated with ...`
- [ ] Không commit mẫu mã độc thật, `*.i64`, `*.idb`, hay binary của IDA
- [ ] Đã cập nhật `README.md` / `docs/` nếu hành vi hoặc cấu hình thay đổi
