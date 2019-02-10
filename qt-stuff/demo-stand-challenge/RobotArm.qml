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

    function parse(object)
    {
        root.x = object.x
        root.y = object.y
        root.z = object.z
        root.roll = object.roll
        root.pitch = object.pitch
        root.yaw = object.yaw
        root.open = object.open
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
