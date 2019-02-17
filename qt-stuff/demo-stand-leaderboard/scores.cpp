#include "scores.h"

Score::Score(int positionVal, QString playerVal, int scoreVal)
{
    position = positionVal;
    player = playerVal;
    score = scoreVal;
}

Scores::Scores(QObject *parent) : QAbstractListModel(parent) { }

QHash<int, QByteArray> Scores::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[PositionRole] = "position";
    roles[PlayerRole] = "player";
    roles[ScoreRole] = "score";
    return roles;
}

int Scores::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return _scores.count();
}

QVariant Scores::data(const QModelIndex &index, int role) const
{
    if (!hasIndex(index.row(), index.column(), index.parent())) { return {}; }

    const Score item = _scores.at(index.row());

    switch (role)
    {
        case PositionRole: return item.position;
        case PlayerRole: return item.player;
        case ScoreRole: return item.score;
        default: return {};
    }
}

bool Scores::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!hasIndex(index.row(), index.column(), index.parent()) || !value.isValid())
    { return false; }

    Score item = _scores.at(index.row());
    switch (role)
    {
    case PositionRole:
        item.position = value.toInt();
        break;
    case PlayerRole:
        item.player = value.toString();
        break;
    case ScoreRole:
        item.score = value.toInt();
        break;
    default:
        return false;
    }

    emit dataChanged(index, index, { role });
    return true;
}

void Scores::addScore(const Score score)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    _scores << score;
    endInsertRows();
}

void Scores::clear()
{
    beginResetModel();
    _scores.clear();
    endResetModel();
}

QVector<Score> Scores::scores()
{
    return _scores;
}
