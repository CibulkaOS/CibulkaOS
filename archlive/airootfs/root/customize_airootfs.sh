#!/usr/bin/env bash
# Runs inside the build chroot after packages are installed, before
# _cleanup_pacstrap_dir deletes /boot.
set -e

# 1) Zálohuje kernel a microcode pro obnovu přes Calamares (shellprocess@restore-kernel)
mkdir -p /usr/share/cibulkaos/boot
for f in /boot/vmlinuz-linux /boot/intel-ucode.img /boot/amd-ucode.img; do
    [ -f "$f" ] && cp -a --sparse=never "$f" /usr/share/cibulkaos/boot/
done

# 2) Nastaví identitu distribuce CibulkaOS v /usr/lib/os-release (bez konfliktu s balíčkem filesystem)
cat > /usr/lib/os-release <<'EOF'
NAME="CibulkaOS"
PRETTY_NAME="CibulkaOS (Anti-GRU Edition)"
ID=cibulkaos
ID_LIKE=arch
BUILD_ID=rolling
ANSI_COLOR="38;2;255;215;0"
HOME_URL="https://cibulka.net/"
DOCUMENTATION_URL="https://cibulka.net/"
SUPPORT_URL="https://cibulka.net/"
BUG_REPORT_URL="https://cibulka.net/"
LOGO=archlinux-logo
EOF

# 3) Zajistí načítání /etc/profile.d/cibulka.sh i v interaktivních non-login bash shellech (např. Konsole)
if [ -f /etc/bash.bashrc ] && ! grep -q '/etc/profile.d/cibulka.sh' /etc/bash.bashrc; then
    printf '\n# CibulkaOS shell ochrana proti fízlokracii\n[ -r /etc/profile.d/cibulka.sh ] && . /etc/profile.d/cibulka.sh\n' >> /etc/bash.bashrc
fi

# 4) Odstraní případný zatoulaný neprivilegovaný účet 'root' vytvořený sysusers během pacstrap
sed -i '/^root:/d' /etc/passwd /etc/shadow || true
