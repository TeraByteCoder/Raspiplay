#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILDROOT_VERSION="2026.02.3"
BUILDROOT_URL="https://gitlab.com/buildroot.org/buildroot.git"
BUILDROOT_DIR="$PROJECT_DIR/buildroot"
OUTPUT_DIR="$PROJECT_DIR/output"
EXTERNAL_DIR="$PROJECT_DIR/br2_external"
DEFCONFIG="raspiplay_zero_w_defconfig"

arch_packages=(
  base-devel
  bc
  cpio
  file
  git
  ncurses
  perl
  python
  rsync
  unzip
  wget
  which
)

missing_packages=()
for package in "${arch_packages[@]}"; do
  if ! pacman -Qi "$package" >/dev/null 2>&1; then
    missing_packages+=("$package")
  fi
done

if ((${#missing_packages[@]})); then
  echo "Installing missing Arch packages: ${missing_packages[*]}"
  sudo pacman -S --needed --noconfirm "${missing_packages[@]}"
fi

if [[ ! -d "$BUILDROOT_DIR/.git" ]]; then
  git clone --depth 1 --branch "$BUILDROOT_VERSION" "$BUILDROOT_URL" "$BUILDROOT_DIR"
else
  echo "Using existing Buildroot checkout at $BUILDROOT_DIR"
fi

make -C "$BUILDROOT_DIR" O="$OUTPUT_DIR" BR2_EXTERNAL="$EXTERNAL_DIR" "$DEFCONFIG"
make -C "$BUILDROOT_DIR" O="$OUTPUT_DIR" olddefconfig
make -C "$BUILDROOT_DIR" O="$OUTPUT_DIR" -j"$(nproc)"

image="$OUTPUT_DIR/images/sdcard.img"
if [[ ! -f "$image" ]]; then
  echo "Build finished, but $image was not created." >&2
  exit 1
fi

echo
echo "Image created:"
echo "$image"

