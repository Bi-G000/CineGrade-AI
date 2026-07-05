#include "illustrator/ArtboardHandle.h"

namespace CineGrade
{

ArtboardHandle::ArtboardHandle() = default;

ArtboardHandle::~ArtboardHandle() = default;

bool ArtboardHandle::IsValid() const
{
    return m_index >= 0;
}

int ArtboardHandle::GetIndex() const
{
    return m_index;
}

void ArtboardHandle::SetIndex(int index)
{
    m_index = index;
}

std::string ArtboardHandle::GetName() const
{
    if (!IsValid())
    {
        return {};
    }

    // TODO:
    // Retrieve artboard name from Illustrator SDK.
    return "Artboard";
}

bool ArtboardHandle::SetName(const std::string& name)
{
    if (!IsValid() || name.empty())
    {
        return false;
    }

    // TODO:
    // Rename artboard using AIArtboardSuite.

    return true;
}

double ArtboardHandle::GetWidth() const
{
    if (!IsValid())
    {
        return 0.0;
    }

    // TODO:
    // Read artboard width.

    return 0.0;
}

double ArtboardHandle::GetHeight() const
{
    if (!IsValid())
    {
        return 0.0;
    }

    // TODO:
    // Read artboard height.

    return 0.0;
}

bool ArtboardHandle::Activate()
{
    if (!IsValid())
    {
        return false;
    }

    // TODO:
    // Set active artboard.

    return true;
}

}
