/* CibulkaOS — Instalační prezentace „Archiv StB × siderické kyvadlo“ */
import QtQuick
import calamares.slideshow

Presentation {
    id: presentation

    property int slideIndex: 0
    property int totalSlides: 6

    function nextSlide() {
        slideIndex = (slideIndex + 1) % totalSlides
        presentation.goToNextSlide()
    }

    function onActivate() {
        advanceTimer.running = true
    }

    function onLeave() {
        advanceTimer.running = false
    }

    Timer {
        id: advanceTimer
        interval: 6000
        running: true
        repeat: true
        onTriggered: nextSlide()
    }

    // Společný rámec slidu (uhlové pozadí, zlatá linka nahoře, spodní archivní ticker + indikátor)
    component ArchiveSlide: Slide {
        id: rootSlide
        property int indexNum: 0
        property string sectionCode: "§ 01"
        property string headline: ""
        property string bodyText: ""
        property string subNote: ""
        property string tickerText: "SDĚLENÍ ARCHIVU: Žádné struktury GRU nebyly v MBR detekovány · nftables aktivní"
        default property alias visualContent: visualSlot.data

        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: "#0b0a0c"

            // Horní zlatá linka
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 3
                color: "#ffd700"
            }

            // Horní stavový řádek spisu
            Row {
                anchors.top: parent.top
                anchors.topMargin: 16
                anchors.left: parent.left
                anchors.leftMargin: 28
                spacing: 10

                Rectangle {
                    width: codeTxt.implicitWidth + 14
                    height: 22
                    radius: 3
                    color: "#16131a"
                    border.color: "#b3122e"
                    border.width: 1

                    Text {
                        id: codeTxt
                        anchors.centerIn: parent
                        text: rootSlide.sectionCode + " · SPIS 0" + (rootSlide.indexNum + 1) + "/06"
                        color: "#ffd700"
                        font.family: "monospace"
                        font.pixelSize: 11
                        font.bold: true
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "CIBULKAOS 2026 · VYDÁNÍ ANTI-GRU"
                    color: "#7a7265"
                    font.family: "monospace"
                    font.pixelSize: 11
                }
            }

            // Hlavní obsah: vlevo 42 % animovaná scéna, vpravo 58 % text
            Item {
                anchors.top: parent.top
                anchors.topMargin: 52
                anchors.bottom: footerBar.top
                anchors.bottomMargin: 12
                anchors.left: parent.left
                anchors.leftMargin: 28
                anchors.right: parent.right
                anchors.rightMargin: 28

                Rectangle {
                    id: visualBox
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * 0.42
                    radius: 8
                    color: "#141117"
                    border.color: "#2c2531"
                    border.width: 1
                    clip: true

                    Item {
                        id: visualSlot
                        anchors.fill: parent
                    }
                }

                Column {
                    anchors.left: visualBox.right
                    anchors.leftMargin: 26
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 14

                    Text {
                        width: parent.width
                        text: rootSlide.headline
                        color: "#ffd700"
                        font.pixelSize: 26
                        font.bold: true
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        width: parent.width
                        text: rootSlide.bodyText
                        color: "#ece6d6"
                        font.pixelSize: 15
                        lineHeight: 1.35
                        wrapMode: Text.WordWrap
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#2c2531"
                    }

                    Text {
                        width: parent.width
                        text: rootSlide.subNote
                        color: "#a69e8e"
                        font.family: "monospace"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                    }
                }
            }

            // Spodní archivní ticker + 6bodový indikátor
            Rectangle {
                id: footerBar
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 36
                color: "#120f15"

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: "#2c2531"
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    text: "▸ " + rootSlide.tickerText
                    color: "#a69e8e"
                    font.family: "monospace"
                    font.pixelSize: 11
                }

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    Repeater {
                        model: presentation.totalSlides
                        Rectangle {
                            width: index === rootSlide.indexNum ? 18 : 6
                            height: 6
                            radius: 3
                            color: index === rootSlide.indexNum ? "#ffd700" : "#3a3242"
                        }
                    }
                }
            }
        }
    }

    // ==================== SLIDE 1: KYVADLO SCHVALUJE ====================
    ArchiveSlide {
        indexNum: 0
        sectionCode: "§ 01"
        headline: "Kyvadlo schvaluje instalaci"
        bodyText: "CibulkaOS připravuje KDE Plasma 6 (Wayland) na Btrfs svazcích (/@, /@home, /@cache, /@log). Superuživatel systému se jmenuje cibulka — účet root neexistuje."
        subNote: "UID 0 = cibulka · SDDM · PipeWire · NetworkManager"
        tickerText: "VYŠŠÍ SFÉRY POTVRZUJÍ: Instalace probíhá bez zásahu cizích struktur"

        // Houpající se kyvadlo + razítko SCHVÁLENO
        Item {
            anchors.fill: parent

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 20
                width: 90
                height: 2
                color: "#b89400"
            }

            Item {
                id: pendulumPivot
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 22
                width: 4
                height: 130
                transformOrigin: Item.Top

                SequentialAnimation on rotation {
                    loops: Animation.Infinite
                    NumberAnimation { from: -24; to: 24; duration: 1500; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 24; to: -24; duration: 1500; easing.type: Easing.InOutSine }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 2
                    height: 108
                    color: "#ffd700"
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    width: 26
                    height: 26
                    radius: 13
                    color: "#ffd700"
                    border.color: "#fff2a6"
                    border.width: 2
                }
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 24
                width: 146
                height: 34
                radius: 4
                color: "#0b0a0c"
                border.color: "#7bd88f"
                border.width: 2
                rotation: -5

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.45; to: 1.0; duration: 750; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.0; to: 0.45; duration: 750; easing.type: Easing.InOutSine }
                }

                Text {
                    anchors.centerIn: parent
                    text: "SCHVÁLENO"
                    color: "#7bd88f"
                    font.family: "monospace"
                    font.pixelSize: 15
                    font.bold: true
                }
            }
        }
    }

    // ==================== SLIDE 2: LUSTRÁTOR 100 666 ====================
    ArchiveSlide {
        indexNum: 1
        sectionCode: "§ 02"
        headline: "Lustrátor 100 666 záznamů StB"
        bodyText: "Příkazy adduser a lustrace prověřují nové účty i celá jména proti 100 666 reálným archivním záznamům z protokolů StB — včetně krycích jmen a čísel svazků."
        subNote: "$ lustrace <jméno>  ·  $ adduser <uživatel>  ·  userdel -rf při shodě"
        tickerText: "DATABÁZE ARCHIVU: 100 666 svazků připraveno (odezva pod 50 ms)"

        Item {
            anchors.fill: parent
            property int shownCount: 0

            NumberAnimation on shownCount {
                from: 0
                to: 100666
                duration: 3800
                loops: Animation.Infinite
                easing.type: Easing.OutCubic
            }

            Column {
                anchors.centerIn: parent
                spacing: 12
                width: parent.width - 28

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: parent.parent.shownCount.toLocaleString()
                    color: "#ffd700"
                    font.family: "monospace"
                    font.pixelSize: 30
                    font.bold: true
                }

                Rectangle {
                    width: parent.width
                    height: 82
                    radius: 4
                    color: "#0b0a0c"
                    border.color: "#2c2531"

                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 5
                        Text { text: "00142  AGENT BRAMBOR  | TS"; color: "#a69e8e"; font.family: "monospace"; font.pixelSize: 11 }
                        Text { text: "08917  KRYCÍ: SÍŤOVKA | A "; color: "#a69e8e"; font.family: "monospace"; font.pixelSize: 11 }
                        Text { text: "42019  SOUDRUH FÍZL   | KTS"; color: "#e0384f"; font.family: "monospace"; font.pixelSize: 11; font.bold: true }
                    }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 140
                    height: 30
                    radius: 4
                    color: "#0b0a0c"
                    border.color: "#e0384f"
                    border.width: 2
                    rotation: -7

                    SequentialAnimation on scale {
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.18; to: 1.0; duration: 600; easing.type: Easing.OutBack }
                        PauseAnimation { duration: 1600 }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "ZAMÍTNUTO"
                        color: "#e0384f"
                        font.family: "monospace"
                        font.pixelSize: 14
                        font.bold: true
                    }
                }
            }
        }
    }

    // ==================== SLIDE 3: FIREWALL RADAR ====================
    ArchiveSlide {
        indexNum: 2
        sectionCode: "§ 03"
        headline: "Firewall proti fízlokracii"
        bodyText: "Služba fizlokracie.service automaticky blokuje ruské a čínské IP rozsahy v jádře přes nftables. Síťové chyby 404 systém hlásí jako úspěšnou sabotáž marxisticko-leninských struktur."
        subNote: "nft list table inet fizlokracie · fizlokracie-firewall --status"
        tickerText: "NFTABLES AKTIVNÍ: Ruské a čínské bloky jsou zahozeny na vstupu i výstupu"

        Item {
            anchors.fill: parent

            Canvas {
                id: radarCanvas
                anchors.centerIn: parent
                width: 184
                height: 184
                property real sweepAngle: 0

                NumberAnimation on sweepAngle {
                    from: 0
                    to: 360
                    duration: 3200
                    loops: Animation.Infinite
                }

                onSweepAngleChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    var cx = width / 2
                    var cy = height / 2
                    var r = 82

                    // Pozadí a soustředné kruhy
                    ctx.fillStyle = "#0b0a0c"
                    ctx.beginPath()
                    ctx.arc(cx, cy, r, 0, Math.PI * 2)
                    ctx.fill()

                    ctx.strokeStyle = "#2c2531"
                    ctx.lineWidth = 1.2
                    for (var k = 1; k <= 3; k++) {
                        ctx.beginPath()
                        ctx.arc(cx, cy, r * k / 3, 0, Math.PI * 2)
                        ctx.stroke()
                    }
                    ctx.beginPath()
                    ctx.moveTo(cx - r, cy); ctx.lineTo(cx + r, cy)
                    ctx.moveTo(cx, cy - r); ctx.lineTo(cx, cy + r)
                    ctx.stroke()

                    // Rotující paprsek radaru
                    var rad = (sweepAngle - 90) * Math.PI / 180
                    ctx.fillStyle = "rgba(255, 215, 0, 0.18)"
                    ctx.beginPath()
                    ctx.moveTo(cx, cy)
                    ctx.arc(cx, cy, r, rad - 0.55, rad)
                    ctx.closePath()
                    ctx.fill()

                    ctx.strokeStyle = "#ffd700"
                    ctx.lineWidth = 2
                    ctx.beginPath()
                    ctx.moveTo(cx, cy)
                    ctx.lineTo(cx + r * Math.cos(rad), cy + r * Math.sin(rad))
                    ctx.stroke()

                    // Blokované RU / CN body
                    ctx.fillStyle = "#e0384f"
                    ctx.beginPath(); ctx.arc(cx + 38, cy - 30, 5, 0, Math.PI * 2); ctx.fill()
                    ctx.beginPath(); ctx.arc(cx - 34, cy + 36, 5, 0, Math.PI * 2); ctx.fill()
                    ctx.fillStyle = "#ffd700"
                    ctx.beginPath(); ctx.arc(cx, cy, 4, 0, Math.PI * 2); ctx.fill()
                }
            }

            Text {
                anchors.top: radarCanvas.top
                anchors.topMargin: 46
                anchors.right: radarCanvas.right
                anchors.rightMargin: 18
                text: "RU ZAHOZENO"
                color: "#e0384f"
                font.family: "monospace"
                font.pixelSize: 10
                font.bold: true
            }

            Text {
                anchors.bottom: radarCanvas.bottom
                anchors.bottomMargin: 40
                anchors.left: radarCanvas.left
                anchors.leftMargin: 14
                text: "CN ZAHOZENO"
                color: "#e0384f"
                font.family: "monospace"
                font.pixelSize: 10
                font.bold: true
            }
        }
    }

    // ==================== SLIDE 4: SUDO -> KYVADLO ====================
    ArchiveSlide {
        indexNum: 3
        sectionCode: "§ 04"
        headline: "Příkaz kyvadlo místo sudo"
        bodyText: "Každé spuštění sudo je přesměrováno na siderické kyvadlo, které čte entropii přímo z /dev/kyvadlo. S 50% šancí přístup schválí — jinak odhalí agenta StB."
        subNote: "$ kyvadlo --stav  ·  $ kyvadlo --generuj-klic 32  ·  generátor: /dev/kyvadlo"
        tickerText: "SIDERICKÝ GENERÁTOR /dev/kyvadlo: Kontakt s vyššími sférami navázán"

        Item {
            anchors.fill: parent
            property bool approved: true

            Timer {
                interval: 1800
                running: true
                repeat: true
                onTriggered: parent.approved = !parent.approved
            }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 28
                height: 150
                radius: 6
                color: "#0b0a0c"
                border.color: parent.approved ? "#7bd88f" : "#e0384f"
                border.width: 1.5

                Column {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    Text {
                        text: "$ sudo pacman -Syu"
                        color: "#ffd700"
                        font.family: "monospace"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    Text {
                        text: "Konzultuji /dev/kyvadlo..."
                        color: "#a69e8e"
                        font.family: "monospace"
                        font.pixelSize: 11
                    }

                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: parent.parent.parent.approved
                            ? "✓ POVOLENO: Kyvadlo se zhouplo doprava.\n  uid=0(cibulka) gid=0(root)"
                            : "✗ ZAMÍTNUTO: Kyvadlo zjistilo,\n  že jste infiltrovaný agent StB!"
                        color: parent.parent.parent.approved ? "#7bd88f" : "#e0384f"
                        font.family: "monospace"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
            }
        }
    }

    // ==================== SLIDE 5: ANTI-GRUB ====================
    ArchiveSlide {
        indexNum: 4
        sectionCode: "§ 05"
        headline: "Zavaděč Anti-GRU(B)"
        bodyText: "Zavaděč byl zbaven asociace s ruskou rozvědkou GRU, dostal vlastní grafické téma a při každém startu běží kontrola integrity anti-grub-check.service."
        subNote: "anti-grub-mkconfig · anti-grub-install · anti-grub-check.service"
        tickerText: "ANTI-GRUB PROVĚŘEN: Vlastní téma se zlatým rastrovým portrétem nainstalováno"

        Item {
            anchors.fill: parent
            property int activeRow: 0

            Timer {
                interval: 1200
                running: true
                repeat: true
                onTriggered: parent.activeRow = (parent.activeRow + 1) % 3
            }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 28
                height: 152
                radius: 6
                color: "#0b0a0c"
                border.color: "#2c2531"

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Text {
                        text: "ANTI-GRUB · CIBULKAOS"
                        color: "#ffd700"
                        font.family: "monospace"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Repeater {
                        model: [
                            "▸ Anti-GRUB CibulkaOS Linux",
                            "  CibulkaOS Linux (záložní)",
                            "  Nastavení firmwaru UEFI"
                        ]
                        Rectangle {
                            width: parent.width
                            height: 26
                            radius: 3
                            color: index === parent.parent.parent.activeRow ? "#ffd700" : "#16131a"

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                text: modelData
                                color: index === parent.parent.parent.parent.activeRow ? "#0b0a0c" : "#a69e8e"
                                font.family: "monospace"
                                font.pixelSize: 11
                                font.bold: index === parent.parent.parent.parent.activeRow
                            }
                        }
                    }
                }
            }
        }
    }

    // ==================== SLIDE 6: SVOBODA ZVÍTĚZÍ ====================
    ArchiveSlide {
        indexNum: 5
        sectionCode: "§ 06"
        headline: "Svoboda zvítězí!"
        bodyText: "Instalace se blíží ke konci. Po restartu vás přivítá Anti-GRUB, přihlašovací obrazovka SDDM a připravená plocha KDE Plasma 6 v tmavém motivu CibulkaOS."
        subNote: "C//OS · ANTI-GRU · https://cibulka.net"
        tickerText: "ARCHIV UZAVŘEN: Připravuje se první spuštění svobodného systému"

        Item {
            anchors.fill: parent

            Canvas {
                id: rosetteCanvas
                anchors.centerIn: parent
                width: 186
                height: 186
                property int drawnEllipses: 1

                Timer {
                    interval: 350
                    running: true
                    repeat: true
                    onTriggered: {
                        rosetteCanvas.drawnEllipses = (rosetteCanvas.drawnEllipses % 12) + 1
                        rosetteCanvas.requestPaint()
                    }
                }

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    var cx = width / 2
                    var cy = height / 2
                    ctx.strokeStyle = "rgba(255, 215, 0, 0.5)"
                    ctx.lineWidth = 1.4
                    for (var i = 0; i < drawnEllipses; i++) {
                        ctx.save()
                        ctx.translate(cx, cy)
                        ctx.rotate(i * Math.PI / 12)
                        ctx.beginPath()
                        ctx.ellipse(-74, -22, 148, 44)
                        ctx.stroke()
                        ctx.restore()
                    }
                }
            }

            Image {
                anchors.centerIn: parent
                source: "cibulkaos-stamp.png"
                width: 116
                height: 116
                fillMode: Image.PreserveAspectFit
            }
        }
    }
}
