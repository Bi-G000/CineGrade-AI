#pragma once

namespace CineGrade
{

class SuiteAcquisition
{
public:
    SuiteAcquisition();
    ~SuiteAcquisition();

    bool AcquireAllSuites();
    void ReleaseAllSuites();

    bool IsReady() const;

private:
    bool AcquireArtSuite();
    bool AcquireDocumentSuite();
    bool AcquireLayerSuite();
    bool AcquirePathSuite();
    bool AcquireRasterSuite();

    void ReleaseArtSuite();
    void ReleaseDocumentSuite();
    void ReleaseLayerSuite();
    void ReleasePathSuite();
    void ReleaseRasterSuite();

private:
    bool m_ready = false;
};

}
