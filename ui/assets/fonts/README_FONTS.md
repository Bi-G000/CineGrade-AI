# Font Requirements

This directory must contain the web fonts used by the CineGrade AI UXP interface. 
Binary font files cannot be committed to the repository directly via this script. 
Please download them from their official sources and place them in this `ui/assets/fonts/` directory.

## 1. Primary UI Font

*   **Name:** Inter (Variable Font)
*   **Purpose:** Main interface typography for panels, buttons, and labels.
*   **Official Source:** [Inter GitHub Releases](https://github.com/rsms/inter/releases) or [rsms.me/inter](https://rsms.me/inter/)
*   **Required File:** `Inter-Variable.woff2`
*   **Destination:** `ui/assets/fonts/Inter-Variable.woff2`

## 2. Monospace Font (Optional but Recommended)

*   **Name:** JetBrains Mono
*   **Purpose:** Used for numerical readouts (e.g., TIC percentages, slider values) and developer console logs.
*   **Official Source:** [JetBrains Mono Website](https://www.jetbrains.com/lp/mono/)
*   **Required File:** `JetBrainsMono-Regular.woff2`
*   **Destination:** `ui/assets/fonts/JetBrainsMono-Regular.woff2`

## Instructions

1. Download the `.woff2` files from the links above.
2. Verify the filenames match exactly (case-sensitive).
3. Place the files directly into this `ui/assets/fonts/` folder.
4. Do not rename the files or convert them to other formats unless absolutely necessary for UXP compatibility.
