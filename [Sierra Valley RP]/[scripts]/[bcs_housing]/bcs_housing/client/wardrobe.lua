if GetResourceState("ox_lib") == "started" then
	lib.registerContext({
		id = "wardrobe_menu",
		title = locale("wardrobe"),
		onExit = function() end,
		options = {
			{
				title = locale("change_outfit"),
				description = locale("change_description"),
				event = "Housing:wardrobe_change",
			},
			{
				title = locale("delete_outfit"),
				description = locale("delete_description"),
				event = "Housing:wardrobe_delete",
			},
			{
				title = locale("save_outfit"),
				event = "Housing:saveOutfit",
			},
		},
	})
end

RegisterNetEvent('Housing:client:CreateWardrobe', function()
	if not CurrentHome then return end
	local home = Homes[CurrentHome.identifier]

	if home then
		if home.configuration.wardrobes == #home.properties.wardrobes then
			return Notify(locale('housing'), locale('max_wardrobes'), 'error', 3000)
		end
		local input = lib.inputDialog(locale('wardrobe') .. ' ' .. locale('name'),
			{ { label = locale('name'), required = true } })
		if input and input[1] then
			HelpText(true, locale('prompt_add_wardrobe'))
			repeat
				local hit, _, coords = lib.raycast.cam()
				if hit then
					DrawMarker(1, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.5, 255, 0, 0,
						100,
						false, false, 2, false, nil, nil, false)
				end
				if IsControlJustPressed(0, 38) and hit then
					wardrobe = {
						name = input[1],
						coords = vec4(coords.x, coords.y, coords.z,
							GetEntityHeading(cache.ped))
					}
					HelpText(false)
				end

				if IsControlJustReleased(0, 73) then
					HelpText(false)
					break
				end
			until wardrobe
			TriggerServerEvent('Housing:server:AddWardrobe',
				{ homeId = CurrentHome.identifier, aptId = LocalPlayer.state.CurrentApartment }, wardrobe)
		end
	end
end)

RegisterNUICallback('createWardrobe', function(data, cb)
	local wardrobe
	local home = Homes[data.identifier]

	if home and CurrentHome and CurrentHome.identifier == home.identifier then
		if home.configuration.wardrobes == #home.properties.wardrobes then
			return Notify(locale('housing'), locale('max_wardrobes'), 'error', 3000)
		end
		ToggleNuiFrame(false)
		HelpText(true, locale('prompt_add_wardrobe'))
		repeat
			local hit, _, coords = lib.raycast.cam()
			if hit then
				DrawMarker(1, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.5, 255, 0, 0, 100,
					false, false, 2, false, nil, nil, false)
			end
			if IsControlJustPressed(0, 38) and hit then
				wardrobe = { name = data.name, coords = vec4(coords.x, coords.y, coords.z, GetEntityHeading(cache.ped)) }
				HelpText(false)
			end

			if IsControlJustReleased(0, 73) then
				HelpText(false)
				break
			end
		until wardrobe
		TriggerServerEvent('Housing:server:AddWardrobe',
			{ homeId = data.identifier, aptId = LocalPlayer.state.CurrentApartment }, wardrobe)
	else
		Notify(locale('housing'), locale('incorrect_home'), 'error', 3000)
	end
	cb(1)
end)

RegisterNUICallback('getHomeWardrobes', function(homeId, cb)
	local home = Homes[homeId]
	if home then
		local wardrobes = home.properties.wardrobes
		if home.properties.complex == 'Apartment' and LocalPlayer.state.CurrentApartment then
			wardrobes = Apartments[homeId]:GetWardrobes()
		end
		cb(wardrobes)
	end
end)

RegisterNUICallback('deleteWardrobe', function(data, cb)
	local home = Homes[data.identifier]
	if home then
		TriggerServerEvent('Housing:server:DeleteWardrobe',
			{ homeId = data.identifier, aptId = LocalPlayer.state.CurrentApartment }, data.name)
	end
	cb(1)
end)

RegisterNetEvent('Housing:client:DeleteWardrobe', function(id, name)
	local homeId, aptId = GetHomeAptId(id)
	local home = Homes[homeId]
	if home then
		home:RemoveWardrobe(name, aptId)
	end
end)

RegisterNetEvent('Housing:client:AddWardrobe', function(id, wardrobe)
	local homeId, aptId = GetHomeAptId(id)
	local home = Homes[homeId]
	if home then
		home:AddWardrobe(wardrobe, aptId)
	end
end)

AddEventHandler("Housing:saveOutfit", function()
	lib.hideContext()
	local name = RequestKeyboardInput(locale("outfit_name"), locale("outfit_desc"), 16)
	if name then
		SaveOutfit(name)
	end
end)

AddEventHandler("Housing:wardrobe_change", function()
	lib.hideContext()
	lib.showMenu("wardrobe_change")
end)

AddEventHandler("Housing:wardrobe_delete", function()
	lib.hideContext()
	lib.showMenu("wardrobe_delete")
end)
