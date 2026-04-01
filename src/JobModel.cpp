#include "JobModel.h"
#include <algorithm>
#include <expected>
#include <format>
#include <functional>
#include <ranges>
#include <QDebug>

namespace {
constexpr int kJobCount = 10;
constexpr int kInitialWorkload = 42;
constexpr int kRunIncrement = 15;
constexpr int kTickIncrement = 2;
constexpr int kProgressModuloFactor = 9;
constexpr int kMaxProgress = 100;

using JobRef = std::reference_wrapper<JobEntry>;
using FindJobResult = std::expected<JobRef, QString>;

QString stateText(JobEntry::State state)
{
    switch (state) {
    case JobEntry::State::Idle:
        return JobModel::tr("Idle");
    case JobEntry::State::Running:
        return JobModel::tr("Running");
    case JobEntry::State::Done:
        return JobModel::tr("Done");
    }

    return JobModel::tr("Unknown");
}

FindJobResult findJob(QList<JobEntry> &jobs, int index)
{
    if (index < 0 || index >= jobs.size()) {
        return std::unexpected(
            QString::fromStdString(std::format("Invalid job index: {}", index)));
    }

    return std::ref(jobs[index]);
}
} // namespace

JobModel::JobModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_jobs.reserve(kJobCount);

    const auto initialJobs = std::views::iota(0, kJobCount)
        | std::views::transform([](int i) {
              return JobEntry{
                  i + 1,
                  QString::fromStdString(std::format("Job #{}", i + 1)),
                  (i * kProgressModuloFactor + kInitialWorkload) % kMaxProgress,
                  JobEntry::State::Idle};
          });

    for (JobEntry entry : initialJobs)
        m_jobs.append(entry);
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
    case StatusTextRole: return stateText(j.state);
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
    const auto job = findJob(m_jobs, index);
    if (!job) {
        qWarning().noquote() << job.error();
        return;
    }

    auto &j = job->get();
    j.state = JobEntry::State::Running;
    j.progress = std::min(j.progress + kRunIncrement, kMaxProgress);
    if (j.progress >= kMaxProgress)
        j.state = JobEntry::State::Done;

    const QModelIndex idx = createIndex(index, 0);
    emit dataChanged(idx, idx, {ProgressRole, StatusTextRole});
}

void JobModel::updateProgress(int workload)
{
    for (int i : std::views::iota(0, m_jobs.size())) {
        auto &j = m_jobs[i];
        if (j.state == JobEntry::State::Running) {
            j.progress = std::min(j.progress + kTickIncrement, kMaxProgress);
            if (j.progress >= kMaxProgress)
                j.state = JobEntry::State::Done;
            const QModelIndex idx = createIndex(i, 0);
            emit dataChanged(idx, idx, {ProgressRole, StatusTextRole});
        } else if (j.state == JobEntry::State::Idle) {
            j.progress = (i * kProgressModuloFactor + workload) % kMaxProgress;
            const QModelIndex idx = createIndex(i, 0);
            emit dataChanged(idx, idx, {ProgressRole});
        }
    }
}
