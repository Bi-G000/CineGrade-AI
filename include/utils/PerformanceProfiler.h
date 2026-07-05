#pragma once

#include <chrono>
#include <string>
#include <unordered_map>

namespace CineGrade
{

class PerformanceProfiler
{
public:
    static PerformanceProfiler& Instance();

    void Begin(const std::string& section);
    void End(const std::string& section);

    void Reset();

private:
    PerformanceProfiler() = default;
    ~PerformanceProfiler() = default;

    PerformanceProfiler(const PerformanceProfiler&) = delete;
    PerformanceProfiler& operator=(const PerformanceProfiler&) = delete;

private:
    using Clock = std::chrono::high_resolution_clock;
    using TimePoint = Clock::time_point;

    std::unordered_map<std::string, TimePoint> m_startTimes;
};

}
