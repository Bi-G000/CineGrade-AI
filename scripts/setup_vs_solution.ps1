<#
.SYNOPSIS
    Configures and generates the Visual Studio 2022 solution for CineGrade AI.
.DESCRIPTION
    Validates required dependencies (Illustrator SDK, ONNX Runtime) and invokes 
    CMake to generate the Visual Studio 2022 x64 solution files.
.PARAMETER IllustratorSDKPath
    Optional. Path to the root of the Adobe Illustrator SDK. 
    If omitted, CMake will attempt to find it automatically.
.PARAMETER OnnxRuntimePath
    Optional. Path to the root of the extracted ONNX Runtime package.
    If omitted, CMake will attempt to find it automatically.
.PARAMETER BuildDir
    The directory to generate the build system into. Default is "build".
.EXAMPLE
    .\setup_vs_solution.ps1 -IllustratorSDKPath "C:\Adobe Illustrator 2024 SDK" -OnnxRuntimePath "C:\libs\onnxruntime"
#>

param(
    [string]$IllustratorSDKPath,
    [string]$OnnxRuntimePath,
    [string]$BuildDir = "build"
)

 $ErrorActionPreference = "Stop"
 $ProjectRoot = Split-Path -Parent $PSScriptRoot

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host " CineGrade AI - Visual Studio Solution Generator" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

# --------------------------------------------------------------------------
# 1. Validate CMake Installation
# --------------------------------------------------------------------------
Write-Host "[1/4] Checking for CMake..." -ForegroundColor Yellow
try {
    $cmakeVersion = & cmake --version 2>&1 | Select-Object -First 1
    Write-Host "  -> Found: $cmakeVersion" -ForegroundColor Green
} catch {
    Write-Host "  -> ERROR: CMake is not installed or not added to your system PATH." -ForegroundColor Red
    Write-Host "  -> Please install CMake 3.21+ from https://cmake.org/download/" -ForegroundColor Red
    exit 1
}

# --------------------------------------------------------------------------
# 2. Validate Dependencies
# --------------------------------------------------------------------------
Write-Host "[2/4] Validating external dependencies..." -ForegroundColor Yellow

if (-not [string]::IsNullOrWhiteSpace($IllustratorSDKPath)) {
    Write-Host "  -> Validating Illustrator SDK at: $IllustratorSDKPath" -ForegroundColor White
    if (-not (Test-Path $IllustratorSDKPath -PathType Container)) {
        Write-Host "  -> ERROR: Directory does not exist." -ForegroundColor Red
        exit 1
    }
    
    $aiHeader = Get-ChildItem -Path $IllustratorSDKPath -Recurse -Filter "IllustratorAPI.h" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $aiHeader) {
        Write-Host "  -> ERROR: 'IllustratorAPI.h' not found in the provided SDK path. Please verify the directory structure." -ForegroundColor Red
        exit 1
    }
    Write-Host "  -> Illustrator SDK validated successfully." -ForegroundColor Green
} else {
    Write-Host "  -> Illustrator SDK path not provided. Relying on CMake auto-discovery..." -ForegroundColor DarkGray
}

if (-not [string]::IsNullOrWhiteSpace($OnnxRuntimePath)) {
    Write-Host "  -> Validating ONNX Runtime at: $OnnxRuntimePath" -ForegroundColor White
    if (-not (Test-Path $OnnxRuntimePath -PathType Container)) {
        Write-Host "  -> ERROR: Directory does not exist." -ForegroundColor Red
        exit 1
    }
    
    $onnxHeader = Get-ChildItem -Path $OnnxRuntimePath -Recurse -Filter "onnxruntime_cxx_api.h" -ErrorAction SilentlyContinue | Select-Object -First 1
    $onxDll = Get-ChildItem -Path $OnnxRuntimePath -Recurse -Filter "onnxruntime.dll" -ErrorAction SilentlyContinue | Select-Object -First 1
    
    if (-not $onnxHeader -or -not $onxDll) {
        Write-Host "  -> ERROR: Required ONNX Runtime files (onnxruntime_cxx_api.h / onnxruntime.dll) not found." -ForegroundColor Red
        exit 1
    }
    Write-Host "  -> ONNX Runtime validated successfully." -ForegroundColor Green
} else {
    Write-Host "  -> ONNX Runtime path not provided. Relying on CMake auto-discovery..." -ForegroundColor DarkGray
}

# --------------------------------------------------------------------------
# 3. Prepare Build Directory
# --------------------------------------------------------------------------
Write-Host "[3/4] Preparing build environment..." -ForegroundColor Yellow
 $FullBuildPath = Join-Path -Path $ProjectRoot -ChildPath $BuildDir

if (-not (Test-Path $FullBuildPath -PathType Container)) {
    New-Item -ItemType Directory -Path $FullBuildPath | Out-Null
    Write-Host "  -> Created build directory: $FullBuildPath" -ForegroundColor Green
} else {
    Write-Host "  -> Build directory already exists: $FullBuildPath" -ForegroundColor DarkGray
}

# --------------------------------------------------------------------------
# 4. Execute CMake Configuration
# --------------------------------------------------------------------------
Write-Host "[4/4] Generating Visual Studio 2022 x64 Solution..." -ForegroundColor Yellow

 $cmakeArgs = @(
    "-S", $ProjectRoot,
    "-B", $FullBuildPath,
    "-G", "Visual Studio 17 2022",
    "-A", "x64"
)

if (-not [string]::IsNullOrWhiteSpace($IllustratorSDKPath)) {
    $cmakeArgs += "-DILLUSTRATOR_SDK_DIR=$IllustratorSDKPath"
}

if (-not [string]::IsNullOrWhiteSpace($OnnxRuntimePath)) {
    $cmakeArgs += "-DONNXRUNTIME_ROOT=$OnnxRuntimePath"
}

try {
    & cmake @cmakeArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "======================================================" -ForegroundColor Green
        Write-Host " SUCCESS: Solution generated successfully!" -ForegroundColor Green
        Write-Host " Location: $FullBuildPath\CineGradeAI.sln" -ForegroundColor Green
        Write-Host "======================================================" -ForegroundColor Green
        exit 0
    } else {
        Write-Host ""
        Write-Host "======================================================" -ForegroundColor Red
        Write-Host " FAILED: CMake exited with code $LASTEXITCODE" -ForegroundColor Red
        Write-Host "======================================================" -ForegroundColor Red
        exit $LASTEXITCODE
    }
} catch {
    Write-Host ""
    Write-Host "======================================================" -ForegroundColor Red
    Write-Host " FATAL: An exception occurred while running CMake." -ForegroundColor Red
    Write-Host " $_" -ForegroundColor Red
    Write-Host "======================================================" -ForegroundColor Red
    exit 1
}
