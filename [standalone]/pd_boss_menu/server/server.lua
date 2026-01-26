print("=== PD BOSS MENU SERVER SCRIPT LOADING ===")
local QBX = exports.qbx_core

-- Helper function to get department display name for notifications
local function GetDeptLabel(department)
    local deptInfo = Config.DepartmentInfo and Config.DepartmentInfo[department]
    if deptInfo then
        return deptInfo.shortName
    end
    -- Fallback labels if Config not loaded yet
    local fallbackLabels = {
        police = 'LSPD',
        lscso = 'LSCSO',
        safr = 'SAFR'
    }
    return fallbackLabels[department] or 'Department'
end

-- ===========================================
-- TGG-BANKING INTEGRATION
-- Uses tgg-banking society accounts instead of pd_funds table
-- ===========================================

-- Check if tgg-banking is available
local function IsTggBankingAvailable()
    return GetResourceState('tgg-banking') == 'started'
end

-- Get society account balance from tgg-banking
local function GetSocietyBalance(department)
    print("[PD_BOSS DEBUG] GetSocietyBalance called for department:", department)

    if IsTggBankingAvailable() then
        -- Try GetSocietyAccount first (returns full account object)
        local success, account = pcall(function()
            return exports['tgg-banking']:GetSocietyAccount(department)
        end)
        print("[PD_BOSS DEBUG] GetSocietyAccount result - success:", success, "account:", account and json.encode(account) or "nil")

        if success and account then
            local balance = account.balance or 0
            print("[PD_BOSS DEBUG] Returning balance from account object:", balance)
            return balance
        end

        -- If account doesn't exist, try to get just the money
        local success2, balance = pcall(function()
            return exports['tgg-banking']:GetSocietyAccountMoney(department)
        end)
        print("[PD_BOSS DEBUG] GetSocietyAccountMoney result - success:", success2, "balance:", balance)

        if success2 and balance then
            print("[PD_BOSS DEBUG] Returning balance from GetSocietyAccountMoney:", balance)
            return balance
        end

        print("[PD_BOSS DEBUG] TGG-Banking available but no account found for:", department)
    else
        print("[PD_BOSS DEBUG] TGG-Banking NOT available, using fallback pd_funds")
    end

    -- Fallback to pd_funds table if tgg-banking unavailable
    local result = MySQL.Sync.fetchAll('SELECT amount FROM pd_funds WHERE department = ?', {department})
    local fallbackAmount = result[1] and result[1].amount or 0
    print("[PD_BOSS DEBUG] Fallback pd_funds result for", department, ":", fallbackAmount)
    return fallbackAmount
end

-- Add money to society account via tgg-banking
local function AddSocietyMoney(department, amount)
    if IsTggBankingAvailable() then
        local success, result = pcall(function()
            return exports['tgg-banking']:AddSocietyMoney(department, amount)
        end)
        if success then
            print("[TGG-BANKING] Added $" .. amount .. " to " .. department .. " society account")
            return true
        else
            print("[TGG-BANKING] Failed to add money: " .. tostring(result))
        end
    end
    -- Fallback to pd_funds if tgg-banking unavailable
    local currentResult = MySQL.Sync.fetchAll('SELECT amount FROM pd_funds WHERE department = ?', {department})
    local currentBalance = currentResult[1] and currentResult[1].amount or 0
    local newBalance = currentBalance + amount
    MySQL.Sync.execute('UPDATE pd_funds SET amount = ? WHERE department = ?', {newBalance, department})
    return true
end

-- Remove money from society account via tgg-banking
local function RemoveSocietyMoney(department, amount)
    if IsTggBankingAvailable() then
        local success, result = pcall(function()
            return exports['tgg-banking']:RemoveSocietyMoney(department, amount)
        end)
        if success and result then
            print("[TGG-BANKING] Removed $" .. amount .. " from " .. department .. " society account")
            return true
        else
            print("[TGG-BANKING] Failed to remove money: " .. tostring(result))
            return false
        end
    end
    -- Fallback to pd_funds if tgg-banking unavailable
    local currentResult = MySQL.Sync.fetchAll('SELECT amount FROM pd_funds WHERE department = ?', {department})
    local currentBalance = currentResult[1] and currentResult[1].amount or 0
    if currentBalance < amount then
        return false
    end
    local newBalance = currentBalance - amount
    MySQL.Sync.execute('UPDATE pd_funds SET amount = ? WHERE department = ?', {newBalance, department})
    return true
end

print("[PD BOSS MENU] TGG-Banking integration loaded. Available:", IsTggBankingAvailable())

    -- Initialize database
MySQL.ready(function()
    -- Create funds table with department support
    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS `pd_funds` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `department` varchar(50) NOT NULL DEFAULT 'police',
            `amount` int(11) NOT NULL DEFAULT 0,
            PRIMARY KEY (`id`),
            UNIQUE KEY `department` (`department`)
        )
    ]])

    -- Add department column if it doesn't exist (for existing tables)
    MySQL.Sync.execute([[
        ALTER TABLE `pd_funds`
        ADD COLUMN IF NOT EXISTS `department` varchar(50) NOT NULL DEFAULT 'police'
    ]])

    -- Create transaction history table with department support
    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS `pd_transactions` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `department` varchar(50) NOT NULL DEFAULT 'police',
            `transaction_type` varchar(20) NOT NULL,
            `amount` int(11) NOT NULL,
            `officer_name` varchar(100) NOT NULL,
            `officer_citizenid` varchar(50) NOT NULL,
            `reason` text,
            `balance_after` int(11) NOT NULL,
            `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            KEY `department` (`department`)
        )
    ]])

    -- Add department column to transactions if it doesn't exist
    MySQL.Sync.execute([[
        ALTER TABLE `pd_transactions`
        ADD COLUMN IF NOT EXISTS `department` varchar(50) NOT NULL DEFAULT 'police'
    ]])

    -- Create disciplinary actions table
    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS `pd_disciplinary` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `department` varchar(50) NOT NULL DEFAULT 'police',
            `officer_citizenid` varchar(50) NOT NULL,
            `officer_name` varchar(100) NOT NULL,
            `action_type` varchar(50) NOT NULL,
            `description` text,
            `issued_by` varchar(100) NOT NULL,
            `issued_by_citizenid` varchar(50) NOT NULL,
            `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `active` tinyint(1) NOT NULL DEFAULT 1,
            PRIMARY KEY (`id`),
            KEY `officer_citizenid` (`officer_citizenid`),
            KEY `department` (`department`)
        )
    ]])

    -- Create duty logs table for tracking officer on-duty time
    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS `pd_duty_logs` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `department` varchar(50) NOT NULL,
            `officer_citizenid` varchar(50) NOT NULL,
            `officer_name` varchar(100) NOT NULL,
            `duty_start` datetime NOT NULL,
            `duty_end` datetime DEFAULT NULL,
            `duration_minutes` int(11) DEFAULT 0,
            `duty_date` date NOT NULL,
            PRIMARY KEY (`id`),
            KEY `officer_citizenid` (`officer_citizenid`),
            KEY `department` (`department`),
            KEY `duty_date` (`duty_date`)
        )
    ]])

    -- Create duty summary table for daily/weekly aggregates (faster queries)
    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS `pd_duty_summary` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `department` varchar(50) NOT NULL,
            `officer_citizenid` varchar(50) NOT NULL,
            `officer_name` varchar(100) NOT NULL,
            `summary_date` date NOT NULL,
            `total_minutes` int(11) NOT NULL DEFAULT 0,
            `shift_count` int(11) NOT NULL DEFAULT 1,
            PRIMARY KEY (`id`),
            UNIQUE KEY `unique_officer_date` (`department`, `officer_citizenid`, `summary_date`),
            KEY `department` (`department`),
            KEY `summary_date` (`summary_date`)
        )
    ]])

    -- Create rank permissions table
    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS `pd_rank_permissions` (
            `grade` int(11) NOT NULL,
            `viewEmployees` tinyint(1) NOT NULL DEFAULT 0,
            `viewBanking` tinyint(1) NOT NULL DEFAULT 0,
            `viewDisciplinary` tinyint(1) NOT NULL DEFAULT 0,
            `hireEmployees` tinyint(1) NOT NULL DEFAULT 0,
            `fireEmployees` tinyint(1) NOT NULL DEFAULT 0,
            `changeRanks` tinyint(1) NOT NULL DEFAULT 0,
            `viewReports` tinyint(1) NOT NULL DEFAULT 0,
            `accessSettings` tinyint(1) NOT NULL DEFAULT 0,
            PRIMARY KEY (`grade`)
        )
    ]])
    
    -- Add viewDisciplinary column if it doesn't exist
    MySQL.Sync.execute([[
        ALTER TABLE `pd_rank_permissions`
        ADD COLUMN IF NOT EXISTS `viewDisciplinary` tinyint(1) NOT NULL DEFAULT 1
    ]])

    -- Add payBonuses column if it doesn't exist (command+ only by default)
    MySQL.Sync.execute([[
        ALTER TABLE `pd_rank_permissions`
        ADD COLUMN IF NOT EXISTS `payBonuses` tinyint(1) NOT NULL DEFAULT 0
    ]])

    -- Update existing rows to have viewDisciplinary = 1 if they don't have it
    MySQL.Sync.execute([[
        UPDATE `pd_rank_permissions`
        SET `viewDisciplinary` = 1
        WHERE `viewDisciplinary` IS NULL
    ]])

    -- Update command+ ranks (11-14) to have payBonuses = 1
    MySQL.Sync.execute([[
        UPDATE `pd_rank_permissions`
        SET `payBonuses` = 1
        WHERE `grade` >= 11
    ]])
    
    -- Initialize PD funds for each department if not exists
    local policeResult = MySQL.Sync.fetchAll('SELECT * FROM pd_funds WHERE department = ?', {'police'})
    if #policeResult == 0 then
        MySQL.Sync.execute('INSERT INTO pd_funds (department, amount) VALUES (?, ?)', {'police', 50000})
        print("Initialized police department funds")
    end

    local lscsoResult = MySQL.Sync.fetchAll('SELECT * FROM pd_funds WHERE department = ?', {'lscso'})
    if #lscsoResult == 0 then
        MySQL.Sync.execute('INSERT INTO pd_funds (department, amount) VALUES (?, ?)', {'lscso', 50000})
        print("Initialized lscso department funds")
    end
    
    -- Initialize default rank permissions if not exists
    local permissionResult = MySQL.Sync.fetchAll('SELECT * FROM pd_rank_permissions LIMIT 1')
    if #permissionResult == 0 then
        print("No rank permissions found in database, initializing defaults...")
        -- Insert default permissions for actual police ranks (1-14 matching jobs.lua)
        for grade = 1, 14 do
            local permissions = GetDefaultRankPermissions(grade)
            print("Inserting permissions for grade", grade, ":", json.encode(permissions))
            MySQL.Sync.execute([[
                INSERT INTO pd_rank_permissions
                (grade, viewEmployees, viewBanking, viewDisciplinary, hireEmployees, fireEmployees, changeRanks, viewReports, accessSettings)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ]], {
                grade,
                permissions.viewEmployees and 1 or 0,
                permissions.viewBanking and 1 or 0,
                permissions.viewDisciplinary and 1 or 0,
                permissions.hireEmployees and 1 or 0,
                permissions.fireEmployees and 1 or 0,
                permissions.changeRanks and 1 or 0,
                permissions.viewReports and 1 or 0,
                permissions.accessSettings and 1 or 0
            })
        end
        print("Default rank permissions initialized successfully")
    else
        print("Rank permissions already exist in database")
        -- Check if all grades 1-14 exist, if not add missing ones
        for grade = 1, 14 do
            local gradeResult = MySQL.Sync.fetchAll('SELECT * FROM pd_rank_permissions WHERE grade = ?', {grade})
            if #gradeResult == 0 then
                print("Missing permissions for grade", grade, ", adding defaults...")
                local permissions = GetDefaultRankPermissions(grade)
                MySQL.Sync.execute([[
                    INSERT INTO pd_rank_permissions
                    (grade, viewEmployees, viewBanking, viewDisciplinary, hireEmployees, fireEmployees, changeRanks, viewReports, accessSettings)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                ]], {
                    grade,
                    permissions.viewEmployees and 1 or 0,
                    permissions.viewBanking and 1 or 0,
                    permissions.viewDisciplinary and 1 or 0,
                    permissions.hireEmployees and 1 or 0,
                    permissions.fireEmployees and 1 or 0,
                    permissions.changeRanks and 1 or 0,
                    permissions.viewReports and 1 or 0,
                    permissions.accessSettings and 1 or 0
                })
                print("Added missing permissions for grade", grade)
            end
        end
    end
end)

-- ========================================
-- DISCORD WEBHOOK SYSTEM
-- ========================================

-- Get the appropriate webhook URL based on action type
function GetWebhookUrl(actionType)
    if not Config.Webhooks then return nil end

    local webhookUrl = nil

    -- Check for specific webhook first
    if actionType == 'hire' or actionType == 'fire' or actionType == 'promote' or actionType == 'demote' then
        webhookUrl = Config.Webhooks.personnel
    elseif actionType == 'deposit' or actionType == 'withdraw' or actionType == 'bonus' then
        webhookUrl = Config.Webhooks.finance
    end

    -- Fall back to 'all' webhook if specific one isn't set
    if (not webhookUrl or webhookUrl == '') and Config.Webhooks.all and Config.Webhooks.all ~= '' then
        webhookUrl = Config.Webhooks.all
    end

    -- Return nil if no valid webhook found
    if not webhookUrl or webhookUrl == '' then
        return nil
    end

    return webhookUrl
end

-- Get department color for action
function GetDepartmentColor(department, actionType)
    local deptColors = Config.DepartmentColors and Config.DepartmentColors[department]
    if not deptColors then
        -- Fallback colors
        local fallbackColors = {
            hire = 3066993, fire = 15158332, promote = 3447003,
            demote = 15105570, deposit = 3066993, withdraw = 15158332, bonus = 15844367
        }
        return fallbackColors[actionType] or 3447003
    end
    return deptColors[actionType] or deptColors.primary or 3447003
end

-- Get department info
function GetDepartmentInfo(department)
    local info = Config.DepartmentInfo and Config.DepartmentInfo[department]
    if not info then
        return {
            name = department:upper(),
            shortName = department:upper(),
            icon = '',
            footer = 'Boss Menu System'
        }
    end
    return info
end

-- Send Discord webhook with embed
function SendDiscordWebhook(actionType, department, data)
    local webhookUrl = GetWebhookUrl(actionType)
    if not webhookUrl then
        return -- Skip if no webhook configured
    end

    local deptInfo = GetDepartmentInfo(department)
    local color = GetDepartmentColor(department, actionType)

    -- Build embed fields based on action type
    local fields = {}
    local title = ''
    local description = ''

    -- Action performer info (always included)
    if data.performerName then
        table.insert(fields, {
            name = 'Performed By',
            value = data.performerName .. (data.performerRank and ('\n*' .. data.performerRank .. '*') or ''),
            inline = true
        })
    end

    -- Build specific content based on action type
    if actionType == 'hire' then
        title = '👮 New Employee Hired'
        description = '**' .. (data.targetName or 'Unknown') .. '** has been hired to the department.'
        table.insert(fields, {
            name = 'New Employee',
            value = data.targetName or 'Unknown',
            inline = true
        })
        table.insert(fields, {
            name = 'Starting Rank',
            value = data.rank or 'Cadet',
            inline = true
        })

    elseif actionType == 'fire' then
        title = '🚫 Employee Terminated'
        description = '**' .. (data.targetName or 'Unknown') .. '** has been terminated from the department.'
        table.insert(fields, {
            name = 'Former Employee',
            value = data.targetName or 'Unknown',
            inline = true
        })
        if data.previousRank then
            table.insert(fields, {
                name = 'Previous Rank',
                value = data.previousRank,
                inline = true
            })
        end

    elseif actionType == 'promote' then
        title = '⬆️ Employee Promoted'
        description = '**' .. (data.targetName or 'Unknown') .. '** has been promoted.'
        table.insert(fields, {
            name = 'Employee',
            value = data.targetName or 'Unknown',
            inline = true
        })
        table.insert(fields, {
            name = 'Rank Change',
            value = (data.previousRank or '?') .. ' → **' .. (data.newRank or '?') .. '**',
            inline = true
        })

    elseif actionType == 'demote' then
        title = '⬇️ Employee Demoted'
        description = '**' .. (data.targetName or 'Unknown') .. '** has been demoted.'
        table.insert(fields, {
            name = 'Employee',
            value = data.targetName or 'Unknown',
            inline = true
        })
        table.insert(fields, {
            name = 'Rank Change',
            value = (data.previousRank or '?') .. ' → **' .. (data.newRank or '?') .. '**',
            inline = true
        })

    elseif actionType == 'deposit' then
        title = '💰 Funds Deposited'
        description = 'Department funds have been increased.'
        table.insert(fields, {
            name = 'Amount',
            value = '+$' .. FormatNumber(data.amount or 0),
            inline = true
        })
        table.insert(fields, {
            name = 'New Balance',
            value = '$' .. FormatNumber(data.newBalance or 0),
            inline = true
        })
        if data.reason and data.reason ~= '' then
            table.insert(fields, {
                name = 'Reason',
                value = data.reason,
                inline = false
            })
        end

    elseif actionType == 'withdraw' then
        title = '💸 Funds Withdrawn'
        description = 'Department funds have been withdrawn.'
        table.insert(fields, {
            name = 'Amount',
            value = '-$' .. FormatNumber(data.amount or 0),
            inline = true
        })
        table.insert(fields, {
            name = 'New Balance',
            value = '$' .. FormatNumber(data.newBalance or 0),
            inline = true
        })
        if data.reason and data.reason ~= '' then
            table.insert(fields, {
                name = 'Reason',
                value = data.reason,
                inline = false
            })
        end

    elseif actionType == 'bonus' then
        title = '🎁 Bonus Payment'
        description = 'A bonus has been paid to an employee.'
        table.insert(fields, {
            name = 'Recipient',
            value = data.targetName or 'Unknown',
            inline = true
        })
        table.insert(fields, {
            name = 'Amount',
            value = '$' .. FormatNumber(data.amount or 0),
            inline = true
        })
        table.insert(fields, {
            name = 'Remaining Funds',
            value = '$' .. FormatNumber(data.newBalance or 0),
            inline = true
        })
        if data.reason and data.reason ~= '' then
            table.insert(fields, {
                name = 'Reason',
                value = data.reason,
                inline = false
            })
        end
    end

    -- Build the embed
    local embed = {
        {
            title = title,
            description = description,
            color = color,
            fields = fields,
            footer = {
                text = deptInfo.footer .. ' • ' .. os.date('%Y-%m-%d %H:%M:%S')
            },
            author = {
                name = deptInfo.name,
                icon_url = deptInfo.icon ~= '' and deptInfo.icon or nil
            }
        }
    }

    -- Send the webhook
    PerformHttpRequest(webhookUrl, function(err, text, headers) end, 'POST', json.encode({
        username = deptInfo.shortName .. ' Boss Menu',
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })

    print('[Discord Webhook] Sent ' .. actionType .. ' notification for ' .. department)
end

-- Helper function to format numbers with commas
function FormatNumber(num)
    local formatted = tostring(num)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- Command to check database status
RegisterCommand('checkrankpermissions', function(source, args, rawCommand)
    local src = source
    local Player = QBX:GetPlayer(src)
    
    -- Only allow police to use this command
    if not Player or Player.PlayerData.job.name ~= 'police' then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Error',
            description = 'You must be a police officer to use this command',
            type = 'error'
        })
        return
    end
    
    print("=== DATABASE CHECK ===")

    -- Check all grades 1-14
    for grade = 1, 14 do
        local result = MySQL.Sync.fetchAll('SELECT * FROM pd_rank_permissions WHERE grade = ?', {grade})
        if #result > 0 then
            local row = result[1]
            print("Grade", grade, ":", json.encode(row))
        else
            print("Grade", grade, ": NOT FOUND")
        end
    end
    
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Database Check',
        description = 'Check server console for database status',
        type = 'info'
    })
end, false)

-- Command to test database operations
RegisterCommand('testpdfunds', function(source, args, rawCommand)
    local src = source
    print("=== TESTING PD FUNDS DATABASE ===")

    -- Test 1: Check if pd_funds table exists and has data
    local funds = MySQL.Sync.fetchAll('SELECT * FROM pd_funds')
    print("pd_funds rows:", #funds)
    if #funds > 0 then
        print("Current amount:", funds[1].amount, "ID:", funds[1].id)
    else
        print("pd_funds is EMPTY - inserting initial row...")
        MySQL.Sync.execute('INSERT INTO pd_funds (id, amount) VALUES (1, 50000)')
    end

    -- Test 2: Try to update funds
    local testAmount = 12345
    print("Attempting to set funds to", testAmount)
    local affected = MySQL.Sync.execute('UPDATE pd_funds SET amount = ? WHERE id = 1', {testAmount})
    print("UPDATE affected rows:", affected)

    -- Test 3: Verify the update worked
    local verify = MySQL.Sync.fetchAll('SELECT amount FROM pd_funds WHERE id = 1')
    if verify and verify[1] then
        print("Verified amount after update:", verify[1].amount)
        if verify[1].amount == testAmount then
            print("SUCCESS: Database UPDATE is working!")
        else
            print("FAILURE: Amount didn't change! Expected", testAmount, "got", verify[1].amount)
        end
    else
        print("FAILURE: Could not read back the value!")
    end

    -- Test 4: Check pd_transactions table
    local txCount = MySQL.Sync.fetchAll('SELECT COUNT(*) as count FROM pd_transactions')
    print("pd_transactions count:", txCount[1] and txCount[1].count or "ERROR")

    -- Test 5: Try inserting a test transaction
    local insertId = MySQL.Sync.insert('INSERT INTO pd_transactions (transaction_type, amount, officer_name, officer_citizenid, reason, balance_after) VALUES (?, ?, ?, ?, ?, ?)', {
        'test',
        100,
        'Test Officer',
        'TEST123',
        'Database test',
        testAmount
    })
    print("Test transaction insert ID:", insertId)

    -- Verify insert
    local newCount = MySQL.Sync.fetchAll('SELECT COUNT(*) as count FROM pd_transactions')
    print("pd_transactions count after insert:", newCount[1] and newCount[1].count or "ERROR")

    if src > 0 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Database Test',
            description = 'Check server console for results',
            type = 'info'
        })
    end

    print("=== DATABASE TEST COMPLETE ===")
end, false)

-- Command to debug tgg-banking society accounts
RegisterCommand('debugsociety', function(source, args, rawCommand)
    local src = source
    local department = args[1] or 'police'

    print("=== DEBUGGING TGG-BANKING SOCIETY ACCOUNTS ===")
    print("Requested department:", department)
    print("TGG-Banking available:", IsTggBankingAvailable())

    if IsTggBankingAvailable() then
        -- Test GetSocietyAccount
        print("\n--- Testing GetSocietyAccount ---")
        local success1, account = pcall(function()
            return exports['tgg-banking']:GetSocietyAccount(department)
        end)
        print("GetSocietyAccount success:", success1)
        if success1 then
            print("Account data:", account and json.encode(account) or "nil")
        else
            print("Error:", tostring(account))
        end

        -- Test GetSocietyAccountMoney
        print("\n--- Testing GetSocietyAccountMoney ---")
        local success2, money = pcall(function()
            return exports['tgg-banking']:GetSocietyAccountMoney(department)
        end)
        print("GetSocietyAccountMoney success:", success2)
        if success2 then
            print("Money:", money)
        else
            print("Error:", tostring(money))
        end

        -- Test common department names
        print("\n--- Testing common department names ---")
        local testNames = {'police', 'lscso', 'safr', 'ambulance', 'pd', 'sheriff', 'LSPD', 'lspd'}
        for _, name in ipairs(testNames) do
            local ok, result = pcall(function()
                return exports['tgg-banking']:GetSocietyAccountMoney(name)
            end)
            if ok and result and result > 0 then
                print("  ", name, "= $" .. tostring(result))
            else
                print("  ", name, "= nil/0")
            end
        end

        -- Try to list all accounts (if export exists)
        print("\n--- Attempting to list all accounts ---")
        local ok3, allAccounts = pcall(function()
            return exports['tgg-banking']:GetAllSocietyAccounts()
        end)
        if ok3 and allAccounts then
            print("All accounts:", json.encode(allAccounts))
        else
            print("GetAllSocietyAccounts not available or failed")
        end
    else
        print("TGG-Banking is not running!")
    end

    -- Show pd_funds fallback
    print("\n--- Checking pd_funds fallback table ---")
    local pdFunds = MySQL.Sync.fetchAll('SELECT * FROM pd_funds')
    for _, row in ipairs(pdFunds) do
        print("  Department:", row.department, "Amount: $" .. tostring(row.amount))
    end

    if src > 0 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Debug Society',
            description = 'Check server console for results',
            type = 'info'
        })
    end

    print("=== DEBUG COMPLETE ===")
end, false)

-- Command to test saving permissions manually
RegisterCommand('testrankpermissions', function(source, args, rawCommand)
    local src = source
    local Player = QBX:GetPlayer(src)
    
    -- Only allow police to use this command
    if not Player or Player.PlayerData.job.name ~= 'police' then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Error',
            description = 'You must be a police officer to use this command',
            type = 'error'
        })
        return
    end
    
    print("=== TESTING RANK PERMISSIONS ===")
    
    -- Test saving permissions for grade 0
    local testPermissions = {
        viewEmployees = true,
        viewBanking = false,
        hireEmployees = false,
        fireEmployees = false,
        changeRanks = false,
        viewReports = true,
        accessSettings = false
    }
    
    print("Testing save for grade 0:", json.encode(testPermissions))
    
    local result = MySQL.Sync.execute([[
        REPLACE INTO pd_rank_permissions 
        (grade, viewEmployees, viewBanking, hireEmployees, fireEmployees, changeRanks, viewReports, accessSettings) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        0,
        testPermissions.viewEmployees and 1 or 0,
        testPermissions.viewBanking and 1 or 0,
        testPermissions.hireEmployees and 1 or 0,
        testPermissions.fireEmployees and 1 or 0,
        testPermissions.changeRanks and 1 or 0,
        testPermissions.viewReports and 1 or 0,
        testPermissions.accessSettings and 1 or 0
    })
    
    print("Save result:", result)
    
    -- Verify the save
    local verify = MySQL.Sync.fetchAll('SELECT * FROM pd_rank_permissions WHERE grade = ?', {0})
    print("Verification:", json.encode(verify))
    
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Test Complete',
        description = 'Check server console for results',
        type = 'info'
    })
end, false)

-- Command to fix banking permissions
RegisterCommand('fixbanking', function(source, args, rawCommand)
    local src = source
    local Player = QBX:GetPlayer(src)
    
    if not Player or Player.PlayerData.job.name ~= 'police' then
        return
    end
    
    print("=== FIXING BANKING PERMISSIONS ===")

    -- Set all ranks to have banking enabled
    for grade = 1, 14 do
        MySQL.Sync.execute([[
            REPLACE INTO pd_rank_permissions
            (grade, viewEmployees, viewBanking, viewDisciplinary, hireEmployees, fireEmployees, changeRanks, viewReports, accessSettings)
            VALUES (?, 1, 1, 1, 1, 1, 1, 1, 1)
        ]], {grade})
    end
    
    print("Banking permissions fixed for all ranks")
    
    -- Force refresh user permissions
    TriggerEvent('pd_boss:server:getUserPermissions', src)
end, false)

-- Command to force refresh all rank permissions to full access
RegisterCommand('refreshrankpermissions', function(source, args, rawCommand)
    local src = source
    local Player = QBX:GetPlayer(src)
    
    -- Only allow police to use this command
    if not Player or Player.PlayerData.job.name ~= 'police' then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Error',
            description = 'You must be a police officer to use this command',
            type = 'error'
        })
        return
    end
    
    print("=== FORCE REFRESHING ALL RANK PERMISSIONS ===")

    -- Set all ranks to have full permissions
    for grade = 1, 14 do
        print("Setting full permissions for grade", grade)
        MySQL.Sync.execute([[
            REPLACE INTO pd_rank_permissions
            (grade, viewEmployees, viewBanking, viewDisciplinary, hireEmployees, fireEmployees, changeRanks, viewReports, accessSettings)
            VALUES (?, 1, 1, 1, 1, 1, 1, 1, 1)
        ]], {grade})
    end
    
    print("All rank permissions set to full access")
    
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Rank Permissions',
        description = 'All rank permissions refreshed to full access',
        type = 'success'
    })
end, false)


-- Command to check database permissions directly
RegisterCommand('checkdbpermissions', function(source, args, rawCommand)
    local src = source
    local Player = QBX:GetPlayer(src)
    
    -- Only allow police to use this command
    if not Player or Player.PlayerData.job.name ~= 'police' then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Error',
            description = 'You must be a police officer to use this command',
            type = 'error'
        })
        return
    end
    
    print("=== CHECKING DATABASE PERMISSIONS ===")

    -- Check all grades
    for grade = 1, 14 do
        local result = MySQL.Sync.fetchAll('SELECT * FROM pd_rank_permissions WHERE grade = ?', {grade})
        if #result > 0 then
            local row = result[1]
            print("Grade", grade, "permissions:")
            print("  viewEmployees:", row.viewEmployees)
            print("  viewBanking:", row.viewBanking)
            print("  hireEmployees:", row.hireEmployees)
            print("  fireEmployees:", row.fireEmployees)
            print("  changeRanks:", row.changeRanks)
            print("  viewReports:", row.viewReports)
            print("  accessSettings:", row.accessSettings)
        else
            print("Grade", grade, ": No permissions found in database")
        end
    end
    
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Database Check',
        description = 'Database permissions checked - see server console',
        type = 'info'
    })
end, false)

-- Command to debug current rank permissions
RegisterCommand('debugrankpermissions', function(source, args, rawCommand)
    local src = source
    local Player = QBX:GetPlayer(src)
    
    -- Only allow police to use this command
    if not Player or Player.PlayerData.job.name ~= 'police' then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Error',
            description = 'You must be a police officer to use this command',
            type = 'error'
        })
        return
    end
    
    print("=== DEBUGGING RANK PERMISSIONS ===")
    
    local grade = Player.PlayerData.job.grade.level
    print("Your grade:", grade)
    
    -- Check database permissions
    local result = MySQL.Sync.fetchAll('SELECT * FROM pd_rank_permissions WHERE grade = ?', {grade})
    if #result > 0 then
        local row = result[1]
        print("Database permissions for grade", grade, ":")
        print("  viewEmployees:", row.viewEmployees)
        print("  viewBanking:", row.viewBanking)
        print("  hireEmployees:", row.hireEmployees)
        print("  fireEmployees:", row.fireEmployees)
        print("  changeRanks:", row.changeRanks)
        print("  viewReports:", row.viewReports)
        print("  accessSettings:", row.accessSettings)
    else
        print("No permissions found in database for grade", grade)
    end
    
    -- Test permission check
    local hasBanking = HasPermission(src, 'viewBanking')
    print("HasPermission check for viewBanking:", hasBanking)
    
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Debug Complete',
        description = 'Check server console for permission details',
        type = 'info'
    })
end, false)

-- Command to reset rank permissions to defaults
RegisterCommand('resetrankpermissions', function(source, args, rawCommand)
    local src = source
    local Player = QBX:GetPlayer(src)
    
    -- Only allow police to use this command
    if not Player or Player.PlayerData.job.name ~= 'police' then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Error',
            description = 'You must be a police officer to use this command',
            type = 'error'
        })
        return
    end
    
    print("Resetting rank permissions to defaults...")

    -- Clear existing permissions
    MySQL.Sync.execute('DELETE FROM pd_rank_permissions')

    -- Insert default permissions for all grades
    for grade = 1, 14 do
        local permissions = GetDefaultRankPermissions(grade)
        print("Resetting permissions for grade", grade, ":", json.encode(permissions))
        MySQL.Sync.execute([[
            INSERT INTO pd_rank_permissions
            (grade, viewEmployees, viewBanking, viewDisciplinary, hireEmployees, fireEmployees, changeRanks, viewReports, accessSettings)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ]], {
            grade,
            permissions.viewEmployees and 1 or 0,
            permissions.viewBanking and 1 or 0,
            permissions.viewDisciplinary and 1 or 0,
            permissions.hireEmployees and 1 or 0,
            permissions.fireEmployees and 1 or 0,
            permissions.changeRanks and 1 or 0,
            permissions.viewReports and 1 or 0,
            permissions.accessSettings and 1 or 0
        })
    end
    
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Rank Management',
        description = 'Rank permissions reset to defaults',
        type = 'success'
    })
    
    print("Rank permissions reset successfully")
end, false)

-- Check if player is boss
function IsBoss(source)
    local Player = QBX:GetPlayer(source)
    if not Player then return false end
    
    local job = Player.PlayerData.job
    if not job then return false end
    
    -- Case insensitive check for job name
    local jobName = string.lower(job.name)
    local jobGrade = string.lower(job.grade.name)
    
    -- Check if job is in the police job list and grade is chief
    for _, policeJob in pairs(Config.PoliceJob) do
        if jobName == string.lower(policeJob) and jobGrade == "chief" then
            return true
        end
    end
    
    -- Check against boss ranks list with case insensitivity
    for _, policeJob in pairs(Config.PoliceJob) do
        if jobName == string.lower(policeJob) then
            for _, rank in pairs(Config.BossRanks) do
                if jobGrade == string.lower(rank) then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Get all data
RegisterNetEvent('pd_boss:server:getData', function()
    local src = source
    local Player = QBX:GetPlayer(src)
    
    if not Player then return end

    -- Get funds (using tgg-banking if available)
    local funds = GetSocietyBalance(Player.PlayerData.job.name)
    
    -- Get employees
    local employees = {}
    local allPlayers = QBX:GetQBPlayers()
    
    for _, player in pairs(allPlayers) do
        if player.PlayerData.job.name == 'police' then
            table.insert(employees, {
                id = player.PlayerData.source,
                name = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname,
                rank = player.PlayerData.job.grade.name,
                grade = player.PlayerData.job.grade.level
            })
        end
    end
    
    -- Get players
    local players = {}
    for _, player in pairs(allPlayers) do
        if player.PlayerData.source ~= src and player.PlayerData.job.name ~= 'police' then
            table.insert(players, {
                id = player.PlayerData.source,
                name = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname,
                job = player.PlayerData.job.name
            })
        end
    end
    
    -- Define ranks (matching QBX police job grades from jobs.lua)
    local ranks = {
        {name = 'cadet', label = 'Cadet', grade = 1},
        {name = 'probationary officer', label = 'Probationary Officer', grade = 2},
        {name = 'officer', label = 'Officer', grade = 3},
        {name = 'senior officer', label = 'Senior Officer', grade = 4},
        {name = 'corporal', label = 'Corporal', grade = 5},
        {name = 'sergeant', label = 'Sergeant', grade = 6},
        {name = 'staff sergeant', label = 'Staff Sergeant', grade = 7},
        {name = 'lieutenant', label = 'Lieutenant', grade = 8},
        {name = 'captain', label = 'Captain', grade = 9},
        {name = 'major', label = 'Major', grade = 10},
        {name = 'commander', label = 'Commander', grade = 11},
        {name = 'deputy chief', label = 'Deputy Chief', grade = 12},
        {name = 'assistant chief', label = 'Assistant Chief', grade = 13},
        {name = 'chief', label = 'Chief', grade = 14}
    }

    -- Send data to client
    TriggerClientEvent('pd_boss:client:updateData', src, {
        funds = funds,
        employees = employees,
        players = players,
        ranks = ranks
    })
end)

-- Direct get data with NO permission checks - NOW INCLUDES OFFLINE EMPLOYEES
RegisterNetEvent('pd_boss:server:directGetData', function(forcedSrc)
    local src = forcedSrc or source
    local Player = QBX:GetPlayer(src)

    if not Player then
        print("Player not found")
        return
    end

    -- Get the boss's job name to query the correct department
    local bossJobName = Player.PlayerData.job.name

    -- Get funds for this specific department (using tgg-banking if available)
    local funds = GetSocietyBalance(bossJobName)

    print("=== LOADING FUNDS FOR DEPARTMENT ===")
    print("Department:", bossJobName, "Funds:", funds)

    -- Get ALL employees (online + offline) using single database query for performance
    local employees = {}

    -- Query database directly for all employees in the same department - much faster than per-player exports
    local dbEmployees = MySQL.Sync.fetchAll([[
        SELECT citizenid, charinfo, job
        FROM players
        WHERE JSON_EXTRACT(job, '$.name') = ?
    ]], {bossJobName})

    -- Get online players once for accurate online status
    local onlinePlayers = QBX:GetQBPlayers()
    local onlineCitizenIds = {}

    print("=== BUILDING ONLINE PLAYER MAP ===")
    print("Total online players:", onlinePlayers and #onlinePlayers or "nil")

    for _, player in pairs(onlinePlayers) do
        if player and player.PlayerData then
            onlineCitizenIds[player.PlayerData.citizenid] = player.PlayerData.source
            print("Online player:", player.PlayerData.citizenid, "->", player.PlayerData.source, "Job:", player.PlayerData.job.name)
        end
    end

    print("=== PROCESSING EMPLOYEES FROM DATABASE ===")
    print("Database employees found:", dbEmployees and #dbEmployees or 0)

    for _, emp in ipairs(dbEmployees or {}) do
        local charSuccess, charinfo = pcall(json.decode, emp.charinfo)
        local jobSuccess, job = pcall(json.decode, emp.job)

        if charSuccess and jobSuccess and charinfo and job then
            local isOnline = onlineCitizenIds[emp.citizenid] ~= nil
            local empName = (charinfo.firstname or 'Unknown') .. ' ' .. (charinfo.lastname or '')

            print("Employee:", empName, "CitizenID:", emp.citizenid, "Online:", isOnline)

            table.insert(employees, {
                id = onlineCitizenIds[emp.citizenid] or nil,
                citizenid = emp.citizenid,
                name = empName,
                rank = job.grade and job.grade.name or 'Unknown',
                grade = job.grade and job.grade.level or 0,
                online = isOnline
            })
        end
    end

    print("=== EMPLOYEE SUMMARY ===")
    local onlineCount = 0
    local offlineCount = 0
    for _, emp in ipairs(employees) do
        if emp.online then onlineCount = onlineCount + 1 else offlineCount = offlineCount + 1 end
    end
    print("Online:", onlineCount, "Offline:", offlineCount)

    -- Get players for hiring (all online players not in boss's department, proximity will be checked client-side)
    local players = {}
    local allPlayers = QBX:GetQBPlayers()
    for _, player in pairs(allPlayers) do
        if player.PlayerData.source ~= src and
           player.PlayerData.job.name ~= bossJobName then
            table.insert(players, {
                id = player.PlayerData.source,
                name = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname,
                job = player.PlayerData.job.name
            })
        end
    end

    -- Get player's department for theming
    local department = Player.PlayerData.job.name or 'police'

    -- Define ranks based on department (matching QBX job grades from jobs.lua)
    local ranks
    if department == 'lscso' then
        ranks = Config.LSCSOanks or {
            {name = 'cadet', label = 'Cadet', grade = 1},
            {name = 'deputy', label = 'Deputy', grade = 2},
            {name = 'senior deputy', label = 'Senior Deputy', grade = 3},
            {name = 'corporal', label = 'Corporal', grade = 4},
            {name = 'sergeant', label = 'Sergeant', grade = 5},
            {name = 'staff sergeant', label = 'Staff Sergeant', grade = 6},
            {name = 'lieutenant', label = 'Lieutenant', grade = 7},
            {name = 'captain', label = 'Captain', grade = 8},
            {name = 'commander', label = 'Commander', grade = 9},
            {name = 'major', label = 'Major', grade = 10},
            {name = 'assistant chief deputy', label = 'Assistant Chief Deputy', grade = 11},
            {name = 'chief deputy', label = 'Chief Deputy', grade = 12},
            {name = 'assistant sheriff', label = 'Assistant Sheriff', grade = 13},
            {name = 'under sheriff', label = 'Under Sheriff', grade = 14},
            {name = 'sheriff', label = 'Sheriff', grade = 15}
        }
    elseif department == 'safr' then
        ranks = Config.SAFRRanks or {
            {name = 'emt', label = 'EMT', grade = 1},
            {name = 'paramedic', label = 'Paramedic', grade = 2},
            {name = 'doctor', label = 'Doctor', grade = 3},
            {name = 'captain', label = 'Captain', grade = 4},
            {name = 'medical coordinator', label = 'Medical Coordinator', grade = 5},
            {name = 'assistant chief', label = 'Assistant Chief', grade = 6},
            {name = 'deputy chief', label = 'Deputy Chief', grade = 7},
            {name = 'chief', label = 'Chief', grade = 8}
        }
    else
        ranks = Config.PoliceRanks or {
            {name = 'cadet', label = 'Cadet', grade = 1},
            {name = 'probationary officer', label = 'Probationary Officer', grade = 2},
            {name = 'officer', label = 'Officer', grade = 3},
            {name = 'senior officer', label = 'Senior Officer', grade = 4},
            {name = 'corporal', label = 'Corporal', grade = 5},
            {name = 'sergeant', label = 'Sergeant', grade = 6},
            {name = 'staff sergeant', label = 'Staff Sergeant', grade = 7},
            {name = 'lieutenant', label = 'Lieutenant', grade = 8},
            {name = 'captain', label = 'Captain', grade = 9},
            {name = 'major', label = 'Major', grade = 10},
            {name = 'commander', label = 'Commander', grade = 11},
            {name = 'deputy chief', label = 'Deputy Chief', grade = 12},
            {name = 'assistant chief', label = 'Assistant Chief', grade = 13},
            {name = 'chief', label = 'Chief', grade = 14}
        }
    end

    -- Get current user info for the client
    local currentUserInfo = {
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        rank = Player.PlayerData.job.grade.name,
        grade = Player.PlayerData.job.grade.level,
        citizenid = Player.PlayerData.citizenid
    }

    -- Send data to client with department info for theming
    TriggerClientEvent('pd_boss:client:updateData', src, {
        funds = funds,
        employees = employees,
        players = players,
        ranks = ranks,
        department = department,
        currentUser = currentUserInfo
    })

    -- Load and send transaction history for this department only
    local transactions = MySQL.Sync.fetchAll([[
        SELECT transaction_type, amount, officer_name, reason, balance_after, timestamp
        FROM pd_transactions
        WHERE department = ?
        ORDER BY timestamp DESC
        LIMIT 50
    ]], {department})

    print("=== LOADING TRANSACTIONS ON MENU OPEN ===")
    print("Department:", department, "Transactions found:", #transactions)

    -- Send transactions to client
    TriggerClientEvent('pd_boss:client:receiveTransactions', src, transactions)
end)

-- Get nearby players for hiring (proximity-based)
RegisterNetEvent('pd_boss:server:getNearbyPlayers', function()
    local src = source
    local Player = QBX:GetPlayer(src)
    
    if not Player then return end
    
    -- Get boss position from client
    TriggerClientEvent('pd_boss:client:getBossPosition', src)
end)

-- Handle boss position and find nearby players
RegisterNetEvent('pd_boss:server:findNearbyPlayers', function(bossCoords)
    local src = source
    local Boss = QBX:GetPlayer(src)
    if not Boss then return end

    local bossJobName = Boss.PlayerData.job.name
    local nearbyPlayers = {}
    local allPlayers = QBX:GetQBPlayers()

    for _, player in pairs(allPlayers) do
        -- Exclude players already in the boss's department (can't hire own employees)
        if player.PlayerData.job.name ~= bossJobName and player.PlayerData.source ~= src then
            -- Get target player position safely
            local targetPed = GetPlayerPed(player.PlayerData.source)
            if targetPed and targetPed ~= 0 then
                local targetCoords = GetEntityCoords(targetPed)
                local distance = #(bossCoords - targetCoords)
                
                -- Check if player is within hiring proximity (10 meters)
                if distance <= 10.0 then
                    table.insert(nearbyPlayers, {
                        id = player.PlayerData.source,
                        name = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname,
                        job = player.PlayerData.job.name,
                        distance = math.floor(distance * 10) / 10
                    })
                end
            end
        end
    end
    
    -- Send nearby players to client
    TriggerClientEvent('pd_boss:client:updateNearbyPlayers', src, nearbyPlayers)
end)

-- Listen for society vehicle purchases from jg-dealerships
-- This logs vehicle purchases made with society funds to the transaction history
AddEventHandler('pd_boss:server:societyVehiclePurchase', function(data)
    if not data or not data.department or not data.amount then
        print("[PD BOSS] Invalid vehicle purchase data received")
        return
    end

    local department = data.department
    local amount = data.amount
    local vehicle = data.vehicle or 'Unknown Vehicle'
    local plate = data.plate or 'N/A'
    local purchasedBy = data.purchasedBy or 'Unknown'

    print("=== SOCIETY VEHICLE PURCHASE ===")
    print("Department:", department)
    print("Vehicle:", vehicle)
    print("Plate:", plate)
    print("Amount:", amount)
    print("Purchased by:", purchasedBy)

    -- Get the new balance after the purchase
    local newBalance = GetSocietyBalance(department)

    -- Log the transaction to pd_transactions
    local reason = string.format('Vehicle Purchase: %s (Plate: %s)', vehicle, plate)

    MySQL.Sync.insert('INSERT INTO pd_transactions (department, transaction_type, amount, officer_name, officer_citizenid, reason, balance_after) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        department,
        'vehicle_purchase',
        amount,
        purchasedBy,
        'SYSTEM', -- No citizenid for system transactions
        reason,
        newBalance
    })

    print("[PD BOSS] Vehicle purchase logged to transactions for", department)

    -- Send Discord webhook for vehicle purchase
    SendDiscordWebhook('withdraw', department, {
        performerName = purchasedBy,
        performerRank = 'Command',
        amount = amount,
        newBalance = newBalance,
        reason = reason
    })
end)

-- Deposit money
RegisterNetEvent('pd_boss:server:deposit', function(data)
    local src = source
    local Player = QBX:GetPlayer(src)
    
    if not Player then 
        print("Player not found for deposit")
        return 
    end
    
    -- Get player's department early for notifications
    local department = Player.PlayerData.job.name

    -- Check if player has permission to view banking information
    if not HasPermission(src, 'viewBanking') then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Management',
            description = 'You do not have permission to access banking information',
            type = 'error'
        })
        return
    end

    -- Handle data object
    local amount = data.amount
    local reason = data.reason or 'Deposit to ' .. GetDeptLabel(department) .. ' funds'
    
    print("=== DEPOSIT DEBUG ===")
    print("Data type:", type(data))
    print("Raw data:", json.encode(data))
    print("Amount:", amount)
    print("Reason received:", data.reason)
    print("Final reason:", reason)
    print("Deposit request - Player:", Player.PlayerData.charinfo.firstname, "Amount:", amount)
    
    if not amount or amount <= 0 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Funds',
            description = 'Invalid amount',
            type = 'error'
        })
        return
    end

    if Player.Functions.RemoveMoney('cash', amount, 'pd-deposit') then
        -- Add to society account (using tgg-banking if available)
        AddSocietyMoney(department, amount)

        -- Get the new balance for logging
        local newBalance = GetSocietyBalance(department)

        -- Log the new balance
        print("Society account balance for", department, ":", newBalance)

        -- Log transaction to database
        local officerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
        -- reason is already set above

        print("=== LOGGING DEPOSIT TRANSACTION ===")
        print("Department:", department)
        print("Officer:", officerName)
        print("Amount:", amount)
        print("Reason:", reason)
        print("New Balance:", newBalance)

        -- Use MySQL.insert for better error handling - includes department
        local insertId = MySQL.Sync.insert('INSERT INTO pd_transactions (department, transaction_type, amount, officer_name, officer_citizenid, reason, balance_after) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            department,
            'deposit',
            amount,
            officerName,
            Player.PlayerData.citizenid,
            reason,
            newBalance
        })

        if insertId and insertId > 0 then
            print("Transaction logged successfully with ID:", insertId)
        else
            print("ERROR: Transaction insert failed! Insert ID:", insertId)
        end

        -- Verify the transaction was saved
        local verifyResult = MySQL.Sync.fetchAll('SELECT COUNT(*) as count FROM pd_transactions WHERE department = ?', {department})
        print("Total transactions in database for", department, ":", verifyResult[1] and verifyResult[1].count or "ERROR")

        print("Successfully deposited $", amount, "to PD funds")

        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Funds',
            description = 'Deposited $' .. amount,
            type = 'success'
        })

        -- Send Discord webhook
        local department = Player.PlayerData.job.name
        SendDiscordWebhook('deposit', department, {
            performerName = officerName,
            performerRank = Player.PlayerData.job.grade.name,
            amount = amount,
            newBalance = newBalance,
            reason = reason
        })

        -- Update data
        TriggerEvent('pd_boss:server:directGetData', src)
    else
        print("Failed to remove money from player - insufficient cash")
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Funds',
            description = 'Not enough cash',
            type = 'error'
        })
    end
end)

-- Withdraw money
RegisterNetEvent('pd_boss:server:withdraw', function(data)
    local src = source
    local Player = QBX:GetPlayer(src)

    if not Player then
        print("Player not found for withdraw")
        return
    end

    -- Get player's department early for notifications
    local department = Player.PlayerData.job.name

    -- Check if player has permission to view banking information
    if not HasPermission(src, 'viewBanking') then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Management',
            description = 'You do not have permission to access banking information',
            type = 'error'
        })
        return
    end

    -- Handle data object
    local amount = data.amount
    local reason = data.reason or 'Withdrawal from ' .. GetDeptLabel(department) .. ' funds'
    
    print("=== WITHDRAWAL DEBUG ===")
    print("Data type:", type(data))
    print("Raw data:", json.encode(data))
    print("Amount:", amount)
    print("Reason received:", data.reason)
    print("Final reason:", reason)
    print("Withdraw request - Player:", Player.PlayerData.charinfo.firstname, "Amount:", amount)
    
    if not amount or amount <= 0 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Funds',
            description = 'Invalid amount',
            type = 'error'
        })
        return
    end
    
    -- Get player's department for department-specific funds
    local department = Player.PlayerData.job.name

    -- Get current balance from society account (using tgg-banking if available)
    local currentFunds = GetSocietyBalance(department)

    print("Current", department, "funds:", currentFunds, "Requested withdraw:", amount)

    if currentFunds >= amount then
        -- Remove from society account (using tgg-banking if available)
        local success = RemoveSocietyMoney(department, amount)
        if not success then
            TriggerClientEvent('ox_lib:notify', src, {
                title = GetDeptLabel(department) .. ' Funds',
                description = 'Failed to withdraw from society account',
                type = 'error'
            })
            return
        end

        -- Get the new balance for logging
        local newBalance = GetSocietyBalance(department)
        print("Society account balance after withdrawal for", department, ":", newBalance)

        -- Log transaction to database
        local officerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname

        print("=== LOGGING WITHDRAWAL TRANSACTION ===")
        print("Department:", department)
        print("Officer:", officerName)
        print("Amount:", amount)
        print("Reason:", reason)
        print("New Balance:", newBalance)

        local insertId = MySQL.Sync.insert('INSERT INTO pd_transactions (department, transaction_type, amount, officer_name, officer_citizenid, reason, balance_after) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            department,
            'withdraw',
            amount,
            officerName,
            Player.PlayerData.citizenid,
            reason,
            newBalance
        })

        if insertId and insertId > 0 then
            print("Withdrawal transaction logged with ID:", insertId)
        else
            print("ERROR: Withdrawal transaction insert failed!")
        end

        -- Verify transaction count
        local verifyResult = MySQL.Sync.fetchAll('SELECT COUNT(*) as count FROM pd_transactions WHERE department = ?', {department})
        print("Total transactions for", department, "after withdrawal:", verifyResult[1] and verifyResult[1].count or "ERROR")
        
        -- Give player cash from PD funds
        print("=== ATTEMPTING TO GIVE PLAYER CASH ===")
        print("Player:", Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
        print("Amount:", amount)
        print("Player current cash before:", Player.PlayerData.money.cash)
        
        -- Try different approaches to give money
        local success = false
        
        -- Method 1: Try AddMoney
        success = Player.Functions.AddMoney('cash', amount, 'pd-withdraw')
        print("AddMoney result:", success)
        
        if not success then
            -- Method 2: Try direct money manipulation
            print("AddMoney failed, trying direct manipulation...")
            local currentCash = Player.PlayerData.money.cash or 0
            Player.PlayerData.money.cash = currentCash + amount
            Player.Functions.Save()
            success = true
            print("Direct manipulation result:", success)
        end
        
        -- Check player cash after
        local updatedPlayer = QBX:GetPlayer(src)
        if updatedPlayer then
            print("Player cash after:", updatedPlayer.PlayerData.money.cash)
        end
        
        if success then
            print("Successfully withdrew $", amount, "from PD funds")
            TriggerClientEvent('ox_lib:notify', src, {
                title = GetDeptLabel(department) .. ' Funds',
                description = 'Withdrew $' .. amount,
                type = 'success'
            })

            -- Send Discord webhook
            local department = Player.PlayerData.job.name
            SendDiscordWebhook('withdraw', department, {
                performerName = officerName,
                performerRank = Player.PlayerData.job.grade.name,
                amount = amount,
                newBalance = newBalance,
                reason = reason
            })
        else
            print("ERROR: Failed to give player cash!")
            TriggerClientEvent('ox_lib:notify', src, {
                title = GetDeptLabel(department) .. ' Funds',
                description = 'Error: Failed to give you cash',
                type = 'error'
            })
            return
        end

        -- Update data
        TriggerEvent('pd_boss:server:directGetData', src)
    else
        print("Insufficient PD funds - Current:", currentFunds, "Requested:", amount)
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Funds',
            description = 'Insufficient PD funds',
            type = 'error'
        })
    end
end)

-- Show notification
RegisterNetEvent('pd_boss:server:showNotification', function(data)
    local src = source
    TriggerClientEvent('ox_lib:notify', src, {
        title = data.title or 'PD Boss Menu',
        description = data.message or 'Notification',
        type = data.type or 'info'
    })
end)

-- Hire player
RegisterNetEvent('pd_boss:server:hire', function(playerId, rank)
    local src = source
    local Player = QBX:GetPlayer(src)
    local targetPlayer = QBX:GetPlayer(playerId)

    -- Get boss's department early for notifications and hiring
    local department = Player and Player.PlayerData.job.name or 'police'

    -- Check if player has permission to hire employees
    if not HasPermission(src, 'hireEmployees') then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Management',
            description = 'You do not have permission to hire employees',
            type = 'error'
        })
        return
    end
    
    if not targetPlayer then 
        print("Target player not found for hiring")
        return 
    end
    
    -- Find the grade level for the rank (matching QBX police job grades from jobs.lua)
    local gradeLevel = 1  -- Default to Cadet
    for _, rankData in pairs({
        {name = 'cadet', grade = 1},
        {name = 'probationary officer', grade = 2},
        {name = 'officer', grade = 3},
        {name = 'senior officer', grade = 4},
        {name = 'corporal', grade = 5},
        {name = 'sergeant', grade = 6},
        {name = 'staff sergeant', grade = 7},
        {name = 'lieutenant', grade = 8},
        {name = 'captain', grade = 9},
        {name = 'major', grade = 10},
        {name = 'commander', grade = 11},
        {name = 'deputy chief', grade = 12},
        {name = 'assistant chief', grade = 13},
        {name = 'chief', grade = 14}
    }) do
        if string.lower(rankData.name) == string.lower(rank) then
            gradeLevel = rankData.grade
            break
        end
    end

    -- Set the job to boss's department with the specified rank
    targetPlayer.Functions.SetJob(department, gradeLevel)

    -- Immediately show success notification
    TriggerClientEvent('ox_lib:notify', src, {
        title = GetDeptLabel(department) .. ' Management',
        description = 'Hired ' .. targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname .. ' as ' .. rank,
        type = 'success'
    })

    TriggerClientEvent('ox_lib:notify', playerId, {
        title = GetDeptLabel(department),
        description = 'You have been hired by ' .. GetDeptLabel(department) .. ' as ' .. rank,
        type = 'success'
    })

    -- Send Discord webhook
    local bossPlayer = QBX:GetPlayer(src)
    if bossPlayer then
        local bossName = bossPlayer.PlayerData.charinfo.firstname .. ' ' .. bossPlayer.PlayerData.charinfo.lastname
        local bossRank = bossPlayer.PlayerData.job.grade.name
        SendDiscordWebhook('hire', department, {
            performerName = bossName,
            performerRank = bossRank,
            targetName = targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname,
            rank = rank
        })
    end

    -- Refresh data for the boss immediately
    TriggerEvent('pd_boss:server:directGetData', src)
end)

-- Fire player (supports both online and offline via citizenid)
RegisterNetEvent('pd_boss:server:fire', function(playerIdOrCitizenId)
    local src = source
    local Player = QBX:GetPlayer(src)
    local department = Player and Player.PlayerData.job.name or 'police'

    -- Check if player has permission to fire employees
    if not HasPermission(src, 'fireEmployees') then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Management',
            description = 'You do not have permission to fire employees',
            type = 'error'
        })
        return
    end

    local targetPlayer = nil
    local citizenid = nil
    local isOnline = false
    local playerName = 'Unknown'

    -- Check if we received a server ID (number) or citizenid (string)
    if type(playerIdOrCitizenId) == 'number' then
        -- Online player by server ID
        targetPlayer = QBX:GetPlayer(playerIdOrCitizenId)
        if targetPlayer then
            citizenid = targetPlayer.PlayerData.citizenid
            isOnline = true
            playerName = targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname
        end
    elseif type(playerIdOrCitizenId) == 'string' then
        -- Could be citizenid - check online first, then offline
        citizenid = playerIdOrCitizenId
        targetPlayer = exports.qbx_core:GetPlayerByCitizenId(citizenid)
        if targetPlayer then
            isOnline = true
            playerName = targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname
        else
            -- Try offline player
            local offlineSuccess, offlinePlayer = pcall(function()
                return exports.qbx_core:GetOfflinePlayer(citizenid)
            end)
            if offlineSuccess and offlinePlayer and offlinePlayer.PlayerData then
                targetPlayer = offlinePlayer
                playerName = offlinePlayer.PlayerData.charinfo.firstname .. ' ' .. offlinePlayer.PlayerData.charinfo.lastname
                isOnline = false
            end
        end
    end

    if not citizenid then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Management',
            description = 'Player not found',
            type = 'error'
        })
        return
    end

    print("Firing employee - CitizenID:", citizenid, "Online:", isOnline, "Name:", playerName)

    -- Try QBX core method first (works for both online and offline)
    local success, errorResult = pcall(function()
        return exports.qbx_core:RemovePlayerFromJob(citizenid, 'police')
    end)

    -- Capture previous rank for webhook before firing
    local previousRank = nil
    if targetPlayer and targetPlayer.PlayerData and targetPlayer.PlayerData.job then
        previousRank = targetPlayer.PlayerData.job.grade.name
    end

    if success then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Management',
            description = 'Fired ' .. playerName,
            type = 'success'
        })

        -- Notify target if online
        if isOnline and targetPlayer then
            TriggerClientEvent('ox_lib:notify', targetPlayer.PlayerData.source, {
                title = GetDeptLabel(department) .. ' Management',
                description = 'You have been fired from the Police Department',
                type = 'error'
            })
        end

        -- Send Discord webhook
        local bossPlayer = QBX:GetPlayer(src)
        if bossPlayer then
            local bossName = bossPlayer.PlayerData.charinfo.firstname .. ' ' .. bossPlayer.PlayerData.charinfo.lastname
            local bossRank = bossPlayer.PlayerData.job.grade.name
            local department = bossPlayer.PlayerData.job.name
            SendDiscordWebhook('fire', department, {
                performerName = bossName,
                performerRank = bossRank,
                targetName = playerName,
                previousRank = previousRank
            })
        end

        -- Refresh data for the boss immediately
        TriggerEvent('pd_boss:server:directGetData', src)
    else
        print("QBX RemovePlayerFromJob failed, attempting fallback:", errorResult)

        -- Fallback: Update database directly
        local fallbackSuccess = pcall(function()
            MySQL.Sync.execute('UPDATE players SET job = ? WHERE citizenid = ?', {
                json.encode({
                    name = 'unemployed',
                    label = 'Unemployed',
                    payment = 0,
                    onduty = false,
                    grade = {
                        name = 'unemployed',
                        level = 0
                    }
                }),
                citizenid
            })
        end)

        if fallbackSuccess then
            TriggerClientEvent('ox_lib:notify', src, {
                title = GetDeptLabel(department) .. ' Management',
                description = 'Fired ' .. playerName,
                type = 'success'
            })

            if isOnline and targetPlayer then
                TriggerClientEvent('ox_lib:notify', targetPlayer.PlayerData.source, {
                    title = GetDeptLabel(department) .. ' Management',
                    description = 'You have been fired from the Police Department',
                    type = 'error'
                })
            end

            TriggerEvent('pd_boss:server:directGetData', src)
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = GetDeptLabel(department) .. ' Management',
                description = 'Failed to fire employee',
                type = 'error'
            })
        end
    end
end)

-- Permission checking function
function HasPermission(source, permission)
    local Player = QBX:GetPlayer(source)
    if not Player then return false end

    local job = Player.PlayerData.job
    if not job then return false end

    -- Check if player is in a supported LEO job (police or lscso)
    local supportedJobs = Config.SupportedJobs or {'police', 'lscso'}
    local isSupported = false
    for _, supportedJob in ipairs(supportedJobs) do
        if job.name == supportedJob then
            isSupported = true
            break
        end
    end

    if not isSupported then
        print("HasPermission: Job", job.name, "is not a supported LEO job")
        return false
    end

    -- Boss grades (11+) always have full permissions
    local grade = job.grade and job.grade.level or 0
    if grade >= 11 then
        print("HasPermission: Boss grade", grade, "- granting", permission)
        return true
    end

    -- For non-boss ranks, check database permissions
    local permissions = GetRankPermissions(grade)
    if permissions and permissions[permission] then
        return true
    end

    -- Fallback to default permissions
    local defaultPerms = GetDefaultRankPermissions(grade)
    if defaultPerms and defaultPerms[permission] then
        return true
    end

    return false
end

-- Get default permissions for a specific rank grade
function GetDefaultRankPermissions(grade)
    -- Default permissions based on rank hierarchy (matching jobs.lua grades 1-14)
    -- Lower ranks (1-5): Basic view permissions only
    -- Mid ranks (6-10): View + some management
    -- Boss ranks (11-14): Full access including bonus payments
    local defaultPermissions = {
        [1] = { -- Cadet
            viewEmployees = true,
            viewBanking = false,
            viewDisciplinary = false,
            hireEmployees = false,
            fireEmployees = false,
            changeRanks = false,
            viewReports = false,
            accessSettings = false,
            payBonuses = false
        },
        [2] = { -- Probationary Officer
            viewEmployees = true,
            viewBanking = false,
            viewDisciplinary = false,
            hireEmployees = false,
            fireEmployees = false,
            changeRanks = false,
            viewReports = false,
            accessSettings = false,
            payBonuses = false
        },
        [3] = { -- Officer
            viewEmployees = true,
            viewBanking = false,
            viewDisciplinary = true,
            hireEmployees = false,
            fireEmployees = false,
            changeRanks = false,
            viewReports = false,
            accessSettings = false,
            payBonuses = false
        },
        [4] = { -- Senior Officer
            viewEmployees = true,
            viewBanking = false,
            viewDisciplinary = true,
            hireEmployees = false,
            fireEmployees = false,
            changeRanks = false,
            viewReports = false,
            accessSettings = false,
            payBonuses = false
        },
        [5] = { -- Corporal
            viewEmployees = true,
            viewBanking = false,
            viewDisciplinary = true,
            hireEmployees = false,
            fireEmployees = false,
            changeRanks = false,
            viewReports = true,
            accessSettings = false,
            payBonuses = false
        },
        [6] = { -- Sergeant
            viewEmployees = true,
            viewBanking = true,
            viewDisciplinary = true,
            hireEmployees = false,
            fireEmployees = false,
            changeRanks = false,
            viewReports = true,
            accessSettings = false,
            payBonuses = false
        },
        [7] = { -- Staff Sergeant
            viewEmployees = true,
            viewBanking = true,
            viewDisciplinary = true,
            hireEmployees = false,
            fireEmployees = false,
            changeRanks = false,
            viewReports = true,
            accessSettings = false,
            payBonuses = false
        },
        [8] = { -- Lieutenant
            viewEmployees = true,
            viewBanking = true,
            viewDisciplinary = true,
            hireEmployees = true,
            fireEmployees = false,
            changeRanks = false,
            viewReports = true,
            accessSettings = false,
            payBonuses = false
        },
        [9] = { -- Captain
            viewEmployees = true,
            viewBanking = true,
            viewDisciplinary = true,
            hireEmployees = true,
            fireEmployees = false,
            changeRanks = true,
            viewReports = true,
            accessSettings = false,
            payBonuses = false
        },
        [10] = { -- Major
            viewEmployees = true,
            viewBanking = true,
            viewDisciplinary = true,
            hireEmployees = true,
            fireEmployees = true,
            changeRanks = true,
            viewReports = true,
            accessSettings = false,
            payBonuses = false
        },
        [11] = { -- Commander (isboss) - CAN PAY BONUSES
            viewEmployees = true,
            viewBanking = true,
            viewDisciplinary = true,
            hireEmployees = true,
            fireEmployees = true,
            changeRanks = true,
            viewReports = true,
            accessSettings = true,
            payBonuses = true
        },
        [12] = { -- Deputy Chief (isboss) - CAN PAY BONUSES
            viewEmployees = true,
            viewBanking = true,
            viewDisciplinary = true,
            hireEmployees = true,
            fireEmployees = true,
            changeRanks = true,
            viewReports = true,
            accessSettings = true,
            payBonuses = true
        },
        [13] = { -- Assistant Chief (isboss) - CAN PAY BONUSES
            viewEmployees = true,
            viewBanking = true,
            viewDisciplinary = true,
            hireEmployees = true,
            fireEmployees = true,
            changeRanks = true,
            viewReports = true,
            accessSettings = true,
            payBonuses = true
        },
        [14] = { -- Chief (isboss) - CAN PAY BONUSES
            viewEmployees = true,
            viewBanking = true,
            viewDisciplinary = true,
            hireEmployees = true,
            fireEmployees = true,
            changeRanks = true,
            viewReports = true,
            accessSettings = true,
            payBonuses = true
        }
    }

    return defaultPermissions[grade] or {}
end

-- Get permissions for a specific rank grade from database
function GetRankPermissions(grade)
    local result = MySQL.Sync.fetchAll('SELECT * FROM pd_rank_permissions WHERE grade = ?', {grade})

    if #result > 0 then
        local row = result[1]
        local permissions = {
            viewEmployees = (row.viewEmployees == 1 or row.viewEmployees == true),
            viewBanking = (row.viewBanking == 1 or row.viewBanking == true),
            viewDisciplinary = (row.viewDisciplinary == 1 or row.viewDisciplinary == true),
            hireEmployees = (row.hireEmployees == 1 or row.hireEmployees == true),
            fireEmployees = (row.fireEmployees == 1 or row.fireEmployees == true),
            changeRanks = (row.changeRanks == 1 or row.changeRanks == true),
            viewReports = (row.viewReports == 1 or row.viewReports == true),
            accessSettings = (row.accessSettings == 1 or row.accessSettings == true),
            payBonuses = (row.payBonuses == 1 or row.payBonuses == true)
        }
        return permissions
    else
        -- Fallback to default permissions if not found in database
        return GetDefaultRankPermissions(grade)
    end
end

-- Set rank (supports both online and offline players via citizenid)
RegisterNetEvent('pd_boss:server:setRank', function(data)
    local src = source
    local Player = QBX:GetPlayer(src)
    local department = Player and Player.PlayerData.job.name or 'police'
    local playerId = data.playerId
    local citizenid = data.citizenid
    local playerName = data.playerName
    local rank = data.rank

    print("SetRank called with data:", json.encode(data))

    -- Check if player has permission to change ranks
    if not HasPermission(src, 'changeRanks') then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Management',
            description = 'You do not have permission to change ranks',
            type = 'error'
        })
        return
    end

    -- Handle multiple identification methods: citizenid, playerId, or playerName
    local targetPlayer = nil
    local isOnline = false
    local targetCitizenId = citizenid
    local targetName = playerName or 'Unknown'

    -- Method 1: Direct citizenid provided
    if citizenid then
        targetPlayer = exports.qbx_core:GetPlayerByCitizenId(citizenid)
        if targetPlayer then
            isOnline = true
            targetName = targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname
        else
            -- Try offline player
            local offlineSuccess, offlinePlayer = pcall(function()
                return exports.qbx_core:GetOfflinePlayer(citizenid)
            end)
            if offlineSuccess and offlinePlayer and offlinePlayer.PlayerData then
                targetPlayer = offlinePlayer
                targetName = offlinePlayer.PlayerData.charinfo.firstname .. ' ' .. offlinePlayer.PlayerData.charinfo.lastname
                isOnline = false
            end
        end
    -- Method 2: Server ID provided
    elseif playerId and type(playerId) == 'number' then
        targetPlayer = QBX:GetPlayer(playerId)
        if targetPlayer then
            isOnline = true
            targetCitizenId = targetPlayer.PlayerData.citizenid
            targetName = targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname
        end
    -- Method 3: Player name provided (search online players)
    elseif playerName then
        local allPlayers = QBX:GetQBPlayers()
        for _, player in pairs(allPlayers) do
            local fullName = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
            if fullName == playerName then
                targetPlayer = player
                playerId = player.PlayerData.source
                targetCitizenId = player.PlayerData.citizenid
                isOnline = true
                break
            end
        end
    end

    if not targetPlayer or not targetCitizenId then
        print("Target player not found for rank change")
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Management',
            description = 'Target player not found',
            type = 'error'
        })
        return
    end

    print("Target player found:", targetName, "Online:", isOnline, "CitizenID:", targetCitizenId)
    print("Current job:", targetPlayer.PlayerData.job.name)
    print("Current grade:", targetPlayer.PlayerData.job.grade.level)

    -- Check if target player is in a supported job
    local currentJob = targetPlayer.PlayerData.job.name
    local supportedJobs = Config.SupportedJobs or {'police', 'lscso', 'safr'}
    local isSupported = false
    for _, job in ipairs(supportedJobs) do
        if currentJob == job then
            isSupported = true
            break
        end
    end

    if not isSupported then
        print("Player not in supported job, current job:", currentJob)
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Department Management',
            description = 'Player must be in a supported department. Current job: ' .. currentJob,
            type = 'error'
        })
        return
    end

    -- Get the appropriate rank config for the department
    local rankConfig
    if currentJob == 'lscso' then
        rankConfig = Config.LSCSOanks
    elseif currentJob == 'safr' then
        rankConfig = Config.SAFRRanks
    else
        rankConfig = Config.PoliceRanks
    end

    -- Find the grade level for the rank
    local gradeLevel = 1  -- Default to lowest rank
    for _, rankData in pairs(rankConfig) do
        if string.lower(rankData.name) == string.lower(rank) then
            gradeLevel = rankData.grade
            break
        end
    end

    print("Setting rank to:", rank, "with grade level:", gradeLevel, "for job:", currentJob)

    -- Try QBX core method (works for both online and offline)
    local success, errorResult = pcall(function()
        return exports.qbx_core:AddPlayerToJob(targetCitizenId, currentJob, gradeLevel)
    end)

    -- Capture previous rank for webhook
    local previousRank = nil
    local previousGrade = 0
    if targetPlayer and targetPlayer.PlayerData and targetPlayer.PlayerData.job then
        previousRank = targetPlayer.PlayerData.job.grade.name
        previousGrade = targetPlayer.PlayerData.job.grade.level or 0
    end

    -- Get department display name
    local deptInfo = Config.DepartmentInfo and Config.DepartmentInfo[currentJob]
    local deptTitle = deptInfo and deptInfo.shortName or string.upper(currentJob)

    if success then
        TriggerClientEvent('ox_lib:notify', src, {
            title = deptTitle,
            description = 'Rank for ' .. targetName .. ' changed to ' .. rank,
            type = 'success'
        })

        -- Notify target if online
        if isOnline and targetPlayer.PlayerData.source then
            TriggerClientEvent('ox_lib:notify', targetPlayer.PlayerData.source, {
                title = deptTitle,
                description = 'Your rank has been changed to ' .. rank,
                type = 'success'
            })
        end

        -- Send Discord webhook (determine if promote or demote)
        local bossPlayer = QBX:GetPlayer(src)
        if bossPlayer then
            local bossName = bossPlayer.PlayerData.charinfo.firstname .. ' ' .. bossPlayer.PlayerData.charinfo.lastname
            local bossRank = bossPlayer.PlayerData.job.grade.name
            local department = bossPlayer.PlayerData.job.name
            local actionType = gradeLevel > previousGrade and 'promote' or 'demote'
            SendDiscordWebhook(actionType, department, {
                performerName = bossName,
                performerRank = bossRank,
                targetName = targetName,
                previousRank = previousRank,
                newRank = rank
            })
        end

        -- Refresh data for the boss immediately
        TriggerEvent('pd_boss:server:directGetData', src)
    else
        print("QBX AddPlayerToJob failed, attempting fallback:", errorResult)

        -- Fallback: Try to update the job directly in the database
        local deptLabel = deptInfo and deptInfo.name or currentJob
        local fallbackSuccess, fallbackError = pcall(function()
            MySQL.Sync.execute('UPDATE players SET job = ? WHERE citizenid = ?', {
                json.encode({
                    name = currentJob,
                    label = deptLabel,
                    payment = 0,
                    onduty = true,
                    grade = {
                        name = rank,
                        level = gradeLevel
                    }
                }),
                targetCitizenId
            })
        end)

        if fallbackSuccess then
            TriggerClientEvent('ox_lib:notify', src, {
                title = deptTitle,
                description = 'Rank for ' .. targetName .. ' changed to ' .. rank,
                type = 'success'
            })

            if isOnline and targetPlayer.PlayerData.source then
                TriggerClientEvent('ox_lib:notify', targetPlayer.PlayerData.source, {
                    title = deptTitle,
                    description = 'Your rank has been changed to ' .. rank,
                    type = 'success'
                })
            end

            TriggerEvent('pd_boss:server:directGetData', src)
        else
            print("Fallback method also failed:", fallbackError)
            TriggerClientEvent('ox_lib:notify', src, {
                title = deptTitle,
                description = 'Failed to change rank: ' .. tostring(errorResult),
                type = 'error'
            })
        end
    end
end)

-- Get rank permissions
RegisterNetEvent('pd_boss:server:getRankPermissions', function()
    local src = source
    local Player = QBX:GetPlayer(src)
    if not Player then return end

    local department = Player.PlayerData.job.name
    local gradeName = Player.PlayerData.job.grade.name

    -- Get rank config for department
    local rankConfig
    local maxGrade
    if department == 'lscso' then
        rankConfig = Config.LSCSOanks
        maxGrade = 15
    elseif department == 'safr' then
        rankConfig = Config.SAFRRanks
        maxGrade = 8
    else
        rankConfig = Config.PoliceRanks
        maxGrade = 14
    end

    -- Check if player is top rank (Chief/Sheriff) - override permission check
    local isTopRank = gradeName and string.lower(gradeName) == 'chief' or string.lower(gradeName) == 'sheriff'

    if not isTopRank and not HasPermission(src, 'accessSettings') then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Department Management',
            description = 'You do not have permission to access rank settings',
            type = 'error'
        })
        return
    end

    -- Get current permissions from database or use defaults
    local permissions = {}

    -- Load all ranks from job configuration
    for grade = 1, maxGrade do
        local rankPermissions = GetRankPermissions(grade)
        permissions[tostring(grade)] = rankPermissions
    end

    TriggerClientEvent('pd_boss:client:updateRankPermissions', src, permissions)
end)

-- Save rank permissions
RegisterNetEvent('pd_boss:server:saveRankPermissions', function(permissions)
    local src = source
    local Player = QBX:GetPlayer(src)
    if not Player then return end

    local gradeName = Player.PlayerData.job.grade.name

    -- Check if player is top rank (Chief/Sheriff) - override permission check
    local isTopRank = gradeName and (string.lower(gradeName) == 'chief' or string.lower(gradeName) == 'sheriff')

    if not isTopRank and not HasPermission(src, 'accessSettings') then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Department Management',
            description = 'You do not have permission to modify rank settings',
            type = 'error'
        })
        return
    end
    
    -- Save permissions to database
    for grade, rankPermissions in pairs(permissions) do
        
        MySQL.Sync.execute([[
            REPLACE INTO pd_rank_permissions 
            (grade, viewEmployees, viewBanking, viewDisciplinary, hireEmployees, fireEmployees, changeRanks, viewReports, accessSettings) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ]], {
            tonumber(grade),
            rankPermissions.viewEmployees and 1 or 0,
            rankPermissions.viewBanking and 1 or 0,
            rankPermissions.viewDisciplinary and 1 or 0,
            rankPermissions.hireEmployees and 1 or 0,
            rankPermissions.fireEmployees and 1 or 0,
            rankPermissions.changeRanks and 1 or 0,
            rankPermissions.viewReports and 1 or 0,
            rankPermissions.accessSettings and 1 or 0
        })
    end
    
    
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Rank Management',
        description = 'Rank permissions updated successfully',
        type = 'success'
    })
    
    -- Force refresh user permissions after saving rank permissions with delay
    SetTimeout(500, function()
        -- Check if player is still connected before refreshing
        local currentPlayer = QBX:GetPlayer(src)
        if currentPlayer and currentPlayer.PlayerData.job.name == 'police' then
            TriggerEvent('pd_boss:server:getUserPermissions', src)
        else
            print("Player no longer available for permission refresh")
        end
    end)
end)

-- Get current user's permissions
RegisterNetEvent('pd_boss:server:getUserPermissions', function()
    local src = source
    local Player = QBX:GetPlayer(src)

    -- Check if player exists and is in a supported job
    local isSupportedJob = false
    local jobName = nil
    if Player and Player.PlayerData.job then
        jobName = Player.PlayerData.job.name
        for _, supportedJob in ipairs(Config.SupportedJobs or {'police', 'lscso'}) do
            if jobName == supportedJob then
                isSupportedJob = true
                break
            end
        end
    end

    if not Player or not isSupportedJob then
        print("Player not found or not in supported LEO job")
        TriggerClientEvent('pd_boss:client:updateUserPermissions', src, {
            viewEmployees = false,
            viewBanking = false,
            viewDisciplinary = false,
            hireEmployees = false,
            fireEmployees = false,
            changeRanks = false,
            viewReports = false,
            accessSettings = false,
            payBonuses = false
        })
        return
    end

    local grade = Player.PlayerData.job.grade.level
    local gradeName = Player.PlayerData.job.grade.name

    print("Getting permissions for player:", Player.PlayerData.charinfo.firstname, "Job:", jobName, "Grade:", grade, "Grade Name:", gradeName)

    -- Get permissions based on the player's actual rank grade
    local permissions = GetRankPermissions(grade)
    -- If no permissions found, use defaults but ensure they're not empty
    if not permissions or next(permissions) == nil then
        permissions = GetDefaultRankPermissions(grade)
    end
    
    -- If permissions are still empty, force initialize the database for this grade
    if not permissions or next(permissions) == nil then
        local defaultPermissions = GetDefaultRankPermissions(grade)
        MySQL.Sync.execute([[
            REPLACE INTO pd_rank_permissions 
            (grade, viewEmployees, viewBanking, viewDisciplinary, hireEmployees, fireEmployees, changeRanks, viewReports, accessSettings) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ]], {
            grade,
            defaultPermissions.viewEmployees and 1 or 0,
            defaultPermissions.viewBanking and 1 or 0,
            defaultPermissions.viewDisciplinary and 1 or 0,
            defaultPermissions.hireEmployees and 1 or 0,
            defaultPermissions.fireEmployees and 1 or 0,
            defaultPermissions.changeRanks and 1 or 0,
            defaultPermissions.viewReports and 1 or 0,
            defaultPermissions.accessSettings and 1 or 0
        })
        permissions = defaultPermissions
    end
    
    -- Boss override: Grade 11+ (boss ranks) always get full permissions
    -- This ensures bosses can always manage their department regardless of database state
    if grade >= 11 then
        print("Boss grade detected (" .. grade .. ") - granting full permissions")
        permissions = {
            viewEmployees = true,
            viewBanking = true,
            viewDisciplinary = true,
            hireEmployees = true,
            fireEmployees = true,
            changeRanks = true,
            viewReports = true,
            accessSettings = true,
            payBonuses = true
        }
    else
        -- Only set missing permissions to defaults for non-boss ranks
        if permissions.viewEmployees == nil then permissions.viewEmployees = true end
        if permissions.viewBanking == nil then permissions.viewBanking = true end
        if permissions.viewDisciplinary == nil then permissions.viewDisciplinary = true end
        if permissions.hireEmployees == nil then permissions.hireEmployees = true end
        if permissions.fireEmployees == nil then permissions.fireEmployees = true end
        if permissions.changeRanks == nil then permissions.changeRanks = true end
        if permissions.viewReports == nil then permissions.viewReports = true end
        if permissions.accessSettings == nil then permissions.accessSettings = true end
    end

    print("Sending permissions to client:", json.encode(permissions))
    TriggerClientEvent('pd_boss:client:updateUserPermissions', src, permissions)
end)

-- Simple NUI callback for fire requests
if RegisterNUICallback then
    RegisterNUICallback('fire', function(data, cb)
        local targetPlayer = nil
        
        if data.playerId then
            targetPlayer = QBX:GetPlayer(data.playerId)
        elseif data.playerName then
            local allPlayers = QBX:GetQBPlayers()
            for _, player in pairs(allPlayers) do
                local fullName = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
                if fullName == data.playerName then
                    targetPlayer = player
                    break
                end
            end
        end
        
        if not HasPermission(source, 'fireEmployees') then
            cb('ok')
            return
        end
        
        if not targetPlayer then 
            cb('ok')
            return 
        end
        
        -- Set job to unemployed with error handling
        local success, error = pcall(function()
            targetPlayer.Functions.SetJob('unemployed', 0)
        end)
        
        if success then
            TriggerClientEvent('ox_lib:notify', source, {
                title = GetDeptLabel(department) .. ' Management',
                description = 'Fired ' .. targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname,
                type = 'success'
            })
            
            TriggerClientEvent('ox_lib:notify', targetPlayer.PlayerData.source, {
                title = GetDeptLabel(department) .. ' Management',
                description = 'You have been fired from the Police Department',
                type = 'error'
            })
            
            TriggerEvent('pd_boss:server:directGetData', source)
            cb('ok')
        else
            print("Error firing player:", error)
            TriggerClientEvent('ox_lib:notify', source, {
                title = GetDeptLabel(department) .. ' Management',
                description = 'Failed to fire employee: ' .. tostring(error),
                type = 'error'
            })
            cb('error')
        end
    end)
end

-- Get transaction history
RegisterNetEvent('pd_boss:server:getTransactions', function()
    local src = source
    local Player = QBX:GetPlayer(src)

    print("=== GET TRANSACTIONS EVENT TRIGGERED ===")
    print("Source:", src)

    if not Player then
        TriggerClientEvent('pd_boss:client:receiveTransactions', src, {})
        return
    end

    -- Check if player has permission to view banking information
    if not HasPermission(src, 'viewBanking') then
        print("Player does not have viewBanking permission")
        TriggerClientEvent('pd_boss:client:receiveTransactions', src, {})
        return
    end

    -- Get player's department for department-specific transactions
    local department = Player.PlayerData.job.name

    -- Using async query to avoid blocking server thread
    local transactions = MySQL.query.await([[
        SELECT transaction_type, amount, officer_name, reason, balance_after, timestamp
        FROM pd_transactions
        WHERE department = ?
        ORDER BY timestamp DESC
        LIMIT 50
    ]], {department}) or {}

    TriggerClientEvent('pd_boss:client:receiveTransactions', src, transactions)
end)

-- Simple server event to trigger transaction loading
RegisterNetEvent('pd_boss:server:requestTransactions', function()
    local src = source
    local Player = QBX:GetPlayer(src)

    if not Player then return end

    -- Check if player has permission to view banking information
    if not HasPermission(src, 'viewBanking') then return end

    -- Get player's department for department-specific transactions
    local department = Player.PlayerData.job.name

    -- Using async query to avoid blocking server thread
    local transactions = MySQL.query.await([[
        SELECT transaction_type, amount, officer_name, reason, balance_after, timestamp
        FROM pd_transactions
        WHERE department = ?
        ORDER BY timestamp DESC
        LIMIT 50
    ]], {department}) or {}

    TriggerClientEvent('pd_boss:client:receiveTransactions', src, transactions)
end)

-- Export Transactions with Filters (debug prints removed for performance)
RegisterNetEvent('pd_boss:server:getExportTransactions', function(filters)
    local src = source
    local Player = QBX:GetPlayer(src)

    if not Player then
        TriggerClientEvent('pd_boss:client:receiveExportTransactions', src, { success = false, message = "Player not found", transactions = {} })
        return
    end

    -- Check permission
    if not HasPermission(src, 'viewBanking') then
        TriggerClientEvent('pd_boss:client:receiveExportTransactions', src, { success = false, message = "No permission", transactions = {} })
        return
    end

    -- Get player's department
    local department = Player.PlayerData.job.name

    -- Build query with filters
    local query = [[
        SELECT transaction_type, amount, officer_name, reason, balance_after, timestamp
        FROM pd_transactions
        WHERE department = ?
    ]]

    local params = { department }

    -- Add date filters
    if filters.start_date and filters.start_date ~= '' then
        query = query .. " AND DATE(timestamp) >= ?"
        table.insert(params, filters.start_date)
    end

    if filters.end_date and filters.end_date ~= '' then
        query = query .. " AND DATE(timestamp) <= ?"
        table.insert(params, filters.end_date)
    end

    -- Add officer name filter
    if filters.officer_name and filters.officer_name ~= '' then
        query = query .. " AND officer_name LIKE ?"
        table.insert(params, "%" .. filters.officer_name .. "%")
    end

    -- Add type filter
    if filters.type and filters.type ~= '' then
        query = query .. " AND transaction_type = ?"
        table.insert(params, filters.type)
    end

    query = query .. " ORDER BY timestamp DESC LIMIT 200" -- Reduced from 1000 for performance

    -- Using async query to avoid blocking server thread
    local transactions = MySQL.query.await(query, params) or {}

    -- Send back to client
    TriggerClientEvent('pd_boss:client:receiveExportTransactions', src, { success = true, transactions = transactions })
end)

-- NUI callback for getting transactions (backup)
if RegisterNUICallback then
    RegisterNUICallback('getTransactions', function(data, cb)
        local src = source
        print("=== GET TRANSACTIONS CALLBACK TRIGGERED ===")
        print("Source:", src)
        
        -- Check if player has permission to view banking information
        if not HasPermission(src, 'viewBanking') then
            print("Player does not have viewBanking permission")
            cb({})
            return
        end
        
        print("Player has viewBanking permission, fetching transactions...")
        
        local transactions = MySQL.Sync.fetchAll([[
            SELECT transaction_type, amount, officer_name, reason, balance_after, timestamp 
            FROM pd_transactions 
            ORDER BY timestamp DESC 
            LIMIT 50
        ]])
        
        print("=== RETRIEVING TRANSACTIONS ===")
        print("Number of transactions found:", #transactions)
        if #transactions > 0 then
            print("First transaction:", json.encode(transactions[1]))
        else
            print("No transactions found in database")
        end
        
        print("Sending transactions to client:", json.encode(transactions))
        cb(transactions)
    end)
else
    print("RegisterNUICallback not available")
end




-- NUI callback for deposit requests (simplified)
if RegisterNUICallback then
    RegisterNUICallback('deposit', function(data, cb)
        local src = source
        print("=== DEPOSIT NUI CALLBACK TRIGGERED ===")
        print("Data:", json.encode(data))
        
        -- Trigger the server event with the data
        TriggerEvent('pd_boss:server:deposit', data)
        cb('ok')
    end)
else
    print("RegisterNUICallback not available for deposit")
end

-- NUI callback for withdraw requests (simplified)
if RegisterNUICallback then
    RegisterNUICallback('withdraw', function(data, cb)
        local src = source
        print("=== WITHDRAW NUI CALLBACK TRIGGERED ===")
        print("Data:", json.encode(data))
        
        -- Trigger the server event with the data
        TriggerEvent('pd_boss:server:withdraw', data)
        cb('ok')
    end)
else
    print("RegisterNUICallback not available for withdraw")
end

-- NUI callback for triggering server events
if RegisterNUICallback then
    RegisterNUICallback('triggerEvent', function(data, cb)
        local src = source
        print("=== TRIGGER EVENT CALLBACK ===")
        print("Event:", data.event)
        print("Source:", src)
        
        if data.event == 'pd_boss:server:requestTransactions' then
            print("Triggering transaction request...")
            
            -- Check if player has permission to view banking information
            if not HasPermission(src, 'viewBanking') then
                print("Player does not have viewBanking permission")
                cb('ok')
                return
            end
            
            print("Player has viewBanking permission, fetching transactions...")
            
            local transactions = MySQL.Sync.fetchAll([[
                SELECT transaction_type, amount, officer_name, reason, balance_after, timestamp 
                FROM pd_transactions 
                ORDER BY timestamp DESC 
                LIMIT 50
            ]])
            
            print("=== RETRIEVING TRANSACTIONS ===")
            print("Number of transactions found:", #transactions)
            if #transactions > 0 then
                print("First transaction:", json.encode(transactions[1]))
            else
                print("No transactions found in database")
            end
            
            print("Sending transactions to client:", json.encode(transactions))
            TriggerClientEvent('pd_boss:client:receiveTransactions', src, transactions)
        end
        
        cb('ok')
    end)
else
    print("RegisterNUICallback not available for triggerEvent")
end

-- ========================================
-- BONUS PAYMENT SYSTEM
-- Pay one-time bonuses to employees from PD funds
-- ========================================

-- Pay bonus to employee (supports online and offline via citizenid)
RegisterNetEvent('pd_boss:server:payBonus', function(data)
    local src = source
    local Player = QBX:GetPlayer(src)

    if not Player then
        print("Player not found for bonus payment")
        return
    end

    -- Check if player has permission to pay bonuses (command+ only)
    local job = Player.PlayerData.job
    local department = job and job.name or 'police'
    if not job then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Management',
            description = 'You must be employed to pay bonuses',
            type = 'error'
        })
        return
    end

    -- Check job is supported
    local isSupportedJob = false
    for _, supportedJob in ipairs(Config.SupportedJobs or {'police'}) do
        if job.name == supportedJob then
            isSupportedJob = true
            break
        end
    end

    if not isSupportedJob then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Management',
            description = 'This menu is not for your department',
            type = 'error'
        })
        return
    end

    -- Check minimum grade for bonus payment
    local minGrade = Config.BonusMinGrade
    local requiredGrade = 11 -- Default
    if type(minGrade) == 'table' then
        requiredGrade = minGrade[job.name] or 11
    elseif type(minGrade) == 'number' then
        requiredGrade = minGrade
    end

    local playerGrade = job.grade.level
    if playerGrade < requiredGrade then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Management',
            description = 'You must be Command+ to pay bonuses (Grade ' .. requiredGrade .. '+)',
            type = 'error'
        })
        return
    end

    -- Also check database permissions
    local permissions = GetRankPermissions(playerGrade)
    if not permissions.payBonuses then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Management',
            description = 'Your rank does not have permission to pay bonuses',
            type = 'error'
        })
        return
    end

    local targetCitizenId = data.citizenid
    local targetPlayerId = data.playerId
    local amount = tonumber(data.amount)
    local reason = data.reason or 'Performance bonus'

    if not amount or amount <= 0 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Bonus',
            description = 'Invalid bonus amount',
            type = 'error'
        })
        return
    end

    -- Get current funds for this department (using tgg-banking if available)
    local currentFunds = GetSocietyBalance(department)

    if currentFunds < amount then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Bonus',
            description = 'Insufficient ' .. department:upper() .. ' funds. Available: $' .. currentFunds,
            type = 'error'
        })
        return
    end

    -- Determine target player (online or offline)
    local targetPlayer = nil
    local isOnline = false
    local targetName = 'Unknown'

    -- Method 1: Direct citizenid provided
    if targetCitizenId then
        targetPlayer = exports.qbx_core:GetPlayerByCitizenId(targetCitizenId)
        if targetPlayer then
            isOnline = true
            targetName = targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname
        else
            -- Try offline player
            local offlineSuccess, offlinePlayer = pcall(function()
                return exports.qbx_core:GetOfflinePlayer(targetCitizenId)
            end)
            if offlineSuccess and offlinePlayer and offlinePlayer.PlayerData then
                targetPlayer = offlinePlayer
                targetName = offlinePlayer.PlayerData.charinfo.firstname .. ' ' .. offlinePlayer.PlayerData.charinfo.lastname
                isOnline = false
            end
        end
    -- Method 2: Server ID provided
    elseif targetPlayerId and type(targetPlayerId) == 'number' then
        targetPlayer = QBX:GetPlayer(targetPlayerId)
        if targetPlayer then
            isOnline = true
            targetCitizenId = targetPlayer.PlayerData.citizenid
            targetName = targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname
        end
    end

    if not targetPlayer or not targetCitizenId then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Bonus',
            description = 'Target employee not found',
            type = 'error'
        })
        return
    end

    print("=== BONUS PAYMENT ===")
    print("Target:", targetName, "CitizenID:", targetCitizenId, "Online:", isOnline)
    print("Amount:", amount, "Reason:", reason)

    -- Deduct from society account (using tgg-banking if available)
    local deductSuccess = RemoveSocietyMoney(department, amount)
    if not deductSuccess then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Bonus',
            description = 'Failed to deduct from society account',
            type = 'error'
        })
        return
    end
    local newBalance = GetSocietyBalance(department)

    -- If online, give cash directly
    if isOnline then
        local success = targetPlayer.Functions.AddMoney('bank', amount, 'pd-bonus')
        if not success then
            -- Try cash as fallback
            success = targetPlayer.Functions.AddMoney('cash', amount, 'pd-bonus')
        end

        if success then
            -- Notify target
            TriggerClientEvent('ox_lib:notify', targetPlayer.PlayerData.source, {
                title = GetDeptLabel(department) .. ' Bonus',
                description = 'You received a $' .. amount .. ' bonus! Reason: ' .. reason,
                type = 'success'
            })
        else
            print("Failed to add money to online player, will add to offline account")
            -- Add to offline player's bank via database
            AddBonusToOfflinePlayer(targetCitizenId, amount)
        end
    else
        -- Offline player - add to their bank account via database
        AddBonusToOfflinePlayer(targetCitizenId, amount)
    end

    -- Log the bonus transaction
    local bossName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname

    MySQL.Sync.execute([[
        INSERT INTO pd_transactions (department, transaction_type, amount, officer_name, officer_citizenid, reason, balance_after)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ]], {
        department,
        'bonus',
        amount,
        targetName,
        targetCitizenId,
        'Bonus paid by ' .. bossName .. ': ' .. reason,
        newBalance
    })

    TriggerClientEvent('ox_lib:notify', src, {
        title = GetDeptLabel(department) .. ' Bonus',
        description = 'Paid $' .. amount .. ' bonus to ' .. targetName,
        type = 'success'
    })

    -- Send Discord webhook (department already defined above)
    SendDiscordWebhook('bonus', department, {
        performerName = bossName,
        performerRank = Player.PlayerData.job.grade.name,
        targetName = targetName,
        amount = amount,
        newBalance = newBalance,
        reason = reason
    })

    -- Refresh data
    TriggerEvent('pd_boss:server:directGetData', src)
end)

-- Helper function to add bonus to offline player's bank
function AddBonusToOfflinePlayer(citizenid, amount)
    -- Get current money from database
    local result = MySQL.Sync.fetchAll('SELECT money FROM players WHERE citizenid = ?', {citizenid})
    if #result > 0 then
        local money = json.decode(result[1].money) or {cash = 0, bank = 0}
        money.bank = (money.bank or 0) + amount

        -- Update money in database
        MySQL.Sync.execute('UPDATE players SET money = ? WHERE citizenid = ?', {
            json.encode(money),
            citizenid
        })

        print("Added $" .. amount .. " to offline player's bank. New bank balance: $" .. money.bank)
    else
        print("Error: Could not find player with citizenid " .. citizenid .. " to add bonus")
    end
end

-- NUI callback for bonus payment
if RegisterNUICallback then
    RegisterNUICallback('payBonus', function(data, cb)
        local src = source
        print("=== PAY BONUS NUI CALLBACK ===")
        print("Data:", json.encode(data))

        -- Trigger the server event
        TriggerEvent('pd_boss:server:payBonus', data)
        cb('ok')
    end)
end

-- Character search for hiring (fuzzy search)
RegisterNetEvent('pd_boss:server:searchCharacters', function(searchQuery)
    local src = source
    local Player = QBX:GetPlayer(src)
    local department = Player and Player.PlayerData.job.name or 'police'

    -- Check if player has permission to hire employees
    if not HasPermission(src, 'hireEmployees') then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Management',
            description = 'You do not have permission to hire employees',
            type = 'error'
        })
        return
    end

    if not searchQuery or searchQuery == '' then
        TriggerClientEvent('pd_boss:client:searchResults', src, {})
        return
    end

    -- Clean and prepare search query for fuzzy matching
    local cleanQuery = string.lower(searchQuery)
    local searchPattern = '%' .. cleanQuery .. '%'

    print("=== CHARACTER SEARCH ===")
    print("Query:", searchQuery)
    print("Pattern:", searchPattern)

    -- Search database for matching characters
    local results = MySQL.Sync.fetchAll([[
        SELECT
            citizenid,
            charinfo,
            job
        FROM players
        WHERE
            LOWER(JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname'))) LIKE ?
            OR LOWER(JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname'))) LIKE ?
            OR LOWER(CONCAT(
                JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')),
                ' ',
                JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname'))
            )) LIKE ?
        LIMIT 20
    ]], {searchPattern, searchPattern, searchPattern})

    local characters = {}

    for _, row in ipairs(results) do
        local charinfo = json.decode(row.charinfo) or {}
        local job = json.decode(row.job) or {name = 'unemployed', grade = {name = 'None', level = 0}}

        -- Check if player is online
        local onlinePlayer = exports.qbx_core:GetPlayerByCitizenId(row.citizenid)
        local isOnline = onlinePlayer ~= nil
        local serverId = nil
        if isOnline then
            serverId = onlinePlayer.PlayerData.source
        end

        -- Skip if already in police or lscso
        local currentJob = job.name or 'unemployed'
        local isAlreadyLEO = currentJob == 'police' or currentJob == 'lscso'

        table.insert(characters, {
            citizenid = row.citizenid,
            firstname = charinfo.firstname or 'Unknown',
            lastname = charinfo.lastname or 'Unknown',
            fullname = (charinfo.firstname or 'Unknown') .. ' ' .. (charinfo.lastname or 'Unknown'),
            jobName = job.name or 'unemployed',
            jobLabel = job.label or 'Unemployed',
            jobGrade = job.grade and job.grade.name or 'None',
            isOnline = isOnline,
            serverId = serverId,
            isAlreadyLEO = isAlreadyLEO
        })
    end

    print("Found", #characters, "matching characters")

    TriggerClientEvent('pd_boss:client:searchResults', src, characters)
end)

-- Hire character by citizenid (from search results)
RegisterNetEvent('pd_boss:server:hireCharacter', function(data)
    local src = source
    local bossPlayer = QBX:GetPlayer(src)
    if not bossPlayer then
        return
    end

    local department = bossPlayer.PlayerData.job.name
    local citizenid = data.citizenid
    local rank = data.rank or 'cadet'

    -- Check if player has permission to hire employees
    if not HasPermission(src, 'hireEmployees') then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Management',
            description = 'You do not have permission to hire employees',
            type = 'error'
        })
        return
    end

    if not citizenid then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Management',
            description = 'Invalid character selected',
            type = 'error'
        })
        return
    end
    local bossName = bossPlayer.PlayerData.charinfo.firstname .. ' ' .. bossPlayer.PlayerData.charinfo.lastname
    local bossRank = bossPlayer.PlayerData.job.grade.name

    -- Find the grade level for the rank
    local gradeLevel = 1  -- Default to lowest rank
    local rankConfig
    if department == 'lscso' then
        rankConfig = Config.LSCSOanks
    elseif department == 'safr' then
        rankConfig = Config.SAFRRanks
    else
        rankConfig = Config.PoliceRanks
    end
    for _, rankData in pairs(rankConfig) do
        if string.lower(rankData.name) == string.lower(rank) then
            gradeLevel = rankData.grade
            break
        end
    end

    print("=== HIRE CHARACTER ===")
    print("CitizenID:", citizenid, "Rank:", rank, "Grade:", gradeLevel, "Department:", department)

    -- Try to add player to job using QBX core
    local success, errorResult = pcall(function()
        return exports.qbx_core:AddPlayerToJob(citizenid, department, gradeLevel)
    end)

    if success then
        -- Get character name for notification
        local targetPlayer = exports.qbx_core:GetPlayerByCitizenId(citizenid)
        local targetName = 'Unknown'

        if targetPlayer then
            targetName = targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname
            -- Notify target if online
            TriggerClientEvent('ox_lib:notify', targetPlayer.PlayerData.source, {
                title = GetDeptLabel(department),
                description = 'You have been hired by ' .. GetDeptLabel(department) .. ' as ' .. rank,
                type = 'success'
            })
        else
            -- Get name from database
            local result = MySQL.Sync.fetchAll('SELECT charinfo FROM players WHERE citizenid = ?', {citizenid})
            if #result > 0 then
                local charinfo = json.decode(result[1].charinfo) or {}
                targetName = (charinfo.firstname or 'Unknown') .. ' ' .. (charinfo.lastname or 'Unknown')
            end
        end

        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Management',
            description = 'Hired ' .. targetName .. ' as ' .. rank,
            type = 'success'
        })

        -- Send Discord webhook
        SendDiscordWebhook('hire', department, {
            performerName = bossName,
            performerRank = bossRank,
            targetName = targetName,
            rank = rank
        })

        -- Refresh data for the boss
        TriggerEvent('pd_boss:server:directGetData', src)
    else
        print("Failed to hire character:", errorResult)
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Management',
            description = 'Failed to hire character. Please try again.',
            type = 'error'
        })
    end
end)

-- ========================================
-- DISCIPLINARY ACTIONS SYSTEM
-- ========================================

-- Get disciplinary actions for the department
RegisterNetEvent('pd_boss:server:getDisciplinaryActions', function()
    local src = source
    local Player = QBX:GetPlayer(src)

    if not Player then return end

    local department = Player.PlayerData.job.name

    print("=== LOADING DISCIPLINARY ACTIONS ===")
    print("Department:", department)

    local actions = MySQL.Sync.fetchAll([[
        SELECT id, officer_citizenid, officer_name, action_type, description, issued_by, timestamp, active
        FROM pd_disciplinary
        WHERE department = ?
        ORDER BY timestamp DESC
    ]], {department})

    print("Found", #actions, "disciplinary actions for", department)

    TriggerClientEvent('pd_boss:client:receiveDisciplinaryActions', src, actions)
end)

-- Add a new disciplinary action
RegisterNetEvent('pd_boss:server:addDisciplinaryAction', function(data)
    local src = source
    local Player = QBX:GetPlayer(src)

    if not Player then return end

    local department = Player.PlayerData.job.name

    -- Check permission
    if not HasPermission(src, 'viewDisciplinary') then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Management',
            description = 'You do not have permission to manage disciplinary actions',
            type = 'error'
        })
        return
    end

    local department = Player.PlayerData.job.name
    local issuedBy = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    local issuedByCitizenid = Player.PlayerData.citizenid

    print("=== ADDING DISCIPLINARY ACTION ===")
    print("Department:", department)
    print("Officer:", data.officerName, "CitizenID:", data.officerCitizenid)
    print("Type:", data.actionType)
    print("Description:", data.description)
    print("Issued by:", issuedBy)

    local insertId = MySQL.Sync.insert([[
        INSERT INTO pd_disciplinary (department, officer_citizenid, officer_name, action_type, description, issued_by, issued_by_citizenid)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ]], {
        department,
        data.officerCitizenid,
        data.officerName,
        data.actionType,
        data.description or '',
        issuedBy,
        issuedByCitizenid
    })

    if insertId and insertId > 0 then
        print("Disciplinary action added with ID:", insertId)

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Disciplinary Action',
            description = 'Action recorded for ' .. data.officerName,
            type = 'success'
        })

        -- Send updated actions back to client
        TriggerEvent('pd_boss:server:getDisciplinaryActions')
    else
        print("ERROR: Failed to add disciplinary action")
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Disciplinary Action',
            description = 'Failed to record action',
            type = 'error'
        })
    end
end)

-- Remove/deactivate a disciplinary action
RegisterNetEvent('pd_boss:server:removeDisciplinaryAction', function(actionId)
    local src = source
    local Player = QBX:GetPlayer(src)

    if not Player then return end

    local department = Player.PlayerData.job.name

    -- Check permission
    if not HasPermission(src, 'viewDisciplinary') then
        TriggerClientEvent('ox_lib:notify', src, {
            title = GetDeptLabel(department) .. ' Management',
            description = 'You do not have permission to manage disciplinary actions',
            type = 'error'
        })
        return
    end

    print("=== REMOVING DISCIPLINARY ACTION ===")
    print("Action ID:", actionId, "Department:", department)

    -- Deactivate instead of delete (for history)
    local affected = MySQL.Sync.execute([[
        UPDATE pd_disciplinary SET active = 0 WHERE id = ? AND department = ?
    ]], {actionId, department})

    if affected and affected > 0 then
        print("Disciplinary action deactivated")

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Disciplinary Action',
            description = 'Action removed from record',
            type = 'success'
        })

        -- Send updated actions back to client
        TriggerEvent('pd_boss:server:getDisciplinaryActions')
    else
        print("ERROR: Failed to remove disciplinary action or wrong department")
    end
end)

-- ========================================
-- DUTY TRACKING SYSTEM
-- ========================================

-- Track active duty sessions (in-memory for quick access, synced with DB)
local activeDutySessions = {} -- [citizenid] = { startTime, logId }

-- Function to start duty session (can be called directly with source)
function StartDutySession(src)
    local Player = QBX:GetPlayer(src)

    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    local department = Player.PlayerData.job.name
    local officerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname

    -- Check if already on duty
    if activeDutySessions[citizenid] then
        print("[DutyTrack] Officer", officerName, "is already on duty")
        return
    end

    local now = os.date('%Y-%m-%d %H:%M:%S')
    local today = os.date('%Y-%m-%d')

    print("[DutyTrack] === STARTING DUTY ===")
    print("[DutyTrack] Officer:", officerName, "Department:", department, "Time:", now)

    -- Insert duty log entry
    local logId = MySQL.Sync.insert([[
        INSERT INTO pd_duty_logs (department, officer_citizenid, officer_name, duty_start, duty_date)
        VALUES (?, ?, ?, ?, ?)
    ]], {department, citizenid, officerName, now, today})

    if logId and logId > 0 then
        activeDutySessions[citizenid] = {
            startTime = os.time(),
            logId = logId,
            department = department,
            officerName = officerName
        }

        print("[DutyTrack] Duty started with log ID:", logId)

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Duty Tracking',
            description = 'Your duty time is being tracked',
            type = 'info'
        })
    end
end

-- Event wrapper for client calls
RegisterNetEvent('pd_boss:server:startDuty', function()
    StartDutySession(source)
end)

-- Function to end duty session (can be called directly with source)
function EndDutySession(src)
    local Player = QBX:GetPlayer(src)

    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    local session = activeDutySessions[citizenid]

    if not session then
        print("[DutyTrack] Officer not on duty, cannot end duty")
        return
    end

    local now = os.date('%Y-%m-%d %H:%M:%S')
    local durationMinutes = math.floor((os.time() - session.startTime) / 60)

    print("[DutyTrack] === ENDING DUTY ===")
    print("[DutyTrack] Officer:", session.officerName, "Duration:", durationMinutes, "minutes")

    -- Update the duty log with end time and duration
    MySQL.Sync.execute([[
        UPDATE pd_duty_logs SET duty_end = ?, duration_minutes = ? WHERE id = ?
    ]], {now, durationMinutes, session.logId})

    -- Update or insert daily summary (atomic upsert to avoid race conditions)
    local today = os.date('%Y-%m-%d')
    MySQL.Sync.execute([[
        INSERT INTO pd_duty_summary (department, officer_citizenid, officer_name, summary_date, total_minutes, shift_count)
        VALUES (?, ?, ?, ?, ?, 1)
        ON DUPLICATE KEY UPDATE
            total_minutes = total_minutes + VALUES(total_minutes),
            shift_count = shift_count + 1
    ]], {session.department, citizenid, session.officerName, today, durationMinutes})

    -- Clear active session
    activeDutySessions[citizenid] = nil

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Duty Tracking',
        description = 'Shift ended: ' .. durationMinutes .. ' minutes logged',
        type = 'info'
    })
end

-- Event wrapper for client calls
RegisterNetEvent('pd_boss:server:endDuty', function()
    EndDutySession(source)
end)

-- Get duty analytics for the department (for boss menu)
RegisterNetEvent('pd_boss:server:getDutyAnalytics', function()
    local src = source
    local Player = QBX:GetPlayer(src)

    if not Player then return end

    local department = Player.PlayerData.job.name

    print("=== LOADING DUTY ANALYTICS ===")
    print("Department:", department)

    -- Get last 7 days of duty summaries for all officers
    local summaries = MySQL.Sync.fetchAll([[
        SELECT officer_citizenid, officer_name, summary_date, total_minutes, shift_count
        FROM pd_duty_summary
        WHERE department = ? AND summary_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
        ORDER BY summary_date DESC, officer_name ASC
    ]], {department})

    -- Get today's active sessions
    local activeSessions = {}
    for citizenid, session in pairs(activeDutySessions) do
        if session.department == department then
            local currentDuration = math.floor((os.time() - session.startTime) / 60)
            table.insert(activeSessions, {
                citizenid = citizenid,
                name = session.officerName,
                startTime = session.startTime,
                currentMinutes = currentDuration
            })
        end
    end

    -- Calculate weekly totals per officer
    local weeklyTotals = {}
    for _, summary in ipairs(summaries) do
        local cid = summary.officer_citizenid
        if not weeklyTotals[cid] then
            weeklyTotals[cid] = {
                name = summary.officer_name,
                totalMinutes = 0,
                shifts = 0,
                dailyBreakdown = {}
            }
        end
        weeklyTotals[cid].totalMinutes = weeklyTotals[cid].totalMinutes + summary.total_minutes
        weeklyTotals[cid].shifts = weeklyTotals[cid].shifts + summary.shift_count
        table.insert(weeklyTotals[cid].dailyBreakdown, {
            date = summary.summary_date,
            minutes = summary.total_minutes,
            shifts = summary.shift_count
        })
    end

    -- Convert to array for sending to client
    local weeklyData = {}
    for citizenid, data in pairs(weeklyTotals) do
        table.insert(weeklyData, {
            citizenid = citizenid,
            name = data.name,
            totalMinutes = data.totalMinutes,
            totalHours = math.floor(data.totalMinutes / 60 * 10) / 10,
            shifts = data.shifts,
            dailyBreakdown = data.dailyBreakdown
        })
    end

    -- Sort by total hours (highest first)
    table.sort(weeklyData, function(a, b) return a.totalMinutes > b.totalMinutes end)

    print("Found", #weeklyData, "officers with duty data")

    TriggerClientEvent('pd_boss:client:receiveDutyAnalytics', src, {
        weeklyData = weeklyData,
        activeSessions = activeSessions,
        department = department
    })
end)

-- Get specific officer's duty history
RegisterNetEvent('pd_boss:server:getOfficerDutyHistory', function(targetCitizenid)
    local src = source
    local Player = QBX:GetPlayer(src)

    if not Player then return end

    local department = Player.PlayerData.job.name

    print("=== LOADING OFFICER DUTY HISTORY ===")
    print("Officer:", targetCitizenid, "Department:", department)

    -- Get last 30 days of duty logs for this officer
    local logs = MySQL.Sync.fetchAll([[
        SELECT duty_start, duty_end, duration_minutes, duty_date
        FROM pd_duty_logs
        WHERE department = ? AND officer_citizenid = ? AND duty_end IS NOT NULL
        ORDER BY duty_start DESC
        LIMIT 100
    ]], {department, targetCitizenid})

    -- Get summary data
    local summary = MySQL.Sync.fetchAll([[
        SELECT summary_date, total_minutes, shift_count
        FROM pd_duty_summary
        WHERE department = ? AND officer_citizenid = ?
        ORDER BY summary_date DESC
        LIMIT 30
    ]], {department, targetCitizenid})

    TriggerClientEvent('pd_boss:client:receiveOfficerDutyHistory', src, {
        logs = logs,
        summary = summary,
        citizenid = targetCitizenid
    })
end)

-- Auto-track duty based on job clock-in (integrate with existing duty system if available)
-- This hooks into player job updates to auto-track duty
-- Also handles job switching via advanced-multijob
AddEventHandler('QBCore:Server:OnJobUpdate', function(src, job)
    local Player = QBX:GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    local currentSession = activeDutySessions[citizenid]

    -- Check if player is going on/off duty for a supported job
    local supportedJobs = Config.SupportedJobs or {'police', 'lscso', 'safr'}
    local isSupported = false
    for _, j in ipairs(supportedJobs) do
        if job.name == j then
            isSupported = true
            break
        end
    end

    print("[DutyTrack] Job update for", citizenid, "Job:", job.name, "OnDuty:", job.onduty, "Supported:", isSupported)

    -- Handle job switching while on duty (e.g., switching from police to lscso via multijob)
    if currentSession then
        -- Player was on duty, check if they switched jobs
        if currentSession.department ~= job.name then
            print("[DutyTrack] Job switch detected - ending previous duty session for", currentSession.department)
            EndDutySession(src)
            currentSession = nil -- Clear so we can potentially start a new one
        end
    end

    -- Start new duty session if switching to a supported job while on duty
    if isSupported and job.onduty and not activeDutySessions[citizenid] then
        StartDutySession(src)
    elseif activeDutySessions[citizenid] and not job.onduty then
        -- Going off duty
        EndDutySession(src)
    end
end)

-- Listen for duty toggle (separate from job update - triggered by QBCore:ToggleDuty)
-- This is the event that fires when players use duty toggle via multijob or other methods
AddEventHandler('QBCore:Server:SetDuty', function(src, onDuty)
    local Player = QBX:GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    local jobName = Player.PlayerData.job.name

    -- Check if player is in a supported job
    local supportedJobs = Config.SupportedJobs or {'police', 'lscso', 'safr'}
    local isSupported = false
    for _, j in ipairs(supportedJobs) do
        if jobName == j then
            isSupported = true
            break
        end
    end

    if not isSupported then return end

    print("[DutyTrack] Duty toggle for", citizenid, "Job:", jobName, "OnDuty:", onDuty)

    if onDuty then
        -- Going on duty - start tracking
        StartDutySession(src)
    elseif activeDutySessions[citizenid] then
        -- Going off duty
        EndDutySession(src)
    end
end)

-- Clean up duty sessions on player disconnect
AddEventHandler('playerDropped', function(reason)
    local src = source
    local Player = QBX:GetPlayer(src)

    if Player then
        local citizenid = Player.PlayerData.citizenid
        if activeDutySessions[citizenid] then
            print("Player disconnected while on duty, ending session")
            -- End the duty session when player disconnects
            local session = activeDutySessions[citizenid]
            local now = os.date('%Y-%m-%d %H:%M:%S')
            local durationMinutes = math.floor((os.time() - session.startTime) / 60)

            -- Update the duty log
            MySQL.Sync.execute([[
                UPDATE pd_duty_logs SET duty_end = ?, duration_minutes = ? WHERE id = ?
            ]], {now, durationMinutes, session.logId})

            -- Update daily summary (atomic upsert to avoid race conditions)
            local today = os.date('%Y-%m-%d')
            MySQL.Sync.execute([[
                INSERT INTO pd_duty_summary (department, officer_citizenid, officer_name, summary_date, total_minutes, shift_count)
                VALUES (?, ?, ?, ?, ?, 1)
                ON DUPLICATE KEY UPDATE
                    total_minutes = total_minutes + VALUES(total_minutes),
                    shift_count = shift_count + 1
            ]], {session.department, citizenid, session.officerName, today, durationMinutes})

            activeDutySessions[citizenid] = nil
        end
    end
end)

-- Initialize duty sessions for players already on duty when resource starts
CreateThread(function()
    Wait(5000) -- Wait for server to be ready and players to be loaded

    print("[DutyTrack] Initializing duty sessions for players already on duty...")

    local supportedJobs = Config.SupportedJobs or {'police', 'lscso', 'safr'}
    local allPlayers = exports.qbx_core:GetQBPlayers()

    for _, player in pairs(allPlayers) do
        if player and player.PlayerData then
            local jobName = player.PlayerData.job.name
            local onDuty = player.PlayerData.job.onduty
            local citizenid = player.PlayerData.citizenid

            -- Check if player is in a supported job and on duty
            local isSupported = false
            for _, j in ipairs(supportedJobs) do
                if jobName == j then
                    isSupported = true
                    break
                end
            end

            if isSupported and onDuty and not activeDutySessions[citizenid] then
                local officerName = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
                print("[DutyTrack] Found player already on duty:", officerName, "Job:", jobName)

                -- Start tracking them (create a session entry without database log since we don't know when they started)
                activeDutySessions[citizenid] = {
                    startTime = os.time(), -- Use current time since we don't know actual start
                    logId = 0, -- No log entry for retroactive sessions
                    department = jobName,
                    officerName = officerName
                }
            end
        end
    end

    local sessionCount = 0
    for _ in pairs(activeDutySessions) do sessionCount = sessionCount + 1 end
    print("[DutyTrack] Initialized with", sessionCount, "active duty sessions")
end)

-- ========================================
-- LIVE UPDATE SYSTEM (Event-Driven)
-- No polling - broadcasts only on changes
-- ========================================

-- Track which players have the boss menu open (by department)
local activeMenuSessions = {} -- [src] = department

-- Register when a player opens the menu
RegisterNetEvent('pd_boss:server:menuOpened', function()
    local src = source
    local Player = QBX:GetPlayer(src)
    if not Player then return end

    local department = Player.PlayerData.job.name
    activeMenuSessions[src] = department
    print("[LiveUpdate] Menu opened by player", src, "Department:", department)
end)

-- Unregister when a player closes the menu
RegisterNetEvent('pd_boss:server:menuClosed', function()
    local src = source
    activeMenuSessions[src] = nil
    print("[LiveUpdate] Menu closed by player", src)
end)

-- Clean up on disconnect
AddEventHandler('playerDropped', function()
    local src = source
    if activeMenuSessions[src] then
        activeMenuSessions[src] = nil
    end
end)

-- Broadcast employee status change to all players with menu open in the same department
local function BroadcastEmployeeUpdate(department, updateType, employeeData)
    local recipients = 0
    for src, dept in pairs(activeMenuSessions) do
        if dept == department then
            TriggerClientEvent('pd_boss:client:liveEmployeeUpdate', src, {
                type = updateType, -- 'online', 'offline', 'duty_start', 'duty_end', 'job_change'
                employee = employeeData
            })
            recipients = recipients + 1
        end
    end
    if recipients > 0 then
        print("[LiveUpdate] Broadcast", updateType, "to", recipients, "recipients in", department)
    end
end

-- Broadcast analytics update (officer count changed)
local function BroadcastAnalyticsUpdate(department)
    -- Count active sessions for this department
    local activeCount = 0
    for citizenid, session in pairs(activeDutySessions) do
        if session.department == department then
            activeCount = activeCount + 1
        end
    end

    for src, dept in pairs(activeMenuSessions) do
        if dept == department then
            TriggerClientEvent('pd_boss:client:liveAnalyticsUpdate', src, {
                onlineCount = activeCount,
                activeSessions = GetActiveSessionsForDepartment(department)
            })
        end
    end
end

-- Helper to get active sessions for a department
function GetActiveSessionsForDepartment(department)
    local sessions = {}
    for citizenid, session in pairs(activeDutySessions) do
        if session.department == department then
            local currentDuration = math.floor((os.time() - session.startTime) / 60)
            table.insert(sessions, {
                citizenid = citizenid,
                name = session.officerName,
                startTime = session.startTime,
                currentMinutes = currentDuration
            })
        end
    end
    return sessions
end

-- Hook into player connecting (new employee comes online)
AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    if not Player then return end

    local supportedJobs = Config.SupportedJobs or {'police', 'lscso', 'safr'}
    local jobName = Player.PlayerData.job.name

    for _, j in ipairs(supportedJobs) do
        if jobName == j then
            local employeeData = {
                citizenid = Player.PlayerData.citizenid,
                name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                rank = Player.PlayerData.job.grade.name,
                grade = Player.PlayerData.job.grade.level,
                online = true,
                onDuty = Player.PlayerData.job.onduty
            }

            -- Small delay to ensure player is fully loaded
            SetTimeout(1000, function()
                BroadcastEmployeeUpdate(jobName, 'online', employeeData)
                if Player.PlayerData.job.onduty then
                    BroadcastAnalyticsUpdate(jobName)
                end
            end)
            break
        end
    end
end)

-- Hook into player disconnecting (employee goes offline)
AddEventHandler('playerDropped', function(reason)
    local src = source
    local Player = QBX:GetPlayer(src)

    if Player then
        local supportedJobs = Config.SupportedJobs or {'police', 'lscso', 'safr'}
        local jobName = Player.PlayerData.job.name
        local citizenid = Player.PlayerData.citizenid

        for _, j in ipairs(supportedJobs) do
            if jobName == j then
                local employeeData = {
                    citizenid = citizenid,
                    name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                    online = false
                }

                BroadcastEmployeeUpdate(jobName, 'offline', employeeData)

                -- If they were on duty, broadcast analytics update
                if activeDutySessions[citizenid] then
                    SetTimeout(100, function()
                        BroadcastAnalyticsUpdate(jobName)
                    end)
                end
                break
            end
        end
    end
end)

-- Enhanced duty start - broadcast live update
local originalStartDutySession = StartDutySession
function StartDutySession(src)
    originalStartDutySession(src)

    local Player = QBX:GetPlayer(src)
    if Player then
        local department = Player.PlayerData.job.name
        local employeeData = {
            citizenid = Player.PlayerData.citizenid,
            name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
            onDuty = true
        }
        BroadcastEmployeeUpdate(department, 'duty_start', employeeData)
        BroadcastAnalyticsUpdate(department)
    end
end

-- Enhanced duty end - broadcast live update
local originalEndDutySession = EndDutySession
function EndDutySession(src)
    local Player = QBX:GetPlayer(src)
    local department = Player and Player.PlayerData.job.name or nil

    originalEndDutySession(src)

    if Player and department then
        local employeeData = {
            citizenid = Player.PlayerData.citizenid,
            name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
            onDuty = false
        }
        BroadcastEmployeeUpdate(department, 'duty_end', employeeData)
        BroadcastAnalyticsUpdate(department)
    end
end

print("[PD BOSS MENU] Live update system initialized")

-- ========================================
-- PANEL PLACEMENT CONFIG SAVE
-- Handles saving panel configurations to config.lua
-- ========================================

RegisterNetEvent('pd_boss:server:savePanelConfig', function(panelData, isEditing, editIndex)
    local src = source

    -- Basic validation
    if not panelData or not panelData.id or not panelData.position then
        print('^1[Panel Save] Invalid panel data received^7')
        TriggerClientEvent('pd_boss:client:panelSaveResult', src, false, 'Invalid panel data')
        return
    end

    local configPath = GetResourcePath(GetCurrentResourceName()) .. '/shared/config.lua'

    -- Read current config file
    local file = io.open(configPath, 'r')
    if not file then
        print('^1[Panel Save] ERROR: Could not read config file^7')
        TriggerClientEvent('pd_boss:client:panelSaveResult', src, false, 'Could not read config file')
        return
    end
    local content = file:read('*all')
    file:close()

    -- Build new panel config entry (properly indented for array item)
    local camOffsetX = panelData.camOffsetX or 0.0
    local camOffsetY = panelData.camOffsetY or 0.0

    local newPanelConfig = string.format([[    {
        id = "%s",
        enabled = true,
        position = vector3(%.4f, %.4f, %.4f),
        heading = %.2f,
        width = %.2f,
        height = %.2f,
        resW = 1920,
        resH = 1280,
        interactDist = 3.0,
        zoomDist = %.2f,
        zoomFov = %.1f,
        camHeight = %.2f,
        camOffsetX = %.2f,
        camOffsetY = %.2f
    }]],
        panelData.id,
        panelData.position.x, panelData.position.y, panelData.position.z,
        panelData.heading,
        panelData.width, panelData.height,
        panelData.zoomDist, panelData.zoomFov, panelData.camHeight,
        camOffsetX, camOffsetY
    )

    local newContent = content
    local success = false

    if isEditing and panelData.originalId then
        -- Update existing panel - find the panel by its ID and replace the entire block
        -- We need to find: {  ... id = "panel_id" ... } including nested braces

        -- Find the start of the panel block by locating the id
        local idPattern = 'id%s*=%s*["\']' .. panelData.originalId .. '["\']'
        local idStart, idEnd = content:find(idPattern)

        if idStart then
            -- Search backwards for the opening brace
            local blockStart = idStart
            local braceCount = 0
            for i = idStart, 1, -1 do
                local char = content:sub(i, i)
                if char == '}' then
                    braceCount = braceCount + 1
                elseif char == '{' then
                    if braceCount == 0 then
                        blockStart = i
                        break
                    else
                        braceCount = braceCount - 1
                    end
                end
            end

            -- Search forwards for the closing brace
            local blockEnd = idEnd
            braceCount = 1
            for i = blockStart + 1, #content do
                local char = content:sub(i, i)
                if char == '{' then
                    braceCount = braceCount + 1
                elseif char == '}' then
                    braceCount = braceCount - 1
                    if braceCount == 0 then
                        blockEnd = i
                        break
                    end
                end
            end

            -- Replace the block
            newContent = content:sub(1, blockStart - 1) .. newPanelConfig .. content:sub(blockEnd + 1)
            success = true
            print('^2[Panel Save] Updated existing panel in config^7')
        else
            print('^1[Panel Save] Could not find panel with id: ' .. panelData.originalId .. '^7')
            TriggerClientEvent('pd_boss:client:panelSaveResult', src, false, 'Could not find panel to update')
            return
        end
    else
        -- Add new panel - find "-- Add more panels here" comment and insert before it
        local commentPattern = '%s*%-%-[^\n]*Add more panels'
        local commentStart = content:find(commentPattern)

        if commentStart then
            -- Insert the new panel before the comment
            newContent = content:sub(1, commentStart - 1) .. newPanelConfig .. ',\n' .. content:sub(commentStart)
            success = true
            print('^2[Panel Save] Added new panel to config^7')
        else
            -- Fallback: find the closing brace of Screen3DPanels
            -- Look for "Config.Screen3DPanels = {" then find its matching close
            local arrayStart = content:find('Config%.Screen3DPanels%s*=%s*{')
            if arrayStart then
                local braceStart = content:find('{', arrayStart)
                local braceCount = 1
                local insertPos = braceStart

                for i = braceStart + 1, #content do
                    local char = content:sub(i, i)
                    if char == '{' then
                        braceCount = braceCount + 1
                    elseif char == '}' then
                        braceCount = braceCount - 1
                        if braceCount == 0 then
                            insertPos = i
                            break
                        end
                    end
                end

                -- Insert before the closing brace
                newContent = content:sub(1, insertPos - 1) .. newPanelConfig .. ',\n' .. content:sub(insertPos)
                success = true
                print('^2[Panel Save] Added new panel to config (fallback method)^7')
            else
                print('^1[Panel Save] Could not find Config.Screen3DPanels in config^7')
                TriggerClientEvent('pd_boss:client:panelSaveResult', src, false, 'Could not find insertion point')
                return
            end
        end
    end

    if not success then
        TriggerClientEvent('pd_boss:client:panelSaveResult', src, false, 'Save operation failed')
        return
    end

    -- Write updated content
    file = io.open(configPath, 'w')
    if not file then
        print('^1[Panel Save] ERROR: Could not write to config file^7')
        TriggerClientEvent('pd_boss:client:panelSaveResult', src, false, 'Could not write to config file')
        return
    end
    file:write(newContent)
    file:close()

    print('^2[Panel Save] Config file saved successfully^7')
    TriggerClientEvent('pd_boss:client:panelSaveResult', src, true, 'Panel saved successfully')
end)

