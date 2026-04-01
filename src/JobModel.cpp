#include "JobModel.h"
#include <algorithm>

JobModel::JobModel(QObject *parent)
    : QAbstractListModel(parent)
{
    for (int i = 0; i < 10; ++i) {
        m_jobs.append({i + 1,
                       QStringLiteral("Job #%1").arg(i + 1),
                       (i * 9 + 42) % 100,
                       QStringLiteral("Idle")});
    }
}

int JobModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return static_cast<int>(m_jobs.size());
}

QVariant JobModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_jobs.size())
        return {};
    const auto &j = m_jobs.at(index.row());
    switch (role) {
    case JobIdRole:      return j.jobId;
    case LabelRole:      return j.label;
    case ProgressRole:   return j.progress;
    case StatusTextRole: return j.statusText;
    default:             return {};
    }
}

QHash<int, QByteArray> JobModel::roleNames() const
{
    return {
        {JobIdRole,      "jobId"},
        {LabelRole,      "label"},
        {ProgressRole,   "progress"},
        {StatusTextRole, "statusText"},
    };
}

void JobModel::runJob(int index)
{
    if (index < 0 || index >= m_jobs.size())
        return;
    auto &j = m_jobs[index];
    j.statusText = QStringLiteral("Running");
    j.progress   = std::min(j.progress + 15, 100);
    if (j.progress >= 100)
        j.statusText = QStringLiteral("Done");
    const QModelIndex idx = createIndex(index, 0);
    emit dataChanged(idx, idx, {ProgressRole, StatusTextRole});
}

void JobModel::updateProgress(int workload)
{
    for (int i = 0; i < m_jobs.size(); ++i) {
        auto &j = m_jobs[i];
        if (j.statusText == QLatin1String("Running")) {
            j.progress = std::min(j.progress + 2, 100);
            if (j.progress >= 100)
                j.statusText = QStringLiteral("Done");
            const QModelIndex idx = createIndex(i, 0);
            emit dataChanged(idx, idx, {ProgressRole, StatusTextRole});
        } else if (j.statusText == QLatin1String("Idle")) {
            j.progress = (i * 9 + workload) % 100;
            const QModelIndex idx = createIndex(i, 0);
            emit dataChanged(idx, idx, {ProgressRole});
        }
    }
}
