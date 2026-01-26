local config = require 'config'

-- Player states (server-side source of truth)
local playerStates = {}

-- =====================
-- HELPER FUNCTIONS
-- =====================

local function GetPlayer(source)
    return exports.qbx_core:GetPlayer(source)
end

local function IsPolice(source)
    local player = GetPlayer(source)
    if not player then return false end

    local job = player.PlayerData.job
    if not job then return false end

    return IsPoliceJob(config.policeJobs, job.name)
end

local function HasRequiredGrade(source, action)
    local player = GetPlayer(source)
    if not player then return false end

    local required = config.gradeRequirements[action] or 0
    local grade = player.PlayerData.job.grade or 0

    return grade >= required
end

local function Notify(source, msg, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Police',
        description = msg,
        type = type or 'inform'
    })
end

local function GetPlayerState(source)
    if not playerStates[source] then
        playerStates[source] = {
            isCuffed = false,
            isHardCuffed = false,
            isEscorted = false,
            escortedBy = nil
        }
    end
    return playerStates[source]
end

local function GetDistance(source1, source2)
    local ped1 = GetPlayerPed(source1)
    local ped2 = GetPlayerPed(source2)

    if not ped1 or not ped2 then return 9999 end

    local coords1 = GetEntityCoords(ped1)
    local coords2 = GetEntityCoords(ped2)

    return #(coords1 - coords2)
end

-- =====================
-- CALLBACKS
-- =====================

lib.callback.register('sv_police_actions:isPlayerCuffed', function(source, targetId)
    local state = GetPlayerState(targetId)
    return state.isCuffed
end)

lib.callback.register('sv_police_actions:isPlayerEscorted', function(source, targetId)
    local state = GetPlayerState(targetId)
    return state.isEscorted
end)

lib.callback.register('sv_police_actions:getPlayerState', function(source, targetId)
    return GetPlayerState(targetId)
end)

-- =====================
-- UNIT BLIPS
-- =====================

lib.callback.register('sv_police_actions:getUnitPositions', function(source)
    if not config.unitBlips or not config.unitBlips.enabled then
        return nil
    end

    local units = {}
    local players = GetPlayers()

    for _, playerId in ipairs(players) do
        local player = GetPlayer(tonumber(playerId))
        if player then
            local job = player.PlayerData.job
            local jobName = job and job.name

            -- Check if this job should show on map
            if jobName and config.unitBlips.blips[jobName] then
                -- Check on-duty requirement
                local showUnit = true
                if config.unitBlips.showOnlyOnDuty then
                    showUnit = job.onduty == true
                end

                if showUnit then
                    local ped = GetPlayerPed(playerId)
                    local coords = GetEntityCoords(ped)
                    local charinfo = player.PlayerData.charinfo

                    -- Check vehicle and siren state
                    local inVehicle = false
                    local sirenOn = false
                    local vehicle = GetVehiclePedIsIn(ped, false)

                    if vehicle and vehicle ~= 0 then
                        inVehicle = true
                        sirenOn = IsVehicleSirenOn(vehicle)
                    end

                    units[tonumber(playerId)] = {
                        coords = {
                            x = coords.x,
                            y = coords.y,
                            z = coords.z
                        },
                        job = jobName,
                        rank = job.grade and job.grade.name or nil,
                        callsign = player.PlayerData.metadata and player.PlayerData.metadata.callsign or nil,
                        name = charinfo and (charinfo.firstname .. ' ' .. charinfo.lastname) or nil,
                        inVehicle = inVehicle,
                        sirenOn = sirenOn
                    }
                end
            end
        end
    end

    return units
end)

-- =====================
-- FRISK
-- =====================

-- Items that can be "felt" during a frisk (weapons, large items)
local friskableWeapons = {
    -- Pistols
    ['weapon_pistol'] = 'Pistol',
    ['weapon_pistol_mk2'] = 'Pistol',
    ['weapon_combatpistol'] = 'Pistol',
    ['weapon_appistol'] = 'Pistol',
    ['weapon_stungun'] = 'Taser',
    ['weapon_pistol50'] = 'Heavy Pistol',
    ['weapon_snspistol'] = 'Small Pistol',
    ['weapon_snspistol_mk2'] = 'Small Pistol',
    ['weapon_heavypistol'] = 'Heavy Pistol',
    ['weapon_vintagepistol'] = 'Pistol',
    ['weapon_flaregun'] = 'Flare Gun',
    ['weapon_marksmanpistol'] = 'Pistol',
    ['weapon_revolver'] = 'Revolver',
    ['weapon_revolver_mk2'] = 'Revolver',
    ['weapon_doubleaction'] = 'Revolver',
    ['weapon_raypistol'] = 'Strange Device',
    ['weapon_ceramicpistol'] = 'Pistol',
    ['weapon_navyrevolver'] = 'Revolver',
    ['weapon_gadgetpistol'] = 'Pistol',
    -- SMGs
    ['weapon_microsmg'] = 'Compact SMG',
    ['weapon_smg'] = 'SMG',
    ['weapon_smg_mk2'] = 'SMG',
    ['weapon_assaultsmg'] = 'SMG',
    ['weapon_combatpdw'] = 'PDW',
    ['weapon_machinepistol'] = 'Machine Pistol',
    ['weapon_minismg'] = 'Mini SMG',
    ['weapon_raycarbine'] = 'Strange Device',
    -- Shotguns
    ['weapon_pumpshotgun'] = 'Shotgun',
    ['weapon_pumpshotgun_mk2'] = 'Shotgun',
    ['weapon_sawnoffshotgun'] = 'Sawed-off',
    ['weapon_assaultshotgun'] = 'Shotgun',
    ['weapon_bullpupshotgun'] = 'Shotgun',
    ['weapon_musket'] = 'Long Gun',
    ['weapon_heavyshotgun'] = 'Heavy Shotgun',
    ['weapon_dbshotgun'] = 'Double Barrel',
    ['weapon_autoshotgun'] = 'Shotgun',
    ['weapon_combatshotgun'] = 'Shotgun',
    -- Rifles
    ['weapon_assaultrifle'] = 'Rifle',
    ['weapon_assaultrifle_mk2'] = 'Rifle',
    ['weapon_carbinerifle'] = 'Rifle',
    ['weapon_carbinerifle_mk2'] = 'Rifle',
    ['weapon_advancedrifle'] = 'Rifle',
    ['weapon_specialcarbine'] = 'Rifle',
    ['weapon_specialcarbine_mk2'] = 'Rifle',
    ['weapon_bullpuprifle'] = 'Rifle',
    ['weapon_bullpuprifle_mk2'] = 'Rifle',
    ['weapon_compactrifle'] = 'Compact Rifle',
    ['weapon_militaryrifle'] = 'Military Rifle',
    ['weapon_heavyrifle'] = 'Heavy Rifle',
    ['weapon_tacticalrifle'] = 'Tactical Rifle',
    -- Melee
    ['weapon_knife'] = 'Knife',
    ['weapon_nightstick'] = 'Baton',
    ['weapon_hammer'] = 'Hammer',
    ['weapon_bat'] = 'Bat',
    ['weapon_crowbar'] = 'Crowbar',
    ['weapon_golfclub'] = 'Club',
    ['weapon_bottle'] = 'Bottle',
    ['weapon_dagger'] = 'Knife',
    ['weapon_hatchet'] = 'Hatchet',
    ['weapon_knuckle'] = 'Knuckles',
    ['weapon_machete'] = 'Machete',
    ['weapon_switchblade'] = 'Switchblade',
    ['weapon_battleaxe'] = 'Axe',
    ['weapon_poolcue'] = 'Pool Cue',
    ['weapon_stone_hatchet'] = 'Hatchet',
}

-- Contraband/suspicious items that can be felt
local friskableContraband = {
    -- Drugs Creator items
    ['drug_lsd'] = 'Small paper tabs',
    ['drug_meth'] = 'Crystalline baggie',
    ['drug_lean'] = 'Bottle of liquid',
    ['drug_ecstasy'] = 'Pill baggie',

    -- Weed varieties
    ['weed'] = 'Baggie of plant matter',
    ['weed_brick'] = 'Large compressed package',
    ['weed_ak47'] = 'Baggie of plant matter',
    ['weed_skunk'] = 'Baggie of plant matter',
    ['weed_amnesia'] = 'Baggie of plant matter',
    ['weed_og-kush'] = 'Baggie of plant matter',
    ['weed_white-widow'] = 'Baggie of plant matter',
    ['weed_purple-haze'] = 'Baggie of plant matter',
    ['joint'] = 'Rolled cigarette',
    ['empty_weed_bag'] = 'Empty plastic baggie',

    -- Cocaine
    ['coke'] = 'Small powder baggie',
    ['cokebaggy'] = 'Small powder baggie',
    ['coke_brick'] = 'Brick-shaped package',
    ['coke_small_brick'] = 'Wrapped package',

    -- Other drugs
    ['crack'] = 'Small rocks in baggie',
    ['crack_baggy'] = 'Small rocks in baggie',
    ['meth'] = 'Crystalline baggie',
    ['oxy'] = 'Pill bottle',
    ['heroin'] = 'Powder baggie',

    -- Gang items
    ['spraycan'] = 'Aerosol can',
    ['sprayremover'] = 'Chemical bottle',

    -- Tools (suspicious)
    ['lockpick'] = 'Metal tools',
    ['advancedlockpick'] = 'Metal tools',
    ['electronickit'] = 'Electronic components',
    ['thermite'] = 'Chemical compound',
    ['trojan_usb'] = 'USB device',

    -- Restraints
    ['handcuffs'] = 'Metal restraints',
    ['ziptie'] = 'Plastic restraints',
    ['rope'] = 'Coiled rope',

    -- Other suspicious
    ['radio'] = 'Electronic device',
    ['binoculars'] = 'Hard case',
    ['gps'] = 'Electronic tracker',
    ['bodycam'] = 'Recording device',
    ['scanner'] = 'Electronic scanner',
}

RegisterNetEvent('sv_police_actions:server:frisk', function(targetId)
    local src = source

    -- Validate
    if not IsPolice(src) then return end
    if not HasRequiredGrade(src, 'frisk') then return end

    local distance = GetDistance(src, targetId)
    if distance > config.distances.target + 1 then
        return Notify(src, 'Too far away', 'error')
    end

    local targetPlayer = GetPlayer(targetId)
    if not targetPlayer then return Notify(src, 'Player not found', 'error') end

    -- Tell target they're being frisked (triggers animation)
    TriggerClientEvent('sv_police_actions:client:beingFrisked', targetId, src)

    -- Check if target has weapon in hand
    local targetPed = GetPlayerPed(targetId)
    local hasWeaponEquipped = GetSelectedPedWeapon(targetPed) ~= `WEAPON_UNARMED`

    local state = GetPlayerState(targetId)

    -- Check inventory for weapons and contraband (can be "felt" through clothing)
    local concealedWeapons = {}
    local suspiciousItems = {}
    local feltSomething = false

    if config.integrations.oxInventory.enabled then
        local inventory = exports.ox_inventory:GetInventoryItems(targetId)
        if inventory then
            for _, item in pairs(inventory) do
                if item and item.name and item.count and item.count > 0 then
                    local itemName = string.lower(item.name)

                    -- Check for weapons
                    if friskableWeapons[itemName] then
                        table.insert(concealedWeapons, friskableWeapons[itemName])
                        feltSomething = true
                    end

                    -- Check for contraband
                    if friskableContraband[itemName] then
                        table.insert(suspiciousItems, friskableContraband[itemName])
                        feltSomething = true
                    end
                end
            end
        end
    end

    -- Notify target what they felt (immersion)
    TriggerClientEvent('sv_police_actions:client:friskFeeling', targetId, {
        feltWeapon = feltSomething
    })

    -- Send detailed results to officer
    TriggerClientEvent('sv_police_actions:client:showFriskResults', src, {
        hasWeaponEquipped = hasWeaponEquipped,
        concealedWeapons = concealedWeapons,
        suspiciousItems = suspiciousItems,
        isCuffed = state.isCuffed,
        targetId = targetId
    })

    -- Notify target
    Notify(targetId, config.notifications.frisked, 'warning')

    if config.debug then
        print(('[sv_police_actions] %s frisked %s - weapons: %d, suspicious: %d'):format(
            src, targetId, #concealedWeapons, #suspiciousItems
        ))
    end
end)

-- =====================
-- CUFF / UNCUFF
-- =====================

RegisterNetEvent('sv_police_actions:server:cuff', function(targetId, isHard)
    local src = source

    -- Validate
    if not IsPolice(src) then return end

    local action = isHard and 'hardcuff' or 'softcuff'
    if not HasRequiredGrade(src, action) then return end

    local distance = GetDistance(src, targetId)
    if distance > config.distances.target + 1 then
        return Notify(src, 'Too far away', 'error')
    end

    local state = GetPlayerState(targetId)
    if state.isCuffed then
        return Notify(src, 'Already cuffed', 'error')
    end

    -- Apply cuffs
    state.isCuffed = true
    state.isHardCuffed = isHard or false

    TriggerClientEvent('sv_police_actions:client:setCuffed', targetId, true, isHard)

    Notify(src, isHard and 'Hard cuffs applied' or 'Handcuffs applied', 'success')

    if config.debug then
        print(('[sv_police_actions] %s cuffed %s (hard: %s)'):format(src, targetId, tostring(isHard)))
    end
end)

RegisterNetEvent('sv_police_actions:server:uncuff', function(targetId)
    local src = source

    -- Validate
    if not IsPolice(src) then return end
    if not HasRequiredGrade(src, 'uncuff') then return end

    local distance = GetDistance(src, targetId)
    if distance > config.distances.target + 1 then
        return Notify(src, 'Too far away', 'error')
    end

    local state = GetPlayerState(targetId)
    if not state.isCuffed then
        return Notify(src, 'Not cuffed', 'error')
    end

    -- Also stop escort if active
    if state.isEscorted and state.escortedBy then
        TriggerClientEvent('sv_police_actions:client:setEscorting', state.escortedBy, false, nil)
        state.isEscorted = false
        state.escortedBy = nil
        TriggerClientEvent('sv_police_actions:client:setEscorted', targetId, false, nil)
    end

    -- Remove cuffs
    state.isCuffed = false
    state.isHardCuffed = false

    TriggerClientEvent('sv_police_actions:client:setCuffed', targetId, false, false)

    Notify(src, 'Cuffs removed', 'success')

    if config.debug then
        print(('[sv_police_actions] %s uncuffed %s'):format(src, targetId))
    end
end)

-- =====================
-- ESCORT
-- =====================

RegisterNetEvent('sv_police_actions:server:escort', function(targetId)
    local src = source

    -- Validate
    if not IsPolice(src) then return end
    if not HasRequiredGrade(src, 'escort') then return end

    local distance = GetDistance(src, targetId)
    if distance > config.distances.target + 1 then
        return Notify(src, 'Too far away', 'error')
    end

    local state = GetPlayerState(targetId)
    if not state.isCuffed then
        return Notify(src, 'Must be cuffed first', 'error')
    end

    if state.isEscorted then
        return Notify(src, 'Already being escorted', 'error')
    end

    -- Start escort
    state.isEscorted = true
    state.escortedBy = src

    TriggerClientEvent('sv_police_actions:client:setEscorted', targetId, true, src)
    TriggerClientEvent('sv_police_actions:client:setEscorting', src, true, targetId)

    Notify(src, 'Now escorting', 'success')

    if config.debug then
        print(('[sv_police_actions] %s escorting %s'):format(src, targetId))
    end
end)

RegisterNetEvent('sv_police_actions:server:unescort', function(targetId)
    local src = source

    -- Validate
    if not IsPolice(src) then return end

    local state = GetPlayerState(targetId)
    if not state.isEscorted or state.escortedBy ~= src then
        return Notify(src, 'Not escorting this player', 'error')
    end

    -- Stop escort
    state.isEscorted = false
    state.escortedBy = nil

    TriggerClientEvent('sv_police_actions:client:setEscorted', targetId, false, nil)
    TriggerClientEvent('sv_police_actions:client:setEscorting', src, false, nil)

    Notify(src, 'Stopped escorting', 'success')

    if config.debug then
        print(('[sv_police_actions] %s stopped escorting %s'):format(src, targetId))
    end
end)

-- =====================
-- SEARCH
-- =====================

RegisterNetEvent('sv_police_actions:server:search', function(targetId)
    local src = source

    -- Validate
    if not IsPolice(src) then return end
    if not HasRequiredGrade(src, 'search') then return end

    local distance = GetDistance(src, targetId)
    if distance > config.distances.target + 1 then
        return Notify(src, 'Too far away', 'error')
    end

    local state = GetPlayerState(targetId)
    if not state.isCuffed then
        return Notify(src, 'Must be cuffed first', 'error')
    end

    local targetPlayer = GetPlayer(targetId)
    if not targetPlayer then return Notify(src, 'Player not found', 'error') end

    -- Get inventory
    local items = {}
    if config.integrations.oxInventory.enabled then
        local inventory = exports.ox_inventory:GetInventoryItems(targetId)
        if inventory then
            for _, item in pairs(inventory) do
                if item and item.count and item.count > 0 then
                    table.insert(items, {
                        name = item.name,
                        label = item.label,
                        count = item.count
                    })
                end
            end
        end
    end

    -- Send results to officer
    TriggerClientEvent('sv_police_actions:client:showSearchResults', src, {
        name = targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname,
        items = items,
        targetId = targetId
    })

    -- Notify target
    Notify(targetId, config.notifications.searched, 'warning')

    if config.debug then
        print(('[sv_police_actions] %s searched %s, found %d items'):format(src, targetId, #items))
    end
end)

-- =====================
-- CHECK ID
-- =====================

RegisterNetEvent('sv_police_actions:server:checkId', function(targetId)
    local src = source

    -- Validate
    if not IsPolice(src) then return end
    if not HasRequiredGrade(src, 'checkId') then return end

    local distance = GetDistance(src, targetId)
    if distance > config.distances.target + 1 then
        return Notify(src, 'Too far away', 'error')
    end

    local targetPlayer = GetPlayer(targetId)
    if not targetPlayer then return Notify(src, 'Player not found', 'error') end

    local charinfo = targetPlayer.PlayerData.charinfo
    local metadata = targetPlayer.PlayerData.metadata

    -- Get licenses from bcs_licensemanager if enabled
    local licenses = {}
    if config.integrations.licenseManager.enabled then
        -- Query licenses from database
        local citizenid = targetPlayer.PlayerData.citizenid
        local licenseData = MySQL.query.await('SELECT license FROM licenses WHERE owner = ?', {citizenid})

        if licenseData then
            for _, row in ipairs(licenseData) do
                licenses[row.license] = true
            end
        end
    else
        -- Use QBX metadata licenses
        licenses = metadata.licences or {}
    end

    -- Check for warrants if lb-tablet enabled
    local warrants = {}
    if config.integrations.lbTablet.enabled and config.integrations.lbTablet.checkWarrants then
        local citizenid = targetPlayer.PlayerData.citizenid
        local warrantData = MySQL.query.await('SELECT reason FROM lbtablet_warrants WHERE cid = ?', {citizenid})

        if warrantData then
            for _, row in ipairs(warrantData) do
                table.insert(warrants, row.reason)
            end
        end
    end

    -- Send results to officer
    TriggerClientEvent('sv_police_actions:client:showIdResults', src, {
        firstname = charinfo.firstname,
        lastname = charinfo.lastname,
        dob = charinfo.birthdate,
        gender = charinfo.gender,
        citizenid = targetPlayer.PlayerData.citizenid,
        licenses = licenses,
        warrants = warrants
    })

    -- Notify target
    Notify(targetId, config.notifications.idChecked, 'inform')

    if config.debug then
        print(('[sv_police_actions] %s checked ID of %s'):format(src, targetId))
    end
end)

-- =====================
-- CHECK WARRANTS (MDT)
-- =====================

RegisterNetEvent('sv_police_actions:server:checkWarrants', function(targetId)
    local src = source

    -- Validate
    if not IsPolice(src) then return end
    if not HasRequiredGrade(src, 'checkWarrants') then return end
    if not config.integrations.lbTablet.enabled then return end

    local targetPlayer = GetPlayer(targetId)
    if not targetPlayer then return Notify(src, 'Player not found', 'error') end

    local citizenid = targetPlayer.PlayerData.citizenid
    local charinfo = targetPlayer.PlayerData.charinfo

    -- Query warrants
    local warrants = MySQL.query.await([[
        SELECT reason, date, issuer
        FROM lbtablet_warrants
        WHERE cid = ?
    ]], {citizenid})

    -- Query profile
    local profile = MySQL.single.await([[
        SELECT notes
        FROM lbtablet_profiles
        WHERE cid = ?
    ]], {citizenid})

    local content = ('**%s %s** (CID: %s)\n\n'):format(
        charinfo.firstname,
        charinfo.lastname,
        citizenid
    )

    if warrants and #warrants > 0 then
        content = content .. '**ACTIVE WARRANTS:**\n'
        for _, w in ipairs(warrants) do
            content = content .. ('- %s (Issued: %s)\n'):format(w.reason, w.date or 'Unknown')
        end
    else
        content = content .. 'No active warrants.\n'
    end

    if profile and profile.notes then
        content = content .. '\n**Officer Notes:**\n' .. profile.notes
    end

    TriggerClientEvent('ox_lib:alertDialog', src, {
        header = 'MDT Warrant Check',
        content = content,
        centered = true
    })

    if config.debug then
        print(('[sv_police_actions] %s checked warrants for %s'):format(src, targetId))
    end
end)

-- =====================
-- VEHICLE INTERACTIONS
-- =====================

RegisterNetEvent('sv_police_actions:server:putInVehicle', function(targetId, vehicleNet)
    local src = source

    -- Validate
    if not IsPolice(src) then return end
    if not HasRequiredGrade(src, 'putInVehicle') then return end

    local distance = GetDistance(src, targetId)
    if distance > config.distances.target + 2 then
        return Notify(src, 'Too far away', 'error')
    end

    local state = GetPlayerState(targetId)
    if not state.isCuffed then
        return Notify(src, 'Must be cuffed first', 'error')
    end

    TriggerClientEvent('sv_police_actions:client:putInVehicle', targetId, vehicleNet)

    Notify(src, 'Placed in vehicle', 'success')

    if config.debug then
        print(('[sv_police_actions] %s put %s in vehicle'):format(src, targetId))
    end
end)

RegisterNetEvent('sv_police_actions:server:removeFromVehicle', function(targetId)
    local src = source

    -- Validate
    if not IsPolice(src) then return end
    if not HasRequiredGrade(src, 'removeFromVehicle') then return end

    local distance = GetDistance(src, targetId)
    if distance > config.distances.target + 3 then
        return Notify(src, 'Too far away', 'error')
    end

    TriggerClientEvent('sv_police_actions:client:removeFromVehicle', targetId)

    Notify(src, 'Removed from vehicle', 'success')

    if config.debug then
        print(('[sv_police_actions] %s removed %s from vehicle'):format(src, targetId))
    end
end)

-- =====================
-- TACKLE
-- =====================

RegisterNetEvent('sv_police_actions:server:tackle', function(targetId)
    local src = source

    -- Validate
    if not config.tackle.enabled then return end
    if not IsPolice(src) then return end
    if not HasRequiredGrade(src, 'tackle') then return end

    local distance = GetDistance(src, targetId)
    if distance > config.distances.target + 1 then
        return Notify(src, 'Too far away', 'error')
    end

    TriggerClientEvent('sv_police_actions:client:tackled', targetId)

    if config.debug then
        print(('[sv_police_actions] %s tackled %s'):format(src, targetId))
    end
end)

-- =====================
-- CLEANUP
-- =====================

AddEventHandler('playerDropped', function()
    local src = source

    -- Clean up player state
    if playerStates[src] then
        -- If they were escorting someone, release them
        for targetId, state in pairs(playerStates) do
            if state.escortedBy == src then
                state.isEscorted = false
                state.escortedBy = nil
                TriggerClientEvent('sv_police_actions:client:setEscorted', targetId, false, nil)
            end
        end

        playerStates[src] = nil
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    -- Uncuff everyone on resource stop
    for playerId, state in pairs(playerStates) do
        if state.isCuffed then
            TriggerClientEvent('sv_police_actions:client:setCuffed', playerId, false, false)
        end
        if state.isEscorted then
            TriggerClientEvent('sv_police_actions:client:setEscorted', playerId, false, nil)
        end
    end
end)

-- =====================
-- ADMIN COMMANDS
-- =====================

lib.addCommand('forceuncuff', {
    help = 'Force uncuff a player (admin)',
    params = {
        { name = 'id', type = 'playerId', help = 'Player server ID' }
    },
    restricted = 'group.admin'
}, function(source, args)
    local targetId = args.id

    local state = GetPlayerState(targetId)

    -- Stop escort
    if state.isEscorted and state.escortedBy then
        TriggerClientEvent('sv_police_actions:client:setEscorting', state.escortedBy, false, nil)
    end

    -- Reset state
    state.isCuffed = false
    state.isHardCuffed = false
    state.isEscorted = false
    state.escortedBy = nil

    TriggerClientEvent('sv_police_actions:client:setCuffed', targetId, false, false)
    TriggerClientEvent('sv_police_actions:client:setEscorted', targetId, false, nil)

    Notify(source, 'Player forcefully uncuffed', 'success')
    Notify(targetId, 'You were uncuffed by an admin', 'inform')
end)

-- =====================
-- DEBUG
-- =====================

if config.debug then
    RegisterCommand('policeactions:serverdebug', function(source)
        print('^3[DEBUG]^7 playerStates:', json.encode(playerStates))
    end, true)
end

print('^2[sv_police_actions]^7 Server loaded')
