import QtQuick 2.10
import RoboticArmVideoQML 1.0

Rectangle {
    width: Constants.width
    height: Constants.height

    color: Constants.backgroundColor

    Text {
        text: qsTr("Hello RoboticArmVideoQML")
        anchors.centerIn: parent
        font: Constants.font
    }
}
