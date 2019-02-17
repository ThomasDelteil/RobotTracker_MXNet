#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QHttpMultiPart>
#include <QNetworkProxy>
#include <QUuid>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>
#include "videowrapper.h"

class Backend : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QObject *videoWrapper READ get_videoWrapper CONSTANT)
    Q_PROPERTY(bool connected MEMBER _connected NOTIFY connectedChanged)

public:
    explicit Backend(QObject *parent = nullptr);
    ~Backend();

signals:
    QString requestPoseDone(QString result);
    QString requestLeftHandDone(QString result);
    QString requestRightHandDone(QString result);
    QString requestFailed(QString error);
    void counterIncreased();
    void connectedChanged(bool connected);

public slots:
    void uploadPose(QImage img);
    void uploadHand(QImage img, bool isRight);

    void set_currentProfile(QString profileName);
    QString get_currentProfile();

    VideoWrapper *get_videoWrapper();

    int frameWidth() const;
    int frameHeight() const;
    int cropRegionWidth() const;

    void enableSendingToMXNet(bool sendingEnabled);

    QString dbServer();

private slots:
    void requestPoseFinished(QNetworkReply *reply);
    void requestHandFinished(QNetworkReply *reply);
    QImage cropPalmRegion(QImage originalFrame, QVariantMap elbow, QVariantMap wrist);

private:
    VideoWrapper *videoWrapper;
    QNetworkAccessManager *managerPose;
    QNetworkAccessManager *managerHand;
    const QString _endpointPose = "http://localhost:8080/predictions/pose";
    const QString _endpointHand = "http://localhost:8080/predictions/hand";
    QString _currentProfile;
    bool _connected = false;
    QHash<QByteArray, QImage> _frames;
    // frame width for the camera's resolution
    const int _frameWidth = 640;
    // frame height for the camera's resolution
    const int _frameHeight = 480;
    // crop region width (and height) for the palms crop regions
    const int _cropRegionWidth = 130;
    const QString _dbServerHost = "localhost";
    const quint16 _dbServerPort = 6547;
};

#endif // BACKEND_H
