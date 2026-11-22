# CibulkaOS

Satirická distribuce Arch Linuxu (archiso + KDE Plasma 6 Wayland + Calamares) na motivy Petra Cibulky.

## Speciální funkcionalita systému
- **Grafický instalátor (Calamares):** KDE Plasma 6 Wayland, Btrfs subvolumes (`/@`, `/@home`, `/@cache`, `/@log`), SDDM, automatické odstranění `calamares` po instalaci.
- **Anti-GRU(B) Bootloader:** GRUB přejmenován/brandován na Anti-GRUB s vlastním grafickým tématem (portrét Petra Cibulky), wrappery `anti-grub-mkconfig` / `anti-grub-install` a startovací kontrolou `anti-grub-check.service`.
- **Siderický generátor náhodných čísel (`/dev/kyvadlo`):** `/dev/kyvadlo` vytvářené přes udev (`99-kyvadlo.rules`) i tmpfiles (`kyvadlo.conf`); nástroj `kyvadlo --generuj-klic` a `--stav`.
- **Příkaz `sudo` nahrazen `kyvadlo`:** `/usr/local/bin/sudo` přesměrovává na `/usr/bin/kyvadlo`, který čte náhodný bajt z `/dev/kyvadlo` a s 50% pravděpodobností přístup zamítne jako infiltrovanému agentovi StB.
- **Lustrace uživatelů:** Root uživatel (UID 0) se jmenuje `cibulka`. Příkaz `/usr/bin/adduser` (a samostatný `/usr/bin/lustrace`) prověřuje uživatele (včetně `-c "Jméno Příjmení"`) proti **100 666 reálným historickým záznamům StB** v `/usr/share/cibulkaos/cibulkovy-seznamy.tsv.gz` (vygenerováno ze `seznam.xls` pomocí `scripts/generate-seznamy.py`) s normalizací české diakritiky; při shodě vypíše skutečné archivní záznamy (krycí jméno, druh svazku, reg. č., protokol) a účet zamítne/smaže (`userdel -rf`).
- **Firewall proti fízlokracii:** Služba `fizlokracie.service` (`/usr/bin/fizlokracie-firewall`) blokuje ruské a čínské IPv4 rozsahy přes `nftables` (s fallbackem na `iptables`). Shellový profil `/etc/profile.d/cibulka.sh` přepisuje síťové a shellové chyby (404, DNS, odmítnuté spojení, nenalezený příkaz) na „Úspěšná sabotáž marxisticko-leninských struktur“.

## Build a testovací příkazy (`Makefile`)
Build systém používá `archiso` (https://wiki.archlinux.org/title/Archiso) a lokální pacman repozitář `/tmp/cibulkaos-localrepo` pro vlastní build Calamares 3.4+, správce balíčků `shelly` a balíčku `cibulkaos-base`.

```bash
make pkgs           # pkg-calamares + pkg-shelly + pkg-base do /tmp/cibulkaos-localrepo (BEZ sudo)
make pkg-calamares  # Jen patchovaný Calamares ze zdrojáků (pomalé)
make pkg-shelly     # Jen Shelly (předkompilované binárky z GitHub Releases; spouští ho i 'make build')
make pkg-base       # Jen cibulkaos-base (rychlé; spouští ho i 'make build')
make publish-repo   # Nahraje cibulkaos-base a shelly do veřejného pacman repa (GitHub Release 'repo', vyžaduje gh)
make build          # BEZ sudo: přestaví cibulkaos-base + shelly, smaže staré kopie z pacman cache, volá sudo mkarchiso → out/cibulkaos-YYYY.MM.DD-x86_64.iso
make run            # Spustí poslední ISO v QEMU (UEFI + KVM)
make run-bios       # Spustí poslední ISO v QEMU (legacy BIOS)
make run-install    # Vytvoří out/cibulkaos-disk.qcow2 (20G) a spustí ISO + disk v QEMU
make run-installed  # Nabootuje nainstalovaný systém z out/cibulkaos-disk.qcow2
make clean          # Smaže work/
make clean-disk     # Smaže out/cibulkaos-disk.qcow2
make clean-pkgs     # Smaže lokální repo a build cache Calamares, Shelly i cibulkaos-base
```

Pozn.: `mkarchiso` přeskakuje už hotové fáze ve `work/`; po změně `cibulkaos-base` nebo `airootfs/` je před `make build` potřeba `make clean`.

## Aktualizace nainstalovaného systému
- Systém se aktualizuje běžně přes `pacman -Syu` (nebo graficky přes **Shelly**) z Arch `[core]`/`[extra]` + online repa **`[cibulkaos]`**.
- Repozitář projektu: https://github.com/CibulkaOS/CibulkaOS (organizace CibulkaOS; dřív `lukastrkan/CibulkaOS`, GitHub staré adresy včetně release assetů přesměrovává – na ně spoléhá mirrorlist v ISO v2026.11.21 a `cibulkaos-base` < 2026.11.21-3). Pacman repo `[cibulkaos]` = assety GitHub Release s tagem `repo` (`https://github.com/CibulkaOS/CibulkaOS/releases/download/repo`), obsahuje `cibulkaos-base` a `shelly` (bez Calamares).
  - `customize_airootfs.sh` připisuje do `/etc/pacman.conf` sekci `[cibulkaos]` s `Include = /etc/pacman.d/cibulkaos-mirrorlist`; mirrorlist je v balíčku, takže změna URL přijde aktualizací.
  - Balíčky zatím **nejsou podepsané** (`SigLevel = Never`, ochrana jen HTTPS GitHubu; s `Optional` se libalpm ptá na chybějící `.sig` a Shelly hlásí falešnou chybu chybějícího balíčku v cache).
  - Build ISO dál používá lokální `file:///tmp/cibulkaos-localrepo` (`archlive/pacman.conf`), ne GitHub.
- Vše specifické pro CibulkaOS je v balíčku **`cibulkaos-base`**, takže pacman soubory vlastní a umí je aktualizovat. Vydání nové verze: zvýšit `pkgver`/`pkgrel` v `pkgbuilds/cibulkaos-base/PKGBUILD` → `make publish-repo` (skript odmítne znovu publikovat stejný název souboru – klienti mají cache podle názvu).
- Pacman hooky z balíčku (`/usr/share/libalpm/hooks/`):
  - `cibulkaos-os-release.hook` – po instalaci/upgradu `filesystem` (který vlastní `/usr/lib/os-release`) zapíše zpět `/usr/share/cibulkaos/os-release`.
  - `95-cibulkaos-boot-nosparse.hook` – po `90-mkinitcpio-install.hook` přepíše `/boot/vmlinuz-*` a `/boot/*-ucode.img` přes `cp --sparse=never` (viz pastička 2).
  - `cibulkaos-grub-theme.hook` – synchronizuje téma Anti-GRUB do `/boot/grub/themes/cibulkaos/`, pokud tam existuje.
  - `cibulkaos-clean-local-db.hook` – odstraní hostitelský klíč `%INSTALLED_DB%` (z forkovaného pacmana např. na CachyOS) z `/var/lib/pacman/local/*/desc` při buildu ISO i při upgradu existujících instalací.
  - `cibulkaos-pacman-siglevel.hook` – v `/etc/pacman.conf` přepne `[cibulkaos]` ze staršího `SigLevel = Optional TrustAll` na `SigLevel = Never` (oprava falešné chyby `.sig` v Shelly).
- Klíčenku pacmana (`pacman-key --init/--populate`) vytváří instalátor v `shellprocess.conf`; v live ISO je `/etc/pacman.d/gnupg` jen tmpfs a do cíle se nekopíruje.
- Pozor: `sudo pacman -Syu` jde přes `kyvadlo` (50% zamítnutí); pro jistotu `/usr/bin/sudo pacman -Syu`.

## Vydání ISO a web
- ISO se vydává jako GitHub Release s tagem `vRRRR.MM.DD` (asset `cibulkaos-RRRR.MM.DD-x86_64.iso` + `.sha256`). **Limit GitHubu je 2 GiB na soubor** – ISO má ~2,13 GB (rezerva cca 18 MB); při přidávání balíčků hlídat velikost, případně ubrat nástroje z `packages.x86_64` převzaté z archiso `releng`.
- Release `repo` je jen úložiště pacman repa `[cibulkaos]` (spravuje `scripts/publish-repo.sh`), ISO do něj nepatří.
- Web `web/` je na **https://cibulkaos.github.io/**: `.github/workflows/pages.yml` ho při pushi do `master` (změna `web/**`) nahraje do repa `CibulkaOS/cibulkaos.github.io` (organizace CibulkaOS, Pages z větve `main`, `.nojekyll`) přes deploy klíč v secretu `PAGES_DEPLOY_KEY`. Web se upravuje jen tady ve `web/`, v cílovém repu ne (přepíše se `rsync --delete`). Toto repo samo Pages nemá (vypnuto; jinak by obsadilo https://cibulkaos.github.io/CibulkaOS/). Tlačítko ke stažení v `web/index.html` odkazuje přímo na asset konkrétního release → při novém vydání aktualizovat URL, datum a název souboru.
- Kořenový `README.md` a `LICENSE` (GPL-3.0-or-later, jako archiso). Zdroj seznamů StB: https://www.slunecnice.cz/sw/seznamy-stb-snb/

## Struktura repozitáře
- `archlive/` – profil pro `mkarchiso`:
  - `profiledef.sh` – metadata ISO, bootmodes (`bios.syslinux`, `uefi.grub`) a `file_permissions` (jen pro soubory v `airootfs/`; práva souborů z `cibulkaos-base` nastavuje jeho PKGBUILD).
  - `packages.x86_64` – seznam balíčků (base, KDE Plasma 6 Wayland, SDDM, NetworkManager, nftables, `cibulkaos-base`, Calamares).
  - `pacman.conf` – repozitáře `core`, `extra` + lokální `[cibulkaos]` (`file:///tmp/cibulkaos-localrepo`).
  - `grub/` & `syslinux/` – konfigurace a téma zavaděče pro live ISO.
  - `airootfs/` – overlay kořenového souborového systému (jen věci live ISO a to, co nemůže být v balíčku):
    - `etc/passwd`, `etc/shadow` – UID 0 účet `cibulka` (bez účtu `root`).
    - `etc/calamares/` – konfigurace Calamares 3.4 (`settings.conf`, `modules/*.conf`, `branding/cibulkaos/`).
    - `etc/systemd/system/multi-user.target.wants/{fizlokracie,anti-grub-check}.service` – symlinky na `/usr/lib/systemd/system/` (povolení služeb v live ISO; v cíli je povoluje `services-systemd.conf`).
    - `root/customize_airootfs.sh` – běží v chrootu po `pacstrap`: zálohuje kernel/ucode do `/usr/share/cibulkaos/boot/`, zapisuje `/usr/lib/os-release` (pojistka k hooku), generuje locale a přidává hook do `/etc/bash.bashrc`.
    - `usr/local/bin/` – jen archiso live nástroje (`choose-mirror`, `livecd-sound`, `Installation_guide`).
- `pkgbuilds/cibulkaos-base/` – balíček CibulkaOS; `PKGBUILD` skládá balíček přímo ze stromu `rootfs/` (zrcadlí cílové cesty, nic se nestahuje):
  - `usr/bin/` – `kyvadlo`, `adduser`, `lustrace`, `anti-grub-mkconfig`, `anti-grub-install`, `anti-grub-check`, `fizlokracie-firewall`, `cibulkaos-firstboot-wallpaper`.
  - `usr/local/bin/sudo` – záměrná výjimka (balíčky do `/usr/local` normálně nepatří): `/usr/bin/sudo` vlastní balíček `sudo` a `/usr/local/bin` je v `PATH` dřív.
  - `usr/lib/cibulkaos/` – `restore-kernel` (volá Calamares), `boot-nosparse`, `sync-grub-theme`, `clean-local-db` (volají pacman hooky).
  - `usr/share/libalpm/hooks/` – pacman hooky (viz „Aktualizace“).
  - `usr/lib/systemd/system/fizlokracie.service`, `anti-grub-check.service`; `usr/lib/udev/rules.d/99-kyvadlo.rules`, `usr/lib/tmpfiles.d/kyvadlo.conf` – `/dev/kyvadlo`.
  - `etc/sudoers.d/10-cibulka` – `Defaults runas_default=cibulka` (nutné, aby `/usr/bin/sudo` fungovalo bez uživatele `root`); práva 0750/0440 nastavuje `PKGBUILD`.
  - `etc/sysusers.d/{basic,arch}.conf` – override `/usr/lib/sysusers.d/` (UID 0 = `cibulka`, zabrání vzniku `root:979`).
  - `etc/profile.d/cibulka.sh` – wrappery pro `curl`, `ping`, `command_not_found_handle(r)` a automatické spuštění `fastfetch` při otevření interaktivního terminálu (načítáno v bash i zsh včetně non-login terminálů přes `/etc/bash.bashrc` a `.zshrc.local`); `etc/skel/.zshrc.local`.
  - `etc/xdg/` – `autostart/cibulkaos-wallpaper.desktop` (tapeta `wallpapers/CibulkaOS/wallpaper-pravy-blok.jpg` po prvním přihlášení), `kdeglobals` (`LookAndFeelPackage=org.cibulkaos.desktop`, `BrowserApplication=org.torproject.torbrowser-launcher.desktop`), `mimeapps.list` (výchozí prohlížeč Prohlížeč Tor), `konsolerc`, `fastfetch/config.jsonc` (vlastní logo CibulkaOS – portrét s kyvadlem); `etc/sddm.conf.d/10-cibulkaos.conf`.
  - `usr/share/plasma/` – Look-and-Feel `org.cibulkaos.desktop` (výchozí panel a Kickoff se Shelly a Prohlížečem Tor) + jednorázové update skripty `cibulkaos_replace_discover_with_shelly.js` a `cibulkaos_pin_torbrowser.js` pro už nainstalované systémy.
  - `usr/share/cibulkaos/` – `cibulkovy-seznamy.tsv.gz` (100 666 reálných záznamů StB), `cibulkovy-seznamy.txt` (fallback), `linux.preset`, `os-release`.
  - `usr/share/grub/themes/cibulkaos/` – Anti-GRUB téma kopírované do cílového systému; dále `usr/share/{wallpapers/CibulkaOS,icons,color-schemes,konsole,sddm}`.
- `pkgbuilds/shelly/PKGBUILD` – balíček grafického správce balíčků **Shelly** (předkompilované binárky z `Seafoam-Labs/Shelly-ALPM`, polkit pravidlo pro `pkexec`); jde jak do ISO, tak do online repa `[cibulkaos]`.
- `pkgbuilds/calamares/PKGBUILD` *(build výstupy a checkout zdrojáků `calamares/`, `src/`, `pkg/` jsou v `.gitignore`)* – staví Calamares ze zdrojáků s patchem v `prepare()`, aby `SetPasswordJob` nastavoval heslo pro `"cibulka"` místo `"root"` a `networkcfg` ignoroval `"cibulka"` jako live uživatele.
- `web/` – samostatná statická prezentační WWW stránka (`index.html`, `style.css`, `app.js`, `assets/`) bez build kroku a bez externích JS knihoven. Texty jsou záměrně netechnické (pět funkcí jako archivní spisy + stažení ISO), bez ukázek ze systému. Nasazení přes GitHub Pages (viz „Vydání ISO a web“).

## Kritické detaily a pastičky (neměnit bez ověření!)
1. **UID 0 = `cibulka` (žádný `root` v `/etc/passwd`):**
   - `pkgbuilds/calamares/PKGBUILD` musí obsahovat patch v `prepare()` pro `SetPasswordJob("cibulka", ...)`, jinak Calamares selže (`usermod: user 'root' does not exist`).
   - `preservefiles.conf` musí mít `perm: cibulka:root:...` (uživatel `root` neexistuje, skupina `root` GID 0 ano).
   - `/etc/sudoers.d/10-cibulka` musí mít `Defaults runas_default=cibulka` a práva `0440` (nastavuje `pkgbuilds/cibulkaos-base/PKGBUILD`).
2. **Btrfs + GRUB `premature end of file`:**
   - `restore-kernel` i `customize_airootfs.sh` **musí** kopírovat `vmlinuz-linux` a microcode s `cp --sparse=never`. Výchozí `--sparse=auto` vytvoří u nulového konce jádra sparse díru, na které GRUB Btrfs ovladač selže při bootu.
   - Po upgradu jádra/microcode přes pacman to samé dělá hook `95-cibulkaos-boot-nosparse.hook` (musí mít číslo > 90, aby běžel po `90-mkinitcpio-install.hook`).
   - `grubcfg.conf` používá `GRUB_DEFAULT: 0` (na Btrfs `GRUB_DEFAULT=saved` vyhazuje `sparse file not allowed`).
3. **Schémata Calamares 3.4:**
   - `mount.conf`: `options: [ bind ]` (musí být YAML pole, ne string!) a `efivarfs` uvnitř `extraMounts` s `efi: true`.
   - `services-systemd.conf`: používá klíč `units:` s `action: enable/disable` (ne `services:`/`enabled:`).
   - `displaymanager.conf`: Plasma 6 Wayland má `desktopFile: "plasma"` (ne `plasmawayland`).
   - `shellprocess*.conf`: používá `dontChroot: false` (ne `chroot: true`) a vlastní instance vyžadují sekci `instances:` v `settings.conf`.
4. **Konflikty souborů při `pacstrap`:**
   - Do `archlive/airootfs/` nevkládat `/etc/os-release`, `/etc/skel/.bashrc` ani `/etc/skel/.zshrc` (kolidují s balíčky `filesystem`, `bash`, `grml-zsh-config`). Úpravy dělat v `customize_airootfs.sh` nebo přes `.zshrc.local`.
   - `mkarchiso` kopíruje `airootfs/` **před** `pacstrap`, takže žádný soubor z `pkgbuilds/cibulkaos-base/rootfs/` nesmí zároveň ležet v `airootfs/` (pacstrap by skončil „exists in filesystem“). Nové soubory CibulkaOS patří do balíčku, do `airootfs/` jen věci live ISO.
   - Do `rootfs/` balíčku nedávat soubory vlastněné jinými balíčky (`/usr/lib/os-release`, `/etc/passwd`, `/usr/bin/sudo` …) – úpravy přes pacman hook. Známá kolize: `/etc/xdg/kdeglobals` vlastní i `extra/deepin-kwin` (nejde tedy instalovat spolu s `cibulkaos-base`).
5. **Synchronizace Cibulkových seznamů:**
   - Při úpravě `pkgbuilds/cibulkaos-base/rootfs/usr/share/cibulkaos/cibulkovy-seznamy.txt` udržovat v souladu i `forbidden_names` v `archlive/airootfs/etc/calamares/modules/users.conf`.
6. **Čeština všude (žádná „czenglish“):**
   - Live systém má `LANG=cs_CZ.UTF-8` (`airootfs/etc/locale.conf`), locale se generuje v `customize_airootfs.sh`; Plasma i Calamares (překlady jsou zabudované v binárce) z toho berou jazyk. `modules/locale.conf` předvyplňuje Europe/Prague bez GeoIP.
   - GRUB fonty v tématu (`terminus-*.pf2`, `ubuntu_regular_*.pf2`) pokrývají českou diakritiku, takže menu GRUB je s diakritikou. Syslinux (`vesamenu`, CP437) diakritiku neumí → texty v `syslinux/*.cfg` česky **bez** diakritiky.
   - GRUB nemá český překlad (`cs.mo`), proto `anti-grub-mkconfig` po vygenerování počeští položky menu přes `sed` (jádro, záložní initramfs, Nastavení firmwaru UEFI, EFI BootNext). Calamares ho používá v `bootloader.conf` (`grubMkconfig`) i v `shellprocess@grub-background.conf`; ruční `grub-mkconfig` dá anglické menu.
   - `pkgbuilds/cibulkaos-base/rootfs/etc/profile.d/cibulka.sh` přepisuje chybové hlášky v angličtině (curl) i v češtině (ping, glibc) – při změně jazyka doplnit obě varianty.
