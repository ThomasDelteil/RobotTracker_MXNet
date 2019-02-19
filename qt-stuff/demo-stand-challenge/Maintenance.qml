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
                                        xLeft: robotsModel.leftArm.x.toFixed(3).toString()
                                        xRight: robotsModel.rightArm.x.toFixed(3).toString()
                                        yLeft: robotsModel.leftArm.y.toFixed(3).toString()
                                        yRight: robotsModel.rightArm.y.toFixed(3).toString()
                                        zLeft: robotsModel.leftArm.z.toFixed(3).toString()
                                        zRight: robotsModel.rightArm.z.toFixed(3).toString()
                                        yawLeft: robotsModel.leftArm.yaw.toFixed(3).toString()
                                        yawRight: robotsModel.rightArm.yaw.toFixed(3).toString()
                                        pitchLeft: robotsModel.leftArm.pitch.toFixed(3).toString()
                                        pitchRight: robotsModel.rightArm.pitch.toFixed(3).toString()
                                        rollLeft: robotsModel.leftArm.roll.toFixed(3).toString()
                                        rollRight: robotsModel.rightArm.roll.toFixed(3).toString()
                                        calibrationNeededLeft: robotsModel.leftArm.calibrationNeeded ? "yes" : "no"
                                        calibrationNeededRight: robotsModel.rightArm.calibrationNeeded ? "yes" : "no"
                                        openRight: robotsModel.rightArm.isOpen ? "yes" : "no"
                                        openLeft: robotsModel.leftArm.isOpen ? "yes" : "no"
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

                                    robotsModel.leftArm.setLearningMode(isOn)
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

                                    robotsModel.leftArm.calibrate()
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

                                    robotsModel.rightArm.setLearningMode(isOn)
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

                                    robotsModel.rightArm.calibrate()
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
