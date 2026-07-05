# ============================================================================
# FindIllustratorSDK.cmake
# ============================================================================
# Finds the Adobe Illustrator SDK (2024+) installed on the system.
# 
# This module defines:
#   ILLUSTRATOR_SDK_FOUND       - True if the SDK was found
#   ILLUSTRATOR_SDK_INCLUDE_DIR - The directory containing IllustratorAPI.h
#   ILLUSTRATOR_SDK_LIBRARIES   - List of absolute paths to required .lib files
#
# Imported Targets:
#   IllustratorSDK::IllustratorSDK - The INTERFACE imported target
#
# Environment Variables:
#   ILLUSTRATOR_SDK_PATH - Optional. If set, overrides automatic detection.
# ============================================================================

include(FindPackageHandleStandardArgs)

# Enforce 64-bit build, as modern Illustrator SDKs do not support x86
if(NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
    message(FATAL_ERROR "CineGrade AI requires a 64-bit (x64) build target. The Adobe Illustrator SDK does not support 32-bit architectures.")
endif()

# --------------------------------------------------------------------------
# 1. Gather Candidate Root Paths
# --------------------------------------------------------------------------
# Priority: CMake Cache -> Environment Variable -> Auto-Discovery
set(_ILLUSTRATOR_SDK_ROOT_CANDIDATES "")

if(DEFINED ILLUSTRATOR_SDK_DIR AND IS_DIRECTORY "${ILLUSTRATOR_SDK_DIR}")
    list(APPEND _ILLUSTRATOR_SDK_ROOT_CANDIDATES "${ILLUSTRATOR_SDK_DIR}")
endif()

if(DEFINED ENV{ILLUSTRATOR_SDK_PATH} AND NOT "$ENV{ILLUSTRATOR_SDK_PATH}" STREQUAL "")
    list(APPEND _ILLUSTRATOR_SDK_ROOT_CANDIDATES "$ENV{ILLUSTRATOR_SDK_PATH}")
endif()

# Auto-discover version-agnostic SDK folders on common Windows drives
file(GLOB _AUTO_SEARCH_PATHS
    "C:/*Illustrator*SDK*"
    "D:/*Illustrator*SDK*"
    "$ENV{PROGRAMFILES}/*Illustrator*SDK*"
)

if(_AUTO_SEARCH_PATHS)
    list(APPEND _ILLUSTRATOR_SDK_ROOT_CANDIDATES ${_AUTO_SEARCH_PATHS})
endif()

list(REMOVE_DUPLICATES _ILLUSTRATOR_SDK_ROOT_CANDIDATES)

# --------------------------------------------------------------------------
# 2. Find Headers (Standard CMake Method)
# --------------------------------------------------------------------------
find_path(ILLUSTRATOR_SDK_INCLUDE_DIR
    NAMES
        IllustratorAPI.h
    HINTS
        ${_ILLUSTRATOR_SDK_ROOT_CANDIDATES}
    PATH_SUFFIXES
        "headers"
        "includes"
        "illustrator/headers"
        "sdk/headers"
)

# --------------------------------------------------------------------------
# 3. Find Required Libraries (Standard CMake Method)
# --------------------------------------------------------------------------
# Only search for the absolute minimum required libraries to avoid pulling 
# in irrelevant static libraries from the SDK samples.
set(ILLUSTRATOR_SDK_LIBRARIES "")

# Core Illustrator API Library
find_library(ILLUSTRATOR_AI_LIB
    NAMES
        AI
    HINTS
        ${_ILLUSTRATOR_SDK_ROOT_CANDIDATES}
    PATH_SUFFIXES
        "lib"
        "lib/x64"
        "libraries"
        "illustrator/lib"
)

if(ILLUSTRATOR_AI_LIB)
    list(APPEND ILLUSTRATOR_SDK_LIBRARIES "${ILLUSTRATOR_AI_LIB}")
endif()

# Adobe Shared Library (often required by modern Illustrator SDKs)
find_library(ILLUSTRATOR_ADSK_LIB
    NAMES
        ADSKLib
    HINTS
        ${_ILLUSTRATOR_SDK_ROOT_CANDIDATES}
    PATH_SUFFIXES
        "lib"
        "lib/x64"
        "libraries"
        "illustrator/lib"
)

if(ILLUSTRATOR_ADSK_LIB)
    list(APPEND ILLUSTRATOR_SDK_LIBRARIES "${ILLUSTRATOR_ADSK_LIB}")
endif()

# --------------------------------------------------------------------------
# 4. Handle Standard Args
# --------------------------------------------------------------------------
find_package_handle_standard_args(IllustratorSDK
    REQUIRED_VARS 
        ILLUSTRATOR_SDK_INCLUDE_DIR 
        ILLUSTRATOR_AI_LIB
    FAIL_MESSAGE 
        "Could NOT find the Adobe Illustrator SDK. Please set the ILLUSTRATOR_SDK_DIR cache variable to point to the root of the installed SDK (e.g., -DILLUSTRATOR_SDK_DIR='C:/Adobe Illustrator 2024 SDK')."
)

# --------------------------------------------------------------------------
# 5. Create Imported Interface Target
# --------------------------------------------------------------------------
if(ILLUSTRATOR_SDK_FOUND)
    add_library(IllustratorSDK::IllustratorSDK INTERFACE IMPORTED)
    
    set_target_properties(IllustratorSDK::IllustratorSDK PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${ILLUSTRATOR_SDK_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "${ILLUSTRATOR_SDK_LIBRARIES}"
    )

    mark_as_advanced(
        ILLUSTRATOR_SDK_INCLUDE_DIR 
        ILLUSTRATOR_AI_LIB 
        ILLUSTRATOR_ADSK_LIB
    )
endif()
