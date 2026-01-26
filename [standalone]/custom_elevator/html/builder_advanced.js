// Advanced Elevator Builder UI

let currentShaft = null;
let currentFloors = [];
let builderActive = false;

// Utility: Get parent resource name
function GetParentResourceName() {
    return window.location.hostname === '' ? 'custom_elevator' : window.location.hostname;
}

// Utility: Post to NUI callback
async function post(endpoint, data = {}) {
    const response = await fetch(`https://${GetParentResourceName()}/${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    });
    return response;
}

// Show notification
function showNotification(message, type = 'info') {
    const container = document.getElementById('notifications');
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;

    container.appendChild(notification);

    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => notification.remove(), 300);
    }, 4000);
}

// Toggle builder UI
function toggleBuilder() {
    const ui = document.getElementById('builder-ui');
    builderActive = !builderActive;

    if (builderActive) {
        ui.classList.remove('hidden');
    } else {
        ui.classList.add('hidden');
        post('closeBuilder');
    }
}

// Update UI state
function updateUI() {
    const noElevator = document.getElementById('no-elevator');
    const elevatorInfo = document.getElementById('elevator-info');

    if (currentShaft) {
        noElevator.classList.add('hidden');
        elevatorInfo.classList.remove('hidden');

        document.getElementById('current-name').textContent = currentShaft.name;
        document.getElementById('floor-count').textContent = currentFloors.length;

        if (currentFloors.length > 0) {
            document.getElementById('last-floor').textContent = currentFloors[currentFloors.length - 1].name;
        } else {
            document.getElementById('last-floor').textContent = '—';
        }
    } else {
        noElevator.classList.remove('hidden');
        elevatorInfo.classList.add('hidden');
    }

    document.getElementById('floor-counter-badge').textContent = currentFloors.length;
    renderFloorsList();
}

// Render floors list
function renderFloorsList() {
    const list = document.getElementById('floors-list');
    list.innerHTML = '';

    if (currentFloors.length === 0) {
        list.innerHTML = '<div class="empty-state">No floors added yet</div>';
        return;
    }

    currentFloors.forEach((floor, index) => {
        const item = document.createElement('div');
        item.className = 'floor-item';
        item.onclick = () => teleportToFloor(index);

        item.innerHTML = `
            <div class="floor-item-content">
                <div class="floor-item-name">${index + 1}. ${floor.name}</div>
                <div class="floor-item-coords">
                    X: ${floor.coords.x.toFixed(2)} Y: ${floor.coords.y.toFixed(2)} Z: ${floor.coords.z.toFixed(2)}
                </div>
            </div>
            <div class="floor-item-actions">
                <button class="icon-btn" onclick="event.stopPropagation(); editFloor(${index})" title="Edit">✏️</button>
                <button class="icon-btn" onclick="event.stopPropagation(); removeFloor(${index})" title="Remove">🗑️</button>
            </div>
        `;

        list.appendChild(item);
    });
}

// Start new elevator
async function startNewElevator() {
    const name = prompt('Enter elevator name:', 'New Elevator');
    if (!name) return;

    currentShaft = { name };
    currentFloors = [];
    updateUI();
    showNotification(`Started new elevator: ${name}`, 'success');
}

// Add floor at current position
async function addFloorAtPosition() {
    if (!currentShaft) {
        showNotification('Start a new elevator first!', 'error');
        return;
    }

    const coords = await post('getCurrentPosition');
    const position = await coords.json();

    const name = prompt(`Floor name (Floor ${currentFloors.length + 1}):`, `Floor ${currentFloors.length + 1}`);
    if (!name) return;

    const floor = {
        id: `floor_${Date.now()}`,
        name: name,
        coords: {
            x: position.x,
            y: position.y,
            z: position.z
        },
        heading: position.heading,
        blip: false,
        jobLock: null
    };

    currentFloors.push(floor);
    updateUI();
    showNotification(`Added floor: ${name}`, 'success');

    // Notify Lua to show marker
    post('addFloorMarker', { floor });
}

// Remove floor
function removeFloor(index) {
    if (!confirm(`Remove floor "${currentFloors[index].name}"?`)) return;

    const removed = currentFloors.splice(index, 1)[0];
    updateUI();
    showNotification(`Removed floor: ${removed.name}`, 'info');
    post('removeFloorMarker', { index });
}

// Edit floor
function editFloor(index) {
    const floor = currentFloors[index];
    const newName = prompt('Floor name:', floor.name);
    if (!newName) return;

    currentFloors[index].name = newName;
    updateUI();
    showNotification(`Updated floor: ${newName}`, 'success');
}

// Teleport to floor
function teleportToFloor(index) {
    const floor = currentFloors[index];
    post('teleportToFloor', { coords: floor.coords, heading: floor.heading });
    showNotification(`Teleporting to: ${floor.name}`, 'info');
}

// Save elevator
async function saveElevator() {
    if (!currentShaft) {
        showNotification('No elevator to save!', 'error');
        return;
    }

    if (currentFloors.length < 2) {
        showNotification('Need at least 2 floors!', 'error');
        return;
    }

    if (!confirm(`Save elevator "${currentShaft.name}" with ${currentFloors.length} floors?`)) return;

    showNotification('Creating elevator...', 'info');

    // Create shaft
    const createResponse = await post('createShaft', { name: currentShaft.name });
    const result = await createResponse.json();

    if (!result.success) {
        showNotification('Failed to create elevator!', 'error');
        return;
    }

    // Add floors
    for (const floor of currentFloors) {
        await post('addFloor', {
            shaftIndex: result.shaftIndex,
            floor: floor
        });
    }

    // Ask to save to file
    if (confirm('Elevator created! Save to config.lua?')) {
        const saveResponse = await post('saveToFile');
        const saveResult = await saveResponse.json();

        if (saveResult.success) {
            showNotification('Saved to config.lua!', 'success');
        } else {
            showNotification('Failed to save to file', 'error');
        }
    }

    // Reset
    currentShaft = null;
    currentFloors = [];
    updateUI();
    post('clearMarkers');
    showNotification('Elevator saved! Start a new one.', 'success');
}

// Cancel build
function cancelBuild() {
    if (!currentShaft) return;

    if (!confirm(`Cancel building "${currentShaft.name}"? You will lose ${currentFloors.length} floors.`)) return;

    currentShaft = null;
    currentFloors = [];
    updateUI();
    post('clearMarkers');
    showNotification('Build cancelled', 'info');
}

// Get current coordinates
async function getCurrentCoords() {
    const coords = await post('getCurrentPosition');
    const position = await coords.json();

    const coordsText = `X: ${position.x.toFixed(2)}, Y: ${position.y.toFixed(2)}, Z: ${position.z.toFixed(2)}, H: ${position.heading.toFixed(2)}`;

    showNotification('Coordinates copied! Check console (F8)', 'success');
    console.log('Current Coordinates:', coordsText);
    post('logCoords', { coords: coordsText });
}

// Show manage menu
function showManageMenu() {
    document.getElementById('manage-modal').classList.remove('hidden');
    loadAllElevators();
}

// Close manage menu
function closeManageMenu() {
    document.getElementById('manage-modal').classList.add('hidden');
}

// Load all elevators
async function loadAllElevators() {
    const response = await post('loadShafts');
    const shafts = await response.json();

    const grid = document.getElementById('elevators-grid');
    grid.innerHTML = '';

    if (!shafts || !Array.isArray(shafts) || shafts.length === 0) {
        grid.innerHTML = '<div class="empty-state">No elevators found</div>';
        return;
    }

    shafts.forEach((elevator, index) => {
        const card = document.createElement('div');
        card.className = 'elevator-card';
        card.innerHTML = `
            <div class="elevator-card-title">${elevator.name}</div>
            <div class="elevator-card-info">${elevator.floors.length} floors</div>
            <div class="elevator-card-actions">
                <button class="btn btn-danger" onclick="deleteElevator(${index})">Delete</button>
            </div>
        `;
        grid.appendChild(card);
    });
}

// Delete elevator
async function deleteElevator(index) {
    const response = await post('loadShafts');
    const shafts = await response.json();

    const shaft = shafts[index];
    if (!shaft) return;

    if (!confirm(`Delete elevator "${shaft.name}"?`)) return;

    const deleteResponse = await post('deleteShaft', { shaftIndex: index + 1 });
    const result = await deleteResponse.json();

    if (result.success || result === true) {
        showNotification('Elevator deleted!', 'success');

        if (confirm('Save changes to config.lua?')) {
            await post('saveToFile');
        }

        loadAllElevators();
    } else {
        showNotification('Failed to delete elevator', 'error');
    }
}

// Toggle help
function toggleHelp() {
    const modal = document.getElementById('help-modal');
    modal.classList.toggle('hidden');
}

// Listen for messages from Lua
window.addEventListener('message', (event) => {
    const data = event.data;

    switch(data.action) {
        case 'openBuilder':
            builderActive = true;
            document.getElementById('builder-ui').classList.remove('hidden');
            break;

        case 'closeBuilder':
            builderActive = false;
            document.getElementById('builder-ui').classList.add('hidden');
            break;

        case 'addFloorShortcut':
            addFloorAtPosition();
            break;

        case 'removeLastFloor':
            if (currentFloors.length > 0) {
                removeFloor(currentFloors.length - 1);
            }
            break;

        case 'showNotification':
            showNotification(data.message, data.type || 'info');
            break;
    }
});

// Keyboard shortcuts
document.addEventListener('keydown', (e) => {
    if (!builderActive) return;

    // F5 - Toggle UI
    if (e.key === 'F5') {
        e.preventDefault();
        toggleBuilder();
    }

    // E - Add floor
    if (e.key === 'e' || e.key === 'E') {
        if (document.activeElement.tagName !== 'INPUT') {
            e.preventDefault();
            addFloorAtPosition();
        }
    }

    // Z - Remove last floor
    if (e.key === 'z' || e.key === 'Z') {
        if (document.activeElement.tagName !== 'INPUT') {
            e.preventDefault();
            if (currentFloors.length > 0) {
                removeFloor(currentFloors.length - 1);
            }
        }
    }

    // ESC - Close modals
    if (e.key === 'Escape') {
        document.getElementById('manage-modal').classList.add('hidden');
        document.getElementById('help-modal').classList.add('hidden');
    }
});

// Initialize
console.log('Advanced Elevator Builder UI loaded');
