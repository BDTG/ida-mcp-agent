#!/usr/bin/env bash
# Bật hook chặn tác giả AI cho repo này. Chạy một lần cho mỗi máy clone.
set -euo pipefail

root=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [ -z "$root" ]; then
  echo "Loi: chay script trong thu muc cua repo ida-mcp-agent." >&2
  exit 1
fi
cd "$root"

if [ ! -f ".githooks/commit-msg" ]; then
  echo "Loi: thieu .githooks/commit-msg" >&2
  exit 1
fi

chmod +x .githooks/commit-msg scripts/check-ai-attribution.sh 2>/dev/null || true
git config core.hooksPath .githooks

echo "hooksPath = $(git config core.hooksPath)"
echo "Hook da bat. Thu commit co dong 'Co-Authored-By: Claude' se bi chan."
echo
echo "Kiem tra danh tinh commit hien tai:"
echo "  user.name  = $(git config user.name)"
echo "  user.email = $(git config user.email)"
if printf '%s %s' "$(git config user.name)" "$(git config user.email)" | grep -Eiq 'claude|anthropic'; then
  echo "CANH BAO: danh tinh commit dang chua ten AI, hook se chan moi commit." >&2
  echo "  Sua: git config user.name \"Ten Ban\"; git config user.email \"ban@example.com\"" >&2
  exit 1
fi
