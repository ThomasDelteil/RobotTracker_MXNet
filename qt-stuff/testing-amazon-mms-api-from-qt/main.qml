import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import Qt.labs.folderlistmodel 2.11
import io.qt.Backend 1.0

ApplicationWindow {
    id: root
    visible: true
    width: 1100
    minimumWidth: 700
    height: 700
    minimumHeight: 500
    title: qsTr("MXNet client")

    property int fontSize: 16
    property string backgroundColor: "#ECECEC"
    property string endpointValue: "http://10.9.71.47/predictions/squeezenet"

    Backend {
        id: backend

        onRequestDone: {
            ta_mxnetOutput.append(result + "\n---");
            progressBar.visible = false;
        }

        onRequestFailed: {
            ta_mxnetOutput.append(error + "\n---");
            progressBar.visible = false;
        }
    }

    color: root.backgroundColor

    ColumnLayout {
        anchors.fill: parent
        //anchors.margins: 5
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.35
            spacing: 0

            Rectangle {
                Layout.preferredWidth: parent.width * 0.3
                Layout.fillHeight: true

                ListView {
                    id: files
                    anchors.fill: parent
                    //clip: true

                    FolderListModel {
                        id: folderModel
                        folder: "file:" + basePath + "img/"
                        nameFilters: ["*.jpg"]
                        caseSensitive: false
                    }

                    model: folderModel
                    delegate: ItemDelegate {
                        width: parent.width
                        text: model.fileName
                        font.pixelSize: 15
                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.Wrap
                        }

                        highlighted: ListView.isCurrentItem

                        onClicked: { files.currentIndex = model.index; }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "lightgray"

                Image {
                    id: currentPhoto
                    anchors.fill: parent
                    anchors.margins: 20
                    source: folderModel.get(files.currentIndex, "fileURL");
                    fillMode: Image.PreserveAspectFit
                    autoTransform: true
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.1
            border.width: 1
            border.color: "gray"
            color: root.backgroundColor

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 10

                Text {
                    text: "MXNet endpoint:"
                    font.pixelSize: root.fontSize
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: btn_send.height//endpoint.contentHeight * 1.5
                    radius: 5
                    border.width: 1

                    TextInput {
                        id: endpoint
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        font.pixelSize: root.fontSize
                        horizontalAlignment: Text.AlignHCenter
                        leftPadding: 10
                        rightPadding: leftPadding
                        clip: true
                        color: "blue"
                        text: root.endpointValue
                        font.family: "Courier New"
                    }
                }

                Button {
                    id: btn_send
                    text: "send"
                    font.pixelSize: root.fontSize
                    onClicked: {
                        if (folderModel.count === 0 || files.currentIndex === -1)
                        {
                            ta_mxnetOutput.append(
                                        "There are no files or nothing is selected" + "\n---"
                                        );
                            return;
                        }

                        progressBar.visible = true;
                        ta_mxnetOutput.append(
                                    "[" + getCurrentDateTime() + "] "
                                    + "Sending "
                                    + folderModel.get(files.currentIndex, "filePath")
                                    + "\n---"
                                    );
                        backend.uploadFile(
                                    endpoint.text,
                                    folderModel.get(files.currentIndex, "filePath")
                                    );
                    }
                }
            }

            Rectangle {
                id: progressBar
                anchors.fill: parent
                anchors.margins: 1
                color: root.backgroundColor
                ProgressBar {
                    anchors.fill: parent
                    indeterminate: true
                }
                visible: false
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.55
            Layout.margins: 10
            radius: 5

            ScrollView {
                anchors.fill: parent
                anchors.margins: 5

                TextArea {
                    id: ta_mxnetOutput
                    readOnly: true
                    font.pixelSize: root.fontSize
                    font.family: "Courier New"
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    selectByMouse: true
                }
            }
        }
    }

    function getCurrentDateTime()
    {
        return new Date().toISOString().replace("T", " ").replace("Z", "");
    }
}
