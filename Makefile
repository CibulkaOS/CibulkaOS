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

.PHONY: all build pkgs run run-bios disk run-install run-installed clean clean-pkgs clean-disk help

all: help

## pkgs: Sestaví vlastní balíčky ze zdrojáků (Calamares) — spouštět BEZ sudo
pkgs:
	@echo ">>> Sestavuji Calamares ze zdrojového kódu (https://codeberg.org/Calamares/calamares)..."
	@mkdir -p $(LOCALREPO)
	cd $(PKGBUILDS)/calamares && PKGDEST=$(LOCALREPO) makepkg -sf --noconfirm --skippgpcheck
	repo-add $(LOCALREPO)/cibulkaos.db.tar.gz $(LOCALREPO)/calamares-*.pkg.tar.zst
	@echo ">>> Hotovo: $$(ls $(LOCALREPO)/calamares-*.pkg.tar.zst)"

## build: Sestaví CibulkaOS ISO (vyžaduje root; spusťte 'make pkgs' nejdříve)
build:
	@if [ ! -f "$(LOCALREPO)/cibulkaos.db" ]; then \
		echo "CHYBA: Lokální repo nenalezeno. Spusťte nejprve 'make pkgs' (bez sudo)." >&2; \
		exit 1; \
	fi
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
	@mount | grep -q "$(WORK_DIR)" && sudo umount -R $(WORK_DIR) 2>/dev/null || true
	sudo rm -rf $(WORK_DIR)
	@echo ">>> Hotovo."

## clean-pkgs: Smaže lokální repo s balíčky (vynutí rebuild Calamares)
clean-pkgs:
	@echo ">>> Mazem lokalni repo $(LOCALREPO)..."
	rm -rf $(LOCALREPO)
	rm -rf $(PKGBUILDS)/calamares/*.pkg.tar.zst $(PKGBUILDS)/calamares/src $(PKGBUILDS)/calamares/pkg
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
