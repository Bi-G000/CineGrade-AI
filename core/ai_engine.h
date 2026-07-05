#ifndef AI_ENGINE_H
#define AI_ENGINE_H

#include <vector>
#include "color_math.h"

// Khai báo trước class của ONNX (Devs sẽ include thư viện thật ở file .cpp)
namespace Ort { class Session; class Env; }

class TheEye {
private:
    Ort::Env* env;
    Ort::Session* session;
    bool isModelLoaded;

public:
    TheEye();
    ~TheEye();

    // Load mô hình U2-Net v1.2 (D#10)
    bool InitializeModel(const char* modelPath); 

    // Chạy suy luận (Inference) và trả về Background Mask (Mảng 1 chiều float từ 0.0 đến 1.0)
    // width, height là kích thước Artboard
    std::vector<float> GetBackgroundMask(unsigned char* pixelData, int width, int height);
};

#endif
