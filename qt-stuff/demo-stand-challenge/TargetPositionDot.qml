import QtQuick 2.12

PositionDot {
    id: root

    property point target: Qt.point(parent.width / 2, parent.height / 2)
    property size bounds: Qt.size(parent.width, parent.height)
    property point normalPosition: Qt.point(position.x / bounds.width,
                                            position.y / bounds.height)

    position: Qt.point(Math.min(Math.max(0, target.x), bounds.width),
                       Math.min(Math.max(0, target.y), bounds.height))
}
