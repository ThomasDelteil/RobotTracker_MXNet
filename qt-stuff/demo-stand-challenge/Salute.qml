import QtQuick 2.12
import QtQuick.Particles 2.12

ParticleSystem {
    property alias startingEmitter: startingEmitter
    property alias majorColor: imageParticle.color

    ParticleGroup {
        name: "fire"
        duration: 400
        durationVariation: 700
        to: { "splode": 1 }
    }

    ParticleGroup {
        name: "splode"
        duration: 600
        durationVariation: 900
        to: { "dead": 1 }
        TrailEmitter {
            group: "works"
            emitRatePerParticle: 100
            lifeSpan: 2000
            maximumEmitted: 1000
            size: 8
            velocity: AngleDirection { angle: 270; angleVariation: 45; magnitude: 20; magnitudeVariation: 20; }
            acceleration: PointDirection { y: 100; yVariation: 20 }
        }
    }

    ParticleGroup {
        name: "dead"
        duration: 500
        durationVariation: 800
        Affector {
            once: true
            onAffected: worksEmitter.burst(500, x, y)
        }
    }

    Emitter {
        id: startingEmitter
        group: "fire"
        width: parent.width
        y: parent.height
        enabled: false
        emitRate: 100
        lifeSpan: 3000
        maximumEmitted: 1000
        velocity: PointDirection { y: -100; }
        size: 16
    }

    Emitter {
        id: worksEmitter
        group: "works"
        enabled: false
        emitRate: 100
        lifeSpan: 3000
        maximumEmitted: 1000
        size: 8
        velocity: CumulativeDirection {
            PointDirection { y: -100 }
            AngleDirection {angleVariation: 360; magnitudeVariation: 150;}
        }
        acceleration: PointDirection { y: 100; yVariation: 20 }
    }

    ImageParticle {
        id: imageParticle
        groups: ["works", "fire", "splode"]
        source: "qrc:///particleresources/glowdot.png"
        color: "lime"
        colorVariation: 0.2
    }
}
