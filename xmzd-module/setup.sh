#!/usr/bin/env bash
set -euo pipefail

echo "================================================="
echo "正在执行自定义模块：追加 CONFIG_USER_NS"
echo "内核源码根目录: $KERNEL_ROOT"
echo "当前 Defconfig 路径: $DEFCONFIG"
echo "================================================="

# 确保 defconfig 文件存在
if [ ! -f "$DEFCONFIG" ]; then
    echo "错误: 未找到 defconfig 文件 ($DEFCONFIG)"
    exit 1
fi

# 检查是否已经存在该配置，避免重复追加
if grep -q '^CONFIG_USER_NS=' "$DEFCONFIG"; then
    echo "提示: CONFIG_USER_NS 已存在于配置中，正在检查其值..."
    # 如果存在但被关闭了 (比如 # CONFIG_USER_NS is not set)，可以先删除它
    sed -i '/CONFIG_USER_NS/d' "$DEFCONFIG"
fi

# 正式追加配置
echo "CONFIG_USER_NS=y" >> "$DEFCONFIG"
echo "成功: 已将 CONFIG_USER_NS=y 追加到 defconfig"
echo "================================================="
