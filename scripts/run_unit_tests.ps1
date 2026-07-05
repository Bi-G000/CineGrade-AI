<#
.SYNOPSIS
    Executes CineGrade AI C++ test suites and generates a formatted summary.
.DESCRIPTION
    Runs Unit, Performance, and Regression tests via CTest. Validates the 
    existence of the testing infrastructure and returns a non-zero exit code 
    if any critical test fails.
.PARAMETER Config
    The build configuration to test (Default: "Release").
.EXAMPLE
    .\run_unit_tests.ps1 -Config Debug
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Debug", "Release")]
    [string]$Config = "Release"
)

 $ErrorActionPreference = "Continue"
Set-StrictMode -Version Latest

 $ProjectRoot = Split-Path -Parent $PSScriptRoot
 $BuildDir = Join-Path -Path $ProjectRoot -ChildPath "build"

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host " CineGrade AI - Test Runner [$Config]" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

# --------------------------------------------------------------------------
# 1. Validate Test Infrastructure
# --------------------------------------------------------------------------
Write-Host "[1/3] Validating test environment..." -ForegroundColor Yellow

if (-not (Test-Path -Path $BuildDir -PathType Container)) {
    Write-Host "  -> ERROR: Build directory '$BuildDir' does not exist." -ForegroundColor Red
    Write-Host "  -> Please run the build scripts first." -ForegroundColor Red
    exit 1
}

 $ctestPath = Get-Command "ctest" -ErrorAction SilentlyContinue
if (-not $ctestPath) {
    Write-Host "  -> ERROR: 'ctest' command not found. Ensure CMake is installed and in PATH." -ForegroundColor Red
    exit 1
}
Write-Host "  -> Environment validated." -ForegroundColor Green

# --------------------------------------------------------------------------
# 2. Execute Test Suites
# --------------------------------------------------------------------------
Write-Host "[2/3] Executing test suites..." -ForegroundColor Yellow
Write-Host ""

# Define the test suites based on CMake LABELS
 $TestSuites = @(
    @{ Label = "unit";       Name = "Unit Tests";       IsCritical = $true }
    @{ Label = "performance"; Name = "Performance Tests"; IsCritical = $false }
    @{ Label = "regression";  Name = "Regression Tests";  IsCritical = $true }
)

 $Summary = @{}
 $OverallFailure = $false

foreach ($Suite in $TestSuites) {
    Write-Host "  > Running $($Suite.Name)..." -ForegroundColor White
    
    # Run CTest for the specific label
    # --output-on-failure: Prints test output only if the test fails
    # --timeout: Prevents hanging tests (e.g., 60 seconds)
    $TestOutput = & ctest -C $Config -L $Suite.Label --output-on-failure --timeout 60 2>&1
    $ExitCode = $LASTEXITCODE
    
    # Parse CTest output for summary stats
    $PassedCount = 0
    $FailedCount = 0
    
    foreach ($Line in $TestOutput) {
        if ($Line -match "(\d+) tests passed") { $PassedCount = [int]$Matches[1] }
        if ($Line -match "(\d+) tests failed") { $FailedCount = [int]$Matches[1] }
    }

    # Record results
    $Summary[$Suite.Name] = @{
        Passed  = $PassedCount
        Failed  = $FailedCount
        Status  = if ($FailedCount -gt 0) { "FAIL" } else { "PASS" }
        Critical = $Suite.IsCritical
    }

    if ($FailedCount -gt 0) {
        Write-Host "    - Result: FAILED ($FailedCount failed, $PassedCount passed)" -ForegroundColor Red
        if ($Suite.IsCritical) { $OverallFailure = $true }
    } else {
        Write-Host "    - Result: PASSED ($PassedCount passed)" -ForegroundColor Green
    }
    Write-Host ""
}

# --------------------------------------------------------------------------
# 3. Generate Summary
# --------------------------------------------------------------------------
Write-Host "[3/3] Test Summary" -ForegroundColor Yellow
Write-Host "------------------------------------------------------" -ForegroundColor Gray

foreach ($Key in $Summary.Keys) {
    $Data = $Summary[$Key]
    $Color = if ($Data.Status -eq "PASS") { "Green" } else { "Red" }
    $CritMark = if ($Data.Critical) { "[CRITICAL]" } else { "[OPTIONAL]" }
    
    Write-Host ("{0,-25} {1,-12} {2,-10} Passed: {3}" -f $Key, $CritMark, $Data.Status, $Data.Passed) -ForegroundColor $Color
}

Write-Host "------------------------------------------------------" -ForegroundColor Gray

if ($OverallFailure) {
    Write-Host "OVERALL RESULT: FAILED" -ForegroundColor Red
    Write-Host "======================================================" -ForegroundColor Red
    exit 1
} else {
    Write-Host "OVERALL RESULT: SUCCESS" -ForegroundColor Green
    Write-Host "======================================================" -ForegroundColor Green
    exit 0
}
