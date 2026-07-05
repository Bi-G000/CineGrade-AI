#pragma once

#include <string>

namespace CineGrade
{

class CineGradeEntryPoint
{
public:
    CineGradeEntryPoint();
    ~CineGradeEntryPoint();

    bool Initialize();
    void Shutdown();

    bool IsInitialized() const;

    const std::string& GetPluginName() const;
    const std::string& GetPluginVersion() const;

private:
    bool m_initialized = false;

    std::string m_pluginName = "CineGrade AI";
    std::string m_pluginVersion = "1.0.0";
};

}
