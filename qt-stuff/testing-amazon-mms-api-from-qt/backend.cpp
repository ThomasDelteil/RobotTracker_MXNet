#include "backend.h"

Backend::Backend(QObject *parent) : QObject(parent)
{
    manager = new QNetworkAccessManager(this);
    connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(requestFinished(QNetworkReply*)));
}

void Backend::uploadFile(QString endpoint, QString fpath)
{
    QFile *file = new QFile(fpath);
    file->open(QIODevice::ReadOnly);

    QNetworkRequest request = QNetworkRequest(QUrl(endpoint));
    request.setRawHeader("Content-Type", "multipart/form-data;");

    manager->post(request, file);
}

void Backend::requestFinished(QNetworkReply *reply)
{
    int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QByteArray data = reply->readAll();

    //qDebug() << status << "|" << data;

    if (status != 200)
    {
        emit requestFailed(QString("Code %1: %2").arg(status).arg(QString(data)));
    }

    emit requestDone(QString(data));
}
