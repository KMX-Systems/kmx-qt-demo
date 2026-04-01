#include "Engine.h"
#include <QDateTime>
#include <QRandomGenerator>

Engine::Engine(QObject *parent)
    : QObject(parent)
{
    connect(&m_timer, &QTimer::timeout, this, &Engine::onTick);
    m_timer.setInterval(1200);
    if (m_autoRefresh)
        m_timer.start();
}

void Engine::setCpuBudget(int value)
{
    if (m_cpuBudget == value) return;
    m_cpuBudget = value;
    emit cpuBudgetChanged();
}

void Engine::setMemoryBudget(int value)
{
    if (m_memoryBudget == value) return;
    m_memoryBudget = value;
    emit memoryBudgetChanged();
}

void Engine::setAutoRefresh(bool value)
{
    if (m_autoRefresh == value) return;
    m_autoRefresh = value;
    value ? m_timer.start() : m_timer.stop();
    emit autoRefreshChanged();
}

void Engine::onTick()
{
    m_workload    = (m_workload + 3) % 100;
    m_activeUsers = 10 + static_cast<int>(QRandomGenerator::global()->bounded(20u));
    m_alerts      = 1  + static_cast<int>(QRandomGenerator::global()->bounded(7u));
    emit workloadChanged();
    emit activeUsersChanged();
    emit alertsChanged();
    m_jobModel.updateProgress(m_workload);
}

void Engine::postEvent(const QString &level, const QString &message)
{
    m_notificationModel.append(level, message);
}

void Engine::clearEvents()
{
    m_notificationModel.clear();
}

void Engine::runJob(int index)
{
    m_jobModel.runJob(index);
}

void Engine::resetSystem()
{
    m_workload    = 20;
    m_alerts      = 1;
    m_activeUsers = 18;
    emit workloadChanged();
    emit alertsChanged();
    emit activeUsersChanged();
    postEvent(QStringLiteral("Info"),
              tr("System reset at %1")
                  .arg(QDateTime::currentDateTime().toString(QStringLiteral("hh:mm:ss"))));
}

void Engine::setLanguage(const QString &locale)
{
    emit languageChangeRequested(locale);
}

bool Engine::applyConfig(const QVariantMap &config)
{
    if (config.contains(QStringLiteral("cpuBudget"))) {
        const int v = config.value(QStringLiteral("cpuBudget")).toInt();
        if (v < 0 || v > 100) return false;
        setCpuBudget(v);
    }
    if (config.contains(QStringLiteral("memoryBudget"))) {
        const int v = config.value(QStringLiteral("memoryBudget")).toInt();
        if (v < 0 || v > 100) return false;
        setMemoryBudget(v);
    }
    postEvent(QStringLiteral("Info"),
              tr("Config applied at %1")
                  .arg(QDateTime::currentDateTime().toString(QStringLiteral("hh:mm:ss"))));
    return true;
}

QVariantList Engine::weeklyStats() const
{
    static const char* days[]   = {"Mon","Tue","Wed","Thu","Fri"};
    static const int   reads[]  = {12, 22, 33, 46, 58};
    static const int   writes[] = {9,  18, 21, 37, 49};
    QVariantList result;
    for (int i = 0; i < 5; ++i) {
        QVariantMap entry;
        entry[QStringLiteral("day")]   = QLatin1String(days[i]);
        entry[QStringLiteral("read")]  = reads[i];
        entry[QStringLiteral("write")] = writes[i];
        result.append(entry);
    }
    return result;
}

QVariantList Engine::trendData() const
{
    const int base = m_workload;
    const int a[]  = {18, 26, 39, 44, 50, 62, base};
    const int b[]  = {12, 22, 28, 35, 47, 53, std::max(10, base - 8)};
    QVariantList seriesA, seriesB;
    for (int v : a) seriesA.append(v);
    for (int v : b) seriesB.append(v);
    return {seriesA, seriesB};
}

QString Engine::exportReport() const
{
    return tr("[%1] System Report\n"
              "  Workload:      %2%\n"
              "  Active users:  %3\n"
              "  Alerts:        %4\n"
              "  CPU budget:    %5%\n"
              "  Memory budget: %6%\n"
              "  Auto-refresh:  %7\n")
        .arg(QDateTime::currentDateTime().toString(QStringLiteral("hh:mm:ss")))
        .arg(m_workload)
        .arg(m_activeUsers)
        .arg(m_alerts)
        .arg(m_cpuBudget)
        .arg(m_memoryBudget)
        .arg(m_autoRefresh ? tr("on") : tr("off"));
}
