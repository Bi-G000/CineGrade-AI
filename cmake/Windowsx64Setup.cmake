# ============================================================================
# Windowsx64Setup.cmake
# ============================================================================
# Configures Windows x64 specific build settings, output directories, 
# post-build DLL copying, and UXP packaging structure.
# Requires CMake 3.21+ and Visual Studio 2022.
# ============================================================================

# --------------------------------------------------------------------------
# 1. Generator & Platform Validation
# --------------------------------------------------------------------------
if(NOT CMAKE_GENERATOR MATCHES "Visual Studio 17 2022")
    message(WARNING "Windowsx64Setup.cmake is optimized for Visual Studio 17 2022. Current generator: ${CMAKE_GENERATOR}")
endif()

if(NOT CMAKE_GENERATOR_PLATFORM STREQUAL "x64")
    message(FATAL_ERROR "CineGrade AI strictly requires the x64 platform. "
                        "Please reconfigure CMake with the '-A x64' flag.")
endif()

# --------------------------------------------------------------------------
# 2. Output Directory Configuration
# Forces all binaries, libraries, and symbols into a unified structure 
# separated by build configuration (Debug/Release).
# --------------------------------------------------------------------------
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/$<CONFIG>")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/$<CONFIG>")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib/$<CONFIG>")

# Ensure PDBs are placed directly next to the DLLs for debugging
set(CMAKE_PDB_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/$<CONFIG>")

# --------------------------------------------------------------------------
# 3. Configurable Packaging Directory
# --------------------------------------------------------------------------
set(CINEGRADE_PACKAGE_DIR "${CMAKE_BINARY_DIR}/package/CineGradeAI" 
    CACHE PATH "Directory to assemble the final UXP plugin package")

# --------------------------------------------------------------------------
# 4. Runtime Dependency Copy Function
# To be called on the main plugin target to automatically pull required 
# third-party DLLs (like ONNX Runtime) into the build output directory.
# --------------------------------------------------------------------------
function(configure_target_runtime TARGET_NAME)
    if(NOT TARGET ${TARGET_NAME})
        message(FATAL_ERROR "configure_target_runtime called with non-existent target: ${TARGET_NAME}")
    endif()

    if(TARGET ONNXRuntime::ONNXRuntime)
        add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                $<TARGET_FILE:ONNXRuntime::ONNXRuntime>
                $<TARGET_FILE_DIR:${TARGET_NAME}>
            COMMENT "Copying ONNX Runtime DLL to output directory..."
            VERBATIM
        )
    endif()
endfunction()

# --------------------------------------------------------------------------
# 5. UXP Packaging Function
# Assembles the final plugin directory structure required by Adobe Illustrator
# and our Windows installer script.
# --------------------------------------------------------------------------
function(configure_uxp_package TARGET_NAME)
    if(NOT TARGET ${TARGET_NAME})
        message(FATAL_ERROR "configure_uxp_package called with non-existent target: ${TARGET_NAME}")
    endif()

    # Workaround for multi-config generators: copy_if_different fails if the 
    # source path evaluates to empty. We use a dummy file for non-Debug configs.
    set(_DUMMY_PDB "${CMAKE_BINARY_DIR}/dummy.pdb")
    if(NOT EXISTS "${_DUMMY_PDB}")
        file(WRITE "${_DUMMY_PDB}" "")
    endif()

    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
        COMMENT "Assembling UXP Plugin Package..."
        
        # Create directory structure
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CINEGRADE_PACKAGE_DIR}/$<CONFIG>"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CINEGRADE_PACKAGE_DIR}/uxp"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CINEGRADE_PACKAGE_DIR}/resources"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CINEGRADE_PACKAGE_DIR}/resources/presets/luts"
        
        # Copy compiled Core Engine (Uses generator expression for filename)
        COMMAND ${CMAKE_COMMAND} -E copy_if_different 
            "$<TARGET_FILE:${TARGET_NAME}>" 
            "${CINEGRADE_PACKAGE_DIR}/$<CONFIG>/$<TARGET_FILE_NAME:${TARGET_NAME}>"
            
        # Copy PDB ONLY in Debug configuration using $<IF:...> fallback
        COMMAND ${CMAKE_COMMAND} -E copy_if_different 
            "$<IF:$<CONFIG:Debug>,$<TARGET_PDB_FILE:${TARGET_NAME}>,${_DUMMY_PDB}>" 
            "${CINEGRADE_PACKAGE_DIR}/$<CONFIG>/$<TARGET_FILE_NAME:${TARGET_NAME}>.pdb"
            
        # Copy UXP Frontend (UI)
        COMMAND ${CMAKE_COMMAND} -E copy_directory 
            "${CMAKE_CURRENT_SOURCE_DIR}/ui" 
            "${CINEGRADE_PACKAGE_DIR}/uxp"
            
        # Copy Resources (Presets, Localization, Icons)
        COMMAND ${CMAKE_COMMAND} -E copy_directory 
            "${CMAKE_CURRENT_SOURCE_DIR}/resources" 
            "${CINEGRADE_PACKAGE_DIR}/resources"
            
        VERBATIM
    )

    # Copy Third-Party DLLs (Dependencies) - Guarded safely by target existence
    if(TARGET ONNXRuntime::ONNXRuntime)
        add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different 
                "$<TARGET_FILE:ONNXRuntime::ONNXRuntime>" 
                "${CINEGRADE_PACKAGE_DIR}/$<CONFIG>/$<TARGET_FILE_NAME:ONNXRuntime::ONNXRuntime>"
            COMMENT "Copying ONNX Runtime DLL to package directory..."
            VERBATIM
        )
    endif()
endfunction()
