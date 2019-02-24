import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

Item {
    id: fnsh

    signal nextWindow(string windowName)

    Rectangle {
        anchors.fill: parent
        color: "#D1E1ED"

        //Fireworks { id: fireworks1; majorColor: "pink"; z: 1 }
        Salute { id: salute1; anchors.fill: parent; majorColor: "orangered" }
        Salute { id: salute2; anchors.fill: parent; majorColor: "green" }
        Salute { id: salute3; anchors.fill: parent; majorColor: "magenta" }
        Salute { id: salute4; anchors.fill: parent; majorColor: "blue" }

        Image {
            id: topShelf
            anchors.top: parent.top
            anchors.topMargin: 10
            width: parent.width
            source: "qrc:/img/books-03.png"
            fillMode: Image.PreserveAspectFit

            Image {
                id: trophy
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: topShelf.top
                height: parent.height
                source: "qrc:/img/trophy.png"
                fillMode: Image.PreserveAspectFit
                visible: false
                states: [
                    State {
                        name: "inPlace"
                        PropertyChanges { target: trophy; visible: true; }
                        AnchorChanges { target: trophy; anchors.bottom: topShelf.bottom }
                    }
                ]
                transitions: Transition {
                    AnchorAnimation { duration: 1000; easing.type: Easing.OutBounce }
                }
            }
        }

        Image {
            id: topShelfSelf
            anchors.top: topShelf.bottom
            width: parent.width
            source: "qrc:/img/shelf-13.png"
            fillMode: Image.PreserveAspectFit
        }

        Image {
            id: topShelfShadow
            anchors.top: topShelfSelf.bottom
            width: parent.width
            z: 1
            source: "qrc:/img/shadow-13.png"
            fillMode: Image.PreserveAspectFit
        }

        Rectangle {
            id: results
            anchors.top: topShelfSelf.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: floor.top
            width: parent.width * 0.6
            color: "white"
            visible: false
            //z: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                Text {
                    Layout.topMargin: parent.height * 0.03
                    font.family: typodermic.name
                    font.pointSize: calculateFontSize(results.width, 0.04)
                    color: "#43ADEE"
                    text: "CHALLENGE COMPLETED!"
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    id: grats
                    Layout.alignment: Qt.AlignHCenter
                    font.family: titillium.name
                    font.pointSize: calculateFontSize(results.width, 0.03)
                    font.bold: true
                    text: "Congratulations!"
                    visible: false
                }

                Row {
                    id: rank
                    Layout.alignment: Qt.AlignHCenter
                    visible: false

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: titillium.name
                        font.pointSize: calculateFontSize(results.width, 0.02)
                        text: "You've got the "
                    }
                    Text {
                        id: rankValue
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: titillium.name
                        font.pointSize: calculateFontSize(results.width, 0.02)
                        font.bold: true
                        text: "unknown"
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: titillium.name
                        font.pointSize: calculateFontSize(results.width, 0.02)
                        text: " rank"
                    }
                }
                Text {
                    id: fail
                    Layout.topMargin: -10
                    Layout.alignment: Qt.AlignHCenter
                    font.family: titillium.name
                    font.pointSize: calculateFontSize(results.width, 0.015)
                    font.italic: true
                    text: "...well, apparently something went wrong"
                    visible: false
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
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
    }

    Timer {
        id: step1
        interval: 500
        running: true
        onTriggered: {
            topShelf.source = "qrc:/img/books-13.png";
            step2.start();
        }
    }
    Timer {
        id: step2
        interval: 500
        running: true
        onTriggered: {
            topShelf.source = "qrc:/img/books-23.png";
            step3.start();
        }
    }
    Timer {
        id: step3
        interval: 500
        onTriggered: {
            topShelf.source = "qrc:/img/books-33.png";
            step4.start();
        }
    }
    Timer {
        id: step4
        interval: 500
        onTriggered: {
            topShelfSelf.source = "qrc:/img/shelf-33.png";
            topShelfShadow.source = "qrc:/img/shadow-33.png";
            trophy.state = "inPlace";
            step5.start();
        }
    }
    Timer {
        id: step5
        interval: 1000
        onTriggered: {
            results.visible = true;
            step6.start();
        }
    }
    Timer {
        id: step6
        interval: 500
        onTriggered: {
            fireworksTimer1.start();
            //fireworksTimer2.start();
            stopFireworks.start();
            grats.visible = true;
            step7.start();
        }
    }
    Timer {
        id: step7
        interval: 500
        onTriggered: {
            rank.visible = true;
            if (rankValue.text === "unknown") { stepFail.start(); }
            step8.start();
        }
    }
    Timer {
        id: stepFail
        interval: 500
        onTriggered: {
            fail.visible = true;
        }
    }

    Timer {
        id: step8
        interval: 15000
        onTriggered: {
            backend.set_currentProfile(0);
            backend.set_currentScore(0);
            nextWindow("welcome.qml");
        }
    }
    Timer {
        id: fireworksTimer1
        interval: 500
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            salute1.startingEmitter.pulse(20);
            salute2.startingEmitter.pulse(70);
            salute3.startingEmitter.pulse(30);
            salute4.startingEmitter.pulse(50);
        }
    }
    Timer {
        id: stopFireworks
        interval: 5000
        onTriggered: {
            fireworksTimer1.stop();
            //fireworksTimer2.stop();
        }
    }
//    Timer {
//        id: fireworksTimer2
//        interval: 2000
//        repeat: true
//        onTriggered: {
//            fireworks1.customEmit(Math.random() * results.width, Math.random() * results.height);
//            fireworks2.customEmit(Math.random() * results.width, Math.random() * results.height);
//            fireworks3.customEmit(Math.random() * results.width, Math.random() * results.height);
//        }
//    }

    Component.onCompleted: {
        request(
            "http://".concat(backend.dbServer(), "/rank/", backend.get_currentScore()),
            "GET",
            function (o)
            {
                if (o.status === 200)
                {
                    //console.log(o.responseText);
                    rankValue.text = "#".concat(o.responseText);
                }
            });
    }
}
