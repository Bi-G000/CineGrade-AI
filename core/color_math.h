#ifndef COLOR_MATH_H
#define COLOR_MATH_H

#include <cmath>

// Cấu trúc điểm neo cho Curves UI (D#10)
struct AnchorPoint {
    float x; // Input Luminance (0.0 - 1.0)
    float y; // Output Luminance (0.0 - 1.0)
};

// Cấu trúc màu L*a*b*
struct LabColor {
    float L; // Lightness (0 to 100)
    float a; // Green to Red (-128 to 127)
    float b; // Blue to Yellow (-128 to 127)
};

// Cấu trúc màu RGB chuẩn
struct RGBColor {
    float r, g, b; // (0.0 to 1.0)
};

class CineGradeMath {
public:
    // Chuyển đổi RGB sang L*a*b* (Thuật toán cốt lõi D#11, D#12)
    static LabColor RGBtoLab(RGBColor rgb) {
        // Bước 1: RGB -> Linear RGB (Gamma Correction)
        float r_lin = (rgb.r > 0.04045f) ? pow((rgb.r + 0.055f) / 1.055f, 2.4f) : rgb.r / 12.92f;
        float g_lin = (rgb.g > 0.04045f) ? pow((rgb.g + 0.055f) / 1.055f, 2.4f) : rgb.g / 12.92f;
        float b_lin = (rgb.b > 0.04045f) ? pow((rgb.b + 0.055f) / 1.055f, 2.4f) : rgb.b / 12.92f;

        // Bước 2: Linear RGB -> XYZ (D65 Illuminant)
        float x = (r_lin * 0.4124564f) + (g_lin * 0.3575761f) + (b_lin * 0.1804375f);
        float y = (r_lin * 0.2126729f) + (g_lin * 0.7151522f) + (b_lin * 0.0721750f);
        float z = (r_lin * 0.0193339f) + (g_lin * 0.1191920f) + (b_lin * 0.9503041f);

        // Bước 3: XYZ -> L*a*b*
        x = x / 0.95047f; y = y / 1.00000f; z = z / 1.08883f;
        
        x = (x > 0.008856f) ? pow(x, 1.0f / 3.0f) : (7.787f * x) + 16.0f / 116.0f;
        y = (y > 0.008856f) ? pow(y, 1.0f / 3.0f) : (7.787f * y) + 16.0f / 116.0f;
        z = (z > 0.008856f) ? pow(z, 1.0f / 3.0f) : (7.787f * z) + 16.0f / 116.0f;

        LabColor lab;
        lab.L = (116.0f * y) - 16.0f;
        lab.a = 500.0f * (x - y);
        lab.b = 200.0f * (y - z);
        return lab;
    }

    // Công thức Mask Multiplication (D#11)
    static RGBColor ApplyColorWheelShift(RGBColor original, LabColor shiftAmount, float luminanceFalloff, float aiBackgroundMask) {
        // Chỉ áp dụng nếu AI mask xác định đây là Background (mask = 1.0)
        // Lưu ý: Cần chuyển shiftAmount về RGB trước khi cộng
        // Pseudo-code rút gọn cho Devs tiếp nối:
        // finalColor = original + (shiftAmount * luminanceFalloff * aiBackgroundMask);
        return original; // Devs sẽ implement phần cộng phức tạp ở file .cpp
    }
};

#endif
