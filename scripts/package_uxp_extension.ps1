<#
.SYNOPSIS
    Packages the compiled CineGrade AI artifacts into a distributable UXP extension (.zip).
.DESCRIPTION
    Validates the build output, checks manifest.json integrity, assembles the required 
    UXP folder structure, and compresses it into a .zip file ready for distribution 
    or local installation.
.PARAMETER Config
    The build configuration to package (Default: "Release").
.PARAMETER OutputName
    The name of the output .zip file (Default: "CineGradeAI_uxp.zip").
.EXAMPLE
    .\package_uxp_extension.ps1 -Config Release
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Debug", "Release")]
    [string]$Config = "Release",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputName = "CineGradeAI_uxp.zip"
)

 $ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

 $ProjectRoot = Split-Path -Parent $PSScriptRoot
 $PackageSourceDir = Join-Path -Path $ProjectRoot -ChildPath "build\package\CineGradeAI\$Config"
 $OutputPath = Join-Path -Path $ProjectRoot -ChildPath $OutputName

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host " CineGrade AI - UXP Extension Packager [$Config]" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

# --------------------------------------------------------------------------
# 1. Validate Build Output Directory
# --------------------------------------------------------------------------
Write-Host "[1/4] Validating build output..." -ForegroundColor Yellow
if (-not (Test-Path -Path $PackageSourceDir -PathType Container)) {
    Write-Host "  -> ERROR: Build package directory not found at '$PackageSourceDir'." -ForegroundColor Red
    Write-Host "  -> Please ensure you have run the build scripts successfully first." -ForegroundColor Red
    exit 1
}
Write-Host "  -> Build directory validated." -ForegroundColor Green

# --------------------------------------------------------------------------
# 2. Validate UXP Manifest
# --------------------------------------------------------------------------
Write-Host "[2/4] Validating UXP manifest..." -ForegroundColor Yellow
 $ManifestPath = Join-Path -Path $PackageSourceDir -ChildPath "uxp\manifest.json"

if (-not (Test-Path -Path $ManifestPath -PathType Leaf)) {
    Write-Host "  -> ERROR: 'manifest.json' not found in '$ManifestPath'." -ForegroundColor Red
    exit 1
}

try {
    $null = Get-Content -Path $ManifestPath -Raw | ConvertFrom-Json
    Write-Host "  -> 'manifest.json' is valid JSON." -ForegroundColor Green
} catch {
    Write-Host "  -> ERROR: 'manifest.json' contains syntax errors:" -ForegroundColor Red
    Write-Host "  -> $_" -ForegroundColor Red
    exit 1
}

# --------------------------------------------------------------------------
# 3. Assemble UXP Structure in Staging Directory
# --------------------------------------------------------------------------
Write-Host "[3/4] Assembling UXP package structure..." -ForegroundColor Yellow
 $StagingDir = Join-Path -Path $env:TEMP -ChildPath "CineGradeAI_Staging_$(Get-Random)"

try {
    # Create staging root
    New-Item -ItemType Directory -Path $StagingDir -Force | Out-Null

    # UXP requires manifest.json to be at the exact root of the extension folder.
    # We copy the CONTENTS of the ui/uxp folder, not the folder itself.
    $UxpSourceDir = Join-Path -Path $PackageSourceDir -ChildPath "uxp"
    Copy-Item -Path "$UxpSourceDir\*" -Destination $StagingDir -Recurse -Force

    # Copy Resources folder
    $ResSourceDir = Join-Path -Path $PackageSourceDir -ChildPath "resources"
    if (Test-Path $ResSourceDir) {
        Copy-Item -Path $ResSourceDir -Destination $StagingDir -Recurse -Force
    }

    # Copy Core Engine DLL(s) to the root where the UXP JS will look for them
    $CoreDll = Get-Item -Path "$PackageSourceDir\*.dll" -ErrorAction SilentlyContinue
    if ($CoreDll) {
        Copy-Item -Path $CoreDll.FullName -Destination $StagingDir -Force
        Write-Host "  -> Bundled core engine: $($CoreDll.Name)" -ForegroundColor DarkGray
    }

    Write-Host "  -> Staging assembly complete." -ForegroundColor Green
} catch {
    Write-Host "  -> ERROR: Failed to assemble staging directory." -ForegroundColor Red
    Write-Host "  -> $_" -ForegroundColor Red
    # Cleanup staging dir if it was partially created
    if (Test-Path $StagingDir) { Remove-Item -Path $StagingDir -Recurse -Force }
    exit 1
}

# --------------------------------------------------------------------------
# 4. Create Final ZIP Archive
# --------------------------------------------------------------------------
Write-Host "[4/4] Compressing to '$OutputName'..." -ForegroundColor Yellow
try {
    # Remove old zip if it exists to prevent Compress-Archive from failing
    if (Test-Path -Path $OutputPath -PathType Leaf) {
        Remove-Item -Path $OutputPath -Force
    }

    Compress-Archive -Path "$StagingDir\*" -DestinationPath $OutputPath -CompressionLevel Optimal
    
    Write-Host ""
    Write-Host "======================================================" -ForegroundColor Green
    Write-Host " SUCCESS: UXP Extension packaged successfully!" -ForegroundColor Green
    Write-Host " Output:   $OutputPath" -ForegroundColor Green
    Write-Host " Size:     $([math]::Round((Get-Item $OutputPath).Length / 1KB, 2)) KB" -ForegroundColor Green
    Write-Host "======================================================" -ForegroundColor Green
} catch {
    Write-Host "  -> ERROR: Failed to compress archive." -ForegroundColor Red
    Write-Host "  -> $_" -ForegroundColor Red
    exit 1
} finally {
    # Always cleanup the temporary staging directory
    if (Test-Path -Path $StagingDir) {
        Remove-Item -Path $StagingDir -Recurse -Force | Out-Null
    }
}
