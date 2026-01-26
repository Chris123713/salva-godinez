--[[
    Mr. X Tablet Integration (lb-tablet)
    =====================================
    HARM: Create fake warrants, reports, cases, BOLOs
    HELP: Clear records for high-rep players
]]

local Tablet = {}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function JsonEncode(data)
    if data == nil then return nil end
    local success, result = pcall(json.encode, data)
    return success and result or nil
end

local function Log(eventType, citizenid, data, source)
    if not Config.LogEvents then return end
    MySQL.insert.await([[
        INSERT INTO mr_x_events (citizenid, event_type, data, source)
        VALUES (?, ?, ?, ?)
    ]], {citizenid, eventType, JsonEncode(data), source})
end

local function IsTabletAvailable()
    return GetResourceState('lb-tablet') == 'started'
end

-- ============================================
-- HARM: CREATE FAKE RECORDS
-- ============================================

---Create a fake arrest warrant
---@param suspectCid string Target citizenid
---@param data table {title?, description?, type?, priority?}
---@return number|nil warrantId
---@return string|nil error
function Tablet.CreateWarrant(suspectCid, data)
    if not IsTabletAvailable() then
        return nil, 'lb-tablet not available'
    end

    -- Default warrant data
    local warrantData = {
        title = data.title or 'Outstanding Warrant',
        description = data.description or 'Subject wanted for questioning regarding ongoing investigation.',
        type = data.type or 'arrest',  -- 'arrest' or 'search'
        status = 'active',
        priority = data.priority or 'medium',
        tags = {'mr_x_generated'},
        target = suspectCid
    }

    -- Create warrant using lb-tablet export (source 0 for system-generated)
    local warrantId, err = exports['lb-tablet']:CreatePoliceWarrant(0, warrantData)

    if warrantId then
        Log(MrXConstants.EventTypes.FAKE_WARRANT_CREATED, suspectCid, {
            warrantId = warrantId,
            type = warrantData.type,
            priority = warrantData.priority
        })

        if Config.Debug then
            print('^3[MR_X]^7 Created fake warrant #' .. warrantId .. ' for ' .. suspectCid)
        end
    end

    return warrantId, err
end

---Create a fake incident report
---@param suspectCid string Target citizenid
---@param data table {title?, description?, type?}
---@return number|nil reportId
---@return string|nil error
function Tablet.CreateReport(suspectCid, data)
    if not IsTabletAvailable() then
        return nil, 'lb-tablet not available'
    end

    local reportData = {
        title = data.title or 'Suspicious Activity Report',
        description = data.description or 'Subject observed engaging in suspicious behavior. Further investigation recommended.',
        type = data.type or 'incident',
        tags = {'mr_x_generated'},
        suspects = {suspectCid}
    }

    local reportId, err = exports['lb-tablet']:CreatePoliceReport(0, reportData)

    if reportId then
        Log(MrXConstants.EventTypes.FAKE_REPORT_CREATED, suspectCid, {
            reportId = reportId,
            type = reportData.type
        })

        if Config.Debug then
            print('^3[MR_X]^7 Created fake report #' .. reportId .. ' for ' .. suspectCid)
        end
    end

    return reportId, err
end

---Create a fake investigation case
---@param suspectCid string Target citizenid
---@param data table {title?, description?, type?}
---@return number|nil caseId
---@return string|nil error
function Tablet.CreateCase(suspectCid, data)
    if not IsTabletAvailable() then
        return nil, 'lb-tablet not available'
    end

    local caseData = {
        title = data.title or 'Open Investigation',
        description = data.description or 'Subject under investigation for alleged criminal activity.',
        type = data.type or 'investigation',
        status = 'open',
        suspects = {suspectCid}
    }

    local caseId, err = exports['lb-tablet']:CreatePoliceCase(0, caseData)

    if caseId then
        Log(MrXConstants.EventTypes.FAKE_CASE_CREATED, suspectCid, {
            caseId = caseId,
            type = caseData.type
        })

        if Config.Debug then
            print('^3[MR_X]^7 Created fake case #' .. caseId .. ' for ' .. suspectCid)
        end
    end

    return caseId, err
end

---Create a BOLO (Be On Lookout) bulletin
---@param data table {title, content, plate?, description?}
---@return boolean success
function Tablet.CreateBOLO(data)
    if not IsTabletAvailable() then
        return false
    end

    -- BOLOs are stored in lbtablet_police_bulletin as pinned entries
    local result = MySQL.insert.await([[
        INSERT INTO lbtablet_police_bulletin (title, content, pinned, created_by, created_at)
        VALUES (?, ?, true, 'SYSTEM_MRX', NOW())
    ]], {
        data.title or 'BOLO Alert',
        data.content or data.description or 'Subject wanted for questioning.'
    })

    if result then
        Log(MrXConstants.EventTypes.FAKE_WARRANT_CREATED, nil, {
            type = 'bolo',
            title = data.title
        })
    end

    return result ~= nil
end

---Create a dispatch alert
---@param data table {job?, priority, code, title, description, coords, time?}
---@return number|nil dispatchId
function Tablet.CreateDispatch(data)
    if not IsTabletAvailable() then
        return nil
    end

    local dispatchId = exports['lb-tablet']:AddDispatch({
        job = data.job or 'police',
        priority = data.priority or 'medium',
        code = data.code or '10-37',
        title = data.title,
        description = data.description,
        location = {
            label = data.label or 'Unknown Location',
            coords = vector2(data.coords.x, data.coords.y)
        },
        time = data.time or 300
    })

    return dispatchId
end

---Add fake jail record
---@param suspectCid string
---@param reason string
---@param time number Jail time in minutes
---@return boolean success
function Tablet.LogJailRecord(suspectCid, reason, time)
    if not IsTabletAvailable() then
        return false
    end

    -- Try to use lb-tablet's jail logging if available
    local success = pcall(function()
        exports['lb-tablet']:LogJailed({
            citizenid = suspectCid,
            firstname = 'Unknown',
            lastname = 'Subject'
        }, {
            citizenid = 'SYSTEM',
            firstname = 'System',
            lastname = 'Generated'
        }, reason, time)
    end)

    return success
end

-- ============================================
-- HELP: CLEAR RECORDS (Premium Services)
-- ============================================

---Clear a specific warrant
---@param source number Player requesting (for payment)
---@param warrantId number
---@return boolean success
---@return string|nil error
function Tablet.ClearWarrant(source, warrantId)
    if not IsTabletAvailable() then
        return false, 'lb-tablet not available'
    end

    local cost = Config.Services.ClearWarrant.cost
    local player = exports.qbx_core:GetPlayer(source)

    if not player or player.PlayerData.money.cash < cost then
        return false, 'insufficient_funds'
    end

    -- Remove money
    exports.qbx_core:RemoveMoney(source, 'cash', cost, 'mr_x_clear_warrant')

    -- Delete warrant
    local success = exports['lb-tablet']:DeletePoliceWarrant(warrantId)

    if success then
        local citizenid = player.PlayerData.citizenid
        Log(MrXConstants.EventTypes.RECORD_CLEARED, citizenid, {
            type = 'warrant',
            recordId = warrantId,
            cost = cost
        }, source)
    end

    return success ~= nil
end

---Clear a specific report
---@param source number
---@param reportId number
---@return boolean success
---@return string|nil error
function Tablet.ClearReport(source, reportId)
    if not IsTabletAvailable() then
        return false, 'lb-tablet not available'
    end

    local cost = Config.Services.ClearReport.cost
    local player = exports.qbx_core:GetPlayer(source)

    if not player or player.PlayerData.money.cash < cost then
        return false, 'insufficient_funds'
    end

    exports.qbx_core:RemoveMoney(source, 'cash', cost, 'mr_x_clear_report')

    local success = exports['lb-tablet']:DeletePoliceReport(reportId)

    if success then
        local citizenid = player.PlayerData.citizenid
        Log(MrXConstants.EventTypes.RECORD_CLEARED, citizenid, {
            type = 'report',
            recordId = reportId,
            cost = cost
        }, source)
    end

    return success ~= nil
end

---Clear a specific case
---@param source number
---@param caseId number
---@return boolean success
---@return string|nil error
function Tablet.ClearCase(source, caseId)
    if not IsTabletAvailable() then
        return false, 'lb-tablet not available'
    end

    local cost = Config.Services.ClearCase.cost
    local player = exports.qbx_core:GetPlayer(source)

    if not player or player.PlayerData.money.cash < cost then
        return false, 'insufficient_funds'
    end

    exports.qbx_core:RemoveMoney(source, 'cash', cost, 'mr_x_clear_case')

    local success = exports['lb-tablet']:DeletePoliceCase(caseId)

    if success then
        local citizenid = player.PlayerData.citizenid
        Log(MrXConstants.EventTypes.RECORD_CLEARED, citizenid, {
            type = 'case',
            recordId = caseId,
            cost = cost
        }, source)
    end

    return success ~= nil
end

---Get all police records for a player
---@param citizenid string
---@return table records
function Tablet.GetPlayerRecords(citizenid)
    local records = {
        warrants = {},
        reports = {},
        cases = {}
    }

    if not IsTabletAvailable() then
        return records
    end

    -- Query warrants (lb-tablet uses linked_profile_id and warrant_status)
    records.warrants = MySQL.query.await([[
        SELECT * FROM lbtablet_police_warrants
        WHERE linked_profile_id = ? AND warrant_status = 'active'
    ]], {citizenid}) or {}

    -- Query reports (lb-tablet uses separate _involved table)
    records.reports = MySQL.query.await([[
        SELECT r.* FROM lbtablet_police_reports r
        INNER JOIN lbtablet_police_reports_involved i ON r.id = i.report_id
        WHERE i.involved = ?
    ]], {citizenid}) or {}

    -- Query cases (lb-tablet uses separate _criminals table, closed column for status)
    records.cases = MySQL.query.await([[
        SELECT c.* FROM lbtablet_police_cases c
        INNER JOIN lbtablet_police_cases_criminals cr ON c.id = cr.case_id
        WHERE cr.id = ? AND c.closed = FALSE
    ]], {citizenid}) or {}

    return records
end

---Clear ALL records for a player (Clean Slate - very expensive)
---@param source number
---@return boolean success
---@return number clearedCount
function Tablet.ClearAllRecords(source)
    if not IsTabletAvailable() then
        return false, 0
    end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false, 0 end

    local citizenid = player.PlayerData.citizenid
    local cost = Config.Services.CleanSlate.cost

    -- Check reputation requirement
    local rep = exports['sv_mr_x']:GetReputation(citizenid)
    if rep < Config.Services.CleanSlate.minRep then
        return false, 0
    end

    if player.PlayerData.money.cash < cost then
        return false, 0
    end

    -- Get all records
    local records = Tablet.GetPlayerRecords(citizenid)
    local clearedCount = 0

    -- Clear warrants
    for _, warrant in ipairs(records.warrants) do
        if exports['lb-tablet']:DeletePoliceWarrant(warrant.id) then
            clearedCount = clearedCount + 1
        end
    end

    -- Clear reports
    for _, report in ipairs(records.reports) do
        if exports['lb-tablet']:DeletePoliceReport(report.id) then
            clearedCount = clearedCount + 1
        end
    end

    -- Clear cases
    for _, case in ipairs(records.cases) do
        if exports['lb-tablet']:DeletePoliceCase(case.id) then
            clearedCount = clearedCount + 1
        end
    end

    -- Charge player
    if clearedCount > 0 then
        exports.qbx_core:RemoveMoney(source, 'cash', cost, 'mr_x_clean_slate')

        Log(MrXConstants.EventTypes.RECORD_CLEARED, citizenid, {
            type = 'clean_slate',
            clearedCount = clearedCount,
            cost = cost
        }, source)
    end

    return true, clearedCount
end

-- ============================================
-- EXPORTS
-- ============================================

exports('CreateFakeWarrant', Tablet.CreateWarrant)
exports('CreateFakeReport', Tablet.CreateReport)
exports('CreateFakeCase', Tablet.CreateCase)
exports('CreateFakeBOLO', Tablet.CreateBOLO)
exports('CreateTabletDispatch', Tablet.CreateDispatch)
exports('LogFakeJailRecord', Tablet.LogJailRecord)
exports('ClearWarrant', Tablet.ClearWarrant)
exports('ClearReport', Tablet.ClearReport)
exports('ClearCase', Tablet.ClearCase)
exports('GetPlayerRecords', Tablet.GetPlayerRecords)
exports('ClearAllRecords', Tablet.ClearAllRecords)

-- Return module
return Tablet
