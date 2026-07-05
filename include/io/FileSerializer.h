#pragma once

#include <cstdint>
#include <string>
#include <vector>

namespace CineGrade
{

class FileSerializer
{
public:
    FileSerializer() = default;
    ~FileSerializer() = default;

    bool SaveBinary(
        const std::string& filePath,
        const std::vector<std::uint8_t>& data);

    bool LoadBinary(
        const std::string& filePath,
        std::vector<std::uint8_t>& data);

    bool SaveText(
        const std::string& filePath,
        const std::string& text);

    bool LoadText(
        const std::string& filePath,
        std::string& text);

    bool Exists(const std::string& filePath) const;

    std::uint64_t GetFileSize(const std::string& filePath) const;
};

}
