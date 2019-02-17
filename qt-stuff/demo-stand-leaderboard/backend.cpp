#include "backend.h"

Backend::Backend(QObject *parent) : QObject(parent)
{
    _challengeScores = new Scores(this);

    _updateTimer = new QTimer(this);
    connect(_updateTimer, &QTimer::timeout, this, &Backend::fetchDataFromDB);
    _updateTimer->start(2000);

    // --- database

    _dbFile = QDir(qApp->applicationDirPath()).filePath("leaderboard.db");
    if (QFileInfo::exists(_dbFile))
    {
        _db = QSqlDatabase::addDatabase("QSQLITE");
        _db.setDatabaseName(_dbFile);
        if (!_db.open())
        {
            qCritical() << QString("Error: couldn't open the database. %1")
                           .arg(_db.lastError().databaseText());
            exit(EXIT_FAILURE);
        }
        else
        {
            fetchDataFromDB();
        }
    }
    else
    {
        qCritical() << "Error: couldn't find the database file";
        exit(EXIT_FAILURE);
    }

    // --- server

    _httpServer = new QHttpServer();

    _httpServer->route("/", []()
    {
        return "Still alive";
    });

    _httpServer->route("/user/exists/", [](QString username)
    {
        // FIXME switch to using the method after it will get supported in QHttpServer
        //if (checkUserName(username)) { return "1"; }
        //{ return "0"; }

        QSqlQuery query;
        query.prepare("SELECT COUNT (*) AS cnt FROM users WHERE users.name == :username;");
        query.bindValue(":username", username);
        query.exec();

        query.first();
        if (query.value(0).toBool()) { return "1"; }
        else { return "0"; }
    });

    _httpServer->route("/user/saveScore/<var>/<var>", [](QString username, int score)
    {
        qDebug() << username << score;
        return "Not implemented yet";
    });

    if (_httpServer->listen(QHostAddress::Any, _port) == -1)
    {
        qWarning() << QString(
                        "Could not start the server, perhaps the port %1 is taken by some other service")
                        .arg(_port);
    }
    else
    {
        qDebug() << QString("Server has started, the port %1 is opened").arg(_port);
    }
}

Backend::~Backend()
{
    // perhaps, stop the server and something else
}

QStringList Backend::getAvailableDrivers()
{
    return QSqlDatabase::drivers();
}

Scores *Backend::challengeScores()
{
    return _challengeScores;
}

bool Backend::checkUserName(QString username)
{
    QSqlQuery query;
    query.prepare("SELECT COUNT (*) AS cnt FROM users WHERE users.name == :username;");
    query.bindValue(":username", username);
    query.exec();

    query.first();
    if (query.value(0).toBool()) { return true; }
    else { return false; }
}

void Backend::fetchDataFromDB()
{
    _challengeScores->clear();

    QSqlQueryModel _queryModel;
    _queryModel.setQuery(
                "SELECT u.name AS player, MAX(s.score) AS score "
                "FROM scores AS s JOIN users AS u "
                    "ON s.user_id = u.id "
                "GROUP BY u.name "
                "ORDER BY s.score DESC;"
                );
    for (int i = 0; i < _queryModel.rowCount(); i++)
    {
        Score score(
                i + 1,
                _queryModel.record(i).value("player").toString(),
                _queryModel.record(i).value("score").toInt()
                );
        //qDebug() << score.position << score.player << score.score;
        _challengeScores->addScore(score);
        //qDebug() << _challengeScores->rowCount();
    }
}
