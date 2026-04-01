#pragma once
#include <expected>
#include <QObject>
#include <QTimer>
#include <QVariantList>
#include <QVariantMap>
#include <QString>
#include "NotificationModel.h"
#include "UserModel.h"
#include "JobModel.h"

class Engine : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int workload       READ workload       NOTIFY workloadChanged)
    Q_PROPERTY(int activeUsers    READ activeUsers    NOTIFY activeUsersChanged)
    Q_PROPERTY(int alerts         READ alerts         NOTIFY alertsChanged)
    Q_PROPERTY(int cpuBudget      READ cpuBudget      WRITE setCpuBudget      NOTIFY cpuBudgetChanged)
    Q_PROPERTY(int memoryBudget   READ memoryBudget   WRITE setMemoryBudget   NOTIFY memoryBudgetChanged)
    Q_PROPERTY(bool autoRefresh   READ autoRefresh    WRITE setAutoRefresh    NOTIFY autoRefreshChanged)
    Q_PROPERTY(QString appVersion READ appVersion     CONSTANT)

    Q_PROPERTY(NotificationModel* notificationModel READ notificationModel CONSTANT)
    Q_PROPERTY(UserModel*         userModel          READ userModel          CONSTANT)
    Q_PROPERTY(JobModel*          jobModel            READ jobModel           CONSTANT)

public:
    explicit Engine(QObject *parent = nullptr);

    int     workload()     const { return m_workload; }
    int     activeUsers()  const { return m_activeUsers; }
    int     alerts()       const { return m_alerts; }
    int     cpuBudget()    const { return m_cpuBudget; }
    int     memoryBudget() const { return m_memoryBudget; }
    bool    autoRefresh()  const { return m_autoRefresh; }
    QString appVersion()   const { return QStringLiteral("1.0"); }

    NotificationModel* notificationModel() { return &m_notificationModel; }
    UserModel*         userModel()          { return &m_userModel; }
    JobModel*          jobModel()           { return &m_jobModel; }

    void setCpuBudget(int value);
    void setMemoryBudget(int value);
    void setAutoRefresh(bool value);

    Q_INVOKABLE void         postEvent(const QString &level, const QString &message);
    Q_INVOKABLE void         clearEvents();
    Q_INVOKABLE void         runJob(int index);
    Q_INVOKABLE void         resetSystem();
    Q_INVOKABLE bool         applyConfig(const QVariantMap &config);
    Q_INVOKABLE QVariantList weeklyStats() const;
    Q_INVOKABLE QVariantList trendData()   const;
    Q_INVOKABLE QString      exportReport() const;
    Q_INVOKABLE void         setLanguage(const QString &locale);

signals:
    void workloadChanged();
    void activeUsersChanged();
    void alertsChanged();
    void cpuBudgetChanged();
    void memoryBudgetChanged();
    void autoRefreshChanged();
    void languageChangeRequested(const QString &locale);

private slots:
    void onTick();

private:
    using ApplyConfigResult = std::expected<void, QString>;

    ApplyConfigResult applyConfigDetailed(const QVariantMap &config);

    int  m_workload    {42};
    int  m_activeUsers {18};
    int  m_alerts      {3};
    int  m_cpuBudget   {55};
    int  m_memoryBudget{68};
    bool m_autoRefresh {true};

    NotificationModel m_notificationModel;
    UserModel         m_userModel;
    JobModel          m_jobModel;

    QTimer m_timer;
};
