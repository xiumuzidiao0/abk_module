#!/usr/bin/env bash
set -euo pipefail

CONFIGS=(
  CONFIG_USER_NS
  CONFIG_NETFILTER_XT_TARGET_REJECT
  CONFIG_NETFILTER_XT_TARGET_LOG
  CONFIG_NETFILTER_XT_MATCH_RECENT
  CONFIG_IP_SET
  CONFIG_IP_SET_HASH_IP
  CONFIG_IP_SET_HASH_NET
  CONFIG_NETFILTER_XT_SET
  CONFIG_TMPFS_POSIX_ACL
  CONFIG_TMPFS_XATTR
)

if [ "${CUSTOM_EXTERNAL_MODULE_STAGE:-}" != "before_build" ]; then
  echo "::warning::Enable USER_NS is intended for before_build; current stage: ${CUSTOM_EXTERNAL_MODULE_STAGE:-unknown}"
fi

if [ -z "${DEFCONFIG:-}" ]; then
  echo "::error::DEFCONFIG is not set; cannot update kernel defconfig."
  exit 1
fi

if [ ! -f "$DEFCONFIG" ]; then
  echo "::error::DEFCONFIG does not exist: $DEFCONFIG"
  exit 1
fi

ensure_defconfig_value() {
  local cfg="$1"
  local value="$2"
  local line="${cfg}=${value}"

  if grep -qxF "$line" "$DEFCONFIG"; then
    echo "$line already present in $DEFCONFIG"
    return 0
  fi

  if grep -Eq "^${cfg}=|^# ${cfg} is not set$" "$DEFCONFIG"; then
    sed -i -E "s|^${cfg}=.*|${line}|; s|^# ${cfg} is not set$|${line}|" "$DEFCONFIG"
  else
    printf '\n%s\n' "$line" >> "$DEFCONFIG"
  fi

  if ! grep -qxF "$line" "$DEFCONFIG"; then
    echo "::error::Failed to write $line to $DEFCONFIG"
    exit 1
  fi

  echo "Wrote $line to $DEFCONFIG"
}

for cfg in "${CONFIGS[@]}"; do
  ensure_defconfig_value "$cfg" y
done
