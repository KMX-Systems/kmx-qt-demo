#pragma once
#include <QAbstractListModel>
#include <QList>
#include <QString>

struct NotificationEntry {
    QString level;
    QString message;
    QString timestamp;
};

class NotificationModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        LevelRole = Qt::UserRole + 1,
        MessageRole,
        TimestampRole
    };
    Q_ENUM(Roles)

    explicit NotificationModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void append(const QString &level, const QString &message);
    Q_INVOKABLE void clear();

private:
    QList<NotificationEntry> m_entries;
};
