#include "UserModel.h"

#include <array>
#include <ranges>

namespace {

struct UserSeed {
    const char *name;
    UserEntry::Role role;
    UserEntry::Status status;
};

constexpr std::array kInitialUsers = {
    UserSeed{"Ana", UserEntry::Role::Admin, UserEntry::Status::Online},
    UserSeed{"Mihai", UserEntry::Role::Analyst, UserEntry::Status::Away},
    UserSeed{"Ioana", UserEntry::Role::Operator, UserEntry::Status::Online},
    UserSeed{"Dan", UserEntry::Role::Viewer, UserEntry::Status::Offline},
    UserSeed{"Elena", UserEntry::Role::Editor, UserEntry::Status::Online},
    UserSeed{"Radu", UserEntry::Role::Admin, UserEntry::Status::Busy},
};

QString roleText(UserEntry::Role role)
{
    switch (role) {
    case UserEntry::Role::Admin:
        return UserModel::tr("Admin");
    case UserEntry::Role::Analyst:
        return UserModel::tr("Analyst");
    case UserEntry::Role::Operator:
        return UserModel::tr("Operator");
    case UserEntry::Role::Viewer:
        return UserModel::tr("Viewer");
    case UserEntry::Role::Editor:
        return UserModel::tr("Editor");
    }

    return UserModel::tr("Unknown");
}

QString statusText(UserEntry::Status status)
{
    switch (status) {
    case UserEntry::Status::Online:
        return UserModel::tr("Online");
    case UserEntry::Status::Away:
        return UserModel::tr("Away");
    case UserEntry::Status::Offline:
        return UserModel::tr("Offline");
    case UserEntry::Status::Busy:
        return UserModel::tr("Busy");
    }

    return UserModel::tr("Unknown");
}

} // namespace

UserModel::UserModel(QObject *parent)
    : QAbstractListModel(parent)
{
    const auto users = kInitialUsers
                     | std::views::transform([](const UserSeed &seed) {
                           return UserEntry{QString::fromLatin1(seed.name), seed.role, seed.status};
                       });

    for (const UserEntry &entry : users)
        m_entries.append(entry);
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
    case RoleRole:   return roleText(e.role);
    case StatusRole: return statusText(e.status);
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
