// Transaction display function - embedded in main script
function updateTransactionDisplay() {
    console.log('=== UPDATING TRANSACTION DISPLAY ===');
    
    const historyContainer = document.getElementById('transactionHistory');
    if (!historyContainer) {
        console.warn('Transaction history container not found');
        return;
    }
    
    console.log('Found transaction history container:', historyContainer);
    
    // Clear existing content
    historyContainer.innerHTML = '';
    
    // Check if we have transactions
    if (!window.transactionHistory || window.transactionHistory.length === 0) {
        console.log('No transactions to display');
        historyContainer.innerHTML = '<div class="transaction-item"><div class="transaction-info"><div class="transaction-details"><div class="transaction-reason">No transactions yet</div></div></div></div>';
        return;
    }
    
    console.log('Displaying', window.transactionHistory.length, 'transactions');
    
    // Add each transaction as a compact item
    window.transactionHistory.forEach((transaction, index) => {
        console.log(`Processing transaction ${index + 1}:`, transaction);
        
        const item = document.createElement('div');
        item.className = 'transaction-item';
        
        const formattedDate = transaction.timestamp.toLocaleDateString();
        const formattedAmount = transaction.amount.toLocaleString('en-US', {
            style: 'currency',
            currency: 'USD'
        });
        
        const reasonText = getReasonText(transaction.reason);
        
        item.innerHTML = `
            <div class="transaction-info">
                <span class="transaction-type-badge ${transaction.type}">
                    ${transaction.type === 'deposit' ? 'Deposit' : 'Withdrawal'}
                </span>
                <div class="transaction-details">
                    <div class="transaction-reason">${reasonText}</div>
                    <div class="transaction-date">${formattedDate}</div>
                </div>
            </div>
            <div class="transaction-amount ${transaction.type === 'deposit' ? 'positive' : 'negative'}">
                ${transaction.type === 'deposit' ? '+' : '-'}${formattedAmount}
            </div>
        `;
        
        historyContainer.appendChild(item);
        console.log(`Added transaction ${index + 1} to display`);
    });
    
    console.log('Transaction display updated successfully');
}

// Helper function for reason text
function getReasonText(reason) {
    const reasonMap = {
        'budget_allocation': 'Budget Allocation',
        'revenue_collection': 'Revenue Collection',
        'grant_funding': 'Grant Funding',
        'donation': 'Donation',
        'equipment_purchase': 'Equipment Purchase',
        'maintenance': 'Maintenance',
        'training': 'Training',
        'operational_expenses': 'Operational Expenses',
        'emergency_fund': 'Emergency Fund',
        'other': 'Other'
    };

    return reasonMap[reason] || reason;
}

// ========== EXPORT MODAL FUNCTIONALITY ==========

// Global variable to store filtered export data
let exportTransactions = [];
let filterDebounceTimer = null;

// Open export modal
function openExportModal() {
    console.log('Opening export modal');
    document.getElementById('exportModal').classList.remove('hidden');

    // Clear date filters - show ALL transactions by default
    document.getElementById('exportEndDate').value = '';
    document.getElementById('exportStartDate').value = '';
    document.getElementById('exportOfficerName').value = '';
    document.getElementById('exportType').value = 'all';

    // Clear loading state immediately - show "No transactions found" until data loads
    exportTransactions = [];
    updateExportTable();

    // Load all transactions (will call updateExportTable again when data arrives)
    applyExportFilters();
}

// Close export modal
function closeExportModal() {
    console.log('Closing export modal');
    document.getElementById('exportModal').classList.add('hidden');
    exportTransactions = [];
}

// Set today filter
function setTodayFilter() {
    const today = new Date();
    const year = today.getFullYear();
    const month = String(today.getMonth() + 1).padStart(2, '0');
    const day = String(today.getDate()).padStart(2, '0');
    const dateString = `${year}-${month}-${day}`;

    document.getElementById('exportStartDate').value = dateString;
    document.getElementById('exportEndDate').value = dateString;

    // Auto-apply filters after setting today's date
    applyExportFilters();
}

// Debounced filter apply for text inputs
function debouncedApplyFilters() {
    clearTimeout(filterDebounceTimer);
    filterDebounceTimer = setTimeout(() => {
        applyExportFilters();
    }, 500); // Wait 500ms after user stops typing
}

// Apply filters and fetch transactions
function applyExportFilters() {
    console.log('=== APPLYING EXPORT FILTERS ===');

    const startDate = document.getElementById('exportStartDate').value;
    const endDate = document.getElementById('exportEndDate').value;
    const officerName = document.getElementById('exportOfficerName').value.trim();
    const type = document.getElementById('exportType').value;

    console.log('Filters:', { startDate, endDate, officerName, type });

    // Send request to server via NUI - response will come via message event
    fetch('https://pd_boss_menu/getExportTransactions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            start_date: startDate || '',
            end_date: endDate || '',
            officer_name: officerName || '',
            type: type === 'all' ? '' : type
        })
    }).then(() => {
        console.log('Export transactions request sent');
    }).catch(error => {
        console.error('Error sending export request:', error);
    });
}

// Update the export table display
function updateExportTable() {
    const tbody = document.getElementById('exportTableBody');
    const countSpan = document.getElementById('exportCount');

    countSpan.textContent = exportTransactions.length;

    if (exportTransactions.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="no-data">No transactions found</td></tr>';
        return;
    }

    tbody.innerHTML = '';

    exportTransactions.forEach(tx => {
        const row = document.createElement('tr');

        const datetime = new Date(tx.timestamp);
        const formattedDate = datetime.toLocaleDateString() + ' ' + datetime.toLocaleTimeString();

        const amount = parseFloat(tx.amount);
        const formattedAmount = '$' + amount.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

        const balanceAfter = parseFloat(tx.balance_after || 0);
        const formattedBalance = '$' + balanceAfter.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

        const txType = tx.transaction_type || 'unknown';
        const displayType = txType === 'deposit' ? 'Deposit' : 'Withdraw';

        const amountClass = txType === 'deposit' ? 'amount-positive' : 'amount-negative';
        const amountPrefix = txType === 'deposit' ? '+' : '-';

        row.innerHTML = `
            <td>${formattedDate}</td>
            <td>${tx.officer_name || 'Unknown'}</td>
            <td><span class="type-badge ${txType}">${displayType}</span></td>
            <td>${getReasonText(tx.reason)}</td>
            <td class="${amountClass}">${amountPrefix}${formattedAmount}</td>
            <td>${formattedBalance}</td>
        `;

        tbody.appendChild(row);
    });
}

// Ensure functions are globally accessible for onclick handlers
window.closeExportModal = closeExportModal;
window.openExportModal = openExportModal;

// Attach event listener to export button
document.addEventListener('DOMContentLoaded', function() {
    const exportBtn = document.getElementById('exportTransactions');
    if (exportBtn) {
        exportBtn.addEventListener('click', openExportModal);
        console.log('Export button listener attached');
    }
    // Note: ESC key handling is done in script.js to prevent conflicts
});
