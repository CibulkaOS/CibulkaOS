/* CibulkaOS - Instalační prezentace */
import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation {
    id: presentation

    function nextSlide() {
        presentation.goToNextSlide();
    }

    Timer {
        id: advanceTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: nextSlide()
    }

    Slide {
        anchors.fill: parent
        Rectangle {
            anchors.fill: parent
            color: "#1c1c2e"
            Column {
                anchors.centerIn: parent
                spacing: 24
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "CibulkaOS se instaluje..."
                    color: "#cdd6f4"
                    font.pixelSize: 32
                    font.bold: true
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Distribuce Arch Linuxu pro svobodné Čechy"
                    color: "#a6adc8"
                    font.pixelSize: 18
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    color: "#585b70"
                    font.pixelSize: 14
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Kyvadlo schválilo vaši instalaci."
                    color: "#cba6f7"
                    font.pixelSize: 16
                    font.italic: true
                }
            }
        }
    }

    Slide {
        anchors.fill: parent
        Rectangle {
            anchors.fill: parent
            color: "#1c1c2e"
            Column {
                anchors.centerIn: parent
                spacing: 20
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Anti-GRU(B) Bootloader"
                    color: "#a6e3a1"
                    font.pixelSize: 28
                    font.bold: true
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Váš bootloader byl lustračně ověřen."
                    color: "#cdd6f4"
                    font.pixelSize: 16
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Žádní agenti GRU nebyli detekováni v MBR."
                    color: "#a6adc8"
                    font.pixelSize: 14
                    font.italic: true
                }
            }
        }
    }

    Slide {
        anchors.fill: parent
        Rectangle {
            anchors.fill: parent
            color: "#1c1c2e"
            Column {
                anchors.centerIn: parent
                spacing: 20
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Příkaz 'kyvadlo'"
                    color: "#f9e2af"
                    font.pixelSize: 28
                    font.bold: true
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Náhrada za 'sudo' s 50% šancí zamítnutí."
                    color: "#cdd6f4"
                    font.pixelSize: 16
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Siderické kyvadlo rozhoduje, kdo má přístup."
                    color: "#a6adc8"
                    font.pixelSize: 14
                    font.italic: true
                }
            }
        }
    }

    Slide {
        anchors.fill: parent
        Rectangle {
            anchors.fill: parent
            color: "#1c1c2e"
            Column {
                anchors.centerIn: parent
                spacing: 20
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Firewall proti fízlokracii"
                    color: "#f38ba8"
                    font.pixelSize: 28
                    font.bold: true
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "IP adresy Ruska a Číny jsou automaticky blokovány."
                    color: "#cdd6f4"
                    font.pixelSize: 16
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Chyba 404 = Úspěšná sabotáž marxisticko-leninských struktur"
                    color: "#a6adc8"
                    font.pixelSize: 13
                    font.italic: true
                }
            }
        }
    }

    Slide {
        anchors.fill: parent
        Rectangle {
            anchors.fill: parent
            color: "#1c1c2e"
            Column {
                anchors.centerIn: parent
                spacing: 20
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "/dev/kyvadlo"
                    color: "#89dceb"
                    font.pixelSize: 28
                    font.bold: true
                    font.family: "monospace"
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Siderický generátor náhodných čísel."
                    color: "#cdd6f4"
                    font.pixelSize: 16
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Šifrovací klíče jsou generovány ve spolupráci s vyššími sférami."
                    color: "#a6adc8"
                    font.pixelSize: 13
                    font.italic: true
                }
            }
        }
    }
}
