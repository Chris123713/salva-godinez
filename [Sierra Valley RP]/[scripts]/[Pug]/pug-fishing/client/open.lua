local resource = GetCurrentResourceName()
local version = GetResourceMetadata(resource, 'version', 0)
print("Pug Fishing "..tostring(version))

local OpeningChest = false
local succededchestopen = false
FishingSkills = {
    biteSpeed = 0,
    rareChance = 0,
    treasureHunter = 0
}
token = 0

function PrintDebug(...)
    if not Config.Debug then return end

    local args = {...}
    for i, v in ipairs(args) do
        if type(v) == "table" then
            local ok, encoded = pcall(json.encode, v)
            args[i] = ok and encoded or "<table>"
        elseif type(v) ~= "string" then
            args[i] = tostring(v)
        end
    end

    local msg = table.concat(args, " ")

    local info = debug.getinfo(2, "Sl") or {}
    local lineNumber = info.currentline or 0
    local source = (info.source or ""):gsub("^@", "")

    local PrintMessage = string.format("^2PUG DEBUG: ^6%s ^0(^4%s:^0%d^0) (THIS IS JUST A PRINT, NOT AN ERROR)", msg, source, lineNumber)
    print(PrintMessage)
end

function GiveFishingRep(rep)
    return SendProtected("Pug:Server:GiveFishingRep", rep)
end


--Put your drawtext option here
function DrawTextOption(text)
	if Framework == "QBCore" then
		exports[Config.CoreName]:DrawText(text, 'left')
	else
		FWork.TextUI(text, "error")
	end
end
function HideTextOption()
	if Framework == "QBCore" then
		exports[Config.CoreName]:HideText()
		Wait(1000)
	else
		FWork.HideUI()
	end
end

function LockInventory()
	local BusyType = "inv_busy"
	if GetResourceState("ox_inventory") == 'started' then
		BusyType = "invBusy"
	end
	if GetResourceState("tgiann-inventory") == 'started' then
		exports["tgiann-inventory"]:SetInventoryActive(true)
	else
		LocalPlayer.state:set(BusyType, true, true)
	end
end

function UnlockInventory()
	RemoveFishingRope()
	local BusyType = "inv_busy"
	if GetResourceState("ox_inventory") == 'started' then
		BusyType = "invBusy"
	end
	if GetResourceState("tgiann-inventory") == 'started' then
		exports["tgiann-inventory"]:SetInventoryActive(true)
	else
		LocalPlayer.state:set(BusyType, false, true)
	end
end

-- Change this to your notification script if needed
function FishingNotify(msg, type, length)
	if Framework == "ESX" then
		FWork.ShowNotification(tostring(msg))
	elseif Framework == "QBCore" then
    	FWork.Functions.Notify(tostring(msg), type, length)
	end
end

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
        Wait(1000)
		if Framework == "QBCore" then
			if Config.InventoryType == "ox_inventory" then
				exports.ox_inventory:displayMetadata({
					uses = "Durability",
					uses = "Durability",
				})
			end
		end
	end
end)

-- item lable text
local OXItems, OXCache = nil, {}
local function GetOxItemAndLable(key)
	key = type(key) == "string" and key or tostring(key)
	if OXCache[key] then return OXCache[key].image, OXCache[key].label end
	if not OXItems then OXItems = exports.ox_inventory:Items() end
	local data = OXItems and OXItems[key]
	if not data then
		local img, lbl = (key .. ".png"), key
		OXCache[key] = { image = img, label = lbl }
		return img, lbl
	end
	local img = (data.client and data.client.image) and tostring(data.client.image):gsub("^nui://ox_inventory/web/images/", "") or (key .. ".png")
	local lbl = data.label or key
	OXCache[key] = { image = img, label = lbl }
	return img, lbl
end
function ShowItemLable(I, Bool)
	if Config.InventoryType == "ox_inventory" then
		local image, label = GetOxItemAndLable(I)
		if Bool then return image, label end
		return label
	elseif Framework == "QBCore" then
		TempFwork = FWork
		if TempFwork.Shared.Items[I] then
			local image = TempFwork.Shared.Items[I].image or I
			local label = TempFwork.Shared.Items[I].label or I
			if Bool then return image, label end
			return label
		end
		return Bool and I, I or I
	elseif Config.InventoryType == "qs-inventory" then
		for item, data in pairs(exports['qs-inventory']:GetItemList()) do
			if tostring(item) == tostring(I) then
				local image = (data.image and tostring(data.image)) or (tostring(I) .. ".png")
				local label = (data.label and tostring(data.label)) or tostring(I)
				if Bool then return image, label end
				return label
			end
		end
		return Bool and I, I or I
	else
		return Bool and I, I or I
	end
end

function loadAnimDict(Anim)
	RequestAnimDict(Anim)
	while not HasAnimDictLoaded(Anim) do
		Wait(0)
	end
end

function GetPlayerItemCount(itemName)
    local count = 0
    local SharedItem

    if Config.InventoryType == "ox_inventory" then
        SharedItem = exports.ox_inventory:GetPlayerItems()
    elseif Config.InventoryType == "qs-inventory" then
        SharedItem = exports['qs-inventory']:getUserInventory()
    elseif Config.InventoryType == "codem-inventory" then
        SharedItem = exports['codem-inventory']:getUserInventory()
    elseif Config.InventoryType == "ak47_inventory" then
        SharedItem = exports['ak47_inventory']:GetPlayerItems()
    elseif Config.InventoryType == "tgiann-inventory" then
        SharedItem = exports["tgiann-inventory"]:GetPlayerItems()
    elseif fwaawff then
        SharedItem = exports.core_inventory:getInventory()
    elseif Framework == "QBCore" then
        SharedItem = FWork.Functions.GetPlayerData().items
    end

    if SharedItem then
        for _, item in pairs(SharedItem) do
            if tostring(item.name):lower() == tostring(itemName):lower() then
                local amount = item.amount or item.count or 0
                count = count + amount
            end
        end
    end
    return count
end


function PugCreateMenu(menuId, menuTitle, options, parentId)
    if Config.Menu == "lation_ui" then
        local lationOptions = {}
        for _, item in ipairs(options) do
            lationOptions[#lationOptions+1] = {
                title = item.title,
                description = item.description or "",
                icon = item.icon,
                iconColor = item.iconColor,
                disabled = item.disabled,
                readOnly = item.readOnly,
                progress = item.progress,
                image = item.image,
                metadata = item.metadata,
                event = item.event,
                args = item.args,
                keybind = item.keybind,
                menu = item.menu
            }
        end

        local data = {
            id = menuId,
            title = menuTitle,
            subtitle = parentId and "" or nil,
            options = lationOptions
        }

        if parentId then
            data.menu = parentId
        end

        exports.lation_ui:registerMenu(data)
        exports.lation_ui:showMenu(menuId)
    elseif Config.Menu == "ox_lib" then
        local oxOptions = {}
        for _, item in ipairs(options) do
            oxOptions[#oxOptions+1] = {
                title = item.title,
                description = item.description or "",
                icon = item.icon,
                event = item.event,
                image = item.image,
                iconColor = item.iconColor,
                disabled = item.disabled,
                progress = item.progress,
                colorScheme = item.colorScheme,
                arrow = item.arrow,
                args = item.args,
            }
        end

        local data = {
            id = menuId,
            title = menuTitle,
            options = oxOptions
        }

        if parentId then
            data.menu = parentId
        end

        lib.registerContext(data)
        lib.showContext(menuId)
    else
        local qbOptions = {}
        for _, item in ipairs(options) do
            qbOptions[#qbOptions+1] = {
                header = item.title,
                txt = item.description or "",
                icon = item.icon,
                image = item.image,
                iconColor = item.iconColor,
                disabled = item.disabled,
                progress = item.progress,
                params = {
                    event = item.event,
                    args = item.args
                }
            }
        end

        exports[Config.Menu]:openMenu(qbOptions)
    end
end


function PugInputDialog(header, fields)
    if Config.Input == "ox_lib" or Config.Input == "kl_lib" then
        local Input = lib.inputDialog(header, fields)
        if Input then return Input end
    else
        local inputFields = {}
        for _, field in ipairs(fields) do
            table.insert(inputFields, {
                text = field.label,
                name = field.name,
                type = field.type,
                isRequired = field.isRequired or false
            })
        end
        local Input = exports[Config.Input]:ShowInput({
            header = header,
            submitText = "Submit",
            inputs = inputFields,
        })
        if Input then
            local result = {}
            for _, f in ipairs(fields) do
                table.insert(result, Input[f.name])
            end
            return result
        end
    end
    ClearPedTasksImmediately(PlayerPedId())
    FishingNotify(Translations.error.missing_input, "error")
    return false
end


function PugProgressBar(id, label, duration, data, onFinish, onCancel)
    local progressLabel = label or "Progress"
    local progressDuration = duration or 5000

    -- Set default fallbacks if `data` is nil or missing fields
    local disables = data and data.disables or {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }

    local anim = data and data.anim or {}
    local prop = data and data.prop or {}
    local propTwo = data and data.propTwo or {}

    if Framework == "QBCore" then
        FWork.Functions.Progressbar(id, progressLabel, progressDuration, false, true, disables, anim, prop, propTwo, function()
            ClearPedTasksImmediately(PlayerPedId())
            if onFinish then onFinish() end
        end, function()
            ClearPedTasksImmediately(PlayerPedId())
            if onCancel then onCancel() end
        end)

    elseif GetResourceState("17mov_Hud") == 'started' then
        local action = {
            duration = progressDuration,
            label = progressLabel,
            useWhileDead = false,
            canCancel = true,
            controlDisables = disables,
            animation = anim,
            prop = prop,
            propTwo = propTwo,
        }

        exports["17mov_Hud"]:StartProgress(action, function()
            -- onStart
        end, function()
            -- onTick
        end, function(wasCanceled)
            ClearPedTasksImmediately(PlayerPedId())
            if wasCanceled then
                if onCancel then onCancel() end
            else
                if onFinish then onFinish() end
            end
        end)

    elseif GetResourceState("ox_lib") == 'started' then
        if lib.progressBar({
            duration = progressDuration,
            label = progressLabel,
            useWhileDead = false,
            canCancel = true,
            disable = disables,
            anim = anim,
            prop = prop,
        }) then
            ClearPedTasksImmediately(PlayerPedId())
            if onFinish then onFinish() end
        else
            ClearPedTasksImmediately(PlayerPedId())
            if onCancel then onCancel() end
        end

    else
        -- fallback
        FWork.Progressbar(progressLabel, progressDuration, {
            FreezePlayer = true,
            onFinish = function()
                ClearPedTasksImmediately(PlayerPedId())
                if onFinish then onFinish() end
            end,
            onCancel = function()
                ClearPedTasksImmediately(PlayerPedId())
                if onCancel then onCancel() end
            end
        })
    end
end

function PugAddTargetToEntity(entity, data)
    if Config.Target == "ox_target" then
        for _, option in ipairs(data) do
            option.args = option.args or {}
            option.args.entity = entity
        end
        exports.ox_target:addLocalEntity(entity, data)
    else
        for _, option in ipairs(data) do
            option.action = function()
                local args = option.args or {}
                args.entity = entity
                TriggerEvent(option.event, args)
            end
        end
        exports[Config.Target]:AddTargetEntity(entity, {
            options = data,
            distance = data.distance or 2.0
        })
    end
end


function HasItem(items, amount)
	local DoesHasItem = "nothing"
	Config.FrameworkFunctions.TriggerCallback("Pug:server:GetPlayerHasItemFishing", function(HasItem)
		if HasItem then
			DoesHasItem = true
		else
			DoesHasItem = false
		end
	end, items, amount)
	while DoesHasItem == "nothing" do Wait(1) end
	return DoesHasItem
end

function SellFishAnim()
    PlayAnimation(PlayerPedId(), "anim@mp_fireworks", "place_firework_2_cylinder", {["flag"] = 49})
end
function LoadModel(model)
    if HasModelLoaded(model) then return end
	RequestModel(model)
	while not HasModelLoaded(model) do
		Wait(0)
	end
end

local camera = nil
function waitForContextMenu()
    local maxAttempts = 40
    local attemptInterval = 1
    local counter = 0

    while true do
        Wait(attemptInterval)
        SetEntityLocallyInvisible(PlayerPedId())
        if Config.Menu == "lation_ui" and not exports.lation_ui:getOpenMenu() or Config.Menu == "ox_lib" and not lib.getOpenContextMenu() then
            counter = counter + 1
            if counter >= maxAttempts then
				RemoveCamera()
                break
            end
        else
            counter = 0
        end
    end
end
function CreateCameraNPC(entity, offset)
    local offset = offset or {0.0,0.0,0.0}

	SetPedTalk(entity)
    PlayAmbientSpeech1(entity, 'GENERIC_HI', 'SPEECH_PARAMS_STANDARD')

	CreateThread(function()
		waitForContextMenu()
	end)

    if not DoesEntityExist(entity) then
        print("Entity does not exist.")
        return
    end

    local coords = GetOffsetFromEntityInWorldCoords(entity, offset[1], 1.35 + offset[1], 0.75 + offset[1])
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)

    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)
    SetCamCoord(cam, coords.x, coords.y, coords.z)
    SetCamRot(cam, 0.0, 0.0, GetEntityHeading(entity) - 180, 0)
    SetCamFov(cam, 60.0)
    camera = cam
end 

function CreateCameraCoord(coord, offset, rotation)
    if not coord or type(coord) ~= "table" then return end

    local offset = offset or {0.0, 0.0, 0.0}
    local rotation = rotation or {0.0, 0.0, 0.0}

    -- Apply heading rotation to offset
    local heading = coord[4] or 0.0
    local hRad = math.rad(heading)
    local ox, oy = offset[1] or 0.0, offset[2] or 0.0
    local rx = ox * math.cos(hRad) - oy * math.sin(hRad)
    local ry = ox * math.sin(hRad) + oy * math.cos(hRad)

    local camX = coord[1] + rx
    local camY = coord[2] + ry
    local camZ = coord[3] + (offset[3] or 0.0)

    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(cam, camX, camY, camZ)
    SetCamRot(cam, rotation[1], rotation[2], rotation[3], 2)
    SetCamFov(cam, 60.0)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)

    camera = cam
end
function RemoveCamera()
    if camera then
        -- Transition back to gameplay cam smoothly
        local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        local playerPed = PlayerPedId()
        local coords = GetGameplayCamCoord()
        local rot = GetGameplayCamRot(2)

        SetCamCoord(cam, coords.x, coords.y, coords.z)
        SetCamRot(cam, rot.x, rot.y, rot.z, 2)
        SetCamFov(cam, GetGameplayCamFov())
        SetCamActive(cam, true)

        SetCamActiveWithInterp(cam, camera, 800, 1, 1) -- smooth transition
        CreateThread(function()
            Wait(800)
            RenderScriptCams(false, true, 500, true, true)
            DestroyCam(camera, true)
            DestroyCam(cam, true)
            camera = nil
        end)
    end
end


RegisterNetEvent("Pug:client:TournamentHasBecomeAvilable", function()
    local phoneEvent = {
        sender = 'Fisher Joe',
        subject = "Fishing Tournament",
        message = 'Come on down to test your fishing skills in this tournament!'
    }

    if GetResourceState("qs-smartphone") == 'started' or GetResourceState("qs-smartphone-pro") == 'started' then
        TriggerServerEvent('qs-smartphone:server:sendNewMail', phoneEvent)
        TriggerServerEvent('phone:sendNewMail', phoneEvent)
    elseif Config.Phone == "okokPhone" then
        phoneEvent.button = {}
        TriggerServerEvent("qb-phone:server:sendNewMail", phoneEvent)
    elseif Config.Phone == "qb-phone" then
        TriggerServerEvent('qb-phone:server:sendNewMail', phoneEvent)
    elseif Config.Phone == "lb-phone" then
        TriggerServerEvent("Pug:Server:SendLbPhoneMailFishing", phoneEvent.subject, phoneEvent.message)
    elseif Config.Phone == "jpr-phonesystem" then
        phoneEvent.event = {}
        TriggerServerEvent('jpr-phonesystem:server:sendEmail', phoneEvent)
    elseif Config.Phone == "roadphone" then
        exports['roadphone']:sendMail(phoneEvent)
    elseif GetResourceState("gksphone") == 'started' then
        phoneEvent.image = '/html/img/icons/mail.png'
        phoneEvent.button = {}
        exports["gksphone"]:SendNewMail(phoneEvent)
    elseif GetResourceState("yseries") == 'started' then
        TriggerServerEvent("Pug:Server:SendyseriesMailFishing", phoneEvent.subject, phoneEvent.message)
    else
        TriggerServerEvent('qb-phone:server:sendNewMail', phoneEvent)
    end
end)

CreateThread(function()
    -- GEMS SELLING
	GemsFisherMan = Config.GemsBuyingPed
    LoadModel(GemsFisherMan)
    GemsBuyer = CreatePed(2, GemsFisherMan, vector4(Config.GemsBuyingPedLoc.x, Config.GemsBuyingPedLoc.y, Config.GemsBuyingPedLoc.z-1, Config.GemsBuyingPedLoc.w), false, false)
    SetPedFleeAttributes(GemsBuyer, 0, 0)
    SetPedDiesWhenInjured(GemsBuyer, false)
    SetPedKeepTask(GemsBuyer, true)
    SetBlockingOfNonTemporaryEvents(GemsBuyer, true)
    SetEntityInvincible(GemsBuyer, true)
    FreezeEntityPosition(GemsBuyer, true)
	-- Gems buyer
	PugAddTargetToEntity(GemsBuyer, {
		{
			name    = "gemsguy",
			type    = "client",
			event   = "Pug:client:SellFishingGemsMenu",
			icon    = "fas fa-user-check",
			label   = Translations.menu.sell_gems,
            args = { entity = GemsBuyer},
			distance = 2.0,
		},
	})
    if Config.GemsBuyerBlip.enabled then
        local blip = AddBlipForCoord(Config.GemsBuyingPedLoc.x, Config.GemsBuyingPedLoc.y, Config.GemsBuyingPedLoc.z)
        SetBlipSprite(blip, Config.GemsBuyerBlip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.GemsBuyerBlip.scale)
        SetBlipColour(blip, Config.GemsBuyerBlip.color)
        SetBlipAsShortRange(blip, Config.GemsBuyerBlip.shortRange)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.GemsBuyerBlip.label)
        EndTextCommandSetBlipName(blip)
    end

    -------------------------

    -- CRAB SELLING
    CrabFisherMan = Config.CrabBuyingPed
    LoadModel(CrabFisherMan)
    CrabBuyer = CreatePed(2, CrabFisherMan, vector4(Config.CrabBuyingPedLoc.x, Config.CrabBuyingPedLoc.y, Config.CrabBuyingPedLoc.z-1, Config.CrabBuyingPedLoc.w), false, false)
    SetPedFleeAttributes(CrabBuyer, 0, 0)
    SetPedDiesWhenInjured(CrabBuyer, false)
    SetPedKeepTask(CrabBuyer, true)
    SetBlockingOfNonTemporaryEvents(CrabBuyer, true)
    SetEntityInvincible(CrabBuyer, true)
    FreezeEntityPosition(CrabBuyer, true)
    PugAddTargetToEntity(CrabBuyer, {
        {
            name    = "crabguy",
            type    = "client",
            event   = "Pug:client:SellFishingCrabsMenu",
            icon    = "fas fa-user-check",
            label   = Translations.menu.sell_crabs,
            args = { entity = CrabBuyer},
            distance = 2.0,
        },
    })
    if Config.CrabBuyerBlip.enabled then
        local blip = AddBlipForCoord(Config.CrabBuyingPedLoc.x, Config.CrabBuyingPedLoc.y, Config.CrabBuyingPedLoc.z)
        SetBlipSprite(blip, Config.CrabBuyerBlip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.CrabBuyerBlip.scale)
        SetBlipColour(blip, Config.CrabBuyerBlip.color)
        SetBlipAsShortRange(blip, Config.CrabBuyerBlip.shortRange)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.CrabBuyerBlip.label)
        EndTextCommandSetBlipName(blip)
    end

    -------------------------

    -- MAIN FISHING HUB LOCATIONS
    local LifeGuardBlips = {}
    if Config.FishingStationBlip.enabled then
        for _, data in pairs(Config.LifeGuardLocations) do
            local coord = vector3(data.LifeGuard.x, data.LifeGuard.y, data.LifeGuard.z)
            local blip = AddBlipForCoord(coord)
            SetBlipSprite(blip, Config.FishingStationBlip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.FishingStationBlip.scale)
            SetBlipColour(blip, Config.FishingStationBlip.color)
            SetBlipAsShortRange(blip, Config.FishingStationBlip.shortRange)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.FishingStationBlip.label)
            EndTextCommandSetBlipName(blip)
            table.insert(LifeGuardBlips, blip)
        end
    end
end)

local SpawnedFishermen = {}
local WavedAt = {}
CreateThread(function()
    while true do
        Wait(1000)
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        for locationName, data in pairs(Config.LifeGuardLocations) do
            local pedData = data.LifeGuard
            local dist = #(pos - vector3(pedData.x, pedData.y, pedData.z))

            if dist <= 50.0 and not SpawnedFishermen[locationName] then
                LoadModel(Config.MainFisherManPed)
                local fisherman = CreatePed(2, Config.MainFisherManPed, pedData.x, pedData.y, pedData.z - 1, pedData.w, false, false)
                SetPedFleeAttributes(fisherman, 0, 0)
                SetPedDiesWhenInjured(fisherman, false)
                SetPedKeepTask(fisherman, true)
                SetBlockingOfNonTemporaryEvents(fisherman, true)
                SetEntityInvincible(fisherman, true)
                FreezeEntityPosition(fisherman, true)

                PugAddTargetToEntity(fisherman, {
                    {
                        name = "MainFisherMan",
                        type = "client",
                        event = "Pug:client:OpenFishingMenu",
                        icon = "fas fa-fish",
                        label = Translations.details.MainFisherMan,
                        args = { entity = fisherman },
                        distance = 5.0,
                    },
                })

                SpawnedFishermen[locationName] = fisherman
                WavedAt[locationName] = false
            end

            if dist <= 4.0 and SpawnedFishermen[locationName] and not WavedAt[locationName] then
                WavedAt[locationName] = true
                SetPedTalk(SpawnedFishermen[locationName])
                PlayAmbientSpeech1(SpawnedFishermen[locationName], 'GENERIC_HI', 'SPEECH_PARAMS_STANDARD')
            elseif dist > 4.0 and WavedAt[locationName] then
                WavedAt[locationName] = false
            end

            if dist > 60.0 and SpawnedFishermen[locationName] then
                DeleteEntity(SpawnedFishermen[locationName])
                SpawnedFishermen[locationName] = nil
                WavedAt[locationName] = nil
            end
        end
    end
end)


RegisterNetEvent("Pug:Fishing:ReloadSkin", function()
	if Config.LockInventory then
		UnlockInventory()
	end
	for k, v in pairs(GetGamePool('CObject')) do
		if IsEntityAttachedToEntity(PlayerPedId(), v) then
			SetEntityAsMissionEntity(v, true, true)
			DeleteObject(v)
			DeleteEntity(v)
		end
	end
    if GetResourceState('pug-sling') == 'started' then
	    TriggerEvent("Pug:ReloadGuns:sling")
    end
end)

RegisterNetEvent("Pug:client:FishingNotify", function(msg, type, length)
	FishingNotify(msg, type, length)
end)

RegisterNUICallback('RequestConfig', function(data, cb)
    cb(Config)
end)

RegisterNetEvent("Pug:client:UseAnchor", function()
    local plyPed = PlayerPedId()
    local plyCoords = GetEntityCoords(plyPed)

    if IsPedInAnyBoat(plyPed) then
        local boat = GetVehiclePedIsIn(plyPed, false)

        if GetEntitySpeed(boat) >= 5 then
            FishingNotify(Translations.error.too_fast_boat, 'error')
            return
        end

        if IsBoatAnchoredAndFrozen(boat) then
            SetBoatAnchor(boat, false)
            SetBoatFrozenWhenAnchored(boat, false)

            FishingNotify(Translations.success.anchor_detached, 'success')  
        else
            SetBoatAnchor(boat, true)
            SetBoatFrozenWhenAnchored(boat, true)

            FishingNotify(Translations.success.anchor_attached, 'success')        
        end
    else
        FishingNotify(Translations.error.not_in_boat, 'error') 
    end
end, false)

RegisterNetEvent("Pug:client:PlayPickupAnim", function()
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return end

    RequestAnimDict("random@domestic")
    while not HasAnimDictLoaded("random@domestic") do
        Wait(0)
    end

    TaskPlayAnim(ped, "random@domestic", "pickup_low", 8.0, -8.0, -1, 0, 0, false, false, false)
end)

RegisterNetEvent('Pug:client:FishingEatFish', function(Item)
    local ped = PlayerPedId()

    local dict = "mp_player_inteat@burger"
    local anim = "mp_player_int_eat_burger_fp"
    local propModel = `prop_cs_burger_01`
    local bone = 18905
    local pos = vec3(0.12, 0.028, 0.001)
    local rot = vec3(10.0, 175.0, 0.0)

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end

    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 49, 0, false, false, false)

    local ProgressBarText = "Eating Fish"
    if Item == "cookedcrab" then ProgressBarText = "Eating Crab" end
    PugProgressBar("consume_item", ProgressBarText, 5000, {
        disables = {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        },
        anim = {}
    }, function() -- Done
        if HasItem(tostring(Item), 1) then
            PugFishToggleItem(false, Item)
            StopAnimTask(PlayerPedId(), AnimDict, AnimAction, 1.0)
            if Framework == "QBCore" then
                local IncreaseHunger = Item == "cookedfish" and math.random(5,15) or math.random(25,50)
                local IncreaseThirst = Item == "cookedfish" and math.random(5,15) or math.random(25,50)
                SendProtected("Pug:Server:SetUpdateMetaDataFishing", "hunger", FWork.Functions.GetPlayerData().metadata["hunger"] + IncreaseHunger)
                SendProtected("Pug:Server:SetUpdateMetaDataFishing", "thirst", FWork.Functions.GetPlayerData().metadata["thirst"] + IncreaseThirst)
            end
        end

    end, function() -- Cancel

    end)
end)



function GetGroundHash(Coords)
    local Position = Coords
    local num = StartShapeTestCapsule(Position.x, Position.y, Position.z + 4, Position.x, Position.y, Position.z - 2.0, 2, 1, 0, 7)
    local Arg1, Arg2, Arg3, Arg4, Arg5 = GetShapeTestResultEx(num)
    return Arg5
end
local function IsGroundHash(Hash)
    if Hash == -1286696947 or 
    Hash == -1885547121 or 
    Hash == 223086562 or 
    Hash == -461750719 or 
    Hash == 1333033863 or 
    Hash == 510490462 or 
    Hash == 2128369009 or 
    Hash == 1913209870 or 
    Hash == -1942898710 or 
    Hash == -840216541 or 
    Hash == 765206029 then
        return true
    else
        return false
    end
end
local UsingShovel
local function FinishDiggingDirtReward()
    return SendProtected("Pug:server:FinishThisBait")
end
RegisterNetEvent("Pug:client:DigDirtWithTrowllFishing", function()
	if UsingShovel then return end
    local PlyCoords = GetEntityCoords(PlayerPedId())
    -- print(GetGroundHash(PlyCoords), "Ground Hash")
    local Hash = GetGroundHash(PlyCoords)
    if IsGroundHash(Hash) then
        local ped = PlayerPedId()

		-- VERY GOOD SHOVEL ANIMATION
		-- RequestAnimDict("random@burial")
		-- while not HasAnimDictLoaded("random@burial") do Wait(0) end

		-- local shovel = CreateObject(GetHashKey("prop_tool_shovel"), 0.0, 0.0, 0.0, true, true, false)
		-- AttachEntityToEntity(shovel, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.24, 0.0, 0.0, 0.0, true, true, false, true, 2, true)

		-- local dirt = CreateObject(GetHashKey("prop_ld_shovel_dirt"), 0.0, 0.0, 0.0, true, true, false)
		-- AttachEntityToEntity(dirt, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.24, 0.0, 0.0, 0.0, true, true, false, true, 2, true)

		-- TaskPlayAnim(ped, "random@burial", "a_burial", 8.0, -8.0, -1, 1, 0, false, false, false)

        if math.random(1,10) == 1 then
            PugFishToggleItem(false, "fishingshovel")
        end

		TaskStartScenarioInPlace(ped, "world_human_gardener_plant", 0, true)

		UsingShovel = true
		PugProgressBar("use-trowl", "Looking for worms...", Config.TrowlProgressBarTime * 1000, {
            disables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            anim = {}
        }, function() -- Done
			UsingShovel = false
			if DoesEntityExist(shovel) then DeleteEntity(shovel) end
			if DoesEntityExist(dirt) then DeleteEntity(dirt) end
			ClearPedTasks(PlayerPedId())
			FinishDiggingDirtReward()
        end, function() -- Cancel
			UsingShovel = false
            ClearPedTasks(PlayerPedId())
        end)
    else
        FishingNotify(Translations.error.no_dirt, 'error') 
    end
end)

function BookEmote()
    if not DoesEntityExist(TabletProp) then
        local PlayerPed =  PlayerPedId()
        local PlayerCoords = GetEntityCoords(PlayerPed)
        loadAnimDict("amb@code_human_in_bus_passenger_idles@female@tablet@idle_a")
        TaskPlayAnim(PlayerPed, 'amb@code_human_in_bus_passenger_idles@female@tablet@idle_a', 'idle_a', 2.0, 2.0, -1, 51, 0, false, false, false)
        TabletProp = CreateObject(GetHashKey("v_ilev_mp_bedsidebook"), PlayerCoords.x, PlayerCoords.y, PlayerCoords.z,  true,  true, true)
        AttachEntityToEntity(TabletProp, PlayerPed, GetPedBoneIndex(PlayerPed, 28422), -0.05, 0.0, 0.0, 90.0, 90.0, 190.0, true, true, false, true, 1, true)
    end
end

function StopBookEmote()
    ClearPedTasks(PlayerPedId())
    if DoesEntityExist(TabletProp) then
        TriggerEvent("FullyDeleteFishingEntity", TabletProp)
    end
end


RegisterNetEvent("Pug:client:OpenFishingLog", function()
    BookEmote()
    Config.FrameworkFunctions.TriggerCallback('Pug:ServerCB:GetFishLogbookData', function(fishData)
        SendNUIMessage({
            action = "openFishLogbook",
            fishData = fishData
        })
        SetNuiFocus(true, true)
    end)
end)

-- Handle closing the logbook
RegisterNUICallback('closeFishLogbook', function(data, cb)
    SetNuiFocus(false, false)
    StopBookEmote()
    cb('ok')
end)



-- HOT ZONES
local hotspotBlip = nil
local zoneBlip = nil
local activeHotspot = nil
local hotspotRadius = 0.0
isInHotZone = false

RegisterNetEvent("Pug:client:CreateHotspotBlip", function(coords, radius)
    activeHotspot = coords
    hotspotRadius = radius

    if hotspotBlip then RemoveBlip(hotspotBlip) end
    if zoneBlip then RemoveBlip(zoneBlip) end

    zoneBlip = AddBlipForRadius(coords.x, coords.y, coords.z, radius)
    SetBlipRotation(zoneBlip, 1)
    SetBlipColour(zoneBlip, 6)
    SetBlipAlpha(zoneBlip, 150)

    hotspotBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(hotspotBlip, 436)
    SetBlipDisplay(hotspotBlip, 4)
    SetBlipScale(hotspotBlip, 0.7)
    SetBlipColour(hotspotBlip, 1)
    SetBlipAsShortRange(hotspotBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName("Fishing Hotspot")
    EndTextCommandSetBlipName(hotspotBlip)
end)

RegisterNetEvent("Pug:client:ClearHotspotBlip", function()
    if hotspotBlip then RemoveBlip(hotspotBlip) hotspotBlip = nil end
    if zoneBlip then RemoveBlip(zoneBlip) zoneBlip = nil end
    activeHotspot = nil
    isInHotZone = false
end)

CreateThread(function()
    while true do
        if activeHotspot then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local dist = #(pos - activeHotspot)
            local inZoneNow = dist <= hotspotRadius

            if inZoneNow ~= isInHotZone then
                isInHotZone = inZoneNow
            end
        else
            isInHotZone = false
        end
        Wait(1500)
    end
end)


