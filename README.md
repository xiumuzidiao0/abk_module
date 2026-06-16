# Enable USER_NS ABK External Module

This is a minimal ABK custom external module that enables Linux user namespaces
by writing this option to the active GKI defconfig:

```text
CONFIG_USER_NS=y
```

Use it as a `before_build` custom external module. The ABK workflow executes
`setup.sh` from the module repository root and provides `$DEFCONFIG`.

Example workflow input:

```text
https://github.com/your-name/userns-defconfig;before_build
```

The script is idempotent. It replaces an existing `CONFIG_USER_NS=...` line or
`# CONFIG_USER_NS is not set`, and appends the option only when missing.
