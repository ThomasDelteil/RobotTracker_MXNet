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
//            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 70
            Layout.leftMargin: parent.width / 8
            Layout.rightMargin: parent.width / 8
            spacing: 15

            Text {
                text: "Your e-mail:"
                //horizontalAlignment: Text.AlignRight
                font.pointSize: root.primaryFontSize
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: text_email.height * 2
                radius: 5
                border.width: 1

                TextInput {
                    id: text_email
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    font.pointSize: root.primaryFontSize
                    //horizontalAlignment: Text.AlignHCenter
                    leftPadding: 10
                    rightPadding: leftPadding
                    clip: true
                    color: "blue"
                    text: "some@example.org"
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
            enabled: checkbox_consent.checkState == 2
            onClicked: {
                if (root.checkEmail(text_email.text))
                {
                    // TODO actually create the profile (new record in DB and whatnot)
                    backend.set_currentProfile(text_email.text);
                    nextWindow("challenge.qml");
                }
                else
                {
                    dialogError.textMain = "That is not a correct e-mail address.\n...Or not a valid RegExp, oopsie!";
                    dialogError.show();
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

    }
}
