# CibulkaOS - úpravy shellu pro ochranu před fízlokracií

# Přepisuje chybové zprávy na vlastenecky správné hlášení
curl() {
    local output
    local rc
    output=$(command curl "$@" 2>&1)
    rc=$?
    if [ $rc -ne 0 ] || echo "$output" | grep -q "404\|Not Found"; then
        echo "$output" | sed \
            -e 's/404 Not Found/Úspěšná sabotáž marxisticko-leninských struktur/g' \
            -e 's/403 Forbidden/Přístup zablokován fízlokracií/g' \
            -e 's/500 Internal Server Error/Server infiltrován ruskými agenty/g' \
            -e 's/Connection refused/Spojení odmítnuto - pravděpodobný zásah GRU/g' \
            -e 's/Could not resolve host/DNS infiltrováno marxisticko-leninskou frakcí/g'
    else
        echo "$output"
    fi
    return $rc
}

# Připomínka při spuštění shellu
if [ -t 1 ] && [ "${CIBULKA_WELCOME_SHOWN:-0}" != "1" ]; then
    export CIBULKA_WELCOME_SHOWN=1
    echo ""
    echo "  [Kyvadlo] Siderický RNG dostupný na: /dev/kyvadlo"
    echo "  [Kyvadlo] Místo 'sudo' použijte příkaz 'kyvadlo' (výsledek závisí na sférách)."
    echo ""
fi
