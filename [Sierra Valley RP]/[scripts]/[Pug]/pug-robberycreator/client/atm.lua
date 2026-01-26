local AllAtmRobberyData
local spawnedRope = nil
local spawnedHook = nil
local ropeAttachedToAtm = false
local atmEntity = nil
local soundId = GetSoundId()
local IsDrilling
local ClientCoolDown
local AtmVailableToHook
local PutHookOnAtm
local ItemsNeeded
local DrawTextLoop


local function isNight()
    local hour = GetClockHours()
    if hour >= 21 or hour <= 6 then
        return true
    end
end

local function RemoveRope()
    RopeUnloadTextures()
    DeleteRope(spawnedRope)
    if DoesEntityExist(spawnedHook) then
        DeleteEntity(spawnedHook)
    end
    if DoesEntityExist(atmEntity) then
        DeleteEntity(atmEntity)
    end
    spawnedRope = nil
    ropeAttachedToAtm = false
    spawnedHook = false
end

RegisterNUICallback('SaveAtmRobberyData', function(data, cb)
    TriggerServerEvent('Pug:saveAtmRobberyData', data)
    cb('ok')
end)

RegisterNetEvent('Pug:client:UpdateAtmRobberyData', function(AtmRobberyData)
    if DrawTextLoop then
        DrawTextLoop = false
        Wait(1100)
    end
    AllAtmRobberyData = json.decode(AtmRobberyData)
    if not AllAtmRobberyData.cooldown then
        AllAtmRobberyData.cooldown = 1
    end
    if AllAtmRobberyData then
        if AllAtmRobberyData.robberyMethod == "rope" then
            ItemsNeeded = 'ropehook'
        else
            ItemsNeeded = nil
        end
    end
    CreateAtmTarget()
    AtmVailableToHook = false
    RemoveRope()
end)

local function LoadDrillSounds()
	RequestAmbientAudioBank("DLC_HEIST_FLEECA_SOUNDSET", 0)
	RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL", 0)
	RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL_2", 0)
end
local function UnloadDrillSounds()
	ReleaseAmbientAudioBank("DLC_HEIST_FLEECA_SOUNDSET")
	ReleaseAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL")
	ReleaseAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL_2")
end
local function LoadPtfx(dict)	
	if not HasNamedPtfxAssetLoaded(dict) then 
		while not HasNamedPtfxAssetLoaded(dict) do 
			RequestNamedPtfxAsset(dict) 
			Wait(5) 
		end 
	end 
end
local function HandleDrillStuff(Atm)
    LoadDrillSounds()
    loadAnimDict("anim@heists@fleeca_bank@drilling")
    local DrillProp = CreateObject("ch_prop_ch_heist_drill", GetEntityCoords(PlayerPedId(), true), true, true, true)
    AttachEntityToEntity(DrillProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.15, 0, -0.01, 90.0, -90.0, 180.0, true, true, false, true, 1, true)
    IsDrilling = true
    local AtmCoords = GetEntityCoords(Atm)
    TaskPlayAnim(PlayerPedId(), "anim@heists@fleeca_bank@drilling","drill_straight_fail", 3.0, 3.0, -1, 1, 0, false, false, false)
    Wait(200)
    PlaySoundFromEntity(soundId, "Drill", DrillProp, "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
    CreateThread(function()
        while not HasNamedPtfxAssetLoaded("core") do RequestNamedPtfxAsset("core") Wait(5) end
        while IsDrilling do
            if not IsEntityPlayingAnim(PlayerPedId(), "anim@heists@fleeca_bank@drilling", "drill_straight_fail", 3) then
                TaskPlayAnim(PlayerPedId(), "anim@heists@fleeca_bank@drilling", "drill_straight_fail", 1.0, 1.0, -1, 1, 0, false, false, false)
            end
            UseParticleFxAssetNextCall("core")
            local SparksFly = StartNetworkedParticleFxNonLoopedAtCoord("sp_ent_sparking_wires", AtmCoords.x, AtmCoords.y, AtmCoords.z+1.1, 0.0, 0.0, GetEntityHeading(PlayerPedId())-180.0, 1.0, 0.0, 0.0, 0.0)
            Wait(700)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.04)
        end
        StopAnimTask(PlayerPedId(), "anim@heists@fleeca_bank@drilling", "drill_straight_fail", 1.0)
        DeleteEntity(DrillProp)
        RemoveNamedPtfxAsset("core")
        RemoveAnimDict("anim@heists@fleeca_bank@drilling")
        UnloadDrillSounds()
        StopSound(soundId)
    end)
end

local function TakingMoney()
    FreezeEntityPosition(PlayerPedId(), true)
    CreateThread(function()
        for _, reward in ipairs(AllAtmRobberyData.rewardItems) do
            if math.random(0, 100) <= tonumber(reward.chance) then
                if tonumber(reward.maxAmount) >= tonumber(reward.minAmount) then
                    local totalAmount = math.random(tonumber(reward.minAmount), tonumber(reward.maxAmount))
                    local givenAmount = 0
                    local chunkSize = math.max(math.floor(totalAmount * 0.1), 1) -- 10% chunks or at least 1 item

                    while givenAmount < totalAmount do
                        local remainingAmount = totalAmount - givenAmount
                        local amountToGive = math.min(chunkSize, remainingAmount)
                        HandleItems(true, tostring(reward.itemName), amountToGive)
                        givenAmount = givenAmount + amountToGive
                        Wait(1000) 
                    end
                else
                    Notify(Config.LangT["MaxRewardLowerThanMin"], "error")
                end
            end
        end

        if AllAtmRobberyData.moneyReward then
            local minMoney = tonumber(AllAtmRobberyData.minMoney) or 0
            local maxMoney = tonumber(AllAtmRobberyData.maxMoney) or 0
            if maxMoney >= minMoney then
                local totalMoney = math.random(minMoney, maxMoney)
                local moneyPerSecond = math.floor(totalMoney / 7)
                local givenMoney = 0
                local remainingMoney = totalMoney

                while givenMoney < totalMoney do
                    local amountToGive = math.min(moneyPerSecond, remainingMoney)
                    HandleMoney(AllAtmRobberyData.rewardType, amountToGive)
                    givenMoney = givenMoney + amountToGive
                    remainingMoney = totalMoney - givenMoney
                    Wait(1000)
                end
            else
                Notify(Config.LangT["MaxRewardLowerThanMin"], "error")
            end
        end
        ClearPedTasksImmediately(PlayerPedId())
    end)
    
	RequestAnimDict('anim@heists@ornate_bank@grab_cash_heels')
	while not HasAnimDictLoaded('anim@heists@ornate_bank@grab_cash_heels') do
		Wait(50)
	end
	local PlayerCoords = GetEntityCoords(PlayerPedId())
	local BagObject = CreateObject(GetHashKey('prop_cs_heist_bag_02'),PlayerCoords.x, PlayerCoords.y,PlayerCoords.z, true, true, true)
	AttachEntityToEntity(BagObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.0, 0.0, -0.16, 250.0, -30.0, 0.0, false, false, false, false, 2, true)
	FreezeEntityPosition(PlayerPedId(), true)
	local time = GetGameTimer()
	local random = math.random(1,100)
    while GetGameTimer() - time < 20000 do
        Wait(1)
		TaskPlayAnim(PlayerPedId(), "anim@heists@ornate_bank@grab_cash_heels", "grab", 8.0, -8.0, -1, 1, 0)
		Wait(5000)
		TaskPlayAnim(PlayerPedId(), "anim@heists@ornate_bank@grab_cash_heels", "grab", 8.0, -8.0, -1, 1, 0)
	end
	DeleteEntity(BagObject)
	ClearPedTasksImmediately(PlayerPedId())
	FreezeEntityPosition(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
    Notify(Config.LangT["Success"], "success")
    FreezeEntityPosition(PlayerPedId(), false)
end

local function getDrivenWheelSpeed(veh)
    local wheels = GetVehicleNumberOfWheels(veh)
    if wheels >= 4 then
        local rear = (GetVehicleWheelSpeed(veh, 2) + GetVehicleWheelSpeed(veh, 3)) * 0.5
        return rear
    end

    local sum = 0.0
    for i = 0, wheels - 1 do
        sum = sum + GetVehicleWheelSpeed(veh, i)
    end
    return sum / math.max(1, wheels)
end

local function CreateRope(targetEntity, boneCoords)
    local Ped = PlayerPedId()
    local hookModel = `prop_rope_hook_01`

    spawnedHook = CreateObject(hookModel, 0.0, 0.0, 0.0, true, true, false)
    while not DoesEntityExist(spawnedHook) do Wait(0) end

    local handBone = GetPedBoneIndex(Ped, 57005)
    AttachEntityToEntity(spawnedHook, Ped, handBone, 0.15, 0.02, -0.03, -150.0, 40.0, 180.0, true, true, false, true, 1, true)

    RopeLoadTextures()
    while not RopeAreTexturesLoaded() do Wait(0) end

    Notify("USE THE ROPEHOOK ITEM WHILE STANDING AT ANY TRUNK", "success")

    local bootDst = boneCoords

    local hookLocalAttach = vector3(0.0, 0.0, 0.12)

    local hookWorld = GetOffsetFromEntityInWorldCoords(
        spawnedHook,
        hookLocalAttach.x, hookLocalAttach.y, hookLocalAttach.z
    )

    local dist =
        #(vector3(hookWorld.x, hookWorld.y, hookWorld.z) - vector3(bootDst.x, bootDst.y, bootDst.z))

    local maxLen = math.max(dist + 2.0, 5.0)   -- pick a max you want (50–80 feels normal)
    local minLen = 0.5                          -- or 0.0

    spawnedRope = AddRope(
        hookWorld.x, hookWorld.y, hookWorld.z,
        0.0, 0.0, 0.0,
        maxLen,       -- initial rope length (can also use dist + 2.0)
        4,
        maxLen,       -- maxLength MUST be big enough
        minLen,       -- minLength should NOT be dist
        0.7,
        0, 0, 0, 0, 0, 0
    )


    while not DoesRopeExist(spawnedRope) do Wait(0) end

    AttachEntitiesToRope(
        spawnedRope,
        spawnedHook,
        targetEntity,
        hookWorld.x, hookWorld.y, hookWorld.z,        -- WORLD point on hook
        bootDst.x,  bootDst.y,  bootDst.z,            -- WORLD point on trunk bone
        dist
    )

    SetRopeLengthChangeRate(spawnedRope, 0.1)

    ropeAttachedToAtm = true
    atmEntity = targetEntity
    local AttachVehicle
    CreateThread(function()
        local startTime = GetGameTimer()
        local burnoutTime = 0
        while true do
            Wait(100)
            if not DoesEntityExist(spawnedHook) then
                RemoveRope()
                break
            end
            if not atmEntity or not spawnedRope then
                break
            end

            local vehicle = GetVehiclePedIsIn(Ped, false)
            if vehicle ~= 0 then
                local wheelSpeed   = getDrivenWheelSpeed(vehicle)
                local currentSpeed = GetEntitySpeed(vehicle)
                local slip         = wheelSpeed - currentSpeed

                if currentSpeed < 2.0 and slip > 3.0 then
                    burnoutTime = burnoutTime + 200
                else
                    burnoutTime = 0
                end
                if burnoutTime > 3500 then 
                    local atmCoords = GetEntityCoords(atmEntity)
                    local OldAtmHeading = GetEntityHeading(atmEntity)
                    AttachVehicle = vehicle
                    atmEntity = CreateObject(GetEntityModel(atmEntity), atmCoords.x, atmCoords.y, atmCoords.z, true, true, false)
                    while not DoesEntityExist(atmEntity) do Wait(0) end
                    ActivatePhysics(atmEntity)
                    FreezeEntityPosition(atmEntity, false)
                    SetEntityHeading(atmEntity, OldAtmHeading)
                    local boneIndex = (GetEntityBoneIndexByName(vehicle, 'exhaust') ~= -1 and GetEntityBoneIndexByName(vehicle, 'exhaust')) or (GetEntityBoneIndexByName(vehicle, 'bumper_r') ~= -1 and GetEntityBoneIndexByName(vehicle, 'bumper_r'))
                    or (GetEntityBoneIndexByName(vehicle, 'boot') ~= -1 and GetEntityBoneIndexByName(vehicle, 'boot')) or -1
                    local boneCoords = GetWorldPositionOfEntityBone(vehicle, boneIndex)
                    AtmVailableToHook = false
                    DetachRopeFromEntity(spawnedRope, spawnedHook)
                    local atmAttach = vector3(atmCoords.x, atmCoords.y, atmCoords.z + 1.0)
                    local vehAttach = vector3(boneCoords.x, boneCoords.y, boneCoords.z)
                    local currentLen = GetRopeLength(spawnedRope)
                    AttachEntitiesToRope(spawnedRope, atmEntity, vehicle,
                        atmAttach.x, atmAttach.y, atmAttach.z,
                        vehAttach.x, vehAttach.y, vehAttach.z,
                        currentLen
                    )
                    TriggerServerEvent("Pug:server:DeleteAtmAtCoords", atmCoords, GetEntityModel(atmEntity))
                    local startTime2 = GetGameTimer()
                    while DoesEntityExist(atmEntity) and GetGameTimer() - startTime2 < 4000 do Wait(50) end
                    local options
                    if GetResourceState("RevoInteract") == 'started' or not Config.Target or Config.DrawTextInsteadOfTarget then
                        CreateThread(function()
                            local showHelp = false
                            local finished = false
                            while not finished do
                                Wait(0)
                                local pedCoords = GetEntityCoords(PlayerPedId())
                                local entityCoords = GetEntityCoords(atmEntity)
                                local dist = #(pedCoords - entityCoords)
                                
                                if dist < 2.0 then
                                    if not showHelp then
                                        if GetResourceState("RevoInteract") == 'started' then
                                            exports.RevoInteract:OpenHelp({
                                                ID = "TakeMoneyATM", 
                                                Text = "Take Money", 
                                                Key = "[E]"
                                            })
                                        else
                                            DrawTextOption("[E] Take Money")
                                        end
                                        showHelp = true
                                    end
                                    if IsControlJustPressed(0, 38) then
                                        finished = true
                                        if GetResourceState("RevoInteract") == 'started' then
                                            exports.RevoInteract:CloseHelp("TakeMoneyATM")
                                        else
                                            HideTextOption()
                                        end
                                        -- Here is exactly what we do when the player
                                        -- chooses the 'Take Money' target option
                                        local Entity = atmEntity
                                        local forward = GetEntityForwardVector(PlayerPedId())
                                        local x, y, z = table.unpack(vector3(forward.x, forward.y, forward.z) + forward * 0.5)
                                        atmEntity = CreateObject("prop_atm_03", x, y, z, true, true, false)
                                        FreezeEntityPosition(PlayerPedId(), true)
                                        loadAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
                                        TaskPlayAnim(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 2.0, 2.0, -1, 1, 1.0, 0, 0, 0)
                                        Notify(Config.LangT["TakingMoney"], "success")
                                        Wait(7000)
                                        ClearPedTasks(PlayerPedId())
                                        FreezeEntityPosition(PlayerPedId(), false)
                                        RemoveRope()
                                        TriggerEvent("FullyDeleteRobberiesEntity", Entity)

                                        for _, reward in ipairs(AllAtmRobberyData.rewardItems) do
                                            if math.random(0, 100) <= tonumber(reward.chance) then
                                                if tonumber(reward.maxAmount) >= tonumber(reward.minAmount) then
                                                    local amount = math.random(tonumber(reward.minAmount), tonumber(reward.maxAmount))
                                                    HandleItems(true, tostring(reward.itemName), amount)
                                                else
                                                    Notify(Config.LangT["MaxRewardLowerThanMin"], "error")
                                                end
                                            end
                                        end

                                        if AllAtmRobberyData.moneyReward then
                                            local minMoney = tonumber(AllAtmRobberyData.minMoney) or 0
                                            local maxMoney = tonumber(AllAtmRobberyData.maxMoney) or 0
                                            if maxMoney >= minMoney then
                                                local rewardAmount = math.random(minMoney, maxMoney)
                                                HandleMoney(AllAtmRobberyData.rewardType, rewardAmount)
                                            else
                                                Notify(Config.LangT["MaxRewardLowerThanMin"], "error")
                                            end
                                        end
                                    end
                                else
                                    if showHelp then
                                        if GetResourceState("RevoInteract") == 'started' then
                                            exports.RevoInteract:CloseHelp("TakeMoneyATM")
                                        else
                                            HideTextOption()
                                        end
                                        showHelp = false
                                    end
                                end
                            end
                        end)
                    else
                        if Config.Target == "ox_target" then
                            options = {
                                {
                                    name = 'RobAtm',
                                    icon = 'fa-solid fa-money-bill-wave',
                                    label = 'Take Money',
                                    distance = 1.5,
                                    onSelect = function(data)
                                        if data.entity then
                                            local Entity = data.entity
                                            if Config.Target == 'ox_target' then
                                                exports.ox_target:removeLocalEntity(atmEntity)
                                            else
                                                exports[Config.Target]:RemoveTargetEntity(atmEntity)
                                            end
                                            local forward = GetEntityForwardVector(PlayerPedId())
                                            local x, y, z = table.unpack(vector3(forward.x, forward.y, forward.z) + forward * 0.5)
                                            atmEntity = CreateObject("prop_atm_03", x, y, z, true, true, false)
                                            FreezeEntityPosition(PlayerPedId(), true)
                                            loadAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
                                            TaskPlayAnim(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 2.0, 2.0, -1, 1, 1.0, 0, 0, 0)
                                            Notify(Config.LangT["TakingMoney"], "success")
                                            Wait(7000)
                                            ClearPedTasks(PlayerPedId())
                                            FreezeEntityPosition(PlayerPedId(), false)
                                            RemoveRope()
                                            TriggerEvent("FullyDeleteRobberiesEntity", Entity)
        
                                            for _, reward in ipairs(AllAtmRobberyData.rewardItems) do
                                                if math.random(0, 100) <= tonumber(reward.chance) then
                                                    if tonumber(reward.maxAmount) >= tonumber(reward.minAmount) then
                                                        local amount = math.random(tonumber(reward.minAmount), tonumber(reward.maxAmount))
                                                        HandleItems(true, tostring(reward.itemName), amount)
                                                    else
                                                        Notify(Config.LangT["MaxRewardLowerThanMin"], "error")
                                                    end
                                                end
                                            end

                                            if AllAtmRobberyData.moneyReward then
                                                local minMoney = tonumber(AllAtmRobberyData.minMoney) or 0
                                                local maxMoney = tonumber(AllAtmRobberyData.maxMoney) or 0
                                                if maxMoney >= minMoney then
                                                    local rewardAmount = math.random(minMoney, maxMoney)
                                                    HandleMoney(AllAtmRobberyData.rewardType, rewardAmount)
                                                else
                                                    Notify(Config.LangT["MaxRewardLowerThanMin"], "error")
                                                end
                                            end

                                        else
                                            Notify("No atm entity found..", "error")
                                        end
                                    end
                                }
                            }
                        else
                            options = {
                                {
                                    name = 'RobAtm',
                                    icon = 'fa-solid fa-money-bill-wave',
                                    label = 'Take Money',
                                    distance = 1.5,
                                    action = function(entity)
                                        if entity then
                                            local Entity = entity
                                            if Config.Target == 'ox_target' then
                                                exports.ox_target:removeLocalEntity(atmEntity)
                                            else
                                                exports[Config.Target]:RemoveTargetEntity(atmEntity)
                                            end
                                            local forward = GetEntityForwardVector(PlayerPedId())
                                            local x, y, z = table.unpack(vector3(forward.x, forward.y, forward.z) + forward * 0.5)
                                            atmEntity = CreateObject("prop_atm_03", x, y, z, true, true, false)
                                            FreezeEntityPosition(PlayerPedId(), true)
                                            loadAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
                                            TaskPlayAnim(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 2.0, 2.0, -1, 1, 1.0, 0, 0, 0)
                                            Notify(Config.LangT["TakingMoney"], "success")
                                            Wait(7000)
                                            ClearPedTasks(PlayerPedId())
                                            FreezeEntityPosition(PlayerPedId(), false)
                                            RemoveRope()
                                            TriggerEvent("FullyDeleteRobberiesEntity", Entity)
        
                                            if AllAtmRobberyData and AllAtmRobberyData.rewardItems then
                                                for _, reward in ipairs(AllAtmRobberyData.rewardItems) do
                                                    if math.random(0, 100) <= tonumber(reward.chance) then
                                                        if tonumber(reward.maxAmount) >= tonumber(reward.minAmount) then
                                                            local amount = math.random(tonumber(reward.minAmount), tonumber(reward.maxAmount))
                                                            HandleItems(true, tostring(reward.itemName), amount)
                                                        else
                                                            Notify(Config.LangT["MaxRewardLowerThanMin"], "error")
                                                        end
                                                    end
                                                end
                                            end

                                            if AllAtmRobberyData.moneyReward then
                                                local minMoney = tonumber(AllAtmRobberyData.minMoney) or 0
                                                local maxMoney = tonumber(AllAtmRobberyData.maxMoney) or 0
                                                if maxMoney >= minMoney then
                                                    local rewardAmount = math.random(minMoney, maxMoney)
                                                    HandleMoney(AllAtmRobberyData.rewardType, rewardAmount)
                                                else
                                                    Notify(Config.LangT["MaxRewardLowerThanMin"], "error")
                                                end
                                            end

                                        else
                                            Notify("No atm entity found..", "error")
                                        end
                                    end
                                }
                            }
                        end
                    end
                    if GetResourceState("RevoInteract") ~= 'started' and Config.Target and not Config.DrawTextInsteadOfTarget then 
                        if Config.Target == 'ox_target' then
                            exports.ox_target:addLocalEntity(atmEntity, options)
                        else
                            exports[Config.Target]:AddTargetEntity(atmEntity, {
                                options = options,
                                distance = 1.5
                            })
                        end
                    end
                    break
                end
            end
        end
        CreateThread(function()
            while true do
                Wait(800)
                if not spawnedRope then
                    RemoveRope()
                    break
                end
                if not DoesEntityExist(AttachVehicle) then
                    RemoveRope()
                    break
                end
                if not DoesEntityExist(atmEntity) then
                    RemoveRope()
                    break
                end
                local CurrentAtmCoords = GetEntityCoords(atmEntity)
                local currentX, currentY, currentZ = table.unpack(GetEntityRotation(atmEntity, 2))
                if currentX > -140.0 and currentX < -40.0 then
                else
                    SetEntityRotation(atmEntity, -90.0, currentY, currentZ, 2) 
                    SetEntityCoords(atmEntity,  CurrentAtmCoords)
                end
            end
        end)
    end)
end

RegisterNetEvent('Pug:client:AttachHookToAtm', function(targetEntity)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local targetCoords = GetEntityCoords(targetEntity)

    if #(playerCoords - targetCoords) < 2.0 then
        RequestAnimDict("mini@repair")
        while not HasAnimDictLoaded("mini@repair") do
            Wait(100)
        end
        TaskPlayAnim(playerPed, "mini@repair", "fixing_a_ped", 8.0, -8.0, -1, 49, 0, false, false, false)
        Wait(1000)
        ClearPedTasks(playerPed)
        if not spawnedRope and not spawnedHook then
            local boneCoords = GetEntityCoords(targetEntity) 
            CreateRope(targetEntity, boneCoords)
            CreateThread(function()
                PutHookOnAtm = true
                while PutHookOnAtm do
                    Wait(1000)
                    if not PutHookOnAtm then
                        break
                    end
                    if #(GetEntityCoords(PlayerPedId())- boneCoords) >= 10 then
                        if spawnedRope then
                            Notify(Config.LangT["RopeBroke"], "error")
                            RemoveRope()
                            PutHookOnAtm = false
                            break
                        end
                    end
                end
            end)
        end
    else
        Notify(Config.LangT["NeedToBeCloserToATM"], "error")
    end
end)

RegisterNetEvent('Pug:client:AttachHookToVehicle', function()
    if not spawnedHook then
        Notify(Config.LangT["NeedHookFirst"], "error")
        return
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestVehicle = nil
    local closestDistance = 5.0 

    local vehicles = GetGamePool('CVehicle')

    for _, vehicle in pairs(vehicles) do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(playerCoords - vehicleCoords)
        
        if distance < closestDistance then
            closestVehicle = vehicle
            closestDistance = distance
        end
    end

    if closestVehicle then
        local boneIndex = (GetEntityBoneIndexByName(closestVehicle, 'exhaust') ~= -1 and GetEntityBoneIndexByName(closestVehicle, 'exhaust')) or (GetEntityBoneIndexByName(closestVehicle, 'bumper_r') ~= -1 and GetEntityBoneIndexByName(closestVehicle, 'bumper_r'))
        or (GetEntityBoneIndexByName(closestVehicle, 'boot') ~= -1 and GetEntityBoneIndexByName(closestVehicle, 'boot')) or -1

        if boneIndex ~= -1 then
            local boneCoords = GetWorldPositionOfEntityBone(closestVehicle, boneIndex)

            if #(playerCoords - boneCoords) < 4.0 then
                RequestAnimDict("mini@repair")
                while not HasAnimDictLoaded("mini@repair") do
                    Citizen.Wait(100)
                end
                TaskPlayAnim(playerPed, "mini@repair", "fixing_a_ped", 8.0, -8.0, -1, 49, 0, false, false, false)
                Wait(1000)
                ClearPedTasks(playerPed)

                AttachEntityToEntity(spawnedHook, closestVehicle, boneIndex, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                SetEntityVisible(spawnedHook, false)
                if spawnedRope then
                    PutHookOnAtm = false
                    local currentLen = GetRopeLength(spawnedRope)
                    local ropeStartCoords = GetEntityCoords(atmEntity)

                    local atmAttach = vector3(ropeStartCoords.x, ropeStartCoords.y, ropeStartCoords.z + 1.0)
                    local vehAttach = vector3(boneCoords.x, boneCoords.y, boneCoords.z)

                    DetachRopeFromEntity(spawnedRope, spawnedHook)

                    AttachEntitiesToRope(spawnedRope, atmEntity, closestVehicle,
                        atmAttach.x, atmAttach.y, atmAttach.z,
                        vehAttach.x, vehAttach.y, vehAttach.z,
                        currentLen
                    )

                    RopeForceLength(spawnedRope, currentLen)

                    HandleItems(false, "ropehook", 1)
                else
                    CreateRope(closestVehicle, boneCoords)
                end
            else
                Notify(Config.LangT["NeedToBeAtBackOfVehicle"], "error")
            end
        else
            Notify(Config.LangT["NoTrunkOrBumperBone"], "error")
        end
    else
        Notify(Config.LangT["NoNearbyVehicles"], "error")
    end
end)

local function HackFailed(Atm)
	Notify(Config.LangT["Failed"], "error")
    if math.random(1, 100) <= 60 then
        ClientCoolDown = true
        Wait(2000)
        local number = 10
        while number > 0 do
            Wait(1000)
            number = number - 1
        end
        AddExplosion(GetOffsetFromEntityInWorldCoords(Atm, 0.0, 0.0, 1.0), 2, 0.8, 1, 0, 1.0, true)
        Wait(700)
        Wait(ClientCoolDownTime)
        ClientCoolDown = false
	end
end

local function DoDrill(entity)
    SendAtmRobberyAlert()
    local OriginalCoords = GetEntityCoords(PlayerPedId())
    TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_STAND_MOBILE', -1, true)
    Wait(2300)
    PlaySoundFrontend(-1, "Fail", "dlc_xm_silo_laser_hack_sounds", true)
    if not AllAtmRobberyData.minigameOption or AllAtmRobberyData.minigameOption == "" or AllAtmRobberyData.minigameOption == " " then
        AllAtmRobberyData.minigameOption = "none"
    end
    local DoMiniGame1 = Config.MiniGames[AllAtmRobberyData.minigameOption].Game()
    if DoMiniGame1 then
        Wait(3000)
        SetEntityCoords(PlayerPedId(), vector3(OriginalCoords.x, OriginalCoords.y, OriginalCoords.z-1))
        ClearPedTasks(PlayerPedId())
        SetPedHeadingToFaceVector(PlayerPedId(), GetEntityCoords(entity))
        HandleDrillStuff(entity)
        local DoMiniGame = AllAtmRobberyData.dontRequireDrilling or Config.MiniGames["drilllaser"].Game()
        if DoMiniGame then
            if AllAtmRobberyData.dontRequireDrilling then
                Wait(5000)
            end
            local CooldownRobberyies = {
                "atmrobbery",
            }
            TriggerServerEvent("Pug:server:SetRobberiesOnCooldown", CooldownRobberyies, tonumber(AllAtmRobberyData.cooldown))
            IsDrilling = false
            Notify(Config.LangT["Success"], "success")
            PlaySoundFrontend(-1, "Pass", "dlc_xm_silo_laser_hack_sounds", true) 
            ClearPedTasksImmediately(PlayerPedId())
            if AllAtmRobberyData.robberyMethod == "drill" then
                TakingMoney()
            else
                if not AtmVailableToHook then
                    AtmVailableToHook = GetEntityCoords(entity)
                end
                TriggerEvent("Pug:client:AttachHookToAtm", entity)
            end
        else
            IsDrilling = false
            Wait(1000)
            ClearPedTasksImmediately(PlayerPedId())
            HackFailed(entity)
        end
    else
        Wait(1000)
        ClearPedTasksImmediately(PlayerPedId())
        HackFailed(entity)
    end
end


function CreateAtmTarget()
    while not AllAtmRobberyData do Wait(1000) end
    local options
    if AllAtmRobberyData then
        if AllAtmRobberyData.robberyMethod == "rope" then
            ItemsNeeded = 'ropehook'
        end
    end
    if GetResourceState("RevoInteract") == 'started' or not Config.Target or Config.DrawTextInsteadOfTarget then
        DrawTextLoop = true
        CreateThread(function()
            local helpShown = false
            
            while DrawTextLoop do
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
        
                local foundATM = false
                local atmDistance = 999.0 
                local closestATM
                for _, atmModel in ipairs(Config.AtmProps) do
                    local atmHash = GetHashKey(atmModel)
                    closestATM = GetClosestObjectOfType(
                        playerCoords.x,
                        playerCoords.y,
                        playerCoords.z,
                        1.5,
                        atmHash,
                        false, -- p4
                        false, -- p5
                        false  -- p6
                    )
                    
                    if DoesEntityExist(closestATM) then
                        atmDistance = #(playerCoords - GetEntityCoords(closestATM))
                        foundATM = (atmDistance <= 1.5)
                        if foundATM then
                            break
                        end
                    end
                end
                
                if foundATM and atmDistance <= 1.5 then
                    if not ropeAttachedToAtm then
                        if not helpShown then
                            if GetResourceState("RevoInteract") == 'started' then
                                exports.RevoInteract:OpenHelp({
                                    ID = "ROBATM", 
                                    Text = "Rob ATM", 
                                    Key = "[E]"
                                })
                            else
                                DrawTextOption("[E] Rob ATM")
                            end
                            helpShown = true
                        end
                        
                        if IsControlJustPressed(0, 38) then
                            if closestATM then
                                if AllAtmRobberyData then
                                    local Continue = true
                                    if AllAtmRobberyData.nightOnly then
                                        if not isNight() then
                                            Notify(Config.LangT["TooBrightOutside"], "error")
                                            Continue = false
                                        end
                                    end
                                    if Continue then
                                        local PoliceCheck = "none"
                        
                                        Config.FrameworkFunctions.TriggerCallback('Pug:serverCB:getPoliceCount', function(policeCount)
                                            local requiredPolice = tonumber(AllAtmRobberyData.atmRobberyPoliceRequired)
                                            if requiredPolice then
                                                if policeCount >= requiredPolice then
                                                    PoliceCheck = true
                                                else
                                                    PoliceCheck = false
                                                    Notify(Config.LangT["PoliceNotOnline"] .. requiredPolice, "error")
                                                end
                                            else
                                                PoliceCheck = true
                                            end
                                        end)
                                        while PoliceCheck == "none" do Wait(50) end
                                        if not PoliceCheck then
                                            Continue = false
                                        end
                                        if Continue then
                                            if IsRobberyOnCooldown("atmrobbery") then
                                                Notify(Config.LangT["GlobalCooldown"], "error")
                                                Continue = false
                                            end
                                            if Continue then
                                                if AllAtmRobberyData.requiredItems and #AllAtmRobberyData.requiredItems > 0 then
                                                    for _, itemData in ipairs(AllAtmRobberyData.requiredItems) do
                                                        local hasRequiredItem = HasItem(itemData.itemName, tonumber(itemData.amount) or 1)
                                                        if not hasRequiredItem then
                                                            Notify(Config.LangT["MissingItems"], "error")
                                                            Continue = false
                                                        end
                                                    end
                                                    if Continue then
                                                        for _, itemData in ipairs(AllAtmRobberyData.requiredItems) do
                                                            if itemData.chance then
                                                                if math.random(1, 100) <= tonumber(itemData.chance) then
                                                                    HandleItems(false, tostring(itemData.itemName), tonumber(itemData.amount) or 1)
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                                if Continue then
                                                    SetPedHeadingToFaceVector(PlayerPedId(), GetEntityCoords(closestATM))
                                                    if ItemsNeeded then
                                                        if not HasItem(ItemsNeeded, 1) then
                                                            Continue = false
                                                        end
                                                    end
                                                    if Continue then
                                                        if AllAtmRobberyData.robberyMethod == "rope" then
                                                            if not AtmVailableToHook then
                                                                DoDrill(closestATM)
                                                            else
                                                                if #(AtmVailableToHook - GetEntityCoords(closestATM)) <= 1.0 then
                                                                    TriggerEvent("Pug:client:AttachHookToAtm", closestATM)
                                                                end
                                                            end
                                                        else
                                                            DoDrill(closestATM)
                                                        end
                                                    else
                                                        Notify(Config.LangT["MissingItems"], "error")
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            else
                                Notify(Config.LangT["NoATMFound"], "error")
                            end
                            Wait(500)
                        end
                    end
                    
                    Wait(0) -- keep it responsive while close
                else
                    -- If the ATM is no longer close, close the help if it’s shown
                    if helpShown then
                        if GetResourceState("RevoInteract") == 'started' then
                            exports.RevoInteract:CloseHelp("ROBATM")
                        else
                            HideTextOption()
                        end
                        helpShown = false
                    end
                    Wait(1000) -- reduce checks when not near any ATM
                end
            end
        end)
    else
        if Config.Target == "ox_target" then
            options = {
                {
                    name = 'RobAtm',
                    icon = 'fa-solid fa-piggy-bank',
                    label = 'Rob ATM',
                    distance = 1.0,
                    items = ItemsNeeded,
                    item = ItemsNeeded,
                    onSelect = function(data)
                        if data.entity then
                            if AllAtmRobberyData then
                                if AllAtmRobberyData.nightOnly then
                                    if not isNight() then
                                        Notify(Config.LangT["TooBrightOutside"], "error")
                                        return
                                    end
                                end

                                local PoliceCheck = "none"
                
                                Config.FrameworkFunctions.TriggerCallback('Pug:serverCB:getPoliceCount', function(policeCount)
                                    local requiredPolice = tonumber(AllAtmRobberyData.atmRobberyPoliceRequired)
                                    if requiredPolice then
                                        if policeCount >= requiredPolice then
                                            PoliceCheck = true
                                        else
                                            PoliceCheck = false
                                            Notify(Config.LangT["PoliceNotOnline"] .. requiredPolice, "error")
                                        end
                                    else
                                        PoliceCheck = true
                                    end
                                end)
                                while PoliceCheck == "none" do Wait(50) end
                                if not PoliceCheck then
                                    return
                                end
                                if IsRobberyOnCooldown("atmrobbery") then
                                    Notify(Config.LangT["GlobalCooldown"], "error")
                                    return
                                end
                                if AllAtmRobberyData.requiredItems and #AllAtmRobberyData.requiredItems > 0 then
                                    for _, itemData in ipairs(AllAtmRobberyData.requiredItems) do
                                        local hasRequiredItem = HasItem(itemData.itemName, tonumber(itemData.amount) or 1)
                                        if not hasRequiredItem then
                                            Notify(Config.LangT["MissingItems"], "error")
                                            -- Notify('You do not have the required item: ' .. itemData.itemName .. ' x' .. (tonumber(itemData.itemQuantity) or 1) .. ' to perform this action.', 'error')
                                            return
                                        end
                                    end

                                    for _, itemData in ipairs(AllAtmRobberyData.requiredItems) do
                                        if itemData.chance then
                                            if math.random(1, 100) <= tonumber(itemData.chance) then
                                                HandleItems(false, tostring(itemData.itemName), tonumber(itemData.amount) or 1)
                                            end
                                        end
                                    end
                                end
                                
                                SetPedHeadingToFaceVector(PlayerPedId(), GetEntityCoords(data.entity))
                                if AllAtmRobberyData.robberyMethod == "rope" then
                                    if not AtmVailableToHook then
                                        DoDrill(data.entity)
                                    else
                                        if #(AtmVailableToHook - GetEntityCoords(data.entity)) <= 1.0 then
                                            TriggerEvent("Pug:client:AttachHookToAtm", data.entity)
                                        end
                                    end
                                else
                                    DoDrill(data.entity)
                                end
                            end
                        else
                            Notify(Config.LangT["NoATMFound"], "error")
                        end
                    end
                }
            }
        else
            options = {
                {
                    name = 'RobAtm',
                    icon = 'fa-solid fa-piggy-bank',
                    label = 'Rob ATM',
                    distance = 1.0,
                    items = ItemsNeeded,
                    item = ItemsNeeded,
                    action = function(entity)
                        if entity then
                            if AllAtmRobberyData then
                                if AllAtmRobberyData.nightOnly then
                                    if not isNight() then
                                        Notify(Config.LangT["TooBrightOutside"], "error")
                                        return
                                    end
                                end

                                local PoliceCheck = "none"
                
                                Config.FrameworkFunctions.TriggerCallback('Pug:serverCB:getPoliceCount', function(policeCount)
                                    local requiredPolice = tonumber(AllAtmRobberyData.atmRobberyPoliceRequired)
                                    if requiredPolice then
                                        if policeCount >= requiredPolice then
                                            PoliceCheck = true
                                        else
                                            PoliceCheck = false
                                            Notify(Config.LangT["PoliceNotOnline"] .. requiredPolice, "error")
                                        end
                                    else
                                        PoliceCheck = true
                                    end
                                end)
                                while PoliceCheck == "none" do Wait(50) end
                                if not PoliceCheck then
                                    return
                                end
                                if IsRobberyOnCooldown("atmrobbery") then
                                    Notify(Config.LangT["GlobalCooldown"], "error")
                                    return
                                end
                                if AllAtmRobberyData.requiredItems and #AllAtmRobberyData.requiredItems > 0 then
                                    for _, itemData in ipairs(AllAtmRobberyData.requiredItems) do
                                        local hasRequiredItem = HasItem(itemData.itemName, tonumber(itemData.amount) or 1)
                                        if not hasRequiredItem then
                                            Notify(Config.LangT["MissingItems"], "error")
                                            -- Notify('You do not have the required item: ' .. itemData.itemName .. ' x' .. (tonumber(itemData.itemQuantity) or 1) .. ' to perform this action.', 'error')
                                            return
                                        end
                                    end

                                    for _, itemData in ipairs(AllAtmRobberyData.requiredItems) do
                                        if itemData.chance then
                                            if math.random(1, 100) <= tonumber(itemData.chance) then
                                                HandleItems(false, tostring(itemData.itemName), tonumber(itemData.amount) or 1)
                                            end
                                        end
                                    end
                                end
                                
                                SetPedHeadingToFaceVector(PlayerPedId(), GetEntityCoords(entity))
                                if AllAtmRobberyData.robberyMethod == "rope" then
                                    if not AtmVailableToHook then
                                        DoDrill(entity)
                                    else
                                        if #(AtmVailableToHook - GetEntityCoords(entity)) <= 1.0 then
                                            TriggerEvent("Pug:client:AttachHookToAtm", entity)
                                        end
                                    end
                                else
                                    DoDrill(entity)
                                end
                            end
                        else
                            Notify(Config.LangT["NoATMFound"], "error")
                        end
                    end
                }
            }
        end
    end
    if GetResourceState("RevoInteract") ~= 'started' and Config.Target and not Config.DrawTextInsteadOfTarget then 
        if Config.Target == 'ox_target' then
            exports.ox_target:addModel(Config.AtmProps, options)
        else
            exports[Config.Target]:AddTargetModel(Config.AtmProps, {
                options = options,
                distance = 1.0    
            })
        end
    end
end

RegisterNetEvent('Pug:client:DeleteAtmAtCoords', function(AtmCoords, Model)
    local DeleteAtmObject = GetClosestObjectOfType(AtmCoords, 1.0, Model, 0, 0, 0)
    if DeleteAtmObject ~= 0 then
        TriggerEvent("FullyDeleteRobberiesEntity", DeleteAtmObject)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        if DoesEntityExist(atmEntity) then
            DeleteEntity(atmEntity)
        end
        if DoesEntityExist(spawnedHook) then
            DeleteEntity(spawnedHook)
        end
    end
end)