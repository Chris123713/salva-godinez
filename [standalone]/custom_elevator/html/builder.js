// Elevator Builder JavaScript

let floors = [];
let editingShaftIndex = null;

// Listen for messages from client
window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.type === 'openBuilder') {
        document.getElementById('builder-container').style.display = 'block';
        if (data.shafts) {
            renderElevatorList(data.shafts);
        }
    } else if (data.type === 'closeBuilder') {
        document.getElementById('builder-container').style.display = 'none';
    } else if (data.type === 'updateShafts') {
        if (data.shafts) {
            renderElevatorList(data.shafts);
        }
    }
});

// Close builder
function closeBuilder() {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

// Close on ESC
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeBuilder();
    }
});

// Switch tabs
function switchTab(tabName) {
    document.querySelectorAll('.tab').forEach(tab => tab.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));

    event.target.classList.add('active');
    document.getElementById(`${tabName}-tab`).classList.add('active');

    if (tabName === 'manage') {
        loadElevators();
    }
}

// Add floor manually
function addFloor() {
    const floorId = `floor_${Date.now()}`;
    const floor = {
        id: floorId,
        name: '',
        coords: { x: 0, y: 0, z: 0 },
        heading: 0,
        blip: false,
        jobLock: null
    };

    floors.push(floor);
    renderFloors();
}

// Add floor at current position
function getCurrentPosForNewFloor() {
    fetch(`https://${GetParentResourceName()}/getCurrentPosition`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    })
    .then(coords => {
        const floorId = `floor_${Date.now()}`;
        const floor = {
            id: floorId,
            name: `Floor ${floors.length + 1}`,
            coords: { x: coords.x, y: coords.y, z: coords.z },
            heading: coords.heading,
            blip: false,
            jobLock: null
        };

        floors.push(floor);
        renderFloors();
    });
}

// Render floors list
function renderFloors() {
    const container = document.getElementById('floor-list');
    container.innerHTML = '';

    if (floors.length === 0) {
        container.innerHTML = '<div class="hint">No floors added yet. Click "Add Floor" to begin.</div>';
        return;
    }

    floors.forEach((floor, index) => {
        const floorDiv = document.createElement('div');
        floorDiv.className = 'floor-item';
        floorDiv.innerHTML = `
            <div class="floor-item-header">
                <div>
                    <div class="floor-name">${floor.name || `Floor ${index + 1}`}</div>
                    <div class="floor-coords">
                        X: ${floor.coords.x.toFixed(2)}, Y: ${floor.coords.y.toFixed(2)}, Z: ${floor.coords.z.toFixed(2)}, H: ${floor.heading.toFixed(2)}
                    </div>
                </div>
                <div class="floor-actions">
                    <button class="btn btn-primary btn-small" onclick="editFloor(${index})">Edit</button>
                    <button class="btn btn-danger btn-small" onclick="deleteFloor(${index})">Delete</button>
                </div>
            </div>
        `;
        container.appendChild(floorDiv);
    });
}

// Edit floor
function editFloor(index) {
    const floor = floors[index];

    const name = prompt('Floor Name:', floor.name);
    if (name === null) return;

    const x = parseFloat(prompt('X Coordinate:', floor.coords.x));
    const y = parseFloat(prompt('Y Coordinate:', floor.coords.y));
    const z = parseFloat(prompt('Z Coordinate:', floor.coords.z));
    const heading = parseFloat(prompt('Heading:', floor.heading));

    if (isNaN(x) || isNaN(y) || isNaN(z) || isNaN(heading)) {
        alert('Invalid coordinates!');
        return;
    }

    floors[index].name = name;
    floors[index].coords = { x, y, z };
    floors[index].heading = heading;

    renderFloors();
}

// Delete floor
function deleteFloor(index) {
    if (confirm('Are you sure you want to delete this floor?')) {
        floors.splice(index, 1);
        renderFloors();
    }
}

// Clear form
function clearForm() {
    if (confirm('Clear all floors and start over?')) {
        floors = [];
        editingShaftIndex = null;
        document.getElementById('shaft-name').value = '';
        renderFloors();
    }
}

// Save elevator
function saveElevator() {
    const shaftName = document.getElementById('shaft-name').value.trim();

    if (!shaftName) {
        alert('Please enter an elevator name!');
        return;
    }

    if (floors.length < 2) {
        alert('An elevator must have at least 2 floors!');
        return;
    }

    // If editing, update the floor. Otherwise, create new shaft.
    if (editingShaftIndex !== null) {
        // Delete old shaft
        fetch(`https://${GetParentResourceName()}/deleteShaft`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ shaftIndex: editingShaftIndex })
        })
        .then(() => {
            // Create new shaft with updated data
            createShaftAndAddFloors(shaftName);
        });
    } else {
        // Create new shaft
        createShaftAndAddFloors(shaftName);
    }
}

function createShaftAndAddFloors(shaftName) {
    fetch(`https://${GetParentResourceName()}/createShaft`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name: shaftName })
    })
    .then(result => {
        if (result.success && result.shaftIndex) {
            // Add all floors to the shaft
            const floorPromises = floors.map(floor => {
                return fetch(`https://${GetParentResourceName()}/addFloor`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        shaftIndex: result.shaftIndex,
                        floor: floor
                    })
                });
            });

            Promise.all(floorPromises).then(() => {
                // Ask if they want to save to config file
                if (confirm('Elevator created! Do you want to save changes to config.lua?\n(This will reload all elevators on the server)')) {
                    fetch(`https://${GetParentResourceName()}/saveToFile`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({})
                    })
                    .then(saveResult => {
                        clearForm();
                        loadShafts();
                    });
                } else {
                    clearForm();
                    loadShafts();
                }
            });
        }
    });
}

// Load elevators
function loadElevators() {
    loadShafts();
}

function loadShafts() {
    fetch(`https://${GetParentResourceName()}/loadShafts`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    })
    .then(shafts => {
        renderElevatorList(shafts);
    });
}

// Render elevator list
function renderElevatorList(elevators) {
    const container = document.getElementById('elevator-list');
    container.innerHTML = '';

    // Handle non-array responses (could be object with success property, null, etc)
    if (!elevators || !Array.isArray(elevators)) {
        console.log('Invalid elevators data:', elevators);
        container.innerHTML = '<div class="hint">No elevators created yet. Switch to "Create New" tab to build your first elevator.</div>';
        return;
    }

    if (elevators.length === 0) {
        container.innerHTML = '<div class="hint">No elevators created yet. Switch to "Create New" tab to build your first elevator.</div>';
        return;
    }

    elevators.forEach((elevator, index) => {
        const card = document.createElement('div');
        card.className = 'elevator-card';
        card.innerHTML = `
            <div class="elevator-card-title">${elevator.name}</div>
            <div class="elevator-card-info">${elevator.floors.length} floors</div>
            <div class="button-group" style="margin-top: 10px;">
                <button class="btn btn-primary btn-small" onclick="editElevator(${index})">Edit</button>
                <button class="btn btn-danger btn-small" onclick="deleteElevator(${index})">Delete</button>
                <button class="btn btn-secondary btn-small" onclick="viewFloors(${index})">View Floors</button>
            </div>
        `;
        container.appendChild(card);
    });
}

// Edit elevator
function editElevator(index) {
    fetch(`https://${GetParentResourceName()}/loadShafts`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    })
    .then(shafts => {
        if (!Array.isArray(shafts) || !shafts[index]) {
            console.error('Invalid shafts data or index:', shafts, index);
            return;
        }

        const shaft = shafts[index];

        document.getElementById('shaft-name').value = shaft.name;
        floors = JSON.parse(JSON.stringify(shaft.floors)); // Deep copy
        editingShaftIndex = index + 1; // Lua is 1-indexed
        renderFloors();

        // Switch to create tab
        document.querySelectorAll('.tab').forEach(tab => tab.classList.remove('active'));
        document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
        document.querySelector('.tab:first-child').classList.add('active');
        document.getElementById('create-tab').classList.add('active');
    });
}

// Delete elevator
function deleteElevator(index) {
    fetch(`https://${GetParentResourceName()}/loadShafts`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    })
    .then(shafts => {
        if (!Array.isArray(shafts) || !shafts[index]) {
            console.error('Invalid shafts data or index:', shafts, index);
            return;
        }

        const shaft = shafts[index];

        if (confirm(`Delete elevator "${shaft.name}"?\n\nThis will also delete all ${shaft.floors.length} floors in this elevator.\n\nDo you want to save to config.lua after deletion?`)) {
            fetch(`https://${GetParentResourceName()}/deleteShaft`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ shaftIndex: index + 1 }) // Lua is 1-indexed
            })
            .then(result => {
                // Result might be {success: true} or just true/false
                const success = result && (result.success === true || result === true);
                if (success) {
                    // Ask if they want to save changes
                    if (confirm('Elevator deleted! Save changes to config.lua?')) {
                        fetch(`https://${GetParentResourceName()}/saveToFile`, {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({})
                        }).then(() => {
                            loadShafts();
                        });
                    } else {
                        loadShafts();
                    }
                }
            });
        }
    });
}

// View floors
function viewFloors(index) {
    fetch(`https://${GetParentResourceName()}/loadShafts`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    })
    .then(shafts => {
        if (!Array.isArray(shafts) || !shafts[index]) {
            console.error('Invalid shafts data or index:', shafts, index);
            return;
        }

        const shaft = shafts[index];

        let floorList = `Floors in "${shaft.name}":\n\n`;
        shaft.floors.forEach((floor, i) => {
            floorList += `${i + 1}. ${floor.name}\n`;
            floorList += `   Coords: ${floor.coords.x.toFixed(2)}, ${floor.coords.y.toFixed(2)}, ${floor.coords.z.toFixed(2)}\n`;
            floorList += `   Heading: ${floor.heading.toFixed(2)}\n`;
            if (floor.blip) floorList += `   Has Blip: Yes\n`;
            if (floor.jobLock) floorList += `   Job Locked: ${floor.jobLock.jobs.join(', ')}\n`;
            floorList += `\n`;
        });

        alert(floorList);
    });
}

// Get parent resource name
function GetParentResourceName() {
    return window.location.hostname === '' ? 'custom_elevator' : window.location.hostname;
}
