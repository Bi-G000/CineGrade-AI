# Changelog

All notable changes to the CineGrade AI project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2024-01-01

### Added
- Initial project scaffolding with C++20 and Visual Studio 2022 support.
- `CMakeLists.txt` configuration for Windows x64 Debug/Release builds.
- Base UXP UI integration (`manifest.json`, HTML/JS/CSS shell).
- Core `L*a*b*` color space conversion algorithms (`RgbToLabConverter`, `LabToRgbConverter`).
- ONNX Runtime environment setup and base `U2NetSubjectSegmentation` class structure.
- LittleCMS (lcms2) dependency setup for ICC profile handling.
- Foundation for the Object Pooling memory management architecture.
- Base Inno Setup scripts for Windows installer and silent uninstaller.
- Comprehensive `.gitignore` and `.editorconfig` for cross-team standardization.

### Changed
- N/A (Initial baseline release)

### Fixed
- N/A (Initial baseline release)

### Planned
- Implementation of AI Mask Multiplication pipeline (connecting ONNX output to pixel buffers).
- Cosine Bell Curve Falloff math for Cinematic Color Wheels.
- Three-way Color Wheels UI rendering and backend logic.
- Smart Auto Curves anchor point calculation and UI projection.
- Total Ink Coverage (TIC) calculation engine for Prepress module.
- FOGRA39/GRACoL Soft-Proofing rendering pipeline.
- "Flatten & Bake" and "Generate Look LUT" master export commands.
- Halftone dot matrix generation algorithms.
- OpenCL GPU acceleration kernels for real-time tile rendering.
- Unit and performance testing frameworks.
