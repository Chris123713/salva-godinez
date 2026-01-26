// Sierra Valley Taxi UI JavaScript
let driverData = null;

$(document).ready(function() {
    // Close UI/Dispatch on ESC key
    $(document).keyup(function(e) {
        if (e.key === "Escape") {
            // Check if dispatch is open
            if (!$('#dispatchOverlay').hasClass('hidden')) {
                hideDispatch();
            } else if (!$('#taxiUI').hasClass('hidden')) {
                closeUI();
            }
        }
    });

    // Sidebar navigation
    $('.nav-item').click(function() {
        const targetTab = $(this).data('tab');
        switchTab(targetTab);
    });
});

// Track if player has vehicle
let hasVehicle = false;

// NUI Message Handler
window.addEventListener('message', function(event) {
    const data = event.data;
    console.log('[TAXI UI] Received NUI message:', data.action);

    switch (data.action) {
        case 'openUI':
            console.log('[TAXI UI] Opening UI with data:', data.data);
            openUI(data.data);
            break;
        case 'closeUI':
            console.log('[TAXI UI] Closing UI (from server)');
            hideUI();
            break;
        case 'updateDriverData':
            updateDriverData(data.data);
            break;
        case 'showMeter':
            showMeter();
            break;
        case 'hideMeter':
            hideMeter();
            break;
        case 'updateMeter':
            updateMeter(data.data);
            break;
        case 'showDispatch':
            showDispatch();
            loadDispatchCalls();
            break;
        case 'hideDispatch':
            hideDispatch();
            break;
        case 'toggleDispatch':
            toggleDispatch();
            break;
        case 'setVehicleState':
            hasVehicle = data.hasVehicle;
            updateWorkingButton();
            break;
    }
});

// Open UI
function openUI(data) {
    console.log('[TAXI UI] openUI called with data:', data);
    driverData = data;
    $('#taxiUI').removeClass('hidden');
    console.log('[TAXI UI] UI should now be visible');
    updateAllData();
}

// Hide UI (called by server closeUI message)
function hideUI() {
    console.log('[TAXI UI] hideUI called');
    $('#taxiUI').addClass('hidden');
}

// Close UI (called by user action - ESC or close button)
function closeUI() {
    console.log('[TAXI UI] closeUI called (user action)');
    $('#taxiUI').addClass('hidden');
    fetch('https://sv_taxi/closeUI', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

// Switch Tab
function switchTab(tabName) {
    // Update sidebar
    $('.nav-item').removeClass('active');
    $(`.nav-item[data-tab="${tabName}"]`).addClass('active');

    // Update content
    $('.tab-pane').removeClass('active');
    $(`#${tabName}-tab`).addClass('active');

    // Update header title
    const titles = {
        'overview': 'Overview',
        'progress': 'Progress',
        'vehicles': 'Vehicles',
        'challenges': 'Challenges'
    };
    $('#pageTitle').text(titles[tabName] || tabName);
}

// Update all data
function updateAllData() {
    if (!driverData) return;

    updateOverview();
    updateProgress();
    loadVehicles();
    updateChallenges();
}

// Update driver data
function updateDriverData(data) {
    driverData = data;
    updateAllData();
}

// Update Overview Tab
function updateOverview() {
    if (!driverData) return;

    // Rank circle progress
    const progressDeg = (driverData.progress / 100) * 360;
    $('#rankCircle').css('--progress', `${progressDeg}deg`);
    $('#rankNumber').text(driverData.rank);
    $('#xpProgress').text(`${driverData.xp.toLocaleString()} / ${driverData.nextRankXP.toLocaleString()}`);

    // Stats (these would be tracked daily in a real implementation)
    $('#dailyEarnings').text(`$${driverData.totalEarnings.toLocaleString()}`);
    $('#dailyRides').text(driverData.totalTrips);

    // Rewards (placeholder - would be calculated based on achievements)
    $('#rewardMoney').text('$1,000');
    $('#rewardXP').text('600 XP');
}

// Update Progress Tab
function updateProgress() {
    if (!driverData) return;

    // Current level
    $('#currentLevel').text(driverData.rank);
    $('#levelXP').text(`${driverData.xp.toLocaleString()} / ${driverData.nextRankXP.toLocaleString()}`);
    $('#levelPercent').text(`${Math.floor(driverData.progress)}%`);
    $('#progressBarFill').css('width', `${driverData.progress}%`);

    // Next level preview
    const nextRank = driverData.rank + 1;
    $('#nextLevelNum').text(nextRank);

    // Just show placeholder for next vehicle unlock
    $('#unlockedVehicle').text('New Vehicle');
}

// Load Vehicles
function loadVehicles() {
    fetch('https://sv_taxi/getVehicles', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).then(resp => resp.json()).then(vehicles => {
        const vehicleGrid = $('#vehicleGrid');
        vehicleGrid.empty();

        if (!vehicles || vehicles.length === 0) {
            vehicleGrid.html('<p style="color: rgba(255,255,255,0.5); text-align: center;">No vehicles available</p>');
            return;
        }

        vehicles.forEach(vehicle => {
            const isLocked = !vehicle.unlocked;
            const cardClass = isLocked ? 'vehicle-card locked' : 'vehicle-card';

            const card = $(`
                <div class="${cardClass}" data-model="${vehicle.model}">
                    <div class="vehicle-image">
                        <i class="fas fa-taxi"></i>
                        ${isLocked ? '<div class="vehicle-lock"><i class="fas fa-lock"></i> RANK ' + vehicle.rank + '</div>' : ''}
                    </div>
                    <div class="vehicle-info-box">
                        <h3 class="vehicle-name-header">${vehicle.label}</h3>
                        <div class="vehicle-price">
                            <span class="price">${(vehicle.multiplier * 100).toFixed(0)}%</span>
                            <button class="rent-btn" ${isLocked ? 'disabled' : ''}>
                                ${isLocked ? '<i class="fas fa-lock"></i> Locked' : 'Rent'}
                            </button>
                        </div>
                    </div>
                </div>
            `);

            if (!isLocked) {
                card.find('.rent-btn').click(function() {
                    spawnVehicle(vehicle.model);
                });
            }

            vehicleGrid.append(card);
        });
    }).catch(err => {
        console.error('Failed to load vehicles:', err);
    });
}

// Spawn vehicle
function spawnVehicle(model) {
    fetch('https://sv_taxi/spawnVehicle', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ vehicle: model })
    });
    closeUI();
}

// Load Dispatch Calls
function loadDispatchCalls() {
    fetch('https://sv_taxi/getDispatchCalls', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).then(resp => resp.json()).then(calls => {
        const callsList = $('#dispatchCallsList');
        callsList.empty();

        if (!calls || calls.length === 0) {
            callsList.html(`
                <div class="no-calls-message">
                    <i class="fas fa-phone-slash"></i>
                    <p>No calls available right now.<br>Rent a vehicle to start receiving calls!</p>
                </div>
            `);
            return;
        }

        calls.forEach(call => {
            const isLocked = call.locked;
            const cardClass = isLocked ? 'dispatch-call-item locked' : 'dispatch-call-item';

            const card = $(`
                <div class="${cardClass}">
                    <div class="call-header">
                        <div class="call-name">${call.passengerName}</div>
                        ${isLocked ? `<div class="call-lock"><i class="fas fa-lock"></i></div>` : ''}
                    </div>
                    <div class="call-info-row">
                        <div class="call-location">
                            <i class="fas fa-map-marker-alt"></i>
                            <span>${call.label}</span>
                        </div>
                        <div class="call-location">
                            <i class="fas fa-location-dot"></i>
                            <span>Los Santos</span>
                        </div>
                    </div>
                    <div class="call-rewards-row">
                        <div class="reward-badge money">
                            <i class="fas fa-dollar-sign"></i>
                            <span>$${call.baseReward}</span>
                        </div>
                        <div class="reward-badge xp">
                            <i class="fas fa-star"></i>
                            <span>${call.xpReward} XP</span>
                        </div>
                        ${isLocked ?
                            `<button class="start-route-btn locked" disabled>
                                <i class="fas fa-lock"></i>
                                <span>Rank ${call.minRank}</span>
                            </button>` :
                            `<button class="start-route-btn" data-call-id="${call.id}">
                                <i class="fas fa-route"></i>
                                <span>Start Route</span>
                            </button>`
                        }
                    </div>
                </div>
            `);

            if (!isLocked) {
                card.find('.start-route-btn').click(function(e) {
                    e.stopPropagation();
                    acceptDispatchCall(call.id);
                });
            }

            callsList.append(card);
        });
    }).catch(err => {
        console.error('Failed to load dispatch calls:', err);
    });
}

// Show Dispatch Overlay
function showDispatch() {
    console.log('[TAXI UI] Showing dispatch overlay');
    $('#dispatchOverlay').removeClass('hidden');
    // Enable cursor for clicking
    fetch('https://sv_taxi/setNuiFocus', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ focus: true, cursor: true })
    });
}

// Hide Dispatch Overlay
function hideDispatch() {
    console.log('[TAXI UI] Hiding dispatch overlay');
    $('#dispatchOverlay').addClass('hidden');
    // Disable cursor when hiding
    fetch('https://sv_taxi/setNuiFocus', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ focus: false, cursor: false })
    });
}

// Toggle Dispatch Overlay
function toggleDispatch() {
    if ($('#dispatchOverlay').hasClass('hidden')) {
        showDispatch();
        loadDispatchCalls();
    } else {
        hideDispatch();
    }
}

// Accept Dispatch Call
function acceptDispatchCall(callId) {
    fetch('https://sv_taxi/acceptCall', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ callId: callId })
    });
    hideDispatch();
}

// Update Challenges
function updateChallenges() {
    if (!driverData) return;

    // NPC rides challenge (based on total trips)
    const npcTrips = driverData.totalTrips || 0;
    const npcStage = Math.floor(npcTrips / 10);
    const npcProgress = (npcTrips % 10) / 10 * 100;

    $('#npcStage').text(npcStage);
    $('#npcCount').text(`${npcTrips % 10} / 10`);
    $('#npcPercent').text(`${Math.floor(npcProgress)}%`);
    $('#npcProgressBar').css('width', `${npcProgress}%`);
}

// Show meter
function showMeter() {
    $('#taxiMeter').removeClass('hidden');
}

// Hide meter
function hideMeter() {
    $('#taxiMeter').addClass('hidden');
}

// Update meter
function updateMeter(data) {
    $('#meterFare').text(`$${data.fare.toFixed(2)}`);
    $('#meterDistance').text(`${data.distance.toFixed(2)}m`);

    const minutes = Math.floor(data.duration / 60);
    const seconds = data.duration % 60;
    $('#meterDuration').text(`${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`);

    $('#meterSpeed').text(`${Math.round(data.speed)} km/h`);
}

// Start NPC Job (called from challenges)
$(document).on('click', '.claim-btn', function() {
    fetch('https://sv_taxi/startNPCJob', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
    closeUI();
});

// Update working button based on vehicle state
function updateWorkingButton() {
    const title = $('#workingTitle');
    const text = $('#workingText');
    const btn = $('#workingBtn');

    if (hasVehicle) {
        // Show "Stop Working" state
        title.text('STOP WORKING');
        text.text('Return your vehicle to stop working.');
        btn.text('Return Vehicle');
        btn.off('click').on('click', function() {
            fetch('https://sv_taxi/returnVehicle', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
            closeUI();
        });
    } else {
        // Show "Start Working" state
        title.text('START WORKING');
        text.text('Rent a vehicle to start working.');
        btn.text('Rent Vehicle');
        btn.off('click').on('click', function() {
            switchTab('vehicles');
        });
    }
}
