#include "core/CineGradeEntryPoint.h"

namespace CineGrade
{

CineGradeEntryPoint::CineGradeEntryPoint() = default;

CineGradeEntryPoint::~CineGradeEntryPoint()
{
    if (m_initialized)
    {
        Shutdown();
    }
}

bool CineGradeEntryPoint::Initialize()
{
    if (m_initialized)
    {
        return true;
    }

    // TODO:
    // - Acquire Illustrator SDK suites
    // - Initialize ONNX Runtime
    // - Initialize LittleCMS
    // - Initialize Logger
    // - Initialize Native Bridge

    m_initialized = true;
    return true;
}

void CineGradeEntryPoint::Shutdown()
{
    if (!m_initialized)
    {
        return;
    }

    // TODO:
    // - Release Illustrator SDK suites
    // - Shutdown AI Engine
    // - Flush Logger
    // - Free caches

    m_initialized = false;
}

bool CineGradeEntryPoint::IsInitialized() const
{
    return m_initialized;
}

const std::string& CineGradeEntryPoint::GetPluginName() const
{
    return m_pluginName;
}

const std::string& CineGradeEntryPoint::GetPluginVersion() const
{
    return m_pluginVersion;
}

}
