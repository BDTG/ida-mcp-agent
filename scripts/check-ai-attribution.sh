#!/usr/bin/env bash
# Quét commit trong một khoảng rev-list, báo đỏ nếu có dấu vết tác giả AI.
# Dùng chung cho CI (.github/workflows/no-ai-coauthor.yml) và cho máy cá nhân.
#
#   bash scripts/check-ai-attribution.sh                 # toàn bộ commit của HEAD
#   bash scripts/check-ai-attribution.sh origin/main..HEAD
#   bash scripts/check-ai-attribution.sh --all-branches
set -euo pipefail

range="${1:-}"

if [ "$range" = "--all-branches" ]; then
  shas=$(git rev-list --all)
elif [ -n "$range" ]; then
  if ! shas=$(git rev-list "$range" 2>/dev/null) || [ -z "$shas" ]; then
    echo "check-ai-attribution: pham vi '$range' khong dung duoc (commit goc khong co trong ban clone), chuyen sang quet toan bo lich su HEAD."
    shas=$(git rev-list HEAD)
  fi
else
  shas=$(git rev-list HEAD)
fi

if [ -z "$shas" ]; then
  echo "check-ai-attribution: khong co commit nao trong pham vi kiem tra."
  exit 0
fi

fail=0
count=0

# Mẫu cấm trong commit message: thấy tên AI là chặn, không xét ngữ cảnh
msg_pattern='claude|anthropic'
# Mẫu cấm trong danh tính commit
id_pattern='claude|anthropic'

for sha in $shas; do
  count=$((count + 1))
  short=$(git rev-parse --short "$sha")
  msg=$(git show -s --format='%B' "$sha")
  an=$(git show -s --format='%an' "$sha")
  ae=$(git show -s --format='%ae' "$sha")
  cn=$(git show -s --format='%cn' "$sha")
  ce=$(git show -s --format='%ce' "$sha")

  if printf '%s\n' "$msg" | grep -Eiq "$msg_pattern"; then
    if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
      echo "::error title=Tac gia AI trong commit::$short co trailer AI trong message"
    fi
    echo "FAIL commit $short: message chua dau vet AI"
    printf '%s\n' "$msg" | grep -Ein "$msg_pattern" | sed 's/^/    /'
    fail=1
  fi

  if printf '%s <%s> %s <%s>' "$an" "$ae" "$cn" "$ce" | grep -Eiq "$id_pattern"; then
    echo "FAIL commit $short: danh tinh commit la AI -> $an <$ae>"
    fail=1
  fi
done

if [ "$fail" -ne 0 ]; then
  echo
  echo "Phat hien $count commit, co commit vi pham quy tac khong dan ten AI."
  echo "Sua: bo trailer trong message (git rebase -i / git commit --amend -m '<message sach>') roi push lai."
  exit 1
fi

echo "OK: $count commit, khong co dau vet tac gia AI."
