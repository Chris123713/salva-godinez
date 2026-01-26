local mp_pointing = false

function GetFishingInfoOpen()
    local info = {
		opnchest = OpeningChest,
		success = succededchestopen
    }
    return info
end

local function startPointing()
    local ped = PlayerPedId()
    RequestAnimDict("anim@mp_point")
    while not HasAnimDictLoaded("anim@mp_point") do
        Wait(0)
    end
    SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
    SetPedConfigFlag(ped, 36, 1)
    Citizen.InvokeNative(0x2D537BA194896636, ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
    RemoveAnimDict("anim@mp_point")
end

local function stopPointing()
    local ped = PlayerPedId()
    Citizen.InvokeNative(0xD01015C7316AE176, ped, "Stop")
    if not IsPedInjured(ped) then
        ClearPedSecondaryTask(ped)
    end
    if not IsPedInAnyVehicle(ped, 1) then
        SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
    end
    SetPedConfigFlag(ped, 36, 0)
    ClearPedSecondaryTask(PlayerPedId())
end

local TreasureBlip

local function getBlipRadius(d)
    if d <= 5   then return 10
    elseif d <= 15  then return 20
    elseif d <= 35  then return 40
    elseif d <= 75  then return 80
    elseif d <= 115 then return 120
    elseif d <= 250 then return 260
    elseif d <= 1000 then return 550
    elseif d <= 3500 then return 1800
    elseif d <= 5000 then return 2600
    elseif d <= 6000 then return 3200
    else return 4000
    end
end

local function getBlipColorByDistance(dist)
    if dist <= 150 then return 1          -- Red (hot)
    elseif dist <= 500 then return 47    -- Orange/yellow (warm)
    elseif dist <= 1000 then return 43    -- Light green
    elseif dist <= 1500 then return 3    -- Light blue
    else return 29                       -- Deep blue (cold)
    end
end

local function updateTreasureBlip(vec, dist)
    if TreasureBlip and DoesBlipExist(TreasureBlip) then
        RemoveBlip(TreasureBlip)
    end
    local FinalDistance = dist and dist <= 2200 and dist or 2200.0
    TreasureBlip = AddBlipForRadius(vec.x, vec.y, vec.z, FinalDistance)
    SetBlipSprite(TreasureBlip, 9)
    SetBlipColour(TreasureBlip, getBlipColorByDistance(FinalDistance))
    SetBlipAlpha(TreasureBlip, 80)
    SetBlipAsShortRange(TreasureBlip, false)
end


local chestspawned = false
RegisterNetEvent("Pug:client:UseTreasureMap", function(Bool)
    Config.FrameworkFunctions.TriggerCallback('Pug:ServerCB:TreasureLocation', function(Location)
        local pedPos = GetEntityCoords(PlayerPedId())
        local dist = #(pedPos - Location)
        if Config.Debug or Config.SetWayPointToTreasure then
            SetNewWaypoint(Location.x, Location.y)
            if dist >= 25 then
                FishingNotify(Translations.success.use_chest_soon, "success")
            end
        end
        if dist <= 35 and not chestspawned then
            chestspawned = true
            if TreasurechestSpawn == nil then
                if Bool then
                    PugFishToggleItem(false, Config.ChestItem, 1)
                end
                RequestModel(GetHashKey("xm_prop_x17_chest_closed"))
                while not HasModelLoaded(GetHashKey("xm_prop_x17_chest_closed")) do Wait(1) end
                TreasurechestSpawn = CreateObject(GetHashKey("xm_prop_x17_chest_closed"),Location.x, Location.y, Location.z,false,false,false)
                PlaceObjectOnGroundProperly(TreasurechestSpawn)
                Wait(100)
                FreezeEntityPosition(TreasurechestSpawn, true)
                if TreasureBlip and DoesBlipExist(TreasureBlip) then
                    RemoveBlip(TreasureBlip)
                end
                FoundTreasureBlip = AddBlipForCoord(Location.x, Location.y, Location.z)
                SetBlipSprite(FoundTreasureBlip, 587) -- a treasure-looking icon
                SetBlipScale(FoundTreasureBlip, 0.8)
                SetBlipColour(FoundTreasureBlip, 26)
                SetBlipAlpha(FoundTreasureBlip, 150)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Treasure Center")
                EndTextCommandSetBlipName(FoundTreasureBlip)
            end
            if Config.Target == "ox_target" then
                exports.ox_target:addModel("xm_prop_x17_chest_closed", {
                    {
                        name = 'TreasurechestSpawn',
                        event = 'Pug:client:OpenFoundTreasure',
                        icon = 'fa-solid fa-treasure-chest',
                        label = Translations.map.open_chest,
                    }
                })
            else
                exports[Config.Target]:AddTargetEntity(TreasurechestSpawn, {
                    options = {
                        {
                            type = "client",
                            event = "Pug:client:OpenFoundTreasure",
                            icon = "fa-solid fa-treasure-chest",
                            label = Translations.map.open_chest,
            
                        },
                    },
                    distance = 3.0
                })
            end
        end
        TaskTurnPedToFaceCoord(PlayerPedId(), Location, 1000)
        RequestAnimDict("amb@world_human_tourist_map@male@base")
        while not HasAnimDictLoaded("amb@world_human_tourist_map@male@base") do
            Wait(100)
        end
        TaskPlayAnim(PlayerPedId(), "amb@world_human_tourist_map@male@base", "base", 8.0, -8.0, -1, 51, 0)
        Wait(3000)
        ClearPedTasks(PlayerPedId())
        TriggerEvent("Pug:Fishing:ReloadSkin")
        if dist >= 40 then
            updateTreasureBlip(Location, dist)
        end
        if dist <= 5 then
            FishingNotify(Translations.map.on_top, "success")
        elseif dist <= 15 and dist > 5 then
            FishingNotify(Translations.map.scorching_hot)
        elseif dist <= 35 and dist > 15 then
            FishingNotify(Translations.map.extremely_hot)
        elseif dist <= 75 and dist > 35 then
            FishingNotify(Translations.map.pretty_hot)
        elseif dist <= 115 and dist > 75 then
            FishingNotify(Translations.map.hot)
        elseif dist <= 250 and dist > 115 then
            FishingNotify(Translations.map.warm)
        elseif dist <= 1000 and dist > 250 then
            FishingNotify(Translations.map.cool)
        elseif dist <= 3500 and dist > 1000 then
            FishingNotify(Translations.map.cold)
        elseif dist <= 5000 and dist > 3500 then
            FishingNotify(Translations.map.pretty_cold)
        elseif dist <= 6000 and dist > 5000 then
            FishingNotify(Translations.map.extremely_cold)
        else
            FishingNotify(Translations.map.freezing_cold)
        end
    end)
end)

local function GiveChestItemsToPlayer()
    return SendProtected("Pug:server:GiveChestItems")
end


RegisterNetEvent("Pug:client:OpenFoundTreasure", function()
    LockInventory()
    if HasItem("treasuremap", 1) then
        if FoundTreasureBlip and DoesBlipExist(FoundTreasureBlip) then
            RemoveBlip(FoundTreasureBlip)
        end
        if Config.Target == "ox_target" then
            exports.ox_target:removeModel("xm_prop_x17_chest_closed", "TreasurechestSpawn")
        else
            exports[Config.Target]:RemoveTargetEntity(TreasurechestSpawn)
        end
        PugFishToggleItem(false, 'treasuremap', 1)
        RequestAnimDict("anim@heists@ornate_bank@hack")
        while not HasAnimDictLoaded("anim@heists@ornate_bank@hack") do
            Wait(100)
        end
        local coords = GetEntityCoords(PlayerPedId())
        local heading = GetEntityHeading(PlayerPedId())
        local forward = GetEntityForwardVector(PlayerPedId())
        local x, y, z = table.unpack(coords + forward * 0.5)
        TaskPlayAnim(PlayerPedId(), "anim@heists@ornate_bank@hack", "hack_loop", 8.0, -8.0, -1, 1, 0, false, false, false)
        if Config.TreasureChestCompleteMiniGame then
            TriggerEvent("Pug:client:UseKeyOnChest")
            while GetFishingInfoOpen().opnchest do
                Wait(300)
                if GetFishingInfoOpen().opnchest then
                    Wait(5)
                else
                    break
                end
            end
        else
            Wait(2000)
        end
        if GetFishingInfoOpen().success or not Config.TreasureChestCompleteMiniGame then
            if Config.Target == "ox_target" then
                exports.ox_target:removeModel("xm_prop_x17_chest_closed", "TreasurechestSpawn")
            end
            DeleteEntity(TreasurechestSpawn)
            chestspawned = false
            TreasurechestSpawn = nil
            if DoesEntityExist(TreasurechestSpawn)  then
                DeleteEntity(TreasurechestSpawn)
            end
            UnlockInventory()
            objectOpen = CreateObject(GetHashKey('xm_prop_x17_chest_open'), x+0.2, y, z, true, false, false)
            PlaceObjectOnGroundProperly(objectOpen)
            SetEntityHeading(objectOpen, heading)
            FreezeEntityPosition(objectOpen, true)
            Wait(200)
            GiveChestItemsToPlayer()
        else
            if Config.LockInventory then
                UnlockInventory()
            end
            PugFishToggleItem(true, 'treasuremap', 1)
            if Config.Target == "ox_target" then
                exports.ox_target:addModel("xm_prop_x17_chest_closed", {
                    {
                        name = 'TreasurechestSpawn',
                        event = 'Pug:client:OpenFoundTreasure',
                        icon = 'fa-solid fa-treasure-chest',
                        label = Translations.map.open_chest,
                    }
                })
            else
                exports[Config.Target]:AddTargetEntity(TreasurechestSpawn, {
                    options = {
                        {
                            type = "client",
                            event = "Pug:client:OpenFoundTreasure",
                            icon = "fa-solid fa-treasure-chest",
                            label = Translations.map.open_chest,
            
                        },
                    },
                    distance = 3.0
                })
            end
        end
        ClearPedTasks(PlayerPedId())
    else
        if Config.LockInventory then
            UnlockInventory()
        end
        FishingNotify(Translations.error.no_map, 'error')
    end
end)

RegisterNetEvent("Pug:client:DeleteOpenChest", function()
    RequestAnimDict("anim@heists@ornate_bank@hack")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@hack") do
        Wait(100)
    end
    TaskPlayAnim(PlayerPedId(), "anim@heists@ornate_bank@hack", "hack_exit", 8.0, -8.0, -1, 1, 0, false, false, false)
    Wait(1000)
    DeleteEntity(objectOpen)
    if DoesEntityExist(objectOpen)then
        DeleteEntity(objectOpen)
    end
    objectOpen = nil
    local heading = GetEntityHeading(PlayerPedId())
    local forward = GetEntityForwardVector(PlayerPedId())
    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()) + forward * 0.5)
    local object = CreateObject(GetHashKey('xm_prop_x17_chest_closed'), x+0.2, y, z, true, false, false)
    PlaceObjectOnGroundProperly(object)
    SetEntityHeading(object, heading)
    FreezeEntityPosition(object, true)
    Wait(1600)
    ClearPedTasks(PlayerPedId())
    DeleteEntity(object)
    if DoesEntityExist(object)then
        DeleteEntity(object)
    end
end)

RegisterNetEvent('Pug:client:Openbottlemap', function()
    RequestAnimDict("mp_arresting")
    while (not HasAnimDictLoaded("mp_arresting")) do
        Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), "mp_arresting" ,"a_uncuff" ,8.0, -8.0, -1, 1, 0, false, false, false )
    local Coords = GetEntityCoords(PlayerPedId())
    bottle = CreateObject(GetHashKey('p_amb_bag_bottle_01'), Coords.x, Coords.y,Coords.z, true, true, true)
    AttachEntityToEntity(bottle, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 0xDEAD), 0.1, 0.05, 0.0, -40.0, 10.0, 90.0, false, false, false, false, 2, true)

    PugProgressBar("opening_box", "Opening bottle", 3700, {
        disables = {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        },
        anim = {}
    }, function()
        local ped = PlayerPedId()

        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_SMOKING", 0, true)
        TriggerEvent("Pug:Fishing:ReloadSkin")
        Wait(1000)

        DeleteEntity(bottle)
        Wait(1000)

        loadAnimDict("amb@world_human_tourist_map@male@base")
        TaskPlayAnim(ped, "amb@world_human_tourist_map@male@base", "base", 8.0, -8.0, -1, 51, 0, false, false, false)

        local mapProp = GetHashKey("prop_tourist_map_01")
        RequestModel(mapProp)
        while not HasModelLoaded(mapProp) do Wait(0) end

        local prop = CreateObject(mapProp, 0.0, 0.0, 0.0, true, true, false)
        AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

        Wait(2000)

        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_SMOKING", 0, true)
        TriggerEvent("Pug:Fishing:ReloadSkin")
        Wait(1300)

        ClearPedTasks(ped)
        DeleteEntity(prop)
        PugFishToggleItem(true, "treasuremap", 1)
        Wait(500)
    end, function()
        PugFishToggleItem(true, "bottlemap", 1)
        TriggerEvent("Pug:Fishing:ReloadSkin")
        ClearPedTasks(PlayerPedId())
        FishingNotify(Translations.details.canceled, "error")
        Wait(500)
    end)
end)

RegisterNetEvent('Pug:client:UseKeyOnChest', function()
	OpeningChest = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "opencircle_game",
        amount = math.random(5, 10),
    })
end)

RegisterNetEvent("Pug:client:OpenTreasureChest", function()
    LockInventory()
    if HasItem(Config.ChestKey, 1) then
        local ped = PlayerPedId()
        local pedPos = GetEntityCoords(ped)
        RequestAnimDict("anim@heists@money_grab@briefcase")
        RequestAnimDict("anim@heists@ornate_bank@hack")
        while not HasAnimDictLoaded("anim@heists@money_grab@briefcase") or not HasAnimDictLoaded("anim@heists@ornate_bank@hack") do
            Wait(100)
        end
        TaskPlayAnim(PlayerPedId(), "anim@heists@money_grab@briefcase", "put_down_case", 8.0, -8.0, -1, 1, 0, false, false, false)
        Wait(100)
        if Cooler == nil then
            RequestModel(GetHashKey("xm_prop_x17_chest_closed"))
            while not HasModelLoaded(GetHashKey("xm_prop_x17_chest_closed")) do Wait(1) end
            Cooler = CreateObject(GetHashKey("xm_prop_x17_chest_closed"),pedPos.x, pedPos.y, pedPos.z,false,false,false)
            AttachEntityToEntity(Cooler, ped, GetPedBoneIndex(ped, 0xEE4F), 0.35, 0.21,  0.05, 0.0, 210.0, -250.0, true, true, false, true, 1, true) -- object is attached to left hand 
        end
        Wait(500)
        ClearPedTasks(PlayerPedId())
        local coords = GetEntityCoords(PlayerPedId())
        local heading = GetEntityHeading(PlayerPedId())
        local forward = GetEntityForwardVector(PlayerPedId())
        local x, y, z = table.unpack(coords + forward * 0.5)
        DeleteEntity(Cooler)
        if DoesEntityExist(Cooler)  then
            DeleteEntity(Cooler)
        end
        local object = CreateObject(GetHashKey('xm_prop_x17_chest_closed'), x+0.2, y, z, true, false, false)
        PlaceObjectOnGroundProperly(object)
        SetEntityHeading(object, heading)
        FreezeEntityPosition(object, true)
        TaskPlayAnim(PlayerPedId(), "anim@heists@ornate_bank@hack", "hack_loop", 8.0, -8.0, -1, 1, 0, false, false, false)
        if Config.TreasureChestCompleteMiniGame then
            TriggerEvent("Pug:client:UseKeyOnChest")
            while GetFishingInfoOpen().opnchest do
                Wait(300)
                if GetFishingInfoOpen().opnchest then
                    Wait(5)
                else
                    break
                end
            end
        else
            Wait(2000)
        end
        if GetFishingInfoOpen().success or not Config.TreasureChestCompleteMiniGame then
            if HasItem(Config.ChestKey, 1) and HasItem(Config.ChestItem, 1) then
                PugFishToggleItem(false, Config.ChestItem, 1)
                DeleteEntity(object)
                Cooler = nil
                UnlockInventory()
                objectOpen = CreateObject(GetHashKey('xm_prop_x17_chest_open'), x+0.2, y, z, true, false, false)
                PlaceObjectOnGroundProperly(objectOpen)
                SetEntityHeading(objectOpen, heading)
                FreezeEntityPosition(objectOpen, true)
                ClearPedTasks(PlayerPedId())
                Wait(200)
                GiveChestItemsToPlayer()
            else
                DeleteEntity(object)
                if DoesEntityExist(object) or DoesEntityExist(Cooler)  then
                    DeleteEntity(object)
                    DeleteEntity(Cooler)
                    Cooler = nil
                end
                FishingNotify(Translations.error.chest_exploit, 'error')
            end
        else
            TaskPlayAnim(PlayerPedId(), "anim@heists@ornate_bank@hack", "hack_exit", 8.0, -8.0, -1, 1, 0, false, false, false)
            Wait(2000)
            DeleteEntity(object)
            if DoesEntityExist(object) or DoesEntityExist(Cooler)  then
                DeleteEntity(object)
                DeleteEntity(Cooler)
                Cooler = nil
            end
            UnlockInventory()
            local chance = math.random(1,100)
            if chance <= Config.ChanceToLoseKey then
                PugFishToggleItem(false, Config.ChestKey, 1)
            end
        end
        ClearPedTasks(PlayerPedId())
    else
        UnlockInventory()
        FishingNotify(Translations.error.no_key, 'error')
    end
end)


-- NUI Callbacks
RegisterNUICallback('TresureClick', function(_, cb)
    PlaySound(-1, "CLICK_BACK", "WEB_NAVIGATION_SOUNDS_PHONE", 0, 0, 1)
    cb('ok')
end)

RegisterNUICallback('TresureFailed', function(_, cb)
	OpeningChest = false
	succededchestopen = false
    PlaySound(-1, "Place_Prop_Fail", "DLC_Dmod_Prop_Editor_Sounds", 0, 0, 1)
	UnlockInventory()
    cb('ok')
end)

RegisterNUICallback('TresureSuccess', function(_, cb)
	succededchestopen = true
	OpeningChest = false
    ClearPedTasks(PlayerPedId())
    cb('ok')
	Wait(4000)
	succededchestopen = false
	UnlockInventory()
end)

RegisterNUICallback('CloseTresure', function(_, cb)
	OpeningChest = false
    SetNuiFocus(false, false)
	UnlockInventory()
    cb('ok')
end)