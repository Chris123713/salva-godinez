--[[
    LB-TABLET INTEGRATION SNIPPET
    For police MDT/dispatch tracking and investigation missions

    This enables Mr. X to:
    - Track police dispatch activity for criminal content timing
    - Generate investigation missions for detectives
    - Create evidence trails for ongoing criminal activity
    - Link criminal missions to MDT records
    - Reactive content based on police pressure

    LB-TABLET FEATURES:
    - Police MDT system
    - Dispatch integration
    - Warrant/BOLO system
    - Evidence management
    - Report filing
]]

-- Helper function to safely call nexus
local function ReportToNexus(eventType, data, source)
    if GetResourceState('sv_nexus_tools') ~= 'started' then return end
    exports['sv_nexus_tools']:ReportActivity(eventType, data, source)
end

local function GetCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    return player and player.PlayerData.citizenid
end

local function GetPlayerCoords(source)
    return GetEntityCoords(GetPlayerPed(source))
end

-- ============================================
-- DISPATCH TRACKING
-- ============================================

-- Call when dispatch call is created
local function OnDispatchCreated(source, dispatchData)
    ReportToNexus('dispatch_created', {
        code = dispatchData.code,
        description = dispatchData.description,
        coords = dispatchData.coords,
        priority = dispatchData.priority,
        type = dispatchData.type  -- 'robbery', 'shooting', 'traffic', etc.
    }, source)
end

-- Call when officer responds to dispatch
local function OnDispatchResponse(source, responseData)
    ReportToNexus('dispatch_received', {
        dispatchType = responseData.code,
        code = responseData.code,
        description = responseData.description,
        coords = responseData.coords,
        priority = responseData.priority
    }, source)
end

-- ============================================
-- WARRANT/BOLO TRACKING
-- ============================================

-- Call when warrant is issued
local function OnWarrantIssued(source, warrantData)
    ReportToNexus('police_investigation', {
        type = 'warrant_issued',
        targetCitizenId = warrantData.targetCitizenId,
        charges = warrantData.charges,
        issuedBy = GetCitizenId(source)
    }, source)
end

-- Call when BOLO is created
local function OnBOLOCreated(source, boloData)
    ReportToNexus('police_investigation', {
        type = 'bolo_created',
        description = boloData.description,
        vehicle = boloData.vehicle,
        suspect = boloData.suspect,
        priority = boloData.priority
    }, source)
end

-- ============================================
-- EVIDENCE TRACKING
-- ============================================

-- Call when evidence is logged in MDT
local function OnEvidenceLogged(source, evidenceData)
    ReportToNexus('evidence_collected', {
        evidenceType = evidenceData.type,
        description = evidenceData.description,
        caseId = evidenceData.caseId,
        linkedTo = evidenceData.linkedCitizenIds,
        coords = evidenceData.coords
    }, source)
end

-- ============================================
-- REPORT FILING
-- ============================================

-- Call when police report is filed
local function OnReportFiled(source, reportData)
    ReportToNexus('police_report', {
        reportType = reportData.type,
        caseId = reportData.caseId,
        title = reportData.title,
        description = reportData.description,
        suspects = reportData.suspects,
        witnesses = reportData.witnesses
    }, source)
end

-- ============================================
-- CRIMINAL RECORD LOOKUP
-- ============================================

-- Call when officer looks up criminal record
local function OnRecordLookup(source, lookupData)
    ReportToNexus('police_investigation', {
        type = 'record_lookup',
        targetCitizenId = lookupData.targetCitizenId,
        lookupType = lookupData.type  -- 'criminal', 'vehicle', 'property'
    }, source)
end

-- ============================================
-- EXAMPLE: Hook into lb-tablet
-- ============================================

--[[
-- lb-tablet has a custom folder structure for adding your own code.
-- In server/custom/yourfile.lua, add:

-- Track dispatch responses
RegisterNetEvent('lb-tablet:dispatch:response', function(dispatchId, dispatchData)
    local src = source
    if GetResourceState('sv_nexus_tools') == 'started' then
        exports['sv_nexus_tools']:ReportActivity('dispatch_received', {
            dispatchType = dispatchData.code,
            code = dispatchData.code,
            description = dispatchData.message,
            coords = dispatchData.coords,
            priority = dispatchData.priority or 'medium'
        }, src)
    end
end)

-- Track warrant creation
RegisterNetEvent('lb-tablet:warrant:create', function(warrantData)
    local src = source
    if GetResourceState('sv_nexus_tools') == 'started' then
        exports['sv_nexus_tools']:ReportActivity('police_investigation', {
            type = 'warrant_issued',
            targetCitizenId = warrantData.citizenid,
            charges = warrantData.charges,
            issuedBy = GetCitizenId(src)
        }, src)
    end
end)

-- Track report filing
RegisterNetEvent('lb-tablet:report:create', function(reportData)
    local src = source
    if GetResourceState('sv_nexus_tools') == 'started' then
        exports['sv_nexus_tools']:ReportActivity('police_report', {
            reportType = reportData.type,
            caseId = reportData.id,
            title = reportData.title
        }, src)
    end
end)
]]

-- ============================================
-- REACTIVE CONTENT TRIGGERS
-- ============================================

--[[
-- In sv_nexus_tools, track police activity for mission timing:

CreateThread(function()
    if GetResourceState('sv_nexus_tools') ~= 'started' then return end

    local recentDispatches = {}
    local DISPATCH_COOLDOWN = 300  -- 5 minutes

    exports['sv_nexus_tools']:SubscribeToEvent('dispatch_created', function(activity)
        local now = os.time()
        local area = activity.data.coords

        -- Track dispatch density
        table.insert(recentDispatches, {
            time = now,
            coords = area,
            type = activity.data.type
        })

        -- Clean old dispatches
        for i = #recentDispatches, 1, -1 do
            if now - recentDispatches[i].time > DISPATCH_COOLDOWN then
                table.remove(recentDispatches, i)
            end
        end

        -- High police activity = not a good time for Mr. X missions in that area
        local areaDispatches = 0
        for _, dispatch in ipairs(recentDispatches) do
            if area and dispatch.coords then
                local dist = #(vector3(area.x, area.y, area.z) - vector3(dispatch.coords.x, dispatch.coords.y, dispatch.coords.z))
                if dist < 500.0 then
                    areaDispatches = areaDispatches + 1
                end
            end
        end

        if areaDispatches >= 3 then
            print('^3[NEXUS]^7 High police activity in area - avoiding for missions')
            -- Mark area as hot zone
        end
    end)

    -- Track investigations for reactive criminal content
    exports['sv_nexus_tools']:SubscribeToEvent('police_investigation', function(activity)
        if activity.data.type == 'warrant_issued' then
            -- Someone has a warrant - could offer them escape mission
            local targetCitizenId = activity.data.targetCitizenId
            print('^3[NEXUS]^7 Warrant issued - could offer escape mission to: ' .. (targetCitizenId or 'unknown'))
        end
    end)
end)
]]

-- ============================================
-- POLICE PRESSURE TRACKING
-- ============================================

-- Track overall police pressure in an area
local areaPolicePressure = {}

local function GetPolicePressure(coords, radius)
    local pressure = 0
    local now = os.time()
    local decayTime = 600  -- Pressure decays over 10 minutes

    for key, data in pairs(areaPolicePressure) do
        local dist = #(coords - data.coords)
        if dist <= radius then
            local age = now - data.time
            if age < decayTime then
                local factor = 1 - (age / decayTime)
                pressure = pressure + (data.weight * factor)
            end
        end
    end

    return pressure
end

local function AddPolicePressure(coords, weight)
    local key = string.format('%.0f_%.0f', coords.x, coords.y)
    areaPolicePressure[key] = {
        coords = coords,
        time = os.time(),
        weight = weight
    }

    -- Cleanup old entries
    local now = os.time()
    for k, v in pairs(areaPolicePressure) do
        if now - v.time > 600 then
            areaPolicePressure[k] = nil
        end
    end
end

-- Export functions
return {
    OnDispatchCreated = OnDispatchCreated,
    OnDispatchResponse = OnDispatchResponse,
    OnWarrantIssued = OnWarrantIssued,
    OnBOLOCreated = OnBOLOCreated,
    OnEvidenceLogged = OnEvidenceLogged,
    OnReportFiled = OnReportFiled,
    OnRecordLookup = OnRecordLookup,
    GetPolicePressure = GetPolicePressure,
    AddPolicePressure = AddPolicePressure
}
