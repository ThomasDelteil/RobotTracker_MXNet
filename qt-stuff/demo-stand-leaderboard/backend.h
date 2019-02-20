#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlQueryModel>
#include <QSqlRecord>
#include <QVariant>
#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QTimer>
#include <QtHttpServer>
#include <QDebug>
#include "scores.h"

class Backend : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Scores *scores READ challengeScores CONSTANT)

public:
    explicit Backend(QObject *parent = nullptr);
    ~Backend();

signals:
    void countChanged(int cnt);

public slots:
    QStringList getAvailableDrivers();
    Scores *challengeScores();
    bool checkUserName(QString username);

private slots:
    void fetchDataFromDB();

private:
    QSqlDatabase _db;
    QString _dbFile;
    QSqlQueryModel _queryModel;
    Scores *_challengeScores;
    QTimer *_updateTimer;
    QHttpServer *_httpServer;
    const quint16 _port = 6547;
};

#endif // BACKEND_H
