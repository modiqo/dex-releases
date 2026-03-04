# dex $VERSION

## Installation

### macOS (Apple Silicon)
```bash
curl -L https://github.com/modiqo/dex-releases/raw/main/releases/$VERSION/dex-macos-aarch64.tar.gz | tar xz
sudo mv dex /usr/local/bin/
```

### macOS (Intel)
```bash
curl -L https://github.com/modiqo/dex-releases/raw/main/releases/$VERSION/dex-macos-x86_64.tar.gz | tar xz
sudo mv dex /usr/local/bin/
```

### Linux (x86_64) - glibc
```bash
curl -L https://github.com/modiqo/dex-releases/raw/main/releases/$VERSION/dex-linux-x86_64.tar.gz | tar xz
sudo mv dex /usr/local/bin/
```

### Linux (ARM64) - glibc
```bash
curl -L https://github.com/modiqo/dex-releases/raw/main/releases/$VERSION/dex-linux-aarch64.tar.gz | tar xz
sudo mv dex /usr/local/bin/
```

### Linux (x86_64) - musl (static, works on any distro)
```bash
curl -L https://github.com/modiqo/dex-releases/raw/main/releases/$VERSION/dex-linux-x86_64-musl.tar.gz | tar xz
sudo mv dex /usr/local/bin/
```

### Linux (ARM64) - musl (static, works on any distro)
```bash
curl -L https://github.com/modiqo/dex-releases/raw/main/releases/$VERSION/dex-linux-aarch64-musl.tar.gz | tar xz
sudo mv dex /usr/local/bin/
```

## Verify Installation
```bash
dex --version
```

## What's New

See CHANGELOG.md for details.
