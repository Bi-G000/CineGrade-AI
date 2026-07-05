# ============================================================================
# FindOnnxRuntime.cmake
# ============================================================================
# Finds the ONNX Runtime library installed on the system.
# 
# This module defines:
#   ONNXRUNTIME_INCLUDE_DIR - The directory containing onnxruntime_cxx_api.h
#   ONNXRUNTIME_LIBRARY     - The path to the import library (.lib)
#   ONNXRUNTIME_DLL         - The path to the dynamic library (.dll)
#
# Imported Targets:
#   ONNXRuntime::ONNXRuntime - The SHARED imported target
#
# Environment Variables:
#   ONNXRUNTIME_ROOT - Optional. If set, overrides automatic detection.
# ============================================================================

include(FindPackageHandleStandardArgs)

# Enforce 64-bit build, as ONNX Runtime only provides x64 binaries for Windows
if(NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
    message(FATAL_ERROR "CineGrade AI requires a 64-bit (x64) build target. ONNX Runtime does not support 32-bit architectures.")
endif()

# --------------------------------------------------------------------------
# 1. Gather Candidate Root Paths
# --------------------------------------------------------------------------
# Priority: CMake Cache -> Environment Variable
set(_ONNXRUNTIME_ROOT_CANDIDATES "")

if(DEFINED ONNXRUNTIME_ROOT AND IS_DIRECTORY "${ONNXRUNTIME_ROOT}")
    list(APPEND _ONNXRUNTIME_ROOT_CANDIDATES "${ONNXRUNTIME_ROOT}")
endif()

if(DEFINED ENV{ONNXRUNTIME_ROOT} AND NOT "$ENV{ONNXRUNTIME_ROOT}" STREQUAL "")
    list(APPEND _ONNXRUNTIME_ROOT_CANDIDATES "$ENV{ONNXRUNTIME_ROOT}")
endif()

list(REMOVE_DUPLICATES _ONNXRUNTIME_ROOT_CANDIDATES)

# --------------------------------------------------------------------------
# 2. Find Headers
# --------------------------------------------------------------------------
find_path(ONNXRUNTIME_INCLUDE_DIR
    NAMES
        onnxruntime_cxx_api.h
    HINTS
        ${_ONNXRUNTIME_ROOT_CANDIDATES}
    PATH_SUFFIXES
        "include"
)

# --------------------------------------------------------------------------
# 3. Find Import Library (.lib)
# --------------------------------------------------------------------------
find_library(ONNXRUNTIME_LIBRARY
    NAMES
        onnxruntime
    HINTS
        ${_ONNXRUNTIME_ROOT_CANDIDATES}
    PATH_SUFFIXES
        "lib"
)

# --------------------------------------------------------------------------
# 4. Find Dynamic Library (.dll)
# ONNX Runtime on Windows is distributed as a DLL. We must locate it so 
# CMake can automatically copy it to the output directory in a post-build step.
find_file(ONNXRUNTIME_DLL
    NAMES
        onnxruntime.dll
    HINTS
        ${_ONNXRUNTIME_ROOT_CANDIDATES}
    PATH_SUFFIXES
        "lib"
        "bin"
)

# --------------------------------------------------------------------------
# 5. Handle Standard Args
# --------------------------------------------------------------------------
find_package_handle_standard_args(OnnxRuntime
    REQUIRED_VARS 
        ONNXRUNTIME_INCLUDE_DIR 
        ONNXRUNTIME_LIBRARY 
        ONNXRUNTIME_DLL
    FAIL_MESSAGE 
        "Could NOT find ONNX Runtime. Please set the ONNXRUNTIME_ROOT cache variable to point to the root of the extracted ONNX Runtime package (e.g., -DONNXRUNTIME_ROOT='C:/libs/onnxruntime')."
)

# --------------------------------------------------------------------------
# 6. Create Imported Shared Target
# --------------------------------------------------------------------------
if(OnnxRuntime_FOUND)
    add_library(ONNXRuntime::ONNXRuntime SHARED IMPORTED)
    
    set_target_properties(ONNXRuntime::ONNXRuntime PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${ONNXRUNTIME_INCLUDE_DIR}"
        IMPORTED_IMPLIB "${ONNXRUNTIME_LIBRARY}"
        IMPORTED_LOCATION "${ONNXRUNTIME_DLL}"
    )

    mark_as_advanced(
        ONNXRUNTIME_INCLUDE_DIR 
        ONNXRUNTIME_LIBRARY 
        ONNXRUNTIME_DLL
    )
endif()
