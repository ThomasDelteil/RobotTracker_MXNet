#ifndef SCORES_H
#define SCORES_H

#include <QObject>
#include <QAbstractListModel>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlQueryModel>
#include <QSqlRecord>
#include <QVariant>
#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QDebug>

class Score
{
public:
    Score() {}
    Score(int positionVal, QString playerVal, int scoreVal);

    int position;
    QString player;
    int score;
};

class Scores: public QAbstractListModel
{
    Q_OBJECT

public:
    enum ScoresRoles {
        PositionRole = Qt::UserRole + 1,
        PlayerRole = Qt::UserRole + 2,
        ScoreRole = Qt::UserRole + 3
    };

    Scores(QObject *parent = nullptr);

public slots:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    void addScore(const Score score);
    void clear();
    QVector<Score> scores();

protected:
    QHash<int, QByteArray> roleNames() const override;

private:
    QVector<Score> _scores;
};

#endif // SCORES_H
