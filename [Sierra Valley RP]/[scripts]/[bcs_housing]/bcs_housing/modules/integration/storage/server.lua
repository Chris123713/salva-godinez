function RegisterStorage(identifier, furniture, home, aptId, owner)
    local stash = {
        id = 'storage:' .. identifier .. ':' .. furniture.identifier,
        label = home.name .. ' ' .. 'storage:' .. identifier .. ':' .. furniture.identifier,
        slots = tonumber(ModelList[furniture.model] and
            ModelList[furniture.model].slots or Config.FurnitureStorage.slots),
        weight = tonumber(ModelList[furniture.model] and
            ModelList[furniture.model].weight or Config.FurnitureStorage.weight),
        owner = owner or home:GetOwner(aptId)
    }
    if Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:RegisterStash(stash.id, stash.label, stash.slots, stash.weight, stash.owner, nil,
            home:GetCoordsFromOffset(furniture.coords))
    elseif Config.Inventory == 'origen_inventory' then
        exports.origen_inventory:RegisterStash(stash.id .. (aptId and ':' .. aptId or ''), {
            label = stash.label,
            slots = stash.slots,
            weight = stash.weight
        })
    end
end

if Config.Inventory == 'ox_inventory' then
    local hookId = exports.ox_inventory:registerHook('openInventory', function(payload)
        local xPlayer = GetPlayerFromId(payload.source)
        local result = SplitString(payload.inventoryId, ':')
        local home = Homes[result[2]]
        if home and xPlayer then
            if not Config.robbery.storageRobbery and not home:isKeyOwner(xPlayer.identifier) and not IsPolice(xPlayer) then
                return false
            end
            return true
        end
        return false
    end, {
        print = false,
        inventoryFilter = {
            '^storage:[%w]+',
        }
    })
end

function RegisterNonFurnitureStorage(id, label, slots, weight, aptId, owner, coords)
    if Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:RegisterStash(id, label, tonumber(slots), tonumber(weight), aptId and true or owner, nil,
            coords)
    elseif Config.Inventory == 'origen_inventory' then
        exports.origen_inventory:RegisterStash(id .. (aptId and ':' .. aptId or ''), {
            label = label,
            slots = slots,
            weight = weight
        })
    end
end
