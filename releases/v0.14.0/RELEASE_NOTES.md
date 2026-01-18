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

### Linux (x86_64)
```bash
curl -L https://github.com/modiqo/dex-releases/raw/main/releases/$VERSION/dex-linux-x86_64.tar.gz | tar xz
sudo mv dex /usr/local/bin/
```

## Verify Installation
```bash
dex --version
```

## What's New

See CHANGELOG.md for details.
