#include "color/RgbColorMath.h"
namespace CineGrade{float RgbColorMath::Clamp(float v){if(v<0)return 0;if(v>1)return 1;return v;}}