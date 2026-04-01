#include "Engine.h"
#include <algorithm>
#include <array>
#include <expected>
#include <format>
#include <iterator>
#include <optional>
#include <ranges>
#include <string>
#include <string_view>
#include <QDateTime>
#include <QRandomGenerator>

namespace {
using ParsedBudget = std::expected<std::optional<int>, QString>;

constexpr int kMinBudget = 0;
constexpr int kMaxBudget = 100;
constexpr int kResetWorkload = 20;
constexpr int kResetAlerts = 1;
constexpr int kResetActiveUsers = 18;

constexpr std::array<std::string_view, 5> kWeekDays{"Mon", "Tue", "Wed", "Thu", "Fri"};
constexpr std::array<int, 5> kWeeklyReads{12, 22, 33, 46, 58};
constexpr std::array<int, 5> kWeeklyWrites{9, 18, 21, 37, 49};

constexpr std::array<int, 6> kTrendABase{18, 26, 39, 44, 50, 62};
constexpr std::array<int, 6> kTrendBBase{12, 22, 28, 35, 47, 53};

template <typename T, std::size_t N>
consteval std::size_t arraySize(const std::array<T, N> &)
{
    return N;
}

static_assert(arraySize(kWeekDays) == arraySize(kWeeklyReads));
static_assert(arraySize(kWeekDays) == arraySize(kWeeklyWrites));

QString toQString(std::string_view text)
{
    return QString::fromLatin1(text.data(), static_cast<int>(text.size()));
}

ParsedBudget parseBudget(const QVariantMap &config, QStringView key)
{
    const QString keyString = key.toString();
    if (!config.contains(keyString))
        return std::optional<int>{};

    bool ok = false;
    const int value = config.value(keyString).toInt(&ok);
    if (!ok)
        return std::unexpected(QObject::tr("%1 must be numeric").arg(keyString));

    if (value < kMinBudget || value > kMaxBudget) {
        return std::unexpected(
            QObject::tr("%1 must be between %2 and %3")
                .arg(keyString)
                .arg(kMinBudget)
                .arg(kMaxBudget));
    }

    return value;
}
} // namespace

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
    m_workload = kResetWorkload;
    m_alerts = kResetAlerts;
    m_activeUsers = kResetActiveUsers;
    emit workloadChanged();
    emit alertsChanged();
    emit activeUsersChanged();
    const auto timestamp = QDateTime::currentDateTime().toString(QStringLiteral("hh:mm:ss")).toStdString();
    postEvent(QStringLiteral("Info"),
              QString::fromStdString(std::format("System reset at {}", timestamp)));
}

void Engine::setLanguage(const QString &locale)
{
    emit languageChangeRequested(locale);
}

bool Engine::applyConfig(const QVariantMap &config)
{
    const auto applyResult = applyConfigDetailed(config);
    if (!applyResult) {
        postEvent(QStringLiteral("Warning"), applyResult.error());
        return false;
    }

    const auto timestamp = QDateTime::currentDateTime().toString(QStringLiteral("hh:mm:ss")).toStdString();
    postEvent(QStringLiteral("Info"),
              QString::fromStdString(std::format("Config applied at {}", timestamp)));
    return true;
}

Engine::ApplyConfigResult Engine::applyConfigDetailed(const QVariantMap &config)
{
    const auto cpuBudget = parseBudget(config, QStringLiteral("cpuBudget"));
    if (!cpuBudget)
        return std::unexpected(cpuBudget.error());

    const auto memoryBudget = parseBudget(config, QStringLiteral("memoryBudget"));
    if (!memoryBudget)
        return std::unexpected(memoryBudget.error());

    if (cpuBudget.value().has_value())
        setCpuBudget(*cpuBudget.value());
    if (memoryBudget.value().has_value())
        setMemoryBudget(*memoryBudget.value());

    return {};
}

QVariantList Engine::weeklyStats() const
{
    QVariantList result;
    result.reserve(static_cast<qsizetype>(kWeekDays.size()));

    const auto rows = std::views::iota(std::size_t{0}, kWeekDays.size())
        | std::views::transform([](std::size_t index) {
              QVariantMap entry;
              entry[QStringLiteral("day")] = toQString(kWeekDays[index]);
              entry[QStringLiteral("read")] = kWeeklyReads[index];
              entry[QStringLiteral("write")] = kWeeklyWrites[index];
              return entry;
          });

    for (QVariantMap entry : rows)
        result.append(entry);

    return result;
}

QVariantList Engine::trendData() const
{
    auto toVariantList = [](const auto &values) {
        QVariantList output;
        output.reserve(static_cast<qsizetype>(std::ranges::size(values)));
        std::ranges::transform(values, std::back_inserter(output), [](int value) {
            return QVariant{value};
        });
        return output;
    };

    std::array<int, kTrendABase.size() + 1> seriesA{};
    std::ranges::copy(kTrendABase, seriesA.begin());
    seriesA.back() = m_workload;

    std::array<int, kTrendBBase.size() + 1> seriesB{};
    std::ranges::copy(kTrendBBase, seriesB.begin());
    seriesB.back() = std::max(10, m_workload - 8);

    return {toVariantList(seriesA), toVariantList(seriesB)};
}

QString Engine::exportReport() const
{
    const auto timestamp = QDateTime::currentDateTime().toString(QStringLiteral("hh:mm:ss")).toStdString();
    const auto report = std::format(
        "[{}] System Report\n"
        "  Workload:      {}%\n"
        "  Active users:  {}\n"
        "  Alerts:        {}\n"
        "  CPU budget:    {}%\n"
        "  Memory budget: {}%\n"
        "  Auto-refresh:  {}\n",
        timestamp,
        m_workload,
        m_activeUsers,
        m_alerts,
        m_cpuBudget,
        m_memoryBudget,
        m_autoRefresh ? "on" : "off");

    return QString::fromStdString(report);
}
