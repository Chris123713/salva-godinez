print'Pug Business Creator 2.5.3'

---------- [Functions] ----------
-- Change this to your notification script if needed
function BusinessNotify(msg, type, length)
	if Framework == "ESX" then
		FWork.ShowNotification(tostring(msg))
	elseif Framework == "QBCore" then
    	FWork.Functions.Notify(tostring(msg), type, length)
	end
end
local TempFwork
local LastTempFworkCheck = 0

local function GetTempFworkForCreatedItems()
	if TempFwork and (GetGameTimer() - LastTempFworkCheck) < 10000 then
		return TempFwork
	end

	local CallbackFinished = false
	Config.FrameworkFunctions.TriggerCallback("Pug:serverCB:GetTempFwork", function(FWork2)
		TempFwork = FWork2
		LastTempFworkCheck = GetGameTimer()
		CallbackFinished = true
	end)

	while not CallbackFinished do Wait(1) end
	return TempFwork
end

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
function GetItemsInformation(I, Bool)
	if Config.InventoryType == "ox_inventory" then
		local image, label = GetOxItemAndLable(I)
		if Bool then return image, label end
		return label
	elseif Framework == "QBCore" then
		TempFwork = GetTempFworkForCreatedItems()
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

function HasItem(items, amount)
	local Player = nil
	if Framework == "QBCore" then
		local DoesHasItem = "nothing"
		Config.FrameworkFunctions.TriggerCallback("Pug:serverESX:GetItemQBCoreBusinessCreator", function(HasItem)
			if HasItem then
				DoesHasItem = true
			else
				DoesHasItem = false
			end
		end, items, amount)
		while DoesHasItem == "nothing" do Wait(1) end
		return DoesHasItem
	else
		local DoesHasItem = "nothing"
		Config.FrameworkFunctions.TriggerCallback("Pug:serverESX:GetItemESXBusinessCreator", function(HasItem)
			if HasItem then
				DoesHasItem = true
			else
				DoesHasItem = false
			end
		end, items, amount)
		while DoesHasItem == "nothing" do Wait(1) end
		return DoesHasItem
	end
end

RegisterNetEvent('Pug:client:ConsumeItem', function(ItemInfo)
	local BarText = "Using "
	local AnimDict, AnimAction

	if Config.ItemconsumerAnimation[ItemInfo.Animation] then
		AnimDict = Config.ItemconsumerAnimation[ItemInfo.Animation].AnimDict
		AnimAction = Config.ItemconsumerAnimation[ItemInfo.Animation].AnimAction

		loadAnimDict(AnimDict)
		PlayAnimation(AnimDict, AnimAction)

	end

	BusinessToggleItem(false, ItemInfo.Item, 1)

	FWork.Functions.Progressbar("consume_item", BarText..ItemInfo.Label.."..", 5000, false, false, {
		disableMovement = false,
		disableCarMovement = false,
		disableMouse = false,
		disableCombat = false,
	}, {}, {}, {}, function() -- Done
		StopAnimTask(PlayerPedId(), AnimDict, AnimAction, 1.0)

		-- Update player metadata for each type based on the item properties
		if ItemInfo.Increase then
			TriggerServerEvent("Pug:Server:SetUpdateMetaDataBusiness", "hunger", FWork.Functions.GetPlayerData().metadata["hunger"] + ItemInfo.Increase)
		end
		if ItemInfo.IncreaseWater then
			TriggerServerEvent("Pug:Server:SetUpdateMetaDataBusiness", "thirst", FWork.Functions.GetPlayerData().metadata["thirst"] + ItemInfo.IncreaseWater)
		end
		if ItemInfo.IncreaseStress then
			TriggerServerEvent('hud:server:RelieveStress', ItemInfo.IncreaseStress)
		end
		if ItemInfo.IncreaseHealth then
			SetEntityHealth(GetEntityHealth(PlayerPedId()) + tonumber(ItemInfo.IncreaseHealth))
		end
		if ItemInfo.IncreaseArmor then
			SetPedArmour(PlayerPedId(), GetPedArmour(PlayerPedId()) + tonumber(ItemInfo.IncreaseArmor))
			TriggerServerEvent("Pug:Server:SetUpdateMetaDataBusiness", "armor", FWork.Functions.GetPlayerData().metadata["armor"] + ItemInfo.IncreaseArmor)
		end

		ReloadSkin()
	end, function()
		-- BusinessToggleItem(true, ItemInfo.Item, 1)
		-- StopAnimTask(PlayerPedId(), AnimDict, AnimAction, 1.0)
		-- ReloadSkin()
		-- BusinessNotify(Config.LangT["Canceled"], 'error')
	end)
end)




---------- [ESX SOCIETY COMPATIBILITY] ----------
RegisterNetEvent("Pug:esx_society:depositMoney", function(BillerJob, BusinessCommission)
	TriggerServerEvent('esx_society:depositMoney', BillerJob, BusinessCommission)
end)
--------------------------------------------------