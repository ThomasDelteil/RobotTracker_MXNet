#include "backend.h"

Backend::Backend(QObject *parent) : QObject(parent)
{
    manager = new QNetworkAccessManager(this);
    connect(
            manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(requestFinished(QNetworkReply*))
            );
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
        QString errorMessage = QString(data);
        QNetworkReply::NetworkError err = reply->error();
        if (err != QNetworkReply::NoError)
        {
            // dictionary: http://doc.qt.io/qt-5/qnetworkreply.html#NetworkError-enum
            errorMessage = QString("QNetworkReply::NetworkError code: %1").arg(QString::number(err));
        }
        emit requestFailed(QString("Code %1 | %2").arg(status).arg(errorMessage));
    }

    emit requestDone(QString(data));
}

// TODO signal errors
bool Backend::createFolder(QString folderName)
{
    if (!QDir().exists(folderName))
    {
        return QDir().mkdir(folderName);
    }
    return true;
}

bool Backend::deleteProfileFolder()
{
    return QDir(_currentProfilePath).removeRecursively();
}

void Backend::set_currentProfilePath(QString profilePath)
{
    _currentProfilePath = profilePath;
}

QString Backend::get_currentProfilePath()
{
    return _currentProfilePath;
}

void Backend::set_currentProfile(QString profileName)
{
    _currentProfile = profileName;
}

QString Backend::get_currentProfile()
{
    return _currentProfile;
}
