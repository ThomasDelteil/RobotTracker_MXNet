#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QHttpMultiPart>
#include <QDir>
#include <QFile>
#include <QDebug>

class Backend : public QObject
{
    Q_OBJECT
public:
    explicit Backend(QObject *parent = nullptr);

signals:
    QString requestDone(QString result);
    QString requestFailed(QString error);

public slots:
    void uploadFile(QString endpoint, QString fpath);
    bool createFolder(QString folderName);

private slots:
    void requestFinished(QNetworkReply *reply);

private:
    QNetworkAccessManager *manager;
};

#endif // BACKEND_H
