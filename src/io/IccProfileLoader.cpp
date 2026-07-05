#include "io/IccProfileLoader.h"

#include <fstream>
#include <iterator>

namespace CineGrade
{

bool IccProfileLoader::Load(const std::string& filePath)
{
    Unload();

    std::ifstream file(filePath, std::ios::binary);

    if (!file.is_open())
    {
        return false;
    }

    m_profileData.assign(
        std::istreambuf_iterator<char>(file),
        std::istreambuf_iterator<char>());

    if (m_profileData.empty())
    {
        return false;
    }

    // TODO:
    // Parse ICC header and extract profile description.
    // Currently we simply use the filename.

    const auto pos = filePath.find_last_of("/\\");
    if (pos == std::string::npos)
    {
        m_profileName = filePath;
    }
    else
    {
        m_profileName = filePath.substr(pos + 1);
    }

    return true;
}

void IccProfileLoader::Unload()
{
    m_profileData.clear();
    m_profileName.clear();
}

bool IccProfileLoader::IsLoaded() const
{
    return !m_profileData.empty();
}

const std::vector<std::uint8_t>& IccProfileLoader::GetData() const
{
    return m_profileData;
}

std::string IccProfileLoader::GetProfileName() const
{
    return m_profileName;
}

std::uint32_t IccProfileLoader::GetProfileSize() const
{
    return static_cast<std::uint32_t>(m_profileData.size());
}

}
