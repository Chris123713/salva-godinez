----------------------------------
-------- VEHICLE STUFF -----------
----------------------------------
local function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
	local nearbyEntities = {}
	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		local playerPed = PlayerPedId()
		coords = GetEntityCoords(playerPed)
	end
	for k, entity in pairs(entities) do
		local distance = #(coords - GetEntityCoords(entity))
		if distance <= maxDistance then
			nearbyEntities[#nearbyEntities+1] = isPlayerEntities and k or entity
		end
	end
	return nearbyEntities
end

local function GetVehiclesInArea(coords, maxDistance)
	return EnumerateEntitiesWithinDistance(GetGamePool('CVehicle'), false, coords, maxDistance) 
end

local function IsSpawnPointClear(coords, maxDistance)
	return #GetVehiclesInArea(coords, maxDistance) == 0 
end
local function SetVehicleFuel(Veh, Amount)
	if GetResourceState("LegacyFuel") == 'started' then
		exports["LegacyFuel"]:SetFuel(Veh, Amount)
	elseif GetResourceState("cdn-fuel") == 'started' then
		exports["cdn-fuel"]:SetFuel(Veh, Amount)
	elseif GetResourceState("ps-fuel") == 'started' then
		exports["ps-fuel"]:SetFuel(Veh, Amount)
	elseif GetResourceState("lj-fuel") == 'started' then
		exports["lj-fuel"]:SetFuel(Veh, Amount)
	elseif GetResourceState("ox_fuel") == 'started' then
		Entity(Veh).state.fuel = Amount
	elseif GetResourceState("okokGasStation") == 'started' then
		exports['okokGasStation']:SetFuel(Veh, Amount)
	else
		SetVehicleFuelLevel(veh, 100.0)
	end
end
local function GenerateRandomPlate()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local nums = "0123456789"

    local plate = ""
    for i = 1, 3 do
        plate = plate .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    for i = 1, 3 do
        plate = plate .. nums:sub(math.random(1, #nums), math.random(1, #nums))
    end

    return plate
end
function GiveVehicleKeys(veh, Plate, VehicleSelected)
	if GetResourceState("MrNewbVehicleKeys") == 'started' then
		TriggerEvent(Config.VehilceKeysGivenToPlayerEvent, Plate)
	elseif GetResourceState("qs-vehiclekeys") == 'started' then
		exports['qs-vehiclekeys']:GiveKeys(Plate, VehicleSelected, true)
	elseif GetResourceState("ak47_vehiclekeys") == 'started' then
		exports['ak47_vehiclekeys']:GiveKey(Plate)
	else
		TriggerEvent(Config.VehilceKeysGivenToPlayerEvent, Plate)
	end
end
local function PugSpawnVehicle(model, cb, coords, isnetworked, teleportInto)
	ClearPedTasksImmediately(PlayerPedId())
    local ped = PlayerPedId()
    model = type(model) == 'string' and GetHashKey(model) or model
    if not IsModelInCdimage(model) then return end
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(ped)
    end
    isnetworked = true
    LoadModel(model)
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, isnetworked, false)
    local netid = NetworkGetNetworkIdFromEntity(veh)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetNetworkIdCanMigrate(netid, true)
    SetVehicleNeedsToBeHotwired(veh, false)
    SetVehRadioStation(veh, 'OFF')
	SetVehicleFuel(veh, 100.0)
    SetModelAsNoLongerNeeded(model)
    if cb then cb(veh) end
end

function GetItemImage(filename)
    local base = "https://cfx-nui-"..Config.InventoryType.."/html/images/"

    if Config.InventoryType == "ox_inventory" then
        base = "https://cfx-nui-ox_inventory/web/images/"
        if not filename:match("%.png$") then
            filename = filename..".png"
        end
    elseif Config.InventoryType == "codem-inventory" then
        base = "https://cfx-nui-codem-inventory/html/itemimages/"
    elseif Config.InventoryType == "ak47_qb_inventory" then
        base = "https://cfx-nui-"..Config.InventoryType.."/web/build/images/"
    elseif Config.InventoryType == "ak47_inventory" then
        base = "https://cfx-nui-"..Config.InventoryType.."/web/build/images/"
    end
    return base .. filename
end

function GetRankIndex(rankTitle)
    for i, v in ipairs(Config.XPRanks) do
        if v.rank == rankTitle then
            return i
        end
    end
    return -1
end

RegisterNetEvent('Pug:client:SellFishMenu', function()
    local menu = {}

    for k, v in pairs(Config.SellFishies) do
		local filename, ItemLable = ShowItemLable(k, true)
        local Image = GetItemImage(filename)
        local Amount = GetPlayerItemCount(k)
        local SellPrice = "$"..math.ceil(Amount * v.pricemin).." - $"..math.ceil(Amount * v.pricemax)
        if Config.ShowAllFishToSellInMenu or Amount > 0 then
            table.insert(menu, {
                title       = ItemLable..': '..SellPrice,
                icon        = Image,
                image        = Image,
                iconColor   = "#1e90ff",
                description = Translations.menu.between..v.pricemin..' - $'..v.pricemax..Translations.menu.per_fish,
                event       = "Pug:client:SellFish",
                disabled = Amount < 1,
                args        = k,
            })
        end
    end

    if Config.Menu ~= "ox_lib" then
        table.insert(menu, {
            title = Translations.menu.back,
            icon  = "fa-solid fa-arrow-left",
            event = "Pug:client:OpenFishingMenu"
        })
    end

    PugCreateMenu("sell_fish", Translations.menu.sell_fish, menu, "fishing_menu")
end)

RegisterNetEvent("Pug:client:SellFish", function(item)
	if item and HasItem(string.lower(tostring(item)), 1) then
		SellFishAnim()

        local Amount = GetPlayerItemCount(item)
        local SellTime = math.random(Config.SellFishTime.MinimumTime, Config.SellFishTime.MaximumTime) * Amount

		PugProgressBar("selling_fish", Translations.details.selling_fish..' '..ShowItemLable(item), SellTime * 1000, {
            disables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            anim = {}
        }, function() -- Done
            Config.FrameworkFunctions.TriggerCallback('Pug:ServerCB:SellFish', function(cansell)
                if cansell then
                    
                else
                    FishingNotify(Translations.error.no_fish, 'error')
                end
            end,item)
        end, function() -- Cancel
            FishingNotify(Translations.details.canceled, "error")
        end)
	else
		FishingNotify(Translations.error.no_fish, 'error')
	end
end)


RegisterNetEvent('Pug:client:SellFishingGemsMenu', function(data)
    if data.data then data.args = data.data end
    local menu = {}

    for k, v in pairs(Config.SellGems) do
		local filename, ItemLable = ShowItemLable(k, true)
        local Image = GetItemImage(filename)
        table.insert(menu, {
            title       = Translations.menu.sell..ItemLable,
            icon        = Image,
			image        = Image,
            iconColor   = "#32cd32",
            description = Translations.menu.between..v.pricemin..' - '..v.pricemax..Translations.menu.per_gem,
            event       = "Pug:client:SellFishingGems",
			disabled = not HasItem(k, 1),
            args        = k
        })
    end

    PugCreateMenu("sell_gems", Translations.menu.sell_gems, menu)
    
    if data and data.args and data.args.entity then
        CreateCameraNPC(data.args.entity, {-0.25, 0.0, 0.0})
    end
end)

RegisterNetEvent("Pug:client:SellFishingGems", function(item)
	if HasItem(item, 1) then
		SellFishAnim()
        
        local Amount = GetPlayerItemCount(item)
        local SellTime = math.random(Config.SellFishTime.MinimumTime, Config.SellFishTime.MaximumTime) * Amount

		PugProgressBar("selling_gems", Translations.details.selling_fish..' '..ShowItemLable(item), SellTime * 1000, {
            disables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            anim = {}
        }, function() -- Done
            Config.FrameworkFunctions.TriggerCallback('Pug:ServerCB:SellGems', function(cansell)
                if cansell then
                    
                else
                    FishingNotify(Translations.error.no_gems, 'error')
                end
            end,item)
        end, function() -- Cancel
            FishingNotify(Translations.details.canceled, "error")
        end)
	else
		FishingNotify(Translations.error.no_gems, 'error')
	end
end)

RegisterNetEvent('Pug:client:SellFishingCrabsMenu', function(data)
    if data.data then data.args = data.data end

    local menu = {}
    for k, v in pairs(Config.SellCrabs) do
        local filename, ItemLable = ShowItemLable(k, true)
        local Image = GetItemImage(filename)
        table.insert(menu, {
            title       = Translations.menu.sell .. ItemLable,
            icon        = Image,
            image       = Image,
            iconColor   = "#e97451", -- crab-orange tone
            description = Translations.menu.between .. v.pricemin .. ' - ' .. v.pricemax .. Translations.menu.per_crab,
            event       = "Pug:client:SellFishingCrabs",
            disabled    = not HasItem(k, 1),
            args        = k
        })
    end

    if Config.Menu ~= "ox_lib" then
        table.insert(menu, {
            title = Translations.menu.back,
            icon  = "fa-solid fa-arrow-left",
            event = "Pug:client:OpenFishingMenu"
        })
    end

    PugCreateMenu("sell_crabs", Translations.menu.sell_crabs, menu)

    if data and data.args and data.args.entity then
        CreateCameraNPC(data.args.entity, {-0.25, 0.0, 0.0})
    end
end)

RegisterNetEvent("Pug:client:SellFishingCrabs", function(item)
    if HasItem(item, 1) then
        SellFishAnim()

        local Amount = GetPlayerItemCount(item)
        local SellTime = math.random(Config.SellFishTime.MinimumTime, Config.SellFishTime.MaximumTime) * Amount

        PugProgressBar("selling_crabs", Translations.details.selling_fish .. ' ' .. ShowItemLable(item), SellTime * 1000, {
            disables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            anim = {}
        }, function()
            Config.FrameworkFunctions.TriggerCallback('Pug:ServerCB:SellCrabs', function(cansell)
                if cansell then
                    -- success handled by server
                else
                    FishingNotify(Translations.error.no_crabs, 'error')
                end
            end, item)
        end, function()
            FishingNotify(Translations.details.canceled, "error")
        end)
    else
        FishingNotify(Translations.error.no_crabs, 'error')
    end
end)


function GetRankInfoFromXP(xp)
    local level = math.floor((xp / 1000) * 100)
    if level < 0 then level = 0 elseif level > 100 then level = 100 end

    for i, v in ipairs(Config.XPRanks) do
        if (xp >= v.min and xp <= v.max) or (i == 8 and xp >= v.min) then
            local range = v.max - v.min
            local percent
            if range <= 0 then
                percent = 100
            else
                percent = math.floor(((xp - v.min) / range) * 100)
                if percent < 0 then percent = 0 elseif percent > 100 then percent = 100 end
            end
            return { title = v.rank, level = level, percent = percent }
        end
    end

    return { title = "Unknown", level = level, percent = 0 }
end


RegisterNetEvent('Pug:client:OpenFishingMenu', function(Data)
    Config.FrameworkFunctions.TriggerCallback('Pug:ServerCB:GetFishingRep', function(rep)
        local rankInfo = GetRankInfoFromXP(rep)
        local menu = {}

        table.insert(menu, {
            title       = ("Rank %d - %s"):format(rankInfo.level, rankInfo.title),
            description = (Translations.menu.next_rank_progress):format(rankInfo.percent),
            icon        = "fa-solid fa-user",
            iconColor   = "#1e90ff",
            colorScheme = '#1e90ff',
            progress    = rankInfo.percent,
        })

        table.insert(menu, {
            title       = Translations.menu.selling_your_fish,
            description = Translations.details.open_fish_sales,
            icon        = "fa-solid fa-dollar-sign",
            iconColor   = "#32cd32",
            arrow = true,
            event       = "Pug:client:SellFishMenu"
        })

        table.insert(menu, {
            title       = Translations.menu.fishing_equipment,
            description = Translations.details.browse_equipment,
            icon        = "fa-solid fa-shop",
            iconColor   = "#1e90ff",
            arrow = true,
            event       = "Pug:client:OpenFishingEquipment"
        })

        table.insert(menu, {
            title       = Translations.menu.all_time_leaderboard,
            description = Translations.details.view_best_catches,
            icon        = "fa-solid fa-trophy",
            iconColor   = "#ffd700",
            arrow = true,
            event       = "Pug:client:OpenLeaderboardStats"
        })

        table.insert(menu, {
            title       = Translations.menu.tournaments,
            description = Translations.details.view_tournament_info,
            icon        = "fa-solid fa-medal",
            iconColor   = "#6a5acd",
            arrow = true,
            event       = "Pug:client:ViewTournamentMenu"
        })

        table.insert(menu, {
            title       = Translations.menu.fishing_challenges,
            description = Translations.details.view_challenges,
            icon        = "fa-solid fa-list-check",
            iconColor   = "#FACC15",
            arrow = true,
            event       = "Pug:client:OpenChallengesMenu"
        })

        table.insert(menu, {
            title       = Translations.menu.skill_system,
            description = Translations.details.upgrade_skills,
            icon        = "fa-star",
            iconColor   = "#F97316",
            arrow = true,
            event       = "Pug:client:OpenSkillsMenu"
        })

        table.insert(menu, {
            title       = Translations.menu.boat_shop,
            description = Translations.details.upgrade_buy_boat,
            icon        = "fa-anchor",
            iconColor   = "#6B7280",
            arrow = true,
            event       = "Pug:client:OpenBoatPurchaseMenu"
        })

        PugCreateMenu("fishing_menu", Translations.menu.fishing, menu)
        if Data and Data.entity then
            CreateCameraNPC(Data.entity, {-0.25, 0.0, 0.0})
        end
    end)
end)
RegisterNetEvent("Pug:client:OpenFishingEquipment", function()
    Config.FrameworkFunctions.TriggerCallback('Pug:ServerCB:GetFishingRep', function(rep)
        local menu = {}

        for _, item in pairs(Config.FishingEquipment) do
            local itemName = item.item
            local price = item.price or 0
            local filename, ItemLable = ShowItemLable(itemName, true)
            local Image = GetItemImage(filename)
            local xpRequired = item.xpRequired or 0
            local hasRank = rep >= xpRequired

            local entry = {
                title       = ItemLable,
                description = hasRank and (Translations.menu.price):format(price) or ("Requires Rank: %s"):format(GetRankInfoFromXP(xpRequired).title),
                icon        = Image,
                image       = Image,
                iconColor   = hasRank and "#1e90ff" or "#808080",
                readOnly    = not hasRank,
                disabled    = not hasRank,
                event       = hasRank and (itemName == "fishingbait" and "Pug:client:BuyFishingBaitDialog" or "Pug:client:PurchaseFishingEquipment") or nil,
                args        = hasRank and itemName or nil
            }

            table.insert(menu, entry)
        end

        if Config.Menu ~= "ox_lib" then
            table.insert(menu, {
                title = Translations.menu.back,
                icon  = "fa-solid fa-arrow-left",
                event = "Pug:client:OpenFishingMenu"
            })
        end

        PugCreateMenu("fishing_equipment", Translations.menu.fishing_equipment, menu, "fishing_menu")
    end)
end)


RegisterNetEvent("Pug:client:BuyFishingBaitDialog", function(itemName)
    if not itemName or itemName ~= "fishingbait" then return end

    local Input = PugInputDialog(Translations.menu.buy_bait, {
        {
            label = Translations.details.buy_bait_amount,
            name = "amount",
            type = "number",
            isRequired = true,
        }
    })

    if not Input then return end

    local amount = tonumber(Input[1])
    if not amount or amount < 1 then
        FishingNotify(Translations.error.invalid_bait_amount, "error")
        return
    end

    TriggerEvent("Pug:client:PurchaseFishingEquipment", itemName, amount)
end)


RegisterNetEvent("Pug:client:PurchaseFishingEquipment", function(itemName, amount)
    if not itemName then return end
    amount = amount or 1
    TriggerServerEvent("Pug:Server:BuyFishingItem", itemName, amount)
end)

RegisterNetEvent('Pug:client:OpenBoatPurchaseMenu', function()
    Config.FrameworkFunctions.TriggerCallback('Pug:ServerCB:GetFishingRepAndBoats', function(rep, owned)
        local boatMenu = {}

        local rankInfo = GetRankInfoFromXP(rep)
        table.insert(boatMenu, {
            title       = (Translations.menu.rank):format(rankInfo.level, rankInfo.title),
            description = (Translations.menu.next_rank_progress):format(rankInfo.percent),
            icon        = 'fa-solid fa-user',
            iconColor   = '#1e90ff',
            progress    = rankInfo.percent,
            colorScheme = '#1e90ff',
            readOnly    = true
        })

        if SpawnedCar and DoesEntityExist(SpawnedCar) then
            local modelHash = GetEntityModel(SpawnedCar)
            for _, boat in ipairs(Config.Boats) do
                if GetHashKey(boat.model) == modelHash then
                    table.insert(boatMenu, {
                        title = "Store "..boat.name .. " (Out)",
                        description = Translations.menu.boat_out_desc or "This boat is currently out. Click to store it.",
                        icon = 'fa-solid fa-anchor-circle-xmark',
                        iconColor = '#dc2626',
                        event = 'Pug:client:StoreBoat'
                    })
                    break
                end
            end
        end

        for _, boat in ipairs(Config.Boats) do
            local isOwned = owned[boat.model] == true
            local canBuy = rep >= boat.xpRequired
            local boatRank = math.floor((boat.xpRequired / 1000) * 100)

            local entry = {
                title       = boat.name .. (isOwned and ' (Owned)' or ''),
                description = (Translations.menu.storage_slots_rank):format(
                    boat.storage or 0,
                    boat.slots or 0,
                    boatRank or 0,
                    boat.cost or 0
                ),
                image = boat.image,
                icon        = isOwned and 'fa-solid fa-circle-check' or (canBuy and 'fa-solid fa-ship' or 'fa-solid fa-lock'),
                iconColor   = isOwned and '#00ced1' or (canBuy and '#32cd32' or '#808080'),
                readOnly    = not isOwned and not canBuy
            }

            if isOwned then
                entry.event = 'Pug:client:SpawnBoat'
                entry.args  = boat.model

            elseif canBuy then
                entry.event = 'Pug:client:BuyBoat'
                entry.args  = boat.model

                entry.progress = 100
                entry.colorScheme = GetProgressBarColor(100)

            else
                local progressToBoat = math.floor((rep / boat.xpRequired) * 100)
                if progressToBoat > 100 then progressToBoat = 100 end
                entry.progress = progressToBoat
                entry.colorScheme = GetProgressBarColor(progressToBoat)
            end


            table.insert(boatMenu, entry)
        end

        if Config.Menu ~= "ox_lib" then
            table.insert(boatMenu, {
                title = Translations.menu.back,
                icon  = "fa-solid fa-arrow-left",
                event = "Pug:client:OpenFishingMenu"
            })
        end

        PugCreateMenu('boat_purchase', Translations.menu.boat_shop, boatMenu, "fishing_menu")
    end)
end)

RegisterNetEvent("Pug:client:StoreBoat", function()
    if SpawnedCar and DoesEntityExist(SpawnedCar) then
        TriggerEvent("FullyDeleteFishingEntity", SpawnedCar)
        Wait(2000)
        if DoesEntityExist(SpawnedCar) then
            local netid = NetworkGetNetworkIdFromEntity(SpawnedCar)
            TriggerServerEvent("Pug:server:FullyRemoveVehicleFishing", netid)
        else
            SpawnedCar = nil
        end
        FishingNotify("Boat has been stored.", "success")
    else
        FishingNotify("No active boat found.", "error")
    end
end)

RegisterNetEvent('Pug:client:BuyBoat', function(model)
    TriggerServerEvent("Pug:Server:BuyBoat", model)
    Wait(100)
    TriggerEvent("Pug:client:OpenBoatPurchaseMenu")
end)


RegisterNetEvent('Pug:client:SpawnBoat', function(model)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local closestGroup, closestDist = nil, math.huge

    for name, data in pairs(Config.LifeGuardLocations) do
        for _, coord in ipairs(data.BoatSpawns) do
            local dist = #(pos - vector3(coord.x, coord.y, coord.z))
            if dist < closestDist then
                closestDist = dist
                closestGroup = name
            end
        end
    end

    if not closestGroup then
        FishingNotify(Translations.error.no_boat_nearby, "error")
        return
    end

    local spawnPoint = nil
    local groupSpawns = Config.LifeGuardLocations[closestGroup].BoatSpawns

    for _, coord in ipairs(groupSpawns) do
        if IsSpawnPointClear(vector3(coord.x, coord.y, coord.z), 5.0) then
            spawnPoint = coord
            break
        end
    end

    if not spawnPoint then
        ClearPedTasksImmediately(PlayerPedId())
        FishingNotify(Translations.error.area_not_clear, "error")
        return
    end

    if SpawnedCar then
        TriggerEvent("FullyDeleteFishingEntity", SpawnedCar)
    end

    PugSpawnVehicle(model, function(veh)
        SpawnedCar = veh
        SetEntityCoords(veh, spawnPoint.x, spawnPoint.y, spawnPoint.z, false, false, false, true)
        SetEntityHeading(veh, spawnPoint.w)
        SetVehicleEngineOn(veh, false, false)
        SetVehicleOnGroundProperly(veh)
        SetVehicleNeedsToBeHotwired(veh, false)
        SetVehicleColours(veh, 0, 0)
        local GeneratedPlate = GenerateRandomPlate()
        SetVehicleNumberPlateText(veh, GeneratedPlate)
        SetVehicleFuel(veh, 100.0)
        SetVehicleDoorsLocked(veh, 0)

        local VehiclePlate = GetVehicleNumberPlateText(veh)
        if VehiclePlate then
            GiveVehicleKeys(veh, string.gsub(VehiclePlate, '^%s*(.-)%s*$', '%1'), model)
        else
            GiveVehicleKeys(veh, GeneratedPlate, model)
        end

        CreateThread(function()
            local endTime = GetGameTimer() + 30000
            while DoesEntityExist(veh) and GetGameTimer() < endTime do
                if GetVehiclePedIsIn(PlayerPedId(), false) == veh then
                    break
                end
                SetEntityDrawOutline(veh, true)
                SetEntityDrawOutlineColor(255, 255, 0, 255)
                Wait(0)
            end
            if DoesEntityExist(veh) then
                SetEntityDrawOutline(veh, false)
            end
        end)

        PugAddTargetToEntity(veh, {
            {
                name     = "openboatstorage",
                type     = "client",
                event    = "Pug:client:OpenBoatStorage",
                icon     = "fas fa-box-open",
                label    = Translations.menu.Open_Boat_Storage,
                args     = {
                    plate = VehiclePlate,
                    model = model
                },
                distance = 2.5,
            }
        })

    end, vector3(spawnPoint.x, spawnPoint.y, spawnPoint.z), true)
end)

RegisterNetEvent("Pug:client:OpenBoatStorage", function(data)
    if data.data or not data.data then data.args = data.data and data.data or data end
    local plate = data.args.plate or "boat"
    local model = data.args.model or "unknown"
    local stashId = "boat_" .. plate

    local boatInfo
    for _, boat in pairs(Config.Boats) do
        if boat.model == model then
            boatInfo = boat
            break
        end
    end

    local slots = boatInfo and boatInfo.slots or 10
    local weight = boatInfo and boatInfo.storage or 50

    if Config.InventoryType == "ox_inventory" then
		TriggerServerEvent("Pug:server:BoatStashCreate", stashId, slots, weight)
		exports.ox_inventory:openInventory('stash', stashId)
    elseif Config.InventoryType == "qs-inventory" then
        exports['qs-inventory']:RegisterStash(stashId, slots, weight)

    elseif Config.InventoryType == "codem-inventory" then
        TriggerServerEvent("codem-inventory:server:openInventory", {
            id = stashId,
            type = "stash",
            slots = slots,
            weight = weight
        })

    elseif Config.InventoryType == "ak47_inventory" then
        exports['ak47_inventory']:OpenInventory({
            identifier = stashId,
            label = 'Boat Storage',
            type = 'stash',
            maxWeight = weight,
            slots = slots,
        })
    elseif Config.InventoryType == "core_inventory" then
        TriggerServerEvent("core_inventory:server:openInventory", {
            id = stashId,
            type = "stash",
            slots = slots,
            weight = weight
        })

    elseif Config.InventoryType == "tgiann-inventory" then
        TriggerServerEvent("tgiann-inventory:server:OpenInventory", {
            id = stashId,
            type = "stash",
            slots = slots,
            weight = weight
        })

    elseif Config.InventoryType == "qb-inventory"
        or Config.InventoryType == "ps-inventory"
        or Config.InventoryType == "lj-inventory" then

        TriggerServerEvent("inventory:server:OpenInventory", "stash", stashId, {
            maxweight = weight,
            slots = slots,
        })
        TriggerEvent("inventory:client:SetCurrentStash", stashId)

    elseif Framework == "QBCore" then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", stashId)
        TriggerEvent("inventory:client:SetCurrentStash", stashId)
    end
end)

-- Main Challenges Menu
RegisterNetEvent('Pug:client:OpenChallengesMenu', function()
    Config.FrameworkFunctions.TriggerCallback('Pug:ServerCB:GetChallengeData', function(data)
        local dh = math.floor(data.dailyResetInSeconds / 3600)
        local dm = math.floor((data.dailyResetInSeconds % 3600) / 60)
        local whd = math.floor(data.weeklyResetInSeconds / 86400)
        local wh  = math.floor((data.weeklyResetInSeconds % 86400) / 3600)
        local wm  = math.floor((data.weeklyResetInSeconds % 3600) / 60)

        local menu = {
            {
                title       = Translations.menu.challenges_daily,
                description = (Translations.menu.reset_in_day):format(dh, dm),
                icon        = "fa-solid fa-calendar-day",
                iconColor   = "#1e90ff",
                arrow = true,
                event       = "Pug:client:OpenDailyChallenges"
            },
            {
                title       = Translations.menu.challenges_weekly,
                description = (Translations.menu.reset_in_week):format(whd, wh, wm),
                icon        = "fa-solid fa-calendar-week",
                iconColor   = "#FACC15",
                arrow = true,
                event       = "Pug:client:OpenWeeklyChallenges"
            },
        }

        if Config.Menu ~= "ox_lib" then
            table.insert(menu, {
                title = Translations.menu.back,
                icon  = "fa-solid fa-arrow-left",
                event = "Pug:client:OpenFishingMenu"
            })
        end

        PugCreateMenu("challenges_main", Translations.menu.challenges, menu, "fishing_menu")
    end)
end)


function GetProgressBarColor(percent, isClaimed)
    if percent >= 100 then
        return isClaimed and "#FFD700" or "#32cd32" -- gold if claimed, green if not
    elseif percent >= 75 then
        return "#32cd32" -- green
    elseif percent >= 50 then
        return "#facc15" -- yellow
    elseif percent >= 25 then
        return "#f97316" -- orange
    else
        return "#ef4444" -- red
    end
end


-- Daily Challenges List
RegisterNetEvent('Pug:client:OpenDailyChallenges', function()
    Config.FrameworkFunctions.TriggerCallback('Pug:ServerCB:GetChallengeData', function(data)
        local menu = {}

        for _, ch in ipairs(data.dailyChallenges or {}) do
            local prog = ch.completed or 0
            local done = prog >= ch.toComplete
            local claimed = ch.claimed or false

            local percent = math.floor((prog / ch.toComplete) * 100)
            if percent > 100 then percent = 100 end

            local barColor = GetProgressBarColor(percent, claimed)

            local statusText = claimed and "Claimed" or (done and "Completed" or "In Progress")
            local icon = claimed and "fa-regular fa-square-check" or (done and "fa-solid fa-square-check" or "fa-regular fa-square")
            local iconColor = claimed and "#FFD700" or (done and "#32cd32" or "#3270cd")

            table.insert(menu, {
                title       = ch.title,
                description = (Translations.menu.progress_status_reward):format(
                    prog, ch.toComplete,
                    statusText,
                    ch.reward or 0
                ),
                icon        = icon,
                iconColor   = iconColor,
                progress    = percent,
                readOnly    = true,
                colorScheme = barColor,
                event       = (done and not claimed) and "Pug:client:ClaimChallenge" or nil,
                args        = { type = "daily", id = ch.id }
            })
        end

        if Config.Menu ~= "ox_lib" then
            table.insert(menu, {
                title = Translations.menu.back,
                icon  = "fa-solid fa-arrow-left",
                event = "Pug:client:OpenChallengesMenu"
            })
        end

        PugCreateMenu("challenges_daily", Translations.menu.challenges_daily, menu, "challenges_main")
    end)
end)



-- Weekly Challenges List
RegisterNetEvent('Pug:client:OpenWeeklyChallenges', function()
    Config.FrameworkFunctions.TriggerCallback('Pug:ServerCB:GetChallengeData', function(data)
        local menu = {}

        for _, ch in ipairs(data.weeklyChallenges or {}) do
            local prog = ch.completed or 0
            local done = prog >= ch.toComplete
            local claimed = ch.claimed or false

            local percent = math.floor((prog / ch.toComplete) * 100)
            if percent > 100 then percent = 100 end

            local barColor = GetProgressBarColor(percent, claimed)


            local statusText = claimed and "Claimed" or (done and "Completed" or "In Progress")
            local icon = claimed and "fa-regular fa-square-check" or (done and "fa-solid fa-square-check" or "fa-regular fa-square")
            local iconColor = claimed and "#FFD700" or (done and "#32cd32" or "#3270cd")

            table.insert(menu, {
                title       = ch.title,
                description = (Translations.menu.progress_status_reward):format(
                    prog, ch.toComplete,
                    statusText,
                    ch.reward or 0
                ),
                icon        = icon,
                iconColor   = iconColor,
                progress    = percent,
                readOnly    = true,
                colorScheme = barColor,
                event       = (done and not claimed) and "Pug:client:ClaimChallenge" or nil,
                args        = { type = "weekly", id = ch.id }
            })
        end

        if Config.Menu ~= "ox_lib" then
            table.insert(menu, {
                title = Translations.menu.back,
                icon  = "fa-solid fa-arrow-left",
                event = "Pug:client:OpenChallengesMenu"
            })
        end

        PugCreateMenu("challenges_weekly", Translations.menu.challenges_weekly, menu, "challenges_main")
    end)
end)

RegisterNetEvent("Pug:client:ClaimChallenge", function(args)
    if not args or not args.type or not args.id then return end
    TriggerServerEvent("Pug:Server:ClaimChallengeReward", args.type, args.id)
    Wait(100)
    if args.type == "daily" then TriggerEvent("Pug:client:OpenDailyChallenges") else TriggerEvent("Pug:client:OpenWeeklyChallenges") end
end)




RegisterNetEvent("Pug:client:OpenLeaderboardStats", function()
    local menu = {
        {
            title = Translations.menu.fish_leaderboard,
            description = Translations.details.fish_leaderboard_desc,
            icon = "fa-solid fa-fish",
            arrow = true,
            iconColor = "#60a5fa",
            event = "Pug:client:ViewFishCaughtLeaderboard"
        },
        {
            title = Translations.menu.tournament_leaderboard,
            description = Translations.details.tournament_wins_desc,
            icon = "fa-solid fa-medal",
            arrow = true,
            iconColor = "#f59e0b",
            event = "Pug:client:ViewTournamentWinsLeaderboard"
        },
        {
            title = Translations.menu.rep_leaderboard,
            description = Translations.details.rep_leaderboard_desc,
            icon = "fa-solid fa-star",
            arrow = true,
            iconColor = "#10b981",
            event = "Pug:client:ViewFishingRepLeaderboard"
        },

    }

    if Config.Menu ~= "ox_lib" then
        table.insert(menu, {
            title = Translations.menu.back,
            icon  = "fa-solid fa-arrow-left",
            event = "Pug:client:OpenFishingMenu"
        })
    end

    PugCreateMenu("leaderboard_stats", Translations.menu.leaderboard_stats, menu, "fishing_menu")
end)

local function GetOrdinal(n)
    local suffixes = { "st", "nd", "rd" }
    local v = n % 100
    if v >= 11 and v <= 13 then return n .. "th" end
    return n .. (suffixes[n % 10] or "th")
end

RegisterNetEvent("Pug:client:ViewFishCaughtLeaderboard", function()
    Config.FrameworkFunctions.TriggerCallback("Pug:ServerCB:GetFishCaughtData", function(myData, leaderboard)
        local menu = {}

        table.insert(menu, {
            title = "You: " .. (myData.total or 0) .. " fish caught",
            description = Translations.details.view_breakdown,
            icon = "fa-solid fa-user-astronaut",
            iconColor = "#60a5fa",
            event = "Pug:client:ViewPersonalStats",
            readOnly = true
        })

        for i, entry in ipairs(leaderboard) do
            if i > 10 then break end

            local icon, color

            if i == 1 then
                icon = "fa-solid fa-crown"
                color = "#FFD700" -- gold
            elseif i == 2 then
                icon = "fa-solid fa-medal"
                color = "#C0C0C0" -- silver
            elseif i == 3 then
                icon = "fa-solid fa-award"
                color = "#CD7F32" -- bronze
            elseif i <= 5 then
                icon = "fa-solid fa-trophy"
                color = "#8a2be2" -- purple for top 5
            elseif i <= 10 then
                icon = "fa-solid fa-fish-fins"
                color = "#3b82f6" -- blue for top 10
            end

            table.insert(menu, {
                title = GetOrdinal(i) .. " " .. entry.name,
                description = Translations.details.total_fish .. entry.total,
                icon = icon,
                iconColor = color,
                readOnly = true
            })
        end

        if Config.Menu ~= "ox_lib" then
            table.insert(menu, {
                title = Translations.menu.back,
                icon  = "fa-solid fa-arrow-left",
                event = "Pug:client:OpenLeaderboardStats"
            })
        end

        PugCreateMenu("fish_leaderboard", Translations.menu.fish_leaderboard, menu, "leaderboard_stats")
    end)
end)

RegisterNetEvent("Pug:client:ViewTournamentWinsLeaderboard", function()
    Config.FrameworkFunctions.TriggerCallback("Pug:ServerCB:GetTournamentWinsLeaderboard", function(myWins, leaderboard)
        local menu = {}

        table.insert(menu, {
            title = "You: " .. (myWins or 0) .. Translations.details.tournament_wins,
            description = Translations.menu.torunament_you_have_won,
            icon = "fa-solid fa-user-astronaut",
            iconColor = "#f59e0b",
            readOnly = true
        })

        for i, entry in ipairs(leaderboard) do
            if i > 10 then break end

            table.insert(menu, {
                title = GetOrdinal(i) .. " " .. entry.name,
                description = Translations.details.total_wins .. entry.wins,
                icon = "fa-solid fa-trophy",
                iconColor = "#f59e0b",
                readOnly = true
            })
        end

        if Config.Menu ~= "ox_lib" then
            table.insert(menu, {
                title = Translations.menu.back,
                icon  = "fa-solid fa-arrow-left",
                event = "Pug:client:OpenLeaderboardStats"
            })
        end

        PugCreateMenu("tournament_leaderboard", Translations.menu.tournament_leaderboard, menu, "leaderboard_stats")
    end)
end)


RegisterNetEvent("Pug:client:ViewFishingRepLeaderboard", function()
    Config.FrameworkFunctions.TriggerCallback("Pug:ServerCB:GetFishingRepLeaderboard", function(myXP, leaderboard)
        local menu = {}

        table.insert(menu, {
            title = "You: " .. (myXP or 0) .. " XP",
            description = Translations.details.tota_fishing_xp,
            icon = "fa-solid fa-user-astronaut",
            iconColor = "#10b981",
            readOnly = true
        })

        for i, entry in ipairs(leaderboard) do
            if i > 10 then break end

            table.insert(menu, {
                title = GetOrdinal(i) .. " " .. entry.name,
                description = Translations.details.fishing_xp .. entry.rep,
                icon = "fa-solid fa-star",
                iconColor = "#10b981",
                readOnly = true
            })
        end

        if Config.Menu ~= "ox_lib" then
            table.insert(menu, {
                title = Translations.menu.back,
                icon  = "fa-solid fa-arrow-left",
                event = "Pug:client:OpenLeaderboardStats"
            })
        end

        PugCreateMenu("rep_leaderboard", Translations.menu.rep_leaderboard, menu, "leaderboard_stats")
    end)
end)

local function GetSkillCostText(skillName, currentTier)
    local nextTier = currentTier + 1
    local req = Config.FishingSkillUpgrades[skillName] and Config.FishingSkillUpgrades[skillName][nextTier]
    if not req then return "Max tier reached" end
    return ("Requires: %d Rep, $%d Cash"):format(req.rep, req.cash).." | (DOES NOT TAKE THE REP)"
end

RegisterNetEvent("Pug:client:OpenSkillsMenu", function()
    local menu = {
        {
            title = Translations.menu.skill_bite_speed,
            description = Translations.details.skill_bite_speed_desc,
            icon = "fa-solid fa-fish",
            iconColor = "#10b981",
            arrow = true,
            event = "Pug:client:OpenSkillBiteSpeed"
        },
        {
            title = Translations.menu.skill_rare_luck,
            description = Translations.details.skill_rare_luck_desc,
            icon = "fa-solid fa-star",
            iconColor = "#b3b910ff",
            arrow = true,
            event = "Pug:client:OpenSkillRareLuck"
        },
        {
            title = Translations.menu.skill_treasure_hunter,
            description = Translations.details.skill_treasure_hunter_desc,
            icon = "fa-solid fa-gem",
            iconColor = "#15b9faff",
            arrow = true,
            event = "Pug:client:OpenSkillTreasureHunter"
        }
    }

    if Config.Menu ~= "ox_lib" then
        table.insert(menu, {
            title = Translations.menu.back,
            icon  = "fa-solid fa-arrow-left",
            event = "Pug:client:OpenFishingMenu"
        })
    end

    PugCreateMenu("skills_menu", "Fishing Skills", menu, "fishing_menu")
end)

RegisterNetEvent("Pug:client:OpenSkillBiteSpeed", function()
    Config.FrameworkFunctions.TriggerCallback("Pug:ServerCB:GetFishingSkills", function(skills)
        local tier = skills["biteSpeed"] or 0
        local maxTier = 3

        local menu = {
            {
                title = ("Tier %d/%d"):format(tier, maxTier),
                description = GetSkillCostText("biteSpeed", tier),
                icon = "fa-solid fa-circle-up",
                iconColor = tier >= maxTier and "#FFD700" or "#1e90ff",
                disabled = tier >= maxTier,
                event = "Pug:client:UpgradeFishingSkill",
                args = "biteSpeed"
            }
        }

        if Config.Menu ~= "ox_lib" then
            table.insert(menu, {
                title = Translations.menu.back,
                icon = "fa-solid fa-arrow-left",
                event = "Pug:client:OpenSkillsMenu"
            })
        end

        PugCreateMenu("skill_bite_speed", "Bite Speed", menu, "skills_menu")
    end)
end)

RegisterNetEvent("Pug:client:OpenSkillRareLuck", function()
    Config.FrameworkFunctions.TriggerCallback("Pug:ServerCB:GetFishingSkills", function(skills)
        local tier = skills["rareChance"] or 0
        local maxTier = 3

        local menu = {
            {
                title = ("Tier %d/%d"):format(tier, maxTier),
                description = GetSkillCostText("rareChance", tier),
                icon = "fa-solid fa-circle-up",
                iconColor = tier >= maxTier and "#FFD700" or "#1e90ff",
                disabled = tier >= maxTier,
                event = "Pug:client:UpgradeFishingSkill",
                args = "rareChance"
            }
        }

        if Config.Menu ~= "ox_lib" then
            table.insert(menu, {
                title = Translations.menu.back,
                icon = "fa-solid fa-arrow-left",
                event = "Pug:client:OpenSkillsMenu"
            })
        end

        PugCreateMenu("skill_rare_luck", "Rare Fish Luck", menu, "skills_menu")
    end)
end)

RegisterNetEvent("Pug:client:OpenSkillTreasureHunter", function()
    Config.FrameworkFunctions.TriggerCallback("Pug:ServerCB:GetFishingSkills", function(skills)
        local tier = skills["treasureHunter"] or 0
        local maxTier = 3

        local menu = {
            {
                title = ("Tier %d/%d"):format(tier, maxTier),
                description = GetSkillCostText("treasureHunter", tier),
                icon = "fa-solid fa-circle-up",
                iconColor = tier >= maxTier and "#FFD700" or "#1e90ff",
                disabled = tier >= maxTier,
                event = "Pug:client:UpgradeFishingSkill",
                args = "treasureHunter"
            }
        }

        if Config.Menu ~= "ox_lib" then
            table.insert(menu, {
                title = Translations.menu.back,
                icon = "fa-solid fa-arrow-left",
                event = "Pug:client:OpenSkillsMenu"
            })
        end

        PugCreateMenu("skill_treasure_hunter", "Treasure Hunter", menu, "skills_menu")
    end)
end)

RegisterNetEvent("Pug:client:UpgradeFishingSkill", function(skillName)
    TriggerServerEvent("Pug:Server:UpgradeFishingSkill", skillName)
    Wait(150)
    if skillName == "biteSpeed" then TriggerEvent("Pug:client:OpenSkillBiteSpeed") end
    if skillName == "rareChance" then TriggerEvent("Pug:client:OpenSkillRareLuck") end
    if skillName == "treasureHunter" then TriggerEvent("Pug:client:OpenSkillTreasureHunter") end
end)

RegisterNetEvent("Pug:client:SetFishingSkills", function(newSkills)
    FishingSkills.biteSpeed = newSkills.biteSpeed or 0
    FishingSkills.rareChance = newSkills.rareChance or 0
    FishingSkills.treasureHunter = newSkills.treasureHunter or 0
end)
