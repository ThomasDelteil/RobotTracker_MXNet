import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

Item {
    signal nextWindow(string windowName)

    RowLayout {
        anchors.fill: parent

        Item {
            Layout.preferredWidth: parent.width * 0.3
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 20

                Image {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignLeft
                    verticalAlignment: Image.AlignTop
                    source: "qrc:/img/bookshelf-left.png"
                }

                Image {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: 10
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignLeft
                    verticalAlignment: Image.AlignBottom
                    source: "qrc:/img/robot-left.png"
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Image {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: parent.height * 0.8
                //fillMode: Image.PreserveAspectFit
                verticalAlignment: Image.AlignTop
                source: "qrc:/img/welcome-background.png"

                ColumnLayout {
                    id: formLayout
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.85
                    height: parent.height
                    clip: true
                    //spacing: 0

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        color: root.primaryColor
                        font.family: typodermic.name
                        font.pointSize: root.calculateFontSize(formLayout.width, 0.06)
                        text: "THE GREAT"
                    }
                    Text {
                        Layout.topMargin: -10
                        Layout.alignment: Qt.AlignHCenter
                        color: root.primaryColor
                        font.family: typodermic.name
                        font.pointSize: root.calculateFontSize(formLayout.width, 0.04)
                        text: "robot arm challenge"
                    }

                    Text {
                        Layout.topMargin: parent.height * 0.01
                        Layout.alignment: Qt.AlignHCenter
                        font.pointSize: root.calculateFontSize(formLayout.width, 0.02)
                        font.family: titillium.name
                        font.bold: true
                        text: "How many books can you move in 5 minutes?"
                    }

                    Row {
                        Layout.topMargin: parent.height * 0.015
                        Layout.alignment: Qt.AlignHCenter
                        Text {
                            font.pointSize: root.calculateFontSize(formLayout.width, 0.02)
                            font.family: titillium.name
                            font.bold: true
                            color: root.primaryColor
                            text: "Highest score: "
                        }
                        Text {
                            id: topScore
                            font.pointSize: root.calculateFontSize(formLayout.width, 0.02)
                            font.family: titillium.name
                            font.bold: true
                            text: "0"
                        }
                    }
                    Row {
                        Layout.topMargin: -10//parent.height * 0.01
                        Layout.alignment: Qt.AlignHCenter

                        Text {
                            color: root.primaryColor
                            font.pointSize: root.calculateFontSize(formLayout.width, 0.02)
                            font.family: titillium.name
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            text: "by "
                        }
                        Text {
                            id: topUser
                            font.pointSize: root.calculateFontSize(formLayout.width, 0.02)
                            font.family: titillium.name
                            font.bold: true
                            // TODO figure out how to set the width and keep the alignment
                            elide: Text.ElideRight
                            text: "unknown"
                        }
                    }

                    Text {
                        Layout.topMargin: parent.height * 0.015
                        Layout.alignment: Qt.AlignHCenter
                        font.pointSize: root.calculateFontSize(formLayout.width, 0.02)
                        font.family: titillium.name
                        text: "Register with your name/nickname to play!"
                    }

                    Rectangle {
                        Layout.topMargin: parent.height * 0.005
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: parent.width * 0.8
                        Layout.preferredHeight: text_username.height * 1.5
                        border.width: 1

                        TextInput {
                            id: text_username
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            font.pointSize: root.calculateFontSize(formLayout.width, 0.02)
                            horizontalAlignment: Text.AlignHCenter
                            leftPadding: 10
                            rightPadding: leftPadding
                            clip: true
                            color: root.primaryColor
                            font.family: titilliumBold.name
                            font.bold: true
                            text: "veryqtperson"

                            onEditingFinished: {
                                // to get rid of virtual keyboard showing up before switching the view
                                checkbox_consent.forceActiveFocus();
                            }
                        }
                    }

                    Item {
                        Layout.topMargin: parent.height * 0.01
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 10

                            ImageCheckbox {
                                id: checkbox_consent
                                width: txtAgree.height * 0.7

                                TapHandler {
                                    onTapped: {
                                        parent.checkState = !parent.checkState
                                    }
                                }
                            }

                            Text {
                                id: txtAgree
                                font.pointSize: root.calculateFontSize(formLayout.width, 0.02)
                                font.family: titilliumBold.name
                                text: "I agree to the terms"
                            }
                        }
                    }

                    ImageButton {
                        Layout.topMargin: parent.height * 0.015
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: parent.width * 0.7
                        Layout.preferredHeight: text_username.height * 1.5
                        //width: parent.width * 0.5
                        unpressedImage: "qrc:/img/button-terms.png"
                        pressedImage: "qrc:/img/button-terms-pressed.png"
                        unpressedColor: "#41CD52"
                        fillMode: Image.Stretch
                        text: "Read the terms"
                        onClicked: {
                            // TODO report the bug of overlapping tap handlers
                            btnRegister.tapEnabled = false;
                            dialogTerms.open();
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }

                ImageButton {
                    id: btnRegister
                    anchors.top: parent.bottom
                    anchors.topMargin: -height/2
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.5
                    enabled: checkbox_consent.checkState === true && text_username.text.length !== 0
                    unpressedImage: "qrc:/img/button-start.png"
                    text: "REGISTER"
                    onClicked: {
                        enabled = false;
                        text = "checking...";

                    request(
                        "http://".concat(backend.dbServer(), "/user/register/", text_username.text),
                        "POST",
                        function (o)
                        {
                            enabled = true;
                            text = "Register";

                            if (o.status === 200)
                            {
                                backend.set_currentProfile(0);

                                //console.log(o.responseText);
                                var jsn = JSON.parse(o.responseText);

                                if(jsn["userID"] === -1)
                                {
                                    dialogUserError.text = "Database connection error. Your results might not be saved. Continue?";
                                    dialogUserError.open();
                                }
                                else
                                {
                                    backend.set_currentProfile(jsn["userID"]);

                                    if (jsn["isNew"] === true)
                                    {
                                        registrationComplete();
                                    }
                                    else
                                    {
                                        dialogUserError.text = "There is already a user with this name. Your score will go to this user. Continue?";
                                        dialogUserError.open();
                                    }
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
            }
        }

        Item {
            Layout.preferredWidth: parent.width * 0.3
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 20

                Image {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignRight
                    verticalAlignment: Image.AlignTop
                    source: "qrc:/img/bookshelf-right.png"
                }

                Image {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.rightMargin: 10
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignRight
                    verticalAlignment: Image.AlignBottom
                    source: "qrc:/img/robot-right.png"
                }
            }
        }
    }

    Rectangle {
        id: floor
        anchors.bottom: parent.bottom
        width: parent.width
        height: parent.height * 0.025
        color: "#B17F4A"
    }

    Dialog {
        id: dialogUserError
        x: (parent.width - width) / 2
        y: 0
        modal: true
        width: 400
        height: 250
        standardButtons: Dialog.Ok | Dialog.Cancel

        property alias text: dialogText.text

        title: "User registration"

        Item {
            anchors.fill: parent

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
        width: parent.width * 0.8
        height: parent.height * 0.6

        background: Image {
            id: termsBackground
            fillMode: Image.PreserveAspectFit
            source: "qrc:/img/terms-background.png"
        }

        Item {
            anchors.centerIn: parent
            width: termsBackground.paintedWidth - 70
            height: termsBackground.paintedHeight - 70

            ColumnLayout {
                anchors.fill: parent

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "TERMS AND CONDITIONS"
                    font.family: typodermic.name
                    font.pointSize: root.calculateFontSize(termsBackground.paintedWidth, 0.02)
                    color: "#63ADE8"
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: parent.height * 0.05

                    TextArea {
                        id: termsText
                        readOnly: true
                        font.pointSize: root.calculateFontSize(termsBackground.paintedWidth, 0.01)
                        text: "".concat(
                                  "Hereby you agree that this challenge will collect ",
                                  "the entered user/nick name and the corresponding score ",
                                  "being shown on the leaderboard to the public during ",
                                  "the event. After the event, nicknames and score ",
                                  "will be deleted.\n\n",
                                  "Furthermore, the Qt Company and AWS are not liable ",
                                  "with regards self-hurting movements, embarrassing ",
                                  "behaviour or alike."
                                  )
                        wrapMode: Text.WordWrap
                    }
                }
            }

            ImageButton {
                anchors.top: parent.bottom
                anchors.topMargin: -5
                anchors.horizontalCenter: parent.horizontalCenter
                height: parent.height * 0.2
                unpressedImage: "qrc:/img/button-start.png"
                text: "CLOSE"
                onClicked: {
                    dialogTerms.close();
                }
            }
        }

        onClosed: {
            btnRegister.tapEnabled = true;
        }
    }

    function registrationComplete()
    {
        //console.log(backend.get_currentProfile());
        nextWindow("challenge.qml");
    }

    Component.onCompleted: {
        request(
            "http://".concat(backend.dbServer(), "/top"),
            "GET",
            function (o)
            {
                if (o.status === 200)
                {
                    //console.log(o.responseText);
                    var jsn = JSON.parse(o.responseText);
                    var topUserName = jsn["userName"];
                    if (topUserName.length > 30)
                    { topUser.text = topUserName.substring(0, 30); }
                    else  { topUser.text = topUserName; }
                    topScore.text = jsn["score"];
                }
            });
    }
}
