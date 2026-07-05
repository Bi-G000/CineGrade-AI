# ============================================================================
# CineGrade AI - Master CMake Configuration
# ============================================================================
# Description: Builds the native C++ core engine for the Adobe Illustrator 
#              CineGrade AI plugin. Integrates ONNX Runtime for AI inference,
#              LittleCMS for ICC color management, and Adobe Illustrator SDK.
# Requirement: Visual Studio 2022, Windows x64, C++20
# ============================================================================

cmake_minimum_required(VERSION 3.21)

# Project Definition
project(CineGradeAI 
    VERSION 1.0.0
    DESCRIPTION "Cinema-Grade Color Engine for Adobe Illustrator"
    LANGUAGES CXX
)

# ----------------------------------------------------------------------------
# Global C++ Standard & Compiler Settings
# ----------------------------------------------------------------------------
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(MSVC)
    # Visual Studio specific flags
    add_compile_options(
        /W4           # High warning level
        /WX           # Treat warnings as errors in CI/Release
        /utf-8        # Source and execution character set is UTF-8
        /MP           # Multi-processor compilation
        /permissive-  # Strict standard conformance
        /Zc:__cplusplus # Force __cplusplus macro to report correct standard
    )
    
    # Suppress specific noisy warnings from third-party or Illustrator SDK headers
    add_compile_definitions(
        _SILENCE_ALL_CXX17_DEPRECATION_WARNINGS
        _CRT_SECURE_NO_WARNINGS
    )
endif()

# ----------------------------------------------------------------------------
# Custom CMake Modules Path
# ----------------------------------------------------------------------------
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# ----------------------------------------------------------------------------
# Dependency Resolution
# ----------------------------------------------------------------------------

# 1. Adobe Illustrator SDK
find_package(IllustratorSDK REQUIRED)
message(STATUS "Illustrator SDK Found: ${ILLUSTRATOR_SDK_DIR}")

# 2. ONNX Runtime (Local third_party)
find_package(OnnxRuntime REQUIRED)
message(STATUS "ONNX Runtime Include: ${ONNXRUNTIME_INCLUDE_DIR}")
message(STATUS "ONNX Runtime Library: ${ONNXRUNTIME_LIB}")

# 3. LittleCMS 2 (Local third_party)
find_package(Lcms2 REQUIRED)
message(STATUS "LittleCMS Include: ${LCMS2_INCLUDE_DIR}")
message(STATUS "LittleCMS Library: ${LCMS2_LIB}")

# ----------------------------------------------------------------------------
# Source Files Aggregation
# ----------------------------------------------------------------------------
# We use GLOB_RECURSE for convenience in this scale of project structure.
# Note: For production CI, it is recommended to explicitly list files to 
# detect missing files properly.
file(GLOB_RECURSE CORE_SOURCES 
    "${CMAKE_CURRENT_SOURCE_DIR}/src/core/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/color/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/image/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/histogram/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/curves/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/levels/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/lut/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/halftone/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/preview/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/renderer/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/gpu/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/vector/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/illustrator/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/utils/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/io/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/ai/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/commands/*.cpp"
)

# ----------------------------------------------------------------------------
# Main Plugin Target (Dynamic Library / .aip wrapper)
# ----------------------------------------------------------------------------
# Illustrator plugins are essentially DLLs. We name the target appropriately.
add_library(${PROJECT_NAME} SHARED ${CORE_SOURCES})

# Define the DLL export macro for our public API
target_compile_definitions(${PROJECT_NAME} PRIVATE 
    CINEGRADE_CORE_EXPORTS 
    ILLUSTRATOR_PLUGIN_BUILD
)

# ----------------------------------------------------------------------------
# Include Directories
# ----------------------------------------------------------------------------
target_include_directories(${PROJECT_NAME} 
    PUBLIC
        # Public API headers for external modules or tests
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        # Internal src headers
        ${CMAKE_CURRENT_SOURCE_DIR}/src
        # Dependencies
        ${ILLUSTRATOR_SDK_DIR}/headers
        ${ONNXRUNTIME_INCLUDE_DIR}
        ${LCMS2_INCLUDE_DIR}
)

# ----------------------------------------------------------------------------
# Link Libraries
# ----------------------------------------------------------------------------
target_link_libraries(${PROJECT_NAME} 
    PRIVATE
        # Illustrator SDK Libraries
        ${ILLUSTRATOR_SDK_LIBS}
        # ONNX Runtime
        ${ONNXRUNTIME_LIB}
        # LittleCMS
        ${LCMS2_LIB}
        # Windows System Libraries required for DLLs and Graphics
        shlwapi.lib
        gdiplus.lib
        d3d11.lib
        dxgi.lib
        opencl.lib
)

# ----------------------------------------------------------------------------
# Output Directories & Naming
# ----------------------------------------------------------------------------
set_target_properties(${PROJECT_NAME} PROPERTIES
    # Illustrator requires the plugin to have a specific extension or be in a specific folder.
    # We'll output as a standard DLL first, post-build will handle packaging.
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/$<CONFIG>"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/$<CONFIG>"
    # Ensure PDBs are put in the bin directory for easy debugging
    PDB_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/$<CONFIG>"
)

# ----------------------------------------------------------------------------
# Post-Build Steps: Plugin Packaging Simulation
# ----------------------------------------------------------------------------
# To test the plugin in Illustrator, it needs the UXP UI, Resources, and 
# ONNX DLLs co-located in a specific directory structure.

set(PLUGIN_PACKAGE_DIR "${CMAKE_BINARY_DIR}/package/CineGradeAI")

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMENT "Packaging CineGrade AI plugin files..."
    # 1. Create directory structure
    COMMAND ${CMAKE_COMMAND} -E make_directory "${PLUGIN_PACKAGE_DIR}/uxp"
    COMMAND ${CMAKE_COMMAND} -E make_directory "${PLUGIN_PACKAGE_DIR}/resources"
    COMMAND ${CMAKE_COMMAND} -E make_directory "${PLUGIN_PACKAGE_DIR}/models"
    
    # 2. Copy compiled Core Engine (.dll / .pdb)
    COMMAND ${CMAKE_COMMAND} -E copy_if_different 
        "$<TARGET_FILE:${PROJECT_NAME}>" 
        "${PLUGIN_PACKAGE_DIR}/$<CONFIG>/${PROJECT_NAME}.dll"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different 
        "$<TARGET_PDB_FILE:${PROJECT_NAME}>" 
        "${PLUGIN_PACKAGE_DIR}/$<CONFIG>/${PROJECT_NAME}.pdb"
        
    # 3. Copy ONNX Runtime DLL (Crucial for standalone execution)
    COMMAND ${CMAKE_COMMAND} -E copy_if_different 
        "${ONNXRUNTIME_DLL}" 
        "${PLUGIN_PACKAGE_DIR}/$<CONFIG>/onnxruntime.dll"
        
    # 4. Copy UXP Frontend files
    COMMAND ${CMAKE_COMMAND} -E copy_directory 
        "${CMAKE_CURRENT_SOURCE_DIR}/ui" 
        "${PLUGIN_PACKAGE_DIR}/uxp"
        
    # 5. Copy Resources (Presets, Localization, Icons)
    COMMAND ${CMAKE_COMMAND} -E copy_directory 
        "${CMAKE_CURRENT_SOURCE_DIR}/resources" 
        "${PLUGIN_PACKAGE_DIR}/resources"
        
    # 6. Copy AI Models
    COMMAND ${CMAKE_COMMAND} -E copy_if_different 
        "${CMAKE_CURRENT_SOURCE_DIR}/resources/presets/luts/fougra39_preview.cube" 
        "${PLUGIN_PACKAGE_DIR}/resources/presets/luts/"

    # Note: The actual installer scripts will zip the 'package' directory.
    VERBATIM
)

# ----------------------------------------------------------------------------
# Testing Configuration (Google Test Preparation)
# ----------------------------------------------------------------------------
enable_testing()
add_subdirectory(tests)

# ----------------------------------------------------------------------------
# Installation Rules (For Installer generation)
# ----------------------------------------------------------------------------
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
)

install(DIRECTORY include/ DESTINATION include)
install(DIRECTORY resources/ DESTINATION resources)
install(DIRECTORY ui/ DESTINATION uxp)
