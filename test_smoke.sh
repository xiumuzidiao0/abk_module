#!/usr/bin/env bash
set -euo pipefail

module_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cp "$module_dir/setup.sh" "$tmp/setup.sh"

printf 'CONFIG_FOO=y\n' > "$tmp/defconfig"
(
  cd "$tmp"
  DEFCONFIG="$tmp/defconfig" CUSTOM_EXTERNAL_MODULE_STAGE=before_build bash setup.sh
  DEFCONFIG="$tmp/defconfig" CUSTOM_EXTERNAL_MODULE_STAGE=before_build bash setup.sh
)

expected_configs=(
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

for cfg in "${expected_configs[@]}"; do
  count="$(grep -c "^${cfg}=y$" "$tmp/defconfig")"
  if [ "$count" != "1" ]; then
    echo "expected one ${cfg}=y after repeated runs, got $count"
    exit 1
  fi
done

printf '# CONFIG_USER_NS is not set\n' > "$tmp/defconfig"
(
  cd "$tmp"
  DEFCONFIG="$tmp/defconfig" CUSTOM_EXTERNAL_MODULE_STAGE=before_build bash setup.sh
)

if ! grep -qxF 'CONFIG_USER_NS=y' "$tmp/defconfig"; then
  echo "expected disabled CONFIG_USER_NS line to be replaced"
  exit 1
fi

echo "smoke test passed"
