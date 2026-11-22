#!/usr/bin/env bash
# Publikuje veřejné pacman repo [cibulkaos] do GitHub Release s tagem "repo".
#
# Klienti (nainstalovaná CibulkaOS) mají v /etc/pacman.conf:
#   [cibulkaos]
#   Include = /etc/pacman.d/cibulkaos-mirrorlist
# a mirrorlist (z balíčku cibulkaos-base) ukazuje na
#   https://github.com/<owner>/<repo>/releases/download/repo
#
# Do repa jdou balíčky cibulkaos-base a shelly (Calamares se po instalaci odstraňuje,
# online ho nikdo nepotřebuje). Stejný název balíčku se nesmí publikovat dvakrát s jiným
# obsahem (klienti mají cache podle názvu souboru) -> nezměněný balíček se nechá na GitHubu
# a znovu se jen zapíše do databáze; před publikací změny vždy zvyšte pkgver/pkgrel.
#
# Použití: scripts/publish-repo.sh   (nebo make publish-repo; vyžaduje přihlášené `gh`)
set -euo pipefail

REPO_TAG="${REPO_TAG:-repo}"
LOCALREPO="${LOCALREPO:-/tmp/cibulkaos-localrepo}"
DB=cibulkaos
PACKAGES=(cibulkaos-base shelly)

command -v gh >/dev/null || { echo "CHYBA: chybí GitHub CLI (pacman -S github-cli; gh auth login)." >&2; exit 1; }

declare -a pkg_paths=()
for p in "${PACKAGES[@]}"; do
    pkg="$(ls -t "$LOCALREPO"/"${p}"-*.pkg.tar.zst 2>/dev/null | head -1 || true)"
    [ -n "$pkg" ] || { echo "CHYBA: v $LOCALREPO není balíček '$p' (spusťte make pkg-base pkg-shelly)." >&2; exit 1; }
    pkg_paths+=("$pkg")
done

if ! gh release view "$REPO_TAG" >/dev/null 2>&1; then
    echo ">>> Vytvářím release '$REPO_TAG' (úložiště pacman repa)..."
    gh release create "$REPO_TAG" --title "Pacman repo [cibulkaos]" --latest=false \
        --notes "Pacman repozitář CibulkaOS. Soubory zde spravuje scripts/publish-repo.sh – needitovat ručně."
fi

existing_assets="$(gh release view "$REPO_TAG" --json assets -q '.assets[].name')"

declare -a to_upload=()
for pkg in "${pkg_paths[@]}"; do
    name="$(basename "$pkg")"
    if grep -qxF "$name" <<<"$existing_assets"; then
        echo ">>> $name už je publikovaný – ponechávám v repu beze změny."
    else
        to_upload+=("$pkg")
    fi
done

if [ "${#to_upload[@]}" -eq 0 ]; then
    echo "CHYBA: žádný nový balíček k publikaci. Zvyšte pkgver/pkgrel v příslušném PKGBUILDu a přestavte balíček." >&2
    exit 1
fi

stage="$(mktemp -d)"
trap 'rm -rf -- "${stage:?}"' EXIT

for pkg in "${pkg_paths[@]}"; do
    name="$(basename "$pkg")"
    cp -- "$pkg" "$stage/$name"
    repo-add -q "$stage/$DB.db.tar.gz" "$stage/$name"
done

# GitHub Releases neumí symlinky -> nahradit .db/.files skutečnými soubory
for f in "$DB.db" "$DB.files"; do
    cp --remove-destination -- "$(readlink -f "$stage/$f")" "$stage/$f"
done

# Nejdřív nové balíčky, teprve potom databáze – db nikdy neodkazuje na chybějící soubor.
for pkg in "${to_upload[@]}"; do
    name="$(basename "$pkg")"
    echo ">>> Nahrávám $name..."
    gh release upload "$REPO_TAG" "$stage/$name"
done

echo ">>> Aktualizuji databázi repa..."
gh release upload "$REPO_TAG" --clobber \
    "$stage/$DB.db" "$stage/$DB.db.tar.gz" "$stage/$DB.files" "$stage/$DB.files.tar.gz"

echo ">>> Hotovo: [cibulkaos] aktualizováno ($(gh repo view --json url -q .url)/releases/tag/$REPO_TAG)"
