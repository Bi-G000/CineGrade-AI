#pragma once

#include <functional>
#include <string>
#include <unordered_map>

namespace CineGrade
{

class UxpNativeBridge
{
public:
    using Callback = std::function<void(const std::string&)>;

    UxpNativeBridge();
    ~UxpNativeBridge();

    bool Initialize();
    void Shutdown();

    bool RegisterCommand(
        const std::string& command,
        Callback callback);

    bool ExecuteCommand(
        const std::string& command,
        const std::string& payload);

    bool HasCommand(
        const std::string& command) const;

private:
    std::unordered_map<std::string, Callback> m_commands;
    bool m_initialized = false;
};

}
