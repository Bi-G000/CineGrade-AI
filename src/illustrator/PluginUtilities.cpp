#include "illustrator/PluginUtilities.h"

namespace CineGrade
{

bool PluginUtilities::HasOpenDocument() const
{
    // TODO:
    // Query Illustrator SDK for an active document.
    return true;
}

std::string PluginUtilities::GetActiveDocumentName() const
{
    if (!ValidateDocument())
    {
        return {};
    }

    // TODO:
    // Read document name via AIDocumentSuite.
    return "Untitled";
}

std::vector<std::string> PluginUtilities::GetArtboardNames() const
{
    std::vector<std::string> artboards;

    if (!ValidateDocument())
    {
        return artboards;
    }

    // TODO:
    // Enumerate artboards using AIArtboardSuite.

    return artboards;
}

bool PluginUtilities::SelectAllArtwork()
{
    if (!ValidateDocument())
    {
        return false;
    }

    // TODO:
    // Select all artwork.

    return true;
}

bool PluginUtilities::DeselectAllArtwork()
{
    if (!ValidateDocument())
    {
        return false;
    }

    // TODO:
    // Clear current selection.

    return true;
}

bool PluginUtilities::RedrawDocument()
{
    if (!ValidateDocument())
    {
        return false;
    }

    // TODO:
    // Force Illustrator redraw.

    return true;
}

bool PluginUtilities::SaveDocument()
{
    if (!ValidateDocument())
    {
        return false;
    }

    // TODO:
    // Save current document.

    return true;
}

bool PluginUtilities::SaveDocumentAs(const std::string& filePath)
{
    if (!ValidateDocument())
    {
        return false;
    }

    if (filePath.empty())
    {
        return false;
    }

    // TODO:
    // Save document to filePath.

    return true;
}

bool PluginUtilities::CloseDocument()
{
    if (!ValidateDocument())
    {
        return false;
    }

    // TODO:
    // Close active document.

    return true;
}

bool PluginUtilities::ValidateDocument() const
{
    return HasOpenDocument();
}

}
