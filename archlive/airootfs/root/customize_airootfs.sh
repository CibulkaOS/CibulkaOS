#!/usr/bin/env bash
# Runs inside the build chroot after packages are installed, before
# _cleanup_pacstrap_dir deletes /boot.
set -e

# 1) Zálohuje kernel a microcode pro obnovu přes Calamares (shellprocess@restore-kernel)
mkdir -p /usr/share/cibulkaos/boot
for f in /boot/vmlinuz-linux /boot/intel-ucode.img /boot/amd-ucode.img; do
    [ -f "$f" ] && cp -a --sparse=never "$f" /usr/share/cibulkaos/boot/
done

# 2) Identita distribuce v /usr/lib/os-release: zdroj je /usr/share/cibulkaos/os-release
#    z balíčku cibulkaos-base, zapisuje ho pacman hook cibulkaos-os-release.hook (i po upgradu
#    balíčku 'filesystem'). Zde jen pojistka pro případ, že hook při pacstrap neproběhl.
install -m644 /usr/share/cibulkaos/os-release /usr/lib/os-release

# 2b) Čeština jako jazyk live systému (Plasma i Calamares běží česky, LANG v /etc/locale.conf)
sed -i -e 's/^#\(cs_CZ.UTF-8 UTF-8\)/\1/' -e 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen

# 3) Zajistí načítání /etc/profile.d/cibulka.sh i v interaktivních non-login bash shellech (např. Konsole)
if [ -f /etc/bash.bashrc ] && ! grep -q '/etc/profile.d/cibulka.sh' /etc/bash.bashrc; then
    printf '\n# CibulkaOS shell ochrana proti fízlokracii\n[ -r /etc/profile.d/cibulka.sh ] && . /etc/profile.d/cibulka.sh\n' >> /etc/bash.bashrc
fi

# 3b) Online repo [cibulkaos] (GitHub Releases) pro aktualizace cibulkaos-base v live i nainstalovaném
#     systému (unpackfs kopíruje /etc/pacman.conf do cíle). Adresa je v /etc/pacman.d/cibulkaos-mirrorlist
#     z balíčku. Balíčky zatím nejsou podepsané -> SigLevel Optional (ochranu dává jen HTTPS GitHubu).
if ! grep -q '^\[cibulkaos\]' /etc/pacman.conf; then
    printf '\n# CibulkaOS – aktualizace balíčku cibulkaos-base\n[cibulkaos]\nSigLevel = Optional TrustAll\nInclude = /etc/pacman.d/cibulkaos-mirrorlist\n' >> /etc/pacman.conf
fi

# 4) Odstraní případný zatoulaný neprivilegovaný účet 'root' vytvořený sysusers během pacstrap
sed -i '/^root:/d' /etc/passwd /etc/shadow || true
