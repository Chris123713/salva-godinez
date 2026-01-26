--[[
    POLICE INTEGRATION SNIPPET
    Copy relevant parts into your police scripts (qb-policejob, ps-dispatch, etc.)

    This enables Mr. X to:
    - Track officer activity patterns
    - Generate detective/investigation missions for active officers
    - Create reactive criminal content based on police pressure
    - Link arrests to active criminal missions
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

-- ============================================
-- DISPATCH INTEGRATION
-- Add to ps-dispatch, cd_dispatch, etc.
-- ============================================

-- Call when officer accepts a dispatch call
local function OnDispatchAccepted(source, dispatchData)
    ReportToNexus('dispatch_received', {
        dispatchType = dispatchData.code or 'unknown',
        code = dispatchData.code,
        description = dispatchData.message or dispatchData.description,
        coords = dispatchData.coords,
        priority = dispatchData.priority or 'medium'
    }, source)
end

-- ============================================
-- PURSUIT INTEGRATION
-- ============================================

-- Call when pursuit begins
local function OnPursuitStart(source, suspectSource, vehicleData)
    ReportToNexus('pursuit_started', {
        suspectCitizenId = GetCitizenId(suspectSource),
        vehiclePlate = vehicleData.plate,
        vehicleModel = vehicleData.model,
        reason = vehicleData.reason or 'Suspect fleeing',
        coords = GetEntityCoords(GetPlayerPed(source))
    }, source)
end

-- Call when pursuit ends
local function OnPursuitEnd(source, outcome, duration)
    ReportToNexus('pursuit_ended', {
        outcome = outcome,  -- 'arrested', 'escaped', 'crashed', 'terminated'
        duration = duration,
        coords = GetEntityCoords(GetPlayerPed(source))
    }, source)
end

-- ============================================
-- ARREST INTEGRATION
-- ============================================

-- Call when arrest is made
local function OnArrestMade(source, suspectSource, arrestData)
    ReportToNexus('arrest_made', {
        suspectCitizenId = GetCitizenId(suspectSource),
        charges = arrestData.charges or {},
        coords = GetEntityCoords(GetPlayerPed(source)),
        fineAmount = arrestData.fine or 0,
        jailTime = arrestData.jailTime or 0
    }, source)
end

-- ============================================
-- CITATION INTEGRATION
-- ============================================

local function OnCitationIssued(source, targetSource, citationData)
    ReportToNexus('citation_issued', {
        targetCitizenId = GetCitizenId(targetSource),
        violation = citationData.violation,
        amount = citationData.amount,
        coords = GetEntityCoords(GetPlayerPed(source))
    }, source)
end

-- ============================================
-- EVIDENCE INTEGRATION
-- ============================================

local function OnEvidenceCollected(source, evidenceData)
    ReportToNexus('evidence_collected', {
        evidenceType = evidenceData.type,
        description = evidenceData.description,
        caseId = evidenceData.caseId,
        coords = GetEntityCoords(GetPlayerPed(source))
    }, source)
end

-- ============================================
-- MDT/CASE INTEGRATION
-- ============================================

local function OnCaseFiled(source, caseData)
    ReportToNexus('case_filed', {
        caseId = caseData.id,
        charges = caseData.charges,
        suspects = caseData.suspects,
        description = caseData.description
    }, source)
end

-- ============================================
-- PATROL INTEGRATION
-- ============================================

local function OnPatrolCheckpoint(source, area)
    ReportToNexus('patrol_checkpoint', {
        area = area,
        coords = GetEntityCoords(GetPlayerPed(source)),
        duration = 0  -- Set actual patrol duration if tracked
    }, source)
end

-- ============================================
-- EXAMPLE: ps-dispatch INTEGRATION
-- ============================================

--[[
-- In ps-dispatch/server/main.lua

RegisterNetEvent('ps-dispatch:server:notify', function(data)
    local src = source

    -- Existing code...

    -- ADD: Report to nexus
    OnDispatchAccepted(src, data)
end)
]]

-- ============================================
-- EXAMPLE: qb-policejob INTEGRATION
-- ============================================

--[[
-- In qb-policejob/server/main.lua

-- Arrest event
RegisterNetEvent('police:server:JailPlayer', function(playerId, time)
    local src = source

    -- Existing jail code...

    -- ADD: Report arrest
    OnArrestMade(src, playerId, {
        charges = GetPlayerCharges(playerId),  -- Your charge tracking
        jailTime = time,
        fine = 0
    })
end)

-- Fine/citation event
RegisterNetEvent('police:server:billPlayer', function(playerId, amount, reason)
    local src = source

    -- Existing billing code...

    -- ADD: Report citation
    OnCitationIssued(src, playerId, {
        violation = reason,
        amount = amount
    })
end)
]]

-- ============================================
-- EXAMPLE: Hook into existing pursuit system
-- ============================================

--[[
-- If your server uses a pursuit tracking system:

AddEventHandler('pursuit:started', function(officerSource, suspectSource, vehicleData)
    OnPursuitStart(officerSource, suspectSource, vehicleData)
end)

AddEventHandler('pursuit:ended', function(officerSource, outcome, duration)
    OnPursuitEnd(officerSource, outcome, duration)
end)
]]

-- ============================================
-- ADVANCED: Auto-detect police near crimes
-- ============================================

--[[
-- Subscribe to criminal events to know when police should respond
CreateThread(function()
    if GetResourceState('sv_nexus_tools') ~= 'started' then return end

    exports['sv_nexus_tools']:SubscribeToEvent('robbery_started', function(activity)
        -- Could auto-generate dispatch for police
        local coords = activity.data.coords
        -- TriggerEvent('ps-dispatch:server:robbery', coords, activity.data.robberyType)
    end)
end)
]]
