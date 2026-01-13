#!/bin/bash
# dex installer script

set -e

VERSION="${VERSION:-latest}"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

# Detect OS and architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Darwin)
    case "$ARCH" in
      arm64|aarch64)
        ARTIFACT="dex-macos-aarch64.tar.gz"
        ;;
      x86_64)
        ARTIFACT="dex-macos-x86_64.tar.gz"
        ;;
      *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
    esac
    ;;
  Linux)
    case "$ARCH" in
      x86_64)
        ARTIFACT="dex-linux-x86_64.tar.gz"
        ;;
      *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
    esac
    ;;
  *)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac

echo "Installing dex $VERSION for $OS $ARCH..."

# Download and install
DOWNLOAD_URL="https://github.com/modiqo/dex-releases/raw/main/releases/$VERSION/$ARTIFACT"

echo "Downloading from: $DOWNLOAD_URL"
curl -fsSL "$DOWNLOAD_URL" | tar xz

# Install
if [ -w "$INSTALL_DIR" ]; then
  mv dex "$INSTALL_DIR/"
else
  sudo mv dex "$INSTALL_DIR/"
fi

echo ""
echo "✓ dex installed successfully!"
echo ""
echo "Verify installation:"
echo "  dex --version"
echo ""
echo "Get started:"
echo "  dex join <your-invite-code>"
echo "  dex register --provider google"
