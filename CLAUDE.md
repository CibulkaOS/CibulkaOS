# CibulkaOS

Satirická distribuce Arch Linuxu (archiso + KDE Plasma 6 Wayland + Calamares) na motivy Petra Cibulky.

## Speciální funkcionalita systému
- **Grafický instalátor (Calamares):** KDE Plasma 6 Wayland, Btrfs subvolumes (`/@`, `/@home`, `/@cache`, `/@log`), SDDM, automatické odstranění `calamares` po instalaci.
- **Anti-GRU(B) Bootloader:** GRUB přejmenován/brandován na Anti-GRUB s vlastním grafickým tématem (portrét Petra Cibulky), wrappery `anti-grub-mkconfig` / `anti-grub-install` a startovací kontrolou `anti-grub-check.service`.
- **Siderický generátor náhodných čísel (`/dev/kyvadlo`):** `/dev/kyvadlo` vytvářené přes udev (`99-kyvadlo.rules`) i tmpfiles (`kyvadlo.conf`); nástroj `kyvadlo --generuj-klic` a `--stav`.
- **Příkaz `sudo` nahrazen `kyvadlo`:** `/usr/local/bin/sudo` přesměrovává na `/usr/local/bin/kyvadlo`, který čte náhodný bajt z `/dev/kyvadlo` a s 50% pravděpodobností přístup zamítne jako infiltrovanému agentovi StB.
- **Lustrace uživatelů:** Root uživatel (UID 0) se jmenuje `cibulka`. Příkaz `/usr/local/bin/adduser` (a samostatný `/usr/local/bin/lustrace`) prověřuje uživatele (včetně `-c "Jméno Příjmení"`) proti **100 666 reálným historickým záznamům StB** v `/usr/share/cibulkaos/cibulkovy-seznamy.tsv.gz` (vygenerováno ze `seznam.xls` pomocí `scripts/generate-seznamy.py`) s normalizací české diakritiky; při shodě vypíše skutečné archivní záznamy (krycí jméno, druh svazku, reg. č., protokol) a účet zamítne/smaže (`userdel -rf`).
- **Firewall proti fízlokracii:** Služba `fizlokracie.service` (`/usr/local/sbin/fizlokracie-firewall`) blokuje ruské a čínské IPv4 rozsahy přes `nftables` (s fallbackem na `iptables`). Shellový profil `/etc/profile.d/cibulka.sh` přepisuje síťové a shellové chyby (404, DNS, odmítnuté spojení, nenalezený příkaz) na „Úspěšná sabotáž marxisticko-leninských struktur“.

## Build a testovací příkazy (`Makefile`)
Build systém používá `archiso` (https://wiki.archlinux.org/title/Archiso) a lokální pacman repozitář `/tmp/cibulkaos-localrepo` pro vlastní build Calamares 3.4+.

```bash
make pkgs           # Sestaví patchovaný Calamares do /tmp/cibulkaos-localrepo (BEZ sudo)
make build          # Sestaví ISO do out/cibulkaos-YYYY.MM.DD-x86_64.iso (volá sudo mkarchiso)
make run            # Spustí poslední ISO v QEMU (UEFI + KVM)
make run-bios       # Spustí poslední ISO v QEMU (legacy BIOS)
make run-install    # Vytvoří out/cibulkaos-disk.qcow2 (20G) a spustí ISO + disk v QEMU
make run-installed  # Nabootuje nainstalovaný systém z out/cibulkaos-disk.qcow2
make clean          # Smaže work/
make clean-disk     # Smaže out/cibulkaos-disk.qcow2
make clean-pkgs     # Smaže lokální repo a build cache Calamares
```

## Struktura repozitáře
- `archlive/` – profil pro `mkarchiso`:
  - `profiledef.sh` – metadata ISO, bootmodes (`bios.syslinux`, `uefi.grub`) a `file_permissions` (každý nový skript/sudoers soubor sem musí být doplněn).
  - `packages.x86_64` – seznam balíčků (base, KDE Plasma 6 Wayland, SDDM, NetworkManager, nftables, Calamares).
  - `pacman.conf` – repozitáře `core`, `extra` + lokální `[cibulkaos]` (`file:///tmp/cibulkaos-localrepo`).
  - `grub/` & `syslinux/` – konfigurace a téma zavaděče pro live ISO.
  - `airootfs/` – overlay kořenového souborového systému:
    - `etc/passwd`, `etc/shadow` – UID 0 účet `cibulka` (bez účtu `root`).
    - `etc/sudoers.d/10-cibulka` – `Defaults runas_default=cibulka` (nutné, aby `/usr/bin/sudo` fungovalo bez uživatele `root`).
    - `etc/calamares/` – konfigurace Calamares 3.4 (`settings.conf`, `modules/*.conf`, `branding/cibulkaos/`).
    - `etc/profile.d/cibulka.sh` – wrappery pro `curl`, `ping` a `command_not_found_handle(r)` (načítáno v bash i zsh včetně non-login terminálů přes `/etc/bash.bashrc` a `.zshrc.local`).
    - `etc/systemd/system/fizlokracie.service`, `anti-grub-check.service` – systémové služby.
    - `etc/udev/rules.d/99-kyvadlo.rules`, `etc/tmpfiles.d/kyvadlo.conf` – vytváření `/dev/kyvadlo`.
    - `etc/xdg/autostart/cibulkaos-wallpaper.desktop` – jednorázové nastavení tapety Petra Cibulky po prvním přihlášení do KDE.
    - `root/customize_airootfs.sh` – běží v chrootu po `pacstrap`: zálohuje kernel/ucode do `/usr/share/cibulkaos/boot/`, zapisuje `/usr/lib/os-release` a přidává hook do `/etc/bash.bashrc`.
    - `usr/local/bin/` – `kyvadlo`, `sudo`, `adduser`, `lustrace`, `restore-kernel`, `anti-grub-mkconfig`, `anti-grub-install`, `cibulkaos-firstboot-wallpaper`.
    - `usr/local/sbin/` – `fizlokracie-firewall`, `anti-grub-check`.
    - `usr/share/cibulkaos/` – `cibulkovy-seznamy.tsv.gz` (100 666 reálných záznamů StB), `cibulkovy-seznamy.txt` (fallback), `linux.preset`.
    - `usr/share/grub/themes/cibulkaos/` – Anti-GRUB téma kopírované do cílového systému.
- `pkgbuilds/calamares/PKGBUILD` *(gitignored v `pkgbuilds/`)* – staví Calamares ze zdrojáků s patchem v `prepare()`, aby `SetPasswordJob` nastavoval heslo pro `"cibulka"` místo `"root"` a `networkcfg` ignoroval `"cibulka"` jako live uživatele.
- `web/` – samostatná statická prezentační WWW stránka (`index.html`, `style.css`, `app.js`, `assets/Petr_Cibulka.jpg`) bez build kroku a bez externích JS knihoven, s přehledem funkcí a návodem k sestavení.

## Kritické detaily a pastičky (neměnit bez ověření!)
1. **UID 0 = `cibulka` (žádný `root` v `/etc/passwd`):**
   - `pkgbuilds/calamares/PKGBUILD` musí obsahovat patch v `prepare()` pro `SetPasswordJob("cibulka", ...)`, jinak Calamares selže (`usermod: user 'root' does not exist`).
   - `preservefiles.conf` musí mít `perm: cibulka:root:...` (uživatel `root` neexistuje, skupina `root` GID 0 ano).
   - `/etc/sudoers.d/10-cibulka` musí mít `Defaults runas_default=cibulka` a práva `0440` v `profiledef.sh`.
2. **Btrfs + GRUB `premature end of file`:**
   - `restore-kernel` i `customize_airootfs.sh` **musí** kopírovat `vmlinuz-linux` a microcode s `cp --sparse=never`. Výchozí `--sparse=auto` vytvoří u nulového konce jádra sparse díru, na které GRUB Btrfs ovladač selže při bootu.
   - `grubcfg.conf` používá `GRUB_DEFAULT: 0` (na Btrfs `GRUB_DEFAULT=saved` vyhazuje `sparse file not allowed`).
3. **Schémata Calamares 3.4:**
   - `mount.conf`: `options: [ bind ]` (musí být YAML pole, ne string!) a `efivarfs` uvnitř `extraMounts` s `efi: true`.
   - `services-systemd.conf`: používá klíč `units:` s `action: enable/disable` (ne `services:`/`enabled:`).
   - `displaymanager.conf`: Plasma 6 Wayland má `desktopFile: "plasma"` (ne `plasmawayland`).
   - `shellprocess*.conf`: používá `dontChroot: false` (ne `chroot: true`) a vlastní instance vyžadují sekci `instances:` v `settings.conf`.
4. **Konflikty souborů při `pacstrap`:**
   - Do `archlive/airootfs/` nevkládat `/etc/os-release`, `/etc/skel/.bashrc` ani `/etc/skel/.zshrc` (kolidují s balíčky `filesystem`, `bash`, `grml-zsh-config`). Úpravy dělat v `customize_airootfs.sh` nebo přes `.zshrc.local`.
5. **Synchronizace Cibulkových seznamů:**
   - Při úpravě `archlive/airootfs/usr/share/cibulkaos/cibulkovy-seznamy.txt` udržovat v souladu i `forbidden_names` v `archlive/airootfs/etc/calamares/modules/users.conf`.
