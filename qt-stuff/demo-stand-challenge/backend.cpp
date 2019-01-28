#include "backend.h"

Backend::Backend(QObject *parent) : QObject(parent)
{
    videoWrapper = new VideoWrapper();
    connect(
            videoWrapper, &VideoWrapper::gotNewShotBytes,
            this, &Backend::uploadBuffer
            );
    connect(
            videoWrapper, &VideoWrapper::gotNewFrame,
            this, [=](){ this->counterIncreased(); }
            );

    manager = new QNetworkAccessManager(this);
    connect(
            manager, &QNetworkAccessManager::finished,
            this, &Backend::requestFinished
            );

    // for debugging with HTTP proxy
    //QNetworkProxy proxy;
    //proxy.setType(QNetworkProxy::HttpProxy);
    //proxy.setHostName("localhost");
    //proxy.setPort(4321);
    //manager->setProxy(proxy);
}

void Backend::uploadBuffer(QBuffer *imgBuffer)
{
    //qDebug() << "uploading" << imgBuffer->size() << "bytes";
    QNetworkRequest request = QNetworkRequest(QUrl(_endpoint));
    request.setRawHeader("Content-Type", "multipart/form-data;");

    imgBuffer->open(QIODevice::ReadOnly);
    manager->post(request, imgBuffer);
    imgBuffer->close();
}

bool Backend::requestFinished(QNetworkReply *reply)
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
        return false;
    }

    emit requestDone(QString(data));
    return true;
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
