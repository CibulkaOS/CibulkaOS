#!/usr/bin/env bash
# Publikuje veřejné pacman repo [cibulkaos] do GitHub Release s tagem "repo".
#
# Klienti (nainstalovaná CibulkaOS) mají v /etc/pacman.conf:
#   [cibulkaos]
#   Include = /etc/pacman.d/cibulkaos-mirrorlist
# a mirrorlist (z balíčku cibulkaos-base) ukazuje na
#   https://github.com/<owner>/<repo>/releases/download/repo
#
# Do repa jde jen cibulkaos-base (Calamares se po instalaci odstraňuje, online ho nikdo nepotřebuje).
# Stejný název balíčku se nesmí publikovat dvakrát s jiným obsahem (klienti mají cache podle
# názvu souboru) -> před publikací vždy zvyšte pkgver/pkgrel v pkgbuilds/cibulkaos-base/PKGBUILD.
#
# Použití: scripts/publish-repo.sh   (nebo make publish-repo; vyžaduje přihlášené `gh`)
set -euo pipefail

REPO_TAG="${REPO_TAG:-repo}"
LOCALREPO="${LOCALREPO:-/tmp/cibulkaos-localrepo}"
DB=cibulkaos

command -v gh >/dev/null || { echo "CHYBA: chybí GitHub CLI (pacman -S github-cli; gh auth login)." >&2; exit 1; }

pkg="$(ls -t "$LOCALREPO"/cibulkaos-base-*.pkg.tar.zst 2>/dev/null | head -1 || true)"
[ -n "$pkg" ] || { echo "CHYBA: v $LOCALREPO není cibulkaos-base (spusťte make pkg-base)." >&2; exit 1; }
name="$(basename "$pkg")"

if ! gh release view "$REPO_TAG" >/dev/null 2>&1; then
    echo ">>> Vytvářím release '$REPO_TAG' (úložiště pacman repa)..."
    gh release create "$REPO_TAG" --title "Pacman repo [cibulkaos]" --latest=false \
        --notes "Pacman repozitář CibulkaOS. Soubory zde spravuje scripts/publish-repo.sh – needitovat ručně."
fi

if gh release view "$REPO_TAG" --json assets -q '.assets[].name' | grep -qxF "$name"; then
    echo "CHYBA: $name už je publikovaný. Zvyšte pkgver/pkgrel v pkgbuilds/cibulkaos-base/PKGBUILD a spusťte make pkg-base." >&2
    exit 1
fi

stage="$(mktemp -d)"
trap 'rm -rf -- "${stage:?}"' EXIT

cp -- "$pkg" "$stage/"
repo-add -q "$stage/$DB.db.tar.gz" "$stage/$name"
# GitHub Releases neumí symlinky -> nahradit .db/.files skutečnými soubory
for f in "$DB.db" "$DB.files"; do
    cp --remove-destination -- "$(readlink -f "$stage/$f")" "$stage/$f"
done

# Nejdřív balíček, teprve potom databáze – db nikdy neodkazuje na chybějící soubor.
echo ">>> Nahrávám $name..."
gh release upload "$REPO_TAG" "$stage/$name"
echo ">>> Aktualizuji databázi repa..."
gh release upload "$REPO_TAG" --clobber \
    "$stage/$DB.db" "$stage/$DB.db.tar.gz" "$stage/$DB.files" "$stage/$DB.files.tar.gz"

echo ">>> Hotovo: $name je v [cibulkaos] ($(gh repo view --json url -q .url)/releases/tag/$REPO_TAG)"
