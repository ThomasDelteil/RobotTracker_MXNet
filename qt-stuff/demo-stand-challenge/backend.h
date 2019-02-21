#ifndef BACKEND_H
#define BACKEND_H

#include "videowrapper.h"
#include <QDebug>
#include <QHttpMultiPart>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QNetworkProxy>
#include <QNetworkReply>
#include <QObject>
#include <QQmlExtensionPlugin>
#include <QQuickImageProvider>
#include <QUuid>

class Backend;

class PalmImageProvider : public QObject, public QQuickImageProvider {
    Q_OBJECT

    Q_PROPERTY(Backend* backend MEMBER _backend)

public:
    PalmImageProvider(QObject* parent = nullptr)
        : QObject(parent)
        , QQuickImageProvider(QQuickImageProvider::Image)
    {
    }

    virtual QImage requestImage(const QString& id, QSize* size, const QSize& requestedSize) override;

private:
    Backend* _backend = nullptr;
};

class Backend : public QObject {
    Q_OBJECT

    Q_PROPERTY(QObject* videoWrapper READ get_videoWrapper CONSTANT)
    Q_PROPERTY(bool connected MEMBER _connected NOTIFY connectedChanged)
    Q_PROPERTY(QImage leftPalm MEMBER _leftPalm READ leftPalm NOTIFY leftPalmChanged)
    Q_PROPERTY(QImage rightPalm MEMBER _rightPalm READ rightPalm NOTIFY rightPalmChanged)
    Q_PROPERTY(int cropRegionWidth READ cropRegionWidth CONSTANT)
    Q_PROPERTY(QSize frameSize READ frameSize WRITE setFrameSize NOTIFY frameSizeChanged)

public:
    explicit Backend(QObject* parent = nullptr);
    ~Backend();

signals:
    QString requestPoseDone(QString result);
    QString requestLeftHandDone(QString result);
    QString requestRightHandDone(QString result);
    QString requestFailed(QString error);
    void counterIncreased();
    void connectedChanged(bool connected);
    void leftPalmChanged();
    void rightPalmChanged();
    void frameSizeChanged();

public slots:
    void uploadPose(QImage img);
    void uploadHand(QImage img, bool isRight);

    void set_currentProfile(int id);
    int get_currentProfile();

    VideoWrapper* get_videoWrapper();

    QSize frameSize() const;
    void setFrameSize(QSize size);

    int cropRegionWidth() const;

    void enableSendingToMXNet(bool sendingEnabled);

    QString dbServer();

    QImage leftPalm() const { return _leftPalm; }
    QImage rightPalm() const { return _rightPalm; }


private slots:
    void requestPoseFinished(QNetworkReply* reply);
    void requestHandFinished(QNetworkReply* reply);
    QImage cropPalmRegion(QImage originalFrame, QVariantMap elbow, QVariantMap wrist);
    void setLeftPalm(QImage palm);
    void setRightPalm(QImage palm);

    bool predictPalm(bool isOpen);

private:
    VideoWrapper* videoWrapper;
    QNetworkAccessManager* managerPose;
    QNetworkAccessManager* managerHand;
    const QString _endpointPose = "http://localhost:8080/predictions/pose";
    const QString _endpointHand = "http://localhost:8080/predictions/hand";
    int _currentProfile;
    bool _connected = false;
    QHash<QByteArray, QImage> _frames;
    // frame size for the camera's resolution
    QSize _frameSize = QSize(640, 480);
    // frame width for the camera's resolution
    const int _frameWidth = 640;//2592
    // frame height for the camera's resolution
    const int _frameHeight = 480;//1944
    // crop region width (and height) for the palms crop regions
    const int _cropRegionWidth = 130;
    const QString _dbServerHost = "localhost";
    const quint16 _dbServerPort = 6547;
    QImage _leftPalm;
    QImage _rightPalm;
    QList<bool> _lastPalmPredictions;
    const int _lastPalmPredictionsCount = 5;
};

#endif // BACKEND_H
