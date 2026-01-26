let currentFloors = [];
let audioElements = {};
let loopingSound = null;

// Initialize sound system
function initSounds() {
    const soundNames = ['ding', 'doorOpen', 'doorClose', 'movement'];
    soundNames.forEach(soundName => {
        audioElements[soundName] = new Audio(`sounds/elevator_${soundName}.ogg`);
        audioElements[soundName].preload = 'auto';
    });
}

// Play sound
function playSound(soundName, volume = 0.5) {
    if (audioElements[soundName]) {
        audioElements[soundName].volume = volume;
        audioElements[soundName].currentTime = 0;
        audioElements[soundName].play().catch(err => {
            console.log('Sound play failed:', err);
        });
    }
}

// Play looping sound
function playLoopingSound(soundName, duration, volume = 0.5) {
    stopLoopingSound();

    if (audioElements[soundName]) {
        audioElements[soundName].volume = volume;
        audioElements[soundName].loop = true;
        audioElements[soundName].currentTime = 0;
        audioElements[soundName].play().catch(err => {
            console.log('Loop sound play failed:', err);
        });

        loopingSound = soundName;

        // Stop after duration
        setTimeout(() => {
            stopLoopingSound();
        }, duration);
    }
}

// Stop looping sound
function stopLoopingSound() {
    if (loopingSound && audioElements[loopingSound]) {
        audioElements[loopingSound].loop = false;
        audioElements[loopingSound].pause();
        audioElements[loopingSound].currentTime = 0;
        loopingSound = null;
    }
}

// Stop all sounds
function stopAllSounds() {
    Object.values(audioElements).forEach(audio => {
        audio.pause();
        audio.currentTime = 0;
        audio.loop = false;
    });
    loopingSound = null;
}

// Update elevator status display
function updateStatus(status, currentFloor, direction) {
    const statusElement = document.getElementById('elevator-status');
    if (!statusElement) return;

    let statusText = '';
    let statusClass = '';

    switch(status) {
        case 'idle':
            statusText = `Currently at ${currentFloor}`;
            statusClass = 'status-idle';
            break;
        case 'moving_up':
            statusText = `Moving Up...`;
            statusClass = 'status-moving';
            break;
        case 'moving_down':
            statusText = `Moving Down...`;
            statusClass = 'status-moving';
            break;
        case 'doors_opening':
            statusText = 'Doors Opening...';
            statusClass = 'status-transition';
            break;
        case 'doors_open':
            statusText = 'Select Your Floor';
            statusClass = 'status-ready';
            break;
        case 'doors_closing':
            statusText = 'Doors Closing...';
            statusClass = 'status-transition';
            break;
        default:
            statusText = 'Please Wait...';
            statusClass = 'status-idle';
    }

    statusElement.textContent = statusText;
    statusElement.className = `elevator-status ${statusClass}`;
}

// Listen for messages from Lua
window.addEventListener('message', function(event) {
    const data = event.data;

    switch(data.action) {
        case 'openMenu':
            openMenu(data.shaftName, data.floors);
            break;
        case 'closeMenu':
            closeMenu();
            break;
        case 'updateElevatorStatus':
            updateStatus(data.status, data.currentFloor, data.direction);
            break;
        case 'initSounds':
            initSounds();
            break;
        case 'playSound':
            playSound(data.sound, data.volume);
            break;
        case 'playLoopingSound':
            playLoopingSound(data.sound, data.duration, data.volume);
            break;
        case 'stopAllSounds':
            stopAllSounds();
            break;
    }
});

// Open the elevator menu
function openMenu(shaftName, floors) {
    currentFloors = floors;
    
    const container = document.getElementById('elevator-container');
    const title = document.getElementById('elevator-title');
    const floorsContainer = document.getElementById('floors-container');
    
    // Set elevator name
    title.textContent = shaftName;
    
    // Clear previous floors
    floorsContainer.innerHTML = '';
    
    // Add floor buttons
    floors.forEach(floor => {
        const floorButton = createFloorButton(floor);
        floorsContainer.appendChild(floorButton);
    });
    
    // Show container
    container.classList.remove('hidden');
    
    // Play sound
    playSound();
}

// Close the elevator menu
function closeMenu() {
    const container = document.getElementById('elevator-container');
    container.classList.add('hidden');
    
    // Send close event to Lua
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

// Create a floor button element
function createFloorButton(floor) {
    const button = document.createElement('div');
    button.className = `floor-button ${floor.locked ? 'locked' : ''}`;
    
    const floorName = document.createElement('div');
    floorName.className = 'floor-name';
    
    // Add icon based on floor name
    const icon = document.createElement('span');
    icon.className = 'floor-icon';
    icon.textContent = getFloorIcon(floor.name);
    
    const name = document.createElement('span');
    name.textContent = floor.name;
    
    floorName.appendChild(icon);
    floorName.appendChild(name);
    
    const status = document.createElement('div');
    status.className = `floor-status ${floor.locked ? 'locked' : 'available'}`;
    status.textContent = floor.locked ? '🔒 Locked' : '✓';
    
    button.appendChild(floorName);
    button.appendChild(status);
    
    // Add click event if not locked
    if (!floor.locked) {
        button.addEventListener('click', function() {
            selectFloor(floor);
        });
    }
    
    return button;
}

// Get icon based on floor name
function getFloorIcon(floorName) {
    const name = floorName.toLowerCase();
    
    if (name.includes('lobby') || name.includes('ground')) {
        return '🏢';
    } else if (name.includes('roof') || name.includes('helipad')) {
        return '🚁';
    } else if (name.includes('basement') || name.includes('garage') || name.includes('parking')) {
        return '🅿️';
    } else if (name.includes('office')) {
        return '💼';
    } else if (name.includes('conference') || name.includes('meeting')) {
        return '👥';
    } else if (name.includes('executive') || name.includes('penthouse')) {
        return '👔';
    } else if (name.includes('surgery') || name.includes('medical')) {
        return '⚕️';
    } else if (name.includes('evidence') || name.includes('storage')) {
        return '📦';
    } else {
        return '📍';
    }
}

// Select a floor
function selectFloor(floor) {
    playSound('ding', 0.3);

    // Send selection to Lua
    fetch(`https://${GetParentResourceName()}/selectFloor`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            floorId: floor.id,
            floorIndex: floor.floorIndex,  // Include floor index for new system
            coords: floor.coords,
            heading: floor.heading
        })
    });
}

// Play UI sound
function playSound() {
    fetch(`https://${GetParentResourceName()}/playSound`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

// Get resource name
function GetParentResourceName() {
    const url = window.location.href;
    const regex = /https?:\/\/(.*?)\/(.+?)\/(.+)/;
    const match = url.match(regex);
    return match ? match[2] : 'custom_elevator';
}

// Handle ESC key
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeMenu();
    }
});

// Prevent context menu
document.addEventListener('contextmenu', function(event) {
    event.preventDefault();
});
