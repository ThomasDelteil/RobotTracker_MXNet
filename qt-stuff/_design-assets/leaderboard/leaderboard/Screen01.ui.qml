import QtQuick 2.12
import RoboticArmLeaderboardQML 1.0

Rectangle {
    width: Constants.width
    height: Constants.height

    color: Constants.backgroundColor

    Text {
        text: qsTr("Hello RoboticArmLeaderboardQML")
        anchors.centerIn: parent
        font.family: Constants.font.family
    }
}
