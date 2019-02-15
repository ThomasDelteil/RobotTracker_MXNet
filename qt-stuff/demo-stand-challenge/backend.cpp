#include "backend.h"

Backend::Backend(QObject *parent) : QObject(parent)
{
    videoWrapper = new VideoWrapper();
    connect(
            videoWrapper, &VideoWrapper::gotNewShotBytes,
            this, &Backend::uploadPose
            );
    connect(
            videoWrapper, &VideoWrapper::gotNewFrame,
            this, [=](){ this->counterIncreased(); }
            );

    managerPose = new QNetworkAccessManager(this);
    connect(
            managerPose, &QNetworkAccessManager::finished,
            this, &Backend::requestPoseFinished
            );

    managerHand = new QNetworkAccessManager(this);
    connect(
            managerHand, &QNetworkAccessManager::finished,
            this, &Backend::requestHandFinished
            );

    // for debugging with HTTP proxy
    //QNetworkProxy proxy;
    //proxy.setType(QNetworkProxy::HttpProxy);
    //proxy.setHostName("localhost");
    //proxy.setPort(4321);
    //manager->setProxy(proxy);
}

void Backend::uploadPose(QBuffer *imgBuffer)
{
    //qDebug() << "uploading" << imgBuffer->size() << "bytes";
    QNetworkRequest request = QNetworkRequest(QUrl(_endpointPose));
    request.setRawHeader("Content-Type", "multipart/form-data;");

    imgBuffer->open(QIODevice::ReadOnly);
    managerPose->post(request, imgBuffer);
    //connect(reply, &QNetworkReply::finished, imgBuffer, &QBuffer::deleteLater);
}

void Backend::uploadHand(QBuffer *imgBuffer)
{
    //qDebug() << "uploading" << imgBuffer->size() << "bytes";
    QNetworkRequest request = QNetworkRequest(QUrl(_endpointPose));
    request.setRawHeader("Content-Type", "multipart/form-data;");

    imgBuffer->open(QIODevice::ReadOnly);
    managerHand->post(request, imgBuffer);
    //connect(reply, &QNetworkReply::finished, imgBuffer, &QBuffer::deleteLater);
}

void Backend::requestPoseFinished(QNetworkReply *reply)
{
    int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QByteArray data = reply->readAll();

    //qDebug() << status << "|" << data;

    if (status != 200)
    {
        QString errorMessage = QString(data);
        QNetworkReply::NetworkError err = reply->error();
        if (status == 0)
        {
            // dictionary: http://doc.qt.io/qt-5/qnetworkreply.html#NetworkError-enum
            errorMessage = QString("QNetworkReply::NetworkError code: %1").arg(QString::number(err));
        }
        emit requestFailed(QString("Code %1 | %2").arg(status).arg(errorMessage));
    }

    emit requestDone(QString(data));
}

void Backend::requestHandFinished(QNetworkReply *reply)
{
    int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QByteArray data = reply->readAll();

    //qDebug() << status << "|" << data;

    if (status != 200)
    {
        QString errorMessage = QString(data);
        QNetworkReply::NetworkError err = reply->error();
        if (status == 0)
        {
            // dictionary: http://doc.qt.io/qt-5/qnetworkreply.html#NetworkError-enum
            errorMessage = QString("QNetworkReply::NetworkError code: %1").arg(QString::number(err));
        }
        emit requestFailed(QString("Code %1 | %2").arg(status).arg(errorMessage));
    }

    emit requestDone(QString(data));
}

void Backend::set_currentProfile(QString profileName)
{
    _currentProfile = profileName;
}

QString Backend::get_currentProfile()
{
    return _currentProfile;
}

VideoWrapper *Backend::get_videoWrapper()
{
    return videoWrapper;
}

void Backend::enableSendingToMXNet(bool sendingEnabled)
{
    videoWrapper->enableSending(sendingEnabled);
}
