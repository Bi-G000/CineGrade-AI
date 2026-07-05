#pragma once

#include <cstdint>
#include <string>
#include <vector>

namespace CineGrade
{

class IccProfileLoader
{
public:
    IccProfileLoader() = default;
    ~IccProfileLoader() = default;

    bool Load(const std::string& filePath);

    void Unload();

    bool IsLoaded() const;

    const std::vector<std::uint8_t>& GetData() const;

    std::string GetProfileName() const;

    std::uint32_t GetProfileSize() const;

private:
    std::string m_profileName;
    std::vector<std::uint8_t> m_profileData;
};

}
