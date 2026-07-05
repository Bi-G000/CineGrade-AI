#pragma once

#include <string>

namespace CineGrade
{

class ArtboardHandle
{
public:
    ArtboardHandle();
    ~ArtboardHandle();

    bool IsValid() const;

    int GetIndex() const;
    void SetIndex(int index);

    std::string GetName() const;
    bool SetName(const std::string& name);

    double GetWidth() const;
    double GetHeight() const;

    bool Activate();

private:
    int m_index = -1;
};

}
