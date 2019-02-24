import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Particles 2.12

Item {
    id: fnsh

    signal nextWindow(string windowName)

    Rectangle {
        anchors.fill: parent
        color: "#D1E1ED"

        // --- fireworks

        ParticleSystem {
            id: randomFireworks
            z: 1

            ImageParticle {
                system: randomFireworks
                source: "qrc:///particleresources/glowdot.png"
                color: "gold"
                colorVariation: 0.2
            }

            Component {
                id: emitterComp
                Emitter {
                    id: container
                    Emitter {
                        id: emitMore
                        system: randomFireworks
                        emitRate: 128
                        lifeSpan: 600
                        size: 12
                        endSize: 8
                        velocity: AngleDirection { angleVariation: 360; magnitude: 60 }
                    }

                    property int life: 2600
                    property real targetX: 0
                    property real targetY: 0
                    function go() {
                        xAnim.start();
                        yAnim.start();
                        container.enabled = true
                    }
                    system: randomFireworks
                    emitRate: 32
                    lifeSpan: 600
                    size: 12
                    endSize: 8
                    NumberAnimation on x {
                        id: xAnim;
                        to: targetX
                        duration: life
                        running: false
                    }
                    NumberAnimation on y {
                        id: yAnim;
                        to: targetY
                        duration: life
                        running: false
                    }
                    Timer {
                        interval: life
                        running: true
                        onTriggered: container.destroy();
                    }
                }
            }
        }

        ParticleSystem {
            anchors.fill: parent

            ParticleGroup {
                name: "fire"
                duration: 1500
                durationVariation: 1500
                to: { "splode": 1 }
            }

            ParticleGroup {
                name: "splode"
                duration: 800
                to: { "dead": 1 }
                TrailEmitter {
                    group: "works"
                    emitRatePerParticle: 100
                    lifeSpan: 1000
                    maximumEmitted: 1200
                    size: 8
                    velocity: AngleDirection { angle: 270; angleVariation: 45; magnitude: 20; magnitudeVariation: 20; }
                    acceleration: PointDirection { y: 100; yVariation: 20 }
                }
            }

            ParticleGroup {
                name: "dead"
                duration: 1000
                Affector {
                    once: true
                    onAffected: worksEmitter.burst(400, x, y)
                }
            }

            Emitter {
                id: startingEmitter
                group: "fire"
                width: parent.width
                y: parent.height
                enabled: false
                emitRate: 80
                lifeSpan: 6000
                velocity: PointDirection { y: -100; }
                size: 16
            }

            Emitter {
                id: worksEmitter
                group: "works"
                enabled: false
                emitRate: 100
                lifeSpan: 3000
                maximumEmitted: 6400
                size: 8
                velocity: CumulativeDirection {
                    PointDirection { y: -100 }
                    AngleDirection {angleVariation: 360; magnitudeVariation: 80;}
                }
                acceleration: PointDirection { y: 100; yVariation: 20 }
            }

            ImageParticle {
                groups: ["works", "fire", "splode"]
                source: "qrc:///particleresources/glowdot.png"
                color: "lime"
                colorVariation: 0.6
            }
        }

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
            fireworks1.start();
            fireworks2.start();
            results.visible = true;
            step6.start();
        }
    }
    Timer {
        id: step6
        interval: 500
        onTriggered: {
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
        id: fireworks1
        interval: 500
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            startingEmitter.pulse(100);
        }
    }
    Timer {
        id: fireworks2
        interval: 2000
        repeat: true
        onTriggered: customEmit(Math.random() * results.width, Math.random() * results.height)
    }

    function customEmit(x, y)
    {
        for (var i = 0; i < 8; i++)
        {
            var obj = emitterComp.createObject(results);
            obj.x = x;
            obj.y = y;
            obj.targetX = Math.random() * 240 - 120 + obj.x;
            obj.targetY = Math.random() * 240 - 120 + obj.y;
            obj.life = Math.round(Math.random() * 2400) + 200;
            obj.emitRate = Math.round(Math.random() * 32) + 32;
            obj.go();
        }
    }

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
