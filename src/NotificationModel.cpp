#include "NotificationModel.h"
#include <array>
#include <expected>
#include <format>
#include <ranges>
#include <string_view>
#include <QDateTime>

namespace {
using ValidEntry = std::expected<NotificationEntry, QString>;

constexpr std::array<std::pair<std::string_view, std::string_view>, 4> kSeedEntries{{
    {"Info", "Sync completed"},
    {"Warning", "Cache nearing limit"},
    {"Info", "Snapshot created"},
    {"Critical", "Service latency spike"},
}};

QString currentTimestamp()
{
    return QDateTime::currentDateTime().toString(QStringLiteral("hh:mm:ss"));
}

QString fromView(std::string_view text)
{
    return QString::fromLatin1(text.data(), static_cast<int>(text.size()));
}

ValidEntry validateNotification(const QString &level, const QString &message)
{
    if (level.trimmed().isEmpty())
        return std::unexpected(QObject::tr("Notification level must not be empty"));
    if (message.trimmed().isEmpty())
        return std::unexpected(QObject::tr("Notification message must not be empty"));

    return NotificationEntry{level, message, currentTimestamp()};
}
} // namespace

NotificationModel::NotificationModel(QObject *parent)
    : QAbstractListModel(parent)
{
    const QString ts = currentTimestamp();
    m_entries.reserve(static_cast<qsizetype>(kSeedEntries.size()));

    const auto entries = kSeedEntries
        | std::views::transform([&](const auto &seed) {
              return NotificationEntry{fromView(seed.first), fromView(seed.second), ts};
          });

    for (NotificationEntry entry : entries)
        m_entries.append(entry);
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
    const auto entry = validateNotification(level, message);
    NotificationEntry normalized;
    if (entry) {
        normalized = *entry;
    } else {
        normalized = {
            QStringLiteral("Warning"),
            QString::fromStdString(
                std::format("Invalid notification payload: {}", entry.error().toStdString())),
            currentTimestamp()};
    }

    const int row = static_cast<int>(m_entries.size());
    beginInsertRows({}, row, row);
    m_entries.append(normalized);
    endInsertRows();
}

void NotificationModel::clear()
{
    beginResetModel();
    m_entries.clear();
    endResetModel();
}
