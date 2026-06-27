#!/usr/bin/env bash
set -euo pipefail

target_dir="${1:?target directory missing}"
external_dir="$(cd "$(dirname "$0")/.." && pwd)"

install -D -m 0644 "$external_dir/board/raspiplay/cmdline.txt" \
  "$BINARIES_DIR/rpi-firmware/cmdline.txt"

mkdir -p "$target_dir/run" "$target_dir/tmp" "$target_dir/var/lib/misc" \
  "$target_dir/var/lib/bluetooth" "$target_dir/var/log" "$target_dir/var/run"

rm -f "$target_dir/etc/init.d/S80dnsmasq"
rm -f "$target_dir/etc/init.d/S90httpd"

find "$target_dir/etc/init.d" -type f -name 'S*' -exec chmod 0755 {} +
find "$target_dir/usr/bin" -type f -name 'radio-*' -exec chmod 0755 {} +
find "$target_dir/www/cgi-bin" -type f -exec chmod 0755 {} +
