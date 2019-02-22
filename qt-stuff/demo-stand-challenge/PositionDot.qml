import QtQuick 2.12

Item {
    id: root

    property real diameter
    property alias color: inner.color
    property point position: Qt.point(x, y)

    x: position.x
    y: position.y

    Rectangle {
        id: inner

        anchors.centerIn: parent

        transform: Translate {
            y: -root.height / 2
            x: -root.width / 2
        }

        width: root.diameter
        height: width
        radius: width * 0.5

        border.width: 1
        border.color: "white"
    }

//    onPositionChanged: console.log('position: ' + position)

    // animation
    Behavior on x {
        NumberAnimation {
            duration: 100
            easing.type: Easing.OutQuart
        }
    }

    Behavior on y {
        NumberAnimation {
            duration: 100
            easing.type: Easing.OutQuart
        }
    }
}
