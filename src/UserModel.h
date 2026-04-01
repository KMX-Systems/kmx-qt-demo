#pragma once
#include <QAbstractListModel>
#include <QList>
#include <QString>

struct UserEntry {
    QString name;
    QString role;
    QString status;
};

class UserModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        RoleRole,
        StatusRole
    };
    Q_ENUM(Roles)

    explicit UserModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

private:
    QList<UserEntry> m_entries;
};
