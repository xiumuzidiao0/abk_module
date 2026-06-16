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

count="$(grep -c '^CONFIG_USER_NS=y$' "$tmp/defconfig")"
if [ "$count" != "1" ]; then
  echo "expected one CONFIG_USER_NS=y after repeated runs, got $count"
  exit 1
fi

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
