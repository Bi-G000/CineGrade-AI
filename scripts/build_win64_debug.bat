@echo off
setlocal enabledelayedexpansion

:: ============================================================================
:: build_win64_debug.bat
:: ============================================================================
:: Builds the CineGrade AI project in Debug configuration using Visual Studio 2022.
:: Requires the solution to be generated first via setup_vs_solution.ps1.
:: ============================================================================

:: Configuration
set "BUILD_DIR=build"
set "CONFIG=Debug"

:: Determine Project Root (one level up from the scripts directory)
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%\.."
set "PROJECT_ROOT=%cd%"

echo ======================================================
echo  CineGrade AI - Windows x64 Build Script [%CONFIG%]
echo ======================================================
echo.

:: --------------------------------------------------------------------------
:: 1. Validate Build Environment
:: --------------------------------------------------------------------------
if not exist "%PROJECT_ROOT%\%BUILD_DIR%" (
    echo [ERROR] Build directory '%BUILD_DIR%' does not exist.
    echo Please run 'powershell -File scripts\setup_vs_solution.ps1' first to generate the solution.
    exit /b 1
)

if not exist "%PROJECT_ROOT%\%BUILD_DIR%\CMakeCache.txt" (
    echo [ERROR] CMakeCache.txt not found in '%BUILD_DIR%'.
    echo The build tree is corrupted or was not configured.
    echo Please delete the '%BUILD_DIR%' folder and run 'setup_vs_solution.ps1' again.
    exit /b 1
)

echo [1/2] Build directory and configuration validated.
echo.

:: --------------------------------------------------------------------------
:: 2. Execute CMake Build
:: --------------------------------------------------------------------------
echo [2/2] Starting %CONFIG% build process...
echo.

:: Pass /m to MSBuild via CMake for multi-processor compilation
cmake --build "%PROJECT_ROOT%\%BUILD_DIR%" --config %CONFIG% -- /p:Platform=x64 /m /v:m

:: --------------------------------------------------------------------------
:: 3. Handle Result
:: --------------------------------------------------------------------------
if %ERRORLEVEL% neq 0 (
    echo.
    echo ======================================================
    echo  [FAILED] Build process exited with error code %ERRORLEVEL%
    echo ======================================================
    exit /b %ERRORLEVEL%
)

echo.
echo ======================================================
echo  [SUCCESS] %CONFIG% build completed successfully!
echo  Output location: %PROJECT_ROOT%\%BUILD_DIR%\bin\%CONFIG%\
echo ======================================================

endlocal
exit /b 0
