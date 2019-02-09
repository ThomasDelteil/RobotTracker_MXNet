import QtQuick 2.0

QtObject {
    id: root

    enum State {
        Disconnected,
        Connecting,
        Connected,
        Error
    }

    property int state: RobotArm.State.Disconnected

    property real x
    property real y
    property real z

    property real roll
    property real pitch
    property real yaw

    property bool open

    function parse(object) {
        root.x = object.x
        root.y = object.y
        root.z = object.z
        root.roll = object.roll
        root.pitch = object.pitch
        root.yaw = object.yaw
        root.open = object.open
    }
}
