#include "UserModel.h"

UserModel::UserModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_entries = {
        {"Ana",   "Admin",    "Online"},
        {"Mihai", "Analyst",  "Away"},
        {"Ioana", "Operator", "Online"},
        {"Dan",   "Viewer",   "Offline"},
        {"Elena", "Editor",   "Online"},
        {"Radu",  "Admin",    "Busy"},
    };
}

int UserModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return static_cast<int>(m_entries.size());
}

QVariant UserModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_entries.size())
        return {};
    const auto &e = m_entries.at(index.row());
    switch (role) {
    case NameRole:   return e.name;
    case RoleRole:   return e.role;
    case StatusRole: return e.status;
    default:         return {};
    }
}

QHash<int, QByteArray> UserModel::roleNames() const
{
    return {
        {NameRole,   "name"},
        {RoleRole,   "role"},
        {StatusRole, "status"},
    };
}
