// CineGrade AI - UI Logic Layer (UXP)
const { entrypoints } = require("uxp");

entrypoints.setup({
    panels: {
        cinegrade: {
            show(event) {
                console.log("CineGrade AI Panel Loaded.");
            }
        }
    }
});

// Hàm gọi C++ Core Engine xử lý ảnh (Bắt buộc bất đồng bộ)
async function applyAICurves() {
    try {
        // Gọi xuống C++ layer thông qua bindding nội bộ
        const result = await require("uxp").host.executeAsModal(async (executionContext) => {
            // Truyền cờ hiệu cho C++ biết: Chạy ONNX -> Tính L*a*b* -> Trả về điểm neo Curves
            return await window.cepBridge.evaluateScript(`calculateSmartCurves("L*a*b*", true)`);
        });
        
        if (result.success) {
            console.log("AI Anchor Points:", result.anchorPoints);
            // Gọi hàm vẽ lại đồ thị Curves ở UI
            drawCurvesUI(result.anchorPoints);
        }
    } catch (error) {
        console.error("Lỗi Engine:", error);
    }
}

// Hàm Generate LUT (D#13)
async function generateLookLUT() {
    const result = await window.cepBridge.evaluateScript(`exportLUTCube("33x33x33")`);
    if(result.path) {
        alert(`Đã xuất LUT tại: ${result.path}`);
    }
}
