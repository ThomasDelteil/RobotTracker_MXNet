import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import io.qt.Backend 1.0

ApplicationWindow {
    id: root
    visible: true
    visibility: "FullScreen"
    width: 1100
    minimumWidth: 900
    height: 700
    minimumHeight: 500
    title: qsTr("Leaderboard")

    property real scaleRatio: Screen.devicePixelRatio.toFixed(0) < 2 ? 1.5 : 2
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
            source: "qrc:/img/bookshelf.png"
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
                    Layout.topMargin: parent.height * 0.02
                    Layout.alignment: Qt.AlignHCenter
                    font.family: typodermic.name
                    // TODO check on super high resolution displays
                    font.pointSize: calculateFontSize(parent.width, 0.04)
                    color: "#43ADEE"
                    text: "LEADERBOARD"
                }

                Text {
                    id: plrsCnt
                    Layout.alignment: Qt.AlignHCenter
                    font.family: titillium.name
                    font.pointSize: calculateFontSize(parent.width, 0.02)
                    font.bold: true
                    text: "Total participants: " + backend.scores.rowCount()
                }

                // TODO perhaps, it's worth doing something to prevent list "jumping" on model updates
                ListView {
                    id: scoresList
                    Layout.preferredWidth: parent.width * 0.6
                    Layout.fillHeight: true
                    Layout.topMargin: 25
                    Layout.alignment: Qt.AlignHCenter
                    clip: true

                    model: backend.scores

                    delegate: ItemDelegate {
                        height: position < 4 ? calculateFontSize(parent.width, 0.035) * 2.5 : calculateFontSize(parent.width, 0.025) * 3

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
                                font.pointSize: position < 4 ? calculateFontSize(parent.width, 0.035) : calculateFontSize(parent.width, 0.025)
                                font.family: titillium.name
                                font.bold: true
                                visible: position >= 4
                                text: position
                            }

                            Text {
                                Layout.fillWidth: true
                                Layout.leftMargin: 30
                                horizontalAlignment: Text.AlignLeft
                                font.pointSize: position < 4 ? calculateFontSize(parent.width, 0.035) : calculateFontSize(parent.width, 0.025)
                                font.family: titillium.name
                                //font.bold: position < 4 ? true : false
                                text: player
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.preferredWidth: parent.width * 0.1
                                Layout.leftMargin: 5
                                horizontalAlignment: Text.AlignHCenter
                                font.pointSize: position < 4 ? calculateFontSize(parent.width, 0.035) : calculateFontSize(parent.width, 0.025)
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
            color: "#B17F4A"
        }
    }

    function calculateFontSize(parentWidth, parentWidthFraction)
    {
        var fontSize = parentWidth > 0 ? parentWidth * parentWidthFraction * root.scaleRatio : root.primaryFontSize;
        //console.log(parentWidth, parentWidthFraction, fontSize);
        return Math.round(fontSize);
    }
}
