#pragma once
namespace CineGrade {
class U2NetSegmentation{
public:
    bool LoadModel();
    bool Infer();
};
}
