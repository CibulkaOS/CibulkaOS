// Výchozí rozložení plochy a spodního panelu CibulkaOS pro KDE Plasma 6.
// Připíná správce balíčků Shelly místo chybějícího KDE Discover.

var panel = new Panel
var panelScreen = panel.screen

// Výška panelu odpovídající výchozímu panelu Plasma 6
panel.height = 2 * Math.ceil(gridUnit * 2.5 / 2)

// Omezení šířky panelu na ultraširokých monitorech (21:9)
const maximumAspectRatio = 21/9;
if (panel.formFactor === "horizontal") {
    const geo = screenGeometry(panelScreen);
    const maximumWidth = Math.ceil(geo.height * maximumAspectRatio);

    if (geo.width > maximumWidth) {
        panel.alignment = "center";
        panel.minimumLength = maximumWidth;
        panel.maximumLength = maximumWidth;
    }
}

var browserDesktop = applicationExists("org.torproject.torbrowser-launcher.desktop")
    ? "org.torproject.torbrowser-launcher.desktop"
    : "preferred://browser"
var browserLauncher = applicationExists("org.torproject.torbrowser-launcher.desktop")
    ? "applications:org.torproject.torbrowser-launcher.desktop"
    : "preferred://browser"

var kickoff = panel.addWidget("org.kde.plasma.kickoff")
kickoff.currentConfigGroup = ["General"]
var kickoffFavorites = [
    browserDesktop,
    "systemsettings.desktop",
    "org.kde.dolphin.desktop",
    "org.kde.konsole.desktop"
]
if (applicationExists("com.shellyorg.shelly.desktop")) {
    kickoffFavorites.splice(1, 0, "com.shellyorg.shelly.desktop")
}
kickoff.writeConfig("favorites", kickoffFavorites)

panel.addWidget("org.kde.plasma.pager")

var tasks = panel.addWidget("org.kde.plasma.icontasks")
tasks.currentConfigGroup = ["General"]
var pinnedLaunchers = [
    "applications:systemsettings.desktop",
    "preferred://filemanager",
    "applications:org.kde.konsole.desktop",
    browserLauncher
]
if (applicationExists("com.shellyorg.shelly.desktop")) {
    pinnedLaunchers.splice(1, 0, "applications:com.shellyorg.shelly.desktop")
}
tasks.writeConfig("launchers", pinnedLaunchers)

panel.addWidget("org.kde.plasma.marginsseparator")

var langIds = ["as", "bn", "bo", "brx", "doi", "gu", "hi", "ja", "kn", "ko",
               "kok", "ks", "lep", "mai", "ml", "mni", "mr", "ne", "or", "pa",
               "sa", "sat", "sd", "si", "ta", "te", "th", "ur", "vi", "zh_CN", "zh_TW"]
if (langIds.indexOf(languageId) != -1) {
    panel.addWidget("org.kde.plasma.kimpanel")
}

panel.addWidget("org.kde.plasma.systemtray")
panel.addWidget("org.kde.plasma.digitalclock")
panel.addWidget("org.kde.plasma.showdesktop")

var desktopsArray = desktopsForActivity(currentActivity())
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = 'org.kde.image'
    desktopsArray[j].currentConfigGroup = ["Wallpaper", "org.kde.image", "General"]
    desktopsArray[j].writeConfig("Image", "file:///usr/share/wallpapers/CibulkaOS/wallpaper-pravy-blok.jpg")
}
