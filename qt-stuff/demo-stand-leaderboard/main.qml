import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import io.qt.Backend 1.0

ApplicationWindow {
    id: root
    visible: true
    width: 1100
    minimumWidth: 700
    height: 700
    minimumHeight: 500
    title: qsTr("Leaderboard")

    property int primaryFontSize: 34
    property string backgroundColor: "#ECECEC"

    Backend { id: backend }

    ColumnLayout {
        anchors.fill: parent

        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            Layout.alignment: Qt.AlignCenter
            text: "Total participants: " + backend.scores.rowCount()
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: root.primaryFontSize * 2
        }

        ListView {
            model: backend.scores

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            delegate: ItemDelegate {
                height: root.primaryFontSize * 3
                width: parent.width
                RowLayout {
                    anchors.fill: parent
                    Text {
                        Layout.preferredWidth: parent.width * 0.1
                        Layout.alignment: Qt.AlignCenter
                        text: position
                        font.pixelSize: position < 4 ? root.primaryFontSize * 1.8 : root.primaryFontSize
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    Text {
                        Layout.fillWidth: true
                        text: player
                        font.pixelSize: position < 4 ? root.primaryFontSize * 1.3 : root.primaryFontSize
                        color: "blue"
                        horizontalAlignment: Text.AlignLeft
                    }
                    Text {
                        Layout.preferredWidth: parent.width * 0.1
                        Layout.alignment: Qt.AlignCenter
                        text: score
                        font.pixelSize: position < 4 ? root.primaryFontSize * 1.5 : root.primaryFontSize
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
                highlighted: hovered
            }
        }
    }
}
