#!/usr/bin/env bash
# Runs inside the build chroot after packages are installed, before
# _cleanup_pacstrap_dir deletes /boot. Saves kernel and ucode images so the
# Calamares shellprocess step can restore them into the installed system.
set -e
mkdir -p /usr/share/cibulkaos/boot
for f in /boot/vmlinuz-linux /boot/intel-ucode.img /boot/amd-ucode.img; do
    [ -f "$f" ] && cp -a "$f" /usr/share/cibulkaos/boot/
done
