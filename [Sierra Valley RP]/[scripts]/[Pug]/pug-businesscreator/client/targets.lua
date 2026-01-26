local RegisterTargets = {}
local TrashCanTargets = {}
local TrayTargets = {}
local StorageTargets = {}
local SeatsTargets = {}
local DutyTargets = {}
local BossMenuTargets = {}
local LockerTargets = {}
local CookStationTargets = {}
local BlipIconDatas = {}
local BusinesBlips = {}
local AnimationTargets = {}
local PropPlacements = {}
local WhiteboardTexture = {}
local ZoneLocations = {}
local PedPlacements = {} 
local SupplyTargets = {}
local ItemsTargets = {}
local GarageTargets = {}
local ClothingTargets = {}
local StockingTargets = {}
local ElevatorTargets = {}
local ApplicationTargets = {}
local MenuimageTargets = {}

---------- [FUNCTIONS] ----------
local function CreateBlip(name, blip, color, coords, Scale, ThisJob)
    local x = coords.x
	local y = coords.y
	local z = coords.z
	if DoesBlipExist(BusinesBlips[ThisJob]) then RemoveBlip(BusinesBlips[ThisJob]) BusinesBlips[ThisJob] = nil Wait(100) end
    BusinesBlips[ThisJob] = AddBlipForCoord(x, y, z)
    SetBlipSprite(BusinesBlips[ThisJob], tonumber(blip))
    SetBlipDisplay(BusinesBlips[ThisJob], 2)
    SetBlipScale(BusinesBlips[ThisJob], tonumber(Scale))
    SetBlipColour(BusinesBlips[ThisJob], tonumber(color))
    SetBlipAsShortRange(BusinesBlips[ThisJob], Config.ShowBlipsOnMiniMapOnlyShortRange)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(BusinesBlips[ThisJob])
end
local function IsPlayerJob(JobName)
	if JobName == "criminal" then
		return true
	else
		local PlayerJob = Config.FrameworkFunctions.GetPlayer(true, false, true).PlayerData.job.name
		local Gang = " "
		if Framework == "QBCore" then
			Gang = FWork.Functions.GetPlayerData().gang.name
		end
		return PlayerJob == JobName or Gang == JobName
	end
end
function PlayAnimation(AnimDict, AnimAction, Entity)
	local Found
	for k, v in pairs(Config.Animations) do
		if Config.Animations[k].AnimDict == AnimDict and Config.Animations[k].AnimAction == AnimAction then
			TriggerEvent("Pug:client:DoBusinessAnimation", k, Entity or PlayerPedId())
			Found = true
			break
		end
	end
	if not Found then
		for k, v in pairs(Config.ItemconsumerAnimation) do
			if Config.ItemconsumerAnimation[k].AnimDict == AnimDict and Config.ItemconsumerAnimation[k].AnimAction == AnimAction then
				DestroyAllProps()
				local MovementType = 51
				local AttachWait = -1
				local AnimationDuration = -1
				if Config.ItemconsumerAnimation[k].AnimationOptions then
					if Config.ItemconsumerAnimation[k].AnimationOptions.Prop then
						local PropName =  Config.ItemconsumerAnimation[k].AnimationOptions.Prop
						local PropBone =  Config.ItemconsumerAnimation[k].AnimationOptions.PropBone
						local SecondPropEmote
						PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6 = table.unpack(Config.ItemconsumerAnimation[k].AnimationOptions.PropPlacement)
						if Config.ItemconsumerAnimation[k].AnimationOptions.SecondProp then
							SecondPropName = Config.ItemconsumerAnimation[k].AnimationOptions.SecondProp
							SecondPropBone = Config.ItemconsumerAnimation[k].AnimationOptions.SecondPropBone
							SecondPropPl1, SecondPropPl2, SecondPropPl3, SecondPropPl4, SecondPropPl5, SecondPropPl6 = table.unpack(Config.ItemconsumerAnimation[k].AnimationOptions.SecondPropPlacement)
							SecondPropEmote = true
						else
							SecondPropEmote = false
						end
						if Config.ItemconsumerAnimation[k].AnimationOptions.EmoteDuration then 
							AnimationDuration = Config.ItemconsumerAnimation[k].AnimationOptions.EmoteDuration
							AttachWait = Config.ItemconsumerAnimation[k].AnimationOptions.EmoteDuration
						end
						Wait(AttachWait)
						AddPropToPlayer(PropName, PropBone, PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6, Entity or PlayerPedId())
						if SecondPropEmote then
							AddPropToPlayer(SecondPropName, SecondPropBone, SecondPropPl1, SecondPropPl2, SecondPropPl3, SecondPropPl4, SecondPropPl5, SecondPropPl6, Entity or PlayerPedId())
						end
					end
				end
				TaskPlayAnim(Entity or PlayerPedId(), Config.ItemconsumerAnimation[k].AnimDict, Config.ItemconsumerAnimation[k].AnimAction, 2.0, 2.0, AnimationDuration, MovementType, 1.0, 0, 0, 0)
				break
			end
		end
	end
end
------------------------------

---------- [CASH REGISTERS] ----------
RegisterNetEvent("Pug:client:CreateAllTargetsregisters", function(Data, Bool)
	local ThisJob = Data["job"]
	for k, v in pairs(Data) do
		if Config.Target == "ox_target" then
			if tostring(k) == "registers" then
				local TableToRun = RegisterTargets
				for u, i in pairs(TableToRun) do
					local TargetName = u
					local ActualTargetId = i.id
					if RegisterTargets[TargetName] then
						if i.job == ThisJob then
							exports.ox_target:removeZone(ActualTargetId)
							RegisterTargets[TargetName] = nil
						end
					end
				end
			end
		else
			if tostring(k) == "registers" then
				local TableToRun = RegisterTargets
				if Bool then
					TableToRun = json.decode(Data["registers"])
				end
				for u, _ in pairs(TableToRun) do
					local TargetName = ThisJob..u..k
					exports[Config.Target]:RemoveZone(TargetName)
				end
			end
		end
	end
	for k, v in pairs(Data) do
		if tostring(k) == "registers" then
			for u, i in pairs(json.decode(Data["registers"])) do
				local TargetName = ThisJob..u..k
				local Info = i
				if Config.Target == "ox_target" then
					local Data = {
						Info = Info,
					}
					RegisterTargets[TargetName] = exports.ox_target:addSphereZone({
						coords = vector3(Info.Target.x,Info.Target.y,Info.Target.z),
						radius = 0.3,
						debug = Config.Debug,
						options = {
							{
								name= TargetName,
								type = "client",
								event = "Pug:Client:DoBusinessRegisteranLogic",
								args = Data,
								icon = "fa-solid fa-print",
								label = Config.LangT["ChargeCustomer"],
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								distance = 2.0
							}
						}
					})
					RegisterTargets[TargetName] = {
						job = ThisJob,
						id = RegisterTargets[TargetName]
					}
				else
					RegisterTargets[u] = v
					exports[Config.Target]:AddBoxZone(TargetName, vector3(Info.Target.x,Info.Target.y,Info.Target.z), 0.4, 0.4, {
						name=TargetName,
						heading=35,
						debugPoly = Config.Debug,
						minZ= Info.Target.z-0.3,
						maxZ= Info.Target.z+0.3,
					}, {
						options = {
							{
								icon = "fa-solid fa-print",
								label = Config.LangT["ChargeCustomer"],
								event = " ",
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								action = function()
									local Data = {
										args = {
											Info = Info,
										}
									}
									TriggerEvent("Pug:Client:DoBusinessRegisteranLogic", Data)
								end,
							},
						},
						distance = 2.0
					})
				end
			end
		end
	end
end)
RegisterNetEvent("Pug:Client:DoBusinessRegisteranLogic", function(Data)
	local Info = Data.args.Info
	if Info.PedCoords ~= nil then
		if Config.HavePlayersWalkToTarget then
			TaskGoStraightToCoord(PlayerPedId(), Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z, 1.0, 20000, 40000.0, 0.5)
			local Count = 0 
			while #(GetEntityCoords(PlayerPedId()) - vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z)) >= 1.1 do Count = Count + 1 Wait(500) if Count >= 4 then return end end
			TaskTurnPedToFaceCoord(PlayerPedId(), vector3(Info.Target.x, Info.Target.y, Info.Target.z))
			Wait(800)
		else
			SetEntityCoords(PlayerPedId(), vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z))
			SetEntityHeading(PlayerPedId(), Info.Heading)
		end
	end
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			loadAnimDict(Info.Animation.AnimDict)
			PlayAnimation(Info.Animation.AnimDict, Info.Animation.AnimAction)
		else
			ClearPedTasksImmediately(PlayerPedId())
			DestroyAllProps()
			TaskStartScenarioInPlace(PlayerPedId(), Info.Animation.AnimDict, 0, false)
		end
	end
	TriggerEvent("Pug:client:UseBusinessRegisters")
	Wait(3000)
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			StopAnimTask(PlayerPedId(), Info.Animation.AnimDict, Info.Animation.AnimAction, 1.0)
		else
			ClearPedTasksImmediately(PlayerPedId())
		end
	end
	DestroyAllProps()
end)
------------------------------

---------- [TRASH CANS] ----------
RegisterNetEvent("Pug:client:CreateAllTargetstrashcans", function(Data, Bool)
	local ThisJob = Data["job"]
	for k, v in pairs(Data) do
		if Config.Target == "ox_target" then
			if tostring(k) == "trashcans" then
				local TableToRun = TrashCanTargets
				for u, i in pairs(TableToRun) do
					local TargetName = u
					local ActualTargetId = i.id
					if TrashCanTargets[TargetName] then
						if i.job == ThisJob then
							exports.ox_target:removeZone(ActualTargetId)
							TrashCanTargets[TargetName] = nil
						end
					end
				end
			end
		else
			if tostring(k) == "trashcans" then
				local TableToRun = TrashCanTargets
				if Bool then
					TableToRun = json.decode(Data["trashcans"])
				end
				for u, _ in pairs(TableToRun) do
					local TargetName = ThisJob..u..k
					exports[Config.Target]:RemoveZone(TargetName)
				end
			end
		end
	end
	for k, v in pairs(Data) do
		if tostring(k) == "trashcans" then
			for u, i in pairs(json.decode(Data["trashcans"])) do
				local TargetName = ThisJob..u..k
				local Info = i
				if Config.Target == "ox_target" then
					local Data = {
						Info = Info,
						Name = TargetName,
					}
					TrashCanTargets[TargetName] = exports.ox_target:addSphereZone({
						coords = vector3(Info.Target.x,Info.Target.y,Info.Target.z),
						radius = 0.3,
						debug = Config.Debug,
						options = {
							{
								name= TargetName,
								type = "client",
								event = "Pug:Client:DoBusinessTrashcanLogic",
								args = Data,
								icon = "fa-solid fa-trash",
								label = Config.LangT["Trash"],
								distance = 2.0
							}
						}
					})
					TrashCanTargets[TargetName] = {
						job = ThisJob,
						id = TrashCanTargets[TargetName]
					}
				else
					TrashCanTargets[u] = v
					exports[Config.Target]:AddBoxZone(TargetName, vector3(Info.Target.x,Info.Target.y,Info.Target.z), 0.8, 0.8, {
						name=TargetName,
						heading=35,
						debugPoly = Config.Debug,
						minZ= Info.Target.z-0.3,
						maxZ= Info.Target.z+0.3,
					}, {
						options = {
							{
								icon = "fa-solid fa-trash",
								label = Config.LangT["Trash"],
								event = " ",
								action = function()
									local Data = {
										args = {
											Info = Info,
											Name = TargetName,
										}
									}
									TriggerEvent("Pug:Client:DoBusinessTrashcanLogic",Data)
								end,
							},
						},
						distance = 2.0
					})
				end
			end
		end
	end
end)
RegisterNetEvent("Pug:Client:DoBusinessTrashcanLogic", function(Data)
	local Info = Data.args.Info
	local TargetName = Data.args.Name
	if Info.PedCoords ~= nil then
		if Config.HavePlayersWalkToTarget then
			TaskGoStraightToCoord(PlayerPedId(), Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z, 1.0, 20000, 40000.0, 0.5)
			local Count = 0 
			while #(GetEntityCoords(PlayerPedId()) - vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z)) >= 1.1 do Count = Count + 1 Wait(500) if Count >= 4 then return end end
			TaskTurnPedToFaceCoord(PlayerPedId(), vector3(Info.Target.x, Info.Target.y, Info.Target.z))
			Wait(800)
		else
			SetEntityCoords(PlayerPedId(), vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z))
			SetEntityHeading(PlayerPedId(), Info.Heading)
		end
	end
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			loadAnimDict(Info.Animation.AnimDict)
			PlayAnimation(Info.Animation.AnimDict, Info.Animation.AnimAction)
		else
			ClearPedTasksImmediately(PlayerPedId())
			DestroyAllProps()
			TaskStartScenarioInPlace(PlayerPedId(), Info.Animation.AnimDict, 0, false)
		end
	end
	if Config.InventoryType == "qs-inventory" then
		exports['qs-inventory']:RegisterStash(TargetName, Config.BusinessStorageSlots, Config.BusinessStorageSize) 
	elseif Config.InventoryType == "ox_inventory" then
		TriggerServerEvent("Pug:server:BusinessOxTrashCanOpen", TargetName, Config.BusinessStorageSlots, Config.BusinessStorageSize)
	else
		if Config.UsingNewQBCore then
			TriggerServerEvent("Pug:Server:OpenStash", TargetName, Config.BusinessStorageSize, Config.BusinessStorageSlots)
		else
			TriggerServerEvent("inventory:server:OpenInventory", "stash", TargetName, {
				maxweight = Config.BusinessStorageSize,
				slots = Config.BusinessStorageSlots,
			})
			TriggerEvent("inventory:client:SetCurrentStash", TargetName)
		end
	end
	Wait(2000)
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			StopAnimTask(PlayerPedId(), Info.Animation.AnimDict, Info.Animation.AnimAction, 1.0)
		else
			ClearPedTasksImmediately(PlayerPedId())
		end
	end
	DestroyAllProps()
end)
------------------------------

---------- [TRAYS] ----------
RegisterNetEvent("Pug:client:CreateAllTargetstrays", function(Data, Bool)
	local ThisJob = Data["job"]
	for k, v in pairs(Data) do
		if Config.Target == "ox_target" then
			if tostring(k) == "trays" then
				-- COPY FROM HERE 
				local TableToRun = TrayTargets
				for u, i in pairs(TableToRun) do
					local TargetName = u
					local ActualTargetId = i.id
					if TrayTargets[TargetName] then
						if i.job == ThisJob then
							exports.ox_target:removeZone(ActualTargetId)
							TrayTargets[TargetName] = nil
						end
					end
				end
				-- TO HERE
			end
		else
			if tostring(k) == "trays" then
				local TableToRun = TrayTargets
				if Bool then
					TableToRun = json.decode(Data["trays"])
				end
				for u, _ in pairs(TableToRun) do
					local TargetName = ThisJob..u..k
					exports[Config.Target]:RemoveZone(TargetName)
				end
			end
		end
	end
	for k, v in pairs(Data) do
		if tostring(k) == "trays" then
			for u, i in pairs(json.decode(Data["trays"])) do
				local TargetName = ThisJob..u..k
				local Info = i
				if Config.Target == "ox_target" then
					local Data = {
						Info = Info,
						Name = TargetName,
					}
					TrayTargets[TargetName] = exports.ox_target:addSphereZone({
						coords = vector3(Info.Target.x,Info.Target.y,Info.Target.z),
						radius = 0.3,
						debug = Config.Debug,
						options = {
							{
								name= TargetName,
								type = "client",
								event = "Pug:Client:DoBusinessTrayLogic",
								args = Data,
								icon = "fa-solid fa-box",
								label = Config.LangT["Counter"],
								distance = 2.0
							}
						}
					})
					-- COPY FROM HERE 
					TrayTargets[TargetName] = {
						job = ThisJob,
						id = TrayTargets[TargetName]
					}
					-- TO HERE
				else
					TrayTargets[u] = v
					exports[Config.Target]:AddBoxZone(TargetName, vector3(Info.Target.x,Info.Target.y,Info.Target.z), 0.4, 0.4, {
						name=TargetName,
						heading=35,
						debugPoly = Config.Debug,
						minZ= Info.Target.z-0.3,
						maxZ= Info.Target.z+0.3,
					}, {
						options = {
							{
								icon = "fa-solid fa-box",
								label = Config.LangT["Counter"],
								event = " ",
								action = function()
									local Data = {
										args = {
											Info = Info,
											Name = TargetName,
										}
									}
									TriggerEvent("Pug:Client:DoBusinessTrayLogic",Data)
								end,
							},
						},
						distance = 2.0
					})
				end
			end
		end
	end
end)
RegisterNetEvent("Pug:Client:DoBusinessTrayLogic", function(Data)
	local TargetName = Data.args.Name
	if Config.InventoryType == "qs-inventory" then
		exports['qs-inventory']:RegisterStash(TargetName, Config.CounterTopTreySlots, Config.CounterTopTreySize) 
	elseif Config.InventoryType == "ox_inventory" then
		TriggerServerEvent("Pug:server:BusinessOxStashOpen", TargetName, Config.CounterTopTreySlots, Config.CounterTopTreySize)
		exports.ox_inventory:openInventory('stash', TargetName)
	else
		if Config.UsingNewQBCore then
			TriggerServerEvent("Pug:Server:OpenStash", TargetName, Config.CounterTopTreySize, Config.CounterTopTreySlots)
		else
			TriggerServerEvent("inventory:server:OpenInventory", "stash", TargetName, {
				maxweight = Config.CounterTopTreySize,
				slots = Config.CounterTopTreySlots,
			})
			TriggerEvent("inventory:client:SetCurrentStash", TargetName)
		end
	end
end)
------------------------------

---------- [STORAGE] ----------
RegisterNetEvent("Pug:client:CreateAllTargetsstorage", function(Data, Bool)
	local ThisJob = Data["job"]
	for k, v in pairs(Data) do
		if Config.Target == "ox_target" then
			if tostring(k) == "storage" then
				local TableToRun = StorageTargets
				for u, i in pairs(TableToRun) do
					local TargetName = u
					local ActualTargetId = i.id
					if StorageTargets[TargetName] then
						if i.job == ThisJob then
							exports.ox_target:removeZone(ActualTargetId)
							StorageTargets[TargetName] = nil
						end
					end
				end
			end
		else
			if tostring(k) == "storage" then
				local TableToRun = StorageTargets
				if Bool then
					TableToRun = json.decode(Data["storage"])
				end
				for u, _ in pairs(TableToRun) do
					local TargetName = ThisJob..u..k
					exports[Config.Target]:RemoveZone(TargetName)
				end
			end
		end
	end
	for k, v in pairs(Data) do
		if tostring(k) == "storage" then
			for u, i in pairs(json.decode(Data["storage"])) do
				local TargetName = ThisJob..u..k
				local Info = i
				if Config.Target == "ox_target" then
					local Data = {
						Info = Info,
						Name = TargetName,
					}
					StorageTargets[TargetName] = exports.ox_target:addSphereZone({
						coords = vector3(Info.Target.x,Info.Target.y,Info.Target.z),
						radius = 0.5,
						debug = Config.Debug,
						options = {
							{
								name= TargetName,
								type = "client",
								event = "Pug:Client:DoBusinessStorageLogic",
								args = Data,
								icon = "fa-solid fa-box",
								label = Config.LangT["Storage"],
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								distance = 2.0
							}
						}
					})
					StorageTargets[TargetName] = {
						job = ThisJob,
						id = StorageTargets[TargetName]
					}
				else
					StorageTargets[u] = v
					exports[Config.Target]:AddBoxZone(TargetName, vector3(Info.Target.x,Info.Target.y,Info.Target.z), 0.7, 0.7, {
						name=TargetName,
						heading=35,
						debugPoly = Config.Debug,
						minZ= Info.Target.z-0.3,
						maxZ= Info.Target.z+0.3,
					}, {
						options = {
							{
								icon = "fa-solid fa-box",
								label = Config.LangT["Storage"],
								event = " ",
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								action = function()
									local Data = {
										args = {
											Info = Info,
											Name = TargetName,
										}
									}
									TriggerEvent("Pug:Client:DoBusinessStorageLogic",Data)
								end,
							},
						},
						distance = 2.0
					})
				end
			end
		end
	end
end)
RegisterNetEvent("Pug:Client:DoBusinessStorageLogic", function(Data)
	local TargetName = Data.args.Name
	if Config.InventoryType == "qs-inventory" then
		exports['qs-inventory']:RegisterStash(TargetName, Config.BusinessStorageSlots, Config.BusinessStorageSize) 
	elseif Config.InventoryType == "ox_inventory" then
		TriggerServerEvent("Pug:server:BusinessOxStashOpen", TargetName, Config.BusinessStorageSlots, Config.BusinessStorageSize)
		exports.ox_inventory:openInventory('stash', TargetName)
	else
		if Config.UsingNewQBCore then
			TriggerServerEvent("Pug:Server:OpenStash", TargetName, Config.BusinessStorageSize, Config.BusinessStorageSlots)
		else
			TriggerServerEvent("inventory:server:OpenInventory", "stash", TargetName, {
				maxweight = Config.BusinessStorageSize,
				slots = Config.BusinessStorageSlots,
			})
			TriggerEvent("inventory:client:SetCurrentStash", TargetName)
		end
	end
end)
------------------------------

---------- [SEATS] ----------
RegisterNetEvent("Pug:client:CreateAllTargetsseats", function(Data, Bool)
	local ThisJob = Data["job"]
	for k, v in pairs(Data) do
		if Config.Target == "ox_target" then
			if tostring(k) == "seats" then
				local TableToRun = SeatsTargets
				for u, i in pairs(TableToRun) do
					local TargetName = u
					local ActualTargetId = i.id
					if SeatsTargets[TargetName] then
						if i.job == ThisJob then
							exports.ox_target:removeZone(ActualTargetId)
							SeatsTargets[TargetName] = nil
						end
					end
				end
			end
		else
			if tostring(k) == "seats" then
				local TableToRun = SeatsTargets
				if Bool then
					TableToRun = json.decode(Data["seats"])
				end
				for u, _ in pairs(TableToRun) do
					local TargetName = ThisJob..u..k
					exports[Config.Target]:RemoveZone(TargetName)
				end
			end
		end
	end
	for k, v in pairs(Data) do
		if tostring(k) == "seats" then
			for u, i in pairs(json.decode(Data["seats"])) do
				local TargetName = ThisJob..u..k
				local Info = i
				if Config.Target == "ox_target" then
					local Data = {
						Info = Info,
						Name = TargetName,
					}
					SeatsTargets[TargetName] = exports.ox_target:addSphereZone({
						coords = vector3(Info.Target.x,Info.Target.y,Info.Target.z),
						radius = 0.4,
						debug = Config.Debug,
						options = {
							{
								name= TargetName,
								type = "client",
								event = "Pug:Client:DoBusinessSeatsLogic",
								args = Data,
								icon = "fa-solid fa-chair",
								label = Config.LangT["Sit"],
								distance = 2.4
							}
						}
					})
					SeatsTargets[TargetName] = {
						job = ThisJob,
						id = SeatsTargets[TargetName]
					}
				else
					SeatsTargets[u] = v
					exports[Config.Target]:AddBoxZone(TargetName, vector3(Info.Target.x,Info.Target.y,Info.Target.z), 0.7, 0.7, {
						name=TargetName,
						heading=35,
						debugPoly = Config.Debug,
						minZ= Info.Target.z-0.3,
						maxZ= Info.Target.z+0.3,
					}, {
						options = {
							{
								icon = "fa-solid fa-chair",
								label = Config.LangT["Sit"],
								event = " ",
								action = function()
									local Data = {
										args = {
											Info = Info,
											Name = TargetName,
										}
									}
									TriggerEvent("Pug:Client:DoBusinessSeatsLogic",Data)
								end,
							},
						},
						distance = 2.0
					})
				end
			end
		end
	end
end)
RegisterNetEvent("Pug:Client:DoBusinessSeatsLogic", function(Data)
	local Info = Data.args.Info
	TaskTurnPedToFaceCoord(PlayerPedId(), vector3(Info.Target.x, Info.Target.y, Info.Target.z))
	Wait(800)
	SetEntityHeading(PlayerPedId(), Info.Heading)
	TaskStartScenarioAtPosition(PlayerPedId(), "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", Info.Target.x, Info.Target.y, Info.Target.z-0.1, Info.Heading, 0, 1, true)
	TriggerEvent("Pug:client:ClearPedTaskLoopCheck")
end)
------------------------------

---------- [DUTY] ----------
RegisterNetEvent("Pug:client:CreateAllTargetsduty", function(Data, Bool)
	local ThisJob = Data["job"]
	for k, v in pairs(Data) do
		if Config.Target == "ox_target" then
			if tostring(k) == "duty" then
				local TableToRun = DutyTargets
				for u, i in pairs(TableToRun) do
					local TargetName = u
					local ActualTargetId = i.id
					if DutyTargets[TargetName] then
						if i.job == ThisJob then
							exports.ox_target:removeZone(ActualTargetId)
							DutyTargets[TargetName] = nil
						end
					end
				end
			end
		else
			if tostring(k) == "duty" then
				local TableToRun = DutyTargets
				if Bool then
					TableToRun = json.decode(Data["duty"])
				end
				for u, _ in pairs(TableToRun) do
					local TargetName = ThisJob..u..k
					exports[Config.Target]:RemoveZone(TargetName)
				end
			end
		end
	end
	for k, v in pairs(Data) do
		if tostring(k) == "duty" then
			for u, i in pairs(json.decode(Data["duty"])) do
				local TargetName = ThisJob..u..k
				local Info = i
				if Config.Target == "ox_target" then
					local Data = {
						Info = Info,
						Name = TargetName,
					}
					DutyTargets[TargetName] = exports.ox_target:addSphereZone({
						coords = vector3(Info.Target.x,Info.Target.y,Info.Target.z),
						radius = 0.4,
						debug = Config.Debug,
						options = {
							{
								name= TargetName,
								type = "client",
								event = "Pug:Client:DoBusinessDutyLogic",
								args = Data,
								icon = "fa-solid fa-clipboard",
								label = Config.LangT["ToggleDuty"],
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								distance = 2.0
							}
						}
					})
					DutyTargets[TargetName] = {
						job = ThisJob,
						id = DutyTargets[TargetName]
					}
				else
					DutyTargets[u] = v
					exports[Config.Target]:AddBoxZone(TargetName, vector3(Info.Target.x,Info.Target.y,Info.Target.z), 0.7, 0.7, {
						name=TargetName,
						heading=35,
						debugPoly = Config.Debug,
						minZ= Info.Target.z-0.3,
						maxZ= Info.Target.z+0.3,
					}, {
						options = {
							{
								icon = "fa-solid fa-clipboard",
								label = Config.LangT["ToggleDuty"],
								event = " ",
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								action = function()
									local Data = {
										args = {
											Info = Info,
											Name = TargetName,
										}
									}
									TriggerEvent("Pug:Client:DoBusinessDutyLogic",Data)
								end,
							},
						},
						distance = 2.0
					})
				end
			end
		end
	end
end)
RegisterNetEvent("Pug:Client:DoBusinessDutyLogic", function(Data)
	local Info = Data.args.Info
	if Info.PedCoords ~= nil then
		if Config.HavePlayersWalkToTarget then
			TaskGoStraightToCoord(PlayerPedId(), Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z, 1.0, 20000, 40000.0, 0.5)
			local Count = 0 
			while #(GetEntityCoords(PlayerPedId()) - vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z)) >= 1.1 do Count = Count + 1 Wait(500) if Count >= 4 then return end end
			TaskTurnPedToFaceCoord(PlayerPedId(), vector3(Info.Target.x, Info.Target.y, Info.Target.z))
			Wait(800)
		else
			SetEntityCoords(PlayerPedId(), vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z))
			SetEntityHeading(PlayerPedId(), Info.Heading)
		end
	end
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			loadAnimDict(Info.Animation.AnimDict)
			PlayAnimation(Info.Animation.AnimDict, Info.Animation.AnimAction)
		else
			ClearPedTasksImmediately(PlayerPedId())
			DestroyAllProps()
			TaskStartScenarioInPlace(PlayerPedId(), Info.Animation.AnimDict, 0, false)
		end
	end
	if Config.FrameworkFunctions.GetPlayer(true, false, true).PlayerData.job.onduty then
        ExecuteCommand('me '..Config.LangT["SignsOffDuty"], "success")
    else
        ExecuteCommand('me '..Config.LangT["SignsOnDuty"], "success")
    end
    FreezeEntityPosition(PlayerPedId(), true)
    Wait(2200)
    FreezeEntityPosition(PlayerPedId(), false)
    TriggerServerEvent("QBCore:ToggleDuty")
	ReloadSkin()
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			StopAnimTask(PlayerPedId(), Info.Animation.AnimDict, Info.Animation.AnimAction, 1.0)
		else
			ClearPedTasksImmediately(PlayerPedId())
		end
	end
	DestroyAllProps()
end)
------------------------------

---------- [BOSS MENU] ----------
RegisterNetEvent("Pug:client:CreateAllTargetsbossmenu", function(Data, Bool)
	local ThisJob = Data["job"]
	for k, v in pairs(Data) do
		if Config.Target == "ox_target" then
			if tostring(k) == "bossmenu" then
				local TableToRun = BossMenuTargets
				for u, i in pairs(TableToRun) do
					local TargetName = u
					local ActualTargetId = i.id
					if BossMenuTargets[TargetName] then
						if i.job == ThisJob then
							exports.ox_target:removeZone(ActualTargetId)
							BossMenuTargets[TargetName] = nil
						end
					end
				end
			end
		else
			if tostring(k) == "bossmenu" then
				local TableToRun = BossMenuTargets
				if Bool then
					TableToRun = json.decode(Data["bossmenu"])
				end
				for u, _ in pairs(TableToRun) do
					local TargetName = ThisJob..u..k
					exports[Config.Target]:RemoveZone(TargetName)
				end
			end
		end
	end
	for k, v in pairs(Data) do
		if tostring(k) == "bossmenu" then
			for u, i in pairs(json.decode(Data["bossmenu"])) do
				local TargetName = ThisJob..u..k
				local Info = i
				if Config.Target == "ox_target" then
					local Data = {
						Info = Info,
						Name = TargetName,
					}
					BossMenuTargets[TargetName] = exports.ox_target:addSphereZone({
						coords = vector3(Info.Target.x,Info.Target.y,Info.Target.z),
						radius = 0.4,
						debug = Config.Debug,
						options = {
							{
								name= TargetName,
								type = "client",
								event = "Pug:Client:DoBusinessBossMenuLogic",
								args = Data,
								icon = "fa-solid fa-clipboard",
								label = Config.LangT["BossMenu"],
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								distance = 2.0
							}
						}
					})
					BossMenuTargets[TargetName] = {
						job = ThisJob,
						id = BossMenuTargets[TargetName]
					}
				else
					BossMenuTargets[u] = v
					exports[Config.Target]:AddBoxZone(TargetName, vector3(Info.Target.x,Info.Target.y,Info.Target.z), 0.7, 0.7, {
						name=TargetName,
						heading=35,
						debugPoly = Config.Debug,
						minZ= Info.Target.z-0.3,
						maxZ= Info.Target.z+0.3,
					}, {
						options = {
							{
								icon = "fa-solid fa-clipboard",
								label = Config.LangT["BossMenu"],
								event = " ",
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								action = function()
									local Data = {
										args = {
											Info = Info,
											Name = TargetName,
										}
									}
									TriggerEvent("Pug:Client:DoBusinessBossMenuLogic",Data)
								end,
							},
						},
						distance = 2.0
					})
				end
			end
		end
	end
end)
RegisterNetEvent("Pug:Client:DoBusinessBossMenuLogic", function(Data)
	local Info = Data.args.Info
	if Info.PedCoords ~= nil then
		if Config.HavePlayersWalkToTarget then
			TaskGoStraightToCoord(PlayerPedId(), Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z, 1.0, 20000, 40000.0, 0.5)
			local Count = 0 
			while #(GetEntityCoords(PlayerPedId()) - vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z)) >= 1.1 do Count = Count + 1 Wait(500) if Count >= 4 then return end end
			TaskTurnPedToFaceCoord(PlayerPedId(), vector3(Info.Target.x, Info.Target.y, Info.Target.z))
			Wait(800)
		else
			SetEntityCoords(PlayerPedId(), vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z))
			SetEntityHeading(PlayerPedId(), Info.Heading)
		end
	end
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			loadAnimDict(Info.Animation.AnimDict)
			PlayAnimation(Info.Animation.AnimDict, Info.Animation.AnimAction)
		else
			ClearPedTasksImmediately(PlayerPedId())
			DestroyAllProps()
			TaskStartScenarioInPlace(PlayerPedId(), Info.Animation.AnimDict, 0, false)
		end
	end
	if Framework == "ESX" then
        local JobName = Config.FrameworkFunctions.GetPlayer(true, false, true).PlayerData.job.name
        TriggerEvent('esx_society:openBossMenu', JobName)
    else
		local BossMenuEvent = "qb-bossmenu:client:OpenMenu"
		if FWork.Shared and FWork.Shared.Gangs and FWork.Shared.Gangs[Info.Business] then
			BossMenuEvent = "qb-gangmenu:client:OpenMenu"
		end
		TriggerEvent(BossMenuEvent)
    end
	Wait(1000)
	TriggerEvent("Pug:ReloadGuns:sling")
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			StopAnimTask(PlayerPedId(), Info.Animation.AnimDict, Info.Animation.AnimAction, 1.0)
		else
			ClearPedTasksImmediately(PlayerPedId())
		end
	end
	DestroyAllProps()
end)
------------------------------

---------- [LOCKERS] ----------
RegisterNetEvent("Pug:client:CreateAllTargetslocker", function(Data, Bool)
	local ThisJob = Data["job"]
	for k, v in pairs(Data) do
		if Config.Target == "ox_target" then
			if tostring(k) == "locker" then
				local TableToRun = LockerTargets
				for u, i in pairs(TableToRun) do
					local TargetName = u
					local ActualTargetId = i.id
					if LockerTargets[TargetName] then
						if i.job == ThisJob then
							exports.ox_target:removeZone(ActualTargetId)
							LockerTargets[TargetName] = nil
						end
					end
				end
			end
		else
			if tostring(k) == "locker" then
				local TableToRun = LockerTargets
				if Bool then
					TableToRun = json.decode(Data["locker"])
				end
				for u, _ in pairs(TableToRun) do
					local TargetName = ThisJob..u..k
					exports[Config.Target]:RemoveZone(TargetName)
				end
			end
		end
	end
	for k, v in pairs(Data) do
		if tostring(k) == "locker" then
			for u, i in pairs(json.decode(Data["locker"])) do
				local TargetName = ThisJob..u..k
				local Info = i
				if Config.Target == "ox_target" then
					local Data = {
						Info = Info,
						Name = TargetName,
					}
					LockerTargets[TargetName] = exports.ox_target:addSphereZone({
						coords = vector3(Info.Target.x,Info.Target.y,Info.Target.z),
						radius = 0.4,
						debug = Config.Debug,
						options = {
							{
								name= TargetName,
								type = "client",
								event = "Pug:Client:DoBusinessLockerLogic",
								args = Data,
								icon = "fa-solid fa-clipboard",
								label = Config.LangT["OpenLocker"],
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								distance = 2.0
							}
						}
					})
					LockerTargets[TargetName] = {
						job = ThisJob,
						id = LockerTargets[TargetName]
					}
				else
					LockerTargets[u] = v
					exports[Config.Target]:AddBoxZone(TargetName, vector3(Info.Target.x,Info.Target.y,Info.Target.z), 0.9, 0.9, {
						name=TargetName,
						heading=35,
						debugPoly = Config.Debug,
						minZ= Info.Target.z-0.5,
						maxZ= Info.Target.z+0.5,
					}, {
						options = {
							{
								icon = "fa-solid fa-clipboard",
								label = Config.LangT["OpenLocker"],
								event = " ",
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								action = function()
									local Data = {
										args = {
											Info = Info,
											Name = TargetName,
										}
									}
									TriggerEvent("Pug:Client:DoBusinessLockerLogic",Data)
								end,
							},
						},
						distance = 2.0
					})
				end
			end
		end
	end
end)
RegisterNetEvent("Pug:Client:DoBusinessLockerLogic", function(Data)
	local Info = Data.args.Info
	local TargetName = Data.args.Name
	if Config.HavePlayersWalkToTarget then
		TaskGoStraightToCoord(PlayerPedId(), Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z, 1.0, 20000, 40000.0, 0.5)
		local Count = 0 
		while #(GetEntityCoords(PlayerPedId()) - vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z)) >= 1.1 do Count = Count + 1 Wait(500) if Count >= 4 then return end end
		TaskTurnPedToFaceCoord(PlayerPedId(), vector3(Info.Target.x, Info.Target.y, Info.Target.z))
		Wait(800)
	else
		SetEntityCoords(PlayerPedId(), vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z))
		SetEntityHeading(PlayerPedId(), Info.Heading)
	end
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			loadAnimDict(Info.Animation.AnimDict)
			PlayAnimation(Info.Animation.AnimDict, Info.Animation.AnimAction)
		else
			ClearPedTasksImmediately(PlayerPedId())
			DestroyAllProps()
			TaskStartScenarioInPlace(PlayerPedId(), Info.Animation.AnimDict, 0, false)
		end
	end
	local CitizenId = Config.FrameworkFunctions.GetPlayer(true, false, true).PlayerData.charinfo.citizenid
	if Config.InventoryType == "qs-inventory" then
		exports['qs-inventory']:RegisterStash(TargetName..CitizenId, Config.BusinessLockerSlots, Config.BusinessLockerSize) 
	elseif Config.InventoryType == "ox_inventory" then
		TriggerServerEvent("Pug:server:BusinessOxStashOpen", tostring(TargetName..CitizenId), Config.BusinessLockerSlots, Config.BusinessLockerSize)
		exports.ox_inventory:openInventory('stash', tostring(TargetName..CitizenId))
	else
		if Config.UsingNewQBCore then
			TriggerServerEvent("Pug:Server:OpenStash", TargetName, Config.BusinessLockerSize, Config.BusinessLockerSlots)
		else
			TriggerServerEvent("inventory:server:OpenInventory", "stash", TargetName..CitizenId, {
				maxweight = Config.BusinessLockerSize,
				slots = Config.BusinessLockerSlots,
			})
			TriggerEvent("inventory:client:SetCurrentStash", TargetName..CitizenId)
		end
	end
	Wait(3000)
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			StopAnimTask(PlayerPedId(), Info.Animation.AnimDict, Info.Animation.AnimAction, 1.0)
		else
			ClearPedTasksImmediately(PlayerPedId())
		end
	end
	DestroyAllProps()
end)
------------------------------

---------- [SUPPLIES] ----------
RegisterNetEvent("Pug:client:CreateAllTargetssupplies", function(Data, Bool)
	local ThisJob = Data["job"]
	for k, v in pairs(Data) do
		if Config.Target == "ox_target" then
			if tostring(k) == "supplies" then
				local TableToRun = SupplyTargets
				for u, i in pairs(TableToRun) do
					local TargetName = u
					local ActualTargetId = i.id
					if SupplyTargets[TargetName] then
						if i.job == ThisJob then
							exports.ox_target:removeZone(ActualTargetId)
							SupplyTargets[TargetName] = nil
						end
					end
				end
			end
		else
			if tostring(k) == "supplies" then
				local TableToRun = SupplyTargets
				if Bool then
					TableToRun = json.decode(Data["supplies"])
				end
				for u, _ in pairs(TableToRun) do
					local TargetName = ThisJob..u..k
					exports[Config.Target]:RemoveZone(TargetName)
				end
			end
		end
	end
	for k, v in pairs(Data) do
		if tostring(k) == "supplies" then
			for u, i in pairs(json.decode(Data["supplies"])) do
				local TargetName = ThisJob..u..k
				local Info = i
				if Config.Target == "ox_target" then
					local Data = {
						Info = Info,
						Name = TargetName,
					}
					SupplyTargets[TargetName] = exports.ox_target:addSphereZone({
						coords = vector3(Info.Target.x,Info.Target.y,Info.Target.z),
						radius = 0.4,
						debug = Config.Debug,
						options = {
							{
								name= TargetName,
								type = "client",
								event = "Pug:Client:DoBusinessSuppliesLogic",
								args = Data,
								icon = "fa-solid fa-burger",
								label = Config.LangT["GrabSupplies"],
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								distance = 2.0
							}
						}
					})
					SupplyTargets[TargetName] = {
						job = ThisJob,
						id = SupplyTargets[TargetName]
					}
				else
					SupplyTargets[u] = v
					exports[Config.Target]:AddBoxZone(TargetName, vector3(Info.Target.x,Info.Target.y,Info.Target.z), 0.9, 0.9, {
						name=TargetName,
						heading=35,
						debugPoly = Config.Debug,
						minZ= Info.Target.z-0.5,
						maxZ= Info.Target.z+0.5,
					}, {
						options = {
							{
								icon = "fa-solid fa-burger",
								label = Config.LangT["GrabSupplies"],
								event = " ",
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								action = function()
									local Data = {
										args = {
											Info = Info,
											Name = TargetName,
											job = ThisJob,
										}
									}
									TriggerEvent("Pug:Client:DoBusinessSuppliesLogic",Data)
								end,
							},
						},
						distance = 2.0
					})
				end
			end
		end
	end
end)
RegisterNetEvent("Pug:Client:DoBusinessSuppliesLogic", function(Data)
	local items = {}
	local Info = Data.args.Info
	if Config.HavePlayersWalkToTarget then
		TaskGoStraightToCoord(PlayerPedId(), Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z, 1.0, 20000, 40000.0, 0.5)
		local Count = 0 
		while #(GetEntityCoords(PlayerPedId()) - vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z)) >= 1.1 do Count = Count + 1 Wait(500) if Count >= 4 then return end end
		TaskTurnPedToFaceCoord(PlayerPedId(), vector3(Info.Target.x, Info.Target.y, Info.Target.z))
		Wait(800)
	else
		SetEntityCoords(PlayerPedId(), vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z))
		SetEntityHeading(PlayerPedId(), Info.Heading)
	end
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			loadAnimDict(Info.Animation.AnimDict)
			PlayAnimation(Info.Animation.AnimDict, Info.Animation.AnimAction)
		else
			ClearPedTasksImmediately(PlayerPedId())
			DestroyAllProps()
			TaskStartScenarioInPlace(PlayerPedId(), Info.Animation.AnimDict, 0, false)
		end
	end
    local items = {}
	local FinalSLot
    for k, v in pairs(Info.SuppliesData) do
        local supplyNum = k:match("Supplies(%d+)$")
        if supplyNum then
            items[tonumber(supplyNum)] = {
                name = v,
                price = tonumber(Info.SuppliesData["SuppliesPrice" .. supplyNum]),
                amount = tonumber(Info.SuppliesData["SuppliesAmount" .. supplyNum]),
                info = {},
                type = "item",
                slot = tonumber(supplyNum)
            }
			FinalSLot = tonumber(supplyNum)
        end
    end
	local FinalItemsShopOpening = {
		label = Data.args.Name,
		slots = FinalSLot,
		items = items
	}
	if Config.InventoryType == "ox_inventory" then
		TriggerServerEvent("Pug:server:BusinessOxShopOpen", FinalItemsShopOpening) 
		exports.ox_inventory:openInventory("shop", {type = Data.args.Name})
	elseif Config.InventoryType == "qs-inventory" then
		TriggerServerEvent("inventory:server:OpenInventory", "shop", "Itemshop_" .. Data.args.Name, FinalItemsShopOpening)
	else
		if Config.UsingNewQBCore then
			TriggerServerEvent("Pug:Server:OpenShop", Data.args.Name, FinalItemsShopOpening)
		else
			TriggerServerEvent("inventory:server:OpenInventory", "shop", Data.args.Name, FinalItemsShopOpening)
		end
	end
	Wait(3000)
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			StopAnimTask(PlayerPedId(), Info.Animation.AnimDict, Info.Animation.AnimAction, 1.0)
		else
			ClearPedTasksImmediately(PlayerPedId())
		end
	end
	DestroyAllProps()
end)
------------------------------

---------- [BLIPS] ----------
RegisterNetEvent("Pug:client:CreateAllTargetsblip", function(Data, Bool)
	local ThisJob = Data["job"]
	if DoesBlipExist(BusinesBlips[ThisJob]) then RemoveBlip(BusinesBlips[ThisJob]) BusinesBlips[ThisJob] = nil Wait(100) end
	for k, v in pairs(Data) do
		if Config.Target == "ox_target" then
			if tostring(k) == "blip" then
				local TableToRun = BlipIconDatas
				for u, i in pairs(TableToRun) do
					local TargetName = u
					local ActualTargetId = i.id
					if BlipIconDatas[TargetName] then
						if i.job == ThisJob then
							exports.ox_target:removeZone(ActualTargetId)
							BlipIconDatas[TargetName] = nil
						end
					end
				end
			end
		else
			if tostring(k) == "blip" then
				local TableToRun = BlipIconDatas
				if Bool then
					TableToRun = json.decode(Data["blip"])
				end
				for u, _ in pairs(TableToRun) do
					local TargetName = ThisJob..u..k
					exports[Config.Target]:RemoveZone(TargetName)
				end
			end
		end
	end
	for k, v in pairs(Data) do
		if tostring(k) == "blip" then
			for u, i in pairs(json.decode(Data["blip"])) do
				local TargetName = ThisJob..u..k
				local Info = i
				if Config.Target == "ox_target" then
					local Data = {
						Info = Info,
						Name = TargetName,
					}
					BlipIconDatas[TargetName] = exports.ox_target:addSphereZone({
						coords = vector3(Info.Target.x,Info.Target.y,Info.Target.z),
						radius = 0.3,
						debug = Config.Debug,
						options = {
							{
								name= TargetName,
								type = "client",
								event = "Pug:Client:DoBusinessBlipLogic",
								args = Data,
								icon = "fa-solid fa-clipboard",
								label = Config.LangT["ToggleBlip"],
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								distance = 2.0
							}
						}
					})
					BlipIconDatas[TargetName] = {
						job = ThisJob,
						id = BlipIconDatas[TargetName]
					}
				else
					BlipIconDatas[u] = v
					exports[Config.Target]:AddBoxZone(TargetName, vector3(Info.Target.x,Info.Target.y,Info.Target.z), 0.9, 0.9, {
						name=TargetName,
						heading=35,
						debugPoly = Config.Debug,
						minZ= Info.Target.z-0.5,
						maxZ= Info.Target.z+0.5,
					}, {
						options = {
							{
								icon = "fa-solid fa-clipboard",
								label = Config.LangT["ToggleBlip"],
								event = " ",
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								action = function()
									local Data = {
										args = {
											Info = Info,
											Name = TargetName,
										}
									}
									TriggerEvent("Pug:Client:DoBusinessBlipLogic",Data)
								end,
							},
						},
						distance = 2.0
					})
				end
				if Info.Enabled then
					CreateBlip(Info.Name, Info.Sprite, Info.Color, Info.Target, Info.Scale, ThisJob)
				end
			end
		end
	end
end)
local ToggleBlipCooldown = false
RegisterNetEvent("Pug:Client:DoBusinessBlipLogic", function(Data)
	local Info = Data.args.Info
	if not ToggleBlipCooldown then
		if Config.HavePlayersWalkToTarget then
			TaskGoToCoordAnyMeans(PlayerPedId(), Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z, 1.0, 0, 0, 786603, 0xbf800000)
			local Count = 0 
			while #(GetEntityCoords(PlayerPedId()) - vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z)) >= 1.1 do Count = Count + 1 Wait(500) if Count >= 4 then return end end
			TaskTurnPedToFaceCoord(PlayerPedId(), vector3(Info.Target.x, Info.Target.y, Info.Target.z))
			Wait(800)
		else
			SetEntityCoords(PlayerPedId(), vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z))
			SetEntityHeading(PlayerPedId(), Info.Heading)
		end
		if Info.Animation ~= nil then
			if not Info.Animation.IsScenario then
				loadAnimDict(Info.Animation.AnimDict)
				PlayAnimation(Info.Animation.AnimDict, Info.Animation.AnimAction)
			else
				ClearPedTasksImmediately(PlayerPedId())
				DestroyAllProps()
				TaskStartScenarioInPlace(PlayerPedId(), Info.Animation.AnimDict, 0, false)
			end
		end
		ToggleBlipCooldown = true
		Wait(2000)
		ReloadSkin()
		TriggerEvent("Pug:client:ChangeBlipEnableStatus", Info)
		if Config.InventoryType == "qs-inventory" then
			ClearPedTasksImmediately(PlayerPedId())
		else
			ClearPedTasks(PlayerPedId())
		end
		DestroyAllProps()
		ToggleBlipCooldown = false
	else
		if Info.Animation ~= nil then
			StopAnimTask(PlayerPedId(), Info.Animation.AnimDict, Info.Animation.AnimAction, 1.0)
		end
		DestroyAllProps()
		BusinessNotify(Config.LangT["CantSpamThis"], "error")
	end
end)
------------------------------

---------- [CRAFT STATIONS] ----------
RegisterNetEvent("Pug:client:CreateAllTargetscookstations", function(Data, Bool)
	local ThisJob = Data["job"]
	for k, v in pairs(Data) do
		if Config.Target == "ox_target" then
			if tostring(k) == "cookstations" then
				local TableToRun = CookStationTargets
				for u, i in pairs(TableToRun) do
					local TargetName = u
					local ActualTargetId = i.id
					if CookStationTargets[TargetName] then
						if i.job == ThisJob then
							exports.ox_target:removeZone(ActualTargetId)
							CookStationTargets[TargetName] = nil
						end
					end
				end
			end
		else
			if tostring(k) == "cookstations" then
				local TableToRun = CookStationTargets
				if Bool then
					TableToRun = json.decode(Data["cookstations"])
				end
				for u, _ in pairs(TableToRun) do
					local TargetName = ThisJob..u..k
					exports[Config.Target]:RemoveZone(TargetName)
				end
			end
		end
	end
	for k, v in pairs(Data) do
		if tostring(k) == "cookstations" then
			for u, i in pairs(json.decode(Data["cookstations"])) do
				local TargetName = ThisJob..u..k
				local Info = i
				if Config.Target == "ox_target" then
					local Data = {
						Info = Info,
						Name = TargetName,
					}
					CookStationTargets[TargetName] = exports.ox_target:addSphereZone({
						coords = vector3(Info.Target.x,Info.Target.y,Info.Target.z),
						radius = 0.3,
						debug = Config.Debug,
						options = {
							{
								name= TargetName,
								type = "client",
								event = "Pug:Client:DoBusinessCraftLogic",
								args = Data,
								icon = "fa-solid fa-clipboard",
								label = Info.CookStationText,
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								distance = 2.0
							}
						}
					})
					CookStationTargets[TargetName] = {
						job = ThisJob,
						id = CookStationTargets[TargetName]
					}
				else
					CookStationTargets[u] = v
					exports[Config.Target]:AddBoxZone(TargetName, vector3(Info.Target.x,Info.Target.y,Info.Target.z), 0.9, 0.9, {
						name=TargetName,
						heading=35,
						debugPoly = Config.Debug,
						minZ= Info.Target.z-0.5,
						maxZ= Info.Target.z+0.5,
					}, {
						options = {
							{
								icon = "fa-solid fa-clipboard",
								label = Info.CookStationText,
								event = " ",
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								action = function()
									local Data = {
										args = {
											Info = Info,
											Name = TargetName,
										}
									}
									TriggerEvent("Pug:Client:DoBusinessCraftLogic",Data)
								end,
							},
						},
						distance = 2.0
					})
				end
				if Info.Enabled then
					CreateBlip(Info.Name, Info.Sprite, Info.Color, Info.Target, Info.Scale)
				end
			end
		end
	end
end)
RegisterNetEvent("Pug:Client:DoBusinessCraftLogic", function(Data)
	local Info = Data.args.Info
	if Info.PedCoords ~= nil then
		if Config.HavePlayersWalkToTarget then
			TaskGoStraightToCoord(PlayerPedId(), Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z, 1.0, 20000, 40000.0, 0.5)
			local Count = 0 
			while #(GetEntityCoords(PlayerPedId()) - vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z)) >= 1.1 do Count = Count + 1 Wait(500) if Count >= 4 then return end end
			TaskTurnPedToFaceCoord(PlayerPedId(), vector3(Info.Target.x, Info.Target.y, Info.Target.z))
			Wait(800)
		else
			SetEntityCoords(PlayerPedId(), vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z))
			SetEntityHeading(PlayerPedId(), Info.Heading)
		end
	end
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			loadAnimDict(Info.Animation.AnimDict)
			PlayAnimation(Info.Animation.AnimDict, Info.Animation.AnimAction)
		else
			ClearPedTasksImmediately(PlayerPedId())
			TaskStartScenarioInPlace(PlayerPedId(), Info.Animation.AnimDict, 0, false)
		end
		DestroyAllProps()
	end
	local AllCraftableData = Info.CookStationData
	local CraftMenu = {}
	if Config.Menu == "ox_lib" then
	else
		CraftMenu = {
			{
				header = Info.CookStationText,
				txt = " ",
				isMenuHeader = true,
			},
		}
	end
	for k, v in pairs(AllCraftableData) do
		local requiredItems = AllCraftableData[k].RequiredItemToCraftIt
		local itemsString = " "
		local ItemStringText = " "

		for key, value in pairs(requiredItems) do
			if string.match(key, "required%d+") then
				local amountKey = "requiredAmount" .. string.sub(key, -1)
				local amount = requiredItems[amountKey] or ""
				itemsString = itemsString .. amount .. "x " .. value .. ", "
				ItemStringText = ItemStringText .. amount .. "x " .. GetItemsInformation(value) .. ", "
			end
		end
		-- remove the trailing comma and space
		itemsString = itemsString:sub(1, -3)

		local ItemsToCraft = {
			Item = AllCraftableData[k].MainIngredientItem,
			ItemAmount = AllCraftableData[k].AmountCanCraft,
			ItemsToRemove = itemsString,
		}
		local DisabledMenu = true
		local items = {}
		for item in itemsString:gmatch("[^,]+") do
			table.insert(items, item:match("^%s*(.-)%s*$"))
		end
		for _, item in ipairs(items) do
			local quantity, name = item:match("(%d+)x%s*(.*)")
			if HasItem(tostring(name), tonumber(quantity)) then
				DisabledMenu = false
			else
				DisabledMenu = true
				break
			end
		end
		if Config.Menu == "ox_lib" then
			local itemImage, itemName = GetItemsInformation(AllCraftableData[k].MainIngredientItem, true)
			local baseUrl = 'https://cfx-nui-'..Config.InventoryType
			local path = ''
			
			if Config.InventoryType == "ox_inventory" then
				if not string.find(itemImage, ".png") then
					itemImage = itemImage..".png"
				end
				path = '/web/images/'..itemImage
			elseif Config.InventoryType == "codem-inventory" then
				path = '/html/itemimages/'..itemImage
			elseif Config.InventoryType == "ak47_qb_inventory" then
				path = '/web/build/images/'..itemImage
			else
				path = '/html/images/'..itemImage
			end
			
			local Image = baseUrl..path
			local Icon = baseUrl..path
			
			CraftMenu[#CraftMenu+1] = {
				title = Config.LangT["Make"]..AllCraftableData[k].AmountCanCraft.."x "..itemName, 
				description = ItemStringText,
				icon = Icon,
				disabled = DisabledMenu,
				event = "Pug:client:CraftBusinessItem",
				args = ItemsToCraft,
				image = Image,                   
				metadata = {
					{label = 'Craft:', value = AllCraftableData[k].MainIngredientItem},                      
				},
			}
		else
			CraftMenu[#CraftMenu+1] = {
				header = Config.LangT["Make"]..AllCraftableData[k].AmountCanCraft.."x "..itemName,
				txt = ItemStringText,
				icon = "fas fa-hand",
				disabled = DisabledMenu,
				params = {
					event = "Pug:client:CraftBusinessItem",
					args = ItemsToCraft,
				}
			}
		end
	end
	if Config.Menu == "ox_lib" then
		CraftMenu[#CraftMenu+1] = {
			title = Config.LangT["Close"],
			icon = "fas fa-x",
			event = "Pug:client:CraftBusinessItem",
		}
		lib.registerContext({
			id = Info.CookStationText,
			title = Info.CookStationText,
			onExit = function()
                ClearPedTasksImmediately(PlayerPedId())
				DestroyAllProps()
            end,
			options = CraftMenu
		})
		lib.showContext(Info.CookStationText)
	else
		CraftMenu[#CraftMenu+1] = {
			header = Config.LangT["Close"],
			icon = "fas fa-x",
			params = {
				event = "Pug:client:CraftBusinessItem",
			}
		}
		exports[Config.Menu]:openMenu(CraftMenu)
	end
end)
RegisterNetEvent("Pug:client:CraftBusinessItem", function(Data)
	if not Data then ClearPedTasksImmediately(PlayerPedId()) DestroyAllProps() return end
	local DisabledMenu = true
	local items = {}
	for item in Data.ItemsToRemove:gmatch("[^,]+") do
		table.insert(items, item:match("^%s*(.-)%s*$"))
	end
	for _, item in ipairs(items) do
		local quantity, name = item:match("(%d+)x%s*(.*)")
		if HasItem(tostring(name), tonumber(quantity)) then
			DisabledMenu = false
		else
			DisabledMenu = Config.LangT["MissingItems"]..quantity.."x ".. name
			break
		end
	end
	if DisabledMenu then BusinessNotify(DisabledMenu, 'error') return end
	for _, item in ipairs(items) do
		local quantity, name = item:match("(%d+)x%s*(.*)")
		BusinessToggleItem(false, tostring(name), tonumber(quantity))
	end
	if Config.UseProgressBar then
		if GetResourceState("17mov_Hud") == 'started' then
			local action = {
				duration = 7500, -- Duration of the progress bar in milliseconds
				label = Config.LangT["Crafting"]..Data.ItemAmount.."x ".. GetItemsInformation(Data.Item), -- Text to be displayed on the progress bar
				useWhileDead = false, -- Cannot be used while the player is dead
				canCancel = false, -- Allow the progress bar to be canceled
				controlDisables = { -- Disable specific controls during the progress
					disableMovement = true, -- Disable movement controls
					disableCarMovement = true, -- Disable car movement controls
					disableMouse = false, -- Disable mouse controls
					disableCombat = true -- Disable combat controls
				},
				animation = { -- Optional animation during the progress bar
					animDict = nil,
					anim = nil,
					flags = 0,
					task = nil
				},
				prop = { -- Optional prop during the progress bar
					model = nil,
					bone = nil,
					coords = vec3(0.0, 0.0, 0.0),
					rotation = vec3(0.0, 0.0, 0.0)
				},
				propTwo = { -- Optional second prop during the progress bar
					model = nil,
					bone = nil,
					coords = vec3(0.0, 0.0, 0.0),
					rotation = vec3(0.0, 0.0, 0.0)
				}
			}
			
			exports["17mov_Hud"]:StartProgress(action, function()
				-- onStart: Hooked when progress is starting
				print("Progress started")
			end, function()
				-- onTick: Hooked every frame of progress
				print("Progress ongoing")
			end, function(wasCanceled)
				-- onFinish: Hooked when progress has ended
				if wasCanceled then
					-- BusinessNotify(Config.LangT["Canceled"], 'error')
					-- for _, item in ipairs(items) do
					-- 	local quantity, name = item:match("(%d+)x%s*(.*)")
					-- 	BusinessToggleItem(true, name, quantity)
					-- end
					-- ClearPedTasksImmediately(PlayerPedId())
					-- DestroyAllProps()
				else
					BusinessToggleItem(true, Data.Item, Data.ItemAmount)
					ClearPedTasksImmediately(PlayerPedId())
					DestroyAllProps()
				end
			end)
		elseif Config.UseProgressBar == "ox_lib" then
			if lib.progressCircle({
				duration = 7500,
				label = Config.LangT["Crafting"]..Data.ItemAmount.."x ".. GetItemsInformation(Data.Item),
				useWhileDead = false,
				canCancel = false,
				disable = {
					car = true,
				},
				anim = {},
				prop = {},
			}) then 
				BusinessToggleItem(true, Data.Item, Data.ItemAmount)
				ClearPedTasksImmediately(PlayerPedId())
				DestroyAllProps()
			else 
				-- BusinessNotify(Config.LangT["Canceled"], 'error')
				-- for _, item in ipairs(items) do
				-- 	local quantity, name = item:match("(%d+)x%s*(.*)")
				-- 	BusinessToggleItem(true, name, quantity)
				-- end
				-- ClearPedTasksImmediately(PlayerPedId())
				-- DestroyAllProps()
			end
		elseif Framework == "ESX" then
			FWork.Progressbar(Config.LangT["Crafting"]..Data.ItemAmount.."x ".. GetItemsInformation(Data.Item), 7500, {FreezePlayer = true, onFinish = function()
				BusinessToggleItem(true, Data.Item, Data.ItemAmount)
				ClearPedTasksImmediately(PlayerPedId())
				DestroyAllProps()
			end, onCancel = function()
				-- BusinessNotify("YOU SPILLED YOUR ITEMS... DONT CANCEL", 'error')
				-- BusinessNotify(Config.LangT["Canceled"], 'error')
				-- for _, item in ipairs(items) do
				-- 	local quantity, name = item:match("(%d+)x%s*(.*)")
				-- 	BusinessToggleItem(true, name, quantity)
				-- end
				-- ClearPedTasksImmediately(PlayerPedId())
				-- DestroyAllProps()
			end})
		else
			FWork.Functions.Progressbar("Crafting", Config.LangT["Crafting"]..Data.ItemAmount.."x ".. GetItemsInformation(Data.Item), 7500, false, false, {
				disableMovement = true,
				disableCarMovement = true,
				disableMouse = false,
				disableCombat = true,
			}, {}, {}, {}, function() -- Done
				BusinessToggleItem(true, Data.Item, Data.ItemAmount)
				ClearPedTasksImmediately(PlayerPedId())
				DestroyAllProps()
			end, function()
				-- BusinessNotify(Config.LangT["Canceled"], 'error')
				-- for _, item in ipairs(items) do
				-- 	local quantity, name = item:match("(%d+)x%s*(.*)")
				-- 	BusinessToggleItem(true, name, quantity)
				-- end
				-- ClearPedTasksImmediately(PlayerPedId())
				-- DestroyAllProps()
			end)
		end
	else
		Wait(1500)
		BusinessNotify(Config.LangT["Crafting"].. GetItemsInformation(Data.Item), 'error')
		Wait(1500)
		BusinessNotify(3, 'error')
		Wait(1500)
		BusinessNotify(2, 'error')
		Wait(1500)
		BusinessNotify(1, 'error')
		Wait(1500)
		BusinessToggleItem(true, Data.Item, Data.ItemAmount)
		ClearPedTasksImmediately(PlayerPedId())
		DestroyAllProps()
	end
end)
------------------------------

---------- [ANIMATIONS] ----------
RegisterNetEvent("Pug:client:CreateAllTargetsanimations", function(Data, Bool)
	local ThisJob = Data["job"]
	for k, v in pairs(Data) do
		if Config.Target == "ox_target" then
			if tostring(k) == "animations" then
				local TableToRun = AnimationTargets
				for u, i in pairs(TableToRun) do
					local TargetName = u
					local ActualTargetId = i.id
					if AnimationTargets[TargetName] then
						if i.job == ThisJob then
							exports.ox_target:removeZone(ActualTargetId)
							AnimationTargets[TargetName] = nil
						end
					end
				end
			end
		else
			if tostring(k) == "animations" then
				local TableToRun = AnimationTargets
				if Bool then
					TableToRun = json.decode(Data["animations"])
				end
				for u, _ in pairs(TableToRun) do
					local TargetName = ThisJob..u..k
					exports[Config.Target]:RemoveZone(TargetName)
				end
			end
		end
	end
	for k, v in pairs(Data) do
		if tostring(k) == "animations" then
			for u, i in pairs(json.decode(Data["animations"])) do
				local TargetName = ThisJob..u..k
				local Info = i
				if Config.Target == "ox_target" then
					local Data = {
						Info = Info,
						Name = TargetName,
					}
					AnimationTargets[TargetName] = exports.ox_target:addSphereZone({
						coords = vector3(Info.Target.x,Info.Target.y,Info.Target.z),
						radius = 0.3,
						debug = Config.Debug,
						options = {
							{
								name= TargetName,
								type = "client",
								event = "Pug:Client:DoBusinessAnimationsLogic",
								args = Data,
								icon = "fa-solid fa-land-mine-on",
								label = Config.LangT["Emote"],
								distance = 2.0
							}
						}
					})
					AnimationTargets[TargetName] = {
						job = ThisJob,
						id = AnimationTargets[TargetName]
					}
				else
					AnimationTargets[u] = v
					exports[Config.Target]:AddBoxZone(TargetName, vector3(Info.Target.x,Info.Target.y,Info.Target.z), 0.7, 0.7, {
						name=TargetName,
						heading=35,
						debugPoly = Config.Debug,
						minZ= Info.Target.z-0.3,
						maxZ= Info.Target.z+0.3,
					}, {
						options = {
							{
								icon = "fa-solid fa-land-mine-on",
								label = Config.LangT["Emote"],
								event = " ",
								action = function()
									local Data = {
										args = {
											Info = Info,
											Name = TargetName,
										}
									}
									TriggerEvent("Pug:Client:DoBusinessAnimationsLogic",Data)
								end,
							},
						},
						distance = 2.0
					})
				end
			end
		end
	end
end)
RegisterNetEvent("Pug:Client:DoBusinessAnimationsLogic", function(Data)
	local Info = Data.args.Info
	if Info.PedCoords ~= nil then
		if Config.HavePlayersWalkToTarget then
			TaskGoStraightToCoord(PlayerPedId(), Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z, 1.0, 20000, 40000.0, 0.5)
			local Count = 0 
			while #(GetEntityCoords(PlayerPedId()) - vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z)) >= 1.1 do Count = Count + 1 Wait(500) if Count >= 4 then return end end
			TaskTurnPedToFaceCoord(PlayerPedId(), vector3(Info.Target.x, Info.Target.y, Info.Target.z))
			Wait(800)
		else
			SetEntityCoords(PlayerPedId(), vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z))
			SetEntityHeading(PlayerPedId(), Info.Heading)
		end
	end
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			if Info.Animation.IsNetWorkedScene then
				loadAnimDict(Info.Animation.AnimDict)
				local NetworkScene = NetworkCreateSynchronisedScene(vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z+1), vector3(0.0, 0.0, 0.0), 2, false, true, 1065353216, 0, 1.3)
				NetworkAddPedToSynchronisedScene(PlayerPedId(), NetworkScene, Info.Animation.AnimDict, Info.Animation.AnimAction, 1.5, -4.0, 1, 1, 1148846080, 0)
				NetworkStartSynchronisedScene(NetworkScene)
			else
				loadAnimDict(Info.Animation.AnimDict)
				PlayAnimation(Info.Animation.AnimDict, Info.Animation.AnimAction)
			end
			TriggerEvent("Pug:client:ClearPedTaskLoopCheck")
		else
			ClearPedTasksImmediately(PlayerPedId())
			DestroyAllProps()
			TaskStartScenarioInPlace(PlayerPedId(), Info.Animation.AnimDict, 0, false)
		end
	end
end)
------------------------------

---------- [PROP PLACEMENTS] ----------
RegisterNetEvent("Pug:client:CreateAllTargetsprops", function(Data, Bool)
	for k, v in pairs(Data) do
		if tostring(k) == "props" then
			local TableToRun = PropPlacements
			if Bool then
				TableToRun = json.decode(Data["props"])
			end
			for u, i in pairs(TableToRun) do
				if Bool then
					local Info = i
					ClosestObject = GetClosestObjectOfType(vector3(Info.Target.x,Info.Target.y,Info.Target.z), 5.0, GetHashKey(Info.Animation))
					if DoesEntityExist(ClosestObject) then
						TriggerEvent("FullyDeleteBusinessEntity", ClosestObject)
					end
				else
					if TableToRun[u].Spawned then
						if TableToRun[u].Business == Data["job"] then
							if DoesEntityExist(TableToRun[u].Spawned) then
								TriggerEvent("FullyDeleteBusinessEntity",TableToRun[u].Spawned)
								TableToRun[u] = nil
							end
						end
					end
				end
			end
		end
	end
	for k, v in pairs(Data) do
		if tostring(k) == "props" then
			for u, i in pairs(json.decode(Data["props"])) do
				local Info = i
				PropPlacements[#PropPlacements+1] = {
					Prop = Info.Animation,
					Coords = Info.Target, 
					Heading = Info.Heading,
					Spawned = nil,
					Business = Info.Business,
				}
			end
		end
	end
end)

CreateThread(function()
	while true do
		Wait(1000)
		for k, v in pairs(PropPlacements) do
			local ThisJob = v.Business
			if not (v.Prop == "prop_tv_flat_michael") and #(GetEntityCoords(PlayerPedId()) - vector3(v.Coords.x, v.Coords.y, v.Coords.z)) <= 100 then
				if not PropPlacements[k].Spawned then
					local ZAxis = v.Coords.z
					if v.Prop == "gr_prop_gr_bench_03a" then
						ZAxis = ZAxis-1.44
					elseif v.Prop == "prop_b_board_blank" or v.Prop == "prop_tv_flat_michael" then
						ZAxis = ZAxis-0.93
					end
					LoadModel(v.Prop)
					PropPlacements[k].Spawned = CreateObject(GetHashKey(v.Prop), vector3(v.Coords.x,v.Coords.y,ZAxis))
					local counter = 0
                    local maxDuration = 30 -- Maximum duration in 100ms intervals (3 seconds)
					local PropDidintSpawn
					while not DoesEntityExist(PropPlacements[k].Spawned) do Wait(100) counter = counter + 1 if counter >= maxDuration then PropDidintSpawn = true print("^2"..v.Prop.." Entity did not spawn within 3 seconds for job "..ThisJob.." at location: "..vector3(v.Coords.x,v.Coords.y,ZAxis)) break end end
					if PropDidintSpawn then
						PropPlacements[k] = nil
						BusinessNotify("Pug Business Creator: "..v.Prop.." Entity did not spawn within 3 seconds for job "..ThisJob.." so it has been removed from the database", 'success')
                       -- CODE HERE TO REMOVE THE PROP FROM THE DATABASE
					   	local Info = {
							Business = v.Business,
							Feature = "props",
							Target = vector3(v.Coords.x, v.Coords.y, v.Coords.z),
							PedCoords = vector3(v.Coords.x, v.Coords.y, v.Coords.z),
							Animation = v.Prop,
							Heading = v.Heading,
						}
					   	TriggerServerEvent("Pug:server:AttemptToRemoveZone", Info, true)
					end
					if PropPlacements[k] then
						SetEntityHeading(PropPlacements[k].Spawned, v.Heading)
						FreezeEntityPosition(PropPlacements[k].Spawned, true)
						if v.Prop == "prop_b_board_blank" or v.Prop == "prop_tv_flat_michael" then
							if Config.Target == "ox_target" then
								local Data = {
									Business = v.Business,
									Prop = v.Prop,
								}
								exports.ox_target:addLocalEntity(PropPlacements[k].Spawned, {
									{
										name= "ChangeChalkBoardImage"..tostring(ZAxis),
										type = "client",
										event = "Pug:client:ChangeChalkBoardImage",
										icon = "fa-solid fa-paintbrush",
										label = Config.LangT["ChangeImage"],
										canInteract = function(entity)
											return IsPlayerJob(ThisJob)
										end,
										args = Data,
										distance = 2.0
									},
								})
							else
								exports[Config.Target]:AddTargetModel(tostring(v.Prop), {
									options = {
										{
											type = "client",
											action = function()
												local Data = {
													Business = v.Business,
													Prop = v.Prop,
												}
												TriggerEvent("Pug:client:ChangeChalkBoardImage", Data)
											end,
											canInteract = function(entity)
												return IsPlayerJob(ThisJob)
											end,
											icon = "fa-solid fa-paintbrush",
											label = Config.LangT["ChangeImage"],
										},
									},
									distance = 2.0    
								})
							end
						end
					end
				end
			elseif #(GetEntityCoords(PlayerPedId()) - vector3(v.Coords.x, v.Coords.y, v.Coords.z)) <= Config.TVSpawnDistance and v.Prop == "prop_tv_flat_michael" then
				if not PropPlacements[k].Spawned then
					local ZAxis = v.Coords.z
					if v.Prop == "gr_prop_gr_bench_03a" then
						ZAxis = ZAxis-1.44
					elseif v.Prop == "prop_b_board_blank" or v.Prop == "prop_tv_flat_michael" then
						ZAxis = ZAxis-0.53
					end
					LoadModel(v.Prop)
					PropPlacements[k].Spawned = CreateObject(GetHashKey(v.Prop), vector3(v.Coords.x,v.Coords.y,ZAxis))
					while not DoesEntityExist(PropPlacements[k].Spawned) do Wait(100) end
					SetEntityHeading(PropPlacements[k].Spawned, v.Heading)
					FreezeEntityPosition(PropPlacements[k].Spawned, true)
					if Config.Target == "ox_target" then
						local Data = {
							Business = v.Business,
							Prop = v.Prop,
						}
						exports.ox_target:addLocalEntity(PropPlacements[k].Spawned, {
							{
								name= "ChangeChalkBoardImage"..tostring(ZAxis),
								type = "client",
								event = "Pug:client:ChangeChalkBoardImage",
								icon = "fa-solid fa-paintbrush",
								label = Config.LangT["ChangeImage"],
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								args = Data,
								distance = 2.0
							},
							{
								name= "UseMouseOnTv"..tostring(ZAxis),
								type = "client",
								event = "Pug:client:UseMouseOnTv",
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								icon = "fa-solid fa-computer-mouse",
								label = Config.LangT["UseMouse"],
								args = Data,
								distance = 2.0
							},
						})
					else
						exports[Config.Target]:AddTargetModel(tostring(v.Prop), {
							options = {
								{
									type = "client",
									action = function()
										local Data = {
											Business = v.Business,
											Prop = v.Prop,
										}
										TriggerEvent("Pug:client:ChangeChalkBoardImage", Data)
									end,
									canInteract = function(entity)
										return IsPlayerJob(ThisJob)
									end,
									icon = "fa-solid fa-paintbrush",
									label = Config.LangT["ChangeImage"],
								},
								{
									type = "client",
									event = "Pug:client:UseMouseOnTv",
									canInteract = function(entity)
										return IsPlayerJob(ThisJob)
									end,
									icon = "fa-solid fa-computer-mouse",
									label = Config.LangT["UseMouse"],
								},
							},
							distance = 2.0    
						})
					end
				end
			else
				if PropPlacements[k].Spawned then
					if PropPlacements[k].Prop == "prop_tv_flat_michael" or PropPlacements[k].Prop == "prop_b_board_blank" then
						ChangeChalkBoardImage("none", tostring(PropPlacements[k].Prop))
					end
					if DoesEntityExist(PropPlacements[k].Spawned) then
						TriggerEvent("FullyDeleteBusinessEntity",PropPlacements[k].Spawned)
					end
					PropPlacements[k].Spawned = nil
				end
			end
		end
	end
end)
------------------------------

---------- [PED PLACEMENTS] ----------
RegisterNetEvent("Pug:client:CreateAllTargetspeds", function(Data, Bool)
	local ThisJob = Data["job"]
	for k, v in pairs(Data) do
		if tostring(k) == "peds" then
			local TableToRun = PedPlacements
			if Bool then
				TableToRun = json.decode(Data["peds"])
			end
			for u, i in pairs(TableToRun) do
				if Bool then
					local Info = i
					CurrentObject = CreatePed(2, GetHashKey(Info.Animation), object,vector3(Info.Target.x,Info.Target.y,Info.Target.z))
					if DoesEntityExist(ClosestObject) then
						TriggerEvent("FullyDeleteBusinessEntity", ClosestObject)
					end
				else
					if tostring(i.job) == tostring(ThisJob) then
						if DoesEntityExist(i.ped) then
							TriggerEvent("FullyDeleteBusinessEntity", i.ped)
							PedPlacements[ThisJob..u] = nil
						end
					end
				end
			end
		end
	end
	for k, v in pairs(Data) do
		if tostring(k) == "peds" then
			for u, i in pairs(json.decode(Data["peds"])) do
				local Info = i
				LoadModel(Info.Model)
				PedPlacements[ThisJob..u] = {
					ped = CreatePed(2, Info.Model,  vector3(Info.Target.x,Info.Target.y,Info.Target.z)),
					job = ThisJob,
				}
				SetEntityHeading(PedPlacements[ThisJob..u].ped, Info.Heading)
				FreezeEntityPosition(PedPlacements[ThisJob..u].ped, true)
				SetPedFleeAttributes(PedPlacements[ThisJob..u].ped, 0, 0)
				SetPedDiesWhenInjured(PedPlacements[ThisJob..u].ped, false)
				SetPedKeepTask(PedPlacements[ThisJob..u].ped, true)
				SetBlockingOfNonTemporaryEvents(PedPlacements[ThisJob..u].ped, true)
				SetEntityInvincible(PedPlacements[ThisJob..u].ped, true)
				if Info.Animation ~= nil then
					if not Info.Animation.IsScenario then
						loadAnimDict(Info.Animation.AnimDict)
						PlayAnimation(Info.Animation.AnimDict, Info.Animation.AnimAction, PedPlacements[ThisJob..u].ped)
					else
						ClearPedTasksImmediately(PedPlacements[ThisJob..u].ped)
						DestroyAllProps()
						TaskStartScenarioInPlace(PedPlacements[ThisJob..u].ped, Info.Animation.AnimDict, 0, false)
					end
				end
			end
		end
	end
end)
------------------------------

---------- [BUSINESS ZONES] ----------
RegisterNetEvent("Pug:client:CreateAllTargetszone", function(Data, Bool)
	local ThisJob = Data["job"]
	for k, v in pairs(Data) do
		if tostring(k) == "zone" then
			local TableToRun = ZoneLocations
			if Bool then
				TableToRun = json.decode(Data["zone"])
			end
			for _, i in pairs(TableToRun) do
				if Bool then
				else
					if i.name == ThisJob then
						ZoneLocations[i.name]:destroy()
						ZoneLocations[i.name] = nil
					end
				end
			end
		end
	end
	for k, v in pairs(Data) do
		if tostring(k) == "zone" then
			for u, i in pairs(json.decode(Data["zone"])) do
				local Info = i
				if Info.Target ~= nil then
					if Info.Target[1] ~= nil then
						ZoneLocations[Info.Business] = PolyZone:Create(Info.Target, { 
							name = tostring(Info.Business),
							minZ = Info.Target[1].z - Info.MinZ,
							maxZ = Info.Target[1].z + Info.MaxZ,
							debugPoly = Config.Debug,
						})
						ZoneLocations[Info.Business]:onPlayerInOut(function(isPointInside)
							if isPointInside then
								if Info.Business ==  ZoneLocations[Info.Business].name then
									BusinessNotify("Entered "..  ZoneLocations[Info.Business].name, 'success')
								end
							else
								if Info.Business ==  ZoneLocations[Info.Business].name then
									if Framework == "QBCore" then
										if Config.FrameworkFunctions.GetPlayer(true, false, true).PlayerData.job.onduty then
											if Config.FrameworkFunctions.GetPlayer(true, false, true).PlayerData.job.name == tostring(Info.Business) then
												TriggerServerEvent("QBCore:ToggleDuty")
											end
										end
									end
									BusinessNotify("Exited "..  ZoneLocations[Info.Business].name, 'error')
								end
							end
						end)
					end
				end
			end
		end
	end
end)
------------------------------

---------- [CHALKBOARD TEXTURE] ----------
RegisterNetEvent("Pug:client:CreateAllTargetswhiteboard", function(Data, Bool, Changed, Upgrades)
	if Changed then
		local Updated
		for key, v in pairs(WhiteboardTexture) do
			if Changed == v.Prop then
				local Info = Data
				if Info.Prop == Changed then
					if #(vector3(v.Coords.x, v.Coords.y, v.Coords.z) - vector3(Info.Target.x, Info.Target.y, Info.Target.z)) <= 4.0 then
						WhiteboardTexture[key] = {
							Coords = Info.Target, 
							UrlLink = Info.UrlLink,
							Prop = Info.Prop,
							Spawned = false,
						}
						Updated = true
					end
				end
			end
		end
		if not Updated then
			for _, v in pairs(Upgrades) do
				local Info = v
				if Info.Prop == Changed then
					WhiteboardTexture[#WhiteboardTexture+1] = {
						Coords = Info.Target, 
						UrlLink = Info.UrlLink,
						Prop = Info.Prop,
						Spawned = false,
					}
					break
				end
			end
		end
	else
		for k, _ in pairs(Data) do
			if tostring(k) == "whiteboard" then
				local Table
				if Bool then
					Table = json.decode(Data["whiteboard"])
				else
					Table = Data
				end
				for _, i in pairs(Table) do
					local Info = i
					WhiteboardTexture[#WhiteboardTexture+1] = {
						Coords = Info.Target, 
						UrlLink = Info.UrlLink,
						Prop = Info.Prop,
						Spawned = false,
					}
				end
			end
		end
	end
end)

CreateThread(function()
	while true do
		for k, v in pairs(WhiteboardTexture) do
			if not (v.Prop == "prop_tv_flat_michael") and #(GetEntityCoords(PlayerPedId()) - vector3(v.Coords.x, v.Coords.y, v.Coords.z)) <= Config.TVSpawnDistance then
				if not WhiteboardTexture[k].Spawned then
					ChangeChalkBoardImage(tostring(v.UrlLink), v.Prop)
					WhiteboardTexture[k].Spawned = tostring(v.UrlLink)
				end
			elseif #(GetEntityCoords(PlayerPedId()) - vector3(v.Coords.x, v.Coords.y, v.Coords.z)) <= Config.TVSpawnDistance and v.Prop == "prop_tv_flat_michael" then
				if not WhiteboardTexture[k].Spawned then
					print(v.UrlLink,"v.UrlLink")
					print(v.Prop,"v.Prop")
					ChangeChalkBoardImage(tostring(v.UrlLink), v.Prop)
					WhiteboardTexture[k].Spawned = tostring(v.UrlLink)
				end
			elseif WhiteboardTexture[k].Spawned then
				if WhiteboardTexture[k].Spawned == tostring(v.UrlLink) then
					WhiteboardTexture[k].Spawned = nil
				end
			end
		end
		Wait(2000)
	end
end)
------------------------------

---------- [ITEM CREATOR] ----------
RegisterNetEvent("Pug:client:CreateAllTargetsitems", function(Data, Bool)
	local ThisJob = Data["job"]
	for k, v in pairs(Data) do
		if Config.Target == "ox_target" then
			if tostring(k) == "items" then
				local TableToRun = ItemsTargets
				for u, i in pairs(TableToRun) do
					local TargetName = u
					local ActualTargetId = i.id
					if ItemsTargets[TargetName] then
						if i.job == ThisJob then
							exports.ox_target:removeZone(ActualTargetId)
							ItemsTargets[TargetName] = nil
						end
					end
				end
			end
		else
			if tostring(k) == "items" then
				local TableToRun = ItemsTargets
				if Bool then
					TableToRun = json.decode(Data["items"])
				end
				for u, _ in pairs(TableToRun) do
					local TargetName = ThisJob..u..k
					exports[Config.Target]:RemoveZone(TargetName)
				end
			end
		end
	end
	for k, v in pairs(Data) do
		if tostring(k) == "items" then
			for u, i in pairs(json.decode(Data["items"])) do
				local TargetName = ThisJob..u..k
				local Info = i
				if Config.Target == "ox_target" then
					local Data = {
						Info = Info,
					}
					ItemsTargets[TargetName] = exports.ox_target:addSphereZone({
						coords = vector3(Info.Target.x,Info.Target.y,Info.Target.z),
						radius = 0.3,
						debug = Config.Debug,
						options = {
							{
								name= TargetName,
								type = "client",
								event = "Pug:Client:DoBusinessItemsLogic",
								args = Data,
								icon = "fa-solid fa-folder-plus",
								label = Config.LangT["CreateItem"],
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								distance = 2.0
							}
						}
					})
					ItemsTargets[TargetName] = {
						job = ThisJob,
						id = ItemsTargets[TargetName]
					}
				else
					ItemsTargets[u] = v
					exports[Config.Target]:AddBoxZone(TargetName, vector3(Info.Target.x,Info.Target.y,Info.Target.z), 0.4, 0.4, {
						name=TargetName,
						heading=35,
						debugPoly = Config.Debug,
						minZ= Info.Target.z-0.3,
						maxZ= Info.Target.z+0.3,
					}, {
						options = {
							{
								icon = "fa-solid fa-folder-plus",
								label = Config.LangT["CreateItem"],
								event = " ",
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								action = function()
									local Data = {
										args = {
											Info = Info,
										}
									}
									TriggerEvent("Pug:Client:DoBusinessItemsLogic", Data)
								end,
							},
						},
						distance = 2.0
					})
				end
			end
		end
	end
end)
RegisterNetEvent("Pug:Client:DoBusinessItemsLogic", function(Data)
	local Info = Data.args.Info
	if Info.PedCoords ~= nil then
		if Config.HavePlayersWalkToTarget then
			TaskGoStraightToCoord(PlayerPedId(), Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z, 1.0, 20000, 40000.0, 0.5)
			local Count = 0 
			while #(GetEntityCoords(PlayerPedId()) - vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z)) >= 1.1 do Count = Count + 1 Wait(500) if Count >= 4 then return end end
			TaskTurnPedToFaceCoord(PlayerPedId(), vector3(Info.Target.x, Info.Target.y, Info.Target.z))
			Wait(800)
		else
			SetEntityCoords(PlayerPedId(), vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z))
			SetEntityHeading(PlayerPedId(), Info.Heading)
		end
	end
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			loadAnimDict(Info.Animation.AnimDict)
			PlayAnimation(Info.Animation.AnimDict, Info.Animation.AnimAction)
		else
			ClearPedTasksImmediately(PlayerPedId())
			DestroyAllProps()
			TaskStartScenarioInPlace(PlayerPedId(), Info.Animation.AnimDict, 0, false)
		end
	end
	if Config.Input == "ox_lib" then
		local Input2 = {}
		Input2[#Input2+1] = {
			label = Config.LangT["ItemName"],
			name = "name",
			type = "input",
		}
		Input2[#Input2+1] = {
			label = Config.LangT["ItemLabel"],
			name = "label",
			type = "input",
		}
		Input2[#Input2+1] = {
			label = Config.LangT["ItemDescription"],
			name = "description",
			type = "input",
		}
		Input2[#Input2+1] = {
			label = Config.LangT["ItemPNG"],
			name = "url",
			type = "input",
		}
		Input2[#Input2+1] = {
			label = Config.LangT["ItemIncrease"],
			name = "increase",
			type = "slider",
		}
		Input2[#Input2+1] = {
			label = Config.LangT["ItemIncreaseWater"],
			name = "increasewater",
			type = "slider",
		}
		Input2[#Input2+1] = {
			label = Config.LangT["ItemIncreaseStress"],
			name = "increasestress",
			type = "slider",
		}
		Input2[#Input2+1] = {
			label = Config.LangT["ItemIncreaseHealth"],
			name = "increasehealth",
			type = "slider",
		}
		Input2[#Input2+1] = {
			label = Config.LangT["ItemIncreaseArmor"],
			name = "increasearmor",
			type = "slider",
		}
		local animationOptions = {}
		for key, _ in pairs(Config.ItemconsumerAnimation) do
			table.insert(animationOptions, { value = key, label = key:sub(1, 1):upper() .. key:sub(2) })
		end

		Input2[#Input2+1] = {
			label = Config.LangT["ItemAnimation"],
			name = "animation",
			type = "select",
			options = animationOptions,
		}
		Input2[#Input2+1] = {
			label = Config.LangT["ItemWeight"],
			name = "weight",
			type = "slider",
		}
		Input2[#Input2+1] = {
			label = Config.LangT["Unique"],
			name = "unique",
			type = "checkbox",
		}

		local Input = lib.inputDialog(Config.LangT["CreateNewItem"], Input2)

		if Input then 
			local ItemName = tostring(string.lower(Input[1]))
			if not Input[1] then
				ClearPedTasksImmediately(PlayerPedId())
				DestroyAllProps()
				BusinessNotify(Config.LangT["MissingItemName"], "error")
				return
			elseif string.match(ItemName, " ") then
				ClearPedTasksImmediately(PlayerPedId())
				DestroyAllProps()
				BusinessNotify(Config.LangT["NoSpaces"], "error")
				return
			end
			local ItemLabel = tostring(Input[2])
			if not Input[2] then
				ClearPedTasksImmediately(PlayerPedId())
				DestroyAllProps()
				BusinessNotify(Config.LangT["MissingItemLabel"], "error")
				return
			end
			local Description = tostring(Input[3])
			if not Input[3] then
				ClearPedTasksImmediately(PlayerPedId())
				DestroyAllProps()
				BusinessNotify(Config.LangT["MissingDescription"], "error")
				return
			end
			local UrlLink = " "
			if not Config.DontRequireURLImages then
				UrlLink = tostring(Input[4])
				if not Input[4] then
					ClearPedTasksImmediately(PlayerPedId())
					DestroyAllProps()
					BusinessNotify(Config.LangT["MissingUrlLink"], "error")
					return
				end
			end
			local Increase = tonumber(Input[5])
			local IncreaseWater = tonumber(Input[6])
			local IncreaseStress = tonumber(Input[7])
			local IncreaseHealth = tonumber(Input[8])
			local IncreaseArmor = tonumber(Input[9])
			local Animation = Input[10]
			if not Animation then
				BusinessNotify(Config.LangT["MissingAnimationInput"], "error")
				return
			end
			local Weight = Input[11]
			local Unique = Input[12]
			if Config.DontRequireURLImages then
				local ItemInfo = {
					Item = ItemName,
					Label = ItemLabel,
					Description = Description,
					Image = UrlLink,
					Job = Info.Business,
					Increase = tonumber(Increase),
					IncreaseWater = tonumber(IncreaseWater),
					IncreaseStress = tonumber(IncreaseStress),
					IncreaseHealth = tonumber(IncreaseHealth),
					IncreaseArmor = tonumber(IncreaseArmor),
					Animation = Animation,
					Weight = Weight,
					Unique = Unique,
				}
				TriggerServerEvent("Pug:server:CreateNewServerItem", ItemInfo)
			else
				if UrlLink:match("%.png$") or UrlLink:match("%.gif$") then
					local ItemInfo = {
						Item = ItemName,
						Label = ItemLabel,
						Description = Description,
						Image = UrlLink,
						Job = Info.Business,
						Increase = tonumber(Increase),
						IncreaseWater = tonumber(IncreaseWater),
						IncreaseStress = tonumber(IncreaseStress),
						IncreaseHealth = tonumber(IncreaseHealth),
						IncreaseArmor = tonumber(IncreaseArmor),
						Animation = Animation,
						Weight = Weight,
						Unique = Unique,
					}
					TriggerServerEvent("Pug:server:CreateNewServerItem", ItemInfo)
				else
					ClearPedTasksImmediately(PlayerPedId())
					DestroyAllProps()
					BusinessNotify(Config.LangT["NeedsToBePNG"], "error")
				end
			end
		else
			ClearPedTasksImmediately(PlayerPedId())
			DestroyAllProps()
			BusinessNotify(Config.LangT["MissingInput"], "error")
		end
	else
		local Input2 = {
			inputs = {}
		}
		Input2.inputs[#Input2.inputs +1] = {
			text = Config.LangT["ItemName"],
			name = "name",
			type = "text",
			isRequired = true
		}
		
		Input2.inputs[#Input2.inputs +1] = {
			text = Config.LangT["ItemLabel"],
			name = "label",
			type = "text",
			isRequired = true
		}
		
		Input2.inputs[#Input2.inputs +1] = {
			text = Config.LangT["ItemDescription"],
			name = "description",
			type = "text",
			isRequired = true
		}
		
		Input2.inputs[#Input2.inputs +1] = {
			text = Config.LangT["ItemPNG"],
			name = "url",
			type = "text",
			isRequired = true
		}
		
		Input2.inputs[#Input2.inputs +1] = {
			text = Config.LangT["ItemIncrease"],
			name = "increase",
			type = "number",
			isRequired = true
		}
		
		Input2.inputs[#Input2.inputs +1] = {
			text = Config.LangT["ItemIncreaseWater"],
			name = "increasewater",
			type = "number",
			isRequired = true
		}
		
		Input2.inputs[#Input2.inputs +1] = {
			text = Config.LangT["ItemIncreaseStress"],
			name = "increasestress",
			type = "number",
			isRequired = true
		}
		
		Input2.inputs[#Input2.inputs +1] = {
			text = Config.LangT["ItemIncreaseHealth"],
			name = "increasehealth",
			type = "number",
			isRequired = true
		}
		
		Input2.inputs[#Input2.inputs +1] = {
			text = Config.LangT["ItemIncreaseArmor"],
			name = "increasearmor",
			type = "number",
			isRequired = true
		}

		local animationOptions = {}
		for key, _ in pairs(Config.ItemconsumerAnimation) do
			table.insert(animationOptions, { value = key, text = key:sub(1, 1):upper() .. key:sub(2) })
		end
		
		Input2.inputs[#Input2.inputs +1] = {
			text = Config.LangT["ItemAnimation"],
			name = "animation",
			type = "select",
			options = animationOptions,
		}
		
		Input2.inputs[#Input2.inputs +1] = {
			text = Config.LangT["ItemWeight"],
			name = "weight",
			type = "number",
			isRequired = true
		}
		
		Input2.inputs[#Input2.inputs +1] = {
			text = Config.LangT["Unique"],
			name = "unique",
			type = "checkbox",
			options = {
				{ value = "unique", text = "Unique" }
			},
			isRequired = true
		}
		
		local Input = exports[Config.Input]:ShowInput({
			header = Config.LangT["CreateNewItem"],
			submitText = "Submit",
			inputs = Input2.inputs
		})
		Wait(1000)
		if Input then
			local ItemName = tostring(string.lower(Input.name))
			if not ItemName then
				ClearPedTasksImmediately(PlayerPedId())
				DestroyAllProps()
				BusinessNotify(Config.LangT["MissingItemName"], "error")
				return
			end
			if string.match(ItemName, " ") then
				ClearPedTasksImmediately(PlayerPedId())
				DestroyAllProps()
				BusinessNotify(Config.LangT["NoSpaces"], "error")
				return
			end
			local ItemLabel = tostring(Input.label)
			if not ItemLabel then
				ClearPedTasksImmediately(PlayerPedId())
				DestroyAllProps()
				BusinessNotify(Config.LangT["MissingItemLabel"], "error")
				return
			end
			local Description = tostring(Input.description)
			if not Description then
				ClearPedTasksImmediately(PlayerPedId())
				DestroyAllProps()
				BusinessNotify(Config.LangT["MissingDescription"], "error")
				return
			end
			local UrlLink = " "
			if not Config.DontRequireURLImages then
				UrlLink = tostring(Input.url)
				if not UrlLink then
					ClearPedTasksImmediately(PlayerPedId())
					DestroyAllProps()
					BusinessNotify(Config.LangT["MissingUrlLink"], "error")
					return
				end
			end
			local Increase = tonumber(Input.increase) or 15
			local IncreaseWater = tonumber(Input.increasewater) or 0
			local IncreaseStress = tonumber(Input.increasestress) or 0
			local IncreaseHealth = tonumber(Input.increasehealth) or 0
			local IncreaseArmor = tonumber(Input.increasearmor) or 0
			local Weight = tonumber(Input.weight) or 1.0
			local Animation = Input.animation
			local Unique = Input.unique
			if Config.DontRequireURLImages then
				local ItemInfo = {
					Item = ItemName,
					Label = ItemLabel,
					Description = Description,
					Image = UrlLink,
					Job = Info.Business,
					Increase = Increase,
					IncreaseWater = IncreaseWater,
					IncreaseStress = IncreaseStress,
					IncreaseHealth = IncreaseHealth,
					IncreaseArmor = IncreaseArmor,
					Animation = Animation,
					Weight = Weight,
					Unique = Unique,
				}
				TriggerServerEvent("Pug:server:CreateNewServerItem", ItemInfo)
			else
				if Input.url:match("%.png$") or Input.url:match("%.gif$") then
					local ItemInfo = {
						Item = ItemName,
						Label = ItemLabel,
						Description = Description,
						Image = UrlLink,
						Job = Info.Business,
						Increase = Increase,
						IncreaseWater = IncreaseWater,
						IncreaseStress = IncreaseStress,
						IncreaseHealth = IncreaseHealth,
						IncreaseArmor = IncreaseArmor,
						Animation = Animation,
						Weight = Weight,
						Unique = Unique,
					}
					TriggerServerEvent("Pug:server:CreateNewServerItem", ItemInfo)
				else
					ClearPedTasksImmediately(PlayerPedId())
					DestroyAllProps()
					BusinessNotify(Config.LangT["NeedsToBePNG"], "error")
				end
			end
		else
			ClearPedTasksImmediately(PlayerPedId())
			DestroyAllProps()
			BusinessNotify(Config.LangT["MissingInput"], "error")
		end
	end
	ClearPedTasksImmediately(PlayerPedId())
	DestroyAllProps()
end)


------------------------------

---------- [CAR GARAGES] ----------
local function CloseMenuFull()
    if Framework == "QBCore" and Config.Menu == "qb-menu" then
        exports[Config.Menu]:closeMenu()
    end
end

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
local function PugSpawnVehicle(model, cb, coords, isnetworked, teleportInto)
	ClearPedTasksImmediately(PlayerPedId())
	DestroyAllProps()
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
RegisterNetEvent("Pug:client:RemoveAllJobFeatures", function(Job)
	local targets = {
		RegisterTargets,
		TrashCanTargets,
		TrayTargets,
		StorageTargets,
		SeatsTargets,
		DutyTargets,
		BossMenuTargets,
		LockerTargets,
		CookStationTargets,
		AnimationTargets,
		SupplyTargets,
		ItemsTargets,
		GarageTargets,
		ClothingTargets,
	}
	
	for _, targetTable in ipairs(targets) do
		for targetName, targetData in pairs(targetTable) do
			if Config.Target == "ox_target" then
				if targetName and string.find(tostring(targetName), Job) then
					exports.ox_target:removeZone(targetData.id)
				end
			else
				if targetData and string.find(tostring(targetData), Job) then
					local success, Decoded = pcall(function() return json.decode(targetData) end)
					if success and Decoded then
						if type(Decoded) == "table" then
							for i, entry in ipairs(Decoded) do
								if entry.Feature then
									local targetName = tostring(Job .. targetName .. entry.Feature)
									exports[Config.Target]:RemoveZone(targetName)
									targetTable[targetName] = nil
								end
							end
						end
					end
				end
			end
		end
	end
	
	
	if DoesBlipExist(BusinesBlips[Job]) then RemoveBlip(BusinesBlips[Job]) BusinesBlips[Job] = nil Wait(100) end

	for k, v in pairs(PropPlacements) do
		if type(v) == "string" then
			local success, Decoded = pcall(function() return json.decode(v) end)
			if success and Decoded then
				if Decoded.Business == Job then
					if DoesEntityExist(Decoded.Spawned) then
						DeleteEntity(Decoded.Spawned)
					end
					PropPlacements[k] = nil
				end
			end
		elseif v.Business == Job then
			if DoesEntityExist(v.Spawned) then
				DeleteEntity(v.Spawned)
			end
			PropPlacements[k] = nil
		end
	end

	for k, v in pairs(PedPlacements) do
		if type(v) == "string" then
			local success, Decoded = pcall(function() return json.decode(v) end)
			if success and Decoded then
				if Decoded.job == Job then
					if DoesEntityExist(Decoded.ped) then
						DeleteEntity(Decoded.ped)
					end
					PedPlacements[k] = nil
				end
			end
		elseif v.job == Job then
			if DoesEntityExist(v.ped) then
				DeleteEntity(v.ped)
			end
			PedPlacements[k] = nil
		end
	end

	for k, v in pairs(ZoneLocations) do
		if type(v) == "string" then
			local success, Decoded = pcall(function() return json.decode(v) end)
			if success and Decoded then
				if k == Job then
					Decoded:destroy()
					ZoneLocations[k] = nil
				end
			end
		elseif k == Job then
			v:destroy()
			ZoneLocations[k] = nil
		end
	end

	for k, v in pairs(WhiteboardTexture) do
		if type(v) == "string" then
			local success, Decoded = pcall(function() return json.decode(v) end)
			if success and Decoded then
				if Decoded.Prop == Job then
					WhiteboardTexture[k] = nil
				end
			end
		elseif v.Prop == Job then
			WhiteboardTexture[k] = nil
		end
	end

    BusinessNotify("All job features for "..Job.." have been removed.", "success")
end)

local SpawnedCar
RegisterNetEvent("Pug:client:CreateAllTargetsgarage", function(Data, Bool)
	local ThisJob = Data["job"]
	for k, v in pairs(Data) do
		if Config.Target == "ox_target" then
			if tostring(k) == "garage" then
				local TableToRun = GarageTargets
				for u, i in pairs(TableToRun) do
					local TargetName = u
					local ActualTargetId = i.id
					if GarageTargets[TargetName] then
						if i.job == ThisJob then
							exports.ox_target:removeZone(ActualTargetId)
							GarageTargets[TargetName] = nil
						end
					end
				end
			end
		else
			if tostring(k) == "garage" then
				local TableToRun = GarageTargets
				if Bool then
					TableToRun = json.decode(Data["garage"])
				end
				for u, _ in pairs(TableToRun) do
					local TargetName = ThisJob..u..k
					exports[Config.Target]:RemoveZone(TargetName)
				end
			end
		end
	end
	for k, v in pairs(Data) do
		if tostring(k) == "garage" then
			for u, i in pairs(json.decode(Data["garage"])) do
				local TargetName = ThisJob..u..k
				local Info = i
				if Config.Target == "ox_target" then
					local Data = {
						Info = Info,
					}
					GarageTargets[TargetName] = exports.ox_target:addSphereZone({
						coords = vector3(Info.Target.x,Info.Target.y,Info.Target.z),
						radius = 0.3,
						debug = Config.Debug,
						options = {
							{
								name= TargetName,
								type = "client",
								event = "Pug:Client:DoBusinessGarageLogic",
								args = Data,
								icon = "fa-solid fa-car",
								label = Config.LangT["BusinessGarage"],
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								distance = 2.0
							},
							{
								name= TargetName,
								type = "client",
								event = "Pug:Client:DoBusinessDeleteVehicle",
								icon = "fa-solid fa-car-burst",
								label = Config.LangT["PutVehicleAway"],
								canInteract = function(entity)
									return IsPlayerJob(ThisJob) and SpawnedCar
								end,
								distance = 2.0
							},
						}
					})
					GarageTargets[TargetName] = {
						job = ThisJob,
						id = GarageTargets[TargetName]
					}
				else
					GarageTargets[u] = v
					exports[Config.Target]:AddBoxZone(TargetName, vector3(Info.Target.x,Info.Target.y,Info.Target.z), 0.4, 0.4, {
						name=TargetName,
						heading=35,
						debugPoly = Config.Debug,
						minZ= Info.Target.z-0.3,
						maxZ= Info.Target.z+0.3,
					}, {
						options = {
							{
								icon = "fa-solid fa-car",
								label = Config.LangT["BusinessGarage"],
								event = " ",
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								action = function()
									local Data = {
										args = {
											Info = Info,
										}
									}
									TriggerEvent("Pug:Client:DoBusinessGarageLogic", Data)
								end,
							},
							{
								icon = "fa-solid fa-car-burst",
								label = Config.LangT["PutVehicleAway"],
								canInteract = function(entity)
									return IsPlayerJob(ThisJob) and SpawnedCar
								end,
								action = function()
									TriggerEvent("FullyDeleteBusinessEntity", SpawnedCar)
									SpawnedCar = false
								end,
							},
						},
						distance = 2.0
					})
				end
			end
		end
	end
end)
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

RegisterNetEvent("Pug:Client:DoBusinessDeleteVehicle", function()
	if GetResourceState("MrNewbVehicleKeys") == 'started' then
		-- vehicle: This would be the vehicle entity
		exports.MrNewbVehicleKeys:RemoveKeys(SpawnedCar)
	elseif GetResourceState("ak47_vehiclekeys") == 'started' then
		local Plate = tostring(GetVehicleNumberPlateText(SpawnedCar))
		exports['ak47_vehiclekeys']:RemoveKey(Plate)
	elseif GetResourceState("qs-vehiclekeys") == 'started' then
		local Plate = tostring(GetVehicleNumberPlateText(SpawnedCar))
		local Model = GetDisplayNameFromVehicleModel(GetEntityModel(SpawnedCar))
		exports['qs-vehiclekeys']:RemoveKeys(Plate, Model)
	end

	TriggerEvent("FullyDeleteBusinessEntity", SpawnedCar)
	SpawnedCar = false
end)
RegisterNetEvent("Pug:Client:DoBusinessGarageLogic", function(Data)
	local Info = Data.args.Info
	if Info.PedCoords ~= nil then
		if Config.HavePlayersWalkToTarget then
			TaskGoStraightToCoord(PlayerPedId(), Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z, 1.0, 20000, 40000.0, 0.5)
			local Count = 0 
			while #(GetEntityCoords(PlayerPedId()) - vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z)) >= 1.1 do Count = Count + 1 Wait(500) if Count >= 4 then return end end
			TaskTurnPedToFaceCoord(PlayerPedId(), vector3(Info.Target.x, Info.Target.y, Info.Target.z))
			Wait(800)
		else
			SetEntityCoords(PlayerPedId(), vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z))
			SetEntityHeading(PlayerPedId(), Info.Heading)
		end
	end
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			loadAnimDict(Info.Animation.AnimDict)
			PlayAnimation(Info.Animation.AnimDict, Info.Animation.AnimAction)
		else
			ClearPedTasksImmediately(PlayerPedId())
			DestroyAllProps()
			TaskStartScenarioInPlace(PlayerPedId(), Info.Animation.AnimDict, 0, false)
		end
	end
	local ItemOptions = {}
	if Config.Input == "ox_lib" then
		for _, v in ipairs(Info.MenuOption) do
			table.insert(ItemOptions, { value = v, label = v })
		end
	else
		table.insert(ItemOptions, { value = Info.MenuOption, text = Info.MenuOption })
	end
	if Config.Input == "ox_lib" then
		local Input = lib.inputDialog(Config.LangT["ChooseBusinessVehicle"], {
			{
				label = Config.LangT["SelectVehicle"],
				name = "vehicle",
				options = ItemOptions,
				type = "select",
			},
		})
		if Input then
			ClearPedTasksImmediately(PlayerPedId())
			DestroyAllProps()
			local VehicleSelected = tostring(Input[1])
			if not Input[1] then
				ClearPedTasksImmediately(PlayerPedId())
				DestroyAllProps()
				BusinessNotify(Config.LangT["HaveNotChosesVehicle"], "error")
				return
			end
			if IsSpawnPointClear(Info.CarCoods, 5.0) then
				if SpawnedCar then
					TriggerEvent("FullyDeleteBusinessEntity", SpawnedCar)
				end
				PugSpawnVehicle(VehicleSelected, function(veh)
					SpawnedCar = veh
					SetEntityHeading(veh, Info.CarHeading)
					SetVehicleEngineOn(veh, false, false)
					SetVehicleOnGroundProperly(veh)
					SetVehicleNeedsToBeHotwired(veh, false)
					SetVehicleColours(veh, 0, 0)
					SetVehicleNumberPlateText(veh, Info.Business)
					SetVehicleFuelLevel(veh, 100.0)
					SetVehicleDoorsLocked(veh, 0)
					local plate = GetVehicleNumberPlateText(veh)
					if plate then
						GiveVehicleKeys(veh, string.gsub(plate, '^%s*(.-)%s*$', '%1'), VehicleSelected)
					else
						print("^1[ERROR]^0 Failed to get vehicle plate for vehicle:", veh)
					end
					
				end, Info.CarCoods, true)
			else
				ClearPedTasksImmediately(PlayerPedId())
				DestroyAllProps()
				BusinessNotify(Config.LangT["TheAreaIsNotClear"], "error")
			end
		else
			ClearPedTasksImmediately(PlayerPedId())
			DestroyAllProps()
			BusinessNotify(Config.LangT["MissingInput"], "error")
		end
	else
		local Input = exports[Config.Input]:ShowInput({
			header = Config.LangT["ChooseBusinessVehicle"],
			submitText = "Submit",
			inputs = { 
				{
					text = Config.LangT["SelectVehicle"],
					name = "vehicle",
					type = "select",
					options = ItemOptions,
					isRequired = true
				},
			}
		})
		if Input then
			ClearPedTasksImmediately(PlayerPedId())
			DestroyAllProps()
			local VehicleSelected = tostring(Input.vehicle)
			if not VehicleSelected then
				ClearPedTasksImmediately(PlayerPedId())
				DestroyAllProps()
				BusinessNotify(Config.LangT["HaveNotChosesVehicle"], "error")
				return
			end
			if IsSpawnPointClear(Info.CarCoods, 5.0) then
				if SpawnedCar then
					TriggerEvent("FullyDeleteBusinessEntity", SpawnedCar)
				end
				PugSpawnVehicle(VehicleSelected, function(veh)
					SpawnedCar = veh
					SetEntityHeading(veh, Info.CarHeading)
					SetVehicleEngineOn(veh, false, false)
					SetVehicleOnGroundProperly(veh)
					SetVehicleNeedsToBeHotwired(veh, false)
					SetVehicleColours(vehicle, 0, 0)
					SetVehicleNumberPlateText(veh, Info.Business)
					SetVehicleFuelLevel(veh, 100.0)
					SetVehicleDoorsLocked(veh, 0)
					GiveVehicleKeys(veh, string.gsub(GetVehicleNumberPlateText(veh), '^%s*(.-)%s*$', '%1'), VehicleSelected)
				end, Info.CarCoods, true)
			else
				ClearPedTasksImmediately(PlayerPedId())
				DestroyAllProps()
				BusinessNotify(Config.LangT["TheAreaIsNotClear"], "error")
			end
		else
			ClearPedTasksImmediately(PlayerPedId())
			DestroyAllProps()
			BusinessNotify(Config.LangT["MissingInput"], "error")
		end
	end
	Wait(3000)
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			StopAnimTask(PlayerPedId(), Info.Animation.AnimDict, Info.Animation.AnimAction, 1.0)
		else
			ClearPedTasksImmediately(PlayerPedId())
		end
	end
	DestroyAllProps()
end)
------------------------------


local InAnimation
RegisterNetEvent("Pug:client:ClearPedTaskLoopCheck", function()
	if not InAnimation then
		BusinessNotify("[C] TO CANCEL EMOTE", 'success')
		InAnimation = true
		while InAnimation do
			Wait(1)
			if InAnimation then
									-- Z keys						-- C Key						-- X Key
				if IsControlJustPressed(0, 48) or IsControlJustPressed(0, 26) or IsControlJustPressed(0, 73) then
					if Config.InventoryType == "qs-inventory" then
						ClearPedTasksImmediately(PlayerPedId())
					else
						ClearPedTasks(PlayerPedId())
					end
					DestroyAllProps()
					InAnimation = false
					break
				end
			else
				break
			end
		end
	else
		InAnimation = false
	end
end)


-- 2.0 UPDATE
---------- [CLOTHING] ----------
RegisterNetEvent("Pug:client:CreateAllTargetsclothing", function(Data, Bool)
	local ThisJob = Data["job"]
	for k, v in pairs(Data) do
		if Config.Target == "ox_target" then
			if tostring(k) == "clothing" then
				local TableToRun = ClothingTargets
				for u, i in pairs(TableToRun) do
					local TargetName = u
					local ActualTargetId = i.id
					if ClothingTargets[TargetName] then
						if i.job == ThisJob then
							exports.ox_target:removeZone(ActualTargetId)
							ClothingTargets[TargetName] = nil
						end
					end
				end
			end
		else
			if tostring(k) == "clothing" then
				local TableToRun = ClothingTargets
				if Bool then
					TableToRun = json.decode(Data["clothing"])
				end
				for u, _ in pairs(TableToRun) do
					local TargetName = ThisJob..u..k
					exports[Config.Target]:RemoveZone(TargetName)
				end
			end
		end
	end
	for k, v in pairs(Data) do
		if tostring(k) == "clothing" then
			for u, i in pairs(json.decode(Data["clothing"])) do
				local TargetName = ThisJob..u..k
				local Info = i
				if Config.Target == "ox_target" then
					local Data = {
						Info = Info,
						Name = TargetName,
					}
					ClothingTargets[TargetName] = exports.ox_target:addSphereZone({
						coords = vector3(Info.Target.x,Info.Target.y,Info.Target.z),
						radius = 0.3,
						debug = Config.Debug,
						options = {
							{
								name= TargetName,
								type = "client",
								event = "Pug:Client:DoBusinessClothingLogic",
								args = Data,
								icon = "fa-solid fa-clipboard",
								label = Config.LangT["ChangeClothes"],
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								distance = 2.0
							}
						}
					})
					ClothingTargets[TargetName] = {
						job = ThisJob,
						id = ClothingTargets[TargetName]
					}
				else
					ClothingTargets[u] = v
					exports[Config.Target]:AddBoxZone(TargetName, vector3(Info.Target.x,Info.Target.y,Info.Target.z), 0.9, 0.9, {
						name=TargetName,
						heading=35,
						debugPoly = Config.Debug,
						minZ= Info.Target.z-0.5,
						maxZ= Info.Target.z+0.5,
					}, {
						options = {
							{
								icon = "fa-solid fa-clipboard",
								label = Config.LangT["ChangeClothes"],
								event = " ",
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								action = function()
									local Data = {
										args = {
											Info = Info,
											Name = TargetName,
										}
									}
									TriggerEvent("Pug:Client:DoBusinessClothingLogic",Data)
								end,
							},
						},
						distance = 2.0
					})
				end
			end
		end
	end
end)
RegisterNetEvent("Pug:Client:DoBusinessClothingLogic", function(Data)
	local Info = Data.args.Info
	local TargetName = Data.args.Name
	if Config.HavePlayersWalkToTarget then
		TaskGoToCoordAnyMeans(PlayerPedId(), Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z, 1.0, 0, 0, 786603, 0xbf800000)
		local Count = 0 
		while #(GetEntityCoords(PlayerPedId()) - vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z)) >= 1.1 do Count = Count + 1 Wait(500) if Count >= 4 then return end end
		TaskTurnPedToFaceCoord(PlayerPedId(), vector3(Info.Target.x, Info.Target.y, Info.Target.z))
		Wait(800)
	else
		SetEntityCoords(PlayerPedId(), vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z))
		SetEntityHeading(PlayerPedId(), Info.Heading)
	end
	ClearPedTasksImmediately(PlayerPedId())
	DestroyAllProps()
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			loadAnimDict(Info.Animation.AnimDict)
			PlayAnimation(Info.Animation.AnimDict, Info.Animation.AnimAction)
		else
			ClearPedTasksImmediately(PlayerPedId())
			TaskStartScenarioInPlace(PlayerPedId(), Info.Animation.AnimDict, 0, false)
		end
	end
	if GetResourceState("fivem-appearance") == 'started' then
		local Appearance = {
			-- ped = true,
			-- headBlend = true,
			-- faceFeatures = true,
			-- headOverlays = true,
			components = true,
			props = true,
			-- tattoos = true
		}
	
		exports['fivem-appearance']:startPlayerCustomization(function (appearance)
			if (appearance) then
				print('Saved')
			else
				print('Canceled')
			end
		end, Appearance)
	elseif GetResourceState("illenium-appearance") == 'started' then
		TriggerEvent('illenium-appearance:client:openOutfitMenu')
	else
		TriggerEvent("qb-clothing:client:openMenu")
	end
	Wait(5500)
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			StopAnimTask(PlayerPedId(), Info.Animation.AnimDict, Info.Animation.AnimAction, 1.0)
		else
			ClearPedTasksImmediately(PlayerPedId())
		end
	end
	DestroyAllProps()
end)

---------- [STOCK SYSTEM] ----------
RegisterNetEvent("Pug:client:CreateAllTargetsstocking", function(Data, Bool)
	local ThisJob = Data["job"]
	for k, v in pairs(Data) do
		if Config.Target == "ox_target" then
			if tostring(k) == "stocking" then
				local TableToRun = StockingTargets
				for u, i in pairs(TableToRun) do
					local TargetName = u
					local ActualTargetId = i.id
					if StockingTargets[TargetName] then
						if i.job == ThisJob then
							exports.ox_target:removeZone(ActualTargetId)
							StockingTargets[TargetName] = nil
						end
					end
				end
			end
		else
			if tostring(k) == "stocking" then
				local TableToRun = StockingTargets
				if Bool then
					TableToRun = json.decode(Data["stocking"])
				end
				for u, _ in pairs(TableToRun) do
					local TargetName = ThisJob..u..k
					exports[Config.Target]:RemoveZone(TargetName)
				end
			end
		end
	end
	for k, v in pairs(Data) do
		if tostring(k) == "stocking" then
			for u, i in pairs(json.decode(Data["stocking"])) do
				local TargetName = ThisJob..u..k
				local Info = i
				if Config.Target == "ox_target" then
					local Data = {
						Info = Info,
						Name = TargetName,
						job = ThisJob,
					}
					StockingTargets[TargetName] = exports.ox_target:addSphereZone({
						coords = vector3(Info.Target.x,Info.Target.y,Info.Target.z),
						radius = 0.3,
						debug = Config.Debug,
						options = {
							{
								name= TargetName,
								type = "client",
								event = "Pug:Client:DoBusinessStockingLogic",
								args = Data,
								icon = "fa-solid fa-shop",
								label = Config.LangT["ViewShop"],
								distance = 2.0
							}
						}
					})
					StockingTargets[TargetName] = {
						job = ThisJob,
						id = StockingTargets[TargetName]
					}
				else
					StockingTargets[u] = v
					exports[Config.Target]:AddBoxZone(TargetName, vector3(Info.Target.x,Info.Target.y,Info.Target.z), 0.9, 0.9, {
						name=TargetName,
						heading=35,
						debugPoly = Config.Debug,
						minZ= Info.Target.z-0.5,
						maxZ= Info.Target.z+0.5,
					}, {
						options = {
							{
								icon = "fa-solid fa-shop",
								label = Config.LangT["ViewShop"],
								event = " ",
								action = function()
									local Data = {
										args = {
											Info = Info,
											Name = TargetName,
											job = ThisJob,
										}
									}
									TriggerEvent("Pug:Client:DoBusinessStockingLogic",Data)
								end,
							},
						},
						distance = 2.0
					})
				end
			end
		end
	end
end)
RegisterNetEvent("Pug:Client:DoBusinessStockingLogic", function(Data)
	local Info = Data.args.Info
	local TargetName = Data.args.Name
	if Config.HavePlayersWalkToTarget then
		TaskGoToCoordAnyMeans(PlayerPedId(), Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z, 1.0, 0, 0, 786603, 0xbf800000)
		local Count = 0 
		while #(GetEntityCoords(PlayerPedId()) - vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z)) >= 1.1 do Count = Count + 1 Wait(500) if Count >= 4 then return end end
		TaskTurnPedToFaceCoord(PlayerPedId(), vector3(Info.Target.x, Info.Target.y, Info.Target.z))
		Wait(800)
	else
		SetEntityCoords(PlayerPedId(), vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z))
		SetEntityHeading(PlayerPedId(), Info.Heading)
	end
	ClearPedTasksImmediately(PlayerPedId())
	DestroyAllProps()
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			loadAnimDict(Info.Animation.AnimDict)
			PlayAnimation(Info.Animation.AnimDict, Info.Animation.AnimAction)
		else
			ClearPedTasksImmediately(PlayerPedId())
			TaskStartScenarioInPlace(PlayerPedId(), Info.Animation.AnimDict, 0, false)
		end
	end
	TriggerEvent("Pug:client:OpenTocingMenu", Data)
	Wait(5500)
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			StopAnimTask(PlayerPedId(), Info.Animation.AnimDict, Info.Animation.AnimAction, 1.0)
		else
			ClearPedTasksImmediately(PlayerPedId())
		end
	end
	DestroyAllProps()
end)

local function getServerTime()
	local Time
    Config.FrameworkFunctions.TriggerCallback('getServerTime', function(serverTime)
		if serverTime then
			Time = serverTime
		end
    end)
	while not Time do Wait(1000) end
	return Time
end

RegisterNetEvent('Pug:client:OpenTocingMenu', function(Data)
	local ostime = getServerTime()
	while not ostime do Wait(1000) end
    local ThisJob = Data.args.job
    local StockedData = Data.args.Info.StockedData
    if Config.Menu == "ox_lib" then
        local menu = {}
		if IsPlayerJob(ThisJob) then
			menu[#menu + 1] = {
				title = "Add items to " .. ThisJob .. " shop",
				description = "Add new items to the shop inventory",
				icon = "fa-solid fa-plus",
				iconColor = "teal",
				iconAnimation = "beat",
				event = "Pug:client:AddItemsToShop",
				arrow = true,
				args = Data 
			}
			if Data.args.Info.money ~= nil then
				menu[#menu + 1] = {
					title = "Collect " .. ThisJob .. " shop money",
					description = "$"..Data.args.Info.money,
					icon = "fa-solid fa-money-bill-transfer",
					iconColor = "green",
					-- iconAnimation = "pulse",
					event = "Pug:client:CollectShopMoney",
					arrow = true,
					args = Data 
				}
			end
		end
		if StockedData then
			for k, v in pairs(StockedData) do
				local Image = 'https://cfx-nui-'..Config.InventoryType..'/html/images/'..GetItemsInformation(v.item, true)
				local Icon = 'https://cfx-nui-'..Config.InventoryType..'/html/images/'..GetItemsInformation(v.item, true)
				if Config.InventoryType == "ox_inventory" then
					Image = 'https://cfx-nui-ox_inventory/web/images/'..GetItemsInformation(v.item, true)
					Icon = 'https://cfx-nui-ox_inventory/web/images/'..GetItemsInformation(v.item, true)
					if not string.find(Image, ".png") then
						Image = Image..".png"
						Icon = Icon..".png"
					end
				elseif Config.InventoryType == "codem-inventory" then
					Image = 'https://cfx-nui-codem-inventory/html/itemimages/'..GetItemsInformation(v.item, true)
					Icon = 'https://cfx-nui-codem-inventory/html/itemimages/'..GetItemsInformation(v.item, true)
				elseif Config.InventoryType == "ak47_qb_inventory" then
					Image = 'https://cfx-nui-'..Config.InventoryType..'/web/build/images/'..GetItemsInformation(v.item, true)
					Icon = 'https://cfx-nui-'..Config.InventoryType..'/web/build/images/'..GetItemsInformation(v.item, true)
				end
				local Durability = ""
				local MainMetaData
				if v.MetaData ~= nil then
					if v.MetaData then
						if v.MetaData.durability ~= nil or v.MetaData.quality ~= nil then
							MainMetaData = v.MetaData
							if Config.InventoryType == "ox_inventory" then
								Durability = " | "..v.MetaData.durability.."% Durability"
								if v.MetaData.degrade ~= nil then
									local degrade = (v.MetaData.degrade * 60)
									local percentage = ((v.MetaData.durability - ostime) * 100) / degrade
									Durability = " | "..math.ceil(percentage).."% Durability"
									
								end
							else 
								if v.MetaData.quality ~= nil then
									Durability = " | "..v.MetaData.quality.."% Durability"
								end
							end
						end
					end
				end
				local progress = (v.quantity / 10.0) * 100 
				menu[#menu + 1] = {
					title =  GetItemsInformation(v.item),
					description = "$" .. v.cost .. " - " .. v.quantity .. " in stock "..Durability,
					image = Image,
					icon = Icon,
					-- iconAnimation = "fade",
					-- arrow = true,
					iconColor = "orange",
					progress = progress,
					event = "Pug:client:BuyShopItems",
					args = {
						item = v.item,
						cost = v.cost,
						quantity = v.quantity,
						MainData = Data.args.Info,
						MetaData = MainMetaData,
					}
				}
			end
		else
			menu[#menu + 1] = {
				title = "No items available",
				description = "No stocked items available for purchase",
			}
		end
        lib.registerContext({
            id = 'shop_menu',
            title = 'Shop Menu',
            options = menu
        })
        lib.showContext('shop_menu')
    else
        local menu = {}

        if IsPlayerJob(ThisJob) then
            menu[#menu + 1] = {
                header = "Add items to shop",
                txt = "Add new items to the shop inventory",
				icon = "fa-solid fa-plus",
                params = {
                    event = "Pug:client:AddItemsToShop",
                    args = Data
                }
            }
            if StockedData then
				if Data.args.Info.money ~= nil then
					menu[#menu + 1] = {
						header = "Collect " .. ThisJob .. " shop money",
						txt = "$"..Data.args.Info.money,
						icon = "fa-solid fa-money-bill-transfer",
						iconColor = "green",
						params = {
							event = "Pug:client:CollectShopMoney",
							args = Data 
						}
					}
				end
            end
        end
		if StockedData then
			for k, v in pairs(StockedData) do
				local itemImage = GetItemsInformation(v.item, true)
				local baseUrl = 'https://cfx-nui-'..Config.InventoryType
				local path = ''
				
				if Config.InventoryType == "ox_inventory" then
					path = '/web/images/'..itemImage
					if not string.find(itemImage, ".png") then
						itemImage = itemImage..".png"
					end
				elseif Config.InventoryType == "codem-inventory" then
					path = '/html/itemimages/'..itemImage
				elseif Config.InventoryType == "ak47_qb_inventory" then
					path = '/web/build/images/'..itemImage
				else
					path = '/html/images/'..itemImage
				end
				
				local Image = baseUrl..path
				local Icon = baseUrl..path
				
				local MainMetaData
				local Durability = ""
				if v.MetaData ~= nil then
					if v.MetaData then
						if v.MetaData.durability ~= nil or v.MetaData.quality ~= nil then
							MainMetaData = v.MetaData
							if Config.InventoryType == "ox_inventory" then
								Durability = " | "..v.MetaData.durability.."% Durability"
								if v.MetaData.degrade ~= nil then
									local degrade = (v.MetaData.degrade * 60)
									local percentage = ((v.MetaData.durability - ostime) * 100) / degrade
									Durability = " | "..math.ceil(percentage).."% Durability"
								end
							else 
								if v.MetaData.quality ~= nil then
									Durability = " | "..v.MetaData.quality.."% Durability"
								end
							end
						end
					end
				end
				menu[#menu + 1] = {
					header = "<img src=nui://"..Config.InventoryType.."/html/images/"..Image.." width=30px onerror='this.onerror=null; this.remove();'>"..GetItemsInformation(v.item),
					txt = "$" .. v.cost .. " - " .. v.quantity .. " in stock "..Durability,
					image = Icon,
					icon = "fa-solid fa-cart-shopping",
					params = {
						event = "Pug:client:BuyShopItems",
						args = {
							item = v.item,
							cost = v.cost,
							quantity = v.quantity,
							MainData = Data.args.Info,
							MetaData = MainMetaData,
						}
					}
				}
			end
		else
			menu[#menu + 1] = {
				header = "No items available",
				txt = "No stocked items available for purchase",
			}
		end
		exports[Config.Menu]:openMenu(menu)
    end
end)

RegisterNetEvent('Pug:client:AddItemsToShop', function(Data)
    local src = source
    local ThisJob = Data.args.job
    local Stored = Data.args.Info.StockedData
    local SharedItem
    if Config.InventoryType == "ox_inventory" then
        SharedItem = exports.ox_inventory:GetPlayerItems()
    elseif Config.InventoryType == "qs-inventory" then
        SharedItem = exports['qs-inventory']:getUserInventory()
    elseif Config.InventoryType == "codem-inventory" then
        SharedItem = exports['codem-inventory']:getUserInventory()
    elseif Framework == "QBCore" then
        SharedItem = FWork.Functions.GetPlayerData().items
    end
    while not SharedItem do Wait(100) end
    local Info = Data.args.Info

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

	local function ItemMetaData(selectedItem)
		if Config.InventoryType == "ox_inventory" then
			local items = exports.ox_inventory:Search('slots', selectedItem)
			if items and #items > 0 then
				return items[1].metadata
			end
		elseif Config.InventoryType == "qs-inventory" then
			local items = exports['qs-inventory']:Search(selectedItem)
			if items then
				if type(items) == "number" then
					return false
				else
					if #items > 0 then
						if items[1].metadata ~= nil then
							return items[1].metadata
						end
					end
				end
			end
		elseif Config.InventoryType == "codem-inventory" then
			for _, item in pairs(SharedItem) do
				if item.name == selectedItem then
					return item.info
				end
			end
		elseif Framework == "QBCore" then
			for _, item in pairs(SharedItem) do
				if item.name == selectedItem then
					return item.info
				end
			end
		end
		return false
	end
	

    if Config.Input == "ox_lib" then
        local items = {}
        for _, item in pairs(SharedItem) do
            table.insert(items, {
                label = item.label,
                value = item.name
            })
        end
        local input = lib.inputDialog('Add Item to Shop', {
            {
                label = 'Select Item',
                name = 'selectedItem',
                type = 'select',
                options = items,
            },
            {
                label = 'Enter Amount',
                name = 'amount',
                type = 'number',
                min = 1,
            },
            {
                label = 'Enter Cost',
                name = 'cost',
                type = 'number',
                min = 0,
            }
        })
        
        if input then
            local selectedItem = input[1]
            local amount = tonumber(input[2])
            local cost = tonumber(input[3])

            if selectedItem and amount and cost then
                if GetPlayerItemCount(selectedItem) >= amount then
                    if Stored then
                        table.insert(Stored, { item = selectedItem, quantity = amount, cost = cost, MetaData = ItemMetaData(selectedItem) })
                    else
                        Stored = { { item = selectedItem, quantity = amount, cost = cost, MetaData = ItemMetaData(selectedItem) } }
                    end

                    local NewInfo = {
                        Business = Info.Business,
                        Feature = "stocking",
                        Target = Info.Target,
                        PedCoords = Info.PedCoords,
                        Animation = Info.Animation,
                        Heading = Info.Heading,
                        StockedData = Stored,
						money = Info.money or 0,
                    }
					BusinessToggleItem(false, tostring(selectedItem), tonumber(amount))
                    TriggerServerEvent("Pug:server:AttemptToRemoveZone", NewInfo)
                    Wait(1000)
                    TriggerServerEvent("Pug:server:AddNewFeatureLocation", NewInfo)
                else
                    BusinessNotify(Config.LangT["NotEnoughItems"], "error")
                end
            else
                BusinessNotify(Config.LangT["NeedToEnterAllFields"], "error")
            end
        else
            BusinessNotify(Config.LangT["Canceled"], "error")
        end
    else
        local items = {}
        for _, item in pairs(SharedItem) do
            table.insert(items, {
                value = item.name,
                text = item.label
            })
        end
        local input = exports[Config.Input]:ShowInput({
            header = 'Add Item to Shop',
            submitText = 'Submit',
            inputs = {
                {
                    text = 'Select Item',
                    name = 'selectedItem',
                    type = 'select',
                    options = items,
                    isRequired = true,
                },
                {
                    text = 'Enter Amount',
                    name = 'amount',
                    type = 'number',
                    min = 1,
                    isRequired = true,
                },
                {
                    text = 'Enter Cost',
                    name = 'cost',
                    type = 'number',
                    min = 0,
                    isRequired = true,
                }
            }
        })
        if input then
            local selectedItem = input.selectedItem
            local amount = tonumber(input.amount)
            local cost = tonumber(input.cost)
            if selectedItem and amount and cost then
                if GetPlayerItemCount(selectedItem) >= amount then
                    if Stored then
                        table.insert(Stored, { item = selectedItem, quantity = amount, cost = cost })
                    else
                        Stored = { { item = selectedItem, quantity = amount, cost = cost } }
                    end

                    local NewInfo = {
                        Business = Info.Business,
                        Feature = "stocking",
                        Target = Info.Target,
                        PedCoords = Info.PedCoords,
                        Animation = Info.Animation,
                        Heading = Info.Heading,
                        StockedData = Stored,
                    }
					BusinessToggleItem(false, tostring(selectedItem), tonumber(amount))
                    TriggerServerEvent("Pug:server:AttemptToRemoveZone", NewInfo)
                    Wait(1000)
                    TriggerServerEvent("Pug:server:AddNewFeatureLocation", NewInfo)
                else
                    BusinessNotify(Config.LangT["NotEnoughItems"], "error")
                end
            else
                BusinessNotify(Config.LangT["NeedToEnterAllFields"], "error")
            end
        else
			BusinessNotify(Config.LangT["Canceled"], "error")
        end
    end
end)
RegisterNetEvent('Pug:client:CollectShopMoney', function(Data)
	TriggerServerEvent("Pug:server:CollectShopMoney", Data)
end)

RegisterNetEvent('Pug:client:BuyShopItems', function(Data)
    local item = Data.item
    local cost = Data.cost
    local quantity = Data.quantity

    if Config.Input == "ox_lib" then
        local input = lib.inputDialog('Buy Item', {
            {
                label = 'Enter Quantity',
                name = 'quantity',
                type = 'number',
                min = 1,
                max = quantity,
            }
        })

        if input then
            local selectedQuantity = tonumber(input[1])

            if selectedQuantity and selectedQuantity <= quantity then
                Data.selectedQuantity = selectedQuantity
                TriggerServerEvent('Pug:server:BuyShopItems', Data)
            else
                BusinessNotify('Invalid quantity selected', 'error')
            end
        else
            BusinessNotify('Purchase cancelled', 'error')
        end
    else
        local input = exports[Config.Input]:ShowInput({
            header = 'Buy Item',
            submitText = 'Submit',
            inputs = {
                {
                    text = 'Enter Quantity',
                    name = 'quantity',
                    type = 'number',
                    min = 1,
                    max = quantity,
                    isRequired = true,
                }
            }
        })

        if input then
            local selectedQuantity = tonumber(input.quantity)

            if selectedQuantity and selectedQuantity <= quantity then
                Data.selectedQuantity = selectedQuantity
                TriggerServerEvent('Pug:server:BuyShopItems', Data)
            else
                BusinessNotify('Invalid quantity selected', 'error')
            end
        else
            BusinessNotify('Purchase cancelled', 'error')
        end
    end
end)


RegisterNetEvent('Pug:client:UpdateBusinessStock', function(NewInfo)
	TriggerServerEvent("Pug:server:AttemptToRemoveZone", NewInfo)
	Wait(100)
	TriggerServerEvent("Pug:server:AddNewFeatureLocation", NewInfo)
end)

------------------------------

---------- [ELEVATORS] ----------
RegisterNetEvent("Pug:client:CreateAllTargetselevator", function(Data, Bool)
	local ThisJob = Data["job"]
	for k, v in pairs(Data) do
		if Config.Target == "ox_target" then
			if tostring(k) == "elevator" then
				local TableToRun = ElevatorTargets
				for u, i in pairs(TableToRun) do
					local TargetName = u
					local ActualTargetId = i.id
					if ElevatorTargets[TargetName] then
						if i.job == ThisJob then
							exports.ox_target:removeZone(ActualTargetId)
							ElevatorTargets[TargetName] = nil
						end
					end
				end
			end
		else
			if tostring(k) == "elevator" then
				local TableToRun = ElevatorTargets
				if Bool then
					TableToRun = json.decode(Data["elevator"])
				end
				for u, _ in pairs(TableToRun) do
					local TargetName = ThisJob..u..k
					exports[Config.Target]:RemoveZone(TargetName)
				end
			end
		end
	end
	for k, v in pairs(Data) do
		if tostring(k) == "elevator" then
			for u, i in pairs(json.decode(Data["elevator"])) do
				local TargetName = ThisJob..u..k
				local Info = i
				if Config.Target == "ox_target" then
					local Data = {
						Info = Info,
						Name = TargetName,
					}
					ElevatorTargets[TargetName] = exports.ox_target:addSphereZone({
						coords = vector3(Info.Target.x,Info.Target.y,Info.Target.z),
						radius = 0.3,
						debug = Config.Debug,
						options = {
							{
								name= TargetName,
								type = "client",
								event = "Pug:Client:DoBusinessElevatorLogic",
								args = Data,
								icon = "fa-solid fa-up-down",
								label = Config.LangT["TakeElevator"],
								distance = 2.0
							}
						}
					})
					ElevatorTargets[TargetName] = {
						job = ThisJob,
						id = ElevatorTargets[TargetName]
					}
				else
					ElevatorTargets[u] = v
					exports[Config.Target]:AddBoxZone(TargetName, vector3(Info.Target.x,Info.Target.y,Info.Target.z), 0.5, 0.5, {
						name=TargetName,
						heading=35,
						debugPoly = Config.Debug,
						minZ= Info.Target.z-0.3,
						maxZ= Info.Target.z+0.3,
					}, {
						options = {
							{
								icon = "fa-solid fa-up-down",
								label = Config.LangT["TakeElevator"],
								event = " ",
								action = function()
									local Data = {
										args = {
											Info = Info,
											Name = TargetName,
										}
									}
									TriggerEvent("Pug:Client:DoBusinessElevatorLogic",Data)
								end,
							},
						},
						distance = 2.0
					})
				end
			end
		end
	end
end)
RegisterNetEvent("Pug:Client:DoBusinessElevatorLogic", function(Data)
	local Info = Data.args.Info
	if Info.PedCoords ~= nil then
		if Config.HavePlayersWalkToTarget then
			TaskGoStraightToCoord(PlayerPedId(), Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z, 1.0, 20000, 40000.0, 0.5)
			local Count = 0 
			while #(GetEntityCoords(PlayerPedId()) - vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z)) >= 1.1 do Count = Count + 1 Wait(500) if Count >= 4 then return end end
			TaskTurnPedToFaceCoord(PlayerPedId(), vector3(Info.Target.x, Info.Target.y, Info.Target.z))
			Wait(800)
		else
			SetEntityCoords(PlayerPedId(), vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z))
			SetEntityHeading(PlayerPedId(), Info.Heading)
		end
	end
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			if Info.Animation.IsNetWorkedScene then
				loadAnimDict(Info.Animation.AnimDict)
				local NetworkScene = NetworkCreateSynchronisedScene(vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z+1), vector3(0.0, 0.0, 0.0), 2, false, true, 1065353216, 0, 1.3)
				NetworkAddPedToSynchronisedScene(PlayerPedId(), NetworkScene, Info.Animation.AnimDict, Info.Animation.AnimAction, 1.5, -4.0, 1, 1, 1148846080, 0)
				NetworkStartSynchronisedScene(NetworkScene)
			else
				loadAnimDict(Info.Animation.AnimDict)
				PlayAnimation(Info.Animation.AnimDict, Info.Animation.AnimAction)
			end
		else
			ClearPedTasksImmediately(PlayerPedId())
			DestroyAllProps()
			TaskStartScenarioInPlace(PlayerPedId(), Info.Animation.AnimDict, 0, false)
		end
	end
	Wait(500)
	PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			StopAnimTask(PlayerPedId(), Info.Animation.AnimDict, Info.Animation.AnimAction, 1.0)
		else
			ClearPedTasksImmediately(PlayerPedId())
		end
	end
	Wait(1500)
	DoScreenFadeOut(500)
	while not IsScreenFadedOut() do
		Wait(0)
	end
	StartPlayerTeleport(PlayerId(), Info.SecondCoords.x, Info.SecondCoords.y, Info.SecondCoords.z, Info.SecondHeading, true, true, true)
	Wait(1000)
	TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, "Shop", 0.4)
	Wait(1000)
	DoScreenFadeIn(500)
	ReloadSkin()
end)
------------------------------

---------- [APPLICATION] ----------
RegisterNetEvent("Pug:client:CreateAllTargetsapplication", function(Data, Bool)
    local ThisJob = Data["job"]
    for k, v in pairs(Data) do
        if Config.Target == "ox_target" then
            if tostring(k) == "application" then
                local TableToRun = ApplicationTargets
                for u, i in pairs(TableToRun) do
                    local TargetName = u
                    local ActualTargetId = i.id
                    if ApplicationTargets[TargetName] then
                        if i.job == ThisJob then
                            exports.ox_target:removeZone(ActualTargetId)
                            ApplicationTargets[TargetName] = nil
                        end
                    end
                end
            end
        else
            if tostring(k) == "application" then
                local TableToRun = ApplicationTargets
                if Bool then
                    TableToRun = json.decode(Data["application"])
                end
                for u, _ in pairs(TableToRun) do
                    local TargetName = ThisJob..u..k
                    exports[Config.Target]:RemoveZone(TargetName)
                end
            end
        end
    end
    for k, v in pairs(Data) do
        if tostring(k) == "application" then
            for u, i in pairs(json.decode(Data["application"])) do
                local TargetName = ThisJob..u..k
                local Info = i
                if Config.Target == "ox_target" then
                    local Data = {
                        Info = Info,
                        Name = TargetName,
                    }
                    ApplicationTargets[TargetName] = exports.ox_target:addSphereZone({
                        coords = vector3(Info.Target.x,Info.Target.y,Info.Target.z),
						radius = 0.3,
                        debug = Config.Debug,
                        options = {
                            {
                                name= TargetName,
                                type = "client",
                                event = "Pug:Client:DoBusinessApplicationLogic",
                                args = Data,
                                icon = "fa-solid fa-school-circle-check",
                                label = string.upper(ThisJob).." "..string.upper(Config.LangT["Application"]),
                                distance = 2.0
                            }
                        }
                    })
                    ApplicationTargets[TargetName] = {
                        job = ThisJob,
                        id = ApplicationTargets[TargetName]
                    }
                else
                    ApplicationTargets[u] = v
                    exports[Config.Target]:AddBoxZone(TargetName, vector3(Info.Target.x,Info.Target.y,Info.Target.z), 0.5, 0.5, {
                        name=TargetName,
                        heading=35,
                        debugPoly = Config.Debug,
                        minZ= Info.Target.z-0.3,
                        maxZ= Info.Target.z+0.3,
                    }, {
                        options = {
                            {
                                icon = "fa-solid fa-school-circle-check",
                                label = string.upper(ThisJob).." "..string.upper(Config.LangT["Application"]),
                                event = " ",
                                action = function()
                                    local Data = {
                                        args = {
                                            Info = Info,
                                            Name = TargetName,
                                        }
                                    }
                                    TriggerEvent("Pug:Client:DoBusinessApplicationLogic",Data)
                                end,
                            },
                        },
                        distance = 2.0
                    })
                end
            end
        end
    end
end)

RegisterNetEvent("Pug:Client:DoBusinessApplicationLogic", function(Data)
    if not Data or not Data.args or not Data.args.Info then
        return
    end

    local Info = Data.args.Info
    local ThisJob = Data.args.Info.Business

    if Info.PedCoords ~= nil then
		if Config.HavePlayersWalkToTarget then
			TaskGoStraightToCoord(PlayerPedId(), Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z, 1.0, 20000, 40000.0, 0.5)
			local Count = 0 
			while #(GetEntityCoords(PlayerPedId()) - vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z)) >= 1.1 do Count = Count + 1 Wait(500) if Count >= 4 then return end end
			TaskTurnPedToFaceCoord(PlayerPedId(), vector3(Info.Target.x, Info.Target.y, Info.Target.z))
			Wait(800)
		else
			SetEntityCoords(PlayerPedId(), vector3(Info.PedCoords.x, Info.PedCoords.y, Info.PedCoords.z))
        	SetEntityHeading(PlayerPedId(), Info.Heading)
		end
    end

    if Info.Animation ~= nil then
        if not Info.Animation.IsScenario then
            loadAnimDict(Info.Animation.AnimDict)
            TaskPlayAnim(PlayerPedId(), Info.Animation.AnimDict, Info.Animation.AnimAction, 8.0, -8.0, -1, 1, 0, false, false, false)
        else
            ClearPedTasksImmediately(PlayerPedId())
            TaskStartScenarioInPlace(PlayerPedId(), Info.Animation.AnimDict, 0, false)
        end
    end

    local menu = {}

    if IsPlayerJob(ThisJob) then
        if Config.Menu == "ox_lib" then
            menu[#menu + 1] = {
                title = "Edit Application",
                description = "Modify the application details",
                icon = "fa-solid fa-pencil-alt",
                iconColor = "teal",
                -- iconAnimation = "beat",
                event = "Pug:Client:EditApplication",
                args = Data
            }
            menu[#menu + 1] = {
                title = "View Applications",
                description = "Accept/Decline Applicants",
                icon = "fa-solid fa-file-alt",
                iconColor = "green",
                -- iconAnimation = "beat",
                event = "Pug:Client:ViewApplicationDetails",
                args = Data
            }
        else
            menu[#menu + 1] = {
                header = "Edit Application",
                txt = "Modify the application details",
                icon = "fa-solid fa-pencil-alt",
                params = {
                    event = "Pug:Client:EditApplication",
                    args = Data
                }
            }
            menu[#menu + 1] = {
                header = "View Applications",
                txt = "Accept/Decline Applicants",
                icon = "fa-solid fa-file-alt",
                params = {
                    event = "Pug:Client:ViewApplicationDetails",
                    args = Data
                }
            }
        end
    end

    if Config.Menu == "ox_lib" then
        menu[#menu + 1] = {
            title = "Take Application",
            description = "Start the application process",
			icon = "fa-solid fa-file-signature",
            iconColor = "orange",
            -- iconAnimation = "beat",
            event = "Pug:Client:TakeApplication",
            args = Data
        }

        lib.registerContext({
            id = 'application_menu',
            title = 'Application Menu',
            options = menu
        })
        lib.showContext('application_menu')
    else
        menu[#menu + 1] = {
            header = "Take Application",
            txt = "Start the application process",
            icon = "fa-solid fa-file-signature",
            params = {
                event = "Pug:Client:TakeApplication",
                args = Data
            }
        }

		exports[Config.Menu]:openMenu(menu)
    end
	Wait(3000)
	if Info.Animation ~= nil then
		if not Info.Animation.IsScenario then
			StopAnimTask(PlayerPedId(), Info.Animation.AnimDict, Info.Animation.AnimAction, 1.0)
		else
			ClearPedTasksImmediately(PlayerPedId())
		end
	end
end)

RegisterNetEvent("Pug:Client:EditApplication", function(Data)
    if not Data or not Data.args or not Data.args.Info then
        return
    end

    local job = Data.args.Info.Business
    local applicationData = Data.args.Info.ApplicationData or {}
    local menu = {}

    for i, question in ipairs(applicationData) do
        if Config.Menu == "ox_lib" then
            menu[#menu + 1] = {
                title = "Question #" .. i,
                description = question.question,
				icon = "fa-solid fa-pen-to-square",
				iconColor = "teal",
                event = "Pug:Client:EditQuestion",
                args = { index = i, data = Data }
            }
        else
            menu[#menu + 1] = {
                header = "Question #" .. i,
				icon = "fa-solid fa-pen-to-square",
				iconColor = "teal",
                txt = question.question,
                params = {
                    event = "Pug:Client:EditQuestion",
                    args = { index = i, data = Data }
                }
            }
        end
    end

    if Config.Menu == "ox_lib" then
        menu[#menu + 1] = {
            title = "Add Question",
            description = "Add a new question to the application",
			iconColor = "green",
			icon = "fa-solid fa-plus",
            event = "Pug:Client:AddQuestion",
            args = Data
        }

        menu[#menu + 1] = {
            title = "Back",
            description = "",
            event = "Pug:Client:DoBusinessApplicationLogic",
            args = Data
        }

        lib.registerContext({
            id = 'edit_application_menu',
            title = 'Edit Application',
            options = menu
        })
        lib.showContext('edit_application_menu')
    else
        menu[#menu + 1] = {
            header = "Add Question",
			icon = "fa-solid fa-plus",
			iconColor = "green",
            txt = "Add a new question to the application",
            params = {
                event = "Pug:Client:AddQuestion",
                args = Data
            }
        }
        menu[#menu + 1] = {
            header = "Back",
            txt = "",
            params = {
                event = "Pug:Client:DoBusinessApplicationLogic",
                args = Data
            }
        }

		exports[Config.Menu]:openMenu(menu)
    end
end)

RegisterNetEvent("Pug:Client:RemoveQuestion", function(Data)
    if not Data or not Data.index or not Data.data then
        print("NO DATA")
        return
    end

    local questionIndex = Data.index
    local applicationData = Data.data.data.args.Info.ApplicationData

    table.remove(applicationData, questionIndex)
    TriggerServerEvent('Pug:server:SaveApplications', Data.data.data.args.Info.Business, applicationData)

    TriggerEvent("Pug:Client:EditApplication", Data.data.data)
end)

RegisterNetEvent("Pug:Client:EditQuestion", function(Data)
    if not Data or not Data.index or not Data.data then
        print("NO DATA")
        return
    end

    local questionIndex = Data.index
    local applicationData = Data.data.args.Info.ApplicationData
    local question = applicationData[questionIndex]
    local menu = {}

    if Config.Menu == "ox_lib" then
        menu[#menu + 1] = {
            title = "Edit Question",
			icon = "fa-solid fa-circle-question",
			iconColor = "teal",
            description = question.question,
            event = "Pug:Client:EditCurrentQuestion",
            args = { index = questionIndex, data = Data }
        }
        menu[#menu + 1] = {
            title = "Edit Answers",
			icon = "fa-solid fa-comment-dots",
			iconColor = "orange",
            description = "Edit the answers for this question",
            event = "Pug:Client:EditAnswers",
            args = { index = questionIndex, data = Data }
        }
		menu[#menu + 1] = {
			title = "Remove Question #" .. questionIndex,
			icon = "fa-solid fa-trash-arrow-up",
			iconColor = "red",
			description = "question",
			event = "Pug:Client:RemoveQuestion",
			args = { index = questionIndex, data = Data }
		}
        menu[#menu + 1] = {
            title = "Back",
            description = "",
            event = "Pug:Client:EditApplication",
            args = Data.data
        }

        lib.registerContext({
            id = 'edit_question_menu',
            title = 'Edit Question',
            options = menu
        })
        lib.showContext('edit_question_menu')
    else
        menu[#menu + 1] = {
            header = "Edit Question",
			icon = "fa-solid fa-circle-question",
            txt = question.question,
            params = {
                event = "Pug:Client:EditCurrentQuestion",
                args = { index = questionIndex, data = Data }
            }
        }
        menu[#menu + 1] = {
            header = "Edit Answers",
			icon = "fa-solid fa-comment-dots",
            txt = "Edit the answers for this question",
            params = {
                event = "Pug:Client:EditAnswers",
                args = { index = questionIndex, data = Data }
            }
        }
		menu[#menu + 1] = {
			header = "Remove Question #" .. questionIndex,
			txt = "Remove this question",
			icon = "fa-solid fa-trash-arrow-up",
			params = {
				event = "Pug:Client:RemoveQuestion",
				args = { index = questionIndex, data = Data }
			}
		}
        menu[#menu + 1] = {
            header = "Back",
            txt = "",
            params = {
                event = "Pug:Client:EditApplication",
                args = Data.data
            }
        }

		exports[Config.Menu]:openMenu(menu)
    end
end)



RegisterNetEvent("Pug:Client:AddQuestion", function(Data)
    if not Data or not Data.args or not Data.args.Info then
        return
    end

    local job = Data.args.Info.Business

    local applicationData = Data.args.Info.ApplicationData or {}

	table.insert(applicationData, { question = 'New Question', answers = {a = 'Answer A', b = 'Answer B', c = 'Answer C', d = 'Answer D', correct = 'a' } })

	Data.args.Info.ApplicationData = applicationData
    TriggerServerEvent('Pug:server:SaveApplications', job, applicationData)

    TriggerEvent("Pug:Client:EditApplication", Data)
end)

RegisterNetEvent("Pug:Client:EditAnswers", function(Data)
    if not Data or not Data.index or not Data.data then
        print("NO DATA")
        return
    end

    local questionIndex = Data.index
    local applicationData = Data.data.data.args.Info.ApplicationData
    local answers = applicationData[questionIndex].answers
    local menu = {}

    if Config.Menu == "ox_lib" then
        for k, v in pairs(answers) do
			if k ~= "correct" then
				menu[#menu + 1] = {
					title = "Answer " .. k,
					icon = "fa-solid fa-circle-question",
					iconColor = "orange",
					description = v,
					event = "Pug:Client:EditSingleAnswer",
					args = { index = questionIndex, key = k, data = Data }
				}
			end
        end
        for k, v in pairs(answers) do
			if k == "correct" then
				menu[#menu + 1] = {
					title = string.upper(k).." Answer",
					description = v,
					icon = "fa-solid fa-check",
					iconColor = "green",
					event = "Pug:Client:EditSingleAnswer",
					args = { index = questionIndex, key = k, data = Data }
				}
			end
        end
        menu[#menu + 1] = {
            title = "Back",
            description = "",
            event = "Pug:Client:EditQuestion",
            args = Data.data
        }

        lib.registerContext({
            id = 'edit_answers_menu',
            title = 'Edit Answers',
            options = menu
        })
        lib.showContext('edit_answers_menu')
    else
        for k, v in pairs(answers) do
			if k ~= "correct" then
				menu[#menu + 1] = {
					header = "Answer " .. k,
					txt = v,
					icon = "fa-solid fa-circle-question",
					params = {
						event = "Pug:Client:EditSingleAnswer",
						args = { index = questionIndex, key = k, data = Data }
					}
				}
			end
        end
        for k, v in pairs(answers) do
			if k == "correct" then
				menu[#menu + 1] = {
					header = string.upper(k).." ANSWER",
					txt = v,
					icon = "fa-solid fa-check",
					params = {
						event = "Pug:Client:EditSingleAnswer",
						args = { index = questionIndex, key = k, data = Data }
					}
				}
			end
        end
        menu[#menu + 1] = {
            header = "Back",
            txt = "",
            params = {
                event = "Pug:Client:EditQuestion",
                args = Data.data
            }
        }

		exports[Config.Menu]:openMenu(menu)
    end
end)


RegisterNetEvent("Pug:Client:EditSingleAnswer", function(Data)
    if not Data or not Data.index or not Data.key or not Data.data then
        print("NO DATA")
        return
    end

    local questionIndex = Data.index
    local answerKey = Data.key
    local applicationData = Data.data.data.data.args.Info.ApplicationData
    local question = applicationData[questionIndex]
    local answer = question.answers[answerKey]

    if Config.Input == "ox_lib" then
        local input
        if answerKey == "correct" then
            local options = {}
            for key, _ in pairs(question.answers) do
                if key ~= "correct" then
                    options[#options + 1] = { value = key, label = key:upper() }
                end
            end

            input = lib.inputDialog('Edit Answer', {
                {
                    label = 'Select Correct Answer',
                    name = 'newAnswer',
                    type = 'select',
                    options = options,
                    placeholder = 'Select the correct answer...'
                }
            })
        else
            input = lib.inputDialog('Edit Answer', {
                {
                    label = 'Edit Answer',
                    name = 'newAnswer',
                    type = 'textarea',
                    default = answer,
                    placeholder = 'Enter the new answer here...'
                }
            })
        end

        if input then
            local newAnswer = input[1]
            if newAnswer and newAnswer ~= "" then
                question.answers[answerKey] = newAnswer
                
                TriggerServerEvent('Pug:server:SaveApplications', Data.data.data.data.args.Info.Business, applicationData)
                TriggerEvent("Pug:Client:EditAnswers", { index = questionIndex, data = Data.data.data })
            else
                BusinessNotify('Invalid answer provided', 'error')
            end
        else
            BusinessNotify('Edit cancelled', 'error')
            TriggerEvent("Pug:Client:EditAnswers", { index = questionIndex, data = Data.data.data })
        end
    else
        if answerKey == "correct" then
            local options = {}
            for key, _ in pairs(question.answers) do
                if key ~= "correct" then
                    options[#options + 1] = { value = key, text = key:upper() }
                end
            end

            local input = exports[Config.Input]:ShowInput({
                header = "Select Correct Answer",
                submitText = "Save",
                inputs = {
                    {
                        text = "Correct Answer",
                        name = "newAnswer",
                        type = "select",
                        options = options
                    }
                }
            })
			if input then
				local newAnswer = input.newAnswer
				if newAnswer and newAnswer ~= "" then
					question.answers[answerKey] = newAnswer
					TriggerServerEvent('Pug:server:SaveApplications', Data.data.data.data.args.Info.Business, applicationData)
					TriggerEvent("Pug:Client:EditAnswers", { index = questionIndex, data = Data.data.data })
				else
					BusinessNotify('Invalid answer provided', 'error')
				end
			else
				BusinessNotify('Edit cancelled', 'error')
				TriggerEvent("Pug:Client:EditAnswers", { index = questionIndex, data = Data.data.data })
			end
        else
			local input = exports[Config.Input]:ShowInput({
                header = "Edit Answer",
                submitText = "Save",
                inputs = {
                    {
                        text = "Answer",
                        name = "newAnswer",
                        type = "text",
                        default = answer
                    }
                }
            })
			if input then
				local newAnswer = input.newAnswer
				if newAnswer and newAnswer ~= "" then
					question.answers[answerKey] = newAnswer
					TriggerServerEvent('Pug:server:SaveApplications', Data.data.data.data.args.Info.Business, applicationData)
					TriggerEvent("Pug:Client:EditAnswers", { index = questionIndex, data = Data.data.data })
				else
					BusinessNotify('Invalid answer provided', 'error')
				end
			else
				BusinessNotify('Edit cancelled', 'error')
				TriggerEvent("Pug:Client:EditAnswers", { index = questionIndex, data = Data.data.data })
			end
        end
    end
end)



RegisterNetEvent("Pug:Client:EditCurrentQuestion", function(Data)
    if not Data or not Data.index or not Data.data then
        print("NO DATA")
        return
    end

    local questionIndex = Data.index
    local applicationData = Data.data.data.args.Info.ApplicationData

    if Config.Input == "ox_lib" then
        local input = lib.inputDialog('Edit Question', {
            {
                label = 'Edit Question',
                name = 'newQuestion',
                type = 'textarea',
                default = applicationData[questionIndex].question,
                placeholder = 'Enter the new question here...',
            }
        })

        if input then
            local newQuestion = input[1]
            if newQuestion and newQuestion ~= "" then
                applicationData[questionIndex].question = newQuestion
                TriggerServerEvent('Pug:server:SaveApplications', Data.data.data.args.Info.Business, applicationData)
                TriggerEvent("Pug:Client:EditApplication", Data.data.data)
            else
                BusinessNotify('Invalid question provided', 'error')
            end
        else
			TriggerEvent("Pug:Client:EditQuestion", Data.data)
            BusinessNotify('Edit cancelled', 'error')
        end
    else
        local input = exports[Config.Input]:ShowInput({
            header = "Edit Question",
            submitText = "Save",
            inputs = {
                {
                    text = "Question",
                    name = "newQuestion",
                    type = "text",
                    default = applicationData[questionIndex].question
                }
            }
		})

		if input then
			local newQuestion = input.newQuestion
			if newQuestion and newQuestion ~= "" then
				applicationData[questionIndex].question = newQuestion
				TriggerServerEvent('Pug:server:SaveApplications', Data.data.data.args.Info.Business, applicationData)
				TriggerEvent("Pug:Client:EditApplication", Data.data.data)
			else
				BusinessNotify('Invalid question provided', 'error')
			end
		else
			TriggerEvent("Pug:Client:EditQuestion", Data.data)
			BusinessNotify('Edit cancelled', 'error')
		end
    end
end)

RegisterNetEvent("Pug:Client:TakeApplication", function(Data)
    if not Data or not Data.args or not Data.args.Info then
        return
    end

    local questions = Data.args.Info.ApplicationData
	local testResults = Data.args.Info.TestResults
	if not questions then BusinessNotify("Application is not available yet...", 'error') return end
	local playerData
	if Framework == "ESX" then
		Config.FrameworkFunctions.TriggerCallback('Pug:server:GetESXPlayerDataBusiness', function(Data)
			if Data then
				playerData = Data
			end
		end)
	else
		playerData = Config.FrameworkFunctions.GetPlayer(true, false, true).PlayerData
	end
	while not playerData do Wait(100) end
	local Taken
	if testResults ~= nil then
		if #testResults >= 1 then
			for _, application in ipairs(testResults) do
				if application.firstName .. " " .. application.lastName == playerData.charinfo.firstname .. " " .. playerData.charinfo.lastname then
					Taken = true
					break
				end
			end
		end
	end
	if Taken then
		BusinessNotify("You already have an application under review...", 'error')
		return
	end
	if GetResourceState("bcs_questionare") == 'started' then
		-- OLD bcs_questionare update
		-- exports['bcs_questionare']:openQuiz({
		-- 	title = 'Application Test For '..string.upper(Data.args.Info.Business),
		-- 	description = 'Complete this test to apply for '..string.upper(Data.args.Info.Business),
		-- 	image = 'JOB',
		-- 	minimum = #questions - 1,
		-- 	shuffle = false,
		-- }, questions, function(correct, questions)
		-- 	BusinessNotify('Test Passed! Correct: '..correct.. " out of "..questions..". Wait for an email from the employer to be hired.", 'success')

		-- 	local applicant = {
		-- 		firstName = playerData.charinfo.firstname,
		-- 		lastName = playerData.charinfo.lastname,
		-- 		citizenID = playerData.charinfo.citizenid,
		-- 		results = { correct = correct, questions = questions },
		-- 		status = "Passed",
		-- 	}

		-- 	table.insert(Data.args.Info.TestResults, applicant)

		
		-- 	TriggerServerEvent('Pug:server:SaveApplications', Data.args.Info.Business, Data.args.Info.ApplicationData, Data.args.Info.TestResults)

		-- end, function(correct, questions)
		-- 	BusinessNotify('Test Failed! Correct: '..correct.. " out of "..questions, 'error')
		-- 	local applicant = {
		-- 		firstName = playerData.charinfo.firstname,
		-- 		lastName = playerData.charinfo.lastname,
		-- 		citizenID = playerData.charinfo.citizenid,
		-- 		results = { correct = correct, questions = questions },
		-- 		status = "Failed",
		-- 	}

		-- 	table.insert(Data.args.Info.TestResults, applicant)

		
		-- 	TriggerServerEvent('Pug:server:SaveApplications', Data.args.Info.Business, Data.args.Info.ApplicationData, Data.args.Info.TestResults)
		-- end)

		-- NEW bcs_questionare update
		local home = {
			minimum = #questions - 1,
			passed = 'Test Passed! Wait for an email from the employer to be hired.',
			failed = 'Test Failed! Better luck next time.',
			title = 'Application Test For '..string.upper(Data.args.Info.Business),
			subtitle = 'Test Application',
			description = 'Complete this test to apply for '..string.upper(Data.args.Info.Business),
			-- image = 'JOB',
		}
	
		local function GenerateQuestions()
			local tempArr = {}
			for i, question in ipairs(questions) do
				local answers = {}
	
				-- Convert the object into an array format and set the `correct` answer
				for key, value in pairs(question.answers) do
					if key ~= "correct" then
						table.insert(answers, {
							id = key,         -- Key becomes the ID (e.g., 'a', 'b', 'c', 'd')
							answer = value,   -- Value is the text for the answer
						})
					end
				end
	
				-- Add the question and answers to the array
				tempArr[#tempArr + 1] = {
					id = i,                        -- Unique ID for the question
					question = question.question,  -- Question text
					answers = answers,             -- Parsed answers as an array
					correct = question.answers.correct, -- Correct answer ID
				}
			end
			return tempArr
		end
	
		local generatedQuestions = GenerateQuestions()
	
	
		-- Start the quiz
		local result = exports['bcs_questionare']:StartQuiz(home, generatedQuestions)
	
		-- Handle the result
		if result then
			local correct = result
			local totalQuestions = #questions
	
			local applicant = {
				firstName = playerData.charinfo.firstname,
				lastName = playerData.charinfo.lastname,
				citizenID = playerData.charinfo.citizenid,
				results = { correct = correct, questions = totalQuestions },
				status = "Passed",
			}
	
			table.insert(Data.args.Info.TestResults, applicant)
	
			TriggerServerEvent('Pug:server:SaveApplications', Data.args.Info.Business, Data.args.Info.ApplicationData, Data.args.Info.TestResults)
		else
			local correct = result
			local totalQuestions = #questions
	
			local applicant = {
				firstName = playerData.charinfo.firstname,
				lastName = playerData.charinfo.lastname,
				citizenID = playerData.charinfo.citizenid,
				results = { correct = correct, questions = totalQuestions },
				status = "Failed",
			}
	
			table.insert(Data.args.Info.TestResults, applicant)
	
			TriggerServerEvent('Pug:server:SaveApplications', Data.args.Info.Business, Data.args.Info.ApplicationData, Data.args.Info.TestResults)
		end

	else
		print("[^3WARNING^7] The 'bcs_questionare' resource is not installed. Follow the readme for instructions on this.")
		BusinessNotify("The 'bcs_questionare' resource is not installed. Follow the readme for instructions on this.", 'error')
	end
end)

RegisterNetEvent("Pug:Client:ViewApplicationDetails", function(Data)
    if not Data or not Data.args or not Data.args.Info then
        return
    end

    local testResults = Data.args.Info.TestResults
    local menu = {}

    if Config.Menu == "ox_lib" then
		if testResults ~= nil then
			if #testResults >= 1 then
				for spot, application in ipairs(testResults) do
					menu[#menu + 1] = {
						title = "Accept ".. application.firstName .. " " .. application.lastName,
						icon = "fa-solid fa-check",
						iconColor = "green",
						description = "Status: " .. application.status,
						event = "Pug:Client:AcceptApplication",
						args = { application = application, Data = Data, Spot = spot }
					}
					menu[#menu + 1] = {
						title = "Reject ".. application.firstName .. " " .. application.lastName,
						description = "",
						iconColor = "red",
						icon = "fa-solid fa-xmark",
						event = "Pug:Client:RejectApplication",
						args = { application = application, Data = Data, Spot = spot }
					}
				end
				menu[#menu + 1] = {
					title = "Back",
					description = "",
					event = "Pug:Client:DoBusinessApplicationLogic",
					args = Data
				}
			else
				menu[#menu + 1] = {
					title = "No Results",
					description = "Nothing...",
					event = "Pug:Client:DoBusinessApplicationLogic",
					args = Data
				}
				menu[#menu + 1] = {
					title = "Back",
					description = "",
					event = "Pug:Client:DoBusinessApplicationLogic",
					args = Data
				}
			end
		else
			menu[#menu + 1] = {
				title = "No Results",
				description = "Nothing...",
				event = "Pug:Client:DoBusinessApplicationLogic",
				args = Data
			}
			menu[#menu + 1] = {
				title = "Back",
				description = "",
				event = "Pug:Client:DoBusinessApplicationLogic",
				args = Data
			}
		end

        lib.registerContext({
            id = 'view_application_details_menu',
            title = 'Application Details',
            options = menu
        })
        lib.showContext('view_application_details_menu')
    else
		if testResults ~= nil then
			if #testResults >= 1 then
				for spot, application in ipairs(testResults) do
					menu[#menu + 1] = {
						header = "Accept ".. application.firstName .. " " .. application.lastName,
						txt = "Status: " .. application.status,
						icon = "fa-solid fa-check",
						params = {
							event = "Pug:Client:AcceptApplication",
							args = { application = application, Data = Data, Spot = spot }
						}
					}
					menu[#menu + 1] = {
						header = "Reject ".. application.firstName .. " " .. application.lastName,
						txt = "Reject this application",
						icon = "fa-solid fa-xmark",
						params = {
							event = "Pug:Client:RejectApplication",
							args = { application = application, Data = Data, Spot = spot }
						}
					}
				end
				menu[#menu + 1] = {
					header = "Back",
					txt = "",
					params = {
						event = "Pug:Client:DoBusinessApplicationLogic",
						args = Data
					}
				}
			else
				menu[#menu + 1] = {
					header = "No Results",
					txt = "Nothing...",
					params = {
						event = "Pug:Client:DoBusinessApplicationLogic",
						args = Data
					}
				}
				menu[#menu + 1] = {
					header = "Back",
					txt = "",
					params = {
						event = "Pug:Client:DoBusinessApplicationLogic",
						args = Data
					}
				}
			end
		else
			menu[#menu + 1] = {
				header = "No Results",
				txt = "Nothing...",
				params = {
					event = "Pug:Client:DoBusinessApplicationLogic",
					args = Data
				}
			}
			menu[#menu + 1] = {
				header = "Back",
				txt = "",
				params = {
					event = "Pug:Client:DoBusinessApplicationLogic",
					args = Data
				}
			}
		end

        exports[Config.Menu]:openMenu(menu)
    end
end)

RegisterNetEvent("Pug:Client:AcceptApplication", function(Data)
    if not Data or not Data.Data.args.Info.TestResults then
        print("NO")
        return
    end

    local application = Data.application

    if Config.Input == "ox_lib" then
        local Input2 = {}
        Input2[#Input2 + 1] = {
            label = "Email Subject",
            name = "subject",
            type = "input",
            default = "Application Accepted"
        }
        Input2[#Input2 + 1] = {
            label = "Email Message",
            name = "message",
            type = "textarea",
            default = "Congratulations! Your application has been accepted to "..Data.Data.args.Info.Business..". Come down to [LOCATION] at [DATE] for your hiring."
        }

        local Input = lib.inputDialog("Send Email to Applicant", Input2)

        if Input then
            local emailData = {
                sender = tostring(Config.FrameworkFunctions.GetPlayer(true, false, true).PlayerData.charinfo.firstname).. " "..tostring(Config.FrameworkFunctions.GetPlayer(true, false, true).PlayerData.charinfo.lastname),
				subject = Input[1],
                message = Input[2]
            }
			if GetResourceState("roadphone") == 'started' then
				-- exports['roadphone']:sendMail(emailData)
			elseif GetResourceState("lb-phone") == 'started' then
				TriggerServerEvent("Pug:Server:SendLbPhoneMailBusiness", tostring(application.citizenID), emailData)
			elseif GetResourceState("qs-smartphone") == 'started' then
				TriggerServerEvent('qs-smartphone:server:sendNewMail', {
					sender = emailData.sender,
					subject = emailData.subject,
					message = emailData.message,
					button = {}
				})
			elseif GetResourceState("okokPhone") == 'started' then
				TriggerServerEvent("Pug:Server:SendOkPhoneMailBusiness", tostring(application.citizenID), emailData)
			elseif GetResourceState("yseries") == 'started' then
        		TriggerServerEvent("Pug:Server:SendyseriesMailBusiness", tostring(application.citizenID), emailData)
			else
				TriggerServerEvent('jpr-phonesystem:server:sendEmail', tostring(application.citizenID), emailData)
				TriggerServerEvent('qb-phone:server:sendNewEventMail', tostring(application.citizenID), emailData)
			end
            
            table.remove(Data.Data.args.Info.TestResults, Data.Spot)

            
            TriggerServerEvent('Pug:server:SaveApplications', Data.Data.args.Info.Business, Data.Data.args.Info.ApplicationData, Data.Data.args.Info.TestResults)
            BusinessNotify('Application accepted and email sent', 'success')
        else
            print("Email input canceled")
        end
    else
        local Input2 = {
            inputs = {}
        }
        Input2.inputs[#Input2.inputs + 1] = {
            text = "Email Subject",
            name = "subject",
            type = "text",
            isRequired = true,
            default = "Application Accepted."
        }
        Input2.inputs[#Input2.inputs + 1] = {
            text = "Email Message",
            name = "message",
            type = "text",
            isRequired = true,
            default = "Congratulations! Your application has been accepted to "..Data.Data.args.Info.Business..". Come down to [LOCATION] at [DATE] for your hiring."
        }

        local Input = exports[Config.Input]:ShowInput({
            header = "Send Email to Applicant",
            submitText = "Submit",
            inputs = Input2.inputs
        })

        if Input then
            local emailData = {
                sender = tostring(Config.FrameworkFunctions.GetPlayer(true, false, true).PlayerData.charinfo.firstname).. " "..tostring(Config.FrameworkFunctions.GetPlayer(true, false, true).PlayerData.charinfo.lastname),
                subject = Input.subject,
                message = Input.message
            }
			if GetResourceState("roadphone") == 'started' then
				-- exports['roadphone']:sendMail(emailData)
			elseif GetResourceState("lb-phone") == 'started' then
				TriggerServerEvent("Pug:Server:SendLbPhoneMailBusiness", tostring(application.citizenID), emailData)
			elseif GetResourceState("qs-smartphone") == 'started' then
				TriggerServerEvent('qs-smartphone:server:sendNewMail', {
					sender = emailData.sender,
					subject = emailData.subject,
					message = emailData.message,
					button = {}
				})
			elseif GetResourceState("okokPhone") == 'started' then
				TriggerServerEvent("Pug:Server:SendOkPhoneMailBusiness", tostring(application.citizenID), emailData)
			elseif GetResourceState("yseries") == 'started' then
        		TriggerServerEvent("Pug:Server:SendyseriesMailBusiness", tostring(application.citizenID), emailData)
			else
				
				TriggerServerEvent('jpr-phonesystem:server:sendEmail', tostring(application.citizenID), emailData)
				TriggerServerEvent('qb-phone:server:sendNewEventMail', tostring(application.citizenID), emailData)
			end

            table.remove(Data.Data.args.Info.TestResults, Data.Spot)

            TriggerServerEvent('Pug:server:SaveApplications', Data.Data.args.Info.Business, Data.Data.args.Info.ApplicationData, Data.Data.args.Info.TestResults)
            BusinessNotify('Application accepted and email sent', 'success')
        else
            print("Email input canceled")
        end
    end
end)

RegisterNetEvent("Pug:Client:RejectApplication", function(Data)
    if not Data or not Data.Data.args.Info.TestResults then
        print("NO")
        return
    end

    local application = Data.application

    if Config.Input == "ox_lib" then
        local Input2 = {}
        Input2[#Input2 + 1] = {
            label = "Email Subject",
            name = "subject",
            type = "input",
            default = "Application Rejected"
        }
        Input2[#Input2 + 1] = {
            label = "Email Message",
            name = "message",
            type = "textarea",
            default = "We regret to inform you that your application has been rejected for "..Data.Data.args.Info.Business.."."
        }

        local Input = lib.inputDialog("Send Email to Applicant", Input2)

        if Input then
            local emailData = {
                sender = tostring(Config.FrameworkFunctions.GetPlayer(true, false, true).PlayerData.charinfo.firstname).. " "..tostring(Config.FrameworkFunctions.GetPlayer(true, false, true).PlayerData.charinfo.lastname),
                subject = Input[1],
                message = Input[2]
            }

			if GetResourceState("roadphone") == 'started' then
				-- exports['roadphone']:sendMail(emailData)
			elseif GetResourceState("lb-phone") == 'started' then
				TriggerServerEvent("Pug:Server:SendLbPhoneMailBusiness", tostring(application.citizenID), emailData)
			elseif GetResourceState("qs-smartphone") == 'started' then
				TriggerServerEvent('qs-smartphone:server:sendNewMail', {
					sender = emailData.sender,
					subject = emailData.subject,
					message = emailData.message,
					button = {}
				})
			elseif GetResourceState("okokPhone") == 'started' then
				TriggerServerEvent("Pug:Server:SendOkPhoneMailBusiness", tostring(application.citizenID), emailData)
			elseif GetResourceState("yseries") == 'started' then
        		TriggerServerEvent("Pug:Server:SendyseriesMailBusiness", tostring(application.citizenID), emailData)
			else
				TriggerServerEvent('jpr-phonesystem:server:sendEmail', tostring(application.citizenID), emailData)
				TriggerServerEvent('qb-phone:server:sendNewEventMail', tostring(application.citizenID), emailData)
			end

            table.remove(Data.Data.args.Info.TestResults, Data.Spot)

            TriggerServerEvent('Pug:server:SaveApplications', Data.Data.args.Info.Business, Data.Data.args.Info.ApplicationData, Data.Data.args.Info.TestResults)
            BusinessNotify('Application rejected and email sent', 'error')
        else
            print("Email input canceled")
        end
    else
        local Input2 = {
            inputs = {}
        }
        Input2.inputs[#Input2.inputs + 1] = {
            text = "Email Subject",
            name = "subject",
            type = "text",
            isRequired = true,
            default = "Application Rejected"
        }
        Input2.inputs[#Input2.inputs + 1] = {
            text = "Email Message",
            name = "message",
            type = "text",
            isRequired = true,
            default = "We regret to inform you that your application has been rejected for "..Data.Data.args.Info.Business.."."
        }

        local Input = exports[Config.Input]:ShowInput({
            header = "Send Email to Applicant",
            submitText = "Submit",
            inputs = Input2.inputs
        })

        if Input then
            local emailData = {
                sender = tostring(Config.FrameworkFunctions.GetPlayer(true, false, true).PlayerData.charinfo.firstname).. " "..tostring(Config.FrameworkFunctions.GetPlayer(true, false, true).PlayerData.charinfo.lastname), 
                subject = Input.subject,
                message = Input.message
            }

			if GetResourceState("roadphone") == 'started' then
				-- exports['roadphone']:sendMail(emailData)
			elseif GetResourceState("lb-phone") == 'started' then
				TriggerServerEvent("Pug:Server:SendLbPhoneMailBusiness", tostring(application.citizenID), emailData)
			elseif GetResourceState("qs-smartphone") == 'started' then
				TriggerServerEvent('qs-smartphone:server:sendNewMail', {
					sender = emailData.sender,
					subject = emailData.subject,
					message = emailData.message,
					button = {}
				})
			elseif GetResourceState("qs-smartphone-pro") == 'started' then
				TriggerServerEvent('phone:sendNewMail', {
					sender = emailData.sender,
					subject = emailData.subject,
					message = emailData.message,
					button = {}
				})
			elseif GetResourceState("okokPhone") == 'started' then
				TriggerServerEvent("Pug:Server:SendOkPhoneMailBusiness", tostring(application.citizenID), emailData)
			elseif GetResourceState("yseries") == 'started' then
        		TriggerServerEvent("Pug:Server:SendyseriesMailBusiness", tostring(application.citizenID), emailData)
			else
				TriggerServerEvent('jpr-phonesystem:server:sendEmail', tostring(application.citizenID), emailData)
				TriggerServerEvent('qb-phone:server:sendNewEventMail', tostring(application.citizenID), emailData)
			end

            table.remove(Data.Data.args.Info.TestResults, Data.Spot)

            TriggerServerEvent('Pug:server:SaveApplications', Data.Data.args.Info.Business, Data.Data.args.Info.ApplicationData, Data.Data.args.Info.TestResults)
            BusinessNotify('Application rejected and email sent', 'error')
        else
            print("Email input canceled")
        end
    end
end)
------------------------------

---------- [MENUIMAGE] ----------
RegisterNetEvent("Pug:client:CreateAllTargetsmenuimage", function(Data, Bool)
	local ThisJob = Data["job"]
	for k, v in pairs(Data) do
		if Config.Target == "ox_target" then
			if tostring(k) == "menuimage" then
				local TableToRun = MenuimageTargets
				for u, i in pairs(TableToRun) do
					local TargetName = u
					local ActualTargetId = i.id
					if MenuimageTargets[TargetName] then
						if i.job == ThisJob then
							exports.ox_target:removeZone(ActualTargetId)
							MenuimageTargets[TargetName] = nil
						end
					end
				end
			end
		else
			if tostring(k) == "menuimage" then
				local TableToRun = MenuimageTargets
				if Bool then
					TableToRun = json.decode(Data["menuimage"])
				end
				for u, _ in pairs(TableToRun) do
					local TargetName = ThisJob..u..k
					exports[Config.Target]:RemoveZone(TargetName)
				end
			end
		end
	end
	for k, v in pairs(Data) do
		if tostring(k) == "menuimage" then
			for u, i in pairs(json.decode(Data["menuimage"])) do
				local TargetName = ThisJob..u..k
				local Info = i
				if Config.Target == "ox_target" then
					local Data = {
						Info = Info,
						Name = TargetName,
					}
					MenuimageTargets[TargetName] = exports.ox_target:addSphereZone({
						coords = vector3(Info.Target.x,Info.Target.y,Info.Target.z),
						radius = 0.3,
						debug = Config.Debug,
						options = {
							{
								name= TargetName,
								type = "client",
								event = "Pug:Client:ChangeBusinessImage",
								args = Data,
								icon = "fa-solid fa-arrow-right-arrow-left",
								label = Config.LangT["ChangeImage"],
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								distance = 2.0
							},
							{
								name= TargetName,
								type = "client",
								event = "Pug:Client:DoBusinessMenuimageLogic",
								args = Data,
								icon = "fa-solid fa-martini-glass-citrus",
								label = Config.LangT["LookAtMenuimage"],
								distance = 2.0
							}
						}
					})
					MenuimageTargets[TargetName] = {
						job = ThisJob,
						id = MenuimageTargets[TargetName]
					}
				else
					MenuimageTargets[u] = v
					exports[Config.Target]:AddBoxZone(TargetName, vector3(Info.Target.x,Info.Target.y,Info.Target.z), 0.5, 0.5, {
						name=TargetName,
						heading=35,
						debugPoly = Config.Debug,
						minZ= Info.Target.z-0.3,
						maxZ= Info.Target.z+0.3,
					}, {
						options = {
							{
								icon = "fa-solid fa-arrow-right-arrow-left",
								label = Config.LangT["ChangeImage"],
								event = " ",
								canInteract = function(entity)
									return IsPlayerJob(ThisJob)
								end,
								action = function()
									local Data = {
										args = {
											Info = Info,
											Name = TargetName,
										}
									}
									TriggerEvent("Pug:Client:ChangeBusinessImage",Data)
								end,
							},
							{
								icon = "fa-solid fa-martini-glass-citrus",
								label = Config.LangT["LookAtMenuimage"],
								event = " ",
								action = function()
									local Data = {
										args = {
											Info = Info,
											Name = TargetName,
										}
									}
									TriggerEvent("Pug:Client:DoBusinessMenuimageLogic",Data)
								end,
							},
						},
						distance = 2.0
					})
				end
			end
		end
	end
end)
RegisterNetEvent("Pug:Client:DoBusinessMenuimageLogic", function(Data)
	local Info = Data.args.Info
	if Info.Image ~= nil then
		AddPropToPlayer(Config.MagazineProp, 6286, 0.15, 0.03, -0.040, 0.0, 180.0, 90.0, PlayerPedId())
		loadAnimDict("cellphone@")
		TaskPlayAnim(PlayerPedId(), "cellphone@", "cellphone_text_read_base", 2.0, 2.0, -1, 51, 1.0, 0, 0, 0)
		
		SetNuiFocus(true, true)
		SendNUIMessage({
			type = "ShowImage",
			Image = Info.Image,
		})
		while IsNuiFocused() do Wait(100) end
		DestroyAllProps()
		StopAnimTask(PlayerPedId(), "cellphone@", "cellphone_text_read_base", 1.0)
	else
		BusinessNotify('NO IMAGE', 'error')
	end
end)
RegisterNetEvent("Pug:Client:ChangeBusinessImage", function(Data)
	local Info = Data.args.Info
	if Config.Input == "ox_lib" then
        local Input2 = {}
        Input2[#Input2 + 1] = {
            label = "Image Link - (Use fivemanage.com/upload)",
            name = "subject",
            type = "input",
			default = Info.Image or " "
        }
		local Input = lib.inputDialog("Change Menu Image", Input2)

        if Input then
			local Image = Input[1]
			local NewInfo = {
				Business = Info.Business,
				Feature = "menuimage",
				Target = Info.Target,
				PedCoords = Info.PedCoords,
				Animation = Info.Animation,
				Heading = Info.Heading,
				Image = Input[1],
			}
			TriggerServerEvent("Pug:server:AttemptToRemoveZone", NewInfo)
			Wait(500)
			TriggerServerEvent("Pug:server:AddNewFeatureLocation", NewInfo)
            BusinessNotify('Image Updated', 'success')
        end
	else
        local Input2 = {
            inputs = {}
        }
        Input2.inputs[#Input2.inputs + 1] = {
            text = "Image Link",
            name = "subject",
            type = "text",
            isRequired = true,
            default = Info.Image or " "
        }
        local Input = exports[Config.Input]:ShowInput({
            header = "Change Image",
            submitText = "Submit",
            inputs = Input2.inputs
        })

        if Input then
			local Image = Input.subject
			local NewInfo = {
				Business = Info.Business,
				Feature = "menuimage",
				Target = Info.Target,
				PedCoords = Info.PedCoords,
				Animation = Info.Animation,
				Heading = Info.Heading,
				Image = Input[1],
			}
			TriggerServerEvent("Pug:server:AttemptToRemoveZone", NewInfo)
			Wait(500)
			TriggerServerEvent("Pug:server:AddNewFeatureLocation", NewInfo)
            BusinessNotify('Image Updated', 'success')
		end
	end
end)
------------------------------