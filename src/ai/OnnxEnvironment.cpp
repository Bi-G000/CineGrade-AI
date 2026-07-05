#include "ai/OnnxEnvironment.h"

namespace CineGrade {

bool OnnxEnvironment::Initialize(){ m_initialized=true; return true; }
void OnnxEnvironment::Shutdown(){ m_initialized=false; }
bool OnnxEnvironment::IsInitialized() const{ return m_initialized; }

}
