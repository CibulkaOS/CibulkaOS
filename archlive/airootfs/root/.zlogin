# fix for screen readers
if grep -Fqa 'accessibility=' /proc/cmdline &> /dev/null; then
    setopt SINGLE_LINE_ZLE
fi

~/.automated_script.sh

# Spustí KDE Plasma Wayland session na TTY1
if [[ $(tty) == "/dev/tty1" ]] && [[ -z $WAYLAND_DISPLAY ]]; then
    /usr/lib/plasma-dbus-run-session-if-needed startplasma-wayland
fi
