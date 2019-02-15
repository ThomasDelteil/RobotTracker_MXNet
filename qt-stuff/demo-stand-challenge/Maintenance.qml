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
                    Layout.preferredHeight: parent.height * 0.7
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
                            Layout.minimumWidth: 250
                            Layout.fillHeight: true
                            color: "transparent"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 10

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    StatusRow {
                                        text: "Algorithm:"
                                        color: backend.connected ? "green" : "red"
                                    }

                                    StatusRow {
                                        text: "Proxy:"
                                        color: robotsModel.state === "connected" ? "green" : "red"
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 5
                                }

                                ScrollView {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.fillHeight: true
                                    clip: true

                                    ArmsData {
                                        id: armsdata
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
                                        calibrationNeededLeft: robotsModel.leftArm.calibrationNeeded ? "yes" : "no"
                                        calibrationNeededRight: robotsModel.rightArm.calibrationNeeded ? "yes" : "no"
                                    }
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

                        ColumnLayout {
                            Layout.fillHeight: true
                            spacing: 15

                            Text {
                                text: "left"
                                font.pointSize: root.secondaryFontSize
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Switch {
                                text: "Learning mode"
                                checked: robotsModel.leftArm.learningMode
                                onClicked: {
                                    let isOn = !robotsModel.leftArm.learningMode
                                    appendToMaintenanceOutput("setLearningMode left: " + isOn)

                                    robotsModel.setLearningMode({ name: "left" }, isOn)
                                }
                            }

                            FancyButton {
                                Layout.alignment: Qt.AlignHCenter
                                font.pointSize: root.secondaryFontSize
                                unpressedColor: "#0096FF"
                                pressedColor: "#3679CC"
                                text: "Calibrate"
                                onClicked: {
                                    appendToMaintenanceOutput("calibrate left")

                                    robotsModel.calibrate({ name: "left" })
                                }
                            }

                        }

                        Rectangle {
                            Layout.fillHeight: true
                            width: 1
                            color: "black"
                        }

                        ColumnLayout {
                            Layout.fillHeight: true
                            spacing: 15

                            Text {
                                text: "right"
                                font.pointSize: root.secondaryFontSize
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Switch {
                                text: "Learning mode"
                                checked: robotsModel.rightArm.learningMode
                                onClicked: {
                                    let isOn = !robotsModel.rightArm.learningMode
                                    appendToMaintenanceOutput("setLearningMode right: " + isOn)

                                    robotsModel.setLearningMode({ name: "right" }, isOn)
                                }
                            }

                            FancyButton {
                                Layout.alignment: Qt.AlignHCenter
                                font.pointSize: root.secondaryFontSize
                                unpressedColor: "#0096FF"
                                pressedColor: "#3679CC"
                                text: "Calibrate"
                                onClicked: {
                                    appendToMaintenanceOutput("calibrate right")

                                    robotsModel.calibrate({ name: "right" })
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            width: 1
                            color: "black"
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }
                }
            }
        }
    }

    function appendToMaintenanceOutput(msg) {
        ta_maintenanceOutput.append(msg, "\n")
    }
}
