function AddItemInventory(source, item, count, metadata)
    if Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:AddItem(source, item, count or 1, metadata)
    elseif Config.Inventory == 'qb-inventory' or Config.Inventory == 'lj-inventory' or Config.Inventory == 'ak47_inventory' or Config.Inventory == 'ps_inventory' then
        exports[Config.Inventory]:AddItem(source, item, count or 1, nil, metadata)
    elseif Config.Inventory == 'core_inventory' then
        exports.core_inventory:addItem(source, item, count or 1, metadata)
    elseif Config.Inventory == 'tgiann' then
        exports.tgiann_inventory:AddItem(source, item, count or 1, nil, metadata)
    elseif Config.Inventory == 'origen_inventory' then
        exports.origen_inventory:addItem(source, item, count or 1, metadata)
    end
end

function RemoveItemInventory(source, item, count, metadata)
    if Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:RemoveItem(source, item, count or 1, nil, metadata)
    end

    if Config.Inventory == 'qb-inventory' or Config.Inventory == 'lj-inventory' or Config.Inventory == 'ak47_inventory' or Config.Inventory == 'ps_inventory' then
        local player = GetPlayerFromId(source)
        if not player then return end
        local items = player.PlayerData.items
        for k, v in pairs(items) do
            if v?.name == item and v.info?.model == metadata.model then
                exports[Config.Inventory]:RemoveItem(source, item, count or 1)
                break
            end
        end
    end

    if Config.Inventory == 'core_inventory' then
        local items = exports.core_inventory:getItems(source, item)
        for k, v in pairs(items) do
            if v?.metadata?.model == metadata.model then
                exports.core_inventory:removeItem(source, item, count or 1, v.info?.id)
                break
            end
        end
    end

    if Config.Inventory == 'tgiann' then
        local itemData = exports["tgiann-inventory"]:GetItemByName(source, item, metadata)
        if itemData then
            exports.tgiann_inventory:RemoveItem(source, item, count or 1, itemData.slot, metadata)
        end
    end

    if Config.Inventory == 'origen_inventory' then
        local items = exports.origen_inventory:getItem(source, item, metadata)
        for k, v in pairs(items) do
            if v?.metadata?.model == metadata.model then
                exports.origen_inventory:removeItem(source, item, count or 1, metadata, v.slot)
                break
            end
        end
    end
end

function ClearInventory(id)
    if Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:ClearInventory(id)
    elseif Config.Inventory == 'qb-inventory' or Config.Inventory == 'lj-inventory' or Config.Inventory == 'ak47_inventory' or Config.Inventory == 'ps_inventory' then
        exports[Config.Inventory]:ClearInventory(id)
    elseif Config.Inventory == 'core_inventory' then
        exports.core_inventory:clearInventory(id)
    elseif Config.Inventory == 'tgiann' then
        exports.tgiann_inventory:ClearInventory(id)
    elseif Config.Inventory == 'origen_inventory' then
        exports.origen_inventory:ClearInventory(id)
    end
end

CreateThread(function()
    RegisterUsableItem(Config.FurnitureItem, function(source)
        TriggerClientEvent('Housing:client:UseFurniture', source)
    end)
end)
