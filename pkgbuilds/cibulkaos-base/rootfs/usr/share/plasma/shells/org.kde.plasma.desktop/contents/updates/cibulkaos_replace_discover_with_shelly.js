// Jednorázová migrace pro už nainstalované systémy CibulkaOS:
// nahradí připnutý neexistující KDE Discover v panelu (a oblíbených Kickoff) správcem Shelly.

var hasShelly = applicationExists("com.shellyorg.shelly.desktop");

function parseList(raw) {
    if (Array.isArray(raw)) {
        return raw.filter(function(item) { return item && item.length > 0; });
    }
    if (typeof raw === "string" && raw.length > 0) {
        return raw.split(",").filter(function(item) { return item.length > 0; });
    }
    return [];
}

function replaceDiscover(list, discoverEntry, shellyEntry) {
    var changed = false;
    var result = [];
    for (var i = 0; i < list.length; i++) {
        var entry = list[i];
        if (entry === discoverEntry) {
            changed = true;
            if (hasShelly && result.indexOf(shellyEntry) === -1 && list.indexOf(shellyEntry) === -1) {
                result.push(shellyEntry);
            }
        } else {
            result.push(entry);
        }
    }
    return { list: result, changed: changed };
}

var allPanels = panels();
for (var p = 0; p < allPanels.length; p++) {
    var widgets = allPanels[p].widgets();
    for (var w = 0; w < widgets.length; w++) {
        var widget = widgets[w];

        if (widget.type === "org.kde.plasma.icontasks" || widget.type === "org.kde.plasma.taskmanager") {
            widget.currentConfigGroup = ["General"];
            var launchers = parseList(widget.readConfig("launchers"));

            if (launchers.length === 0) {
                // Uživatel neměl launchers přepsané -> Plasma používala vestavěný výchozí seznam s Discoverem
                var defaults = [
                    "applications:systemsettings.desktop",
                    "preferred://filemanager",
                    "applications:org.kde.konsole.desktop",
                    "preferred://browser"
                ];
                if (hasShelly) {
                    defaults.splice(1, 0, "applications:com.shellyorg.shelly.desktop");
                }
                widget.writeConfig("launchers", defaults);
                widget.reloadConfig();
            } else {
                var updated = replaceDiscover(
                    launchers,
                    "applications:org.kde.discover.desktop",
                    "applications:com.shellyorg.shelly.desktop"
                );
                if (updated.changed) {
                    widget.writeConfig("launchers", updated.list);
                    widget.reloadConfig();
                }
            }
        } else if (widget.type === "org.kde.plasma.kickoff") {
            widget.currentConfigGroup = ["General"];
            var favs = parseList(widget.readConfig("favorites"));
            if (favs.length > 0) {
                var updatedFavs = replaceDiscover(
                    favs,
                    "org.kde.discover.desktop",
                    "com.shellyorg.shelly.desktop"
                );
                if (updatedFavs.changed) {
                    widget.writeConfig("favorites", updatedFavs.list);
                    widget.reloadConfig();
                }
            }
        }
    }
}
