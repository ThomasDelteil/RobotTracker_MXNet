import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import io.qt.Backend 1.0

ApplicationWindow {
    id: root
    visible: true
    width: 1100
    minimumWidth: 900
    height: 700
    minimumHeight: 500
    title: qsTr("Leaderboard")

    property int primaryFontSize: 40
    property int secondaryFontSize: 30
    property string backgroundColor: "#ECECEC"

    Backend {
        id: backend

        onCountChanged: {
            plrsCnt.text = "Total participants: " + cnt;
        }
    }

    FontLoader { id: typodermic; source: "qrc:/fonts/typodermic.ttf" }
    FontLoader { id: titillium; source: "qrc:/fonts/titillium.ttf" }
    FontLoader { id: titilliumBold; source: "qrc:/fonts/titillium-bold.ttf" }

    Rectangle {
        anchors.fill: parent
        color: "#D1E1ED"

        Image {
            id: topShelf
            anchors.top: parent.top
            anchors.topMargin: 10
            width: parent.width
            source: "qrc:/img/top-shelf.png"
            fillMode: Image.PreserveAspectFit
        }

        Image {
            anchors.top: topShelf.bottom
            width: parent.width
            z: 1
            source: "qrc:/img/bookmark.png"
            fillMode: Image.PreserveAspectFit
        }

        Rectangle {
            anchors.top: topShelf.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: floor.top
            width: parent.width * 0.6
            color: "white"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    font.family: typodermic.name
                    font.pointSize: parent.width * 0.08
                    color: "#63ADE8"
                    text: "LEADERBOARD"
                }

                Text {
                    Layout.topMargin: -5
                    id: plrsCnt
                    Layout.alignment: Qt.AlignHCenter
                    font.family: titillium.name
                    font.pointSize: root.secondaryFontSize
                    font.bold: true
                    text: "Total participants: " + backend.scores.rowCount()
                }

                // TODO perhaps, it's worth doing something to prevent list "jumping" on model updates
                ListView {
                    Layout.preferredWidth: parent.width * 0.6
                    Layout.minimumWidth: 400
                    Layout.fillHeight: true
                    Layout.topMargin: 25
                    Layout.alignment: Qt.AlignHCenter
                    clip: true

                    model: backend.scores

                    delegate: ItemDelegate {
                        height: root.primaryFontSize * 1.5
                        width: parent.width
                        RowLayout {
                            anchors.fill: parent
                            spacing: 0

                            Image
                            {
                                Layout.preferredWidth: parent.width * 0.1
                                source: position < 4 ? "qrc:/img/" + position + ".png" : ""
                                fillMode: Image.PreserveAspectFit
                                visible: position < 4
                            }
                            Text {
                                Layout.preferredWidth: parent.width * 0.1
                                horizontalAlignment: Text.AlignRight
                                font.pointSize: position < 4 ? root.primaryFontSize : root.secondaryFontSize
                                font.family: titillium.name
                                font.bold: true
                                visible: position >= 4
                                text: position
                            }

                            Text {
                                Layout.fillWidth: true
                                Layout.leftMargin: 25
                                horizontalAlignment: Text.AlignLeft
                                font.pointSize: position < 4 ? root.primaryFontSize : root.secondaryFontSize
                                font.family: titillium.name
                                //font.bold: position < 4 ? true : false
                                text: player
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.preferredWidth: parent.width * 0.1
                                Layout.leftMargin: 5
                                horizontalAlignment: Text.AlignHCenter
                                font.pointSize: position < 4 ? root.primaryFontSize : root.secondaryFontSize
                                font.family: titillium.name
                                font.bold: position < 4 ? true : false
                                text: score
                            }
                        }
                        highlighted: hovered
                    }
                }
            }
        }

        Rectangle {
            id: floor
            anchors.bottom: parent.bottom
            width: parent.width
            height: parent.height * 0.025
            color: "#A98052"
        }
    }
}
