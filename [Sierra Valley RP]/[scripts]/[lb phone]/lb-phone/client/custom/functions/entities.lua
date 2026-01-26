if Config.PropSpawn ~= "state" then
    return
end

---<b>Key:</b> player source
---<br><b>Value:</b> phone object
---@type { [number]: number }
local phoneObjects = {}

local function DeletePlayerPhoneEntity(source)
    if phoneObjects[source] then
        local entity = phoneObjects[source]

        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end

        phoneObjects[source] = nil

        debugprint("Deleted phone entity for source " .. source)
    end
end

---@param source number
local function IsPhoneOpen(source)
    local state = Player(source).state

    if not state.phoneOpen and not state.onCallWith and not state.instapicIsLive then
        return false
    end

    return true
end

---@param source number
---@param ped number
local function SpawnAndAttachPhoneToPlayer(source, ped)
    if phoneObjects[source] then
        debugprint("Phone entity already exists for source " .. source)
        return
    end

    local showPhoneTimer = GetGameTimer() + 500
    local phoneVariation = Player(source).state.lbPhoneVariation
    local itemData = phoneVariation and Config.Item.Names[phoneVariation]
    local phoneModel = itemData and itemData.model or Config.PhoneModel or `prop_amb_phone`
    local rotation = itemData and itemData.rotation or Config.PhoneRotation or vector3(0.0, 0.0, 180.0)
    local offset = itemData and itemData.offset or Config.PhoneOffset or vector3(0.0, -0.005, 0.0)
    local coords = GetEntityCoords(ped)

    LoadModel(phoneModel)

    while showPhoneTimer > GetGameTimer() do
        Wait(0)
    end

    if not IsPhoneOpen(source) then
        debugprint("Player closed phone before it was spawned")
        SetModelAsNoLongerNeeded(phoneModel)
        return
    end

    local phone = CreateObject(phoneModel, coords.x, coords.y, coords.z, false, true, true)

    SetEntityCollision(phone, false, false)
    AttachEntityToEntity(phone, ped, GetPedBoneIndex(ped, 28422), offset.x, offset.y, offset.z, rotation.x, rotation.y, rotation.z, false, false, false, false, 2, true)
    SetModelAsNoLongerNeeded(phoneModel)

    if itemData and itemData.textureVariation then
        SetObjectTextureVariation(phone, itemData.textureVariation)
    end

    phoneObjects[source] = phone

    debugprint("Created phone entity for source " .. source)
end

local function HandleStateBagChange(bagName, key, value, reserved, replicated)
    local source, ped = GetPlayerDataFromStateBag(bagName)

    if not source or source == GetPlayerServerId(PlayerId()) then
        return
    end

    if not ped then
        debugprint("Ped not found")
        return
    end

    if value then
        SpawnAndAttachPhoneToPlayer(source, ped)
    else
        Wait(0) -- allow states to update

        if not IsPhoneOpen(source) then
            DeletePlayerPhoneEntity(source)
        end
    end
end

---@diagnostic disable-next-line: param-type-mismatch
AddStateBagChangeHandler("phoneOpen", nil, HandleStateBagChange)

---@diagnostic disable-next-line: param-type-mismatch
AddStateBagChangeHandler("onCallWith", nil, HandleStateBagChange)

---@diagnostic disable-next-line: param-type-mismatch
AddStateBagChangeHandler("instapicIsLive", nil, HandleStateBagChange)

RegisterNetEvent("onPlayerDropped", function(src)
    DeletePlayerPhoneEntity(src)
end)
