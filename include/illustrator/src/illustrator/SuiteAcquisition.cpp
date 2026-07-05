#include "illustrator/SuiteAcquisition.h"

namespace CineGrade
{

SuiteAcquisition::SuiteAcquisition() = default;

SuiteAcquisition::~SuiteAcquisition()
{
    ReleaseAllSuites();
}

bool SuiteAcquisition::AcquireAllSuites()
{
    if (m_ready)
    {
        return true;
    }

    if (!AcquireArtSuite())       return false;
    if (!AcquireDocumentSuite())  return false;
    if (!AcquireLayerSuite())     return false;
    if (!AcquirePathSuite())      return false;
    if (!AcquireRasterSuite())    return false;

    m_ready = true;
    return true;
}

void SuiteAcquisition::ReleaseAllSuites()
{
    if (!m_ready)
    {
        return;
    }

    ReleaseRasterSuite();
    ReleasePathSuite();
    ReleaseLayerSuite();
    ReleaseDocumentSuite();
    ReleaseArtSuite();

    m_ready = false;
}

bool SuiteAcquisition::IsReady() const
{
    return m_ready;
}

bool SuiteAcquisition::AcquireArtSuite()
{
    // TODO: Acquire AIArtSuite from Illustrator SDK
    return true;
}

bool SuiteAcquisition::AcquireDocumentSuite()
{
    // TODO: Acquire AIDocumentSuite
    return true;
}

bool SuiteAcquisition::AcquireLayerSuite()
{
    // TODO: Acquire AILayerSuite
    return true;
}

bool SuiteAcquisition::AcquirePathSuite()
{
    // TODO: Acquire AIPathSuite
    return true;
}

bool SuiteAcquisition::AcquireRasterSuite()
{
    // TODO: Acquire AIRasterSuite
    return true;
}

void SuiteAcquisition::ReleaseArtSuite()
{
    // TODO: Release AIArtSuite
}

void SuiteAcquisition::ReleaseDocumentSuite()
{
    // TODO: Release AIDocumentSuite
}

void SuiteAcquisition::ReleaseLayerSuite()
{
    // TODO: Release AILayerSuite
}

void SuiteAcquisition::ReleasePathSuite()
{
    // TODO: Release AIPathSuite
}

void SuiteAcquisition::ReleaseRasterSuite()
{
    // TODO: Release AIRasterSuite
}

}
