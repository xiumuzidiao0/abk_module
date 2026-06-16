# Enable USER_NS ABK External Module

This is a minimal ABK custom external module that enables Linux user namespaces
and DroidSpaces-recommended defconfig options by writing these options to the
active GKI defconfig:

```text
CONFIG_USER_NS=y
CONFIG_NETFILTER_XT_TARGET_REJECT=y
CONFIG_NETFILTER_XT_TARGET_LOG=y
CONFIG_NETFILTER_XT_MATCH_RECENT=y
CONFIG_IP_SET=y
CONFIG_IP_SET_HASH_IP=y
CONFIG_IP_SET_HASH_NET=y
CONFIG_NETFILTER_XT_SET=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
```

Use it as a `before_build` custom external module. The ABK workflow executes
`setup.sh` from the module repository root and provides `$DEFCONFIG`.

Example workflow input:

```text
https://github.com/your-name/userns-defconfig;before_build
```

The script is idempotent. It replaces an existing `CONFIG_USER_NS=...` line or
`# CONFIG_USER_NS is not set`, and appends the option only when missing.
