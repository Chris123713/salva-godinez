/* ========================================
   PD Boss Menu - Time Tracking Module
   Handles officer duty time tracking
   ======================================== */

console.log('=== TIME TRACKING MODULE LOADED ===');

// Time tracking functionality
const TimeTracking = {
    currentShift: null,
    shiftHistory: [],

    startShift(officerId, officerName) {
        this.currentShift = {
            officerId: officerId,
            officerName: officerName,
            startTime: new Date(),
            endTime: null
        };
        console.log('[Time Tracking] Shift started for', officerName);
    },

    endShift() {
        if (this.currentShift) {
            this.currentShift.endTime = new Date();
            this.shiftHistory.push({...this.currentShift});
            const duration = this.getShiftDuration(this.currentShift);
            console.log('[Time Tracking] Shift ended. Duration:', duration);
            this.currentShift = null;
            return duration;
        }
        return null;
    },

    getShiftDuration(shift) {
        if (!shift || !shift.startTime) return '0h 0m';
        const end = shift.endTime || new Date();
        const diffMs = end - shift.startTime;
        const hours = Math.floor(diffMs / (1000 * 60 * 60));
        const minutes = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));
        return `${hours}h ${minutes}m`;
    },

    getCurrentShiftDuration() {
        return this.getShiftDuration(this.currentShift);
    },

    getShiftHistory() {
        return this.shiftHistory;
    },

    formatTime(date) {
        if (!date) return 'N/A';
        return date.toLocaleTimeString('en-US', {
            hour: '2-digit',
            minute: '2-digit',
            hour12: true
        });
    }
};

// Initialize real-time tracking updates
function initializeRealTimeTracking() {
    console.log('[Time Tracking] Initializing real-time tracking...');
    // Request duty data from server
    fetch('https://pd_boss_menu/getRealTimeDutyData', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).catch(() => {});
}

window.TimeTracking = TimeTracking;
window.initializeRealTimeTracking = initializeRealTimeTracking;
