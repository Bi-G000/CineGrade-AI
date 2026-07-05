#include "core/UxpNativeBridge.h"

namespace CineGrade
{

UxpNativeBridge::UxpNativeBridge() = default;

UxpNativeBridge::~UxpNativeBridge()
{
    Shutdown();
}

bool UxpNativeBridge::Initialize()
{
    if (m_initialized)
    {
        return true;
    }

    m_commands.clear();
    m_initialized = true;

    return true;
}

void UxpNativeBridge::Shutdown()
{
    if (!m_initialized)
    {
        return;
    }

    m_commands.clear();
    m_initialized = false;
}

bool UxpNativeBridge::RegisterCommand(
    const std::string& command,
    Callback callback)
{
    if (!m_initialized)
    {
        return false;
    }

    m_commands[command] = std::move(callback);
    return true;
}

bool UxpNativeBridge::ExecuteCommand(
    const std::string& command,
    const std::string& payload)
{
    if (!m_initialized)
    {
        return false;
    }

    auto it = m_commands.find(command);

    if (it == m_commands.end())
    {
        return false;
    }

    it->second(payload);
    return true;
}

bool UxpNativeBridge::HasCommand(
    const std::string& command) const
{
    return m_commands.find(command) != m_commands.end();
}

}
