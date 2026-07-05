#pragma once

#include <fstream>
#include <mutex>
#include <string>

namespace CineGrade
{

enum class LogLevel
{
    Info,
    Warning,
    Error,
    Debug
};

class Logger
{
public:
    static Logger& Instance();

    bool Initialize(const std::string& logFile = "CineGradeAI.log");
    void Shutdown();

    void Log(LogLevel level, const std::string& message);

    void Info(const std::string& message);
    void Warning(const std::string& message);
    void Error(const std::string& message);
    void Debug(const std::string& message);

private:
    Logger() = default;
    ~Logger() = default;

    Logger(const Logger&) = delete;
    Logger& operator=(const Logger&) = delete;

    std::string LevelToString(LogLevel level) const;

private:
    std::ofstream m_stream;
    std::mutex m_mutex;
    bool m_initialized = false;
};

}
