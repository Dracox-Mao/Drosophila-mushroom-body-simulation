#!/bin/sh
# 一键发布到 GitHub（在你自己的电脑上运行）
#   用法：sh push-to-github.sh [仓库名]
#   默认仓库名：fly-mushroom-body
set -e

REPO="${1:-fly-mushroom-body}"
GH_USER="Dracox-Mao"

if [ ! -f index.html ]; then
  echo "✗ 请在解压后的 fly-mushroom-body 目录里运行本脚本"
  exit 1
fi

if [ ! -d .git ]; then
  git init
  git branch -M main 2>/dev/null || true
fi

git add -A
git commit -m "feat: 果蝇蘑菇体 3D 神经模拟（LIF + 稀疏编码 + 多巴胺门控可塑 + LLM 果蝇人格）" || echo "（没有新改动，跳过提交）"

# 用 gh 建远程仓库（推荐）；没有 gh 就手动建
if command -v gh >/dev/null 2>&1; then
  gh repo create "$GH_USER/$REPO" --public --source=. --remote=origin --push
  echo "✓ 已创建并推送：https://github.com/$GH_USER/$REPO"
else
  echo "未检测到 gh CLI。请手动："
  echo "  1) 浏览器打开 https://github.com/new 新建仓库 $REPO（不要勾选 README）"
  echo "  2) 然后运行："
  echo "     git remote add origin https://github.com/$GH_USER/$REPO.git"
  echo "     git push -u origin main"
  exit 0
fi

cat <<'EOF'

—— 下一步（可选）——
开启 GitHub Pages 让它在线可玩：
  仓库 → Settings → Pages → Source 选 "Deploy from a branch" → Branch: main / (root) → Save
  等约 30 秒，访问：https://<用户名>.github.io/fly-mushroom-body/
EOF
