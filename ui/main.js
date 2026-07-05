'use strict';

let CineGradeCore = null;
let coreError = null;

try {
    CineGradeCore = require('./CineGradeCore.node');
    if (!CineGradeCore) {
        throw new Error("CineGradeCore.node resolved to null.");
    }
} catch (e) {
    coreError = e.message || "Unknown error loading native module.";
}

class StatusController {
    constructor(elementId) {
        this.element = document.getElementById(elementId);
        this.timeout = null;
    }

    show(message, type = 'info') {
        if (!this.element) return;
        this.element.textContent = message;
        this.element.className = `status-message status-${type}`;
        this.element.style.display = 'block';

        if (this.timeout) clearTimeout(this.timeout);
        if (type !== 'error') {
            this.timeout = setTimeout(() => {
                this.element.style.display = 'none';
            }, 3000);
        }
    }

    destroy() {
        if (this.timeout) clearTimeout(this.timeout);
        if (this.element) {
            this.element.style.display = 'none';
            this.element.textContent = '';
            this.element.className = '';
        }
    }
}

class CurvesController {
    constructor(canvasId) {
        this.canvas = document.getElementById(canvasId);
        if (!this.canvas) return;
        
        this.ctx = this.canvas.getContext('2d');
        this.width = this.canvas.width;
        this.height = this.canvas.height;
        this.anchor = { x: 0.5, y: 0.5 };
        this.isDragging = false;

        this._onPointerDown = this._handlePointerDown.bind(this);
        this._onPointerMove = this._handlePointerMove.bind(this);
        this._onPointerUp = this._handlePointerUp.bind(this);

        this.canvas.addEventListener('pointerdown', this._onPointerDown);
        this.canvas.addEventListener('pointermove', this._onPointerMove);
        this.canvas.addEventListener('pointerup', this._onPointerUp);
        
        this.render();
    }

    _handlePointerDown(e) {
        const pos = this._getPos(e);
        const ax = this.anchor.x * this.width;
        const ay = (1 - this.anchor.y) * this.height;
        
        if (Math.hypot(pos.x - ax, pos.y - ay) < 15) {
            this.isDragging = true;
            this.canvas.setPointerCapture(e.pointerId);
        }
    }

    _handlePointerMove(e) {
        if (!this.isDragging) return;
        const pos = this._getPos(e);
        this.anchor.x = Math.max(0, Math.min(1, pos.x / this.width));
        this.anchor.y = Math.max(0, Math.min(1, 1 - (pos.y / this.height)));
        this.render();
    }

    _handlePointerUp() {
        if (this.isDragging) {
            this.isDragging = false;
            this.syncWithEngine();
        }
    }

    _getPos(e) {
        const rect = this.canvas.getBoundingClientRect();
        const scaleX = this.width / rect.width;
        const scaleY = this.height / rect.height;
        return {
            x: (e.clientX - rect.left) * scaleX,
            y: (e.clientY - rect.top) * scaleY
        };
    }

    syncWithEngine() {
        if (CineGradeCore && CineGradeCore.updateCurveAnchor) {
            CineGradeCore.updateCurveAnchor(this.anchor.x, this.anchor.y);
        }
    }

    render() {
        const ctx = this.ctx;
        const w = this.width;
        const h = this.height;
        
        ctx.clearRect(0, 0, w, h);
        ctx.fillStyle = '#1e1e1e';
        ctx.fillRect(0, 0, w, h);

        ctx.strokeStyle = '#3c3c3c';
        ctx.lineWidth = 1;
        for (let i = 0; i <= 4; i++) {
            const p = (i / 4) * w;
            ctx.beginPath(); ctx.moveTo(p, 0); ctx.lineTo(p, h); ctx.stroke();
            ctx.beginPath(); ctx.moveTo(0, p); ctx.lineTo(w, p); ctx.stroke();
        }

        ctx.strokeStyle = '#5a5a5a';
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(0, h);
        ctx.lineTo(w, 0);
        ctx.stroke();

        ctx.strokeStyle = '#e0e0e0';
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.moveTo(0, h);
        
        const cpx = this.anchor.x * w;
        const cpy = (1 - this.anchor.y) * h;
        ctx.quadraticCurveTo(cpx, cpy, w, 0);
        ctx.stroke();

        ctx.fillStyle = '#ffffff';
        ctx.beginPath();
        ctx.arc(cpx, cpy, 5, 0, Math.PI * 2);
        ctx.fill();
        
        ctx.strokeStyle = '#000000';
        ctx.lineWidth = 1;
        ctx.stroke();
    }

    destroy() {
        if (!this.canvas) return;
        this.canvas.removeEventListener('pointerdown', this._onPointerDown);
        this.canvas.removeEventListener('pointermove', this._onPointerMove);
        this.canvas.removeEventListener('pointerup', this._onPointerUp);
    }
}

class ColorWheelController {
    constructor(canvasId, dotId, channel) {
        this.canvas = document.getElementById(canvasId);
        if (!this.canvas) return;

        this.ctx = this.canvas.getContext('2d');
        this.dot = document.getElementById(dotId);
        this.channel = channel;
        this.size = this.canvas.width;
        this.center = this.size / 2;
        this.radius = this.size / 2 - 5;
        
        this.angle = 0;
        this.offset = 0; 
        this.isDragging = false;

        this._onPointerDown = this._handlePointerDown.bind(this);
        this._onPointerMove = this._handlePointerMove.bind(this);
        this._onPointerUp = this._handlePointerUp.bind(this);
        
        this.drawWheel();
        
        this.canvas.addEventListener('pointerdown', this._onPointerDown);
        this.canvas.addEventListener('pointermove', this._onPointerMove);
        this.canvas.addEventListener('pointerup', this._onPointerUp);
    }

    _handlePointerDown(e) {
        this.isDragging = true;
        this.canvas.setPointerCapture(e.pointerId);
        this._updateUI(e);
    }

    _handlePointerMove(e) {
        if (!this.isDragging) return;
        this._updateUI(e);
    }

    _handlePointerUp() {
        this.isDragging = false;
    }

    _updateUI(e) {
        const { angle, offset } = this._getAngleOffset(e);
        this.angle = angle;
        this.offset = offset;
        this.updateDotPosition();
        this.syncWithEngine();
    }

    _getAngleOffset(e) {
        const rect = this.canvas.getBoundingClientRect();
        const scaleX = this.size / rect.width;
        const x = (e.clientX - rect.left) * scaleX - this.center;
        const y = (e.clientY - rect.top) * scaleX - this.center;
        
        let angle = Math.atan2(y, x) * (180 / Math.PI);
        if (angle < 0) angle += 360;
        
        const dist = Math.hypot(x, y);
        const offset = Math.min(dist / this.radius, 1.0);
        return { angle, offset };
    }

    updateDotPosition() {
        const rad = this.angle * (Math.PI / 180);
        const dist = this.offset * this.radius;
        const x = this.center + (dist * Math.cos(rad));
        const y = this.center + (dist * Math.sin(rad));
        
        const xPercent = (x / this.size) * 100;
        const yPercent = (y / this.size) * 100;
        
        this.dot.style.left = `${xPercent}%`;
        this.dot.style.top = `${yPercent}%`;
    }

    syncWithEngine() {
        if (CineGradeCore && CineGradeCore.updateColorWheel) {
            CineGradeCore.updateColorWheel(this.channel, this.angle, this.offset);
        }
    }

    drawWheel() {
        const ctx = this.ctx;
        const center = this.center;
        const radius = this.radius;
        
        for (let angle = 0; angle < 360; angle += 1) {
            const startAngle = (angle - 1) * (Math.PI / 180);
            const endAngle = (angle + 1) * (Math.PI / 180);
            
            ctx.beginPath();
            ctx.moveTo(center, center);
            ctx.arc(center, center, radius, startAngle, endAngle);
            ctx.closePath();
            ctx.fillStyle = `hsl(${angle}, 100%, 50%)`;
            ctx.fill();
        }
        
        const gradient = ctx.createRadialGradient(center, center, 0, center, center, radius);
        gradient.addColorStop(0, 'rgba(0,0,0,0.6)');
        gradient.addColorStop(1, 'rgba(0,0,0,0)');
        ctx.fillStyle = gradient;
        ctx.fillRect(0, 0, this.size, this.size);
    }

    reset() {
        this.angle = 0;
        this.offset = 0;
        this.updateDotPosition();
        this.syncWithEngine();
    }

    destroy() {
        if (!this.canvas) return;
        this.canvas.removeEventListener('pointerdown', this._onPointerDown);
        this.canvas.removeEventListener('pointermove', this._onPointerMove);
        this.canvas.removeEventListener('pointerup', this._onPointerUp);
    }
}

class Application {
    constructor() {
        this.status = null;
        this.curvesController = null;
        this.wheelShadows = null;
        this.wheelMidtones = null;
        this.wheelHighlights = null;
        this.isEyeActive = false;
        this.isPrepressActive = false;
        this.handlers = {};
    }

    init() {
        this.status = new StatusController('status-bar');
        
        if (coreError) {
            this.status.show(`Fatal: ${coreError}`, 'error');
        }

        this.initUI();
    }

    initUI() {
        this.curvesController = new CurvesController('curves-canvas');
        this.wheelShadows = new ColorWheelController('wheel-shadows', 'dot-shadows', 'shadows');
        this.wheelMidtones = new ColorWheelController('wheel-midtones', 'dot-midtones', 'midtones');
        this.wheelHighlights = new ColorWheelController('wheel-highlights', 'dot-highlights', 'highlights');

        const btnEye = document.getElementById('btn-toggle-eye');
        const btnAiSuggestion = document.getElementById('btn-apply-ai');
        const btnPrepress = document.getElementById('btn-toggle-prepress');
        const btnFlatten = document.getElementById('btn-flatten-bake');
        const btnGenerateLut = document.getElementById('btn-generate-lut');
        const btnUninstall = document.getElementById('btn-uninstall');
        const iccSelect = document.getElementById('icc-profile');
        const inputBlack = document.getElementById('input-black');
        const inputWhite = document.getElementById('input-white');

        this.handlers.onBtnEyeClick = () => {
            this.isEyeActive = !this.isEyeActive;
            btnEye.classList.toggle('active', this.isEyeActive);
            if (CineGradeCore && CineGradeCore.toggleEye) {
                CineGradeCore.toggleEye(this.isEyeActive);
            }
        };

        this.handlers.onBtnAiSuggestionClick = () => {
            btnAiSuggestion.disabled = true;
            btnAiSuggestion.textContent = 'Analyzing...';
            
            if (CineGradeCore && CineGradeCore.applyAiSuggestion) {
                try {
                    const result = CineGradeCore.applyAiSuggestion();
                    if (result && result.success) {
                        this.status.show('AI Suggestion applied', 'success');
                    } else {
                        this.status.show('AI Analysis failed', 'error');
                    }
                } catch (e) {
                    this.status.show('Engine Error', 'error');
                }
            } else {
                this.status.show('Core not loaded', 'error');
            }
            
            btnAiSuggestion.disabled = false;
            btnAiSuggestion.textContent = 'Apply AI Suggestion';
        };

        this.handlers.onInputBlack = () => {
            const display = document.getElementById('val-input-black');
            display.textContent = inputBlack.value;
            if (CineGradeCore && CineGradeCore.setInputBlack) {
                CineGradeCore.setInputBlack(parseInt(inputBlack.value, 10));
            }
        };

        this.handlers.onInputWhite = () => {
            const display = document.getElementById('val-input-white');
            display.textContent = inputWhite.value;
            if (CineGradeCore && CineGradeCore.setInputWhite) {
                CineGradeCore.setInputWhite(parseInt(inputWhite.value, 10));
            }
        };

        this.handlers.onBtnResetWheelsClick = () => {
            this.wheelShadows.reset();
            this.wheelMidtones.reset();
            this.wheelHighlights.reset();
        };

        this.handlers.onIccChange = () => {
            if (CineGradeCore && CineGradeCore.setIccProfile) {
                CineGradeCore.setIccProfile(iccSelect.value);
            }
        };

        this.handlers.onBtnPrepressClick = () => {
            this.isPrepressActive = !this.isPrepressActive;
            btnPrepress.classList.toggle('active', this.isPrepressActive);
            if (CineGradeCore && CineGradeCore.togglePrepressView) {
                CineGradeCore.togglePrepressView(this.isPrepressActive);
            }
        };

        this.handlers.onTicUpdate = (maxTic) => {
            const ticValueEl = document.getElementById('tic-value');
            const ticStatusEl = document.getElementById('tic-status');
            const overlay = document.getElementById('gamut-warning-overlay');
            
            ticValueEl.textContent = `${maxTic}%`;
            
            if (maxTic > 300) {
                ticStatusEl.textContent = 'OVER LIMIT';
                ticStatusEl.classList.add('over-limit');
                overlay.classList.add('active');
            } else {
                ticStatusEl.textContent = 'OK';
                ticStatusEl.classList.remove('over-limit');
                overlay.classList.remove('active');
            }
        };

        this.handlers.onBtnFlattenClick = () => {
            btnFlatten.disabled = true;
            btnFlatten.textContent = 'Processing...';
            if (CineGradeCore && CineGradeCore.flattenAndBake) {
                try {
                    CineGradeCore.flattenAndBake();
                    this.status.show('Flattened successfully', 'success');
                } catch (e) {
                    this.status.show('Flatten failed', 'error');
                }
            }
            btnFlatten.disabled = false;
            btnFlatten.textContent = 'Flatten & Bake';
        };

        this.handlers.onBtnGenerateLutClick = () => {
            btnGenerateLut.disabled = true;
            btnGenerateLut.textContent = 'Generating...';
            
            if (CineGradeCore && CineGradeCore.generateLookLut) {
                try {
                    const result = CineGradeCore.generateLookLut();
                    if (result && result.path) {
                        this.status.show(`Saved: ${result.path}`, 'success');
                    } else {
                        this.status.show('Export failed', 'error');
                    }
                } catch (e) {
                    this.status.show('Export Error', 'error');
                }
            }
            
            btnGenerateLut.disabled = false;
            btnGenerateLut.textContent = 'Generate Look LUT';
        };

        this.handlers.onBtnUninstallClick = () => {
            btnUninstall.disabled = true;
            btnUninstall.textContent = 'Uninstalling...';
            if (CineGradeCore && CineGradeCore.uninstallPlugin) {
                CineGradeCore.uninstallPlugin();
            }
        };

        btnEye.addEventListener('click', this.handlers.onBtnEyeClick);
        btnAiSuggestion.addEventListener('click', this.handlers.onBtnAiSuggestionClick);
        inputBlack.addEventListener('input', this.handlers.onInputBlack);
        inputWhite.addEventListener('input', this.handlers.onInputWhite);
        document.getElementById('btn-reset-wheels').addEventListener('click', this.handlers.onBtnResetWheelsClick);
        iccSelect.addEventListener('change', this.handlers.onIccChange);
        btnPrepress.addEventListener('click', this.handlers.onBtnPrepressClick);
        btnFlatten.addEventListener('click', this.handlers.onBtnFlattenClick);
        btnGenerateLut.addEventListener('click', this.handlers.onBtnGenerateLutClick);
        btnUninstall.addEventListener('click', this.handlers.onBtnUninstallClick);

        if (CineGradeCore && CineGradeCore.onTicUpdate) {
            CineGradeCore.onTicUpdate(this.handlers.onTicUpdate);
        }
    }

    destroy() {
        if (this.status) this.status.destroy();
        if (this.curvesController) this.curvesController.destroy();
        if (this.wheelShadows) this.wheelShadows.destroy();
        if (this.wheelMidtones) this.wheelMidtones.destroy();
        if (this.wheelHighlights) this.wheelHighlights.destroy();

        if (CineGradeCore && CineGradeCore.removeTicUpdate && this.handlers.onTicUpdate) {
            CineGradeCore.removeTicUpdate(this.handlers.onTicUpdate);
        }

        const remove = (id, event, handler) => {
            const el = document.getElementById(id);
            if (el && handler) el.removeEventListener(event, handler);
        };

        remove('btn-toggle-eye', 'click', this.handlers.onBtnEyeClick);
        remove('btn-apply-ai', 'click', this.handlers.onBtnAiSuggestionClick);
        remove('input-black', 'input', this.handlers.onInputBlack);
        remove('input-white', 'input', this.handlers.onInputWhite);
        remove('btn-reset-wheels', 'click', this.handlers.onBtnResetWheelsClick);
        remove('icc-profile', 'change', this.handlers.onIccChange);
        remove('btn-toggle-prepress', 'click', this.handlers.onBtnPrepressClick);
        remove('btn-flatten-bake', 'click', this.handlers.onBtnFlattenClick);
        remove('btn-generate-lut', 'click', this.handlers.onBtnGenerateLutClick);
        remove('btn-uninstall', 'click', this.handlers.onBtnUninstallClick);
        
        this.handlers = {};
    }
}

const app = new Application();

document.addEventListener('DOMContentLoaded', () => {
    app.init();
});
