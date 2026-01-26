if GetConvar('qbx:enablebridge', 'true') == 'false' then return end

-- This will hold the real QBCore object once it's ready
local qbCoreCompatObject = nil
local isReady = false

-- Create a proxy stub that forwards calls to the real object when ready
-- This ensures scripts that cache the object early still work
local function createForwardingStub()
    -- Create forwarding tables for nested objects that scripts might cache
    local functionsProxy = setmetatable({}, {
        __index = function(_, key)
            -- If real object is ready, forward to it
            if isReady and qbCoreCompatObject and qbCoreCompatObject.Functions then
                return qbCoreCompatObject.Functions[key]
            end
            -- Otherwise return safe defaults
            local safeFunctions = {
                GetPlayer = function() return nil end,
                GetPlayerByCitizenId = function() return nil end,
                GetPlayers = function() return {} end,
                GetQBPlayers = function() return {} end,  -- For NPWD
                CreateCallback = function() end,
                TriggerCallback = function() end,
                TriggerClientCallback = function() end,
                CreateUseableItem = function() end,
                AddItem = function() return false end,
                RemoveItem = function() return false end,
                AddMoney = function() return false end,
                RemoveMoney = function() return false end,
                GetMoney = function() return 0 end,
                SpawnVehicle = function() return nil end,
                CreateVehicle = function() return nil end,
                Notify = function() end,
                HasItem = function() return false end,
                AddJobRep = function() end
            }
            return safeFunctions[key]
        end
    })
    
    local commandsProxy = setmetatable({}, {
        __index = function(_, key)
            -- If real object is ready, forward to it
            if isReady and qbCoreCompatObject and qbCoreCompatObject.Commands then
                return qbCoreCompatObject.Commands[key]
            end
            -- Otherwise return safe defaults
            if key == 'Add' then
                return function(...) 
                    if isReady and qbCoreCompatObject and qbCoreCompatObject.Commands then
                        return qbCoreCompatObject.Commands.Add(...)
                    end
                end
            elseif key == 'Refresh' then
                return function() end
            elseif key == 'List' then
                return {}
            end
            return nil
        end
    })
    
    return setmetatable({}, {
        __index = function(_, key)
            -- If the real object is ready, forward to it
            if isReady and qbCoreCompatObject then
                return qbCoreCompatObject[key]
            end
            -- Otherwise return safe defaults or proxies
            if key == 'Functions' then
                return functionsProxy
            elseif key == 'Commands' then
                return commandsProxy
            elseif key == 'Config' or key == 'Shared' or key == 'Players' or key == 'Player' or key == 'UsableItems' then
                return {}
            end
            return nil
        end
    })
end

local stubObject = createForwardingStub()
qbCoreCompatObject = stubObject

local placeholderFunction = function()
    -- Return stub object immediately for compiled JavaScript compatibility (NPWD)
    -- This prevents "No such export" errors when NPWD checks synchronously
    return qbCoreCompatObject
end

-- CRITICAL: Register export IMMEDIATELY using FiveM's export system
-- This is required for compiled JavaScript resources like NPWD to find the export
-- We register it immediately so NPWD can find it even if qbCoreCompat isn't ready yet
-- IMPORTANT: This must be registered BEFORE any require() calls
-- NOTE: We cannot use exports['qb-core'].GetCoreObject = ... with provide directive
-- We must use exports() function and __cfx_export_ event handler instead

-- Register using exports() function for maximum compatibility
exports('GetCoreObject', placeholderFunction)

-- Also register GetQBPlayers immediately for NPWD
-- NPWD calls this as a separate export, not through GetCoreObject().Functions
local getQBPlayersStub = function()
    -- If not ready yet, return nil to signal that the function isn't available yet
    -- qbx_npwd checks for nil and handles it appropriately
    if not isReady or not qbCoreCompatObject or not qbCoreCompatObject.Functions then
        return nil
    end
    
    -- Forward to the real function which formats data correctly for JavaScript
    local success, result = pcall(function()
        return qbCoreCompatObject.Functions.GetQBPlayers()
    end)
    
    if success and result then
        return result
    end
    
    -- Return nil on error - this is safer than an empty table for JavaScript iteration
    return nil
end
exports('GetQBPlayers', getQBPlayersStub)

-- Also register via FiveM's export event system for compiled JavaScript resources
AddEventHandler('__cfx_export_qb-core_GetCoreObject', function(setCB)
    -- Return the current function (will be updated when qbCoreCompat is ready)
    -- This ensures the export exists even if it returns a stub initially
    setCB(function() return qbCoreCompatObject end)
end)

AddEventHandler('__cfx_export_qbx_core_GetCoreObject', function(setCB)
    -- Also register for qbx_core export
    setCB(function() return qbCoreCompatObject end)
end)

AddEventHandler('__cfx_export_qb-core_GetQBPlayers', function(setCB)
    -- Register GetQBPlayers for NPWD compatibility
    setCB(getQBPlayersStub)
end)

require 'bridge.qb.server.debug'
require 'bridge.qb.server.events'

local convertItems = require 'bridge.qb.shared.compat'.convertItems
convertItems(require '@ox_inventory.data.items', require 'shared.items')

---@diagnostic disable-next-line: lowercase-global
qbCoreCompat = {}

-- Wait for QBX to be initialized
while not QBX or not QBX.Players or not QBX.UsableItems do
    Wait(50)
end

qbCoreCompat.Config = lib.table.merge(require 'config.server', require 'config.shared')
qbCoreCompat.Shared = require 'bridge.qb.shared.main'
qbCoreCompat.Shared.Jobs = GetJobs()
qbCoreCompat.Shared.Gangs = GetGangs()
qbCoreCompat.Players = QBX.Players
qbCoreCompat.Player = require 'bridge.qb.server.player'
qbCoreCompat.Player_Buckets = QBX.Player_Buckets
qbCoreCompat.Entity_Buckets = QBX.Entity_Buckets
qbCoreCompat.UsableItems = QBX.UsableItems
qbCoreCompat.Functions = require 'bridge.qb.server.functions'
qbCoreCompat.Commands = require 'bridge.qb.server.commands'

---@diagnostic disable: deprecated

---@deprecated Call lib.print.debug() instead
qbCoreCompat.Debug = lib.print.debug

---@deprecated Call lib.print.error() instead
qbCoreCompat.ShowError = lib.print.error

---@deprecated Use lib.print.info() instead
qbCoreCompat.ShowSuccess = lib.print.info

---@deprecated use https://coxdocs.dev/ox_lib/Modules/Callback/Lua/Server instead
qbCoreCompat.ClientCallbacks = {}

---@deprecated use https://coxdocs.dev/ox_lib/Modules/Callback/Lua/Server instead
qbCoreCompat.ServerCallbacks = {}

-- Callback Events --

-- Client Callback
---@deprecated use https://coxdocs.dev/ox_lib/Modules/Callback/Lua/Server instead
RegisterNetEvent('QBCore:Server:TriggerClientCallback', function(name, ...)
    if qbCoreCompat.ClientCallbacks[name] then
        qbCoreCompat.ClientCallbacks[name](...)
        qbCoreCompat.ClientCallbacks[name] = nil
    end
end)

-- Server Callback
---@deprecated use https://coxdocs.dev/ox_lib/Modules/Callback/Lua/Server instead
RegisterNetEvent('QBCore:Server:TriggerCallback', function(name, ...)
    local src = source
    qbCoreCompat.Functions.TriggerCallback(name, src, function(...)
        TriggerClientEvent('QBCore:Client:TriggerCallback', src, name, ...)
    end, ...)
end)

--- @deprecated
RegisterNetEvent('QBCore:CallCommand', function(command, args)
    local src = source --[[@as Source]]
    local player = GetPlayer(src)
    if not player then return end
    if IsPlayerAceAllowed(src --[[@as string]], ('command.%s'):format(command)) then
        local commandString = command
        for _, value in pairs(args) do
            commandString = ('%s %s'):format(commandString, value)
        end
        TriggerClientEvent('QBCore:Command:CallCommand', src, commandString)
    end
end)

-- Callback Functions --

-- Client Callback
---@deprecated use https://coxdocs.dev/ox_lib/Modules/Callback/Lua/Server instead
function qbCoreCompat.Functions.TriggerClientCallback(name, source, cb, ...)
    qbCoreCompat.ClientCallbacks[name] = cb
    TriggerClientEvent('QBCore:Client:TriggerClientCallback', source, name, ...)
end

-- Server Callback
---@deprecated use https://coxdocs.dev/ox_lib/Modules/Callback/Lua/Server instead
function qbCoreCompat.Functions.CreateCallback(name, cb)
    qbCoreCompat.ServerCallbacks[name] = cb
end

---@deprecated call a function instead
function qbCoreCompat.Functions.TriggerCallback(name, source, cb, ...)
    if not qbCoreCompat.ServerCallbacks[name] then return end
    qbCoreCompat.ServerCallbacks[name](source, cb, ...)
end

---@deprecated call server function qbx.spawnVehicle from modules/lib.lua
qbCoreCompat.Functions.CreateCallback('QBCore:Server:SpawnVehicle', function(source, cb, model, coords, warp)
    local vehId = qbCoreCompat.Functions.SpawnVehicle(source, model, coords, warp)

    if vehId then cb(NetworkGetNetworkIdFromEntity(vehId)) end
end)

---@deprecated call server function qbx.spawnVehicle from modules/lib.lua
qbCoreCompat.Functions.CreateCallback('QBCore:Server:CreateVehicle', function(source, cb, model, coords, warp)
    local vehId = qbCoreCompat.Functions.CreateVehicle(source, model, nil, coords, warp)

    if vehId then cb(NetworkGetNetworkIdFromEntity(vehId)) end
end)

AddEventHandler('qbx_core:server:onJobUpdate', function(jobName, job)
    qbCoreCompat.Shared.Jobs[jobName] = job
end)

AddEventHandler('qbx_core:server:onGangUpdate', function(gangName, gang)
    qbCoreCompat.Shared.Gangs[gangName] = gang
end)

-- Now that qbCoreCompat is ready, update the reference and mark as ready
qbCoreCompatObject = qbCoreCompat
isReady = true

-- Use the standard export function registration system
-- This properly registers exports for both qb-core and qbx_core
local createQbExport = require 'bridge.qb.shared.export-function'
createQbExport('GetCoreObject', function()
    return qbCoreCompat
end)

-- Register QBCore:GetObject event for scripts that use it as a fallback
-- This event is triggered by scripts when exports fail
AddEventHandler('QBCore:GetObject', function(cb)
    if type(cb) == 'function' then
        cb(qbCoreCompat)
    end
end)

-- Export Functions directly for compatibility with scripts that expect exports['qbx_core']:Functions
exports('Functions', qbCoreCompat.Functions)