// Job Market DUI Script

const jobGrid = document.getElementById('jobGrid');
let currentJobs = {};

// Listen for NUI messages from the client
window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.type === 'update') {
        updateJobDisplay(data.jobs);
    }
});

// Update the job display with new data
function updateJobDisplay(jobs) {
    if (!jobs || Object.keys(jobs).length === 0) {
        jobGrid.innerHTML = `
            <div class="loading">
                <i class="fa-solid fa-briefcase"></i>
                <span>No job data available</span>
            </div>
        `;
        return;
    }

    // Sort jobs by label
    const sortedJobs = Object.entries(jobs).sort((a, b) =>
        a[1].label.localeCompare(b[1].label)
    );

    // Build HTML for all job cards
    let html = '';
    for (const [jobKey, job] of sortedJobs) {
        const card = createJobCard(jobKey, job);
        html += card;
    }

    jobGrid.innerHTML = html;

    // Store current state for comparison on next update
    currentJobs = { ...jobs };
}

// Create HTML for a single job card
function createJobCard(jobKey, job) {
    const multiplierPercent = Math.floor((job.multiplier - 1) * 100);
    const multiplierStr = multiplierPercent >= 0 ? `+${multiplierPercent}%` : `${multiplierPercent}%`;

    const multiplierClass = multiplierPercent > 0 ? 'positive' :
                           (multiplierPercent < 0 ? 'negative' : 'neutral');

    const statusText = getStatusText(job.reason);
    const icon = job.icon || 'fa-solid fa-briefcase';

    // Calculate worker bar width (max 10 workers = 100%)
    const workerPercent = Math.min((job.workers / 10) * 100, 100);

    // Check if this job was updated
    const wasUpdated = currentJobs[jobKey] &&
        (currentJobs[jobKey].workers !== job.workers ||
         currentJobs[jobKey].multiplier !== job.multiplier);

    return `
        <div class="job-card ${job.reason} ${wasUpdated ? 'updated' : ''}" data-job="${jobKey}">
            <div class="job-header">
                <div class="job-icon">
                    <i class="${icon}"></i>
                </div>
                <div class="job-title">${job.label}</div>
            </div>
            <div class="job-stats">
                <div class="stat-row">
                    <span class="stat-label">Active Workers</span>
                    <span class="stat-value workers">${job.workers}</span>
                </div>
                <div class="worker-bar">
                    <div class="worker-bar-fill" style="width: ${workerPercent}%"></div>
                </div>
                <div class="stat-row">
                    <span class="stat-label">Pay Modifier</span>
                    <span class="stat-value multiplier ${multiplierClass}">${multiplierStr}</span>
                </div>
                <div class="stat-row">
                    <span class="stat-label">Status</span>
                    <span class="status-badge ${job.reason}">${statusText}</span>
                </div>
            </div>
        </div>
    `;
}

// Get human-readable status text
function getStatusText(reason) {
    const statusMap = {
        'surge': 'High Demand',
        'normal': 'Normal',
        'declining': 'Cooling',
        'saturated': 'Saturated',
        'forced': 'Admin Override'
    };
    return statusMap[reason] || 'Unknown';
}

// Initialize with empty state
updateJobDisplay({});

// Debug: Log when script loads
console.log('[Job Orchestrator] DUI script loaded');
