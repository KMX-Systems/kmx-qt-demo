#pragma once
#include <QAbstractListModel>
#include <QList>
#include <QString>

struct JobEntry {
    enum class State {
        Idle,
        Running,
        Done
    };

    int     jobId;
    QString label;
    int     progress;   // 0–100
    State   state;
};

class JobModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        JobIdRole = Qt::UserRole + 1,
        LabelRole,
        ProgressRole,
        StatusTextRole
    };
    Q_ENUM(Roles)

    explicit JobModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void runJob(int index);
    void updateProgress(int workload); // driven by Engine timer

private:
    QList<JobEntry> m_jobs;
};
