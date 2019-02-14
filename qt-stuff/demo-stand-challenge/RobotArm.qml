import QtQuick 2.12

QtObject {
    id: root

    enum ConnectionStatus {
        Disconnected = 0,
        Connecting = 1,
        Connected = 2,
        Error = 3
    }

    property int connectionStatus: RobotArm.ConnectionStatus.Connecting

    property real x
    property real y
    property real z

    property real roll
    property real pitch
    property real yaw

    property bool open

    property string name

    property real minX: 0.253
    property real maxX: 0.253

    property real minY: -0.25
    property real maxY: 0.25

    property real minZ: 0.1
    property real maxZ: 0.37

    property real minRoll: 0
    property real maxRoll: 0

    property real minPitch: Math.PI / 2
    property real maxPitch: Math.PI / 2

    property real minYaw: -Math.PI / 2
    property real maxYaw: -Math.PI / 2

    property bool calibrationNeeded
    property bool learningMode

    function parse(object)
    {
        root.x = object.x
        root.y = object.y
        root.z = object.z
        root.roll = object.roll
        root.pitch = object.pitch
        root.yaw = object.yaw
        root.open = object.open
        root.calibrationNeeded = object.calibrationNeeded
        root.learningMode = object.learningMode
    }

    function getConnectionStatusColor()
    {
        switch (connectionStatus)
        {
            case 0: return "red";
            case 1: return "lightblue";
            case 2: return "green";
            case 3: return "yellow";
        }
    }
}
