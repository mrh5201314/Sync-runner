#!/bin/bash
# ====================== 导出项目的 tags + branches ======================

# 切换到脚本所在目录，确保工作目录正确
cd "$(dirname "$0")" || exit 1

# 获取当前文件夹名（项目名）
FolderName=$(basename "$PWD")

# 检查 Git 仓库
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "不是 Git 仓库，无法导出。"
    exit 1
fi

# ---------- 收集 tags ----------
tags=()
while IFS= read -r tag; do
    tags+=("$tag")
done < <(git tag --sort=creatordate)

# ---------- 收集本地分支（按最近提交排序） ----------
branches=()
while IFS= read -r branch; do
    branches+=("$branch")
done < <(git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads)

tag_idx=${#tags[@]}
branch_idx=${#branches[@]}
total_idx=$((tag_idx + branch_idx))

if [ "$total_idx" -eq 0 ]; then
    echo "该项目没有任何标签或分支。"
    exit 0
fi

# 安全文件名函数：将 / \ : 替换为 _
safe_name() {
    echo "$1" | sed 's|[/\\:]|_|g'
}

# 导出单个项目的函数
export_item() {
    local name="$1"
    local safe=$(safe_name "$name")
    local output_zip="${FolderName}_${safe}.zip"
    echo "导出: $name"
    if git archive --format=zip --output="$output_zip" "$name"; then
        echo "成功导出: $output_zip"
    else
        echo "导出失败: $name"
        return 1
    fi
}

# ====================== 主菜单 ======================
while true; do
    echo
    echo "===== 项目 $FolderName 的标签与分支列表 ====="

    if [ "$tag_idx" -gt 0 ]; then
        echo "[标签]"
        for ((i=0; i<tag_idx; i++)); do
            echo "$((i+1)). ${tags[$i]}"
        done
    else
        echo "[标签] 无"
    fi

    echo
    if [ "$branch_idx" -gt 0 ]; then
        echo "[分支]"
        for ((i=0; i<branch_idx; i++)); do
            echo "$((tag_idx + i + 1)). ${branches[$i]}"
        done
    else
        echo "[分支] 无"
    fi

    echo
    echo "0. 导出全部标签和分支"
    echo
    read -p "请输入编号 (1-$total_idx) 或输入 0 导出全部: " choice

    # 空输入重新显示
    if [ -z "$choice" ]; then
        continue
    fi

    # 导出全部
    if [ "$choice" = "0" ]; then
        echo
        echo "正在导出项目 $FolderName 的所有标签和分支..."
        for tag in "${tags[@]}"; do
            export_item "$tag"
        done
        for branch in "${branches[@]}"; do
            export_item "$branch"
        done
        echo
        echo "√ 项目 $FolderName 的所有标签和分支已导出到当前目录。"
        echo "   文件名格式：项目名_标签名或分支名.zip"
        sleep 2
        exit 0
    fi

    # 校验是否为纯数字
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        continue
    fi

    if [ "$choice" -lt 1 ] || [ "$choice" -gt "$total_idx" ]; then
        continue
    fi

    # 判断选中的是标签还是分支
    if [ "$choice" -le "$tag_idx" ]; then
        idx=$((choice - 1))
        selected="${tags[$idx]}"
        export_item "$selected"
    else
        idx=$((choice - tag_idx - 1))
        selected="${branches[$idx]}"
        export_item "$selected"
    fi

    echo
    sleep 2
    exit 0
done