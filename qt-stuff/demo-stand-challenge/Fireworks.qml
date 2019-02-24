import QtQuick 2.12
import QtQuick.Particles 2.12

ParticleSystem {
    id: parentSystem

    property alias majorColor: imageParticle.color

    ImageParticle {
        id: imageParticle
        system: parentSystem
        source: "qrc:///particleresources/glowdot.png"
        color: "gold"
        colorVariation: 0.1
    }

    Component {
        id: emitterComp
        Emitter {
            id: container
            Emitter {
                id: emitMore
                system: parentSystem
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
            system: parentSystem
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
}
