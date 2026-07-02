🎨 CINEGRADE AI PLUGIN FOR ILLUSTRATOR
Phiên bản: Golden Master (GM) v1.0
Loại tài liệu: Bản vẽ Kỹ thuật (Technical Blueprint & Specification)
Phạm vi: Deliverable #9 đến #13

MỤC LỤC (TABLE OF CONTENTS)
1. Tổng quan Kiến trúc
2. Thông số Kỹ thuật Cốt lõi
3. Chi tiết Tính năng (Modules)
4. Hướng dẫn Đóng gói & Triển khai
5. Nợ Kỹ thuật & Lộ trình Tương lai
1. TỔNG QUAN KIẾN TRÚC (ARCHITECTURE OVERVIEW)
Plugin hoạt động theo kiến trúc 3 lớp (3-Tier Architecture) để đảm bảo UI không bị giật lag khi xử lý nặng:

Presentation Layer (UI): Sử dụng Adobe UXP (HTML/CSS/JavaScript). Chịu trách nhiệm vẽ Color Wheels, biểu đồ Curves và nhận input chuột.
Core Engine Layer (Xử lý màu): Viết bằng C++ (dùng Illustrator SDK). Chịu trách nhiệm tính toán toán học màu Lab*, quản lý bộ nhớ (Object Pooling), và tương tác trực tiếp với Pixel của Artboard.
AI Inference Layer (Mô hình): Chạy lồng ghép trong C++ thông qua ONNX Runtime. Chịu trách nhiệm nhận diện Subject (The Eye) và xuất ra Alpha Mask.
2. THÔNG SỐ KỸ THUẬT CỐT LÕI (CORE SPECS)
Hệ điều hành hỗ trợ: Windows 10/11 (64-bit), macOS 11+ (Universal Binary).
AI Framework: Bắt buộc dùng ONNX Runtime C++ API (Không dùng CoreML hay TFLite để giữ tính đồng nhất cross-platform).
Không gian màu mặc định: Toàn bộ tính toán Curves và Color Wheels phải chuyển đổi qua Lab* trước khi tính toán, sau đó chuyển ngược lại RGB/CMYK để tránh dịch chuyển Hue (Hue Shift).
Benchmark Target: Inference Time < 30ms. RAM Idle < 15MB. Artboard switching < 16ms.
3. CHI TIẾT TÍNH NĂNG (FEATURES SPECIFICATIONS)
MODULE 1: WORKFLOW INTEROPERABILITY (D#9)
LUT 3D Engine: Phải hỗ trợ đọc/ghi định dạng .cube (3D LUT) chuẩn ngành.
Gradient Map Optimizer: Bắt buộc bật cơ chế Hardware Acceleration (GPU) để render gradient map lên typography trong < 5ms. Cấm dùng CPU loop thông thường.
MODULE 2: AI ENGINE & SMART AUTO ADJUSTMENTS (D#10)
Mô hình sử dụng: Biến thể U2-Net (Khoảng 11.2MB).
Dataset Fine-tune (QUAN TRỌNG): Mô hình gốc không dùng được. Phải fine-tune lại trên tập dữ liệu chứa "Knockout Typography trên Gradient Mesh" kèm Boundary Loss để tránh Mask Bleeding. Tên mã nội bộ: the_eye_v1.2.onnx.
Luồng Smart Curves:
ONNX xuất ra Saliency Mask (< 30ms).
Đảo ngược Mask thành Background Mask.
Cắt lập Histogram riêng cho vùng Background.
Tính toán điểm Black/White point trong không gian Lab*.
UI Output: KHÔNG apply trực tiếp vào pixel. Phải tính toán ngược các giá trị này thành Tọa độ (X, Y) và đẩy lên đồ thị Curves UI dưới dạng các "Anchor Points" ảo để user có thể chỉnh sửa tay (Non-destructive).
MODULE 3: CINEMATIC COLOR WHEELS (D#11)
Giao diện: 3 bánh xe Joystick (Shadows, Midtones, Highlights). Render bằng Pixmap 256x256 để tốn 0% CPU lúc idle.
Thuật toán Falloff: Dùng Cosine-based Bell Curves để chia vùng Luminance. TUYỆT ĐỐI KHÔNG DÙNG ngưỡng cắt cứng (Hard threshold) để tránh Color Banding.
Mask Multiplication (Công thức lõi):
// Pseudo-code cho toán học áp dụng màuFinal_Pixel = Original_Pixel + (Color_Shift_Array * Luminance_BellCurve_Array * Inverted_AI_Mask_Array);
Xử lý Gamut: Sử dụng Hard Clip (Cắt cứng tại biên sRGB). Bật thêm tính năng Gamut Warning Overlay (Lớp phủ màu đỏ Opacity 50%) trực tiếp lên canvas cho các pixel bị vượt ngưỡng.
MODULE 4: ADVANCED SOFT-PROOFING & PREPRESS (D#12)
ICC CMM: Gọi trực tiếp ColorSync (Mac) và WCS (Windows) API. Cấm gọi API của Adobe (quá chậm).
Rendering Intent: Khóa cứng ở Relative Colorimetric + Black Point Compensation (BPC). (Tối ưu cho Poster/Vector, tránh làm nhạt màu).
TIC Engine (Total Ink Coverage): Tính toán C + M + Y + K. Ngưỡng cảnh báo mặc định: 300% (Cho giấy Couche). Cho phép người dùng tùy chỉnh.
Hiển thị Lỗi: Tích hợp ngay Module 3. Nếu một pixel vừa bị đẩy màu bằng Color Wheels, vừa vượt 300% TIC -> Phủ lớp màu Đỏ Đặc (Hard Overlay). Không dùng viền đỏ (Outline).
MODULE 5: ZERO-LATENCY & MASTER EXPORT (D#13)
Memory Management: Bắt buộc dùng Object Pooling cho Pixel Buffers. Đặt Mutex locks ở mọi điểm giao tiếp giữa UXP (JS) và C++ Core để tránh Illustrator Crash (Thread Safety).
Nút "Flatten & Bake": Chạy một lượt render cuối cùng qua toàn bộ pipeline, ghi đè lên Pixel Layer, sau đó tự động xóa toàn bộ Extension Data khỏi file .AI để giảm dung lượng.
Nút "Generate Look LUT":
Tạo một lưới màu 3D giả lập (Identity Grid 33x33x33 điểm màu).
Đẩy lưới này qua toàn bộ thuật toán (AI Mask -> Curves -> Wheels).
Ghi các giá trị đầu ra ra file định dạng .cube chuẩn.
4. HƯỚNG DẪN ĐÓNG GÓI & TRIỂN KHAI (DEPLOYMENT)
4.1. Cấu trúc Source Code (Payload)
CineGradeAI_Source/├── core/                  # Thư viện .dll / .so & ONNX Runtime│   ├── CineGradeEngine.dll│   ├── onnxruntime.dll│   └── models/│       └── the_eye_v1.2.onnx├── ui/                    # Manifest, HTML, CSS, JS của UXP│   ├── manifest.json│   ├── index.html│   ├── main.js│   └── styles.css└── uninstaller/           # Script cleanup    └── cleanup.bat
4.2. Yêu cầu Installer (Dùng Inno Setup cho Windows)
Biên dịch ra 1 file duy nhất: CineGradeAI_Setup.exe.
Chức năng tự động: Phải dùng script để tự động dò tìm đường dẫn {userappdata}\Adobe\Adobe Illustrator [Phiên bản]\Plugables\UXP\ và dùng xcopy silent đẩy toàn bộ source vào đó. User chỉ được phép bấm Next -> Install.
4.3. Yêu cầu Uninstaller (Dọn sạch 100%)
Khi bấm Uninstall (từ Control Panel Windows hoặc nút bấm trong UI Plugin), phải chạy script dọn dẹp:
Xóa thư mục plugin trong AppData\Roaming\Adobe\...
Xóa file cấu hình .json / .plist liên quan.
Dọn dẹp Registry/PLIST.
Quy tắc tối thượng: Không được xóa bất kỳ file hệ thống nào của Adobe Illustrator.
5. NỢ KỸ THUẬT & LỘ TRÌNH TƯƠNG LAI (TECH DEBT)
[D#11-Future] Soft Gamut Compression: Hiện tại đang dùng Hard Clip cho Color Wheels. Cần nâng cấp lên Perceptual Renderer Intent trong các phiên bản v2.x để giữ nguyên chi tiết Highlight khi đẩy màu quá mạnh.
[D#10-Future] Fine-tune qua Edge Devices: Tối ưu hóa ONNX model bằng Quantization (INT8) để giảm RAM tiêu thụ xuống dưới 5MB cho các máy tính cấu hình thấp.
© CineGrade AI Technical Team - Internal Use Only
