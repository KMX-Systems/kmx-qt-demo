#include "NotificationModel.h"
#include <QDateTime>

NotificationModel::NotificationModel(QObject *parent)
    : QAbstractListModel(parent)
{
    const QString ts = QDateTime::currentDateTime().toString("hh:mm:ss");
    m_entries = {
        {"Info",     "Sync completed",       ts},
        {"Warning",  "Cache nearing limit",  ts},
        {"Info",     "Snapshot created",     ts},
        {"Critical", "Service latency spike",ts},
    };
}

int NotificationModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return static_cast<int>(m_entries.size());
}

QVariant NotificationModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_entries.size())
        return {};
    const auto &e = m_entries.at(index.row());
    switch (role) {
    case LevelRole:     return e.level;
    case MessageRole:   return e.message;
    case TimestampRole: return e.timestamp;
    default:            return {};
    }
}

QHash<int, QByteArray> NotificationModel::roleNames() const
{
    return {
        {LevelRole,     "level"},
        {MessageRole,   "message"},
        {TimestampRole, "timestamp"},
    };
}

void NotificationModel::append(const QString &level, const QString &message)
{
    const int row = static_cast<int>(m_entries.size());
    beginInsertRows({}, row, row);
    m_entries.append({level, message, QDateTime::currentDateTime().toString("hh:mm:ss")});
    endInsertRows();
}

void NotificationModel::clear()
{
    beginResetModel();
    m_entries.clear();
    endResetModel();
}
