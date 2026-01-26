--[[
    Mr. X External Integration Hooks
    =================================
    Hooks into external resources for:
    - MDT/Police records
    - Death events (bounty completion)
    - Job activities
    - Economy tracking
]]

local Hooks = {}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function GetCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    return player and player.PlayerData.citizenid
end

local function JsonEncode(data)
    if data == nil then return nil end
    local success, result = pcall(json.encode, data)
    return success and result or nil
end

local function FindPlayerSource(citizenid)
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local player = exports.qbx_core:GetPlayer(tonumber(playerId))
        if player and player.PlayerData.citizenid == citizenid then
            return tonumber(playerId)
        end
    end
    return nil
end

-- ============================================
-- DEATH DETECTION HOOKS (Enhanced)
-- Ensures bounty/betrayal completion works
-- ============================================

-- Primary hook: QBX ambulancejob death
AddEventHandler('qbx_ambulancejob:server:playerDied', function(victimSource)
    if not victimSource then return end

    local victimCid = GetCitizenId(victimSource)
    if not victimCid then return end

    if Config.Debug then
        print('^3[MR_X:HOOKS]^7 Player died (qbx_ambulancejob): ' .. victimCid)
    end

    -- Check for active bounty
    local bounty = exports['sv_mr_x']:GetBountyOnPlayer(victimCid)
    if bounty and bounty.accepted_by then
        local hunterSource = FindPlayerSource(bounty.accepted_by)
        if hunterSource then
            -- Check if hunter is nearby
            local hunterPed = GetPlayerPed(hunterSource)
            local victimPed = GetPlayerPed(victimSource)

            if hunterPed and victimPed then
                local hunterCoords = GetEntityCoords(hunterPed)
                local victimCoords = GetEntityCoords(victimPed)
                local dist = #(hunterCoords - victimCoords)

                if dist < 100.0 then
                    -- Hunter was nearby - auto-claim bounty
                    exports['sv_mr_x']:ClaimBounty(bounty.accepted_by, victimCid)
                    if Config.Debug then
                        print('^2[MR_X:HOOKS]^7 Auto-claimed bounty for ' .. bounty.accepted_by)
                    end
                end
            end
        end
    end

    -- Check for gang betrayal
    pcall(function()
        exports['sv_mr_x']:CompleteBetrayal(nil, victimCid)
    end)

    -- Record death for fact discovery
    pcall(function()
        exports['sv_mr_x']:RecordFact(victimCid, 'DEATH', {
            timestamp = os.time(),
            wasKilled = false
        })
    end)
end)

-- Secondary hook: QBX ambulancejob killed by player
AddEventHandler('qbx_ambulancejob:server:playerKilled', function(victimSource, killerSource)
    if not victimSource or not killerSource then return end

    local victimCid = GetCitizenId(victimSource)
    local killerCid = GetCitizenId(killerSource)

    if not victimCid or not killerCid then return end

    if Config.Debug then
        print('^3[MR_X:HOOKS]^7 Player killed (qbx_ambulancejob): ' .. killerCid .. ' killed ' .. victimCid)
    end

    -- Check for bounty
    local bounty = exports['sv_mr_x']:GetBountyOnPlayer(victimCid)
    if bounty and bounty.accepted_by == killerCid then
        exports['sv_mr_x']:ClaimBounty(killerCid, victimCid)
        if Config.Debug then
            print('^2[MR_X:HOOKS]^7 Bounty claimed by ' .. killerCid)
        end
    end

    -- Check for gang betrayal
    local success, amount = exports['sv_mr_x']:CompleteBetrayal(killerCid, victimCid)
    if success then
        if Config.Debug then
            print('^2[MR_X:HOOKS]^7 Gang betrayal completed by ' .. killerCid)
        end
    end

    -- Record as facts
    pcall(function()
        exports['sv_mr_x']:RecordFact(victimCid, 'DEATH', {
            killedBy = killerCid,
            timestamp = os.time()
        })
        exports['sv_mr_x']:RecordFact(killerCid, 'KILL', {
            victim = victimCid,
            timestamp = os.time()
        })
    end)
end)

-- ============================================
-- OSP_AMBULANCE DEATH DETECTION HOOKS
-- Primary death detection for Sierra Valley RP
-- ============================================

-- Track death states to detect kills
local PlayerDeathStates = {}
local LastDamageSource = {}

-- Hook into osp_ambulance death status changes
-- This is the primary hook for death detection on this server
AddEventHandler('hospital:server:SetDeathStatus', function(isDead)
    local src = source
    local victimCid = GetCitizenId(src)
    if not victimCid then return end

    if Config.Debug then
        print('^3[MR_X:HOOKS]^7 Death status changed (osp_ambulance): ' .. victimCid .. ' isDead=' .. tostring(isDead))
    end

    if isDead then
        -- Player just died
        PlayerDeathStates[victimCid] = {
            timestamp = os.time(),
            source = src
        }

        -- Check for active bounty on this player
        local bounty = nil
        pcall(function()
            bounty = exports['sv_mr_x']:GetBountyOnPlayer(victimCid)
        end)

        if bounty and bounty.accepted_by then
            local hunterSource = FindPlayerSource(bounty.accepted_by)
            if hunterSource then
                -- Check if hunter is nearby (within 100 units = likely the killer)
                local hunterPed = GetPlayerPed(hunterSource)
                local victimPed = GetPlayerPed(src)

                if hunterPed and hunterPed ~= 0 and victimPed and victimPed ~= 0 then
                    local hunterCoords = GetEntityCoords(hunterPed)
                    local victimCoords = GetEntityCoords(victimPed)
                    local dist = #(hunterCoords - victimCoords)

                    if dist < 100.0 then
                        -- Hunter was nearby when target died - claim bounty
                        pcall(function()
                            exports['sv_mr_x']:ClaimBounty(bounty.accepted_by, victimCid)
                        end)
                        if Config.Debug then
                            print('^2[MR_X:HOOKS]^7 Auto-claimed bounty for ' .. bounty.accepted_by .. ' (osp_ambulance death)')
                        end
                    end
                end
            end
        end

        -- Check for gang betrayal completion
        pcall(function()
            exports['sv_mr_x']:CompleteBetrayal(nil, victimCid)
        end)

        -- Record death fact (camera-aware if enabled)
        pcall(function()
            exports['sv_mr_x']:RecordFact(victimCid, 'DEATH', {
                timestamp = os.time(),
                wasKilled = false  -- Unknown killer from this event
            })
        end)
    else
        -- Player respawned/revived - clear death state
        PlayerDeathStates[victimCid] = nil
    end
end)

-- Hook into laststand status (player is down but not dead yet)
AddEventHandler('hospital:server:SetLaststandStatus', function(isLaststand)
    local src = source
    local victimCid = GetCitizenId(src)
    if not victimCid then return end

    if Config.Debug then
        print('^3[MR_X:HOOKS]^7 Laststand status (osp_ambulance): ' .. victimCid .. ' inLaststand=' .. tostring(isLaststand))
    end

    if isLaststand then
        -- Player entered laststand - they might die soon
        -- Track this for potential bounty completion
        PlayerDeathStates[victimCid] = {
            timestamp = os.time(),
            source = src,
            laststand = true
        }
    end
end)

-- Fallback: Generic death resource hooks (legacy support)
AddEventHandler('hospital:server:playerDied', function(source)
    local victimCid = GetCitizenId(source)
    if victimCid then
        -- Check for nearby bounty hunter
        local bounty = exports['sv_mr_x']:GetBountyOnPlayer(victimCid)
        if bounty and bounty.accepted_by then
            local hunterSource = FindPlayerSource(bounty.accepted_by)
            if hunterSource then
                local dist = #(GetEntityCoords(GetPlayerPed(hunterSource)) - GetEntityCoords(GetPlayerPed(source)))
                if dist < 100.0 then
                    exports['sv_mr_x']:ClaimBounty(bounty.accepted_by, victimCid)
                end
            end
        end
    end
end)

-- ============================================
-- MDT / POLICE RECORD HOOKS
-- lb-tablet integration for early warnings
-- ============================================

-- Hook into warrant creation
AddEventHandler('lb-tablet:server:warrantCreated', function(targetCid, warrantData)
    if not targetCid then return end

    if Config.Debug then
        print('^3[MR_X:HOOKS]^7 Warrant created for ' .. targetCid)
    end

    -- Record fact
    pcall(function()
        exports['sv_mr_x']:RecordFact(targetCid, 'WARRANT', {
            timestamp = os.time(),
            type = warrantData and warrantData.type or 'unknown'
        })
    end)

    -- Send early warning if player qualifies
    local source = FindPlayerSource(targetCid)
    if source then
        local qualifies = exports['sv_mr_x']:QualifiesForEarlyWarning(targetCid)
        if qualifies then
            exports['sv_mr_x']:SendEarlyWarning(source, 'WARRANT', {warrantId = warrantData and warrantData.id})
        end
    end
end)

-- Hook into BOLO creation
AddEventHandler('lb-tablet:server:boloCreated', function(targetCid, boloData)
    if not targetCid then return end

    if Config.Debug then
        print('^3[MR_X:HOOKS]^7 BOLO created for ' .. targetCid)
    end

    -- Record fact
    pcall(function()
        exports['sv_mr_x']:RecordFact(targetCid, 'BOLO', {
            timestamp = os.time(),
            description = boloData and boloData.description or nil
        })
    end)

    -- Send early warning
    local source = FindPlayerSource(targetCid)
    if source then
        local qualifies = exports['sv_mr_x']:QualifiesForEarlyWarning(targetCid)
        if qualifies then
            exports['sv_mr_x']:SendEarlyWarning(source, 'BOLO', {boloId = boloData and boloData.id})
        end
    end
end)

-- Hook into police report creation
AddEventHandler('lb-tablet:server:reportCreated', function(targetCid, reportData)
    if not targetCid then return end

    if Config.Debug then
        print('^3[MR_X:HOOKS]^7 Police report on ' .. targetCid)
    end

    -- Record fact
    pcall(function()
        exports['sv_mr_x']:RecordFact(targetCid, 'POLICE_REPORT', {
            timestamp = os.time(),
            charges = reportData and reportData.charges or nil
        })
    end)

    -- Early warning for investigation
    local source = FindPlayerSource(targetCid)
    if source then
        local qualifies = exports['sv_mr_x']:QualifiesForEarlyWarning(targetCid)
        if qualifies then
            exports['sv_mr_x']:SendEarlyWarning(source, 'INVESTIGATION', nil)
        end
    end
end)

-- ============================================
-- ECONOMY HOOKS
-- Track large transactions
-- NOTE: Cash requires camera visibility, bank requires financial intel
-- ============================================

-- Hook into money changes
AddEventHandler('QBCore:Server:OnMoneyChange', function(source, moneyType, amount, action, reason)
    if not source or amount < 10000 then return end  -- Only track large amounts

    local citizenid = GetCitizenId(source)
    if not citizenid then return end

    -- Record activity (always recorded for internal tracking)
    pcall(function()
        exports['sv_mr_x']:RecordActivity(citizenid, 'money_change', {
            type = moneyType,
            amount = amount,
            action = action,
            reason = reason
        })
    end)

    -- Record large transactions as facts with camera-awareness
    -- Cash transactions: require camera visibility (physical exchange)
    -- Bank transactions: require financial intel source (electronic, not visible on camera)
    if amount >= 50000 then
        local isCash = moneyType == 'cash'

        pcall(function()
            if isCash then
                -- Cash transactions visible on camera (counting, exchanging)
                exports['sv_mr_x']:RecordFact(citizenid, 'LARGE_CASH_TRANSACTION', {
                    type = moneyType,
                    amount = amount,
                    action = action,
                    reason = reason,
                    timestamp = os.time()
                }, source, true)  -- requireCamera = true
            else
                -- Bank/electronic transactions - NOT visible on camera
                -- Requires Mr. X to have financial network access (bank hack, insider, etc.)
                exports['sv_mr_x']:RecordFact(citizenid, 'BANK_INTEL_TRANSACTION', {
                    type = moneyType,
                    amount = amount,
                    action = action,
                    reason = reason,
                    timestamp = os.time(),
                    intelSource = 'financial_network'
                }, source, false)  -- requireCamera = false (but could add bank_access check)
            end
        end)
    end
end)

-- ============================================
-- WEAPON/ITEM PURCHASE HOOKS
-- ============================================

-- Hook into illegal weapon purchases (if weapons shop exists)
AddEventHandler('qb-weapons:server:buyWeapon', function(source, weapon, price)
    local citizenid = GetCitizenId(source)
    if not citizenid then return end

    -- Record activity
    pcall(function()
        exports['sv_mr_x']:RecordActivity(citizenid, 'weapon_purchase', {
            weapon = weapon,
            price = price
        })
    end)

    -- Record as fact
    pcall(function()
        exports['sv_mr_x']:RecordFact(citizenid, 'WEAPON_PURCHASE', {
            weapon = weapon,
            timestamp = os.time()
        })
    end)
end)

-- Hook into illegal item crafting
AddEventHandler('qb-crafting:server:craftItem', function(source, item, amount)
    local citizenid = GetCitizenId(source)
    if not citizenid then return end

    -- Check if it's an illegal/interesting item
    local illegalItems = {
        'lockpick', 'advancedlockpick', 'weapon_', 'thermite',
        'laptop', 'electronickit', 'drill'
    }

    local isIllegal = false
    for _, pattern in ipairs(illegalItems) do
        if item:lower():find(pattern) then
            isIllegal = true
            break
        end
    end

    if isIllegal then
        pcall(function()
            exports['sv_mr_x']:RecordFact(citizenid, 'CRAFTED_ITEM', {
                item = item,
                amount = amount,
                timestamp = os.time()
            })
        end)
    end
end)

-- ============================================
-- VEHICLE HOOKS
-- ============================================

-- Hook into vehicle theft
AddEventHandler('qb-vehiclekeys:server:vehicleStolen', function(source, plate)
    local citizenid = GetCitizenId(source)
    if not citizenid then return end

    pcall(function()
        exports['sv_mr_x']:RecordFact(citizenid, 'VEHICLE_THEFT', {
            plate = plate,
            timestamp = os.time()
        })
        exports['sv_mr_x']:RecordActivity(citizenid, 'vehicle_theft', {plate = plate})
    end)
end)

-- Hook into lockpicking
AddEventHandler('qb-lockpick:server:success', function(source, plate)
    local citizenid = GetCitizenId(source)
    if not citizenid then return end

    pcall(function()
        exports['sv_mr_x']:RecordFact(citizenid, 'LOCKPICK', {
            plate = plate,
            timestamp = os.time()
        })
    end)
end)

-- ============================================
-- GANG ACTIVITY HOOKS
-- ============================================

-- Hook into gang territory activities
AddEventHandler('qb-gangmenu:server:claimTerritory', function(source, territory)
    local citizenid = GetCitizenId(source)
    if not citizenid then return end

    pcall(function()
        exports['sv_mr_x']:RecordFact(citizenid, 'GANG_TERRITORY', {
            territory = territory,
            timestamp = os.time()
        })
        exports['sv_mr_x']:RecordActivity(citizenid, 'gang_activity', {type = 'territory_claim'})
    end)
end)

-- ============================================
-- JOB CHANGE HOOKS
-- ============================================

AddEventHandler('QBCore:Server:OnJobUpdate', function(source, job)
    local citizenid = GetCitizenId(source)
    if not citizenid then return end

    pcall(function()
        exports['sv_mr_x']:RecordFact(citizenid, 'JOB_CHANGE', {
            job = job.name,
            grade = job.grade and job.grade.level or 0,
            timestamp = os.time()
        })
    end)

    -- Update archetype if needed
    pcall(function()
        exports['sv_mr_x']:UpdateArchetype(citizenid, source)
    end)
end)

AddEventHandler('QBCore:Server:OnGangUpdate', function(source, gang)
    local citizenid = GetCitizenId(source)
    if not citizenid then return end

    pcall(function()
        exports['sv_mr_x']:RecordFact(citizenid, 'GANG_CHANGE', {
            gang = gang.name,
            grade = gang.grade and gang.grade.level or 0,
            timestamp = os.time()
        })
    end)
end)

-- ============================================
-- ROBBERY/HEIST HOOKS
-- ============================================

-- Bank robbery hooks
AddEventHandler('qb-bankrobbery:server:startRobbery', function(source, bankType)
    local citizenid = GetCitizenId(source)
    if not citizenid then return end

    pcall(function()
        exports['sv_mr_x']:RecordFact(citizenid, 'BANK_ROBBERY', {
            bankType = bankType,
            timestamp = os.time()
        })
        exports['sv_mr_x']:RecordActivity(citizenid, 'robbery', {type = bankType})
    end)
end)

-- Store robbery hooks
AddEventHandler('qb-storerobbery:server:startRobbery', function(source, storeId)
    local citizenid = GetCitizenId(source)
    if not citizenid then return end

    pcall(function()
        exports['sv_mr_x']:RecordFact(citizenid, 'STORE_ROBBERY', {
            storeId = storeId,
            timestamp = os.time()
        })
        exports['sv_mr_x']:RecordActivity(citizenid, 'robbery', {type = 'store'})
    end)
end)

-- Jewelry heist hooks
AddEventHandler('qb-jewelery:server:startHeist', function(source)
    local citizenid = GetCitizenId(source)
    if not citizenid then return end

    pcall(function()
        exports['sv_mr_x']:RecordFact(citizenid, 'JEWELRY_HEIST', {timestamp = os.time()})
        exports['sv_mr_x']:RecordActivity(citizenid, 'robbery', {type = 'jewelry'})
    end)
end)

-- ============================================
-- ARREST/JAIL HOOKS
-- ============================================

AddEventHandler('qbx_prison:server:jailed', function(source, time, reason)
    local citizenid = GetCitizenId(source)
    if not citizenid then return end

    pcall(function()
        exports['sv_mr_x']:RecordFact(citizenid, 'JAILED', {
            time = time,
            reason = reason,
            timestamp = os.time()
        })
    end)
end)

AddEventHandler('police:server:playerArrested', function(source, charges)
    local citizenid = GetCitizenId(source)
    if not citizenid then return end

    pcall(function()
        exports['sv_mr_x']:RecordFact(citizenid, 'ARRESTED', {
            charges = charges,
            timestamp = os.time()
        })
    end)
end)

-- ============================================
-- SERVICE INTEGRATION HOOKS
-- Mechanic, Dealer, etc.
-- ============================================

-- Mechanic service used
AddEventHandler('qb-mechanicjob:server:repairVehicle', function(mechanicSource, customerSource, plate, cost)
    -- Track mechanic activity
    local mechanicCid = GetCitizenId(mechanicSource)
    if mechanicCid then
        pcall(function()
            exports['sv_mr_x']:RecordActivity(mechanicCid, 'job_activity', {
                type = 'mechanic_repair',
                customer = GetCitizenId(customerSource),
                cost = cost
            })
        end)
    end

    -- Track customer vehicle repair
    local customerCid = GetCitizenId(customerSource)
    if customerCid then
        pcall(function()
            exports['sv_mr_x']:RecordFact(customerCid, 'VEHICLE_REPAIR', {
                plate = plate,
                cost = cost,
                timestamp = os.time()
            })
        end)
    end
end)

-- ============================================
-- PLAYER KILL DETECTION (via damage tracking)
-- ============================================

-- Track last damage to attribute kills
-- This helps identify who killed whom when death status changes
local LastDamageBy = {}
local DAMAGE_ATTRIBUTION_WINDOW = 10  -- seconds

---Record that a player was damaged by another player
---@param victimSource number
---@param attackerSource number
local function RecordDamage(victimSource, attackerSource)
    local victimCid = GetCitizenId(victimSource)
    local attackerCid = GetCitizenId(attackerSource)

    if victimCid and attackerCid and victimCid ~= attackerCid then
        LastDamageBy[victimCid] = {
            attackerCid = attackerCid,
            attackerSource = attackerSource,
            timestamp = os.time()
        }
    end
end

---Get the likely killer for a victim (within attribution window)
---@param victimCid string
---@return string|nil killerCid
---@return number|nil killerSource
local function GetLikelyKiller(victimCid)
    local damage = LastDamageBy[victimCid]
    if not damage then return nil, nil end

    local elapsed = os.time() - damage.timestamp
    if elapsed <= DAMAGE_ATTRIBUTION_WINDOW then
        return damage.attackerCid, damage.attackerSource
    end

    return nil, nil
end

-- Hook for player damage (if baseevents is available)
AddEventHandler('baseevents:onPlayerDied', function(killerType, deathCoords)
    local src = source
    local victimCid = GetCitizenId(src)
    if not victimCid then return end

    -- Get likely killer from damage tracking
    local killerCid, killerSource = GetLikelyKiller(victimCid)

    if killerCid then
        if Config.Debug then
            print('^3[MR_X:HOOKS]^7 Player killed (baseevents): ' .. killerCid .. ' killed ' .. victimCid)
        end

        -- Check for bounty
        local bounty = nil
        pcall(function()
            bounty = exports['sv_mr_x']:GetBountyOnPlayer(victimCid)
        end)

        if bounty and bounty.accepted_by == killerCid then
            pcall(function()
                exports['sv_mr_x']:ClaimBounty(killerCid, victimCid)
            end)
            if Config.Debug then
                print('^2[MR_X:HOOKS]^7 Bounty claimed by ' .. killerCid .. ' (baseevents)')
            end
        end

        -- Check for gang betrayal
        pcall(function()
            exports['sv_mr_x']:CompleteBetrayal(killerCid, victimCid)
        end)

        -- Record kill facts
        pcall(function()
            exports['sv_mr_x']:RecordFact(victimCid, 'DEATH', {
                killedBy = killerCid,
                timestamp = os.time()
            })
            exports['sv_mr_x']:RecordFact(killerCid, 'KILL', {
                victim = victimCid,
                timestamp = os.time()
            })
        end)
    end

    -- Clear damage tracking
    LastDamageBy[victimCid] = nil
end)

-- Hook for player killed events (if baseevents fires this separately)
AddEventHandler('baseevents:onPlayerKilled', function(killerId, deathData)
    local src = source
    local victimCid = GetCitizenId(src)
    local killerCid = GetCitizenId(killerId)

    if not victimCid then return end

    if killerCid then
        if Config.Debug then
            print('^3[MR_X:HOOKS]^7 Player killed (baseevents:onPlayerKilled): ' .. killerCid .. ' killed ' .. victimCid)
        end

        -- Check for bounty
        local bounty = nil
        pcall(function()
            bounty = exports['sv_mr_x']:GetBountyOnPlayer(victimCid)
        end)

        if bounty and bounty.accepted_by == killerCid then
            pcall(function()
                exports['sv_mr_x']:ClaimBounty(killerCid, victimCid)
            end)
        end

        -- Check for gang betrayal
        pcall(function()
            exports['sv_mr_x']:CompleteBetrayal(killerCid, victimCid)
        end)
    end
end)

-- ============================================
-- INITIALIZATION
-- ============================================

CreateThread(function()
    Wait(5000)  -- Wait for resources to load

    if Config.Debug then
        print('^2[MR_X:HOOKS]^7 External hooks module loaded')
        print('^2[MR_X:HOOKS]^7 Registered death, MDT, economy, and activity hooks')
    end

    -- Register any dynamic hooks based on available resources
    local resources = {
        'lb-tablet', 'qbx_ambulancejob', 'qbx_prison',
        'qb-bankrobbery', 'qb-storerobbery', 'qb-jewelery',
        'qb-weapons', 'qb-vehiclekeys', 'osp_ambulance'
    }

    for _, resource in ipairs(resources) do
        local state = GetResourceState(resource)
        if state == 'started' then
            if Config.Debug then
                print('^2[MR_X:HOOKS]^7 ✓ Detected resource: ' .. resource)
            end
        elseif state == 'missing' then
            -- Only log important missing resources
        else
            if Config.Debug then
                print('^3[MR_X:HOOKS]^7 Resource ' .. resource .. ' state: ' .. state)
            end
        end
    end

    -- Specific check for osp_ambulance (primary death system)
    if GetResourceState('osp_ambulance') == 'started' then
        print('^2[MR_X:HOOKS]^7 ✓ osp_ambulance detected - using as primary death detection')
    else
        print('^3[MR_X:HOOKS]^7 ⚠ osp_ambulance not found - using fallback death detection')
    end
end)

-- ============================================
-- EXPORTS
-- ============================================

-- Export to allow other modules to record damage for kill attribution
exports('RecordPlayerDamage', function(victimSource, attackerSource)
    RecordDamage(victimSource, attackerSource)
end)

-- Export to get likely killer
exports('GetLikelyKiller', function(victimCid)
    return GetLikelyKiller(victimCid)
end)

-- Export to check if player is in death/laststand state
exports('IsPlayerDead', function(citizenid)
    return PlayerDeathStates[citizenid] ~= nil
end)

-- Return module
return Hooks
