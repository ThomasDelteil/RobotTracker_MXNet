import QtQuick 2.0

Item {
    id: root

    property alias data: data

    QtObject {
        id: data

        property real x
        property real y
        property real z

        property real roll
        property real pitch
        property real yaw

        property bool open
    }

    function parse(object) {
        root.data.x = object.x
        root.data.y = object.y
        root.data.z = object.z
        root.data.roll = object.roll
        root.data.pitch = object.pitch
        root.data.yaw = object.yaw
        root.data.open = object.open
    }

    states: [
        State {
            name: "disconnected"
        },
        State {
            name: "connecting"
        },
        State {
            name: "connected"
        },
        State {
            name: "error"
        }
    ]
}
