import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

Item {
    signal nextWindow(string windowName)

    ColumnLayout {
        anchors.fill: parent

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Greetings, challenger"
            font.pointSize: root.primaryFontSize * 2.5
            //font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 70
            Layout.leftMargin: parent.width / 8
            Layout.rightMargin: parent.width / 8
            spacing: 15

            Text {
                text: "Your nickname:"
                //horizontalAlignment: Text.AlignRight
                font.pointSize: root.primaryFontSize
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: text_username.height * 2
                radius: 5
                border.width: 1

                TextInput {
                    id: text_username
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    font.pointSize: root.primaryFontSize
                    //horizontalAlignment: Text.AlignHCenter
                    leftPadding: 10
                    rightPadding: leftPadding
                    clip: true
                    color: "blue"
                    text: "veryqtperson"
                    //font.family: "Courier New"
                }
            }
        }

        RowLayout {
            Layout.topMargin: 10
            Layout.alignment: Qt.AlignHCenter
            spacing: 0

            CheckBox {
                id: checkbox_consent

                text: "I agree to the terms"
                font.pointSize: root.secondaryFontSize
            }
            Text {
                id: txt_terms
                text: "(read the terms)"
                font.pointSize: root.secondaryFontSize
                color: "blue"
                font.italic: true

                TapHandler {
                    onTapped: dialogTerms.open();
                }
            }
        }

        FancyButton {
            text: "Register"
            Layout.topMargin: 20
            Layout.alignment: Qt.AlignHCenter
            font.pointSize: root.primaryFontSize
            enabled: checkbox_consent.checkState == 2 && text_username.text.length !== 0
            onClicked: {
                enabled = false;
                text = "checking...";

                request("http://".concat(backend.dbServer(), "/user/exists/", text_username.text), function (o)
                {
                    enabled = true;
                    text = "Register";

                    if (o.status === 200)
                    {
                        if (o.responseText === "0")
                        {
                            registrationComplete();
                        }
                        else
                        {
                            dialogUserError.text = "There is already a user with this name. Your score will go to this user. Continue?";
                            dialogUserError.open();
                        }
                    }
                    else
                    {
                        dialogUserError.text = "Database connection error. Your results might not be saved. Continue?";
                        dialogUserError.open();
                    }
                });
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

    }

    Dialog {
        id: dialogUserError
        x: (parent.width - width) / 2
        y: 0
        width: 400
        height: 250
        standardButtons: Dialog.Ok | Dialog.Cancel

        property alias text: dialogText.text

        title: "User registration"

        Rectangle {
            anchors.fill: parent
            //color: Styles.regionBackground
            //border.color: Styles.mainBackground
            //border.width: 3

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    //Layout.topMargin: 10
                    //Layout.leftMargin: 15
                    //Layout.rightMargin: 15

                    TextArea {
                        id: dialogText
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: dialogUserError.text
                        font.family: "Courier New"
                        font.pointSize: root.secondaryFontSize
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        onAccepted: {
            registrationComplete();
        }
    }

    Dialog {
        id: dialogTerms
        anchors.centerIn: parent
        modal: true
        title: "Terms and conditions"
        width: parent.width * 0.6
        height: parent.height * 0.4

        ColumnLayout {
            anchors.fill: parent

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                TextArea {
                    font.pointSize: root.secondaryFontSize
                    text: "We can do whatever and you can't do anything. We can do whatever and you can't do anything. We can do whatever and you can't do anything. We can do whatever and you can't do anything. We can do whatever and you can't do anything. We can do whatever and you can't do anything. We can do whatever and you can't do anything. We can do whatever and you can't do anything."
                    wrapMode: Text.WordWrap
                }
            }

            Button {
                Layout.alignment: Qt.AlignRight
                text: "Okay, Google"
                onClicked: {
                    dialogTerms.close();
                }
            }
        }
    }

    function registrationComplete()
    {
        backend.set_currentProfile(text_username.text);
        nextWindow("challenge.qml");
    }
}
