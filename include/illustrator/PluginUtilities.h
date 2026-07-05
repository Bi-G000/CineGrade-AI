#pragma once

#include <string>
#include <vector>

namespace CineGrade
{

class PluginUtilities
{
public:
    PluginUtilities() = default;
    ~PluginUtilities() = default;

    bool HasOpenDocument() const;

    std::string GetActiveDocumentName() const;

    std::vector<std::string> GetArtboardNames() const;

    bool SelectAllArtwork();

    bool DeselectAllArtwork();

    bool RedrawDocument();

    bool SaveDocument();

    bool SaveDocumentAs(const std::string& filePath);

    bool CloseDocument();

private:
    bool ValidateDocument() const;
};

}
