#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="cibulkaos"
iso_label="CIBULKAOS_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Petr Cibulka <https://cibulka.net>"
iso_application="CibulkaOS - Distribuce pro svobodné Čechy"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux'
           'uefi.grub')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/sudoers.d/10-cibulka"]="0:0:440"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/root/Desktop/install-cibulkaos.desktop"]="0:0:644"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  ["/usr/local/bin/kyvadlo"]="0:0:755"
  ["/usr/local/bin/sudo"]="0:0:755"
  ["/usr/local/bin/adduser"]="0:0:755"
  ["/usr/local/bin/lustrace"]="0:0:755"
  ["/usr/local/bin/restore-kernel"]="0:0:755"
  ["/usr/local/bin/anti-grub-mkconfig"]="0:0:755"
  ["/usr/local/bin/anti-grub-install"]="0:0:755"
  ["/usr/local/bin/cibulkaos-firstboot-wallpaper"]="0:0:755"
  ["/usr/local/sbin/fizlokracie-firewall"]="0:0:755"
  ["/usr/local/sbin/anti-grub-check"]="0:0:755"
)
