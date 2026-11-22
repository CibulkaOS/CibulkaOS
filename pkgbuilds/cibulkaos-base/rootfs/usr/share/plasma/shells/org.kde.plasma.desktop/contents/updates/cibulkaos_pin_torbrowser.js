// Jednorázová migrace pro už nainstalované systémy CibulkaOS:
// nahradí prázdný placeholder preferred://browser na panelu (a v Kickoff) za Prohlížeč Tor.

if (applicationExists("org.torproject.torbrowser-launcher.desktop")) {
    var parseList = function(raw) {
        if (Array.isArray(raw)) {
            return raw.filter(function(item) { return item && item.length > 0; });
        }
        if (typeof raw === "string" && raw.length > 0) {
            return raw.split(",").filter(function(item) { return item.length > 0; });
        }
        return [];
    };

    var replaceEntry = function(list, oldEntry, newEntry) {
        var changed = false;
        var result = [];
        for (var i = 0; i < list.length; i++) {
            var entry = list[i];
            if (entry === oldEntry) {
                changed = true;
                if (result.indexOf(newEntry) === -1 && list.indexOf(newEntry) === -1) {
                    result.push(newEntry);
                }
            } else {
                result.push(entry);
            }
        }
        return { list: result, changed: changed };
    };

    var allPanels = panels();
    for (var p = 0; p < allPanels.length; p++) {
        var widgets = allPanels[p].widgets();
        for (var w = 0; w < widgets.length; w++) {
            var widget = widgets[w];

            if (widget.type === "org.kde.plasma.icontasks" || widget.type === "org.kde.plasma.taskmanager") {
                widget.currentConfigGroup = ["General"];
                var launchers = parseList(widget.readConfig("launchers"));
                if (launchers.length > 0) {
                    var updated = replaceEntry(
                        launchers,
                        "preferred://browser",
                        "applications:org.torproject.torbrowser-launcher.desktop"
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
                    var updatedFavs = replaceEntry(
                        favs,
                        "preferred://browser",
                        "org.torproject.torbrowser-launcher.desktop"
                    );
                    if (updatedFavs.changed) {
                        widget.writeConfig("favorites", updatedFavs.list);
                        widget.reloadConfig();
                    }
                }
            }
        }
    }
}
