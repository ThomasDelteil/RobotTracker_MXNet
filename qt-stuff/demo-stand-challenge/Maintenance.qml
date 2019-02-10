import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

Item {
    anchors.fill: parent

    Image {
        anchors.fill: parent

        source: "qrc:/img/under-construction.png"
        fillMode: Image.PreserveAspectCrop

        Rectangle {
            anchors.fill: parent
            anchors.margins: 20
            color: root.backgroundColor
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height * 0.6
                    color: "transparent"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            border.width: 1

                            ScrollView {
                                anchors.fill: parent
                                anchors.margins: 5

                                TextArea {
                                    id: ta_maintenanceOutput
                                    readOnly: true
                                    font.pointSize: root.secondaryFontSize
                                    font.family: "Courier New"
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    selectByMouse: true
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: parent.width * 0.2
                            Layout.minimumWidth: 250;
                            Layout.fillHeight: true
                            color: "transparent"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 10

                                StatusRow {
                                    text: "Algorithm server:"
                                    color: "red"
                                }

                                StatusRow {
                                    text: "Arm proxy server:"
                                    color: "red"
                                }

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }

                                ArmsData {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignHCenter

                                    statusLeft: robotsModel.leftArm.getConnectionStatusColor()
                                    statusRight: robotsModel.rightArm.getConnectionStatusColor()
                                    xLeft: robotsModel.leftArm.x
                                    xRight: robotsModel.rightArm.x
                                    yLeft: robotsModel.leftArm.y
                                    yRight: robotsModel.rightArm.y
                                    zLeft: robotsModel.leftArm.z
                                    zRight: robotsModel.rightArm.z
                                    yawLeft: robotsModel.leftArm.yaw
                                    yawRight: robotsModel.rightArm.yaw
                                    pitchLeft: robotsModel.leftArm.pitch
                                    pitchRight: robotsModel.rightArm.pitch
                                    rollLeft: robotsModel.leftArm.roll
                                    rollRight: robotsModel.rightArm.roll
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15

                        GridLayout {
                            rows: 3
                            columns: 3
                            rowSpacing: 10
                            columnSpacing: 10

                            FancyButton {
                                Layout.row: 1
                                Layout.column: 1
                                Layout.alignment: Qt.AlignHCenter
                                font.pointSize: root.secondaryFontSize
                                unpressedColor: "#0096FF"
                                pressedColor: "#3679CC"
                                text: "Up"
                                onClicked: {
                                    appendToMaintenanceOutput("up");
                                }
                            }

                            FancyButton {
                                Layout.row: 2
                                Layout.column: 0
                                font.pointSize: root.secondaryFontSize
                                unpressedColor: "#0096FF"
                                pressedColor: "#3679CC"
                                text: "Left"
                                onClicked: {
                                    appendToMaintenanceOutput("left");
                                }
                            }

                            FancyButton {
                                Layout.row: 2
                                Layout.column: 1
                                font.pointSize: root.secondaryFontSize * 1.5
                                unpressedColor: "#FF2600"
                                pressedColor: "#B5331E"
                                text: "RESET"
                                onClicked: {
                                    appendToMaintenanceOutput("RESET");
                                }
                            }

                            FancyButton {
                                Layout.row: 2
                                Layout.column: 2
                                font.pointSize: root.secondaryFontSize
                                unpressedColor: "#0096FF"
                                pressedColor: "#3679CC"
                                text: "Right"
                                onClicked: {
                                    appendToMaintenanceOutput("right");
                                }
                            }

                            FancyButton {
                                Layout.row: 3
                                Layout.column: 1
                                Layout.alignment: Qt.AlignHCenter
                                font.pointSize: root.secondaryFontSize
                                unpressedColor: "#0096FF"
                                pressedColor: "#3679CC"
                                text: "Down"
                                onClicked: {
                                    appendToMaintenanceOutput("down");
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            width: 1
                            color: "black"
                        }

                        FancyButton {
                            font.pointSize: root.secondaryFontSize
                            unpressedColor: "#0096FF"
                            pressedColor: "#3679CC"
                            text: "Some"
                            onClicked: {
                                appendToMaintenanceOutput("some");
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            width: 1
                            color: "black"
                        }

                        FancyButton {
                            font.pointSize: root.secondaryFontSize
                            unpressedColor: "#0096FF"
                            pressedColor: "#3679CC"
                            text: "Another"
                            onClicked: {
                                appendToMaintenanceOutput("another");
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }

                        FancyButton {
                            Layout.row: 2
                            Layout.column: 1
                            font.pointSize: root.secondaryFontSize * 1.5
                            unpressedColor: "#FF2600"
                            pressedColor: "#B5331E"
                            text: "EMERGENCY\nSTOP"
                            onClicked: {
                                appendToMaintenanceOutput("EMERGENCY STOP");
                            }
                        }
                    }
                }
            }
        }
    }

    function appendToMaintenanceOutput(msg)
    {
        ta_maintenanceOutput.append(msg, "\n");
    }
}
