#!/usr/bin/env bash
# ==============================================================================
# ABK 外部模块核心脚本 - 完整健壮版
# ==============================================================================
set -euo pipefail

# 1. 导入/读取配置文件（如果有需要的话）
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
if [ -f "${SCRIPT_DIR}/module.conf" ]; then
    source "${SCRIPT_DIR}/module.conf"
    echo "=== [${MODULE_NAME} v${MODULE_VERSION}] By ${MODULE_AUTHOR} ==="
else
    echo "=== [未知模块] 开始执行 ==="
fi

echo "-> 当前构建组合: ${CONFIG}"
echo "-> 目标 Defconfig: ${DEFCONFIG}"

# 2. 安全检查：确保当前执行阶段正确
if [ "${CUSTOM_EXTERNAL_MODULE_STAGE}" != "after_patch" ]; then
    echo "ℹ️ [跳过] 当前阶段为 ${CUSTOM_EXTERNAL_MODULE_STAGE}，本模块仅在 after_patch 阶段运行。"
    exit 0
fi

# 3. 确保目标 defconfig 文件存在
if [ ! -f "$DEFCONFIG" ]; then
    echo "❌ [错误] 未找到 defconfig 文件: $DEFCONFIG"
    exit 1
fi

# 4. 创建备份（良好习惯：修改前留退路）
echo "-> 正在备份原始 defconfig..."
cp "$DEFCONFIG" "${DEFCONFIG}.bak"

# 5. 幂等性处理与配置追加
echo "-> 正在优化 defconfig 配置..."
# 清理可能存在的冲突项 (包括注释掉的、显式关闭的、或者已经存在的)
sed -i '/CONFIG_USER_NS/d' "$DEFCONFIG"

# 追加你需要的配置
cat << EOF >> "$DEFCONFIG"
# --- Custom External Module: Enable User Namespace ---
CONFIG_USER_NS=y
# -----------------------------------------------------
EOF

# 6. 最终验证
if grep -q '^CONFIG_USER_NS=y$' "$DEFCONFIG"; then
    echo "✅ [成功] CONFIG_USER_NS=y 已成功注入到 defconfig！"
    # 打印最后几行确认
    tail -n 5 "$DEFCONFIG"
else
    echo "❌ [失败] 写入配置失败，正在还原备份..."
    mv "${DEFCONFIG}.bak" "$DEFCONFIG"
    exit 1
fi

echo "================================================="
