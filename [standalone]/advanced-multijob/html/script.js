let currentData = null;

// Listen for NUI messages
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'openMenu':
            openMenu(data.data);
            break;
        case 'closeMenu':
            closeMenu();
            break;
        case 'updateData':
            updateMenu(data.data);
            break;
    }
});

// Open menu
function openMenu(data) {
    currentData = data;
    const container = document.getElementById('multijob-container');
    container.classList.remove('hidden');
    updateMenu(data);
}

// Close menu
function closeMenu() {
    const container = document.getElementById('multijob-container');
    container.classList.add('hidden');
    fetch(`https://${resourceName}/closeMenu`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

// Update menu with new data
function updateMenu(data) {
    if (!data) return;
    
    currentData = data;
    
    // Update current job
    updateCurrentJob(data.currentJob);
    
    // Update jobs list
    updateJobsList(data.jobs, data.totalJobs);
}

// Update current job section
function updateCurrentJob(job) {
    const currentJobName = document.getElementById('currentJobName');
    const statusText = document.getElementById('statusText');
    const statusIcon = document.getElementById('statusIcon');
    const dutyBtn = document.getElementById('dutyBtn');
    const advancedBtn = document.getElementById('advancedBtn');
    
    if (currentJobName) {
        currentJobName.textContent = job.label || job.name;
    }
    
    if (statusText && statusIcon) {
        if (job.onduty) {
            statusText.textContent = 'On Duty';
            statusIcon.textContent = '⚡';
            dutyBtn.innerHTML = '<span class="duty-icon">👁</span><span>Go Off Duty</span>';
        } else {
            statusText.textContent = 'Off Duty';
            statusIcon.textContent = '💤';
            dutyBtn.innerHTML = '<span class="duty-icon">👁</span><span>Go On Duty</span>';
        }
    }
    
    if (dutyBtn) {
        const canToggleDuty = job.canToggleDuty !== false;
        if (!canToggleDuty) {
            dutyBtn.style.display = 'none';
        } else {
            dutyBtn.style.display = 'flex';
        }
    }
    
    if (advancedBtn) {
        const canQuitJob = job.canQuitJob !== false;
        if (!canQuitJob) {
            advancedBtn.style.display = 'none';
        } else {
            advancedBtn.style.display = 'block';
        }
    }
}

// Update jobs list
function updateJobsList(jobs, totalJobs) {
    const jobsList = document.getElementById('jobsList');
    const jobCount = document.getElementById('jobCount');
    
    if (jobCount) {
        jobCount.textContent = `${totalJobs || jobs.length} job${(totalJobs || jobs.length) !== 1 ? 's' : ''}`;
    }
    
    if (!jobsList) return;
    
    jobsList.innerHTML = '';
    
    if (!jobs || jobs.length === 0) {
        jobsList.innerHTML = '<div style="color: rgba(255,255,255,0.5); text-align: center; padding: 20px;">No jobs available</div>';
        return;
    }
    
    jobs.forEach(job => {
        const jobItem = document.createElement('div');
        jobItem.className = `job-list-item ${job.isCurrent ? 'current' : ''}`;
        
        const canQuitJob = job.canQuitJob !== false;
        jobItem.innerHTML = `
            <div class="job-list-left">
                <div class="job-list-name">
                    ${job.label || job.name}
                    ${job.isCurrent ? '<span class="current-badge">✓</span>' : ''}
                </div>
                <div class="job-list-grade">Grade ${job.grade}: ${job.gradeName}</div>
            </div>
            <div class="job-list-actions">
                ${canQuitJob ? `<button class="advanced-btn-list" data-job="${job.name}" data-job-label="${job.label || job.name}">
                    Advanced
                </button>` : ''}
                <button class="switch-btn" ${job.isCurrent ? 'disabled' : ''} data-job="${job.name}">
                    → Switch
                </button>
            </div>
        `;
        
        // Add click event to switch button
        const switchBtn = jobItem.querySelector('.switch-btn');
        if (switchBtn && !job.isCurrent) {
            switchBtn.addEventListener('click', () => {
                switchJob(job.name);
            });
        }
        
        // Add click event to advanced button (only if it exists)
        const advancedBtn = jobItem.querySelector('.advanced-btn-list');
        if (advancedBtn && canQuitJob) {
            advancedBtn.addEventListener('click', () => {
                const jobName = advancedBtn.getAttribute('data-job');
                const jobLabel = advancedBtn.getAttribute('data-job-label');
                quitJobFromList(jobName, jobLabel);
            });
        }
        
        jobsList.appendChild(jobItem);
    });
}

// Switch job
function switchJob(jobName) {
    fetch(`https://${resourceName}/switchJob`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ jobName: jobName })
    });
    
    // Refresh data after a short delay
    setTimeout(() => {
        fetch(`https://${resourceName}/refreshData`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
    }, 500);
}

// Toggle duty
function toggleDuty() {
    fetch(`https://${resourceName}/toggleDuty`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
    
    // Refresh data after a short delay
    setTimeout(() => {
        fetch(`https://${resourceName}/refreshData`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
    }, 500);
}

// Show quit confirmation modal
function showQuitConfirmModal(jobName, jobLabel) {
    const modal = document.getElementById('quitConfirmModal');
    const confirmText = document.getElementById('quitConfirmText');
    const confirmBtn = document.getElementById('quitConfirmBtn');
    const cancelBtn = document.getElementById('quitCancelBtn');
    
    if (!modal || !confirmText) return;
    
    confirmText.textContent = `Are you sure you want to quit/resign from ${jobLabel}?`;
    modal.classList.remove('hidden');
    
    // Remove existing event listeners by cloning
    const newConfirmBtn = confirmBtn.cloneNode(true);
    const newCancelBtn = cancelBtn.cloneNode(true);
    confirmBtn.parentNode.replaceChild(newConfirmBtn, confirmBtn);
    cancelBtn.parentNode.replaceChild(newCancelBtn, cancelBtn);
    
    // Add new event listeners
    newConfirmBtn.addEventListener('click', () => {
        modal.classList.add('hidden');
        performQuitJob(jobName);
    });
    
    newCancelBtn.addEventListener('click', () => {
        modal.classList.add('hidden');
    });
}

// Close modal on ESC key
function closeQuitModal() {
    const modal = document.getElementById('quitConfirmModal');
    if (modal) {
        modal.classList.add('hidden');
    }
}

// Perform the actual job quit
function performQuitJob(jobName) {
    fetch(`https://${resourceName}/quitJob`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ jobName: jobName })
    });
    
    // Refresh data after a longer delay to ensure server has processed
    setTimeout(() => {
        fetch(`https://${resourceName}/refreshData`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
    }, 1000);
}

// Quit job function (for current job)
function quitJob() {
    if (!currentData || !currentData.currentJob) return;
    
    const jobName = currentData.currentJob.name;
    const jobLabel = currentData.currentJob.label;
    
    // Prevent quitting unemployed job
    if (jobName === 'unemployed') {
        // Show a simple message instead of alert
        const modal = document.getElementById('quitConfirmModal');
        const confirmText = document.getElementById('quitConfirmText');
        if (modal && confirmText) {
            confirmText.textContent = 'You cannot quit the unemployed job.';
            modal.classList.remove('hidden');
            setTimeout(() => {
                modal.classList.add('hidden');
            }, 2000);
        }
        return;
    }
    
    // Show custom confirmation modal
    showQuitConfirmModal(jobName, jobLabel);
}

// Quit job function (for jobs in the list)
function quitJobFromList(jobName, jobLabel) {
    if (!jobName) return;
    
    // Prevent quitting unemployed job
    if (jobName === 'unemployed') {
        const modal = document.getElementById('quitConfirmModal');
        const confirmText = document.getElementById('quitConfirmText');
        if (modal && confirmText) {
            confirmText.textContent = 'You cannot quit the unemployed job.';
            modal.classList.remove('hidden');
            setTimeout(() => {
                modal.classList.add('hidden');
            }, 2000);
        }
        return;
    }
    
    // Show custom confirmation modal
    showQuitConfirmModal(jobName, jobLabel);
}

// Event listeners
document.addEventListener('DOMContentLoaded', function() {
    const closeBtn = document.getElementById('closeBtn');
    const dutyBtn = document.getElementById('dutyBtn');
    const advancedBtn = document.getElementById('advancedBtn');
    
    if (closeBtn) {
        closeBtn.addEventListener('click', closeMenu);
    }
    
    if (dutyBtn) {
        dutyBtn.addEventListener('click', toggleDuty);
    }
    
    if (advancedBtn) {
        advancedBtn.addEventListener('click', quitJob);
    }
    
    // Close on ESC key
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            const modal = document.getElementById('quitConfirmModal');
            if (modal && !modal.classList.contains('hidden')) {
                closeQuitModal();
            } else {
                closeMenu();
            }
        }
    });
});

// Get parent resource name (available in NUI context)
const resourceName = GetParentResourceName ? GetParentResourceName() : 'custom-multijob';

