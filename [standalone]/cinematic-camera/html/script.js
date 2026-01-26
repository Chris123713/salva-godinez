const resourceName = GetParentResourceName();

// UI State
let cameraActive = false;
let uiActive = false;
let currentZoom = 50;
let currentSpeed = 'normal';

// DOM Elements
const cameraUI = document.getElementById('camera-ui');
const closeBtn = document.getElementById('closeBtn');
const toggleCameraBtn = document.getElementById('toggleCameraBtn');
const exitCameraBtn = document.getElementById('exitCameraBtn');
const toggleUIBtn = document.getElementById('toggleUIBtn');
const uiStatus = document.getElementById('uiStatus');
const zoomSlider = document.getElementById('zoomSlider');
const zoomValue = document.getElementById('zoomValue');
const zoomInBtn = document.getElementById('zoomInBtn');
const zoomOutBtn = document.getElementById('zoomOutBtn');
const zoomResetBtn = document.getElementById('zoomResetBtn');
const speedButtons = document.querySelectorAll('.speed-btn');
const resetViewBtn = document.getElementById('resetViewBtn');

// Event Listeners
closeBtn.addEventListener('click', () => {
    closeUI();
});

toggleCameraBtn.addEventListener('click', () => {
    toggleCamera();
});

exitCameraBtn.addEventListener('click', () => {
    exitCamera();
});

toggleUIBtn.addEventListener('click', () => {
    toggleUI();
});

zoomSlider.addEventListener('input', (e) => {
    const value = parseInt(e.target.value);
    updateZoom(value);
});

zoomInBtn.addEventListener('click', () => {
    const newZoom = Math.max(1, currentZoom - 5);
    updateZoom(newZoom);
    zoomSlider.value = newZoom;
});

zoomOutBtn.addEventListener('click', () => {
    const newZoom = Math.min(70, currentZoom + 5);
    updateZoom(newZoom);
    zoomSlider.value = newZoom;
});

zoomResetBtn.addEventListener('click', () => {
    const defaultZoom = 50;
    updateZoom(defaultZoom);
    zoomSlider.value = defaultZoom;
});

speedButtons.forEach(btn => {
    btn.addEventListener('click', () => {
        speedButtons.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        currentSpeed = btn.dataset.speed;
        sendNUIMessage('setSpeed', { speed: currentSpeed });
    });
});

resetViewBtn.addEventListener('click', () => {
    sendNUIMessage('resetView', {});
});

// Functions
function sendNUIMessage(action, data) {
    fetch(`https://${resourceName}/${action}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    }).catch(() => {});
}

function closeUI() {
    cameraUI.classList.add('hidden');
    sendNUIMessage('closeUI', {});
}

function toggleCamera() {
    cameraActive = !cameraActive;
    sendNUIMessage('toggleCamera', {});
    
    if (cameraActive) {
        toggleCameraBtn.style.display = 'none';
        exitCameraBtn.disabled = false;
        exitCameraBtn.style.display = 'flex';
    } else {
        toggleCameraBtn.style.display = 'flex';
        exitCameraBtn.disabled = true;
        exitCameraBtn.style.display = 'none';
    }
}

function exitCamera() {
    cameraActive = false;
    sendNUIMessage('exitCamera', {});
    toggleCameraBtn.style.display = 'flex';
    exitCameraBtn.disabled = true;
    exitCameraBtn.style.display = 'none';
}

function toggleUI() {
    uiActive = !uiActive;
    sendNUIMessage('toggleUI', {});
    
    if (uiActive) {
        uiStatus.textContent = 'ON';
        uiStatus.classList.add('on');
        toggleUIBtn.classList.add('active');
    } else {
        uiStatus.textContent = 'OFF';
        uiStatus.classList.remove('on');
        toggleUIBtn.classList.remove('active');
    }
}

function updateZoom(value) {
    currentZoom = value;
    zoomValue.textContent = value;
    sendNUIMessage('setZoom', { zoom: value });
}

// Listen for messages from client
window.addEventListener('message', (event) => {
    const data = event.data;
    
    switch(data.action) {
        case 'openUI':
            cameraUI.classList.remove('hidden');
            break;
        case 'closeUI':
            cameraUI.classList.add('hidden');
            break;
        case 'updateCameraState':
            cameraActive = data.active;
            if (cameraActive) {
                toggleCameraBtn.style.display = 'none';
                exitCameraBtn.disabled = false;
                exitCameraBtn.style.display = 'flex';
            } else {
                toggleCameraBtn.style.display = 'flex';
                exitCameraBtn.disabled = true;
                exitCameraBtn.style.display = 'none';
            }
            break;
        case 'updateUIState':
            uiActive = data.active;
            if (uiActive) {
                uiStatus.textContent = 'ON';
                uiStatus.classList.add('on');
                toggleUIBtn.classList.add('active');
            } else {
                uiStatus.textContent = 'OFF';
                uiStatus.classList.remove('on');
                toggleUIBtn.classList.remove('active');
            }
            break;
        case 'updateZoom':
            currentZoom = data.zoom;
            zoomValue.textContent = data.zoom;
            zoomSlider.value = data.zoom;
            break;
    }
});

// Close UI on ESC
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && !cameraUI.classList.contains('hidden')) {
        closeUI();
    }
});

