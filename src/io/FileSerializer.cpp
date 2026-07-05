#include "io/FileSerializer.h"

#include <filesystem>
#include <fstream>
#include <iterator>

namespace CineGrade
{

bool FileSerializer::SaveBinary(
    const std::string& filePath,
    const std::vector<std::uint8_t>& data)
{
    std::ofstream file(filePath, std::ios::binary);

    if (!file.is_open())
    {
        return false;
    }

    if (!data.empty())
    {
        file.write(
            reinterpret_cast<const char*>(data.data()),
            static_cast<std::streamsize>(data.size()));
    }

    return file.good();
}

bool FileSerializer::LoadBinary(
    const std::string& filePath,
    std::vector<std::uint8_t>& data)
{
    std::ifstream file(filePath, std::ios::binary);

    if (!file.is_open())
    {
        return false;
    }

    data.assign(
        std::istreambuf_iterator<char>(file),
        std::istreambuf_iterator<char>());

    return file.good() || file.eof();
}

bool FileSerializer::SaveText(
    const std::string& filePath,
    const std::string& text)
{
    std::ofstream file(filePath);

    if (!file.is_open())
    {
        return false;
    }

    file << text;

    return file.good();
}

bool FileSerializer::LoadText(
    const std::string& filePath,
    std::string& text)
{
    std::ifstream file(filePath);

    if (!file.is_open())
    {
        return false;
    }

    text.assign(
        std::istreambuf_iterator<char>(file),
        std::istreambuf_iterator<char>());

    return file.good() || file.eof();
}

bool FileSerializer::Exists(const std::string& filePath) const
{
    return std::filesystem::exists(filePath);
}

std::uint64_t FileSerializer::GetFileSize(const std::string& filePath) const
{
    if (!Exists(filePath))
    {
        return 0;
    }

    return static_cast<std::uint64_t>(
        std::filesystem::file_size(filePath));
}

}
