#pragma once

namespace CineGrade {

class OnnxEnvironment {
public:
    bool Initialize();
    void Shutdown();
    bool IsInitialized() const;
private:
    bool m_initialized=false;
};

}
