PROFILE    := archlive
OUT_DIR    := out
WORK_DIR   := work
ISO        := $(shell ls -t $(OUT_DIR)/cibulkaos-*.iso 2>/dev/null | head -1)
LOCALREPO  := /tmp/cibulkaos-localrepo
PKGBUILDS  := pkgbuilds

OVMF       := /usr/share/edk2/x64/OVMF.4m.fd
QEMU_MEM   := 2G
QEMU_CORES := 8
DISK_IMG   := $(OUT_DIR)/cibulkaos-disk.qcow2
DISK_SIZE  := 20G

.PHONY: all build pkgs pkg-calamares pkg-shelly pkg-base publish-repo run run-bios disk run-install run-installed clean clean-pkgs clean-disk help

all: help

## pkgs: Sestaví vlastní balíčky (Calamares + Shelly + cibulkaos-base) — spouštět BEZ sudo
pkgs: pkg-calamares pkg-shelly pkg-base

## pkg-calamares: Sestaví patchovaný Calamares ze zdrojáků do lokálního repa (pomalé)
pkg-calamares:
	@echo ">>> Sestavuji Calamares ze zdrojového kódu (https://codeberg.org/Calamares/calamares)..."
	@mkdir -p $(LOCALREPO)
	cd $(PKGBUILDS)/calamares && PKGDEST=$(LOCALREPO) makepkg -sf --noconfirm --skippgpcheck
	repo-add $(LOCALREPO)/cibulkaos.db.tar.gz $(LOCALREPO)/calamares-*.pkg.tar.zst
	@echo ">>> Hotovo: $$(ls $(LOCALREPO)/calamares-*.pkg.tar.zst)"

## pkg-shelly: Zabalí správce balíčků Shelly (předkompilované binárky) do lokálního repa (rychlé)
pkg-shelly:
	@if [ "$$(id -u)" -eq 0 ]; then echo "CHYBA: makepkg nesmí běžet jako root – spouštějte make BEZ sudo." >&2; exit 1; fi
	@echo ">>> Sestavuji shelly..."
	@mkdir -p $(LOCALREPO)
	rm -f $(LOCALREPO)/shelly-*.pkg.tar.zst
	cd $(PKGBUILDS)/shelly && PKGDEST=$(LOCALREPO) makepkg -fd --noconfirm
	repo-add $(LOCALREPO)/cibulkaos.db.tar.gz $(LOCALREPO)/shelly-*.pkg.tar.zst
	@echo ">>> Hotovo: $$(ls $(LOCALREPO)/shelly-*.pkg.tar.zst)"

## pkg-base: Sestaví balíček cibulkaos-base (skripty, služby, hooky, témata) do lokálního repa (rychlé)
pkg-base:
	@if [ "$$(id -u)" -eq 0 ]; then echo "CHYBA: makepkg nesmí běžet jako root – spouštějte make BEZ sudo." >&2; exit 1; fi
	@echo ">>> Sestavuji cibulkaos-base..."
	@mkdir -p $(LOCALREPO)
	rm -f $(LOCALREPO)/cibulkaos-base-*.pkg.tar.zst
	cd $(PKGBUILDS)/cibulkaos-base && PKGDEST=$(LOCALREPO) makepkg -fd --noconfirm
	repo-add $(LOCALREPO)/cibulkaos.db.tar.gz $(LOCALREPO)/cibulkaos-base-*.pkg.tar.zst
	@echo ">>> Hotovo: $$(ls $(LOCALREPO)/cibulkaos-base-*.pkg.tar.zst)"

## publish-repo: Publikuje cibulkaos-base a shelly do veřejného pacman repa (GitHub Release 'repo'; vyžaduje gh)
publish-repo: pkg-base pkg-shelly
	scripts/publish-repo.sh

## build: Sestaví CibulkaOS ISO (spouštět BEZ sudo, sudo volá sám; Calamares nejdříve přes 'make pkgs')
build: pkg-base pkg-shelly
	@if ! ls $(LOCALREPO)/calamares-*.pkg.tar.zst >/dev/null 2>&1; then \
		echo "CHYBA: Calamares v lokálním repu nenalezen. Spusťte nejprve 'make pkgs' (bez sudo)." >&2; \
		exit 1; \
	fi
	@# mkarchiso používá pacman cache hostitele; stará kopie balíčků se stejnou verzí
	@# by neprošla kontrolou checksumu proti novému repu -> smazat je z cache.
	@for d in $$(pacman-conf CacheDir); do \
		sudo find "$${d:?}" -maxdepth 1 \( -name 'cibulkaos-base-*.pkg.tar.zst*' -o -name 'shelly-*.pkg.tar.zst*' \) -delete; \
	done
	@echo ">>> Sestavuji CibulkaOS ISO..."
	@mkdir -p $(OUT_DIR)
	sudo mkarchiso -v -w $(WORK_DIR) -o $(OUT_DIR) $(PROFILE)
	@echo ">>> ISO sestaveno: $$(ls -t $(OUT_DIR)/cibulkaos-*.iso | head -1)"

## run: Spustí poslední ISO v QEMU s UEFI
run:
	$(if $(ISO),,$(error Zadne ISO nenalezeno v $(OUT_DIR)/. Spustte 'make build' nejdrive.))
	@echo ">>> Spoustim: $(ISO)"
	qemu-system-x86_64 \
		-name CibulkaOS \
		-machine q35,accel=kvm \
		-cpu host \
		-smp $(QEMU_CORES) \
		-m $(QEMU_MEM) \
		-bios $(OVMF) \
		-cdrom $(ISO) \
		-boot d \
		-device virtio-vga \
		-display gtk,show-cursor=on \
		-audiodev pa,id=snd \
		-device ich9-intel-hda \
		-device hda-output,audiodev=snd \
		-nic user,model=virtio-net-pci

## run-bios: Spustí poslední ISO v QEMU s legacy BIOS
run-bios:
	$(if $(ISO),,$(error Zadne ISO nenalezeno v $(OUT_DIR)/. Spustte 'make build' nejdrive.))
	@echo ">>> Spoustim (BIOS): $(ISO)"
	qemu-system-x86_64 \
		-name CibulkaOS \
		-machine q35,accel=kvm \
		-cpu host \
		-smp $(QEMU_CORES) \
		-m $(QEMU_MEM) \
		-cdrom $(ISO) \
		-boot d \
		-device virtio-vga \
		-display gtk,show-cursor=on \
		-nic user,model=virtio-net-pci

## disk: Vytvoří virtuální disk pro instalaci ($(DISK_SIZE), qcow2)
disk:
	$(if $(ISO),,$(error Zadne ISO nenalezeno v $(OUT_DIR)/. Spustte 'make build' nejdrive.))
	@if [ -f "$(DISK_IMG)" ]; then \
		echo ">>> Disk $(DISK_IMG) jiz existuje, preskakuji vytvoreni."; \
	else \
		echo ">>> Vytvářím virtuální disk $(DISK_IMG) ($(DISK_SIZE))..."; \
		qemu-img create -f qcow2 $(DISK_IMG) $(DISK_SIZE); \
		echo ">>> Disk vytvořen."; \
	fi

## run-install: Spustí ISO + virtuální disk v QEMU (UEFI) pro instalaci
run-install: disk
	@echo ">>> Spoustim instalaci: $(ISO) -> $(DISK_IMG)"
	qemu-system-x86_64 \
		-name CibulkaOS \
		-machine q35,accel=kvm \
		-cpu host \
		-smp $(QEMU_CORES) \
		-m $(QEMU_MEM) \
		-bios $(OVMF) \
		-cdrom $(ISO) \
		-drive file=$(DISK_IMG),format=qcow2,if=virtio \
		-boot d \
		-device virtio-vga \
		-display gtk,show-cursor=on \
		-audiodev pa,id=snd \
		-device ich9-intel-hda \
		-device hda-output,audiodev=snd \
		-nic user,model=virtio-net-pci

## run-installed: Spustí nainstalovaný systém z disku (bez ISO)
run-installed:
	$(if $(wildcard $(DISK_IMG)),,$(error Disk $(DISK_IMG) nenalezen. Spustte 'make run-install' nejdrive.))
	@echo ">>> Spoustim nainstalovaný systém: $(DISK_IMG)"
	qemu-system-x86_64 \
		-name CibulkaOS \
		-machine q35,accel=kvm \
		-cpu host \
		-smp $(QEMU_CORES) \
		-m $(QEMU_MEM) \
		-bios $(OVMF) \
		-drive file=$(DISK_IMG),format=qcow2,if=virtio \
		-boot c \
		-device virtio-vga \
		-display gtk,show-cursor=on \
		-audiodev pa,id=snd \
		-device ich9-intel-hda \
		-device hda-output,audiodev=snd \
		-nic user,model=virtio-net-pci

## clean: Smaže work adresář (build cache)
clean:
	@echo ">>> Cistim work adresar..."
	@# přerušený mkarchiso/pacstrap nechává připojené tmpfs/proc/sys uvnitř work/ → odpojit (od nejhlubšího)
	@findmnt -rn -o TARGET | grep "^$(CURDIR)/$(WORK_DIR)/" | sort -r | while read -r m; do sudo umount -l "$$m"; done
	sudo rm -rf $(WORK_DIR)
	@echo ">>> Hotovo."

## clean-pkgs: Smaže lokální repo s balíčky (vynutí rebuild Calamares, Shelly i cibulkaos-base)
clean-pkgs:
	@echo ">>> Mazem lokalni repo $(LOCALREPO)..."
	rm -rf $(LOCALREPO)
	rm -rf $(PKGBUILDS)/calamares/*.pkg.tar.zst $(PKGBUILDS)/calamares/src $(PKGBUILDS)/calamares/pkg
	rm -rf $(PKGBUILDS)/shelly/*.pkg.tar.zst $(PKGBUILDS)/shelly/src $(PKGBUILDS)/shelly/pkg
	rm -rf $(PKGBUILDS)/cibulkaos-base/src $(PKGBUILDS)/cibulkaos-base/pkg
	@echo ">>> Hotovo."

## clean-disk: Smaže virtuální disk (začít instalaci znovu)
clean-disk:
	@echo ">>> Mazem virtualni disk $(DISK_IMG)..."
	rm -f $(DISK_IMG)
	@echo ">>> Hotovo."

## clean-all: Smaže work i out adresáře
clean-all:
	@echo ">>> Cistim vse..."
	sudo rm -rf $(WORK_DIR) $(OUT_DIR)
	@echo ">>> Hotovo."

## help: Zobrazí tuto nápovědu
help:
	@echo ""
	@echo "  CibulkaOS - Distribuce pro svobodne Cechy"
	@echo ""
	@grep -E '^## ' Makefile | sed 's/## /  make /'
	@echo ""
