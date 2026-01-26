console.log('=== PD BOSS MENU SCRIPT LOADING ===');

// Detect if running in DUI context (3D screen mode)
const urlParams = new URLSearchParams(window.location.search);
const isDuiContext = urlParams.has('res');
console.log('DUI Context:', isDuiContext);

// Keyboard proxy mode - when true, NUI is hidden but captures keyboard for DUI
let keyboardProxyMode = false;

// Setup keyboard proxy - captures all keyboard input and forwards to client
function setupKeyboardProxy() {
    if (isDuiContext) return; // Only for NUI, not DUI

    // Get the hidden input element for keyboard capture
    const proxyInput = document.getElementById('keyboardProxyInput');
    if (!proxyInput) {
        console.error('[NUI] Keyboard proxy input element not found!');
        return;
    }

    // Listen on the hidden input for keyboard events
    proxyInput.addEventListener('keydown', function(e) {
        console.log('[NUI PROXY] keydown event on input:', e.key, 'proxyMode:', keyboardProxyMode);
        if (!keyboardProxyMode) return;

        // Prevent default to stop the input from accumulating text
        e.preventDefault();

        // Hardcode resource name for keyboard proxy - GetParentResourceName returns undefined in this context
        const resourceName = 'pd_boss_menu';
        console.log('[NUI PROXY] Resource name:', resourceName);

        // ESC closes the menu
        if (e.key === 'Escape') {
            fetch(`https://pd_boss_menu/closeMenu`, {
                method: 'POST',
                body: JSON.stringify({})
            }).catch(err => console.error('[NUI PROXY] closeMenu fetch error:', err));
            return;
        }

        // Forward all other keys to client for DUI
        console.log('[NUI PROXY] Forwarding key to client:', e.key);
        fetch(`https://pd_boss_menu/keyboardInput`, {
            method: 'POST',
            body: JSON.stringify({
                type: 'keydown',
                key: e.key,
                keyCode: e.keyCode,
                char: e.key.length === 1 ? e.key : null
            })
        }).catch(err => console.error('[NUI PROXY] keyboardInput fetch error:', err));
    });

    proxyInput.addEventListener('keyup', function(e) {
        if (!keyboardProxyMode) return;
        e.preventDefault();

        fetch(`https://pd_boss_menu/keyboardInput`, {
            method: 'POST',
            body: JSON.stringify({
                type: 'keyup',
                key: e.key,
                keyCode: e.keyCode
            })
        }).catch(err => console.error('[NUI PROXY] keyup fetch error:', err));
    });

    // Also listen on document as a fallback
    document.addEventListener('keydown', function(e) {
        if (!keyboardProxyMode) return;
        // Don't duplicate if already handled by proxyInput
        if (e.target && e.target.id === 'keyboardProxyInput') return;

        // ESC closes the menu
        if (e.key === 'Escape') {
            fetch(`https://pd_boss_menu/closeMenu`, {
                method: 'POST',
                body: JSON.stringify({})
            }).catch(err => console.error('[NUI DOC] closeMenu fetch error:', err));
            return;
        }

        // Forward all other keys to client for DUI
        fetch(`https://pd_boss_menu/keyboardInput`, {
            method: 'POST',
            body: JSON.stringify({
                type: 'keydown',
                key: e.key,
                keyCode: e.keyCode,
                char: e.key.length === 1 ? e.key : null
            })
        }).catch(err => console.error('[NUI DOC] keyboardInput fetch error:', err));
    });

    console.log('[NUI] Keyboard proxy listeners registered');
}

// Focus the proxy input to capture keyboard events
function focusKeyboardProxy() {
    const proxyInput = document.getElementById('keyboardProxyInput');
    if (proxyInput) {
        proxyInput.value = ''; // Clear any accumulated text
        proxyInput.focus();
        // Verify focus was successful
        if (document.activeElement === proxyInput) {
            console.log('[NUI] Keyboard proxy input focused successfully');
        } else {
            console.warn('[NUI] Failed to focus proxy input, active:', document.activeElement?.id || document.activeElement?.tagName);
        }
    } else {
        console.error('[NUI] Keyboard proxy input element not found!');
    }
}

// Initialize keyboard proxy after DOM loads
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupKeyboardProxy);
} else {
    setupKeyboardProxy();
}

// In DUI mode, immediately show the container (don't wait for openMenu)
if (isDuiContext) {
    console.log('DUI MODE: Auto-showing container for 3D panel');
    // Run immediately and also on DOM ready to ensure it works
    const showContainer = function() {
        const container = document.getElementById('container');
        if (container) {
            container.classList.remove('hidden');
            console.log('DUI: Container is now visible');
        }
    };
    // Try immediately (in case DOM is already loaded)
    showContainer();
    // Also run when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', showContainer);
    }
}

// Get parent resource name safely - handles both NUI and DUI contexts
function GetParentResourceName() {
    // First try URL query parameter (for DUI/3D panel context)
    const resFromUrl = urlParams.get('res');
    if (resFromUrl) {
        return resFromUrl;
    }

    // Fallback for traditional NUI context
    if (window.invokeNative) {
        try {
            return window.invokeNative('0xE5E9EBBB');
        } catch (e) {
            console.warn('invokeNative failed:', e);
        }
    }

    return 'pd_boss_menu';
}

let currentData = {
    funds: 0,
    players: [],
    employees: [],
    ranks: []
};

/* ========================================
   NUI Communication Utilities
   Provides error handling and retry logic
   ======================================== */
const NUI = {
    // Dynamic resource name - works in both NUI and DUI contexts
    get resourceName() {
        return GetParentResourceName();
    },

    // Send a request to the Lua client with error handling
    async post(eventName, data = {}) {
        try {
            const response = await fetch(`https://${this.resourceName}/${eventName}`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
            if (!response.ok) {
                console.warn(`NUI Warning: ${eventName} returned ${response.status}`);
                return null;
            }
            const text = await response.text();
            try {
                return JSON.parse(text);
            } catch {
                return text;
            }
        } catch (error) {
            console.error(`NUI Error [${eventName}]:`, error.message);
            return null;
        }
    },

    // Close the menu safely
    closeMenu() {
        return this.post('closeMenu');
    },

    // Force close with notification
    forceClose() {
        return this.post('forceClose');
    }
};

// Expose NUI utility globally
window.NUI = NUI;

// Handle window visibility change (alt-tab, minimize, etc.)
// Only close on blur in traditional NUI mode - DUI handles this differently
if (!isDuiContext) {
    document.addEventListener('visibilitychange', function() {
        if (document.hidden) {
            console.log('Window lost visibility - closing menu');
            NUI.forceClose();
        }
    });

    // Handle window blur (another way to detect focus loss)
    window.addEventListener('blur', function() {
        console.log('Window lost focus - closing menu');
        NUI.forceClose();
    });
} else {
    console.log('DUI mode: Blur/visibility handlers disabled');
}

// Force refresh all transactions with new layout
window.refreshAllTransactions = function() {
    console.log('=== FORCING TRANSACTION REFRESH ===');
    
    // Clear current display
    const historyContainer = document.getElementById('transactionHistory');
    if (historyContainer) {
        historyContainer.innerHTML = '';
    }
    
    // Clear transaction history
    window.transactionHistory = [];
    
    // Force reload from server
    loadTransactionsFromServer();
    
    console.log('Transaction refresh triggered');
};

// Test function to manually load transactions from server
window.loadTransactionsFromServer = function() {
    console.log('=== MANUALLY LOADING TRANSACTIONS FROM SERVER ===');
    
    // Send request to server to get transactions
    fetch('https://pd_boss_menu/triggerEvent', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            eventName: 'pd_boss:server:requestTransactions'
        })
    })
    .then(response => response.text())
    .then(data => {
        console.log('Transaction request sent to server');
    })
    .catch(error => {
        console.error('Error requesting transactions:', error);
    });
};


// Quick test to check officer name
window.testOfficerName = function() {
    console.log('=== TESTING OFFICER NAME ===');
    console.log('Current data:', currentData);
    console.log('Employees:', currentData.employees);
    if (currentData.employees && currentData.employees.length > 0) {
        console.log('Current officer name:', currentData.employees[0].name);
    } else {
        console.log('No employees found');
    }
};


// Current user permissions
let currentUserPermissions = {
    viewEmployees: false,
    viewBanking: false,
    viewDisciplinary: false,
    hireEmployees: false,
    fireEmployees: false,
    changeRanks: false,
    viewReports: false,
    accessSettings: false,
    payBonuses: false
};

// Current department info for theming
let currentDepartment = 'police';

// Department display names (used throughout for dynamic labels)
const departmentLabels = {
    'police': { short: 'LSPD', full: 'Los Santos Police Department' },
    'lscso': { short: 'LSCSO', full: 'Los Santos County Sheriff\'s Office' },
    'safr': { short: 'SAFR', full: 'San Andreas Fire Rescue' },
    'sasp': { short: 'SASP', full: 'San Andreas State Police' },
    'bcso': { short: 'BCSO', full: 'Blaine County Sheriff\'s Office' }
};

// Helper function to get department label
function getDeptLabel() {
    const dept = departmentLabels[currentDepartment];
    return dept ? dept.short : 'Department';
}

// Current user info (the player using the menu)
let currentUser = {
    name: 'Unknown Officer',
    rank: 'Unknown',
    grade: 0,
    citizenid: ''
};

// Disciplinary actions data
let disciplinaryActions = [];
let disciplinaryHistory = []; // Separate storage for historical records
let selectedOfficer = null;
let currentFilter = 'all';

// Storage keys for localStorage
const DISCIPLINARY_ACTIONS_KEY = 'pd_boss_disciplinary_actions';
const DISCIPLINARY_HISTORY_KEY = 'pd_boss_disciplinary_history';

// Track hired officers this week
let hiredThisWeek = 0;

// Flag to prevent server from overriding rank permissions
let rankModalOpen = false;
let rankModalInitialized = false;

// Transaction History - Initialize global array
if (typeof window.transactionHistory === 'undefined') {
    window.transactionHistory = [];
}

// DOM Elements - with null checks
let container, closeBtn, refreshBtn, navIcons, tabPanes, currentFundsSpan;
let depositBtn, withdrawBtn, depositAmount, withdrawAmount, employeeContainer;
let playerList, employeeTableBody, employeeSearch, onlineEmployeesList;

// Initialize DOM elements when document is ready
function initializeDOMElements() {
    console.log('Initializing DOM elements...');
    
    container = document.getElementById('container');
    closeBtn = document.getElementById('closeBtn');
    refreshBtn = document.getElementById('refreshBtn');
    navIcons = document.querySelectorAll('.nav-icon');
    tabPanes = document.querySelectorAll('.tab-pane');
    currentFundsSpan = document.getElementById('currentFunds');
    depositBtn = document.getElementById('depositBtn');
    withdrawBtn = document.getElementById('withdrawBtn');
    depositAmount = document.getElementById('depositAmount');
    withdrawAmount = document.getElementById('withdrawAmount');
    employeeContainer = document.getElementById('employeeContainer');
    playerList = document.getElementById('playerList');
    employeeTableBody = document.getElementById('employeeTableBody');
    employeeSearch = document.getElementById('employeeSearch');
    onlineEmployeesList = document.getElementById('onlineEmployeesList');
    
    // Debug: Check which elements are missing
    const requiredElements = [
        'container', 'closeBtn', 'refreshBtn', 'currentFunds', 'depositBtn', 
        'withdrawBtn', 'depositAmount', 'withdrawAmount', 'employeeContainer',
        'playerList', 'employeeTableBody', 'employeeSearch', 'onlineEmployeesList'
    ];
    
    const missingElements = [];
    requiredElements.forEach(id => {
        if (!document.getElementById(id)) {
            missingElements.push(id);
        }
    });
    
    if (missingElements.length > 0) {
        console.warn('Missing DOM elements:', missingElements);
    } else {
        console.log('All DOM elements found successfully');
    }
    
    // Set up navigation after DOM elements are found
    if (navIcons && navIcons.length > 0) {
        console.log('Found', navIcons.length, 'navigation icons');
        navIcons.forEach(icon => {
            console.log('Adding click listener to icon with data-tab:', icon.dataset.tab);
            icon.addEventListener('click', () => switchTab(icon.dataset.tab));
        });
    } else {
        console.warn('No navigation icons found');
    }
    
    // Set up button event listeners
    if (depositBtn) {
        console.log('Setting up deposit button listener');
        depositBtn.addEventListener('click', handleDeposit);
    } else {
        console.warn('Deposit button not found');
    }
    
    if (withdrawBtn) {
        console.log('Setting up withdraw button listener');
        console.log('Withdraw button element:', withdrawBtn);
        withdrawBtn.addEventListener('click', handleWithdraw);
        console.log('Withdraw button listener added successfully');
    } else {
        console.warn('Withdraw button not found');
        console.log('Looking for withdraw button with ID withdrawBtn...');
        const foundBtn = document.getElementById('withdrawBtn');
        console.log('Found withdraw button:', foundBtn);
    }
    
    // Set up close button
    if (closeBtn) {
        console.log('Setting up close button listener');
        closeBtn.addEventListener('click', closeBossMenu);
    } else {
        console.warn('Close button not found');
    }
}

// Dashboard elements
const totalEmployeesValue = document.getElementById('totalEmployeesValue');
const onlineEmployees = document.getElementById('onlineEmployees');
const avgWorkHours = document.getElementById('avgWorkHours');
const highestRank = document.getElementById('highestRank');
const highestRankCount = document.getElementById('highestRankCount');
const mostCommonRank = document.getElementById('mostCommonRank');
const mostCommonRankCount = document.getElementById('mostCommonRankCount');
const activityBars = document.getElementById('activityBars');

// Event Listeners
// Close button will be set up in initializeDOMElements()

if (refreshBtn) {
    refreshBtn.addEventListener('click', function() {
        refreshData();
    });
}

// Simple function to add a test transaction directly
window.addTestTransactionDirect = function() {
    console.log('=== ADDING TEST TRANSACTION DIRECTLY ===');
    
    const historyContainer = document.getElementById('transactionHistory');
    if (!historyContainer) {
        console.error('History container not found!');
        return;
    }
    
    // Create test transaction
    const transactionEntry = document.createElement('div');
    transactionEntry.className = 'transaction-item';
    transactionEntry.innerHTML = `
        <div class="transaction-info">
            <span class="transaction-type-badge deposit">Deposit</span>
            <div class="transaction-details">
                <div class="transaction-reason">Budget Allocation</div>
                <div class="transaction-officer">Officer: Test Officer</div>
                <div class="transaction-date">${new Date().toLocaleDateString()}</div>
            </div>
        </div>
        <div class="transaction-amount positive">+$1,000.00</div>
    `;
    
    // Add to top of list
    historyContainer.insertBefore(transactionEntry, historyContainer.firstChild);
    console.log('Test transaction added successfully!');
};


// Button event listeners will be set up in initializeDOMElements()

// Navigation will be set up in initializeDOMElements()

// Search functionality
if (employeeSearch) {
    employeeSearch.addEventListener('input', function() {
        filterEmployees(this.value);
    });
}

// Simple function to add a test transaction directly
window.addTestTransactionDirect = function() {
    console.log('=== ADDING TEST TRANSACTION DIRECTLY ===');
    
    const historyContainer = document.getElementById('transactionHistory');
    if (!historyContainer) {
        console.error('History container not found!');
        return;
    }
    
    // Create test transaction
    const transactionEntry = document.createElement('div');
    transactionEntry.className = 'transaction-item';
    transactionEntry.innerHTML = `
        <div class="transaction-info">
            <span class="transaction-type-badge deposit">Deposit</span>
            <div class="transaction-details">
                <div class="transaction-reason">Budget Allocation</div>
                <div class="transaction-officer">Officer: Test Officer</div>
                <div class="transaction-date">${new Date().toLocaleDateString()}</div>
            </div>
        </div>
        <div class="transaction-amount positive">+$1,000.00</div>
    `;
    
    // Add to top of list
    historyContainer.insertBefore(transactionEntry, historyContainer.firstChild);
    console.log('Test transaction added successfully!');
};


// Global close function
function closeBossMenu() {
    console.log('Closing boss menu');
    // In DUI mode (3D panel), don't hide the menu - it should always be visible
    if (isDuiContext) {
        console.log('DUI mode: Menu stays visible on 3D panel');
        return;
    }

    // Reset traditional mode flag
    isTraditionalNuiActive = false;

    if (container) {
        container.classList.add('hidden');
        console.log('Menu hidden, traditional mode deactivated');
    }

    // Close export modal if open
    const exportModal = document.getElementById('exportModal');
    if (exportModal && !exportModal.classList.contains('hidden')) {
        exportModal.classList.add('hidden');
        console.log('Export modal closed with boss menu');
    }

    cleanupChart();
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'https://pd_boss_menu/closeMenu');
    xhr.send();
}

// Listen for ESC key
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape' || event.keyCode === 27) {
        // Check modals in order of priority (most specific to least specific)

        // Check if theme modal is open
        const themeModal = document.getElementById('themeModal');
        if (themeModal && !themeModal.classList.contains('hidden')) {
            event.preventDefault();
            event.stopPropagation();
            if (typeof closeThemeModal === 'function') {
                closeThemeModal();
            } else {
                themeModal.classList.add('hidden');
            }
            console.log('ESC pressed: Closed theme modal');
            return;
        }

        // Check if rank management modal is open
        const rankModal = document.getElementById('rankManagementModal');
        if (rankModal && !rankModal.classList.contains('hidden')) {
            event.preventDefault();
            event.stopPropagation();
            if (typeof closeRankModal === 'function') {
                closeRankModal();
            } else {
                rankModal.classList.add('hidden');
            }
            console.log('ESC pressed: Closed rank management modal');
            return;
        }

        // Check if employee edit modal is open
        const employeeEditModal = document.getElementById('employeeEditModal');
        if (employeeEditModal && !employeeEditModal.classList.contains('hidden')) {
            event.preventDefault();
            event.stopPropagation();
            if (typeof closeEmployeeEditModal === 'function') {
                closeEmployeeEditModal();
            } else {
                employeeEditModal.classList.add('hidden');
            }
            console.log('ESC pressed: Closed employee edit modal');
            return;
        }

        // Check if officer hours modal is open
        const officerHoursModal = document.getElementById('officerHoursModal');
        if (officerHoursModal && !officerHoursModal.classList.contains('hidden')) {
            event.preventDefault();
            event.stopPropagation();
            if (typeof closeOfficerHoursModal === 'function') {
                closeOfficerHoursModal();
            } else {
                officerHoursModal.classList.add('hidden');
            }
            console.log('ESC pressed: Closed officer hours modal');
            return;
        }

        // Check if officer disciplinary modal is open
        const officerDisciplinaryModal = document.getElementById('officerDisciplinaryModal');
        if (officerDisciplinaryModal && !officerDisciplinaryModal.classList.contains('hidden')) {
            event.preventDefault();
            event.stopPropagation();
            if (typeof closeOfficerDisciplinaryModal === 'function') {
                closeOfficerDisciplinaryModal();
            } else {
                officerDisciplinaryModal.classList.add('hidden');
            }
            console.log('ESC pressed: Closed officer disciplinary modal');
            return;
        }

        // Check if add disciplinary modal is open
        const addDisciplinaryModal = document.getElementById('addDisciplinaryModal');
        if (addDisciplinaryModal && !addDisciplinaryModal.classList.contains('hidden')) {
            event.preventDefault();
            event.stopPropagation();
            if (typeof closeAddDisciplinaryModal === 'function') {
                closeAddDisciplinaryModal();
            } else {
                addDisciplinaryModal.classList.add('hidden');
            }
            console.log('ESC pressed: Closed add disciplinary modal');
            return;
        }

        // Check if export modal is open
        const exportModal = document.getElementById('exportModal');
        if (exportModal && !exportModal.classList.contains('hidden')) {
            // Close only the export modal, NOT the boss menu
            event.preventDefault();
            event.stopPropagation();
            if (typeof closeExportModal === 'function') {
                closeExportModal();
            } else {
                exportModal.classList.add('hidden');
            }
            console.log('ESC pressed: Closed export modal');
            return; // Don't close boss menu
        }

        // If no modals are open, close boss menu
        if (container) {
            closeBossMenu();
        }
    }
});

// Listen for messages from client
window.addEventListener('message', function(event) {
    console.log('=== MESSAGE RECEIVED ===', event.data);
    const data = event.data;

    // Handle keyboard/text input from client (FiveM has no native DUI keyboard)
    if (data.action === 'keypress') {
        const activeEl = document.activeElement;
        if (activeEl && (activeEl.tagName === 'INPUT' || activeEl.tagName === 'TEXTAREA')) {
            if (data.key === 'Backspace') {
                // Simulate backspace
                const start = activeEl.selectionStart;
                const end = activeEl.selectionEnd;
                if (start > 0 || start !== end) {
                    const val = activeEl.value;
                    if (start === end) {
                        activeEl.value = val.slice(0, start - 1) + val.slice(end);
                        activeEl.selectionStart = activeEl.selectionEnd = start - 1;
                    } else {
                        activeEl.value = val.slice(0, start) + val.slice(end);
                        activeEl.selectionStart = activeEl.selectionEnd = start;
                    }
                    activeEl.dispatchEvent(new Event('input', { bubbles: true }));
                }
            } else if (data.key === 'Enter') {
                activeEl.dispatchEvent(new KeyboardEvent('keydown', { key: 'Enter', code: 'Enter', bubbles: true }));
            }
        }
        return;
    }

    if (data.action === 'textInput') {
        // Insert text into the currently focused input field
        const activeEl = document.activeElement;
        if (activeEl && (activeEl.tagName === 'INPUT' || activeEl.tagName === 'TEXTAREA')) {
            // Replace selection or insert at cursor
            const start = activeEl.selectionStart;
            const end = activeEl.selectionEnd;
            const val = activeEl.value;
            activeEl.value = val.slice(0, start) + data.text + val.slice(end);
            activeEl.selectionStart = activeEl.selectionEnd = start + data.text.length;
            activeEl.dispatchEvent(new Event('input', { bubbles: true }));
            console.log('[TextInput] Inserted text:', data.text);
        } else {
            // No input focused - try to find a search input
            const searchInput = document.querySelector('input[type="search"], input[type="text"], .search-input, #employeeSearch');
            if (searchInput) {
                searchInput.value = data.text;
                searchInput.dispatchEvent(new Event('input', { bubbles: true }));
                searchInput.focus();
                console.log('[TextInput] Set search input to:', data.text);
            } else {
                console.log('[TextInput] No input field found');
            }
        }
        return;
    }

    // Keyboard proxy mode - NUI stays hidden but captures keyboard for DUI
    if (data.action === 'enterKeyboardProxy') {
        console.log('[NUI] Entering keyboard proxy mode');
        keyboardProxyMode = true;
        // Hide the NUI container - user sees only the 3D panel
        const container = document.getElementById('container');
        if (container) {
            container.classList.add('hidden');
        }
        // Show the keyboard proxy input (but keep pointer-events: none to not block mouse)
        // Programmatic focus() works regardless of pointer-events
        const proxyInput = document.getElementById('keyboardProxyInput');
        if (proxyInput) {
            proxyInput.classList.remove('hidden');
            proxyInput.style.zIndex = '9999'; // Bring to front in DOM stacking
        }
        // Focus the input to capture keyboard events
        focusKeyboardProxy();
        // Set up interval to maintain focus (in case mouse clicks steal it)
        if (window.keyboardProxyInterval) {
            clearInterval(window.keyboardProxyInterval);
        }
        window.keyboardProxyInterval = setInterval(function() {
            if (keyboardProxyMode) {
                focusKeyboardProxy();
            }
        }, 100); // Refocus every 100ms
        return;
    }

    if (data.action === 'exitKeyboardProxy') {
        console.log('[NUI] Exiting keyboard proxy mode');
        keyboardProxyMode = false;
        // Stop the refocus interval
        if (window.keyboardProxyInterval) {
            clearInterval(window.keyboardProxyInterval);
            window.keyboardProxyInterval = null;
        }
        // Hide the keyboard proxy input
        const proxyInput = document.getElementById('keyboardProxyInput');
        if (proxyInput) {
            proxyInput.classList.add('hidden');
            proxyInput.style.zIndex = '-1';
            proxyInput.blur();
        }
        return;
    }

    // Keyboard input forwarded from NUI proxy to DUI
    if (data.action === 'keyboardInput' && isDuiContext) {
        console.log('[DUI] Received keyboard input:', data.key, 'char:', data.char, 'type:', data.type);
        const activeEl = document.activeElement;
        console.log('[DUI] Active element:', activeEl?.tagName, activeEl?.id || activeEl?.className);

        if (data.type === 'keydown') {
            // Handle special keys
            if (data.key === 'Backspace') {
                if (activeEl && (activeEl.tagName === 'INPUT' || activeEl.tagName === 'TEXTAREA')) {
                    const start = activeEl.selectionStart;
                    const end = activeEl.selectionEnd;
                    if (start > 0 || start !== end) {
                        const val = activeEl.value;
                        if (start === end) {
                            activeEl.value = val.slice(0, start - 1) + val.slice(end);
                            activeEl.selectionStart = activeEl.selectionEnd = start - 1;
                        } else {
                            activeEl.value = val.slice(0, start) + val.slice(end);
                            activeEl.selectionStart = activeEl.selectionEnd = start;
                        }
                        activeEl.dispatchEvent(new Event('input', { bubbles: true }));
                    }
                }
            } else if (data.key === 'Enter') {
                if (activeEl) {
                    activeEl.dispatchEvent(new KeyboardEvent('keydown', { key: 'Enter', code: 'Enter', bubbles: true }));
                }
            } else if (data.key === 'Tab') {
                // Move focus to next input
                const inputs = document.querySelectorAll('input, textarea, button, select');
                const currentIndex = Array.from(inputs).indexOf(activeEl);
                if (currentIndex >= 0 && currentIndex < inputs.length - 1) {
                    inputs[currentIndex + 1].focus();
                }
            } else if (data.char && data.char.length === 1) {
                // Printable character - insert into focused input
                if (activeEl && (activeEl.tagName === 'INPUT' || activeEl.tagName === 'TEXTAREA')) {
                    const start = activeEl.selectionStart;
                    const end = activeEl.selectionEnd;
                    const val = activeEl.value;
                    activeEl.value = val.slice(0, start) + data.char + val.slice(end);
                    activeEl.selectionStart = activeEl.selectionEnd = start + 1;
                    activeEl.dispatchEvent(new Event('input', { bubbles: true }));
                }
            }
        }
        return;
    }

    // Text input from lib.inputDialog (T key in Lua)
    if (data.action === 'textInput' && isDuiContext) {
        console.log('[DUI] Received text input:', data.text);

        // Find the first visible search input and fill it
        const searchInputs = document.querySelectorAll('input[type="text"], input:not([type])');
        for (const input of searchInputs) {
            // Check if input is visible
            const style = window.getComputedStyle(input);
            if (style.display !== 'none' && style.visibility !== 'hidden') {
                input.value = data.text;
                input.dispatchEvent(new Event('input', { bubbles: true }));
                input.focus();
                console.log('[DUI] Text inserted into:', input.id || input.placeholder);
                break;
            }
        }
        return;
    }

    // Handle cr-3dnui focus events (DUI mode only)
    if (data.type === 'focus_on') {
        console.log('[DUI] Focus gained');
        return;
    }
    if (data.type === 'focus_off') {
        console.log('[DUI] Focus lost - closing menu');
        closeBossMenu();
        return;
    }

    // Handle messages sent with 'type' instead of 'action' (e.g., receiveTransactions)
    if (data.type === 'receiveTransactions') {
        console.log('=== RECEIVED TRANSACTIONS FROM SERVER ===');
        console.log('Transactions:', data.transactions);

        if (data.transactions && Array.isArray(data.transactions)) {
            // Convert database transactions to display format
            window.transactionHistory = data.transactions.map(transaction => ({
                id: transaction.id || Date.now(),
                type: transaction.transaction_type,
                amount: transaction.amount,
                reason: transaction.reason,
                balance: transaction.balance_after,
                timestamp: new Date(transaction.timestamp),
                officer: transaction.officer_name
            }));

            console.log('Converted transactions:', window.transactionHistory);

            // Update the display
            if (typeof updateTransactionDisplay === 'function') {
                updateTransactionDisplay();
            }
        }
        return;
    }

    switch (data.action) {
        case 'openMenu':
            openMenu();
            break;
        case 'updateData':
            currentData.funds = data.funds || 0;
            currentData.players = data.players || [];
            currentData.employees = data.employees || [];
            currentData.ranks = data.ranks || [];

            // Debug: Log received employee data with online status
            console.log('=== RECEIVED EMPLOYEE DATA ===');
            console.log('Total employees:', currentData.employees.length);
            currentData.employees.forEach(emp => {
                console.log('Employee:', emp.name, 'Online:', emp.online, 'Type:', typeof emp.online);
            });
            const onlineCount = currentData.employees.filter(e => e.online === true).length;
            const offlineCount = currentData.employees.filter(e => e.online !== true).length;
            console.log('Online count:', onlineCount, 'Offline count:', offlineCount);

            // Store current user info (the player using the menu)
            if (data.currentUser) {
                currentUser = data.currentUser;
                console.log('Current user info received:', currentUser);
            }

            // Update department for theming
            if (data.department) {
                currentDepartment = data.department;
                applyDepartmentTheme(data.department);
            }

            // Note: Server sends emp.online (boolean), not emp.status
            // Do NOT add a default status - the online field is authoritative

            // Only update if DOM elements are ready
            if (document.getElementById('totalEmployees')) {
                updateDashboard();
                updateFundsDisplay();
                updateEmployeeList();
                updatePlayerList();
                // Also update analytics display so it uses current employee online count
                updateAnalyticsDisplay();
            } else {
                console.warn('DOM not ready, skipping data update');
            }
            break;
        case 'forceClose':
            // Close all open modals first
            closeAllModals();
            // In DUI mode, don't hide the container - panel should always show
            if (!isDuiContext && container) {
                container.classList.add('hidden');
                isTraditionalNuiActive = false;
                console.log('forceClose: Standard NUI hidden, traditional mode deactivated');
            }
            cleanupChart();
            break;
        case 'updateNearbyPlayers':
            currentData.players = data.players || [];
            updatePlayerList();
            break;
        case 'updateRankPermissions':
            console.log('Received rank permissions from server:', data.permissions);
            updateRankPermissionUI(data.permissions);
            break;
        case 'updateUserPermissions':
            currentUserPermissions = data.permissions;
            applyPermissionRestrictions();
            break;
        case 'updateSearchResults':
            displaySearchResults(data.characters);
            break;
        case 'receiveDisciplinaryActions':
            console.log('Received disciplinary actions from server:', data.actions);
            processDisciplinaryActionsFromServer(data.actions);
            break;
        case 'receiveDutyAnalytics':
            console.log('Received duty analytics from server:', data.data);
            processDutyAnalyticsFromServer(data.data);
            break;
        case 'receiveOfficerDutyHistory':
            console.log('Received officer duty history from server:', data.data);
            processOfficerDutyHistoryFromServer(data.data);
            break;

        case 'receiveExportTransactions':
            console.log('=== RECEIVED EXPORT TRANSACTIONS ===');
            console.log('Response:', data.data);
            if (typeof updateExportTable === 'function') {
                if (data.data && data.data.success) {
                    exportTransactions = data.data.transactions || [];
                    console.log('Loaded', exportTransactions.length, 'export transactions');
                    updateExportTable();
                } else {
                    console.error('Failed to load export transactions:', data.data ? data.data.message : 'No data');
                    exportTransactions = [];
                    updateExportTable();
                }
            }
            break;

        // ========================================
        // LIVE UPDATE HANDLERS (Event-Driven)
        // ========================================
        case 'liveEmployeeUpdate':
            console.log('📡 Live employee update:', data.updateType, data.employee?.name);
            handleLiveEmployeeUpdate(data.updateType, data.employee);
            break;

        case 'liveAnalyticsUpdate':
            console.log('📡 Live analytics update - Online:', data.onlineCount);
            handleLiveAnalyticsUpdate(data.onlineCount, data.activeSessions);
            break;
    }
});

// ========================================
// LIVE UPDATE PROCESSING FUNCTIONS
// Updates UI without full refresh
// ========================================

function handleLiveEmployeeUpdate(updateType, employee) {
    if (!employee || !employee.citizenid) return;

    const existingIndex = currentData.employees.findIndex(e => e.citizenid === employee.citizenid);

    switch (updateType) {
        case 'online':
            // Employee came online
            if (existingIndex >= 0) {
                // Update existing employee
                currentData.employees[existingIndex].online = true;
                if (employee.rank) currentData.employees[existingIndex].rank = employee.rank;
                if (employee.grade !== undefined) currentData.employees[existingIndex].grade = employee.grade;
                if (employee.onDuty !== undefined) currentData.employees[existingIndex].onDuty = employee.onDuty;
            } else {
                // Add new employee (they might have just joined the department)
                currentData.employees.push({
                    citizenid: employee.citizenid,
                    name: employee.name,
                    rank: employee.rank || 'Unknown',
                    grade: employee.grade || 0,
                    online: true,
                    onDuty: employee.onDuty || false
                });
            }
            showLiveUpdateToast(`${employee.name} is now online`, 'success');
            break;

        case 'offline':
            // Employee went offline
            if (existingIndex >= 0) {
                currentData.employees[existingIndex].online = false;
                currentData.employees[existingIndex].onDuty = false;
            }
            showLiveUpdateToast(`${employee.name} went offline`, 'info');
            break;

        case 'duty_start':
            // Employee started duty
            if (existingIndex >= 0) {
                currentData.employees[existingIndex].onDuty = true;
            }
            showLiveUpdateToast(`${employee.name} went on duty`, 'success');
            break;

        case 'duty_end':
            // Employee ended duty
            if (existingIndex >= 0) {
                currentData.employees[existingIndex].onDuty = false;
            }
            showLiveUpdateToast(`${employee.name} went off duty`, 'info');
            break;

        case 'job_change':
            // Employee changed jobs - remove from current list
            if (existingIndex >= 0) {
                currentData.employees.splice(existingIndex, 1);
            }
            showLiveUpdateToast(`${employee.name} left the department`, 'warning');
            break;
    }

    // Update UI components efficiently (no full refresh)
    updateDashboard();
    updateEmployeeList();
    updateAnalyticsDisplay();

    // Also update analytics panel if it exists
    if (typeof updateAnalytics === 'function') {
        updateAnalytics();
    }
}

function handleLiveAnalyticsUpdate(onlineCount, activeSessions) {
    // Update server duty data
    if (!window.serverDutyData) {
        window.serverDutyData = {};
    }
    window.serverDutyData.activeSessions = activeSessions || [];

    // Update the on-duty count in stats
    const onDutyElement = document.getElementById('onlineOfficers');
    if (onDutyElement) {
        onDutyElement.textContent = onlineCount.toString();
    }

    const officersOnDutyElement = document.getElementById('officersOnDuty');
    if (officersOnDutyElement) {
        officersOnDutyElement.textContent = onlineCount.toString();
    }

    // Update active sessions list if visible
    const activeSessionsList = document.getElementById('activeSessionsList') || document.getElementById('dutyOfficersList');
    if (activeSessionsList && activeSessions) {
        let html = '';
        if (activeSessions.length > 0) {
            activeSessions.forEach(session => {
                const hours = Math.floor(session.currentMinutes / 60);
                const mins = session.currentMinutes % 60;
                const timeStr = hours > 0 ? `${hours}h ${mins}m` : `${mins}m`;
                html += `
                    <div class="duty-officer-item">
                        <span class="officer-name">${session.name}</span>
                        <span class="status-online">On Duty</span>
                        <span class="duty-time">${timeStr}</span>
                    </div>
                `;
            });
        } else {
            html = '<div class="no-data">No officers currently on duty</div>';
        }
        activeSessionsList.innerHTML = html;
    }

    console.log('📊 Analytics updated - Officers on duty:', onlineCount);
}

// Show a subtle toast notification for live updates
function showLiveUpdateToast(message, type = 'info') {
    // Only show if Animations utility exists
    if (typeof Animations !== 'undefined' && Animations.showToast) {
        Animations.showToast({
            title: 'Live Update',
            message: message,
            type: type,
            duration: 3000,
            icon: type === 'success' ? '✅' : type === 'warning' ? '⚠️' : 'ℹ️'
        });
    } else {
        console.log(`[Live Update] ${message}`);
    }
}

// Track if we're in traditional NUI mode (SetNuiFocus was used)
let isTraditionalNuiActive = false;

// Functions
function openMenu() {
    // Safety: In standard NUI frame, mark that we're now in traditional mode
    if (!isDuiContext) {
        isTraditionalNuiActive = true;
        console.log('openMenu: Standard NUI context, setting traditional mode active');
    }

    if (container) {
        container.classList.remove('hidden');
        switchTab('dashboard');
        // Get current user permissions
        getUserPermissions();
        
        // Fetch real-time duty data for all officers (including offline) to populate weekly hours
        if (typeof initializeRealTimeTracking === 'function') {
            initializeRealTimeTracking();
        } else {
            // Fallback: request duty data directly
            fetch('https://pd_boss_menu/getRealTimeDutyData', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            }).catch(() => {});
        }
    }
}

// Get current user's permissions
function getUserPermissions() {
    console.log('=== REQUESTING USER PERMISSIONS ===');

    // Use fetch to trigger the server event - permissions arrive via message event
    fetch('https://pd_boss_menu/getUserPermissions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).then(response => {
        console.log('User permissions request sent, waiting for data via message event');
    }).catch(error => {
        console.error('Error requesting user permissions:', error);
        // If request fails, use default full access
        currentUserPermissions = {
            viewEmployees: true,
            viewBanking: true,
            viewDisciplinary: true,
            hireEmployees: true,
            fireEmployees: true,
            changeRanks: true,
            viewReports: true,
            accessSettings: true
        };
        console.log('=== USING DEFAULT PERMISSIONS (FULL ACCESS) ===', currentUserPermissions);
        applyPermissionRestrictions();
    });

    // Note: Actual permission data arrives via the 'updateUserPermissions' message event
}

// Apply permission restrictions to the UI
function applyPermissionRestrictions() {
    console.log('=== APPLYING PERMISSION RESTRICTIONS ===', currentUserPermissions);
    
    // If no permissions are loaded yet, don't hide anything
    if (!currentUserPermissions || Object.keys(currentUserPermissions).length === 0) {
        console.log('No permissions loaded yet, skipping restrictions');
        return;
    }
    
    // Hide/show banking tab based on viewBanking permission
    const bankingTab = document.querySelector('[data-tab="funds"]');
    if (bankingTab) {
        const shouldShow = currentUserPermissions.viewBanking;
        console.log('=== BANKING TAB PERMISSION CHECK ===');
        console.log('Current user permissions:', currentUserPermissions);
        console.log('viewBanking permission:', currentUserPermissions.viewBanking);
        console.log('Banking tab visibility:', shouldShow ? 'SHOW' : 'HIDE');
        console.log('Banking tab element found:', bankingTab);
        bankingTab.style.display = shouldShow ? 'flex' : 'none';
        console.log('Banking tab display style set to:', bankingTab.style.display);
    } else {
        console.log('Banking tab element not found');
    }
    
    // Hide/show hire tab based on hireEmployees permission (same as banking)
    const hireTab = document.querySelector('[data-tab="hire"]');
    if (hireTab) {
        const shouldShow = currentUserPermissions.hireEmployees;
        console.log('=== HIRE TAB PERMISSION CHECK ===');
        console.log('Current user permissions:', currentUserPermissions);
        console.log('hireEmployees permission:', currentUserPermissions.hireEmployees);
        console.log('Hire tab visibility:', shouldShow ? 'SHOW' : 'HIDE');
        console.log('Hire tab element found:', hireTab);
        
        // WORKAROUND: Use local storage to track hire permission since server database is broken
        // Check if we have a locally stored hire permission state
        const localHirePermission = localStorage.getItem('hireEmployeesPermission');
        let shouldShowHire = currentUserPermissions.hireEmployees;
        
        if (localHirePermission !== null) {
            // Use locally stored permission instead of server value
            shouldShowHire = localHirePermission === 'true';
            console.log('Using local hire permission:', shouldShowHire);
        } else {
            console.log('No local hire permission found, using server value:', shouldShowHire);
        }
        
        hireTab.style.display = shouldShowHire ? 'flex' : 'none';
        
        console.log('Hire tab display style set to:', hireTab.style.display);
    } else {
        console.log('Hire tab element not found');
    }
    
    // Hide/show disciplinary tab based on viewDisciplinary permission
    const disciplinaryTab = document.querySelector('[data-tab="employees"]');
    if (disciplinaryTab) {
        const shouldShow = currentUserPermissions.viewDisciplinary;
        console.log('=== DISCIPLINARY TAB PERMISSION CHECK ===');
        console.log('Current user permissions:', currentUserPermissions);
        console.log('viewDisciplinary permission:', currentUserPermissions.viewDisciplinary);
        console.log('Disciplinary tab visibility:', shouldShow ? 'SHOW' : 'HIDE');
        console.log('Tab element found:', disciplinaryTab);
        disciplinaryTab.style.display = shouldShow ? 'flex' : 'none';
        console.log('Tab display style set to:', disciplinaryTab.style.display);
    } else {
        console.log('Disciplinary tab element not found');
    }
    
    // Hide/show settings tab based on accessSettings permission
    const settingsTab = document.querySelector('[data-tab="settings"]');
    if (settingsTab) {
        // WORKAROUND: Use local storage to track accessSettings permission since server database is broken
        const localAccessSettingsPermission = localStorage.getItem('accessSettingsPermission');
        let shouldShow = currentUserPermissions.accessSettings;
        
        if (localAccessSettingsPermission !== null) {
            // Use locally stored permission instead of server value
            shouldShow = localAccessSettingsPermission === 'true';
            console.log('Using local accessSettings permission:', shouldShow);
        } else {
            console.log('No local accessSettings permission found, using server value:', shouldShow);
        }
        
        console.log('=== SETTINGS TAB PERMISSION CHECK ===');
        console.log('accessSettings permission:', currentUserPermissions.accessSettings);
        console.log('Settings tab visibility:', shouldShow ? 'SHOW' : 'HIDE');
        settingsTab.style.display = shouldShow ? 'flex' : 'none';
        console.log('Settings tab display style set to:', settingsTab.style.display);
    } else {
        console.log('Settings tab element not found');
    }
    
    // Hide/show rank change buttons and rank selection based on changeRanks permission
    const rankChangeButtons = document.querySelectorAll('.btn-promote, .rank-select, .rank-change-btn, .btn-rank-change');
    const rankSelectionGrid = document.getElementById('rankSelectionGrid');
    const rankSelectionSection = document.querySelector('.form-section:has(#rankSelectionGrid)');
    
    rankChangeButtons.forEach(button => {
        const shouldShow = currentUserPermissions.changeRanks;
        console.log('=== RANK CHANGE BUTTONS PERMISSION CHECK ===');
        console.log('changeRanks permission:', currentUserPermissions.changeRanks);
        console.log('Rank change button visibility:', shouldShow ? 'SHOW' : 'HIDE');
        button.style.display = shouldShow ? 'block' : 'none';
    });
    
    // Hide the entire rank selection section if user doesn't have changeRanks permission
    if (rankSelectionGrid) {
        const shouldShow = currentUserPermissions.changeRanks;
        console.log('=== RANK SELECTION GRID PERMISSION CHECK ===');
        console.log('changeRanks permission:', currentUserPermissions.changeRanks);
        console.log('Rank selection grid visibility:', shouldShow ? 'SHOW' : 'HIDE');
        rankSelectionGrid.style.display = shouldShow ? 'grid' : 'none';
    }
    
    if (rankSelectionSection) {
        const shouldShow = currentUserPermissions.changeRanks;
        console.log('=== RANK SELECTION SECTION PERMISSION CHECK ===');
        console.log('changeRanks permission:', currentUserPermissions.changeRanks);
        console.log('Rank selection section visibility:', shouldShow ? 'SHOW' : 'HIDE');
        rankSelectionSection.style.display = shouldShow ? 'block' : 'none';
    }
    
    console.log('Found', rankChangeButtons.length, 'rank change buttons');
    
    // Hide/show fire buttons based on fireEmployees permission
    const fireButtons = document.querySelectorAll('.btn-fire, .fire-btn, .btn-fire-employee');
    fireButtons.forEach(button => {
        const shouldShow = currentUserPermissions.fireEmployees;
        console.log('=== FIRE BUTTONS PERMISSION CHECK ===');
        console.log('fireEmployees permission:', currentUserPermissions.fireEmployees);
        console.log('Fire button visibility:', shouldShow ? 'SHOW' : 'HIDE');
        button.style.display = shouldShow ? 'block' : 'none';
    });
    console.log('Found', fireButtons.length, 'fire buttons');
    
    // Hide/show hire buttons based on hireEmployees permission
    const hireButtons = document.querySelectorAll('.btn-hire, .hire-btn, .btn-hire-employee');
    hireButtons.forEach(button => {
        const shouldShow = currentUserPermissions.hireEmployees;
        console.log('=== HIRE BUTTONS PERMISSION CHECK ===');
        console.log('hireEmployees permission:', currentUserPermissions.hireEmployees);
        console.log('Hire button visibility:', shouldShow ? 'SHOW' : 'HIDE');
        button.style.display = shouldShow ? 'block' : 'none';
    });
    console.log('Found', hireButtons.length, 'hire buttons');
    
    // Also apply permissions to any open modals
    applyModalPermissions();
}

// Apply permissions to modal content
function applyModalPermissions() {
    console.log('=== APPLYING MODAL PERMISSIONS ===');
    
    // Hide/show rank selection based on changeRanks permission
    // WORKAROUND: Use local storage to track changeRanks permission since server database is broken
    const localChangeRanksPermission = localStorage.getItem('changeRanksPermission');
    let shouldShowRanks = currentUserPermissions.changeRanks;
    
    if (localChangeRanksPermission !== null) {
        // Use locally stored permission instead of server value
        shouldShowRanks = localChangeRanksPermission === 'true';
        console.log('Using local changeRanks permission:', shouldShowRanks);
    } else {
        console.log('No local changeRanks permission found, using server value:', shouldShowRanks);
    }
    
    console.log('changeRanks permission:', currentUserPermissions.changeRanks);
    console.log('Rank selection visibility:', shouldShowRanks ? 'SHOW' : 'HIDE');
    
    // Target the specific rank selection elements
    const rankSelectionGrid = document.getElementById('rankSelectionGrid');
    const rankChangePreview = document.getElementById('rankChangePreview');
    
    // Hide/show the rank selection grid
    if (rankSelectionGrid) {
        console.log('Hiding/showing rank selection grid');
        rankSelectionGrid.style.display = shouldShowRanks ? 'grid' : 'none';
    }
    
    // Hide/show the rank change preview
    if (rankChangePreview) {
        console.log('Hiding/showing rank change preview');
        rankChangePreview.style.display = shouldShowRanks ? 'block' : 'none';
    }
    
    // Hide/show the entire form section containing rank selection
    const rankFormSection = document.querySelector('#employeeEditModal .form-section:has(#rankSelectionGrid)');
    if (rankFormSection) {
        console.log('Hiding/showing rank form section');
        rankFormSection.style.display = shouldShowRanks ? 'block' : 'none';
    }
    
    // Only hide the specific rank selection form section, not all rank elements
    const rankSelectionFormSection = document.querySelector('#employeeEditModal .form-section');
    if (rankSelectionFormSection && rankSelectionFormSection.querySelector('#rankSelectionGrid')) {
        console.log('Hiding/showing rank selection form section');
        rankSelectionFormSection.style.display = shouldShowRanks ? 'block' : 'none';
    }
    
    // Hide/show fire buttons in modal
    // WORKAROUND: Use local storage to track fireEmployees permission since server database is broken
    const localFireEmployeesPermission = localStorage.getItem('fireEmployeesPermission');
    let shouldShowFire = currentUserPermissions.fireEmployees;
    
    if (localFireEmployeesPermission !== null) {
        // Use locally stored permission instead of server value
        shouldShowFire = localFireEmployeesPermission === 'true';
        console.log('Using local fireEmployees permission:', shouldShowFire);
    } else {
        console.log('No local fireEmployees permission found, using server value:', shouldShowFire);
    }
    
    const modalFireButtons = document.querySelectorAll('#employeeEditModal .btn-fire, #employeeEditModal .fire-btn, #employeeEditModal .btn-fire-employee');
    modalFireButtons.forEach(button => {
        console.log('Modal fire button visibility:', shouldShowFire ? 'SHOW' : 'HIDE');
        button.style.display = shouldShowFire ? 'block' : 'none';
    });
    
    console.log('Found', modalFireButtons.length, 'fire buttons in modal');
}

function switchTab(tabName) {
    console.log('Switching to tab:', tabName);

    // Update nav icons
    if (navIcons && navIcons.length > 0) {
        navIcons.forEach(icon => icon.classList.remove('active'));
    }
    const activeNavIcon = document.querySelector(`[data-tab="${tabName}"]`);
    if (activeNavIcon) {
        activeNavIcon.classList.add('active');
        console.log('Activated nav icon for:', tabName);
    } else {
        console.warn('Nav icon not found for tab:', tabName);
    }

    // Update tab panes with animation
    if (tabPanes && tabPanes.length > 0) {
        tabPanes.forEach(pane => pane.classList.remove('active'));
    }
    const activeTabPane = document.getElementById(tabName);
    if (activeTabPane) {
        activeTabPane.classList.add('active');
        console.log('Activated tab pane for:', tabName);

        // Animate cards in the new tab with staggered entrance
        if (window.Animations) {
            setTimeout(() => {
                Animations.animateStaggered(`#${tabName} .stat-card, #${tabName} .analytics-card`, 'animate-fade-in-up', 80);
            }, 50);
        }
    } else {
        console.warn('Tab pane not found for:', tabName);
    }

    // If switching to hire tab, get nearby players once
    if (tabName === 'hire') {
        console.log('Switching to hire tab, getting nearby players...');
        getNearbyPlayers();
        updateRecruitmentStats();
    }

    // If switching to analytics tab, refresh duty tracking
    if (tabName === 'analytics') {
        refreshDutyTracking();
        updateAnalytics();
    }

    // If switching to employees tab, initialize disciplinary actions
    if (tabName === 'employees') {
        initializeDisciplinaryActions();
    }

    // If switching to funds tab, load transaction history
    if (tabName === 'funds') {
        console.log('Switching to funds tab, loading transaction history...');
        console.log('loadTransactionHistory function type:', typeof loadTransactionHistory);
        console.log('loadTransactionHistoryFallback function type:', typeof loadTransactionHistoryFallback);
        console.log('updateTransactionDisplay function type:', typeof updateTransactionDisplay);

        // Load transaction history using the new event system
        console.log('Loading transaction history using event system...');
        testLoadTransactions();
    }
}

// Test function to manually load transactions
function testLoadTransactions() {
    console.log('=== MANUAL TRANSACTION LOADING TEST ===');
    console.log('Function called at:', new Date().toISOString());

    // Use fetch to trigger the server event - transactions arrive via message event
    console.log('Loading transactions using NUI callback...');

    fetch('https://pd_boss_menu/getTransactions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).then(response => {
        console.log('Transaction request sent, waiting for data via message event');
    }).catch(error => {
        console.error('Error requesting transactions:', error);
    });

    // Note: Actual transaction data arrives via the 'receiveTransactions' message event
    // which is handled by the window.addEventListener('message') handler
}


// Update transaction display
function updateTransactionDisplay() {
    const historyContainer = document.getElementById('transactionHistory');
    if (!historyContainer) {
        console.warn('Transaction history container not found');
        return;
    }
    
    console.log('=== UPDATING TRANSACTION DISPLAY ===');
    console.log('Transaction history:', window.transactionHistory);
    
    if (!window.transactionHistory || window.transactionHistory.length === 0) {
        historyContainer.innerHTML = '<div class="no-transactions">No transactions found</div>';
        return;
    }
    
    // Sort transactions by timestamp (newest first)
    const sortedTransactions = window.transactionHistory.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
    
    let html = '';
    sortedTransactions.forEach(transaction => {
        const isDeposit = transaction.type === 'deposit';
        const isVehiclePurchase = transaction.type === 'vehicle_purchase';
        const amountClass = isDeposit ? 'deposit' : 'withdraw';
        const amountPrefix = isDeposit ? '+' : '-';
        const formattedAmount = `$${transaction.amount.toLocaleString()}`;
        const formattedDate = new Date(transaction.timestamp).toLocaleDateString();
        const formattedTime = new Date(transaction.timestamp).toLocaleTimeString();

        // Determine badge label based on transaction type
        let badgeLabel = transaction.type.toUpperCase();
        let badgeClass = amountClass;
        if (isVehiclePurchase) {
            badgeLabel = 'VEHICLE';
            badgeClass = 'vehicle-purchase'; // Special class for vehicle purchases
        }

        html += `
            <div class="transaction-item">
                <div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 0.5rem;">
                    <span class="transaction-type-badge ${badgeClass}">${badgeLabel}</span>
                    <div class="transaction-amount ${amountClass}">${amountPrefix}${formattedAmount}</div>
                </div>
                <div style="display: flex; flex-direction: column; gap: 0.25rem;">
                    <div class="transaction-reason">${getReasonText(transaction.reason)}</div>
                    <div class="transaction-officer">Officer: ${transaction.officer}</div>
                    <div class="transaction-date">${formattedDate} at ${formattedTime}</div>
                </div>
            </div>
        `;
    });
    
    historyContainer.innerHTML = html;
    console.log('Transaction display updated with', sortedTransactions.length, 'transactions');
}

// Make sure the function is available globally
window.updateTransactionDisplay = updateTransactionDisplay;

// Test function to verify everything works
window.testTransactionDisplay = function() {
    console.log('=== TESTING TRANSACTION DISPLAY ===');
    console.log('updateTransactionDisplay function:', typeof updateTransactionDisplay);
    console.log('window.updateTransactionDisplay function:', typeof window.updateTransactionDisplay);
    
    // Create test transactions
    window.transactionHistory = [
        {
            id: 1,
            type: 'deposit',
            amount: 1000,
            reason: 'budget_allocation',
            balance: 55115,
            timestamp: new Date(),
            officer: 'Test Officer'
        }
    ];
    
    console.log('Test transactions created:', window.transactionHistory);
    
    // Try to update display
    if (typeof updateTransactionDisplay === 'function') {
        updateTransactionDisplay();
        console.log('updateTransactionDisplay called successfully');
    } else {
        console.error('updateTransactionDisplay function not available');
    }
};


// Get reason text for display
function getReasonText(reason) {
    const reasonMap = {
        // Deposit reasons
        'budget_allocation': 'Budget Allocation',
        'revenue_collection': 'Revenue Collection',
        'grant_funding': 'Grant Funding',
        'donation': 'Donation',
        
        // Withdrawal reasons
        'equipment_purchase': 'Equipment Purchase',
        'maintenance': 'Maintenance',
        'training': 'Training',
        'operational_expenses': 'Operational Expenses',
        'emergency_fund': 'Emergency Fund',
        
        // Common
        'other': 'Other',
        
        // Handle old database entries
        'Deposit to PD funds': 'Budget Allocation',
        'Withdrawal from PD funds': 'Equipment Purchase'
    };
    
    return reasonMap[reason] || reason;
}


// Client event handler to receive transactions

// Global function for manual testing
window.testTransactions = testLoadTransactions;
window.testTransactionsDirect = function() {
    console.log('Direct test function called');
    console.log('testLoadTransactions type:', typeof testLoadTransactions);
    if (typeof testLoadTransactions === 'function') {
        testLoadTransactions();
    } else {
        console.error('testLoadTransactions is not a function');
    }
};


// Load transactions when script loads
console.log('=== LOADING TRANSACTIONS ON SCRIPT START ===');
setTimeout(function() {
    console.log('Loading transactions after 2 second delay...');
    testLoadTransactions();
}, 2000);

function refreshData() {
    console.log('=== REFRESH DATA CALLED ===');
    
    // Use fetch instead of XMLHttpRequest to prevent blocking
    fetch('https://pd_boss_menu/refreshData', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(response => {
        console.log('Refresh data response:', response.status);
        return response.text();
    })
    .then(text => {
        console.log('Refresh data completed:', text);
    })
    .catch(error => {
        console.error('Refresh data error:', error);
        // Don't let errors freeze the UI
    });
}

// Simple function to add a test transaction directly
window.addTestTransactionDirect = function() {
    console.log('=== ADDING TEST TRANSACTION DIRECTLY ===');
    
    const historyContainer = document.getElementById('transactionHistory');
    if (!historyContainer) {
        console.error('History container not found!');
        return;
    }
    
    // Create test transaction
    const transactionEntry = document.createElement('div');
    transactionEntry.className = 'transaction-item';
    transactionEntry.innerHTML = `
        <div class="transaction-info">
            <span class="transaction-type-badge deposit">Deposit</span>
            <div class="transaction-details">
                <div class="transaction-reason">Budget Allocation</div>
                <div class="transaction-officer">Officer: Test Officer</div>
                <div class="transaction-date">${new Date().toLocaleDateString()}</div>
            </div>
        </div>
        <div class="transaction-amount positive">+$1,000.00</div>
    `;
    
    // Add to top of list
    historyContainer.insertBefore(transactionEntry, historyContainer.firstChild);
    console.log('Test transaction added successfully!');
};


function updateDashboard() {
    console.log('=== UPDATE DASHBOARD CALLED ===');
    
    // Check if required elements exist before proceeding
    const totalEmployeesEl = document.getElementById('totalEmployees');
    if (!totalEmployeesEl) {
        console.warn('Dashboard elements not ready, skipping update');
        return;
    }
    
    // Update total employees
    const totalEmployees = currentData.employees.length;
    if (totalEmployeesValue) {
        totalEmployeesValue.textContent = totalEmployees;
    } else {
        console.warn('totalEmployeesValue element not found');
    }
    if (totalEmployeesEl) {
        totalEmployeesEl.textContent = totalEmployees;
    } else {
        console.warn('totalEmployees element not found');
    }
    
    // Update online employees (using boolean online field from server)
    const onlineCount = currentData.employees.filter(emp => emp.online === true).length;
    if (onlineEmployees) {
        onlineEmployees.textContent = onlineCount;
    } else {
        console.warn('onlineEmployees element not found');
    }
    
    // Update sidebar quick stats
    updateSidebarStats();
    
    // Update total weekly hours (sum of all officers' weekly hours)
    if (avgWorkHours) {
        let totalWeeklyMinutes = 0;
        
        // Get weekly hours from allOfficersDutyData if available
        if (typeof allOfficersDutyData !== 'undefined' && allOfficersDutyData.length > 0) {
            allOfficersDutyData.forEach(officer => {
                totalWeeklyMinutes += (officer.weeklyHours?.total_minutes || 0);
            });
        }
        
        const hours = Math.floor(totalWeeklyMinutes / 60);
        const mins = Math.floor(totalWeeklyMinutes % 60);
        avgWorkHours.textContent = `${hours}h ${mins}m`;
    } else {
        console.warn('avgWorkHours element not found');
    }
    
    // Update highest rank
    if (currentData.employees.length > 0) {
        const sortedByGrade = [...currentData.employees].sort((a, b) => b.grade - a.grade);
        const highest = sortedByGrade[0];
        const highestRankLabel = getRankLabel(highest.grade);
        if (highestRank) {
            highestRank.textContent = highestRankLabel;
        } else {
            console.warn('highestRank element not found');
        }
        
        const highestCount = currentData.employees.filter(emp => emp.grade === highest.grade).length;
        if (highestRankCount) {
            highestRankCount.textContent = highestCount;
        } else {
            console.warn('highestRankCount element not found');
        }
    }
    
    // Update most common rank
    if (currentData.employees.length > 0) {
        const rankCounts = {};


        currentData.employees.forEach(emp => {
            rankCounts[emp.grade] = (rankCounts[emp.grade] || 0) + 1;
        });
        
        let mostCommon = 0;
        let maxCount = 0;
        Object.keys(rankCounts).forEach(grade => {
            if (rankCounts[grade] > maxCount) {
                maxCount = rankCounts[grade];
                mostCommon = parseInt(grade);
            }
        });
        
        const mostCommonLabel = getRankLabel(mostCommon);
        if (mostCommonRank) {
            mostCommonRank.textContent = mostCommonLabel;
        } else {
            console.warn('mostCommonRank element not found');
        }
        if (mostCommonRankCount) {
            mostCommonRankCount.textContent = maxCount;
        } else {
            console.warn('mostCommonRankCount element not found');
        }
    }
    
    // Initialize duty tracking
    initializeDutyTracking();
    
    // Update analytics with duty tracking
    updateAnalytics();
    
    // Update online employees list
    updateOnlineEmployeesList();
    
    // Update employee table
    updateEmployeeTable();
}

function getRankLabel(grade) {
    const rank = currentData.ranks.find(r => r.grade === grade);
    return rank ? rank.label : 'Unknown';
}

// Duty tracking variables
let dutyTracking = {
    officers: new Map(), // officerId -> { startTime, totalTime, isOnDuty, name }
    weeklyHours: new Map(), // officerId -> weekly hours
    dailyHours: new Map() // officerId -> { date: hours }
};


// Chart variables
let dutyTimeChart = null;
let chartData = {
    labels: [],
    dutyHours: [],
    onlineOfficers: []
};


// Global chart cleanup function
function cleanupChart() {
    if (dutyTimeChart) {
        console.log('Cleaning up existing chart...');
        try {
            dutyTimeChart.destroy();
        } catch (error) {
            console.warn('Error destroying chart during cleanup:', error);
        }
        dutyTimeChart = null;
    }
}

// Initialize duty tracking - now loads from server
function initializeDutyTracking() {
    console.log('=== INITIALIZE DUTY TRACKING CALLED ===');

    // Reset local duty tracking data
    dutyTracking.officers.clear();
    dutyTracking.weeklyHours.clear();
    dutyTracking.dailyHours.clear();

    // Request duty analytics from server (persistent data)
    console.log('Requesting duty analytics from server...');
    fetch('https://pd_boss_menu/getDutyAnalytics', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).catch(err => {
        console.error('Error requesting duty analytics:', err);
    });

    // Also initialize with current online employees for real-time display
    if (currentData.employees) {
        currentData.employees.forEach(emp => {
            if (emp.online === true) {
                console.log('Initializing duty tracking for online:', emp.name);
                startDutyTracking(emp.citizenid || emp.id, emp.name);
            }
        });
    }

    console.log(`Duty tracking initialized - ${dutyTracking.officers.size} officers on duty`);
}

// Process duty analytics received from server
function processDutyAnalyticsFromServer(serverData) {
    console.log('Processing duty analytics from server');

    if (!serverData) return;

    // Store server weekly data for display
    window.serverDutyData = serverData;

    // Update weekly hours from server data
    if (serverData.weeklyData) {
        serverData.weeklyData.forEach(officer => {
            dutyTracking.weeklyHours.set(officer.citizenid, officer.totalMinutes / 60);

            // Store daily breakdown
            if (officer.dailyBreakdown) {
                const dailyData = {};
                officer.dailyBreakdown.forEach(day => {
                    dailyData[day.date] = day.minutes / 60;
                });
                dutyTracking.dailyHours.set(officer.citizenid, dailyData);
            }
        });
    }

    // Update active sessions display
    if (serverData.activeSessions) {
        serverData.activeSessions.forEach(session => {
            if (!dutyTracking.officers.has(session.citizenid)) {
                dutyTracking.officers.set(session.citizenid, {
                    startTime: new Date(session.startTime * 1000),
                    totalTime: session.currentMinutes * 60 * 1000,
                    isOnDuty: true,
                    name: session.name
                });
            }
        });
    }

    // Update the analytics display
    updateAnalyticsDisplay();

    console.log('Duty analytics processed - Weekly data for', serverData.weeklyData?.length || 0, 'officers');
}

// Process officer duty history from server
function processOfficerDutyHistoryFromServer(serverData) {
    console.log('Processing officer duty history from server');

    if (!serverData) return;

    // Store for the officer hours modal
    window.officerDutyHistory = serverData;

    // Update the modal if it's open
    const modal = document.getElementById('officerHoursModal');
    if (modal && !modal.classList.contains('hidden')) {
        updateOfficerHoursModalWithServerData(serverData);
    }
}

// Update analytics display with server data
function updateAnalyticsDisplay() {
    const serverData = window.serverDutyData;

    // Get online count from employee list as fallback/primary source
    const employeeOnlineCount = currentData.employees ? currentData.employees.filter(e => e.online === true).length : 0;

    // Use active sessions if available, otherwise use employee online count
    let activeSessionsCount = 0;
    if (serverData && serverData.activeSessions && serverData.activeSessions.length > 0) {
        activeSessionsCount = serverData.activeSessions.length;
    } else {
        // Fallback to online employee count from employee list
        activeSessionsCount = employeeOnlineCount;
    }

    console.log('Analytics: activeSessions=', serverData?.activeSessions?.length || 0, 'employeeOnline=', employeeOnlineCount, 'using=', activeSessionsCount);

    // Update the on-duty count in stats
    const onDutyElement = document.getElementById('onlineOfficers');
    if (onDutyElement) {
        onDutyElement.textContent = activeSessionsCount.toString();
    }

    // Also update the stat card if it exists
    const officersOnDutyElement = document.getElementById('officersOnDuty');
    if (officersOnDutyElement) {
        officersOnDutyElement.textContent = activeSessionsCount.toString();
    }

    if (!serverData) return;

    // Update active sessions list if container exists
    const activeSessionsList = document.getElementById('activeSessionsList') || document.getElementById('dutyOfficersList');
    if (activeSessionsList && serverData.activeSessions) {
        let html = '';
        if (serverData.activeSessions.length > 0) {
            serverData.activeSessions.forEach(session => {
                const hours = Math.floor(session.currentMinutes / 60);
                const mins = session.currentMinutes % 60;
                const timeStr = hours > 0 ? `${hours}h ${mins}m` : `${mins}m`;
                html += `
                    <div class="duty-officer-item">
                        <span class="officer-name">${session.name}</span>
                        <span class="status-online">On Duty</span>
                        <span class="duty-time">${timeStr}</span>
                    </div>
                `;
            });
        } else {
            html = '<div class="no-data">No officers currently on duty</div>';
        }
        activeSessionsList.innerHTML = html;
    }

    // Update weekly hours table if it exists
    const weeklyTable = document.getElementById('weeklyHoursTable');
    if (weeklyTable && serverData.weeklyData) {
        let tableHTML = '';
        serverData.weeklyData.forEach(officer => {
            const hours = officer.totalHours;
            const hoursFormatted = hours.toFixed(1);
            tableHTML += `
                <tr>
                    <td>${officer.name}</td>
                    <td>${hoursFormatted} hrs</td>
                    <td>${officer.shifts} shifts</td>
                    <td>
                        <button class="btn btn-sm" onclick="viewOfficerDutyHistory('${officer.citizenid}')">View</button>
                    </td>
                </tr>
            `;
        });

        if (tableHTML === '') {
            tableHTML = '<tr><td colspan="4" class="no-data">No duty data for this week</td></tr>';
        }

        weeklyTable.innerHTML = tableHTML;
    }

    // Update dashboard quick stats
    if (serverData.weeklyData) {
        const totalHoursThisWeek = serverData.weeklyData.reduce((sum, o) => sum + o.totalMinutes, 0) / 60;
        const avgWorkHoursEl = document.getElementById('avgWorkHours');
        if (avgWorkHoursEl) {
            avgWorkHoursEl.textContent = totalHoursThisWeek.toFixed(1) + ' hrs';
        }
    }

    console.log('[Analytics] Display updated - Active sessions:', activeSessionsCount, 'Weekly officers:', serverData.weeklyData?.length || 0);
}

// View officer duty history
function viewOfficerDutyHistory(citizenid) {
    console.log('Viewing duty history for:', citizenid);

    // Request history from server
    fetch('https://pd_boss_menu/getOfficerDutyHistory', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ citizenid: citizenid })
    }).catch(err => {
        console.error('Error requesting officer duty history:', err);
    });

    // Show the modal (will be populated when data arrives)
    const modal = document.getElementById('officerHoursModal');
    if (modal) {
        modal.classList.remove('hidden');
    }
}

// Update officer hours modal with server data
function updateOfficerHoursModalWithServerData(data) {
    const logsContainer = document.getElementById('officerDutyLogs');
    if (!logsContainer) return;

    let html = '';

    if (data.logs && data.logs.length > 0) {
        data.logs.forEach(log => {
            const startDate = new Date(log.duty_start);
            const duration = log.duration_minutes;
            const hoursWorked = (duration / 60).toFixed(1);

            html += `
                <div class="duty-log-entry">
                    <div class="duty-log-date">${startDate.toLocaleDateString()}</div>
                    <div class="duty-log-time">${startDate.toLocaleTimeString()} - ${new Date(log.duty_end).toLocaleTimeString()}</div>
                    <div class="duty-log-duration">${hoursWorked} hours</div>
                </div>
            `;
        });
    } else {
        html = '<div class="no-data">No duty logs found</div>';
    }

    logsContainer.innerHTML = html;

    // Update summary if available
    if (data.summary && data.summary.length > 0) {
        const summaryContainer = document.getElementById('officerDutySummary');
        if (summaryContainer) {
            const totalMinutes = data.summary.reduce((sum, s) => sum + s.total_minutes, 0);
            const totalShifts = data.summary.reduce((sum, s) => sum + s.shift_count, 0);
            summaryContainer.innerHTML = `
                <div class="summary-stat">Total Hours (30 days): ${(totalMinutes / 60).toFixed(1)}</div>
                <div class="summary-stat">Total Shifts: ${totalShifts}</div>
            `;
        }
    }
}

// Clear old daily data to prevent memory buildup
function clearOldDailyData() {
    const now = new Date();
    const sevenDaysAgo = new Date(now.getTime() - (7 * 24 * 60 * 60 * 1000));
    const cutoffDate = sevenDaysAgo.toISOString().split('T')[0];
    
    dutyTracking.dailyHours.forEach((dailyData, officerId) => {
        const cleanedData = {};


        Object.keys(dailyData).forEach(dateKey => {
            if (dateKey >= cutoffDate) {
                cleanedData[dateKey] = dailyData[dateKey];
            }
        });
        dutyTracking.dailyHours.set(officerId, cleanedData);
    });
    
    console.log(`🧹 Cleared daily data older than ${cutoffDate}`);
}

// Initialize the duty time chart with enhanced visuals
function initializeChart() {
    const ctx = document.getElementById('dutyTimeChart');
    if (!ctx) {
        console.warn('dutyTimeChart canvas not found');
        return;
    }
    
    // Clean up existing chart
    cleanupChart();
    
    // Clear the canvas
    ctx.getContext('2d').clearRect(0, 0, ctx.width, ctx.height);
    
    // Generate time labels for the last 24 hours
    const now = new Date();
    const labels = [];
    for (let i = 23; i >= 0; i--) {
        const time = new Date(now.getTime() - (i * 60 * 60 * 1000));
        const hour = time.getHours();
        const timeLabel = hour === 0 ? '12 AM' : 
                         hour < 12 ? hour + ' AM' : 
                         hour === 12 ? '12 PM' : 
                         (hour - 12) + ' PM';
        labels.push(timeLabel);
    }
    
    chartData.labels = labels;
    chartData.dutyHours = new Array(24).fill(0);
    chartData.onlineOfficers = new Array(24).fill(0);
    
    console.log('Creating enhanced chart...');
    try {
        dutyTimeChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Duty Hours',
                    data: chartData.dutyHours,
                    borderColor: '#6366F1',
                    backgroundColor: 'rgba(99, 102, 241, 0.2)',
                    borderWidth: 4,
                    fill: true,
                    tension: 0.4,
                    pointBackgroundColor: '#6366F1',
                    pointBorderColor: '#ffffff',
                    pointBorderWidth: 3,
                    pointRadius: 6,
                    pointHoverRadius: 8,
                    pointHoverBackgroundColor: '#4F46E5',
                    pointHoverBorderColor: '#ffffff',
                    pointHoverBorderWidth: 4,
                    yAxisID: 'y',
                    gradient: {
                        backgroundColor: {
                            type: 'linear',
                            x0: 0,
                            y0: 0,
                            x1: 0,
                            y1: 1,
                            colorStops: [
                                { offset: 0, color: 'rgba(99, 102, 241, 0.3)' },
                                { offset: 1, color: 'rgba(99, 102, 241, 0.05)' }
                            ]
                        }
                    }
                },
                {
                    label: 'Online Officers',
                    data: chartData.onlineOfficers,
                    borderColor: '#10B981',
                    backgroundColor: 'rgba(16, 185, 129, 0.2)',
                    borderWidth: 4,
                    fill: false,
                    tension: 0.4,
                    pointBackgroundColor: '#10B981',
                    pointBorderColor: '#ffffff',
                    pointBorderWidth: 3,
                    pointRadius: 6,
                    pointHoverRadius: 8,
                    pointHoverBackgroundColor: '#059669',
                    pointHoverBorderColor: '#ffffff',
                    pointHoverBorderWidth: 4,
                    yAxisID: 'y1'
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
                intersect: false,
                mode: 'index'
            },
            plugins: {
                tooltip: {
                    backgroundColor: 'rgba(15, 23, 42, 0.95)',
                    titleColor: '#ffffff',
                    bodyColor: '#ffffff',
                    borderColor: '#6366F1',
                    borderWidth: 2,
                    cornerRadius: 12,
                    displayColors: true,
                    padding: 15,
                    titleFont: {
                        size: 14,
                        weight: 'bold'
                    },
                    bodyFont: {
                        size: 13
                    },
                    callbacks: {
                        title: function(context) {
                            return '📊 ' + context[0].label;
                        },
                        label: function(context) {
                            if (context.datasetIndex === 0) {
                                const hours = context.parsed.y;
                                return '⏰ Duty Hours: ' + formatTime(hours);
                            } else {
                                return '👮 Online Officers: ' + Math.round(context.parsed.y);
                            }
                        },
                        afterBody: function(context) {
                            const totalDuty = context.reduce((sum, item) => {
                                return sum + (item.datasetIndex === 0 ? item.parsed.y : 0);
                            }, 0);
                            const totalOfficers = context.reduce((sum, item) => {
                                return sum + (item.datasetIndex === 1 ? item.parsed.y : 0);
                            }, 0);
                                return [
                                    '',
                                    `📈 Total Activity: ${formatTime(totalDuty)} duty, ${totalOfficers} officers`
                                ];
                        }
                    }
                },
                legend: {
                    display: true,
                    position: 'top',
                    align: 'start',
                    labels: {
                        color: '#ffffff',
                        usePointStyle: true,
                        padding: 25,
                        font: {
                            size: 14,
                            weight: 'bold',
                            family: 'Inter, sans-serif'
                        },
                        boxWidth: 12,
                        boxHeight: 12
                    }
                },
                title: {
                    display: true,
                    text: '📊 Real-Time Duty Analytics',
                    color: '#ffffff',
                    font: {
                        size: 18,
                        weight: 'bold',
                        family: 'Inter, sans-serif'
                    },
                    padding: {
                        top: 15,
                        bottom: 25
                    }
                }
            },
            scales: {
                x: {
                    grid: {
                        color: 'rgba(148, 163, 184, 0.1)',
                        drawBorder: false,
                        lineWidth: 1
                    },
                    ticks: {
                        color: '#94A3B8',
                        font: {
                            size: 12,
                            weight: '500',
                            family: 'Inter, sans-serif'
                        },
                        maxTicksLimit: 8,
                        padding: 8
                    },
                    title: {
                        display: true,
                        text: '🕐 Time (24 Hours)',
                        color: '#ffffff',
                        font: {
                            size: 16,
                            weight: 'bold',
                            family: 'Inter, sans-serif'
                        },
                        padding: 15
                    }
                },
                y: {
                    type: 'linear',
                    display: true,
                    position: 'left',
                    min: 0,
                    max: 12,
                    grid: {
                        color: 'rgba(99, 102, 241, 0.1)',
                        drawBorder: false,
                        lineWidth: 1
                    },
                    ticks: {
                        color: '#6366F1',
                        font: {
                            size: 12,
                            weight: '500',
                            family: 'Inter, sans-serif'
                        },
                        stepSize: 2,
                        padding: 8,
                        callback: function(value) {
                            return formatTime(value);
                        }
                    },
                    title: {
                        display: true,
                        text: '⏰ Duty Hours',
                        color: '#6366F1',
                        font: {
                            size: 16,
                            weight: 'bold',
                            family: 'Inter, sans-serif'
                        },
                        padding: 15
                    }
                },
                y1: {
                    type: 'linear',
                    display: true,
                    position: 'right',
                    min: 0,
                    max: 10,
                    grid: {
                        drawOnChartArea: false,
                        drawBorder: false
                    },
                    ticks: {
                        color: '#10B981',
                        font: {
                            size: 12,
                            weight: '500',
                            family: 'Inter, sans-serif'
                        },
                        stepSize: 2,
                        padding: 8,
                        callback: function(value) {
                            return Math.round(value);
                        }
                    },
                    title: {
                        display: true,
                        text: '👮 Officers',
                        color: '#10B981',
                        font: {
                            size: 16,
                            weight: 'bold',
                            family: 'Inter, sans-serif'
                        },
                        padding: 15
                    }
                }
            },
            animation: {
                duration: 2000,
                easing: 'easeInOutQuart',
                delay: (context) => {
                    return context.type === 'data' && context.mode === 'default' ? context.dataIndex * 100 : 0;
                }
            },
            elements: {
                point: {
                    hoverBackgroundColor: '#ffffff',
                    hoverBorderColor: '#6366F1',
                    hoverBorderWidth: 3
                }
            }
        }
    });
    
    console.log('Enhanced chart created successfully');
    } catch (error) {
        console.error('Error creating chart:', error);
        dutyTimeChart = null;
    }
}

// Start duty tracking for an officer
function startDutyTracking(officerId, officerName) {
    const now = new Date();
    dutyTracking.officers.set(officerId, {
        startTime: now,
        totalTime: 0,
        isOnDuty: true,
        name: officerName
    });
    console.log(`🕐 Started duty tracking for ${officerName} at ${now.toLocaleTimeString()}`);
}

// Stop duty tracking for an officer
function stopDutyTracking(officerId) {
    const officer = dutyTracking.officers.get(officerId);
    if (officer && officer.isOnDuty) {
        const now = new Date();
        const sessionTime = (now - officer.startTime) / (1000 * 60 * 60); // hours
        officer.totalTime += sessionTime;
        officer.isOnDuty = false;
        
        // Update weekly hours
        const weeklyHours = dutyTracking.weeklyHours.get(officerId) || 0;
        dutyTracking.weeklyHours.set(officerId, weeklyHours + sessionTime);
        
        // Update daily hours
        const today = new Date().toISOString().split('T')[0];
        const dailyData = dutyTracking.dailyHours.get(officerId) || {};


        dailyData[today] = (dailyData[today] || 0) + sessionTime;
        dutyTracking.dailyHours.set(officerId, dailyData);
        
        console.log(`🕐 Stopped duty tracking for ${officer.name} - Session: ${formatTime(sessionTime)}, Total Weekly: ${formatTime(weeklyHours + sessionTime)}, Today: ${formatTime(dailyData[today])}`);
    }
}

// Get current week identifier
function getCurrentWeek() {
    const now = new Date();
    const startOfWeek = new Date(now);
    startOfWeek.setDate(now.getDate() - now.getDay());
    return startOfWeek.toISOString().split('T')[0];
}

// Calculate duty time for an officer
function calculateDutyTime(officerId) {
    const officer = dutyTracking.officers.get(officerId);
    if (!officer) return 0;
    
    let totalTime = officer.totalTime;
    if (officer.isOnDuty && officer.startTime) {
        const now = new Date();
        const currentSession = (now - officer.startTime) / (1000 * 60 * 60); // hours
        totalTime += currentSession;
    }
    
    return Math.max(0, totalTime); // Ensure non-negative time
}

// Format time in hours and minutes
function formatTime(hours) {
    const h = Math.floor(hours);
    const m = Math.floor((hours - h) * 60);
    return `${h}h ${m}m`;
}

// Update analytics with duty tracking data
function updateAnalytics() {
    console.log('=== UPDATE ANALYTICS CALLED ===');

    // Check if required elements exist before proceeding
    const officersOnDutyEl = document.getElementById('officersOnDuty');
    if (!officersOnDutyEl) {
        console.warn('Analytics elements not ready, skipping update');
        return;
    }

    // Use emp.online (boolean) - the authoritative field from server
    const onlineOfficers = currentData.employees.filter(emp => emp.online === true);

    // Check for duty status changes and update tracking
    currentData.employees.forEach(emp => {
        // Use emp.online (boolean) instead of emp.status (string)
        const isCurrentlyOnline = emp.online === true;
        const empKey = emp.citizenid || emp.id; // Use citizenid as primary key
        const wasOnDuty = dutyTracking.officers.has(empKey) && dutyTracking.officers.get(empKey).isOnDuty;

        if (isCurrentlyOnline && !wasOnDuty) {
            // Officer just clocked in
            console.log('Officer clocked in:', emp.name);
            startDutyTracking(empKey, emp.name);
        } else if (!isCurrentlyOnline && wasOnDuty) {
            // Officer just clocked out
            console.log('Officer clocked out:', emp.name);
            stopDutyTracking(empKey);
        } else if (isCurrentlyOnline && wasOnDuty) {
            // Officer is still on duty, ensure tracking is accurate
            const officer = dutyTracking.officers.get(empKey);
            if (officer && officer.startTime) {
                // Update total time with current session
                const now = new Date();
                const currentSession = (now - officer.startTime) / (1000 * 60 * 60); // hours
                officer.totalTime = Math.max(0, currentSession);
            }
        }
    });

    // Update officers on duty count
    const officersOnDutyElement = document.getElementById('officersOnDuty');
    if (officersOnDutyElement) {
        officersOnDutyElement.textContent = onlineOfficers.length;
    } else {
        console.warn('officersOnDuty element not found');
    }

    // Calculate total duty hours today
    let totalDutyHours = 0;
    let longestShift = 0;
    let shortestShift = Infinity;
    let totalShifts = 0;

    onlineOfficers.forEach(emp => {
        const empKey = emp.citizenid || emp.id;
        const dutyTime = calculateDutyTime(empKey);
        totalDutyHours += dutyTime;

        if (dutyTime > longestShift) longestShift = dutyTime;
        if (dutyTime < shortestShift) shortestShift = dutyTime;
        if (dutyTime > 0) totalShifts++;
    });
    
    // Update analytics cards
    const totalDutyHoursEl = document.getElementById('totalDutyHours');
    const avgDutyTimeEl = document.getElementById('avgDutyTime');
    const weeklyHoursEl = document.getElementById('weeklyHours');
    
    if (totalDutyHoursEl) {
        totalDutyHoursEl.textContent = formatTime(totalDutyHours);
    } else {
        console.warn('totalDutyHours element not found');
    }
    
    if (avgDutyTimeEl) {
        avgDutyTimeEl.textContent = onlineOfficers.length > 0 ? 
            formatTime(totalDutyHours / onlineOfficers.length) : '0h 0m';
    } else {
        console.warn('avgDutyTime element not found');
    }
    
    // Calculate weekly hours
    let weeklyTotal = 0;
    dutyTracking.weeklyHours.forEach(hours => weeklyTotal += hours);
    if (weeklyHoursEl) {
        weeklyHoursEl.textContent = formatTime(weeklyTotal);
    } else {
        console.warn('weeklyHours element not found');
    }
    
    // Update duty tracking stats
    const longestShiftEl = document.getElementById('longestShift');
    const shortestShiftEl = document.getElementById('shortestShift');
    const totalShiftsEl = document.getElementById('totalShifts');
    
    if (longestShiftEl) {
        longestShiftEl.textContent = longestShift > 0 ? formatTime(longestShift) : '0h 0m';
    } else {
        console.warn('longestShift element not found');
    }
    
    if (shortestShiftEl) {
        shortestShiftEl.textContent = shortestShift < Infinity ? formatTime(shortestShift) : '0h 0m';
    } else {
        console.warn('shortestShift element not found');
    }
    
    if (totalShiftsEl) {
        totalShiftsEl.textContent = totalShifts;
    } else {
        console.warn('totalShifts element not found');
    }
    
    // Update duty officers list
    updateDutyOfficersList(onlineOfficers);
    
    // Chart update removed - only showing officers on duty now
    
    // Force refresh duty tracking for any missed officers
    refreshDutyTracking();
    
    // Update dashboard average work hours
    updateSidebarStats();
}

// Force refresh duty tracking for existing online officers
function refreshDutyTracking() {
    if (currentData.employees) {
        currentData.employees.forEach(emp => {
            const isCurrentlyOnline = emp.status && emp.status.toLowerCase() === 'online';
            const isTracked = dutyTracking.officers.has(emp.id);
            
            if (isCurrentlyOnline && !isTracked) {
                console.log('Force starting duty tracking for:', emp.name);
                startDutyTracking(emp.id, emp.name);
            }
        });
    }
}

// Update the chart with enhanced real-time data
function updateChart() {
    if (!dutyTimeChart) return;
    
    const now = new Date();
    const currentHour = now.getHours();
    
    // Calculate enhanced statistics
    let totalDutyHours = 0;
    let onlineOfficers = 0;
    let totalWeeklyHours = 0;
    let averageDutyTime = 0;
    
    dutyTracking.officers.forEach((officer, id) => {
        if (officer.isOnDuty) {
            onlineOfficers++;
            if (officer.startTime) {
                const dutyTime = (now - officer.startTime) / (1000 * 60 * 60); // hours
                totalDutyHours += dutyTime;
            }
        }
        
        // Calculate weekly hours
        const weeklyHours = dutyTracking.weeklyHours.get(id) || 0;
        totalWeeklyHours += weeklyHours;
    });
    
    // Calculate average duty time
    if (onlineOfficers > 0) {
        averageDutyTime = totalDutyHours / onlineOfficers;
    }
    
    // Update chart data with enhanced scaling
    chartData.dutyHours[currentHour] = Math.min(totalDutyHours, 12); // Increased cap for better visibility
    chartData.onlineOfficers[currentHour] = onlineOfficers;
    
    // Update the chart with smooth animation
    dutyTimeChart.data.datasets[0].data = [...chartData.dutyHours];
    dutyTimeChart.data.datasets[1].data = [...chartData.onlineOfficers];
    dutyTimeChart.update('active'); // Smooth update with animation
    
    // Update real-time statistics display
    updateRealTimeStats(totalDutyHours, onlineOfficers, averageDutyTime, totalWeeklyHours);
    
    console.log(`📊 Enhanced Chart Updated - Hour ${currentHour}: ${formatTime(totalDutyHours)} duty, ${onlineOfficers} officers online, Avg: ${formatTime(averageDutyTime)}`);
}

// Update real-time statistics display
function updateRealTimeStats(totalDutyHours, onlineOfficers, averageDutyTime, totalWeeklyHours) {
    // Update analytics cards with real-time data
    const avgDutyTimeElement = document.getElementById('avgDutyTime');
    if (avgDutyTimeElement) {
        avgDutyTimeElement.textContent = averageDutyTime > 0 ? formatTime(averageDutyTime) : '0h 0m';
    }
    
    // Update online officers count
    const onlineOfficersElement = document.getElementById('onlineOfficers');
    if (onlineOfficersElement) {
        onlineOfficersElement.textContent = onlineOfficers.toString();
    }
    
    // Update total duty hours
    const totalDutyElement = document.getElementById('totalDutyHours');
    if (totalDutyElement) {
        totalDutyElement.textContent = formatTime(totalDutyHours);
    }
    
    // Update weekly hours if element exists
    const weeklyHoursElement = document.getElementById('weeklyHours');
    if (weeklyHoursElement) {
        weeklyHoursElement.textContent = formatTime(totalWeeklyHours);
    }
    
    // Add live indicator
    const liveIndicator = document.querySelector('.live-indicator');
    if (liveIndicator) {
        liveIndicator.style.animation = 'pulse 2s infinite';
    }
    
    // Update current activity
    const currentActivityElement = document.getElementById('currentActivity');
    if (currentActivityElement) {
        currentActivityElement.textContent = `${formatTime(totalDutyHours)} duty, ${onlineOfficers} officers`;
    }
    
    // Calculate and update peak hours
    updatePeakHours();
}

// Calculate peak hours from chart data
function updatePeakHours() {
    const peakHoursElement = document.getElementById('peakHours');
    if (!peakHoursElement) return;
    
    // Find the hour with maximum activity
    let maxActivity = 0;
    let peakHour = 0;
    
    for (let i = 0; i < chartData.dutyHours.length; i++) {
        const activity = chartData.dutyHours[i] + chartData.onlineOfficers[i];
        if (activity > maxActivity) {
            maxActivity = activity;
            peakHour = i;
        }
    }
    
    if (maxActivity > 0) {
        const hour = peakHour;
        const timeLabel = hour === 0 ? '12 AM' : 
                         hour < 12 ? hour + ' AM' : 
                         hour === 12 ? '12 PM' : 
                         (hour - 12) + ' PM';
        peakHoursElement.textContent = `${timeLabel} (${formatTime(maxActivity)} activity)`;
    } else {
        peakHoursElement.textContent = 'No data yet';
    }
}

// Update the duty officers list
function updateDutyOfficersList(officers) {
    const dutyOfficersList = document.getElementById('dutyOfficersList');
    const officerCount = document.getElementById('officerCount');
    
    if (!dutyOfficersList) {
        console.warn('dutyOfficersList element not found');
        return;
    }
    
    dutyOfficersList.innerHTML = '';
    
    if (officers.length === 0) {
        dutyOfficersList.innerHTML = '<div class="no-data">No officers currently on duty</div>';
        if (officerCount) officerCount.textContent = '0 officers';
        return;
    }
    
    // Update officer count
    if (officerCount) {
        officerCount.textContent = `${officers.length} officer${officers.length !== 1 ? 's' : ''}`;
    }
    
    officers.forEach(officer => {
        const dutyTime = calculateDutyTime(officer.id);
        const firstLetter = officer.name.charAt(0).toUpperCase();
        const rankLabel = getRankLabel(officer.grade);
        
        const officerElement = document.createElement('div');
        officerElement.className = 'officer-card';
        officerElement.innerHTML = `
            <div class="officer-card-content">
                <div class="officer-info">
                    <div class="officer-avatar">${firstLetter}</div>
                    <div class="officer-details">
                        <div class="officer-name">${officer.name}</div>
                        <div class="officer-rank">${rankLabel}</div>
                    </div>
                </div>
                <div class="officer-time">${formatTime(dutyTime)}</div>
            </div>
        `;
        
        // Add click handler to open officer hours modal
        officerElement.addEventListener('click', () => {
            openOfficerHoursModal(officer);
        });
        
        dutyOfficersList.appendChild(officerElement);
    });
}

// Simple function to add a test transaction directly
window.addTestTransactionDirect = function() {
    console.log('=== ADDING TEST TRANSACTION DIRECTLY ===');
    
    const historyContainer = document.getElementById('transactionHistory');
    if (!historyContainer) {
        console.error('History container not found!');
        return;
    }
    
    // Create test transaction
    const transactionEntry = document.createElement('div');
    transactionEntry.className = 'transaction-item';
    transactionEntry.innerHTML = `
        <div class="transaction-info">
            <span class="transaction-type-badge deposit">Deposit</span>
            <div class="transaction-details">
                <div class="transaction-reason">Budget Allocation</div>
                <div class="transaction-officer">Officer: Test Officer</div>
                <div class="transaction-date">${new Date().toLocaleDateString()}</div>
            </div>
        </div>
        <div class="transaction-amount positive">+$1,000.00</div>
    `;
    
    // Add to top of list
    historyContainer.insertBefore(transactionEntry, historyContainer.firstChild);
    console.log('Test transaction added successfully!');
};


// Open officer hours modal
function openOfficerHoursModal(officer) {
    console.log('Opening officer hours modal for:', officer.name);
    
    // Update modal header
    document.getElementById('officerHoursName').textContent = `${officer.name} - Hours`;
    document.getElementById('officerHoursNameFull').textContent = officer.name;
    document.getElementById('officerHoursRank').textContent = getRankLabel(officer.grade);
    document.getElementById('officerHoursAvatar').textContent = officer.name.charAt(0).toUpperCase();
    
    // Calculate and display officer statistics
    updateOfficerHoursStats(officer);
    
    // Load officer's weekly chart
    loadOfficerWeeklyChart(officer);
    
    // Load daily breakdown
    loadOfficerDailyBreakdown(officer);
    
    // Load shift history
    loadOfficerShiftHistory(officer);
    
    // Start real-time updates for this officer
    startOfficerHoursRealTimeUpdate(officer);
    
    // Initialize calendar navigation
    initializeCalendarNavigation();
    
    // Show modal
    document.getElementById('officerHoursModal').classList.remove('hidden');
}

// Close officer hours modal
function closeOfficerHoursModal() {
    // Clean up the officer activity chart
    if (officerActivityChart) {
        officerActivityChart.destroy();
        officerActivityChart = null;
    }
    
    // Stop real-time updates
    stopOfficerHoursRealTimeUpdate();
    
    document.getElementById('officerHoursModal').classList.add('hidden');
}

// Update officer hours statistics
function updateOfficerHoursStats(officer) {
    const dutyTime = calculateDutyTime(officer.id);
    const weeklyHours = calculateWeeklyHours(officer.id);
    const dailyHours = calculateDailyHours(officer.id);
    
    // Update with enhanced visibility
    const weeklyEl = document.getElementById('weeklyHours');
    const dailyEl = document.getElementById('dailyHours');
    const currentEl = document.getElementById('currentShift');
    
    if (weeklyEl) {
        weeklyEl.textContent = formatTime(weeklyHours);
        weeklyEl.style.color = '#6366F1';
        weeklyEl.style.fontWeight = '700';
    }
    
    if (dailyEl) {
        dailyEl.textContent = formatTime(dailyHours);
        dailyEl.style.color = '#6366F1';
        dailyEl.style.fontWeight = '700';
    }
    
    if (currentEl) {
        currentEl.textContent = formatTime(dutyTime);
        currentEl.style.color = dutyTime > 0 ? '#10B981' : '#6366F1';
        currentEl.style.fontWeight = '700';
    }
    
    console.log(`📊 Officer ${officer.name} - Weekly: ${formatTime(weeklyHours)}, Daily: ${formatTime(dailyHours)}, Current: ${formatTime(dutyTime)}`);
}

// Calculate weekly hours for an officer
function calculateWeeklyHours(officerId) {
    const weeklyHours = dutyTracking.weeklyHours.get(officerId) || 0;
    const officer = dutyTracking.officers.get(officerId);
    
    // Add current session if officer is on duty
    if (officer && officer.isOnDuty && officer.startTime) {
        const now = new Date();
        const currentSession = (now - officer.startTime) / (1000 * 60 * 60); // hours
        return weeklyHours + currentSession;
    }
    
    return weeklyHours;
}

// Calculate daily hours for an officer
function calculateDailyHours(officerId) {
    const officer = dutyTracking.officers.get(officerId);
    if (!officer) return 0;
    
    // Get today's date for daily calculation
    const today = new Date();
    const todayKey = today.toISOString().split('T')[0];
    
    // Get existing daily hours for today
    const dailyData = dutyTracking.dailyHours.get(officerId) || {};


    const todayHours = dailyData[todayKey] || 0;
    
    // Add current session if officer is on duty
    if (officer.isOnDuty && officer.startTime) {
        const now = new Date();
        const currentSession = (now - officer.startTime) / (1000 * 60 * 60); // hours
        return todayHours + currentSession;
    }
    
    return Math.max(0, todayHours); // Ensure non-negative time
}

// Real-time update variables for officer hours
let officerHoursUpdateInterval = null;
let currentOfficerForHours = null;
let currentViewDate = new Date(); // Track the currently viewed date

// Start real-time updates for officer hours
function startOfficerHoursRealTimeUpdate(officer) {
    currentOfficerForHours = officer;
    
    // Clear any existing interval
    if (officerHoursUpdateInterval) {
        clearInterval(officerHoursUpdateInterval);
    }
    
    // Update every 5 seconds for real-time accuracy
    officerHoursUpdateInterval = setInterval(() => {
        if (currentOfficerForHours) {
            updateOfficerHoursStats(currentOfficerForHours);
        }
    }, 5000);
    
    console.log(`🔄 Started real-time updates for officer: ${officer.name}`);
}

// Stop real-time updates for officer hours
function stopOfficerHoursRealTimeUpdate() {
    if (officerHoursUpdateInterval) {
        clearInterval(officerHoursUpdateInterval);
        officerHoursUpdateInterval = null;
    }
    currentOfficerForHours = null;
    console.log('⏹️ Stopped officer hours real-time updates');
}

// Individual officer activity chart
let officerActivityChart = null;

// Load officer activity chart
function loadOfficerWeeklyChart(officer) {
    console.log('Loading individual activity chart for:', officer.name);
    
    const ctx = document.getElementById('officerActivityChart');
    if (!ctx) {
        console.warn('officerActivityChart canvas not found');
        return;
    }
    
    // Clean up existing chart
    if (officerActivityChart) {
        officerActivityChart.destroy();
        officerActivityChart = null;
    }
    
    // Generate time labels for the last 24 hours
    const now = new Date();
    const labels = [];
    for (let i = 23; i >= 0; i--) {
        const time = new Date(now.getTime() - (i * 60 * 60 * 1000));
        const hour = time.getHours();
        const timeLabel = hour === 0 ? '12 AM' : 
                         hour < 12 ? hour + ' AM' : 
                         hour === 12 ? '12 PM' : 
                         (hour - 12) + ' PM';
        labels.push(timeLabel);
    }
    
    // Get real data for this officer (no test data)
    const dutyHours = getRealOfficerDutyData(officer);
    const clockEvents = getRealOfficerClockEvents(officer);
    const activityLevel = getRealOfficerActivityLevel(officer);
    
    try {
        officerActivityChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: '⏰ Duty Hours',
                        data: dutyHours,
                        borderColor: '#6366F1',
                        backgroundColor: 'rgba(99, 102, 241, 0.2)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4,
                        pointBackgroundColor: '#6366F1',
                        pointBorderColor: '#ffffff',
                        pointBorderWidth: 2,
                        pointRadius: 5,
                        pointHoverRadius: 7,
                        yAxisID: 'y'
                    },
                    {
                        label: '🕐 Clock In/Out',
                        data: clockEvents,
                        borderColor: '#10B981',
                        backgroundColor: 'rgba(16, 185, 129, 0.2)',
                        borderWidth: 3,
                        fill: false,
                        tension: 0.4,
                        pointBackgroundColor: '#10B981',
                        pointBorderColor: '#ffffff',
                        pointBorderWidth: 2,
                        pointRadius: 5,
                        pointHoverRadius: 7,
                        yAxisID: 'y1'
                    },
                    {
                        label: '📈 Activity Level',
                        data: activityLevel,
                        borderColor: '#F59E0B',
                        backgroundColor: 'rgba(245, 158, 11, 0.2)',
                        borderWidth: 3,
                        fill: false,
                        tension: 0.4,
                        pointBackgroundColor: '#F59E0B',
                        pointBorderColor: '#ffffff',
                        pointBorderWidth: 2,
                        pointRadius: 5,
                        pointHoverRadius: 7,
                        yAxisID: 'y2'
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: {
                    intersect: false,
                    mode: 'index'
                },
                plugins: {
                    legend: {
                        display: false // We have custom legend in HTML
                    },
                    tooltip: {
                        backgroundColor: 'rgba(15, 23, 42, 0.95)',
                        titleColor: '#ffffff',
                        bodyColor: '#ffffff',
                        borderColor: '#6366F1',
                        borderWidth: 2,
                        cornerRadius: 12,
                        displayColors: true,
                        padding: 12,
                        callbacks: {
                            title: function(context) {
                                return '🕐 ' + context[0].label;
                            },
                            label: function(context) {
                                if (context.datasetIndex === 0) {
                                    return '⏰ Duty Hours: ' + formatTime(context.parsed.y);
                                } else if (context.datasetIndex === 1) {
                                    return '🕐 Clock Events: ' + context.parsed.y;
                                } else {
                                    return '📈 Activity: ' + Math.round(context.parsed.y) + '%';
                                }
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        grid: {
                            color: 'rgba(148, 163, 184, 0.1)',
                            drawBorder: false
                        },
                        ticks: {
                            color: '#94A3B8',
                            font: {
                                size: 11,
                                family: 'Inter, sans-serif'
                            },
                            maxTicksLimit: 8
                        },
                        title: {
                            display: true,
                            text: '🕐 Time (24 Hours)',
                            color: '#ffffff',
                            font: {
                                size: 14,
                                weight: 'bold'
                            }
                        }
                    },
                    y: {
                        type: 'linear',
                        display: true,
                        position: 'left',
                        min: 0,
                        max: 12,
                        grid: {
                            color: 'rgba(99, 102, 241, 0.1)',
                            drawBorder: false
                        },
                        ticks: {
                            color: '#6366F1',
                            font: {
                                size: 11,
                                family: 'Inter, sans-serif'
                            },
                            callback: function(value) {
                                return value + 'h';
                            }
                        },
                        title: {
                            display: true,
                            text: '⏰ Hours',
                            color: '#6366F1',
                            font: {
                                size: 12,
                                weight: 'bold'
                            }
                        }
                    },
                    y1: {
                        type: 'linear',
                        display: true,
                        position: 'right',
                        min: 0,
                        max: 5,
                        grid: {
                            drawOnChartArea: false,
                            drawBorder: false
                        },
                        ticks: {
                            color: '#10B981',
                            font: {
                                size: 11,
                                family: 'Inter, sans-serif'
                            }
                        },
                        title: {
                            display: true,
                            text: '🕐 Events',
                            color: '#10B981',
                            font: {
                                size: 12,
                                weight: 'bold'
                            }
                        }
                    },
                    y2: {
                        type: 'linear',
                        display: false
                    }
                },
                animation: {
                    duration: 2000,
                    easing: 'easeInOutQuart'
                }
            }
        });
        
        // Update officer activity statistics
        updateOfficerActivityStats(dutyHours, clockEvents, activityLevel);
        
        console.log('Individual officer activity chart created successfully');
    } catch (error) {
        console.error('Error creating officer activity chart:', error);
        officerActivityChart = null;
    }
}

// Get real duty data for officer (no test data)
function getRealOfficerDutyData(officer) {
    const data = new Array(24).fill(0);
    
    // Only show data if officer is actually on duty
    const officerData = dutyTracking.officers.get(officer.id);
    if (officerData && officerData.isOnDuty) {
        const now = new Date();
        const currentHour = now.getHours();
        const dutyTime = calculateDutyTime(officer.id);
        
        // Show current duty time in current hour
        if (currentHour >= 0 && currentHour < 24) {
            data[currentHour] = dutyTime;
        }
    }
    
    return data;
}

// Get real clock events for officer (no test data)
function getRealOfficerClockEvents(officer) {
    const data = new Array(24).fill(0);
    
    // Only show actual clock events if officer is on duty
    const officerData = dutyTracking.officers.get(officer.id);
    if (officerData && officerData.isOnDuty) {
        const now = new Date();
        const currentHour = now.getHours();
        
        // Show clock in event at current hour
        if (currentHour >= 0 && currentHour < 24) {
            data[currentHour] = 1;
        }
    }
    
    return data;
}

// Get real activity level for officer (no test data)
function getRealOfficerActivityLevel(officer) {
    const data = new Array(24).fill(0);
    
    // Only show activity if officer is actually on duty
    const officerData = dutyTracking.officers.get(officer.id);
    if (officerData && officerData.isOnDuty) {
        const now = new Date();
        const currentHour = now.getHours();
        const dutyTime = calculateDutyTime(officer.id);
        
        // Show activity level based on current duty time
        if (currentHour >= 0 && currentHour < 24 && dutyTime > 0) {
            // Activity level based on duty time (0-100%)
            data[currentHour] = Math.min(dutyTime * 20, 100); // Scale duty time to activity %
        }
    }
    
    return data;
}

// Update officer activity statistics
function updateOfficerActivityStats(dutyHours, clockEvents, activityLevel) {
    // Calculate today's total activity (real data only)
    const todayActivity = dutyHours.reduce((sum, hours) => sum + hours, 0);
    const todayActivityEl = document.getElementById('todayActivity');
    if (todayActivityEl) {
        todayActivityEl.textContent = formatTime(todayActivity);
    }
    
    // Find peak hour (only if there's actual activity)
    let maxActivity = 0;
    let peakHour = 0;
    for (let i = 0; i < dutyHours.length; i++) {
        if (dutyHours[i] > maxActivity) {
            maxActivity = dutyHours[i];
            peakHour = i;
        }
    }
    
    const peakHourEl = document.getElementById('peakHour');
    if (peakHourEl) {
        if (maxActivity > 0) {
            const peakHourLabel = peakHour === 0 ? '12 AM' : 
                                 peakHour < 12 ? peakHour + ' AM' : 
                                 peakHour === 12 ? '12 PM' : 
                                 (peakHour - 12) + ' PM';
            peakHourEl.textContent = peakHourLabel;
        } else {
            peakHourEl.textContent = 'No activity';
        }
    }
    
    // Calculate total shifts (real clock events only)
    const totalShifts = clockEvents.reduce((sum, events) => sum + events, 0);
    const totalShiftsEl = document.getElementById('totalShifts');
    if (totalShiftsEl) {
        totalShiftsEl.textContent = totalShifts.toString();
    }
    
    console.log(`📊 Real Activity Stats - Today: ${formatTime(todayActivity)}, Peak: ${maxActivity > 0 ? peakHour + ':00' : 'None'}, Shifts: ${totalShifts}`);
}

// Load officer daily breakdown
function loadOfficerDailyBreakdown(officer, viewDate = null) {
    const dailyBreakdownList = document.getElementById('dailyBreakdownList');
    if (!dailyBreakdownList) return;
    
    // Use provided date or current view date
    const baseDate = viewDate || currentViewDate;
    
    // Show clean data - only real duty information
    const days = [];
    for (let i = 6; i >= 0; i--) {
        const date = new Date(baseDate);
        date.setDate(date.getDate() - i);
        const dateKey = date.toISOString().split('T')[0];
        
        // Get real data for this specific day
        const dailyData = dutyTracking.dailyHours.get(officer.id) || {};


        const dayHours = dailyData[dateKey] || 0;
        const isToday = i === 0 && isSameDay(date, new Date());
        
        // Add current session if it's today and officer is on duty
        let totalHours = dayHours;
        if (isToday) {
            const officerData = dutyTracking.officers.get(officer.id);
            if (officerData && officerData.isOnDuty && officerData.startTime) {
                const now = new Date();
                const currentSession = (now - officerData.startTime) / (1000 * 60 * 60);
                totalHours += currentSession;
            }
        }
        
        days.push({
            date: date.toLocaleDateString(),
            hours: totalHours,
            shifts: totalHours > 0 ? 1 : 0
        });
    }
    
    dailyBreakdownList.innerHTML = '';
    days.forEach(day => {
        const dayElement = document.createElement('div');
        dayElement.className = 'day-entry';
        dayElement.innerHTML = `
            <div class="day-info">
                <div class="day-date">${day.date}</div>
                <div class="day-shifts">${day.shifts} shift${day.shifts !== 1 ? 's' : ''}</div>
            </div>
            <div class="day-hours">${formatTime(day.hours)}</div>
        `;
        dailyBreakdownList.appendChild(dayElement);
    });
}

// Simple function to add a test transaction directly
window.addTestTransactionDirect = function() {
    console.log('=== ADDING TEST TRANSACTION DIRECTLY ===');
    
    const historyContainer = document.getElementById('transactionHistory');
    if (!historyContainer) {
        console.error('History container not found!');
        return;
    }
    
    // Create test transaction
    const transactionEntry = document.createElement('div');
    transactionEntry.className = 'transaction-item';
    transactionEntry.innerHTML = `
        <div class="transaction-info">
            <span class="transaction-type-badge deposit">Deposit</span>
            <div class="transaction-details">
                <div class="transaction-reason">Budget Allocation</div>
                <div class="transaction-officer">Officer: Test Officer</div>
                <div class="transaction-date">${new Date().toLocaleDateString()}</div>
            </div>
        </div>
        <div class="transaction-amount positive">+$1,000.00</div>
    `;
    
    // Add to top of list
    historyContainer.insertBefore(transactionEntry, historyContainer.firstChild);
    console.log('Test transaction added successfully!');
};


// Load officer shift history
function loadOfficerShiftHistory(officer) {
    const shiftsList = document.getElementById('shiftsList');
    if (!shiftsList) return;
    
    // Show clean data - only real shift information
    const shifts = [];
    
    // Only show current shift if officer is on duty
    const officerData = dutyTracking.officers.get(officer.id);
    if (officerData && officerData.isOnDuty && officerData.startTime) {
        const startTime = officerData.startTime;
        const now = new Date();
        const duration = calculateDutyTime(officer.id);
        
        // Get user's local timezone abbreviation
        const tzAbbr = new Date().toLocaleTimeString('en-US', {timeZoneName: 'short'}).split(' ').pop();
        
        shifts.push({
            date: startTime.toLocaleDateString(),
            startTime: startTime.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit', hour12: true}).toUpperCase() + ' ' + tzAbbr,
            endTime: 'In Progress',
            duration: duration
        });
    }
    
    console.log(`📋 Shift history loaded for ${officer.name} - showing real data only`);
    
    shiftsList.innerHTML = '';
    shifts.forEach(shift => {
        const shiftElement = document.createElement('div');
        shiftElement.className = 'shift-entry';
        shiftElement.innerHTML = `
            <div class="shift-info">
                <div class="shift-date">${shift.date}</div>
                <div class="shift-times">${shift.startTime} - ${shift.endTime}</div>
            </div>
            <div class="shift-duration">${formatTime(shift.duration)}</div>
        `;
        shiftsList.appendChild(shiftElement);
    });
}

// Simple function to add a test transaction directly
window.addTestTransactionDirect = function() {
    console.log('=== ADDING TEST TRANSACTION DIRECTLY ===');
    
    const historyContainer = document.getElementById('transactionHistory');
    if (!historyContainer) {
        console.error('History container not found!');
        return;
    }
    
    // Create test transaction
    const transactionEntry = document.createElement('div');
    transactionEntry.className = 'transaction-item';
    transactionEntry.innerHTML = `
        <div class="transaction-info">
            <span class="transaction-type-badge deposit">Deposit</span>
            <div class="transaction-details">
                <div class="transaction-reason">Budget Allocation</div>
                <div class="transaction-officer">Officer: Test Officer</div>
                <div class="transaction-date">${new Date().toLocaleDateString()}</div>
            </div>
        </div>
        <div class="transaction-amount positive">+$1,000.00</div>
    `;
    
    // Add to top of list
    historyContainer.insertBefore(transactionEntry, historyContainer.firstChild);
    console.log('Test transaction added successfully!');
};


// Helper function to check if two dates are the same day
function isSameDay(date1, date2) {
    return date1.getDate() === date2.getDate() &&
           date1.getMonth() === date2.getMonth() &&
           date1.getFullYear() === date2.getFullYear();
}

// Initialize calendar navigation
function initializeCalendarNavigation() {
    const prevWeekBtn = document.getElementById('prevWeekBtn');
    const nextWeekBtn = document.getElementById('nextWeekBtn');
    const todayBtn = document.getElementById('todayBtn');
    const datePicker = document.getElementById('datePicker');
    
    if (!prevWeekBtn || !nextWeekBtn || !todayBtn || !datePicker) return;
    
    // Set initial date picker value
    datePicker.value = currentViewDate.toISOString().split('T')[0];
    
    // Previous week button
    prevWeekBtn.addEventListener('click', () => {
        currentViewDate.setDate(currentViewDate.getDate() - 7);
        datePicker.value = currentViewDate.toISOString().split('T')[0];
        if (currentOfficerForHours) {
            loadOfficerDailyBreakdown(currentOfficerForHours, new Date(currentViewDate));
        }
    });
    
    // Next week button
    nextWeekBtn.addEventListener('click', () => {
        currentViewDate.setDate(currentViewDate.getDate() + 7);
        datePicker.value = currentViewDate.toISOString().split('T')[0];
        if (currentOfficerForHours) {
            loadOfficerDailyBreakdown(currentOfficerForHours, new Date(currentViewDate));
        }
    });
    
    // Today button
    todayBtn.addEventListener('click', () => {
        currentViewDate = new Date();
        datePicker.value = currentViewDate.toISOString().split('T')[0];
        if (currentOfficerForHours) {
            loadOfficerDailyBreakdown(currentOfficerForHours, new Date(currentViewDate));
        }
    });
    
    // Date picker change
    datePicker.addEventListener('change', (e) => {
        currentViewDate = new Date(e.target.value);
        if (currentOfficerForHours) {
            loadOfficerDailyBreakdown(currentOfficerForHours, new Date(currentViewDate));
        }
    });
    
    console.log('📅 Calendar navigation initialized');
}

function updateOnlineEmployeesList() {
    if (!onlineEmployeesList) {
        console.warn('onlineEmployeesList element not found');
        return;
    }

    onlineEmployeesList.innerHTML = '';

    // Filter for online employees - use the boolean online field from server
    const onlineEmployees = currentData.employees.filter(emp => emp.online === true);

    console.log('Online employees list - found', onlineEmployees.length, 'online out of', currentData.employees.length);

    if (onlineEmployees.length === 0) {
        onlineEmployeesList.innerHTML = '<div class="no-data">No employees online</div>';
        return;
    }

    onlineEmployees.forEach(employee => {
        const employeeItem = document.createElement('div');
        employeeItem.className = 'online-employee';

        const rankLabel = getRankLabel(employee.grade);
        const firstLetter = employee.name.charAt(0).toUpperCase();

        employeeItem.innerHTML = `
            <div class="employee-avatar">${firstLetter}</div>
            <div class="employee-info">
                <div class="employee-name">${employee.name} (${rankLabel})</div>
            </div>
            <div class="status-badge status-online">Online</div>
        `;

        onlineEmployeesList.appendChild(employeeItem);
    });
}

// Simple function to add a test transaction directly
window.addTestTransactionDirect = function() {
    console.log('=== ADDING TEST TRANSACTION DIRECTLY ===');
    
    const historyContainer = document.getElementById('transactionHistory');
    if (!historyContainer) {
        console.error('History container not found!');
        return;
    }
    
    // Create test transaction
    const transactionEntry = document.createElement('div');
    transactionEntry.className = 'transaction-item';
    transactionEntry.innerHTML = `
        <div class="transaction-info">
            <span class="transaction-type-badge deposit">Deposit</span>
            <div class="transaction-details">
                <div class="transaction-reason">Budget Allocation</div>
                <div class="transaction-officer">Officer: Test Officer</div>
                <div class="transaction-date">${new Date().toLocaleDateString()}</div>
            </div>
        </div>
        <div class="transaction-amount positive">+$1,000.00</div>
    `;
    
    // Add to top of list
    historyContainer.insertBefore(transactionEntry, historyContainer.firstChild);
    console.log('Test transaction added successfully!');
};


function updateEmployeeTable() {
    if (!employeeTableBody) {
        console.warn('employeeTableBody element not found');
        return;
    }
    
    employeeTableBody.innerHTML = '';
    
    if (!currentData.employees || currentData.employees.length === 0) {
        employeeTableBody.innerHTML = '<tr><td colspan="6" class="no-data">No employees found</td></tr>';
        return;
    }
    
    currentData.employees.forEach(employee => {
        const row = document.createElement('tr');
        const rankLabel = getRankLabel(employee.grade);
        const firstLetter = employee.name.charAt(0).toUpperCase();
        
        row.innerHTML = `
            <td>
                <div class="employee-cell">
                    <div class="employee-avatar">${firstLetter}</div>
                    <div>
                        <div>${employee.name}</div>
                    </div>
                </div>
            </td>
            <td><span class="rank-badge">${rankLabel}</span></td>
            <td><span class="status-badge">${employee.status || 'Online'}</span></td>
            <td>Online</td>
            <td>1 min</td>
            <td>
                <div class="action-buttons">
                    <button class="action-btn action-btn-edit" onclick="openEmployeeEditModal('${employee.id}')" title="Edit Employee">
                        ✏️
                    </button>
                </div>
            </td>
        `;
        
        employeeTableBody.appendChild(row);
    });
}

// Simple function to add a test transaction directly
window.addTestTransactionDirect = function() {
    console.log('=== ADDING TEST TRANSACTION DIRECTLY ===');
    
    const historyContainer = document.getElementById('transactionHistory');
    if (!historyContainer) {
        console.error('History container not found!');
        return;
    }
    
    // Create test transaction
    const transactionEntry = document.createElement('div');
    transactionEntry.className = 'transaction-item';
    transactionEntry.innerHTML = `
        <div class="transaction-info">
            <span class="transaction-type-badge deposit">Deposit</span>
            <div class="transaction-details">
                <div class="transaction-reason">Budget Allocation</div>
                <div class="transaction-officer">Officer: Test Officer</div>
                <div class="transaction-date">${new Date().toLocaleDateString()}</div>
            </div>
        </div>
        <div class="transaction-amount positive">+$1,000.00</div>
    `;
    
    // Add to top of list
    historyContainer.insertBefore(transactionEntry, historyContainer.firstChild);
    console.log('Test transaction added successfully!');
};


function filterEmployees(searchTerm) {
    const rows = employeeTableBody.querySelectorAll('tr');
    rows.forEach(row => {
        const nameCell = row.querySelector('td:first-child');
        if (nameCell) {
            const name = nameCell.textContent.toLowerCase();
            if (name.includes(searchTerm.toLowerCase())) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        }
    });
}

// Simple function to add a test transaction directly
window.addTestTransactionDirect = function() {
    console.log('=== ADDING TEST TRANSACTION DIRECTLY ===');
    
    const historyContainer = document.getElementById('transactionHistory');
    if (!historyContainer) {
        console.error('History container not found!');
        return;
    }
    
    // Create test transaction
    const transactionEntry = document.createElement('div');
    transactionEntry.className = 'transaction-item';
    transactionEntry.innerHTML = `
        <div class="transaction-info">
            <span class="transaction-type-badge deposit">Deposit</span>
            <div class="transaction-details">
                <div class="transaction-reason">Budget Allocation</div>
                <div class="transaction-officer">Officer: Test Officer</div>
                <div class="transaction-date">${new Date().toLocaleDateString()}</div>
            </div>
        </div>
        <div class="transaction-amount positive">+$1,000.00</div>
    `;
    
    // Add to top of list
    historyContainer.insertBefore(transactionEntry, historyContainer.firstChild);
    console.log('Test transaction added successfully!');
};


function editEmployee(employeeId) {
    // Find employee and switch to employees tab
    const employee = currentData.employees.find(emp => emp.id === employeeId);
    if (employee) {
        switchTab('employees');
        // Scroll to employee in the list
        setTimeout(() => {
            const employeeCard = document.querySelector(`[data-employee-id="${employeeId}"]`);
            if (employeeCard) {
                employeeCard.scrollIntoView({ behavior: 'smooth' });
            }
        }, 100);
    }
}

// Track previous funds for animation
let previousFunds = 0;

function updateFundsDisplay() {
    console.log('Updating funds display - Current funds:', currentData.funds);

    // Try to find the element if it's not already cached
    let fundsElement = currentFundsSpan;
    if (!fundsElement) {
        fundsElement = document.getElementById('currentFunds');
        console.log('Found currentFunds element:', fundsElement);
    }

    if (fundsElement) {
        const newFunds = currentData.funds;

        // Use animated counter if available and funds changed significantly
        if (window.Animations && Math.abs(newFunds - previousFunds) > 0) {
            Animations.animateCounter(fundsElement, previousFunds, newFunds, 800, '$', '');
        } else {
            const formattedAmount = '$' + newFunds.toLocaleString();
            fundsElement.textContent = formattedAmount;
        }

        previousFunds = newFunds;
        console.log('Updated funds display to:', newFunds);
    } else {
        console.error('currentFunds element not found! Available elements:');
        console.log('Elements with "fund" in id:', document.querySelectorAll('[id*="fund"]'));
        console.log('Elements with "Fund" in id:', document.querySelectorAll('[id*="Fund"]'));
    }
}

function handleDeposit() {
    console.log('Deposit button clicked');
    const amount = parseFloat(depositAmount.value);
    const reason = document.getElementById('depositReason').value;
    console.log('Deposit amount:', amount, 'Reason:', reason);
    
    if (amount && amount > 0) {
        console.log('=== CLIENT DEPOSIT DEBUG ===');
        console.log('Amount:', amount);
        console.log('Reason from dropdown:', reason);
        console.log('Data being sent:', JSON.stringify({ amount: amount, reason: reason }));
        console.log('Sending deposit request for amount:', amount, 'with reason:', reason);
        
        // Immediately update the display optimistically
        console.log('Before deposit - currentData.funds:', currentData.funds);
        currentData.funds += amount;
        console.log('After deposit - currentData.funds:', currentData.funds);
        updateFundsDisplay();
        
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'https://pd_boss_menu/deposit');
        xhr.setRequestHeader('Content-Type', 'application/json');
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                console.log('=== DEPOSIT RESPONSE DEBUG ===');
                console.log('Status:', xhr.status);
                console.log('Response:', xhr.responseText);
                if (xhr.status === 200) {
                    console.log('Deposit successful');
                    console.log('=== DEPOSIT TRANSACTION DEBUG ===');
                    console.log('Original reason from dropdown:', reason);
                    console.log('getReasonText result:', getReasonText(reason));

                    // Show success toast
                    if (window.Animations) {
                        Animations.showToast({
                            title: 'Deposit Successful',
                            message: `$${amount.toLocaleString()} deposited to department funds`,
                            type: 'success',
                            icon: '💰'
                        });
                    }
                    
                    // Direct transaction logging - simple and reliable
                    const historyContainer = document.getElementById('transactionHistory');
                    if (historyContainer) {
                        // Create new transaction entry
                        const transactionEntry = document.createElement('div');
                        transactionEntry.className = 'transaction-item';
                        transactionEntry.innerHTML = `
                            <div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 0.5rem;">
                                <span class="transaction-type-badge deposit">Deposit</span>
                                <div class="transaction-amount positive">+$${amount.toLocaleString()}</div>
                            </div>
                            <div style="display: flex; flex-direction: column; gap: 0.25rem;">
                                <div class="transaction-reason">${getReasonText(reason)}</div>
                                <div class="transaction-officer">Officer: ${currentUser.name}</div>
                                <div class="transaction-date">${new Date().toLocaleDateString()}</div>
                            </div>
                        `;
                        
                        // Add to top of list
                        historyContainer.insertBefore(transactionEntry, historyContainer.firstChild);
                        console.log('Transaction added to display');
                    }
                    
                    // Reset form AFTER transaction is created
                    depositAmount.value = '';
                    document.getElementById('depositReason').value = 'budget_allocation';
                    
                    // Refresh data to get accurate amounts and reload transactions
                    setTimeout(() => {
                        refreshData();
                        // Force reload transactions from database to show correct reason
                        loadTransactionsFromServer();
                    }, 1000);
                } else {
                    console.error('Deposit failed:', xhr.status);
                    console.error('Response text:', xhr.responseText);
                    // Revert the optimistic update
                    currentData.funds -= amount;
                    updateFundsDisplay();
                    
                    // Show error notification
                    var errorXhr = new XMLHttpRequest();
                    errorXhr.open('POST', 'https://pd_boss_menu/showNotification');
                    errorXhr.setRequestHeader('Content-Type', 'application/json');
                    errorXhr.send(JSON.stringify({
                        title: getDeptLabel() + ' Funds',
                        message: 'Deposit failed! Please try again.',
                        type: 'error'
                    }));
                }
            }
        };


        
        xhr.send(JSON.stringify({ amount: amount, reason: reason }));
    } else {
        console.warn('Invalid deposit amount:', amount);
        // Send notification to client instead of alert
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'https://pd_boss_menu/showNotification');
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.send(JSON.stringify({ 
            title: 'Invalid Amount', 
            message: 'Please enter a valid deposit amount', 
            type: 'error' 
        }));
    }
}

function handleWithdraw() {
    console.log('=== WITHDRAW FUNCTION CALLED ===');
    console.log('Withdraw button clicked');
    console.log('withdrawAmount element:', withdrawAmount);
    console.log('withdrawAmount value:', withdrawAmount ? withdrawAmount.value : 'ELEMENT NOT FOUND');
    
    if (!withdrawAmount) {
        console.error('withdrawAmount element is null!');
        return;
    }
    
    const amount = parseFloat(withdrawAmount.value);
    const reason = document.getElementById('withdrawReason').value;
    console.log('Withdraw amount:', amount, 'Reason:', reason);
    console.log('withdrawReason element:', document.getElementById('withdrawReason'));
    
    if (amount && amount > 0) {
        // Check if we have enough funds
        if (currentData.funds < amount) {
            // Send notification to client instead of alert
            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'https://pd_boss_menu/showNotification');
            xhr.setRequestHeader('Content-Type', 'application/json');
            xhr.send(JSON.stringify({
                title: getDeptLabel() + ' Funds',
                message: 'Insufficient ' + getDeptLabel() + ' funds! Current: $' + currentData.funds.toLocaleString(),
                type: 'error'
            }));
            return;
        }
        
        console.log('=== CLIENT WITHDRAWAL DEBUG ===');
        console.log('Amount:', amount);
        console.log('Reason from dropdown:', reason);
        console.log('Data being sent:', JSON.stringify({ amount: amount, reason: reason }));
        console.log('Sending withdraw request for amount:', amount, 'with reason:', reason);
        
        // Immediately update the display optimistically
        console.log('Before withdraw - currentData.funds:', currentData.funds);
        currentData.funds -= amount;
        console.log('After withdraw - currentData.funds:', currentData.funds);
        updateFundsDisplay();
        
        console.log('=== SENDING WITHDRAW REQUEST ===');
        console.log('URL: https://pd_boss_menu/withdraw');
        console.log('Data being sent:', JSON.stringify({ amount: amount, reason: reason }));
        
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'https://pd_boss_menu/withdraw');
        xhr.setRequestHeader('Content-Type', 'application/json');
        
        xhr.onreadystatechange = function() {
            console.log('XHR State:', xhr.readyState, 'Status:', xhr.status);
            if (xhr.readyState === 4) {
                console.log('=== WITHDRAW RESPONSE DEBUG ===');
                console.log('Status:', xhr.status);
                console.log('Response:', xhr.responseText);
                
                if (xhr.status === 200) {
                    console.log('Withdraw successful');

                    // Show success toast
                    if (window.Animations) {
                        Animations.showToast({
                            title: 'Withdrawal Successful',
                            message: `$${amount.toLocaleString()} withdrawn from department funds`,
                            type: 'success',
                            icon: '💸'
                        });
                    }

                    // Direct transaction logging - simple and reliable
                    const historyContainer = document.getElementById('transactionHistory');
                    if (historyContainer) {
                        // Create new transaction entry
                        const transactionEntry = document.createElement('div');
                        transactionEntry.className = 'transaction-item';
                        transactionEntry.innerHTML = `
                            <div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 0.5rem;">
                                <span class="transaction-type-badge withdraw">Withdrawal</span>
                                <div class="transaction-amount negative">-$${amount.toLocaleString()}</div>
                            </div>
                            <div style="display: flex; flex-direction: column; gap: 0.25rem;">
                                <div class="transaction-reason">${getReasonText(reason)}</div>
                                <div class="transaction-officer">Officer: ${currentUser.name}</div>
                                <div class="transaction-date">${new Date().toLocaleDateString()}</div>
                            </div>
                        `;
                        
                        // Add to top of list
                        historyContainer.insertBefore(transactionEntry, historyContainer.firstChild);
                        console.log('Transaction added to display');
                    }
                    
                    // Reset form AFTER transaction is created
                    withdrawAmount.value = '';
                    document.getElementById('withdrawReason').value = 'equipment_purchase';
                    
                    // Refresh data to get accurate amounts and reload transactions
                    setTimeout(() => {
                        refreshData();
                        // Force reload transactions from database to show correct reason
                        loadTransactionsFromServer();
                    }, 1000);
                } else {
                    console.error('Withdraw failed:', xhr.status);
                    console.error('Response text:', xhr.responseText);
                    // Revert the optimistic update
                    currentData.funds += amount;
                    updateFundsDisplay();
                    
                    // Show error notification
                    var errorXhr = new XMLHttpRequest();
                    errorXhr.open('POST', 'https://pd_boss_menu/showNotification');
                    errorXhr.setRequestHeader('Content-Type', 'application/json');
                    errorXhr.send(JSON.stringify({
                        title: getDeptLabel() + ' Funds',
                        message: 'Withdrawal failed! Please try again.',
                        type: 'error'
                    }));
                }
            }
        };


        
        console.log('Sending withdraw request...');
        xhr.send(JSON.stringify({ amount: amount, reason: reason }));
        console.log('Withdraw request sent');
        
    } else {
        console.warn('Invalid withdraw amount:', amount);
        // Send notification to client instead of alert
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'https://pd_boss_menu/showNotification');
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.send(JSON.stringify({
            title: getDeptLabel() + ' Funds',
            message: 'Please enter a valid amount to withdraw',
            type: 'error'
        }));
    }
}

function updateEmployeeList() {
    if (!employeeTableBody) {
        console.warn('employeeTableBody element not found');
        return;
    }

    employeeTableBody.innerHTML = '';

    if (!currentData.employees || currentData.employees.length === 0) {
        employeeTableBody.innerHTML = '<tr><td colspan="6" class="no-data">No employees found</td></tr>';
        return;
    }

    // Sort employees by grade level (highest to lowest), then by online status
    const sortedEmployees = [...currentData.employees].sort((a, b) => {
        // Online first, then by grade
        const aOnline = a.online === true;
        const bOnline = b.online === true;
        if (aOnline !== bOnline) return bOnline ? 1 : -1;
        return b.grade - a.grade;
    });

    sortedEmployees.forEach(employee => {
        const row = document.createElement('tr');

        // Find the rank label
        let rankLabel = employee.rank;
        for (const rank of currentData.ranks) {
            if (rank.name.toLowerCase() === employee.rank.toLowerCase() || rank.grade === employee.grade) {
                rankLabel = rank.label;
                break;
            }
        }

        // Determine online/offline status - must be explicitly true to be online
        const isOnline = employee.online === true;
        const statusClass = isOnline ? 'online' : 'offline';
        const statusText = isOnline ? '🟢 Online' : '❌ Offline';
        const statusBadgeClass = isOnline ? 'status-online' : 'status-offline';

        // Use citizenid as identifier for offline employees, id for online
        const employeeIdentifier = employee.citizenid ? `'${employee.citizenid}'` : employee.id;

        // Conditionally show bonus button based on payBonuses permission
        const bonusButton = currentUserPermissions.payBonuses ?
            `<button class="btn btn-bonus" onclick="openBonusModal(${employeeIdentifier})" title="Pay Bonus">💰</button>` : '';

        row.innerHTML = `
            <td>
                <span class="employee-name-cell">${employee.name}</span>
            </td>
            <td><span class="rank-badge">${rankLabel}</span></td>
            <td><span class="status-badge ${statusBadgeClass}">${statusText}</span></td>
            <td>${employee.location || (isOnline ? 'In City' : 'N/A')}</td>
            <td>${employee.playTime || (isOnline ? 'Active' : 'Offline')}</td>
            <td>
                <div class="action-buttons">
                    <button class="btn btn-actions" onclick="openEmployeeEditModal(${employeeIdentifier})" title="Edit Employee">✏️</button>
                    ${bonusButton}
                </div>
            </td>
        `;

        // Add offline class for styling
        if (!isOnline) {
            row.classList.add('employee-offline');
        }

        employeeTableBody.appendChild(row);
    });
}

// Simple function to add a test transaction directly
window.addTestTransactionDirect = function() {
    console.log('=== ADDING TEST TRANSACTION DIRECTLY ===');
    
    const historyContainer = document.getElementById('transactionHistory');
    if (!historyContainer) {
        console.error('History container not found!');
        return;
    }
    
    // Create test transaction
    const transactionEntry = document.createElement('div');
    transactionEntry.className = 'transaction-item';
    transactionEntry.innerHTML = `
        <div class="transaction-info">
            <span class="transaction-type-badge deposit">Deposit</span>
            <div class="transaction-details">
                <div class="transaction-reason">Budget Allocation</div>
                <div class="transaction-officer">Officer: Test Officer</div>
                <div class="transaction-date">${new Date().toLocaleDateString()}</div>
            </div>
        </div>
        <div class="transaction-amount positive">+$1,000.00</div>
    `;
    
    // Add to top of list
    historyContainer.insertBefore(transactionEntry, historyContainer.firstChild);
    console.log('Test transaction added successfully!');
};


function updatePlayerList() {
    if (!playerList) {
        console.warn('playerList element not found');
        return;
    }
    
    playerList.innerHTML = '';
    
    if (!currentData.players || currentData.players.length === 0) {
        return;
    }
    
    currentData.players.forEach(player => {
        const playerCard = document.createElement('div');
        playerCard.className = 'player-card';
        
        playerCard.innerHTML = `
            <div class="player-info">
                <h4>${player.name}</h4>
                <p>Current Job: ${player.job}</p>
                ${player.distance ? `<p>Distance: ${player.distance}m</p>` : ''}
            </div>
            <div class="player-actions">
                <select class="rank-select" id="hire-rank-${player.id}">
                    ${currentData.ranks.map(rank => 
                        `<option value="${rank.name}">${rank.label}</option>`
                    ).join('')}
                </select>
                <button class="btn btn-hire" onclick="hirePlayer(${player.id})">Hire</button>
            </div>
        `;
        
        playerList.appendChild(playerCard);
    });
    
    // Update recruitment stats
    updateRecruitmentStats();
}

function getNearbyPlayers() {
    console.log('Getting nearby players...');
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'https://pd_boss_menu/getNearbyPlayers');
    xhr.send();
}

// Manual refresh function for nearby players
function refreshNearbyPlayers() {
    console.log('=== MANUALLY REFRESHING NEARBY PLAYERS ===');
    getNearbyPlayers();
}

function hirePlayer(playerId) {
    const rankSelect = document.getElementById(`hire-rank-${playerId}`);
    const rank = rankSelect.value;

    console.log('Hiring player:', playerId, 'with rank:', rank);

    // Increment hired this week counter
    hiredThisWeek++;

    // Update recruitment stats
    updateRecruitmentStats();

    // Use the original NetEvent system that was working
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'https://pd_boss_menu/hire');
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send(JSON.stringify({ playerId: playerId, rank: rank }));

    // Celebration animation!
    if (window.Animations) {
        Animations.celebrate({
            title: 'New Officer Hired!',
            message: `Successfully hired as ${rank}`,
            confetti: true
        });
    }

    // Refresh the nearby players list
    setTimeout(function() {
        getNearbyPlayers();
    }, 1000);
}

function fireEmployee(playerId) {
    console.log('=== FIRE EMPLOYEE ===');
    console.log('Firing employee:', playerId);
    
    // Send fire request to server
    fetch(`https://${GetParentResourceName()}/refreshData`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ 
            action: 'fire',
            playerId: playerId 
        })
    })
    .then(response => {
        console.log('Fire request response:', response.status);
        // Refresh data after fire
        setTimeout(() => {
            refreshData();
        }, 500);
    })
    .catch(error => {
        console.error('Fire request error:', error);
        // Still refresh data even if fire fails
        setTimeout(() => {
            refreshData();
        }, 500);
    });
    
    console.log('Fire request sent');
}

function setRank(playerId) {
    // Find the rank select element
    let rankSelect = document.getElementById(`rank-${playerId}`);
    if (!rankSelect) {
        rankSelect = document.querySelector('.rank-select-large');
    }
    
    if (!rankSelect) {
        console.error('Rank select element not found');
        return;
    }
    
    const rank = rankSelect.value;
    
    // Get the current player's name from the data
    let playerName = null;
    if (currentData.employees && currentData.employees.length > 0) {
        // Use the first employee's name (which should be the current player)
        playerName = currentData.employees[0].name;
    }
    
    if (!playerName) {
        console.error('Player name not found');
        return;
    }
    
    // Send the rank update request using player name instead of ID
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'https://pd_boss_menu/setRank');
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send(JSON.stringify({ playerName: playerName, rank: rank }));
    
    // Instantly refresh data
    var dataXhr = new XMLHttpRequest();
    dataXhr.open('POST', 'https://pd_boss_menu/refreshData');
    dataXhr.send();
}

// Table-based rank change function
function setRankFromTable(employeeName) {
    // Find the rank select for this employee
    const employee = currentData.employees.find(emp => emp.name === employeeName);
    if (!employee) {
        console.error('Employee not found:', employeeName);
        return;
    }
    
    const rankSelect = document.getElementById(`rank-select-${employee.id}`);
    if (!rankSelect) {
        console.error('Rank select not found for employee:', employeeName);
        return;
    }
    
    const rank = rankSelect.value;
    
    // Send the rank update request using player name
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'https://pd_boss_menu/setRank');
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send(JSON.stringify({ playerName: employeeName, rank: rank }));
    
    // Instantly refresh data
    var dataXhr = new XMLHttpRequest();
    dataXhr.open('POST', 'https://pd_boss_menu/refreshData');
    dataXhr.send();
}

// Table-based fire employee function
function fireEmployeeFromTable(employeeName) {
    if (!confirm(`Are you sure you want to fire ${employeeName}?`)) {
        return;
    }
    
    console.log('Firing employee from table:', employeeName);
    
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'https://pd_boss_menu/fire');
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send(JSON.stringify({ playerName: employeeName }));
    
    setTimeout(function() {
        refreshData();
    }, 1000);
}

// Employee Edit Modal Functions
let currentEditingEmployee = null;
let pendingRankChange = null;

function openEmployeeEditModal(employeeIdOrCitizenId) {
    console.log('Opening edit modal for employee:', employeeIdOrCitizenId);
    console.log('Available employees:', currentData.employees);

    // Find the employee data by id or citizenid
    let employee = null;
    if (typeof employeeIdOrCitizenId === 'string') {
        // It's a citizenid (string)
        employee = currentData.employees.find(emp => emp.citizenid === employeeIdOrCitizenId);
    } else {
        // It's a server id (number)
        employee = currentData.employees.find(emp => emp.id == employeeIdOrCitizenId);
    }

    if (!employee) {
        console.error('Employee not found:', employeeIdOrCitizenId);
        return;
    }

    console.log('Found employee:', employee);
    currentEditingEmployee = employee;
    pendingRankChange = null;

    // Populate modal with employee data
    document.getElementById('editEmployeeAvatar').textContent = employee.name.charAt(0).toUpperCase();

    // Show online/offline status in name
    const statusIndicator = employee.online === true ? '🟢' : '❌';
    document.getElementById('editEmployeeName').textContent = `${statusIndicator} ${employee.name}`;

    // Update current rank display
    updateCurrentRankDisplay(employee);

    // Populate rank selection cards
    populateRankSelectionCards(employee);

    // Disciplinary status removed - no longer needed

    // Hide rank change preview
    document.getElementById('rankChangePreview').style.display = 'none';

    // Show modal
    document.getElementById('employeeEditModal').classList.remove('hidden');

    // Reapply permissions to the modal content
    applyModalPermissions();
}

function updateCurrentRankDisplay(employee) {
    const currentRankBadge = document.getElementById('currentRankBadge');
    const currentRankGrade = document.getElementById('currentRankGrade');
    
    // Find the rank label for the employee's grade
    const rank = currentData.ranks.find(r => r.grade === employee.grade);
    const rankLabel = rank ? rank.label : 'Unknown';
    
    currentRankBadge.textContent = rankLabel;
    currentRankGrade.textContent = `Grade ${employee.grade}`;
    
    // Rank cards will be populated separately
}

function populateRankSelectionCards(employee) {
    const rankGrid = document.getElementById('rankSelectionGrid');
    rankGrid.innerHTML = '';
    
    // Sort ranks by grade (lowest to highest)
    const sortedRanks = [...currentData.ranks].sort((a, b) => a.grade - b.grade);
    
    sortedRanks.forEach(rank => {
        const rankCard = document.createElement('div');
        rankCard.className = 'rank-card';
        rankCard.dataset.rankName = rank.name;
        rankCard.dataset.rankGrade = rank.grade;
        
        // Add current class if this is the employee's current rank
        if (rank.grade === employee.grade) {
            rankCard.classList.add('current');
        }
        
        rankCard.innerHTML = `
            <div class="rank-card-name">${rank.label}</div>
            <div class="rank-card-grade">Grade ${rank.grade}</div>
        `;
        
        // Add click handler
        rankCard.addEventListener('click', () => selectRank(rank));
        
        rankGrid.appendChild(rankCard);
    });
}

// Simple function to add a test transaction directly
window.addTestTransactionDirect = function() {
    console.log('=== ADDING TEST TRANSACTION DIRECTLY ===');
    
    const historyContainer = document.getElementById('transactionHistory');
    if (!historyContainer) {
        console.error('History container not found!');
        return;
    }
    
    // Create test transaction
    const transactionEntry = document.createElement('div');
    transactionEntry.className = 'transaction-item';
    transactionEntry.innerHTML = `
        <div class="transaction-info">
            <span class="transaction-type-badge deposit">Deposit</span>
            <div class="transaction-details">
                <div class="transaction-reason">Budget Allocation</div>
                <div class="transaction-officer">Officer: Test Officer</div>
                <div class="transaction-date">${new Date().toLocaleDateString()}</div>
            </div>
        </div>
        <div class="transaction-amount positive">+$1,000.00</div>
    `;
    
    // Add to top of list
    historyContainer.insertBefore(transactionEntry, historyContainer.firstChild);
    console.log('Test transaction added successfully!');
};


function selectRank(rank) {
    // Remove selected class from all cards
    document.querySelectorAll('.rank-card').forEach(card => {
        card.classList.remove('selected');
    });
    
    // Add selected class to clicked card
    const selectedCard = document.querySelector(`[data-rank-name="${rank.name}"]`);
    if (selectedCard) {
        selectedCard.classList.add('selected');
    }
    
    // Update preview
    const preview = document.getElementById('rankChangePreview');
    const previewRank = document.getElementById('previewRank');
    
    previewRank.textContent = rank.label;
    preview.style.display = 'flex';
    
    // Store the selected rank
    pendingRankChange = rank;
}

function closeEmployeeEditModal() {
    document.getElementById('employeeEditModal').classList.add('hidden');
    currentEditingEmployee = null;
    pendingRankChange = null;
}

// Close all modals - used when escaping or force closing the menu
function closeAllModals() {
    const modalIds = [
        'employeeEditModal',
        'rankManagementModal',
        'officerHoursModal',
        'officerDisciplinaryModal',
        'addDisciplinaryModal'
    ];

    modalIds.forEach(id => {
        const modal = document.getElementById(id);
        if (modal) {
            modal.classList.add('hidden');
        }
    });

    // Reset modal state variables
    currentEditingEmployee = null;
    pendingRankChange = null;
    rankModalOpen = false;
    selectedOfficer = null;
}

// Removed old changeEmployeeRank function - now using rank card selection

function saveEmployeeChanges() {
    if (!currentEditingEmployee) {
        console.error('No employee being edited');
        return;
    }

    console.log('Saving changes for:', currentEditingEmployee.name);

    // Send rank update if there's a pending change
    if (pendingRankChange) {
        console.log('Applying rank change:', pendingRankChange.label);
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'https://pd_boss_menu/setRank');
        xhr.setRequestHeader('Content-Type', 'application/json');
        // Send citizenid for offline players, playerId for online
        xhr.send(JSON.stringify({
            citizenid: currentEditingEmployee.citizenid,
            playerId: currentEditingEmployee.id,
            playerName: currentEditingEmployee.name,
            rank: pendingRankChange.name
        }));
    }

    // Disciplinary status updates removed - no longer needed

    // Close modal
    closeEmployeeEditModal();

    // Refresh data
    setTimeout(() => {
        refreshData();
    }, 500);
}

function fireEmployeeFromModal() {
    console.log('=== FIRE EMPLOYEE FROM MODAL ===');
    console.log('Modal fire function called');

    // Store employee identifier before clearing (prefer citizenid for offline support)
    const employeeIdentifier = currentEditingEmployee ?
        (currentEditingEmployee.citizenid || currentEditingEmployee.id) : null;
    const isOnline = currentEditingEmployee ? currentEditingEmployee.online === true : false;

    // Close modal properly
    try {
        console.log('Closing modal...');
        closeEmployeeEditModal();
        console.log('Modal closed successfully');
    } catch (e) {
        console.error('Modal close failed:', e);
    }

    // Fire the employee if we have an identifier
    if (employeeIdentifier) {
        console.log('Firing employee:', employeeIdentifier, 'Online:', isOnline);
        fireEmployee(employeeIdentifier);
    }

    console.log('Fire from modal completed');
}

// Rank Management Modal Functions
function openRankModal() {
    console.log('Opening rank management modal');
    document.getElementById('rankManagementModal').classList.remove('hidden');
    
    // Set flag to prevent server overrides
    rankModalOpen = true;
    
    // Always load current permissions from server when opening modal
    console.log('Loading current rank permissions from server...');
    loadRankPermissions();
    
    // Ensure all rank cards are visible
    const rankCards = document.querySelectorAll('.rank-card');
    rankCards.forEach(card => {
        card.style.display = 'block';
    });
    
    // Add event listeners to all checkboxes for interaction
    addCheckboxEventListeners();
}

function closeRankModal() {
    document.getElementById('rankManagementModal').classList.add('hidden');
    // Clear flag when modal is closed
    rankModalOpen = false;
}

// Load current rank permissions from server
function loadRankPermissions() {
    console.log('Loading rank permissions from server...');
    // Send request to get current permissions
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'https://pd_boss_menu/getRankPermissions');
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            // The server sends data via client event, not HTTP response
            // The updateRankPermissionUI will be called from the message handler
            console.log('Requested rank permissions from server - waiting for response via client event');
        } else if (xhr.readyState === 4) {
            console.error('Failed to request rank permissions:', xhr.status, xhr.responseText);
        }
    };


    xhr.send();
}

// Update the rank permission UI based on server data
function updateRankPermissionUI(permissions) {
    console.log('Loading rank permissions:', permissions);
    
    // Get all rank cards (they should all be visible by default)
    const rankCards = document.querySelectorAll('.rank-card');
    console.log('Found', rankCards.length, 'rank cards');
    
    // Update each rank card with permissions
    rankCards.forEach(card => {
        const grade = card.getAttribute('data-grade');
        console.log('Processing rank card for grade:', grade);
        
        const checkboxes = card.querySelectorAll('input[type="checkbox"]');
        
        if (checkboxes.length >= 6) {
            // Use server permissions if available, otherwise use defaults
            const serverPermissions = permissions[grade];
            if (serverPermissions) {
                console.log('Using server permissions for grade', grade, ':', serverPermissions);
                checkboxes[0].checked = serverPermissions.viewBanking || false;
                checkboxes[1].checked = serverPermissions.viewDisciplinary || false;
                checkboxes[2].checked = serverPermissions.hireEmployees || false;
                checkboxes[3].checked = serverPermissions.fireEmployees || false;
                checkboxes[4].checked = serverPermissions.changeRanks || false;
                checkboxes[5].checked = serverPermissions.accessSettings || false;
            } else {
                console.log('No server permissions for grade', grade, '- using defaults');
                checkboxes.forEach(checkbox => {
                    checkbox.checked = true;
                });
            }
            console.log('Set checkboxes for grade', grade);
        } else {
            console.error('Not enough checkboxes found for grade', grade, 'Expected 6, found', checkboxes.length);
        }
    });
    
    // Add event listeners to all checkboxes
    addCheckboxEventListeners();
}

// Add event listeners to checkboxes for real-time interaction
function addCheckboxEventListeners() {
    const allCheckboxes = document.querySelectorAll('.rank-card input[type="checkbox"]');
    console.log('Adding event listeners to', allCheckboxes.length, 'checkboxes');
    
    allCheckboxes.forEach((checkbox, index) => {
        // Remove existing listeners to avoid duplicates
        checkbox.removeEventListener('change', handlePermissionChange);
        // Add new listener
        checkbox.addEventListener('change', handlePermissionChange);
        console.log(`Added listener to checkbox ${index + 1}`);
    });
}

// Simple function to add a test transaction directly
window.addTestTransactionDirect = function() {
    console.log('=== ADDING TEST TRANSACTION DIRECTLY ===');
    
    const historyContainer = document.getElementById('transactionHistory');
    if (!historyContainer) {
        console.error('History container not found!');
        return;
    }
    
    // Create test transaction
    const transactionEntry = document.createElement('div');
    transactionEntry.className = 'transaction-item';
    transactionEntry.innerHTML = `
        <div class="transaction-info">
            <span class="transaction-type-badge deposit">Deposit</span>
            <div class="transaction-details">
                <div class="transaction-reason">Budget Allocation</div>
                <div class="transaction-officer">Officer: Test Officer</div>
                <div class="transaction-date">${new Date().toLocaleDateString()}</div>
            </div>
        </div>
        <div class="transaction-amount positive">+$1,000.00</div>
    `;
    
    // Add to top of list
    historyContainer.insertBefore(transactionEntry, historyContainer.firstChild);
    console.log('Test transaction added successfully!');
};


// Handle checkbox changes
function handlePermissionChange(event) {
    const checkbox = event.target;
    const rankCard = checkbox.closest('.rank-card');
    
    // Validate elements exist
    if (!rankCard) {
        console.error('Could not find rank card for checkbox');
        return;
    }
    
    const grade = rankCard.getAttribute('data-grade');
    if (!grade) {
        console.error('Could not find grade for rank card');
        return;
    }
    
    console.log(`Permission changed for grade ${grade}:`, checkbox.checked);
    
    // Visual feedback only - don't apply changes until Save is clicked
    if (checkbox.checked) {
        console.log(`Enabled permission for grade ${grade}`);
    } else {
        console.log(`Disabled permission for grade ${grade}`);
    }
    
    // Add visual feedback to show changes are pending
    const saveButton = document.querySelector('#rankManagementModal .modal-footer button');
    if (saveButton) {
        saveButton.style.backgroundColor = '#ff6b35'; // Orange to indicate pending changes
        saveButton.textContent = 'Save Changes *';
    }
}

// Get default permissions for a specific grade (matching jobs.lua grades 1-14)
function getDefaultPermissionsForGrade(grade) {
    const defaultPermissions = {
        1: { // Cadet
            viewEmployees: true,
            viewBanking: false,
            viewDisciplinary: false,
            hireEmployees: false,
            fireEmployees: false,
            changeRanks: false,
            viewReports: false,
            accessSettings: false
        },
        2: { // Probationary Officer
            viewEmployees: true,
            viewBanking: false,
            viewDisciplinary: false,
            hireEmployees: false,
            fireEmployees: false,
            changeRanks: false,
            viewReports: false,
            accessSettings: false
        },
        3: { // Officer
            viewEmployees: true,
            viewBanking: false,
            viewDisciplinary: true,
            hireEmployees: false,
            fireEmployees: false,
            changeRanks: false,
            viewReports: false,
            accessSettings: false
        },
        4: { // Senior Officer
            viewEmployees: true,
            viewBanking: false,
            viewDisciplinary: true,
            hireEmployees: false,
            fireEmployees: false,
            changeRanks: false,
            viewReports: false,
            accessSettings: false
        },
        5: { // Corporal
            viewEmployees: true,
            viewBanking: false,
            viewDisciplinary: true,
            hireEmployees: false,
            fireEmployees: false,
            changeRanks: false,
            viewReports: true,
            accessSettings: false
        },
        6: { // Sergeant
            viewEmployees: true,
            viewBanking: true,
            viewDisciplinary: true,
            hireEmployees: false,
            fireEmployees: false,
            changeRanks: false,
            viewReports: true,
            accessSettings: false
        },
        7: { // Staff Sergeant
            viewEmployees: true,
            viewBanking: true,
            viewDisciplinary: true,
            hireEmployees: false,
            fireEmployees: false,
            changeRanks: false,
            viewReports: true,
            accessSettings: false
        },
        8: { // Lieutenant
            viewEmployees: true,
            viewBanking: true,
            viewDisciplinary: true,
            hireEmployees: true,
            fireEmployees: false,
            changeRanks: false,
            viewReports: true,
            accessSettings: false
        },
        9: { // Captain
            viewEmployees: true,
            viewBanking: true,
            viewDisciplinary: true,
            hireEmployees: true,
            fireEmployees: false,
            changeRanks: true,
            viewReports: true,
            accessSettings: false
        },
        10: { // Major
            viewEmployees: true,
            viewBanking: true,
            viewDisciplinary: true,
            hireEmployees: true,
            fireEmployees: true,
            changeRanks: true,
            viewReports: true,
            accessSettings: false
        },
        11: { // Commander (isboss)
            viewEmployees: true,
            viewBanking: true,
            viewDisciplinary: true,
            hireEmployees: true,
            fireEmployees: true,
            changeRanks: true,
            viewReports: true,
            accessSettings: true
        },
        12: { // Deputy Chief (isboss)
            viewEmployees: true,
            viewBanking: true,
            viewDisciplinary: true,
            hireEmployees: true,
            fireEmployees: true,
            changeRanks: true,
            viewReports: true,
            accessSettings: true
        },
        13: { // Assistant Chief (isboss)
            viewEmployees: true,
            viewBanking: true,
            viewDisciplinary: true,
            hireEmployees: true,
            fireEmployees: true,
            changeRanks: true,
            viewReports: true,
            accessSettings: true
        },
        14: { // Chief (isboss)
            viewEmployees: true,
            viewBanking: true,
            viewDisciplinary: true,
            hireEmployees: true,
            fireEmployees: true,
            changeRanks: true,
            viewReports: true,
            accessSettings: true
        }
    };
    return defaultPermissions[grade] || defaultPermissions[1];
}

// Debounce timer for permission refreshes
let permissionRefreshTimer = null;

// Debounced permission refresh to prevent multiple rapid requests
function debouncedPermissionRefresh() {
    // Clear existing timer
    if (permissionRefreshTimer) {
        clearTimeout(permissionRefreshTimer);
    }
    
    // Set new timer
    permissionRefreshTimer = setTimeout(() => {
        console.log('Executing debounced permission refresh...');
        getUserPermissions();
        permissionRefreshTimer = null;
    }, 500); // Wait 500ms before refreshing
}

// Save rank permissions
function saveRankPermissions() {
    console.log('Saving rank permissions...');
    
    // Get all rank cards
    const visibleRankCards = document.querySelectorAll('.rank-card');
    const permissions = {};


    let validCards = 0;
    let invalidCards = 0;
    
    console.log('Found', visibleRankCards.length, 'rank cards');
    
    visibleRankCards.forEach(card => {
        const grade = card.getAttribute('data-grade');
        const checkboxes = card.querySelectorAll('input[type="checkbox"]');
        
        console.log(`Processing rank card for grade ${grade}, found ${checkboxes.length} checkboxes`);
        
        // Validate the rank card
        if (!grade) {
            console.error('Rank card missing grade attribute');
            invalidCards++;
            return;
        }
        
        if (checkboxes.length < 6) {
            console.error(`Invalid rank card for grade ${grade}: Expected 6 checkboxes, found ${checkboxes.length}`);
            invalidCards++;
            return;
        }
        
        // Process valid rank card
        permissions[grade] = {
            viewBanking: checkboxes[0].checked,
            viewDisciplinary: checkboxes[1].checked,
            hireEmployees: checkboxes[2].checked,
            fireEmployees: checkboxes[3].checked,
            changeRanks: checkboxes[4].checked,
            accessSettings: checkboxes[5].checked
        };


        
        validCards++;
        console.log(`Grade ${grade} permissions:`, permissions[grade]);
    });
    
    // Check if we have valid data to save
    if (invalidCards > 0) {
        console.error(`Found ${invalidCards} invalid rank cards, ${validCards} valid cards`);
        showNotification('Rank Management', `Found ${invalidCards} invalid rank cards. Please check the interface.`, 'error');
        return;
    }
    
    if (validCards === 0) {
        console.error('No valid rank cards found');
        showNotification('Rank Management', 'No valid rank cards found. Please refresh and try again.', 'error');
        return;
    }
    
    console.log('Sending permissions to server:', permissions);
    
    // WORKAROUND: Store permissions locally since server database is broken
    if (permissions['4'] && permissions['4'].hireEmployees !== undefined) {
        localStorage.setItem('hireEmployeesPermission', permissions['4'].hireEmployees.toString());
        console.log('Stored local hire permission:', permissions['4'].hireEmployees);
    }
    
    if (permissions['4'] && permissions['4'].changeRanks !== undefined) {
        localStorage.setItem('changeRanksPermission', permissions['4'].changeRanks.toString());
        console.log('Stored local changeRanks permission:', permissions['4'].changeRanks);
    }
    
    if (permissions['4'] && permissions['4'].fireEmployees !== undefined) {
        localStorage.setItem('fireEmployeesPermission', permissions['4'].fireEmployees.toString());
        console.log('Stored local fireEmployees permission:', permissions['4'].fireEmployees);
    }
    
    if (permissions['4'] && permissions['4'].accessSettings !== undefined) {
        localStorage.setItem('accessSettingsPermission', permissions['4'].accessSettings.toString());
        console.log('Stored local accessSettings permission:', permissions['4'].accessSettings);
    }
    
    // Store disciplinary permission locally
    if (permissions['4'] && permissions['4'].viewDisciplinary !== undefined) {
        localStorage.setItem('viewDisciplinaryPermission', permissions['4'].viewDisciplinary.toString());
        console.log('Stored local viewDisciplinary permission:', permissions['4'].viewDisciplinary);
        
        // Update current user permissions immediately
        currentUserPermissions.viewDisciplinary = permissions['4'].viewDisciplinary;
        console.log('Updated currentUserPermissions.viewDisciplinary to:', currentUserPermissions.viewDisciplinary);
        
        // Apply permission restrictions immediately
        applyPermissionRestrictions();
    }
    
    // Send permissions to server
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'https://pd_boss_menu/saveRankPermissions');
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    console.log('Rank permissions saved successfully');
                    // Show success notification
                    showNotification('Rank Management', 'Rank permissions updated successfully', 'success');
                    // Reset save button
                    resetSaveButton();
                    // Refresh user permissions to apply the changes with debouncing
                    console.log('Refreshing user permissions to apply rank changes...');
                    debouncedPermissionRefresh();
                } else {
                    console.error('Failed to save rank permissions:', xhr.status, xhr.responseText);
                    showNotification('Rank Management', 'Failed to save rank permissions', 'error');
                }
            }
    };


    xhr.onerror = function() {
        console.error('Network error while saving rank permissions');
        showNotification('Rank Management', 'Network error while saving permissions', 'error');
    };


    xhr.send(JSON.stringify(permissions));
}

// Helper function to show notifications
function showNotification(title, message, type) {
    var notifyXhr = new XMLHttpRequest();
    notifyXhr.open('POST', 'https://pd_boss_menu/showNotification');
    notifyXhr.setRequestHeader('Content-Type', 'application/json');
    notifyXhr.send(JSON.stringify({ 
        title: title, 
        message: message, 
        type: type 
    }));
}

// Manual refresh function for permissions
function refreshPermissions() {
    console.log('=== MANUALLY REFRESHING PERMISSIONS ===');
    getUserPermissions();
}

// Debug function to check current permissions
function debugPermissions() {
    console.log('=== CURRENT PERMISSIONS DEBUG ===');
    console.log('Current user permissions:', currentUserPermissions);
    console.log('Banking permission:', currentUserPermissions.viewBanking);
    
    const bankingSection = document.querySelector('.funds-section');
    if (bankingSection) {
        console.log('Banking section element found:', bankingSection);
        console.log('Banking section display style:', bankingSection.style.display);
        console.log('Banking section computed style:', window.getComputedStyle(bankingSection).display);
    } else {
        console.log('Banking section element NOT found');
    }
}

// Debug function to test rank management
function debugRankManagement() {
    console.log('=== RANK MANAGEMENT DEBUG ===');
    console.log('Current data:', currentData);
    console.log('Current user permissions:', currentUserPermissions);
    
    const rankCards = document.querySelectorAll('.rank-card');
    console.log('Found', rankCards.length, 'rank cards');
    
    rankCards.forEach((card, index) => {
        const grade = card.getAttribute('data-grade');
        const checkboxes = card.querySelectorAll('input[type="checkbox"]');
        console.log(`Rank card ${index} (grade ${grade}):`, {
            grade: grade,
            checkboxes: checkboxes.length,
            checked: Array.from(checkboxes).map(cb => cb.checked)
        });
    });
    
    // Test saving permissions
    console.log('Testing save permissions...');
    saveRankPermissions();
}

// Reset save button to normal state
function resetSaveButton() {
    const saveButton = document.querySelector('#rankManagementModal .modal-footer button');
    if (saveButton) {
        saveButton.style.backgroundColor = ''; // Reset to default
        saveButton.textContent = 'Save Changes';
    }
}

// Force refresh permissions - call this function to manually refresh
function forceRefreshPermissions() {
    console.log('=== FORCE REFRESHING PERMISSIONS ===');
    getUserPermissions();
}

// Manual function to test banking tab visibility
function testBankingTab() {
    console.log('=== TESTING BANKING TAB ===');
    const bankingTab = document.querySelector('[data-tab="funds"]');
    if (bankingTab) {
        console.log('Banking tab found:', bankingTab);
        console.log('Current display style:', bankingTab.style.display);
        console.log('Current user permissions:', currentUserPermissions);
        console.log('viewBanking permission:', currentUserPermissions.viewBanking);
        
        // Force show the banking tab for testing
        bankingTab.style.display = 'flex';
        console.log('Banking tab forced to show');
    } else {
        console.log('Banking tab not found');
    }
}

// Manual function to test disciplinary tab visibility
function testDisciplinaryTab() {
    console.log('=== TESTING DISCIPLINARY TAB ===');
    const disciplinaryTab = document.querySelector('[data-tab="employees"]');
    if (disciplinaryTab) {
        console.log('Disciplinary tab found:', disciplinaryTab);
        console.log('Current display style:', disciplinaryTab.style.display);
        console.log('Current user permissions:', currentUserPermissions);
        console.log('viewEmployees permission:', currentUserPermissions.viewEmployees);
        console.log('viewDisciplinary permission:', currentUserPermissions.viewDisciplinary);
        
        // Force show the disciplinary tab for testing
        disciplinaryTab.style.display = 'flex';
        console.log('Disciplinary tab forced to show');
    } else {
        console.log('Disciplinary tab not found');
    }
}

// Force set disciplinary permission for testing
function forceSetDisciplinaryPermission(value) {
    console.log('=== FORCE SETTING DISCIPLINARY PERMISSION ===');
    currentUserPermissions.viewDisciplinary = value;
    console.log('Set viewDisciplinary to:', value);
    console.log('Current permissions:', currentUserPermissions);
    applyPermissionRestrictions();
}


// Add event listeners for rank management
function initializeRankManagement() {
    // Add save button functionality
    const saveButton = document.querySelector('#rankManagementModal .modal-footer button');
    if (saveButton) {
        saveButton.addEventListener('click', saveRankPermissions);
    }
    
    // Add close button functionality
    const closeButton = document.querySelector('#rankManagementModal .close-btn');
    if (closeButton) {
        closeButton.addEventListener('click', closeRankModal);
    }
}

// Update sidebar quick stats
function updateSidebarStats() {
    const onlineCount = currentData.employees.filter(emp => emp.online === true).length;
    const funds = currentData.funds;
    
    // Update quick stats in sidebar
    const quickOnlineCount = document.getElementById('quickOnlineCount');
    const quickFunds = document.getElementById('quickFunds');
    const quickAlerts = document.getElementById('quickAlerts');
    
    if (quickOnlineCount) {
        quickOnlineCount.textContent = onlineCount;
    }
    
    if (quickFunds) {
        const formattedFunds = funds >= 1000 ? `$${(funds / 1000).toFixed(0)}K` : `$${funds}`;
        quickFunds.textContent = formattedFunds;
    }
    
    if (quickAlerts) {
        // Calculate alerts based on various conditions
        let alertCount = 0;
        if (onlineCount === 0) alertCount++;
        if (funds < 10000) alertCount++;
        if (currentData.employees.length < 5) alertCount++;
        quickAlerts.textContent = alertCount;
    }
    
    // Update total weekly hours (sum of all officers' weekly hours)
    if (avgWorkHours) {
        let totalWeeklyMinutes = 0;
        
        // Get weekly hours from allOfficersDutyData if available
        if (typeof allOfficersDutyData !== 'undefined' && allOfficersDutyData.length > 0) {
            allOfficersDutyData.forEach(officer => {
                totalWeeklyMinutes += (officer.weeklyHours?.total_minutes || 0);
            });
        }
        
        const hours = Math.floor(totalWeeklyMinutes / 60);
        const mins = Math.floor(totalWeeklyMinutes % 60);
        avgWorkHours.textContent = `${hours}h ${mins}m`;
    }
}

// Update recruitment stats
function updateRecruitmentStats() {
    const nearbyCitizens = document.getElementById('nearbyCitizens');
    const pendingApplications = document.getElementById('pendingApplications');
    const hiredThisWeekEl = document.getElementById('hiredThisWeek');
    
    if (nearbyCitizens) {
        nearbyCitizens.textContent = currentData.players ? currentData.players.length : 0;
    }
    
    if (pendingApplications) {
        // Placeholder for pending applications
        pendingApplications.textContent = '0';
    }
    
    if (hiredThisWeekEl) {
        hiredThisWeekEl.textContent = hiredThisWeek;
    }
}


// Initialize everything when DOM is ready
function initializeApp() {
    console.log('=== PD BOSS MENU INITIALIZATION START ===');
    console.log('Initialization function called at:', new Date().toISOString());
    
    // Load disciplinary data from localStorage
    loadDisciplinaryData();
    
    // Load transaction history
    console.log('Loading transaction history on app initialization...');
    testLoadTransactions();
    
    // Add a small delay to ensure DOM is fully loaded
    setTimeout(() => {
        console.log('Starting DOM initialization...');
        
        // Initialize DOM elements
        initializeDOMElements();
        
        // Note: Click handlers for settings cards are already in the HTML using onclick attributes
        // No need to add duplicate event listeners here
        
    // Initialize rank management
    initializeRankManagement();
    
    // Start duty tracking timer - update every minute
        setInterval(function() {
            const analyticsTab = document.getElementById('analytics');
            if (analyticsTab && analyticsTab.classList.contains('active')) {
                updateAnalytics();
            }
        }, 60000); // Update every minute
        
        console.log('=== PD BOSS MENU INITIALIZATION COMPLETE ===');
        
        // Load transaction history on initialization
        console.log('Loading transaction history on initialization...');
        testLoadTransactions();
        
        // Also try to load transactions when switching to funds tab
        console.log('Setting up transaction loading for funds tab...');
        const fundsTab = document.querySelector('[data-tab="funds"]');
        if (fundsTab) {
            fundsTab.addEventListener('click', function() {
                console.log('Funds tab clicked, loading transactions...');
                testLoadTransactions();
            });
        }
        
        // Fallback: Set up navigation if it wasn't set up properly
        setTimeout(() => {
            if (!navIcons || navIcons.length === 0) {
                console.log('Retrying navigation setup...');
                navIcons = document.querySelectorAll('.nav-icon');
                if (navIcons && navIcons.length > 0) {
                    console.log('Found', navIcons.length, 'navigation icons on retry');
                    navIcons.forEach(icon => {
                        console.log('Adding click listener to icon with data-tab:', icon.dataset.tab);
                        icon.addEventListener('click', () => switchTab(icon.dataset.tab));
                    });
                }
            }
        }, 500);
    }, 100); // 100ms delay to ensure DOM is ready
}

// Settings card click handlers - Initialize app when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeApp);
} else {
    // DOM is already loaded
    initializeApp();
}


// ==================== DISCIPLINARY ACTIONS FUNCTIONS ====================

// Initialize disciplinary actions when switching to employees tab
function initializeDisciplinaryActions() {
    // Don't reset disciplinary actions - keep existing data
    
    // Set up search functionality
    const officerSearch = document.getElementById('officerSearch');
    if (officerSearch) {
        officerSearch.addEventListener('input', function() {
            // Apply both search and current filter
            filterOfficersByStatus(currentFilter);
        });
    }
    
    // Set up filter buttons
    const filterButtons = document.querySelectorAll('.filter-btn');
    filterButtons.forEach(button => {
        button.addEventListener('click', function() {
            // Remove active class from all buttons
            filterButtons.forEach(btn => btn.classList.remove('active'));
            // Add active class to clicked button
            this.classList.add('active');
            
            currentFilter = this.dataset.filter;
            filterOfficersByStatus(currentFilter);
        });
    });
    
    // Populate officers grid
    updateOfficersGrid();
    
    // Update disciplinary displays for all officers
    if (currentData.employees && currentData.employees.length > 0) {
        currentData.employees.forEach(officer => {
            updateDisciplinaryActionsList(officer.id);
            updateDisciplinaryHistoryList(officer.id);
        });
    }
    
    // Set current date in modal
    const dateInput = document.getElementById('disciplinaryDate');
    if (dateInput) {
        dateInput.value = new Date().toISOString().split('T')[0];
    }
    
    // Set issued by field to current user
    const issuedByInput = document.getElementById('disciplinaryIssuedBy');
    if (issuedByInput && currentData.employees.length > 0) {
        issuedByInput.value = currentData.employees[0].name; // Current user
    }
}

// Add sample disciplinary actions for demonstration
function addSampleDisciplinaryActions() {
    // No sample data - start with clean records
}

// Update officers grid
function updateOfficersGrid() {
    const officersGrid = document.getElementById('officersGrid');
    if (!officersGrid) return;
    
    officersGrid.innerHTML = '';
    
    if (!currentData.employees || currentData.employees.length === 0) {
        officersGrid.innerHTML = '<div class="no-data">No officers found</div>';
        return;
    }
    
    currentData.employees.forEach(employee => {
        const officerCard = document.createElement('div');
        officerCard.className = 'officer-card';
        officerCard.dataset.officerId = employee.id;
        
        const firstLetter = employee.name.charAt(0).toUpperCase();
        const rankLabel = getRankLabel(employee.grade);
        const disciplinaryStatus = getDisciplinaryStatus(employee.id);
        
        officerCard.innerHTML = `
            <div class="officer-avatar">${firstLetter}</div>
            <div class="officer-info">
                <div class="officer-name">${employee.name}</div>
                <div class="officer-rank">${rankLabel}</div>
                <div class="officer-status-badge ${disciplinaryStatus.class}">${disciplinaryStatus.text}</div>
            </div>
        `;
        
        officerCard.addEventListener('click', () => selectOfficer(employee));
        officersGrid.appendChild(officerCard);
    });
}

// Simple function to add a test transaction directly
window.addTestTransactionDirect = function() {
    console.log('=== ADDING TEST TRANSACTION DIRECTLY ===');
    
    const historyContainer = document.getElementById('transactionHistory');
    if (!historyContainer) {
        console.error('History container not found!');
        return;
    }
    
    // Create test transaction
    const transactionEntry = document.createElement('div');
    transactionEntry.className = 'transaction-item';
    transactionEntry.innerHTML = `
        <div class="transaction-info">
            <span class="transaction-type-badge deposit">Deposit</span>
            <div class="transaction-details">
                <div class="transaction-reason">Budget Allocation</div>
                <div class="transaction-officer">Officer: Test Officer</div>
                <div class="transaction-date">${new Date().toLocaleDateString()}</div>
            </div>
        </div>
        <div class="transaction-amount positive">+$1,000.00</div>
    `;
    
    // Add to top of list
    historyContainer.insertBefore(transactionEntry, historyContainer.firstChild);
    console.log('Test transaction added successfully!');
};


// Get disciplinary status for an officer
function getDisciplinaryStatus(officerId) {
    // Match by either officerId or officerCitizenid (server uses citizenid)
    const officerActions = disciplinaryActions.filter(action =>
        action.officerId == officerId || action.officerCitizenid == officerId
    );
    
    if (officerActions.length === 0) {
        return { text: 'Clean Record', class: 'clean' };


    }
    
    // Check for strikes - look for the highest strike number, not just count
    const strikeActions = officerActions.filter(action => action.type.startsWith('strike'));
    const suspensions = officerActions.filter(action => action.type === 'suspension').length;
    const terminations = officerActions.filter(action => action.type === 'termination').length;
    
    if (terminations > 0) {
        return { text: 'Terminated', class: 'terminated' };


    } else if (suspensions > 0) {
        return { text: 'Suspended', class: 'suspended' };


    } else if (strikeActions.length > 0) {
        // Find the highest strike number
        let highestStrike = 0;
        strikeActions.forEach(action => {
            const strikeNumber = parseInt(action.type.replace('strike_', ''));
            if (strikeNumber > highestStrike) {
                highestStrike = strikeNumber;
            }
        });
        
        if (highestStrike >= 3) {
            return { text: 'Strike 3', class: 'strike-3' };


        } else if (highestStrike === 2) {
            return { text: 'Strike 2', class: 'strike-2' };


        } else if (highestStrike === 1) {
            return { text: 'Strike 1', class: 'strike-1' };


        }
    }
    
    // Check for warnings if no strikes
    const warnings = officerActions.filter(action => action.type === 'verbal_warning' || action.type === 'written_warning').length;
    if (warnings > 0) {
        return { text: 'Warnings', class: 'warnings' };


    }
    
    return { text: 'Clean Record', class: 'clean' };


}

// Select an officer
function selectOfficer(officer) {
    selectedOfficer = officer;
    
    // Open the officer disciplinary modal
    openOfficerDisciplinaryModal(officer);
    
    // Highlight selected officer in grid
    document.querySelectorAll('.officer-card').forEach(card => {
        card.classList.remove('selected');
    });
    
    const selectedCard = document.querySelector(`[data-officer-id="${officer.id}"]`);
    if (selectedCard) {
        selectedCard.classList.add('selected');
    }
}

// Open officer disciplinary modal
function openOfficerDisciplinaryModal(officer) {
    const modal = document.getElementById('officerDisciplinaryModal');
    if (!modal) return;
    
    // Update modal with officer info
    document.getElementById('modalOfficerName').textContent = `${officer.name} - Disciplinary Actions`;
    document.getElementById('modalOfficerAvatar').textContent = officer.name.charAt(0).toUpperCase();
    document.getElementById('modalOfficerNameFull').textContent = officer.name;
    document.getElementById('modalOfficerRank').textContent = getRankLabel(officer.grade);
    
    const status = getDisciplinaryStatus(officer.id);
    const modalOfficerStatus = document.getElementById('modalOfficerStatus');
    modalOfficerStatus.textContent = status.text;
    modalOfficerStatus.className = `status-badge ${status.class}`;
    
    // Update disciplinary actions and history
    updateModalDisciplinaryActionsList(officer.id);
    updateModalDisciplinaryHistoryList(officer.id);
    
    // Force refresh the modal content
    
    // Show modal
    modal.classList.remove('hidden');
}

// Close officer disciplinary modal
function closeOfficerDisciplinaryModal() {
    const modal = document.getElementById('officerDisciplinaryModal');
    if (modal) {
        modal.classList.add('hidden');
    }
}

// Update disciplinary actions list for selected officer
function updateDisciplinaryActionsList(officerId) {
    const actionsList = document.getElementById('disciplinaryActionsList');
    if (!actionsList) return;
    
    const officerActions = disciplinaryActions.filter(action => action.officerId == officerId);
    
    if (officerActions.length === 0) {
        actionsList.innerHTML = '<div class="no-data">No disciplinary actions on record</div>';
        return;
    }
    
    // Sort actions by date (newest first)
    officerActions.sort((a, b) => new Date(b.date) - new Date(a.date));
    
    actionsList.innerHTML = '';
    
    officerActions.forEach(action => {
        const actionItem = document.createElement('div');
        actionItem.className = 'disciplinary-action-item';
        
        const actionTypeLabels = {
            'verbal_warning': 'Verbal Warning',
            'written_warning': 'Written Warning',
            'strike_1': 'Strike 1',
            'strike_2': 'Strike 2',
            'strike_3': 'Strike 3',
            'suspension': 'Suspension',
            'termination': 'Termination'
        };


        
        actionItem.innerHTML = `
            <div class="action-header">
                <div class="action-type ${action.type}">${actionTypeLabels[action.type] || action.type}</div>
                <div class="action-date">${new Date(action.date).toLocaleDateString()}</div>
                <button class="btn-remove-action" onclick="event.stopPropagation(); removeDisciplinaryAction('${action.id}')" title="Remove Action">×</button>
            </div>
            <div class="action-reason">${action.reason}</div>
            <div class="action-details">
                <span class="action-issued-by">Issued by: ${action.issuedBy}</span>
            </div>
        `;
        
        actionsList.appendChild(actionItem);
    });
}

// Simple function to add a test transaction directly
window.addTestTransactionDirect = function() {
    console.log('=== ADDING TEST TRANSACTION DIRECTLY ===');
    
    const historyContainer = document.getElementById('transactionHistory');
    if (!historyContainer) {
        console.error('History container not found!');
        return;
    }
    
    // Create test transaction
    const transactionEntry = document.createElement('div');
    transactionEntry.className = 'transaction-item';
    transactionEntry.innerHTML = `
        <div class="transaction-info">
            <span class="transaction-type-badge deposit">Deposit</span>
            <div class="transaction-details">
                <div class="transaction-reason">Budget Allocation</div>
                <div class="transaction-officer">Officer: Test Officer</div>
                <div class="transaction-date">${new Date().toLocaleDateString()}</div>
            </div>
        </div>
        <div class="transaction-amount positive">+$1,000.00</div>
    `;
    
    // Add to top of list
    historyContainer.insertBefore(transactionEntry, historyContainer.firstChild);
    console.log('Test transaction added successfully!');
};


// Filter officers by search term
function filterOfficers(searchTerm) {
    const officerCards = document.querySelectorAll('.officer-card');
    
    officerCards.forEach(card => {
        const officerName = card.querySelector('.officer-name').textContent.toLowerCase();
        if (searchTerm === '' || officerName.includes(searchTerm.toLowerCase())) {
            card.style.display = 'flex';
        } else {
            card.style.display = 'none';
        }
    });
}

// Simple function to add a test transaction directly
window.addTestTransactionDirect = function() {
    console.log('=== ADDING TEST TRANSACTION DIRECTLY ===');
    
    const historyContainer = document.getElementById('transactionHistory');
    if (!historyContainer) {
        console.error('History container not found!');
        return;
    }
    
    // Create test transaction
    const transactionEntry = document.createElement('div');
    transactionEntry.className = 'transaction-item';
    transactionEntry.innerHTML = `
        <div class="transaction-info">
            <span class="transaction-type-badge deposit">Deposit</span>
            <div class="transaction-details">
                <div class="transaction-reason">Budget Allocation</div>
                <div class="transaction-officer">Officer: Test Officer</div>
                <div class="transaction-date">${new Date().toLocaleDateString()}</div>
            </div>
        </div>
        <div class="transaction-amount positive">+$1,000.00</div>
    `;
    
    // Add to top of list
    historyContainer.insertBefore(transactionEntry, historyContainer.firstChild);
    console.log('Test transaction added successfully!');
};


// Filter officers by status
function filterOfficersByStatus(filter) {
    const officerCards = document.querySelectorAll('.officer-card');
    const searchTerm = document.getElementById('officerSearch').value.toLowerCase();
    
    officerCards.forEach(card => {
        const officerId = card.dataset.officerId;
        const status = getDisciplinaryStatus(officerId);
        const officerName = card.querySelector('.officer-name').textContent.toLowerCase();
        
        let shouldShow = false;
        
        // Check status filter
        switch (filter) {
            case 'all':
                shouldShow = true;
                break;
            case 'clean':
                shouldShow = status.class === 'clean';
                break;
            case 'strikes':
                shouldShow = status.class.startsWith('strike') || status.class === 'warnings';
                break;
            case 'suspended':
                shouldShow = status.class === 'suspended' || status.class === 'terminated';
                break;
        }
        
        // Also check search term
        if (shouldShow && searchTerm !== '') {
            shouldShow = officerName.includes(searchTerm);
        }
        
        card.style.display = shouldShow ? 'flex' : 'none';
    });
    
    console.log(`Filtered by ${filter}: ${document.querySelectorAll('.officer-card[style*="flex"]').length} officers shown`);
}

// Open add disciplinary action modal
function openAddDisciplinaryModal() {
    const modal = document.getElementById('addDisciplinaryModal');
    if (!modal) return;
    
    // Set officer select to current officer only
    const officerSelect = document.getElementById('disciplinaryOfficerSelect');
    if (officerSelect && selectedOfficer) {
        // Clear existing options
        officerSelect.innerHTML = '';
        
        // Add only the selected officer
        const option = document.createElement('option');
        option.value = selectedOfficer.id;
        option.textContent = selectedOfficer.name;
        option.selected = true;
        officerSelect.appendChild(option);
        
        // Make the dropdown read-only
        officerSelect.disabled = true;
        officerSelect.style.background = 'rgba(30, 41, 59, 0.4)';
        officerSelect.style.color = 'rgba(255, 255, 255, 0.7)';
        officerSelect.style.cursor = 'not-allowed';
    }
    
    // Clear form
    document.getElementById('disciplinaryReason').value = '';
    
    modal.classList.remove('hidden');
}

// Close add disciplinary action modal
function closeAddDisciplinaryModal() {
    console.log('=== CLOSING MODAL ===');
    try {
        const modal = document.getElementById('addDisciplinaryModal');
        if (modal) {
            console.log('Modal found, adding hidden class');
            modal.classList.add('hidden');
        } else {
            console.log('Modal not found');
        }
        
        // Reset officer select dropdown
        const officerSelect = document.getElementById('disciplinaryOfficerSelect');
        if (officerSelect) {
            console.log('Resetting officer select');
            officerSelect.disabled = false;
            officerSelect.style.background = '';
            officerSelect.style.color = '';
            officerSelect.style.cursor = '';
        }
        console.log('=== MODAL CLOSED ===');
    } catch (error) {
        console.error('Error closing modal:', error);
    }
}

// Save disciplinary action
function saveDisciplinaryAction() {
    try {
        const officerSelect = document.getElementById('disciplinaryOfficerSelect');
        const officerId = officerSelect.value;
        const type = document.getElementById('disciplinaryType').value;
        const reason = document.getElementById('disciplinaryReason').value;
        const issuedBy = document.getElementById('disciplinaryIssuedBy').value;
        const date = document.getElementById('disciplinaryDate').value;

        // Validate all fields
        if (!officerId || !type || !reason || !issuedBy || !date) {
            console.log('Missing required fields for disciplinary action');
            return;
        }

        // Get officer name from the select dropdown
        const officerName = officerSelect.options[officerSelect.selectedIndex]?.text || 'Unknown';

        console.log('Saving disciplinary action to server:', {
            officerId, officerName, type, reason
        });

        // Send to server for persistent storage
        fetch('https://pd_boss_menu/addDisciplinaryAction', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                officerCitizenid: officerId,
                officerName: officerName,
                actionType: type,
                description: reason
            })
        }).then(() => {
            console.log('Disciplinary action sent to server');
            // Server will send back updated list via receiveDisciplinaryActions
        }).catch(err => {
            console.error('Error saving disciplinary action:', err);
        });

        // Optimistic UI update - add locally while waiting for server
        const newAction = {
            id: Date.now().toString(),
            officerId: officerId,
            officerCitizenid: officerId,
            officerName: officerName,
            type: type,
            description: reason,
            issuedBy: issuedBy,
            date: date,
            timestamp: new Date().toISOString()
        };
        disciplinaryActions.push(newAction);

        // Wait for array to be updated before checking status
        setTimeout(() => {
            // Update the modal content to show the new action
            updateModalDisciplinaryActionsList(officerId);
            updateModalDisciplinaryHistoryList(officerId);

            // Update officer status badge in modal
            const modalOfficerStatus = document.getElementById('modalOfficerStatus');
            if (modalOfficerStatus) {
                const status = getDisciplinaryStatus(officerId);
                modalOfficerStatus.textContent = status.text;
                modalOfficerStatus.className = `status-badge ${status.class}`;
            }

            // Also update the officer's status in the main officers grid
            const officerCard = document.querySelector(`[data-officer-id="${officerId}"]`);
            if (officerCard) {
                const officerStatusBadge = officerCard.querySelector('.officer-status-badge');
                if (officerStatusBadge) {
                    const status = getDisciplinaryStatus(officerId);
                    officerStatusBadge.textContent = status.text;
                    officerStatusBadge.className = `officer-status-badge ${status.class}`;
                }
            }
        }, 100);
        
        // Clear the form
        document.getElementById('disciplinaryReason').value = '';
        document.getElementById('disciplinaryType').value = 'verbal_warning';
        
        // Update officers grid to show new status
        updateOfficersGrid();
        
        // Close the add disciplinary action modal
        closeAddDisciplinaryModal();
    } catch (error) {
        console.error('Error saving disciplinary action:', error);
    }
}

// Remove disciplinary action
function removeDisciplinaryAction(actionId) {
    try {
        console.log('Removing disciplinary action:', actionId);

        // Send to server for permanent removal
        fetch('https://pd_boss_menu/removeDisciplinaryAction', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ actionId: actionId })
        }).then(() => {
            console.log('Disciplinary action removal sent to server');
            // Server will send back updated list via receiveDisciplinaryActions
        }).catch(err => {
            console.error('Error removing disciplinary action from server:', err);
        });

        // Optimistic UI update - remove locally while waiting for server
        const actionToMove = disciplinaryActions.find(action => action.id === actionId || action.id == actionId);

        if (actionToMove) {
            // Move to history before removing
            moveToHistory(actionToMove);
        }

        // Remove from active actions (handle both string and number IDs)
        disciplinaryActions = disciplinaryActions.filter(action => action.id !== actionId && action.id != actionId);

        // Update display
        if (selectedOfficer) {
            const officerId = selectedOfficer.citizenid || selectedOfficer.id;
            updateDisciplinaryActionsList(officerId);
            updateDisciplinaryHistoryList(officerId);
            updateModalDisciplinaryActionsList(officerId);
            updateModalDisciplinaryHistoryList(officerId);
        }

        // Update officers grid
        updateOfficersGrid();
    } catch (error) {
        console.error('Error removing disciplinary action:', error);
    }
}

// Move action to history
function moveToHistory(action) {
    const historyEntry = {
        ...action,
        deletedAt: new Date().toISOString(),
        deletedBy: 'System', // Using fallback since currentUser is not defined
        status: 'deleted'
    };


    
    disciplinaryHistory.push(historyEntry);
    
    // Save to localStorage
    saveDisciplinaryData();
}

// Save disciplinary data - now handled by server, this is a no-op for backwards compatibility
function saveDisciplinaryData() {
    // Server handles all persistence now
    console.log('Disciplinary data is now saved on server');
}

// Load disciplinary data from server
function loadDisciplinaryData() {
    console.log('Requesting disciplinary data from server...');
    // Request data from server via NUI callback
    fetch('https://pd_boss_menu/getDisciplinaryActions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).catch(err => {
        console.error('Error requesting disciplinary data:', err);
    });
}

// Process disciplinary actions received from server
function processDisciplinaryActionsFromServer(serverActions) {
    console.log('Processing', serverActions.length, 'disciplinary actions from server');

    // Clear existing arrays
    disciplinaryActions = [];
    disciplinaryHistory = [];

    // Convert server format to local format
    serverActions.forEach(action => {
        const localAction = {
            id: action.id,
            officerId: action.officer_citizenid, // Use citizenid as officerId for consistency
            officerCitizenid: action.officer_citizenid,
            officerName: action.officer_name,
            type: action.action_type,
            description: action.description,
            issuedBy: action.issued_by,
            date: new Date(action.timestamp).toLocaleDateString(),
            timestamp: action.timestamp
        };

        if (action.active === 1 || action.active === true) {
            disciplinaryActions.push(localAction);
        } else {
            // Inactive actions go to history
            localAction.status = 'removed';
            disciplinaryHistory.push(localAction);
        }
    });

    console.log('Active actions:', disciplinaryActions.length, 'Historical:', disciplinaryHistory.length);

    // Update the UI if on disciplinary tab
    if (selectedOfficer) {
        updateDisciplinaryActionsList(selectedOfficer.citizenid || selectedOfficer.id);
        updateDisciplinaryHistoryList(selectedOfficer.citizenid || selectedOfficer.id);
    }

    // Update officers grid to show correct status badges
    updateOfficersGrid();
}


// Switch disciplinary tab
function switchDisciplinaryTab(tabName) {
    // Remove active class from all tab buttons
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    
    // Hide all tab content
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    
    // Activate selected tab button
    const activeTabBtn = document.querySelector(`[data-tab="${tabName}"]`);
    if (activeTabBtn) {
        activeTabBtn.classList.add('active');
    }
    
    // Show selected tab content
    const activeTabContent = document.getElementById(tabName + 'Tab');
    if (activeTabContent) {
        activeTabContent.classList.add('active');
    }
    
    // Update content based on selected tab
    if (selectedOfficer) {
        if (tabName === 'actions') {
            updateDisciplinaryActionsList(selectedOfficer.id);
        } else if (tabName === 'history') {
            updateDisciplinaryHistoryList(selectedOfficer.id);
        }
    }
}

// Update disciplinary history list
function updateDisciplinaryHistoryList(officerId) {
    const historyList = document.getElementById('modalDisciplinaryHistoryList');
    if (!historyList) return;
    
    // Get both active and historical actions
    const activeActions = disciplinaryActions.filter(action => action.officerId == officerId);
    const historicalActions = disciplinaryHistory.filter(action => action.officerId == officerId);
    const allActions = [...activeActions, ...historicalActions];
    
    if (allActions.length === 0) {
        historyList.innerHTML = '<div class="no-data">No disciplinary history on record</div>';
        return;
    }
    
    // Sort actions by date (newest first)
    allActions.sort((a, b) => new Date(b.date) - new Date(a.date));
    
    historyList.innerHTML = '';
    
    allActions.forEach(action => {
        const historyItem = document.createElement('div');
        historyItem.className = 'disciplinary-history-item';
        
        const actionTypeLabels = {
            'verbal_warning': 'Verbal Warning',
            'written_warning': 'Written Warning',
            'strike_1': 'Strike 1',
            'strike_2': 'Strike 2',
            'strike_3': 'Strike 3',
            'suspension': 'Suspension',
            'termination': 'Termination'
        };


        
        historyItem.innerHTML = `
            <div class="history-item-header">
                <div class="history-action-type ${action.type}">${actionTypeLabels[action.type] || action.type}</div>
                <div class="history-date">${new Date(action.date).toLocaleDateString()}</div>
            </div>
            <div class="history-reason">${action.reason}</div>
            <div class="history-details">
                <span class="history-issued-by">Issued by: ${action.issuedBy}</span>
                <span class="history-time">${new Date(action.timestamp).toLocaleString()}</span>
            </div>
        `;
        
        historyList.appendChild(historyItem);
    });
}

// Simple function to add a test transaction directly
window.addTestTransactionDirect = function() {
    console.log('=== ADDING TEST TRANSACTION DIRECTLY ===');
    
    const historyContainer = document.getElementById('transactionHistory');
    if (!historyContainer) {
        console.error('History container not found!');
        return;
    }
    
    // Create test transaction
    const transactionEntry = document.createElement('div');
    transactionEntry.className = 'transaction-item';
    transactionEntry.innerHTML = `
        <div class="transaction-info">
            <span class="transaction-type-badge deposit">Deposit</span>
            <div class="transaction-details">
                <div class="transaction-reason">Budget Allocation</div>
                <div class="transaction-officer">Officer: Test Officer</div>
                <div class="transaction-date">${new Date().toLocaleDateString()}</div>
            </div>
        </div>
        <div class="transaction-amount positive">+$1,000.00</div>
    `;
    
    // Add to top of list
    historyContainer.insertBefore(transactionEntry, historyContainer.firstChild);
    console.log('Test transaction added successfully!');
};


// Switch modal disciplinary tab
function switchModalDisciplinaryTab(tabName) {
    try {
        // Remove active class from all modal tab buttons
        document.querySelectorAll('.modal-tab-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        
        // Hide all modal tab content
        document.querySelectorAll('.modal-tab-content').forEach(content => {
            content.classList.remove('active');
        });
        
        // Activate selected modal tab button
        const activeTabBtn = document.querySelector(`.modal-tab-btn[data-tab="${tabName}"]`);
        if (activeTabBtn) {
            activeTabBtn.classList.add('active');
        }
        
        // Show selected modal tab content
        const activeTabContent = document.getElementById('modal' + tabName.charAt(0).toUpperCase() + tabName.slice(1) + 'Tab');
        if (activeTabContent) {
            activeTabContent.classList.add('active');
        }
        
        // Refresh data when switching to history tab
        if (tabName === 'history' && selectedOfficer) {
            updateModalDisciplinaryHistoryList(selectedOfficer.id);
        }
    } catch (error) {
        console.error('Error switching modal tab:', error);
    }
}

// Update modal disciplinary actions list
function updateModalDisciplinaryActionsList(officerId) {
    try {
        const actionsList = document.getElementById('modalDisciplinaryActionsList');
        if (!actionsList) {
            return;
        }
        
        const officerActions = disciplinaryActions.filter(action => action.officerId == officerId);
        
        
        if (officerActions.length === 0) {
            actionsList.innerHTML = '<div class="no-data">No disciplinary actions on record</div>';
            return;
        }
        
        // Sort actions by date (newest first)
        officerActions.sort((a, b) => new Date(b.date) - new Date(a.date));
        
        actionsList.innerHTML = '';
        
        officerActions.forEach(action => {
            const actionItem = document.createElement('div');
            actionItem.className = 'disciplinary-action-item';
            
            const actionTypeLabels = {
                'verbal_warning': 'Verbal Warning',
                'written_warning': 'Written Warning',
                'strike_1': 'Strike 1',
                'strike_2': 'Strike 2',
                'strike_3': 'Strike 3',
                'suspension': 'Suspension',
                'termination': 'Termination'
            };


            
            actionItem.innerHTML = `
                <div class="action-header">
                    <div class="action-type ${action.type}">${actionTypeLabels[action.type] || action.type}</div>
                    <div class="action-date">${new Date(action.date).toLocaleDateString()}</div>
                    <button class="btn-remove-action" onclick="event.stopPropagation(); removeDisciplinaryAction('${action.id}')" title="Remove Action">×</button>
                </div>
                <div class="action-reason">${action.reason}</div>
                <div class="action-details">
                    <span class="action-issued-by">Issued by: ${action.issuedBy}</span>
                </div>
            `;
            
            actionsList.appendChild(actionItem);
        });
        
    } catch (error) {
        console.error('Error updating modal actions list:', error);
    }
}

// Update modal disciplinary history list
function updateModalDisciplinaryHistoryList(officerId) {
    const historyList = document.getElementById('modalDisciplinaryHistoryList');
    if (!historyList) return;
    
    // Get both active and historical actions
    const activeActions = disciplinaryActions.filter(action => action.officerId == officerId);
    const historicalActions = disciplinaryHistory.filter(action => action.officerId == officerId);
    const allActions = [...activeActions, ...historicalActions];
    
    if (allActions.length === 0) {
        historyList.innerHTML = '<div class="no-data">No disciplinary history on record</div>';
        return;
    }
    
    // Sort actions by date (newest first)
    allActions.sort((a, b) => new Date(b.date) - new Date(a.date));
    
    historyList.innerHTML = '';
    
    allActions.forEach(action => {
        const historyItem = document.createElement('div');
        historyItem.className = 'disciplinary-history-item';
        
        const actionTypeLabels = {
            'verbal_warning': 'Verbal Warning',
            'written_warning': 'Written Warning',
            'strike_1': 'Strike 1',
            'strike_2': 'Strike 2',
            'strike_3': 'Strike 3',
            'suspension': 'Suspension',
            'termination': 'Termination'
        };


        
        historyItem.innerHTML = `
            <div class="history-item-header">
                <div class="history-action-type ${action.type}">${actionTypeLabels[action.type] || action.type}</div>
                <div class="history-date">${new Date(action.date).toLocaleDateString()}</div>
            </div>
            <div class="history-reason">${action.reason}</div>
            <div class="history-details">
                <span class="history-issued-by">Issued by: ${action.issuedBy}</span>
                <span class="history-time">${new Date(action.timestamp).toLocaleString()}</span>
            </div>
        `;
        
        historyList.appendChild(historyItem);
    });
}

// Simple function to add a test transaction directly
window.addTestTransactionDirect = function() {
    console.log('=== ADDING TEST TRANSACTION DIRECTLY ===');
    
    const historyContainer = document.getElementById('transactionHistory');
    if (!historyContainer) {
        console.error('History container not found!');
        return;
    }
    
    // Create test transaction
    const transactionEntry = document.createElement('div');
    transactionEntry.className = 'transaction-item';
    transactionEntry.innerHTML = `
        <div class="transaction-info">
            <span class="transaction-type-badge deposit">Deposit</span>
            <div class="transaction-details">
                <div class="transaction-reason">Budget Allocation</div>
                <div class="transaction-officer">Officer: Test Officer</div>
                <div class="transaction-date">${new Date().toLocaleDateString()}</div>
            </div>
        </div>
        <div class="transaction-amount positive">+$1,000.00</div>
    `;
    
    // Add to top of list
    historyContainer.insertBefore(transactionEntry, historyContainer.firstChild);
    console.log('Test transaction added successfully!');
};


// ========================================
// BONUS PAYMENT MODAL FUNCTIONS
// ========================================

let currentBonusEmployee = null;

function openBonusModal(employeeIdOrCitizenId) {
    console.log('Opening bonus modal for:', employeeIdOrCitizenId);

    // Find the employee data by id or citizenid
    let employee = null;
    if (typeof employeeIdOrCitizenId === 'string') {
        employee = currentData.employees.find(emp => emp.citizenid === employeeIdOrCitizenId);
    } else {
        employee = currentData.employees.find(emp => emp.id == employeeIdOrCitizenId);
    }

    if (!employee) {
        console.error('Employee not found for bonus:', employeeIdOrCitizenId);
        if (typeof Animations !== 'undefined' && Animations.showToast) {
            Animations.showToast({
                title: 'Error',
                message: 'Employee not found',
                type: 'error'
            });
        }
        return;
    }

    currentBonusEmployee = employee;

    // Check if bonus modal exists, if not create it
    let bonusModal = document.getElementById('bonusPaymentModal');
    if (!bonusModal) {
        createBonusModal();
        bonusModal = document.getElementById('bonusPaymentModal');
    }

    // Populate modal
    const statusIndicator = employee.online === true ? '🟢' : '❌';
    document.getElementById('bonusEmployeeName').textContent = statusIndicator + ' ' + employee.name;

    // Find rank label
    let rankLabel = employee.rank;
    for (const rank of currentData.ranks) {
        if (rank.grade === employee.grade) {
            rankLabel = rank.label;
            break;
        }
    }
    document.getElementById('bonusEmployeeRank').textContent = rankLabel;

    // Clear input fields
    document.getElementById('bonusAmount').value = '';
    document.getElementById('bonusReason').value = '';

    // Show modal
    bonusModal.classList.remove('hidden');
}

function createBonusModal() {
    const modalHTML = '<div id="bonusPaymentModal" class="modal hidden">' +
        '<div class="modal-content" style="max-width: 400px;">' +
            '<div class="modal-header">' +
                '<h3>💰 Pay Bonus</h3>' +
                '<button class="close-btn" onclick="closeBonusModal()">&times;</button>' +
            '</div>' +
            '<div class="modal-body">' +
                '<div class="bonus-employee-info" style="text-align: center; margin-bottom: 20px;">' +
                    '<div id="bonusEmployeeName" style="font-size: 18px; font-weight: bold;"></div>' +
                    '<div id="bonusEmployeeRank" style="color: #888; font-size: 14px;"></div>' +
                '</div>' +
                '<div class="form-group">' +
                    '<label for="bonusAmount">Bonus Amount ($)</label>' +
                    '<input type="number" id="bonusAmount" placeholder="Enter amount..." min="1" step="1" style="width: 100%; padding: 10px; border-radius: 6px; border: 1px solid #333; background: #1a1a2e; color: white;">' +
                '</div>' +
                '<div class="form-group" style="margin-top: 15px;">' +
                    '<label for="bonusReason">Reason</label>' +
                    '<input type="text" id="bonusReason" placeholder="Performance bonus, recognition, etc..." style="width: 100%; padding: 10px; border-radius: 6px; border: 1px solid #333; background: #1a1a2e; color: white;">' +
                '</div>' +
                '<div class="bonus-quick-amounts" style="display: flex; gap: 8px; margin-top: 15px; flex-wrap: wrap;">' +
                    '<button class="btn btn-secondary" onclick="setQuickBonusAmount(100)" style="flex: 1;">$100</button>' +
                    '<button class="btn btn-secondary" onclick="setQuickBonusAmount(500)" style="flex: 1;">$500</button>' +
                    '<button class="btn btn-secondary" onclick="setQuickBonusAmount(1000)" style="flex: 1;">$1,000</button>' +
                    '<button class="btn btn-secondary" onclick="setQuickBonusAmount(5000)" style="flex: 1;">$5,000</button>' +
                '</div>' +
            '</div>' +
            '<div class="modal-footer" style="display: flex; gap: 10px; justify-content: flex-end;">' +
                '<button class="btn btn-secondary" onclick="closeBonusModal()">Cancel</button>' +
                '<button class="btn btn-success" onclick="submitBonusPayment()">💰 Pay Bonus</button>' +
            '</div>' +
        '</div>' +
    '</div>';

    document.body.insertAdjacentHTML('beforeend', modalHTML);
}

function closeBonusModal() {
    const bonusModal = document.getElementById('bonusPaymentModal');
    if (bonusModal) {
        bonusModal.classList.add('hidden');
    }
    currentBonusEmployee = null;
}

function setQuickBonusAmount(amount) {
    document.getElementById('bonusAmount').value = amount;
}

function submitBonusPayment() {
    if (!currentBonusEmployee) {
        console.error('No employee selected for bonus');
        return;
    }

    const amount = parseInt(document.getElementById('bonusAmount').value);
    const reason = document.getElementById('bonusReason').value || 'Performance bonus';

    if (!amount || amount <= 0) {
        if (typeof Animations !== 'undefined' && Animations.showToast) {
            Animations.showToast({
                title: 'Invalid Amount',
                message: 'Please enter a valid bonus amount',
                type: 'error'
            });
        }
        return;
    }

    console.log('Submitting bonus payment:', {
        citizenid: currentBonusEmployee.citizenid,
        playerId: currentBonusEmployee.id,
        amount: amount,
        reason: reason
    });

    // Send bonus payment request to server
    fetch('https://pd_boss_menu/payBonus', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            citizenid: currentBonusEmployee.citizenid,
            playerId: currentBonusEmployee.id,
            amount: amount,
            reason: reason
        })
    })
    .then(function(response) {
        console.log('Bonus payment request sent');
        if (typeof Animations !== 'undefined' && Animations.showToast) {
            Animations.showToast({
                title: 'Bonus Sent',
                message: '$' + amount.toLocaleString() + ' bonus sent to ' + currentBonusEmployee.name,
                type: 'success'
            });
        }
        closeBonusModal();
        setTimeout(function() { refreshData(); }, 500);
    })
    .catch(function(error) {
        console.error('Error sending bonus payment:', error);
        if (typeof Animations !== 'undefined' && Animations.showToast) {
            Animations.showToast({
                title: 'Error',
                message: 'Failed to send bonus payment',
                type: 'error'
            });
        }
    });
}

// Make bonus functions globally accessible
window.openBonusModal = openBonusModal;
window.closeBonusModal = closeBonusModal;
window.setQuickBonusAmount = setQuickBonusAmount;
window.submitBonusPayment = submitBonusPayment;

console.log('=== BONUS PAYMENT SYSTEM LOADED ===');

// ========================================
// DEPARTMENT THEME SYSTEM
// ========================================

function applyDepartmentTheme(department) {
    console.log('Applying department theme:', department);

    // Use correct container ID and also target dashboard-wrapper
    const container = document.getElementById('container');
    const dashboardWrapper = document.querySelector('.dashboard-wrapper');

    if (!container) {
        console.warn('Theme: Could not find #container element');
        return;
    }

    // All available department themes - add new ones here
    const allThemes = ['theme-lspd', 'theme-lscso', 'theme-sasp', 'theme-bcso', 'theme-safr', 'theme-police'];

    // Remove existing department themes from all relevant elements
    container.classList.remove(...allThemes);
    document.body.classList.remove(...allThemes);
    if (dashboardWrapper) {
        dashboardWrapper.classList.remove(...allThemes);
    }

    // Department configuration - add new departments here
    const deptConfig = {
        'lscso': {
            theme: 'theme-lscso',
            shortName: 'LSCSO',
            fullName: 'Los Santos County Sheriff\'s Office',
            type: 'sheriff',
            icon: 'fa-shield-alt'
        },
        'sasp': {
            theme: 'theme-sasp',
            shortName: 'SASP',
            fullName: 'San Andreas State Police',
            type: 'state',
            icon: 'fa-star'
        },
        'bcso': {
            theme: 'theme-bcso',
            shortName: 'BCSO',
            fullName: 'Blaine County Sheriff\'s Office',
            type: 'sheriff',
            icon: 'fa-shield-alt'
        },
        'safr': {
            theme: 'theme-safr',
            shortName: 'SAFR',
            fullName: 'San Andreas Fire Rescue',
            type: 'ems',
            icon: 'fa-ambulance'
        },
        'police': {
            theme: 'theme-lspd',
            shortName: 'LSPD',
            fullName: 'Los Santos Police Department',
            type: 'police',
            icon: 'fa-shield'
        }
    };

    // Get config for department (default to police/LSPD)
    const dept = department.toLowerCase();
    const config = deptConfig[dept] || deptConfig['police'];

    // Apply theme class to elements
    container.classList.add(config.theme);
    document.body.classList.add(config.theme);
    if (dashboardWrapper) dashboardWrapper.classList.add(config.theme);

    // Update header with department info
    updateDepartmentHeader(config.shortName, config.fullName, config.type, config.icon);
    console.log(`Theme applied: ${config.shortName} (${config.type})`);
}

function updateDepartmentHeader(shortName, fullName, type, icon) {
    // Update header title if it exists (uses .header-center h1 in HTML)
    const headerTitle = document.querySelector('.header-center h1');
    if (headerTitle) {
        headerTitle.textContent = shortName + ' Management';
    }

    // Update subtitle (uses .header-center p in HTML, preserve employee count span)
    const headerSubtitle = document.querySelector('.header-center p');
    if (headerSubtitle) {
        const employeeCount = document.getElementById('totalEmployees');
        const count = employeeCount ? employeeCount.textContent : '0';
        headerSubtitle.innerHTML = fullName + ' - Managing <span id="totalEmployees">' + count + '</span> employees';
    }

    // Note: Logo uses SVG in HTML, not FontAwesome icon - no change needed
}

// Apply theme on menu open
window.applyDepartmentTheme = applyDepartmentTheme;

console.log('=== DEPARTMENT THEME SYSTEM LOADED ===');

/* ========================================
   Character Search System
   ======================================== */

// Initialize character search event listeners
document.addEventListener('DOMContentLoaded', function() {
    const searchBtn = document.getElementById('characterSearchBtn');
    const searchInput = document.getElementById('characterSearchInput');

    if (searchBtn) {
        searchBtn.addEventListener('click', searchCharacters);
    }

    if (searchInput) {
        searchInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                searchCharacters();
            }
        });
    }
});

// Search for characters
function searchCharacters() {
    const searchInput = document.getElementById('characterSearchInput');
    const resultsContainer = document.getElementById('characterSearchResults');

    if (!searchInput || !resultsContainer) return;

    const query = searchInput.value.trim();
    if (query.length < 2) {
        resultsContainer.innerHTML = '<p class="search-hint">Please enter at least 2 characters</p>';
        return;
    }

    // Show loading state
    resultsContainer.innerHTML = '<p class="search-loading">Searching for characters...</p>';

    // Send search request to server
    fetch('https://pd_boss_menu/searchCharacters', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ query: query })
    }).catch(err => {
        console.error('Search error:', err);
        resultsContainer.innerHTML = '<p class="no-results">Error searching. Please try again.</p>';
    });
}

// Display search results
function displaySearchResults(characters) {
    const resultsContainer = document.getElementById('characterSearchResults');
    if (!resultsContainer) return;

    if (!characters || characters.length === 0) {
        resultsContainer.innerHTML = '<p class="no-results">No characters found matching your search</p>';
        return;
    }

    // Build rank options HTML based on current department
    const ranks = currentData.ranks || [
        { name: 'cadet', label: 'Cadet' },
        { name: 'probationary officer', label: 'Probationary Officer' },
        { name: 'officer', label: 'Officer' }
    ];

    let html = '';
    characters.forEach(char => {
        const initial = char.firstname.charAt(0).toUpperCase();
        const statusClass = char.isOnline ? '' : 'offline';
        const isLeo = char.isAlreadyLEO;

        html += `
            <div class="search-result-item ${isLeo ? 'already-leo' : ''}">
                <div class="search-result-info">
                    <div class="search-result-avatar">${initial}</div>
                    <div class="search-result-details">
                        <span class="search-result-name">${char.fullname}</span>
                        <span class="search-result-job">${char.jobLabel || char.jobName} ${char.jobGrade ? '(' + char.jobGrade + ')' : ''}</span>
                    </div>
                    <span class="search-result-status ${statusClass} ${isLeo ? 'leo' : ''}">
                        ${isLeo ? 'Already LEO' : (char.isOnline ? 'Online' : 'Offline')}
                    </span>
                </div>
                <div class="search-result-actions">
                    ${isLeo ? '<span style="color: var(--accent-warning); font-size: 12px;">Already employed</span>' : `
                    <select id="hire-rank-search-${char.citizenid}">
                        ${ranks.map(r => `<option value="${r.name}">${r.label}</option>`).join('')}
                    </select>
                    <button class="btn-hire-small" onclick="hireCharacterFromSearch('${char.citizenid}')">
                        Hire
                    </button>
                    `}
                </div>
            </div>
        `;
    });

    resultsContainer.innerHTML = html;
}

// Hire a character from search results
function hireCharacterFromSearch(citizenid) {
    const rankSelect = document.getElementById(`hire-rank-search-${citizenid}`);
    if (!rankSelect) {
        console.error('Rank select not found for citizenid:', citizenid);
        return;
    }

    const rank = rankSelect.value;

    console.log('Hiring character from search:', citizenid, 'with rank:', rank);

    // Send hire request to server
    fetch('https://pd_boss_menu/hireCharacter', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ citizenid: citizenid, rank: rank })
    }).then(() => {
        // Show success animation
        if (window.Animations) {
            Animations.celebrate({
                title: 'New Officer Hired!',
                message: `Successfully hired as ${rank}`,
                confetti: true
            });
        }

        // Clear search and refresh
        const searchInput = document.getElementById('characterSearchInput');
        if (searchInput) searchInput.value = '';

        const resultsContainer = document.getElementById('characterSearchResults');
        if (resultsContainer) {
            resultsContainer.innerHTML = '<p class="search-hint">Type a name and click search to find characters</p>';
        }

        // Increment hired this week counter
        hiredThisWeek++;
        updateRecruitmentStats();
    }).catch(err => {
        console.error('Hire error:', err);
        if (window.Animations) {
            Animations.showToast({
                title: 'Error',
                message: 'Failed to hire character',
                type: 'error'
            });
        }
    });
}

// Expose functions globally
window.searchCharacters = searchCharacters;
window.displaySearchResults = displaySearchResults;
window.hireCharacterFromSearch = hireCharacterFromSearch;

console.log('=== CHARACTER SEARCH SYSTEM LOADED ===');

/* ========================================
   Theme Customization System
   ======================================== */

// Theme Configuration
const THEME_STORAGE_KEY = 'pd_boss_menu_theme';
const DEFAULT_THEME = {
    primaryColor: '#5078F2',
    secondaryColor: '#6366F1',
    primaryBg: '#1a1a2e',
    secondaryBg: '#16213e',
    tertiaryBg: '#0f0f23',
    sidebarBg: '#0f172a'
};

// Load saved theme on page load
function loadSavedTheme() {
    try {
        const saved = localStorage.getItem(THEME_STORAGE_KEY);
        if (saved) {
            const theme = JSON.parse(saved);
            console.log('Loading saved theme:', theme);
            applyTheme(theme);
        } else {
            console.log('No saved theme, applying default theme');
            applyTheme(DEFAULT_THEME);
        }
    } catch (error) {
        console.error('Failed to load theme:', error);
        console.log('Applying default theme due to error');
        applyTheme(DEFAULT_THEME);
    }
}

// Helper: Convert hex to RGB
function hexToRgb(hex) {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
    } : null;
}

// Apply theme to document
function applyTheme(theme) {
    console.log('=== APPLYING THEME ===');
    console.log('Primary Color:', theme.primaryColor);
    console.log('Secondary Color:', theme.secondaryColor);

    const root = document.documentElement;

    // Main accent colors
    root.style.setProperty('--accent-primary', theme.primaryColor);
    root.style.setProperty('--accent-secondary', theme.secondaryColor);

    // Theme system colors (used throughout the UI)
    root.style.setProperty('--theme-accent', theme.primaryColor);
    root.style.setProperty('--theme-button', theme.primaryColor);
    root.style.setProperty('--theme-button-hover', theme.secondaryColor);

    const lightColor = adjustBrightness(theme.primaryColor, 30);
    root.style.setProperty('--theme-light', lightColor);
    console.log('Theme Light:', lightColor);

    // Generate darker shades for backgrounds
    const darkPrimary = adjustBrightness(theme.primaryColor, -80);
    const darkSecondary = adjustBrightness(theme.primaryColor, -60);
    root.style.setProperty('--theme-primary', darkPrimary);
    root.style.setProperty('--theme-secondary', darkSecondary);
    console.log('Dark Primary:', darkPrimary);
    console.log('Dark Secondary:', darkSecondary);

    // Extract RGB values for rgba() usage
    const primaryRgb = hexToRgb(theme.primaryColor);
    const darkPrimaryRgb = hexToRgb(darkPrimary);
    const darkSecondaryRgb = hexToRgb(darkSecondary);

    if (primaryRgb && darkPrimaryRgb && darkSecondaryRgb) {
        const primaryRgbStr = `${darkPrimaryRgb.r}, ${darkPrimaryRgb.g}, ${darkPrimaryRgb.b}`;
        const secondaryRgbStr = `${darkSecondaryRgb.r}, ${darkSecondaryRgb.g}, ${darkSecondaryRgb.b}`;
        const highlightStr = `rgba(${primaryRgb.r}, ${primaryRgb.g}, ${primaryRgb.b}, 0.2)`;
        const borderStr = `rgba(${primaryRgb.r}, ${primaryRgb.g}, ${primaryRgb.b}, 0.3)`;

        root.style.setProperty('--theme-primary-rgb', primaryRgbStr);
        root.style.setProperty('--theme-secondary-rgb', secondaryRgbStr);
        root.style.setProperty('--theme-highlight', highlightStr);
        root.style.setProperty('--theme-border', borderStr);

        console.log('RGB Values Set:');
        console.log('  Primary RGB:', primaryRgbStr);
        console.log('  Secondary RGB:', secondaryRgbStr);
        console.log('  Highlight:', highlightStr);
        console.log('  Border:', borderStr);
    }

    // Apply background colors if provided
    if (theme.primaryBg) {
        root.style.setProperty('--primary-bg', theme.primaryBg + 'd9'); // Add alpha
        root.style.setProperty('--theme-primary', theme.primaryBg);
        console.log('Primary Background:', theme.primaryBg);
    }
    if (theme.secondaryBg) {
        root.style.setProperty('--secondary-bg', theme.secondaryBg + 'd9'); // Add alpha
        root.style.setProperty('--theme-secondary', theme.secondaryBg);
        root.style.setProperty('--header-bg', theme.secondaryBg + 'f2'); // Higher opacity for header
        console.log('Secondary Background:', theme.secondaryBg);
    }
    if (theme.tertiaryBg) {
        root.style.setProperty('--tertiary-bg', theme.tertiaryBg + 'd9'); // Add alpha
        console.log('Tertiary Background:', theme.tertiaryBg);
    }
    if (theme.sidebarBg) {
        root.style.setProperty('--sidebar-bg', theme.sidebarBg);
        console.log('Sidebar Background:', theme.sidebarBg);
    }

    // Update background RGB values for rgba() usage
    if (theme.primaryBg) {
        const primaryBgRgb = hexToRgb(theme.primaryBg);
        if (primaryBgRgb) {
            root.style.setProperty('--theme-primary-rgb', `${primaryBgRgb.r}, ${primaryBgRgb.g}, ${primaryBgRgb.b}`);
        }
    }
    if (theme.secondaryBg) {
        const secondaryBgRgb = hexToRgb(theme.secondaryBg);
        if (secondaryBgRgb) {
            root.style.setProperty('--theme-secondary-rgb', `${secondaryBgRgb.r}, ${secondaryBgRgb.g}, ${secondaryBgRgb.b}`);
        }
    }

    // Update preview if modal is open
    const primaryColorPicker = document.getElementById('primaryColorPicker');
    const primaryColorValue = document.getElementById('primaryColorValue');
    const primaryBgPicker = document.getElementById('primaryBgPicker');
    const primaryBgValue = document.getElementById('primaryBgValue');
    const secondaryBgPicker = document.getElementById('secondaryBgPicker');
    const secondaryBgValue = document.getElementById('secondaryBgValue');
    const tertiaryBgPicker = document.getElementById('tertiaryBgPicker');
    const tertiaryBgValue = document.getElementById('tertiaryBgValue');
    const sidebarBgPicker = document.getElementById('sidebarBgPicker');
    const sidebarBgValue = document.getElementById('sidebarBgValue');

    if (primaryColorPicker) primaryColorPicker.value = theme.primaryColor;
    if (primaryColorValue) primaryColorValue.textContent = theme.primaryColor;
    if (primaryBgPicker && theme.primaryBg) primaryBgPicker.value = theme.primaryBg;
    if (primaryBgValue && theme.primaryBg) primaryBgValue.textContent = theme.primaryBg;
    if (secondaryBgPicker && theme.secondaryBg) secondaryBgPicker.value = theme.secondaryBg;
    if (secondaryBgValue && theme.secondaryBg) secondaryBgValue.textContent = theme.secondaryBg;
    if (tertiaryBgPicker && theme.tertiaryBg) tertiaryBgPicker.value = theme.tertiaryBg;
    if (tertiaryBgValue && theme.tertiaryBg) tertiaryBgValue.textContent = theme.tertiaryBg;
    if (sidebarBgPicker && theme.sidebarBg) sidebarBgPicker.value = theme.sidebarBg;
    if (sidebarBgValue && theme.sidebarBg) sidebarBgValue.textContent = theme.sidebarBg;

    console.log('=== THEME APPLIED SUCCESSFULLY ===');

    // Verify the values were set
    console.log('Verification - CSS Variables:');
    console.log('  --accent-primary:', getComputedStyle(root).getPropertyValue('--accent-primary'));
    console.log('  --theme-accent:', getComputedStyle(root).getPropertyValue('--theme-accent'));
    console.log('  --theme-primary:', getComputedStyle(root).getPropertyValue('--theme-primary'));
}

// Save theme
function saveTheme() {
    const primaryColor = document.getElementById('primaryColorPicker').value;
    const primaryBg = document.getElementById('primaryBgPicker').value;
    const secondaryBg = document.getElementById('secondaryBgPicker').value;
    const tertiaryBg = document.getElementById('tertiaryBgPicker').value;
    const sidebarBg = document.getElementById('sidebarBgPicker').value;

    const theme = {
        primaryColor: primaryColor,
        secondaryColor: adjustBrightness(primaryColor, 10), // Slightly lighter variant
        primaryBg: primaryBg,
        secondaryBg: secondaryBg,
        tertiaryBg: tertiaryBg,
        sidebarBg: sidebarBg
    };

    try {
        localStorage.setItem(THEME_STORAGE_KEY, JSON.stringify(theme));
        applyTheme(theme);
        console.log('Theme saved:', theme);

        // Show notification (modal stays open for further adjustments)
        if (window.Animations) {
            Animations.showToast({
                title: 'Saved',
                message: 'Theme saved!',
                type: 'success'
            });
        }

        // Don't close modal - let user continue adjusting colors
    } catch (error) {
        console.error('Failed to save theme:', error);
        if (window.Animations) {
            Animations.showToast({
                title: 'Error',
                message: 'Failed to save theme',
                type: 'error'
            });
        }
    }
}

// Reset to default theme
function resetTheme() {
    try {
        localStorage.removeItem(THEME_STORAGE_KEY);
        applyTheme(DEFAULT_THEME);
        console.log('Theme reset to default');

        if (window.Animations) {
            Animations.showToast({
                title: 'Success',
                message: 'Theme reset to default',
                type: 'success'
            });
        }
    } catch (error) {
        console.error('Failed to reset theme:', error);
    }
}

// Helper: Adjust color brightness
function adjustBrightness(hex, percent) {
    const num = parseInt(hex.replace('#', ''), 16);
    const r = Math.min(255, Math.max(0, (num >> 16) + percent));
    const g = Math.min(255, Math.max(0, ((num >> 8) & 0x00FF) + percent));
    const b = Math.min(255, Math.max(0, (num & 0x0000FF) + percent));
    return '#' + ((r << 16) | (g << 8) | b).toString(16).padStart(6, '0');
}

// Modal controls
function openThemeModal() {
    const modal = document.getElementById('themeModal');
    if (modal) {
        modal.classList.remove('hidden');

        // Load current theme values
        const saved = localStorage.getItem(THEME_STORAGE_KEY);
        const theme = saved ? JSON.parse(saved) : DEFAULT_THEME;

        // Set accent color values
        const primaryColorPicker = document.getElementById('primaryColorPicker');
        const primaryColorValue = document.getElementById('primaryColorValue');
        if (primaryColorPicker) primaryColorPicker.value = theme.primaryColor;
        if (primaryColorValue) primaryColorValue.textContent = theme.primaryColor;

        // Set background color values
        const primaryBgPicker = document.getElementById('primaryBgPicker');
        const primaryBgValue = document.getElementById('primaryBgValue');
        if (primaryBgPicker) primaryBgPicker.value = theme.primaryBg || DEFAULT_THEME.primaryBg;
        if (primaryBgValue) primaryBgValue.textContent = theme.primaryBg || DEFAULT_THEME.primaryBg;

        const secondaryBgPicker = document.getElementById('secondaryBgPicker');
        const secondaryBgValue = document.getElementById('secondaryBgValue');
        if (secondaryBgPicker) secondaryBgPicker.value = theme.secondaryBg || DEFAULT_THEME.secondaryBg;
        if (secondaryBgValue) secondaryBgValue.textContent = theme.secondaryBg || DEFAULT_THEME.secondaryBg;

        const tertiaryBgPicker = document.getElementById('tertiaryBgPicker');
        const tertiaryBgValue = document.getElementById('tertiaryBgValue');
        if (tertiaryBgPicker) tertiaryBgPicker.value = theme.tertiaryBg || DEFAULT_THEME.tertiaryBg;
        if (tertiaryBgValue) tertiaryBgValue.textContent = theme.tertiaryBg || DEFAULT_THEME.tertiaryBg;

        const sidebarBgPicker = document.getElementById('sidebarBgPicker');
        const sidebarBgValue = document.getElementById('sidebarBgValue');
        if (sidebarBgPicker) sidebarBgPicker.value = theme.sidebarBg || DEFAULT_THEME.sidebarBg;
        if (sidebarBgValue) sidebarBgValue.textContent = theme.sidebarBg || DEFAULT_THEME.sidebarBg;
    }
}

function closeThemeModal() {
    const modal = document.getElementById('themeModal');
    if (modal) {
        modal.classList.add('hidden');
    }
}

// Initialize theme system on page load
document.addEventListener('DOMContentLoaded', function() {
    console.log('=== THEME SYSTEM INITIALIZING ===');

    // Load saved theme on startup
    loadSavedTheme();

    // Setup color picker event listeners with LIVE preview (doesn't save until Apply is clicked)
    const colorPicker = document.getElementById('primaryColorPicker');
    if (colorPicker) {
        colorPicker.addEventListener('input', function(e) {
            const color = e.target.value;
            const primaryColorValue = document.getElementById('primaryColorValue');
            if (primaryColorValue) {
                primaryColorValue.textContent = color;
            }

            // Live preview - update CSS variables temporarily
            const root = document.documentElement;
            root.style.setProperty('--accent-primary', color);
            root.style.setProperty('--accent-secondary', adjustBrightness(color, 10));
            root.style.setProperty('--theme-accent', color);
            root.style.setProperty('--theme-button', color);
        });
    }

    // Setup background color pickers with LIVE preview and auto-close
    const primaryBgPicker = document.getElementById('primaryBgPicker');
    if (primaryBgPicker) {
        primaryBgPicker.addEventListener('input', function(e) {
            const color = e.target.value;
            const primaryBgValue = document.getElementById('primaryBgValue');
            if (primaryBgValue) primaryBgValue.textContent = color;

            // Live preview - update CSS variables temporarily
            const root = document.documentElement;
            root.style.setProperty('--primary-bg', color + 'd9');
            root.style.setProperty('--theme-primary', color);
        });
        primaryBgPicker.addEventListener('change', function(e) {
            e.target.blur(); // Close the color picker
        });
    }

    const secondaryBgPicker = document.getElementById('secondaryBgPicker');
    if (secondaryBgPicker) {
        secondaryBgPicker.addEventListener('input', function(e) {
            const color = e.target.value;
            const secondaryBgValue = document.getElementById('secondaryBgValue');
            if (secondaryBgValue) secondaryBgValue.textContent = color;

            // Live preview - update CSS variables temporarily
            const root = document.documentElement;
            root.style.setProperty('--secondary-bg', color + 'd9');
            root.style.setProperty('--theme-secondary', color);
            root.style.setProperty('--header-bg', color + 'f2');
        });
        secondaryBgPicker.addEventListener('change', function(e) {
            e.target.blur(); // Close the color picker
        });
    }

    const tertiaryBgPicker = document.getElementById('tertiaryBgPicker');
    if (tertiaryBgPicker) {
        tertiaryBgPicker.addEventListener('input', function(e) {
            const color = e.target.value;
            const tertiaryBgValue = document.getElementById('tertiaryBgValue');
            if (tertiaryBgValue) tertiaryBgValue.textContent = color;

            // Live preview - update CSS variables temporarily
            const root = document.documentElement;
            root.style.setProperty('--tertiary-bg', color + 'd9');
        });
        tertiaryBgPicker.addEventListener('change', function(e) {
            e.target.blur(); // Close the color picker
        });
    }

    const sidebarBgPicker = document.getElementById('sidebarBgPicker');
    if (sidebarBgPicker) {
        sidebarBgPicker.addEventListener('input', function(e) {
            const color = e.target.value;
            const sidebarBgValue = document.getElementById('sidebarBgValue');
            if (sidebarBgValue) sidebarBgValue.textContent = color;

            // Live preview - update CSS variables temporarily
            const root = document.documentElement;
            root.style.setProperty('--sidebar-bg', color);
        });
        sidebarBgPicker.addEventListener('change', function(e) {
            e.target.blur(); // Close the color picker
        });
    }

    console.log('=== THEME SYSTEM LOADED ===');
});

// Expose theme functions globally
window.openThemeModal = openThemeModal;
window.closeThemeModal = closeThemeModal;
window.saveTheme = saveTheme;
window.resetTheme = resetTheme;

console.log('=== THEME CUSTOMIZATION SYSTEM LOADED ===');
