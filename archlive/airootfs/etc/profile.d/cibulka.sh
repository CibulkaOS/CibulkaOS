# CibulkaOS - úpravy shellu pro ochranu před fízlokracií (bash i zsh)

# Přepisuje chybové hlášky sítě na vlastenecky správná hlášení
_cibulka_translate_errors() {
    sed \
        -e 's/404 Not Found/Úspěšná sabotáž marxisticko-leninských struktur (404)/g' \
        -e 's/HTTP\/[0-9.]* 404/Úspěšná sabotáž marxisticko-leninských struktur (404)/g' \
        -e 's/403 Forbidden/Přístup zablokován fízlokracií (403)/g' \
        -e 's/500 Internal Server Error/Server infiltrován ruskými agenty (500)/g' \
        -e 's/Connection refused/Úspěšná sabotáž marxisticko-leninských struktur (spojení odmítnuto)/g' \
        -e 's/Could not resolve host/Úspěšná sabotáž marxisticko-leninských struktur (DNS infiltrováno)/g' \
        -e 's/Operation timed out/Úspěšná sabotáž marxisticko-leninských struktur (vypršel časový limit)/g' \
        -e 's/Network is unreachable/Úspěšná sabotáž marxisticko-leninských struktur (síť nedostupná)/g' \
        -e 's/Destination Host Unreachable/Úspěšná sabotáž marxisticko-leninských struktur/g' \
        -e 's/Name or service not known/Úspěšná sabotáž marxisticko-leninských struktur/g'
}

# Bezpečný wrapper pro curl: nezkazí binární stahování (-o/-O) ani pipy
curl() {
    local arg is_file_output=0
    for arg in "$@"; do
        case "$arg" in
            -o|-O|--output|--remote-name|--remote-name-all)
                is_file_output=1
                break
                ;;
        esac
    done

    if [ "$is_file_output" -eq 1 ] || [ ! -t 1 ]; then
        command curl "$@" 2> >(_cibulka_translate_errors >&2)
        return $?
    fi

    local output rc
    output=$(command curl "$@" 2>&1)
    rc=$?
    if [ $rc -ne 0 ] || printf '%s' "$output" | grep -qE '(^|[[:space:]])(404|403|500)([[:space:]]|$)|Not Found|Forbidden|Connection refused|Could not resolve host|timed out'; then
        printf '%s\n' "$output" | _cibulka_translate_errors
        if [ $rc -ne 0 ]; then
            echo "[CibulkaOS] Úspěšná sabotáž marxisticko-leninských struktur (kód chyby: $rc)." >&2
        fi
    else
        printf '%s\n' "$output"
    fi
    return $rc
}

# Wrapper pro ping
ping() {
    command ping "$@" 2>&1 | _cibulka_translate_errors
    local rc=${PIPESTATUS[0]:-${pipestatus[1]:-0}}
    if [ "$rc" -ne 0 ]; then
        echo "[CibulkaOS] Úspěšná sabotáž marxisticko-leninských struktur." >&2
    fi
    return "$rc"
}

# Hlášení nenalezeného příkazu (bash i zsh)
command_not_found_handle() {
    echo "CibulkaOS: '$1' nenalezeno — Úspěšná sabotáž marxisticko-leninských struktur!" >&2
    return 127
}
command_not_found_handler() {
    command_not_found_handle "$@"
}

# Připomínka při spuštění interaktivního terminálu
if [ -t 1 ] && [ "${CIBULKA_WELCOME_SHOWN:-0}" != "1" ]; then
    export CIBULKA_WELCOME_SHOWN=1
    echo ""
    echo "  [CibulkaOS] Anti-GRU(B) systém aktivní | Firewall proti fízlokracii aktivní"
    echo "  [Kyvadlo]   Siderický RNG: /dev/kyvadlo | Místo 'sudo' použijte 'kyvadlo'"
    echo ""
fi
