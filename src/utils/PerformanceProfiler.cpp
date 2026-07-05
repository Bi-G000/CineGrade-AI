#include "utils/PerformanceProfiler.h"

#include "utils/Logger.h"

namespace CineGrade
{

PerformanceProfiler& PerformanceProfiler::Instance()
{
    static PerformanceProfiler instance;
    return instance;
}

void PerformanceProfiler::Begin(const std::string& section)
{
    m_startTimes[section] = Clock::now();
}

void PerformanceProfiler::End(const std::string& section)
{
    auto it = m_startTimes.find(section);

    if (it == m_startTimes.end())
    {
        Logger::Instance().Warning(
            "PerformanceProfiler::End() called before Begin(): " + section);
        return;
    }

    const auto endTime = Clock::now();

    const auto elapsed =
        std::chrono::duration_cast<std::chrono::microseconds>(
            endTime - it->second);

    Logger::Instance().Debug(
        "[PROFILE] " + section +
        " : " +
        std::to_string(elapsed.count()) +
        " us");

    m_startTimes.erase(it);
}

void PerformanceProfiler::Reset()
{
    m_startTimes.clear();
}

}
