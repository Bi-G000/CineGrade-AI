# Contributing to CineGrade AI

First off, thank you for taking the time to contribute to CineGrade AI! 

This guide outlines the processes and standards for contributing to this project. By following these guidelines, you help us maintain a high-quality, stable, and readable codebase.

---

## Table of Contents
- [Development Environment Setup](#development-environment-setup)
- [Coding Standards](#coding-standards)
- [Branch Strategy](#branch-strategy)
- [Commit Message Convention](#commit-message-convention)
- [Pull Request Workflow](#pull-request-workflow)
- [Code Review Rules](#code-review-rules)
- [Issue Reporting](#issue-reporting)
- [Bug Report Template](#bug-report-template)
- [Feature Request Template](#feature-request-template)

---

## Development Environment Setup

### Prerequisites
- **OS:** Windows 10/11 (x64)
- **Compiler:** Visual Studio 2022 with "Desktop development with C++" workload.
- **Build System:** CMake 3.21+
- **Python:** 3.8+ (for `tools/` scripts)
- **Git:** Latest version recommended.

### Initial Setup
1. Fork the repository and clone your fork locally.
   ```bash
   git clone https://github.com/YOUR_USERNAME/CineGrade-AI.git
   cd CineGrade-AI
   ```
2. Generate the Visual Studio solution using CMake:
   ```bash
   cmake -B build -G "Visual Studio 17 2022" -A x64
   ```
3. Open the generated `CineGradeAI.sln` in `build/` with Visual Studio.
4. Set the build configuration to `Debug` or `Release` and build the solution (Ctrl+Shift+B).

---

## Coding Standards

### C++ (Core Engine)
- **Standard:** C++20 strictly.
- **Naming Conventions:**
  - Classes/Structs/Namespaces: `PascalCase` (e.g., `ColorMathEngine`, `OnnxRuntimeEnvironment`).
  - Functions/Methods: `PascalCase` (e.g., `CalculateLuminance()`).
  - Variables: `camelCase` (e.g., `pixelBuffer`, `isModelLoaded`).
  - Members: `m_` prefix (e.g., `m_session`, `m_width`).
  - Constants/Enums: `kPascalCase` or `UPPER_SNAKE_CASE` (e.g., `kMaxTreshold`, `COLOR_SPACE_LAB`).
  - Interfaces: `I` prefix (e.g., `IImageBuffer`, `ICurveInterpolator`).
- **Memory Management:** 
  - Use `std::unique_ptr` and `std::shared_ptr`. Raw `new`/`delete` is strictly prohibited outside of low-level abstraction layers.
  - Pass by `const reference` for large objects.
- **Formatting:** Follow the `.clang-format` configuration if present, otherwise adhere to the `.editorconfig` rules (4 spaces, UTF-8).

### JavaScript/HTML/CSS (UXP UI)
- **Standard:** ECMAScript 6+ (ES6).
- **Naming Conventions:**
  - Variables/Functions: `camelCase`.
  - Classes/Constructors: `PascalCase`.
  - Constants: `UPPER_SNAKE_CASE`.
- **UI Best Practices:** 
  - Do not manipulate the DOM directly in loops. Use DocumentFragments.
  - Always unregister event listeners when the UXP panel is unloaded to prevent memory leaks.

---

## Branch Strategy

We use a simplified GitFlow workflow:
- `main`: Contains production-ready code only. Tags reflect version releases.
- `develop`: The active development branch. Contains the latest delivered features.
- `feature/<issue-id>-<short-desc>`: Branches created from `develop` for new features.
- `bugfix/<issue-id>-<short-desc>`: Branches created from `develop` (or `main` for hotfixes) to fix bugs.
- `release/<version>`: Preparation branches for release, allowing minor bug fixes and documentation updates.

---

## Commit Message Convention

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.

Format:
```
<type>(<scope>): <short summary>

<optional detailed description>
```

**Types:**
- `feat`: A new feature.
- `fix`: A bug fix.
- `docs`: Documentation only changes.
- `style`: Changes that do not affect the meaning of the code (white-space, formatting).
- `refactor`: A code change that neither fixes a bug nor adds a feature.
- `perf`: A code change that improves performance.
- `test`: Adding missing tests or correcting existing tests.
- `chore`: Changes to the build process or auxiliary tools.

**Example:**
```
feat(color): implement cosine bell curve falloff for color wheels

Replaces hard threshold luminance masking with cosine-based 
smooth transitions to eliminate color banding in shadows.
```

---

## Pull Request Workflow

1. **Update Branch:** Ensure your feature branch is up to date with `develop`.
   ```bash
   git fetch origin
   git rebase origin/develop
   ```
2. **Run Tests:** Ensure all unit tests pass locally and no new compiler warnings are introduced.
3. **Update Documentation:** If you added new public APIs, update the corresponding `.md` files in `docs/api/`.
4. **Submit PR:** Target the `develop` branch. Provide a clear title and description referencing the related Issue (e.g., "Resolves #12").
5. **CI Checks:** Your PR must pass all automated Continuous Integration checks before review.

---

## Code Review Rules

- **Approvals:** Require at least one approval from a core maintainer.
- **Size:** Keep PRs small and focused. If a PR exceeds 400 lines of code (excluding tests/docs), consider breaking it down.
- **Resolution:** All review comments must be addressed (resolved, fixed, or explicitly deferred with justification).
- **Self-Reviews:** Before requesting review, review your own diff to catch obvious mistakes or debug prints.

---

## Issue Reporting

Before creating a new issue, please search the existing issues to avoid duplicates. 

When reporting, be precise. Provide steps to reproduce, expected outcomes, and actual outcomes. Include system information (OS version, Illustrator version, Plugin version).

---

## Bug Report Template

```markdown
**Bug Description**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Open Illustrator file '...'
2. Go to '...'
3. Click on '....'
4. See error

**Expected Behavior**
A clear and concise description of what you expected to happen.

**Screenshots / Logs**
If applicable, add screenshots or paste the log output from the `FileLogger`.

**Environment (please complete the following information):**
 - OS: [e.g., Windows 11 23H2]
 - Illustrator Version: [e.g., v28.0]
 - Plugin Version: [e.g., v0.1.0]

**Additional Context**
Add any other context about the problem here.
```

---

## Feature Request Template

```markdown
**Problem Description**
A clear and concise description of what the problem is. Ex. I'm always frustrated when [...]

**Proposed Solution**
A clear and concise description of what you want to happen.

**Alternatives Considered**
A clear description of any alternative solutions or features you've considered.

**Additional Context**
Add any other context or screenshots about the feature request here.
```

