# Raspiplay Radio Sender

Minimal Buildroot image for a Raspberry Pi Zero W (first generation, ARMv6) that receives Bluetooth A2DP audio and retransmits it through `pifmadv` on GPIO 4 / physical pin 7.

The root filesystem is embedded as a gzip-compressed initramfs and runs from RAM. The generated SD card image only contains the boot partition, firmware, device tree, and kernel, so normal power loss does not corrupt the root filesystem.

## Features

- Buildroot-based Raspberry Pi Zero W image using `raspberrypi0w_defconfig` semantics.
- BusyBox init, no systemd, no PulseAudio, no PipeWire.
- Read-only initramfs root filesystem with volatile `/tmp`, `/run`, and `/var` tmpfs mounts.
- BlueZ 5, BlueALSA, `bt-agent`, and automatic trust loop for incoming Bluetooth devices.
- WLAN client mode with SSH enabled for debugging.
- BusyBox `httpd` web UI with an FM frequency slider from 87.5 to 108.0 MHz.
- `pifmadv` cross-compiled for Raspberry Pi 1/Zero ARMv6.

## Build

On Arch Linux:

```bash
./build.sh
```

The final image is written to:

```text
output/images/sdcard.img
```

Write it to an SD card:

```bash
sudo dd if=output/images/sdcard.img of=/dev/sdX bs=4M conv=fsync status=progress
```

Replace `/dev/sdX` with the actual block device.

## Runtime

- The Pi connects to the configured Wi-Fi on boot.
- SSH login: `radio` / `radio` or `root` / `radio`.
- Pair a phone with Bluetooth device `Radio-Sender`.
- Set the FM frequency in the web UI.

The frequency backend calls:

```bash
arecord -D bluealsa -f S16_LE -r 44100 -c 2 | pifmadv --audio - --freq <frequency>
```

## Project Layout

```text
br2_external/
  board/raspiplay/              Buildroot board files, kernel fragment, genimage config
  configs/                      Buildroot defconfig
  package/pifmadv/              External Buildroot package for PiFmAdv
rootfs_overlay/
  etc/init.d/                   SysV startup scripts
  etc/hostapd/                  Access point configuration
  etc/dnsmasq.d/                DHCP/DNS configuration
  usr/bin/                      Radio control scripts
  www/                          BusyBox httpd document root and CGI
build.sh                        Full Arch Linux build automation
```

## Notes

Modern Buildroot uses `raspberrypi0w_defconfig` for the first-generation Raspberry Pi Zero W. Older references to `raspberrypizero_defconfig` are not valid in Buildroot 2026.02.x.

`pifmadv` is an experimental FM transmitter. Transmitting RF without authorization is illegal in many jurisdictions. Use a shielded/direct connection and comply with local regulations.
