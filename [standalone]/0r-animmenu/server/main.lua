RegisterNetEvent('0resmon-animmenu:sendAnimRequest:server', function(data)
    TriggerClientEvent('0resmon-animmenu:receiveAnimRequest:client', data.id, data)
end)

RegisterNetEvent('0resmon-animmenu:playAnimTogetherSender:server', function(data)
    local id = data.data.target
    if data.target then
        id = data.target
    end
    TriggerClientEvent('0resmon-animmenu:playAnimTogetherSender:client', id, data)
end)

RegisterNetEvent('0resmon-animmenu:playAnimTogetherSender2:server', function(data)
    local id = data.data.target
    if data.target then
        id = data.target
    end
    TriggerClientEvent('0resmon-animmenu:playAnimTogetherSender2:client', id, data)
end)

RegisterNetEvent('0resmon-animmenu:requstCanelledNotif:server', function(target)
    TriggerClientEvent('0resmon-animmenu:requstCanelledNotif:client', target)
end)

RegisterNetEvent('0resmon-animmenu:cancelEmote:server', function(target)
    TriggerClientEvent('0resmon-animmenu:cancelEmote:client', target)
end)

RegisterNetEvent('0resmon-animmenu:animDictLoaded:server', function(target)
    TriggerClientEvent('0resmon-animmenu:animDictLoaded:client', target)
end)

RegisterNetEvent('0resmon-animmenu:ptfxSync:server', function(asset, name, offset, rot, bone, scale, color)
    if type(asset) ~= "string" or type(name) ~= "string" or type(offset) ~= "vector3" or type(rot) ~= "vector3" then
        return
    end
    local srcPlayerState = Player(source).state
    srcPlayerState:set('ptfxAsset', asset, true)
    srcPlayerState:set('ptfxName', name, true)
    srcPlayerState:set('ptfxOffset', offset, true)
    srcPlayerState:set('ptfxRot', rot, true)
    srcPlayerState:set('ptfxBone', bone, true)
    srcPlayerState:set('ptfxScale', scale, true)
    srcPlayerState:set('ptfxColor', color, true)
    srcPlayerState:set('ptfxPropNet', false, true)
    srcPlayerState:set('ptfx', false, true)
end)

RegisterNetEvent("0resmon-animmenu:ptfxSyncProp:server", function(propNet)
    local srcPlayerState = Player(source).state
    if propNet then
        local waitForEntityToExistCount = 0
        while waitForEntityToExistCount <= 100 and not DoesEntityExist(NetworkGetEntityFromNetworkId(propNet)) do
            Wait(10)
            waitForEntityToExistCount = waitForEntityToExistCount + 1
        end
        if waitForEntityToExistCount < 100 then
            srcPlayerState:set('ptfxPropNet', propNet, true)
            return
        end
    end
    srcPlayerState:set('ptfxPropNet', false, true)
end)

Citizen.CreateThread(function()
    -- Find resources that contains "smallresources"
    -- handsup.lua
    local resourceList = {}
    for i = 0, GetNumResources(), 1 do
        local resource_name = GetResourceByFindIndex(i)
        if resource_name and GetResourceState(resource_name) == "started" then
            table.insert(resourceList, resource_name)
        end
    end
    local findedResources = {}
    for k, v in pairs(resourceList) do
        if string.match(v, "smallresources") then
            table.insert(findedResources, v)
        end
    end
    for k, v in pairs(findedResources) do
        local loadedFile = LoadResourceFile(v, "client/handsup.lua")
        if loadedFile ~= nil then
            local resPath = GetResourcePath(v)
            print("^0[^3WARNING^0] " .. GetCurrentResourceName() .. " ^1" .. v .. "/client/handsup.lua ^0file deleted by script.")
            os.remove(resPath .. "/client/handsup.lua")
            Citizen.Wait(500)
            StopResource(v)
            Citizen.Wait(500)
            StartResource(v)
        end
    end
    -- crouchprone.lua
    for k, v in pairs(findedResources) do
        local loadedFile = LoadResourceFile(v, "client/crouchprone.lua")
        if loadedFile ~= nil then
            local resPath = GetResourcePath(v)
            print("^0[^3WARNING^0] " .. GetCurrentResourceName() .. " ^1" .. v .. "/client/crouchprone.lua ^0file deleted by script.")
            os.remove(resPath .. "/client/crouchprone.lua")
            Citizen.Wait(500)
            StopResource(v)
            Citizen.Wait(500)
            StartResource(v)
        end
    end
end)

RegisterNetEvent('0resmon-animmenu:convertCode:server', function(code, type)
    local src = source
    local type = string.lower(type)
    local tableString = "return {" .. code .. "}"
    local loadedFunction, errorMessage = load(tableString)
    if loadedFunction then
        local resultTable = loadedFunction()
        for key, value in pairs(resultTable) do
            if type == "expressions" or type == "walks" then
                local newTableString = '{\n    "' .. value[1] .. '",\n    "' .. key .. '",\n    "' .. string.lower(key) .. '",\n    ' .. 'imageId = "' .. string.lower(key) .. '"\n},'
                TriggerClientEvent('0resmon-animmenu:copyCode:client', src, newTableString)
            elseif type == "dances" then
                local animationOptions = ""
                if value.AnimationOptions then
                    for optKey, optValue in pairs(value.AnimationOptions) do
                        animationOptions = animationOptions .. optKey .. " = " .. tostring(optValue) .. ", "
                    end
                    animationOptions = "{" .. animationOptions .. "}"
                end
                local newTableString = string.format('{\n    "%s",\n    "%s",\n    "%s",\n    "%s",\n    imageId = "%s",\n    AnimationOptions = %s\n},', key, value[3], value[1], value[2], string.lower(key), animationOptions)
                TriggerClientEvent('0resmon-animmenu:copyCode:client', src, newTableString)
            elseif type == "emotes" then
                local animationOptions = ""
                if value.AnimationOptions then
                    for optKey, optValue in pairs(value.AnimationOptions) do
                        animationOptions = animationOptions .. optKey .. " = " .. tostring(optValue) .. ", "
                    end
                    animationOptions = "{" .. animationOptions .. "}"
                end
                local newTableString = string.format('{\n    "%s",\n    "%s",\n    "%s",\n    "%s",\n    imageId = "%s",\n    AnimationOptions = %s\n},', key, value[1], value[2], value[3], string.lower(key), animationOptions)
                print(newTableString)
                TriggerClientEvent('0resmon-animmenu:copyCode:client', src, newTableString)
            end
        end
    else
        print("Error loading code: " .. errorMessage)
    end
end)

-- Citizen.CreateThread(function()
--     Citizen.Wait(500)
--     local path = GetResourcePath(GetCurrentResourceName())
--     local tempfile = io.open(path:gsub('//', '/')..'/'.."test.lua", 'a+')
--     if tempfile then
--         tempfile:close()
--         path = path:gsub('//', '/')..'/'.."test.lua"
--     end
--     local file = io.open(path, 'w') -- 'w' kullanarak eski içeriği temizliyoruz
--     file:write("RES.PropEmotes = {\n")

--     for _, v in pairs(anims) do
--         file:write("    {\n")
--         for i = 1, 4 do
--             file:write(("        '%s',\n"):format(v[i]))
--         end
--         file:write(("        imageId = '%s',\n"):format(v[1]))

--         -- AnimationOptions'u direkt olarak yazdır
--         if v.AnimationOptions then
--             file:write("        AnimationOptions = " .. serializeTable(v.AnimationOptions, 2) .. ",\n")
--         end

--         file:write("    },\n")
--     end

--     file:write("}\n")
--     file:close()
-- end)

-- function serializeTable(tbl, indent)
--     indent = indent or 0
--     local formatting = string.rep("    ", indent)
--     local result = "{\n"

--     for k, v in pairs(tbl) do
--         local key = type(k) == "number" and "" or tostring(k) .. " = "

--         if type(v) == "table" then
--             result = result .. formatting .. "    " .. key .. serializeTable(v, indent + 1) .. ",\n"
--         elseif type(v) == "string" then
--             result = result .. formatting .. "    " .. key .. string.format("'%s'", v) .. ",\n"
--         else
--             result = result .. formatting .. "    " .. key .. tostring(v) .. ",\n"
--         end
--     end

--     return result .. formatting .. "}"
-- end

RegisterNetEvent('0resmon-animmenu:setPedAlpha:server', function(id, alpha)
    TriggerClientEvent("0resmon-animmenu:setPedAlpha:server", -1, id, alpha)
end)