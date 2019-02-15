#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QHttpMultiPart>
#include <QNetworkProxy>
#include <QDebug>
#include "videowrapper.h"

class Backend : public QObject
{
    Q_OBJECT
public:
    explicit Backend(QObject *parent = nullptr);
    Q_PROPERTY(QObject *videoWrapper READ get_videoWrapper CONSTANT)
    Q_PROPERTY(bool connected MEMBER _connected NOTIFY connectedChanged)

signals:
    QString requestDone(QString result);
    QString requestFailed(QString error);
    void counterIncreased();
    void connectedChanged(bool connected);

public slots:
    void uploadPose(QBuffer *imgBuffer);
    void uploadHand(QBuffer *imgBuffer);

    void set_currentProfile(QString profileName);
    QString get_currentProfile();

    VideoWrapper *get_videoWrapper();

    void enableSendingToMXNet(bool sendingEnabled);

private slots:
    void requestPoseFinished(QNetworkReply *reply);
    void requestHandFinished(QNetworkReply *reply);

private:
    VideoWrapper *videoWrapper;
    QNetworkAccessManager *managerPose;
    QNetworkAccessManager *managerHand;
    QString _endpointPose = "http://localhost:8080/predictions/pose";
    QString _endpointHand = "http://localhost:8080/predictions/hand";
    QString _currentProfile;
    bool _connected = false;
};

#endif // BACKEND_H
