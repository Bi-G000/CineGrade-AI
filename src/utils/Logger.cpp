#include "utils/Logger.h"

#include <chrono>
#include <ctime>
#include <iomanip>
#include <sstream>

namespace CineGrade
{

Logger& Logger::Instance()
{
    static Logger instance;
    return instance;
}

bool Logger::Initialize(const std::string& logFile)
{
    std::lock_guard<std::mutex> lock(m_mutex);

    if (m_initialized)
    {
        return true;
    }

    m_stream.open(logFile, std::ios::out | std::ios::app);

    if (!m_stream.is_open())
    {
        return false;
    }

    m_initialized = true;
    Info("Logger initialized.");

    return true;
}

void Logger::Shutdown()
{
    std::lock_guard<std::mutex> lock(m_mutex);

    if (!m_initialized)
    {
        return;
    }

    Info("Logger shutdown.");

    m_stream.close();
    m_initialized = false;
}

void Logger::Log(LogLevel level, const std::string& message)
{
    std::lock_guard<std::mutex> lock(m_mutex);

    if (!m_initialized || !m_stream.is_open())
    {
        return;
    }

    auto now = std::chrono::system_clock::now();
    auto nowTime = std::chrono::system_clock::to_time_t(now);

    std::tm localTime{};

#ifdef _WIN32
    localtime_s(&localTime, &nowTime);
#else
    localTime = *std::localtime(&nowTime);
#endif

    m_stream
        << "["
        << std::put_time(&localTime, "%Y-%m-%d %H:%M:%S")
        << "] "
        << "["
        << LevelToString(level)
        << "] "
        << message
        << std::endl;
}

void Logger::Info(const std::string& message)
{
    Log(LogLevel::Info, message);
}

void Logger::Warning(const std::string& message)
{
    Log(LogLevel::Warning, message);
}

void Logger::Error(const std::string& message)
{
    Log(LogLevel::Error, message);
}

void Logger::Debug(const std::string& message)
{
    Log(LogLevel::Debug, message);
}

std::string Logger::LevelToString(LogLevel level) const
{
    switch (level)
    {
        case LogLevel::Info:
            return "INFO";

        case LogLevel::Warning:
            return "WARNING";

        case LogLevel::Error:
            return "ERROR";

        case LogLevel::Debug:
            return "DEBUG";

        default:
            return "UNKNOWN";
    }
}

}
