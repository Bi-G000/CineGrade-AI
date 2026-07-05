# CineGrade AI - Product Roadmap

This document outlines the strategic development phases for CineGrade AI, from initial infrastructure setup to the Golden Master release.

---

## Phase 1: Foundation
**Objective:** Establish build systems, repository structure, and base interfaces.
- [x] Configure CMake build system for Visual Studio 2022 (x64, C++20).
- [x] Setup repository structure, `.gitignore`, and `.editorconfig`.
- [x] Define public API headers in `include/` (Interfaces for Color, Image, AI).
- [x] Initialize UXP panel manifest and basic HTML/JS shell.
- [x] Integrate third-party dependencies (ONNX Runtime, LittleCMS) into `third_party/`.

## Phase 2: Core Engine
**Objective:** Implement low-level memory and image handling without external dependencies.
- [ ] Implement `MemoryManager` with Object Pooling for pixel buffers.
- [ ] Develop `ArtboardPixelBuffer` for safe read/write access to Illustrator canvas data.
- [ ] Setup threading primitives and Mutex locks for thread-safe UI/Engine communication.
- [ ] Create the `ILogger` and `IPerformanceProfiler` utilities.

## Phase 3: Color Engine
**Objective:** Build the mathematical core for all color transformations.
- [ ] Implement `RgbToLabConverter` and `LabToRgbConverter` (D65 Illuminant).
- [ ] Develop `BezierCurveInterpolator` for Curves adjustment.
- [ ] Implement `BlackWhitePointClipping` for Levels adjustment.
- [ ] Build `CubeLutParser` and `ThreeDLutApplier`.
- [ ] Integrate LittleCMS for ICC Profile loading and `Relative Colorimetric` rendering intent.

## Phase 4: AI Engine
**Objective:** Integrate local machine learning for subject isolation.
- [ ] Implement `OnnxRuntimeEnvironment` initialization and session management.
- [ ] Integrate `U2NetSubjectSegmentation` (v1.2 model).
- [ ] Implement input preprocessing (downsampling, normalization) for ONNX.
- [ ] Implement output post-processing to extract the binary Background Mask.
- [ ] Optimize inference to meet the < 30ms benchmark.

## Phase 5: Illustrator Integration
**Objective:** Bridge the C++ Engine with the Adobe Illustrator SDK.
- [ ] Implement `SuiteAcquisition` to safely grab required Adobe SDK suites.
- [ ] Develop `ArtboardHandleWrapper` to extract pixel data from the active document.
- [ ] Create the `INonDestructiveStack` to queue filter operations without mutating original art.
- [ ] Implement base Command classes (`IApplyCurvesCommand`, etc.) tied to Illustrator's undo/redo history.

## Phase 6: UI/UX
**Objective:** Build the interactive frontend controls in UXP.
- [ ] Design and implement the Curves UI (Canvas-based graph with draggable anchor points).
- [ ] Design and implement the 3-Way Color Wheels (Joystick controls).
- [ ] Build the "The Eye" AI toggle and visual overlay system.
- [ ] Implement the Prepress Panel (ICC selector, TIC Warning display).
- [ ] Create Master Export UI ("Flatten & Bake", "Generate Look LUT").

## Phase 7: Performance
**Objective:** Optimize bottlenecks to achieve zero-latency interaction.
- [ ] Implement `OpenCLContextManager` for GPU acceleration.
- [ ] Port L*a*b* conversions and LUT applications to OpenCL kernels.
- [ ] Optimize the `Mask Multiplication` formula to run on the GPU.
- [ ] Implement tile-based rendering (`RealtimeTileRenderer`) for large artboards.

## Phase 8: Testing
**Objective:** Ensure mathematical accuracy and system stability.
- [ ] Write Unit Tests for L*a*b* math, Curves interpolation, and Histogram separation.
- [ ] Write Regression Tests for "Knockout Text Bleeding" and "Hard Clip Artifacts".
- [ ] Write Performance Benchmarks for ONNX inference and GPU kernel compilation.
- [ ] Conduct 48-hour stress tests for Memory Leaks during Artboard switching.

## Phase 9: Public Beta
**Objective:** Release to a closed group for real-world feedback.
- [ ] Finalize Inno Setup installer with silent uninstall scripts.
- [ ] Implement crash reporting telemetry (anonymized).
- [ ] Distribute to selected typography studios and prepress houses.
- [ ] Gather feedback and fix critical P0/P1 bugs.

## Phase 10: v1.0 Release
**Objective:** Golden Master build for production.
- [ ] Lock feature set.
- [ ] Final UI polish and localization (EN, VI, JP).
- [ ] Compile final Release binaries.
- [ ] Publish documentation and developer guides.
- [ ] Deploy to distribution servers.
